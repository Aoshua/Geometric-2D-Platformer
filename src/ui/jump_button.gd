extends TouchScreenButton

@onready var transparency_level = 0.5

func _ready():
	modulate = Color(1, 1, 1, transparency_level)
