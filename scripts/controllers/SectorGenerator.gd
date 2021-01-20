extends Node

const ASTEROID_MIN_SIZE: float = 0.25
const ASTEROIDS_PER_SECTOR: int = 5

export var asteroid_scene: PackedScene

onready var _asteroids_root: Node = $"/root/game/asteroids"
onready var _weighted_table := preload("res://lib/chance/WeightedTable.gd")

var _asteroid_table: Reference

func generate_sector() -> void:
  for _i in range(ASTEROIDS_PER_SECTOR):
    var _new_asteroid = asteroid_scene.instance()
    var _asteroid_type: String = _asteroid_table.pick().type

    _new_asteroid.initialize(_asteroid_type, rand_range(ASTEROID_MIN_SIZE, 1))
    _asteroids_root.add_child(_new_asteroid)

    _new_asteroid.position = Vector2(rand_range(-400, 400), rand_range(-200, 200))

func _ready():
  _asteroid_table = _weighted_table.new()

  _asteroid_table.initialize_table(CastleDB.get_entries("asteroids"))

  call_deferred("generate_sector")
