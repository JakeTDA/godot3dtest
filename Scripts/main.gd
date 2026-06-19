extends Node3D

@onready var main_menu = $CanvasLayer/MainMenu
@onready var address_entry = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AddressEntry
@onready var hud = $CanvasLayer/HUD
@onready var health_bar = $CanvasLayer/HUD/HealthBar
@onready var enemy = load("res://Scenes/enemy.tscn")
@onready var shotgunenemy = load("res://Scenes/shotgun_enemy.tscn")
@onready var player_list = []

const Player = preload("res://Scenes/player.tscn")
const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()
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
				
func _on_host_button_pressed() -> void:
	main_menu.hide() 
	hud.show()
	
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	multiplayer.peer_connected.connect(_on_peer_connected)
	
	add_player(multiplayer.get_unique_id())
	
	upnp_setup()
	
	

func _on_join_button_pressed() -> void:
	main_menu.hide() 
	hud.show()
	
	enet_peer.create_client(address_entry.text, PORT)
	multiplayer.multiplayer_peer = enet_peer
	
func add_player(peer_id):
	var player = Player.instantiate()
	player.name = str(peer_id)
	add_child(player)
	player_list += [player]
	if player.is_multiplayer_authority():
		player.health_changed.connect(update_health_bar)
		
func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()

func _on_peer_connected(peer_id):
	await get_tree().create_timer(5.0).timeout
	enemy_sync(peer_id)
	
func enemy_sync(peer_id):
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.sync_state.rpc_id(peer_id, enemy.global_position, enemy.global_rotation, enemy.health)
	pass

func update_health_bar(health_value):
	health_bar.value = health_value
	
@rpc("call_local", "authority", "reliable")
func spawn_bullet(spawn_position, spawn_velocity):
	if multiplayer.is_server():
		var bullet = preload("res://Scenes/bullet.tscn").instantiate()
		bullet.global_position = spawn_position
		bullet.velocity = spawn_velocity
		get_node("/root/Main/BulletContainer").add_child(bullet)

func _on_multiplayer_spawner_spawned(node) -> void:
	if node.is_multiplayer_authority():
		node.health_changed.connect(update_health_bar)


func _on_enemy_died(enemy_position : Vector3):
	if not multiplayer.is_server():
		return
	await get_tree().create_timer(1.0).timeout	
	respawn_enemy.rpc(enemy_position)

@rpc("authority","call_local","reliable")
func respawn_enemy(enemy_position):
	var new_enemy = enemy.instantiate()
	new_enemy.global_position = enemy_position
	if enemy_ai == false:
		new_enemy.shoot_ai = false
	else:
		new_enemy.shoot_ai = true
	if !new_enemy.is_inside_tree():
		add_child(new_enemy)
		
func upnp_setup():
	var upnp = UPNP.new()
	
	var discover_result = upnp.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Discover Failed! Error %s" % discover_result)
		
	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), \
		"UPNP Invalid Gateway!")
		
	var map_result = upnp.add_port_mapping(PORT) 
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Port Mapping Failed! Error %s" % map_result)
	
	print("Success! Join Address: %s" % upnp.query_external_address())
	
	
	
