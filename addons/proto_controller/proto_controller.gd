# ProtoController v1.0 by Brackeys
# CC0 License
# Intended for rapid prototyping of first-person games.
# Happy prototyping!

extends CharacterBody3D	

signal health_changed(health_value)

@export_group("Player Properties")

@export var health : float = 100.0

## Can we move around?
@export var can_move : bool = true
## Are we affected by gravity?
@export var has_gravity : bool = true
## Can we press to jump?
@export var can_jump : bool = true
## Can we hold to run?
@export var can_sprint : bool = false
## Can we press to enter freefly mode (noclip)?
@export var can_freefly : bool = false


@export_group("Speeds")
## Look around rotation speed.
@export var look_speed : float = 0.002
## Normal speed.
@export var base_speed : float = 7.0
## Speed of jump.
@export var jump_velocity : float = 4.5
## How fast do we run?
@export var sprint_speed : float = 10.0
## How fast do we freefly?
@export var freefly_speed : float = 25.0
## How much do we sliiiiide?
@export var friction : float = 1.0

@export_group("Input Actions")
## Name of Input Action to move Left.
@export var input_left : String = "ui_left"
## Name of Input Action to move Right.
@export var input_right : String = "ui_right"
## Name of Input Action to move Forward.
@export var input_forward : String = "ui_up"
## Name of Input Action to move Backward.
@export var input_back : String = "ui_down"
## Name of Input Action to Jump.
@export var input_jump : String = "ui_accept"
## Name of Input Action to Sprint.
@export var input_sprint : String = "sprint"
## Name of Input Action to toggle freefly mode.
@export var input_freefly : String = "freefly"

@export var input_shoot : String = "shoot"

@onready var ani = $AnimationPlayer
@onready var muzzleflash = $Head/Camera3D/Weapon/Muzzle
@onready var weapons = ["res://Resources/GunStats/pistol.tres",
"res://Resources/GunStats/shotgun.tres",
"res://Resources/GunStats/smg.tres"]
@onready var time_stop_area = $TimeStopArea

var bull : int = 0

var mouse_captured : bool = false
var look_rotation : Vector2
var move_speed : float = 0.0
var freeflying : bool = false

## IMPORTANT REFERENCES
@onready var head: Node3D = $Head
@onready var collider: CollisionShape3D = $Collider
@onready var weapon: Weapon = $Head/Camera3D/Weapon
@onready var camera = $Head/Camera3D

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready() -> void:
	if not is_multiplayer_authority(): return
	
	camera.current = true
	check_input_mappings()
	look_rotation.y = rotation.y
	look_rotation.x = head.rotation.x
	
	add_to_group("players")
	weapon.stop_shoot.connect(cur_reload)
	weapon.ammo_out.connect(out_of_ammo)
func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	# Mouse capturing
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		capture_mouse()
	if Input.is_key_pressed(KEY_ESCAPE): 	
		release_mouse()
	
	# Weapon Swap Test
	#if Input.is_key_pressed(KEY_V):
		#weapon.gun_stats = pistol
		#full_auto = weapon.get_mode()
		#cooldown = weapon.get_cooldown()
	#if Input.is_key_pressed(KEY_B):
		#weapon.gun_stats = shotgun
		#full_auto = weapon.get_mode()
		#cooldown = weapon.get_cooldown()
	#if Input.is_just_key_pressed(KEY_N):
		#weapon.gun_stats = smg
		#full_auto = weapon.get_mode()
		#cooldown = weapon.get_cooldown()
	if Input.is_action_just_pressed("reload"):
		reload()
	if Input.is_action_just_pressed("weapon_swap"):
		weapon_swap()
	# Look around
	if mouse_captured and event is InputEventMouseMotion:
		rotate_look(event.relative)
	
	# Toggle freefly mode
	if can_freefly and Input.is_action_just_pressed(input_freefly):
		if not freeflying:
			enable_freefly()
		else:
			disable_freefly()
			
	#if Input.is_action_just_pressed(input_shoot):
		#print("shoot")
		#bull += 1
		#print(bull)
@onready var cooldown = weapon.get_cooldown()
var on_cooldown = false
@onready var reload_time = weapon.get_reload()
var reloading = false
var ammo_out = false
@onready var full_auto = weapon.get_mode()

func cur_reload():
	reloading = true

func out_of_ammo():
	ammo_out = true

func reload():
	print("reloading")
	await get_tree().create_timer(reload_time).timeout
	weapon.reload()
	ammo_out = false
	reloading = false
	print("reloaded")
	
