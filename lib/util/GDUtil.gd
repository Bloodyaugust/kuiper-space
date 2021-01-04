extends Node

static func free_children(node):
  for n in node.get_children():
      n.free()

static func queue_free_children(node):
  for n in node.get_children():
      n.queue_free()

static func rotate_toward(from, to, by) -> float:
  var _angle_distance: float = short_angle_dist(from, to)
  var _new_angle: float

  if abs(_angle_distance) > by:
    if _angle_distance > 0:
      _new_angle = from + by
    else:
      _new_angle = from - by
  else:
    _new_angle = to

  return _new_angle

static func short_angle_dist(from, to) -> float:
  var max_angle: float = PI * 2
  var difference: float = fmod(to - from, max_angle)
  return fmod(2 * difference, max_angle) - difference
