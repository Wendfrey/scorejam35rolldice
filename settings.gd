extends Panel
@export var is_mainMenu:bool = false
@onready var button: Button = $MarginContainer/VBoxContainer/Button


func _ready() -> void:
	if is_mainMenu:
		button.hide()
func _on_button_button_up() -> void:
	get_tree().change_scene_to_file("res://MainMenu.tscn")
