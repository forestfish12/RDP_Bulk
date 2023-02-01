param (
    [String[]]$Computers,
    [String]$Prefix,
    [System.Array]$Range
)

#Setup varables and dependencies
.\dependency.ps1
$localusername = 'localhost\administrator'
$temp_path = './temp'
$failed_connect_file = "$temp_path\failed_connections.txt"

if(!(Test-Path -Path $temp_path)) {
    New-Item -Path $temp_path -ItemType Directory
}

#Get credentials in case laps cant find one.
$credentialparams = @{
    'Message' = 'Enter the default admin password'
    'Username' = $localusername
}

#Compile list of computers from provided arguments
foreach ($num in $Range) {
    [String]$name = $Prefix + $num
    $Computers += $name
}

#Setup the failed connections file for the current session
$date = Get-Date -Format "dddd MMM-d-yyyy H:mm"
"Failed Connections $date" > $failed_connect_file

foreach ($ComputerName in $Computers) {
    Write-Host "checking if $ComputerName is available"
    
    #Ping computer to see it is up.
    if (!(Test-Connection $ComputerName -Count 1 -ErrorAction SilentlyContinue)) {
        Write-Error "Cant find host $ComputerName"
        Write-Error "Ensure that $ComputerName exists and is connected to the network"
        $ComputerName >> $failed_connect_file 
    } else { 
        Write-Host "Success"
        Write-Host "Getting password for $ComputerName"

        $laps = Get-AdmPwdPassword -ComputerName $ComputerName

        #Create new credential set for the computer based on whether laps found one or not.
        if ($laps.password.length -eq 0) {
            $defaultcred = Get-Credential @credentialparams
            New-StoredCredential -Credentials $defaultcred -Persist Session -Target $ComputerName > $null
        }
        else {
            New-StoredCredential -UserName $localusername -Password $laps.password -Target $ComputerName -Persist Session > $null
        }

        Start-Process mstsc -Wait -ArgumentList "/v:$ComputerName"
    }
}
