extends Sprite

onready var _area2d: Area2D = $"./Area2D"

var _data: Dictionary
var _resource_count: int
var _rotation_speed: float

func get_type() -> String:
  return _data.type

func initialize(type: String, size: float) -> void:
  _data = CastleDB.get_asteroid(type)

  modulate = Color(_data.colorHex)
  _resource_count = lerp(_data.resourceRange[0], _data.resourceRange[1], size)

func mine() -> Dictionary:
  _resource_count -= 1

  _scale_asteroid()

  if _resource_count <= 0:
    queue_free()

  return {
    "type": _data.resource,
    "amount": 1
  }

func _on_area_input_event(viewport: Object, event: InputEvent, shape_index: int):
  if event is InputEventMouseButton && event.button_index == BUTTON_RIGHT && !event.pressed && Store.state.selection.size() > 0:
    for _drone in Store.state.selection:
      if _drone._data.type == "mining":
        _drone.target_asteroid(self, true)

func _process(delta):
  rotate(_rotation_speed * delta)

func _ready():
  _rotation_speed = rand_range(-0.25, 0.25)
  _scale_asteroid()

  _area2d.connect("input_event", self, "_on_area_input_event")

func _scale_asteroid() -> void:
  var _new_scale: float = 0.25 + (_resource_count / _data.resourceRange[1]) * 0.75
  scale = Vector2(_new_scale, _new_scale)

  _area2d.get_child(0).shape.radius = (get_rect().size.length() * 0.75) / 2
