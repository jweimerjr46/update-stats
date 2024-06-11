extends Control

@onready var game_code = $VBoxContainer/GameCode
@onready var code_label = $VBoxContainer/Codelabel
@onready var syntax_label = $VBoxContainer/CodeEdit


# Called when the node enters the scene tree for the first time.
func _ready():
	syntax_label.gutters_draw_line_numbers = true
	game_code.grab_focus()
	for keyword in ["for"]:
		syntax_label.syntax_highlighter.add_keyword_color(keyword, Color("#ff8ccc"))
	


@warning_ignore("unused_parameter")
func _process(delta):
	if Input.is_action_just_pressed("get_input"):
		get_input_text()
	
	
func get_input_text():
	#print(game_code.text)
	code_label.text = game_code.text


func _on_start_button_pressed():
	if len(game_code.text) < 10:
		Global.player_name = game_code.text
	else:
		var split_string = game_code.text.split()
		#print(int(split_string[0] + split_string[1]))
		Global.player_health = int(split_string[0] + split_string[1])
	get_tree().change_scene_to_file("res://quiz_screen.tscn")
