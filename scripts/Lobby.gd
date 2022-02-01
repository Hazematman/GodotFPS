extends Node2D

export var maxPlayers : int = 4
export var defaultPort : int = 5678

var currentPort : int = defaultPort
var currentIp : String = ""

onready var servBut = get_node("createServerButton")
onready var clientBut = get_node("joinServerButton")
onready var ipEdit = get_node("serverIPLabel/serverIPEdit")
onready var portEdit = get_node("serverPortLabel/serverPortEdit")

func get_port():
	var port = int(portEdit.text)
	currentPort = port

func get_ip():
	currentIp = ipEdit.text
	
func set_callbacks():
	# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_connected", self, "_player_connected")

# Called when the node enters the scene tree for the first time.
func _ready():
	portEdit.text = str(defaultPort)
	
	clientBut.connect("button_down", self, "_on_clientBut_pressed")
	servBut.connect("button_down", self, "_on_servBut_pressed")

func _on_servBut_pressed():
	get_port()
	Networking.create_server(currentPort, maxPlayers)
	
func _on_clientBut_pressed():
	get_port()
	get_ip()
	Networking.join_server(currentIp, currentPort)

func _player_connected(id):
	print("Player joined %d" % id)
