package sdrl

import rl "vendor:raylib"

// ===== STANDARD & DEFAULT COLORS =====
LIGHT_MAX_STANDARD :: rl.Color{255, 147, 41, 255} // Warm torch glow
LIGHT_NONE :: rl.Color{0, 0, 0, 255} // Darkness
AMBIENT_LIGHT :: rl.Color{38, 38, 38, 255}

// ===== UI COLORS =====
UI_BG :: rl.Color{20, 20, 25, 255}
UI_TEXT :: rl.Color{220, 220, 220, 255}
UI_HIGHLIGHT :: rl.Color{255, 215, 0, 255}

// ===== LIGHT COLORS =====
LIGHT_TORCH_BASIC :: rl.Color{255, 147, 41, 255} // Warm torch glow
LIGHT_FIRE :: rl.Color{255, 85, 0, 255} // Bright fire
LIGHT_MAGIC_BLUE :: rl.Color{100, 149, 237, 255} // Arcane magic
LIGHT_MAGIC_PURPLE :: rl.Color{147, 51, 234, 255} // Dark magic
LIGHT_POISON :: rl.Color{50, 205, 50, 255} // Toxic green
LIGHT_MOONLIGHT :: rl.Color{180, 200, 230, 255} // Cool blue-white
LIGHT_BLOOD :: rl.Color{139, 0, 0, 255} // Dark red

// ===== ENTITY COLORS =====
COLOR_PLAYER :: rl.Color{255, 255, 255, 255}
COLOR_ENEMY_WEAK :: rl.Color{200, 100, 100, 255}
COLOR_ENEMY_STRONG :: rl.Color{139, 0, 0, 255}

// ===== OBJECT/TILE COLORS (BASE - before lighting) =====
COLOR_FLOOR :: rl.Color{64, 64, 64, 255}
COLOR_WALL :: rl.Color{96, 96, 96, 255}

// Brogue-inspired palette
// old
//COLOR_FLOOR := rl.Color{55, 45, 38, 255} // - darker, more contrast against walls
COLOR_FLOOR_DOT := rl.Color{85, 75, 60, 255} // - noticeably lighter, stands out
//COLOR_WALL := rl.Color{120, 100, 80, 255} // - brighter accent line on walls
//COLOR_WALL_ACCENT := rl.Color{140, 115, 90, 255} // - actually visible against floor
COLOR_WATER :: rl.Color{30, 144, 255, 255}

// ===== TILE DETAIL COLORS (BASE - before lighting) =====
COLOR_FLOOR_ACCENT :: rl.Color{80, 80, 80, 255} // Darker gray for floor dots
COLOR_WALL_ACCENT :: rl.Color{150, 150, 150, 255} // Lighter gray for wall borders

add_light :: proc(existing: rl.Color, new_light: rl.Color) -> rl.Color {
	return rl.Color {
		min(u8(int(existing.r) + int(new_light.r)), 255),
		min(u8(int(existing.g) + int(new_light.g)), 255),
		min(u8(int(existing.b) + int(new_light.b)), 255),
		255,
	}
    // TODO debug text, check if colors are saturating (hitting 255) or wrapping over
}

is_dark :: proc(c: rl.Color) -> bool {
	return c.r < 10 && c.g < 10 && c.b < 10
}

apply_lighting :: proc(base: rl.Color, light: rl.Color) -> rl.Color {
	r := (f32(base.r) / 255.0) * (f32(light.r) / 255.0) * 255.0
	g := (f32(base.g) / 255.0) * (f32(light.g) / 255.0) * 255.0
	b := (f32(base.b) / 255.0) * (f32(light.b) / 255.0) * 255.0
	return rl.Color{u8(r), u8(g), u8(b), base.a}
}

dim_color :: proc(base: rl.Color, intensity: f32) -> rl.Color {
	factor := clamp(intensity, 0.0, 1.0)
	return rl.Color {
		u8(f32(base.r) * factor),
		u8(f32(base.g) * factor),
		u8(f32(base.b) * factor),
		base.a,
	}
}
