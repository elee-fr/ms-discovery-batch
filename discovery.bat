@ECHO off
chcp 850>nul

REM This Batch script retrieves both hardware and software information on a
REM Windows-operated server, persists them to a text file and uploads them to an
REM FTP server. See the README.md file for more details.

REM Default local configuration, as in config.example.bat. The configuration
REM can be edited directly here, or in an external config.bat file.

SET OUTPUT_DIR=C:\

SET FTP_UPLOAD=0
SET FTP_USER=anonymous
SET FTP_PASSWORD=anonymous@example.com
SET FTP_HOST=xx.xx.xx.xx
SET FTP_PORT=21

IF EXIST config.bat call config.bat

REM Retrieve host name and fully qualified domain name

FOR /f "usebackq tokens=*" %%i in (`hostname`) DO (
    SET HOSTNAME=%%i
)
FOR /f "usebackq skip=1 tokens=1 delims= " %%i in (`wmic computersystem get domain`) DO (
    SET FQDN=%%i
    GOTO :setOutputName
)

:setOutputName
FOR /F %%A IN ('WMIC OS GET LocalDateTime ^| FINDSTR \.') DO @SET B=%%A
SET OUTPUT="%OUTPUT_DIR%\%HOSTNAME%.%FQDN%_%B:~0,4%-%B:~4,2%-%B:~6,2%_%time:~-11,2%-%time:~-8,2%-%time:~-5,2%.txt"

ECHO === Global === >> %OUTPUT%
ECHO Hostname: %HOSTNAME% >> %OUTPUT%
ECHO FQDN: %FQDN% >> %OUTPUT%

REM Retrieve OS version and language

FOR /f "usebackq skip=1 tokens=*" %%i in (`wmic os get caption`) DO (
    SET OS=%%i
    GOTO :printOS
)
:printOS
ECHO OS Name: %OS% >> %OUTPUT%

REM Retrieve OS version

FOR /f "tokens=4 delims=[] " %%i IN ('ver') DO SET VERSION=%%i
ECHO OS Version: %VERSION% >> %OUTPUT%

REM Retrieve server manufacturer and model

FOR /f "usebackq skip=1 tokens=*" %%i in (`wmic computersystem get manufacturer`) DO (
    SET MANUFACTURER=%%i
    GOTO :printManufacturer
)
:printManufacturer
ECHO Server Manufacturer: %MANUFACTURER% >> %OUTPUT%

FOR /f "usebackq skip=1 tokens=*" %%i in (`wmic computersystem get model`) DO (
    SET MODEL=%%i
    GOTO :printModel
)
:printModel
ECHO Server Model: %MODEL% >> %OUTPUT%

REM Retrieve processor, cores and threads information

FOR /f "usebackq skip=1 tokens=*" %%i in (`wmic CPU get name`) DO (
    SET CPUMODEL=%%i
    GOTO :printCpuModel
)
:printCpuModel
ECHO CPU Model: %CPUMODEL% >> %OUTPUT%

FOR /f "usebackq skip=1 tokens=*" %%i in (`wmic computersystem get NumberOfProcessors`) DO (
    SET CPU=%%i
    GOTO :printCpuCount
)
:printCpuCount
ECHO Total number of CPU: %CPU% >> %OUTPUT%

FOR /f "usebackq skip=1 tokens=*" %%i in (`wmic CPU get NumberOfCores`) DO (
    SET CORES=%%i
    GOTO :printCores
)
:printCores
ECHO Number of cores per CPU: %CORES% >> %OUTPUT%

FOR /f "usebackq skip=1 tokens=*" %%i in (`wmic CPU get NumberOfLogicalProcessors`) DO (
    SET THREADS=%%i
    GOTO :printThreads
)
:printThreads
ECHO Number of threads per CPU: %THREADS% >> %OUTPUT%

REM Retrieve enabled MAC addresses

ECHO === MAC addresses === >> %OUTPUT%
FOR /f "usebackq tokens=*" %%L in (`wmic NICCONFIG WHERE "IPEnabled=true" GET IPAddress^,macaddress /format:csv`) DO (
    FOR /f "delims=" %%M in ("%%L") DO (
        ECHO %%M >> %OUTPUT%
    )
)

REM Retrieve installed Microsoft products

