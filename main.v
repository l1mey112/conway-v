import term.ui as tui
import term
import time
import math

struct App {
mut:
	tui &tui.Context = 0
	mouse_down bool
	pos VectorInt

	paused bool = true

	board[][] bool
}

fn event(e &tui.Event, x voidptr) {
	mut app := &App(x)

	if !e.modifiers.is_empty() {
		if e.modifiers.has(.ctrl) {
			if e.typ == .key_down && e.code == .c {
				exit(0)
			}
		}
		if e.modifiers.has(.shift) {

		}
		if e.modifiers.has(.alt) {

		}
	}

	if e.typ == .mouse_move {
		app.pos = VectorInt{e.x, e.y}
	}
	if e.typ == .mouse_down && e.button == .left{
		app.mouse_down = true
	}
	if e.typ == .mouse_down && e.button == .right{
		app.mouse_down = false
	}

	if e.typ == .key_down && e.code == .enter {
		app.paused = !app.paused
		app.mouse_down = false
	}
}

fn search(board[][] bool, pos VectorInt)int{
	//mut app := &App(a)
	mut find := 0
	//? includes self

	for j in pos.y-1..pos.y+2 {
		for i in pos.x-1..pos.x+2{
			if i < 0 || j < 0 || i >= board[0].len || j >= board.len {continue}
			if board[j][i] == true && !(i == pos.x && j == pos.y) {
				find++
			}
		}
	}

	return find
}

/* fn search(a voidptr, pos VectorInt)int{
	mut app := &App(a)
	mut find := 0

	for j in pos.y-1..pos.y+1 {
		for i in pos.x-1..pos.x+1{
			if i < 0 || j < 0 || i >= app.board[0].len || j >= app.board.len {continue}
			if app.board[j][i] {
				find++
			}
		}
	}

	return find
} */

fn ruint(v f64)u8{
	return u8(math.round(v))
}

fn mapf(old_min f64, old_max f64, new_min f64, new_max f64, value f64)f64{
	return new_min + ((new_max-new_min)/(old_max-old_min)) * (math.clamp(value, old_min, old_max))
}

fn frame(a voidptr) {
	mut app := &App(a)
	/* elapsed := app.tui.frame_count/f64(fps) */

	//? draw
	if app.mouse_down && app.paused {
		app.board[app.pos.y][app.pos.x] = true
	}

	//? iterate
	
	temp := app.board
	for j in 0..app.board.len {
		for i in 0..app.board[0].len  {
			if !app.paused {
				neighbours := search(temp, VectorInt{i, j})

				if neighbours == 3 && temp[j][i] == false{
					app.board[j][i] = true
				}
				if (neighbours == 2 || neighbours == 3) && temp[j][i]{
					//? live
				}else if neighbours < 2 && temp[j][i]{
					app.board[j][i] = false
				} else if neighbours > 3 && temp[j][i]{
					app.board[j][i] = false
				}
			}

			if app.board[j][i] == false {continue}
			app.tui.set_cursor_position(i,j)
			if app.paused { app.tui.write(term.red("█")) } else {
				app.tui.set_color(tui.Color{
					ruint(mapf(0,app.board.len,0,255,j)),
					ruint(mapf(0,app.board[0].len,0,255,i)),
					255
				})
				app.tui.write("█")
			}
		}
	}

	app.tui.flush()
	if !app.paused {time.sleep(time.millisecond * 80)}
	app.tui.clear()
}

//? Any live cell with fewer than two live neighbours dies (referred to as underpopulation).
//? Any live cell with more than three live neighbours dies (referred to as overpopulation).
//? Any live cell with two or three live neighbours lives, unchanged, to the next generation.
//? Any dead cell with exactly three live neighbours comes to life.

const (
	fps = 60
)

fn main(){
	x,y := term.get_terminal_size()
	mut app := &App{
		board: [][]bool{cap: y+1, len: y+1,init:[]bool{cap: x+1,len: x+1, init: false}}
	}
	app.tui = tui.init(
		user_data: app
		frame_fn: frame
		event_fn: event

		window_title: 'V term.ui event viewer'
		hide_cursor: true
		capture_events: true
		frame_rate: fps
		use_alternate_buffer: true
	)

	app.tui.clear()
	app.tui.run() ?
}