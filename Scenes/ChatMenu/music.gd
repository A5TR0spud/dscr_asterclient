extends AudioStreamPlayer
class_name Music

const conversion_factor: float = 0.8066
const sample_hz: float = 22050.0

static var now_playing: Music = null

@export var song_button: Node

var chained_songs: Array[Music] = []
var current_song: Array = []
var song_length: float = 0.0

var _build_thread: Thread = null

signal song_built
signal song_end

const NEG = -1
const SEP = -3
const DECIMAL = -10
const GROUP_BEGIN = -14
const GROUP_END = -15
const SONG = -577
const NOTE = -605003

enum NoteType { SINE, SQUARE, SAWTOOTH, TRIANGLE }

func play_music() -> void:
	if is_playing():
		stop_music()
		return

	if now_playing:
		now_playing.chain_music(self)
		(song_button as TranslatableSimple).message = [-577, -25]
		song_button.refresh()
		return

	if Input.is_key_pressed(KEY_CTRL):
		stop_music()
		song_button.disabled = true
		_start_build_song()
		return

	if current_song.size() > 0:
		print(current_song)
		now_playing = self
		play()
		(song_button as TranslatableSimple).message = [-577, -29]
		song_button.refresh()

func chain_music(next: Music) -> void:
	chained_songs.append(next)

func cancel_chain() -> void:
	(song_button as TranslatableSimple).message = [-577]
	song_button.refresh()
	for i in chained_songs:
		i.cancel_chain()

func stop_music() -> void:
	stop()
	if now_playing == self: now_playing = null
	cancel_chain()
	chained_songs.clear()
	song_button.refresh()

func check_song(message: Array) -> bool:
	var parser = TransmissionParser.new(message)
	while not parser.is_at_end():
		if not parser.skip_to(SONG): return false
		parser.expect(SONG)
		var pos := parser.save_state()
		var notes := parser.read_group_items(parse_note)

		if parser.has_error():
			print(parser.get_error_message())
			parser.restore_state(pos, true)
			continue

		notes.sort_custom(func(a, b): return a.start_time < b.start_time)
		song_length = 0
		for note in notes:
			song_length = maxf(note.start_time + note.duration, song_length)
		current_song = notes
		song_button.disabled = true
		_start_build_song()

		return true

	return false

func parse_note(parser: TransmissionParser) -> Dictionary:
	parser.expect(NOTE)
	var start_time = parser.read_number()
	parser.expect(SEP)
	var duration = parser.read_number()
	parser.expect(SEP)
	var frequency = parser.read_number()
	parser.try_consume(SEP)

	return {
		"start_time": start_time * conversion_factor,
		"duration": duration * conversion_factor,
		"frequency": frequency / conversion_factor
	}

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
				"total_duration": note_data.duration,
				"type": NoteType.SINE
			}
			active_notes.append(note)
			current_note += 1
		
		var mixed_sample = 0.0
		
		var j = active_notes.size() - 1
		while j >= 0:
			var note = active_notes[j]
			
			var increment = note.frequency / sample_hz
			
			var sample = 0.0
			if note.type == NoteType.SINE:
				sample = sin(note.phase * TAU)
			elif note.type == NoteType.SAWTOOTH:
				sample = 2.0 * note.phase - 1.0
			elif note.type == NoteType.SQUARE:
				sample = 1.0 if note.phase < 0.5 else -1.0
			elif note.type == NoteType.TRIANGLE:
				sample = 4.0 * abs(fmod(note.phase + 0.75, 1.0) - 0.5) - 1.0
			
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

func _ready() -> void:
	stream = AudioStreamGenerator.new()
	stream.mix_rate = sample_hz
	stream.buffer_length = 0.5

func _on_finished() -> void:
	now_playing = null
	song_end.emit()
	if not chained_songs.is_empty():
		var next = chained_songs[0]
		var remain = chained_songs.slice(1)
		for chain in remain:
			next.chain_music(chain)
		next.play_music()
		chained_songs.clear()
	stop_music()
