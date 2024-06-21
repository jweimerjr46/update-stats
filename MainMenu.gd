extends Control

@onready var game_code = $HBoxContainer/MarginContainer/VBoxContainerBefore/GameCodeOriginal
@onready var message_label = $HBoxContainer/VBoxContainer/MessageLabel
@onready var load_button = $HBoxContainer/VBoxContainer/LoadDataButton
@onready var name_label = $HBoxContainer/MarginContainer/VBoxContainerBefore/NameLabelBefore
@onready var level_label = $HBoxContainer/MarginContainer/VBoxContainerBefore/LevelLabelBefore
@onready var xp_label = $HBoxContainer/MarginContainer/VBoxContainerBefore/XPLabelBefore
@onready var bank_label = $HBoxContainer/MarginContainer/VBoxContainerBefore/BankLabelBefore
@onready var health_label = $HBoxContainer/MarginContainer/VBoxContainerBefore/HealthLabelBefore
@onready var energy_label = $HBoxContainer/MarginContainer/VBoxContainerBefore/EnergyLabelBefore
@onready var happiness_label = $HBoxContainer/MarginContainer/VBoxContainerBefore/HappinessLabelBefore
@onready var food_label = $HBoxContainer/MarginContainer/VBoxContainerBefore/FoodLabelBefore
@onready var money_label = $HBoxContainer/MarginContainer/VBoxContainerBefore/MoneyLabelBefore
@onready var correct_label = $HBoxContainer/MarginContainer/VBoxContainerBefore/CorrectLabelBefore
@onready var time_label = $HBoxContainer/MarginContainer/VBoxContainerBefore/TimeLabelBefore

@onready var game_code_updated = $HBoxContainer/MarginContainer2/VBoxContainerAfter/GameCodeNew
@onready var name_label_updated = $HBoxContainer/MarginContainer2/VBoxContainerAfter/HBoxContainer/VBoxContainer/NameLabelAfter
@onready var level_label_updated = $HBoxContainer/MarginContainer2/VBoxContainerAfter/HBoxContainer/VBoxContainer/LevelLabelAfter
@onready var xp_label_updated = $HBoxContainer/MarginContainer2/VBoxContainerAfter/HBoxContainer/VBoxContainer/XPLabelAfter
@onready var bank_label_updated = $HBoxContainer/MarginContainer2/VBoxContainerAfter/HBoxContainer/VBoxContainer/BankLabelAfter
@onready var health_label_updated = $HBoxContainer/MarginContainer2/VBoxContainerAfter/HBoxContainer/VBoxContainer/HealthLabelAfter
@onready var energy_label_updated = $HBoxContainer/MarginContainer2/VBoxContainerAfter/HBoxContainer/VBoxContainer/EnergyLabelAfter
@onready var happiness_label_updated = $HBoxContainer/MarginContainer2/VBoxContainerAfter/HBoxContainer/VBoxContainer/HappinessLabelAfter
@onready var food_label_updated = $HBoxContainer/MarginContainer2/VBoxContainerAfter/HBoxContainer/VBoxContainer/FoodLabelAfter
@onready var money_label_updated = $HBoxContainer/MarginContainer2/VBoxContainerAfter/HBoxContainer/VBoxContainer/MoneyLabelAfter
@onready var correct_label_updated = $HBoxContainer/MarginContainer2/VBoxContainerAfter/HBoxContainer/VBoxContainer/CorrectLabelAfter
@onready var time_label_updated = $HBoxContainer/MarginContainer2/VBoxContainerAfter/HBoxContainer/VBoxContainer/TimeLabelAfter

var updated_player_name
var updated_level
var updated_xp
var updated_bank
var updated_player_health
var updated_energy
var updated_happiness
var updated_food
var updated_money
var updated_alltime_correct
var updated_total_time_played

var valid_save_code = false

# Called when the node enters the scene tree for the first time.
func _ready():	
	game_code.grab_focus()	
		


@warning_ignore("unused_parameter")
func _process(delta):	
	if Input.is_action_just_pressed("load_data"):
		load_button.emit_signal("pressed")
	
	
