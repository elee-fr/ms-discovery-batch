# Script Batch MS Discovery

[Read this documentation in english](/README.md).

Ce script Batch récupère des informations sur la configuration technique et les logiciels installés sur le serveur sur lequel on l'exécute, en vue de réaliser des analyses de conformité en licences logicielles pour les produits serveurs de *Microsoft* tels que *Windows Server* et *SQL Server*. Il ne fonctionne que sur les serveurs ayant *Windows* comme système d'exploitation. Il permet enfin d'envoyer les résultats vers un serveur FTP pour centraliser les informations obtenues sur chaque serveur.

## Utilisation

* Télécharger le script `discovery.bat` dans un dossier sur le serveur cible.
* Ajuster la configuration si nécessaire comme détaillé ci-dessous.
* Lancer le script `discovery.bat`, par exemple en ligne de commande, avec des droits d'administrateur. 
* Les informations obtenues par le script sont écrites dans un fichier texte dont le nom suit le motif `hostname.domain_year_month_day-hours_minutes_seconds.txt`.
* Si le paramètre de configuration `FTP_UPLOAD` est réglé à `1`, le fichier texte est envoyé au serveur FTP et détruit localement.

## Configuration

Il est possible d'ajuster la configuration ou bien directement dans le script principal `discovery.bat`, ou bien en créant un fichier `config.bat` (à placer dans le même dossier) selon les modèles fournis dans `config.test.bat` (pour un essai local) ou `config.example.bat` (pour un envoi vers un serveur FTP). La configuration permet d'ajuster le dossier de sortie du script et les identifiants de connexion au serveur FTP auquel les résultats doivent être envoyés.

**Attention** : Le script utilise le client FTP *Windows* natif [ftp.exe](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/ftp). Ce client ne permet que d'effectuer des connexions FTP actives ; voir [cette explication](https://winscp.net/eng/docs/ftp_modes) et [cette question](https://stackoverflow.com/questions/32226143/failed-to-ftp-upload-using-windows-ftp-exe-port-ip-is-not-same-as-nnn-nnn-nnn). L'envoi vers un serveur FTP ne va donc fonctionner que si le serveur qui exécute le script parvient à accéder en mode FTP actif au serveur FTP. Les pare-feux et réseaux intermédiaires peuvent empêcher cela. 

## Format de sortie


Le format du fichier texte obtenu en sortie du script est le suivant :

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

Les rubriques *MAC addresses*, *Installed products* et *SQL Server instances* contiennent autant de lignes que nécessaire, au format CSV. Si aucune adresse, aucun produit ou aucune instance n'est trouvée, seule la ligne des attributs est présente.

Outre les informations générales sur le serveur contenues dans la première section, les adresses MAC peuvent servir à l'identification de la machine (physique ou virtuelle). La liste des produits installés est filtrée pour ne contenir que les produits édités par *Microsoft*. 

## Contribuer

Ce script est fourni sous la [Licence MIT](/LICENSE). N'hésitez pas à nous faire part de vos remarques, questions ou suggestions en ouvrant un nouveau ticket ou une nouvelle demande de fusion.
