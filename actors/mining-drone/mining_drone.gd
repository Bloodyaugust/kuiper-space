extends Sprite

enum MINING_DRONE_STATES {
  IDLE,
  MINING,
  UNLOADING
}

const CARGO_SPACE: int = 2

export var asteroid_type_target: String
export var health_scene: PackedScene
export var team: int

onready var _beam: Line2D = $"./Beam"
onready var _boid = $"./Boid"
onready var _data: Dictionary = CastleDB.get_drone("mining")
onready var _tree = get_tree()

var _inventory: Dictionary = {
  "metals": 0,
  "volatiles": 0,
  "carbon": 0,
  "silicates": 0
}
var _job_completion: float
var _mothership: Sprite
var _state: int = MINING_DRONE_STATES.IDLE
var _target: Node2D
var _user_specified_target: bool

func target_asteroid(asteroid: Sprite, user_specified: bool) -> void:
  _target = asteroid
  _user_specified_target = user_specified

  if user_specified:
    asteroid_type_target = asteroid._data.type

  _set_state(MINING_DRONE_STATES.MINING)

func _draw():
  pass
  # draw_arc(Vector2(), sqrt(_data.range), 0, PI * 2, 12, Color.red)
  # draw_arc(Vector2(), sqrt(500), 0, PI * 2, 12, Color.blue)
  # draw_arc(Vector2(), sqrt(10000), 0, PI * 2, 12, Color.green)

func _has_cargo() -> bool:
  for _resource_key in _inventory.keys():
    if _inventory[_resource_key] > 0:
      return true

  return false

func _has_cargo_space() -> bool:
  var _cargo: int = 0

  for _resource_key in _inventory.keys():
    _cargo += _inventory[_resource_key]

  return _cargo < CARGO_SPACE

func _on_asteroid_mined_out():
  _target = null
  _user_specified_target = false
  
  if _state != MINING_DRONE_STATES.IDLE:
    _set_state(MINING_DRONE_STATES.IDLE)

func _on_died():
  queue_free()

func _process(delta):
  if _target == null || _target.is_queued_for_deletion():
    _on_asteroid_mined_out()

  match _state:
    MINING_DRONE_STATES.IDLE:
      if _has_cargo_space():
        # TODO: cache this
        var _asteroids = _tree.get_nodes_in_group("asteroids")

        for _asteroid in _asteroids:
          if _asteroid.get_type() == asteroid_type_target:
            _target = _asteroid
            _set_state(MINING_DRONE_STATES.MINING)
            break

      if _target == null && _has_cargo():
        _set_state(MINING_DRONE_STATES.UNLOADING)
    
    MINING_DRONE_STATES.MINING:
      if global_position.distance_squared_to(_target.global_position) <= _data.range:
        _job_completion += _data.workSpeed * delta
        _beam.look_at(_target.global_position)
        _beam.set_point_position(1, Vector2.RIGHT * global_position.distance_to(_target.global_position))

        if _job_completion >= 1:
          var _resource_object = _target.mine()

          _inventory[_resource_object.type] += _resource_object.amount

          if _has_cargo_space():
            _set_state(MINING_DRONE_STATES.MINING)
          else:
            _set_state(MINING_DRONE_STATES.UNLOADING)
      else:
        _beam.set_point_position(1, Vector2())

    MINING_DRONE_STATES.UNLOADING:
      if global_position.distance_squared_to(_mothership.global_position) <= _data.range:
        _job_completion += _data.workSpeed * delta
        _beam.look_at(_mothership.global_position)
        _beam.set_point_position(1, Vector2.RIGHT * global_position.distance_to(_mothership.global_position))
      else:
        _beam.set_point_position(1, Vector2())

      if _job_completion >= 1:
        if _user_specified_target:
          _set_state(MINING_DRONE_STATES.MINING)
        else:
          _set_state(MINING_DRONE_STATES.IDLE)

  update()

func _ready():
  var _new_health_behavior = health_scene.instance()

  _new_health_behavior.name = "health"
  _new_health_behavior.health = _data.health
  _new_health_behavior.connect("died", self, "_on_died")

  add_child(_new_health_behavior)

  _mothership = _tree.get_nodes_in_group("mothership")[0]

func _set_state(new_state: int) -> void:
  _job_completion = 0
  _beam.set_point_position(1, Vector2())

  match _state:
    MINING_DRONE_STATES.UNLOADING:
      var _resources_to_store: Array = []

      for _resource_key in _inventory.keys():
        if _inventory[_resource_key] > 0:
          _resources_to_store.append({
            "type": _resource_key,
            "amount": _inventory[_resource_key]
          })
          _inventory[_resource_key] = 0

      _mothership.store_resources(_resources_to_store)

  match new_state:
    MINING_DRONE_STATES.IDLE:
      _boid.set_target(_mothership.global_position)

    MINING_DRONE_STATES.MINING:
      _boid.set_target(_target.global_position)

    MINING_DRONE_STATES.UNLOADING:
      _boid.set_target(_mothership.global_position)

  _state = new_state
