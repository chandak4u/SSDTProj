#!/bin/bash
set -e

/opt/mssql/bin/sqlservr &
SQL_PID=$!

#echo "Waiting for SQL Server..."
# sleep 30s
# for i in {1..30}; do
#     if /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "${MSSQL_SA_PASSWORD}" -C -Q "SELECT 1" &> /dev/null; then
#         echo "SQL Server ready!"
#         break
#     fi
#     sleep 2s
# done
# end of SQL Server readiness loop (currently disabled)

# Set database name from environment variable or use default
DATABASE_NAME="${DATABASE_NAME:-AdventureWorks2019}"

# Build connection string
#CS="Server=localhost;Database=${DATABASE_NAME};User Id=sa;Password=${MSSQL_SA_PASSWORD};TrustServerCertificate=True"

echo "Deploying database: ${DATABASE_NAME}..."

/opt/sqlpackage/sqlpackage /Action:Publish \
  /SourceFile:"/usr/src/app/AdventureWorks2019.dacpac" \
  /TargetConnectionString:"${CS}" 
	


echo "Database ready!"
wait $SQL_PID
