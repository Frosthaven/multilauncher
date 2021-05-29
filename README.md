# Overview

Sometimes games are best with companion apps. Launching those apps and closing them every time is tedious. This project is simple in scope, but takes away the tedium by giving you a single exe that can launch and close companion apps for you. Now with custom cmd support!

# Getting Started / Download
You will need both a compiled `multilaunch.exe` and `multilaunch.json` file.

You can find the latest `multilaunch.zip` on the [releases](https://github.com/Frosthaven/multilauncher/releases) page under "Assets".

# Configuration
The `multilaunch.json` configuration file has 4 sections: `app`, `before`, `after`, and `extras`.

**app**
This is the configuration section for your main program you intend to launch.

`launch_path` is the full path to the main application's executable (without extension)

`watch_process_for_exit` is the process name (without extension) as it appears in task manager for the main application while running.

`arguments` is an array of arguments you want to feed to the main application.

**before:**

Entries in this configuration section take place before the main application launches. Supports the arrays `kill_tasks`, `run_programs`, and `run_commands`.

**after:**

Entries in this configuration section take place after the main application is closed. Supports the arrays `kill_tasks`, `run_programs`, and `run_commands`.

**extras:**

This section holds extra configuration options.

`wipe_sys_tray`: Can be `true` or `false`. If true, Multilaunch will swipe your mouse across the system tray to remove ghost icons from killed processes.

## example multilaunch.json
```json
{
	"app": {
		"launch_path": "C:/Games/Grinding Gear Games/PathOfExile",
		"watch_process_for_exit": "PathOfExile_x64",
		"arguments": [
      "--nologo",
      "--waitforpreload"
		]
	},

	"before": {
		"kill_tasks": [
			
		],
		"run_programs": [
			"C:/Users/frosthaven/AppData/Local/Programs/Awakened PoE Trade/Awakened PoE Trade"
		],
		"run_commands": [

		]
	},

	"after": {
		"kill_tasks": [
			"Awakened POE Trade"
		],
		"run_programs": [
			
		],
		"run_commands": [

		]
	},

	"extras": {
		"wipe_sys_tray": true
	}
}
```

In the example above, we are launching the game "Path of Exile" with two command line arguments that the game supports. We are also telling Multilaunch to keep an eye on the "PathOfExile_x64" process.

Before The game launches, we have Multilaunch start up a useful trade macro companion app - "Awakened PoE Trade".

After the game is closed (and the "PathOfExile_x64" process no longer exists), we are closing our trade macro by killing thee task "Awakened POE Trade" in task manager.

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
Although powershell scripts are very agile on their own, game launchers are quite picky. By compiling to an exe, we can feed the exe to game launcher libraries such as GoG.
