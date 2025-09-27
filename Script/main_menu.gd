extends Control

@export var mainGame:PackedScene
@onready var tutocontainer: MarginContainer = $TutoContainer



func _on_button_play_button_up() -> void:
	get_tree().change_scene_to_packed(mainGame)


func _on_button_tutorial_button_up() -> void:
	if tutocontainer.visible:
		tutocontainer.hide()
	else:
		tutocontainer.show()


func _on_button_setting_button_up() -> void:
	pass # Replace with function body.
