extends CanvasLayer

signal resume_game


func _on_main_menu_button_pressed():
	get_tree().change_scene_to_file("res://src/ui/menus/main_menu.tscn")
	queue_free()
