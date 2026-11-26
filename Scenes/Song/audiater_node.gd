extends Control
class_name AudiaterNode

@onready var music_player_node: AudioStreamPlayer = $Music
@onready var current_time_label: Label = $VBoxContainer/HBoxContainer2/CurrentTime
@onready var progress: HSlider = $VBoxContainer/HBoxContainer2/ProgressSlider
@onready var duration_label: Label = $VBoxContainer/HBoxContainer2/Duration
@onready var volume: HSlider = $VBoxContainer/HBoxContainer/VolumeSlider
@onready var playpause_tr: LocaleNode = $VBoxContainer/HBoxContainer/PlayButton/LocaleNode

enum NoteType {
	SINE,
	SQUARE,
	SAWTOOTH,
	TRIANGLE,
	ARBITRARY,
	NOISE,
	BARK,
	MEOW,
	CHIRP,
}

const NOTE = -605003
const NOTE_SINE = -807
const NOTE_NOISE = -157403
const NOTE_SAW = -157457
const NOTE_TRI = -157458
const NOTE_SQUARE = -157459
const NOTE_BARK = -310
const NOTE_MEOW = -311
const NOTE_CHIRP = -312

const VALID_NOTES: PackedInt64Array = [
	NOTE,
	NOTE_SINE,
	NOTE_NOISE,
	NOTE_SAW,
	NOTE_SQUARE,
	NOTE_TRI,
	NOTE_BARK,
	NOTE_MEOW,
	NOTE_CHIRP
]

const NEG = -1
const SEP = -3
const DECIMAL = -10
const VARIABLE = -11
const GROUP_BEGIN = -14
const GROUP_END = -15
const SEQUENCER = -122
const SONG = -577
const conversion_factor: float = Main.HE6_HALF_LIFE
const sample_hz: float = 22050.0

static var now_playing: AudiaterNode = null

var active_notes: Array = []
var current_note: int = 0
static var queued_songs: Array[AudiaterNode] = []
var current_song: Array = []
var playback: AudioStreamGeneratorPlayback
var playback_time: float = 0.0
var song_length: float = 0.0

var song_variables: Dictionary = {}

func play_music() -> void:
	if music_player_node.is_playing():
		stop_music()
		return
	if now_playing and now_playing.music_player_node.is_playing():
		now_playing.stop_music()
	if current_song.size() > 0:
		playpause_tr.translations["text"] = "MUSIC_STOP"
		playpause_tr.refresh()
		#print(current_song)
		active_notes = []
		current_note = 0
		playback_time = 0.0
		now_playing = self
		music_player_node.play()
		playback = music_player_node.get_stream_playback()

func check_song(message: Array) -> bool:
	if playback: stop_music()

	var parser = TransmissionParser.new(message)
	while not parser.is_at_end():
		if not parser.skip_to(SONG): return false
		parser.expect(SONG)
		var pos := parser.save_state()
		song_variables = {}
		var notes := parse_song_group(parser)

		if parser.has_error():
			print(parser.get_error_message())
			parser.restore_state(pos, true)
			continue

		notes.sort_custom(func(a, b): return a.start_time < b.start_time)
		song_length = 0
		for note in notes:
			song_length = maxf(note.start_time + note.duration, song_length)
		current_song = notes
		progress.max_value = song_length
		duration_label.text = String.num(song_length / Main.HE6_HALF_LIFE, 0)
		progress.value = 0
		current_time_label.text = "0".pad_zeros(duration_label.text.length())
		return true

	return false

class Note:
	extends RefCounted
	var start_time: float
	var duration: float
	var frequency: float
	var type: NoteType
	
	func _init(start: float, length: float, freq: float, note_type: NoteType = NoteType.ARBITRARY):
		start_time = start
		duration = length
		frequency = freq
		type = note_type

func parse_song_note(parser: TransmissionParser) -> Note:
	#print("note ", parser.save_state())
	var type: NoteType = NoteType.ARBITRARY
	
	if parser.try_consume(NOTE_SINE):
		type = NoteType.SINE
	elif parser.try_consume(NOTE_SAW):
		type = NoteType.SAWTOOTH
	elif parser.try_consume(NOTE_TRI):
		type = NoteType.TRIANGLE
	elif parser.try_consume(NOTE_NOISE):
		type = NoteType.NOISE
	elif parser.try_consume(NOTE_SQUARE):
		type = NoteType.SQUARE
	elif parser.try_consume(NOTE_BARK):
		type = NoteType.BARK
	elif parser.try_consume(NOTE_MEOW):
		type = NoteType.MEOW
	elif parser.try_consume(NOTE_CHIRP):
		type = NoteType.CHIRP
	else:
		parser.expect(NOTE)

	var start_time = parser.read_number() * conversion_factor
	parser.expect(SEP)
	var duration = parser.read_number() * conversion_factor
	parser.expect(SEP)
	var frequency = parser.read_number() / conversion_factor
	return Note.new(start_time, duration, frequency, type)

