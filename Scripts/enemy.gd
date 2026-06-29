extends CharacterBody3D

@export var health = 100
@export var damage = 10
@export var speed = 5
@export var shoot_ai = false
@onready var ani = $Boom/AnimationPlayer
@onready var weapon = $Weapon
var hurtbox: Hurtbox
var mesh_instance_3d: MeshInstance3D
var collider: CollisionShape3D
var fire_rate = 1
var shoot_cooldown = fire_rate
var dead = false
@onready var player = get_tree().get_first_node_in_group("players")

signal enemy_dead(spawn_point: Vector3)
	
func _ready() -> void:
	hurtbox = $Hurtbox
	mesh_instance_3d = $MeshInstance3D
	collider = $Collider
	weapon.ammo_out.connect(reload)
	add_to_group("enemies")
	if multiplayer.is_server():
		enemy_dead.connect(get_tree().current_scene._on_enemy_died)

func _physics_process(delta: float) -> void:
	if not player:
		player = get_tree().get_first_node_in_group("players")
		return
	shoot_cooldown -= delta
	if shoot_cooldown <= 0 and dead == false and shoot_ai == true:
		look_at(player.global_position)
		weapon.shoot()
		shoot_cooldown = fire_rate
	pass	

func _on_enemy_hit(damage_amount: int) -> void:
		damaged(damage_amount)
		
func damaged(damage_amount):
	health -= damage_amount
	print(health)
	if health <= 0 and dead == false:
		dead = true
		death()
	
func reload():
	weapon.reload()
func death():
	hurtbox.queue_free()
	mesh_instance_3d.queue_free()
	collider.queue_free()
	ani.play("play")
	await get_tree().create_timer(1.0).timeout
	dead = false
	enemy_dead.emit(global_position)
	queue_free()
