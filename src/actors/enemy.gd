extends Actor

func _ready() -> void:
	velocity.x = -speed.x


func _on_stop_detector_body_entered(body: Node2D) -> void:
	if body.global_position.y > $StompDetector.global_position.y:
		return 
	
	# Defer disabling the collision shape and freeing the node to avoid errors
	call_deferred("disable_collision_and_free")


func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	if is_on_wall():
		velocity.x *= -1.0
	move_and_slide()


func disable_collision_and_free() -> void:
	$CollisionShape2D.disabled = true
	queue_free()
