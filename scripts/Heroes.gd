extends Team
class_name Heroes


var is_hero_turn := true
var fov_range := 6

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
				if mon.current_tile.x == _x && mon.current_tile.y == _y:
					for hero in slots:
						var dmg = hero.attack
						mon.receive_damage(dmg)
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
