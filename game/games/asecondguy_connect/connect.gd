extends Node2D

const END_MESSAGES := [
	"Draw",
	"You won",
	"You lost",
]
const PLAYER_COLORS := [Color.yellow, Color.red]

var _last_chip: RigidBody2D
var _end_condition := 0
var _chips_played := 0
var _fallen_chips := []

onready var _play_area := $PlayArea
onready var _grid := $Grid
onready var _chips := $Chips
onready var _spawners := [$Spawner1, $Spawner2]


func _ready():
	_spawn_chip(0)
	# setup the code representation of all played chips
	for _x in range(_grid.grid_size.x):
		var tmp := []
		for _y in range(_grid.grid_size.y):
			tmp.push_back(null)
		_fallen_chips.push_back(tmp)


func _empty():
	$Bounds/Bottom.set_deferred("disabled", true)
	for c in _chips.get_children():
		# set all chips back to rigid mode
		c.set_deferred("mode", 0)


func _on_PlayArea_body_exited(_body):
	if _end_condition == -1:
		return
	if _play_area.get_overlapping_bodies().size() == 0:
		GameManager.end_game(END_MESSAGES[_end_condition])


func _on_chip_sleep(chip: RigidBody2D):
	if !chip.sleeping:
		return
	_last_chip = chip
	var grid_pos: Vector2 = _grid.global_to_grid_pos(chip.position)
	if grid_pos.x >= 0:
		chip.set_deferred("mode", chip.MODE_STATIC)
		_chips_played += 1
		_fallen_chips[grid_pos.x][grid_pos.y] = chip.player_id
		_update_end_condition()
		# max number of chips is 42
		if _chips_played == 42 or _end_condition != 0:
			_empty()
		else:
			# [1, 0][last_id] ==> 0 -> 1, 1 -> 0
			_spawn_chip([1, 0][chip.player_id])


func _spawn_chip(player_id := 0):
	var chip: RigidBody2D = preload("res://games/asecondguy_connect/chip.tscn").instance()
	chip.player_id = player_id
	chip.color = PLAYER_COLORS[player_id]
	chip.global_position = _spawners[player_id].global_position
	if chip.connect("sleeping_state_changed", self, "_on_chip_sleep", [chip]) != OK:
		GameManager.end_game("A fatal error occured.")
	_chips.call_deferred("add_child", chip)


func _update_end_condition():
	if (
		_end_condition_line_checker(_last_chip, Vector2(-1, 0), Vector2(1, 0)) == 4  # vertical
		or _end_condition_line_checker(_last_chip, Vector2(0, -1), Vector2(0, 1)) == 4  # horizontal
		or _end_condition_line_checker(_last_chip, Vector2(-1, -1), Vector2(1, 1)) == 4  # diagonal_plus
		or _end_condition_line_checker(_last_chip, Vector2(-1, 1), Vector2(1, -1)) == 4
	):  # diagonal_minus
		_end_condition = _last_chip.player_id + 1


func _end_condition_line_checker(chip: RigidBody2D, left_dir: Vector2, right_dir: Vector2):
	var count: int = 1
	count += _end_condition_find_chip_line(chip, left_dir)
	count += _end_condition_find_chip_line(chip, right_dir)
	return count


func _end_condition_find_chip_line(chip: RigidBody2D, dir: Vector2) -> int:
	var last_chip_position: Vector2 = _grid.global_to_grid_pos(_last_chip.position)
	var count: int = 0
	for i in range(1, 4):
		var pos: Vector2 = last_chip_position + (dir * i)
		if pos.x < 0 or pos.x >= _fallen_chips.size():
			break
		if pos.y < 0 or pos.y >= _fallen_chips[pos.x].size():
			break
		if _fallen_chips[pos.x][pos.y] != chip.player_id:
			break
		count += 1
	return count


func _on_PlayArea_tree_exiting():
	_end_condition = -1
