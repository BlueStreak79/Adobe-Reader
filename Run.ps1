# Function to log messages
function Write-Log {
    param (
        [string]$Message
    )
    $LogTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "$LogTime - $Message"
    Add-content -Path $LogFile -Value $LogMessage
}

# Set log file path
$LogFile = "$env:TEMP\AcrobatReaderInstallation.log"

# Function to check if Adobe Reader is already installed
function Is-AdobeReaderInstalled {
    return (Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object {$_.DisplayName -like "Adobe Acrobat Reader DC"} -ErrorAction SilentlyContinue) -ne $null
}

# Main script
try {
    # Check if Adobe Reader is already installed
    if (Is-AdobeReaderInstalled) {
        Write-Log "Adobe Acrobat Reader DC is already installed."
        Write-Host "Adobe Acrobat Reader DC is already installed."
    }
    else {
        # URL to download Adobe Acrobat Reader DC installer
        $DownloadURL = "https://ardownload2.adobe.com/pub/adobe/reader/win/AcrobatDC/2101320077/AcroRdrDC2101320077_en_US.exe"

        # Path to store the downloaded installer
        $InstallerPath = "$env:TEMP\AcrobatReaderInstaller.exe"

        # Download Adobe Acrobat Reader DC installer
        Write-Log "Downloading Adobe Acrobat Reader DC installer..."
        Invoke-WebRequest -Uri $DownloadURL -OutFile $InstallerPath

        # Install Adobe Acrobat Reader DC silently
        Write-Log "Installing Adobe Acrobat Reader DC..."
        Start-Process -FilePath $InstallerPath -ArgumentList "/sAll /rs /msi EULA_ACCEPT=YES" -Wait

        # Check if installation was successful
        if (Is-AdobeReaderInstalled) {
            Write-Log "Adobe Acrobat Reader DC has been installed successfully."
            Write-Host "Adobe Acrobat Reader DC has been installed successfully."
        }
        else {
            Write-Log "Failed to install Adobe Acrobat Reader DC."
            Write-Host "Failed to install Adobe Acrobat Reader DC."
        }

        # Remove the installer file
        Write-Log "Cleaning up..."
        Remove-Item -Path $InstallerPath -Force
    }
}
catch {
    Write-Log "An error occurred: $_"
    Write-Host "An error occurred: $_"
}

# Display log file path
Write-Host "Installation log file path: $LogFile"
