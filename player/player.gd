extends KinematicBody2D

signal life_changed
signal dead

var life

const UP = Vector2(0, -1)

enum {IDLE, WALK, DUCK, JUMP, HURT, DEAD}
var state
var anim
var new_anim

var motion = Vector2()

export (int) var speed = 350
export (int) var gravity = 40
export (int) var jump_speed = -900
export (int) var max_y = 630

func start(pos):
	position = pos
	show()
	change_state(IDLE)
	life = 3
	emit_signal('life_changed', life)

func hurt():
	if state != HURT:
		change_state(HURT)

func change_state(new_state):
	state = new_state
	match state:
		IDLE:
			new_anim = 'idle'
		WALK:
			new_anim = 'walk'
		DUCK:
			new_anim = 'duck'
		JUMP:
			new_anim = 'jump'
		HURT:
			new_anim = 'hurt'
			motion.y = -900
			motion.x = 300 * sign(motion.x)
			life -= 1
			emit_signal('life_changed', life)
			yield(get_tree().create_timer(0.5), 'timeout')
			change_state(IDLE)
			if life <= 0:
				change_state(DEAD)
		DEAD:
			emit_signal("dead")

func get_input():
	if state == HURT:
		return
	
	var move_left = Input.is_action_pressed('move_left')
	var move_right = Input.is_action_pressed('move_right')
	var jump = Input.is_action_just_pressed('jump')
	
	if move_left:
		motion.x = -speed
		$Sprite.flip_h = true
	elif move_right:
		motion.x = speed
		$Sprite.flip_h = false
	else:
		motion.x = 0
	
	if jump and is_on_floor():
		change_state(JUMP)
		motion.y = jump_speed
		motion.x = 0
	
	# IDLE transitions to WALK when moving
	if state == IDLE and motion.x != 0:
		change_state(WALK)
	# WALK transitions to IDLE when standing still
	if state == WALK and motion.x == 0:
		change_state(IDLE)
	# transition to JUMP when falling off an edge
	if state in [IDLE, WALK] and !is_on_floor():
		change_state(JUMP)
	# transition to IDLE when on floor
	if state == JUMP and is_on_floor():
		change_state(IDLE)

func _ready():
	change_state(IDLE) 

func _physics_process(_delta):
	motion.y += gravity
	
	get_input()
	
	for idx in range(get_slide_count()):
		var collision = get_slide_collision(idx)
		if collision.collider.is_in_group('enemies'):
			var player_feet = (position + $CollisionShape2D.shape.extents).y
			if player_feet < collision.collider.position.y:
				collision.collider.take_damage()
				motion.y = -200
			else:
				hurt()
	
	if position.y >= max_y:
		emit_signal("dead")
	
	if new_anim != anim:
		anim = new_anim
		$Sprite.play(anim)
	
	motion = move_and_slide(motion, UP)
