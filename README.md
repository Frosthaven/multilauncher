# Overview

Sometimes games are best with companion apps. Launching those apps and closing them every time is tedious. This project is simple in scope, but takes away the tedium by giving you a single exe that can launch and close companion apps for you. Now with custom cmd support!

# Getting Started / Download
You will need both a compiled `multilaunch.exe` and `multilaunch.json` file.

You can find the latest `multilaunch.zip` on the [releases](https://github.com/Frosthaven/multilauncher/releases) page under "Assets".

# Configuration
Here is an example `multilaunch.json` configuration file:

```json
{
  "watch_process_name": "PathOfExile_x64",

  "run_these": [
    "D:/StandaloneLibrary/Grinding Gear Games/PathOfExile",
    "C:/Users/frosthaven/AppData/Local/Programs/Awakened PoE Trade/Awakened PoE Trade"
  ],
  "run_cmd": [],

  "kill_these_after": [
    "Awakened POE Trade"
  ],
  "run_cmd_after": []
}
```

`watch_process_name` is the name of the game or application as it appears in task manager.

`run_these` is an array of programs you want to run (notice we don't add ".exe" to anything). Make sure your main game or application is listed here!

`kill_these_after` is an array of program names as they appear in the task manager. These will be killed when the watched process exits (example: You've closed the game).

*In the example above, we are launching both Path of Exile and a trade macro program. When "PathOfExile_x64" is no longer running, we kill the process named "Awakened PoE Trade".*

# Adding CMD Scripts (Advanced)
There are two json config points for running cmd scripts:

`run_cmd` entries will execute after the programs have started, and `run_cmd_after` entries will execute after the programs have ended

*Note: If your cmd scripts require double quotes, be sure to escape each one you use (example: `\"`)


# Using A Different Config File

You can run multilauncher with a command line argument to provide your own config file. All of these are valid:

powershell
```ps1
Start-Process multilaunch.exe -ArgumentList "-config path/to/the/config.json"
```

cmd
```cmd
multilaunch.exe -config "path/to/the/config.json"
```

# Order of Events

1. multilauncher.exe starts
2. `run_these`
3. `run_cmd`
4. waits for `watch_process_name` to close
5. `run_these_after`
6. `run_cmd_after`
7. multilauncher.exe exits

# Building from Source
First, you want to install the ps2exe powershell module. Open a new powershell window (as admin) and run this command (selecting yes to all options):

```ps1
Install-Module ps2exe
```

Then, you will want to call this module to compile the script

```ps1
ps2exe .\multilaunch.ps1 .\multilaunch.exe
```

# Why Compile To EXE?
Although powershell scripts are very agile on their own, game launchers are quite picky. By compiling to an exe, we can feed the exe to game launcher libraries such as GoG.
