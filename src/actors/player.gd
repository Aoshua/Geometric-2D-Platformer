extends Actor

@export var stomp_impulse = 500.0
@export var green_texture: Texture2D
@export var blue_texture: Texture2D
@export var pink_texture: Texture2D
@export var camera_limit_left = -167
@export var camera_limit_right = 7748

const JUMP_FORCE = 1300.0
const MOVE_SPEED = 800.0
const GRAVITY = 3000.0

var is_dead = false
var current_coins = 0
var shield_active = false

@export_group("Jelly Deform")
@export var jelly_enabled: bool = true
@export var max_stretch: float = 0.15         # 15% at top speed
@export var speed_for_max: float = MOVE_SPEED
@export var shear_at_max: float = 0.10        # tiny tilt forward
@export var spring: float = 40.0
@export var damping: float = 12.0
@export var min_scale: float = 0.9
@export var max_scale: float = 1.3

@onready var jelly_node: Node2D = %Jelly

# Jelly state (start at 1:1, no shear)
var _sx := 1.0
var _sy := 1.0
var _vsx := 0.0
var _vsy := 0.0
var _shear := 0.0     # Node2D.skew is in radians; we'll feed a small value
var _vshear := 0.0

# For landing squash
var _was_on_floor := false
var _prev_velocity := Vector2.ZERO

# TODO: This sucks when false, so just get rid of it
var use_smooth_graphics: bool = true

func _ready():
	update_skin()
	set_camera_limits()
	update_coin_label()
	update_shield_ui(false)


func set_camera_limits():
	var camera = get_node("Camera2D")
	camera.limit_left = camera_limit_left
	camera.limit_right = camera_limit_right


# Called by coin on collision
func collect_coin():
	SoundManager.play_sound("coin-grabbed")
	current_coins += 1
	update_coin_label()


# Called by portal on collision
func bank_coins():
	Global.add_coins(current_coins)


func update_skin():
	# Filtering mode depends on toggle
	if use_smooth_graphics:
		%PlayerSkin.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	else:
		%PlayerSkin.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	%PlayerSkin.texture_repeat = CanvasItem.TEXTURE_REPEAT_DISABLED
	
	print("loading player skin" + str(Global.current_skin))
	match Global.current_skin:
		Global.PlayerSkins.GREEN:
			print("matches green")
			%PlayerSkin.texture = green_texture
		Global.PlayerSkins.BLUE:
			print("matches blue")
			%PlayerSkin.texture = blue_texture
		Global.PlayerSkins.PINK:
			print("matches pink")
			%PlayerSkin.texture = pink_texture


func update_coin_label():
	%CoinsLabel.text = "Coins: " + str(current_coins).pad_zeros(4)


func update_shield_ui(showShield: bool):
	%Shield.visible = showShield
		
	if (Global.shields == 0):
		%ShieldButton.visible = false
		%ShieldLabel.visible = false
	elif (Global.shields == 1):
		%ShieldLabel.visible = false
	else:
		%ShieldLabel.text = "x " + str(Global.shields)


func _on_enemy_detector_area_entered(area: Area2D) -> void:
	velocity = calculate_stomp_velocity(velocity, stomp_impulse)


func _on_enemy_detector_body_entered(body: Node2D) -> void:
	if shield_active:
		SoundManager.play_sound("shield-activated")
		# Calculate the normalized vector from the enemy to the player.
		var bounce_dir = (global_position - body.global_position).normalized()
		var bounce_distance = 50
		var bounce_duration = 0.5
		
		# Store the enemy's original velocity if it's a CharacterBody2D
		var original_velocity = Vector2.ZERO
		if body is CharacterBody2D:
			original_velocity = body.velocity
		
		# Create and configure tweens using the create_tween() method
		var player_tween = create_tween()
		player_tween.tween_property(self, "global_position", 
			global_position + bounce_dir * bounce_distance, bounce_duration)\
			.set_trans(Tween.TRANS_QUAD)\
			.set_ease(Tween.EASE_OUT)
		
		# Create tween for the enemy
		var enemy_tween = body.create_tween()
		enemy_tween.tween_property(body, "global_position", 
			body.global_position - bounce_dir * (bounce_distance * 2), bounce_duration)\
			.set_trans(Tween.TRANS_QUAD)\
			.set_ease(Tween.EASE_OUT)
		
		# Reset the enemy's velocity after the tween completes
		enemy_tween.tween_callback(func():
			if body is CharacterBody2D:
				body.velocity = original_velocity
		)
		
		# Disable the shield and update the UI.
		shield_active = false
		update_shield_ui(false)
		return
	
	if is_dead:
		return
	
	is_dead = true # Disable player rather than destroying
	MusicManager.pause_music()
	SoundManager.play_sound("game-over", -10)
	
	process_mode = Node.PROCESS_MODE_DISABLED
	visible = false
	toggle_control_visibility(false)
	
	var game_over_scene = load("res://src/ui/menus/game_over.tscn").instantiate()
	game_over_scene.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child(game_over_scene)
	
	if game_over_scene.has_method("set_player"):
		game_over_scene.set_player(self)


func revive() -> void:
	is_dead = false
	process_mode = Node.PROCESS_MODE_INHERIT
	visible = true
	toggle_control_visibility(true)
	# Reset other state (position, velocity, etc.)?


