# item_card.gd
extends Control

signal buy_pressed(item_id)

@export var item_name: String = "Item Name" 
@export var item_price: int = 100
@export var item_icon: Texture2D
@export var item_id: String = ""
@export var button_text: String = "Buy"
@export var button_disabled: bool = false
@export var icon_size: int = 140

func _ready():
	update_display()
	$PanelContainer/MarginContainer/VBoxContainer/BuyButton.connect("pressed", _on_buy_button_pressed)

func update_display():
	$PanelContainer/MarginContainer/VBoxContainer/ItemName.text = item_name
	$PanelContainer/MarginContainer/VBoxContainer/PriceContainer/ItemPrice.text = str(item_price)
	$PanelContainer/MarginContainer/VBoxContainer/BuyButton.text = button_text
	$PanelContainer/MarginContainer/VBoxContainer/BuyButton.disabled = button_disabled	
	$PanelContainer/MarginContainer/VBoxContainer/CenterContainer/ItemSprite.custom_minimum_size  = Vector2(icon_size, icon_size)
	  
	if item_icon:
		$PanelContainer/MarginContainer/VBoxContainer/CenterContainer/ItemSprite.texture = item_icon

func _on_buy_button_pressed():
	emit_signal("buy_pressed", item_id)
