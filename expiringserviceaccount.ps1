$ServiceAccount = @()
$ServiceAccounts = @()
$ExpiringPasswordObject = @()
#Set this to however long you would like to get a warning for and converts it to FileUTC for usage in Powershell. The value of msDS-UserPasswordExpiryTimeComputed is given in FileTimeUTC
$PasswordExpireLimitDate = (Get-Date).AddDays(30).ToFileTimeUtc()

import-module activedirectory

#Gets all workstations that need to have software installed, if you don't want to uninstall all of the software from you will need to use a text document and Get-Content
$ServiceAccounts = Get-ADUser -SearchBase "OU=ServiceAccounts DC=contoso,DC=lan" -filter {Enabled -eq $True} -Properties Name,DisplayName,msDS-UserPasswordExpiryTimeComputed,PasswordNeverExpires | where {($_.PasswordExpiration = $True -or $_.
'msDS-UserPasswordExpiryTimeComputed' -lt $PasswordExpireLimitDate) } 

$ExpiringPasswordObject =  New-Object System.Collections.Generic.List[System.Object]

ForEach($ServiceAccount in $ServiceAccounts) {
#Converts msDS-UserPasswordExpirtTimeComputer to human readable will create angry errors that can be ignored if account have valid expiration date.
$ServiceAccount.PasswordExpiration = [DateTimeOffset]::FromFileTime($ServiceAccount.'msDS-UserPasswordExpiryTimeComputed')
$ExpiringPasswordObject.Add($ServiceAccount)
}

$ExpiringPasswordObject | Out-GridView 
$ExpiringPasswordObject | Select Displayname, DistinguishedName, Enabled, GivenName, UserPrincipalName, SamAccountName, PasswordNeverExpires, @{n="PasswordExpiration";e={$_.PasswordExpiration}} | Export-CSV C:\Temp\AccountExpiring.CSV
