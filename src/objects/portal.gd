@tool
extends Area2D

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@export var next_scene: PackedScene
@export var current_level: int


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("bank_coins"):
		body.bank_coins()
	
	SoundManager.play_sound("teleport")
	teleport() # Doesn't currently distinguish between player and enemy


func _get_configuration_warnings() -> PackedStringArray:
	var warnings = PackedStringArray()
	if not next_scene:
		warnings.append("The Next Scene property can't be empty")
	if not current_level:
		warnings.append("The Current Level property can't be empty")
	return warnings


func teleport() -> void:
	anim_player.play("fade_in")
	await anim_player.animation_finished
	Global.unlock_level(current_level)
	get_tree().change_scene_to_packed(next_scene)
