class_name Slot extends PanelContainer

@export var slot_text: String = ""
@export var bg_color: Color

@onready var color_rect: ColorRect = %ColorRect
@onready var rich_text_label: RichTextLabel = %RichTextLabel


enum Type {DISCARD, PLACE, ACTIVE, BENCH}


func _ready() -> void:
	rich_text_label.text = slot_text
	color_rect.color = bg_color
