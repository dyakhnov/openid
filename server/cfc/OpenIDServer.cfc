<!--- Document Information -----------------------------------------------------

Title:		OpenIDServer.cfc

Author:		Dmitry Yakhnov
Email:		dmitry@yakhnov.info

Website:	http://www.yakhnov.info/
			http://www.coldfusiondeveloper.com.au/

Purpose:	Server library for OpenID auth framework

Modification Log:

Name				Date			Version		Description
================================================================================
Dmitry Yakhnov		23/01/2007		0.0.1		Created
Dmitry Yakhnov		02/03/2007		0.1			Released
Dmitry Yakhnov		27/04/2007		0.1.1		Thread-safe version
Dmitry Yakhnov		13/07/2007		0.1.2		Minor fix

------------------------------------------------------------------------------->
<cfcomponent name="OpenIDServer" hint="Server library for OpenID auth framework">

<cfset instance = StructNew() />

<cffunction name="init" returntype="OpenIDServer" access="public" output="false">
	<cfargument name="DSN" type="string" required="true" />

	<cfset instance.keyChars = "" />

	<cfloop index="i" from="48" to="57">
		<cfset instance.keyChars = instance.keyChars & chr(i) />
	</cfloop>
	<cfloop index="i" from="97" to="122">
		<cfset instance.keyChars = instance.keyChars & chr(i) />
	</cfloop>
	<cfloop index="i" from="65" to="90">
		<cfset instance.keyChars = instance.keyChars & chr(i) />
	</cfloop>

	<cfset instance.dsn = arguments.DSN />
	<cfset instance.nl = chr(10) />
	<cfset instance.ttl = 120 />

	<cfreturn this />

</cffunction>

<cffunction name="randomKey" returntype="string">
	<cfargument name="Length" type="numeric" required="true" />

	<cfset var randomKey = "" />
	<cfset var i = 0 />
	<cfset var chars = "" />

	<cfset randomize(right(gettickcount(),5)) />

	<cfloop index="i" from="1" to="#arguments.Length#">
		<cfset randomKey = randomKey & mid(instance.keyChars,randrange(1,len(instance.keyChars)),1) />
	</cfloop>

	<cfreturn randomKey />

</cffunction>

<cffunction name="hex2bin" returntype="any">
	<cfargument name="inputString" type="string" required="true" />

	<cfset var outStream = createobject("java","java.io.ByteArrayOutputStream").init() />
	<cfset var inputLength = len(arguments.inputString) />
	<cfset var outputString = "" />
	<cfset var i = 0 />
	<cfset var ch = "" />

	<cfif inputLength mod 2 neq 0>
		<cfset arguments.inputString = "0" & inputString />
	</cfif>

	<cfloop from="1" to="#inputLength#" index="i" step="2">
		<cfset ch = Mid(inputString, i, 2) />
		<cfset outStream.write(javacast("int", InputBaseN(ch, 16))) />
	</cfloop>

	<cfset outStream.flush() />
	<cfset outStream.close() />

	<cfreturn outStream.toByteArray() />

</cffunction>

<cffunction name="scope2form" returntype="string">
	<cfargument name="Scope" type="struct" required="true" />

	<cfset var outString = "" />

	<cfsetting enablecfoutputonly="true" />
	<cfsavecontent variable="outString">
		<cfloop collection="#arguments.Scope#" item="k">
			<cfif findnocase("openid.",k)>
				<cfoutput><input type="hidden" name="#k#" value="#arguments.Scope[k]#" /></cfoutput>
			</cfif>
		</cfloop>
	</cfsavecontent>
	<cfsetting enablecfoutputonly="false" />

	<cfreturn outString />

</cffunction>

