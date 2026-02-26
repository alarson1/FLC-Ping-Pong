extends Control

signal ask_run_sim()

func _ready():
	pass

func _on_sim_run_button_pressed():
	# check anything before we fire?
	ask_run_sim.emit()
	
func on_simulation_success(_data: Dictionary):
	var label: Label = $MarginContainer/PanelContainer/VBoxContainer/Simulation/MarginContainer/VBoxContainer/SimLabel
	label.text = "Success"
	
func on_simulation_failed(reason: String):
	var label: Label = 	$MarginContainer/PanelContainer/VBoxContainer/Simulation/MarginContainer/VBoxContainer/SimLabel
	label.text = "!! " + reason + "!!"
	label["theme_override_colors/font_color"] = Color.RED
