extends Node

signal died

export var health: float

func damage(amount: float) -> void:
  health -= amount

  if health <= 0:
    emit_signal("died")
