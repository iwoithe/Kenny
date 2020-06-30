extends Node

var num_levels = 2
var current_level = 1

var game_scene = 'res://main.tscn'
var title_screen = 'res://ui/menu/title_screen.tscn'

func restart():
	get_tree().change_scene(title_screen)
	current_level = 1

func next_level():
	current_level += 1
	if current_level <= num_levels:
		get_tree().reload_current_scene()
