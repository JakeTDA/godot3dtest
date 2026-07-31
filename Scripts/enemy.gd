class_name Enemy
extends CharacterBody3D

@export var health = 100
@export var damage = 10
@export var speed = 5
@export var shoot_ai = false
@onready var ani = $Boom/AnimationPlayer
@onready var weapon_ani = $Weapon/Muzzle
@onready var weapon = $Weapon
var hurtbox: Hurtbox
var mesh_instance_3d: MeshInstance3D
var collider: CollisionShape3D
var fire_rate = 1
var shoot_cooldown = fire_rate
var dead = false
@onready var player = get_tree().get_first_node_in_group("players")
@onready var current_scene = self.scene_file_path
signal enemy_dead(spawn_point: Vector3)
	
func _ready() -> void:
	if GameManager.enemy_ai == true:
		shoot_ai = true
	else:
		shoot_ai = false
		
	hurtbox = $Hurtbox
	mesh_instance_3d = $MeshInstance3D
	collider = $Collider
	weapon.ammo_out.connect(reload)
	add_to_group("enemies")
	if multiplayer.is_server():
		enemy_dead.connect(GameManager._on_enemy_died)

func _physics_process(delta: float) -> void:
	if not player:
		player = get_tree().get_first_node_in_group("players")
		return
	shoot_cooldown -= delta
	if shoot_cooldown <= 0 and dead == false and shoot_ai == true:
		look_at(player.global_position)
		weapon.shoot()
		weapon_ani.restart()
		weapon_ani.emitting = true
		shoot_cooldown = fire_rate
	pass	

func _on_enemy_hit(damage_amount: int) -> void:
		damaged(damage_amount)
		
func damaged(damage_amount):
	health -= damage_amount
	#print(health)
	if health <= 0 and dead == false:
		dead = true
		death()
	
func reload():
	weapon.reload()
func death():
	hurtbox.queue_free()
	mesh_instance_3d.queue_free()
	collider.queue_free()
	weapon.queue_free()
	ani.play("play")
	enemy_dead.emit(current_scene, global_position)
	await get_tree().create_timer(5.0).timeout
	dead = false
	queue_free()
