extends CharacterBody3D

@onready var springArmPivot = $SpringPivot
@onready var SpringArm = $SpringPivot/SpringArm3D
@onready var Armature = $Armature
@onready var Animtree = $AnimationTree

@export var Mouse_Sensitivity = 0.005



@export var RunSpeed = 10
@export var JUMP_VELOCITY = 4.5
@export var Walk_speed = 5

var lerpValue = 0.15

var strafe_dir = Vector3.ZERO
var strafe = Vector3.ZERO

var SPEED = 0


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	
	if event is InputEventMouseMotion:
		springArmPivot.rotate_y(-event.relative.x * Mouse_Sensitivity)
		SpringArm.rotate_x(-event.relative.y * Mouse_Sensitivity)
		SpringArm.rotation.x = clamp(SpringArm.rotation.x, -PI/4, PI/4)


func _physics_process(delta): 
	
	var front_rot = $SpringPivot.global_transform.basis.get_euler().y
	
	if Input.is_action_pressed("Aim"):
		Animtree.set("parameters/Aim_Anim/current_state", 0)
	
	else :
		Animtree.set("parameters/Aim_Anim/current_state", 1)
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	direction = direction.rotated(Vector3.UP, springArmPivot.rotation.y)
	
	strafe_dir = direction
	direction = direction.rotated(Vector3.UP, lerpValue).normalized()
	
	if direction:
		if Input.is_action_pressed("Sprint") && Animtree.get("parameters/Aim_Anim/current_state") == 1 :
			SPEED = RunSpeed
		else:
			SPEED = Walk_speed
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		if int(Animtree.get("parameters/Aim_Anim/current_state")) == 1 :
			Armature.rotation.y = lerp_angle(Armature.rotation.y, atan2(-velocity.x , -velocity.z), lerpValue)
		else :
			Armature.rotation.y = lerp_angle(Armature.rotation.y, front_rot, lerpValue)
	
	
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	strafe = lerp(strafe, strafe_dir, delta * lerpValue)
	Animtree.set("parameters/Strafe/blend_position", Vector2(-strafe.x, strafe.z))

	move_and_slide()
