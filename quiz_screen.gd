extends Control

'''
Animations:
	Playing animation
	When energy gets low (modulate color)
	When health gets low (takes precident)
	When happiness gets low
	When energy gets to zero
	When health gets to zero
	When happiness gets to zero
	When something gets to 100%
	
Sound effects:
	Get question correct
	Get question incorrect
	Sell food
	Buy food
	Play
	When something gets to 100%
'''

# Colors


@export var choices_group: ButtonGroup
var level_dictionary = Global.level_dictionary

var question_label
var code_label
var xp_label
var correct_label
var total_label
var timer_label
var food_label
var money_label
var bank_label
var question_xp_label
var level_label

var health_bar
var energy_bar
var happiness_bar
var xp_progress_bar

@onready var warning_window = $WarningWindow
@onready var warning_label = $WarningWindow/VBoxContainer/WarningLabel
@onready var exit_window = $ExitWindow
@onready var save_code_to_copy = $ExitWindow/VBoxContainer/SaveCode

var questions = []
var original_questions = []
var correct_answer = ""
var current_question = ""
var buttons = []
var options = []
var questions_answered = 0
var questions_correct = 0
var timer_started = false
var time_elapsed = 0.0
@onready var anim = $HBoxContainer/VBoxContainer2/AnimatedSprite2D
@onready var sound_player = $AudioStreamPlayer
var correct_sound = preload("res://assets/up.wav")
var incorrect_sound = preload("res://assets/down.wav")

# Player Stats
var player_health = Global.player_health
var player_happiness = Global.happiness
var player_energy = Global.energy
var food = Global.food
var money = Global.money
var player_name = Global.player_name
var level = Global.level
var xp = Global.xp
var alltime_correct = Global.alltime_correct
var total_time_played = Global.total_time_played
var bank = Global.bank
var coin_timer

var correct_percentage = player_happiness/5.0
var correct_run = 0

# variables for adjustments
var health_reduction_rate = 0.4
var energy_reduction_rate = 0.7
var energy_per_food = 2
var cost_buy_food = 4
var price_sell_food = 2
var cost_to_play = 5
var play_health_increase = 2
var play_energy_decrease = 4
var correct_list = [1, 1, 1, 1, 1,
					1, 1, 1, 1, 1,
					1, 1, 1, 1, 1,
					1, 1, 1, 1, 1]
var question_xp = 0

var times_wrong = 0


