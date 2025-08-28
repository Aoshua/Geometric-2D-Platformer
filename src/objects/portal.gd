@tool
extends Area2D

@onready var anim_player: AnimationPlayer = $AnimationPlayer

const LEVELS_DIR := "res://src/levels"
const LEVEL_NAME_PATTERN := r"level_(\d+)$"
var current_level: int = -1
var next_scene: PackedScene = null

# Animation vars
var pulse_speed = 1.2          # how fast it "breathes"
var pulse_amount = 0.04        # ± scale amount (0.06 = ±6%)
var rotation_speed = 0.7       # speed of the subtle rotation
var rotation_deg = 0.5		   # max rotation swing, in degrees
var glow_scale = 1.16          # base size of the glow layer
var glow_pulse_amount = 0.04   # how much the glow grows/shrinks
var glow_alpha = 0.45          # base glow strength
var glow_alpha_variation = 0.25# how much the glow fades in/out
var _t = 0.0
var _base_scale = Vector2.ONE
var _glow: Sprite2D

func _ready() -> void:
	z_index = 1            # in front of tiles, behind player
	z_as_relative = false  # use absolute z (ignore parent’s z)
	recompute_links()
	init_glow_animation()


func init_glow_animation():
	_base_scale = %PortalSprite.scale
	
	_glow = Sprite2D.new()
	_glow.texture = %PortalSprite.texture
	_glow.centered = %PortalSprite.centered
	_glow.offset = %PortalSprite.offset
	_glow.flip_h = %PortalSprite.flip_h
	_glow.flip_v = %PortalSprite.flip_v
	_glow.modulate = Color(1, 1, 1, glow_alpha)
	
	%PortalSprite.add_child(_glow)
	_glow.z_index = %PortalSprite.z_index - 1
	_glow.show_behind_parent = true
	_glow.position = Vector2.ZERO
	_glow.scale = Vector2.ONE
	
	var mat = CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_glow.material = mat


func _process(delta: float) -> void:
	_t += delta

	# Pulse
	var s = 1.0 + pulse_amount * sin(_t * TAU * pulse_speed)
	%PortalSprite.scale = _base_scale * s

	# Subtle rotation
	rotation = deg_to_rad(rotation_deg) * sin(_t * TAU * rotation_speed)

	# Glow motion
	var gs = glow_scale + glow_pulse_amount * sin(_t * TAU * pulse_speed + PI/6.0)
	_glow.scale = _base_scale * gs

	var a = clamp(glow_alpha + glow_alpha_variation * sin(_t * TAU * pulse_speed - PI/4.0), 0.0, 1.0)
	_glow.modulate.a = a

	_glow.rotation = rotation * 0.7


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
	if scene_path == "":
		return -1

	var base := scene_path.get_file().get_basename() # e.g. "level_3"
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
	
	if current_level <= 0 or next_scene == null:
		end_game(body)
	else:
		teleport()


func end_game(body: Node2D):
	if body.has_method("toggle_control_visibility"):
		body.toggle_control_visibility(false)
	
	var menu = load("res://src/ui/menus/game_complete_menu.tscn").instantiate()
	menu.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child(menu)


func teleport() -> void:
	anim_player.play("fade_in")
	await anim_player.animation_finished
	Global.unlock_level(current_level)
	get_tree().change_scene_to_packed(next_scene)
