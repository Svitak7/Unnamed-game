#scirpt: marta

extends KinematicBody2D

onready var state = IdleState.new(self)
var previous_state
const STATE_IDLE = 1
const STATE_WALK = 2
const STATE_RUN = 3
const STATE_TIRED = 4
const STATE_WATERING = 5
const STATE_FILLING = 6

const WALK_SPEED = 0.8
const RUN_SPEED  = 2.4

const MAX_STAMINA = 100
const RECHARGE_STAMINA = 40
const RECHARGE_STAMINA_WALK = 10
const CHARGE_STAMINA = 80

const MAX_WATER = 100
const REFILL_WATER = 40
const FLOW_WATER = 40
const SCALE = 1.7


onready var test_stamina = get_node("test_stamina")
onready var test_water = get_node("test_water")
onready var marta_area = get_node("marta_area")
onready var area_water_flow = get_node("area_water_flow")
onready var parent = get_parent()
var start_point
var end_point


signal state_changed

func _ready():
	set_fixed_process(true)
	set_process_input(true)
	marta_area.connect("area_enter",self,"_on_area_enter")
	marta_area.connect("area_exit",self,"_on_area_exit")
	area_water_flow.add_to_group(game.GROUP_WATER_AREA)
	if parent!=null: 
		parent = parent.get_name()
		start_point = get_node("/root/"+parent+"/start")
		end_point = get_node("/root/"+parent+"/end")
	pass
	
func _fixed_process(delta):
	state.update(delta)
	
	if(get_pos().x < start_point.get_pos().x):
		set_pos(Vector2(start_point.get_pos().x,get_pos().y))
		set_scale(Vector2(-SCALE,SCALE))

	if(get_pos().x > end_point.get_pos().x):
		set_pos(Vector2(end_point.get_pos().x,get_pos().y))
	
	pass
func _on_time_out(marta):
	print("Im rest!")
	marta.set_state(marta.STATE_IDLE)
	

func set_state(new_state):
	state.exit()
	previous_state = get_state()
	if new_state == STATE_IDLE:
		state = IdleState.new(self)
	elif new_state == STATE_WALK:
		state = WalkState.new(self)
	elif new_state == STATE_RUN:
		state = RunState.new(self)
	elif new_state == STATE_TIRED:
		state = TiredState.new(self)
	elif new_state == STATE_WATERING:
		state = WateringState.new(self)
	elif new_state == STATE_FILLING:
		state = FillingState.new(self)
		
	emit_signal("state_changed",self)
	pass
	
func get_state():
	if state extends IdleState:
		return STATE_IDLE
	elif state extends WalkState:
		return STATE_WALK
	elif state extends RunState:
		return STATE_RUN
	elif state extends TiredState:
		return STATE_TIRED
	elif state extends WateringState:
		return STATE_WATERING
	elif state extends FillingState:
		return STATE_FILLING
	pass
	
func _on_area_enter(other_body):
	if other_body.is_in_group(game.GROUP_SINKS): game.at_sink = true
func _on_area_exit(other_body):
	if other_body.is_in_group(game.GROUP_SINKS): game.at_sink = false
	
func _input(event):
	state.input(event)
	pass

#class IdleState -------------------------------------------------------

class IdleState:
	
	var marta
	var sprite = marta.get_node("sprite_anim")
	var anim   = marta.get_node("anim")
	
	func _init(marta):
		self.marta = marta
		sprite.set_frame(0)
		print("I am in idle state")
		pass
		
	func _on_time_out():
		print("Im rest!")
		set_state(STATE_IDLE)
		
	func recharge_stamina(delta):
		game.stamina += delta * RECHARGE_STAMINA
		game.stamina = min(game.stamina,MAX_STAMINA)
		

	
	func update(delta):
		recharge_stamina(delta)

		pass
		
	func input(event):
		if Input.is_action_pressed("watering") && game.at_sink && game.water<100:
			marta.set_state(STATE_FILLING)
			return
		if Input.is_action_pressed("watering") && !game.at_sink:
			marta.set_state(STATE_WATERING)
		if Input.is_action_pressed("walk_left") || Input.is_action_pressed("walk_right"):
			if Input.is_action_pressed("run"):
				marta.set_state(STATE_RUN)
			else:
				marta.set_state(STATE_WALK)
			
		pass
		
	func exit():
		
		pass
		

#class WalkState -------------------------------------------------------

