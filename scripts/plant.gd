#sprites: plant
extends AnimatedSprite

const LEVEL_UP_1 = 100
const LEVEL_UP_2 = 200
const LEVEL_UP_3 = 300
var plant_water = 50
const WATER_LOSS=2
const WATERING_RATE = 40
var at_plant = false
var time_start = false
var time_left = 0
var time_water = 0.17


onready var water_text = get_node("plant_water")
onready var plant_area = get_node("plant_area")
onready var anim = get_node("anim")
onready var particles_1 = get_node("immunity_particles")
onready var particles_2 = get_node("immunity_particles1")

onready var parent = get_parent()
var water_flow
var is_leveling_1 = false
var is_leveling_2 = false
var is_leveling_3 = false

func _ready():
	set_fixed_process(true)
	set_process_input(true)
	set_frame(1)
	if parent!=null: 
		parent = parent.get_name()
		water_flow = get_node("/root/"+parent+"/marta/water_flow")
	particles_1.set_emitting(false)
	particles_2.set_emitting(false)
	plant_area.connect("area_enter",self,"_on_area_enter")
	plant_area.connect("area_exit",self,"_on_area_exit")
	
func _fixed_process(delta):

	if plant_water>LEVEL_UP_1 && !is_leveling_1:
		anim.play("level_up_1")
		is_leveling_1 = true
	if plant_water>LEVEL_UP_2 && !is_leveling_2:
		anim.play("level_up_2")
		is_leveling_2 = true
	if plant_water>LEVEL_UP_3 && !is_leveling_3:
		anim.play("level_up_max")
		is_leveling_3 = true
	if plant_water==0:
		set_frame(0)
		
	if  at_plant && game.watering && !is_leveling_3:
		plant_water += delta * WATERING_RATE
	elif !is_leveling_3:
		plant_water -= delta * WATER_LOSS
		plant_water = max(plant_water,0)
		
	if !is_leveling_3:
		water_text.set_text(str(int(plant_water)))
	else:
		particles_1.set_emitting(true)
		particles_2.set_emitting(true)
		water_text.set_text("max")
		

	if time_start:
		if !at_plant && (time_left == 0):
			water_flow.set_lifetime(1) 
			time_start = false
			
	time_left -= delta
	time_left = max(time_left,0)
	

	
	

func _on_area_enter(other_body):
	if other_body.is_in_group(game.GROUP_WATER_AREA):
		at_plant = true
		water_flow.set_lifetime(time_water)
	
func _on_area_exit(other_body):
	if other_body.is_in_group(game.GROUP_WATER_AREA):
		at_plant = false
		time_start = true
		time_left = time_water
	

	
	
	
