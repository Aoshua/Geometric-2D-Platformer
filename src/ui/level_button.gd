extends Button

var level_number = 0
var level_path = ""
var is_unlocked = false

# Function to set up the button with level info
func set_level(number: int, unlocked: bool):
	level_number = number
	level_path = "res://src/levels/level_" + str(number) + ".tscn"
	is_unlocked = unlocked
	
	# Set button text
	text = str(level_number)
	
	# Disable or enable the button depending on whether it's unlocked
	if is_unlocked:
		disabled = false
	else:
		disabled = true
		# Optionally, change the appearance of the button to show it's locked
		add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))  # Grey out text

func _pressed():
	if is_unlocked:
		get_tree().change_scene_to_file(level_path)
