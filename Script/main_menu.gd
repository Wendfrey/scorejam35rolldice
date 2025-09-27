extends Control

@export var mainGame:PackedScene
@export var settings:PackedScene
@onready var tutocontainer: MarginContainer = $TutoContainer
@onready var setting: Panel = $settings





func _on_button_play_button_up() -> void:
	get_tree().change_scene_to_packed(mainGame)


func _on_button_tutorial_button_up() -> void:
	if tutocontainer.visible:
		tutocontainer.hide()
	else:
		tutocontainer.show()
		setting.hide()


func _on_button_setting_button_up() -> void:
	if setting.visible:
		setting.hide()
	else:
		tutocontainer.hide()
		setting.show()