ECHO === Installed products === >> %OUTPUT%
FOR /f "usebackq tokens=*" %%A in (`wmic product where "vendor like 'Microsoft%%'" get name^,version^,installdate^,vendor /format:csv`) DO (
    FOR /f "delims=" %%B in ("%%A") DO (
        ECHO %%B >> %OUTPUT%
    )
)

REM Retrieve SQL Server instances versions and editions

ECHO === SQL Server instances === >> %OUTPUT%
ECHO Version,Edition,ProductVersion >> %OUTPUT%

where /q sqlcmd
IF %ERRORLEVEL% NEQ 0 (
    GOTO :end
)

SET SQL=      SET NOCOUNT ON;
SET SQL=%SQL% SELECT
SET SQL=%SQL%   CASE
SET SQL=%SQL%      WHEN CONVERT(VARCHAR, SERVERPROPERTY('ProductVersion')) LIKE '7%%' THEN 'SQL Server 7.0'
SET SQL=%SQL%      WHEN CONVERT(VARCHAR, SERVERPROPERTY('ProductVersion')) LIKE '8%%' THEN 'SQL Server 2000'
SET SQL=%SQL%      WHEN CONVERT(VARCHAR, SERVERPROPERTY('ProductVersion')) LIKE '9%%' THEN 'SQL Server 2005'
SET SQL=%SQL%      WHEN CONVERT(VARCHAR, SERVERPROPERTY('ProductVersion')) LIKE '10.0%%' THEN 'SQL Server 2008'
SET SQL=%SQL%      WHEN CONVERT(VARCHAR, SERVERPROPERTY('ProductVersion')) LIKE '10.5%%' THEN 'SQL Server 2008 R2'
SET SQL=%SQL%      WHEN CONVERT(VARCHAR, SERVERPROPERTY('ProductVersion')) LIKE '11%%' THEN 'SQL Server 2012'
SET SQL=%SQL%      WHEN CONVERT(VARCHAR, SERVERPROPERTY('ProductVersion')) LIKE '12%%' THEN 'SQL Server 2014'
SET SQL=%SQL%      WHEN CONVERT(VARCHAR, SERVERPROPERTY('ProductVersion')) LIKE '13%%' THEN 'SQL Server 2016'
SET SQL=%SQL%      WHEN CONVERT(VARCHAR, SERVERPROPERTY('ProductVersion')) LIKE '14%%' THEN 'SQL Server 2017'
SET SQL=%SQL%      WHEN CONVERT(VARCHAR, SERVERPROPERTY('ProductVersion')) LIKE '15%%' THEN 'SQL Server 2019'
SET SQL=%SQL%      ELSE '???'
SET SQL=%SQL%   END AS 'Version',
SET SQL=%SQL%   CONVERT(VARCHAR, SERVERPROPERTY('Edition')) AS 'Edition',
SET SQL=%SQL%   CONVERT(VARCHAR, SERVERPROPERTY('ProductVersion')) AS 'ProductVersion'

FOR /f "usebackq tokens=2 delims=()" %%i in (`sc query ^| findstr /I /R /C:"SQL Server (.*)"`) DO (
    IF %%i == MSSQLSERVER (
        FOR /f "usebackq tokens=*" %%j in (`sqlcmd -Q "%SQL%" -W -s "," -h -1`) DO (
            ECHO %%j >> %OUTPUT%
        )
    ) ELSE (
        FOR /f "usebackq tokens=*" %%j in (`sqlcmd -S ^(LOCAL^)\%%i -Q "%SQL%" -W -s "," -h -1`) DO (
            ECHO %%j >> %OUTPUT%
        )
    )
)

:end

REM Upload results to the FTP server and delete the local file

SET FTPFILE="%OUTPUT_DIR%\ftpcmd.bat"
IF %FTP_UPLOAD% == 1 (
    ECHO open %FTP_HOST% %FTP_PORT% > %FTPFILE%
    ECHO user %FTP_USER% %FTP_PASSWORD% >> %FTPFILE%
    ECHO bin >> %FTPFILE%
    ECHO put %OUTPUT% >> %FTPFILE%
    ECHO quit >> %FTPFILE%
    ftp -n -s:%FTPFILE%
    DEL %OUTPUT%
    DEL %FTPFILE%
)

EXIT /B 0
