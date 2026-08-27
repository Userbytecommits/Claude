extends Node

@onready var music_player = AudioStreamPlayer.new()
@onready var sfx_players: Array[AudioStreamPlayer] = []

const SFX_POOL_SIZE = 6

var music_volume = -8.0
var sfx_volume = -4.0
var current_track = ""
var _next_sfx_index = 0

func _ready():
	add_child(music_player)
	music_player.bus = "Music"
	music_player.volume_db = music_volume
	music_player.finished.connect(_on_music_finished)

	for i in range(SFX_POOL_SIZE):
		var p = AudioStreamPlayer.new()
		p.bus = "SFX"
		p.volume_db = sfx_volume
		add_child(p)
		sfx_players.append(p)

func play_music(track_name: String, fade_in: bool = true, loop: bool = true):
	if current_track == track_name and music_player.playing:
		return
	var audio_path = "res://audio/music/%s.wav" % track_name
	if not ResourceLoader.exists(audio_path):
		return
	current_track = track_name
	var stream = load(audio_path)
	if stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD if loop else AudioStreamWAV.LOOP_DISABLED
	music_player.stream = stream
	music_player.volume_db = -40.0 if fade_in else music_volume
	music_player.play()
	if fade_in:
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", music_volume, 1.0)

func _on_music_finished():
	if current_track != "":
		play_music(current_track, false)

func play_sfx(sfx_name: String):
	var audio_path = "res://audio/sfx/%s.wav" % sfx_name
	if not ResourceLoader.exists(audio_path):
		return
	var p = sfx_players[_next_sfx_index]
	_next_sfx_index = (_next_sfx_index + 1) % sfx_players.size()
	p.stream = load(audio_path)
	p.play()

func set_music_volume(volume: float):
	music_volume = volume
	music_player.volume_db = volume

func set_sfx_volume(volume: float):
	sfx_volume = volume
	for p in sfx_players:
		p.volume_db = volume

func stop_music():
	current_track = ""
	music_player.stop()
