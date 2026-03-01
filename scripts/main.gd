extends Node2D

const GRID_WIDTH: int = 50
const GRID_HEIGHT: int = 32
const CELL_SIZE: int = 24
const WORLD_OFFSET: Vector2i = Vector2i(20, 120)

enum TileType {
	EMPTY,
	ROAD,
	RESIDENTIAL,
	COMMERCIAL,
	INDUSTRIAL,
}

const TILE_COLORS := {
	TileType.EMPTY: Color("2d3c44"),
	TileType.ROAD: Color("6f7f86"),
	TileType.RESIDENTIAL: Color("66bb6a"),
	TileType.COMMERCIAL: Color("42a5f5"),
	TileType.INDUSTRIAL: Color("ffa726"),
}

const TILE_NAMES := {
	TileType.EMPTY: "Erase",
	TileType.ROAD: "Road",
	TileType.RESIDENTIAL: "Residential",
	TileType.COMMERCIAL: "Commercial",
	TileType.INDUSTRIAL: "Industrial",
}

@onready var simulation: Node = $Simulation
@onready var info_label: Label = $UI/Panel/InfoLabel

var grid: Array[Array] = []
var active_brush: int = TileType.ROAD
var hovered_cell: Vector2i = Vector2i(-1, -1)
var last_stats: Dictionary = {}


func _ready() -> void:
	_initialize_grid()
	last_stats = simulation.get_snapshot()
	set_process(true)
	queue_redraw()


func _process(delta: float) -> void:
	var sim_inputs: Dictionary = _collect_sim_inputs()
	last_stats = simulation.advance(delta, sim_inputs)
	hovered_cell = _world_to_cell(get_global_mouse_position())
	_update_ui()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var cell: Vector2i = _world_to_cell(event.position)
		if _is_cell_in_bounds(cell):
			_paint_cell(cell, active_brush)
			queue_redraw()

	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var drag_cell: Vector2i = _world_to_cell(event.position)
		if _is_cell_in_bounds(drag_cell):
			_paint_cell(drag_cell, active_brush)
			queue_redraw()

	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_0:
				active_brush = TileType.EMPTY
			KEY_1:
				active_brush = TileType.ROAD
			KEY_2:
				active_brush = TileType.RESIDENTIAL
			KEY_3:
				active_brush = TileType.COMMERCIAL
			KEY_4:
				active_brush = TileType.INDUSTRIAL
			KEY_C:
				_initialize_grid()
		queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(0, 0, 1280, 720), Color("1e272c"), true)

	var world_size := Vector2i(GRID_WIDTH * CELL_SIZE, GRID_HEIGHT * CELL_SIZE)
	draw_rect(Rect2(WORLD_OFFSET, world_size), Color("243137"), true)

	for y in GRID_HEIGHT:
		for x in GRID_WIDTH:
			var tile_type: int = grid[y][x]
			var pos := Vector2i(x * CELL_SIZE, y * CELL_SIZE) + WORLD_OFFSET
			draw_rect(Rect2(pos, Vector2i(CELL_SIZE - 1, CELL_SIZE - 1)), TILE_COLORS[tile_type], true)

	if _is_cell_in_bounds(hovered_cell):
		var hover_pos := Vector2i(hovered_cell.x * CELL_SIZE, hovered_cell.y * CELL_SIZE) + WORLD_OFFSET
		draw_rect(Rect2(hover_pos, Vector2i(CELL_SIZE - 1, CELL_SIZE - 1)), Color(1, 1, 1, 0.2), true)


func _initialize_grid() -> void:
	grid.clear()
	for _y in GRID_HEIGHT:
		var row: Array = []
		row.resize(GRID_WIDTH)
		row.fill(TileType.EMPTY)
		grid.append(row)


func _paint_cell(cell: Vector2i, tile_type: int) -> void:
	if grid[cell.y][cell.x] != tile_type:
		grid[cell.y][cell.x] = tile_type


func _world_to_cell(world_pos: Vector2) -> Vector2i:
	var local := world_pos - Vector2(WORLD_OFFSET)
	return Vector2i(floori(local.x / CELL_SIZE), floori(local.y / CELL_SIZE))


func _is_cell_in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < GRID_WIDTH and cell.y < GRID_HEIGHT


func _collect_sim_inputs() -> Dictionary:
	var road_tiles: int = 0
	var residential_tiles: int = 0
	var commercial_tiles: int = 0
	var industrial_tiles: int = 0
	var connected_zones: int = 0
	var total_zones: int = 0

	for y in GRID_HEIGHT:
		for x in GRID_WIDTH:
			var tile_type: int = grid[y][x]
			match tile_type:
				TileType.ROAD:
					road_tiles += 1
				TileType.RESIDENTIAL:
					residential_tiles += 1
					total_zones += 1
					if _has_adjacent_road(Vector2i(x, y)):
						connected_zones += 1
				TileType.COMMERCIAL:
					commercial_tiles += 1
					total_zones += 1
					if _has_adjacent_road(Vector2i(x, y)):
						connected_zones += 1
				TileType.INDUSTRIAL:
					industrial_tiles += 1
					total_zones += 1
					if _has_adjacent_road(Vector2i(x, y)):
						connected_zones += 1

	var connected_zone_ratio := float(connected_zones) / max(1.0, float(total_zones))

	return {
		"road_tiles": road_tiles,
		"residential_tiles": residential_tiles,
		"commercial_tiles": commercial_tiles,
		"industrial_tiles": industrial_tiles,
		"total_zone_tiles": total_zones,
		"connected_zone_ratio": connected_zone_ratio,
		"map_tiles": GRID_WIDTH * GRID_HEIGHT,
	}


func _has_adjacent_road(cell: Vector2i) -> bool:
	var dirs := [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
	for d in dirs:
		var c := cell + d
		if _is_cell_in_bounds(c) and grid[c.y][c.x] == TileType.ROAD:
			return true
	return false


func _update_ui() -> void:
	var info := PackedStringArray()
	info.append("City Builder Prototype - First Playable")
	info.append("")
	info.append("Brush: %s | Controls: [1] Road  [2] Residential  [3] Commercial  [4] Industrial  [0] Erase  [C] Clear" % TILE_NAMES[active_brush])
	info.append("")
	info.append("Day: %d  |  Population: %d  |  Jobs: %d  |  Treasury: $%s" % [
		last_stats.get("day", 0),
		last_stats.get("population", 0),
		last_stats.get("jobs", 0),
		_format_int(last_stats.get("treasury", 0)),
	])
	info.append("Attractiveness: %s  |  Transit Share: %s%%  |  Car Share: %s%%" % [
		_format_float(last_stats.get("attractiveness", 0.0), 2),
		_format_float(last_stats.get("transit_share", 0.0) * 100.0, 0),
		_format_float(last_stats.get("car_share", 0.0) * 100.0, 0),
	])
	info.append("Taxes/day: $%s  |  Services/day: $%s  |  Net/day: $%s" % [
		_format_int(last_stats.get("tax_income", 0)),
		_format_int(last_stats.get("service_cost", 0)),
		_format_int(last_stats.get("net_income", 0)),
	])
	info.append("")
	info.append("Road Access: Keep zones touching roads to improve growth.")
	info_label.text = "\n".join(info)
	queue_redraw()


func _format_int(value: int) -> String:
	return String.num_int64(value)


func _format_float(value: float, decimals: int) -> String:
	return String.num(value, decimals)
