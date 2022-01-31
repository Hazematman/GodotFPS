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
	get_tree().connect("network_peer_connected", self, "_player_connected")

# Called when the node enters the scene tree for the first time.
func _ready():
	servBut.connect("pressed", self, "_on_servBut_pressed")
	clientBut.connect("pressed", self, "_on_clientBut_pressed")
	portEdit.text = str(defaultPort)

func _on_servBut_pressed():
	get_port()
	print("Creating Server at %d" % currentPort)
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(currentPort, maxPlayers)
	get_tree().network_peer = peer
	set_callbacks()
	
func _on_clientBut_pressed():
	get_port()
	get_ip()
	print("Joining Server at %s:%d" % [currentIp, currentPort])
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(currentIp, currentPort)
	get_tree().network_peer = peer
	set_callbacks()

func _player_connected(id):
	print("Player joined %d" % id)
