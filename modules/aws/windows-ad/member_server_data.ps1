<powershell>
# Set Administrator password
$AdminPassword = ConvertTo-SecureString "${admin_password}" -AsPlainText -Force
$AdminUser = [ADSI]"WinNT://./Administrator,User"
$AdminUser.SetPassword("${admin_password}")

# Set DNS to DC
$dcIP = "${dc_ip}"
$netAdapter = Get-NetAdapter | Where-Object {$_.Status -eq "Up"}
Set-DnsClientServerAddress -InterfaceIndex $netAdapter.InterfaceIndex -ServerAddresses $dcIP

# Wait for DC to be ready
Start-Sleep -Seconds 300

# Join domain
$DomainName = "${domain_name}"
$DomainCred = New-Object System.Management.Automation.PSCredential("$DomainName\Administrator", $AdminPassword)

Add-Computer -DomainName $DomainName -Credential $DomainCred -Restart -Force

# Install common vulnerable services for testing
$InstallVulnServices = @'
# Install IIS with vulnerable configuration
Install-WindowsFeature -Name Web-Server -IncludeManagementTools
Install-WindowsFeature -Name Web-Asp-Net45

# Create a test website with uploads enabled
New-Item -Path "C:\inetpub\uploads" -ItemType Directory
$acl = Get-Acl "C:\inetpub\uploads"
$permission = "Everyone","FullControl","Allow"
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
$acl.SetAccessRule($accessRule)
Set-Acl "C:\inetpub\uploads" $acl

# Enable SMBv1 (intentionally vulnerable)
Enable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol
'@

$InstallVulnServices | Out-File C:\install-vuln-services.ps1
Register-ScheduledTask -TaskName "InstallVulnServices" `
    -Trigger (New-ScheduledTaskTrigger -AtStartup) `
    -Action (New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File C:\install-vuln-services.ps1") `
    -RunLevel Highest `
    -User "System"
</powershell>