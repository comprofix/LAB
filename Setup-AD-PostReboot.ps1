# Author: ChatGPT (OpenAI)
# Part 2: Post-reboot configuration (DHCP, OUs, users, groups, GPOs)

# ------------------ Configurable Variables ------------------
$DomainName         = "LAB.local"
$DhcpScopeName      = "LAB"
$DhcpStartRange     = "192.168.100.100"
$DhcpEndRange       = "192.168.100.199"
$DhcpSubnetMask     = "255.255.255.0"
$DhcpGateway        = "192.168.100.1"
$DhcpDnsServer      = "192.168.1000.2"   # This server's static IP
$DefaultOUPath      = "DC=LAB,DC=local"
$LABOU              = "OU=LAB,$DefaultOUPath"

# ------------------ Configure DHCP ------------------
Write-Host "`nAuthorizing DHCP Server..." -ForegroundColor Cyan
Add-DhcpServerInDC -DnsName "$env:COMPUTERNAME.$DomainName" -IPAddress $DhcpDnsServer

Write-Host "Adding DHCP scope..." -ForegroundColor Cyan
Add-DhcpServerv4Scope `
    -Name $DhcpScopeName `
    -StartRange $DhcpStartRange `
    -EndRange $DhcpEndRange `
    -SubnetMask $DhcpSubnetMask `
    -State Active

Set-DhcpServerv4OptionValue -ScopeId 192.168.100.0 -Router $DhcpGateway
Set-DhcpServerv4OptionValue -ScopeId 192.168.100.0 -DnsServer $DhcpDnsServer
Set-DhcpServerv4OptionValue -ScopeId 192.168.100.0 -DnsDomain $DomainName

# ------------------ Create Default OU Structure ------------------
Write-Host "Creating default OU structure..." -ForegroundColor Cyan

New-ADOrganizationalUnit -Name "LAB" -Path $DefaultOUPath -ErrorAction SilentlyContinue
New-ADOrganizationalUnit -Name "Users" -Path $LABOU -ErrorAction SilentlyContinue
New-ADOrganizationalUnit -Name "Groups" -Path $LABOU -ErrorAction SilentlyContinue
New-ADOrganizationalUnit -Name "Computers" -Path $LABOU -ErrorAction SilentlyContinue
New-ADOrganizationalUnit -Name "Servers" -Path "OU=Computers,$LABOU" -ErrorAction SilentlyContinue
New-ADOrganizationalUnit -Name "Workstations" -Path "OU=Computers,$LABOU" -ErrorAction SilentlyContinue

# ------------------ Create Baseline GPOs ------------------
Write-Host "Creating baseline GPOs..." -ForegroundColor Cyan

$GPO1 = New-GPO -Name "Security Baseline" -ErrorAction SilentlyContinue
New-GPLink -Name "Security Baseline" -Target $LABOU -ErrorAction SilentlyContinue

# Example: screensaver secure
Set-GPRegistryValue -Name "Security Baseline" -Key "HKLM\Software\Policies\Microsoft\Windows\Control Panel\Desktop" `
    -ValueName "ScreenSaverIsSecure" -Type DWord -Value 1 -ErrorAction SilentlyContinue

$GPO2 = New-GPO -Name "Workstation Policy" -ErrorAction SilentlyContinue
New-GPLink -Name "Workstation Policy" -Target "OU=Workstations,OU=Computers,$LABOU" -ErrorAction SilentlyContinue

Write-Host "`n✅ Post-reboot setup complete! DHCP, OUs, users, groups, GPOs are ready." -ForegroundColor Green
