extends Control
@onready var button: Button = $SubmitScore/Button
@onready var text_edit: LineEdit = $SubmitScore/TextEdit
@onready var square_box: NinePatchRect = $SubmitScore
@onready var scoreboardbg: NinePatchRect = $NinePatchRect
@onready var timerScore : Timer = $TimerScore
@onready var total_spectators_label: RichTextLabel = $TotalSpectatorsLabel
@onready var score_labels_node : Control = $ScoreLabelsNode

var score
var url = "https://www.mabl.icu/gamejam/scores.csv"
var scoreSeparator : String = "-"
var csv : Array
var pos : int
var min_score : int



func _ready() -> void:
	total_spectators_label.text = str(Globals.final_score)+"K"
	total_spectators_label.visible = Globals.submit_score
	get_leadeboard_data()
	
func get_leadeboard_data():
	$HTTPRequest.request_completed.connect(_on_request_completed)
	$HTTPRequest.request(url + "?v=" + str(randi() % 10000))


func _on_request_completed(result, response_code, headers, body):
	pos = 0
	csv = body.get_string_from_utf8().split("\n")
	
	if Globals.submit_score:
		if csv.size() >= 21 && str(csv[csv.size() - 1]) == "":
			var last_entry = csv[csv.size() - 2]
			min_score = int(last_entry.split(",")[1])
		elif csv.size() >= 20 && str(csv[csv.size() - 1]) != "":
			var last_entry = csv[csv.size() - 1]
			min_score = int(last_entry.split(",")[1])
		else:
			min_score = 0
			
		if Globals.final_score > 0 && Globals.final_score > min_score:
			square_box.visible = true
	
	timerScore.start()
	$HTTPRequest.request_completed.disconnect(_on_request_completed)
			

func summit_score(name,score:String):
	var summit_url
	summit_url = "https://www.mabl.icu/gamejam/submitScore.php?name="+name+"&score="+score
	$HTTPRequest.request_completed.connect(_on_summit_score_completed)
	$HTTPRequest.request(summit_url)
	Globals.submit_score = false
	
func _on_summit_score_completed(result, response_code, headers, body):
	$HTTPRequest.request_completed.disconnect(_on_summit_score_completed)
	get_leadeboard_data()
	
func _on_button_pressed() -> void:
	var regex = RegEx.new()
	regex.compile("[^A-Za-z]")
	var typedText = regex.sub(text_edit.text,'',true)
	if text_edit.text != typedText:
		text_edit.text = typedText
	elif typedText.length() > 2:
		square_box.hide()
		var scoretag = get_tree().get_nodes_in_group("Scorelabel")
		for i in scoretag:
			i.queue_free()
		
		summit_score(typedText,scoreEncrypt())

func scoreEncrypt() -> String:
	var minus = randi_range(1,Globals.final_score/2);
	return to_base(Globals.final_score-(minus*2),33)+"x"+to_base(minus,30)+"-"+to_base(Globals.final_score-minus,36);
	
	
func to_base(n: int, base: int) -> String:
	var chars := "0123456789abcdefghijklmnopqrstuvwxyz"
	var result := ""
	if n == 0:
		return "0"
	while n > 0:
		result = chars[n % base] + result
		n = n / base
	return result

func _on_timer_score_timeout() -> void:
	if pos < csv.size():
		if csv[csv.size() - pos - 1] != "":
			var new_label = Label.new()
			
			var split = csv[csv.size() - pos - 1].split(",")
			new_label.text = str(csv.size() - pos, ". ", split[0])
			new_label.add_theme_font_size_override("font_size", 25)
			new_label.position = Vector2(45, 30 + (25 * (csv.size() - pos - 1)))
			new_label.set("theme_override_colors/font_color", Color(0.0, 0.0, 0.0, 1.0))
			new_label.add_theme_font_override("font", load("res://Assets/font/Caveat-Bold.ttf"))
			
			var new_labelScore = Label.new()
			new_labelScore.text = split[1]
			new_labelScore.position = Vector2(475, 30 + (25 * (csv.size() - pos - 1)))
			new_labelScore.set("theme_override_colors/font_color", Color(0.0, 0.0, 0.0, 1.0))
			new_labelScore.add_theme_font_size_override("font_size", 25)
			new_labelScore.add_theme_font_override("font", load("res://Assets/font/Caveat-Bold.ttf")) 

			
			new_label.add_to_group("Scorelabel")
			new_labelScore.add_to_group("Scorelabel")
			score_labels_node.add_child(new_label)
			score_labels_node.add_child(new_labelScore)
		

		pos += 1
	else:
		timerScore.stop()
	


func _on_button_menu_button_up() -> void:
	get_tree().change_scene_to_file("res://MainMenu.tscn")
