extends KinematicBody

var mouseRelative : Vector2 = Vector2()
var minLookAngle : float = -90.0
var maxLookAngle : float = 90.0
var lookSensitivity : float = 10.0

var gravity : float = 12.0

var speed : float = 1000.0
var velocity : Vector3 = Vector3()

onready var camera = $camera

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		mouseRelative = event.relative
	elif Input.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif Input.is_action_pressed("fire"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	var forward = global_transform.basis.z
	var right = global_transform.basis.x
	
	velocity.x = 0
	velocity.z = 0
	
	var movementDir = Vector3()
	if Input.is_action_pressed("move_forward"):
		movementDir.z = -1
	elif Input.is_action_pressed("move_backward"):
		movementDir.z = 1
	
	if Input.is_action_pressed("move_right"):
		movementDir.x = 1
	elif Input.is_action_pressed("move_left"):
		movementDir.x = -1
		
	movementDir = (movementDir.z * forward) + (movementDir * right)
	movementDir = movementDir.normalized()
	
	
	
	var movementSpeed = speed * delta * movementDir
	
	velocity.x = movementSpeed.x
	velocity.z = movementSpeed.z
	velocity.y -= gravity * delta
	
	velocity = move_and_slide(velocity, Vector3.UP)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# rotate the camera along the x axis
	camera.rotation_degrees.x -= mouseRelative.y * lookSensitivity * delta
	# clamp camera x rotation axis
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, minLookAngle, maxLookAngle)
	# rotate the player along their y-axis
	rotation_degrees.y -= mouseRelative.x * lookSensitivity * delta
	# reset the mouseDelta vector
	mouseRelative = Vector2()
