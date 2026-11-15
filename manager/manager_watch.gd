class_name ManagerWatch
extends RefCounted

const FACING_DURATION := 10.0
const BACK_DURATION := 5.0
const SECTOR_DURATION := 2.0
# Zones regardees pendant la phase de face : -1 gauche, 0 centre, 1 droite
const SCAN_ORDER := [-1, 0, 1, 0, -1]
# Sans duree de dos : balayage continu, ce cycle se repete sans fin
const SWEEP_ORDER := [-1, 0, 1, 0]
const ARROW_WARNING := 1.0

var _facing_duration: float
var _back_duration: float
var _sector_duration: float
var _facing := true
var _time_left: float


# Durees reglables par niveau ; les constantes sont les valeurs par defaut.
# Une duree de dos nulle donne un balayage continu : la duree de face est alors celle d'un aller-retour.
func _init(facing := FACING_DURATION, back := BACK_DURATION, sector := SECTOR_DURATION) -> void:
	_back_duration = back
	_sector_duration = sector
	_facing_duration = SWEEP_ORDER.size() * sector if _is_sweeping() else facing
	_time_left = _facing_duration


func _is_sweeping() -> bool:
	return _back_duration <= 0.0


func is_facing() -> bool:
	return _facing


# Avance le cycle : le temps en trop est reporte sur les phases suivantes
func update(delta: float) -> void:
	_time_left -= delta
	while _time_left <= 0.0:
		if _is_sweeping():
			_time_left += _facing_duration
			continue
		_facing = not _facing
		_time_left += _facing_duration if _facing else _back_duration


# Zone regardee a cet instant, valable pendant la phase de face
func current_sector() -> int:
	var order: Array = SWEEP_ORDER if _is_sweeping() else SCAN_ORDER
	var step := int((_facing_duration - _time_left) / _sector_duration)
	return order[mini(step, order.size() - 1)]


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


# Regard continu entre -1 (gauche) et 1 (droite) : il passe -0.5 et 0.5 quand la zone change
func look_position() -> float:
	if not _facing:
		return -1.0
	var elapsed := _facing_duration - _time_left
	if _is_sweeping():
		# Milieu de la zone de droite ; le cycle boucle, on prend l'ecart le plus court
		var from_right := absf(elapsed - 2.5 * _sector_duration)
		from_right = minf(from_right, _facing_duration - from_right)
		return maxf(-1.0, 1.0 - from_right / _sector_duration)
	var time_from_middle := absf(elapsed - _facing_duration / 2.0)
	return maxf(-1.0, 1.0 - time_from_middle / _sector_duration)


# Cachee de dos, sauf juste avant le retournement pour prevenir le joueur
func is_arrow_visible() -> bool:
	return _facing or _time_left <= ARROW_WARNING
