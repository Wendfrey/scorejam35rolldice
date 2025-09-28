extends Node2D

const DICE = preload("uid://lcw65s7ygglt")
const MARGIN_X = 125
@export var dice_sliding_into_game_sound: AudioStreamPlayer

@export var spawnPoint: Marker2D

var do_repositions: bool = false
func _ready() -> void:
	child_order_changed.connect(reposition_childs)

func spawn_dice(get_red_bar_call:Callable, get_green_bar_call:Callable, get_blue_bar_call:Callable,  dice_about_to_be_destroyed: bool = false):
	if get_child_count() < 6 or (get_child_count() == 6 and dice_about_to_be_destroyed):
		do_repositions = false
		var new_dice = DICE.instantiate() 
		add_child(new_dice)
		new_dice.position = spawnPoint.position - position + Vector2((get_child_count()-1) * MARGIN_X, 0)
		new_dice.init_dice(Vector2((get_child_count()-1) * MARGIN_X, 0), get_red_bar_call, get_green_bar_call, get_blue_bar_call, Callable())
		do_repositions = true
		get_tree().create_timer(0.2).timeout.connect(_play_sound)
		return new_dice
	else:
		return null

func reposition_childs():
	if do_repositions and is_inside_tree():
		for i in range(get_child_count()):
			get_child(i).animate_move_to(Vector2(i * MARGIN_X, 0))

func recalculate_dice_spectators():
		for i in range(get_child_count()):
			get_child(i).calculate_spectator_score()
	
func _play_sound():
	dice_sliding_into_game_sound.play()
