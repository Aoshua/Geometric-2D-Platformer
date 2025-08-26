@tool
extends Area2D

@onready var anim_player: AnimationPlayer = $AnimationPlayer

const LEVELS_DIR := "res://src/levels"         # <- your folder
const LEVEL_NAME_PATTERN := r"level_(\d+)$"     # <- your naming

var current_level: int = -1
var next_scene: PackedScene = null


func _ready() -> void:
	recompute_links()


func _notification(what: int) -> void:
	# Keep things fresh if reparented / edited
	if what == NOTIFICATION_POSTINITIALIZE \
	or what == NOTIFICATION_ENTER_TREE \
	or what == NOTIFICATION_PARENTED:
		recompute_links()


func recompute_links() -> void:
	current_level = infer_current_level()
	if current_level > 0:
		next_scene = infer_next_scene(current_level)
	else:
		next_scene = null


func get_host_scene_path() -> String:
	# We may be inside an instanced subscene (portal.tscn). The level is the
	# next ancestor whose scene_file_path is non-empty and DIFFERENT.
	var n: Node = self
	var first_scene_path := ""  # e.g. "res://src/objects/portal.tscn"
	while n != null:
		if n.scene_file_path != "":
			if first_scene_path == "":
				# first non-empty is likely the portal scene itself; keep going
				first_scene_path = n.scene_file_path
			elif n.scene_file_path != first_scene_path:
				# next non-empty (different) is the host level scene
				return n.scene_file_path
		n = n.get_parent()

	# Editor fallback (if we never found a host scene above)
	if Engine.is_editor_hint():
		var tree := get_tree()
		if tree:
			var edited := tree.edited_scene_root
			if edited and edited.scene_file_path != "":
				return edited.scene_file_path

	# Runtime fallback
	var tree2 := get_tree()
	if tree2 and tree2.current_scene and tree2.current_scene.scene_file_path != "":
		return tree2.current_scene.scene_file_path

	return ""


func infer_current_level() -> int:
	var scene_path := get_host_scene_path()
	print("scene_path: ", scene_path)
	if scene_path == "":
		return -1

	var base := scene_path.get_file().get_basename() # e.g. "level_3"
	print("base: ", base)
	var re := RegEx.new()
	if re.compile(LEVEL_NAME_PATTERN) != OK:
		return -1

	var m := re.search(base)
	if m:
		var s := m.get_string(1)  # capture group 1: the number
		if s != "":
			return int(s)
	return -1


func infer_next_scene(level: int) -> PackedScene:
	var dir := LEVELS_DIR.rstrip("/")
	var next_path := "%s/level_%d.tscn" % [dir, level + 1]
	if ResourceLoader.exists(next_path):
		return ResourceLoader.load(next_path)
	return null


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	recompute_links()

	if current_level <= 0:
		warnings.append("Can't infer current level from parent scene name. Expected something like 'level_3.tscn'.")

	if next_scene == null:
		var guess := "%s/level_%d.tscn" % [LEVELS_DIR.rstrip("/"), max(current_level, 1) + 1]
		warnings.append("Couldn't find next scene at: %s" % guess)

	return warnings


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("bank_coins"):
		body.bank_coins()
	SoundManager.play_sound("teleport")
	teleport()


func teleport() -> void:
	print("current_level: ", str(current_level))
	if current_level <= 0 or next_scene == null:
		push_warning("Portal couldn't resolve current level or next scene; aborting teleport.")
		return
	anim_player.play("fade_in")
	await anim_player.animation_finished
	Global.unlock_level(current_level)
	get_tree().change_scene_to_packed(next_scene)
