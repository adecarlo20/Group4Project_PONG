extends CharacterBody2D

var window_size : Vector2i
var SPEED = 400
const ACCELERATION = 50
var speed
var direction = Vector2.ZERO
var is_ball = true

#const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	
	if direction:
		velocity = direction*SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
	move_and_slide()
	get_parent().send_client_ball_pos(self.position)
	#move_and_collide(direction * speed * delta)

func _ready():
	direction.x = [1,-1].pick_random()
	direction.y = [1,-1].pick_random()
	pass




func new_ball():
	position.x = window_size.x/2
	position.y = 540
	pass

func random_direction():
	var new_direction
	new_direction.x = [1,-1].pick_random()
	new_direction.y = randf_range(-1,1)
	return new_direction.normalized()
	pass
