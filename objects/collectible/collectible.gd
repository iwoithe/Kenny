extends Area2D

signal pickup

var textures = {
				'Coin': 'res://assets/objects/coins/sprites/gold.png',
}

func init(type, pos):
	$Sprite.texture = load(textures[type])
	position = pos

func _on_Collectible_body_entered(body):
	emit_signal('pickup')
	queue_free()
