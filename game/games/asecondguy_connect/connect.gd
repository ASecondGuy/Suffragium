extends Node2D

var _last_chip: RigidBody2D


func _empty():
	$bounds/bottom.disabled = true
