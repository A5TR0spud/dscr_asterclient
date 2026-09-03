extends AudioStreamPlayer
class_name Music

enum NoteType { SINE, SQUARE, SAWTOOTH, TRIANGLE }

const NEG = -1
const SEP = -3
const DECIMAL = -10
const GROUP_BEGIN = -14
const GROUP_END = -15
const SONG = -577
const NOTE = -605003
const conversion_factor: float = 0.8066
const sample_hz: float = 22050.0

static var now_playing: Music = null

@export var song_button: Node

var active_notes: Array = []
var current_note: int = 0
var chained_songs: Array[Music] = []
var current_song: Array = []
var playback: AudioStreamGeneratorPlayback
var playback_time: float = 0.0
var song_length: float = 0.0

signal song_end

func play_music() -> void:
	if is_playing():
		stop_music()
		return

	if now_playing:
		now_playing.chain_music(self)
		(song_button as TranslatableSimple).message = [-577, -25]
		song_button.refresh()
		return

	if current_song.size() > 0:
		print(current_song)
		active_notes = []
		current_note = 0
		playback_time = 0.0
		now_playing = self
		play()
		playback = get_stream_playback()
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
	if playback: stop_music()

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

func _fill_buffer() -> void:
	var frames_available := playback.get_frames_available()
	var time_step: float = 1.0 / sample_hz

	for i in range(frames_available):
		while current_note < current_song.size() and playback_time >= current_song[current_note].start_time:
			var note_data = current_song[current_note]
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
		playback.push_frame(Vector2.ONE * mixed_sample)
		playback_time += time_step

	if playback.get_playback_position() >= song_length:
		stop()
		_on_finished()

func _ready() -> void:
	stream = AudioStreamGenerator.new()
	stream.mix_rate = sample_hz
	stream.buffer_length = 0.5

func _process(_delta: float) -> void:
	if playback: _fill_buffer()

func _on_finished() -> void:
	playback = null
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
