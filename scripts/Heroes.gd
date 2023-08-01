extends Node2D
class_name Heroes


var current_tile :Vector2i
var slots :Array
var tile_map :TileMap
var world :Node2D
var fov_range := 6
var dead := false

var hero_knight := load("res://scenes/Heroes/hero_knight.tscn")
var hero_mage := load("res://scenes/Heroes/hero_mage.tscn")

@export var team :Array: set = set_team


signal moved
signal try_move


func _ready():
	current_tile = pos_to_map(position)
	tile_map = get_parent().get_node("TileMap")
	world = get_parent()
	await get_tree().create_timer(0.2).timeout
#	update_visual()


func set_team(value):
	if !value: return
	
	team = value
	for _v in value:
		var new_hero
		match _v:
			Game.HEROES.knight:
				new_hero = hero_knight.instantiate()
			Game.HEROES.mage:
				new_hero = hero_mage.instantiate()
		
		if new_hero:
			slots.append(new_hero)
			call_deferred("add_hero_into_slots", new_hero)


func add_hero_into_slots(_hero):
	if !_hero: return
	add_child(_hero)
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


func _input(event):
	if !event.is_pressed():
		return
		
	if event.is_action("left"):
		heroes_move(-1, 0)
	elif event.is_action("right"):
		heroes_move(1, 0)
	elif event.is_action("up"):
		heroes_move(0, -1)
	elif event.is_action("down"):
		heroes_move(0, 1)


func heroes_move(dx:int, dy:int) -> void:
	if tile_map == null: return
	if world == null: return
	
	var _x = current_tile.x + dx
	var _y = current_tile.y + dy
	
	var dest := Vector2i(_x, _y)
	
	var tile := tile_map.get_cell_atlas_coords(0, dest)
	
	# 尝试移动到地板
	if tile == Game.TILE_FLOOR:
		var blocked = false
		if !world.monsters.is_empty():
			for mon in world.monsters:
				if mon.current_tile.x == _x && mon.current_tile.y == _y:
					mon.receive_damage(2)
					if mon.dead:
						world.monsters.erase(mon)
					blocked = true
					break
				
		if !blocked:
			current_tile = dest
	# 尝试打开门
	elif tile == Game.TILE_DOOR:
		tile_map.set_cell(0, dest, 0, Game.TILE_FLOOR)
	
	emit_signal("try_move", dest, tile)
	position = current_tile * Game.TILESIZE
	emit_signal("moved")
#	update_visual()


func receive_damage(dmg:int) -> void:
	pass


func pos_to_map(pos:Vector2) -> Vector2i:
	var _x = pos.x / Game.TILESIZE
	var _y = pos.y / Game.TILESIZE
	return Vector2i(_x, _y)


#func update_visual() -> void:
#	var space_state = get_world_2d().direct_space_state
#	for i in Game.level_size.x:
#		for j in Game.level_size.y:
#			map.set_cell(1, Vector2i(i, j), 0, Game.TILE_DARK)
##			var x_dir = 1 if i < current_tile.x else -1
##			var y_dir = 1 if j < current_tile.y else -1
#			var hero_center = get_tile_center(current_tile.x, current_tile.y)
#			var vision_center = get_tile_center(i, j)
#			var query = PhysicsRayQueryParameters2D.create(hero_center, vision_center)
#			var result = space_state.intersect_ray(query)
#			var vision_length = (vision_center - hero_center).length()
#			if !result.is_empty():
#				var collider_length = (result.position - hero_center).length()
#				if (collider_length <= 128 and vision_length <= 128) or (collider_length <= 128 and vision_length > 128):
#					map.set_cell(1, Vector2i(i, j), 0, Game.TILE_NONE)
#			else:
#				if vision_length <= 128:
#					map.set_cell(1, Vector2i(i, j), 0, Game.TILE_NONE)


func get_tile_center(tile_x:int, tile_y:int) -> Vector2:
	return Vector2((tile_x + 0.5) * Game.TILESIZE, (tile_y + 0.5) * Game.TILESIZE)
