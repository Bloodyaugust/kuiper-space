extends Node2D

const ORIGIN_OFFSET: Vector2 = Vector2(100, 100)
const POSITION_SCALAR: Vector2 = Vector2(0.195 / 3, 0.333 / 3)

onready var _tree := get_tree()

var _asteroids: Array
var _drones: Array
var _platforms: Array
var _ships: Array

func _draw():
  for _asteroid in _asteroids:
    draw_arc(_asteroid.global_position * POSITION_SCALAR + ORIGIN_OFFSET, 4, 0, PI * 2, 6, Color(_asteroid._data.colorHex), 1, true)
    # draw_texture()

  for _platform in _platforms:
    var _draw_position = _platform.global_position * POSITION_SCALAR + ORIGIN_OFFSET
    draw_rect(Rect2(_draw_position.x - 4, _draw_position.y - 4, 8, 8), Color.blue)

  for _ship in _ships:
    var _draw_position = _ship.global_position * POSITION_SCALAR + ORIGIN_OFFSET
    draw_rect(Rect2(_draw_position.x - 4, _draw_position.y - 4, 8, 6), Color.green)

  for _drone in _drones:
    draw_circle(_drone.global_position * POSITION_SCALAR + ORIGIN_OFFSET, 2 if _drone.team == 1 else 1, Color.greenyellow if _drone.team == 0 else Color.red)

func _process(_delta):
  _asteroids = _tree.get_nodes_in_group("asteroids")
  _drones = _tree.get_nodes_in_group("drones")
  _platforms = _tree.get_nodes_in_group("platforms")
  _ships = _tree.get_nodes_in_group("ships")

  update()
