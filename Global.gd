extends Node

var player_name := ""

const API_KEY = "API-KEY"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  SilentWolf.configure({
	"api_key": API_KEY,
	"game_id": "bug-hunt1",
	"log_level": 1
  })

  SilentWolf.configure_scores({
	"open_scene_on_close": "res://gui/title/title.tscn"
  })
