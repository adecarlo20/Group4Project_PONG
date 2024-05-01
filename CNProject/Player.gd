extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var is_ball = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")



func _physics_process(delta):
	# Add the gravity.
	if GameGlobal.isspawned:
		if Input.is_action_pressed("up"):
			self.position.y -= 500*delta
			get_parent().input_to_server(1, self.position.y)
			#self.velocity.y = -600
			#if self.position.y > 100 && self.position.y < 1000:
				#print("UP Left")
				#self.position.y = self.position.y - 7
				#get_parent().input_to_server(1)
				##rpc_id(1, "input_from_player", 1)
			#else:
				#print("Out of bounds: ", self.position.y)
				#self.position.y = 101
		if Input.is_action_pressed("down"):
			self.position.y += 500*delta
			get_parent().input_to_server(2,  self.position.y)
			#self.velocity.y = 600
			#if self.position.y > 100 && self.position.y < 1000:
				#print("DOWN Left")
				#self.position.y = self.position.y + 7
				#get_parent().input_to_server(2)
			#else:
				#print("Out of bounds: ", self.position.y)
				#self.position.y = 1000
			#rpc_id(1, "input_from_player", 2)
		#193 is player height
		self.position.y = clamp(position.y, 193 / 2, 1080 - 193 / 2)
	
	
	#
	#if not is_on_floor():
		#velocity.y += gravity * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var direction = Input.get_axis("ui_left", "ui_right")
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
#
	move_and_slide()


func _on_area_2d_body_entered(body):
	if body.is_ball:
		body.direction.x *= -1
		body.SPEED = body.SPEED *1.1
	pass # Replace with function body.
