class_name Routine
extends Node

func run(runner: Promise, method: Callable) -> void:
	await method.call()
	runner.method_finished()
