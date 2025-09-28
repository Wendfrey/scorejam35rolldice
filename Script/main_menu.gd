extends Control

@onready var tutocontainer: NinePatchRect = $NinePatchRect
@export var mainGame:PackedScene
@export var settings:PackedScene
@onready var setting: Panel = $settings
@onready var credits_container: PanelContainer = $CreditsContainer
@onready var credits_label: RichTextLabel = $CreditsContainer/MarginContainer/VBoxContainer/CreditsLabel

func _ready() -> void:
	var creditsTxt:FileAccess = FileAccess.open("res://credits.txt", FileAccess.READ)
	var test = creditsTxt.get_as_text()
	credits_label.text = creditsTxt.get_as_text()

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


func _on_button_credits_pressed() -> void:
	if credits_container.visible:
		credits_container.hide()
	else:
		credits_container.show()
		tutocontainer.hide()
		setting.hide()
		
func _on_close_credits_button_pressed() -> void:
	credits_container.hide()


func _on_credits_label_meta_clicked(meta: Variant) -> void:
	print(meta)
	DisplayServer.clipboard_set(meta)


func _on_button_scoreboards_pressed() -> void:
	Globals.submit_score = false
	get_tree().change_scene_to_file("res://game_over.tscn")
