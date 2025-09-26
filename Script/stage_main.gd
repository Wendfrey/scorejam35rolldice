extends Node2D


var redStress:float
var greenStress:float
var blueStress:float
var spectatorCount:int
var aproval:float



func end_game():
	if redStress > 100 or greenStress > 100 or blueStress > 100:
		pass
func update_aproval():
	aproval = (redStress + greenStress + blueStress)/3
