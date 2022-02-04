extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var insideId : int = 0
var inside : Node = null
var meInside : bool = false

var maxSpeed : float = 2000.0
var speedStep : float = 500.0
var speed : float = 0.0

var turnSpeed : float = 100.0
var pitchSpeed : float = 100.0

var takeOffSpeed : float = 500.0

onready var camera : Camera = $Camera

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

remotesync func addPlayer(playerId):
	if inside == null:
		insideId = playerId
		var player = get_parent().get_node(str(playerId))
		inside = player
		player.get_parent().remove_child(player)

func engage(player):
	if inside == null:
		rpc("addPlayer", player.get_network_master())
		camera.set_current(true)
		meInside = true

func _physics_process(delta):
	if meInside:
		if Input.is_action_pressed("accelerate"):
			speed = min(speed+speedStep*delta, maxSpeed)
		elif Input.is_action_pressed("deccelerate"):
			speed = max(speed-speedStep*delta, 0)
			
		if Input.is_action_pressed("move_left"):
			rotation_degrees.y += delta * turnSpeed
		elif Input.is_action_pressed("move_right"):
			rotation_degrees.y -= delta * turnSpeed
		
		if speed >= takeOffSpeed or !is_on_floor():
			if Input.is_action_pressed("pitch_up"):
				rotation_degrees.x -= delta * pitchSpeed
			elif Input.is_action_pressed("pitch_down"):
				rotation_degrees.x += delta * pitchSpeed
		
		var forward = global_transform.basis.z
		var right = global_transform.basis.x
		
		var velocity = delta * speed * forward
		
		if speed < 100.0:
			velocity.y = -12 * delta
			
		move_and_slide(velocity, Vector3.UP)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
