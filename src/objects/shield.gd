extends Sprite2D

@export var flicker_intensity: float = 0.1  # Controls the randomness of the flicker
@export var flicker_speed: float = 8.0  # How fast the flicker changes

var base_scale: Vector2
var base_modulate: Color

func _ready():
	# Store the initial scale and color
	base_scale = scale
	base_modulate = modulate

func _process(delta):
	# Create a random flicker effect
	var noise_x = randf_range(1.0 - flicker_intensity, 1.0 + flicker_intensity)
	var noise_y = randf_range(1.0 - flicker_intensity, 1.0 + flicker_intensity)
	
	# Animate scale with noise
	scale = base_scale * Vector2(noise_x, noise_y)
	
	# Animate color/opacity with noise
	var color_noise = randf_range(0.8, 1.0)
	modulate.a = base_modulate.a * color_noise
	
	# Optional: Add a subtle color variation for electric feel
	var r_noise = randf_range(0.9, 1.1)
	var b_noise = randf_range(0.9, 1.1)
	modulate.r = base_modulate.r * r_noise
	modulate.b = base_modulate.b * b_noise
