extends CanvasLayer

signal resume_game


func _on_resume_button_pressed():
	emit_signal("resume_game")
	queue_free()


func _on_restart_button_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()
	queue_free()


func _on_main_menu_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://src/ui/menus/main_menu.tscn")
	queue_free()
