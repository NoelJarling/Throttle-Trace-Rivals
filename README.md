# Throttle Trace Rivals

An unofficial mod for [Throttle Trace](https://store.steampowered.com/app/4535730/) that lets you race your friends' personal-best ghosts in Time Attack.

- Every ghost file in your `ghosts` folder that matches the current track is raced as a ghost in the Ashton Vale livery, labelled with the driver's name and lap time, next to your own PB ghost.
- Your own PB ghosts are exported automatically (on game start and whenever you set a new PB) to `ghosts/exports/`, ready to send to others. Existing files are never replaced or deleted.

Built for Throttle Trace v0.39.0 (Godot 4.6). Game updates may break it.

## Install

The game has no built-in mod support, so the mod is loaded through a small mod loader that Godot starts via `override.cfg`.

### 1. Copy `override.cfg` into the game folder

In Steam: right-click Throttle Trace → **Manage → Browse local files**. Put `override.cfg` next to the game executable.

| OS      | Default game folder                                         |
|---------|-------------------------------------------------------------|
| Linux   | `~/.local/share/Steam/steamapps/common/Throttle Trace/`     |
| Windows | `C:\Program Files (x86)\Steam\steamapps\common\Throttle Trace\` |

### 2. Copy `mod_loader/` and `mods/` into the game's user data folder

| OS      | User data folder                                    |
|---------|-----------------------------------------------------|
| Linux   | `~/.local/share/godot/app_userdata/Throttle Trace/` |
| Windows | `%APPDATA%\Godot\app_userdata\Throttle Trace\`      |

The folder exists once you have started the game at least once. Afterwards it should look like this:

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

### 3. Enable mods in the Steam launch options

Mods are only loaded when the game is started with `--enable-mods`. In Steam: right-click Throttle Trace → **Properties → General → Launch Options** and enter:

```
%command% --enable-mods
```

Without this option the game runs completely unmodded, even with everything installed.

### 4. Start the game

Start Throttle Trace through Steam. The mod creates the `ghosts/` folder and exports your existing PBs on first start.

## Usage

- **Share your ghosts:** send files from `ghosts/exports/` to your friends. They are named `<track>_<player>_<m-ss.mmm>.ttghost`.
- **Race other ghosts:** put `.ttghost` files you received directly into the `ghosts/` folder (not into `exports/`), then start a Time Attack run on that track. All matching ghosts are loaded; files for other tracks are ignored.

## Uninstall

To play without mods, just remove `--enable-mods` from the launch options.

To uninstall, delete `override.cfg` from the game folder. To remove everything, also delete `mod_loader/`, `mods/` and `ghosts/` from the user data folder.

## Troubleshooting

- **Mod stopped working after an update or "Verify integrity of game files":** Steam may have removed `override.cfg`. Copy it back into the game folder.
- **Mods don't load at all:** check that the launch options contain `%command% --enable-mods`. Without it the log shows `[ModLoader] mods disabled`.
- **Logs:** `logs/godot.log` in the user data folder. Mod loader messages start with `[ModLoader]`.
