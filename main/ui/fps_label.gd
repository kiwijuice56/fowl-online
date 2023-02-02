class_name FpsLabel
extends Label
# Updates the FPS label every second

@onready var timer: Timer = $Timer

func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout() -> void:
	text = str(Engine.get_frames_per_second())
