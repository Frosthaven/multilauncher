# FUNCTIONS *******************************************************************
#******************************************************************************
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


    Write-Host "Waiting for $Name to end..." -NoNewline
    while ( (Get-Process -Name $Name -ErrorAction SilentlyContinue).Count -eq $NumberOfProcesses )
    {
        Write-Host '.' -NoNewline
        Start-Sleep -Milliseconds 400
    }

    Write-Host ''
}

# CONFIG **********************************************************************
#******************************************************************************
$root_path = [System.AppDomain]::CurrentDomain.BaseDirectory.TrimEnd('\') 
if ($root_path -eq $PSHOME.TrimEnd('\')) 
{     
	$root_path = $PSScriptRoot 
}

$watch_process_name = ""
$run_these = @()
$kill_these_after = @()

if (Test-Path -Path ($root_path+"\multilaunch.json") -PathType Leaf) {
$json = Get-Content -Raw ($root_path+"\multilaunch.json") | ConvertFrom-Json
    $json | foreach {
        $watch_process_name = [IO.Path]::GetFileNameWithoutExtension($_.watch_process_name)
        $_.run_these | foreach {
            $run_these += $_
        }
        $_.kill_these_after | foreach {
            $kill_these_after += $_
        }
    }
}

# RUN *************************************************************************
#******************************************************************************

$run_these | ForEach-Object {
    $full = $_
    $path = Split-Path -Path $_
    Write-Host "Running $_"
    Start-Process $full -WorkingDirectory $path
}

Wait-ForProcess -Name $watch_process_name
$a = Get-Process $watch_process_name
$a.waitforexit()

$kill_these_after | ForEach-Object {
    Write-Host "Closing $_"
    Stop-Process -Name $_ -Force
}