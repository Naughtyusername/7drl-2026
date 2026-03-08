package sdrl

kill_enemy :: proc(game: ^Game, target: ^Actor) {
	target.alive = false

	game.enemies_slain += 1

	if enemy_data, ok1 := target.data.(Enemy_Data); ok1 {
		log_combat(game, "The %s dies!", enemy_data.name)
		if enemy_data.enemy_type == .Vampire_Lord {
			game.boss_dead = true
		}
	}
}

resolve_player_attack :: proc(game: ^Game, attacker: ^Actor, target: ^Actor) {
	player := get_player(game)
	pd, ok := &player.data.(Player_Data)
	if !ok {return}

	stats := get_weapon_stats(pd.active_weapon)
	damage := stats.damage + pd.weapon_damage_bonus
	// should set correct weapon speed for both
	game.last_action_cost = stats.speed

	if pd.shadow_strike_ready && pd.active_weapon == .Dagger {
		damage *= 2
		pd.shadow_strike_ready = false
		log_combat(game, "Shadow Strike!")
	}

	target.hp -= damage
	if enemy_data, e_ok := &target.data.(Enemy_Data); e_ok {
		log_combat(game, "You strike the %s for %d damage!", enemy_data.name, damage)
		if enemy_data.enemy_type == .Vampire_Lord {
			enemy_data.hits_since_teleport += 1
		}
	}
	if target.hp <= 0 {
		kill_enemy(game, target)
	}
}

resolve_enemy_attack :: proc(game: ^Game, enemy: Actor, player: ^Actor) {
	enemy_data, ok := enemy.data.(Enemy_Data)
	if !ok {return}

	game.death_cause = enemy_data.name // sets death flag name were this hit to be the last hit
	player.hp -= enemy_data.damage
	if enemy_data.enemy_type == .Lantern_Pest {
		if pd, p_ok := &player.data.(Player_Data); p_ok {
			if pd.lantern.state == .Lit {
				pd.lantern.state = .Extinguished
			}
			pd.lantern.fuel = max(0, pd.lantern.fuel - 20)
			if pd.lantern.fuel <= 0 {
				pd.lantern.state = .Empty
			}
			log_messagef(game, "The pest smothers your lantern! [-20 fuel]")
		}
	}
	log_combat(game, "The %s hits you for %d!", enemy_data.name, enemy_data.damage)
}
