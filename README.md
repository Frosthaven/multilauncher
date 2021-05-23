# Getting Started
In order for this to work, you will need both a compiled `multilaunch.exe` and `multilaunch.json` file, placed on your computer next to each other. You can find the latest build in a zip file located on the [releases](https://github.com/Frosthaven/multilauncher/releases) page

# Configuration
Here is an example `multilaunch.json` configuration file:

```json
{
	"watch_process_name": "PathOfExile_x64",
	"run_these": [
		"D:/StandaloneLibrary/Grinding Gear Games/PathOfExile",
		"D:/StandaloneLibrary/POE Tools/Awakened-PoE-Trade-2.10.1"
	],
	"kill_these_after": [
		"Awakened-PoE-Trade-2.10.1",
		"Awakened POE Trade"
	]
}
```

`watch_process_name` is the name of the game or application as it appears in task manager.

`run_these` is an array of programs you want to run (notice we don't add ".exe" to anything). Make sure your main game or application is listed here!

`kill_these_after` is an array of program names as they appear in the task manager. These will be killed when the watched process exits (IE: You've closed the game).

In the example above, we are launching both Path of Exile and a trade macro program. When PathOfExile_x64 is no longer running, we kill the programs "Awakened-PoE-Trade-2.10.1" and ""Awakened PoE Trade" - two processes spawned by the trade macro when run.

# Building from source
First, you want to install the ps2exe powershell module. Open a new powershell window (as admin) and run this command (selecting yes to all options):

```ps1
Install-Module ps2exe
```

Then, you will want to call this module to compile the script

```ps1
ps2exe .\multilaunch.ps1 .\multilaunch.exe
```

# Why Compile To EXE?
Althought powershell scripts are very agile on their own, game launchers are quite picky. By compiling to an exe, we can feed the exe to game launcher libraries such as GoG.
