extends Node

var maxPlayers : int = 4
var currentIP : String =  ""
var currentPort : int = 5678

var connected : bool = false

var players = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	# warning-ignore:return_value_discarded
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	# warning-ignore:return_value_discarded
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	# warning-ignore:return_value_discarded
	get_tree().connect("connection_failed", self, "_connection_failed")
	# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_connected", self, "_player_connected")
	# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	
func reset_network_connection() -> void:
	if get_tree().has_network_peer():
		get_tree().network_peer = null

func create_server(port : int, players : int = 4) -> void:
	currentIP = "localhost"
	currentPort = port
	maxPlayers = players
	print("Creating Server at %d" % currentPort)
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(currentPort, maxPlayers)
	get_tree().network_peer = peer
	
func join_server(ip : String, port : int) -> void:
	currentIP = ip
	currentPort = port
	print("Joining Server at %s:%d" % [currentIP, currentPort])
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(currentIP, currentPort)
	get_tree().network_peer = peer

func _connected_to_server() -> void:
	connected = true

func _connection_failed() -> void:
	reset_network_connection()

func _server_disconnected() -> void:
	reset_network_connection()
	
func _player_connected(id) -> void:
	print("Player %d has connected" % id)
	
func _player_disconnected(id) -> void:
	pass
	
func instance_node_at_location(node: Object, parent: Object, location: Vector2) -> Object:
	var node_instance = instance_node(node, parent)
	node_instance.global_position = location
	return node_instance

func instance_node(node: Object, parent: Object) -> Object:
	var node_instance = node.instance()
	parent.add_child(node_instance)
	return node_instance