func parse_song_item(parser: TransmissionParser) -> Array[Note]:
	#print("item ", parser.save_state())
	if not parser.can_continue():
		return []
	if (parser.peek() in VALID_NOTES) and DictionaryHandler.contains_signal(parser.peek()):
		return [parse_song_note(parser)]
	if parser.try_consume(VARIABLE):
		var idx = parser.advance()
		#print(song_variables.get(idx))
		if parser.check(GROUP_BEGIN):
			var p := parse_song_group(parser)
			song_variables[idx] = p
			return p
		else:
			if idx in song_variables:
				return song_variables[idx]
			return []
	return parse_song_group(parser)

func parse_song_chord(parser: TransmissionParser) -> Array[Note]:
	#print("chord ", parser.save_state())
	var items: Array[Note] = []
	var sav: int = parser.save_state()
	while not parser.check(GROUP_END) and parser.can_continue():
		var _i: Array[Note] = parse_song_item(parser)
		if not _i:
			parser.restore_state(sav, true)
			break
		sav = parser.save_state()
		items.append_array(_i)
		parser.try_consume(SEP)
	return items

func parse_song_sequence(parser: TransmissionParser) -> Array[Note]:
	#print("sequence ", parser.save_state())
	var items: Array[Note] = []
	var _sequence_accum: float = 0
	var do: bool = true
	var sav: int = parser.save_state()
	while not parser.check(GROUP_END) and parser.can_continue() and do:
		var _i: Array[Note] = parse_song_chord(parser)
		do = parser.try_consume(SEQUENCER)
		if not _i:
			parser.restore_state(sav, true)
			break
		sav = parser.save_state()
		var end: float = 0
		for n in items:
			#print(n.start_time, " ", n.duration, " ", n.frequency)
			end = max(n.start_time + n.duration, end)
		_sequence_accum = end
		
		for idx: int in range(_i.size()):
			var o: Note = _i[idx]
			_i[idx] = Note.new(o.start_time + _sequence_accum, o.duration, o.frequency, o.type)
		#print(_sequence_accum)
		#_sequence_accum += _i.reduce(func(acc, b): return max(b.duration, acc), 0)
		#for existing_note in items:
		#	_sequence_accum = max(existing_note.start_time + existing_note.duration, _sequence_accum)
		items.append_array(_i)
	return items

func parse_song_group(parser: TransmissionParser) -> Array[Note]:
	#print("group ", parser.save_state())
	parser.expect(GROUP_BEGIN)
	var items := parse_song_sequence(parser)
	parser.expect(GROUP_END)
	return items

func smoothed_square_wave(phase: float, smoothness: float = 0) -> float:
	var neg: bool = phase >= 0.5
	if neg: phase -= 0.5
	var mag: float = 0
	if phase < 0.25 * smoothness:
		mag = sin(TAU * phase / smoothness)
	elif phase < 0.5 - 0.25 * smoothness:
		mag = 1
	else:
		mag = sin(TAU * (0.5 - phase) / smoothness)
	return -mag if neg else mag

