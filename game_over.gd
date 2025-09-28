extends Control
@onready var button: Button = $SquareBox/Button
@onready var text_edit: TextEdit = $SquareBox/TextEdit
@onready var square_box: Sprite2D = $SquareBox
@onready var scoreboardbg: NinePatchRect = $NinePatchRect
@onready var scoreboard: RichTextLabel = $NinePatchRect/scoreboard
@onready var timerScore : Timer = $TimerScore
@onready var total_spectators_label: RichTextLabel = $TotalSpectatorsLabel

var score
var url = "http://www.mabl.icu/gamejam/scores.csv"
var scoreSeparator : String = "-"
var csv : Array
var pos : int


#http://www.mabl.icu/gamejam/submitScore.php?name=toni&score=55577

func _ready() -> void:
	total_spectators_label.text = str(globalvar.score)+"K"
	$HTTPRequest.request_completed.connect(_on_request_completed)
	$HTTPRequest.request(url)


func _on_request_completed(result, response_code, headers, body):
	pos = 0
	csv = body.get_string_from_utf8().split("\n")
	timerScore.start()

			

func summit_score(name,score:String):
	var summit_url
	summit_url = "http://www.mabl.icu/gamejam/submitScore.php?name="+name+"&score="+score
	$HTTPRequest.request(summit_url)



func _on_button_pressed() -> void:
	if text_edit.text != "":
		summit_score(text_edit.text,str(globalvar.score))
		square_box.hide()
	for new_label in get_tree():
		new_label.queue_free()


func _on_timer_score_timeout() -> void:
	if pos < csv.size():
		if csv[csv.size() - pos - 1] != "":
			var new_label = Label.new()
			
			var split = csv[csv.size() - pos - 1].split(",")
			new_label.text = str(csv.size() - pos, ". ", split[0])
			new_label.position = Vector2(45, 30 + (25 * (csv.size() - pos - 1)))
			new_label.set("theme_override_colors/font_color", Color(0.0, 0.0, 0.0, 1.0))
			
			var new_labelScore = Label.new()
			new_labelScore.text = split[1]
			new_labelScore.position = Vector2(475, 30 + (25 * (csv.size() - pos - 1)))
			new_labelScore.set("theme_override_colors/font_color", Color(0.0, 0.0, 0.0, 1.0))
			
			add_child(new_label)
			add_child(new_labelScore)
		pos = pos + 1
		timerScore.start()
			
