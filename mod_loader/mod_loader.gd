extends Node
## Minimal mod loader for Throttle Trace.
## Injected via override.cfg next to the game executable.
##
## Mods live in user://mods/. Each mod is either:
##   - a folder  user://mods/<name>/  containing mod.gd
##   - a .pck/.zip  user://mods/<name>.pck  (mounted into res://, may contain res://mods/<name>/mod.gd)
## mod.gd must `extends Node`; it is added as a child of this loader, so _ready() runs after all game autoloads.

const MODS_DIR := "user://mods"

var loaded_mods: Dictionary = {}


func _ready() -> void:
	print("[ModLoader] starting, scanning ", ProjectSettings.globalize_path(MODS_DIR))
	DirAccess.make_dir_recursive_absolute(MODS_DIR)
	_mount_packs()
	_load_mods()


func _mount_packs() -> void:
	for file in DirAccess.get_files_at(MODS_DIR):
		if file.get_extension() in ["pck", "zip"]:
			var ok := ProjectSettings.load_resource_pack(MODS_DIR.path_join(file), true)
			print("[ModLoader] mounted pack ", file, " -> ", ok)


func _load_mods() -> void:
	var dirs := Array(DirAccess.get_directories_at(MODS_DIR))
	# Packs can ship res://mods/<name>/mod.gd
	if DirAccess.dir_exists_absolute("res://mods"):
		for d in DirAccess.get_directories_at("res://mods"):
			dirs.append("res://mods/" + d)
	dirs.sort()
	for d in dirs:
		var base: String = d if d.begins_with("res://") else MODS_DIR.path_join(d)
		var path := base.path_join("mod.gd")
		if not FileAccess.file_exists(path):
			continue
		var script = load(path)
		if script == null:
			push_error("[ModLoader] failed to load " + path)
			continue
		var mod: Node = script.new()
		mod.name = base.get_file()
		loaded_mods[mod.name] = mod
		add_child(mod)
		print("[ModLoader] loaded mod ", mod.name)


## Replace a game script with a subclass of it. Call from a mod's _init() or _ready(),
## BEFORE the game instantiates the target (works for scenes loaded later, not for autoloads already running).
## child_script_path's script must `extends "res://path/to/original.gd"`.
func install_script_extension(child_script_path: String) -> void:
	var child: Script = load(child_script_path)
	var parent: Script = child.get_base_script()
	child.new()  # force compile/caching of the chain
	child.take_over_path(parent.resource_path)
	print("[ModLoader] extended ", parent.resource_path, " with ", child_script_path)
