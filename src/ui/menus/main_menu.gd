extends CanvasLayer

func _ready():
	Global.load_game()
	var anim_player = $ContentContainer/AnimationSpace/PlayerSprite/AnimationPlayer


func _on_continue_button_pressed():
	Global.navigate_to_current_level()


func _on_select_level_button_pressed():
	get_tree().change_scene_to_file("res://src/ui/menus/level_select.tscn")


func _on_shop_button_pressed():
	get_tree().change_scene_to_file("res://src/ui/menus/shop.tscn")


func _unhandled_input(event):
	if event is InputEventScreenTouch:
		print("Screen touched at position: ", event.position)


func _on_button_pressed():
	Global.reset_progress()
