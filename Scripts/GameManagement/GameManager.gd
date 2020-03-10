extends Node

var GameSession = preload("res://Scenes/World/World.tscn")
var Player = preload("res://Entities/Character/Player/Player.tscn")
var world
var players_info = {}

func prepare_game():
	randomize()
	rpc("initialize_world")
	rpc("initialize_players")

remotesync func initialize_world():
	print("initializing world...")
	world = GameSession.instance()
	get_tree().get_root().add_child(world)
	get_tree().change_scene_to(world)

remotesync func initialize_players():
	print("initializing players...")
	for p in LobbyManager.players:
		var player = Player.instance()
		player.set_name(str(p))
		player.global_position = Vector2(randi()%int(get_viewport().size.x), randi()%int(get_viewport().size.y))
		players_info[p] = {"position": player.global_position}
		world.add_child(player)
		get_tree().change_scene_to(world)
		
remote func process_input(input):
	var mouse_pos = input['mouse_pos']
	var delta = input['delta']
	update(get_tree().get_rpc_sender_id(), mouse_pos, delta)
	
func update(id, mouse_pos, delta):
	var player = get_node("world/" + str(id))
	var direction = mouse_pos - players_info[id]['position']
	player.move_and_collide(direction.normalized() * player.move_speed * delta)
	var player_info = {"position": player.global_position}
	rpc_unreliable("update_players_info", id, player_info)
	
remotesync func update_players_info(id, player_info):
	players_info[id] = player_info
