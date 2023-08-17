extends Team
class_name Heroes


var is_hero_turn := true
var fov_range := 6
var picked :Unit = null


func _ready():
	_initialization()


func _input(event):
	if !event.is_pressed():
		return
	
	if is_hero_turn:
		if event.is_action_pressed("left"):
			heroes_act(-1, 0)
		elif event.is_action_pressed("right"):
			heroes_act(1, 0)
		elif event.is_action_pressed("up"):
			heroes_act(0, -1)
		elif event.is_action_pressed("down"):
			heroes_act(0, 1)
		elif event.is_action_pressed("wait"):
			heroes_act(0, 0)
		elif event.is_action_pressed("rotate clockwise"):
			rotate_formation(true)
		elif event.is_action_pressed("rotate anticlockwise"):
			rotate_formation(false)
	
	if event.is_action_pressed("test"):
		print("slots")


func _unhandled_input(event):
	if event.is_action_released("scale up"):
		$Camera2D.zoom += Vector2(0.1, 0.1)
	elif event. is_action_released("scale down"):
		$Camera2D.zoom -= Vector2(0.1, 0.1)
	$Camera2D.zoom = clamp($Camera2D.zoom, Vector2(0.5, 0.5), Vector2(2.0, 2.0))


func heroes_act(dx:int, dy:int) -> void:
	var tile_map :TileMap = get_parent().get_node("TileMap")
	if tile_map == null: return
	var world = get_parent()
	if world == null: return
	
	var _x := current_tile.x + dx
	var _y := current_tile.y + dy
	
	var dest := Vector2i(_x, _y)
	var tile := tile_map.get_cell_atlas_coords(0, dest)
	var is_open_door := false
	var is_wait_range_hit := false
	
	# 尝试移动时，遇敌发起攻击
	if tile == Game.TILE_FLOOR:
		var blocked = false
		if !world.monsters.is_empty():
			for mon in world.monsters:
				var mon_pos = mon.current_tile
				if mon_pos == dest:
					var attackers :Array = []
					var from_pos = dest - current_tile
					var attack_slots := get_adjacent_slot_from_attack_dir(from_pos)
					# 判断英雄们，近战需要在靠近敌人的格子才能发动攻击
					for i in members.size():
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
						tween.tween_callback(mon.receive_damage.bind(attacker, current_tile))
						await get_tree().create_timer(0.2).timeout
					
					if mon.dead:
						world.monsters.erase(mon)
					blocked = true
					break
					
				elif world.map[mon_pos].is_in_view:
					for i in members.size():
						if members[i].has_node("range"):
							var range_node = members[i].get_node("range")
							var _arrow = range_node.cast_skill(mon)
							_arrow.hit_target.connect(_on_arrow_hit_target)
							is_wait_range_hit = true
		
		if !blocked:
			current_tile = dest
	# 尝试打开门
	elif tile == Game.TILE_DOOR:
		tile_map.set_cell(0, dest, 0, Game.TILE_FLOOR)
		is_open_door = true
	
	try_act.emit(dest, is_open_door)
	position = current_tile * Game.TILESIZE
	
	if !is_wait_range_hit:
		acted.emit()
	
	is_hero_turn = false


func _process(_delta):
	var mouse_pos = get_global_mouse_position()
	if Input.is_action_pressed("mouse right"):
		if !picked:
			var _hero = get_member_by_pos(mouse_pos)
			if _hero:
				picked = _hero
				var tween = create_tween()
				tween.tween_property(_hero, "scale", Vector2(1.2, 1.2), 0.1)
		
	elif Input.is_action_just_released("mouse right"):
		if picked:
			var _hero = get_member_by_pos(mouse_pos)
			var tween = create_tween()
			
			if _hero != null and _hero != picked:
				var origin_slot_index = picked.in_slot
				var replace_slot_index = _hero.in_slot
				var origin_slot = get_node("slot" + str(origin_slot_index))
				var replace_slot = get_node("slot" + str(replace_slot_index))
				
				tween.set_parallel(true)
				tween.tween_property(_hero, "global_position", origin_slot.global_position, 0.2)
				_hero.reparent(origin_slot, true)
				_hero.in_slot = origin_slot_index
				
				tween.tween_property(picked, "global_position", replace_slot.global_position, 0.2)
				picked.reparent(replace_slot, true)
				picked.in_slot = replace_slot_index
			
			tween.tween_property(picked, "scale", Vector2(1.0, 1.0), 0.1)
			picked = null


func _on_Unit_mou_entered(_unit):
	super._on_Unit_mou_entered(_unit)


func _on_Unit_mou_exited(_unit):
	super._on_Unit_mou_exited(_unit)


func _on_arrow_hit_target(_arrow:Ammo):
	acted.emit()
