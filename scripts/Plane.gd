extends KinematicBody

var insideId : int = 0
var inside : Node = null
var meInside : bool = false

var maxSpeed : float = 500.0
var speedStep : float = 100.0
var speed : float = 0.0
var velocity : Vector3 = Vector3()
var gravity : float = -40

var turnSpeed : float = 100.0
var pitchSpeed : float = 100.0

var takeOffSpeed : float = 500.0

onready var camera : Camera = $Camera

func _ready():
	# Set network master to host system
	set_network_master(1)

remotesync func addPlayer(playerId):
	if inside == null:
		insideId = playerId
		var player = get_parent().get_node(str(playerId))
		inside = player
		player.get_parent().remove_child(player)
		player.vehicle = self
		
func removeFromVeh():
	if inside != null:
		insideId = 0
		var player = inside
		inside = null
		player.vehicle = null
		get_parent().add_child(player)
		speed = 0
		return player
	return null
		
remotesync func removePlayer(_playerId):
	if inside != null:
		var player = removeFromVeh()
		player.rpc("removeVeh", translation)
		
remotesync func setControl(_position, vel, rot):
	velocity = vel
	rotation_degrees = rot

remote func setPos(position, newVelocity, rotation):
	translation = position
	rotation_degrees = rotation
	velocity = newVelocity

func engage(player):
	if inside == null:
		rpc("addPlayer", player.get_network_master())
		camera.set_current(true)
		meInside = true

func _physics_process(delta):
	if meInside:
		var newRotation = rotation_degrees
		if Input.is_action_pressed("accelerate"):
			speed = min(speed+speedStep*delta, maxSpeed)
		elif Input.is_action_pressed("deccelerate"):
			speed = max(speed-speedStep*delta, 0)
			
		if Input.is_action_pressed("move_left"):
			newRotation.y += delta * turnSpeed
		elif Input.is_action_pressed("move_right"):
			newRotation.y -= delta * turnSpeed
		
		if speed >= takeOffSpeed or !is_on_floor():
			if Input.is_action_pressed("pitch_up"):
				newRotation.x -= delta * pitchSpeed
			elif Input.is_action_pressed("pitch_down"):
				newRotation.x += delta * pitchSpeed
		
		var forward = global_transform.basis.z
		var _right = global_transform.basis.x
		
		var newVelocity = speed * forward
		
		rpc_id(1, "setControl", translation, newVelocity, newRotation)
	
	if is_network_master():
		var newVelocity = velocity
		
		if speed < 100.0:
			newVelocity.y = velocity.y + gravity * delta
			
		velocity = move_and_slide(newVelocity, Vector3.UP)
		
		rpc("setPos", translation, velocity, rotation_degrees)

func _process(_delta):
	if meInside:
		if Input.is_action_just_pressed("interact"):
			rpc("removePlayer", inside.get_network_master())
			camera.set_current(false)
			meInside = false
