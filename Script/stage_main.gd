extends Node2D

const DICE = preload("uid://lcw65s7ygglt")

@onready var dicehandler: Node2D = $dicehandler

var redStress:float
var greenStress:float
var blueStress:float
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
	var comment = build_comment("green", true)
	await show_comment(comment, 0.99)
	dicehandler.spawn_dice()
	dicehandler.spawn_dice()
	dicehandler.spawn_dice()
func end_game():
	if redStress > 100 or greenStress > 100 or blueStress > 100:
		pass
func update_aproval():
	aproval = (redStress + greenStress + blueStress)/3

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
