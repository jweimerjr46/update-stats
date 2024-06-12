extends Control

@onready var game_code = $HBoxContainer/VBoxContainer/GameCode
@onready var code_label = $HBoxContainer/VBoxContainer/Codelabel
@onready var start_button = $HBoxContainer/VBoxContainer/StartButton
@onready var load_button = $HBoxContainer/VBoxContainer/LoadDataButton
@onready var name_label = $HBoxContainer/MarginContainer/VBoxContainer2/NameLabel
@onready var level_label = $HBoxContainer/MarginContainer/VBoxContainer2/LevelLabel
@onready var xp_label = $HBoxContainer/MarginContainer/VBoxContainer2/XPLabel
@onready var bank_label = $HBoxContainer/MarginContainer/VBoxContainer2/BankLabel
@onready var health_label = $HBoxContainer/MarginContainer/VBoxContainer2/HealthLabel
@onready var energy_label = $HBoxContainer/MarginContainer/VBoxContainer2/EnergyLabel
@onready var happiness_label = $HBoxContainer/MarginContainer/VBoxContainer2/HappinessLabel
@onready var food_label = $HBoxContainer/MarginContainer/VBoxContainer2/FoodLabel
@onready var money_label = $HBoxContainer/MarginContainer/VBoxContainer2/MoneyLabel
@onready var correct_label = $HBoxContainer/MarginContainer/VBoxContainer2/CorrectLabel
@onready var time_label = $HBoxContainer/MarginContainer/VBoxContainer2/TimeLabel

# Called when the node enters the scene tree for the first time.
func _ready():	
	game_code.grab_focus()
	start_button.disabled = true
	
	

@warning_ignore("unused_parameter")
func _process(delta):
	if Input.is_action_just_pressed("get_input"):
		get_input_text()
	if Input.is_action_just_pressed("load_data"):
		load_button.emit_signal("pressed")
	
	
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
	level_label.text = "Level: " + str(Global.level)
	xp_label.text = "XP: " + str(Global.xp)
	bank_label.text = "Bank: " + str(Global.bank)
	health_label.text = "Health: " + str(Global.player_health)
	energy_label.text = "Energy: " + str(Global.energy)
	happiness_label.text = "Happiness: " + str(Global.happiness)
	food_label.text = "Food: " + str(Global.food)
	money_label.text = "Money: " + str(Global.money)
	correct_label.text = "Total Correct: " + str(Global.alltime_correct)
	time_label.text = "Total Time: " + str(Global.total_time_played)
	
	
