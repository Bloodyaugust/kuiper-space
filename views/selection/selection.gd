extends Control

export var selected_actor_scene: PackedScene

onready var _selected_actors_container: GridContainer = find_node("SelectedActors")

func _on_state_changed(state_key, substate):
  match state_key:
    "selection":
      if substate.size() == 0:
        rect_position.y = 600
      else:
        _show()

func _ready():
  Store.connect("state_changed", self, "_on_state_changed")

func _show():
  rect_position.y = 450

  GDUtil.queue_free_children(_selected_actors_container)

  for _selectable in Store.state.selection:
    var _new_selected_actor_component: Control = selected_actor_scene.instance()

    _selected_actors_container.add_child(_new_selected_actor_component)
