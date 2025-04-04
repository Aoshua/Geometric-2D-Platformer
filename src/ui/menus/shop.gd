extends CanvasLayer

#func _ready():
	#set_scroll_container_dimensions()


func set_scroll_container_dimensions():
	# Get references to containers
	var scroll_container = $TabContainer/Items/ScrollContainer
	var hbox = $TabContainer/Items/ScrollContainer/ItemsGrid

	# Make ScrollContainer fill the tab area
	scroll_container.anchor_left = 0
	scroll_container.anchor_top = 0
	scroll_container.anchor_right = 1
	scroll_container.anchor_bottom = 1
	scroll_container.offset_left = 0
	scroll_container.offset_top = 0
	scroll_container.offset_right = 0
	scroll_container.offset_bottom = 0

	# Important: Enable size flags to expand
	scroll_container.size_flags_horizontal = Control.SIZE_FILL
	scroll_container.size_flags_vertical = Control.SIZE_FILL

	# Set up the HBoxContainer with margins
	hbox.anchor_left = 0
	hbox.anchor_top = 0
	hbox.anchor_right = 1
	hbox.anchor_bottom = 1

	# Apply the 15px offset around all sides
	hbox.offset_left = 15
	hbox.offset_top = 15
	hbox.offset_right = -15
	hbox.offset_bottom = -15

	# Make HBoxContainer expand to fill the ScrollContainer
	hbox.size_flags_horizontal = Control.SIZE_FILL
	hbox.size_flags_vertical = Control.SIZE_FILL