func _ready():
	question_label = $HBoxContainer/MarginContainer/VBoxContainer/QuestionLabel
	code_label = $HBoxContainer/MarginContainer/VBoxContainer/MarginContainer/CodeLabel
	xp_label = $HBoxContainer/VBoxContainer3/XPLabel
	xp_label.text = "XP: " + str(xp)
	correct_label = $HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/CorrectLabel
	total_label = $HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/TotalLabel
	timer_label = $HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer2/TimerLabel
	food_label = $HBoxContainer/VBoxContainer2/FoodLabel
	money_label = $HBoxContainer/VBoxContainer2/CoinLabel
	bank_label = $HBoxContainer/VBoxContainer2/BankLabel
	$HBoxContainer/VBoxContainer2/NameLabel.text = player_name
	question_xp_label = $HBoxContainer/MarginContainer/VBoxContainer/QuestionXPLabel
	level_label = $HBoxContainer/VBoxContainer3/LevelLabel
	level_label.text = "Level: " + str(Global.level)
	
	food_label.text = "Food: " + str(food)
	money_label.text = "Money: " + str(money)
	
	#code_label.syntax_highlighter.add_color_region('"', '"', Color("#e3af20"))
	var python_keywords = [
	"False", "None", "True", "and", "as", "assert", "async", "await", "break", "class", 
	"continue", "def", "del", "elif", "else", "except", "finally", "for", "from", "global", 
	"if", "import", "in", "is", "lambda", "nonlocal", "not", "or", "pass", "raise", "return", 
	"try", "while", "with", "yield"
]

	# adds keywords and color for keywords
	for keyword in python_keywords:
		code_label.syntax_highlighter.add_keyword_color(keyword, Color("#569cd6"))

	# formats strings
	code_label.syntax_highlighter.add_color_region('"', '"', Color("#6a9955"))
	code_label.syntax_highlighter.add_color_region("'", "'", Color("#6a9955"))

	# formats comments
	code_label.syntax_highlighter.add_color_region('#', '', Color("#211f1f"))

	coin_timer = $Timer
	
	health_bar = $HBoxContainer/VBoxContainer2/HBoxContainer/HealthBar
	energy_bar = $HBoxContainer/VBoxContainer2/HBoxContainer2/EnergyBar
	happiness_bar = $HBoxContainer/VBoxContainer2/HBoxContainer3/HappinessBar
	xp_progress_bar = $HBoxContainer/VBoxContainer3/NextLevelProgressBar
	xp_progress_bar.value = xp - level_dictionary[level]
	xp_progress_bar.max_value = level_dictionary[level + 1]
	health_bar.value = player_health
	energy_bar.value = player_energy
	happiness_bar.value = player_happiness
	
	coin_timer.connect("timeout", add_money)
	coin_timer.start()
		
	var file = FileAccess.open("res://questions.json", FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		var json = JSON.new()
		var parse_result = json.parse(json_text)

		if parse_result == OK:
			questions = json.get_data()
			original_questions = questions.duplicate()
			# print(questions)
		else:
			print("Failed to parse JSON file")
		file.close()
	else:
		print("questions3.json file not found")

	randomize()
	questions.shuffle()
	current_question = questions.pop_front()
	#print(current_question)
	question_label.text = current_question["question"]
	code_label.text = current_question["code"]
	code_label_size(code_label)
	correct_answer = current_question['correct_answer']
	question_xp = int(current_question['xp'])
	question_xp_label.text = "Question XP: " + str(question_xp)	

	buttons = choices_group.get_buttons()

	options = current_question['options']
	options.shuffle()
	for i in range(4):
		buttons[i].connect("pressed", button_pressed.bind(buttons[i]))
		buttons[i].text = options[i]

func _process(delta):
	if timer_started:
		if player_energy > 30:
			player_health -= delta * health_reduction_rate
		elif player_energy > 0:
			player_health -= delta * health_reduction_rate * 1.5
		else:
			player_health -= delta * health_reduction_rate * 2
		player_health = clamp(player_health, 0, 102)
		if player_health == 0:
			timer_started = false
			warning_label.text = "YOU LOST ALL YOUR HEALTH!

You will go back to beginning of the current level, lose half of your food, and half of your coins."
			warning_window.show()
			if level == 0:
				xp = 0
			else:
				xp = level_dictionary[level]
			player_health = 100
			player_energy = 100
			xp_label.text = "XP: " + str(xp)
			food = floor(food / 2.0)
			food_label.text = "Food: " + str(food)
			money = floor(money / 2.0)
			money_label.text = "Money: " + str(money)
		health_bar.value = player_health
		player_energy -= delta * energy_reduction_rate
		energy_bar.value = player_energy
		time_elapsed += delta		
		update_time_label(time_elapsed)

	if Input.is_action_just_pressed("reset_game"):
		reset_game()
	elif Input.is_action_just_pressed("feed"):
		if food > 0:
			food -= 1
			food = clamp(food, 0, 100)
			player_energy += energy_per_food
			energy_bar.value = player_energy
			player_energy = clamp(player_energy, 0, 102)
			print("Fed creature, energy is: " + str(player_energy).pad_decimals(2))
			print("Food: " + str(food))
			food_label.text = "Food: " + str(food)
	elif Input.is_action_just_pressed("play") and money >= cost_to_play and player_energy > play_energy_decrease:
		player_health += play_health_increase
		player_energy -= play_energy_decrease
		money -= cost_to_play
		money_label.text = "Money: " + str(money)
	elif Input.is_action_just_pressed("buy_food") and money > cost_buy_food and player_energy > 0:
		food += 1
		money -= cost_buy_food
		money_label.text = "Money: " + str(money)
		food_label.text = "Food: " + str(food)
	elif Input.is_action_just_pressed("sell_food") and food > 0:
		food -= 1
		money += price_sell_food
		update_money()
		food_label.text = "Food: " + str(food)
	elif Input.is_action_just_pressed("show code"):
		$HBoxContainer/VBoxContainer3/ExitButton.emit_signal("pressed")


func get_next_question():	
	if questions.size() == 0:
		reset_questions()
	current_question = questions.pop_front()
	question_label.text = current_question["question"]
	code_label.text = current_question["code"]
	code_label_size(code_label)
	options = current_question['options']
	question_xp = int(current_question['xp'])
	question_xp_label.text = "Question XP: " + str(question_xp)
	options.shuffle()
	for i in range(4):
		buttons[i].text = options[i]
	correct_answer = current_question['correct_answer']


func reset_questions():
	questions = original_questions.duplicate()
	questions.shuffle()
	
	
func code_label_size(label):	
	var height = (label.text.count("\n") + 1) * 75
	label.custom_minimum_size = Vector2(0, height )
	
	
func button_pressed(button):	
	if not timer_started:
		timer_started = true

	if timer_started:
		#var button = choices_group.get_pressed_button()
		questions_answered += 1
		total_label.text = "Attempts: " + str(questions_answered)

		if button.text == correct_answer and times_wrong < 3:
			alltime_correct += 1
			anim.play("jump")
			sound_player.stream = correct_sound
			sound_player.play()
			questions_correct += 1
			xp += question_xp * (0.5 ** times_wrong)
			times_wrong = 0
			xp_label.text = "XP: " + str(xp)
			# Working on the XP level progress bar
			xp_progress_bar.value = xp - level_dictionary[level]
			if xp > level_dictionary[level + 1]:
				level += 1
				level_label.text = "Level: " + str(level)
				xp_progress_bar.value = xp - level_dictionary[level]
				xp_progress_bar.max_value = level_dictionary[level + 1] - level_dictionary[level]
				print(xp_progress_bar.max_value)
			if player_energy > 0:
				player_health += 2
			correct_run += 1
			if correct_percentage < 20:
				correct_list.append(1)
				correct_list.pop_front()
				correct_percentage = correct_list.count(1)
			if correct_run >= 20:
				food += 3
			elif correct_run >= 10:
				food += 2
			elif correct_run >= 5:
				food += 1
			if food > 100:
				if player_energy > 0:
					var to_sell = food - 100
					money += price_sell_food * to_sell
					update_money()
				food = 100
			correct_label.text = "Correct: " + str(questions_correct)
			get_next_question()
		else:
			anim.play("wrong")
			times_wrong += 1
			sound_player.stream = incorrect_sound
			sound_player.play()
			player_health -= 4
			correct_run = 0
			if correct_percentage > 0:
				correct_list.append(0)
				correct_list.pop_front()
				correct_percentage = correct_list.count(1)
			question_xp_label.text = "YOU ARE WRONG!"
		button.set_pressed_no_signal(false)
		if times_wrong == 3:
			get_next_question()
			times_wrong = 0
	
	player_happiness = correct_percentage * 5
	happiness_bar.value = player_happiness
	
	food_label.text = "Food: " + str(food)


func reset_game():
	time_elapsed = 0.0
	timer_label.text = "Time: " + str(time_elapsed).pad_decimals(1)
	questions_answered = 0
	questions_correct = 0
	correct_label.text = "Correct: " + str(questions_correct)
	total_label.text = "Attempts: " + str(questions_answered)
	timer_started = false
	health_bar.value = 100
	happiness_bar.value = 100
	energy_bar.value = 100
	food = 0
	money = 0
	correct_run = 0
	reset_questions()
	get_next_question()
	
func add_money():
	if happiness_bar.value > 75 and timer_started and player_energy > 50:
		money += 1
		update_money()
		
		
func update_money():
	if money > 100:
		bank += (money - 100)
		money = 100
	money_label.text = "Money: " + str(money)
	bank_label.text = "Bank: " + str(bank)
	
	
# Function to disable a button and change its appearance
func disable_button(button: Button):
	# Modulate the button's color to indicate it is not correct
	button.modulate = Color(0.5, 0.5, 0.5) # Example: gray color

	# Change the button's text color
	var font = button.get_theme_font("font")
	var new_font = font.duplicate() # Duplicate the font to avoid changing the original
	new_font.color = Color(1, 0, 0) # Example: red color
	button.add_font_override("font", new_font)

	# Disable the button
	button.disabled = true
	
func update_time_label(time):
	var hours = floor(time / 3600)
	var minutes = floor(int(time/60) % 60)	
	var seconds = int(time) % 60
	timer_label.text = "Time: %02d:%02d:%02d" % [hours, minutes, seconds]


func encode_data():
	var data_array = [str(level).lpad(2, "0"), str(xp).lpad(7, "0"), str(int(bank)).lpad(7, "0"), str(int(player_health)).lpad(3, "0"), str(int(player_energy)).lpad(3, "0"), str(int(player_happiness)).lpad(3, "0"), str(int(food)).lpad(3, "0"), str(int(money)).lpad(3, "0"), str(int(alltime_correct)).lpad(6, "0"), str(int(total_time_played + time_elapsed)).lpad(6, "0")]
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
	for c in player_name:
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


func _on_cancel_button_pressed():
	exit_window.hide()
	timer_started = true


func _on_leave_button_pressed():
	get_tree().quit()


func _on_exit_button_pressed():
	exit_window.show()
	save_code_to_copy.text = encode_data()
	DisplayServer.clipboard_set(save_code_to_copy.text)
	timer_started = false


func _on_message_close_button_pressed():	
	warning_window.hide()
	timer_started = true
