extends Node2D

var multiplayer_peer = ENetMultiplayerPeer.new()
var url : String = "your-prod.url"
#192.168.1.1 router
#127.0.0.1 default
var defualt_ip = "127.0.0.1"
const PORT = 62830

var left_blue = preload("res://pong_assets/left_pallete.png")
var right_pink = preload("res://pong_assets/right_pallete.png")

var peer_player_spawned = false
var ball_is_spawned = false

@rpc("any_peer")
func player_joined(side):
	pass

@rpc("any_peer")
func input_from_player(direction, player_position):
		pass

@rpc("any_peer", "reliable")
func ready_start_game():
	pass

@rpc("any_peer")
func update_peer_position(peer_player_position):
	if peer_player_spawned:
		get_node("PeerPlayer").position.y = peer_player_position
	pass

@rpc("any_peer", "reliable")
func game_has_started():
	print("Server telling clients that game has started")
	get_node("ReadyButton").queue_free()
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
	spawn_ball()
	pass


@rpc("any_peer", "unreliable")
func send_ball_pos(ball_position):
	if self.has_node("fake_ball"):
		get_node("fake_ball").position = ball_position
	pass


@rpc("any_peer", "reliable")
func update_score(left_score, right_score):
	get_node("RightScore").text = str(right_score)
	get_node("LeftScore").text = str(left_score)
	pass


@rpc("any_peer", "reliable")
func game_over_alert(game_winner):
	get_node("fake_ball").queue_free()
	var game_over_screen = preload("res://game_over_hud.tscn").instantiate()
	add_child(game_over_screen)
	game_over_screen.get_node("Label").text = "GAME OVER"
	if game_winner == 1:
		game_over_screen.get_node("LowerLabel").text = "LEFT WINS"
	else:
		game_over_screen.get_node("LowerLabel").text = "RIGHT WINS"
	await get_tree().create_timer(4).timeout
	game_over_screen.queue_free()
	get_node("RightScore").text = "0"
	get_node("LeftScore").text = "0"
	var ready_button = preload("res://ready_button.tscn").instantiate()
	if GameGlobal.selected_side == 1:
		ready_button.position = Vector2i(500-155, 540-85)
	else:
		ready_button.position = Vector2i(1320-155, 540-85)
	ready_button.connect("pressed", _on_ready_button_pressed.bind())
	add_child(ready_button)
	pass



@rpc("any_peer")
func peer_player_connected():
	#left
	if GameGlobal.selected_side == 1:
		var player_node = preload("res://peer_player.tscn")
		var player_node_instance = player_node.instantiate()
		add_child(player_node_instance)
		var new_player_position
		new_player_position = Vector2i(1820,540)
		player_node_instance.get_node("PlayerShape").texture = right_pink
		player_node_instance.position = new_player_position
		await get_tree().create_timer(0.1).timeout
		peer_player_spawned = true
		#spawn player right side
		pass
	#right
	else:
		var player_node = preload("res://peer_player.tscn")
		var player_node_instance = player_node.instantiate()
		add_child(player_node_instance)
		var new_player_position
		new_player_position = Vector2i(100,540)
		player_node_instance.get_node("PlayerShape").texture = left_blue
		player_node_instance.position = new_player_position
		await get_tree().create_timer(0.1).timeout
		peer_player_spawned = true
		#spawn player left side
		pass
	pass


# Called when the node enters the scene tree for the first time.
func _ready():
	#This creates the client and happens right when this scene is added as a child.
	print("Client Connecting ...")
	multiplayer_peer.create_client(GameGlobal.ip_address, GameGlobal.port)
	print("Client Joining IP: ", GameGlobal.ip_address, " Port: ", GameGlobal.port)
	multiplayer.multiplayer_peer = multiplayer_peer
	await get_tree().create_timer(0.2).timeout
	print("Status: ", multiplayer_peer.get_connection_status())
	var player_node = preload("res://player.tscn")
	var player_node_instance = player_node.instantiate()
	add_child(player_node_instance)
	var new_player_position
	if GameGlobal.selected_side == 1:
		new_player_position = Vector2i(100,540)
		player_node_instance.get_node("PlayerShape").texture = left_blue
		var ready_button = preload("res://ready_button.tscn").instantiate()
		ready_button.position = Vector2i(500-155, 540-85)
		ready_button.connect("pressed", _on_ready_button_pressed.bind())
		add_child(ready_button)
	if GameGlobal.selected_side == 2:
		new_player_position = Vector2i(1820,540)
		player_node_instance.get_node("PlayerShape").texture = right_pink
		var ready_button = preload("res://ready_button.tscn").instantiate()
		ready_button.position = Vector2i(1320-155, 540-85)
		ready_button.connect("pressed", _on_ready_button_pressed.bind())
		add_child(ready_button)
		#get_node("ReadyButton").visible = true
	player_node_instance.position = new_player_position
	GameGlobal.isspawned = true
	
	rpc_id(1, "player_joined", GameGlobal.selected_side)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func input_to_server(direction, player_position):
	rpc_id(1, "input_from_player", direction, player_position)
	pass



@rpc("any_peer")
func rpc_test_func(chicken):
	print("This is client with passed infor: ", chicken)
	print("Get local addres", IP.get_local_addresses())
	pass



func _on_bottom_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	print("Area Shape Entered Bottom: ", area_rid)
	pass # Replace with function body.


func _on_top_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	print("Area Shape Entered Top: ", area_rid)
	pass # Replace with function body.


func _on_left_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	print("Area Shape Entered Left: ", area_rid)
	pass # Replace with function body.


func _on_right_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	print("Area Shape Entered Right: ", area_rid)
	pass # Replace with function body.


func spawn_ball():
	var fake_ball_node = preload("res://fake_ball.tscn")
	var fake_ball_node_instance = fake_ball_node.instantiate()
	fake_ball_node_instance.position = Vector2i(960, 540)
	add_child(fake_ball_node_instance)
	var ball_is_spawned = true
	pass


func _on_top_body_entered(body):
	#print("BALL TOUCHED TOP")
	pass # Replace with function body.


func _on_bottom_body_entered(body):
	#print("BALL TOUCHED BOTTOM")
	pass # Replace with function body.


func _on_ready_button_pressed():
	rpc_id(1, "ready_start_game")
	pass # Replace with function body.
