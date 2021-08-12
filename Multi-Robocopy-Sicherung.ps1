#Verzeichnissicherung
# V1.0, 19.11.2019
# V1.1, 03.02.2021 - /COPYALL entfernt

[decimal]$prozent = "0"
[decimal]$ink = "5"
[string]$pc = hostname
[string]$cred = whoami

Clear-Host

# Logdatei leeren, bzw. leere Logdatei erzeugen
Write-Host "" > \\$pc\c$\temp\verzeichnissicherung.log

try
{
$s = New-PSSession -ComputerName hauptserver.domain -Credential $cred
}
catch
{
        Write-Host "Keine oder falsche Credentials angegeben."
        Write-Host "Skript ohne Aktion beendet."
        break
}

# Hier stehen alle Server, auf denen sich zu sichernde Verzeichnisse befinden
[array]$servers = "quellserver1.domain","quellserver2.domain","quellserver3.domain"

Write-Host "-----------------------------------------------------------------------------------------"
Write-Host "###                               Verzeichnissynchronisierung                         ###"
Write-Host "-----------------------------------------------------------------------------------------"
Write-Host ""

# Verzeichnisse auf jedem Server sichern. Spezialfall: Auf quellserver3 wird zusätzlich ein weiteres Verzeichnis gesichert. Als Ziel kann natürlich auch ein anderer Server angegeben werden; hier wird lokal gesichert.
foreach ($server in $servers)
{   
    Write-Host "ProgramData/ auf $server wird gesichert... (Gesamtfortschritt bei $prozent%)"
    invoke-command -scriptblock {robocopy "\\$server\C$\ProgramData\Verzeichnis1" "\\$server\C$\zielverzeichnis\Verzeichnis1" /mir /purge /r:1 /w:5 /NFL /NDL /NJS /NJH /NP >> \\$pc\c$\temp\verzeichnissicherung.log}
    $prozent+=$ink

    Write-Host "Program Files (x86)/ auf $server wird gesichert... (Gesamtfortschritt bei $prozent%)"
    invoke-command -scriptblock {robocopy "\\$server\C$\Program Files (x86)\Verzeichnis2" "\\$server\C$\zielverzeichnis\Verzeichnis2" /mir /purge /r:1 /w:5 /NFL /NDL /NJS /NJH /NP >> \\$pc\c$\temp\verzeichnissicherung.log}
    $prozent+=$ink

    Write-Host "Verzeichnis3/ auf $server wird gesichert... (Gesamtfortschritt bei $prozent%)"
    invoke-command -scriptblock {robocopy "\\$server\C$\Verzeichnis3" "\\$server\C$\zielverzeichnis\Verzeichnis3" /mir /purge /r:1 /w:5 /NFL /NDL /NJS /NJH /NP >> \\$pc\c$\temp\verzeichnissicherung.log}
    $prozent+=$ink
    
    if ($server -eq "quellserver3.domain")
    {
        $prozent+= 2.5
        Write-Host "Spezialverzeichnis/ auf  $server wird gesichert... (Gesamtfortschritt bei $prozent%)"
        invoke-command -scriptblock {robocopy "\\$server\c$\Program Files (x86)\Spezialverzeichnis" "\\$server\c$\zielverzeichnis\Spezialverzeichnis" /mir /purge /r:1 /w:5 /NFL /NJS /NDL /NJH /NP >> \\$pc\c$\temp\verzeichnissicherung.log}
        $prozent+=$ink + 2.5
    }
}

Remove-PSSession $s

Write-Host ""
Write-Host "-----------------------------------------------------------------------------------------"
Write-Host "###                      Synchronisierung zu $prozent% abgeschlossen.                    ###"
Write-Host "-----------------------------------------------------------------------------------------"
Write-Host "`a"

# Endabfertigung mit der Möglichkeit die Logdatei zu betrachten
switch(Read-Host "Soll die Logdatei angezeigt werden? (J/N)") {
J {
    & "C:\Windows\system32\notepad.exe" C:\temp\verzeichnissicherung.log
    Write-Host "Ende"
    break
}
N {
    switch (Read-Host "Soll die Logdatei gelöscht werden? (J/N)") {
    J {
       rm C:\temp\verzeichnissicherung.log
       Write-Host "Logdatei gelöscht."
       break 
    }
    N {
        Write-Host "Skript beendet."
        break
    }
    default {"Logdatei wird behalten"}
    }
    Write-Host "Ende"
    break
}
default {"Ungültige Eingabe."}
}