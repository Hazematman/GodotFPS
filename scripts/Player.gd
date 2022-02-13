extends KinematicBody

enum PlayerState {
	IDLE,
	WALKING,
	RUNNING,
	SHOOTING,
}

var mouseRelative : Vector2 = Vector2()
var minLookAngle : float = -90.0
var maxLookAngle : float = 90.0
var lookSensitivity : float = 10.0

export var gravity : float = 40
var maxAngle : float = 30.0
var jumpSpeed : float = 20

export var speed : float = 8.0
var sprintFactor : float = 2.0
var velocity : Vector3 = Vector3()

var bulletRange : float = 100.0
var interactRange : float = 1.0
var state = PlayerState.IDLE

var vehicle : Node = null

var jumping : bool = false

puppet var puppetPosition = Vector3()
puppet var puppetVelocity = Vector3()
puppet var puppetRotation = Vector3()
puppet var puppetLookRot : float = 0
puppet var puppetState = PlayerState.IDLE

onready var camera : Camera = $camera
onready var model : Node = $PlayerModel
onready var anims : AnimationPlayer = $PlayerModel/Animations
onready var backCtl : Position3D = $PlayerModel/Root/Skeleton/BackPos
onready var fpsModel : Node = $camera/rifle
onready var hud : Node = $Sprite

func _ready():
	if is_network_master():
		print("Master")
		camera.set_current(true)
		model.hide()
		
		# warning-ignore:return_value_discarded
		get_viewport().connect("size_changed", self, "resizeUI")
	else:
		camera.set_current(false)
		hud.hide()
		fpsModel.hide()
		print("Not master")
	
	puppetPosition = Vector3(0, 2.75, 0)

func _input(event):
	if is_network_master():
		if event is InputEventMouseMotion:
			mouseRelative = event.relative

func _physics_process(delta):
	if is_network_master():
		
		# Prevent player from walking up surfaces that are too steep
		var onSteep = false
		for i in get_slide_count():
			var collision = get_slide_collision(i)
			var angle = collision.normal.angle_to(Vector3.UP)
			if rad2deg(angle) > maxAngle:
				onSteep = true
				break
		
		var forward = global_transform.basis.z
		var right = global_transform.basis.x
		var speedMultipler = 1.0
		
		velocity.x = 0
		velocity.z = 0
		
		if jumping and is_on_floor():
			jumping = false
		
		var movementDir = Vector3()
		if Input.is_action_pressed("move_forward"):
			movementDir.z = -1
		elif Input.is_action_pressed("move_backward"):
			movementDir.z = 1
		
		if Input.is_action_pressed("move_right"):
			movementDir.x = 1
		elif Input.is_action_pressed("move_left"):
			movementDir.x = -1
			
		if Input.is_action_pressed("run"):
			speedMultipler = sprintFactor
			
		if Input.is_action_pressed("jump") and is_on_floor():
			velocity.y = jumpSpeed
			jumping = true
			
		if movementDir.length_squared() > 0:
			if speedMultipler == sprintFactor:
				state = PlayerState.RUNNING
			else:
				state = PlayerState.WALKING
		else:
			state = PlayerState.IDLE
			
		movementDir = (movementDir.z * forward) + (movementDir.x * right)
		movementDir = movementDir.normalized()
		
		var movementSpeed = speedMultipler * speed * movementDir
		
		if not onSteep:
			velocity.x = movementSpeed.x
			velocity.z = movementSpeed.z
		else:
			velocity.x = 0
			velocity.y = 0
			
		velocity.y -= gravity * delta
		
		
		var snap = Vector3.DOWN if not jumping else Vector3.ZERO
		velocity = move_and_slide_with_snap(velocity, snap, Vector3.UP, true, 4, deg2rad(maxAngle))

func _process(delta):
	if is_network_master():
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			# rotate the camera along the x axis
			camera.rotation_degrees.x -= mouseRelative.y * lookSensitivity * delta
			# clamp camera x rotation axis
			camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, minLookAngle, maxLookAngle)
			# rotate the player along their y-axis
			rotation_degrees.y -= mouseRelative.x * lookSensitivity * delta
			# reset the mouseDelta vector
			mouseRelative = Vector2()
			
			if Input.is_action_just_pressed("fire"):
				shoot()
			if Input.is_action_just_pressed("interact"):
				interact()
				return
		
		rset("puppetPosition", translation)
		rset("puppetVelocity", velocity)
		rset("puppetRotation", rotation_degrees)
		rset("puppetLookRot", camera.rotation_degrees.x)
		rset("puppetState", state)
	else:
		translation = puppetPosition
		rotation_degrees = puppetRotation
		velocity = puppetVelocity
		state = puppetState
		
		backCtl.rotation_degrees.x = -puppetLookRot
		
		if state == PlayerState.RUNNING:
			print("Running")
			anims.play("Run", -1, 2)
		elif state == PlayerState.WALKING:
			anims.play("Walk", -1, 2)
		else:
			anims.play("Idle")
		
func resizeUI():
	hud.position = 0.5 * get_viewport().get_size()
	
func castray(distance):
	var displayMid = 0.5 * (get_viewport().get_size())
	var space_state = get_world().direct_space_state
	var from = camera.project_ray_origin(displayMid)
	var to = from + camera.project_ray_normal(displayMid) * distance
	
	return space_state.intersect_ray(from, to)

func interact():
	var result = castray(interactRange)
	if result and result.collider.has_method("engage"):
		result.collider.engage(self)

func shoot():
	var result = castray(bulletRange)
	if result and result.collider.has_method("hit"):
		result.collider.hit()
		
remotesync func removeVeh(location):
	translation = location + Vector3(0, 3, 0)
