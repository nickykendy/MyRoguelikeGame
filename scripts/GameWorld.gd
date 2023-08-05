extends Node2D

@onready var tile_map := $TileMap
@onready var text_panel := $CanvasLayer/UI/VBoxContainer/TextEdit

var astar :AStarGrid2D
var monsters :Array
var alert_monsters :Array
var heroes :Array
var map :Dictionary = {}
var fov_map :MRPAS
var battle_log :String


func _ready():
	_generate_map()
	
	astar = AStarGrid2D.new()
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.region = Rect2i(0, 0, Game.level_size.x, Game.level_size.y)
	astar.cell_size = Vector2(Game.TILESIZE, Game.TILESIZE)
	astar.update()
	for i in Game.level_size.x:
		for j in Game.level_size.y:
			var _pos = Vector2i(i, j)
			var _tile = tile_map.get_cell_atlas_coords(0, _pos, false)
			if _tile != Game.TILE_FLOOR:
				astar.set_point_solid(_pos, true)
	
	monsters = get_tree().get_nodes_in_group("monsters")
	heroes = get_tree().get_nodes_in_group("heroes")
	var all_characters := monsters.duplicate()
	all_characters.append_array(heroes.duplicate())
	
	if !heroes.is_empty():
		heroes[0].moved.connect(_on_Hero_moved)
		heroes[0].try_move.connect(_on_Hero_try_move)
	
	if !all_characters.is_empty():
		for _char in all_characters:
			_char.dmg_taken.connect(_on_Team_dmg_taken)
	
	_populate_mrpas()
	_compute_field_of_view()
	_update_monsters_visibility()


func _on_Hero_moved() -> void:
	if heroes.is_empty(): return
	
	await get_tree().create_timer(0.2).timeout
	if !monsters.is_empty():
		for mon in monsters:
			mon.act(astar, monsters)
	
	heroes[0].is_hero_turn = true


func _on_Hero_try_move(coord:Vector2i, tileType:Vector2i) -> void:
	if map.is_empty(): return
	if !fov_map: return
	
	if tileType == Game.TILE_DOOR:
		astar.set_point_solid(coord, false)
		map[coord].is_walkable = true
		fov_map.set_transparent(coord, true)
		
	_compute_field_of_view()
	_update_monsters_visibility()


func _on_Team_dmg_taken(attacker:Unit, victim:Unit, dmg:float) -> void:
	if battle_log:
		battle_log = battle_log + "\n" + attacker.name + " attacks " + victim.name + " with " + str(dmg)
	else:
		battle_log = attacker.name + " attacks " + victim.name + " with " + str(dmg)
	
	text_panel.text = battle_log


func _generate_map() -> void:
	for _x in Game.level_size.x:
		for _y in Game.level_size.y:
			var pos = Vector2i(_x, _y)
			map[pos] = Cell.new()
			var _tile = tile_map.get_cell_atlas_coords(0, pos, false)
			if _tile == Game.TILE_DOOR or _tile == Game.TILE_WALL:
				map[pos].is_walkable = false


func _populate_mrpas() -> void:
	if map.is_empty(): return
	
	fov_map = MRPAS.new(Game.level_size)
	for pos in map:
		fov_map.set_transparent(pos, map[pos].is_walkable)


func _compute_field_of_view() -> void:
	if !fov_map: return
	if heroes.is_empty(): return
	
	fov_map.clear_field_of_view()
	fov_map.compute_field_of_view(heroes[0].current_tile, heroes[0].fov_range)
	
	for pos in map:
		if fov_map.is_in_view(pos):
			map[pos].is_in_view = true
			map[pos].is_explored = true
		else:
			map[pos].is_in_view = false
		
		update_fog(pos, map[pos].is_in_view, map[pos].is_explored)


func _update_monsters_visibility() -> void:
	if monsters.is_empty(): return
	
	for mon in monsters:
		var pos = mon.current_tile
		if !map[pos].is_in_view:
			mon.visible = false
		else:
			mon.visible = true


func update_fog(pos:Vector2i, is_in_view:bool, is_explored) -> void:
	if is_in_view:
		tile_map.set_cell(1, pos, 0, Game.TILE_NONE)
	elif is_explored:
		tile_map.set_cell(1, pos, 0, Game.TILE_FOG)
	else:
		tile_map.set_cell(1, pos, 0, Game.TILE_DARK)


func get_tile_center(tile_x:int, tile_y:int) -> Vector2:
	return Vector2((tile_x + 0.5) * Game.TILESIZE, (tile_y + 0.5) * Game.TILESIZE)
