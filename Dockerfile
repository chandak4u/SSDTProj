# SQL Server Database Container
FROM mcr.microsoft.com/mssql/server:2022-latest

ENV ACCEPT_EULA=Y
ENV MSSQL_SA_PASSWORD=YourStrong@Passw0rd
ENV MSSQL_PID=Developer

WORKDIR /usr/src/app

USER root

# Install unzip for SqlPackage
RUN apt-get update && \
    apt-get install -y unzip libicu70 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Download and install SqlPackage
ADD https://aka.ms/sqlpackage-linux /tmp/sqlpackage.zip
RUN unzip -q /tmp/sqlpackage.zip -d /opt/sqlpackage && \
    chmod +x /opt/sqlpackage/sqlpackage && \
    ln -s /opt/sqlpackage/sqlpackage /usr/local/bin/sqlpackage && \
    rm /tmp/sqlpackage.zip

COPY bin/Output/*.dacpac ./AdventureWorks2019.dacpac

COPY entrypoint.sh /usr/src/app/entrypoint.sh

RUN chmod +x /usr/src/app/entrypoint.sh

EXPOSE 1433

ENTRYPOINT ["/usr/src/app/entrypoint.sh"]
