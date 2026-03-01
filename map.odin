package sdrl

import "core:math/rand"

generate_dungeon :: proc(game: ^Game) {
    generate_ca_caves(game, CA_WALL_PROB, CA_SMOOTHING)

    num_rooms := rand.int_max(ROOM_COUNT_MAX - ROOM_COUNT_MIN + 1) + ROOM_COUNT_MIN
    rooms := make([dynamic]Rectangle, 0, num_rooms)
    defer delete(rooms)

    max_attempts := num_rooms * 3
    for _ in 0..<max_attempts {
        if len(rooms) >= num_rooms {
            break
        }

        room := generate_random_room(game)
        if can_place_room(game, room, rooms, 2) {
            carve_room(game, room)
            append(&rooms, room)
        }
    }

    if len(rooms) > 1 {
        connect_all_rooms(game, rooms)
    }

    if len(rooms) > 0 {
        player := get_player(game)
        player_x, player_y := get_room_center(rooms[0])
        player.x = player_x
        player.y = player_y
    } else {
        place_player(game)
    }

    spawn_enemies(game, 10)

    log_messagef(game, "The dungeon shift around you...")
}
