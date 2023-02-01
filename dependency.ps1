$CredManager = @{'Name' = 'TUN.CredentialManager'; 'RequiredVersion' = '3.0'}
$LAPSModule = @{'Name' = 'AdmPwd.PS'; 'RequiredVersion' = '6.3.1.0'}

Install-Module @CredManager
Import-Module @CredManager

Install-Module @LAPSModule
Import-Module @LAPSModule