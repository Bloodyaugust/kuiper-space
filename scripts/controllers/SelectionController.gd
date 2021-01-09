extends Node2D

onready var _tree := get_tree()

var _drawing_selection: bool
var _selection_rect: Rect2
var _selection_start: Vector2

func _draw():
  draw_rect(_selection_rect, Color.green, false)

func _unhandled_input(event: InputEvent):
  if event is InputEventMouseButton:
    if _drawing_selection && event.button_index == BUTTON_LEFT && !event.pressed:
      if _selection_rect.size.x < 0 && _selection_rect.size.y < 0:
        _selection_rect = Rect2(get_global_mouse_position(), _selection_rect.size.abs())

      if _selection_rect.size.x < 0:
        _selection_rect = Rect2(_selection_start.x + _selection_rect.size.x, _selection_start.y, abs(_selection_rect.size.x), abs(_selection_rect.size.y))

      if _selection_rect.size.y < 0:
        _selection_rect = Rect2(_selection_start.x, _selection_start.y + _selection_rect.size.y, abs(_selection_rect.size.x), abs(_selection_rect.size.y))

      Store.set_state("selection", _select_actors())
      _drawing_selection = false
      _selection_start = Vector2()
      _selection_rect = Rect2()
    elif event.button_index == BUTTON_LEFT:
      _drawing_selection = true
      _selection_start = get_global_mouse_position()
      _selection_rect = Rect2(_selection_start.x, _selection_start.y, 0, 0)

func _process(delta):
  if _drawing_selection:
    _selection_rect.size = get_global_mouse_position() - _selection_start

  update()

func _select_actors() -> Array:
  var _selectables: Array = _tree.get_nodes_in_group("selectables")
  var _selection: Array = []

  for _selectable in _selectables:
    if _selectable.team == 0 && _selection_rect.has_point(_selectable.global_position):
      _selection.append(_selectable)

  return _selection
