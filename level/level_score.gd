class_name LevelScore
extends RefCounted

const BASE_SCORE := 1000
const POINTS_PER_SECOND := 10
const WRONG_CODE_PENALTY := 100

var _elapsed := 0.0
var _running := true
var _penalty := 0


func update(delta: float) -> void:
	if _running:
		_elapsed += delta


func stop() -> void:
	_running = false


func elapsed() -> float:
	return _elapsed


func add_penalty(points: int) -> void:
	_penalty += points


# Le score baisse avec le temps et les penalites, sans descendre sous zero
func score() -> int:
	return maxi(0, BASE_SCORE - int(_elapsed * POINTS_PER_SECOND) - _penalty)


# Temps au format MM:SS.d (dixiemes tronques)
static func format_time(seconds: float) -> String:
	var tenths := int(seconds * 10.0)
	var minutes := tenths / 600
	var secs := (tenths / 10) % 60
	return "%02d:%02d.%d" % [minutes, secs, tenths % 10]
