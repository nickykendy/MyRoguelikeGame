extends Sprite2D
class_name Ammo

var target :Team
var caster :Unit
var dir
var spd := 1.0


func _ready():
	if target == null: return
	if caster == null: return
	dir = (target.global_position - caster.global_position).normalized()
	rotate(dir.angle())

func _process(_delta):
	if target == null: return
	
	global_position += dir * spd
	
	if global_position.distance_to(target.global_position) <= 8:
		queue_free()