class WalkState:
	
	var marta
	var sprite = marta.get_node("sprite_anim")
	var anim = marta.get_node("anim")
	var moving = false;
	var water_flow = marta.get_node("water_flow")
	
	func _init(marta):
		self.marta = marta
		print("I am in the walk state")
		
	func update(delta):
		game.stamina+=delta*RECHARGE_STAMINA_WALK
		game.stamina = min(game.stamina,MAX_STAMINA)
		if Input.is_action_pressed("walk_left"):
			walk_left()
			if !moving:
				anim.play("walk")
				moving=true
		elif Input.is_action_pressed("walk_right"):
			walk_right()
			if !moving:
				anim.play("walk")
				moving=true
		else:
			moving=false
			marta.set_state(marta.STATE_IDLE)
		
	func input(event):
		if Input.is_action_pressed("watering") && game.at_sink && game.water<100:
			marta.set_state(STATE_FILLING)
			return
		if Input.is_action_pressed("watering") && !game.at_sink:
			marta.set_state(STATE_WATERING)
			return
		if Input.is_action_pressed("walk_left") || Input.is_action_pressed("walk_right"):
			if Input.is_action_pressed("run"):
				marta.set_state(STATE_RUN)
		
	func walk_left():
		marta.set_scale(Vector2(-SCALE,SCALE))
		marta.move(Vector2(-WALK_SPEED,0))
	
	func walk_right():
		marta.set_scale(Vector2(SCALE,SCALE))
		marta.move(Vector2(WALK_SPEED,0))
		
	func exit():
		anim.stop()
		sprite.set_frame(0)
		pass
		
#class RunState -------------------------------------------------------

class RunState:
	
	var marta
	var sprite = marta.get_node("sprite_anim")
	var anim = marta.get_node("anim")
	var moving = false
	var water_flow = marta.get_node("water_flow")
	
	
	func _init(marta):
		self.marta = marta
		print("I am in the run state")
	
	func update(delta):
		game.stamina -= delta * CHARGE_STAMINA;
		
		if(game.stamina<0):
			game.stamina=0
			marta.set_state(marta.STATE_TIRED)
		
		if Input.is_action_pressed("walk_left") && Input.is_action_pressed("run"):
			run_left()
			if !moving:
				anim.play("run")
				moving=true
		elif Input.is_action_pressed("walk_right") && Input.is_action_pressed("run"):
			run_right()
			if !moving:
				anim.play("run")
				moving=true
		else:
			moving=false
			marta.set_state(marta.STATE_WALK)
		pass
		
	func input(event):pass
		
		
	func run_left():
		marta.set_scale(Vector2(-SCALE,SCALE))
		marta.move(Vector2(-RUN_SPEED,0))
		pass
		
	func run_right():
		marta.set_scale(Vector2(SCALE,SCALE))
		marta.move(Vector2(RUN_SPEED,0))
		pass
		
	func exit():
		anim.stop()
		sprite.set_frame(0)
		pass
		
	
#class TiredState -------------------------------------------------------

class TiredState:
	
	var marta
	var timer = marta.get_node("tired_timer")
	var anim = marta.get_node("anim")
	
	func _init(marta):
		self.marta = marta
		timer.connect("timeout",self,"_on_time_out")
		timer.start()
		anim.play("tired")
		print("I am in the tired state")
		pass
		
	func _on_time_out():
		print("Im rest!")
		marta.set_state(marta.STATE_IDLE)
	
	func update(delta):
		
		pass
		
	func input(event):
		
		pass
		
	func exit():
		anim.stop()
		pass
		
		
#class WateringState -------------------------------------------------------

class WateringState:
	
	var marta
	var anim = marta.get_node("anim")
	var sprite = marta.get_node("sprite_anim")
	var water_flow = marta.get_node("water_flow")
	var point_water = marta.get_node("point_water")

	func _init(marta):
		water_flow.set_pos(point_water.get_pos())
		self.marta= marta
		anim.play("watering")
		print("I am in the watering state")
		
		
	
	func update(delta):
		if !anim.is_playing():
			water_flow.set_emitting(true)
			game.water -= delta * FLOW_WATER
			game.water = max(game.water,0)
			game.watering = true
		if game.water == 0: 
			water_flow.set_emitting(false)
			game.watering = false
		pass
		
	func input(event):
		if !Input.is_action_pressed("watering"):
			marta.set_state(marta.STATE_IDLE)
		
		
		if (Input.is_action_pressed("walk_left") || Input.is_action_pressed("walk_right")) && !Input.is_action_pressed("watering"):
			if Input.is_action_pressed("run"):
				marta.set_state(STATE_RUN)
			else:
				marta.set_state(STATE_WALK)
		pass
		
	func exit():
		water_flow.set_emitting(false)
		game.watering = false
	
		
		anim.stop()
		anim.play("unwatering")
		pass

#class FillingState -------------------------------------------------------

class FillingState:
	
	var marta
	var sprite = marta.get_node("sprite_anim")
	#TODO
	func _init(marta):
		self.marta = marta
		sprite.set_frame(15)
		print("im refilling")
		pass
		
	
	func update(delta):
		game.water+=delta*REFILL_WATER
		game.water = min(game.water,MAX_WATER)
		if game.water==MAX_WATER: marta.set_state(STATE_IDLE)
		pass
		
	func input(event):
		
		pass
		
	func exit():
		
		pass
