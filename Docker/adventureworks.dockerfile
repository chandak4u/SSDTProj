# About the images that we use in this DockerFile https://hub.docker.com/_/microsoft-mssql-tools?tab=description
FROM mcr.microsoft.com/mssql-tools

# # Switch to root user for installation (if not already root)
# USER root

# sqlpackage
RUN apt-get update \
    && apt-get install -y unzip wget libicu55 \
    && wget -q -O /var/opt/sqlpackage.zip https://go.microsoft.com/fwlink/?linkid=2185670 \
    && unzip -qq /var/opt/sqlpackage.zip -d /var/opt/sqlpackage \
    && rm /var/opt/sqlpackage.zip \
    && chmod a+x /var/opt/sqlpackage/sqlpackage \
    && ln -s /var/opt/sqlpackage/sqlpackage /usr/bin/sqlpackage \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# powershell 7
RUN apt-get update \
    && wget https://github.com/PowerShell/PowerShell/releases/download/v7.4.1/powershell-lts_7.4.1-1.deb_amd64.deb \
    && dpkg -i powershell-lts_7.4.1-1.deb_amd64.deb \
    && apt-get install -f \
    && rm powershell-lts_7.4.1-1.deb_amd64.deb \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /home/app

COPY bin/Release /home/app
 
# ARG branch=""
# ARG commit=""
# ARG version=""
# ARG build=""
# LABEL com.amsoftware.build.branch=$branch
# LABEL com.amsoftware.build.commit=$commit
# LABEL com.amsoftware.build.version=$version
# LABEL com.amsoftware.build.buildmetadata=$build
# ENV SOURCE_COMMIT=$commit
# ENV SOURCE_BRANCH=$branch
# ENV SOURCE_VERSION=$version
# ENV SOURCE_BUILD=$build

COPY Docker/scripts/deploy_dacpac.ps1 /home/app
RUN ["/bin/sh", "-c", "chmod a+x /home/app/deploy_dacpac.ps1"]
# removing root user context
# USER $APP_UID
ENTRYPOINT ["pwsh", "-File", "/home/app/deploy_dacpac.ps1"]