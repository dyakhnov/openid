<html>

<head>
	<title>OpenID CFC Example</title>
	<link href="styles.css" rel="stylesheet" type="text/css" />
</head>

<body>

<!--- Default command --->
<cfparam name="cmd" type="string" default="process" />

<!---
Use of client instead of default session scope:
<cfset openIDSession = CreateObject("component", "cfc.ClientScopeOpenIDSession").init() />
<cfset oConsumer = CreateObject("component", "cfc.OpenIDConsumer2").init(openIDSession) />
--->

<cfset openIDSession = CreateObject("component", "cfc.SessionScopeOpenIDSession").init() />
<cfset oConsumer = CreateObject("component", "cfc.OpenIDConsumer2").init(openIDSession) />

<h1>OpenID CFC Authenticator</h1>

<cfif cmd eq "auth">

	<cfset authArgs = StructNew() />
	<cfset authArgs.identifier = form.openid_identity />
	<cfset authArgs.returnURL = "http#IIF(cgi.https eq 'on',DE('s'),DE(''))#://#cgi.http_host##cgi.script_name#" />
	<cfset authArgs.sregRequired = "nickname" />
	<cfset authArgs.sregOptional = "email,fullname,dob,country" />
	<cfset authArgs.axRequired = "email,fullname,firstname,lastname" />
	<cfset authArgs.ax.email = "http://axschema.org/contact/email" />
	<cfset authArgs.ax.fullname = "http://axschema.org/namePerson" />
	<cfset authArgs.ax.firstname = "http://axschema.org/namePerson/first" />
	<cfset authArgs.ax.lastname = "http://axschema.org/namePerson/last" />

	<cfif not oConsumer.authenticate(authArgs)>
		<p>Can't find OpenID server</p>
	</cfif>

<cfelseif cmd eq "process">

	<cfset openID = oConsumer.verifyAuthentication() />

	<cfif openID.result is "success">
		<p class="info">INFO: <span><cfoutput>#openID.resultMsg#</cfoutput></span></p>
	<cfelse>
		<p class="error">ERROR: <span><cfoutput>#openID.resultMsg#</cfoutput></span></p>
	</cfif>

	<p><a href="index.cfm">&larr; go back</a></p>

	<h3>OpenID Result</h3>
	<cfdump var="#OpenID#">

</cfif>

</body>

</html>