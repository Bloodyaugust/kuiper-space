extends Sprite

var _data: Dictionary
var _resource_count: int
var _rotation_speed: float

func get_type() -> String:
  return _data.type

func initialize(type: String, size: float) -> void:
  _data = CastleDB.get_asteroid(type)

  modulate = Color(_data.colorHex)
  _resource_count = lerp(_data.resourceRange[0], _data.resourceRange[1], size)
  var _new_scale: float = _resource_count / _data.resourceRange[1]
  scale = Vector2(_new_scale, _new_scale)

func mine() -> Dictionary:
  _resource_count -= 1

  var _new_scale: float = _resource_count / _data.resourceRange[1]
  scale = Vector2(_new_scale, _new_scale)

  if _resource_count <= 0:
    queue_free()

  return {
    "type": _data.resource,
    "amount": 1
  }

func _process(delta):
  rotate(_rotation_speed * delta)

func _ready():
  _rotation_speed = rand_range(-0.25, 0.25)
