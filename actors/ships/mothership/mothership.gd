extends Sprite

export var health_scene: PackedScene
export var team: int
export var weapon_scene: PackedScene

onready var _data: Dictionary = CastleDB.get_entry("ships", "mothership")

var _inventory: Dictionary = {
  "metals": 0,
  "volatiles": 0,
  "carbon": 0,
  "silicates": 0
}

func spend_resources(spend_objects: Array) -> void:
  for _spend_data in spend_objects:
    _inventory[_spend_data.type] -= _spend_data.amount
  
  _update_store_resources()

func store_resources(resource_objects: Array) -> void:
  for _resource_data in resource_objects:
    _inventory[_resource_data.type] += _resource_data.amount

  _update_store_resources()

func _on_died():
  queue_free()

func _ready():
  var _new_health_behavior = health_scene.instance()
  var _ship_rect = get_rect()

  _new_health_behavior.name = "health"
  _new_health_behavior.health = _data.health
  _new_health_behavior.connect("died", self, "_on_died")

  add_child(_new_health_behavior)

  for _weapon in _data.weapons:
    var _weapon_data = CastleDB.get_weapon(_weapon.weapon)
    var _new_weapon = weapon_scene.instance()

    _new_weapon.initialize(_weapon_data)

    add_child(_new_weapon)

    _new_weapon.translate(Vector2(_weapon.position[0] - (_ship_rect.size.x / 2), _weapon.position[1] - (_ship_rect.size.y / 2)))

  call_deferred("_update_store_resources")

func _update_store_resources():
  for _key in _inventory.keys():
    Store.set_state(_key, _inventory[_key])
