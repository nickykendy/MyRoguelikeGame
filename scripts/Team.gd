extends Node2D
class_name Team

var current_tile :Vector2i
var members :Array
var dead := false

@export var team :Array: set = set_team

const SLOT_POS := [Vector2(8, 8), Vector2(24, 8), Vector2(24, 24), Vector2(8, 24)]

signal dmg_taken


func _initialization():
	current_tile = pos_to_map(position)


func set_team(new_team):
	team = new_team
	var length = new_team.size()
	for i in length:
		var new_member = load(Game.UNITS[new_team[i]]).instantiate()
		if new_member:
			members.append(new_member)
			call_deferred("add_member_into_slots", new_member, i, length)
	


func add_member_into_slots(_member:Unit, _index:int, _num:int) -> void:
	match _num:
		1:
			_member.in_slot = 8
			get_node("slot8").add_child(_member, true)
		2:
			_member.in_slot = _index + _index + 4
			var slot_name = "slot" + str(_member.in_slot)
			get_node(slot_name).add_child(_member, true)
		_:
			_member.in_slot = _index
			var slot_name = "slot" + str(_member.in_slot)
			get_node(slot_name).add_child(_member, true)
	
	_member.mou_entered.connect(_on_Unit_mou_entered)
	_member.mou_exited.connect(_on_Unit_mou_exited)


func _on_Unit_mou_entered(_unit):
	_unit.self_modulate = Color(0.0, 1.0, 0.0, 1.0)


func _on_Unit_mou_exited(_unit):
	_unit.self_modulate = Color(1.0, 1.0, 1.0, 1.0)


func pos_to_map(_pos:Vector2) -> Vector2i:
	var _x = _pos.x / Game.TILESIZE
	var _y = _pos.y / Game.TILESIZE
	return Vector2i(_x, _y)


func map_to_pos(_map:Vector2i) -> Vector2:
	var _x = _map.x * Game.TILESIZE
	var _y = _map.y * Game.TILESIZE
	return Vector2(_x, _y)


func get_member_by_pos(_pos:Vector2) -> Unit:
	if members.is_empty(): return
	
	var _member :Unit = null
	for _m in members:
		var unit_pos = _m.global_position
		if _pos.x > unit_pos.x - 8 and _pos.x < unit_pos.x + 8 and _pos.y > unit_pos.y - 8 and _pos.y < unit_pos.y + 8:
			_member = _m
			break
	
	return _member


func get_tile_center(tile_x:int, tile_y:int) -> Vector2:
	return Vector2((tile_x + 0.5) * Game.TILESIZE, (tile_y + 0.5) * Game.TILESIZE)


func receive_damage(attacker:Unit, from:Vector2i) -> void:
	var dmg = attacker.attack
	var length := members.size()
	
	if length > 0:
		if attacker.is_melee:
			var dir = from - current_tile
			var defend_slots := get_adjacent_slot_from_attack_dir(dir)
			var available := check_adjacent_slot_available(defend_slots)
			var victim :Unit
			
			if !available.is_empty():
				var i = randi_range(0, available.size() - 1)
				victim = available[i]
			else:
				if !members.is_empty():
					var i = randi_range(0, members.size() - 1)
					victim = members[i]
			
			if victim:
				victim.take_damage(dmg)
				dmg_taken.emit(attacker, victim, dmg)
				
				if victim.dead == true:
					var i = members.find(victim)
					victim.queue_free()
					if i != -1:
						members.remove_at(i)
					if members.is_empty():
						dead = true
		else:
			var i := randi_range(0, length - 1)
			if members[i]:
				members[i].take_damage(dmg)
				dmg_taken.emit(attacker, members[i], dmg)
				
				if members[i].dead == true:
					members[i].queue_free()
					members.remove_at(i)
					if members.is_empty():
						dead = true
	else:
		dead = true


func get_adjacent_slot_from_attack_dir(_direction:Vector2i) -> Array:
	var adjacent_slots :Array
	if _direction == Vector2i.RIGHT:
		adjacent_slots = [1, 2, 4, 5, 6]
	elif _direction == Vector2i.LEFT:
		adjacent_slots = [0, 3, 4, 7, 6]
	elif _direction == Vector2i.UP:
		adjacent_slots = [0, 1, 4, 5, 7]
	elif _direction == Vector2i.DOWN:
		adjacent_slots = [3, 2, 5, 6, 7]
	
	return adjacent_slots


func check_adjacent_slot_available(_adjacent_slots:Array) -> Array:
	var available :Array = []
	for _slot in _adjacent_slots:
		var _member = get_member_by_slot_index(_slot)
		if _member != null:
			available.append(_member)
	
	return available


func get_member_by_slot_index(_index:int) -> Unit:
	if members.is_empty(): return
	
	var member :Unit = null
	for _m in members:
		if _m.in_slot == _index:
			member = _m
			break
	
	return member 
