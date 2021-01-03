extends Node

const ASTEROID_MIN_SIZE: float = 0.25
const ASTEROIDS_PER_SECTOR: int = 15

export var asteroid_scene: PackedScene

onready var _asteroids_root: Node = $"/root/game/asteroids"

func generate_sector() -> void:
  var _asteroids = CastleDB.get_entries("asteroids")
  var _asteroid_types = []

  for _asteroid in _asteroids:
    _asteroid_types.append(_asteroid.type)

  for _i in range(ASTEROIDS_PER_SECTOR):
    var _new_asteroid = asteroid_scene.instance()

    _new_asteroid.initialize(_asteroid_types[randi() % _asteroid_types.size()], rand_range(ASTEROID_MIN_SIZE, 1))
    _asteroids_root.add_child(_new_asteroid)

    _new_asteroid.position = Vector2(rand_range(-400, 400), rand_range(-200, 200))

func _ready():
  call_deferred("generate_sector")
