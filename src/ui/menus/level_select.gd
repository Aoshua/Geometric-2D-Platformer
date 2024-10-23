extends CanvasLayer

var levels_path = "res://src/levels"
var unlocked_levels = 0

@onready var level_button_scene = preload("res://src/ui/level_button.tscn")

func _ready():
	var dir = DirAccess.open(levels_path)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		var level_index = 0

		while file_name != "":
			if file_name.ends_with(".tscn") and file_name.begins_with("level_"):
				# Create a button for each level
				var level_button = level_button_scene.instantiate()

				# Determine if this level is unlocked
				if level_index <= unlocked_levels:
					level_button.set_level(level_index + 1, true)  # Unlocked
				else:
					level_button.set_level(level_index + 1, false)  # Locked

				%GridContainer.add_child(level_button)
				level_index += 1
			file_name = dir.get_next()

		dir.list_dir_end()
