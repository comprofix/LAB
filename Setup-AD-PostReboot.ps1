<#
.SYNOPSIS
    Post-reboot script: configures DHCP, DHCP delegation groups, OUs, baseline GPOs for LAB.local domain.
#>

# ------------------ Configurable Variables ------------------
$DomainName         = "LAB.local"
$DhcpScopeName      = "LAB"
$DhcpStartRange     = "192.168.100.100"
$DhcpEndRange       = "192.168.100.199"
$DhcpSubnetMask     = "255.255.255.0"
$DhcpGateway        = "192.168.100.1"
$DhcpDnsServer      = "192.168.100.2"  # This server's static IP
$DefaultOUPath      = "DC=LAB,DC=local"
$LABOU              = "OU=LAB,$DefaultOUPath"

# ------------------ Authorize DHCP ------------------
Write-Host "`n[INFO] Authorizing DHCP server..." -ForegroundColor Cyan
Add-DhcpServerInDC -DnsName "$env:COMPUTERNAME.$DomainName" -IPAddress $DhcpDnsServer -ErrorAction SilentlyContinue

# ------------------ Create DHCP scope if missing ------------------
if (-not (Get-DhcpServerv4Scope -ScopeId 192.168.100.0 -ErrorAction SilentlyContinue)) {
    Write-Host "[INFO] Adding DHCP scope..." -ForegroundColor Cyan
    Add-DhcpServerv4Scope `
        -Name $DhcpScopeName `
        -StartRange $DhcpStartRange `
        -EndRange $DhcpEndRange `
        -SubnetMask $DhcpSubnetMask `
        -State Active

    Set-DhcpServerv4OptionValue -ScopeId 192.168.100.0 -Router $DhcpGateway
    Set-DhcpServerv4OptionValue -ScopeId 192.168.100.0 -DnsServer $DhcpDnsServer
    Set-DhcpServerv4OptionValue -ScopeId 192.168.100.0 -DnsDomain $DomainName
} else {
    Write-Host "[INFO] DHCP scope already exists. Skipping." -ForegroundColor Yellow
}

# ------------------ Ensure DHCP security groups ------------------
Write-Host "[INFO] Checking DHCP security groups..." -ForegroundColor Cyan
$domainDN = (Get-ADDomain).DistinguishedName
$usersContainer = "CN=Users,$domainDN"

foreach ($group in @("DHCP Administrators", "DHCP Users")) {
    if (-not (Get-ADGroup -Filter "Name -eq '$group'" -ErrorAction SilentlyContinue)) {
        Write-Host "Creating group '$group'..." -ForegroundColor Cyan
        New-ADGroup -Name $group -GroupScope DomainLocal -Path $usersContainer -Description "Created by setup script"
    } else {
        Write-Host "'$group' already exists." -ForegroundColor Yellow
    }
}

# Optional: add domain Administrator to DHCP Administrators group
$netbios = (Get-ADDomain).NetBIOSName
$domainAdmin = "$netbios\Administrator"
Add-ADGroupMember -Identity "DHCP Administrators" -Members $domainAdmin -ErrorAction SilentlyContinue
Write-Host "Added $domainAdmin to 'DHCP Administrators'." -ForegroundColor Cyan

# ------------------ Create default OU structure ------------------
Write-Host "`n[INFO] Creating default OU structure..." -ForegroundColor Cyan

foreach ($ou in @(
    "LAB",
    "Users",
    "Groups",
    "Computers",
    "Servers",
    "Workstations"
)) {
    if ($ou -eq "LAB") {
        $path = $DefaultOUPath
    }
    elseif ($ou -in @("Users","Groups","Computers")) {
        $path = $LABOU
    }
    else {
        $path = "OU=Computers,$LABOU"
    }

    if (-not (Get-ADOrganizationalUnit -LDAPFilter "(name=$ou)" -SearchBase $path -ErrorAction SilentlyContinue)) {
        New-ADOrganizationalUnit -Name $ou -Path $path -ErrorAction SilentlyContinue
        Write-Host "Created OU '$ou' in '$path'." -ForegroundColor Cyan
    } else {
        Write-Host "OU '$ou' already exists in '$path'." -ForegroundColor Yellow
    }
}

# ------------------ Create baseline GPOs ------------------
Write-Host "`n[INFO] Creating baseline GPOs..." -ForegroundColor Cyan

$gpos = @(
    @{ Name = "Security Baseline"; Target = $LABOU },
    @{ Name = "Workstation Policy"; Target = "OU=Workstations,OU=Computers,$LABOU" }
)

foreach ($gpo in $gpos) {
    if (-not (Get-GPO -Name $gpo.Name -ErrorAction SilentlyContinue)) {
        New-GPO -Name $gpo.Name | Out-Null
        New-GPLink -Name $gpo.Name -Target $gpo.Target | Out-Null
        Write-Host "Created and linked GPO '${gpo.Name}'." -ForegroundColor Cyan
    } else {
        Write-Host "GPO '${gpo.Name}' already exists." -ForegroundColor Yellow
    }
}

# Example: set secure screensaver in Security Baseline GPO
Set-GPRegistryValue -Name "Security Baseline" `
    -Key "HKLM\Software\Policies\Microsoft\Windows\Control Panel\Desktop" `
    -ValueName "ScreenSaverIsSecure" -Type DWord -Value 1 -ErrorAction SilentlyContinue

Write-Host "`n✅ [COMPLETE] Post-reboot setup done! DHCP, security groups, OUs, and GPOs are ready." -ForegroundColor Green
