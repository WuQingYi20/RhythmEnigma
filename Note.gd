extends Area2D

@export var speed: float = 200.0  # 音符移动速度

func _ready() -> void:
	add_to_group("notes")  # 将音符添加到"notes"组

func _process(delta: float) -> void:
	position.x -= speed * delta  # 音符向左移动
	if position.x < -100:  # 如果音符移出屏幕左侧
		queue_free()  # 删除音符

func _on_area_entered(area: Area2D) -> void:
	print("Note collided with: ", area.name)
