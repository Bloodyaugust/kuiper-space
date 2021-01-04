extends Node

var db: Object

func get_asteroid(type: String) -> Dictionary:
  var asteroids: Array = get_entries("asteroids")

  for asteroid in asteroids:
    if asteroid.type == type:
      return asteroid

  return {}

func get_drone(type: String) -> Dictionary:
  var drones: Array = get_entries("drones")

  for drone in drones:
    if drone.type == type:
      return drone

  return {}

func get_entries(sheet_name: String) -> Array:
  for sheet in db.sheets:
    if sheet_name == sheet.name:
      return sheet.lines

  return []

func get_weapon(type: String) -> Dictionary:
  var weapons: Array = get_entries("weapons")

  for weapon in weapons:
    if weapon.type == type:
      return weapon

  return {}

func _load_db() -> Object:
  var file = File.new()
  file.open("res://data/base.json", File.READ)

  var json = file.get_as_text()
  file.close()

  var parsed_json = JSON.parse(json)

  return parsed_json.result

func _init():
  db = _load_db()
