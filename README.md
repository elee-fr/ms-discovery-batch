# MS Discovery Batch script

[Lire cette documentation en français](/README.fr.md).

This batch script retrieves information about the technical configuration and software installed on the server on which it is run, in order to perform software license compliance analysis for *Microsoft* server products such as *Windows Server* and *SQL Server*. It works only on servers with *Windows* as operating system. Finally, it allows to send the results to an FTP server to centralize the information retrieved on each server.

## Usage

* Download the `discovery.bat` script to a folder on the target server.
* Adjust the configuration if necessary as detailed below.
* Run the `discovery.bat` script, e.g. from the command line, with administrator privileges. 
* Information obtained by the script are written to a text file named `hostname.domain_year_month_day-hours_minutes_seconds.txt`.
* If the `FTP_UPLOAD` configuration parameter is set to `1`, the text file is sent to the FTP server and destroyed locally.

## Configuration

It is possible to adjust the configuration either directly in the main `discovery.bat` script, or by creating a `config.bat` file (to be placed in the same directory) according to the templates provided in `config.test.bat` (for local testing) or `config.example.bat` (for sending to an FTP server). The configuration allows you to adjust the output folder of the script, and the login credentials for the FTP server to which the results are to be sent.

**Warning** : The script uses the native *Windows* FTP client [ftp.exe](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/ftp). This client allows only active FTP connections; see [this explanation](https://winscp.net/eng/docs/ftp_modes) and [this question](https://stackoverflow.com/questions/32226143/failed-to-ftp-upload-using-windows-ftp-exe-port-ip-is-not-same-as-nnn-nnn-nnn). Therefore, sending to an FTP server will only work if the server running the script is able to access the FTP server in active FTP mode. Firewalls and intermediate networks can prevent this. 

## Output format

The format of the text file obtained at the output of the script is as follows:

```
=== Global ===
Hostname: colibri12
FQDN: colibri12.example.com
OS Name: Microsoft Windows Server 2012 R2 Standard
OS Version: 10.0.18363.959
Server Manufacturer: Dell Inc.
Server Model: XPS 15 7590
CPU Model: Intel(R) Xeon(R) CPU E5-2698 v4 @ 2.20GHz 
Total number of CPU: 4
Number of cores per CPU: 2
Number of threads per CPU: 2
=== MAC addresses ===
Node,IPAddress,MACAddress
colibri12,{192.168.1.56;fe80::b980:255b:b43e:db},60:F2:11:52:A2:03
colibri12,{192.168.1.59;fe80::b980:265b:b43e:db},60:F2:11:52:A2:56
...
=== Installed products ===
Node,InstallDate,Name,Vendor,Version
colibri12,20170818,SQL Server 2012 Common Files,Microsoft Corporation,11.3.6020.0 
colibri12,20180222,Skype for Business Server 2015, Conferencing Server,Microsoft Corporation,6.0.9319.503 
...
=== SQL Server instances ===
Version,Edition,ProductVersion
SQL Server 2012,Enterprise Edition: Core-based,11.0.6251.0
SQL Server 2014,Express Edition (64-bit),12.0.2269.0
...
```

The *MAC addresses*, *Installed products* and *SQL Server instances* sections contain as many lines as necessary, in CSV format. If no address, product or instance is found, only the attributes line is present.

In addition to the general server information contained in the first section, MAC addresses can be used to identify the machine (physical or virtual). The list of installed products is filtered to contain only the products edited by *Microsoft*.

## Contributing

This script is provided under the [MIT License](/LICENSE). Please feel free to send us remarks, questions or suggestions by opening a new issue or a new merge-request.
