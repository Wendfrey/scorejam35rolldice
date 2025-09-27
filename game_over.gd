extends Control
@onready var button: Button = $SquareBox/Button
@onready var text_edit: TextEdit = $SquareBox/TextEdit
@onready var square_box: Sprite2D = $SquareBox
@onready var scoreboardbg: NinePatchRect = $NinePatchRect
@onready var scoreboard: RichTextLabel = $NinePatchRect/scoreboard
@onready var v_box_container: VBoxContainer = $NinePatchRect/MarginContainer/VBoxContainer


var score
var url = "http://www.mabl.icu/gamejam/scores.csv"


#http://www.mabl.icu/gamejam/submitScore.php?name=toni&score=55577

func _ready() -> void:
	$HTTPRequest.request_completed.connect(_on_request_completed)
	$HTTPRequest.request(url)


func _on_request_completed(result, response_code, headers, body):
	var pos = 1
	var csv = body.get_string_from_utf8().split("\n")
	for i:String in csv:
		if pos < 21:
			var split = i.split(",")
			scoreboard.text +=str(pos)+"."+split[0]+".................................."+split[1]+"\n"
		pos += 1

func summit_score(name,score:String):
	var summit_url
	summit_url = "http://www.mabl.icu/gamejam/submitScore.php?name="+name+"&score="+score
	$HTTPRequest.request(summit_url)



func _on_button_pressed() -> void:
	if text_edit.text != "":
		summit_score(text_edit.text,"6000")
		square_box.hide()
		scoreboardbg.show()
		$HTTPRequest.request_completed.connect(_on_request_completed)
		$HTTPRequest.request(url)
	
