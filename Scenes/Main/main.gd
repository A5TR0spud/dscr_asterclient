extends Control
class_name Main

@export var websocket_url: String = "wss://dscr-relay.dixonary.co.uk"
var socket: WebSocketPeer = WebSocketPeer.new()

const MaxMessageLength: int = 2000
const He6HalfLife: float = 0.8067
const CHANNEL_LEAVE: int = -65533
const CHANNEL_JOIN: int = -65534
const CHANNEL_AT: int = -65535
const SKELETON_KEY: int = -65536

@onready var CallsignNode: CallsignSelector = $MarginContainer/MainContainer/Body/Sidebar/CallsignContainer/CallsignEdit
var Callsign: int = 0:
	set(value):
		if value < 0:
			value += 4096
		value = value % 4096
		CallsignNode.CALLSIGN = value
		Callsign = value
var previous_state = null

var PreviouslyAcceptedCallsign: int = -1

var ConnectedUsers: Array[int] = []
@onready var TimeoutTime: Timer = $TimeoutTime
@onready var ReconnectTime: Timer = $ReconnectTime
@onready var ReconnectCD: Timer = $ReconnectCooldown

static var instance : Main

signal ReloadDict
signal ReloadSettings
static var NEW_THEME = preload("uid://c0reghmcwiqpy")
static func OnDictReload() -> void:
	instance.ReloadDict.emit()
static func OnSettingsReload() -> void:
	NEW_THEME.default_font_size = SettingsHandler.FontSize
	instance.ReloadSettings.emit()

signal ConnectedUserChange

func _enter_tree() -> void:
	instance = self

var TRYING_TO_QUIT: bool = false

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if socket.get_ready_state() == WebSocketPeer.STATE_CLOSED:
			KillProcess()
			return
		TRYING_TO_QUIT = true
		socket.close(1001)
		# if it can't close properly in 10 seconds then just shut it down anyway
		get_tree().create_timer(10).timeout.connect(KillProcess)

func KillProcess():
	get_tree().quit()

func _ready():
	SaveSystem.Load()
	TRYING_TO_QUIT = false
	get_tree().set_auto_accept_quit(false)
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

var _queuedCallsign: Array = [0, false]

func CallsignSet(cs: int, IsReconnect: bool = false) -> void:
	for i in ConnectedUsers:
		if i == cs and i != PreviouslyAcceptedCallsign:
			cs += 1
			cs %= 4096
	_queuedCallsign = [cs, IsReconnect]

func StartConnect(IsReconnectAttempt: bool = false) -> void:
	if TRYING_TO_QUIT: return
	if IsReconnectAttempt:
		print("Attempting Reconnect")
	else:
		if SettingsHandler.PreferredCallsign <= 4095 and SettingsHandler.PreferredCallsign >= 0:
			CallsignSet(SettingsHandler.PreferredCallsign)
		else:
			CallsignSet(randi_range(0, 4095))
	# Initiate connection to the given URL.
	var err = socket.connect_to_url(websocket_url)
	if err == OK:
		Chat.NewLog(Chat.State.Connecting)
		TimeoutTime.start()
		print("Connecting to %s..." % websocket_url)
		set_physics_process(true)
	else:
		push_error("Unable to connect.")
		Chat.NewLog(Chat.State.FailedToConnect)
		set_physics_process(false)

func SendMessage(written: String) -> bool:
	var sig: Array[int] = DictionaryHandler.ParseTextToSignals(written)
	if sig.size() == 0:
		return false
	var strig: Array = sig.map(func (a): return str(a)) as Array[String]
	strig.insert(0, "M")
	var o: String = ",".join(strig)
	if o and socket.send_text(o) == Error.OK:
		return true
	return false

func HandlePacket(incoming: String) -> void:
	print("< Got string data from server: %s" % incoming)
	var Status: PackedStringArray = incoming.split(",")
	if Status[0] == "K":
		PreviouslyAcceptedCallsign = Status[1].to_int()
		Callsign = PreviouslyAcceptedCallsign
		return
	if Status[0] == "U":
		Callsign += 1
		CallsignSet(Callsign, false)
		return
	if Status[0] == "R":
		Chat.NewTransmission(Status.slice(1))
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
			Chat.NewLog(Chat.State.Disconnecting)
			print("CLOSING")
		elif state == WebSocketPeer.STATE_CONNECTING:
			print("CONNECTING")
		elif state == WebSocketPeer.STATE_OPEN:
			Chat.NewLog(Chat.State.Connected)
			TimeoutTime.stop()
			ReconnectTime.stop()
			print("OPEN")
		else:
			print("OTHER STATE: %d", state)

	# Not open yet, but created.
	if state == WebSocketPeer.STATE_CONNECTING:
		pass

	# `WebSocketPeer.STATE_OPEN` means the socket is connected and ready
	# to send and receive data.
	elif state == WebSocketPeer.STATE_OPEN:
		if _queuedCallsign.size() > 0:
			Callsign = _queuedCallsign[0]
			print("Callsign: %s" % Callsign)
			var m: String = str("S,%s" % Callsign)
			if _queuedCallsign[1]:
				m += ",0"
			socket.send_text(m)
			_queuedCallsign = []
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
		if code == -1:
			Chat.NewLog(Chat.State.FailedToConnect)
		else:
			Chat.NewLog(Chat.State.Disconnected)
		print("WebSocket closed with code: %d. Clean: %s" % [code, code != -1])
		set_physics_process(false) # Stop processing.
		if TRYING_TO_QUIT:
			KillProcess()
			return
		if ReconnectCD.is_stopped():
			Chat.NewLog(Chat.State.WillAutoReconnectSoon, [roundi(ReconnectTime.wait_time / He6HalfLife)])
			ReconnectTime.start()
	previous_state = state

func _on_dictionary_save_open_pressed():
	SaveSystem.LoadDict()
	SaveSystem.OpenSaveLocation()

func _on_dsve_button_pressed():
	OS.shell_open("https://dsve.akqqa.dev/")

func _on_callsign_edit_callsign_submitted(newValue: int) -> void:
	Callsign = newValue
	SettingsHandler.PreferredCallsign = newValue
	SettingsHandler.Save()
	CallsignSet(Callsign, false)

func _on_timeout_time_timeout():
	if socket.get_ready_state() == WebSocketPeer.STATE_CONNECTING:
		print("Timed out...")
		socket.close(-1)

func _on_reconnect_time_timeout():
	if socket.get_ready_state() == WebSocketPeer.STATE_CLOSED and ReconnectCD.is_stopped():
		print("Attempting auto-reconnect...")
		ReconnectCD.start()
		StartConnect()
