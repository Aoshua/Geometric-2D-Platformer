extends CanvasLayer

func _ready():
	Global.load_game()


func _on_continue_button_pressed():
	Global.navigate_to_current_level()


func _on_select_level_button_pressed():
	pass # Replace with function body.


func _unhandled_input(event):
	if event is InputEventScreenTouch:
		print("Screen touched at position: ", event.position)


func _on_continue_button_mouse_entered():
	print("Mouse entered")


func _on_continue_button_mouse_exited():
	print("Mouse exited")
