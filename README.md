# Azure-Export-AD-Import
This powershell script will export users from Azure AD and then import the users into your local Active Directory.

## Requirements
Administrator access on Azure AD, Office 365, and your local Active Directory.

## Important
**Before running the script be sure to understand what the commands are doing especially the import command on line 57. Line 57 is commented by default for your safety!**

You will need to modify the -Path "OU=students,OU=users,DC=domian,DC=edu" on line 57 to reflect your AD directory organization and structure.

## Instructions
1.	Download the repo to your computer and unzip the folder. 
2.	Navigate to the folder that contains the powershell script “ExportAzureImportAD.ps1”
3.	Open the file with Visual Studio Code or the text editor of your choice.
4.	Modify the import command on line 57 to reflect your organizations Domain and OU structure. 
5.	Run the script by opening powershell in your current folder and type ./ExportAzureImportAD.ps1
6.	After running the script, you should now have an export.csv file your script folder.
7.	Review the data to ensure the script is pulling the correct users.
8.	Test the script by copying the export.csv to testing.csv.
9.	Keep the headers but replace the data with several test users(jtest@domain.edu, jdoe@domain.edu, etc).
10.	Uncomment line 57 and rerun the powershell script.
11.	This should create the test users in your local active directory.
12.	After testing, change the $importFile to “\export.csv”
13.	Take a deep breath and run the powershell script ./ExportAzureImportAD.ps1.
14.	If all goes well, you should now have your Azure AD users in your local Active Directory.

Note: If you are using Azure sync it will take some time for all users to finish a complete re-sync.
