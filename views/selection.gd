extends Control

func _on_state_changed(state_key, substate):
  match state_key:
    "selection":
      if substate.size() == 0:
        rect_position.y = 600
      else:
        rect_position.y = 450

func _ready():
  Store.connect("state_changed", self, "_on_state_changed")
