package main

import "core:c"
import "core:math"
import "core:time"
import "core:fmt"
import rl "vendor:raylib"

WIN_WIDTH :: 1800
WIN_HEIGHT :: 1000
STEP :: 0.5

Direction :: enum {
    Up = 0,
    Down,
    Right,
    Left,
}

dirs := [4][2]f32 {
    {0, -1},
    {0, 1},
    {1, 0},
    {-1, 0},
}

Segment :: struct {
    start_x, start_y: f32,
    orientation: Direction,
}

dragon: [dynamic]Segment
SEGMENT_SIZE: f32

origin_x, origin_y: f32

// WARNING: 'segm.' is translated implicitly to '(segm^).'

draw :: proc(segm: ^Segment) {
    rl.DrawLineEx({ segm.start_x, segm.start_y }, cast(rl.Vector2)end_point(segm), 5, rl.BLACK);
}

end_point :: proc(segm: ^Segment) -> [2]f32 {
    return { segm.start_x + dirs[segm.orientation][0] * SEGMENT_SIZE, segm.start_y + dirs[segm.orientation][1] * SEGMENT_SIZE }
}

next :: proc(init: Direction) -> Direction {
    switch init {
        case .Up: return .Right
        case .Right: return .Down
        case .Down: return .Left
        case .Left: return .Up
    }

    return cast(Direction)5
}

step :: proc() {
    initial_length := len(dragon)

    rotation_origin := end_point(&dragon[initial_length - 1])

    for i := initial_length - 1; i >= 0; i -= 1 {
        append(&dragon, Segment { rotation_origin[0], rotation_origin[1], next(dragon[i].orientation) })
        rotation_origin = end_point(&dragon[len(dragon) - 1])
    }
}

main :: proc() {
    rl.InitWindow(WIN_WIDTH, WIN_HEIGHT, "Dragon Curve")

    SEGMENT_SIZE = 10

    origin_x = 0
    origin_y = 0

    append(&dragon, Segment { 400, 400, Direction.Up })

    for !rl.WindowShouldClose() {
        if rl.IsMouseButtonPressed(rl.MouseButton.LEFT) {
            step()
        }
        
        if rl.IsKeyDown(rl.KeyboardKey.W) {
            for i in 0 ..< len(dragon) {
                dragon[i].start_y -= STEP;
            }
        }
        else if rl.IsKeyDown(rl.KeyboardKey.S) {
            for i in 0 ..< len(dragon) {
                dragon[i].start_y += STEP;
            }
        }
        else if rl.IsKeyDown(rl.KeyboardKey.A) {
            for i in 0 ..< len(dragon) {
                dragon[i].start_x -= STEP;
            }
        }
        else if rl.IsKeyDown(rl.KeyboardKey.D) {
            for i in 0 ..< len(dragon) {
                dragon[i].start_x += STEP;
            }
        }

        // TODO: better movement + scrolling

        rl.BeginDrawing()
        rl.ClearBackground(rl.GRAY)

        for i in 0 ..< len(dragon) {
            draw(&dragon[i])
        }

        rl.EndDrawing()
    }

    delete(dragon)

    rl.CloseWindow()
}