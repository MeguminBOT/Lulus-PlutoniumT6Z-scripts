/* Based on various scripts

# "Configuration Mod for dedicated servers" by JezuzLizard
https://forum.plutonium.pw/topic/526/release-zombies-configuration-mod-for-dedicated-servers

# Zombie Health code from "Cold War Zombies Mod for Black Ops 2" by teh_bandit
Modified to Black Ops 4 health cap at round 35.
https://forum.plutonium.pw/topic/15807/release-zombies-cold-war-mod-final-update

*/

#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\gametypes_zm\_hud_util;
#include scripts\zm\_utility;
#include common_scripts\utility;

init()
{
    thread zombies_per_round_override();
    thread zombie_health_override();
	thread zombie_health_cap_override();
	thread zombie_spawn_delay_fix();
	thread zombie_speed_fix();
    //thread zombie_speed_override();
    //thread zombie_speed_cap_override();
    //thread zombie_move_animation_override();
	level thread on_player_connected();
}

on_player_connected()
{
	for(;;) {
		level waittill("connected", player);
		level thread on_player_spawned();
	}
}

on_player_spawned()
{
	self endon("disconnect");
    self waittill("spawned_player");
	level thread zombie_bo4_health_cap();		
}

zombies_per_round_override()
{
	if (!level.cmZombieTotalPermanentOverride) {
		return;
	}

    while (1) {
		level waittill("start_of_round");
		level.zombie_total = level.cmZombieTotalPermanentOverrideValue;
	}
}

zombie_health_override()
{
	if (!level.cmZombieHealthPermanentOverride) {
		return;
	}

    while (1) {
		level waittill("start_of_round");
		level.zombie_health = level.cmZombieHealthPermanentOverrideValue;
	}
}

zombie_health_cap_override()
{
	if (!level.cmZombieMaxHealthOverride) {
		return;
	}

    while (1) {
		level waittill("start_of_round");
		if (level.zombie_health > level.cmZombieMaxHealthOverrideValue) {
			level.zombie_health = level.cmZombieMaxHealthOverrideValue;
		}
	}
}

zombie_spawn_delay_fix()
{
	if (level.cmZombieSpawnRateLocked) {
		return;
	}

    i = 1;
	while (i <= level.round_number) {
		timer = level.cmZombieSpawnRate;
        if (timer > 0.08) {
			level.cmZombieSpawnRate = timer * level.cmZombieSpawnRateMultiplier;
			i++;
			continue;
		}
        if (timer < 0.08) {
			level.cmZombieSpawnRate = 0.08;
			break;
		}
		i++;
	}

    while (1) {
		level waittill("start_of_round");
		if (level.cmZombieSpawnRate > 0.08) {
			level.cmZombieSpawnRate = level.cmZombieSpawnRate * level.cmZombieSpawnRateMultiplier;
		}
		level.zombie_vars["zombie_spawn_delay"] = level.cmZombieSpawnRate;
	}
}

zombie_speed_fix()
{
	if (level.cmZombieMoveSpeedLocked) {
		return;
	}

    if (level.gamedifficulty == 0) {
		level.zombie_move_speed = level.round_number * level.zombie_vars["zombie_move_speed_multiplier_easy"];
	} else {
		level.zombie_move_speed = level.round_number * level.zombie_vars["zombie_move_speed_multiplier"];
	}
}

/* zombie_speed_override()
{
	if (!level.cmZombieMoveSpeedLocked) {
		return;
	}
	
    while (1) {
		level waittill("start_of_round");
		level.zombie_move_speed = getDvarIntDefault("cmZombieMoveSpeed", 1);
	}
}

zombie_speed_cap_override()
{
	if (!level.cmZombieMoveSpeedCap) {
		return;
	}
	
    while (1) {
		level waittill("start_of_round");
		if (level.zombie_move_speed > level.cmZombieMoveSpeedCapValue) {
			level.zombie_move_speed = level.cmZombieMoveSpeedCapValue;
		}
	}
}

zombie_move_animation_override()
{
	if (level.cmZombieMoveAnimation == "") {
		return;
	}
	
	while (1) {
		zombies = getAiArray(level.zombie_team);
		foreach(zombie in zombies) {
			if (zombie in_enabled_playable_area()) {
				zombie maps\mp\zombies\_zm_utility::set_zombie_run_cycle(level.cmZombieMoveAnimation);
			}
		}
		wait 1;
	}
} */

zombie_bo4_health_cap()
{
	for(;;) {
		level waittill("start_of_round");
		if(level.zombie_health > 11272) {
			level.zombie_health = 11272;
		}
	}
}