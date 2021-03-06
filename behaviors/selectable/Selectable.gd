extends Node2D

onready var _parent: Sprite = get_parent()

var _selected: bool

func _draw():
  if _selected:
    draw_arc(position, _parent.get_rect().size.x + 2, 0, PI * 2, 12, Color.green)

func _on_parent_died():
  if _selected:
    Store.state.selection.remove(Store.state.selection.find(_parent))

    Store.set_state("selection", Store.state.selection)

func _on_state_changed(state_key, substate):
  match state_key:
    "selection":
      _selected = false

      for _selectable in substate:
        if _parent == _selectable:
          _selected = true
          break

func _process(delta):
  update()

func _ready():
  _parent.add_to_group("selectables")

  _parent.connect("died", self, "_on_parent_died")
  Store.connect("state_changed", self, "_on_state_changed")
