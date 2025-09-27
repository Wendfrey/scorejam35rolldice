extends Node2D

const DICE = preload("uid://lcw65s7ygglt")




func spawn_dice():
	if get_child_count() < 6:
		var new_dice = DICE.instantiate() 
		add_child(new_dice)
		new_dice.position = Vector2((get_child_count()-1) * 100, 0)
		
	else:
		push_error("too many dices")
