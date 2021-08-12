# 11.12.2019
# Variable Datenbank Treiber umstellen; V1.0
# Im Prinzip ein einfaches Replace per Powershell

# Datei sichern
copy Pfad:\zur\datei.xml Pfad:\zur\datei_bak.xml

# Datenbanktreiber auf Server 2016 umstellen
(Get-Content Pfad:\zur\datei.xml) -replace 'ODBC Driver 17', 'ODBC Driver 13' | Set-Content Pfad:\zur\datei.xml