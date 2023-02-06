class_name PlayerSprite
extends Node3D

@export var icon: Sprite3D
@export var gag_timer: Timer
@export var gag_anim: AnimationPlayer
@export var thought_anim: AnimationPlayer
@export var gag_delay: float = 15.0

func _ready() -> void:
	gag_anim.speed_scale = randf_range(0.9, 1.1)
	gag_timer.start(gag_delay * randf_range(0.6, 1.5))
	gag_timer.timeout.connect(_gag_started)

func _gag_started() -> void:
	gag_anim.play(gag_anim.get_animation_list()[randi() % len(gag_anim.get_animation_list())])
	gag_timer.start(gag_delay * randf_range(0.8, 1.2))

func initialize(player: Player) -> void:
	visible = true
	icon.texture = StyleConstants.profile_images[player.icon]

func set_current_player(is_current: bool) -> void:
	if is_current:
		thought_anim.stop()
		thought_anim.play("start_thought")
		await thought_anim.animation_finished
		thought_anim.play("thought_loop")
	else:
		thought_anim.stop()
		thought_anim.play("end_thought")
		await thought_anim.animation_finished
