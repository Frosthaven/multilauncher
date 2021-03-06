# SETUP ************************************************************************
#*******************************************************************************
# accept command line parameters
param (
    [string]$config = "none"
)

# get the root path, whether as a ps1 script or compiled exe
$root_path = [System.AppDomain]::CurrentDomain.BaseDirectory.TrimEnd('\')
# $full_script_path = [Environment]::GetCommandLineArgs()[0]
if ($root_path -eq $PSHOME.TrimEnd('\')) 
{     
    $root_path = $PSScriptRoot
    # $full_script_path = $root_path+"\"+$MyInvocation.MyCommand.Name
}

# backfill config if not provided with default root path
if ($config -eq "none") {
    $config = "$root_path\multilaunch.json"
}

# FUNCTIONS ********************************************************************
#*******************************************************************************
Function KillTasks {
    param($list)

    $list | ForEach-Object {
        Write-Host "  > $_" -ForegroundColor Red
        $friendly_name = [IO.Path]::GetFileNameWithoutExtension($_)
        $running_process = Get-Process $friendly_name -ErrorAction SilentlyContinue
        if ($running_process) {
            $running_process | Stop-Process -Force
        }
        Remove-Variable running_process
    }
}

Function RunPrograms {
    param($list)

    $list | ForEach-Object {
        $data_type = $_.GetType().Name

        if ($data_type -eq "String") {
            $full = $_
            $path = Split-Path -Path $full
            if ($path) {
                Write-Host "  > $full" -ForegroundColor Green
                Start-Process "$full" -WorkingDirectory "$path"
            }
        } elseif ($data_type -eq "PSCustomObject") {
            $full = $_.path
            $path = Split-Path -Path $full
            $cwd = $path
            $friendly_argument_list = " "
            Write-Host "  > $full" -ForegroundColor Green

            if ($_.cwd) {
                $cwd = $_.cwd
            }
            if ($_.arguments) {
                $friendly_argument_list = $_.arguments.Split(',')
            }

            Write-Host "    path: $full" -ForegroundColor Green
            Write-Host "    cwd:  $cwd" -ForegroundColor Green
            Write-Host "    args: $friendly_argument_list" -ForegroundColor Green
            Start-Process "$full" -WorkingDirectory "$cwd" -ArgumentList $friendly_argument_list
        }
    }
}

Function RunCommands {
    param($list)

    $list | ForEach-Object {
        Write-Host "  > $_" -ForegroundColor Blue
        cmd.exe /c $_
    }
}

Function WaitForProcess {
    param (
        $Name = 'none',
        [Switch]
        $IgnoreAlreadyRunningProcesses
    )

    $Name = [IO.Path]::GetFileNameWithoutExtension($Name)
    if ($IgnoreAlreadyRunningProcesses) {
        $NumberOfProcesses = (Get-Process -Name $Name -ErrorAction SilentlyContinue).Count
    } else {
        $NumberOfProcesses = 0
    }

    while ( (Get-Process -Name $Name -ErrorAction SilentlyContinue).Count -eq $NumberOfProcesses ) {
        Start-Sleep -Milliseconds 400
    }
}

Function WipeSystray {
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

# begin parsing the json
if (Test-Path -Path $config -PathType Leaf) {
    $json = Get-Content -Raw $config | ConvertFrom-Json
        $json | ForEach-Object {
            Write-Host "[Begin]: Beginning Multilaunch" -ForegroundColor Yellow
            # before section ******************************
            if ($_.before) {
                if ($_.before.kill_tasks) {
                    Write-Host "[Before]: Killing Tasks..." -ForegroundColor Red
                    KillTasks -list $_.before.kill_tasks
                }
                if ($_.before.run_programs) {
                    Write-Host "[Before]: Running Programs..." -ForegroundColor Green
                    RunPrograms -list $_.before.run_programs
                }
                if ($_.before.run_commands) {
                    Write-Host "[Before]: Running Commands..." -ForegroundColor Blue
                    RunCommands -list $_.before.run_commands
                }
            }

            # launch section ******************************
            if ($_.app -and $_.app.launch_path -and $_.app.watch_process_for_exit) {

                $path = Split-Path -Path $_.app.launch_path
                $friendly_path_name = $_.app.launch_path
                $friendly_name = [IO.Path]::GetFileNameWithoutExtension($_.app.watch_process_for_exit)
                if ($_.app.arguments) {
                    $friendly_arguments = $_.app.arguments.Split(',')
                    Write-Host "[Launch]: $friendly_path_name $friendly_arguments" -ForegroundColor Magenta
                    Start-Process $friendly_path_name -WorkingDirectory $path -ArgumentList $_.app.arguments.Split(',')
                    Remove-Variable friendly_arguments
                } else {
                    Write-Host "[Launch]: $friendly_path_name" -ForegroundColor Magenta
                    Start-Process $friendly_path_name -WorkingDirectory $path
                }
                Write-Host "[Launch]: Waiting for $friendly_name to end..." -ForegroundColor Magenta
                WaitForProcess -Name $friendly_name
                $a = Get-Process $friendly_name
                Remove-Variable path
                Remove-Variable friendly_path_name
                Remove-Variable friendly_name
                $a.waitforexit()
            }

            # after section *******************************
            if ($_.after) {
                if ($_.after.kill_tasks) {
                    Write-Host "[After]: Killing Tasks..." -ForegroundColor Red
                    KillTasks -list $_.after.kill_tasks
                }
                if ($_.after.run_programs) {
                    Write-Host "[After]: Running Programs..." -ForegroundColor Green
                    RunPrograms -list $_.after.run_programs
                }
                if ($_.after.run_commands) {
                    Write-Host "[After]: Running Commands..." -ForegroundColor Blue
                    RunCommands -list $_.after.run_commands
                }
            }

            # extras **************************************
            if ($_.extras) {
                if ($_.extras.wipe_sys_tray -and $_.extras.wipe_sys_tray -eq $true) {
                    WipeSysTray
                }
            }
        }
}

Write-Host "[End]: Multilaunch has ended successfully!" -ForegroundColor Yellow

<# in case I want to add elevated sections, here's a self-reminder:
    stop-exe-list-elevated -list $kill_these_after_elevated
#>
