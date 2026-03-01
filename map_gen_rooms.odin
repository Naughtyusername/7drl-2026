package sdrl

import "core:math/rand"

Rectangle :: struct {
    x, y, width, height: int,
}

generate_random_room :: proc(game: ^Game) -> Rectangle {
    width := rand.int_max(ROOM_SIZE_MAX - ROOM_SIZE_MIN + 1) + ROOM_SIZE_MIN
    height := rand.int_max(ROOM_SIZE_MAX - ROOM_SIZE_MIN + 1) + ROOM_SIZE_MIN
    x := rand.int_max(game.map_width - width - 2) + 1
    y := rand.int_max(game.map_height - height - 2) + 1

    return Rectangle{x, y, width, height}
}

can_place_room :: proc(game: ^Game, new_room: Rectangle, existing_rooms: [dynamic]Rectangle, padding: int) -> bool {
    for room in existing_rooms {
        if rectangles_overlap_with_padding(new_room, room, padding) {
            return false
        }
    }
    return true
}

rectangles_overlap_with_padding :: proc(a, b: Rectangle, padding: int) -> bool {
    return a.x < b.x + b.width + padding &&
           a.x + a.width + padding > b.x &&
           a.y < b.y + b.height + padding &&
           a.y + a.height + padding > b.y
}

carve_room :: proc(game: ^Game, room: Rectangle) {
    for y in room.y..<room.y + room.height {
        for x in room.x..<room.x + room.width {
            if in_bounds(game, x, y) {
                game.tiles[y][x] = .Floor
            }
        }
    }
}

get_room_center :: proc(room: Rectangle) -> (x, y: int) {
    x = room.x + room.width / 2
    y = room.y + room.height / 2
    return
}

connect_rooms :: proc(game: ^Game, from_room, to_room: Rectangle) {
    from_x, from_y := get_room_center(from_room)
    to_x, to_y := get_room_center(to_room)

    // Randomly choose horizontal-first or vertical-first
    if rand.int_max(2) == 0 {
        carve_corridor_horizontal(game, from_x, to_x, from_y)
        carve_corridor_vertical(game, from_y, to_y, to_x)
    } else {
        carve_corridor_vertical(game, from_y, to_y, from_x)
        carve_corridor_horizontal(game, from_x, to_x, to_y)
    }
}

carve_corridor_horizontal :: proc(game: ^Game, x1, x2, y: int) {
    start_x := min(x1, x2)
    end_x := max(x1, x2)

    for x in start_x..=end_x {
        if in_bounds(game, x, y) {
            game.tiles[y][x] = .Floor
        }
    }
}

carve_corridor_vertical :: proc(game: ^Game, y1, y2, x: int) {
    start_y := min(y1, y2)
    end_y := max(y1, y2)

    for y in start_y..=end_y {
        if in_bounds(game, x, y) {
            game.tiles[y][x] = .Floor
        }
    }
}

connect_all_rooms :: proc(game: ^Game, rooms: [dynamic]Rectangle) {
    for i in 0..<len(rooms)-1 {
        connect_rooms(game, rooms[i], rooms[i+1])
    }
}
