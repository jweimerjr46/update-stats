extends Control

@onready var game_code = $HBoxContainer/VBoxContainer/GameCode
@onready var code_label = $HBoxContainer/VBoxContainer/Codelabel
@onready var start_button = $HBoxContainer/VBoxContainer/StartButton
@onready var name_label = $HBoxContainer/MarginContainer/VBoxContainer2/NameLabel
@onready var xp_label = $HBoxContainer/MarginContainer/VBoxContainer2/XPLabel


# Called when the node enters the scene tree for the first time.
func _ready():	
	game_code.grab_focus()
	start_button.disabled = true
	
	

@warning_ignore("unused_parameter")
func _process(delta):
	if Input.is_action_just_pressed("get_input"):
		get_input_text()
	
	
func get_input_text():
	#print(game_code.text)
	code_label.text = game_code.text


func _on_start_button_pressed():
	
	get_tree().change_scene_to_file("res://quiz_screen.tscn")


func _on_load_data_button_pressed():
	start_button.disabled = false	
	if len(game_code.text) < 10:
		Global.player_name = game_code.text
	else:
		var split_string = game_code.text.split()
		#print(int(split_string[0] + split_string[1]))
		Global.player_health = int(split_string[0] + split_string[1])
	name_label.text = "Name: " + Global.player_name
	xp_label.text = "XP: " + str(Global.xp)
	
	
