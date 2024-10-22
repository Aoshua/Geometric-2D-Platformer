extends TouchScreenButton

@onready var max_distance = shape.radius
@onready var transparency_level = 0.5
@onready var knob = $Knob  # Reference to the knob inside the joystick

var stick_center: Vector2 = Vector2.ZERO
var touched: bool = false
var touch_index: int = -1  # Track which touch is controlling the joystick
var joystick_diameter: int = 300  # Make the interactable area bigger

func _ready():
	# Set transparency and the center of the joystick
	modulate = Color(1, 1, 1, transparency_level)
	knob.modulate = Color(1, 1, 1, transparency_level)
	stick_center = knob.position  # Store the initial knob center position

func _input(event):
	# Detect touch and mouse input events
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		# If the touch or mouse click begins and the joystick is not being touched
		if (event is InputEventScreenTouch and event.pressed and touch_index == -1) or (event is InputEventMouseButton and event.pressed and touch_index == -1):
			# Check if the touch or click occurs inside the joystick's boundaries
			var global_position = get_global_position()

			# Define a larger interactable size for the joystick area
			var size = Vector2(joystick_diameter, joystick_diameter)

			# Create a Rect2 with the global position as the center and size as the second parameter
			var rect = Rect2(global_position - size / 2, size)

			# Check if the touch/click point is within the Rect2 area
			if rect.has_point(event.position):
				touch_index = event.index if event is InputEventScreenTouch else -2  # -2 for mouse input
				touched = true

		# If the touch or mouse click ends and it's the tracked touch
		elif (event is InputEventScreenTouch and not event.pressed and event.index == touch_index) or (event is InputEventMouseButton and not event.pressed and touch_index == -2):
			touch_index = -1  # Reset the tracked touch
			touched = false
			reset_joystick_position()

	# Handle drag event
	if (event is InputEventScreenDrag and event.index == touch_index) or (event is InputEventMouseMotion and touch_index == -2):
		move_knob(event.position)

func _process(delta):
	# Constrain the knob's movement within max_distance
	if touched:
		knob.position = stick_center + (knob.position - stick_center).limit_length(max_distance)

# Move the knob based on the touch or mouse position
func move_knob(input_position: Vector2) -> void:
	# Convert the global input position (touch or mouse) to local (relative to the joystick)
	var local_input_pos = to_local(input_position)
	knob.position = stick_center + (local_input_pos - stick_center).limit_length(max_distance)

# Reset the joystick to its center position when released
func reset_joystick_position() -> void:
	knob.position = stick_center

# Get the direction the joystick is being pushed in (normalized vector)
func get_joystick_dir() -> Vector2:
	var dir = knob.position - stick_center
	if dir.length() > 0:
		return dir.normalized()
	return Vector2.ZERO
