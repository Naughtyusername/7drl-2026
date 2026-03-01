package sdrl

import "core:math/rand"

generate_ca_caves :: proc(game: ^Game, wall_probability: f32, smoothing_passes: int) {
	for y in 1 ..< game.map_height - 1 {
		for x in 1 ..< game.map_width - 1 {
			if rand.float32() < wall_probability {
				game.tiles[y][x] = .Wall
			} else {
				game.tiles[y][x] = .Floor
			}
		}
	}

	for _ in 0 ..< smoothing_passes {
		smooth_map(game)
	}

	// Ensure borders are solid walls
	for y in 0 ..< game.map_height {
		game.tiles[y][0] = .Wall
		game.tiles[y][game.map_width - 1] = .Wall
	}
	for x in 0 ..< game.map_width {
		game.tiles[0][x] = .Wall
		game.tiles[game.map_height - 1][x] = .Wall
	}
}

smooth_map :: proc(game: ^Game) {
	// Copy to avoid reading/writing same buffer
	old_tiles := make([dynamic][dynamic]Tile, game.map_height)
	defer {
		for i in 0 ..< game.map_height {
			delete(old_tiles[i])
		}
		delete(old_tiles)
	}

	for y in 0 ..< game.map_height {
		old_tiles[y] = make([dynamic]Tile, game.map_width)
		for x in 0 ..< game.map_width {
			old_tiles[y][x] = game.tiles[y][x]
		}
	}

	// CA rule: >4 neighbors = wall
	for y in 1 ..< game.map_height - 1 {
		for x in 1 ..< game.map_width - 1 {
			walls := count_neighbor_walls(old_tiles, x, y)
			if walls > 4 {
				game.tiles[y][x] = .Wall
			} else {
				game.tiles[y][x] = .Floor
			}
		}
	}
}

count_neighbor_walls :: proc(tiles: [dynamic][dynamic]Tile, x, y: int) -> int {
	count := 0
	for dy in -1 ..= 1 {
		for dx in -1 ..= 1 {
			if dx == 0 && dy == 0 {
				continue
			}
			if tiles[y + dy][x + dx] == .Wall {
				count += 1
			}
		}
	}
	return count
}
