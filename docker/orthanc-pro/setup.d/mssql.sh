#!/usr/bin/env bash
set -o errexit

if [[ $MSSQL_LICENSE_STRING && $MSSQL_CONNECTION_STRING ]]; then
	licensestring=$MSSQL_LICENSE_STRING
	connectionstring=$MSSQL_CONNECTION_STRING
else
	licenseStringFile=/run/secrets/${MSSQL_LICENSE_STRING_SECRET:-mssql-licensestring}
	connectionStringFile=/run/secrets/${MSSQL_CONNECTION_STRING_SECRET:-mssql-connectionstring}

	if [[ ! -e "$licenseStringFile" || ! -e "$connectionStringFile" ]]; then
		echo "MSSQL-SETUP: Use mssql-licensestring and mssql-connectionstring Docker secrets to enable" >&2
		exit 0
	fi

	licensestring=$(<"$licenseStringFile")
	connectionstring=$(<"$connectionStringFile")
fi

echo "MSSQL-SETUP: Found license and strings files, writing mssql.json and enabling Microsoft SQL Server Index plugin" >&2
cat <<EOF >/etc/orthanc/mssql.json
{
	"MSSQL" : {
		"EnableIndex": true,
		"EnableStorage": false,
		"ConnectionString": "$connectionstring",
		"LicenseString": "$licensestring"
	}
}
EOF
mv /usr/share/orthanc/plugins{-disabled,}/libOrthancMsSqlIndex.so