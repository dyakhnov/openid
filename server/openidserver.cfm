<cfprocessingdirective pageencoding="utf-8" />
<cfimport prefix="udf" taglib="udf/" />

<!--- Remove expired sessions (TTL=120sec) --->
<cfquery datasource="#application.dsn#">
	DELETE FROM openid_sessions
	WHERE dtCreated < <cfqueryparam value="#dateadd("n",-2,now())#" cfsqltype="cf_sql_date" />
</cfquery>


<cfset oOpenIDServer = createobject("component","cfc.OpenIDServer").init(application.dsn) />

<cfparam name="openid_mode" type="string" default="" />

<cfif structkeyexists(url,"openid.mode")>
	<cfset openid_mode = url['openid.mode'] />
<cfelseif structkeyexists(form,"openid.mode")>
	<cfset openid_mode = form['openid.mode'] />
</cfif>

<cfswitch expression="#openid_mode#">
	<cfcase value="associate">
		<cfset oOpenIDServer.doAssociate() />
	</cfcase>
	<cfcase value="check_authentication">
		<cfset oOpenIDServer.doAuthentication(form) />
	</cfcase>
	<cfcase value="checkid_setup">
		<cfif session.UserID neq "">
			<cfset Handle = "" />
			<cfif cmd eq "go">
				<cfset sOpenID = duplicate(form) />
				<cfif not isDefined("form.submit_no")>
					<cfif isDefined("form.submit_yes_always")>
						<cfset oOpenIDServer.insertTrustedRoot(form['openid.trust_root']) />
					</cfif>
					<cfif not structkeyexists(sOpenID,"openid.assoc_handle")>
						<cfset Handle = oOpenIDServer.randomKey(32) />
						<cfset Secret = oOpenIDServer.randomKey(20) />
						<cfset oOpenIDServer.insertAssociate(Handle,Secret) />
					<cfelse>
						<cfset Handle = sOpenID['openid.assoc_handle'] />
						<cfset Secret = oOpenIDServer.getSecret(Handle) />
					</cfif>
				<cfelse>
					<cfset goURL = sOpenID['openid.return_to'] & iif(findnocase("?",sOpenID['openid.return_to']),de("&"),de("?")) />
					<cflocation addtoken="false" url="#goURL#openid.mode=cancel" />
				</cfif>
			<cfelse>
				<cfset sOpenID = duplicate(url) />
				<cfif structkeyexists(sOpenID,"openid.trust_root") and oOpenIDServer.getTrustedRoot(sOpenID['openid.trust_root']) neq "">
					<cfset Handle = oOpenIDServer.randomKey(32) />
					<cfset Secret = oOpenIDServer.randomKey(20) />
					<cfset oOpenIDServer.insertAssociate(Handle,Secret) />
				<cfelseif structkeyexists(sOpenID,"openid.assoc_handle")>
					<cfset Handle = sOpenID['openid.assoc_handle'] />
					<cfset Secret = oOpenIDServer.getSecret(Handle) />
				</cfif>
			</cfif>
			<cfif Handle neq "">
				<cfquery datasource="#application.dsn#" name="qProfile">
					SELECT * FROM users
					WHERE UserID = <cfqueryparam value="#session.UserID#" cfsqltype="cf_sql_idstamp" />
				</cfquery>
				<cfset goURL = sOpenID['openid.return_to'] & iif(findnocase("?",sOpenID['openid.return_to']),de("&"),de("?")) />
				<cfset goURL = goURL & "openid.mode=id_res&openid.identity=#urlencodedformat(sOpenID['openid.identity'])#&openid.return_to=#urlencodedformat(sOpenID['openid.return_to'])#" />
				<cfset signed = "mode,identity,return_to" />
				<cfset tokens = "" />
				<cfset tokens = tokens & "mode:id_res" & chr(10) />
				<cfset tokens = tokens & "identity:#sOpenID['openid.identity']#" & chr(10) />
				<cfset tokens = tokens & "return_to:#sOpenID['openid.return_to']#" & chr(10) />
				<cfif structkeyexists(sOpenID,"openid.sreg.required")>
					<cfloop list="#sOpenID['openid.sreg.required']#" index="i">
						<cfloop query="qProfile">
							<cfif findnocase(i,application.allowed) and findnocase(i,qProfile.columnList)>
								<cfset signed = signed & ",sreg.#i#" />
								<cfset tokens = tokens & "sreg.#i#:#qProfile[i][qProfile.currentrow]#" & chr(10) />
								<cfset goURL = goURL & "&openid.sreg.#i#=#qProfile[i][qProfile.currentrow]#" />
							</cfif>
						</cfloop>
					</cfloop>
				</cfif>
				<udf:hmac key="#Secret#" data="#tokens#" hash_function="sha1" output_bits="160">
				<cfset sig = oOpenIDServer.hex2bin(digest,"hex") />
				<cfset goURL = goURL & "&openid.signed=#signed#&openid.sig=#tobase64(sig)#" />
				<cfset goURL = goURL & "&openid.assoc_handle=#Handle#&openid.trust_root=#urlencodedformat(sOpenID['openid.trust_root'])#" />
				<cflocation addtoken="false" url="#goURL#" />
			<cfelse>
				<udf:wrapper>
					<p>Another site on the web wants to validate your identity.</p>
					<p>The address wanting permission is:</p>
					<p style="padding:1em;background-color:#dddddd;border:1px solid #000000;font-size:115%;"><cfoutput>#sOpenID['openid.trust_root']#</cfoutput></p>
					<p>Do you want to pass your identity to them?</p>
					<form method="post" action="openidserver.cfm">
					<input type="hidden" name="cmd" value="go" />
					<cfoutput>#oOpenIDServer.scope2form(url)#</cfoutput>
					<input type="submit" name="submit_yes_once" value="Yes; just this time." />
					<input type="submit" name="submit_yes_always" value="Yes; always." />
					<input type="submit" name="submit_no" value="No." />
					</form>
				</udf:wrapper>
			</cfif>
		<cfelse>
			<cfset goURL = "" />
			<cfloop collection="#url#" item="k">
				<cfif goURL eq "">
					<cfset goURL = "?" />
				<cfelse>
					<cfset goURL = goURL & "&" />
				</cfif>
				<cfset goURL = goURL & k & "=" & url[k] />
			</cfloop>
			<cfset session.Destination = cgi.script_name & goURL />
			<cflocation addtoken="false" url="#application.rooturl#?cmd=login" />
		</cfif>
	</cfcase>
	<cfdefaultcase>
		<udf:wrapper>
			<p>This is an OpenID server endpoint, not a human-readable resource.</p>
			<p>For more information, see <a href="http://openid.net/">http://openid.net/</a></p>
		</udf:wrapper>
	</cfdefaultcase>
</cfswitch>
