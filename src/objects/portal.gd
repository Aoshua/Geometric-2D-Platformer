@tool
extends Area2D

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@export var next_scene: PackedScene

func _on_body_entered(body: Node2D) -> void:
	teleport() # Doesn't currently distinguish between player and enemy

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = PackedStringArray()
	if not next_scene:
		warnings.append("The next scene property can't be empty")
	return warnings

func teleport() -> void:
	anim_player.play("fade_in")
	await anim_player.animation_finished
	Global.unlock_level()
	get_tree().change_scene_to_packed(next_scene)
