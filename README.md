# Overview

Sometimes games are best with companion apps. Launching those apps and closing them every time is tedious. This project is simple in scope, but takes away the tedium by giving you a single exe that can launch and close companion apps for you. Now with custom cmd support!

# Getting Started / Download
You will need both a compiled `multilaunch.exe` and `multilaunch.json` file.

You can find the latest `multilaunch.zip` on the [releases](https://github.com/Frosthaven/multilauncher/releases) page under "Assets".

# Config
The `multilaunch.json` configuration file has the following sections and values:

* `app`: This is the configuration section for the main program you intend to launch.
  * `watch_process_for_exit` is the process name as it appears in task manager for the main application while running.
  * `launch_path` is the full path to the main application's executable.
  * `arguments` is an array of arguments you want to feed to the main application.

* `before` & `after`: Entries in these sections execute actions either before the main application is launched or after it has closed.
  * `kill_tasks` an array of tasks to kill by name as they appear task manager (without extension)
  * `run_programs` an array of programs to run given the full path/to/the/file
  * `run_commands` an array of command line scripts to run

* `extras`: This section holds extra configuration options.
  * `wipe_sys_tray`: Can be `true` or `false`. If true, Multilaunch will swipe your mouse across the system tray to remove ghost icons from killed processes.

***Important Note:*** *In the current release, it is advisable to NOT add file extensions (like .exe) to paths and process names unless needed inside of a `run_commands` section*

# Example `multilaunch.json`
```json
{
  "app": {
    "watch_process_for_exit": "PathOfExile_x64",
    "launch_path": "C:/Games/Grinding Gear Games/PathOfExile",
    "arguments": [
      "--nologo",
      "--waitforpreload"
    ]
  },

  "before": {
    "run_programs": [
      "C:/Users/frosthaven/AppData/Local/Programs/Awakened PoE Trade/Awakened PoE Trade"
    ]
  },

  "after": {
    "kill_tasks": [
      "Awakened POE Trade"
    ]
  },

  "extras": {
    "wipe_sys_tray": true
  }
}
```

In the example above, we are launching the game *Path of Exile* with two command line arguments that the game supports. We are also telling Multilaunch to keep an eye on the *PathOfExile_x64* process.

Before the game launches, we have Multilaunch start up a useful trade macro companion app - *Awakened PoE Trade*.

After the game is closed (and the *PathOfExile_x64* process no longer exists), we are closing our trade macro by killing the task *Awakened POE Trade* in task manager.

Finally, in the extras section, we are telling Multilaunch to swipe the mouse across the system tray when everything is done. This is because killing the trade macro leaves a ghost icon in the tray, and moving the mouse over it fixes it.


# Using A Different Config File

You can run multilauncher with a command line argument to provide your own config file. All of these are valid:

powershell
```ps1
Start-Process multilaunch.exe -ArgumentList "-config path/to/the/config_name.json"
```

cmd
```cmd
multilaunch.exe -config "path/to/the/config_name.json"
```

game launcher "arguments" or "parameters" box
```cmd
-config "path/to/the/config.json"
```

# Building from Source
First, you want to install the ps2exe powershell module. Open a new powershell window (as admin) and run this command (selecting yes to all options):

```ps1
Install-Module ps2exe
```

Then, you will want to call the build script to begin compilation:

```ps1
ps2exe .\build
```

# Why Compile To EXE?
Although powershell scripts are very agile on their own, game launchers are quite picky. By compiling to an exe, we can feed the exe to game launcher libraries such as GoG & Steam.
