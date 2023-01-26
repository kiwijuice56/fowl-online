class_name Promise
extends Node

signal promise_finished
var routine_count: int

func all(coroutines: Array[Callable]) -> void:
	routine_count = len(coroutines)
	for coroutine in coroutines:
		var routine = Routine.new()
		routine.run(self, coroutine)
	await promise_finished

func method_finished() -> void:
	routine_count -= 1
	if routine_count == 0:
		promise_finished.emit()
