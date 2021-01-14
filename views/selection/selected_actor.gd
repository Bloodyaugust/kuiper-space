extends Control

export var alive_color: Color
export var dead_color: Color

onready var health_bar: ColorRect = $"./HealthBar"

var selectable: Object

func _process(delta):
  if selectable != null && !selectable.is_queued_for_deletion():
    _set_health(selectable.health.health / selectable._data.health)

func _set_health(health: float) -> void:
  health_bar.color = alive_color.linear_interpolate(dead_color, 1 - health)
  health_bar.rect_size = Vector2(health * 40, 6)
