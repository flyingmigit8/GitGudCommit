class_name VictoryScreen
extends CanvasLayer

# Use the correct path to your time label
@onready var time_label := $TimeLabel

var final_time := "00:00.000"

func _ready() -> void:
	# Make sure victory screen processes when game is paused
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	# Pause the game when the victory screen appears
	get_tree().paused = true
		
	# Set the time label text
	time_label.text = "Your Time: " + final_time

func set_final_time(time: String) -> void:
	final_time = time
	time_label.text = "Your Time: " + final_time

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"toggle_pause"):
		restart_game()

func restart_game() -> void:
	# Unpause the game
	get_tree().paused = false
	
	# Reload the current scene to restart the game
	get_tree().reload_current_scene()
