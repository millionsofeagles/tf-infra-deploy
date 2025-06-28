<powershell>
# Set Administrator password
$AdminPassword = ConvertTo-SecureString "${admin_password}" -AsPlainText -Force
$AdminUser = [ADSI]"WinNT://./Administrator,User"
$AdminUser.SetPassword("${admin_password}")

# Enable RDP
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# Install common tools for compatibility testing
Install-WindowsFeature -Name Web-Server -IncludeManagementTools
Install-WindowsFeature -Name Web-Asp-Net45

# Create test directories
New-Item -Path "C:\test" -ItemType Directory -Force
New-Item -Path "C:\tools" -ItemType Directory -Force

# Enable SMB for file transfer testing
Enable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart

# Download and install common testing tools
$ToolsDir = "C:\tools"

# PowerShell execution policy for testing
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force

# Create a simple test service (for exploit testing)
$ServiceScript = @'
import socket
import threading
import time

def handle_client(client_socket):
    try:
        data = client_socket.recv(1024)
        response = f"Echo: {data.decode()}"
        client_socket.send(response.encode())
    except:
        pass
    finally:
        client_socket.close()

def main():
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.bind(('0.0.0.0', 9999))
    server.listen(5)
    
    while True:
        client, addr = server.accept()
        client_handler = threading.Thread(target=handle_client, args=(client,))
        client_handler.start()

if __name__ == "__main__":
    main()
'@

$ServiceScript | Out-File -FilePath "C:\tools\test_service.py" -Encoding UTF8

# Windows Defender exclusions for testing (disable real-time protection)
Add-MpPreference -ExclusionPath "C:\tools"
Add-MpPreference -ExclusionPath "C:\test"

Write-Host "Windows Server setup complete for pentesting compatibility testing"
</powershell>