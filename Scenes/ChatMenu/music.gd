extends AudioStreamPlayer

const sample_hz: float = 22050.0

@export var song_button: Node

var current_song: Array = []
var song_length: float = 0.0

var _build_thread: Thread = null

signal song_built

const NEG = -1
const SEP = -3
const DECIMAL = -10
const GROUP_BEGIN = -14
const GROUP_END = -15
const SONG = -577
const NOTE = -605003

func play_music() -> void:
	if is_playing():
		stop_music()
		return

	if current_song.size() > 0:
		play()
		(song_button as TranslatableSimple).message = [-577, -29]
		song_button.refresh()

func stop_music() -> void:
	stop()
	(song_button as TranslatableSimple).message = [-577]
	song_button.refresh()

func check_song(message: Array) -> bool:
	var message_len = message.size()
	var song_index = message.find(SONG)
	if song_index == -1 || message_len <= (song_index + 2):
		return false

	while song_index < (message_len - 1):
		if message[song_index + 1] != GROUP_BEGIN:
			song_index += 1
			continue
		var group_end = message.find(GROUP_END, song_index + 1)
		if group_end == -1:
			song_index += 1
			continue

		var song_notes = message.slice(song_index + 2, group_end)
		if song_notes.is_empty():
			song_index += 1
			continue
		current_song = _parse_song(song_notes)
		if current_song.is_empty():
			song_index += 1
			continue
		_start_build_song()
		song_button.disabled = true
		return true

	return false

func _start_build_song() -> void:
	if _build_thread != null and _build_thread.is_alive():
		_build_thread.wait_to_finish()
	
	_build_thread = Thread.new()
	_build_thread.start(_build_song.bind(current_song, song_length))
	pass

func _build_song(song: Array, length: float) -> void:
	var active_notes: Array = []
	var current_note: int = 0
	var playback_time: float = 0.0
	var sample_count: int = int(sample_hz * length)
	var time_step: float = 1.0 / sample_hz
	var wav_data: PackedByteArray = PackedByteArray()
	wav_data.resize(sample_count * 2 * 2)
	
	for i in range(sample_count):
		while current_note < song.size() and playback_time >= song[current_note].start_time:
			var note_data = song[current_note]
			var note = {
				"frequency": note_data.frequency,
				"phase": 0.0,
				"time_left": note_data.duration,
				"total_duration": note_data.duration
			}
			active_notes.append(note)
			current_note += 1
		
		var mixed_sample = 0.0
		
		var j = active_notes.size() - 1
		while j >= 0:
			var note = active_notes[j]
			
			var increment = note.frequency / sample_hz
			var sample = sin(note.phase * TAU)
			
			var volume_envelope = clamp(note.time_left / 0.05, 0.0, 1.0)
			mixed_sample += sample * 0.2 * volume_envelope
			
			note.phase = fmod(note.phase + increment, 1.0)
			note.time_left -= time_step
			
			if note.time_left <= 0:
				active_notes.remove_at(j)
			
			j -= 1

		mixed_sample = clamp(mixed_sample, -1.0, 1.0)
		var int_sample: int = int(mixed_sample * 32767.0)
		var byte_index: int = i * 4
		wav_data.encode_s16(byte_index, int_sample)
		wav_data.encode_s16(byte_index + 2, int_sample)
		playback_time += time_step
	
	var wav_stream: AudioStreamWAV = AudioStreamWAV.new()
	wav_stream.format = AudioStreamWAV.FORMAT_16_BITS
	wav_stream.mix_rate = int(sample_hz)
	wav_stream.stereo = true
	wav_stream.data = wav_data
	
	_on_song_built.call_deferred(wav_stream)

func _on_song_built(wav_stream: AudioStreamWAV) -> void:
	stream = wav_stream
	song_built.emit()
	song_button.disabled = false

func _parse_song(message: Array) -> Array:
	var notes: Array = []
	var note_start: int = 0
	var length: float = 0.0
	
	while note_start >= 0:
		if message[note_start] != NOTE:
			return []

		var note_message: Array = []
		var end_index = message.find(NOTE, note_start + 1)
		if end_index >= 0:
			note_message = message.slice(note_start + 1, end_index)
		else:
			note_message = message.slice(note_start + 1)
		if note_message.back() == SEP:
			note_message.pop_back()

		var note = _parse_note(note_message)
		if note.has("error"):
			print("SONG: Failed to parse note: ", note.error)
			return []
		notes.append(note)
		length = max(length, note.start_time + note.duration)

		note_start = message.find(NOTE, note_start + 1)

	notes.sort_custom(func(a, b): return a.start_time < b.start_time)
	song_length = length

	return notes

func _parse_note(message: Array) -> Dictionary:
	if message.count(SEP) != 2:
		return {"error": "Invalid value count"}

	var sep_1 = message.find(SEP)
	var sep_2 = message.find(SEP, sep_1 + 1)

	var start_time = _parse_value(message.slice(0, sep_1))
	var duration = _parse_value(message.slice(sep_1 + 1, sep_2))
	var frequency = _parse_value(message.slice(sep_2 + 1))

	return {"start_time": start_time, "duration": duration, "frequency": frequency}

func _parse_value(message: Array) -> float:
	var negative: bool = false
	var decimal: bool = false
	var value: float = 0.0
	
	for i in message:
		if i == NEG:
			negative = true
			continue
		elif i == DECIMAL:
			decimal = true
			continue
		else:
			var num = i as float
			if negative:
				num = -num
			if decimal:
				num = ("0." + str(i)).to_float()
			value += num

	return value

func _ready() -> void:
	stream = AudioStreamGenerator.new()
	stream.mix_rate = sample_hz
	stream.buffer_length = 0.5

func _on_finished() -> void:
	stop_music()
