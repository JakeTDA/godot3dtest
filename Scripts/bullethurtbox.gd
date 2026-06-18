class_name Hitbox extends Area3D
signal enemy_hit(damage_amount : int)

var bullet : Bullet
@onready var raycast = $Ray
@onready var mesh: MeshInstance3D = $"../MeshInstance3D"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if owner is Bullet:
		bullet = owner
	#area_entered.connect(damage)
func _physics_process(delta: float) -> void:
	#if not multiplayer.is_server():
		#return
	
	if raycast.is_colliding():
		#if not multiplayer.is_server():
			#return
		var target = raycast.get_collider()
		damage(target)
		mesh.hide()
		raycast.enabled = false
		raycast.set_process_internal(false)
		await get_tree().create_timer(2.0).timeout
		bullet.destroy_bullet.rpc()
			
func damage(area: Node3D):
	if not is_multiplayer_authority():
		return
	var damage_amount = bullet.damage
	if area is Hurtbox:
		#if area.is_multiplayer_authority(): return
		area.damage(damage_amount)
		
