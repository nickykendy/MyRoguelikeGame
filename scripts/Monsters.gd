extends Node2D
class_name Monsters


var current_tile :Vector2i
var slots :Array
var map :TileMap
var dead := false

var mon_bat := load("res://scenes/Monsters/bat.tscn")

@export var team :Array: set = set_team


func _ready():
	current_tile = pos_to_map(position)
	map = get_parent().get_node("TileMap")


func set_team(value):
	if !value: return
	
	team = value
	for _v in value:
		var new_monster
		match _v:
			Game.MONSTERS.bat:
				new_monster = mon_bat.instantiate()
		
		if new_monster:
			slots.append(new_monster)
			call_deferred("add_monster_into_slots", new_monster)


func add_monster_into_slots(_monster):
	if !_monster: return
	add_child(_monster)
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


func act(pathfinding, monsters):
	var player_ref = get_parent().get_node("Hero")
	if !player_ref: return
	
	var my_pos = Vector2(current_tile.x, current_tile.y)
	var player_pos = Vector2(player_ref.current_tile.x, player_ref.current_tile.y)
	var path = pathfinding.get_id_path(my_pos, player_pos)
	
	if path:
		assert(path.size() > 1)
		var dest := Vector2i(path[1].x, path[1].y)
		
		if dest == player_ref.current_tile:
			player_ref.receive_damage(1)
		else:
			var blocked = false
			for mon in monsters:
				if mon.current_tile == dest:
					blocked = true
					break
			
			if !blocked:
				current_tile = dest
				position = current_tile * Game.TILESIZE


func pos_to_map(pos:Vector2) -> Vector2i:
	var _x = pos.x / Game.TILESIZE
	var _y = pos.y / Game.TILESIZE
	return Vector2i(_x, _y)


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
