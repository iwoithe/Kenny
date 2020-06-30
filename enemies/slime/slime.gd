extends KinematicBody2D

const UP = Vector2(0, -1)

export (int) var speed = 50
export (int) var gravity = 40
export (int) var facing = -1

export (int) var raycast_left_depth = 15
export (int) var raycast_right_depth = 15

var motion = Vector2()

onready var rc_left = $raycast_left
onready var rc_right = $raycast_right

func take_damage():
	$Sprite.play('death')
	$SquashedSFX.play()
	$CollisionShape2D.disabled = true
	$CollisionShape2D2.disabled = true
	set_physics_process(false)
	$kill_timer.start()

func _ready():
	rc_left.cast_to.y = raycast_left_depth
	rc_right.cast_to.y = raycast_right_depth
	$Sprite.play("walk")

func _physics_process(_delta):
	$Sprite.flip_h = motion.x > 0
	motion.y += gravity
	motion.x = facing * speed
	
	motion = move_and_slide(motion, UP)
	
	for idx in range(get_slide_count()):
		var collision = get_slide_collision(idx)
		if collision.collider.name == 'Player':
			collision.collider.hurt()
	
	if !(rc_left.is_colliding()) and (facing == -1):
		facing *= -1
	if !(rc_right.is_colliding()) and (facing == 1):
		facing *= -1

	if position.y > 1000:
		queue_free()

func _on_kill_timer_timeout():
	queue_free()
