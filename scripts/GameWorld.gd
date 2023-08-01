extends Node2D

@onready var tile_map := $TileMap

var astar :AStarGrid2D
var monsters :Array
var heroes :Array
var grid :Dictionary = {}


func _ready():
	astar = AStarGrid2D.new()
	astar.diagonal_mode = 1
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
	
	if heroes.is_empty(): return
	heroes[0].moved.connect(_on_Hero_moved)
	heroes[0].try_move.connect(_on_Hero_try_move)


func _on_Hero_moved() -> void:
	for mon in monsters:
		mon.act(astar, monsters)


func _on_Hero_try_move(coord:Vector2, tileType:Vector2i) -> void:
	if tileType == Game.TILE_DOOR:
		astar.set_point_solid(coord, false)