func _fill_buffer() -> void:
	var frames_available := playback.get_frames_available()
	var time_step: float = 1.0 / sample_hz

	for i in range(frames_available):
		while current_note < current_song.size() and playback_time >= current_song[current_note].start_time:
			var note_data: Note = current_song[current_note]
			var note = {
				"frequency": note_data.frequency,
				"phase": 0.0,
				"time_left": note_data.duration,
				"total_duration": note_data.duration,
				"type": note_data.type
			}
			active_notes.append(note)
			current_note += 1
		
		var mixed_sample = 0.0
		
		var j = active_notes.size() - 1
		while j >= 0:
			var note = active_notes[j]
			
			var simulated_frequency: float = note.frequency
			var attack_time: float = 0.0025
			var sustain: float = 0.5
			var decay_time: float = 0.01
			var volume_envelope: float = 1
			
			var sample = 0.0
			var start_ago: float = note.total_duration - note.time_left
			var note_time: float = start_ago / note.total_duration
			match note.type:
				NoteType.ARBITRARY:
					var s: float = clamp(1.0 - (600.0 / note.frequency), 0, 1) * 0.3 + 0.25
					s += max(-0.01, remap(note.time_left / note.total_duration, 1, 0, -0.2, 0.05))
					sample = smoothed_square_wave(note.phase, clamp(s, 0.2, 0.9))
					volume_envelope = 0.8
				NoteType.SINE:
					sample = sin(note.phase * TAU)
					volume_envelope = 2
				NoteType.SAWTOOTH:
					sample = 2.0 * abs(fmod(note.phase + 0.5, 1.0)) - 1.0
					volume_envelope = 0.8
				NoteType.SQUARE:
					sample = sign(note.phase - 0.5)
					volume_envelope = 0.6
				NoteType.TRIANGLE:
					sample = 4.0 * abs(fmod(note.phase + 0.75, 1.0) - 0.5) - 1.0
					volume_envelope = 1.6
				NoteType.NOISE:
					sample = (float(rand_from_seed(note.frequency + start_ago * note.frequency * 2)[0]) / INT32_MAX) * 2 - 1
					volume_envelope = 0.9
				NoteType.BARK:
					#attack_time = 0.25 * note.total_duration
					sustain = 0.2
					simulated_frequency += (cos(note_time * PI) * 0.5 - 0.5) * simulated_frequency * 0.1 + simulated_frequency * 0.05
					#decay_time = 0.25 * note.total_duration
					var _noise = (float(rand_from_seed(note.frequency + start_ago * note.frequency * 2)[0]) / INT32_MAX) * 2 - 1
					var _smooth = smoothed_square_wave(note.phase, 0.2)
					sample = lerp(_noise, _smooth, note_time * 0.5 + 0.5)
				NoteType.MEOW:
					#simulated_frequency += (simulated_frequency * 0.1) - (simulated_frequency * 0.5 * note_time)
					simulated_frequency += (cos((note_time * 0.75 - 0.25) * PI) - 0.7) * simulated_frequency * 0.1
					attack_time = 0.25 * note.total_duration
					decay_time = 0.25 * note.total_duration
					sustain = 1
					sample = 2.0 * abs(fmod(note.phase + 0.5, 1.0)) - 1.0
				NoteType.CHIRP:
					simulated_frequency += simulated_frequency * 0.2 * -cos(note_time * PI * 2.3) + simulated_frequency * 0.1
					attack_time = 0.125 * note.total_duration
					decay_time = 0.25 * note.total_duration
					sustain = 0.9
					sample = smoothed_square_wave(note.phase, 0.8)
					volume_envelope = 0.8
			
			if start_ago < attack_time:
				volume_envelope *= start_ago / attack_time
			if note.time_left < decay_time:
				volume_envelope *= note.time_left / decay_time
			volume_envelope *= remap(note_time, 0, 1, 1, sustain)
			#volume_envelope /= note.frequency / 200.0 + 1
			mixed_sample += sample * 0.3 * volume_envelope
			
			note.phase = fmod(note.phase + simulated_frequency / sample_hz, 1.0)
			note.time_left -= time_step
			
			if note.time_left <= 0:
				active_notes.remove_at(j)
			
			j -= 1

		mixed_sample = clamp(mixed_sample, -2.0, 2.0)
		playback.push_frame(Vector2.ONE * mixed_sample)
		playback_time += time_step

	if playback.get_playback_position() >= song_length:
		music_player_node.stop()
		_on_finished()

func _process(_delta: float) -> void:
	if playback:
		_fill_buffer()
		if music_player_node.playing:
			progress.value = music_player_node.get_playback_position() + AudioServer.get_time_since_last_mix()
			current_time_label.text = String.num(progress.value / Main.HE6_HALF_LIFE, 0).pad_zeros(duration_label.text.length())

func stop_music() -> void:
	playpause_tr.translations["text"] = "MUSIC_PLAY"
	playpause_tr.refresh()
	music_player_node.stop()
	progress.value = 0
	current_time_label.text = "0".pad_zeros(duration_label.text.length())
	if now_playing == self: now_playing = null

func _ready() -> void:
	music_player_node.stream = AudioStreamGenerator.new()
	music_player_node.stream.mix_rate = sample_hz
	music_player_node.stream.buffer_length = 0.5

func _on_play_button_pressed():
	queued_songs.clear()
	play_music()

func _on_queue_button_pressed():
	if queued_songs.is_empty() and not now_playing:
		play_music()
	else:
		queued_songs.append(self)

func _on_finished():
	playback = null
	now_playing = null
	stop_music()
	if not queued_songs.is_empty():
		queued_songs.front().play_music()
		queued_songs = queued_songs.slice(1)

func _on_volume_slider_value_changed(value):
	music_player_node.volume_linear = value
