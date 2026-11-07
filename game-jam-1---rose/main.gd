extends Node2D

const W := 640.0
const H := 480.0
const COLS := 10
const ROWS := 5

var player_x := W / 2
var bullets: Array[Vector2] = []
var bombs: Array[Vector2] = []
var aliens: Array[Vector2] = []
var alien_dir := 1.0
var alien_speed := 30.0
var shoot_cd := 0.0
var bomb_cd := 1.0
var score := 0
var lives := 3
var level := 1
var state := "play"
var font: Font


func _ready() -> void:
	font = ThemeDB.fallback_font
	start_level()


func start_level() -> void:
	aliens.clear()
	for r in ROWS:
		for c in COLS:
			aliens.append(Vector2(80 + c * 44, 60 + r * 34))
	alien_dir = 1.0
	alien_speed = 30.0 + level * 8.0
	bullets.clear()
	bombs.clear()


func reset() -> void:
	score = 0
	lives = 3
	level = 1
	state = "play"
	start_level()


func _process(delta: float) -> void:
	if state != "play":
		if Input.is_key_pressed(KEY_ENTER):
			reset()
		queue_redraw()
		return

	var dir := Input.get_axis("ui_left", "ui_right")
	if Input.is_key_pressed(KEY_A):
		dir -= 1.0
	if Input.is_key_pressed(KEY_D):
		dir += 1.0
	player_x = clampf(player_x + clampf(dir, -1, 1) * 300.0 * delta, 20, W - 20)

	shoot_cd -= delta
	if (Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_UP)) and shoot_cd <= 0 and bullets.size() < 3:
		bullets.append(Vector2(player_x, H - 50))
		shoot_cd = 0.3

	for i in range(bullets.size() - 1, -1, -1):
		bullets[i].y -= 450.0 * delta
		if bullets[i].y < 0:
			bullets.remove_at(i)

	# move aliens
	var edge := false
	for a in aliens:
		if (a.x > W - 30 and alien_dir > 0) or (a.x < 30 and alien_dir < 0):
			edge = true
			break
	if edge:
		alien_dir = -alien_dir
		for i in aliens.size():
			aliens[i].y += 14
	else:
		var speed := alien_speed * (1.0 + (ROWS * COLS - aliens.size()) / 25.0)
		for i in aliens.size():
			aliens[i].x += alien_dir * speed * delta

	# alien bombs
	bomb_cd -= delta
	if bomb_cd <= 0 and aliens.size() > 0:
		var a: Vector2 = aliens[randi() % aliens.size()]
		bombs.append(a + Vector2(0, 10))
		bomb_cd = maxf(0.3, 1.0 - level * 0.1)
	for i in range(bombs.size() - 1, -1, -1):
		bombs[i].y += 200.0 * delta
		if absf(bombs[i].x - player_x) < 18 and absf(bombs[i].y - (H - 40)) < 14:
			bombs.remove_at(i)
			lives -= 1
			if lives <= 0:
				state = "over"
		elif bombs[i].y > H:
			bombs.remove_at(i)

	# bullet vs alien
	for bi in range(bullets.size() - 1, -1, -1):
		for ai in range(aliens.size() - 1, -1, -1):
			if absf(bullets[bi].x - aliens[ai].x) < 16 and absf(bullets[bi].y - aliens[ai].y) < 12:
				aliens.remove_at(ai)
				bullets.remove_at(bi)
				score += 10
				break

	for a in aliens:
		if a.y > H - 60:
			state = "over"

	if aliens.is_empty() and state == "play":
		level += 1
		start_level()

	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(0, 0, W, H), Color.BLACK)
	for a in aliens:
		draw_rect(Rect2(a.x - 14, a.y - 8, 28, 16), Color.LIME_GREEN)
		draw_rect(Rect2(a.x - 8, a.y - 4, 4, 4), Color.BLACK)
		draw_rect(Rect2(a.x + 4, a.y - 4, 4, 4), Color.BLACK)
		draw_rect(Rect2(a.x - 14, a.y + 8, 6, 4), Color.LIME_GREEN)
		draw_rect(Rect2(a.x + 8, a.y + 8, 6, 4), Color.LIME_GREEN)
	draw_rect(Rect2(player_x - 18, H - 36, 36, 12), Color.CYAN)
	draw_rect(Rect2(player_x - 4, H - 46, 8, 10), Color.CYAN)
	for b in bullets:
		draw_rect(Rect2(b.x - 2, b.y - 8, 4, 12), Color.WHITE)
	for b in bombs:
		draw_rect(Rect2(b.x - 2, b.y - 6, 4, 12), Color.RED)
	draw_string(font, Vector2(10, 22), "SCORE %d" % score, HORIZONTAL_ALIGNMENT_LEFT, -1, 18)
	draw_string(font, Vector2(W / 2 - 30, 22), "LEVEL %d" % level, HORIZONTAL_ALIGNMENT_LEFT, -1, 18)
	draw_string(font, Vector2(W - 100, 22), "LIVES %d" % lives, HORIZONTAL_ALIGNMENT_LEFT, -1, 18)
	if state == "over":
		draw_string(font, Vector2(0, H / 2), "GAME OVER - press Enter", HORIZONTAL_ALIGNMENT_CENTER, W, 32, Color.YELLOW)
