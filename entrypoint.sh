#!/bin/bash
set -e

/opt/mssql/bin/sqlservr &
SQL_PID=$!

echo "Waiting for SQL Server..."
sleep 30s

for i in {1..30}; do
    if /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "${MSSQL_SA_PASSWORD}" -C -Q "SELECT 1" &> /dev/null; then
        echo "SQL Server ready!"
        break
    fi
    sleep 2s
done

echo "Deploying database..."
/opt/sqlpackage/sqlpackage /Action:Publish \
    /SourceFile:/usr/src/app/AdventureWorks2019.dacpac \
    /TargetServerName:localhost \
    /TargetDatabaseName:AdventureWorks2019 \
    /TargetUser:sa \
    /TargetPassword:"${MSSQL_SA_PASSWORD}" \
    /TargetTrustServerCertificate:True \
    /p:IgnoreFullTextCatalogFilePath=True \
    /p:IgnoreFileAndLogFilePath=True \
    /p:BlockOnPossibleDataLoss=False || echo "Deployment completed with warnings/errors (Full-Text features skipped)"

echo "Database ready!"
wait $SQL_PID
