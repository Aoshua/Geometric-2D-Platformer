extends CanvasLayer

var levels_path = "res://src/levels"
var total_levels = 7

@onready var level_button_scene = preload("res://src/ui/level_button.tscn")

func _ready():
	for i in range(total_levels):
		var level_button = level_button_scene.instantiate()

		# Determine if this level is unlocked
		if i < Global.unlocked_levels:
			level_button.set_level(i + 1, true)  # Unlocked
		else:
			level_button.set_level(i + 1, false)  # Locked

		%GridContainer.add_child(level_button)
