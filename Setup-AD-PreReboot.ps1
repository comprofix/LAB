# Author: ChatGPT (OpenAI)
# Part 1: Install features and promote to first DC

# ------------------ Configurable Variables ------------------
$DomainName            = "LAB.local"
$DomainNetbios         = "LAB"
$SafeModeAdminPassword = Read-Host -Prompt "Enter DSRM password" -AsSecureString

# ------------------ Install Features ------------------
Write-Host "`nInstalling roles and features..." -ForegroundColor Cyan

Install-WindowsFeature `
    NET-Framework-Core, `
    AD-Domain-Services, `
    DNS, `
    DHCP, `
    GPMC, `
    RSAT-AD-AdminCenter, `
    RSAT-DNS-Server, `
    RSAT-DHCP -IncludeManagementTools

# ------------------ Promote to Domain Controller ------------------
Write-Host "`nPromoting this server to first Domain Controller for $DomainName..." -ForegroundColor Cyan

Install-ADDSForest `
    -DomainName $DomainName `
    -DomainNetbiosName $DomainNetbios `
    -SafeModeAdministratorPassword $SafeModeAdminPassword `
    -InstallDNS `
    -Force

Write-Host "`nServer will now reboot automatically to complete promotion." -ForegroundColor Yellow
