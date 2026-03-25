extends Node2D

@onready var head = $KunzhaHead
@onready var foods = [$Furui1,$Furui2,$Furui3,$Furui4,$Furui5]

func _ready():
	call_deferred("spawn_food")

func spawn_food():
	for f in foods:
		f.visible = false
	
	var idx = randi() % foods.size()
	foods[idx].position = Vector2(
		randi() % 2300 + 120,
		randi() % 1200 + 120
	)
	foods[idx].visible = true

func on_food_eaten():
	for food in foods:
		if food.visible:
			head.add_body(food.texture)
			break
	spawn_food()
