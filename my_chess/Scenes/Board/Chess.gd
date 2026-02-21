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
	
	"MD": preload("uid://dxrwlseblnmip")
}

const TEXTURE_HOLDER = preload("uid://d3cyn0rmw3q6u")

@onready var piece: = $Pieces
@onready var dots: = $Dots
@onready var turn_: = $Turn

# Variebles
var board: Array # Board
var white: bool = true
var state: bool = false # true - move; false - select
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
			
			if !state and (white and board[y_index][x_index] > PN.EMPTY or !white and board[y_index][x_index] < PN.EMPTY) :
				selected_piece = Vector2(y_index, x_index)
				show_options()
				state = true
			elif state: set_move(y_index, x_index)

func is_mouse_out() -> bool: # Check if tap is on the board
	if get_global_mouse_position().x < 0 or get_global_mouse_position().x > BOARD_WIDTH or get_global_mouse_position().y > 0 or get_global_mouse_position().y < -BOARD_WIDTH:
		return true
	return false

func display_board() -> void: # Display board from board array
	for child in piece.get_children():
		child.queue_free()
	
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

func show_options() -> void:
	moves = get_moves()
	if moves.is_empty():
		state = false
		return
	show_dots()

func show_dots() -> void:
	var nmoves: Array
	for group in moves:
		for i in range(group.size()):
			nmoves.append(group[i])
			var holder = TEXTURE_HOLDER.instantiate()
			dots.add_child(holder)
			holder.texture = PS.MD
			
			var alpha: float
			if group.size() == 1:
				alpha = 255.0
			else:
				alpha = lerp(255.0, 200.0, float(i) / float(group.size() - 1))
			holder.modulate.a = alpha / 255.0
			
			var move = group[i]
			holder.global_position = Vector2(move.y * CELL_WIDTH + CELL_WIDTH/2.0, -move.x * CELL_WIDTH - CELL_WIDTH/2.0)
	moves = nmoves

func delete_dots():
	for dot in dots.get_children():
		dot.queue_free()

func set_move(y_index, x_index):
	for move in moves:
		if move.x == y_index and move.y == x_index:
			board[y_index][x_index] = board[selected_piece.x][selected_piece.y]
			board[selected_piece.x][selected_piece.y] = PN.EMPTY
			white = !white
			display_board()
			break
	delete_dots()
	state = false
	if !state and (white and board[y_index][x_index] > PN.EMPTY or !white and board[y_index][x_index] < PN.EMPTY) :
		selected_piece = Vector2(y_index, x_index)
		show_options()
		state = true

func get_moves() -> Array:
	var _moves: Array
	match abs(board[selected_piece.x][selected_piece.y]):
		PN.WPOWNN: _moves = get_pawn_moves()
		PN.WKNIGHTN: _moves = get_knight_moves()
		PN.WBISHOPN: _moves = get_bishop_moves()
		PN.WROCKN: _moves = get_rook_moves()
		PN.WQUEENN: _moves = get_queen_moves()
		PN.WKINGN: _moves = get_king_moves()
	return _moves

#region Get moves
func get_rook_moves() -> Array:
	var _moves: = []
	var directions = [Vector2(0, 1), Vector2(0, -1), Vector2(1, 0), Vector2(-1, 0)]
	
	for dir in directions:
		var group: = []
		var pos = selected_piece
		pos += dir
		while is_valid_position(pos):
			if is_empty(pos): group.append(pos)
			elif is_enemy(pos):
				group.append(pos)
				break
			else: break
			pos += dir
		if group.size() > 0:
			_moves.append(group)
	
	return _moves
func get_bishop_moves() -> Array:
	var _moves: = []
	var directions = [Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1)]
	
	for dir in directions:
		var group: = []
		var pos = selected_piece
		pos += dir
		while is_valid_position(pos):
			if is_empty(pos): group.append(pos)
			elif is_enemy(pos):
				group.append(pos)
				break
			else: break
			pos += dir
		if group.size() > 0:
			_moves.append(group)
	
	return _moves
func get_queen_moves() -> Array:
	var _moves: = []
	var directions = [Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1), 
	Vector2(0, 1), Vector2(0, -1), Vector2(1, 0), Vector2(-1, 0)]
	
	for dir in directions:
		var group: = []
		var pos = selected_piece
		pos += dir
		while is_valid_position(pos):
			if is_empty(pos): group.append(pos)
			elif is_enemy(pos):
				group.append(pos)
				break
			else: break
			pos += dir
		if group.size() > 0:
			_moves.append(group)
	
	return _moves
func get_king_moves() -> Array:
	var _moves: = []
	var directions = [Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1), 
	Vector2(0, 1), Vector2(0, -1), Vector2(1, 0), Vector2(-1, 0)]
	
	for dir in directions:
		var group: = []
		var pos = selected_piece + dir
		if is_valid_position(pos):
			if is_empty(pos): group.append(pos)
			elif is_enemy(pos):
				group.append(pos)
		if group.size() > 0:
			_moves.append(group)
	
	return _moves
func get_knight_moves() -> Array:
	var _moves: = []
	var directions = [Vector2(-2, 1), Vector2(-2, -1), Vector2(-1, -2), Vector2(1, -2), 
	Vector2(2, 1), Vector2(2, -1), Vector2(1, 2), Vector2(-1, 2)]
	
	for dir in directions:
		var group: = []
		var pos = selected_piece + dir
		if is_valid_position(pos):
			if is_empty(pos): group.append(pos)
			elif is_enemy(pos):
				group.append(pos)
		if group.size() > 0:
			_moves.append(group)
	
	return _moves
func get_pawn_moves() -> Array:
	var _moves: Array
	var direction: Vector2
	var is_first_move: = false
	var group_1: = []
	var group_2: = []
	var group_3: = []
	
	if white: direction = Vector2(1, 0)
	else: direction = Vector2(-1, 0)
	
	if white and selected_piece.x == 1 or !white and selected_piece.x == 6:
		is_first_move = true
	
	var pos = selected_piece + direction
	if is_valid_position(pos) and is_empty(pos):
		group_1.append(pos)
		pos = selected_piece + direction * 2
		if is_first_move and is_valid_position(pos) and is_empty(pos):
			group_1.append(pos)
	
	pos = selected_piece + Vector2(direction.x, 1)
	if is_valid_position(pos) and is_enemy(pos):
		group_2.append(pos)
	
	pos = selected_piece + Vector2(direction.x, -1)
	if is_valid_position(pos) and is_enemy(pos):
		group_3.append(pos)
	
	_moves = [group_1, group_2, group_3]
	return _moves
func is_valid_position(pos: Vector2) -> bool: # Check if cell on the board
	if pos.x >= 0 and pos.x < BOARD_SIZE and pos.y >= 0 and pos.y < BOARD_SIZE: return true
	return false
func is_empty(pos: Vector2) -> bool: # Check if cell empty
	if board[pos.x][pos.y] == PN.EMPTY: return true
	return false
func is_enemy(pos: Vector2) -> bool: # Check if cell enemy
	if white and board[pos.x][pos.y] < PN.EMPTY or !white and board[pos.x][pos.y] > PN.EMPTY: return true
	return false
#endregion
