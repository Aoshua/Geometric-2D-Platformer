extends Actor

@export var stomp_impulse = 500.0
@export var green_texture: Texture2D
@export var blue_texture: Texture2D
@export var pink_texture: Texture2D
@export var camera_limit_left = -167
@export var camera_limit_right = 7748

# Rotation animation settings
@export var ground_rotation_speed = 0.75  # Rotation speed multiplier on ground
@export var air_rotation_speed = 1        # Faster rotation in air (no friction)
@export var velocity_spin_factor = 0.001  # How much velocity affects spin
@export var pentagon_radius = 45.0        # Distance from center to corner (adjust to match your sprite size)

const JUMP_FORCE = 1300.0
const MOVE_SPEED = 800.0
const GRAVITY = 3000.0
const PENTAGON_ANGLE = 72.0  # 360 / 5 sides

var is_dead = false
var current_coins = 0
var shield_active = false
var current_rotation = 0.0
var target_rotation = 0.0
var last_horizontal_input = 0.0

func _ready():
	update_skin()
	set_camera_limits()
	update_coin_label()
	update_shield_ui(false)
	# Initialize rotation to resting position (flat side down)
	%PlayerSkin.rotation = 0.0
	current_rotation = 0.0
	# toggle_control_visibility(false) # Useful when taking screenshots


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
	# print("loading player skin" + str(Global.current_skin))
	match Global.current_skin:
		Global.PlayerSkins.GREEN:
			%PlayerSkin.texture = green_texture
		Global.PlayerSkins.BLUE:
			%PlayerSkin.texture = blue_texture
		Global.PlayerSkins.PINK:
			print("matches pink")
			%PlayerSkin.texture = pink_texture


func update_coin_label():
	%CoinsLabel.text = "Gems: " + str(current_coins).pad_zeros(4)


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
	# Reset rotation to resting position
	%PlayerSkin.rotation = 0.0
	current_rotation = 0.0
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


func calculate_vertical_offset(rotation_degrees: float) -> float:
	# Calculate how much to raise the sprite so the lowest point stays at ground level
	# Pentagon rotates through 72° cycles (5 sides)
	# The lowest point varies as it tips from flat side to corner
	
	# Normalize rotation to 0-72° range for one side
	var normalized_rotation = fmod(abs(rotation_degrees), PENTAGON_ANGLE)
	
	# At 0° (flat side): lowest point is at apothem distance (radius * cos(36°))
	# At 36° (corner down): lowest point is at full radius
	# We need to offset the difference
	
	var apothem = pentagon_radius * cos(deg_to_rad(36.0))  # Distance to flat side
	var angle_from_flat = abs(normalized_rotation - PENTAGON_ANGLE / 2.0)  # Distance from 36° (corner position)
	
	# Calculate current lowest point
	var current_lowest = pentagon_radius * cos(deg_to_rad(angle_from_flat))
	
	# Offset is the difference between apothem (resting position) and current lowest point
	return apothem - current_lowest


func update_rotation_animation(delta: float, horizontal_input: float):
	# Determine rotation speed based on whether player is on ground or in air
	var rotation_speed = ground_rotation_speed if is_on_floor() else air_rotation_speed
	
	# Add velocity-based spin for more dynamic movement
	var velocity_spin = velocity.x * velocity_spin_factor
	
	if abs(horizontal_input) > 0.1:  # Player is moving
		# Rotate continuously in the direction of movement
		# Right = clockwise (positive), Left = counter-clockwise (negative)
		var rotation_direction = sign(horizontal_input)
		current_rotation += rotation_direction * rotation_speed * abs(horizontal_input) * delta * 360.0
		current_rotation += velocity_spin * delta * 360.0
		
		last_horizontal_input = horizontal_input
	else:
		# When stopped, gradually settle to nearest resting position (multiple of 72°)
		if is_on_floor():
			var nearest_rest = round(current_rotation / PENTAGON_ANGLE) * PENTAGON_ANGLE
			var rotation_diff = nearest_rest - current_rotation
			
			# Smoothly rotate to rest position
			if abs(rotation_diff) > 0.5:
				current_rotation += sign(rotation_diff) * min(abs(rotation_diff), rotation_speed * delta * 180.0)
			else:
				current_rotation = nearest_rest
		else:
			# In air with no input, maintain rotation with slight velocity-based spin
			current_rotation += velocity_spin * delta * 360.0
	
	# Apply rotation to sprite
	%PlayerSkin.rotation = deg_to_rad(current_rotation)
	
	# Apply vertical offset to keep lowest point at consistent height (only on ground)
	if is_on_floor():
		var offset = calculate_vertical_offset(current_rotation)
		%PlayerSkin.position.y = (-1 * pentagon_radius) + offset
	else:
		# In air, no offset needed
		%PlayerSkin.position.y = 0


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

	# Update rotation animation
	update_rotation_animation(delta, horizontal_input)

	# Apply movement
	move_and_slide()


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
