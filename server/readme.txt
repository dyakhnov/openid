Title:		OpenIDServer CFC
Version:	0.1
Date:		2 March 2007
Author: 	Dmitry Yakhnov
Email:		dmitry@yakhnov.info
Website:	http://www.yakhnov.info/
			http://www.coldfusiondeveloper.com.au/


DESCRIPTION
------------------------------

This is an OpenID auth framework server component including single-server multiple-users basic example.

REQUIREMENTS
------------------------------

* ColdFusion MX server
* MySQL server

INSTALLATRION
------------------------------

1. Create database and populate tables with MySQL server using mysql.sql file;

2. Create CF datasource pointing to that MySQL database (default name is openid);

3. Update config settings in Application.cfm (if necessary);

4. Make sure OpenID consumer instance can access OpenID server;

5. Test account credentials are:
		Username: test
		Password: test
