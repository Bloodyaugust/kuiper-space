extends Node

const BOID_MAX_COHESION_DISTANCE = 10000
const BOID_MAX_REPEL_DISTANCE = 500
const BOID_REPEL_SCALAR = 0.25

onready var _parent: Node2D = get_parent()
onready var _tree := get_tree()

var _rotation_vector_target: Vector2
var _target: Vector2

func set_target(new_target: Vector2) -> void:
  _target = new_target

func _process(delta):
  var _drones = _tree.get_nodes_in_group("drones")
  var _flock_rotation_vector = Vector2()
  var _flock_repel_vector = Vector2()

  for _drone in _drones:
    if _drone.global_position.distance_squared_to(_parent.global_position) < BOID_MAX_COHESION_DISTANCE:
      _flock_rotation_vector += Vector2(cos(_drone.rotation), sin(_drone.rotation))
    if _drone.global_position.distance_squared_to(_parent.global_position) < BOID_MAX_REPEL_DISTANCE:
      _flock_repel_vector += (_parent.global_position - _drone.global_position).normalized()
  _flock_rotation_vector = _flock_rotation_vector.normalized()

  var _rotation_vector_target = (_target - _parent.global_position).normalized()

  var _total_vector: Vector2 = (_flock_rotation_vector + _rotation_vector_target + (_flock_repel_vector * BOID_REPEL_SCALAR)).normalized()
  var _rotation: float = _total_vector.angle()

  _parent.rotation = GDUtil.rotate_toward(_parent.rotation, _rotation, (_parent._data.speed / 50) * delta)
  _parent.translate(Vector2.RIGHT.rotated(_parent.rotation) * _parent._data.speed * delta)
