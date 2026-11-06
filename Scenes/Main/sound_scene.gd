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
@onready var party_horn: AudioStreamPlayer = $party_horn
@onready var ping: AudioStreamPlayer = $ping

enum Sounds {
	NONE,
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
	COMMAND_ACCEPTED,
	PING,
	# sourced from https://pixabay.com/sound-effects/film-special-effects-birthday-party-horn-250238/
	# for free
	# uploaded by Universfield
	PARTY_HORN
}

func _enter_tree():
	instance = self

static func play_sound(sound_id: Sounds, avoid_overlap: bool = false) -> void:
	instance._play_sound(sound_id, avoid_overlap)

func _play_sound(sound_id: Sounds, avoid_overlap: bool = false) -> void:
	if AudioServer.is_bus_mute(AudioServer.get_bus_index("Master")):
		return
	var sound_to_play: AudioStreamPlayer = null
	match sound_id:
		Sounds.NONE:
			return
		Sounds.NOTIFICATION:
			sound_to_play = notification_sound
		Sounds.CLICK:
			sound_to_play = click
		Sounds.CANCEL:
			if confirm_or_success.playing or fail_or_redundant.playing:
				return
			sound_to_play = cancel_or_close
		Sounds.DISCARD:
			sound_to_play = cancel_or_close
		Sounds.CLOSE_UI:
			sound_to_play = cancel_or_close
		Sounds.OPEN_UI:
			sound_to_play = open_ui
		Sounds.FAIL:
			sound_to_play = fail_or_redundant
		Sounds.REDUNDANT:
			sound_to_play = fail_or_redundant
		Sounds.CONFIRMED:
			sound_to_play = confirm_or_success
		Sounds.SUCCESS:
			sound_to_play = confirm_or_success
		Sounds.MESSAGE_SENT:
			sound_to_play = message_send
		Sounds.COMMAND_ACCEPTED:
			sound_to_play = message_send
		Sounds.PARTY_HORN:
			party_horn.pitch_scale = randf_range(1.45, 1.55)
			sound_to_play = party_horn
		Sounds.PING:
			sound_to_play = ping
	if sound_to_play.playing and avoid_overlap:
		return
	sound_to_play.play()
