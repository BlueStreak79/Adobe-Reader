$script = @'
param (
  [ValidateScript({
      if ([System.IO.Path]::GetExtension($_) -eq ".zip") { $true }
      else { throw "`nThe Path parameter should be an accessible file path to the zip archive (.zip) containing the Adobe Acrobat installation files. Download link: https://helpx.adobe.com/acrobat/kb/acrobat-dc-downloads.html" }
    })]
  [System.IO.FileInfo]$Path # Optional local path to setup archive.
)

# Variables
$Archive = "$env:temp\AdobeAcrobat.zip"
$InstallerPath = "$env:temp\Adobe Acrobat"
$Installer = "$InstallerPath\Setup.exe"
$DownloadURL = "https://trials.adobe.com/AdobeProducts/APRO/Acrobat_HelpX/win32/Acrobat_DC_Web_WWMUI.zip"
$LogFile = "$env:temp\AdobeAcrobatInstall.log"

# Logging function
function Write-Log {
  param (
    [string]$Message
  )
  $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
  $logMessage = "$timestamp - $Message"
  Write-Output $logMessage | Out-File -FilePath $LogFile -Append -Force
}

# Log start
Write-Log "Starting Adobe Acrobat DC installation script."

try {
  # Download or copy setup files
  if ($Path) {
    Write-Log "Using local archive: $Path"
    Copy-Item -Path $Path.FullName -Destination $Archive -Force
  }
  else {
    Write-Log "Downloading setup files from $DownloadURL"
    Invoke-WebRequest -Uri $DownloadURL -OutFile $Archive
  }
  
  # Check if the archive was downloaded or copied successfully
  if (-Not (Test-Path -Path $Archive)) {
    throw "Failed to acquire the setup archive."
  }

  # Extract installer
  Write-Log "Extracting setup files to $env:temp"
  Expand-Archive -Path $Archive -DestinationPath $env:temp -Force

  # Check if the installer executable exists
  if (-Not (Test-Path -Path $Installer)) {
    throw "Failed to extract the installer. Setup.exe not found."
  }

  # Install Acrobat
  Write-Log "Starting installation of Adobe Acrobat DC."
  Start-Process -Wait -FilePath $Installer -ArgumentList "/sAll /rs /msi EULA_ACCEPT=YES"
  Write-Log "Adobe Acrobat DC installation completed successfully."
}
catch {
  Write-Log "An error occurred: $_"
  throw
}
finally {
  # Cleanup
  Write-Log "Cleaning up temporary files."
  Remove-Item -Path $Archive, $InstallerPath -Recurse -Force -ErrorAction Ignore
  Write-Log "Cleanup completed."
  Write-Log "Script finished."
}
'@

iex $script
