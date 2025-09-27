extends Node2D

const DICE = preload("uid://lcw65s7ygglt")

@onready var settings: Panel = $settings

@onready var dicehandler: Node2D = $dicehandler

@onready var aproval_bar: ProgressBar = $MarginContainer/CanvasLayer/Background/AprovalBar
@onready var red_bar: ProgressBar = $MarginContainer/CanvasLayer/MoodBarRed/RedBar
@onready var blue_bar: ProgressBar = $MarginContainer/CanvasLayer/MoodBarBlue/BlueBar
@onready var green_bar: ProgressBar = $MarginContainer/CanvasLayer/TextureRect/GreenBar
@onready var turn_label: Label = $MarginContainer/TurnLabel
@onready var chat_box: Sprite2D = $ChatBox
@onready var subtitles: RichTextLabel = $ChatBox/subtitles
@onready var hostCharHead: AnimationPlayer = $HostCharacter/HeadAnimation
@onready var hostCharHand: AnimationPlayer = $HostCharacter/HandAnimation
@onready var speech_sfx_1: AudioStreamPlayer = $speech_sfx1
@onready var total_spectators_label: RichTextLabel = $TotalSpectatorsLabel

var totalSpectators:int
var aproval:float
var currentTurn = 1

func _ready() -> void:
	
	update_aproval()
	
	if add_dice_and_connect():
		await get_tree().create_timer(0.2).timeout
	if add_dice_and_connect():
		await get_tree().create_timer(0.2).timeout
	if add_dice_and_connect():
		await get_tree().create_timer(0.2).timeout
	
	update_spritemood("RedMan", red_bar.value)
	update_spritemood("BlueMan", blue_bar.value)
	update_spritemood("GreenMan", green_bar.value)
	
	
func check_end_game():
	if red_bar.value <= 0 or blue_bar.value <= 0 or green_bar.value <= 0:
		print("game lost")
		
func update_aproval():
	aproval = (red_bar.value + blue_bar.value + green_bar.value)/3
	aproval_bar.value =100 - aproval
	
func build_comment(target: String, effect: bool) -> String:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	if effect:
		var positives = [
			"That was pure [tornado]ICONIC[/tornado], thank you [color={target}]{target}[/colo].",
			"Drama? Delivered. Shade? Perfect. [color={target}]{target}[/color] is giving [shake]TV gold[/shake].",
			"[color={target}]{target}[/color] ate. No crumbs left.",
			"This was peak [shake]tea-spilling[/shake], and [color={target}]{target}[/color] was the kettle."
		]
		return positives[rng.randi_range(0, positives.size() - 1)].format({"target": target})
	else:
		var negatives =[
			"Flop era unlocked, thank you [wave][color={target}]{target}[/color][/wave].",
			"[color={target}]{target}[/color], [wave]sweetie[/wave], you couldn’t win a debate in a kindergarten.",
			"This wasn’t iconic, [color={target}]{target}[/color], it was more like ironic.",
			"[color={target}]{target}[/color], your 15 minutes are already over.",
			"I'll pretend I didn't hear that,[color={target}]{target}[/color].",
			"[color={target}]{target}[/colo], you’re not a clown you're the entire circus."
			]
		return negatives[rng.randi_range(0, negatives.size() - 1)].format({"target": target})
		
func show_comment(raw_text: String, speed := 0.03) -> void:
	chat_box.show()
	subtitles.bbcode_enabled = true
	subtitles.bbcode_text = raw_text
	subtitles.visible_ratio = 0.0
	hostCharHand.play("Hand" + str(randi_range(1,9)))

	while subtitles.visible_ratio < 1:
		if Input.is_action_just_pressed("ui_accept"):
			subtitles.visible_ratio = 1.1
			break
		if subtitles.visible_ratio < 1 and not speech_sfx_1.playing:
			speech_sfx_1.play()
			hostCharHead.play("Talk" + str(randi_range(1,6)))

		
		subtitles.visible_ratio += speed * get_process_delta_time()
		subtitles.visible_ratio = min(subtitles.visible_ratio, 1.0)
		await get_tree().process_frame
	await get_tree().create_timer(1.5).timeout
	subtitles.text = ""
	chat_box.hide()
	hostCharHead.play("Idle")

func _dice_rolled(face:DiceFaceDataResource, dice_spectator:int):
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
			add_dice_and_connect()
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
	
	totalSpectators += dice_spectator
	total_spectators_label.text = "{sp}k".format({sp = totalSpectators})
	dicehandler.recalculate_dice_spectators()
	if target_comment != "dice":
		comment = build_comment(target_comment,target_effect)
	else:
		comment = "There is an uncomfortable silence in the room"
	show_comment(comment,0.9)
	check_end_game()
	
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

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			if settings.visible:
				settings.hide()
			else:
				settings.show()


func _on_pass_turn_button_pressed() -> void:
	currentTurn += 1
	turn_label.text = "TURN {turn} / 10".format({turn = currentTurn})
	if add_dice_and_connect():
		await get_tree().create_timer(0.2).timeout
	if add_dice_and_connect():
		await get_tree().create_timer(0.2).timeout
	if add_dice_and_connect():
		await get_tree().create_timer(0.2).timeout

func add_dice_and_connect() -> bool:
	var dice = dicehandler.spawn_dice(red_bar.get.bind("value"), green_bar.get.bind("value"), blue_bar.get.bind("value"))
	if dice:
		dice.connect("dice_rolled",_dice_rolled)
		return true
	return false
