extends Sprite2D

static var is_menu_displayed:bool = false

signal dice_rolled(face:DiceFaceDataResource)

@export var all_possible_faces: Array[DiceFaceDataResource]

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

@onready var face_2: Sprite2D = $Face2
@onready var face_3: Sprite2D = $Face3
@onready var face_4: Sprite2D = $Face4
@onready var face_5: Sprite2D = $Face5
@onready var face_6: Sprite2D = $Face6
@onready var dice_menu: Control = $DiceMenu
@onready var label_face_number: Label = $LabelFaceNumber

@onready var texture_array: Array[Sprite2D] = [
	self,
	face_2,
	face_3,
	face_4,
	face_5,
	face_6
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

func _ready() -> void:
	rng = RandomNumberGenerator.new()
	generate_new_dice()

## Input control
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and ticks == timer and dice_menu.visible:
		generate_new_dice()

## Inicia el roll del dado
func roll() -> void:
	show_menu(false)
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
			self.texture = options[rnd_number].texture
			label_face_number.text = str(rnd_number + 1)
			
			interval = 1
		else:
			var rnd_number = rng.randi_range(0, options.size()-1)
			while(rnd_number == previous_roll):
				rnd_number = rng.randi_range(0, options.size()-1)
			previous_roll = rnd_number
			self.texture = options[rnd_number].texture
			label_face_number.text = str(rnd_number + 1)
			
			interval += 0.05
		$TimerRoll.start(interval)
	else:
		$TimerRoll.stop()
		isFinished = true
		self.texture = choice.texture
		label_face_number.text = str(num_choice + 1)
		dice_rolled.emit(choice)
		
	audio_stream_player.play()
	vibrate()
	
## Change faces of dice
func generate_new_dice():
	choice = null
	options.clear()
	for i in range(6):
		options.append(all_possible_faces.pick_random())
		texture_array[i].texture = options[i].texture
	label_face_number.text = str(1)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and ticks == timer:
		if dice_menu.visible and not dice_menu.get_rect().has_point(get_local_mouse_position()):
			show_menu(false)
		elif get_rect().has_point(get_local_mouse_position()):
			show_menu(true)
		
func show_menu(visibility:bool):
	if is_menu_displayed and visibility:
		return
		
	is_menu_displayed = visibility
	
	dice_menu.visible = visibility
	for i in range(1, 6):
		texture_array[i].visible = visibility
		
	z_index = 1 if visibility else 0

var current_anim:Tween = null
var current_pos

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

func _on_dice_roll_button_pressed() -> void:
	if ticks == timer:
		roll()

func _on_dice_menu_mouse_exited() -> void:
	if not dice_menu.get_rect().has_point(get_local_mouse_position()):
		show_menu(false)


func _on_dice_menu_mouse_entered() -> void:
	print("Entered")
