<cfimport taglib="udf" prefix="udf" />

<cfif cmd eq "auth">
	<cfquery datasource="#application.dsn#" name="qLogin">
		SELECT UserID FROM users
		WHERE
			Username = <cfqueryparam value="#form.Username#" cfsqltype="cf_sql_varchar" maxlength="32" /> AND
			Userpass = <cfqueryparam value="#hash(form.Userpass)#" cfsqltype="cf_sql_varchar" maxlength="32" />
	</cfquery>
	<cfif qLogin.recordcount gt 0>
		<cfset session.UserID = qLogin.UserID />
		<cfif session.Destination neq "">
			<cfset gopath = session.Destination />
			<cfset session.Destination = "" />
			<cflocation addtoken="false" url="#gopath#" />
		</cfif>
	<cfelse>
		<cflocation addtoken="false" url="#application.rooturl#?cmd=failed" />
	</cfif>
<cfelseif cmd eq "logout">
	<cfset session.UserID = "" />
</cfif>

<udf:wrapper>

<cfoutput>

	<cfif listfindnocase("login,failed",cmd)>
		<cfif cmd eq "failed">
			<p class="error">Access denied.</p>
		</cfif>
		<p>Please login:</p>
		<form action="#application.rooturl#" method="post">
		<input type="hidden" name="cmd" value="auth" />
		Username:<br />
		<input type="text" name="Username" value="" /><br /><br />
		Password:<br />
		<input type="password" name="Userpass" value="" /><br /><br />
		<input type="submit" value="Login" />
		</form>
	<cfelse>
		<cfif session.UserID eq "">
			<p>Use <cfoutput><strong>#application.rooturl#</strong></cfoutput> as your OpenID URL.</p>
			<p>Make sure that this site is accessible by OpenID consumer.</p>
		<cfelse>
			<p><a href="#application.rooturl#?cmd=logout">Logout</a></p>
		</cfif>
	</cfif>

</cfoutput>

</udf:wrapper>