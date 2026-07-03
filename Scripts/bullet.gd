class_name Bullet
extends CharacterBody3D
signal bullet_hit(node : Node)
signal bullet_unhit(node : Node)

@export var damage_num : float = 100.0
@export var accel_curve : Curve
@export var speed : float = 40.0
@export var time_taken : float = 1.0
@export var size : float = 0.1
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var hitbox_collision = $CollisionShape3D
@onready var raycast = $Ray

var time_stopped = false
var bullet : Bullet
var power_hit = false
var time = 0.0
var hit = false
func _ready() -> void:
	pass

func _on_bullet_hit():
	bullet_hit.emit(self)

func _on_bullet_unhit():
	bullet_unhit.emit(self)
	

var acceleration : float = 0.0
func _physics_process(delta):
	power_hit = false
	if raycast.is_colliding(): 
		var target = raycast.get_collider()
		if hit == false:
			print("it hit")
			hit = true
			raycast.enabled = false
			damage(target)
			mesh.hide()
			#destroy_bullet()
			
	time += delta
	var time_calc = clamp(time / time_taken, 0.0, 1.0)
	acceleration = accel_curve.sample(time_calc) * speed
	position += global_transform.basis * Vector3(0,0,-acceleration) * delta
	
func damage(area: Node3D):
	var damage_amount = damage_num
	if area is Hurtbox:
		print('its hurt')
		#if area.is_multiplayer_authority(): return
		area.damage(damage_amount)
		
func destroy_bullet():
	queue_free()
		
		
