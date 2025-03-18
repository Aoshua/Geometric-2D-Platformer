extends Area2D

@onready var anim_player: AnimationPlayer = get_node("AnimationPlayer")


func _on_body_entered(body):
	anim_player.play("fade_out") # queue_free after this?
	if body.has_method("collect_coin"):
		body.collect_coin()
