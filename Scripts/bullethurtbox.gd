class_name Hitbox extends Area3D
signal collision_hit(bullet: Node)

var bullet : Bullet
@onready var raycast = $Ray
@onready var mesh: MeshInstance3D = $"../MeshInstance3D"
var hit = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if owner is Bullet:
		bullet = owner
	#area_entered.connect(damage)
func _physics_process(delta: float) -> void:
	if raycast.is_colliding():
		if hit == true:
			return
		hit = true
		collision_hit.emit()
		var target = raycast.get_collider()
		if target is Power:
			return
		mesh.hide()
		raycast.enabled = false
		raycast.set_process_internal(false)
		damage(target)
		bullet.destroy_bullet()
	else:
		hit = false
			
func damage(area: Node3D):
	var damage_amount = bullet.damage
	if area is Hurtbox:
		#if area.is_multiplayer_authority(): return
		area.damage(damage_amount)
		
