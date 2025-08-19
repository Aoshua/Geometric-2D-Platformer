extends CanvasLayer

var levels_path = "res://src/levels"
var total_levels = 50 # Actual value is 7
var rows = 3

@onready var level_button_scene = preload("res://src/ui/level_button.tscn")
@onready var scroll_container: ScrollContainer
@onready var grid_container: GridContainer

func _ready():
	setup_scroll_container()
	populate_grid()
	# Scroll to show the current unlocked level after a frame
	call_deferred("scroll_to_current_level")

func setup_scroll_container():
	scroll_container = %ScrollContainer
	grid_container = %GridContainer
	grid_container.offset_bottom = 50.0
	
	# Configure ScrollContainer
	scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll_container.follow_focus = true
	
	# Configure GridContainer for horizontal layout
	var columns_needed = int(ceil(float(total_levels) / rows))
	grid_container.columns = columns_needed

func populate_grid():
	# Clear existing buttons
	for child in grid_container.get_children():
		grid_container.remove_child(child)
		child.queue_free()
	
	# Create buttons in column-major order (down first, then right)
	for col in range(int(ceil(float(total_levels) / rows))):
		for row in range(rows):
			var level_index = col * rows + row
			
			if level_index >= total_levels:
				# Add empty control to maintain grid structure
				var empty_control = Control.new()
				empty_control.custom_minimum_size = Vector2(80, 80)  # Match button size
				grid_container.add_child(empty_control)
				continue
			
			var level_button = level_button_scene.instantiate()
			
			# Determine if this level is unlocked
			if level_index < Global.unlocked_levels:
				level_button.set_level(level_index + 1, true)  # Unlocked
			else:
				level_button.set_level(level_index + 1, false)  # Locked
			
			grid_container.add_child(level_button)

func scroll_to_current_level():
	if Global.unlocked_levels > 0:
		var current_level = Global.unlocked_levels - 1
		var column = int(current_level / rows)
		
		# Calculate the approximate scroll position
		# This assumes uniform button widths - adjust as needed
		var button_width = 80  # Adjust to match your button size
		var spacing = grid_container.get_theme_constant("h_separation")
		var target_scroll = column * (button_width + spacing)
		
		# Ensure we don't scroll past the end
		var max_scroll = scroll_container.get_h_scroll_bar().max_value
		target_scroll = min(target_scroll, max_scroll)
		
		scroll_container.scroll_horizontal = target_scroll
