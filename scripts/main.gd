extends Node3D

const GRID_WIDTH: int = 50
const GRID_HEIGHT: int = 32
const CELL_SIZE: float = 2.0
const GROUND_THICKNESS: float = 0.2

const CAMERA_MIN_DISTANCE: float = 18.0
const CAMERA_MAX_DISTANCE: float = 120.0
const CAMERA_TILT_DEG: float = 55.0

enum TileType {
	EMPTY,
	ROAD,
	RESIDENTIAL,
	COMMERCIAL,
	INDUSTRIAL,
}

const TILE_NAMES: Dictionary = {
	TileType.EMPTY: "Erase",
	TileType.ROAD: "Road",
	TileType.RESIDENTIAL: "Residential",
	TileType.COMMERCIAL: "Commercial",
	TileType.INDUSTRIAL: "Industrial",
}

@onready var simulation: Node = $Simulation
@onready var info_label: Label = $UI/Panel/InfoLabel
@onready var ground_root: Node3D = $World/GroundRoot
@onready var building_root: Node3D = $World/BuildingRoot
@onready var hover_cursor: MeshInstance3D = $World/HoverCursor
@onready var camera_3d: Camera3D = $Camera3D

var grid: Array = []
var ground_tiles: Array = []
var building_tiles: Dictionary = {}

var active_brush: int = TileType.ROAD
var hovered_cell: Vector2i = Vector2i(-1, -1)
var last_stats: Dictionary = {}

var materials: Dictionary = {}

var is_panning: bool = false
var camera_target: Vector3 = Vector3.ZERO
var camera_distance: float = 56.0


func _ready() -> void:
	_initialize_materials()
	_initialize_grid()
	_generate_ground_meshes()
	_initialize_hover_cursor()
	_update_camera_transform()
	last_stats = simulation.get_snapshot()
	set_process(true)


func _process(delta: float) -> void:
	hovered_cell = _mouse_to_cell(get_viewport().get_mouse_position())
	_update_hover_cursor()

	var sim_inputs: Dictionary = _collect_sim_inputs()
	last_stats = simulation.advance(delta, sim_inputs)
	_update_ui()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			is_panning = event.pressed
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			camera_distance = clampf(camera_distance - 4.0, CAMERA_MIN_DISTANCE, CAMERA_MAX_DISTANCE)
			_update_camera_transform()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			camera_distance = clampf(camera_distance + 4.0, CAMERA_MIN_DISTANCE, CAMERA_MAX_DISTANCE)
			_update_camera_transform()
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_paint_at_mouse(event.position)

	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			_paint_at_mouse(event.position)
		if is_panning:
			var pan_scale: float = camera_distance * 0.012
			camera_target.x -= event.relative.x * pan_scale
			camera_target.z -= event.relative.y * pan_scale
			_update_camera_transform()

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
				_refresh_all_tiles()
		_update_ui()


func _initialize_materials() -> void:
	materials.clear()
	materials[TileType.EMPTY] = _create_material(Color("2d3c44"))
	materials[TileType.ROAD] = _create_material(Color("6f7f86"))
	materials[TileType.RESIDENTIAL] = _create_material(Color("66bb6a"))
	materials[TileType.COMMERCIAL] = _create_material(Color("42a5f5"))
	materials[TileType.INDUSTRIAL] = _create_material(Color("ffa726"))


func _create_material(color: Color) -> StandardMaterial3D:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.9
	return mat


func _initialize_grid() -> void:
	grid.clear()
	for _y in GRID_HEIGHT:
		var row: Array = []
		row.resize(GRID_WIDTH)
		row.fill(TileType.EMPTY)
		grid.append(row)


func _generate_ground_meshes() -> void:
	for child in ground_root.get_children():
		child.queue_free()
	ground_tiles.clear()

	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = Vector3(CELL_SIZE * 0.96, GROUND_THICKNESS, CELL_SIZE * 0.96)

	for y in GRID_HEIGHT:
		var row: Array = []
		for x in GRID_WIDTH:
			var tile: MeshInstance3D = MeshInstance3D.new()
			tile.mesh = mesh
			tile.position = _cell_to_world(x, y)
			tile.material_override = materials[TileType.EMPTY]
			ground_root.add_child(tile)
			row.append(tile)
		ground_tiles.append(row)


