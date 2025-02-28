class_name VictoryScreen
extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Pause the game when the victory screen appears
	get_tree().paused = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# You can add any continuous logic here if needed
	pass

# Function to handle the restart button press
func _on_restart_button_pressed() -> void:
	# Unpause the game
	get_tree().paused = false
	# Reload the current scene
	get_tree().reload_current_scene()
