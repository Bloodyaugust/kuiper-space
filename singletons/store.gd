extends Node

signal state_changed(state_key, substate)

signal achievement_get(achievement)

var state: Dictionary = {
  "achievements_synced": false,
  "client_view": "",
  "game": "",
  "selection": []
 }

func set_state(state_key: String, new_state) -> void:
  state[state_key] = new_state
  emit_signal("state_changed", state_key, state[state_key])
  print("State changed: ", state_key, " -> ", state[state_key])
  
func _initialize():
  set_state("achievements_synced", false)
  set_state("client_view", ClientConstants.CLIENT_VIEW_MAIN_MENU)
  set_state("game", GameConstants.GAME_OVER)
  set_state("selection", [])

func _ready():
  call_deferred("_initialize")
