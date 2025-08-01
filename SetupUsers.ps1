param(
    [string]$Domain,
    [string]$OU

)


$Users = Import-Csv .\Users.csv

ForEach ($User in $Users) {
    $DisplayName = $User.DisplayName
    $FirstName = $User.FirstName
    $Surname = $User.Surname
    $SurnameInitial = $User.Surname[0]

    Write-Host $DisplayName "$FirstName$SurnameInitial@$Domain"

    Write-Host "Creating sample users..." -ForegroundColor Cyan
    $UserPassword = ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force

    New-ADUser -Name "$DisplayName" -GivenName "$FirstName" -Surname "$Surname" `
        -SamAccountName "$FirstName$SurnameInitial" -UserPrincipalName "$FirstName$SurnameInitial@$Domain" `
        -AccountPassword $UserPassword -Enabled $true `
        -Path "$OU" -ErrorAction SilentlyContinue

    Set-ADUser -Identity "$FirstName$SurnameInitial" -EmailAddress "$FirstName$SurnameInitial@$Domain"
    Set-ADUser -Identity "$FirstName$SurnameInitial" -DisplayName "$DisplayName"
    Set-ADUser -Identity "$FirstName$SurnameInitial" -Add @{proxyAddresses="SMTP:$FirstName$SurnameInitial@$Domain"}


}