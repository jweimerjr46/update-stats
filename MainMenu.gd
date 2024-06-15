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
	encode_data("4")	
	

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
			decode_data(game_code.text)
			
			
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


func encode_data(to_encode):
	var data_array = [str(Global.level).lpad(2, "0"), str(Global.xp).lpad(7, "0"), str(Global.bank).lpad(7, "0"), str(Global.player_health).lpad(3, "0"), str(Global.energy).lpad(3, "0"), str(Global.happiness).lpad(3, "0"), str(Global.food).lpad(3, "0"), str(Global.money).lpad(3, "0"), str(Global.alltime_correct).lpad(6, "0"), str(Global.total_time_played).lpad(6, "0")]
	var whole_number = ""
	for d in data_array:
		whole_number += d
	print(whole_number)
		
	var whole_number_array = [whole_number.substr(0, 10) + "5", whole_number.substr(10, 10) + "5", whole_number.substr(20, 10) + "5", whole_number.substr(30) + "5"]
	var divide_numbers = []
	for n in whole_number_array:
		print(n + " length: " + str(len(n)))
		divide_numbers.append(int(n)/5)
	var checksum = 0
	for n in divide_numbers:
		var n_str = str(n)
		for c in n_str:
			checksum += int(c)
	
	var name_check = ""
	for c in Global.player_name:
		name_check += str(c.unicode_at(0))
	checksum += int(name_check.substr(0, 6))
	
	print(checksum)		
	print(divide_numbers)
	var numbers_hex = []
	for n in divide_numbers:
		numbers_hex.append("%X" % n)
	numbers_hex.append("%X" % checksum)
	
	var save_code = ""
	for n in numbers_hex:
		n += "-"
		save_code += n		
	
	print(numbers_hex)
	
	save_code = Global.player_name + "-" + save_code.substr(0, len(save_code) - 1)
	
	print(save_code)
	return save_code
	
	
func decode_data(save_code):
	var parts = save_code.split("-")
	var player_name = parts[0]
	var numbers_hex = parts.slice(1, parts.size() - 1)
	var checksum_hex = parts[parts.size() - 1]

	print("Player Name: ", player_name)
	print("Numbers Hex: ", numbers_hex)
	print("Checksum Hex: ", checksum_hex)

	# Validate checksum
	var checksum = 0
	for hex_number in numbers_hex:
		var num_str = str(hex_number.hex_to_int())
		print("Num Str: ", num_str)
		for c in num_str:
			checksum += int(c)

	print("Checksum after numbers: ", checksum)

	var name_check = ""
	for c in player_name:
		name_check += str(c.unicode_at(0))
	print("Name Check: ", name_check)
	checksum += int(name_check.substr(0, 6))

	print("Checksum after name check: ", checksum)

	if checksum != checksum_hex.hex_to_int():
		print("Invalid save code: checksum does not match")
		return

	# Decode numbers
	var divide_numbers = []
	for hex_number in numbers_hex:
		divide_numbers.append(str(hex_number.hex_to_int() * 5))
	print("Divide Numbers: ", divide_numbers)

	# Convert whole_number back to individual stats
	var whole_number = ""
	var whole_numbers = []
	
	for n in divide_numbers:
		n[-1] = ""		
		whole_numbers.append(n)
	
	print("Whole Numbers: " + str(whole_numbers))
	
	whole_number = whole_numbers[0].lpad(10, "0") + whole_numbers[1].lpad(10, "0") + whole_numbers[2].lpad(10, "0") + whole_numbers[3].lpad(13, "0")
			
	print("Whole Number: ", whole_number)
	
	Global.player_name = player_name
	Global.level = int(whole_number.substr(0, 2))
	Global.xp = int(whole_number.substr(2, 7))
	Global.bank = int(whole_number.substr(9, 7))
	Global.player_health = int(whole_number.substr(16, 3))
	Global.energy = int(whole_number.substr(19, 3))
	Global.happiness = int(whole_number.substr(22, 3))
	Global.food = int(whole_number.substr(25, 3))
	Global.money = int(whole_number.substr(28, 3))
	Global.alltime_correct = int(whole_number.substr(31, 6))
	Global.total_time_played = int(whole_number.substr(37, 6))
	
	print("Decoded data:")
	print("Player Name: ", Global.player_name)
	print("Level: ", Global.level)
	print("XP: ", Global.xp)
	print("Bank: ", Global.bank)
	print("Player Health: ", Global.player_health)
	print("Energy: ", Global.energy)
	print("Happiness: ", Global.happiness)
	print("Food: ", Global.food)
	print("Money: ", Global.money)
	print("Alltime Correct: ", Global.alltime_correct)
	print("Total Time Played: ", Global.total_time_played)

	
	

