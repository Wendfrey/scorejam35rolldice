extends Node2D


func _on_ready() -> void:
	$Dice.interval = 1.0
	$Dice.timer = 4
	$Dice.options = ["testBlue.png", "testCyan.png", "testGreen.png", "testOrange.png", "testRed.png", "testYellow.png"]
	$Dice.roll()

func _process(delta: float) -> void:
	if $Dice.isFinished:
		$Dice.interval = 0.1
		$Dice.timer = 50
		$Dice.options = ["testBlue.png", "testCyan.png", "testGreen.png"]
		$Dice.roll()

		
