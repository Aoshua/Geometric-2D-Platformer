extends CanvasLayer

func _ready():
	%CurrentCoinsLabel.text = Formatters.format_number_with_commas(Global.coins)


func _on_touch_screen_button_pressed():
	get_tree().change_scene_to_file("res://src/ui/menus/main_menu.tscn")
	queue_free()
