extends Node2D

const DICE = preload("uid://lcw65s7ygglt")

@onready var dicehandler: Node2D = $dicehandler

@onready var aproval_bar: ProgressBar = $MarginContainer/CanvasLayer/Background/AprovalBar
@onready var red_bar: ProgressBar = $MarginContainer/CanvasLayer/MoodBarRed/RedBar
@onready var blue_bar: ProgressBar = $MarginContainer/CanvasLayer/MoodBarBlue/BlueBar
@onready var green_bar: ProgressBar = $MarginContainer/CanvasLayer/TextureRect/GreenBar

var spectatorCount:int
var aproval:float

var handTextures:Array =[
	"res://Assets/Texture/HostCharacter/HandA.png",
	"res://Assets/Texture/HostCharacter/HandB.png",
	"res://Assets/Texture/HostCharacter/HandC.png",
	"res://Assets/Texture/HostCharacter/HandD.png",
	"res://Assets/Texture/HostCharacter/HandE.png",
	"res://Assets/Texture/HostCharacter/HandF.png",
	"res://Assets/Texture/HostCharacter/HandG.png"
	
]



@onready var subtitles: RichTextLabel = $MarginContainer2/subtitles
@onready var hand: Sprite2D = $HostHead/Hand
@onready var speech_sfx_1: AudioStreamPlayer = $speech_sfx1

func _ready() -> void:
	
	update_aproval()
	
	dicehandler.spawn_dice().connect("dice_rolled",_dice_rolled)
	await get_tree().create_timer(0.2).timeout
	dicehandler.spawn_dice().connect("dice_rolled",_dice_rolled)
	await get_tree().create_timer(0.2).timeout
	dicehandler.spawn_dice().connect("dice_rolled",_dice_rolled)
	
	update_spritemood("RedMan", red_bar.value)
	update_spritemood("BlueMan", blue_bar.value)
	update_spritemood("GreenMan", green_bar.value)
	
	
func end_game():
	if red_bar.value > 100 or blue_bar.value > 100 or green_bar.value > 100:
		pass
		
func update_aproval():
	aproval = (red_bar.value + blue_bar.value + green_bar.value)/3
	aproval_bar.value =100 - aproval
	
func build_comment(target: String, effect: bool) -> String:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	if effect:
		var positives = [
			"{target} is [rainbow]shining[/rainbow] today, dont you think?",
			"{target} positive2"
		]
		return positives[rng.randi_range(0, positives.size() - 1)].format({"target": target})
	else:
		var negatives =[
			"{target} negative1",
			"{target} negative2"
			]
		return negatives[rng.randi_range(0, negatives.size() - 1)].format({"target": target})
		
func show_comment(raw_text: String, speed := 0.03) -> void:
	subtitles.bbcode_enabled = true
	subtitles.bbcode_text = raw_text
	subtitles.visible_ratio = 0.0

	while subtitles.visible_ratio < 1:
		if Input.is_action_just_pressed("ui_accept"):
			subtitles.visible_ratio = 1.1
			break
		if subtitles.visible_ratio < 1 and not speech_sfx_1.playing:
			speech_sfx_1.play()
			hand.texture = load(handTextures[randi_range(0,handTextures.size()-1)])

		
		subtitles.visible_ratio += speed * get_process_delta_time()
		subtitles.visible_ratio = min(subtitles.visible_ratio, 1.0)
		await get_tree().process_frame
	await get_tree().create_timer(1).timeout
	subtitles.text = ""

func _dice_rolled(face:DiceFaceDataResource):
	var effect = 10
	var target_comment = ""
	var target_effect:bool
	var comment = ""
	print(DiceFaceDataResource.Effect.keys()[face.effect])
	print(DiceFaceDataResource.FaceColor.keys()[face.faceColor])
	
	match(face.effect):
		DiceFaceDataResource.Effect.POSITIVE:
			pass
			target_effect = true
		DiceFaceDataResource.Effect.NEGATIVE:
			effect *= -1
			target_effect = false
		DiceFaceDataResource.Effect.ADD_DICE:
			dicehandler.spawn_dice().connect("dice_rolled",_dice_rolled)
			target_comment = "dice"

	match(face.faceColor):
		DiceFaceDataResource.FaceColor.RED:
			red_bar.value += effect
			target_comment = "Red"
			update_spritemood("RedMan", red_bar.value)
		DiceFaceDataResource.FaceColor.BLUE:
			blue_bar.value += effect
			target_comment = "Blue"
			update_spritemood("BlueMan", blue_bar.value)
		DiceFaceDataResource.FaceColor.GREEN:
			green_bar.value += effect
			target_comment = "Green"
			update_spritemood("GreenMan", green_bar.value)
		DiceFaceDataResource.FaceColor.ALL:
			red_bar.value += effect
			blue_bar.value += effect
			green_bar.value += effect
			target_comment = "Everyone"
			update_spritemood("RedMan", red_bar.value)
			update_spritemood("BlueMan", blue_bar.value)
			update_spritemood("GreenMan", green_bar.value)
	
	update_aproval()
	if target_comment != "dice":
		comment = build_comment(target_comment,target_effect)
	else:
		comment = "There is an uncomfortable silence in the room"
	show_comment(comment,0.9)
	
func update_spritemood(target_man : String, value : float) -> void:
	var man : AnimatedSprite2D = get_node(str("MarginContainer/CanvasLayer/Background/", target_man))
	if value >= 50:
		man.animation = "default"
	elif value > 30:
		man.animation = "tense"
	elif value > 10:
		man.animation = "bother"
	else:
		man.animation = "angry"
