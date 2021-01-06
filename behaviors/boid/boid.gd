extends Node

const BOID_ENEMY_CHASE_SCALAR: float = 3.0
const BOID_ENEMY_REPEL_SCALAR: float = 5.0
const BOID_FRIENDLY_REPEL_SCALAR: float = 0.25
const BOID_PLATFORM_REPEL_SCALAR: float = 10.0
const BOID_TARGET_TIME_TO_MAX_SCALAR: float = 7.5
const BOID_TARGET_MAX_SCALAR: float = 2.0
const BOID_MAX_CHASE_DISTANCE: float = 15000.0
const BOID_MAX_COHESION_DISTANCE: float = 10000.0
const BOID_MAX_ENEMY_REPEL_DISTANCE: float = 8000.0
const BOID_MAX_FRIENDLY_REPEL_DISTANCE: float = 500.0
const BOID_MAX_PLATFORM_REPEL_DISTANCE: float = 4000.0

export var chase_enemies: bool

onready var _parent: Node2D = get_parent()
onready var _tree := get_tree()

var _rotation_vector_target: Vector2
var _target: Vector2
var _target_soft: bool
var _time_following_target: float

func set_target(new_target: Vector2, soft: bool = false) -> void:
  _target = new_target
  _target_soft = soft
  _time_following_target = 0

func _process(delta):
  var _drones = _tree.get_nodes_in_group("drones")
  var _platforms = _tree.get_nodes_in_group("platforms")
  var _flock_chase_vector = Vector2()
  var _flock_rotation_vector = Vector2()
  var _flock_enemy_repel_vector = Vector2()
  var _flock_friendly_repel_vector = Vector2()
  var _flock_platform_repel_vector = Vector2()

  if !_target_soft:
    _time_following_target += delta

  for _drone in _drones:
    if _drone != _parent:
      if _drone.team == _parent.team:
        if _drone.global_position.distance_squared_to(_parent.global_position) < BOID_MAX_COHESION_DISTANCE:
          _flock_rotation_vector += Vector2(cos(_drone.rotation), sin(_drone.rotation))
        if _drone.global_position.distance_squared_to(_parent.global_position) < BOID_MAX_FRIENDLY_REPEL_DISTANCE:
          _flock_friendly_repel_vector += (_parent.global_position - _drone.global_position).normalized()
      else:
        if chase_enemies:
          if _drone.global_position.distance_squared_to(_parent.global_position) < BOID_MAX_CHASE_DISTANCE:
            _flock_chase_vector += (_drone.global_position - _parent.global_position).normalized()
        else:
          if _drone.global_position.distance_squared_to(_parent.global_position) < BOID_MAX_ENEMY_REPEL_DISTANCE:
            _flock_enemy_repel_vector += (_parent.global_position - _drone.global_position).normalized()
  _flock_rotation_vector = _flock_rotation_vector.normalized()

  var _boid_target_scalar = lerp(1, BOID_TARGET_MAX_SCALAR, _time_following_target / BOID_TARGET_TIME_TO_MAX_SCALAR) if _flock_chase_vector.length_squared() < 0.1 && _flock_enemy_repel_vector.length_squared() < 0.1 else Vector2()
  _rotation_vector_target = (_target - _parent.global_position).normalized() * _boid_target_scalar

  for _platform in _platforms:
    if _platform.global_position.distance_squared_to(_parent.global_position) < BOID_MAX_PLATFORM_REPEL_DISTANCE:
      _flock_platform_repel_vector += (_parent.global_position - _platform.global_position).normalized()

  var _total_vector: Vector2 = (_flock_rotation_vector + _rotation_vector_target + (_flock_friendly_repel_vector * BOID_FRIENDLY_REPEL_SCALAR) + (_flock_enemy_repel_vector * BOID_ENEMY_REPEL_SCALAR) + (_flock_chase_vector * BOID_ENEMY_CHASE_SCALAR) + (_flock_platform_repel_vector * BOID_PLATFORM_REPEL_SCALAR)).normalized()
  var _rotation: float = _total_vector.angle()

  _parent.rotation = GDUtil.rotate_toward(_parent.rotation, _rotation, (_parent._data.speed / 50) * delta)
  _parent.translate(Vector2.RIGHT.rotated(_parent.rotation) * _parent._data.speed * delta)
