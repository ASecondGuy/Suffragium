extends Node2D

onready var _play_area := $PlayArea

var _last_chip: RigidBody2D

func _ready():
	_empty()

func _empty():
	$bounds/bottom.disabled = true


func _on_PlayArea_body_exited(_body):
	if _play_area.get_overlapping_bodies().size() == 0:
		GameManager.end_game()
