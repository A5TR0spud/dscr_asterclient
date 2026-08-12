extends Control
class_name Main

@export var websocket_url: String = "wss://dscr-relay.dixonary.co.uk"
var socket: WebSocketPeer = WebSocketPeer.new()

const MAX_MESSAGE_LENGTH: int = 2000
const HE6_HALF_LIFE: float = 0.8067
const CHANNEL_LEAVE: int = -65533
const CHANNEL_JOIN: int = -65534
const CHANNEL_AT: int = -65535
const SKELETON_KEY: int = -65536

@onready var callsign_node: CallsignSelector = $MarginContainer/MainContainer/Body/Sidebar/CallsignContainer/CallsignEdit
var callsign: int = 0:
	set(value):
		if value < 0:
			value += 4096
		value = value % 4096
		callsign_node.callsign = value
		callsign = value
var previous_state = null

var previously_accepted_callsign: int = -1

var connected_users: Array[int] = []
@onready var timeout_time: Timer = $TimeoutTime
@onready var reconnect_time: Timer = $ReconnectTime
@onready var reconnect_cooldown: Timer = $ReconnectCooldown

static var instance : Main

signal reload_dict
signal reload_settings
static var new_theme = preload("uid://c0reghmcwiqpy")
static func on_dict_reload() -> void:
	instance.reload_dict.emit()
static func on_settings_reload() -> void:
	new_theme.default_font_size = SettingsHandler.font_size
	instance.reload_settings.emit()

signal connected_user_change

func _enter_tree() -> void:
	instance = self

var trying_to_quit: bool = false

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if socket.get_ready_state() == WebSocketPeer.STATE_CLOSED:
			kill_process()
			return
		trying_to_quit = true
		socket.close(1001)
		# if it can't close properly in 10 seconds then just shut it down anyway
		get_tree().create_timer(10).timeout.connect(kill_process)

func kill_process():
	get_tree().quit()

func _ready():
	SaveSystem.load()
	trying_to_quit = false
	get_tree().set_auto_accept_quit(false)
	start_connect()

static func get_callsign_color(value: int) -> Color:
	var hue: float = fmod(137.5 * value, 360) / 360.0;
	return _hsl_to_color(hue, 1.0, 0.7)

static func _hsl_to_color(h: float, s: float, l: float) -> Color:
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
		r = _hue_to_rgb(p, q, h + 1./3.)
		g = _hue_to_rgb(p, q, h)
		b = _hue_to_rgb(p, q, h - 1./3.)
	return Color(r, g, b)

static func _hue_to_rgb(p: float, q: float, t: float) -> float:
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

var _queued_callsign: Array = [0, false]

func set_callsign(cs: int, is_reconnect: bool = false) -> void:
	for i in connected_users:
		if i == cs and i != previously_accepted_callsign:
			cs += 1
			cs %= 4096
	_queued_callsign = [cs, is_reconnect]

func start_connect(is_reconnect_attempt: bool = false) -> void:
	if trying_to_quit: return
	if is_reconnect_attempt:
		print("Attempting Reconnect")
	else:
		if SettingsHandler.preferred_callsign <= 4095 and SettingsHandler.preferred_callsign >= 0:
			set_callsign(SettingsHandler.preferred_callsign)
		else:
			set_callsign(randi_range(0, 4095))
	# Initiate connection to the given URL.
	var err = socket.connect_to_url(websocket_url)
	if err == OK:
		Chat.new_log(Chat.State.CONNECTING)
		timeout_time.start()
		print("Connecting to %s..." % websocket_url)
		set_physics_process(true)
	else:
		push_error("Unable to connect.")
		Chat.new_log(Chat.State.FAILED_TO_CONNECT)
		set_physics_process(false)

func send_message(written: String) -> bool:
	var sig: Array[int] = DictionaryHandler.parse_text_to_signals(written)
	if sig.size() == 0:
		return false
	var strig: Array = sig.map(func (a): return str(a)) as Array[String]
	strig.insert(0, "M")
	var o: String = ",".join(strig)
	if o and socket.send_text(o) == Error.OK:
		return true
	return false

func handle_packet(incoming: String) -> void:
	print("< Got string data from server: %s" % incoming)
	var status: PackedStringArray = incoming.split(",")
	if status[0] == "K":
		previously_accepted_callsign = status[1].to_int()
		callsign = previously_accepted_callsign
		return
	if status[0] == "U":
		callsign += 1
		set_callsign(callsign, false)
		return
	if status[0] == "R":
		Chat.new_transmission(status.slice(1))
		return
	if status[0] == "C":
		connected_users.clear()
		for i in status.slice(1):
			connected_users.append(i.to_int())
		emit_signal("connected_user_change")
		return
	print("UNKNOWN STRING PACKET: %s" % incoming)

static func base_10_to_callsign(num: int) -> String:
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
			Chat.new_log(Chat.State.DISCONNECTING)
			print("CLOSING")
		elif state == WebSocketPeer.STATE_CONNECTING:
			print("CONNECTING")
		elif state == WebSocketPeer.STATE_OPEN:
			Chat.new_log(Chat.State.CONNECTED)
			timeout_time.stop()
			reconnect_time.stop()
			print("OPEN")
		else:
			print("OTHER STATE: %d", state)

	# Not open yet, but created.
	if state == WebSocketPeer.STATE_CONNECTING:
		pass

	# `WebSocketPeer.STATE_OPEN` means the socket is connected and ready
	# to send and receive data.
	elif state == WebSocketPeer.STATE_OPEN:
		if _queued_callsign.size() > 0:
			callsign = _queued_callsign[0]
			print("Callsign: %s" % callsign)
			var m: String = str("S,%s" % callsign)
			if _queued_callsign[1]:
				m += ",0"
			socket.send_text(m)
			_queued_callsign = []
		while socket.get_available_packet_count():
			var packet = socket.get_packet()
			if socket.was_string_packet():
				handle_packet(packet.get_string_from_utf8())
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
			Chat.new_log(Chat.State.FAILED_TO_CONNECT)
		else:
			Chat.new_log(Chat.State.DISCONNECTED)
		print("WebSocket closed with code: %d. Clean: %s" % [code, code != -1])
		set_physics_process(false) # Stop processing.
		if trying_to_quit:
			kill_process()
			return
		if reconnect_cooldown.is_stopped():
			Chat.new_log(Chat.State.WILL_AUTO_RECONNECT_SOON, [roundi(reconnect_time.wait_time / HE6_HALF_LIFE)])
			reconnect_time.start()
	previous_state = state

func _on_dictionary_save_open_pressed():
	SaveSystem.load_dict()
	SaveSystem.open_save_location()

func _on_dsve_button_pressed():
	OS.shell_open("https://dsve.akqqa.dev/")

func _on_callsign_edit_callsign_submitted(new_value: int) -> void:
	callsign = new_value
	SettingsHandler.preferred_callsign = new_value
	SettingsHandler.save()
	set_callsign(callsign, false)

func _on_timeout_time_timeout():
	if socket.get_ready_state() == WebSocketPeer.STATE_CONNECTING:
		print("Timed out...")
		socket.close(-1)

func _on_reconnect_time_timeout():
	if socket.get_ready_state() == WebSocketPeer.STATE_CLOSED and reconnect_cooldown.is_stopped():
		print("Attempting auto-reconnect...")
		reconnect_cooldown.start()
		start_connect()
