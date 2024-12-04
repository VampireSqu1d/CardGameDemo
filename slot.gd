class_name Slot extends PanelContainer

@export var slot_text: String = ""
@export var slot_type: Type = Type.PLACE
@export var bg_color: Color

@export_category("Roration Anim Value")
@export_range(0.0, 15.0) var rotation_tilt: float = 5.0
@export_range(0.05, 1.0) var tilt_duration: float = 0.2

@onready var color_rect: ColorRect = %ColorRect
@onready var rich_text_label: RichTextLabel = %RichTextLabel


enum Type {DISCARD, PLACE, HAND, ACTIVE, DECK}

var has_card: bool = false

var card_in_slot: Card:
	set(value):
		card_in_slot = value
		if card_in_slot:
			has_card = true
		else:
			has_card = false


var tilt_tween: Tween

func _ready() -> void:
	rich_text_label.text = slot_text
	color_rect.color = bg_color
	
	pivot_offset.x = size.x / 2.0
	pivot_offset.y = size.y / 2.0




func _on_mouse_entered() -> void:
	if tilt_tween and tilt_tween.is_running():
		tilt_tween.kill()
	
	tilt_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)
	tilt_tween.tween_property(self, "rotation", deg_to_rad(rotation_tilt), tilt_duration)
	tilt_tween.tween_property(self, "rotation", deg_to_rad(-rotation_tilt), tilt_duration)
	tilt_tween.tween_property(self, "rotation", deg_to_rad(rotation_tilt), tilt_duration)
	tilt_tween.tween_property(self, "rotation", deg_to_rad(-rotation_tilt), tilt_duration)
	tilt_tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR)
	tilt_tween.tween_property(self, "rotation", deg_to_rad(0),0.2)


func _on_mouse_exited() -> void:
	if tilt_tween and tilt_tween.is_running():
		tilt_tween.kill()
	tilt_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)
	tilt_tween.tween_property(self, "rotation", deg_to_rad(0),0.2)


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is Card 

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	data = data as Card
	#if has_card: return
	data.reparent(self)
	data.z_index += 20
	#data.move_to_pos(self.position + self.size/2)
	if slot_type == Type.DISCARD:
		data.destroy()
	card_in_slot = data
