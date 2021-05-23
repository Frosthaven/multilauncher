# FUNCTIONS ********************************************************************
#*******************************************************************************
function Wait-ForProcess {
    param
    (
        $Name = 'notepad',

        [Switch]
        $IgnoreAlreadyRunningProcesses
    )

    if ($IgnoreAlreadyRunningProcesses)
    {
        $NumberOfProcesses = (Get-Process -Name $Name -ErrorAction SilentlyContinue).Count
    }
    else
    {
        $NumberOfProcesses = 0
    }


    #Write-Host "Waiting for $Name to end..." -NoNewline
    while ( (Get-Process -Name $Name -ErrorAction SilentlyContinue).Count -eq $NumberOfProcesses )
    {
        #Write-Host '.' -NoNewline
        Start-Sleep -Milliseconds 400
    }

    Write-Host ''
}

# SETUP ************************************************************************
#*******************************************************************************
$root_path = [System.AppDomain]::CurrentDomain.BaseDirectory.TrimEnd('\') 
if ($root_path -eq $PSHOME.TrimEnd('\')) 
{     
	$root_path = $PSScriptRoot 
}

$watch_process_name = ""
$run_these = @()
$run_cmd = @()
$kill_these_after = @()
$run_cmd_after = @()

if (Test-Path -Path ($root_path+"\multilaunch.json") -PathType Leaf) {
$json = Get-Content -Raw ($root_path+"\multilaunch.json") | ConvertFrom-Json
    $json | foreach {
        $watch_process_name = [IO.Path]::GetFileNameWithoutExtension($_.watch_process_name)
        $_.run_these | foreach {
            $run_these += $_
        }
        $_.run_cmd | foreach {
            $run_cmd += $_
        }
        $_.run_cmd_after | foreach {
            $run_cmd_after += $_
        }
        $_.kill_these_after | foreach {
            $kill_these_after += $_
        }
    }
}

# RUN **************************************************************************
#*******************************************************************************

# launch extras
Write-Host 
Write-Host "************************************************************"
Write-Host "Running Applications..."
Write-Host "************************************************************"
Write-Host 
$run_these | ForEach-Object {
    $full = $_
    $path = Split-Path -Path $_
    Write-Host "  > $_"
    Start-Process $full -WorkingDirectory $path
}

Write-Host 
Write-Host "************************************************************"
Write-Host "Running Startup Commands..."
Write-Host "************************************************************"
Write-Host 
$run_cmd | ForEach-Object {
    cmd.exe /c $_
}

Write-Host 
Write-Host "************************************************************"
Write-Host "Waiting for $watch_process_name to end..."
Write-Host "************************************************************"
Write-Host 
# wait for the process to load and then quit
Wait-ForProcess -Name $watch_process_name
$a = Get-Process $watch_process_name
$a.waitforexit()

Write-Host 
Write-Host "************************************************************"
Write-Host "Killing Applications..."
Write-Host "************************************************************"
Write-Host 
$kill_these_after | ForEach-Object {
    Write-Host "  > $_"
    Stop-Process -Name $_ -Force
}

Write-Host 
Write-Host "************************************************************"
Write-Host "Running Shutdown Commands..."
Write-Host "************************************************************"
Write-Host 
$run_cmd_after | ForEach-Object {
    cmd.exe /c $_
}