func _on_load_data_button_pressed():
	if game_code.text:		
		if len(game_code.text) <= 10:
			Global.player_name = game_code.text
			set_labels()
		else:
			decode_data(game_code.text)
			if valid_save_code == false:
				message_label.text = "Invalid Save Code!"
				game_code_updated.text = ""
				reset_labels()
			else:
				set_labels()
				set_updated_labels()
				message_label.text = "Data Loaded"
				game_code_updated.text = encode_data()
				$HBoxContainer/VBoxContainer/CopyNewCodeButton.disabled = false


func encode_data():
	var data_array = [str(updated_level).lpad(2, "0"), str(int(updated_xp)).lpad(7, "0"), str(updated_bank).lpad(7, "0"), str(updated_player_health).lpad(3, "0"), str(updated_energy).lpad(3, "0"), str(updated_happiness).lpad(3, "0"), str(updated_food).lpad(3, "0"), str(updated_money).lpad(3, "0"), str(updated_alltime_correct).lpad(6, "0"), str(updated_total_time_played).lpad(6, "0")]
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
	for c in updated_player_name:
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
	
	save_code = updated_player_name + "-" + save_code.substr(0, len(save_code) - 1)
	
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
		valid_save_code = false
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
	
	updated_player_name = player_name
	updated_level = int(whole_number.substr(0, 2))
	updated_xp = int(whole_number.substr(2, 7))
	updated_bank = int(whole_number.substr(9, 7))
	updated_player_health = int(whole_number.substr(16, 3))
	updated_energy = int(whole_number.substr(19, 3))
	updated_happiness = int(whole_number.substr(22, 3))
	updated_food = int(whole_number.substr(25, 3))
	updated_money = int(whole_number.substr(28, 3))
	updated_alltime_correct = int(whole_number.substr(31, 6))
	updated_total_time_played = int(whole_number.substr(37, 6))
	
	
	
	valid_save_code = true
	
	
func reset_labels():
	name_label.text = "Name: "
	level_label.text = "Level: "
	xp_label.text = "XP: "
	bank_label.text = "Bank: "
	health_label.text = "Health: "
	energy_label.text = "Energy: "
	happiness_label.text = "Happiness: "
	food_label.text = "Food: "
	money_label.text = "Money: "
	correct_label.text = "Total Correct: "
	time_label.text = "Total Time: "
	
	name_label_updated.text = "Name: "
	level_label_updated.text = "Level: "
	xp_label_updated.text = "XP: "
	bank_label_updated.text = "Bank: "
	health_label_updated.text = "Health: "
	energy_label_updated.text = "Energy: "
	happiness_label_updated.text = "Happiness: "
	food_label_updated.text = "Food: "
	money_label_updated.text = "Money: "
	correct_label_updated.text = "Total Correct: "
	time_label_updated.text = "Total Time: "
	
func set_labels():
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
	update_time_label(Global.total_time_played)
	
func set_updated_labels():
	name_label_updated.text = "Name: " + Global.player_name
	level_label_updated.text = "Level: " + str(Global.level)
	xp_label_updated.text = "XP: " + str(Global.xp)
	bank_label_updated.text = "Bank: " + str(Global.bank)
	health_label_updated.text = "Health: " + str(Global.player_health)
	energy_label_updated.text = "Energy: " + str(Global.energy)
	happiness_label_updated.text = "Happiness: " + str(Global.happiness)
	food_label_updated.text = "Food: " + str(Global.food)
	money_label_updated.text = "Money: " + str(Global.money)
	correct_label_updated.text = "Total Correct: " + str(Global.alltime_correct)
	update_time_label(Global.total_time_played)


func update_time_label(time):
	var hours = floor(time / 3600)
	var minutes = floor(int(time/60) % 60)	
	var seconds = int(time) % 60
	time_label.text = "Time: %02d:%02d:%02d" % [hours, minutes, seconds]
	time_label_updated.text = "Time: %02d:%02d:%02d" % [hours, minutes, seconds]


func _on_copy_new_code_button_pressed():
	#$HBoxContainer/MarginContainer2/VBoxContainerAfter/GameCodeNew.text = encode_data()
	#$HBoxContainer/MarginContainer2/VBoxContainerAfter/GameCodeNew.text = "hello"
	DisplayServer.clipboard_set(game_code_updated.text)
