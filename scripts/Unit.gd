extends Sprite2D
class_name Unit


var dead := false
var cur_health :float: set = set_cur_health
var is_front := true

@export var max_health :float = 10.0
@export var attack :float = 3.0

signal mou_entered
signal mou_exited


func _ready():
	cur_health = max_health
	$Area2D.mouse_entered.connect(_on_area_2d_mouse_entered)
	$Area2D.mouse_exited.connect(_on_area_2d_mouse_exited)


func take_damage(dmg:int) -> void:
	cur_health = cur_health - dmg
	if cur_health <= 0:
		dead = true


func set_cur_health(value):
	cur_health = value
	$HP.size.x = cur_health / max_health * 16.0


func _on_area_2d_mouse_entered():
	mou_entered.emit(self)


func _on_area_2d_mouse_exited():
	mou_exited.emit(self)
