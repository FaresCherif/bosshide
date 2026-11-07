class_name ManagerWatch
extends RefCounted

const FACING_DURATION := 10.0
const BACK_DURATION := 5.0
const SECTOR_DURATION := 2.0
# Zones regardees pendant la phase de face : -1 gauche, 0 centre, 1 droite
const SCAN_ORDER := [-1, 0, 1, 0, -1]

var _facing := true
var _time_left := FACING_DURATION


func is_facing() -> bool:
	return _facing


# Avance le cycle : le temps en trop est reporte sur les phases suivantes
func update(delta: float) -> void:
	_time_left -= delta
	while _time_left <= 0.0:
		_facing = not _facing
		_time_left += FACING_DURATION if _facing else BACK_DURATION


# Zone regardee a cet instant, valable pendant la phase de face
func current_sector() -> int:
	var step := int((FACING_DURATION - _time_left) / SECTOR_DURATION)
	return SCAN_ORDER[mini(step, SCAN_ORDER.size() - 1)]


# Zone d'un point selon son decalage horizontal par rapport au manager
static func sector_at(offset_x: float, zone_width: float) -> int:
	var half_center := zone_width / 6.0
	if offset_x < -half_center:
		return -1
	if offset_x > half_center:
		return 1
	return 0


func sees(offset_x: float, zone_width: float) -> bool:
	return _facing and sector_at(offset_x, zone_width) == current_sector()
