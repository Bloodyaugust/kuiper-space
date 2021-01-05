extends Sprite

enum COMBAT_DRONE_STATES {
  IDLE,
  MOVING,
  ATTACKING
}

export var health_scene: PackedScene
export var team: int
export var weapon_scene: PackedScene

onready var _boid = $"./Boid"
onready var _data: Dictionary = CastleDB.get_drone("laser")
onready var _tree := get_tree()

var _state: int
var _stationary: bool
var _target: Node2D

func _on_died():
  queue_free()

func _on_target_died():
  _target = null
  _state = COMBAT_DRONE_STATES.IDLE

func _process(delta):
  if _target == null || _target.is_queued_for_deletion():
    _state = COMBAT_DRONE_STATES.IDLE
    _target = null

  match _state:
    COMBAT_DRONE_STATES.IDLE:
      var _possible_targets = _tree.get_nodes_in_group("attackable")

      for _possible_target in _possible_targets:
        if _possible_target.get_node("health").health > 0 && !_possible_target.is_queued_for_deletion():
          _set_target(_possible_target)

      if _target == null && !_stationary:
        _stationary = true
        _boid.set_target(global_position)

    COMBAT_DRONE_STATES.MOVING:
      _boid.set_target(_target.global_position)
      
      if position.distance_squared_to(_target.position) <= _data.range:
        _state = COMBAT_DRONE_STATES.ATTACKING

    COMBAT_DRONE_STATES.ATTACKING:
      if position.distance_squared_to(_target.position) > _data.range:
        _state = COMBAT_DRONE_STATES.MOVING

func _ready():
  var _new_health_behavior = health_scene.instance()

  _new_health_behavior.name = "health"
  _new_health_behavior.health = _data.health
  _new_health_behavior.connect("died", self, "_on_died")

  add_child(_new_health_behavior)

  for _weapon in _data.weapons:
    var _weapon_data = CastleDB.get_weapon(_weapon.weapon)
    var _new_weapon = weapon_scene.instance()

    _new_weapon.initialize(_weapon_data)

    add_child(_new_weapon)

func _set_target(target: Node2D):
  if _target != null:
    _target.get_node("health").disconnect("died", self, "_on_target_died")

  _target = target
  _target.get_node("health").connect("died", self, "_on_target_died")
  _state = COMBAT_DRONE_STATES.MOVING
  _stationary = false
