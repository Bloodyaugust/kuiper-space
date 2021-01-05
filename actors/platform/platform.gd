extends Sprite

enum PLATFORM_STATES {
  IDLE,
  MOVING
}

const PLATFORM_ARRIVED_DISTANCE = 50

export var health_scene: PackedScene
export var team: int
export var weapon_scene: PackedScene

onready var _data: Dictionary = CastleDB.get_platform("laser_defense")
onready var _tree := get_tree()

var _state: int
var _target: Vector2

func set_target(new_target: Vector2) -> void:
  _target = new_target
  _state = PLATFORM_STATES.MOVING

func _draw():
  # pass
  draw_arc(Vector2(), sqrt(CastleDB.get_weapon(_data.weapons[0].weapon).range), 0, PI * 2, 12, Color.red)
  # draw_arc(Vector2(), sqrt(500), 0, PI * 2, 12, Color.blue)
  # draw_arc(Vector2(), sqrt(10000), 0, PI * 2, 12, Color.green)

func _on_died():
  queue_free()

func _process(delta):
  match _state:
    PLATFORM_STATES.MOVING:
      translate((_target - global_position).normalized() * _data.speed * delta)
      
      if position.distance_squared_to(_target) <= PLATFORM_ARRIVED_DISTANCE:
        _state = PLATFORM_STATES.IDLE

  update()

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
