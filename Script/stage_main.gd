extends Node2D

const GAME_OVER_SCENE = preload("uid://bcklhse4ojfjd")

@export var mousePan:Array[Node2D];
@export var mousePanSpeedX:Array[float];
@export var mousePanSpeedY:Array[float];


@onready var settings: Panel = $settings
@onready var dicehandler: Node2D = $dicehandler
@onready var aproval_bar: ProgressBar = $MarginContainer/CanvasLayer/Background/AprovalBar
@onready var red_bar: ProgressBar = $MarginContainer/CanvasLayer/MoodBars/Red/MoodBarRed/RedBar
@onready var blue_bar: ProgressBar = $MarginContainer/CanvasLayer/MoodBars/Blue/MoodBarBlue/BlueBar
@onready var green_bar: ProgressBar = $MarginContainer/CanvasLayer/MoodBars/Green/MoodBarGreen/GreenBar
@onready var turn_label: Label = $MarginContainer/TurnLabel
@onready var chat_box: Sprite2D = $ChatBox
@onready var subtitles: RichTextLabel = $ChatBox/subtitles
@onready var hostCharHead: AnimationPlayer = $HostCharacter/HeadAnimation
@onready var hostCharHand: AnimationPlayer = $HostCharacter/HandAnimation
@onready var speech_sfx_1: AudioStreamPlayer = $speech_sfx1
@onready var total_spectators_label: RichTextLabel = $MarginContainer/CanvasLayer/Background/TotalSpectatorsLabel
@onready var pass_turn_button: Button = $PlayZone/HBoxContainer/PassTurn/PassTurnButton
@onready var refresh_zone_shape: CollisionShape2D = $PlayZone/HBoxContainer/RefreshPanel/RefreshZone/CollisionShape2D
@onready var refresh_zone_panel: Panel = $PlayZone/HBoxContainer/RefreshPanel
@onready var gameOverPlayer:AnimationPlayer = $GameOverPlayer

const maxTurns:int = 15;

var totalSpectators:int
var aproval:float
var currentTurn = 1
var mousePanX:Array[float] = []
var mousePanY:Array[float] = []


func _ready() -> void:
	
	update_aproval()
	generate_three_dice()
	
	update_spritemood("RedMan", red_bar.value)
	update_spritemood("BlueMan", blue_bar.value)
	update_spritemood("GreenMan", green_bar.value)
	
	savePanOrigins()
	refresh_turn_text()
	gameOverPlayer.play("RESET")
	
func _process(_delta):
	backgroundPan()
	
func check_end_game() -> bool:
	if red_bar.value <= 0:
		do_end_game("RED")
		return true
	elif blue_bar.value <= 0:
		do_end_game("BLUE")
		return true
	elif green_bar.value <= 0:
		do_end_game("GREEN")
		return true
	return false
		
func do_end_game(scenario:String):
	pass_turn_button.disabled = true
	gameOverPlayer.play(scenario)
	await get_tree().create_timer(1.5).timeout
	Globals.final_score = totalSpectators
	Globals.submit_score = true
	get_tree().change_scene_to_packed(GAME_OVER_SCENE)
		
func update_aproval():
	aproval = (red_bar.value + blue_bar.value + green_bar.value)/3
	aproval_bar.value =100 - aproval
	
func build_comment(target: String, effect: bool) -> String:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	if effect:
		var positives = [
			"That was pure [tornado]ICONIC[/tornado], thank you [color={target}]{target}[/color].",
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
			"[color={target}]{target}[/color], you’re not a clown you're the entire circus."
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
		if not is_inside_tree():
			return
		await get_tree().process_frame
	await get_tree().create_timer(4).timeout
	subtitles.text = ""
	chat_box.hide()
	hostCharHead.play("Idle")

func _dice_rolled(face:DiceFaceDataResource, dice_spectator:int):
	pass_turn_button.disabled = false
	
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
			add_dice_and_connect(true)
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
	if !check_end_game():
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

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			if settings.visible:
				settings.hide()
			else:
				settings.show()

func _on_pass_turn_button_pressed() -> void:
	refresh_zone_shape.disabled = false
	refresh_zone_panel.modulate = Color.WHITE
	currentTurn += 1
	if currentTurn > maxTurns:
		do_end_game("END")
	else:
		pass_turn_button.disabled = true
		refresh_turn_text()
		generate_three_dice()
		await get_tree().create_timer(0.8).timeout
		pass_turn_button.disabled = false

func refresh_turn_text() -> void:
	turn_label.text = "TURN {turn} / {max}".format({turn = currentTurn, max = maxTurns})
	

func add_dice_and_connect(is_dice_destroyed:bool = false) -> bool:
	var dice = dicehandler.spawn_dice(red_bar.get.bind("value"), green_bar.get.bind("value"), blue_bar.get.bind("value"), is_dice_destroyed)
	if dice:
		dice.connect("dice_rolled",_dice_rolled)
		dice.connect("new_dice", _on_dice_new_dice)
		dice.connect("dice_roll_start", _on_dice_dice_roll)
		return true
	return false
	
func _on_dice_dice_roll():
	pass_turn_button.disabled = true

func _on_dice_new_dice():
	refresh_zone_shape.disabled = true
	refresh_zone_panel.modulate = Color.RED
	add_dice_and_connect(true)

func generate_three_dice():
	if add_dice_and_connect():
		await get_tree().create_timer(0.2).timeout
	if add_dice_and_connect():
		await get_tree().create_timer(0.2).timeout
	add_dice_and_connect()

func savePanOrigins() -> void:
	var i = 0;
	mousePanX.resize(mousePan.size())
	mousePanY.resize(mousePan.size())
	for item in mousePan:
		mousePanX[i] = item.position.x;
		mousePanY[i] = item.position.y;
		i+=1;

func backgroundPan() -> void:
	if mousePanX.size() >0:
		var moved = Vector2(
			zeroToOne(get_viewport().get_mouse_position().x/get_viewport().get_visible_rect().size.x),
			zeroToOne(get_viewport().get_mouse_position().y/get_viewport().get_visible_rect().size.y))
		var i = 0;
		for item in mousePan:
			item.position.x = mousePanX[i]-(moved.x*mousePanSpeedX[i]);
			item.position.y = mousePanY[i]-(moved.y*mousePanSpeedY[i]);
			i+=1;
		
	
func zeroToOne(num:float):
	if num < 0:
		return 0
	if num > 1:
		return 1
	return num
