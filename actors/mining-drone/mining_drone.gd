extends Sprite

enum MINING_DRONE_STATES {
  IDLE,
  MOVING,
  MINING,
  UNLOADING
}

export var asteroid_type_target: String
export var health_scene: PackedScene

onready var _data: Dictionary = CastleDB.get_drone("mining")
onready var _tree = get_tree()

var _inventory: Dictionary = {
  "metals": 0,
  "water": 0,
  "carbon": 0,
  "silicates": 0
}
var _job_completion: float
var _returning_cargo: bool
var _state: int = MINING_DRONE_STATES.IDLE
var _target: Node2D

func _on_asteroid_mined_out():
  _target = null
  _state = MINING_DRONE_STATES.IDLE
  _job_completion = 0

func _on_died():
  queue_free()

func _process(delta):
  match _state:
    MINING_DRONE_STATES.IDLE:
      # TODO: cache this
      var _asteroids = _tree.get_nodes_in_group("asteroids")

      for _asteroid in _asteroids:
        if _asteroid.get_type() == asteroid_type_target:
          _target = _asteroid
          _state = MINING_DRONE_STATES.MOVING
          _returning_cargo = false

          look_at(_target.position)
          break

      if _target == null:
        _target = _tree.get_nodes_in_group("mothership")[0]
        _state = MINING_DRONE_STATES.MOVING
        _returning_cargo = true
        look_at(_target.position)

    MINING_DRONE_STATES.MOVING:
      if _target == null || _target.is_queued_for_deletion():
        _on_asteroid_mined_out()
        continue

      translate((_target.position - position).normalized() * _data.speed * delta)

      if position.distance_squared_to(_target.position) <= 150:
        if _returning_cargo:
          _state = MINING_DRONE_STATES.UNLOADING
        else:
          _state = MINING_DRONE_STATES.MINING
    
    MINING_DRONE_STATES.MINING:
      if _target == null || _target.is_queued_for_deletion():
        _on_asteroid_mined_out()
        continue
      else:
        _job_completion += _data.workSpeed * delta

        if _job_completion >= 1:
          var _resource_object = _target.mine()

          _inventory[_resource_object.type] += _resource_object.amount
          _job_completion = 0
          _state = MINING_DRONE_STATES.MOVING
          # TODO: Cache this
          _target = _tree.get_nodes_in_group("mothership")[0]
          _returning_cargo = true

          look_at(_target.position)

    MINING_DRONE_STATES.UNLOADING:
      _job_completion += _data.workSpeed * delta

      if _job_completion >= 1:
        # TODO: Unload inventory to mothership
        _job_completion = 0
        _returning_cargo = false
        _state = MINING_DRONE_STATES.IDLE

func _ready():
  var _new_health_behavior = health_scene.instance()

  _new_health_behavior.name = "health"
  _new_health_behavior.health = _data.health
  _new_health_behavior.connect("died", self, "_on_died")

  add_child(_new_health_behavior)