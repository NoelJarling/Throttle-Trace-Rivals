extends Node
## Rival Ghosts: in Time Attack, every ghost file in user://ghosts/ that matches
## the current track is raced as a gold ghost next to your own PB ghost.
##
## Sharing: on game start and whenever you set a new PB, PB ghosts that aren't exported
## yet are added to user://ghosts/exports/<track name>_<player name>_<m-ss.mmm>.ttghost.
## Existing files are never replaced or deleted. Send a file to others;
## they drop it into their user://ghosts/ folder.
##
## File format (JSON): { format, version, physics, track_id, track_name,
##   driver, time, captures: [[time, progress, child_surface_index, slip_angle, speed], ...] }

const FORMAT := "throttle-trace-ghost"
const GHOSTS_DIR := "user://ghosts"
const EXPORTS_DIR := "user://ghosts/exports"
const RIVAL_COLOR := Color(1.0, 0.72, 0.1)

var _ghost_car_scene: PackedScene = preload("res://ghosts/ghost_car.tscn")
var _track: Track
var _rivals: Array = []  # [{ghost, captures, car}]


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(EXPORTS_DIR)
	get_tree().node_added.connect(_on_node_added)
	TimeAttackManager.restarted.connect(_spawn_rivals)
	# Convert existing PB ghosts into shareable files
	for profile in TrackProfile.get_profiles(true, true):
		_export_pb(profile)


func _on_node_added(node: Node) -> void:
	if node is Track:
		# Re-emitted on a full restart, which rebuilds the player car
		node.initialized.connect(_on_track_initialized.bind(node))


func _on_track_initialized(track: Track) -> void:
	if not track.is_time_trial or track.player == null:
		return
	for rival in _rivals:
		if is_instance_valid(rival.get("car")):
			rival.car.queue_free()
	_track = track
	_rivals = []
	var profile: TrackProfile = track.params.profile
	track.player.lap_completed.connect(_on_lap_completed.bind(profile))

	for file in DirAccess.get_files_at(GHOSTS_DIR):
		if file.get_extension() != "ttghost":
			continue
		var ghost = JSON.parse_string(FileAccess.get_file_as_string(GHOSTS_DIR.path_join(file)))
		if _is_compatible(ghost, track, profile):
			_rivals.append({ghost = ghost, captures = _to_game_captures(ghost)})

	_spawn_rivals()


func _on_lap_completed(lap: Lap, profile: TrackProfile) -> void:
	_export_if_new_pb.call_deferred(lap, profile)  # runs after the game saved a possible new PB
	_spawn_rivals()


## Exports only this track's ghost, and only if this lap became the saved PB.
func _export_if_new_pb(lap: Lap, profile: TrackProfile) -> void:
	var data = TimeAttackManager.get_ghost_data(profile)
	if data != null and float(data.time) == lap.time:
		_export_pb(profile)


func _is_compatible(ghost, track: Track, profile: TrackProfile) -> bool:
	if not ghost is Dictionary or ghost.get("format") != FORMAT or ghost.get("track_id") != profile.id:
		return false
	if not ghost.get("captures") is Array or ghost.captures.size() < 2:
		return false
	var child_count := track.surface.child_surfaces.size()
	return ghost.captures.all(func(c): return int(c[2]) < child_count)


func _to_game_captures(ghost: Dictionary) -> Array:
	return ghost.captures.map(func(c): return {
		time = float(c[0]), progress = float(c[1]), child_surface_index = int(c[2]),
		slip_angle = float(c[3]), speed = float(c[4]),
	})


func _spawn_rivals() -> void:
	if not is_instance_valid(_track):
		return
	for rival in _rivals:
		if is_instance_valid(rival.get("car")):
			rival.car.queue_free()
		var car: Node3D = _ghost_car_scene.instantiate()
		_track.add_child(car)
		car.init(_track.player, rival.captures)
		car.model.color = RIVAL_COLOR

		var tag := Label3D.new()
		tag.text = "%s  %s" % [rival.ghost.get("driver", "Rival"), Utils.format_seconds_to_minutes(rival.ghost.time)]
		tag.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		tag.fixed_size = true
		tag.pixel_size = 0.0008
		tag.font_size = 32
		tag.outline_size = 8
		tag.modulate = RIVAL_COLOR
		tag.no_depth_test = true
		tag.position = Vector3(0, 1.2, 0)
		car.add_child(tag)
		rival.car = car


## Adds the PB ghost of a track to exports/ unless that lap is already exported.
## Existing files are never replaced or deleted.
func _export_pb(profile: TrackProfile) -> void:
	var data = TimeAttackManager.get_ghost_data(profile)
	if data == null:
		return
	var driver := Steam.getPersonaName() if SteamService.enabled else "Player"
	var time := float(data.time)
	var file_name := ("%s_%s_%d-%06.3f.ttghost" % [profile.track_name, driver, int(time / 60.0), fmod(time, 60.0)]).validate_filename()
	var path := EXPORTS_DIR.path_join(file_name)
	if FileAccess.file_exists(path):
		return
	for other in DirAccess.get_files_at(EXPORTS_DIR):
		var g = JSON.parse_string(FileAccess.get_file_as_string(EXPORTS_DIR.path_join(other)))
		if g is Dictionary and g.get("track_id") == profile.id and g.get("driver") == driver and g.get("time") == time:
			return  # same lap already exported under another file name

	var ghost := {
		format = FORMAT,
		version = 1,
		physics = TimeAttackManager._file_name,
		track_id = profile.id,
		track_name = profile.track_name,
		driver = driver,
		time = time,
		captures = data.captures.map(func(c): return [
			float(c.time), float(c.progress), int(c.child_surface_index),
			float(c.get("slip_angle", 0.0)), float(c.get("speed", 0.0)),
		]),
	}
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(ghost, "", false, true))
