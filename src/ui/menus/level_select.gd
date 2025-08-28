# NOTE:
# If I ever decide to add many more levels: change rows to 3

extends CanvasLayer

var levels_path = "res://src/levels"
var rows = 1

@onready var level_button_scene = preload("res://src/ui/level_button.tscn")
@onready var scroll_container: ScrollContainer

func _ready():
	setup_scroll_container()
	populate_grid()
	# Scroll to show the current unlocked level after a frame
	call_deferred("scroll_to_current_level")

func setup_scroll_container():
	scroll_container = %ScrollContainer
	
	# Configure ScrollContainer
	scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll_container.follow_focus = true
	
	# Disable scrolling when just 1 row
	if (rows == 1):
		# Center the row of columns and let the row fill the width
		%MarginContainer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		%HBoxContainer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		%HBoxContainer.alignment = BoxContainer.ALIGNMENT_CENTER
		scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED


func populate_grid():
	# Clear existing buttons
	var children = %HBoxContainer.get_children()
	for child in children:
		%HBoxContainer.remove_child(child)
		child.queue_free()
		
	var total_levels = get_total_levels()
	print("total_levels: ", str(total_levels))
	var columns_needed = int(ceil(float(total_levels) / rows))
	
	for col in range(columns_needed):
		var vBox = VBoxContainer.new()
		%HBoxContainer.add_child(vBox)
		
		for row in range(rows):
			var level_index = col * rows + row
			
			if level_index >= total_levels:
				# Add empty control to maintain grid structure
				var empty_control = Control.new()
				empty_control.custom_minimum_size = Vector2(80, 80)  # Match button size
				vBox.add_child(empty_control)
				continue
			
			var level_button = level_button_scene.instantiate()
			
			# Determine if this level is unlocked
			if level_index < Global.unlocked_levels:
				level_button.set_level(level_index + 1, true)  # Unlocked
			else:
				level_button.set_level(level_index + 1, false)  # Locked
				
			vBox.add_child(level_button)


func scroll_to_current_level():
	if scroll_container.horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED:
		return
		
	if Global.unlocked_levels > 0:
			var current_level = Global.unlocked_levels
			var column = int(current_level / rows)
			
			# Get the VBoxContainer for the current level's column
			var hbox = %HBoxContainer
			var vbox_containers = hbox.get_children()
			
			if column < vbox_containers.size():
				var target_vbox = vbox_containers[column]
				
				# Calculate the horizontal position to scroll to
				var target_position = target_vbox.global_position.x - hbox.global_position.x
				
				# Get the scroll container's viewport width
				var viewport_width = scroll_container.get_viewport_rect().size.x
				var vbox_width = target_vbox.size.x
				
				# Center the target column in the viewport
				var scroll_position = target_position - (viewport_width / 2) + (vbox_width / 2)
				
				# Clamp to valid scroll range
				scroll_position = max(0, scroll_position)
				scroll_position = min(scroll_position, scroll_container.get_h_scroll_bar().max_value)
				
				# Set the scroll position
				scroll_container.scroll_horizontal = int(scroll_position)


func get_total_levels() -> int:
	var dir := DirAccess.open("res://src/levels")
	if dir == null:
		push_error("Could not open levels directory.")
		return 0
	
	var regex := RegEx.new()
	regex.compile("^level_(\\d+)\\.tscn$")
	
	var max_level := 0
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tscn"):
			var result = regex.search(file_name)
			if result:
				var level_num = int(result.get_string(1))
				max_level = max(max_level, level_num)
		file_name = dir.get_next()
	dir.list_dir_end()
	
	return max_level

