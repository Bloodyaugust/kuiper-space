extends Control

enum SELECTION_VIEWS {
  NONE,
  UNITS,
  MOTHERSHIP
}

export var selected_actor_scene: PackedScene

onready var _selected_actors_container: GridContainer = find_node("SelectedActors")
onready var _units_container: MarginContainer = find_node("Units")

var _current_subview: int = SELECTION_VIEWS.NONE
var _visible: bool

func _hide():
  rect_position.y = 600
  _visible = false

  _current_subview = SELECTION_VIEWS.NONE

  _units_container.visible = false

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

  _units_container.visible = false

  if Store.state.selection.size() == 1 && Store.state.selection[0]._data.type == "mothership":
    _current_subview = SELECTION_VIEWS.MOTHERSHIP
  else:
    _current_subview = SELECTION_VIEWS.UNITS

  GDUtil.queue_free_children(_selected_actors_container)

  match _current_subview:
    SELECTION_VIEWS.UNITS:
      _units_container.visible = true

      for _selectable in Store.state.selection:
        var _new_selected_actor_component: Control = selected_actor_scene.instance()

        _new_selected_actor_component.selectable = _selectable
        _selected_actors_container.add_child(_new_selected_actor_component)
