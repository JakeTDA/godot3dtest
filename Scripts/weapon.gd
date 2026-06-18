class_name Weapon extends Node3D

@export var gun_stats : GunStats
@onready var bullet = load("res://Scenes/bullet.tscn")
@onready var pos: Node3D = $pos

var main : Node
func _ready() -> void:
	main = get_tree().current_scene

func local_shoot_request():
	shoot.rpc(pos.global_position, pos.global.transform.basis)

@rpc("any_peer","call_local")
func shoot():
	if not multiplayer.is_server():
		return
	for i in gun_stats.bullet_count:
		var instance = bullet.instantiate()
		main.get_node("BulletContainer").add_child(instance, true)
		instance.global_position = pos.global_position
		instance.global_transform.basis = pos.global_transform.basis
		instance.damage = gun_stats.damage
		instance.rotation.x += deg_to_rad(randf_range(-gun_stats.spread, gun_stats.spread))
		instance.rotation.y += deg_to_rad(randf_range(-gun_stats.spread, gun_stats.spread))
	
