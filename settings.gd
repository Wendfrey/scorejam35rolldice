extends Panel
@export var is_mainMenu:bool = false
@onready var quitbutton: Button = $MarginContainer/VBoxContainer/HBoxContainer/Button
@onready var resumebutton: Button = $MarginContainer/VBoxContainer/HBoxContainer/Button2


func _ready() -> void:
	if is_mainMenu:
		quitbutton.hide()
func _on_button_button_up() -> void:
	get_tree().change_scene_to_file("res://MainMenu.tscn")


func _on_button_2_button_up() -> void:
	$".".hide()
