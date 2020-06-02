# Setup Parameters
param (
  # Filename to be exported from Azure AD
  $exportFile = $PSScriptRoot + "\export.csv",
  # Filename to be imported to Active Directory
  $importFile = $PSScriptRoot + "\testing.csv",
  # Search by student domain, edit to reflect your schools domain.
  $studentDomain = "*subdomain.cacc.edu" 
)

#Temporary Student Password
$password = ConvertTo-SecureString Password1234 -AsPlainText -Force

# Check for powershell modules and install if needed.
Write-Host "Checking Powershell Modules" -foregroundcolor "green"
if (Get-Module -ListAvailable -Name AzureAD) {
  Write-Host "AzureADInstalled"
} 
else {
  Install-Module -Name AzureAD
}
if (Get-Module -ListAvailable -Name MSOnline) {
  Write-Host "MSOnline Installed"
} 
else {
  Install-Module -Name MSOnline
}

Write-Host "Logging you in..." -foregroundcolor "green"
#Asks for office 365 credentials and stores them in $UserCredentials
$UserCredential = Get-Credential

#Sets remote execution policy
Set-ExecutionPolicy Unrestricted -Scope CurrentUser

# Import Remote Powershell Session
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession -AllowClobber $Session

#Import Powershell Modules
Write-Host "Importing Powershell Modules" -foregroundcolor "green"
import-module MSOnline
import-module AzureAD

# Connect to Office 365 and Azure AD
Connect-MSOLService -Credential $UserCredential
Connect-AzureAD -Credential $UserCredential

# Export Users from Azure AD
Write-Host "Exporting users from Azure AD" -foregroundcolor "green"
Get-MsolUser -EnabledFilter EnabledOnly -MaxResults 200000 | Select-Object City, Country, Department, DisplayName, Fax, FirstName, LastName, MobilePhone, Office, PasswordNeverExpires, PhoneNumber, PostalCode, SignInName, State, StreetAddress, Title, UserPrincipalName | where-object {$_.UserPrincipalName -like $studentDomain} |  Export-Csv $exportFile -Encoding UTF8 -NoTypeInformation

Write-Host "Importing Users into AD" -foregroundcolor "green"
# Warning this will import users into your local active directory, proceed with caution.
# Import Users to local AD
import-csv $importfile -Encoding UTF8 | foreach-object {
  New-ADUser -Name ($_.Firstname + " " + $_.Lastname) -SamAccountName $_.UserPrincipalName.Split("@")[0] -Path "OU=students,OU=accounts,DC=yourdomain,DC=edu" -GivenName $_.FirstName -Surname $_.LastName -City $_.City -Department $_.Department -DisplayName $_.DisplayName -Fax $_.Fax -MobilePhone $_.MobilePhone -Office $_.Office -PasswordNeverExpires ($_.PasswordNeverExpires -eq "True") -OfficePhone $_.PhoneNumber -PostalCode $_.PostalCode -EmailAddress $_.UserPrincipalName -State $_.State -StreetAddress $_.StreetAddress -Title $_.Title -UserPrincipalName $_.UserPrincipalName -AccountPassword $password -enabled $true 
  Set-AzureADUserPassword -ObjectId $_.UserPrincipalName -Password $password -ForceChangePasswordNextLogin $true
}
