extends Actor

@export var stomp_impulse = 500.0
const JUMP_FORCE = 1300.0
const MOVE_SPEED = 800.0
const GRAVITY = 3000.0

var is_dead = false
var current_coins = 0


func _ready():
	update_coin_label()


# Called by coin on collision
func collect_coin():
	current_coins += 1
	update_coin_label()


# Called by portal on collision
func bank_coins():
	Global.add_coins(current_coins)


func update_coin_label():
	var coin_label = %CoinsLabel
	if coin_label:
		coin_label.text = "Coins: " + str(current_coins).pad_zeros(3)


func _on_enemy_detector_area_entered(area: Area2D) -> void:
	velocity = calculate_stomp_velocity(velocity, stomp_impulse)


func _on_enemy_detector_body_entered(body: Node2D) -> void:
	if is_dead:
		return
	
	is_dead = true # Disable player rather than destroying
	
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
