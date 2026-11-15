class_name LevelScore
extends RefCounted

const BASE_SCORE := 1000
const POINTS_PER_SECOND := 10
const WRONG_CODE_PENALTY := 100
const WRONG_ANSWER_PENALTY := 100
# Dernieres secondes d'une limite de temps : le chrono passe au rouge
const TIME_WARNING := 10.0

var _elapsed := 0.0
var _running := true
var _penalty := 0
var _wrong_codes := 0
var _wrong_answers := 0


func update(delta: float) -> void:
	if _running:
		_elapsed += delta


func stop() -> void:
	_running = false


func elapsed() -> float:
	return _elapsed


# Limite de temps du niveau en secondes ; 0 ou moins = pas de limite
func time_left(limit: float) -> float:
	return maxf(0.0, limit - _elapsed)


func is_time_up(limit: float) -> bool:
	return limit > 0.0 and _elapsed >= limit


func is_running_out(limit: float) -> bool:
	return limit > 0.0 and time_left(limit) <= TIME_WARNING


# Avec une limite, le chrono compte a rebours
func chrono_seconds(limit: float) -> float:
	return time_left(limit) if limit > 0.0 else _elapsed


func add_penalty(points: int) -> void:
	_penalty += points


func add_wrong_code() -> void:
	_wrong_codes += 1
	add_penalty(WRONG_CODE_PENALTY)


func add_wrong_answer() -> void:
	_wrong_answers += 1
	add_penalty(WRONG_ANSWER_PENALTY)


func wrong_codes() -> int:
	return _wrong_codes


func wrong_answers() -> int:
	return _wrong_answers


# Le score baisse avec le temps et les penalites, sans descendre sous zero
func score() -> int:
	return maxi(0, BASE_SCORE - int(_elapsed * POINTS_PER_SECOND) - _penalty)


# Temps au format MM:SS.d (dixiemes tronques)
static func format_time(seconds: float) -> String:
	var tenths := int(seconds * 10.0)
	var minutes := tenths / 600
	var secs := (tenths / 10) % 60
	return "%02d:%02d.%d" % [minutes, secs, tenths % 10]
