class_name RandomSoundSpawner
extends Node

# Universal sound class with more options, such as pitch or file variation

@export var sounds: Array[Resource]
@export var volume := 0.0
@export var pitch := 1.0
@export var rand_pitch_range := 0.0

func play_sound() -> void:
	var sound_player: AudioStreamPlayer = AudioStreamPlayer.new()
	sound_player.volume_db = volume
	sound_player.stream = sounds[randi() % len(sounds)]
	sound_player.pitch_scale = pitch
	add_child(sound_player)
	
	sound_player.play()
	await sound_player.finished
	sound_player.queue_free()
