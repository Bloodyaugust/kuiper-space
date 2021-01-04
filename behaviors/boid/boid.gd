extends Node

onready var _parent: Node2D = get_parent()

var _rotation_vector_target: Vector2
var _target: Vector2

func set_target(new_target: Vector2) -> void:
  _target = new_target

func _process(delta):
  var _rotation_vector_target = (_target - _parent.global_position).normalized()
  var _rotation: float = _rotation_vector_target.angle()

  _parent.rotation = GDUtil.rotate_toward(_parent.rotation, _rotation, (PI / 2) * delta)
  _parent.translate(Vector2.RIGHT.rotated(_parent.rotation) * _parent._data.speed * delta)
