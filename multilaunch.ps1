# SETUP ************************************************************************
#*******************************************************************************
# accept command line parameters
param (
    [string]$config = "none"
)

# get the root path, whether as a ps1 script or compiled exe
$root_path = [System.AppDomain]::CurrentDomain.BaseDirectory.TrimEnd('\') 
if ($root_path -eq $PSHOME.TrimEnd('\')) 
{     
    $root_path = $PSScriptRoot
}

#backfill config if not provided with default root path
if ($config -eq "none") {
    $config = "$root_path\multilaunch.json"
}

# prepare values we want from json config file
$wipe_tray = $false
$watch_process_name = ""
$run_these = @()
$run_cmd = @()
$kill_these_after = @()
$run_cmd_after = @()

# read the json config into our above values
if (Test-Path -Path $config -PathType Leaf) {
$json = Get-Content -Raw $config | ConvertFrom-Json
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
        $wipe_tray = $_.wipe_tray
    }
}

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


    while ( (Get-Process -Name $Name -ErrorAction SilentlyContinue).Count -eq $NumberOfProcesses )
    {
        Start-Sleep -Milliseconds 400
    }
}

function Wipe-Systray {
    # this is a hacky way to wipe dead systray icons from killed process by
    # moving the mouse across the tray. due to the nature of it being so hacky
    # this is currently an undocumented feature
    Add-Type -AssemblyName System.Windows.Forms
    $screen = [System.Windows.Forms.SystemInformation]::VirtualScreen
    $x = $screen.Width
    $y = $screen.Height - 30
    $end = $screen.Width / 3 * 2
    $original = [Windows.Forms.Cursor]::Position
    while ($x -gt $end) {
        [Windows.Forms.Cursor]::Position = "$x, $y"
        $x -= 20
        Start-Sleep -Milliseconds 1
    }
    [Windows.Forms.Cursor]::Position = $original
}

# RUN **************************************************************************
#*******************************************************************************

Write-Host 
Write-Host "Running Applications..."
Write-Host 
$run_these | ForEach-Object {
    $full = $_
    $path = Split-Path -Path $_
    Write-Host "  > $_"
    Start-Process $full -WorkingDirectory $path
}

Write-Host 
Write-Host "Running Startup Commands..."
Write-Host 
$run_cmd | ForEach-Object {
    Write-Host "  > $_"
    cmd.exe /c $_
}

Write-Host 
Write-Host "[Waiting for $watch_process_name to end]"
Write-Host 
Wait-ForProcess -Name $watch_process_name
$a = Get-Process $watch_process_name
$a.waitforexit()

Write-Host 
Write-Host "Killing Applications..."
Write-Host 
$kill_these_after | ForEach-Object {
    Write-Host "  > $_"
    Stop-Process -Name $_ #attempts a graceful close first
    Stop-Process -Name $_ -Force
}

Write-Host 
Write-Host "Running Shutdown Commands..."
Write-Host 
$run_cmd_after | ForEach-Object {
    Write-Host "  > $_"
    cmd.exe /c $_
}

if ($wipe_tray -eq $true) {
    Wipe-Systray
}