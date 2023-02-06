class_name GameMenu
extends Menu

@export var bid_menu: BidMenu
@export var trump_menu: TrumpMenu
@export var info_overlay: InfoOverlay

func _ready() -> void:
	visible = false
	modulate.a = 0

func exit() -> void:
	super.exit()
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.1)
	await tween.finished
	visible = false

func enter() -> void:
	super.enter()
	visible = true
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.1)
	await tween.finished
