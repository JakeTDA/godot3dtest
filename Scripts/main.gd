# wall running
# time stop
# parkour
# good sliding mechanics
# time stop but not just one basic time stop move, there will be variations and many creative ways u can use it

extends Node3D

@onready var main_menu = $CanvasLayer/MainMenu
@onready var hud = $CanvasLayer/HUD
@onready var health_bar = $CanvasLayer/HUD/HealthBar
@onready var enemy = load("res://Scenes/enemy.tscn")
@onready var shotgunenemy = load("res://Scenes/shotgun_enemy.tscn")

const Player = preload("res://Scenes/player.tscn")
@export var enemy_ai = true

# add this temporarily anywhere
#func _process(delta):
#	print("enemy count: ", get_tree().get_nodes_in_group("enemies").size())

func _unhandled_input(event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	if Input.is_action_just_pressed("extra1"):
		if enemy_ai == true:
			enemy_ai = false
			for enemy in get_tree().get_nodes_in_group("enemies"):
				enemy.shoot_ai = false
				print("ai turned off")
		else:
			enemy_ai = true
			for enemy in get_tree().get_nodes_in_group("enemies"):
				enemy.shoot_ai = true
				print("ai turned on")
				
func _on_play_button_pressed() -> void:
	main_menu.hide() 
	hud.show()
	
	add_player(multiplayer.get_unique_id())

func add_player(peer_id):
	var player = Player.instantiate()
	player.name = str(peer_id)
	add_child(player)
	player.health_changed.connect(update_health_bar)
		
func update_health_bar(health_value):
	health_bar.value = health_value
	

func _on_multiplayer_spawner_spawned(node) -> void:
	if node.is_multiplayer_authority():
		node.health_changed.connect(update_health_bar)


func _on_enemy_died(enemy_position : Vector3):
	if not multiplayer.is_server():
		return
	await get_tree().create_timer(1.0).timeout	
	respawn_enemy(enemy_position)

func respawn_enemy(enemy_position):
	var new_enemy = enemy.instantiate()
	new_enemy.global_position = enemy_position
	if enemy_ai == false:
		new_enemy.shoot_ai = false
	else:
		new_enemy.shoot_ai = true
	if new_enemy.is_inside_tree() == false:
		add_child(new_enemy)

	
	
