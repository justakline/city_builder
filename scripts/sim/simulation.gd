extends Node

const TICKS_PER_DAY: float = 1.0

var _accumulator: float = 0.0

var _day: int = 0
var _population: int = 120
var _treasury: int = 50000
var _jobs: int = 0

var _attractiveness: float = 0.45
var _transit_share: float = 0.35
var _car_share: float = 0.65

var _tax_income: int = 0
var _service_cost: int = 0
var _net_income: int = 0


func advance(delta: float, inputs: Dictionary) -> Dictionary:
	_accumulator += delta
	while _accumulator >= TICKS_PER_DAY:
		_accumulator -= TICKS_PER_DAY
		_step(inputs)
	return get_snapshot()


func get_snapshot() -> Dictionary:
	return {
		"day": _day,
		"population": _population,
		"treasury": _treasury,
		"jobs": _jobs,
		"attractiveness": _attractiveness,
		"transit_share": _transit_share,
		"car_share": _car_share,
		"tax_income": _tax_income,
		"service_cost": _service_cost,
		"net_income": _net_income,
	}


func _step(inputs: Dictionary) -> void:
	_day += 1

	var roads: int = int(inputs.get("road_tiles", 0))
	var residential: int = int(inputs.get("residential_tiles", 0))
	var commercial: int = int(inputs.get("commercial_tiles", 0))
	var industrial: int = int(inputs.get("industrial_tiles", 0))
	var connected_ratio: float = float(inputs.get("connected_zone_ratio", 0.0))
	var map_tiles: int = int(inputs.get("map_tiles", 1))

	var road_density: float = 0.0
	if map_tiles > 0:
		road_density = float(roads) / float(map_tiles)
	var road_score: float = clampf(road_density * 18.0, 0.0, 1.0)
	_attractiveness = clampf(0.2 + connected_ratio * 0.45 + road_score * 0.20, 0.0, 1.0)

	var capacity: int = residential * 14
	_jobs = commercial * 9 + industrial * 14

	var target_population: int = int(capacity * (0.55 + _attractiveness * 0.7))
	var migration_delta: int = int((_attractiveness - 0.52) * 65.0)
	var births: int = int(_population * 0.0012)

	var smoothing: int = int(round(float(target_population - _population) * 0.12))
	_population = max(0, _population + smoothing + births + migration_delta)

	_transit_share = clampf(0.25 + connected_ratio * 0.5 - road_density * 0.15, 0.05, 0.95)
	_car_share = 1.0 - _transit_share

	var income_tax: int = int(_population * 2.2)
	var sales_tax: int = int((_population * 1.4) * (0.8 + float(commercial) * 0.02))
	var property_tax: int = int((residential + commercial + industrial) * 7.5)
	_tax_income = income_tax + sales_tax + property_tax

	_service_cost = int(800 + _population * 1.7 + roads * 3.5)
	_net_income = _tax_income - _service_cost
	_treasury += _net_income
