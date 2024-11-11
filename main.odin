package main

import "core:fmt"
import "core:mem"
import rl "vendor:raylib"

import "data"
import bres "libs/bresenham"

import life "life/simple"
// import life "life/abrash"
// import life "life/simple/static"
// import life "life/abrash/static"


print := fmt.println


main :: proc() {
	context.allocator = track_alloc_init()

	rl.SetTraceLogLevel(rl.TraceLogLevel.WARNING)

	rl.InitWindow(data.SW, data.SH, "Game of Life - Odin/Raylib")
	defer rl.CloseWindow()

	rl.SetTargetFPS(60)

	data.init_screen()

	life.init()
	life.randomize_cells()

	t1 := rl.GetTime()

	main_loop: for !rl.WindowShouldClose() {
		defer free_all(context.temp_allocator)

		t2 := rl.GetTime()
		data.dt = f32(t2-t1)
		t1 = t2
		data.ellapsed_time += f64(data.dt)

		handle_input()

		if !data.paused {
			life.compute_gen()
		}

		rl.BeginDrawing()
			// rl.ClearBackground(rl.BLACK)

			data.clear_screen()
			life.draw_grid()

			rl.UpdateTexture(data.screen.tex, data.screen.pixels)
			rl.DrawTextureEx(data.screen.tex, rl.Vector2{}, 0, f32(data.scale), rl.WHITE);  // Draw a Texture2D with extended parameters
		rl.EndDrawing()

		track_alloc_check_bad_frees()
	}

	life.destroy()

	track_alloc_finish()
}


toggle_pause :: proc() {
	data.paused = !data.paused
	print("paused", data.paused)
}

draw_cells :: proc(gm:[2]int) {
	using data
	points := bres.line(last_gm.x, last_gm.y, gm.x, gm.y)
	for p in points do life.revive_cell(p.x, p.y)
}

erase_cells :: proc(gm:[2]int) {
	using data
	points := bres.line(last_gm.x, last_gm.y, gm.x, gm.y)
	for p in points do life.kill_cell(p.x, p.y)
}

handle_input :: proc() {
	using data

	mpos :[2]int = {int(rl.GetMouseX()), int(rl.GetMouseY())}

	// mouse position, in grid coords
	gm := [2]int { mpos.x/scale, mpos.y/scale }
	defer last_gm = gm

	// rl.MouseButton
	if      rl.IsMouseButtonDown(.LEFT)  do draw_cells(gm)
	else if rl.IsMouseButtonDown(.RIGHT) do erase_cells(gm)

	// rl.KeyboardKey
	if      rl.IsKeyPressed(.SPACE) do toggle_pause()
	else if rl.IsKeyPressed(.R)     do life.randomize_cells()
	else if rl.IsKeyPressed(.C)     do life.clear_grid()
	else if rl.IsKeyPressed(.F)     do life.fill_grid()
}
