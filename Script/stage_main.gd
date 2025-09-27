extends Node2D

const DICE = preload("uid://lcw65s7ygglt")

@onready var dicehandler: Node2D = $dicehandler

@onready var aproval_bar: ProgressBar = $MarginContainer/CanvasLayer/Background/AprovalBar
@onready var red_bar: ProgressBar = $MarginContainer/CanvasLayer/Background/RedBar
@onready var blue_bar: ProgressBar = $MarginContainer/CanvasLayer/Background/BlueBar
@onready var green_bar: ProgressBar = $MarginContainer/CanvasLayer/Background/GreenBar

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
	dicehandler.spawn_dice().connect("dice_rolled",_dice_rolled)
	dicehandler.spawn_dice().connect("dice_rolled",_dice_rolled)
	
	
func end_game():
	if red_bar.value > 100 or blue_bar.value > 100 or green_bar.value > 100:
		pass
func update_aproval():
	aproval = (red_bar.value + blue_bar.value + green_bar.value)/3
	aproval_bar.value = aproval
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

func _dice_rolled(face:DiceFaceDataResource):
	
	var effect = 10
	
	
	
	
	print(DiceFaceDataResource.Effect.keys()[face.effect])
	print(DiceFaceDataResource.FaceColor.keys()[face.faceColor])
	
	match(face.effect):
		DiceFaceDataResource.Effect.POSITIVE:
			pass
		DiceFaceDataResource.Effect.NEGATIVE:
			effect *= -1
		DiceFaceDataResource.Effect.ADD_DICE:
			pass

	match(face.faceColor):
		DiceFaceDataResource.FaceColor.RED:
			red_bar.value += effect
		DiceFaceDataResource.FaceColor.BLUE:
			blue_bar.value += effect
		DiceFaceDataResource.FaceColor.GREEN:
			green_bar.value += effect
		DiceFaceDataResource.FaceColor.ALL:
			red_bar.value += effect
			blue_bar.value += effect
			green_bar.value += effect

	
