class_name Game
extends Node

@onready var _pause_menu := $InterfaceLayer/PauseMenu as PauseMenu
@onready var time_label := $InterfaceLayer/TimeLabel as Label

func _ready() -> void:
	# Connect to the stopwatch's time_updated signal
	GameStopwatch.time_updated.connect(_on_stopwatch_time_updated)
	# Start the stopwatch when the game begins
	GameStopwatch.start()

func _on_stopwatch_time_updated(time_text: String) -> void:
	time_label.text = time_text

func get_final_time() -> String:
	GameStopwatch.stop()
	return GameStopwatch.get_time()
	
func resume_stopwatch() -> void:
	GameStopwatch.start();

# New method to hide the stopwatch UI
func hide_stopwatch_ui() -> void:
	time_label.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"toggle_fullscreen"):
		var mode := DisplayServer.window_get_mode()
		if mode == DisplayServer.WINDOW_MODE_FULLSCREEN or \
				mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		get_tree().root.set_input_as_handled()
	elif event.is_action_pressed(&"toggle_pause"):
		var tree := get_tree()
		
		if not tree.paused:
			GameStopwatch.stop()
			_pause_menu.open()
		else:
			GameStopwatch.start()
			_pause_menu.close()
			
		get_tree().root.set_input_as_handled()
