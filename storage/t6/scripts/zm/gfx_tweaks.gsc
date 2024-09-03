#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_perks;
#include maps\mp\zombies\_zm_powerups;
#include maps\mp\gametypes_zm\spawnlogic;
#include maps\mp\gametypes_zm\_hostmigration;

init()
{
    level thread on_player_connect();
}

on_player_connect()
{
    level endon("game_ended");
    self endon( "end_game" );

    for (;;) {
        level waittill("connected", player);
        player thread on_players_spawned();
        wait 5.0;
    }
}

on_players_spawned()
{
    self endon( "disconnect" );
    self waittill("spawned_player");
    self SetClientDvar("r_fogOpacity", "0.1");
    self SetClientDvar("r_fogSunOpacity", "0.25");
}