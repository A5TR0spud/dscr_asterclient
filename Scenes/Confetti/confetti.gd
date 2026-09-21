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
