class_name Weapon extends Node3D

signal stop_shoot()
signal ammo_out()

@export var gun_stats : GunStats
@onready var bullet = load("res://Scenes/bullet.tscn")
@onready var player = $"../../.."
@onready var pos : Node3D
@onready var mag = gun_stats.magazine
@onready var weapons = ["res://Resources/GunStats/pistol.tres",
"res://Resources/GunStats/shotgun.tres",
"res://Resources/GunStats/smg.tres"]

var weapon_num : int = 0
var main : Node
func _ready() -> void:
	main = get_tree().current_scene
	if get_parent() is Camera3D:
		pos = $"../pos"
	else:
		pos = $pos
	
func shoot():
	if mag > 0:
		for i in gun_stats.bullet_count:
			var instance = bullet.instantiate()
			get_tree().current_scene.add_child(instance)
			instance.global_position = pos.global_position
			instance.global_transform.basis = pos.global_transform.basis
			instance.damage = gun_stats.damage
			instance.size = gun_stats.bullet_size
			instance.speed = gun_stats.bullet_speed
			instance.accel_curve = gun_stats.speed_curve
			instance.time_taken = gun_stats.time_taken
			instance.rotation.x += deg_to_rad(randf_range(-gun_stats.spread, gun_stats.spread))
			instance.rotation.y += deg_to_rad(randf_range(-gun_stats.spread, gun_stats.spread))
	if mag <= 1:
		ammo_out.emit()
	if mag <= 0:
		reload()
	mag -= 1
	print(mag)
func get_cooldown():
	return gun_stats.fire_rate

func get_mode():
	return gun_stats.full_auto

func get_reload():
	return gun_stats.reload

func reload():
	mag = gun_stats.magazine
	stop_shoot.emit()
	return gun_stats.reload

func weapon_swap():
	weapon_num += 1
	if weapon_num > weapons.size() - 1:
		weapon_num = 0
	gun_stats = load(weapons[weapon_num])
	mag = gun_stats.magazine
	
