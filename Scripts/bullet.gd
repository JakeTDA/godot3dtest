class_name Bullet
extends CharacterBody3D
signal bullet_hit(node : Node)
signal bullet_unhit(node : Node)

@export var damage : float = 100.0
@export var accel_curve : Curve
@export var speed : float = 40.0
@export var time_taken : float = 1.0
@export var size : float = 0.1
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var bullet_hitbox: Hitbox = $BulletHitbox
@onready var hitbox_collision = $BulletHitbox/CollisionShape3D
@onready var raycast = $BulletHitbox/Ray
var time = 0.0
func _ready() -> void:
	call_deferred("apply_size")
	bullet_hitbox.collision_hit.connect(_on_bullet_hit)
	bullet_hitbox.collision_unhit.connect(_on_bullet_unhit)

func _on_bullet_hit():
	bullet_hit.emit(self)

func _on_bullet_unhit():
	bullet_unhit.emit(self)
	

func apply_size():
	mesh.scale = Vector3(size,size,size)
	bullet_hitbox.scale = Vector3(size,size,size)
var acceleration : float = 0.0
func _physics_process(delta):
	time += delta
	var time_calc = clamp(time / time_taken, 0.0, 1.0)
	acceleration = accel_curve.sample(time_calc) * speed
	#if acceleration <= 1:
		#raycast.enabled = false
	#else:
		#raycast.enabled = true
	position += global_transform.basis * Vector3(0,0,-acceleration) * delta
	
func destroy_bullet():
	queue_free()
