extends Node3D

var camrot_h = 0.0
var camrot_v = 0.0
var cam_v_max = 75.0
var cam_v_min = -55.0
@onready var cam_sensitivity = 0.5


@onready var Camera = $H_rot/V_Rot/CameraSpring/Camera3D

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass # Replace with function body.


func _input(event):
	if event is InputEventMouseMotion:
		camrot_h += -event.relative.x * cam_sensitivity
		camrot_v += -event.relative.y * cam_sensitivity

func _physics_process(delta):
	camrot_v = clamp(camrot_v, cam_v_min, cam_v_max)
	
	$H_rot.rotation_degrees.y = camrot_h
	$H_rot/V_Rot.rotation_degrees.x = camrot_v