<cffunction name="insertAssociate" returntype="void">
	<cfargument name="Handle" type="string" required="true" />
	<cfargument name="Secret" type="string" required="true" />

	<cfquery datasource="#instance.dsn#">
		INSERT INTO openid_sessions (dtCreated,Handle,Secret)
		VALUES (
			#now()#,
			<cfqueryparam value="#arguments.Handle#" cfsqltype="cf_sql_varchar" maxlength="32" />,
			<cfqueryparam value="#arguments.Secret#" cfsqltype="cf_sql_varchar" maxlength="20" />
		)
	</cfquery>

</cffunction>

<cffunction name="doAssociate" returntype="void">

	<cfset var Handle = "" />
	<cfset var Secret = "" />
	<cfset var outMessage = "" />

	<cfset Handle = randomKey(32) />
	<cfset Secret = randomKey(20) />
	<cfset insertAssociate(Handle,Secret) />

	<cfset outMessage = outMessage & "assoc_type:HMAC-SHA1" & instance.nl />
	<cfset outMessage = outMessage & "expires_in:#instance.ttl#" & instance.nl />
	<cfset outMessage = outMessage & "assoc_handle:#Handle#" & instance.nl />
	<cfset outMessage = outMessage & "mac_key:#tobase64(Secret)#" & instance.nl />

	<cfcontent reset="true" /><cfoutput>#outMessage#</cfoutput><cfabort />

</cffunction>

<cffunction name="doAuthentication" returntype="void">
	<cfargument name="Scope" type="struct" required="true" />

	<cfset var isValid = "" />
	<cfset var outMessage = "" />
	<cfset var qSession = "" />

	<cfset isValid = "false" />

	<cfquery datasource="#instance.dsn#" name="qSession">
		SELECT * FROM openid_sessions
		WHERE Handle = <cfqueryparam value="#arguments.Scope['openid.assoc_handle']#" cfsqltype="cf_sql_varchar" maxlength="32" />
	</cfquery>

	<cfif qSession.recordcount gt 0>
		<cfset isValid = "true" />
		<!--- TODO: check sig --->
	</cfif>

	<cfset outMessage = outMessage & "is_valid:#isValid#" & instance.nl />

	<cfcontent reset="true" /><cfoutput>#outMessage#</cfoutput><cfabort />

</cffunction>

<cffunction name="insertTrustedRoot" returntype="void">
	<cfargument name="TrustedRoot" type="string" required="true" />

	<cfset var qSession = "" />

	<cfquery datasource="#instance.dsn#" name="qSession">
		INSERT INTO openid_trusted (TrustedID,TrustedRoot)
		VALUES (
			<cfqueryparam value="#createuuid()#" cfsqltype="cf_sql_idstamp" maxlength="35" />,
			<cfqueryparam value="#arguments.TrustedRoot#" cfsqltype="cf_sql_varchar" maxlength="255" />
		)
	</cfquery>

</cffunction>

<cffunction name="getTrustedRoot" returntype="string">
	<cfargument name="TrustedRoot" type="string" required="true" />

	<cfset var qSession = "" />

	<cfquery datasource="#instance.dsn#" name="qSession">
		SELECT TrustedID FROM openid_trusted
		WHERE TrustedRoot = <cfqueryparam value="#arguments.TrustedRoot#" cfsqltype="cf_sql_varchar" maxlength="255" />
	</cfquery>

	<cfif qSession.recordcount gt 0>
		<cfreturn qSession.TrustedID />
	<cfelse>
		<cfreturn "" />
	</cfif>

</cffunction>

<cffunction name="getSecret" returntype="string">
	<cfargument name="Handle" type="string" required="true" />

	<cfset var qSession = "" />

	<cfquery datasource="#instance.dsn#" name="qSession">
		SELECT Secret FROM openid_sessions
		WHERE Handle = <cfqueryparam value="#arguments.Handle#" cfsqltype="cf_sql_varchar" maxlength="32" />
	</cfquery>

	<cfif qSession.recordcount gt 0>
		<cfreturn qSession.Secret />
	<cfelse>
		<cfreturn "" />
	</cfif>

</cffunction>

</cfcomponent>