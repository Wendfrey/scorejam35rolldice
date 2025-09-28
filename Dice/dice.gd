extends Control

static var is_menu_displayed:bool = false

const BASE_FACE_VALUE:float = 4
const BASE_STR_SPECTATOR_TEXT = "[rainbow]{points}K[/rainbow]"

signal dice_rolled(face:DiceFaceDataResource, spectator_amount)

@export var all_possible_faces: Array[DiceFaceDataResource]

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var dice_menu: Control = $DiceMenu
@onready var label_face_number: Label = $LabelFaceNumber
@onready var spectator_label: RichTextLabel = $DiceMenu/SpectatorLabel
@onready var face_1: TextureRect = $Face1

@onready var texture_array: Array = [
	$Face1,
	$DiceMenu/Face2,
	$DiceMenu/Face3,
	$DiceMenu/Face4,
	$DiceMenu/Face5,
	$DiceMenu/Face6
]

var options : Array[DiceFaceDataResource]
var interval : float = 0.1
var timer : int = 10
var previewInterval : float = 1
var active : bool = true
var preview : bool = false
var isFinished : bool = false
var rng: RandomNumberGenerator
var ticks: int  = timer
var num_choice: int = 0
var choice: DiceFaceDataResource
var previous_roll = -1

var current_anim:Tween = null
var current_pos
var is_anim_move_playing: bool = false

var grabbed: bool = false
var current_zone: Area2D = null

var get_red_bar_value:Callable = Callable()
var get_green_bar_value:Callable = Callable()
var get_blue_bar_value:Callable = Callable()
var get_tension_bar_value:Callable = Callable()

var spectactor_score:int = 0

func _ready() -> void:
	rng = RandomNumberGenerator.new()

## Input control
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and ticks == timer and dice_menu.visible:
		generate_new_dice()
		
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and ticks == timer:
		if dice_menu.visible and not dice_menu.get_rect().has_point(get_local_mouse_position()):
			show_menu(false)
		elif face_1.get_rect().has_point(get_local_mouse_position()) and not is_anim_move_playing:
			show_menu(true)
			
	if is_menu_displayed and dice_menu.visible and event.is_action_pressed("gmply_grab") and face_1.get_rect().has_point(get_local_mouse_position()):
		grabbed = true
		print("grabbed")
		current_pos = position
		show_menu(false)
		is_menu_displayed = true
	elif grabbed and event.is_action_released("gmply_grab"):
		is_menu_displayed = false
		print("released")
		grabbed = false
		if current_zone and current_zone.has_meta("zone"):
			match(current_zone.get_meta("zone", "")):
				"ROLL":
					roll()
				"REFRESH":
					generate_new_dice()
					animate_move_to(current_pos)
		else:
			animate_move_to(current_pos)
		
	if event is InputEventMouseMotion and grabbed:
		global_position = get_global_mouse_position()

func init_dice(new_pos: Vector2, _red_bar_callable:Callable, _green_bar_callable:Callable, _blue_bar_callable:Callable, _tension_bar_callable:Callable):
	get_red_bar_value = _red_bar_callable
	get_blue_bar_value = _blue_bar_callable
	get_green_bar_value = _green_bar_callable
	get_tension_bar_value = _tension_bar_callable
	
	animate_move_to(new_pos)
	generate_new_dice()

## Inicia el roll del dado
func roll() -> void:
	show_menu(false)
	is_menu_displayed = true
	previous_roll = num_choice
	num_choice = rng.randi_range(0, options.size()-1)
	choice = options[num_choice]
	interval = 0.1
	ticks = 0
	isFinished = false
	##Iniciemos el timer con el intervalo de espera para ver el "roll" del dado
	##Estoy abierto a mejoras
	$TimerRoll.wait_time = interval
	$TimerRoll.start()

