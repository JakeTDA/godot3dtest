class_name Hitbox extends Area3D
signal collision_hit(bullet: Node)
signal collision_unhit(bullet: Node)

@onready var raycast = $Ray
@onready var mesh: MeshInstance3D = $"../MeshInstance3D"
var time_stopped = false
var bullet : Bullet
var power_hit = false
var hit = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if owner is Bullet:
		bullet = owner
func _physics_process(delta: float) -> void:
	power_hit = false
	if raycast.is_colliding(): 
		#print("???")
		var target = raycast.get_collider()
		if target is Power:
			power_hit = true
		else:
			#print("sout")
			if hit == false:
				hit = true
				raycast.enabled = false
				damage(target)
				mesh.hide()
				bullet_delete()
	
	if power_hit and not time_stopped:
		collision_hit.emit()
	
	if not power_hit and time_stopped:
		collision_unhit.emit()
		
func damage(area: Node3D):
	var damage_amount = bullet.damage
	if area is Hurtbox:
		#if area.is_multiplayer_authority(): return
		area.damage(damage_amount)
		
func bullet_delete():
	bullet.queue_free()
