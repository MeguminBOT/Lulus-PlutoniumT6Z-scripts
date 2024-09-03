/* Based on various scripts

# Max Ammo behaves like Black Ops 4 from "Cold War Zombies Mod for Black Ops 2" by teh_bandit
https://forum.plutonium.pw/topic/15807/release-zombies-cold-war-mod-final-update

*/

#include maps\mp\zombies\_zm_powerups;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\gametypes_zm\_hud_util;
#include scripts\zm\_utility;
#include common_scripts\utility;

init()
{
	level thread on_player_spawned();
}

on_player_spawned()
{
	level endon("end_game");
	self endon("disconnect");

	for(;;) {
		self waittill("spawned_player");
		self thread max_ammo_bo4();
	}
}

max_ammo_bo4()
{
	level endon("end_game");
	self endon("disconnect");

	for(;;) {
		self waittill("zmb_max_ammo");
		weaps = self getweaponslist(1);
		foreach (weap in weaps) {
			self setweaponammoclip(weap, weaponclipsize(weap));
		}
	}
}