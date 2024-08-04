extends Node2D

var note_scene = preload("res://Note.tscn")
var track_positions: Array[float] = [100.0, 200.0, 300.0, 400.0]  # 四个轨道的Y坐标
var spawn_timer: float = 0.0
var spawn_interval: float = 1.0  # 生成音符的间隔时间
var score: int = 0
var feedback_label: Label

func _ready() -> void:
	$ScoreLabel.text = "Score: 0"
	print("Game started")
	
	# 添加轨道背景
	for i in range(4):
		var track = ColorRect.new()
		track.color = Color(0.5, 0.5, 0.5, 0.3)  # 半透明灰色
		track.size = Vector2(800, 50)
		track.position = Vector2(0, track_positions[i] - 25)
		add_child(track)
	
	# 添加击打区域
	for i in range(4):
		var hit_area = ColorRect.new()
		hit_area.color = Color(1, 0, 0, 0.3)  # 半透明红色
		hit_area.size = Vector2(100, 50)
		hit_area.position = Vector2(50, track_positions[i] - 25)
		add_child(hit_area)
	
	# 添加反馈标签
	feedback_label = Label.new()
	feedback_label.name = "FeedbackLabel"
	feedback_label.position = Vector2(400, 50)
	feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	feedback_label.add_theme_font_size_override("font_size", 24)
	add_child(feedback_label)

	# 创建计时器来清除反馈
	var timer = Timer.new()
	timer.timeout.connect(_on_feedback_timer_timeout)
	timer.wait_time = 0.5
	timer.one_shot = false
	add_child(timer)
	timer.start()

	print("Game started! Press D, F, J, K to hit the notes when they reach the red area.")

func _on_feedback_timer_timeout() -> void:
	feedback_label.text = ""

func _process(delta: float) -> void:
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_note()
		spawn_timer = 0.0

func spawn_note() -> void:
	var note = note_scene.instantiate()
	var track = randi() % 4  # 随机选择一个轨道
	note.position = Vector2(800, track_positions[track])  # 在屏幕右侧生成音符
	add_child(note)
	print("Note spawned at position: ", note.position)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.pressed:
		match event.keycode:
			KEY_D:
				check_note(0)
			KEY_F:
				check_note(1)
			KEY_J:
				check_note(2)
			KEY_K:
				check_note(3)

func check_note(track: int) -> void:
	var hit_area = Rect2(50, track_positions[track] - 25, 100, 50)
	var closest_note = null
	var closest_distance = 1000.0

	for note in get_tree().get_nodes_in_group("notes"):
		if hit_area.has_point(note.position):
			var distance = abs(note.position.x - 100)  # 100 是击打区域的中心
			if distance < closest_distance:
				closest_note = note
				closest_distance = distance

	if closest_note:
		var score_gain = int(max(10, 100 - closest_distance))
		score += score_gain
		$ScoreLabel.text = "Score: " + str(score)
		feedback_label.text = "Hit! +" + str(score_gain)
		print("Hit! Score gain: ", score_gain)
		closest_note.queue_free()
	else:
		feedback_label.text = "Miss!"
		print("Miss!")