func _initialize_hover_cursor() -> void:
	var cursor_mesh: BoxMesh = BoxMesh.new()
	cursor_mesh.size = Vector3(CELL_SIZE * 0.98, 0.06, CELL_SIZE * 0.98)
	hover_cursor.mesh = cursor_mesh
	var cursor_mat: StandardMaterial3D = StandardMaterial3D.new()
	cursor_mat.albedo_color = Color(1, 1, 1, 0.35)
	cursor_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	cursor_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	hover_cursor.material_override = cursor_mat


func _refresh_all_tiles() -> void:
	for y in GRID_HEIGHT:
		for x in GRID_WIDTH:
			_update_ground_tile(Vector2i(x, y))
			_refresh_building_at(Vector2i(x, y))


func _paint_at_mouse(mouse_pos: Vector2) -> void:
	var cell: Vector2i = _mouse_to_cell(mouse_pos)
	if not _is_cell_in_bounds(cell):
		return
	if grid[cell.y][cell.x] == active_brush:
		return

	grid[cell.y][cell.x] = active_brush
	_update_ground_tile(cell)
	_refresh_building_at(cell)

	var neighbors: Array[Vector2i] = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
	for offset: Vector2i in neighbors:
		var n: Vector2i = cell + offset
		if _is_cell_in_bounds(n):
			_refresh_building_at(n)


func _update_ground_tile(cell: Vector2i) -> void:
	var tile_type: int = grid[cell.y][cell.x]
	var tile: MeshInstance3D = ground_tiles[cell.y][cell.x] as MeshInstance3D
	tile.material_override = materials[tile_type]


func _refresh_building_at(cell: Vector2i) -> void:
	var key: String = "%d_%d" % [cell.x, cell.y]
	var should_exist: bool = _is_developed_zone(cell)

	if should_exist:
		if not building_tiles.has(key):
			var building: MeshInstance3D = MeshInstance3D.new()
			var building_mesh: BoxMesh = BoxMesh.new()
			building_mesh.size = Vector3(CELL_SIZE * 0.72, _building_height(cell), CELL_SIZE * 0.72)
			building.mesh = building_mesh
			building.position = _cell_to_world(cell.x, cell.y)
			building.position.y = (GROUND_THICKNESS * 0.5) + (_building_height(cell) * 0.5)
			building.material_override = materials[grid[cell.y][cell.x]]
			building_root.add_child(building)
			building_tiles[key] = building
		else:
			var existing: MeshInstance3D = building_tiles[key] as MeshInstance3D
			existing.material_override = materials[grid[cell.y][cell.x]]
	else:
		if building_tiles.has(key):
			var old_building: MeshInstance3D = building_tiles[key] as MeshInstance3D
			old_building.queue_free()
			building_tiles.erase(key)


func _building_height(cell: Vector2i) -> float:
	var tile_type: int = grid[cell.y][cell.x]
	match tile_type:
		TileType.RESIDENTIAL:
			return 1.6
		TileType.COMMERCIAL:
			return 2.3
		TileType.INDUSTRIAL:
			return 1.9
		_:
			return 1.3


func _is_zone(tile_type: int) -> bool:
	return tile_type == TileType.RESIDENTIAL or tile_type == TileType.COMMERCIAL or tile_type == TileType.INDUSTRIAL


func _is_developed_zone(cell: Vector2i) -> bool:
	var tile_type: int = grid[cell.y][cell.x]
	return _is_zone(tile_type) and _has_adjacent_road(cell)


func _has_adjacent_road(cell: Vector2i) -> bool:
	var dirs: Array[Vector2i] = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
	for d: Vector2i in dirs:
		var c: Vector2i = cell + d
		if _is_cell_in_bounds(c) and grid[c.y][c.x] == TileType.ROAD:
			return true
	return false


func _cell_to_world(x: int, y: int) -> Vector3:
	var origin_x: float = -(float(GRID_WIDTH) * CELL_SIZE * 0.5) + (CELL_SIZE * 0.5)
	var origin_z: float = -(float(GRID_HEIGHT) * CELL_SIZE * 0.5) + (CELL_SIZE * 0.5)
	return Vector3(origin_x + float(x) * CELL_SIZE, 0.0, origin_z + float(y) * CELL_SIZE)


