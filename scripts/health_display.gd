extends Control

const heart_bar_scene = preload("res://scenes/heart_bar.tscn")

@onready var container: GridContainer = $MarginContainer/GridContainer
@onready var max_health_field: SpinBox = $DebugContainer/VBoxContainer/MaxHealth/MaxHealthField
@onready var health_per_heart_field: SpinBox = $DebugContainer/VBoxContainer/HealthPerHeart/HealthPerHeartField
@onready var current_health_field: SpinBox = $DebugContainer/VBoxContainer/CurrentHealth/CurrentHealthField
@onready var hearts_per_row_field: SpinBox = $DebugContainer/VBoxContainer/HeartsPerRow/HeartsPerRowField

var hearts_per_row : int = 20

var max_health : int = 55
var health_per_heart : int = 10
var current_health : int = max_health

var new_max_health : int = max_health
var new_health_per_heart : int = health_per_heart
var new_current_health : int = current_health

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()

func _ready() -> void:
	container.columns = hearts_per_row
	initialize()
	max_health_field.value = max_health
	health_per_heart_field.value = health_per_heart
	current_health_field.value = current_health
	hearts_per_row_field.value = hearts_per_row

func initialize():
	var num_hearts : int = ceil(float(max_health) / health_per_heart)
	var remainder : int = current_health % health_per_heart
	for i in num_hearts:
		var heart_bar = heart_bar_scene.instantiate()
		heart_bar.max_value = health_per_heart
		#heart_bar.update_value(health_per_heart)
		#if i == num_hearts - 1 and remainder != 0:
			#heart_bar.update_value(remainder)
		container.call_deferred("add_child", heart_bar)
	await get_tree().process_frame
	update_health(current_health)

func update_health(_value : int):
	var full_hearts : int = floor(float(_value) / health_per_heart)
	
	var remainder : int = _value % health_per_heart
	
	for i in full_hearts:
		container.get_child(i).update_value(health_per_heart)
	
	if full_hearts == container.get_child_count():
		return
	
	if remainder > 0:	
		container.get_child(full_hearts).update_value(remainder)
	
	var offset : int = 0 if remainder == 0 else 1
	for i in range(full_hearts + offset, container.get_child_count()):
		container.get_child(i).update_value(0)
	
func clear():
	for child in container.get_children():
		child.queue_free()

func _on_max_health_field_value_changed(value: float) -> void:
	if value < current_health:
		new_current_health = int(value)
		current_health_field.value = new_current_health
	if value < 1:
		value = 1
		max_health_field.value = value
	new_max_health = int(value)
	

func _on_health_per_heart_field_value_changed(value: float) -> void:
	if value > new_max_health:
		value = new_max_health
		health_per_heart_field.value = value
		
	new_health_per_heart = int(value)
	

func _on_current_health_field_value_changed(value: float) -> void:
	if value > new_max_health:
		value = new_max_health
		current_health_field.value = value
		
	new_current_health = int(value)

func _on_hearts_per_row_field_value_changed(value: float) -> void:
	container.columns = int(value)


func _on_button_pressed() -> void:
	if new_max_health != max_health or health_per_heart != new_health_per_heart:
		clear()
		max_health = new_max_health
		health_per_heart = new_health_per_heart
		current_health = new_current_health
		await get_tree().process_frame
		initialize()
	else:
		current_health = new_current_health
		update_health(current_health)



