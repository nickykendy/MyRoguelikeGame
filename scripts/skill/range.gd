extends Node


var caster
const arrow := preload("res://scenes/Misc/arrow.tscn")


func cast_skill(_target:Team) -> Ammo:
	caster = get_parent()
	var _arrow := arrow.instantiate()
	_arrow.target = _target
	_arrow.caster = caster
	caster.add_child(_arrow)
	return _arrow
