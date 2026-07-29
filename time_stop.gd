class_name Power
extends Area3D
signal speed_change(speed_curve)
var bullet : Bullet
var fast_to_slow = load("res://Resources/SpeedCurves/fast_to_slow.tres")
var slow_to_fast = load("res://Resources/SpeedCurves/slow_to_fast.tres")
@onready var collider = $CollisionShape3D
@onready var mesh = $MeshInstance3D
@onready var col_radius = collider.shape.radius
@onready var mesh_radius = mesh.mesh.radius
@onready var mesh_height = mesh.mesh.height
var lerping = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func time_stop(bullet : Bullet):
	if bullet.time_stopped == false:
		#print("BULLET")
		bullet.time = 0
		bullet.accel_curve = fast_to_slow
		bullet.time_stopped = true
	
func time_release(bullet: Bullet):
	if is_instance_valid(bullet) and bullet.time_stopped == true:
		#print("LEE")
		bullet.time = 0
		bullet.accel_curve = slow_to_fast		
		bullet.time_stopped = false
		
func activate():
	lerping = lerp(lerping,col_radius,0.01)
	collider.shape.radius = lerping
	mesh.mesh.radius = lerping
	mesh.mesh.height = lerping * 2
	#collider.disabled = false
	#mesh.visible = true

func disable():
	lerping = lerp(lerping,0.0,0.05)
	collider.shape.radius = lerping
	mesh.mesh.radius = lerping
	mesh.mesh.height = lerping * 2
	#collider.disabled = true
	#mesh.visible = false
	


func _on_body_entered(body: Node3D) -> void:
	if body is Bullet:
		time_stop(body)
	if body is Enemy:
		#body.shoot_ai = false
		print("off")
		
	pass # Replace with function body.


func _on_body_exited(body: Node3D) -> void:
	if body is Bullet:
		time_release(body)
	if body is Enemy:
		print("e")
		#body.shoot_ai = true
	pass # Replace with function body.
