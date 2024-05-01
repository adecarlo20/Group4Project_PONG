extends Node2D
var server_scene = load("res://server_game_screen.tscn")
var client_scene = load("res://client_game_screen.tscn")
var client_selection_scene = load("res://client_selection_scene.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


#when the server button is pressed, add the server scene
func _on_server_button_pressed():
	print("Server Button Pressed")
	var new_scene_server = server_scene.instantiate()
	get_tree().get_root().add_child(new_scene_server)
	self.queue_free()
	pass # Replace with function body.

#when the client button is pressed, add the client scene
func _on_client_button_pressed():
	print("Client Button Pressed")
	var new_scene_client = client_selection_scene.instantiate()
	get_tree().get_root().add_child(new_scene_client)
	self.queue_free()
	pass


#change the IP varaible when typing
func _on_ip_enter_text_changed(new_text):
	GameGlobal.ip_address = str(new_text)
	pass

#change the port variable when typing
func _on_port_enter_text_changed(new_text):
	GameGlobal.port = str_to_var(new_text)
	pass
