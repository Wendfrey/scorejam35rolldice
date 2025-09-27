extends Node2D


var redStress:float
var greenStress:float
var blueStress:float
var spectatorCount:int
var aproval:float




func _ready() -> void:
	pass

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
			"{target} positive1",
			"{target} positive2"
		]
		return positives[rng.randi_range(0, positives.size() - 1)].format({"target": target})
	else:
		var negatives =[
			"{target}negative1",
			"{target}negative2"
			]
		return negatives[rng.randi_range(0, negatives.size() - 1)].format({"target": target})
	
