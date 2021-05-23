# Getting Started
In order for this to work, you will need both a compiled `multilaunch.exe` and `multilaunch.json` file, placed on your computer next to each other. You can find the latest build on the [releases](https://github.com/Frosthaven/multilauncher/releases) page

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

`run_these` is an array of programs you want to run. Make sure your main game or application is listed here!

`kill_these_after` is an array of exe names as they appear in the task manager. These will be killed when the watched process exits (or you've left the game).

In the example above, we are launching both Path of Exile and a trade macro program. When PathOfExile_x64 is no longer running, we kill the programs "Awakened-PoE-Trade-2.10.1" and ""Awakened PoE Trade" - two processes spawned by the trade macro when run.