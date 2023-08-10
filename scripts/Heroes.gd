extends Team
class_name Heroes


var is_hero_turn := true
var fov_range := 6
var picked :Unit = null

signal moved
signal try_move


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
			_rotate_formation(true)
		elif event.is_action_pressed("rotate anticlockwise"):
			_rotate_formation(false)
	
	if event.is_action_pressed("test"):
		print("slots")


func _rotate_formation(is_clockwise:bool) -> void:
	if members.is_empty(): return
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	var length = members.size()
	for i in length:
		var next := 0
		var new_slot_name := ""
		var member_slot = members[i].in_slot
		if is_clockwise:
			if length >= 3:
				next = (member_slot + 1) % 4
			elif length == 2:
				if member_slot % 2 == 0:
					next = member_slot + 1
				else:
					if member_slot == 7:
						next = 4
					else:
						next = 6
			else:
				next = 8
		else:
			if length >= 3:
				if member_slot == 0:
					next = 3
				else:
					next = member_slot - 1
			elif length == 2:
				if member_slot % 2 == 0:
					if member_slot == 4:
						next = 7
					else:
						next = 5
				else:
					next = member_slot - 1
			else:
				next = 8
		
		new_slot_name = "slot" + str(next)
		var new_slot = get_node(new_slot_name)
		tween.tween_property(members[i], "global_position", new_slot.global_position, 0.2)
		members[i].reparent(new_slot, true)
		members[i].in_slot = next
	


func _unhandled_input(event):
	if event.is_action_released("scale up"):
		$Camera2D.zoom += Vector2(0.1, 0.1)
	elif event. is_action_released("scale down"):
		$Camera2D.zoom -= Vector2(0.1, 0.1)
	$Camera2D.zoom = clamp($Camera2D.zoom, Vector2(0.5, 0.5), Vector2(2.0, 2.0))


func heroes_act(dx:int, dy:int) -> void:
	var tile_map :TileMap = get_parent().get_node("TileMap")
	if tile_map == null: return
	var world :Node2D = get_parent()
	if world == null: return
	
	var _x := current_tile.x + dx
	var _y := current_tile.y + dy
	
	var dest := Vector2i(_x, _y)
	
	var tile := tile_map.get_cell_atlas_coords(0, dest)
	
	# 尝试移动到地板
	if tile == Game.TILE_FLOOR:
		var blocked = false
		if !world.monsters.is_empty():
			for mon in world.monsters:
				if mon.current_tile == dest:
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
						mon.receive_damage(attacker, current_tile)
					
					if mon.dead:
						world.monsters.erase(mon)
					blocked = true
					break
		
		if !blocked:
			current_tile = dest
	# 尝试打开门
	elif tile == Game.TILE_DOOR:
		tile_map.set_cell(0, dest, 0, Game.TILE_FLOOR)
	
	try_move.emit(dest, tile)
	position = current_tile * Game.TILESIZE
	moved.emit()
	
	is_hero_turn = false


func _process(_delta):
	if Input.is_action_pressed("mouse left"):
		if !picked:
			var mouse_pos = get_global_mouse_position()
			var _hero = get_member_by_pos(mouse_pos)
			if _hero:
				picked = _hero
				_hero.global_position = mouse_pos
		
	elif Input.is_action_just_released("mouse left"):
		if picked:
			var mouse_pos = get_global_mouse_position()
			var _hero = get_member_by_pos(mouse_pos)
			if _hero != null and _hero != picked:
				var tween = create_tween()
				tween.set_parallel(true)
				
				var origin_slot_index = picked.in_slot
				var replace_slot_index = _hero.in_slot
				var origin_slot = get_node("slot" + str(origin_slot_index))
				var replace_slot = get_node("slot" + str(replace_slot_index))
				
				tween.tween_property(_hero, "global_position", origin_slot.global_position, 0.2)
				_hero.reparent(origin_slot, true)
				_hero.in_slot = origin_slot_index
				
				tween.tween_property(picked, "global_position", replace_slot.global_position, 0.2)
				picked.reparent(replace_slot, true)
				picked.in_slot = replace_slot_index
				
		picked = null


func _on_Unit_mou_entered(_unit):
	super._on_Unit_mou_entered(_unit)


func _on_Unit_mou_exited(_unit):
	super._on_Unit_mou_exited(_unit)
