#scirpt: cat

extends Node2D

var state 
onready var parent = get_parent()
const STATE_IDLE          = 1
const STATE_PATROL        = 2
const STATE_GOTO_PLANT    = 3
const STATE_DESTROY_PLANT = 4
const STATE_RUN           = 5
const STATE_HIDE          = 6

const WALK_SPEED = 0.8

var start_point
var end_point
var plants

func _ready():
	if parent != null:
		print("jest parent?")
		parent = parent.get_name()
		start_point = get_node("/root/"+parent+"/start")
		end_point = get_node("/root/"+parent+"/end")
		plants = get_tree().get_nodes_in_group("plants")
		
	state = PatrolState.new(self,start_point,end_point)
	set_fixed_process(true)
	pass
	
func _fixed_process(delta):
	state.update(delta)
		
func set_state(new_state):
	state.exit()
	if new_state == STATE_IDLE:
		state = IdleState.new(self)
	elif new_state == STATE_PATROL:
		state = PatrolState.new(self)
	elif new_state == STATE_GOTO_PLANT:
		state = GoToPlantState.new(self)
	elif new_state == STATE_DESTROY_PLANT:
		state = DestroyPlantState.new(self)
	elif new_state == STATE_RUN:
		state = RunState.new(self)
	elif new_state == STATE_HIDE:
		state = HideState.new(self)
		
	
	

#class IDLE STATE ---------------------------------------------------------------------------------->

class IdleState:
	
	var cat 
	
	func _init(cat):
		self.cat = cat
		print("cat is in idle state")
		pass
	
	func update(delta):
		pass
		
	func input():
		pass
		
	func exit():
		pass
		
#class PATROL STATE ---------------------------------------------------------------------------------->

class PatrolState extends Node2D:
	
	var cat
	var sprite = cat.get_node("sprite")
	
	var start_position
	var end_position
	var start_point
	var end_point
	
	var start_move = true
	var end_move = false
	
	func _init(cat,start_point,end_point):
		self.cat = cat
		self.start_point = start_point
		self.end_point = end_point
		print("cat is in patrol state")
		pass
	
	func update(delta):
	
		if start_move:
			move_to_start()
		if end_move:
			move_to_end()
		if start_point != null:
			if cat.get_pos().x < start_point.get_pos().x:
				print("zmiana kierunku na prawo")
				start_move = false
				end_move = true
		if end_point != null:
			if cat.get_pos().x > end_point.get_pos().x:
				print("zmiana kierunku na lewo")
				start_move = true
				end_move = false
				
		

		pass
		
	
		
	func move_to_end():
		cat.set_scale(Vector2(1,1))
		cat.move(Vector2(WALK_SPEED,0))
		
	func move_to_start():
		cat.set_scale(Vector2(-1,1))
		cat.move(Vector2(-WALK_SPEED,0))
		pass
	
	func input():
		pass
		
	func exit():
		pass
		
#class GO TO PLANT STATE ---------------------------------------------------------------------------------->

class GoToPlantState:
	
	var cat
	
	func _init(cat):
		self.cat = cat
		print("cat is going to the plant")
		pass
	
	func update(delta):
		pass
		
	func input():
		pass
		
	func exit():
		pass
		
#class  DESTROY PLANT STATE---------------------------------------------------------------------------------->

class DestroyPlantState:
	
	var cat
	
	func _init(cat):
		self.cat = cat
		print("cat is destroying plant")
		pass
	
	func update(delta):
		pass
		
	func input():
		pass
		
	func exit():
		pass
		
#class RUN STATE ---------------------------------------------------------------------------------->

class RunState:
	
	var cat
	
	func _init(cat):
		self.cat = cat
		print("cat is running away from marta")
		pass
	
	func update(delta):
		pass
		
	func input():
		pass
		
	func exit():
		pass
		

#class HIDE STATE ---------------------------------------------------------------------------------->

class HideState:
	
	var cat
	
	func _init(cat):
		self.cat = cat
		print("cat is hiding")
		pass
	
	func update(delta):
		pass
		
	func input():
		pass
		
	func exit():
		pass
