extends Sprite2D

var dead = false
var max_health := 10.0
var cur_health :int:
	set(value):
		cur_health = value
		$HP.size.x = cur_health / max_health * 16.0


func _ready():
	cur_health = max_health	


func take_damage(dmg:int) -> void:
	cur_health = cur_health - dmg
	if cur_health <= 0:
		dead = true
