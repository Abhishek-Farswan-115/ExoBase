extends CharacterBody3D

@onready var player = $Armature/Skeleton3D
@onready var Anim_tree = $AnimationTree



var Walk_speed = 5.0
var Run_speed = 10
var Movement_Speed = 0
const JUMP_VELOCITY = 25
var acceleration = 5
var angular_accel = 7

var direction = Vector3.BACK
var strafe_dir = Vector3.ZERO
var strafe = Vector3.ZERO

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 50

func _unhandled_input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()


func _physics_process(delta):
	
	var h_rot = $Camroot/H_rot.global_transform.basis.get_euler().y
	
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		

	if Input.is_action_pressed("Aim"):
		Anim_tree.set("parameters/Aim_Anim/transition_request", "Aiming")
	else :
		Anim_tree.set("parameters/Aim_Anim/transition_request", "Not_Aiming")
	# As good practice, you should replace UI actions with custom gameplay actions.
	if Input.is_action_pressed("ui_left") ||  Input.is_action_pressed("ui_right") || Input.is_action_pressed("ui_up") || Input.is_action_pressed("ui_down"):
		var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y))
		
		strafe_dir = direction
		
		direction = direction.rotated(Vector3.UP, h_rot).normalized()

		if Input.is_action_pressed("Sprint") && Anim_tree.get("parameters/Aim_Anim/current_state") == "Not_Aiming":
			Movement_Speed = Run_speed
		else:
			Movement_Speed = Walk_speed
	else:
		Movement_Speed = 0
		strafe_dir = Vector3.ZERO
		
		if Anim_tree.get("parameters/Aim_Anim/current_state") == "Aiming":
			direction = $Camroot/H_rot.global_transform.basis.z 
		
	velocity = lerp(velocity, direction * Movement_Speed, delta * acceleration )
	
	move_and_slide()
	
	if Anim_tree.get("parameters/Aim_Anim/current_state") == "Not_Aiming":
		player.rotation.y = lerp_angle(player.rotation.y, atan2(direction.x, direction.z) - rotation.y, delta * angular_accel)
	else :
		player.rotation.y = lerp_angle(player.rotation.y, $Camroot/H_rot.rotation.y, delta * angular_accel) 
	
	strafe = lerp(strafe, strafe_dir, delta * acceleration)
	Anim_tree.set("parameters/Strafe/blend_position", Vector2(-strafe.x, strafe.z))
