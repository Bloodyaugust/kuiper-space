extends Node2D

enum WEAPON_STATES {
  IDLE,
  RELOAD,
  COOLDOWN,
  FIRING
}

onready var _beam: Line2D = $"./Beam"
onready var _tree := get_tree()

var _clip: int
var _data: Dictionary
var _heat: float
var _state: int
var _target: Node2D
var _time_to_reload: float

func initialize(data: Dictionary) -> void:
  _data = data

  _clip = _data.clip

func _clear_target() -> void:
  if _target != null:
    _target.get_node("health").disconnect("died", self, "_on_target_died")

  _target = null
  _state = WEAPON_STATES.IDLE

func _fire(delta):
  look_at(_target.global_position)

  if _data.beam:
    _beam.set_point_position(1, Vector2.RIGHT * global_position.distance_to(_target.global_position))
    _target.get_node("health").damage(_data.damage * delta)
    _heat += _data.heat * delta

    if _heat >= _data.heatCapacity:
      _state = WEAPON_STATES.COOLDOWN

func _on_target_died():
  _target = null
  _state = WEAPON_STATES.IDLE

func _process(delta):
  _heat = clamp(_heat - _data.cooling * delta, 0, _data.heatCapacity)

  if _state == WEAPON_STATES.FIRING && (_target == null || _target.is_queued_for_deletion()):
    _target = null
    _state = WEAPON_STATES.IDLE

  if _state != WEAPON_STATES.FIRING:
    _beam.set_point_position(1, Vector2())

  match _state:
    WEAPON_STATES.IDLE:
      if _target == null || _target.is_queued_for_deletion():
        var _possible_targets = _tree.get_nodes_in_group("player")

        for _possible_target in _possible_targets:
          if _possible_target.get_node("health").health > 0 && !_possible_target.is_queued_for_deletion() && global_position.distance_squared_to(_possible_target.global_position) <= _data.range:
            _set_target(_possible_target)

      if _target != null && global_position.distance_squared_to(_target.global_position) <= _data.range:
        _state = WEAPON_STATES.FIRING

    WEAPON_STATES.FIRING:
      if global_position.distance_squared_to(_target.global_position) > _data.range:
        _clear_target()
      else:
        _fire(delta)

    WEAPON_STATES.COOLDOWN:
      if _heat == 0:
        _state = WEAPON_STATES.IDLE

func _set_target(new_target: Node2D) -> void:
  if _target != null:
    _target.get_node("health").disconnect("died", self, "_on_target_died")

  _target = new_target
  _target.get_node("health").connect("died", self, "_on_target_died")
