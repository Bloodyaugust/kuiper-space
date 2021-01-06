extends Node2D

enum WEAPON_STATES {
  IDLE,
  RELOAD,
  COOLDOWN,
  FIRING
}

onready var _parent: Node2D = get_parent()
onready var _tree := get_tree()

var _beam: Line2D
var _clip: int
var _data: Dictionary
var _delay: float
var _heat: float
var _state: int
var _sustain: float
var _target: Node2D
var _time_to_reload: float

func initialize(data: Dictionary) -> void:
  _beam = $"./Beam"

  _data = data

  _clip = _data.clip

  if _data.beam:
    _beam.width = _data.size

func _clear_target() -> void:
  if _target != null:
    _target.get_node("health").disconnect("died", self, "_on_target_died")

  _target = null
  _state = WEAPON_STATES.IDLE
  _beam.set_point_position(1, Vector2())

func _fire(delta):
  look_at(_target.global_position)

  if _clip == 0:
    _time_to_reload = _data.reload
    _state = WEAPON_STATES.RELOAD
    _beam.set_point_position(1, Vector2())
    return

  if _delay > 0:
    _delay -= delta
    return
  
  if _data.beam:
    if _sustain > 0:
      _beam.set_point_position(1, Vector2.RIGHT * global_position.distance_to(_target.global_position))
      _target.get_node("health").damage(_data.damage * delta)
      _heat += _data.heat * delta
      _sustain -= delta

      if _sustain <= 0:
        _delay = _data.delay
        _clip -= 1
        _beam.set_point_position(1, Vector2())

      if _heat >= _data.heatCapacity:
        _state = WEAPON_STATES.COOLDOWN
        _beam.set_point_position(1, Vector2())
        _delay = 0
        _sustain = 0

    else:
      _sustain = _data.sustain

func _on_target_died():
  _clear_target()

func _process(delta):
  _heat = clamp(_heat - _data.cooling * delta, 0, _data.heatCapacity)

  if _state == WEAPON_STATES.FIRING && (_target == null || _target.is_queued_for_deletion()):
    _target = null
    _state = WEAPON_STATES.IDLE

  match _state:
    WEAPON_STATES.IDLE:
      if _target == null || _target.is_queued_for_deletion():
        var _possible_targets = _tree.get_nodes_in_group("attackable")

        for _possible_target in _possible_targets:
          if _possible_target.team != _parent.team && _possible_target.get_node("health").health > 0 && !_possible_target.is_queued_for_deletion() && global_position.distance_squared_to(_possible_target.global_position) <= _data.range:
            _set_target(_possible_target)

    WEAPON_STATES.FIRING:
      if global_position.distance_squared_to(_target.global_position) > _data.range:
        _clear_target()
      else:
        _fire(delta)

    WEAPON_STATES.COOLDOWN:
      if _heat == 0:
        _clear_target()
        
    WEAPON_STATES.RELOAD:
      _time_to_reload -= delta

      if _time_to_reload <= 0:
        _clip = _data.clip
        _clear_target()
        
func _set_target(new_target: Node2D) -> void:
  if _target != null:
    _target.get_node("health").disconnect("died", self, "_on_target_died")

  _target = new_target
  _target.get_node("health").connect("died", self, "_on_target_died")
  _state = WEAPON_STATES.FIRING
