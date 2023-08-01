extends Node


const TILESIZE := 32
const TILE_NONE := Vector2i(0, 0)
const TILE_FLOOR := Vector2i(1, 0)
const TILE_STAIRS := Vector2i(1, 1)
const TILE_DOOR := Vector2i(0, 1)
const TILE_FOG := Vector2i(2, 1)
const TILE_DARK := Vector2i(3, 1)
var level_size := Vector2i(25, 25)

enum HEROES {
	knight,
	mage
}

enum MONSTERS {
	bat
}

func _ready():
	DisplayServer.window_set_size(Vector2(1920, 1080), 0)
