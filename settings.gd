extends Panel
@export var is_mainMenu:bool = false
@onready var button: Button = $MarginContainer/VBoxContainer/HBoxContainer/Button
@onready var button_2: Button = $MarginContainer/VBoxContainer/HBoxContainer/Button2
@onready var background: NinePatchRect = $NinePatchRect
@onready var control: Control = $Control

func _ready() -> void:
	if is_mainMenu:
		control.hide()
		button.hide()
		background.self_modulate = Color("8798be")
func _on_button_button_up() -> void:
	get_tree().change_scene_to_file("res://MainMenu.tscn")
	
func _on_button_2_button_up() -> void:
	$".".hide()
	
	
