class_name Hurtbox extends Area3D

signal enemy_hit(damage_amount : int)
# Called when the node enters the scene tree for the first time.
func damage(damage_amount : int):
	enemy_hit.emit(damage_amount)
