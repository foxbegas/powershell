#Quelle: https://www.c-sharpcorner.com/code/291/powershell-perform-iisreset-on-multiple-server-in-one-go.aspx
# 09.05.2019; V1.0
# 30.10.2019; V1.1

# Credentialsabfrage für den zu nutzenden User

    try
    {
        $s = New-PSSession -ComputerName hauptserver.domain -Credential domain\user
    }
    catch
    {
        Write-Host "Keine Credentials angegeben."
        Write-Host "Skript ohne Aktion beendet."
        break
    }

    [array]$servers = "hauptserver.domain","server1.domain","server2.domain","server3.domain"

#Geht jeden Server des Arrays durch und führt IISRESET aus
#Zeigt den Status im Anschluss an die Aktion

    foreach ($server in $servers)
    {
        Write-Host "Restarting IIS on server $server..."
        invoke-command -scriptblock {IISRESET} $server
        Write-Host "IIS status for server $server"
        Invoke-Command -scriptblock {IISRESET /status} $server   
    }
    
    Remove-PSSession $s

    Write-Host "Der IIS wurde auf allen angegebenen Servern neugestartet."