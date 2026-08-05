extends Control
class_name Main

@export var websocket_url: String = "wss://dscr-relay.dixonary.co.uk"
var socket: WebSocketPeer = WebSocketPeer.new()
const MaxMessageLength: int = 2000

const He6HalfLife: float = 0.8067 #about 121/150
const CHANNEL_LEAVE: int = -65533
const CHANNEL_JOIN: int = -65534
const CHANNEL_AT: int = -65535
const SKELETON_KEY: int = -65536

@onready var CallsignNode: CallsignSelector =  $MarginContainer/MainContainer/Body/Sidebar/CallsignContainer/CallsignEdit
var Callsign: int = 0:
	set(value):
		if value < 0:
			value += 4096
		value = value % 4096
		CallsignNode.CALLSIGN = value
		Callsign = value
var NeedCallsign: bool = true
var previous_state: WebSocketPeer.State = WebSocketPeer.STATE_CLOSED

@onready var ChatBody: VBoxContainer = $MarginContainer/MainContainer/Body/Chat/MarginContainer/ScrollContainer/MarginContainer/ChatDisplay
@onready var ChatScroll: ScrollContainer = $MarginContainer/MainContainer/Body/Chat/MarginContainer/ScrollContainer

var ConnectedUsers: Array[int] = []

static var instance : Main

signal ReloadDict
signal ConnectedUserChange

func _enter_tree() -> void:
	instance = self

func _ready():
	SaveSystem.LoadDict()
	StartConnect()

static func GetCallsignColor(value: int) -> Color:
	var hue: float = fmod(137.5 * value, 360) / 360.0;
	return _hslToCol(hue, 1.0, 0.7)

static func _hslToCol(h: float, s: float, l: float) -> Color:
	var r: float
	var g: float
	var b: float
	if s == 0.0:
		r = l
		g = l
		b = l
	else:
		var q := l * (1 + s) if l < 0.5 else l + s - (l * s)
		var p := 2 * l - q
		r = _hueToRgb(p, q, h + 1./3.)
		g = _hueToRgb(p, q, h)
		b = _hueToRgb(p, q, h - 1./3.)
	return Color(r, g, b)

static func _hueToRgb(p: float, q: float, t: float) -> float:
	if (t < 0):
		t += 1
	if (t > 1):
		t -= 1
	if (t < 1./6.):
		return (q - p) * 6 * t + p
	if (t < 0.5):
		return q
	if (t < 2./3.):
		return (q - p) * (2./3. - t) * 6 + p
	return p

func StartConnect() -> void:
	NeedCallsign = true
	Callsign = randi_range(0, 4095)
	#TODO: save and load callsign to settings.json
	# Initiate connection to the given URL.
	var err = socket.connect_to_url(websocket_url)
	if err == OK:
		print("Connecting to %s..." % websocket_url)
		set_physics_process(true)
	else:
		push_error("Unable to connect.")
		set_physics_process(false)

var Trx = preload("res://Scenes/transmission_entry.tscn")

func RenderNewMessage(incoming: PackedStringArray) -> void:
	var newMessage: TransEntry = Trx.instantiate()
	newMessage.Timestamp = Time.get_ticks_msec()
	newMessage.Sender = incoming[0].to_int()
	newMessage.Trans = incoming[1].to_int()
	var o: Array[int] = []
	for s in incoming.slice(2):
		o.append(s.to_int())
	newMessage.Message = o
	ChatBody.add_child(newMessage)
	#TODO: autoscroll

func HandlePacket(incoming: String) -> void:
	var Status: PackedStringArray = incoming.split(",")
	if Status[0] == "K":
		Callsign = Status[1].to_int()
		return
	if Status[0] == "U":
		Callsign += 1
		NeedCallsign = true
		return
	if Status[0] == "R":
		RenderNewMessage(Status.slice(1))
		return
	if Status[0] == "C":
		ConnectedUsers.clear()
		for i in Status.slice(1):
			ConnectedUsers.append(i.to_int())
		emit_signal("ConnectedUserChange")
		return
	print("UNKNOWN STRING PACKET: %s" % incoming)

static func base10ToCallsign(num: int) -> String:
	var o: String = String.num_int64(num, 8)
	while o.length() < 4:
		o = "0" + o
	return o

func _physics_process(_delta):
	# Call this in `_process()` or `_physics_process()`.
	# Data transfer and state updates will only happen when calling this function.
	socket.poll()

	# get_ready_state() tells you what state the socket is in.
	var state: WebSocketPeer.State = socket.get_ready_state()
	if state != previous_state:
		if state == WebSocketPeer.STATE_CLOSED:
			print("CLOSED")
		elif state == WebSocketPeer.STATE_CLOSING:
			print("CLOSING")
		elif state == WebSocketPeer.STATE_CONNECTING:
			print("CONNECTING")
		elif state == WebSocketPeer.STATE_OPEN:
			print("OPEN")
		else:
			print("OTHER STATE: %d", state)

	# Not open yet, but created.
	if state == WebSocketPeer.STATE_CONNECTING:
		pass

	# `WebSocketPeer.STATE_OPEN` means the socket is connected and ready
	# to send and receive data.
	elif state == WebSocketPeer.STATE_OPEN:
		if NeedCallsign:
			print("Callsign: %s" % Callsign)
			socket.send_text(str("S,%s" % Callsign))
			NeedCallsign = false
		#socket.send_text("Test packet")
		while socket.get_available_packet_count():
			var packet = socket.get_packet()
			if socket.was_string_packet():
				HandlePacket(packet.get_string_from_utf8())
			else:
				print("< Got binary data from server: %s" % str(packet.to_int64_array()))

	# `WebSocketPeer.STATE_CLOSING` means the socket is closing.
	# It is important to keep polling for a clean close.
	elif state == WebSocketPeer.STATE_CLOSING:
		pass

	# `WebSocketPeer.STATE_CLOSED` means the connection has fully closed.
	# It is now safe to stop polling.
	elif state == WebSocketPeer.STATE_CLOSED:
		# The code will be `-1` if the disconnection was not properly notified by the remote peer.
		var code = socket.get_close_code()
		print("WebSocket closed with code: %d. Clean: %s" % [code, code != -1])
		set_physics_process(false) # Stop processing.
	previous_state = state

func _on_dictionary_save_open_pressed():
	SaveSystem.OpenSaveLocation()

static func OnDictReload() -> void:
	instance._onDictReload()

func _onDictReload() -> void:
	ReloadDict.emit()

func _on_dsve_button_pressed():
	OS.shell_open("https://dsve.akqqa.dev/")

func _on_callsign_edit_callsign_submitted(newValue: int) -> void:
	Callsign = newValue
	NeedCallsign = true
