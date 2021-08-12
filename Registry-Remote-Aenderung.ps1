# Registry-Schlüssel auf Remoteservern bearbeiten, zum Beispiel in Terminalserver-Umgebungen
# 18.09.2019; V1.0
# 30.10.2019; V1.1

# Einen Hinweis des zu verwendenden Users ausgeben
    Write-Host "Message-Box beachten!"
    [System.Windows.Forms.MessageBox]::Show(„Bitte den User domain\user nutzen!“,“Anmeldung“,0, [System.Windows.Forms.MessageBoxIcon]::Warning)
    
# Auf alle Diamant-Citrix-Server parallel aufschalten

    try
    {
        $cred = Get-Credential -credential domain\user
    }
    catch
    {
        Write-Host "Keine Credentials angegeben."
        Write-Host "Skript ohne Aktion beendet."
        break
    }

    try
    {
        $s = New-PSSession -Credential $cred -Computer server1.domain, server2.domain, server3.domain

        #write-host $error[0].Exception.GetType().FullName
        # Die Registry-Schlüssel zunächst auf einen anderen Wert ändern und dann auf den korrekten Wert setzen
        invoke-command -Script { New-ItemProperty -Path HKLM:\SOFTWARE\Wow6432Node\Microsoft\Office\Excel\Addins\Addin.Name -Name AddinName -Value 1 -PropertyType DWORD -Force } -Session $s
        invoke-command -Script { New-ItemProperty -Path HKLM:\SOFTWARE\Wow6432Node\Microsoft\Office\Excel\Addins\Addin.Name -Name AddinName -Value 3 -PropertyType DWORD -Force } -Session $s

        # Sitzung sauber beenden
        Remove-PSSession -Session $s

        Write-Host "Skript erfolgreich ausgeführt."
    }
    catch
    {
        Write-Host "Falsche Credentials angegeben."
        Write-Host "Skript ohne Aktion beendet."
        break
    }