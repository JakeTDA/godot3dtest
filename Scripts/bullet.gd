class_name Bullet
extends CharacterBody3D

@export var damage = 100

@export var speed = 40.0

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var bullet_hitbox: Hitbox = $BulletHitbox
 
func _process(delta):
	position += transform.basis * Vector3(0,0,-speed) * delta
	
@rpc("any_peer","call_local","reliable")
func destroy_bullet():
	if multiplayer.is_server():
		queue_free()
