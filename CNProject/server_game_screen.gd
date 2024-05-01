extends Node2D

var multiplayer_peer = ENetMultiplayerPeer.new()
var url : String = "your-prod.url"
const PORT = 62830

var right_score = 0
var left_score = 0

var connected_peers = []
var left_blue = preload("res://pong_assets/left_pallete.png")
var right_pink = preload("res://pong_assets/right_pallete.png")
var player_info_dict = {
	
}
var start_game_players_ready = false
var right_player_id
var left_player_id

var LEFT = 1
var RIGHT = 2

var max_game_points = 5



@rpc("any_peer", "reliable")
func player_joined(side):
	var sender_id = multiplayer.get_remote_sender_id()
	print("Player Side Selected: ", side)
	var player_node = preload("res://player.tscn")
	var player_node_instance = player_node.instantiate()
	
	var new_player_position
	if side == 1:
		new_player_position = Vector2i(100,540)
		player_node_instance.name = "left"
		player_node_instance.get_node("PlayerShape").texture = left_blue
		left_player_id = sender_id
	if side== 2:
		new_player_position = Vector2i(1820,540)
		player_node_instance.get_node("PlayerShape").texture = right_pink
		player_node_instance.name = "right"
		right_player_id = sender_id
	player_node_instance.position = new_player_position
	add_child(player_node_instance)
	player_info_dict[sender_id] = {"Side":side, "Ready":false}
	print("PLayer dict side: ", player_info_dict.get(sender_id)["Side"])
	for i in connected_peers:
		if sender_id!=i:
			rpc_id(i, "peer_player_connected")
		else:
			if connected_peers.size()==2:
				rpc_id(sender_id, "peer_player_connected")
			pass
	pass

@rpc("any_peer", "unreliable")
func input_from_player(direction, player_position):
		var sender_id = multiplayer.get_remote_sender_id()
		#print("Side: ",  player_info_dict.get(sender_id)["Side"], " Going in direction: ", direction)
		if  player_info_dict.get(sender_id)["Side"] == 1:
			get_node("left").position.y = player_position
			get_node("left").position.x = 100
			get_node("left").velocity.y = 0
			#print("Serve Position: ", get_node("left").position.y)
			for i in connected_peers:
				if sender_id!=i:
					rpc_id(i, "update_peer_position", get_node("left").position.y )
		if  player_info_dict.get(sender_id)["Side"] == 2:
			get_node("right").position.y = player_position
			get_node("right").position.x = 1820
			get_node("right").velocity.y = 0
			for i in connected_peers:
				if sender_id!=i:
					rpc_id(i, "update_peer_position", get_node("right").position.y )
			pass
		pass





@rpc("any_peer")
func update_peer_position(peer_player_position):
	pass

@rpc("any_peer")
func peer_player_connected():
	pass

@rpc("any_peer", "reliable")
func ready_start_game():
	var sender_id = multiplayer.get_remote_sender_id()
	player_info_dict.get(sender_id)["Ready"] = true
	
	pass
@rpc("any_peer", "reliable")
func game_has_started():
	pass

@rpc("any_peer", "unreliable")
func send_ball_pos(ball_position):
	pass

@rpc("any_peer", "reliable")
func update_score(left_score, right_score):
	pass

@rpc("any_peer", "reliable")
func game_over_alert(game_winner):
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	#This creates the server and happens right when this scene is added as a child.
	multiplayer_peer.create_server(GameGlobal.port)
	print("Server Creating Port: ", GameGlobal.port)
	multiplayer.multiplayer_peer = multiplayer_peer
	
	multiplayer_peer.peer_connected.connect(_on_peer_connected)
	multiplayer_peer.peer_disconnected.connect(_on_peer_disconnected)
	
	print("Server is up and running.")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if self.has_node("left"):
		get_node("left").position.x = 100
		get_node("left").velocity.y = 0
	if self.has_node("right"):
		get_node("right").position.x = 1820
		get_node("right").velocity.y = 0
	if start_game_players_ready == false:
		if(player_info_dict.has(right_player_id) && player_info_dict.has(left_player_id)):
			if player_info_dict.get(right_player_id)["Ready"] && player_info_dict.get(left_player_id)["Ready"]:
				start_game()
				start_game_players_ready = true
				pass
	pass

#Function from 	multiplayer_peer.peer_connected.connect(_on_peer_connected)
func _on_peer_connected(new_peer_id : int) -> void:
	print("Player " + str(new_peer_id) + " has joined")
	connected_peers.append(new_peer_id)


#funciton from multiplayer_peer.peer_disconnected.connect(_on_peer_disconnected)
func _on_peer_disconnected(leaving_peer_id : int) -> void:
	print("Player Disconnected: ", str(leaving_peer_id))

@rpc("any_peer")
func rpc_test_func(chicken):
	pass


func _on_rp_cto_client_button_pressed():
	for i in connected_peers:
		var chicken = "PIIZA"
		rpc_id(i, "rpc_test_func", chicken)
	pass


#when the ball touches the top, change the balls direction
func _on_top_body_entered(body):
	if body.is_ball:
		body.direction.y *= -1
	pass # Replace with function body.

#when the ball touches the bottom, change the balls direction
func _on_bottom_body_entered(body):
	if body.is_ball:
		body.direction.y *= -1
	pass


func _on_left_body_entered(body):
	body.queue_free()
	right_score += 1
	$RightScore.text = str(right_score)
	for i in connected_peers:
		rpc_id(i, "update_score", left_score, right_score)
	if right_score >= max_game_points:
		game_over(RIGHT)
	else:
		var new_ball = preload("res://ball.tscn").instantiate()
		new_ball.position = Vector2i(960, 540)
		add_child(new_ball)
	pass


func _on_right_body_entered(body):
	body.queue_free()
	left_score += 1
	$LeftScore.text = str(left_score)
	for i in connected_peers:
		rpc_id(i, "update_score", left_score, right_score)
	if left_score >= max_game_points:
		game_over(LEFT)
	else:
		var new_ball = preload("res://ball.tscn").instantiate()
		new_ball.position = Vector2i(960, 540)
		add_child(new_ball)
	pass


func start_game():
	for i in connected_peers:
		rpc_id(i, "game_has_started")
	var start_clock = preload("res://start_game_countdown_hud.tscn").instantiate()
	add_child(start_clock)
	start_clock.get_node("Label").text = "3"
	await get_tree().create_timer(1).timeout
	start_clock.get_node("Label").text = "2"
	await get_tree().create_timer(1).timeout
	start_clock.get_node("Label").text = "1"
	await get_tree().create_timer(1).timeout
	start_clock.get_node("Label").text = "GO!"
	await get_tree().create_timer(0.5).timeout
	start_clock.queue_free()
	var ball_node = preload("res://ball.tscn")
	var ball_node_instance = ball_node.instantiate()
	ball_node_instance.position = Vector2i(960, 540)
	add_child(ball_node_instance)
	print("Game Started")
	pass


func send_client_ball_pos(ball_position):
	for i in connected_peers:
		rpc_id(i, "send_ball_pos", ball_position)
	pass


func game_over(game_winner):
	for i in connected_peers:
		rpc_id(i, "game_over_alert", game_winner)
	get_node("RightScore").text = "0"
	get_node("LeftScore").text = "0"
	start_game_players_ready = false
	player_info_dict.get(right_player_id)["Ready"] = false
	player_info_dict.get(left_player_id)["Ready"] = false
	right_score = 0
	left_score = 0
	pass
