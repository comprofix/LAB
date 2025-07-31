<#
.SYNOPSIS
    Pre-reboot script: installs AD DS, DNS, DHCP, promotes to DC if not already a DC.
#>

# ------------------ Configurable Variables ------------------
$DomainName            = "LAB.local"
$DomainNetbios         = "LAB"
$SafeModeAdminPassword = Read-Host -Prompt "Enter DSRM password" -AsSecureString

Write-Host "`n[INFO] Installing required Windows features..." -ForegroundColor Cyan

Install-WindowsFeature `
    NET-Framework-Core, `
    AD-Domain-Services, `
    DNS, `
    DHCP, `
    GPMC, `
    RSAT-AD-AdminCenter, `
    RSAT-DNS-Server, `
    RSAT-DHCP -IncludeManagementTools

# ------------------ Promote to Domain Controller if needed ------------------
if (-not (Get-ADDomainController -ErrorAction SilentlyContinue)) {
    Write-Host "`n[INFO] Promoting this server to first Domain Controller for $DomainName..." -ForegroundColor Cyan

    Install-ADDSForest `
        -DomainName $DomainName `
        -DomainNetbiosName $DomainNetbios `
        -SafeModeAdministratorPassword $SafeModeAdminPassword `
        -InstallDNS `
        -Force `
        -Restart

    # Script ends here: server will reboot automatically
} else {
    Write-Host "`n[INFO] This machine is already a Domain Controller. Skipping promotion." -ForegroundColor Yellow
}
