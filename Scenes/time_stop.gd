class_name Power
extends StaticBody3D
signal speed_change(speed_curve)
var bullet : Bullet
var fast_to_slow = load("res://Resources/SpeedCurves/fast_to_slow.tres")
var slow_to_fast = load("res://Resources/SpeedCurves/slow_to_fast.tres")
@onready var collider = $CollisionShape3D
@onready var mesh = $MeshInstance3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().current_scene.child_entered_tree.connect(_on_child_entered)
	pass # Replace with function body.

func _on_child_entered(node: Node):
	if node is Bullet:
		node.bullet_hit.connect(time_stop)
		node.bullet_unhit.connect(time_release)
		bullet = node

func time_stop(bullet : Bullet):
	if bullet.bullet_hitbox.time_stopped == false:
		print("BULLET")
		bullet.time = 0.0
		bullet.accel_curve = fast_to_slow
		bullet.bullet_hitbox.time_stopped = true
	
func time_release(bullet: Bullet):
	if is_instance_valid(bullet) and bullet.bullet_hitbox.time_stopped == true:
		print("LEE")
		bullet.time = 0.0
		bullet.accel_curve = slow_to_fast		
		bullet.bullet_hitbox.time_stopped = false
		
func activate():
	collider.disabled = false
	mesh.visible = true

func disable():
	collider.disabled = true
	mesh.visible = false
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
