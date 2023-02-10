class_name FpsLabel
extends Label
# Displays the current FPS every second

@onready var timer: Timer = $Timer

func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout() -> void:
	text = "fps: " + str(Engine.get_frames_per_second())
