class_name Player
extends CharacterBody2D

const SPEED: float = 200.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var footstep_player: AudioStreamPlayer2D = $FootstepPlayer

# 8 звуков шагов по умолчанию (задашь в инспекторе)
@export var footstep_sounds_default: Array[AudioStream] = []

var last_dir: Vector2 = Vector2.DOWN
var _is_moving: bool = false
var _footstep_index: int = 0

func _ready() -> void:
	# Подписываемся на смену кадров анимации
	anim.frame_changed.connect(_on_anim_frame_changed)


func _physics_process(delta: float) -> void:
	# порядок: (neg_x, pos_x, neg_y, pos_y)
	var input_vector := Input.get_vector("run_left", "run_right", "run_up", "run_down")

	if input_vector.length() > 0.0:
		_is_moving = true
		var dir := input_vector.normalized()
		velocity = dir * SPEED
		move_and_slide()

		last_dir = dir
		_play_run_animation(dir)
	else:
		_is_moving = false
		velocity = Vector2.ZERO
		move_and_slide()
		_play_idle_animation(last_dir)


func _play_run_animation(dir: Vector2) -> void:
	if abs(dir.y) >= abs(dir.x):
		if dir.y < 0.0:
			anim.play("run_up")
		else:
			anim.play("run_down")
	else:
		if dir.x > 0.0:
			anim.play("run_right")
		else:
			anim.play("run_left")


func _play_idle_animation(dir: Vector2) -> void:
	if dir == Vector2.ZERO:
		dir = Vector2.DOWN

	if abs(dir.y) >= abs(dir.x):
		if dir.y < 0.0:
			anim.play("idle_up")
		else:
			anim.play("idle_down")
	else:
		if dir.x > 0.0:
			anim.play("idle_right")
		else:
			anim.play("idle_left")

const FOOTSTEP_FRAMES := [0, 3, 7] # под твой спрайт

func _on_anim_frame_changed() -> void:
	if not _is_moving:
		return

	var current_anim := anim.animation
	if not current_anim.begins_with("run_"):
		return

	var frame := anim.frame
	if frame in FOOTSTEP_FRAMES:
		_play_footstep()



func _play_footstep() -> void:
	if footstep_sounds_default.is_empty():
		return

	# берём звук по порядку
	var sfx: AudioStream = footstep_sounds_default[_footstep_index]

	# продвигаем индекс вперёд по кругу
	_footstep_index = (_footstep_index + 1) % footstep_sounds_default.size()

	# играем без рандома по высоте, чтобы не ломать задуманный ритм
	footstep_player.stream = sfx
	footstep_player.play()
