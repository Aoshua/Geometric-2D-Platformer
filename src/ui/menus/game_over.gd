extends CanvasLayer


func _on_reset_button_pressed():
	get_tree().reload_current_scene()
	queue_free()


func _on_revive_button_pressed():
	pass # Replace with function body.


func _on_main_menu_button_pressed():
	get_tree().change_scene_to_file("res://src/ui/menus/main_menu.tscn")
