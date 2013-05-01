<cfsilent>

	<cfapplication name="OpenIDServer" sessionmanagement="true" />
	
	<cfif not isDefined("application.loaded") or isDefined("url.updateapp")>

		<cfset application.dsn = "openid" />
		<cfset application.allowed = "nickname,email,fullname,dob,gender,postcode,country,language,timezone" />
		<cfset application.rooturl = "http://" & cgi.http_host & left(cgi.script_name,len(cgi.script_name)-len(spanexcluding(reverse(cgi.script_name),"/"))) />
		<cfset application.loaded = now() />

	</cfif>

	<cfparam name="session.UserID" type="string" default="" />
	<cfparam name="session.Destination" type="string" default="" />

	<cfparam name="cmd" type="string" default="" />

</cfsilent>
