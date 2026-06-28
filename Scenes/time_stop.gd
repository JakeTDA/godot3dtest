class_name Power
extends StaticBody3D
signal speed_change(speed_curve)

var speed_curve : Curve
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().current_scene.child_entered_tree.connect(_on_child_entered)
	pass # Replace with function body.

func _on_child_entered(node: Node):
	if node is Bullet:
		node.bullet_hit.connect(_on_bullet_hit)

func _on_bullet_hit(bullet : Bullet):
	print("BULLET")
	speed_curve = load("res://Resources/SpeedCurves/fast_to_slow.tres")
	bullet.accel_curve = speed_curve
	await get_tree().create_timer(1.0).timeout
	speed_curve = load("res://Resources/SpeedCurves/slow_to_fast.tres")
	bullet.time = 0
	bullet.accel_curve = speed_curve
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
