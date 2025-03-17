extends Control

func _process(_delta):
	get_window().size = size


var color_list = [] # for debug
var okhsl_list = [] # for debug
var label_list = []
var number_of_intermediates = 0
var start_color = Color(0,0,0,0)
var end_color = Color(0,0,0,0)
var is_longer_path = false


@export var color_label : PackedScene
@export var color_list_ui: Node


func add_new_label(color: Color, label: String):
	var instance = color_label.instantiate()
	color_list_ui.add_child(instance)
	label_list.append(instance)
	
	instance.get_node("div/Label").text = label
	instance.get_node("div/div/ColorRect").color = color
	instance.get_node("div/div/TextEdit").text = color.to_html(false)


func purge():
	for child in label_list:
		child.queue_free()
	label_list = []


func _on_color_picker_color_changed1(color: Color):
	start_color = color
	recalculate_colors()


func _on_color_picker_color_changed2(color: Color):
	end_color = color
	recalculate_colors()


func _on_text_edit_value_changed(value: float):
	number_of_intermediates = value
	var number_of_colors = number_of_intermediates + 2
	recalculate_colors()


func _on_check_box_toggled(toggled_on: bool) -> void:
	is_longer_path = !is_longer_path
	recalculate_colors()


func recalculate_colors():
	purge()
	var number_of_colors = number_of_intermediates + 2
	
	var start_okhsl = Vector4(start_color.ok_hsl_h, start_color.ok_hsl_s, start_color.ok_hsl_l, start_color.a)
	var end_okhsl = Vector4(end_color.ok_hsl_h, end_color.ok_hsl_s, end_color.ok_hsl_l, end_color.a)
	
	var diff = end_okhsl - start_okhsl
	# Adjustments because hue is circular
	if (is_longer_path):
		diff.x = fmod(fposmod(end_okhsl.x - start_okhsl.x + 0.5, 1.0) + 1.5, 2.0) - 1.0
	else:
		diff.x = fposmod(end_okhsl.x - start_okhsl.x + 0.5, 1.0) - 0.5
	var step = diff / (number_of_intermediates + 1)
	
	var current_okhsl = start_okhsl
	add_new_label(start_color, "Start color")
	for n in number_of_colors - 2:
		current_okhsl += step
		var new_color = Color.from_ok_hsl(current_okhsl.x, current_okhsl.y, current_okhsl.z, current_okhsl.w)
		var color_name = "Color #" + str(n + 2).pad_decimals(0)
		add_new_label(new_color, color_name)
	add_new_label(end_color, "End color")
	
