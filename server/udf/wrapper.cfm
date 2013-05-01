<cfswitch expression="#thisTag.ExecutionMode#">

<cfcase value="start">
<html>
<head>
	<title>OpenIDServer CFC Example</title>
	<cfoutput>
		<link rel="openid.server" href="#application.rooturl#openidserver.cfm" />
		<link rel="openid.delegate" href="#application.rooturl#" />
	</cfoutput>
	<style type="text/css">
		body {
			font-family: Arial, Helvetica;
			font-size: 80%;
		}
		p.error {
			font-size: 90%;
			color: #c00;
			font-weight: bold;
		}
	</style>
</head>
<body>
</cfcase>

<cfcase value="end">
</body>
</html>
</cfcase>

</cfswitch>