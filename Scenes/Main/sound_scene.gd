extends Node
class_name SoundManager

static var instance: SoundManager

@onready var notification_sound: AudioStreamPlayer = $notification
@onready var cancel_or_close: AudioStreamPlayer = $cancel_close
@onready var open_ui: AudioStreamPlayer = $open_ui
@onready var fail_or_redundant: AudioStreamPlayer = $fail_redundant
@onready var confirm_or_success: AudioStreamPlayer = $confirm_success
@onready var message_send: AudioStreamPlayer = $message_send
@onready var command_send: AudioStreamPlayer = $command_send
@onready var click: AudioStreamPlayer = $click

enum Sounds {
	NOTIFICATION,
	CLICK,
	CANCEL,
	DISCARD,
	CLOSE_UI,
	OPEN_UI,
	FAIL,
	REDUNDANT,
	CONFIRMED,
	SUCCESS,
	MESSAGE_SENT,
	COMMAND_ACCEPTED
}

func _enter_tree():
	instance = self

static func play_sound(sound_id: Sounds) -> void:
	instance._play_sound(sound_id)

func _play_sound(sound_id: Sounds) -> void:
	match sound_id:
		Sounds.NOTIFICATION:
			notification_sound.play()
		Sounds.CLICK:
			click.play()
		Sounds.CANCEL:
			if confirm_or_success.playing or fail_or_redundant.playing:
				return
			cancel_or_close.play()
		Sounds.DISCARD:
			cancel_or_close.play()
		Sounds.CLOSE_UI:
			cancel_or_close.play()
		Sounds.OPEN_UI:
			open_ui.play()
		Sounds.FAIL:
			fail_or_redundant.play()
		Sounds.REDUNDANT:
			fail_or_redundant.play()
		Sounds.CONFIRMED:
			confirm_or_success.play()
		Sounds.SUCCESS:
			confirm_or_success.play()
		Sounds.MESSAGE_SENT:
			message_send.play()
		Sounds.COMMAND_ACCEPTED:
			message_send.play()
