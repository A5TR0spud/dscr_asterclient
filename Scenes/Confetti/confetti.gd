extends Control
class_name Confetti


static var instance: Confetti
@onready var cd: Timer = $Cooldown
@onready var lb: GPUParticles2D = $LeftBasic
@onready var lt: GPUParticles2D = $LeftTrails
@onready var rb: GPUParticles2D = $RightBasic
@onready var rt: GPUParticles2D = $RightTrails

func _enter_tree():
	instance = self

func _burst():
	if not Engine.is_editor_hint():
		if not instance.cd.is_stopped():
			return
		cd.start(12)
	show()
	for c in get_children():
		if c is GPUParticles2D:
			c.restart()
	if not get_window().has_focus():
		return
	SoundManager.play_sound(SoundManager.Sounds.PARTY_HORN)

static func burst():
	if not instance or not instance.is_node_ready():
		return
	instance._burst()

func _on_cooldown_timeout():
	hide()

func _on_item_rect_changed():
	if not is_node_ready():
		await ready
	lb.position = Vector2(0, get_viewport_rect().size.y)
	lt.position = Vector2(0, get_viewport_rect().size.y)
	rb.position = get_viewport_rect().size
	rt.position = get_viewport_rect().size

static func can_confetti() -> bool:
	return SettingsHandler.confetti and DictionaryHandler.support_dscr and -702 in DictionaryHandler.word_keys


const CONFETTI: int = -702
const DELIMIT: int = -2
const NIL: int = -111
const NOT: int = -29
const IS_OF: int = -99
const IS: int = -100
const AND: int = -30
const THEN: int = -36

static func evaluate_confetti(message: Array[int]) -> bool:
	if not can_confetti():
		return false
	var confetti_parser := TransmissionParser.new(message)
	while confetti_parser.can_continue():
		if not confetti_parser.skip_to(CONFETTI):
			break
		if confetti_parser.peek(-1) == NIL:
			confetti_parser.skip(2)
			continue
		if confetti_parser.peek(1) == NOT:
			confetti_parser.skip(2)
			continue
		if confetti_parser.peek(1) == IS_OF:
			confetti_parser.skip(2)
			continue
		if confetti_parser.peek(1) == IS:
			var p2 = confetti_parser.peek(2)
			if p2 is int and p2 != DELIMIT:
				confetti_parser.skip(3)
				continue
		var j: int = confetti_parser.save_state()
		var delimited_left: int = j
		var delimited_right: int = message.size() - 1 - j
		for i in range(1,4):
			if (
				((confetti_parser.peek(-i) == DELIMIT or confetti_parser.peek(-i) == THEN) and
				(confetti_parser.peek(-i - 1) == DELIMIT or -i - 1 + j < 0))
				or confetti_parser.peek(-i) == AND
			):
				delimited_left = i - 1
				break
		for i in range(1,4):
			if (
				(confetti_parser.peek(i) == DELIMIT and
				(confetti_parser.peek(i + 1) == DELIMIT or i + j + 1 >= message.size()))
				or confetti_parser.peek(i) == AND
			):
				delimited_right = i - 1
				break
		#print("l ", delimited_left, " r ", delimited_right)
		if delimited_right + delimited_left < 3:
			return true
		confetti_parser.skip()
	return false
