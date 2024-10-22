extends CanvasLayer


func _on_reset_button_pressed():
	Global.navigate_to_current_level()
	queue_free()


func _on_revive_button_pressed():
	pass # Replace with function body.


func _on_main_menu_button_pressed():
	get_tree().change_scene_to_file("res://src/ui/menus/main_menu.tscn")
