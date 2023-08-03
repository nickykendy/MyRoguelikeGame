extends Node2D
class_name Team

var current_tile :Vector2i
var slots :Array
var dead := false

@export var team :Array: set = set_team


func _initialization():
	current_tile = pos_to_map(position)


func set_team(new_team):
	team = new_team
	for _member in new_team:
		var new_member = load(Game.UNITS[_member]).instantiate()
		
		if new_member:
			slots.append(new_member)
			call_deferred("add_member_into_slots", new_member)


func add_member_into_slots(_member):
	add_child(_member)
	update_team_formation()


func update_team_formation():
	if slots.is_empty(): return
	
	var length = slots.size()
	match length:
		1:
			slots[0].position = Vector2(16, 16)
		2:
			slots[0].position = Vector2(8, 16)
			slots[1].position = Vector2(24, 16)
		3:
			slots[0].position = Vector2(16, 8)
			slots[1].position = Vector2(8, 24)
			slots[2].position = Vector2(24, 24)
		4:
			slots[0].position = Vector2(8, 8)
			slots[1].position = Vector2(24, 8)
			slots[2].position = Vector2(8, 24)
			slots[3].position = Vector2(24, 24)


func pos_to_map(_pos:Vector2) -> Vector2i:
	var _x = _pos.x / Game.TILESIZE
	var _y = _pos.y / Game.TILESIZE
	return Vector2i(_x, _y)


func get_tile_center(tile_x:int, tile_y:int) -> Vector2:
	return Vector2((tile_x + 0.5) * Game.TILESIZE, (tile_y + 0.5) * Game.TILESIZE)


func receive_damage(dmg:int) -> void:
	var length := slots.size()
	if length > 0:
		var i := randi_range(0, length - 1)
		slots[i].take_damage(dmg)
		if slots[i].dead == true:
			slots[i].queue_free()
			slots.remove_at(i)
			update_team_formation()
			if slots.is_empty():
				dead = true
	else:
		dead = true
