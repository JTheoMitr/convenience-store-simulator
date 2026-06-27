extends Node

@onready var music_player: AudioStreamPlayer = $MusicPlayer

var current_track: AudioStream


func play_track(track: AudioStream, restart: bool = false) -> void:
	if track == null:
		return

	var is_same_track: bool = current_track == track

	if is_same_track and music_player.playing and !restart:
		return

	current_track = track
	music_player.stream = track
	music_player.play()


func stop_music() -> void:
	music_player.stop()
	current_track = null
