extends Node2D
class_name Team

var current_tile :Vector2i
var members :Array
var slots :Array
var dead := false

@export var team :Array: set = set_team

signal dmg_taken


func _initialization():
	current_tile = pos_to_map(position)
	slots.resize(4)


func set_team(new_team):
	team = new_team
	for i in new_team.size():
		var new_member = load(Game.UNITS[new_team[i]]).instantiate()
		if new_member:
			members.append(new_member)
			slots.append(new_member)
			call_deferred("add_member_into_slots", new_member)
	


func add_member_into_slots(_member:Unit) -> void:
	add_child(_member, true)
	_member.mou_entered.connect(_on_Unit_mou_entered)
	_member.mou_exited.connect(_on_Unit_mou_exited)
	update_team_formation()


func _on_Unit_mou_entered(_unit):
	_unit.self_modulate = Color(0.0, 1.0, 0.0, 1.0)


func _on_Unit_mou_exited(_unit):
	_unit.self_modulate = Color(1.0, 1.0, 1.0, 1.0)


func update_team_formation():
	if members.is_empty(): return
	if slots.is_empty():return
	
#	var members_length = members.size()
	if slots[0] != null:
		slots[0].position = Vector2(8, 8)
	if slots[1] != null:
		slots[1].position = Vector2(24, 8)
	if slots[2] != null:
		slots[2].position = Vector2(24, 24)
	if slots[3] != null:
		slots[3].position = Vector2(8, 24)


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
	if slots.is_empty():return
	
	var _member :Unit
	for slot in slots:
		if slot:
			var unit_pos = slot.global_position
			if _pos.x > unit_pos.x - 8 and _pos.x < unit_pos.x + 8 and _pos.y > unit_pos.y - 8 and _pos.y < unit_pos.y + 8:
				_member = slot
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
			var defend_slot :Vector2i = get_adjacent_slot_from_attack_dir(dir)
			var available := check_adjacent_slot_available(defend_slot)
			var victim :Unit
			if available.size() > 1:
				if randi_range(1, 100) > 50:
					victim = slots[defend_slot.x]
				else:
					victim = slots[defend_slot.y]
			elif available.size() == 1 and available[0] != null:
				victim = available[0]
			else:
				if members.size() > 1:
					if randi_range(1, 100) > 50:
						victim = members[0]
					else:
						victim = members[1]
				elif members.size() == 1:
					victim = members[0]
			
			if victim:
				victim.take_damage(dmg)
				dmg_taken.emit(attacker, victim, dmg)
				
				if victim.dead == true:
					victim.queue_free()
					var i = members.find(victim)
					members.remove_at(i)
					update_team_formation()
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
					update_team_formation()
					if members.is_empty():
						dead = true
	else:
		dead = true


func get_adjacent_slot_from_attack_dir(_direction:Vector2i) -> Vector2i:
	var adjacent_slot := Vector2i.ZERO
	if _direction == Vector2i.RIGHT:
		adjacent_slot = Vector2i(1, 2)
	elif _direction == Vector2i.LEFT:
		adjacent_slot = Vector2i(0, 3)
	elif _direction == Vector2i.UP:
		adjacent_slot = Vector2i(0, 1)
	elif _direction == Vector2i.DOWN:
		adjacent_slot = Vector2i(3, 2)
	
	return adjacent_slot


func check_adjacent_slot_available(_adjacent_slot:Vector2i) -> Array:
	var available :Array
	if slots.is_empty(): return available
	
	if slots[_adjacent_slot.x]:
		available.append(slots[_adjacent_slot.x])
	
	if slots[_adjacent_slot.y]:
		available.append(slots[_adjacent_slot.y])
	
	return available


func _recalculate_slots() -> void:
	pass
