extends Sprite2D

@export var speed = 400
# 身体间距（越大越宽松，绝对不重叠）
@export var body_gap = 25

var direction = Vector2.RIGHT
var body_parts = []
var position_history = []  # 轨迹记录（身体跟着走）

func _process(delta):
	# 记录头部走过的所有位置（轨迹核心）
	position_history.insert(0, position)
	
	# 移动控制
	handle_input()
	position += direction * speed * delta
	
	# 身体跟随轨迹
	update_body()

# 🔥 修复：D键/右键 正确写法！！！
func handle_input():
	if Input.is_action_pressed("ui_up"):
		direction = Vector2.UP
	elif Input.is_action_pressed("ui_down"):
		direction = Vector2.DOWN
	elif Input.is_action_pressed("ui_left"):
		direction = Vector2.LEFT
	elif Input.is_action_pressed("ui_right"):
		direction = Vector2.RIGHT

# 标准贪吃蛇轨迹跟随（身体走回头走过的路）
func update_body():
	for i in range(body_parts.size()):
		var index = (i + 1) * body_gap
		if index < position_history.size():
			body_parts[i].position = position_history[index]
	
	# 限制轨迹长度，防止卡顿
	if position_history.size() > body_parts.size() * body_gap + 100:
		position_history.resize(body_parts.size() * body_gap + 100)

# 碰撞判断（不误吃）
func _on_Area2D_area_entered(area):
	var food_parent = area.get_parent()
	if food_parent.name.find("Furui") != -1 && food_parent.visible:
		get_parent().on_food_eaten()

# 生成身体（不重叠 + 跟轨迹）
func add_body(food_texture):
	var new_body = Sprite2D.new()
	new_body.texture = food_texture
	new_body.scale = Vector2(0.05, 0.05)
	
	# 生成在最后一节身体后面
	if body_parts.size() == 0:
		new_body.position = position_history[body_gap]
	else:
		new_body.position = body_parts[-1].position
	
	get_parent().add_child(new_body)
	body_parts.append(new_body)
