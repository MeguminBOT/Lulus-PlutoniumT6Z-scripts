/* Based on various scripts

# "Configuration Mod for dedicated servers" by JezuzLizard
https://forum.plutonium.pw/topic/526/release-zombies-configuration-mod-for-dedicated-servers

# Droppable weapons taken from "Cold War Zombies Mod for Black Ops 2" by teh_bandit
https://forum.plutonium.pw/topic/15807/release-zombies-cold-war-mod-final-update

*/

#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\gametypes_zm\_hud_util;
#include scripts\zm\_utility;
#include common_scripts\utility;

init()
{
    level thread on_player_connect();
}

on_player_connect()
{
    self endon( "end_game" );

    for (;;) {
        level waittill("connected", player);
        player thread on_players_spawned();
        wait 5.0;
    }
}

on_players_spawned()
{
    self endon("disconnect");

    for (;;) {
        self waittill("spawned_player");

		// Player Health configuration
		self.health = level.cmPlayerMaxHealth;
		self.maxHealth = self.health;
		self setMaxHealth(level.cmPlayerMaxHealth);

		// No melee lunge & friendly fire.
		self SetClientDvar("g_friendlyfireDist", "0");
		self SetClientDvar("aim_automelee_enabled", "0");

		// Droppable Weapons
		self thread droppable_weapons();

		// Respawn
		self thread watch_for_respawn();
    }
}

on_player_downed()
{
	level endon("game_ended");
	self endon("disconnect");

    for (;;) {
		self waittill("entering_last_stand");

		if (is_gametype_active("zcleansed")) {
			continue;
		}

		self.statusicon = "waypoint_revive";
		self.health = self.maxhealth;
	}
}

droppable_weapons()
{
	level endon("end_game");
	self endon("disconnect");

	for (;;) {
		if (self meleebuttonpressed()) {
			duration = 0;
			while (self meleebuttonpressed()) {
				duration += 1;
				if (duration == 25) {
					weap = self getCurrentWeapon();
					self dropItem(weap);
					break;
				}
				wait 0.05;
			}
		}
		wait 0.05;
	}
}

watch_for_respawn()
{
	self endon( "disconnect" );
	while (1) {
		self waittill_any( "spawned_player", "player_revived" );
		wait_network_frame();
		checkJuggPerk();
	}
}

checkJuggPerk() 
{
	if (self._retain_perks && self hasPerk("specialty_armorvest")) {
		self setMaxHealth(level.cmPerkJuggHealth);
		self.health = level.cmPerkJuggHealth;
		self.maxHealth = self.health;
	} else if (self.pers_upgrades_awarded["jugg"] && maps\mp\zombies\_zm_utility::is_classic()) {
		self setMaxHealth(level.cmPerkPermaJuggHealth);
		self.health = level.cmPerkPermaJuggHealth;
		self.maxHealth = self.health;
	} else {
		self setMaxHealth(level.cmPlayerMaxHealth);
		self.health = level.cmPlayerMaxHealth;
		self.maxHealth = self.health;
	}
}