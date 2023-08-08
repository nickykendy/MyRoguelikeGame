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
		print(slots)


func _rotate_formation(is_clockwise:bool) -> void:
	if members.is_empty(): return
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	var length = members.size()
	for i in length:
		var next := 0
		var new_slot_name := ""
		if is_clockwise:
			next = (members[i].in_slot + 1) % 4
		else:
			next = (members[i].in_slot - 1) % 4
		
		match length:
			# 成员数量为3或者4时
			_:
				new_slot_name = "slot" + str(next)
			# 成员数量为2时
			2:
				new_slot_name = "slot" + str(next + 5)
			# 成员数量为1时
			1:
				new_slot_name = "slot" + str(next + 8)
		
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
	if slots.is_empty(): return
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
					var attack_slot := get_adjacent_slot_from_attack_dir(from_pos)
					
					for i in slots.size():
						if slots[i] != null:
							if !slots[i].is_melee:
								attackers.append(slots[i])
							elif slots[i].is_melee and (i == attack_slot.x or i == attack_slot.y):
								attackers.append(slots[i])
						
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
	if slots.is_empty(): return
	
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
			if _hero != picked:
				var origin_index = slots.find(picked)
				var switch_index = slots.find(_hero)
				var temp_slots = slots.duplicate()
				temp_slots[origin_index] = slots[switch_index]
				temp_slots[switch_index] = slots[origin_index]
				slots = temp_slots.duplicate()
				temp_slots.clear()
		picked = null
		update_team_formation()


func _on_Unit_mou_entered(_unit):
	super._on_Unit_mou_entered(_unit)


func _on_Unit_mou_exited(_unit):
	super._on_Unit_mou_exited(_unit)
