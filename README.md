# Throttle Trace Rivals

An unofficial mod for [Throttle Trace](https://store.steampowered.com/app/4535730/) that lets you race your friends' personal-best ghosts in Time Attack.

- Every ghost file in your `ghosts` folder that matches the current track is raced as a gold ghost, labelled with the driver's name and lap time, next to your own PB ghost.
- Your own PB ghosts are exported automatically (when you open a track in Time Attack and whenever you set a new PB) to `ghosts/exports/`, ready to send to others. Existing files are never replaced or deleted.

Built for Throttle Trace v0.39.0 (Godot 4.6). Game updates may break it.

## Install

### 1. Install the mod loader

The game has no built-in mod support. Install the [Throttle Trace Mod Loader](https://github.com/NoelJarling/Throttle-Trace-Mod-Loader) first, including the `--enable-mods` launch option.

### 2. Copy `mods/` into the game's user data folder

| OS      | User data folder                                    |
|---------|-----------------------------------------------------|
| Linux   | `~/.local/share/godot/app_userdata/Throttle Trace/` |
| Windows | `%APPDATA%\Godot\app_userdata\Throttle Trace\`      |

Afterwards it should look like this:

```
Throttle Trace/            (user data folder)
├── mod_loader/
│   └── mod_loader.gd
├── mods/
│   └── rival_ghosts/
│       └── mod.gd
└── ghosts/                (created by the mod on first start)
    └── exports/
```

### 3. Start the game

Start Throttle Trace through Steam. The mod creates the `ghosts/` folder. Your PB for a track is exported the first time you open that track in Time Attack.

## Usage

- **Share your ghosts:** send files from `ghosts/exports/` to your friends. They are named `<track>_<player>_<m-ss.mmm>.ttghost`.
- **Race other ghosts:** put `.ttghost` files you received directly into the `ghosts/` folder (not into `exports/`), then start a Time Attack run on that track. All matching ghosts are loaded; files for other tracks are ignored.

## Uninstall

Delete `mods/rival_ghosts/` from the user data folder. Your ghosts stay in `ghosts/` until you delete that folder too.
