#sript: sink
extends Sprite

onready var sink_area = get_node("sink_area")

func _ready():
	sink_area.add_to_group(game.GROUP_SINKS)
	pass
