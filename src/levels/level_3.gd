extends Node2D

@onready var player = $Player 
@onready var camera = player.get_node("Camera2D")

func _ready():
	set_camera_limits()

func set_camera_limits():
	camera.limit_left = -167
	camera.limit_right = 7748