func _on_pause_button_pressed():
	get_tree().paused = true
	toggle_control_visibility(false)
	var pause_menu = load("res://src/ui/menus/pause_menu.tscn").instantiate()
	pause_menu.connect("resume_game", _on_resume_game)
	pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child(pause_menu)


func _on_resume_game():
	toggle_control_visibility(true)
	get_tree().paused = false


func toggle_control_visibility(show: bool):
	%Joystick.visible = show
	%JumpButton.visible = show
	%PauseButton.visible = show


func _physics_process(delta: float) -> void:
	# Get horizontal input from joystick
	var horizontal_input = %Joystick.get_joystick_dir().x
	
	# Check for keyboard input (A and D keys)
	if Input.is_action_pressed("move_left"):
		horizontal_input = -1.0  # Left (A key)
	elif Input.is_action_pressed("move_right"):
		horizontal_input = 1.0  # Right (D key)

	# If the player is on the floor and the jump button is pressed, set vertical velocity for jump
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = -JUMP_FORCE
		SoundManager.play_sound("jump", -15)
	
	# If the jump button is released while moving up (jump interrupted)
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= 0.5  # Reduce upward velocity, creating a "jump cut" effect
	
	# Calculate horizontal velocity based on input, and retain the previous vertical velocity
	velocity.x = horizontal_input * MOVE_SPEED
	
	# Apply gravity while in the air
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Apply movement
	move_and_slide()
	
	# Update jello deformation
	_update_jelly(delta)
	_prev_velocity = velocity
	_was_on_floor = is_on_floor()


func get_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"), # Left and right at the same time = 0
		-1.0 if Input.is_action_just_pressed("jump") and is_on_floor() else 1.0 # y axis negative (-1 for up, 1 for down)
	)


func calculate_move_velocity(
		linear_velocity: Vector2,
		direction: Vector2,
		is_jump_interrupted: bool
	) -> Vector2:
	var out = linear_velocity
	out.x = speed.x * direction.x
	out.y += gravity * get_physics_process_delta_time()
	if direction.y == -1.0:
		out.y = speed.y * direction.y # Immediately jump
	if is_jump_interrupted:
		out.y = 0.0
	return out


func calculate_stomp_velocity(linear_velocity: Vector2, impulse: float) -> Vector2:
	var out = linear_velocity
	out.y = -impulse # Negates the y velocity
	return out


func _on_shield_button_pressed():
	SoundManager.play_sound("shield-activated")
	Global.use_shield()
	shield_active = true
	update_shield_ui(true)


func _spring(x: float, v: float, goal: float, k: float, c: float, dt: float) -> Dictionary:
	v += (k * (goal - x) - c * v) * dt
	x += v * dt
	return {"x": x, "v": v}


func _update_jelly(delta: float) -> void:
	if not jelly_enabled or jelly_node == null:
		return

	var v: Vector2 = velocity
	var speed := v.length()
	var horiz_dominates = abs(v.x) >= abs(v.y)

	# Map speed to [0..1] for deformation amount
	var t = clamp(speed / max(1.0, speed_for_max), 0.0, 1.0)
	var target_stretch = 1.0 + t * max_stretch
	var target_squash = 1.0 / target_stretch
	var target_shear = t * shear_at_max
	
	if not use_smooth_graphics:
		target_shear = 0.0

	var desired_sx := 1.0
	var desired_sy := 1.0
	var desired_shear := 0.0

	if horiz_dominates:
		desired_sx = target_stretch
		desired_sy = target_squash
		desired_shear = sign(v.x) * target_shear
	else:
		# (keep if you want vertical jelly during jumps/falls)
		desired_sx = target_squash
		desired_sy = target_stretch
		desired_shear = sign(v.y) * target_shear

	# --- Landing squash juice ---
	if is_on_floor() and not _was_on_floor and _prev_velocity.y > 0.0:
		var impact := _prev_velocity.y
		var bump = clamp(impact * 0.0005, 0.0, 0.25)  # tune 0.0005..0.001
		_sx = max(_sx - bump, min_scale)
		_sy = min(_sy + bump, max_scale)
		_shear = 0.0
		_vsx = 0.0
		_vsy = 0.0
		_vshear = 0.0

	# --- Spring toward desired state ---
	var r := _spring(_sx, _vsx, desired_sx, spring, damping, delta)
	_sx = r.x
	_vsx = r.v

	r = _spring(_sy, _vsy, desired_sy, spring, damping, delta)
	_sy = r.x
	_vsy = r.v

	r = _spring(_shear, _vshear, desired_shear, spring, damping, delta)
	_shear = r.x
	_vshear = r.v

	# Safety clamps
	_sx = clamp(_sx, min_scale, max_scale)
	_sy = clamp(_sy, min_scale, max_scale)

	# Apply to visuals only (physics shapes remain unchanged)
	jelly_node.scale = Vector2(_sx, _sy)

	if use_smooth_graphics:
		jelly_node.skew = _shear    # allow shear for gooey lean
	else:
		jelly_node.skew = 0.0       # disable shear for pixel crisp
		jelly_node.position = jelly_node.position.round()
