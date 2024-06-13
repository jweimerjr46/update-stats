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
	save_game("4")
	
	

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
	if game_code.text:
		start_button.disabled = false
		if len(game_code.text) < 10:
			Global.player_name = game_code.text
		else:
			load_game(game_code.text)
			
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
		

func save_game(to_encode):
	var data = "*****JERRY*2*****67***6543*45100100100100**4534***457"
	Global.player_name = data.substr(0, 10)
	Global.level = data.substr(10, 2)
	Global.xp = data.substr(12, 7)
	Global.bank = data.substr(19, 7)
	Global.player_health = data.substr(27, 3)
	Global.energy = data.substr(29, 3)
	Global.happiness = data.substr(32, 3)
	Global.food = data.substr(35, 3)
	Global.money = data.substr(38, 3)
	Global.alltime_correct = data.substr(41, 6)
	Global.total_time_played = data.substr(47, 6)
	

func load_game(save_code):
	print(save_code)
	'''
	1-10 player_name
	11-12 level
	13-19 xp
	20-26 bank
	27-29 player_health
	30-32 energy
	33-35 happiness
	36-38 food
	39-41 money
	42-47 alltime_correct
	48-53 total_time_played (in seconds)
	
	Pad values with *
	'''
	
	var data = "*****JERRY*2*****67***6543*45100100100100**4534***457"
	Global.player_name = data.substr(0, 10)
	Global.level = data.substr(10, 2)
	Global.xp = data.substr(12, 7)
	Global.bank = data.substr(19, 7)
	Global.player_health = data.substr(27, 3)
	Global.energy = data.substr(29, 3)
	Global.happiness = data.substr(32, 3)
	Global.food = data.substr(35, 3)
	Global.money = data.substr(38, 3)
	Global.alltime_correct = data.substr(41, 6)
	Global.total_time_played = data.substr(47, 6)
	
	
