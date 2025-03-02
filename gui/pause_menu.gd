class_name PauseMenu
extends Control

@export var fade_in_duration := 0.3
@export var fade_out_duration := 0.2

@onready var center_cont := $ColorRect/CenterContainer as CenterContainer
@onready var resume_button := center_cont.get_node(^"VBoxContainer/ResumeButton") as Button

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func open() -> void:
	show()
	resume_button.grab_focus()
	modulate.a = 0.0
	center_cont.anchor_bottom = 0.5
	
	# Set the game to paused when opening the menu
	get_tree().paused = true
	
	var tween := create_tween()
	# Make sure the tween works while paused
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	
	tween.tween_property(
		self,
		"modulate:a",
		1.0,
		fade_in_duration
	).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	
	tween.parallel().tween_property(
		center_cont,
		"anchor_bottom",
		1.0,
		fade_out_duration
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func close() -> void:
	var tween := create_tween()
	# Make sure the tween works while paused
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	
	tween.tween_property(
		self,
		"modulate:a",
		0.0,
		fade_out_duration
	).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	
	tween.parallel().tween_property(
		center_cont,
		"anchor_bottom",
		0.5,
		fade_out_duration
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	# Unpause at the end of the animation
	tween.tween_callback(func() -> void:
		get_tree().paused = false
	)
	tween.tween_callback(hide)


func _on_resume_button_pressed() -> void:
	GameStopwatch.start()
	close()
	
func _on_reset_button_pressed() -> void:
	close()
	reset_game()

func _on_quit_button_pressed() -> void:
	if visible:
		get_tree().quit()
		
func reset_game() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
	GameStopwatch.reset()
