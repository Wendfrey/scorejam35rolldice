extends Node2D

const DICE = preload("uid://lcw65s7ygglt")


func _ready() -> void:
	child_order_changed.connect(reposition_childs)

func spawn_dice():
	if get_child_count() < 6:
		var new_dice = DICE.instantiate() 
		add_child(new_dice)
		new_dice.position = Vector2((get_child_count()-1) * 100, 0)

		return new_dice
	else:
		push_error("too many dices")

func reposition_childs():
	for i in range(get_child_count()):
		get_child(i).position= Vector2(i * 100, 0)
