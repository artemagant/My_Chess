extends Sprite2D

enum PN { # Pieces Numbers For Board
	BPOWNN = -1,
	BKNIGHTN = -2,
	BBISHOPN = -3,
	BROCKN = -4,
	BQUEENN = -5,
	BKINGN = -6,
	EMPTY = 0,
	WPOWNN = 1,
	WKNIGHTN = 2,
	WBISHOPN = 3,
	WROCKN = 4,
	WQUEENN = 5,
	WKINGN = 6,
}

#region Variebles
@export var BOARD_SIZE: = 8
@export var CELL_WIDTH: = 16
var BOARD_WIDTH:= BOARD_SIZE * CELL_WIDTH

const PS = { # Pieces Sprites
	"WPOWNS": preload("uid://bqvcbvwyduwxj"),
	"BPOWNS": preload("uid://42rlwdso603k"),
	"WKNIGHTS": preload("uid://dxi1rhss57cx4"),
	"BKNIGHTS": preload("uid://by064ojr46xo"),
	"WBISHOPS": preload("uid://b5h0sqs28srrd"),
	"BBISHOPS": preload("uid://3inpam73bvy6"),
	"WROCKS": preload("uid://68x6m6lu1xe5"),
	"BROCKS": preload("uid://0so85mkvqvfj"),
	"WQUEENS": preload("uid://coo25q21u2thc"),
	"BQUEENS": preload("uid://bx3oifvrenwq1"),
	"WKINGS": preload("uid://bnpmwvmy41yty"),
	"BKINGS": preload("uid://bn8j75lyrhqjv"),
}

const TEXTURE_HOLDER = preload("uid://d3cyn0rmw3q6u")

@onready var piece: = $Pieces
@onready var dots: = $Dots
@onready var turn_: = $Turn

# Variebles
var board: Array # Board
var turn: bool # true - our; false - not our
var we: bool # true - white; false - black
var state: bool # true - move; false - select
var moves: = [] # Possible moves
var selected_piece: Vector2 # Index of selected piece
#endregion

func _ready() -> void:
	# Make Starting Board
	board.append([PN.WROCKN, PN.WKNIGHTN, PN.WBISHOPN, PN.WQUEENN, PN.WKINGN, PN.WBISHOPN, PN.WKNIGHTN, PN.WROCKN])
	board.append([PN.WPOWNN, PN.WPOWNN, PN.WPOWNN, PN.WPOWNN, PN.WPOWNN, PN.WPOWNN, PN.WPOWNN, PN.WPOWNN])
	board.append([PN.EMPTY, PN.EMPTY, PN.EMPTY, PN.EMPTY, PN.EMPTY, PN.EMPTY, PN.EMPTY, PN.EMPTY])
	board.append([PN.EMPTY, PN.EMPTY, PN.EMPTY, PN.EMPTY, PN.EMPTY, PN.EMPTY, PN.EMPTY, PN.EMPTY])
	board.append([PN.EMPTY, PN.EMPTY, PN.EMPTY, PN.EMPTY, PN.EMPTY, PN.EMPTY, PN.EMPTY, PN.EMPTY])
	board.append([PN.EMPTY, PN.EMPTY, PN.EMPTY, PN.EMPTY, PN.EMPTY, PN.EMPTY, PN.EMPTY, PN.EMPTY])
	board.append([PN.BPOWNN, PN.BPOWNN, PN.BPOWNN, PN.BPOWNN, PN.BPOWNN, PN.BPOWNN, PN.BPOWNN, PN.BPOWNN])
	board.append([PN.BROCKN, PN.BKNIGHTN, PN.BBISHOPN, PN.BQUEENN, PN.BKINGN, PN.BBISHOPN, PN.BKNIGHTN, PN.BROCKN])
	
	# Display board
	display_board()

# Take the taps on the screen and get the index of selected cell
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if is_mouse_out():
				return
			var x_index = snapped(get_global_mouse_position().x, 0) / CELL_WIDTH
			var y_index = abs(snapped(get_global_mouse_position().y, 0) / CELL_WIDTH)
			
			if !state and turn and (our(board[y_index][x_index]) or !our(board[y_index][x_index])):
				show_options()
				selected_piece = Vector2(y_index, x_index)

func our(number: PN) -> bool: # Check if piece is our
	if (number < 0 and !we) or (number > 0 and we):
		return true
	return false

func is_mouse_out() -> bool: # Check if tap is on the board
	if get_global_mouse_position().x < 0 or get_global_mouse_position().x > BOARD_WIDTH or get_global_mouse_position().y > 0 or get_global_mouse_position().y < -BOARD_WIDTH:
		return true
	return false

func display_board() -> void: # Display board from board array
	for i in BOARD_SIZE:
		for j in BOARD_SIZE:
			var holder: = TEXTURE_HOLDER.instantiate() # New pieces 
			piece.add_child(holder) # Add
			# Position
			holder.global_position = Vector2(j * CELL_WIDTH + CELL_WIDTH/2.0, -i*CELL_WIDTH - CELL_WIDTH/2.0)
			
			match board[i][j]: # Match texture
				PN.WPOWNN: holder.texture = PS.WPOWNS
				PN.WKNIGHTN: holder.texture = PS.WKNIGHTS
				PN.WBISHOPN: holder.texture = PS.WBISHOPS
				PN.WROCKN: holder.texture = PS.WROCKS
				PN.WQUEENN: holder.texture = PS.WQUEENS
				PN.WKINGN: holder.texture = PS.WKINGS
				PN.EMPTY: holder.texture = null
				PN.BPOWNN: holder.texture = PS.BPOWNS
				PN.BKNIGHTN: holder.texture = PS.BKNIGHTS
				PN.BBISHOPN: holder.texture = PS.BBISHOPS
				PN.BROCKN: holder.texture = PS.BROCKS
				PN.BQUEENN: holder.texture = PS.BQUEENS
				PN.BKINGN: holder.texture = PS.BKINGS

func show_options():
	moves = get_moves()
	if moves == []:
		state = false
		return
	

func get_moves():
	pass
