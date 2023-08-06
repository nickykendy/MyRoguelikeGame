extends Team
class_name Monsters


func _ready():
	_initialization()


func act(pathfinding, monsters):
	var heroes = get_tree().get_nodes_in_group("heroes")
	if heroes.is_empty(): return
	var player_ref = heroes[0]
	
	var my_pos = Vector2(current_tile.x, current_tile.y)
	var player_pos = Vector2(player_ref.current_tile.x, player_ref.current_tile.y)
	var path = pathfinding.get_id_path(my_pos, player_pos)
	
	if path:
		assert(path.size() > 1)
		var dest := Vector2i(path[1].x, path[1].y)
		
		if dest == player_ref.current_tile:
			var attackers :Array = []
			var from_pos = dest - current_tile
			var attack_slot := get_adjacent_slot_from_attack_dir(from_pos)
			
			for i in slots.size():
				if slots[i] != null:
					if !slots[i].is_melee:
						attackers.append(slots[i])
					elif slots[i].is_melee and (i == attack_slot.x or i == attack_slot.y):
						attackers.append(slots[i])
				
			for attacker in attackers:
				player_ref.receive_damage(attacker, current_tile)
			
		else:
			var blocked = false
			for mon in monsters:
				if mon.current_tile == dest:
					blocked = true
					break
			
			if !blocked:
				current_tile = dest
				position = current_tile * Game.TILESIZE
