extends Node


const TILESIZE := 32
const TILE_NONE := Vector2i(0, 0)
const TILE_FLOOR := Vector2i(1, 0)
const TILE_WALL := Vector2i(2, 0)
const TILE_STAIRS := Vector2i(1, 1)
const TILE_DOOR := Vector2i(0, 1)
const TILE_FOG := Vector2i(2, 1)
const TILE_DARK := Vector2i(3, 1)
const TILE_VOID := Vector2i(3, 0)

var level_size := Vector2i(26, 25)


var UNITS :Dictionary = {
	"hero knight" = "res://scenes/Characters/Heroes/hero_knight.tscn",
	"hero mage" = "res://scenes/Characters/Heroes/hero_mage.tscn",
	"hero ranger" = "res://scenes/Characters/Heroes/hero_ranger.tscn",
	"hero fighter" = "res://scenes/Characters/Heroes/hero_fighter.tscn",
	
	"mon bat" = "res://scenes/Characters/Monsters/bat.tscn",
	"mon rat" = "res://scenes/Characters/Monsters/rat.tscn",
	"mon beholder" = "res://scenes/Characters/Monsters/beholder.tscn",
	"mon worm" = "res://scenes/Characters/Monsters/worm.tscn"
}

func _ready():
	DisplayServer.window_set_size(Vector2(1280, 800), 0)
	randomize()
