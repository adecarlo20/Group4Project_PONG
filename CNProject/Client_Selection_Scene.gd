extends Node2D
var client_scene = load("res://client_game_screen.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


#when left is clicked, global variable is changed to left, then connect to server by adding client scene
func _on_join_left_pressed():
	GameGlobal.selected_side = 1
	print("Left Selected")
	var new_scene_client = client_scene.instantiate()
	get_tree().get_root().add_child(new_scene_client)
	self.queue_free()
	pass # Replace with function body.

#when right is clicked, global variable is changed to right, then connect to server by adding client scene
func _on_join_right_pressed():
	GameGlobal.selected_side = 2
	print("Right Selected")
	var new_scene_client = client_scene.instantiate()
	get_tree().get_root().add_child(new_scene_client)
	self.queue_free()
	pass # Replace with function body.
