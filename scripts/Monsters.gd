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
			var attack_slots := get_adjacent_slot_from_attack_dir(from_pos)
			
			for i in members.size():
				if members[i] != null:
					if !members[i].is_melee:
						attackers.append(members[i])
					else:
						for _slot in attack_slots:
							if members[i].in_slot == _slot:
								attackers.append(members[i])
				
			for attacker in attackers:
				var tween = create_tween()
				tween.tween_property(attacker, "scale", Vector2(1.2, 1.2), 0.1)
				tween.tween_property(attacker, "scale", Vector2(1.0, 1.0), 0.1)
				tween.tween_callback(player_ref.receive_damage.bind(attacker, current_tile))
				await get_tree().create_timer(0.2).timeout
			
		else:
			var blocked = false
			for mon in monsters:
				if mon.current_tile == dest:
					blocked = true
					break
			
			if !blocked:
				current_tile = dest
				
		try_act.emit(dest)
		position = current_tile * Game.TILESIZE
		acted.emit()
