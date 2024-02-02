#SFTP-Download über winscp, Verschieben und Umbennenn der Datei; Das Skript läuft in diesem Falle auf Scriptrunner-Server
#foxbegas
#V1.0, 17.01.2024
#V1.1, 18.01.2024
#V1.01, 19.01.2024
#V1.2, 24.01.2024


# Powershell-Umgebungsvariabeln festlegen; Wir möchten ein PSDrive "X" verbinden
param(
[Parameter(Mandatory = $true)]
[pscredential]$mounter
)
$date = (Get-Date).Date
$filefilter = $date.AddDays(-1) # Die hier ist wichtig, weil wir testen wollen, ob am Vortag eine Datei geladen wurde
$zstempel= Get-Date -UFormat %Y-%m-%d_%H-%M-%S
$xpath = '\\path\to\root'

# Laufwerke verbinden
####----------------------------------###
try{
    Write-Host "Zielverzeichnis verbinden"
    $null=New-PSDrive -Name "X" -PSProvider FileSystem -Root $xpath -Credential $mounter
    Write-Host "Laufwerk verbunden"
}
catch{
    Write-Host "Fehler beim Verbinden von $xpath"
}
####----------------------------------###

# Allgemeine Variablen definieren; wir möchten auch Dateien mit bestimmten Zugriffsdaten filtern, falls schon Dateien geladen wurden

$filepathsrc = 'X:\sub\directory'
$dlog = "X:\Logs\Download.log"
$testpatharchiv = 'X:\sub\archiv'
$stbfile = (Get-ChildItem -Path $testpatharchiv -File | Where-object { ($_.Name -like "*STRING*") -and ($_.LastWriteTime.Date -eq $date) })
$stafile = (Get-ChildItem -Path $filepathsrc -file | Where-Object {($_.LastWriteTime -gt $filefilter)})


if(Test-Path -Path ("C:\path\to\session.log") -PathType Leaf ){Remove-Item -Path "C:\path\to\session.log" -Force}

# WinSCP-.NET-assembly laden
Add-Type -Path "C:\DLL\WinSCPnet.dll"

# Sitzungsoptionen konfigurieren; diese können über die WINSCP-GUI erzeugt werden
$sessionOptions = New-Object WinSCP.SessionOptions -Property @{
    Protocol = [WinSCP.Protocol]::Sftp
    HostName = "sftp.server.domain"
    UserName = "SFTPUSER"
    SshHostKeyFingerprint = "ssh-rsa FINGERPRINT"
    SshPrivateKeyPath = "\\path\to\ppk"
    PrivateKeyPassphrase = "PASSPHRASE"
}

$session = New-Object WinSCP.Session -Property @{
  SessionlogPath= "C:\path\to\session.log"
}

# Test, ob schon eine Datei am heutigen Tag heruntergeladen wurde
if ($stbfile) {
    Write-Host "Datei ist bereits vorhanden"
    $dilog = "$zstempel" + ": Es wurde bereits eine Datei zum Import bereitgestellt."
    Add-Content $dlog -value $dilog
    exit
}

# Verbindungsversuch
try
{
    # Verbinden
    Write-Host "Verbinde mit SFTP-Server..." $sessionOptions.HostName
    $session.Open($sessionOptions)
    Write-Host "Verbindung erfolgreich"
    Write-Host "Versuche Dateidownload..."
}
catch
{
    Write-Host "Keine Verbindung möglich"
    $session.Dispose()
    Write-Host "SFTP-Verbindung geschlossen"
    exit
}

# Downloadversuch
try
{
    # Dateien übertragen
    $session.GetFiles("/Path/To/Remote/Share/*", "C:\local\directory\*", $True).Check()
    
    Write-Host "Dateien wurden heruntergeladen"
    Write-Host "Downloadverzeichnis: " $filepathsrc
}
catch
{
    Write-Host "Keine Dateien zum Download vorhanden."
    exit
}
finally
{
    $session.Dispose()
    Write-Host "SFTP-Verbindung geschlossen"
}

# Kopieren zu X: / PSDrive
try {
    Copy-Item -Path "C:\local\directory\*.txt" -Destination "X:\download\directory\" -PassThru
	#Sicherungskopie (wenn gewünscht)
    Move-Item -Path "C:\local\directory\*.txt" -Destination "C:\path\to\save" -PassThru
}
catch {
    throw
    exit
}
# Die heruntergeladenen Dateien werden kopiert, wenn am Ausführungstag eine Datei vorhanden ist (Definition in den Variablen). Die Datei erhält einen neue Endung, um von einem Folgeprogramm verabeitet werden zu können

# Kopiervorgang mit Test, ob bereits eine Datei verarbeitet wurde (Test im Archiv), Logeintrag und Bereinigung des Arbeitsverzeichnisses
if ( $stafile -and -not $stbfile) {
    foreach ($sta in $stafile) {
        $filenamenew = [System.IO.Path]::GetFileNameWithoutExtension($bka) + ".GANZTOLLEENDUNG"
        $copysrc = $filepathsrc + "\" + $sta
        $copydst = 'X:\destination\' + $filenamenew
        Copy-Item -Path $copysrc -Destination $copydst -PassThru
        Write-Host "Die Datei $filenamenew wurde kopiert"
        $dilog = "$zstempel" + ": Die Datei " + "$filenamenew" + " wurde zum Import bereitgestellt."
        Add-Content $dlog -value $dilog
        Copy-Item -Path $copysrc -Destination "X:\destination\download\Archiv" -PassThru
    }
}
else {
    Write-Host "Es wurde keine Datei kopiert"
    $dilog = "$zstempel" + ": Die Dateien konnten nicht kopiert werden oder es standen keine Dateien zur Verfügung."
    Add-Content $dlog -value $dilog
}

exit
