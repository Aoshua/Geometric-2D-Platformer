extends CanvasLayer

var levels_path = "res://src/levels"
var total_levels = 19 # Actual value is 7
var rows = 3
var columns = 6
var levels_per_page = rows * columns
var current_page = 0
var total_pages = int(ceil(float(total_levels) / levels_per_page))

@onready var level_button_scene = preload("res://src/ui/level_button.tscn")

func _ready():
	current_page = int(Global.unlocked_levels / levels_per_page) # Determine initial page
	update_grid()


func _on_left_button_pressed():
	if current_page > 0:
		current_page -= 1
		update_grid()


func _on_right_button_pressed():
	if current_page < total_pages - 1:
		current_page += 1
		update_grid()


func update_grid():
	# Empty grid of old buttons
	for child in %GridContainer.get_children():
		%GridContainer.remove_child(child)
		child.queue_free()  # Free the memory
	
	var start_index = current_page * levels_per_page
	var end_index = min(start_index + levels_per_page, total_levels)
	
	for i in range(start_index, end_index):
		var level_button = level_button_scene.instantiate()

		# Determine if this level is unlocked
		if i < Global.unlocked_levels:
			level_button.set_level(i + 1, true)  # Unlocked
		else:
			level_button.set_level(i + 1, false)  # Locked

		%GridContainer.add_child(level_button)
	
	update_button_states()


func update_button_states():
	%LeftButton.visible = (current_page != 0)
	%RightButton.visible = (current_page != total_pages - 1)
