extends CanvasLayer

@export var label: String = "Alert message here" 


func _ready(): 
	$Control/Card/VBoxContainer/Label.text = label


func _on_button_pressed():
	queue_free()
