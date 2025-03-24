extends Actor

var time = 0
var jiggle_speed = 7.0
var jiggle_amount = 0.1
var sprite_height = 0


func _ready() -> void:
	velocity.x = -speed.x
	sprite_height = %EnemySprite.texture.get_height()


func _on_stop_detector_body_entered(body: Node2D) -> void:
	if body.global_position.y > $StompDetector.global_position.y:
		return 
	
	# Defer disabling the collision shape and freeing the node to avoid errors
	call_deferred("disable_collision_and_free")


func _physics_process(delta: float) -> void:
	# Jiggle Animation:
	time += delta
	var x_scale = 1.0 + sin(time * jiggle_speed) * jiggle_amount
	var y_scale = 1.0 + cos(time * jiggle_speed) * jiggle_amount
	%EnemySprite.scale = Vector2(x_scale, y_scale)
	# Directly offset position based on how much the y_scale differs from 1.0
	var offset_factor = sprite_height / 0.75  # Try different values here (0.75)
	var y_offset = ((1.0 - y_scale) * offset_factor) - 50 # And here (50)
	%EnemySprite.position.y = y_offset
	
	# Movement:
	velocity.y += gravity * delta
	if is_on_wall():
		velocity.x *= -1.0
		# Flip the sprite when changing direction
		if velocity.x > 0:
			%EnemySprite.flip_h = false
		else:
			%EnemySprite.flip_h = true
		
	move_and_slide()


func disable_collision_and_free() -> void:
	$CollisionShape2D.disabled = true
	queue_free()


func _on_screen_enabler_screen_entered():
	$ScreenEnabler.queue_free()
