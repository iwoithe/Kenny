extends Node2D

signal score_changed
var score

export (int) var camera_bottom_limit = 630

var Collectible = preload("res://objects/collectible/collectible.tscn")

onready var pickups = $Pickups

func _ready():
	score = 0
	emit_signal('score_changed', score)
	pickups.hide()
	$Player.start($PlayerSpawn.position)
	set_camera_limits()
	spawn_pickups()

func set_camera_limits():
	var map_size = $World.get_used_rect()
	var cell_size = $World.cell_size
	$Player/Camera2D.limit_left = (map_size.position.x) * cell_size.x
	$Player/Camera2D.limit_right = (map_size.end.x) * cell_size.x
	$Player/Camera2D.limit_bottom = camera_bottom_limit

func spawn_pickups():
	for cell in pickups.get_used_cells():
		var id = pickups.get_cellv(cell)
		var type = pickups.tile_set.tile_get_name(id)
		if type in ['Coin']:
			var c = Collectible.instance()
			var pos = pickups.map_to_world(cell)
			c.init(type, pos + pickups.cell_size/2)
			add_child(c)
			c.connect('pickup', self, '_on_Collectible_pickup', ['Coin'])

func _on_Collectible_pickup(c_type):
	score += 1
	if c_type == 'Coin':
		$SFX/Coin.play()
	emit_signal('score_changed', score)

func _on_Player_dead():
	GameState.restart()

func _on_Door_body_entered(body):
	GameState.next_level()
