param(
    [string]$Domain,
    [string]$OU
)

$Users = Import-Csv .\Users.csv

ForEach ($User in $Users) {
    $DisplayName = $User.DisplayName
    $FirstName = $User.FirstName
    $Surname = $User.Surname
    $SurnameInitial = $Surname[0]
    $SamAccountName = "$FirstName$SurnameInitial"
    $UserPrincipalName = "$SamAccountName@$Domain"

    Write-Host "🖨️ Processing user: $DisplayName ($UserPrincipalName)" -ForegroundColor Yellow

    # Check if user already exists
    $ExistingUser = Get-ADUser -Filter { SamAccountName -eq $SamAccountName } -ErrorAction SilentlyContinue

    if ($ExistingUser) {
        Write-Host "❗ User '$SamAccountName' already exists. Skipping creation." -ForegroundColor Red
    } else {
        Write-Host "🛠️ Creating user '$SamAccountName'..." -ForegroundColor Cyan
        $UserPassword = ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force

        New-ADUser -Name $DisplayName `
            -GivenName $FirstName `
            -Surname $Surname `
            -SamAccountName $SamAccountName `
            -UserPrincipalName $UserPrincipalName `
            -AccountPassword $UserPassword `
            -Enabled $true `
            -Path $OU `
            -ErrorAction Stop

        # Set additional attributes
        Set-ADUser -Identity $SamAccountName -EmailAddress $UserPrincipalName
        Set-ADUser -Identity $SamAccountName -DisplayName $DisplayName
        Set-ADUser -Identity $SamAccountName -Add @{proxyAddresses = "SMTP:$UserPrincipalName"}

        Write-Host "✅ User '$SamAccountName' created successfully." -ForegroundColor Green
        
    }
}
