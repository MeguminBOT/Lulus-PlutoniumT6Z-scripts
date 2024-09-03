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
    level endon("game_ended");
    self endon( "end_game" );

    for (;;) {
        level waittill("connected", player);
        player thread voice_chat();
    }
}

voice_chat()
{
    self endon("disconnect");
    self SetClientDvar("sv_voice", "1");
    self SetClientDvar("sv_voiceQuality", "9");
}