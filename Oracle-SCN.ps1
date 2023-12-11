#Aktuelle SCN Nummer(NEXT_CHANGE#) über RMAN herausfinden
# 19.11.2019 V1.0
# 12.08.2021 V1.1

# Vorher muss die SSH-Library installiert werden: Install-Module Posh-SSH
#$ep = '--%'
Clear-Host

Write-Host "-----------------------------------------------------------------------------------------"
Write-Host "###                             Datenbank-Sicherungsarchiv                              ###"
Write-Host "-----------------------------------------------------------------------------------------"
Write-Host ""
Write-Host "Verbindung zur Datenbank wird hergestellt..."

# SSH-Verbindung zum DB-Host herstellen
try
{
    $sshora = New-SSHSession -Computer oracledb.domain -Credential oracleuser
}
catch
{
    Write-Host "Keine oder falsche Credentials angegeben."
    Write-Host "Skript ohne Aktion beendet."
    break
}

$stora = New-SSHShellStream -SSHSession $sshora
#Write-Host "stora enthält: $stora"
$insc =  'SELECT SEQUENCE#,NEXT_CHANGE#,NEXT_TIME FROM V$ARCHIVED_LOG ORDER BY NEXT_CHANGE# DESC FETCH FIRST 1 ROW ONLY;'
$ret0 = Invoke-SSHStreamExpectAction -ShellStream $stora -Command "sqlplus sys/sys@orcl as sysdba" -ExpectString "oracle@oracledb[/home/oracle]> " -Action $insc -TimeOut "60"
Write-Host "Angemeldet: $ret0"
Write-Host "Starte SQL-Client..."
#$ret = Invoke-SSHCommand -SSHSession $sshora -Command $insc
#Write-Host $ret
#Write-Host $stora.Read()
$ret0 = Invoke-SSHStreamExpectAction -ShellStream $stora -Command $insc -ExpectString "SQL> " -Action $insc -TimeOut "60"
Start-Sleep -m 500
$stora.Read()
$ret0 =Invoke-SSHStreamExpectAction -ShellStream $stora -Command "exit" -ExpectString "SQL> " -Action "exit" -TimeOut "60"
Write-Host "Abgemeldet: $ret0"
#Write-Host "Folgende Daten gefunden:`n" $ret.Output
#Write-Host $stora.Read()

# Bash-Bedienung über eine Stream-Read/Write-Kombination einrichten


#$stora.WriteLine("hostname")
#$stora.ReadLine()

#$stora = Invoke-SSHCommand -SSHSession $sshora ("hostname")
#Write-Host "Verbindung mit $stora.ReadLine() hergestellt."


# Ab hier folgen Eingaben, wobei auf die Bash gewartet wird
#while ($stora.Read() -ne "oracle@oracledb[/home/oracle]> ")
#{
#    Start-Sleep -Seconds 3
#}

# An RMAN anmelden
#Write-Host "Anmeldung an RMAN..."
#$stora.WriteLine("rman target /")
#while ($stora.Read() -ne "RMAN> ")
#{
#    Start-Sleep -Seconds 5
#}

# Aktuellste archivierte SCN ausgeben
#$stora.WriteLine("SELECT SEQUENCE#,NEXT_CHANGE#,NEXT_TIME FROM V$ARCHIVED_LOG ORDER BY NEXT_CHANGE# DESC FETCH FIRST 1 ROW ONLY;")
#$stora.Read()
    #$rmanpw = Read-Host "Bitte das Kennwort für den User 'sys' eingeben" -AsSecureString

#Invoke-SSHCommand -SSHSession $sshora -Command "hostname"
#Invoke-SSHCommand -SSHSession $sshora -Command "rman target sys/$rmanpw@oracleinstance"
#Invoke-SSHCommand -SSHSession $sshora -Command "SELECT SEQUENCE#,NEXT_CHANGE#,NEXT_TIME FROM V$ARCHIVED_LOG ORDER BY NEXT_CHANGE# DESC FETCH FIRST 1 ROW ONLY;"
#Invoke-SSHCommand -SSHSession $sshora -Command "exit"

$ret0 = Remove-SSHSession -SSHSession $sshora
Write-Host "SSH-Sitzung geschlossen: $ret0"
