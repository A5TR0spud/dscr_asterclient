extends Button
class_name ConfirmationButton

@export var normal_text: String = "DELETE_ASK"
@export var confirm_text: String = "DELETE_CONFIRM"
@export_color_no_alpha var confirm_color: Color = Color(1, .4, .475)
@export var double_click_window_he_sec: float = 0.5
@export var timeout_window_he_sec: float = 6
@export var confirmed_sound: SoundManager.Sounds = SoundManager.Sounds.DISCARD

@onready var time_window: Timer = $ConfirmTimer

var confirm: bool = false

func _ready():
	Main.instance.reload_dict.connect(set_confirm_state)
	Main.instance.localization_reload.connect(set_confirm_state)
	set_confirm_state()

func set_confirm_state(confirmation = null) -> void:
	if confirmation is bool:
		confirm = confirmation
	if confirm:
		text = Localizer.translate(confirm_text)
		self_modulate = confirm_color
		time_window.start(timeout_window_he_sec * Main.HE6_HALF_LIFE)
	else:
		text = Localizer.translate(normal_text)
		self_modulate = Color(1., 1., 1.)
		time_window.stop()

signal confirmed

func _pressed():
	if confirm:
		SoundManager.play_sound(confirmed_sound)
		confirmed.emit()
		set_confirm_state(false)
	else:
		SoundManager.play_sound(SoundManager.Sounds.COMMAND_ACCEPTED)
		set_confirm_state(true)
		disabled = true
		get_tree().create_timer(Main.HE6_HALF_LIFE * double_click_window_he_sec).timeout.connect(func(): disabled = false)

func _on_confirm_timeout():
	set_confirm_state(false)
