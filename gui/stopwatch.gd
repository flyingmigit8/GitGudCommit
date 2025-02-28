class_name Stopwatch
extends Node

signal time_updated(elapsed_time_text: String)

var elapsed_time := 0.0
var running := false
var formatted_time := "00:00.000"

func _ready() -> void:
	# Make sure timer works even when game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	if running:
		elapsed_time += delta
		update_formatted_time()
		emit_signal("time_updated", formatted_time)
		

func start() -> void:
	running = true

func stop() -> void:
	running = false

func reset() -> void:
	elapsed_time = 0.0
	update_formatted_time()
	emit_signal("time_updated", formatted_time)

func update_formatted_time() -> void:
	var minutes := int(elapsed_time / 60)
	var seconds := int(elapsed_time) % 60
	var milliseconds := int((elapsed_time - int(elapsed_time)) * 1000)
	
	formatted_time = "%02d:%02d.%03d" % [minutes, seconds, milliseconds]

func get_time() -> String:
	return formatted_time
