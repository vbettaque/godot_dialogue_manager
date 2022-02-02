extends CanvasLayer


signal actioned(next_id)


const Line = preload("res://addons/dialogue_manager/dialogue_line.gd")
const MenuItem = preload("res://addons/dialogue_manager/example_balloon/menu_item.tscn")


onready var balloon := $Balloon
onready var margin := $Balloon/Margin
onready var character_label := $Balloon/Margin/VBox/Character
onready var dialogue_label := $Balloon/Margin/VBox/Dialogue
onready var responses_menu := $Balloon/Margin/VBox/Responses/Menu


var dialogue: Line


func _ready() -> void:
	balloon.visible = false
	
	if not dialogue:
		queue_free()
		return
	
	if dialogue.character != "":
		character_label.visible = true
		character_label.bbcode_text = dialogue.character
	else:
		character_label.visible = false
	
	dialogue_label.dialogue = dialogue
	
	# Show any responses we have
	responses_menu.is_active = false
	for item in responses_menu.get_children():
		item.queue_free()
	
	if dialogue.responses.size() > 1:
		for response in dialogue.responses:
			var item = MenuItem.instance()
			item.bbcode_text = response.prompt
			responses_menu.add_child(item)
	
	# Make sure our responses get included in the height reset
	responses_menu.visible = true
	
	yield(get_tree(), "idle_frame")
	balloon.rect_min_size = margin.rect_size
	balloon.rect_size = Vector2(0, -1)
	balloon.rect_global_position = Vector2(0, balloon.get_viewport_rect().size.y - balloon.rect_size.y)
	
	# Ok, we can hide it now. It will come back later if we have any responses
	responses_menu.visible = false
	
	# Show our box
	balloon.visible = true
	
	dialogue_label.type_out()
	yield(dialogue_label, "finished")
	
	# Wait for input
	var next_id: String = ""
	if dialogue.responses.size() > 1:
		responses_menu.is_active = true
		responses_menu.visible = true
		var response = yield(responses_menu, "actioned")
		next_id = dialogue.responses[response[0]].next_id
	else:
		while true:
			if Input.is_action_just_pressed("ui_accept"):
				next_id = dialogue.next_id
				break
			yield(get_tree(), "idle_frame")
	
	# Send back input
	emit_signal("actioned", next_id)
	queue_free()
