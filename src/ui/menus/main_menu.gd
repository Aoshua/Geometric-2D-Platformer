extends CanvasLayer

func _ready():
	Global.load_game()


func _on_continue_button_pressed():
	print("Continue Button Pressed")
	var level_path = "res://src/levels/level_" + str(Global.unlocked_levels) + ".tscn" 
	get_tree().change_scene_to_file(level_path)


func _on_select_level_button_pressed():
	pass # Replace with function body.

func _unhandled_input(event):
	if event is InputEventScreenTouch:
		print("Screen touched at position: ", event.position)
