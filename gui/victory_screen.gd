class_name VictoryScreen
extends CanvasLayer

@onready var line_edit: LineEdit = $Control/LineEdit
@onready var time_label := $TimeLabel
var final_time := "00:00.000"
var player_name: String

func _ready() -> void:
	# Make sure victory screen processes when game is paused
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	# Pause the game when the victory screen appears
	get_tree().paused = true
	
	GameStopwatch.stop()
	# Set the time label text
	time_label.text = "Your Time: " + GameStopwatch.formatted_time

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_pause"):
		restart_game()

func restart_game() -> void:
	# Unpause the game
	get_tree().paused = false
	
	# Reload the current scene to restart the game
	GameStopwatch.stop()
	GameStopwatch.reset()
	get_tree().change_scene_to_file("res://gui/title/title.tscn")
	
func _on_submit_button_pressed() -> void:
	if player_name.is_empty():
		player_name = "Guest"  # Default name if empty
		
	var time = GameStopwatch.elapsed_time

	if not Global.API_KEY == "API-KEY":
		var sw_result: Dictionary = await SilentWolf.Scores.save_score(player_name, time).sw_save_score_complete
		print("Score persisted successfully: " + str(sw_result.score_id))
		print(time)
		get_tree().paused = false
		get_tree().change_scene_to_file("res://addons/silent_wolf/Scores/Leaderboard.tscn")
	else:
		restart_game()

func _on_line_edit_text_changed(new_text: String) -> void:
	player_name = line_edit.text
	Global.player_name = player_name

func _on_new_button_pressed() -> void:
	restart_game()
