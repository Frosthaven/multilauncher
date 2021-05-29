$icon = "./assets/app.ico"
$title = "MultiLaunch manages the launching and automation of companion apps so that you don't have to"
$description = $title

ps2exe ./multilaunch.ps1 ./multilaunch.exe `
    -iconFile $icon `
    -title $title `
    -description $description
ps2exe ./multilaunch.ps1 ./multilaunch_elevated.exe `
    -requireAdmin `
    -iconFile $icon `
    -title $title `
    -description $description