## Cada vez que se el timer acabe cambia la textura hasta que ticks sea igual a timer
func _on_timer_timeout() -> void:
	##Cuando se acabe el tiempo de espera, que haga el "roll". Si aún no ha acabado el tiempo (timer), reiniciamos el timer
	##Sigo diciendo, estoy abierto a mejoras. Me disculpo con quien tenga que leer esto
	
	ticks = ticks + 1
	if ticks < timer:
		if timer - ticks  == 1:
			var rnd_number = rng.randi_range(0, options.size()-1)
			while(rnd_number == num_choice or rnd_number == previous_roll):
				rnd_number = rng.randi_range(0, options.size()-1)
			face_1.texture = options[rnd_number].texture
			label_face_number.text = str(rnd_number + 1)
			
			interval = 1
		else:
			var rnd_number = rng.randi_range(0, options.size()-1)
			while(rnd_number == previous_roll):
				rnd_number = rng.randi_range(0, options.size()-1)
			previous_roll = rnd_number
			face_1.texture = options[rnd_number].texture
			label_face_number.text = str(rnd_number + 1)
			
			interval += 0.05
		$TimerRoll.start(interval)
	else:
		$TimerRoll.stop()
		isFinished = true
		face_1.texture = choice.texture
		label_face_number.text = str(num_choice + 1)
		dice_rolled.emit(choice, spectactor_score)
		
	audio_stream_player.play()
	vibrate()
	if isFinished:
		await get_tree().create_timer(1).timeout
		is_menu_displayed = false
		queue_free()

## Change faces of dice
func generate_new_dice():
	choice = null
	options.clear()
	for i in range(6):
		options.append(all_possible_faces.pick_random())
		texture_array[i].texture = options[i].texture
	label_face_number.text = str(1)
	
	calculate_spectator_score()

func show_menu(visibility:bool):
	if is_menu_displayed and visibility:
		return
		
	is_menu_displayed = visibility
	
	dice_menu.visible = visibility
	for i in range(1, 6):
		texture_array[i].visible = visibility
		
	z_index = 1 if visibility else 0

func vibrate():
	if current_anim:
		current_anim.stop()
		position = current_pos
	current_pos = position
	current_anim = get_tree().create_tween()
	current_anim.bind_node(self)
	current_anim.tween_property(self, "position", Vector2(3, 0), 0.05).as_relative()
	current_anim.tween_property(self, "position", Vector2(-3, 0), 0.05).as_relative()
	current_anim.tween_property(self, "position", current_pos, 0.05)

func animate_move_to(new_position:Vector2):
	var anim = get_tree().create_tween()
	anim.bind_node(self)
	current_pos = new_position
	anim.tween_property(self, "is_anim_move_playing", true, 0)
	anim.tween_property(self, "position", new_position, 0.5).set_trans(Tween.TRANS_CUBIC)
	anim.tween_property(self, "is_anim_move_playing", false, 0)

func calculate_spectator_score():
	var green_mult = lerpf(1.5, 0, get_green_bar_value.call() / 100.0) 
	var blue_mult = lerpf(1.5, 0.5, get_blue_bar_value.call() / 100.0) 
	var red_mult = lerpf(1.5, 0.5, get_red_bar_value.call() / 100.0)
	var accumulated_spectator_value: float = BASE_FACE_VALUE * 2
	for option:DiceFaceDataResource in options:
		var mult = 0
		match (option.faceColor):
			DiceFaceDataResource.FaceColor.RED:
				mult = red_mult
			DiceFaceDataResource.FaceColor.BLUE:
				mult = blue_mult
			DiceFaceDataResource.FaceColor.GREEN:
				mult = green_mult
			DiceFaceDataResource.FaceColor.ALL:
				mult = (red_mult + blue_mult + green_mult) / 3
			DiceFaceDataResource.FaceColor.WHITE:
				mult = 1
		
		match (option.effect):
			DiceFaceDataResource.Effect.POSITIVE:
				accumulated_spectator_value -= (2.0-mult) * BASE_FACE_VALUE
			DiceFaceDataResource.Effect.NEGATIVE:
				accumulated_spectator_value += max(mult, 1) * BASE_FACE_VALUE
			DiceFaceDataResource.Effect.ADD_DICE:
				accumulated_spectator_value -= (2.0-mult) * BASE_FACE_VALUE
	spectactor_score = floori(accumulated_spectator_value)
	spectator_label.text = BASE_STR_SPECTATOR_TEXT.format({points= spectactor_score})
	
	globalvar.score = spectactor_score
	
func _on_dice_roll_button_pressed() -> void:
	if ticks == timer:
		roll()

func _on_dice_menu_mouse_exited() -> void:
	if not dice_menu.get_rect().has_point(get_local_mouse_position()):
		show_menu(false)

func _on_zone_detector_area_2d_area_exited(area: Area2D) -> void:
	if current_zone and area and current_zone == area:
		current_zone = null

func _on_zone_detector_area_2d_area_entered(area: Area2D) -> void:
	if area:
		current_zone = area
