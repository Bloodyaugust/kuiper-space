extends Control

export var selected_actor_scene: PackedScene

onready var _selected_actors_container: GridContainer = find_node("SelectedActors")

var _visible: bool

func _hide():
  rect_position.y = 600
  _visible = false

func _on_state_changed(state_key, substate):
  match state_key:
    "selection":
      if substate.size() == 0:
        _hide()
      else:
        _show()

func _ready():
  Store.connect("state_changed", self, "_on_state_changed")

func _show():
  rect_position.y = 450
  _visible = true

  GDUtil.queue_free_children(_selected_actors_container)

  for _selectable in Store.state.selection:
    var _new_selected_actor_component: Control = selected_actor_scene.instance()

    _new_selected_actor_component.selectable = _selectable
    _selected_actors_container.add_child(_new_selected_actor_component)
