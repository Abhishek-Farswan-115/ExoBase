extends CharacterBody3D


const JUMP_VELOCITY = 25

var Walk_speed = 5.0
var Run_speed = 10
var Movement_Speed = 0
var acceleration = 5
var angular_accel = 7

var direction = Vector3.BACK
var strafe_dir = Vector3.ZERO
var strafe = Vector3.ZERO

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 50

@onready var player = $Armature/Skeleton3D
@onready var Anim_tree = $AnimationTree


func _ready():
	Anim_tree.set("active", true)
	Anim_tree.set("parameters/Aim_Anim/transition_request", "Not_Aiming")


func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_dir:
		direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y))
		
		strafe_dir = direction
		
		var h_rot: float = $Camroot/H_rot.global_transform.basis.get_euler().y
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
	
	velocity = lerp(velocity, direction * Movement_Speed, delta * acceleration)
	Anim_tree.set("parameters/Idle_Walk_Run/blend_amount", velocity.length() / Run_speed * 2 - 1)
	
	if Anim_tree.get("parameters/Aim_Anim/current_state") == "Aiming":
		player.rotation.y = $Camroot/H_rot.rotation.y + deg_to_rad(180) 
		direction = $Camroot/H_rot.global_transform.basis.z 
	elif input_dir:
		player.rotation.y = lerp_angle(player.rotation.y, atan2(direction.x, direction.z) - rotation.y, delta * angular_accel)
	
	strafe = lerp(strafe, strafe_dir, delta * acceleration)
	Anim_tree.set("parameters/Strafe/blend_position", Vector2(strafe.x, -strafe.z))
	
	move_and_slide()


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	elif event.is_action_pressed("Aim"):
		Anim_tree.set("parameters/Aim_Anim/transition_request", "Aiming")
	elif event.is_action_released("Aim"):
		Anim_tree.set("parameters/Aim_Anim/transition_request", "Not_Aiming")