func weapon_swap():
	weapon.weapon_swap()
	reload_time = weapon.get_reload()
	cooldown = weapon.get_cooldown()
	full_auto = weapon.get_mode()
	reloading = false
	ammo_out = false
	

func shoot():
	#print(cooldown)
	if on_cooldown == false and reloading == false and ammo_out == false:
		#print("shoot")
		weapon.shoot()
		ani.stop()
		ani.play("pistolshoot")
		muzzleflash.restart()
		muzzleflash.emitting = true
		on_cooldown = true
		
		await get_tree().create_timer(cooldown).timeout
		on_cooldown = false
	
func _physics_process(delta: float) -> void:	
	# If freeflying, handle freefly and nothing else
	if Input.is_action_just_pressed(input_shoot) and weapon and not full_auto:
		shoot()		
	if Input.is_action_pressed(input_shoot) and weapon and full_auto:
		shoot()
	if Input.is_action_pressed("right_click"):
		time_stop_area.activate()
	else:
		time_stop_area.disable()
		
	#if Input.is_action_just_pressed(input_shoot) and weapon:
		#print("shoot")
		#weapon.shoot()
		#ani.stop()
		#ani.play("pistolshoot")
		#muzzleflash.restart()
		#muzzleflash.emitting = true
		
			
	if can_freefly and freeflying:
		var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
		var motion := (head.global_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		motion *= freefly_speed * delta
		move_and_collide(motion)
		return
	
	# Apply gravity to velocity
	if has_gravity:
		if not is_on_floor():
			velocity += get_gravity() * delta

	# Apply jumping
	if can_jump:
		if Input.is_action_just_pressed(input_jump) and is_on_floor():
			velocity.y = jump_velocity

	# Modify speed based on sprinting
	if can_sprint and Input.is_action_pressed(input_sprint):
			move_speed = sprint_speed
	else:
		move_speed = base_speed

	# Apply desired movement to velocity
	if can_move:
		var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
		var move_dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if move_dir:
			velocity.x = move_dir.x * move_speed
			velocity.z = move_dir.z * move_speed
		else:
			velocity.x = move_toward(velocity.x, 0, move_speed * friction)
			velocity.z = move_toward(velocity.z, 0, move_speed * friction)
	else:
		velocity.x = 0
		velocity.y = 0
	
	# Use velocity to actually move
	move_and_slide()


## Rotate us to look around.
## Base of controller rotates around y (left/right). Head rotates around x (up/down).
## Modifies look_rotation based on rot_input, then resets basis and rotates by look_rotation.
func rotate_look(rot_input : Vector2):
	look_rotation.x -= rot_input.y * look_speed
	look_rotation.x = clamp(look_rotation.x, deg_to_rad(-85), deg_to_rad(85))
	look_rotation.y -= rot_input.x * look_speed
	transform.basis = Basis()
	rotate_y(look_rotation.y)
	head.transform.basis = Basis()
	head.rotate_x(look_rotation.x)


func enable_freefly():
	collider.disabled = true
	freeflying = true
	velocity = Vector3.ZERO

func disable_freefly():
	collider.disabled = false
	freeflying = false


func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true


func release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false


## Checks if some Input Actions haven't been created.
## Disables functionality accordingly.
func check_input_mappings():
	if can_move and not InputMap.has_action(input_left):
		push_error("Movement disabled. No InputAction found for input_left: " + input_left)
		can_move = false
	if can_move and not InputMap.has_action(input_right):
		push_error("Movement disabled. No InputAction found for input_right: " + input_right)
		can_move = false
	if can_move and not InputMap.has_action(input_forward):
		push_error("Movement disabled. No InputAction found for input_forward: " + input_forward)
		can_move = false
	if can_move and not InputMap.has_action(input_back):
		push_error("Movement disabled. No InputAction found for input_back: " + input_back)
		can_move = false
	if can_jump and not InputMap.has_action(input_jump):
		push_error("Jumping disabled. No InputAction found for input_jump: " + input_jump)
		can_jump = false
	if can_sprint and not InputMap.has_action(input_sprint):
		push_error("Sprinting disabled. No InputAction found for input_sprint: " + input_sprint)
		can_sprint = false
	if can_freefly and not InputMap.has_action(input_freefly):
		push_error("Freefly disabled. No InputAction found for input_freefly: " + input_freefly)
		can_freefly = false

func _on_player_hurtbox_enemy_hit(damage_amount: int) -> void:
	player_hit(damage_amount)
	
func player_hit(damage_amount : int):
	if not is_multiplayer_authority():
		return
	health -= damage_amount
	#print(health)
	if health <= 0:
		health = 100.0
		position = Vector3.ZERO
	health_changed.emit(health)
