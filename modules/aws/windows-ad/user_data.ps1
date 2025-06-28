<powershell>
# Set Administrator password
$AdminPassword = ConvertTo-SecureString "${admin_password}" -AsPlainText -Force
$AdminUser = [ADSI]"WinNT://./Administrator,User"
$AdminUser.SetPassword("${admin_password}")

# Install AD DS Role
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# Import AD DS module
Import-Module ADDSDeployment

# Configure AD DS
$DomainName = "${domain_name}"
$DomainNetbios = "${domain_netbios}"
$SafeModePassword = ConvertTo-SecureString "${safe_mode_password}" -AsPlainText -Force

if ("${is_first_dc}" -eq "true") {
    # Create new forest
    Install-ADDSForest `
        -DomainName $DomainName `
        -DomainNetbiosName $DomainNetbios `
        -SafeModeAdministratorPassword $SafeModePassword `
        -InstallDns:$true `
        -NoRebootOnCompletion:$false `
        -Force:$true
} else {
    # Join existing domain as additional DC
    Install-ADDSDomainController `
        -DomainName $DomainName `
        -SafeModeAdministratorPassword $SafeModePassword `
        -Credential (New-Object System.Management.Automation.PSCredential("$DomainNetbios\Administrator", $AdminPassword)) `
        -InstallDns:$true `
        -NoRebootOnCompletion:$false `
        -Force:$true
}

# Create test users and groups after reboot
$CreateUsersScript = @'
Import-Module ActiveDirectory

# Wait for AD to be ready
Start-Sleep -Seconds 60

# Create OUs
New-ADOrganizationalUnit -Name "PentestLab" -Path "DC=$($DomainName.Split('.') -join ',DC=')"
New-ADOrganizationalUnit -Name "Users" -Path "OU=PentestLab,DC=$($DomainName.Split('.') -join ',DC=')"
New-ADOrganizationalUnit -Name "Computers" -Path "OU=PentestLab,DC=$($DomainName.Split('.') -join ',DC=')"
New-ADOrganizationalUnit -Name "Groups" -Path "OU=PentestLab,DC=$($DomainName.Split('.') -join ',DC=')"

# Create test groups
New-ADGroup -Name "IT_Admins" -GroupScope Global -Path "OU=Groups,OU=PentestLab,DC=$($DomainName.Split('.') -join ',DC=')"
New-ADGroup -Name "Developers" -GroupScope Global -Path "OU=Groups,OU=PentestLab,DC=$($DomainName.Split('.') -join ',DC=')"
New-ADGroup -Name "Finance" -GroupScope Global -Path "OU=Groups,OU=PentestLab,DC=$($DomainName.Split('.') -join ',DC=')"

# Create test users
$users = @(
    @{Name="John Smith"; SamAccountName="jsmith"; Department="IT"; Password="P@ssw0rd123!"},
    @{Name="Jane Doe"; SamAccountName="jdoe"; Department="Finance"; Password="Finance2023!"},
    @{Name="Bob Johnson"; SamAccountName="bjohnson"; Department="Development"; Password="Dev@2023!"},
    @{Name="Alice Williams"; SamAccountName="awilliams"; Department="IT"; Password="IT@dmin2023!"}
)

foreach ($user in $users) {
    New-ADUser `
        -Name $user.Name `
        -GivenName $user.Name.Split(' ')[0] `
        -Surname $user.Name.Split(' ')[1] `
        -SamAccountName $user.SamAccountName `
        -UserPrincipalName "$($user.SamAccountName)@${domain_name}" `
        -Department $user.Department `
        -Path "OU=Users,OU=PentestLab,DC=$($DomainName.Split('.') -join ',DC=')" `
        -AccountPassword (ConvertTo-SecureString $user.Password -AsPlainText -Force) `
        -Enabled $true `
        -PasswordNeverExpires $true
}

# Add users to groups
Add-ADGroupMember -Identity "IT_Admins" -Members "jsmith","awilliams"
Add-ADGroupMember -Identity "Finance" -Members "jdoe"
Add-ADGroupMember -Identity "Developers" -Members "bjohnson"

# Add IT_Admins to Domain Admins (intentional misconfiguration for testing)
Add-ADGroupMember -Identity "Domain Admins" -Members "IT_Admins"
'@

if ("${is_first_dc}" -eq "true") {
    $CreateUsersScript | Out-File C:\create-test-users.ps1
    Register-ScheduledTask -TaskName "CreateTestUsers" `
        -Trigger (New-ScheduledTaskTrigger -AtStartup) `
        -Action (New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File C:\create-test-users.ps1") `
        -RunLevel Highest `
        -User "System"
}
</powershell>