func _mouse_to_cell(mouse_pos: Vector2) -> Vector2i:
	var ray_origin: Vector3 = camera_3d.project_ray_origin(mouse_pos)
	var ray_dir: Vector3 = camera_3d.project_ray_normal(mouse_pos)

	var ground_plane: Plane = Plane(Vector3.UP, GROUND_THICKNESS * 0.5)
	var hit_variant: Variant = ground_plane.intersects_ray(ray_origin, ray_dir)
	if hit_variant == null:
		return Vector2i(-1, -1)

	var hit: Vector3 = hit_variant
	var min_x: float = -(float(GRID_WIDTH) * CELL_SIZE * 0.5)
	var min_z: float = -(float(GRID_HEIGHT) * CELL_SIZE * 0.5)
	var gx: int = int(floor((hit.x - min_x) / CELL_SIZE))
	var gy: int = int(floor((hit.z - min_z) / CELL_SIZE))
	return Vector2i(gx, gy)


func _is_cell_in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < GRID_WIDTH and cell.y < GRID_HEIGHT


func _update_hover_cursor() -> void:
	if _is_cell_in_bounds(hovered_cell):
		hover_cursor.visible = true
		hover_cursor.position = _cell_to_world(hovered_cell.x, hovered_cell.y)
		hover_cursor.position.y = GROUND_THICKNESS * 0.5 + 0.05
	else:
		hover_cursor.visible = false


func _update_camera_transform() -> void:
	var tilt_radians: float = deg_to_rad(CAMERA_TILT_DEG)
	var cam_y: float = sin(tilt_radians) * camera_distance
	var cam_z: float = cos(tilt_radians) * camera_distance
	camera_3d.position = camera_target + Vector3(0.0, cam_y, cam_z)
	camera_3d.look_at(camera_target, Vector3.UP)


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

	var connected_zone_ratio: float = 0.0
	if total_zones > 0:
		connected_zone_ratio = float(connected_zones) / float(total_zones)

	return {
		"road_tiles": road_tiles,
		"residential_tiles": residential_tiles,
		"commercial_tiles": commercial_tiles,
		"industrial_tiles": industrial_tiles,
		"total_zone_tiles": total_zones,
		"connected_zone_ratio": connected_zone_ratio,
		"map_tiles": GRID_WIDTH * GRID_HEIGHT,
	}


func _update_ui() -> void:
	var info: PackedStringArray = PackedStringArray()
	info.append("City Builder Prototype - 3D")
	info.append("")
	info.append("Brush: %s | [1] Road [2] Residential [3] Commercial [4] Industrial [0] Erase [C] Clear" % TILE_NAMES[active_brush])
	info.append("Camera: Right-drag pan | Mouse wheel zoom")
	info.append("")
	info.append("Day: %d  |  Population: %d  |  Jobs: %d  |  Treasury: $%s" % [
		int(last_stats.get("day", 0)),
		int(last_stats.get("population", 0)),
		int(last_stats.get("jobs", 0)),
		_format_int(int(last_stats.get("treasury", 0))),
	])
	info.append("Attractiveness: %s  |  Transit Share: %s%%  |  Car Share: %s%%" % [
		_format_float(float(last_stats.get("attractiveness", 0.0)), 2),
		_format_float(float(last_stats.get("transit_share", 0.0)) * 100.0, 0),
		_format_float(float(last_stats.get("car_share", 0.0)) * 100.0, 0),
	])
	info.append("Taxes/day: $%s  |  Services/day: $%s  |  Net/day: $%s" % [
		_format_int(int(last_stats.get("tax_income", 0))),
		_format_int(int(last_stats.get("service_cost", 0))),
		_format_int(int(last_stats.get("net_income", 0))),
	])
	info.append("")
	info.append("Development rule: Zoned tiles touching roads spawn building cubes.")
	info_label.text = "\n".join(info)


func _format_int(value: int) -> String:
	return String.num_int64(value)


func _format_float(value: float, decimals: int) -> String:
	return String.num(value, decimals)
