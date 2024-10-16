extends Sprite2D
class_name Ammo

var target :Team
var caster :Unit
var dir
var spd := 5.0

signal hit_target


func _ready():
	if target == null: return
	if caster == null: return
	dir = (target.global_position - caster.global_position).normalized()
	rotate(dir.angle())
	await get_tree().create_timer(2.0).timeout
	_destroy()


func _process(_delta):
	if target == null: return
	global_position += dir * spd
	if global_position.distance_to(target.global_position) <= 16:
		_destroy()


func _destroy() -> void:
	hit_target.emit(self)
	queue_free()
