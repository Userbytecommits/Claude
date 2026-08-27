extends Node
class_name AudioManager

@onready var music_player = AudioStreamPlayer.new()
@onready var sfx_player = AudioStreamPlayer.new()

static var instance: AudioManager
var music_volume = -10.0
var sfx_volume = -5.0

func _ready():
	instance = self

	add_child(music_player)
	music_player.bus = "Music"
	music_player.volume_db = music_volume

	add_child(sfx_player)
	sfx_player.bus = "SFX"
	sfx_player.volume_db = sfx_volume

func play_music(track_name: String, fade_in: bool = true):
	var audio_path = "res://audio/music/%s.ogg" % track_name
	if ResourceLoader.exists(audio_path):
		music_player.stream = load(audio_path)
		music_player.play()
		if fade_in:
			var tween = create_tween()
			tween.tween_property(music_player, "volume_db", music_volume, 1.0)

func play_sfx(sfx_name: String):
	var audio_path = "res://audio/sfx/%s.wav" % sfx_name
	if ResourceLoader.exists(audio_path):
		sfx_player.stream = load(audio_path)
		sfx_player.play()

func set_music_volume(volume: float):
	music_volume = volume
	music_player.volume_db = volume

func set_sfx_volume(volume: float):
	sfx_volume = volume
	sfx_player.volume_db = volume

func stop_music():
	music_player.stop()
