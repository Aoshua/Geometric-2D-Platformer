extends CanvasLayer

func _ready():
	var header_height = $Header.size.y + 40 # 40 is arbitrary offset
	var screen_size = get_viewport().get_visible_rect().size
	
	# Set TabContainer position and size
	$TabContainer.anchor_left = 0
	$TabContainer.anchor_top = 0
	$TabContainer.anchor_right = 1
	$TabContainer.anchor_bottom = 1
	
	$TabContainer.offset_left = 10
	$TabContainer.offset_top = header_height
	$TabContainer.offset_right = -10
	$TabContainer.offset_bottom = -10
