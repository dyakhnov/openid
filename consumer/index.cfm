<html>

<head>
	<title>OpenID CFC Example</title>
	<link href="styles.css" rel="stylesheet" type="text/css" />
	<script src="https://www.idselector.com/selector/c7749d5e1939c42dbf5db85bdac728d02fc5fe91" id="__openidselector" type="text/javascript" charset="utf-8"></script>
</head>

<body>

<h1>OpenID CFC Example</h1>

<form action="openidauth.cfm" method="post">
<input type="hidden" name="cmd" value="auth" />
OpenID Identity:<br />
<input type="text" id="openid_identifier" name="openid_identity" value="" size="25" />
<input type="submit" value="Login" />
</form>

</body>

</html>