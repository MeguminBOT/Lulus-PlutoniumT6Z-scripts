/* Based on various scripts

# HealthBar and Zombie Counter from "HealthBarV2" by andresito_20
https://forum.plutonium.pw/topic/33928/gsc-zm-healthbarv2

# Round Timer from "Black Ops 2 Zombies Reimagined" by Jbleezy
https://forum.plutonium.pw/topic/29979/black-ops-2-zombies-reimagined

# Location Names from "Black Ops 2 Zombies Reimagined" by Jbleezy
https://forum.plutonium.pw/topic/29979/black-ops-2-zombies-reimagined

# Zone Location Names from "Black Ops 2 Zombies Reimagined" by Jbleezy
https://forum.plutonium.pw/topic/29979/black-ops-2-zombies-reimagined

*/

#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_perks;
#include maps\mp\zombies\_zm_powerups;
#include maps\mp\gametypes_zm\spawnlogic;
#include maps\mp\gametypes_zm\_hostmigration;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\gametypes_zm\_hud_message;

init()
{
	level endon("end_game");

	level thread on_player_connect();
	level thread command_bar();

	precacheshader("damage_feedback");
	precacheshader("zm_riotshield_tomb_icon");
	precacheshader("zm_riotshield_hellcatraz_icon");
	precacheshader("menu_mp_fileshare_custom");
}

on_player_connect()
{
	self endon("end_game");

	for (;;) {
		level waittill("connected", player);
		functions = 1;
		player thread bar_function_and_toggle(functions);
		player thread on_player_spawned();
	}
}

on_player_spawned()
{   
	self endon("disconnect");
    self waittill("spawned_player");

	//self thread shield_hud();
	self thread timer_hud();
	self thread zone_hud();		
}

command_bar()
{
	level endon("end_game");
	prefix = "#";

	for (;;) {
		level waittill("say", message, player);
		message = toLower(message);
		if (!level.intermission && message[0] == prefix) {
			args = strtok(message, " ");
			command = getSubStr(args[0], 1);
			switch (command) {
				case "bar":
				if (isDefined(args[1])) {
						if (args[1] == "top") {
							functions = 1;
							player thread bar_function_and_toggle(functions);
						} else if (args[1] == "left") {
							functions = 2;
							player thread bar_function_and_toggle(functions);
						} else if (args[1] == "off") {
							functions = 100;
							player thread bar_function_and_toggle(functions);
						}
					}
				break;
			}
		}
	}
}

bar_function_and_toggle(functions)
{
	flag_wait("initial_blackscreen_passed");

	if (functions == 100) {
		if (isDefined(self.health_bar)) {
			self.health_bar render_destroy_elem();
		}
		if (isDefined(self.health_bar_text)) {
			self.health_bar_text render_destroy_elem();
		}
		if (isDefined(self.health_bar_name_text)) {
			self.health_bar_name_text render_destroy_elem();
		}
		if (isDefined(self.health_mas)) {
			self.health_mas render_destroy_elem();
		}
		if (isDefined(self.health_map_name_text)) {
			self.health_map_name_text render_destroy_elem();
		}
		if (isDefined(self.player_zombie_text)) {
			self.player_zombie_text render_destroy_elem();
		}
	} else {
		if (isDefined(self.health_bar)) {
			self.health_bar render_destroy_elem();
		}
		if (isDefined(self.health_bar_text)) {
			self.health_bar_text render_destroy_elem();
		}
		if (isDefined(self.health_bar_name_text)) {
			self.health_bar_name_text render_destroy_elem();
		}
		if (isDefined(self.health_mas)) {
			self.health_mas render_destroy_elem();
		}
		if (isDefined(self.health_map_name_text)) {
			self.health_map_name_text render_destroy_elem();
		}
		if (isDefined(self.player_zombie_text)) {
			self.player_zombie_text render_destroy_elem();
		}

		self.health_bar = self createprimaryprogressbar();
		self.player_zombie_text = self createfontstring("Objective", 1);

		if (functions == 1) {
			self.player_zombie_text.label = &"Zombie: ^1";
			self.health_bar.width = 100;
			self.health_bar.height = 2;
			self.health_bar_text = self createFontString("Objective", 1);
			self.health_bar_name_text = self createFontString("Objective", 1);
			self.health_map_name_text = self createFontString("Objective", 1);
			self.health_mas = self createFontString("Objective", 1.5);
			self.health_bar_text setpoint("CENTER", 0, 45, -228);
			self.health_map_name_text setpoint(0, 0, 0, -228);
			self.health_bar_name_text setpoint("CENTER", 0, 30, -205);
			self.health_mas setpoint("CENTER", 0, -45, -228);
			self.health_bar setpoint("CENTER", 0, "CENTER", -216); // <- Edit
			self.player_zombie_text setpoint("CENTER", 0, -35, -205);
			self thread update_zombies();
			self thread bar_health_function();
		} else if (functions == 2) {
			self.player_zombie_text.label = &"Zombie: ^1";
			self.health_bar.width = 100;
			self.health_bar.height = 2;
			self.health_bar_text = self createFontString("Objective", 1);
			self.health_bar_name_text = self createFontString("Objective", 1);
			self.health_map_name_text = self createFontString("Objective", 1);
			self.health_mas = self createFontString("Objective", 1.5);
			self.health_bar_text setpoint("LEFT", "LEFT", 65, 132);
			self.health_map_name_text setpoint("LEFT", "LEFT", 0, 132);
			self.health_bar_name_text setpoint("LEFT", "LEFT", 0, 110);
			self.health_mas setpoint("LEFT", "LEFT", 55, 132);
			self.health_bar setpoint("LEFT", "LEFT", 0, 120); // <- Edit
			self.player_zombie_text setpoint("LEFT", "LEFT", 55, 110);
			self thread bar_health_function();
			self thread update_zombies();
		}
	}
}
	
bar_health_function()
{
	level endon("end_game");
	self endon("endbar_health");
	self endon("disconnect");

	namePlayer = self.name;
	self.health_bar_name_text setText(namePlayer + "");
	self.health_mas setText("+");
	self.health_bar.hidewheninmenu = 1;
	self.health_bar_text.hidewheninmenu = 1;
	self.health_bar_name_text.hidewheninmenu = 1;
	self.health_mas.hidewheninmenu = 1;
	self.player_zombie_text.hidewheninmenu = 1;
	self.health_bar.hidewheninscope  = 1;
	self.health_bar_text.hidewheninscope  = 1;
	self.health_bar_name_text.hidewheninscope  = 1;
	self.health_mas.hidewheninscope = 1;
	self.player_zombie_text.hidewheninscope = 1;

	map = getDvar("ui_zm_mapstartlocation");
	switch (map) {
		case "tomb":
			self.health_map_name_text setText("ORIGINS");
		break;
		case "transit":
			self.health_map_name_text setText("TRANSIT");
		break;
		case "town":
			self.health_map_name_text setText("TOWN");
		break;
		case "farm":
			self.health_map_name_text setText("FARM");
		break;
		case "processing":
			self.health_map_name_text setText("BURIED");
		break;
		case "prison":
			self.health_map_name_text setText("PRISON");
		break;
		case "nuked":
			self.health_map_name_text setText("NUKETOWN");
		break;
		case "rooftop":
			self.health_map_name_text setText("HIGHRISE");
		break;
	}

	while (true) {
		if (isdefined(self.e_afterlife_corpse)) {
			self.health_bar.bar.alpha = 0;
			self.health_bar.barframe.alpha = 0;
			self.health_bar_text.alpha = 0;
			self.health_bar_name_text.alpha = 0;
			self.player_zombie_text.alpha = 0;

			wait 0.05;
			continue;
		}

		self.health_bar.alpha = 0;
		self.health_bar.bar.alpha = 1;
		self.health_bar.barframe.alpha = 1;
		self.health_bar_text.alpha = 1;
		self.health_bar_name_text.alpha = 1;
		self.player_zombie_text.alpha = 1;
		self.health_bar updatebar(self.health / self.maxhealth);
		self.health_bar_text setText(self.health + "^7/^8" + self.maxhealth);

		if (self.health <= self.maxhealth && self.health >= 71) {
			self.health_bar_text.color = (0, 1, 0.5); self.health_mas.color = (0, 1, 0.5); 
			self.health_bar.bar.color = (0, 1, 0.5);
		} else if (self.health <= 70 && self.health >= 50) {
			self.health_bar_text.color = (1, 1, 0); self.health_mas.color = (1, 1, 0);
			self.health_bar.bar.color = (1, 1, 0);
		} else if (self.health <= 49 && self.health >= 25) {
			self.health_bar_text.color = (1, 0.5, 0); self.health_mas.color = (1, 0.5, 0);
			self.health_bar.bar.color = (1, 0.5, 0);
		} else if (self.health <= 24 && self.health >= 0) {
			self.health_bar_text.color = (0.5, 0, 0); self.health_mas.color = (0.5, 0, 0);
			self.health_bar.bar.color = (0.5, 0, 0);
		}
		wait 0.5;
	}
}

update_zombies()
{
	level endon("end_game");
	self endon("endbar_health");
	self endon("disconnect");

	while (isDefined(self.health_bar)) {
		self.player_zombie_text setvalue(get_round_enemy_array().size + level.zombie_total);
		wait 0.7;
	}
	wait 0.5;
}

render_destroy_elem()
{
	foreach (child in self.children)
		child render_destroy_elem();
	self destroyelem();
}

// shield_hud()
// {
// 	self endon("disconnect");
// 	flag_wait("initial_blackscreen_passed");

// 	shield_text = self createprimaryprogressbartext();
// 	shield_text setpoint(undefined, "BOTTOM", 205, 15);
// 	shield_text.hidewheninmenu = 1;
// 	shield_hud = newClientHudElem(self);
// 	shield_hud.alignx = "right";
// 	shield_hud.aligny = "bottom";
// 	shield_hud.horzalign = "user_right";
// 	shield_hud.vertalign = "user_bottom";
// 	shield_hud.x -= 175;
// 	shield_hud.alpha = 0;
// 	shield_hud.color = (1, 1, 1);
// 	shield_hud.hidewheninmenu = 1;

// 	if (getdvar("mapname") == "zm_transit") {
// 		shield_hud setShader("damage_feedback", 32, 32);
// 	}

// 	if (getdvar("mapname") == "zm_tomb") {
// 		shield_hud setShader("zm_riotshield_tomb_icon", 32, 32);
// 	}

// 	if (getdvar("mapname") == "zm_prison") {
// 		shield_hud setShader("zm_riotshield_hellcatraz_icon", 32, 32);
// 	}

// 	for(;;) {
// 		if (self hasweapon("riotshield_zm") || self hasweapon("alcatraz_shield_zm") || self hasweapon("tomb_shield_zm")) {
// 			shield_text.alpha = 1;
// 			shield_hud.alpha = 1;
// 		} else {
// 			shield_text.alpha = 0;
// 			shield_hud.alpha = 0;
// 		}

// 		shield_text setvalue(2500 - self.shielddamagetaken);
// 		wait 0.05;

// 		if (self.shielddamagetaken >= 2500) {
// 			shield_text.alpha = 0;
// 		}
// 	}
// }

timer_hud()
{
	self endon("disconnect");

	self thread round_timer_hud();

	timer_hud = newClientHudElem(self);
	timer_hud.alignx = "right";
	timer_hud.aligny = "top";
	timer_hud.horzalign = "user_right";
	timer_hud.vertalign = "user_top";
	timer_hud.x -= 5;
	timer_hud.y += 2;
	timer_hud.fontscale = 1.4;
	timer_hud.alpha = 0;
	timer_hud.color = ( 1, 1, 1 );
	timer_hud.hidewheninmenu = 1;
	timer_hud.label = &"Time: ";

	flag_wait( "initial_blackscreen_passed" );
	
	timer_hud.alpha = 1;
	timer_hud setTimerUp(0);
}

round_timer_hud()
{
	self endon("disconnect");

	round_timer_hud = newClientHudElem(self);
	round_timer_hud.alignx = "right";
	round_timer_hud.aligny = "top";
	round_timer_hud.horzalign = "user_right";
	round_timer_hud.vertalign = "user_top";
	round_timer_hud.x -= 5;
	round_timer_hud.y += 17;
	round_timer_hud.fontscale = 1.4;
	round_timer_hud.alpha = 0;
	round_timer_hud.color = ( 1, 1, 1 );
	round_timer_hud.hidewheninmenu = 1;
	round_timer_hud.label = &"Round Time: ";

	flag_wait( "initial_blackscreen_passed" );

	round_timer_hud.alpha = 1;

	while (1) {
		round_timer_hud setTimerUp(0);
		start_time = int(getTime() / 1000);

		level waittill( "end_of_round" );

		end_time = int(getTime() / 1000);
		time = end_time - start_time;

		set_time_frozen(round_timer_hud, time);
	}
}

set_time_frozen(hud, time)
{
	level endon( "start_of_round" );

	time -= .1; // need to set it below the number or it shows the next number

	while (1) {
		hud setTimer(time);

		wait 0.5;
	}
}

zone_hud()
{
	self endon("disconnect");
	zone_hud = newClientHudElem(self);
	zone_hud.alignx = "left";
	zone_hud.aligny = "bottom";
	zone_hud.horzalign = "user_left";
	zone_hud.vertalign = "user_bottom";
	zone_hud.x += 5;
	if (level.script == "zm_buried") {
		zone_hud.y -= 180;
	} else if (level.script == "zm_tomb") {
		zone_hud.y -= 180;
	} else {
		zone_hud.y -= 180;
	}
	zone_hud.fontscale = 1.4;
	zone_hud.alpha = 0;
	zone_hud.color = ( 1, 1, 1 );
	zone_hud.hidewheninmenu = 1;
	flag_wait( "initial_blackscreen_passed" );
	prev_zone = "";
	while (1) {
		zone = self get_zone_name();
		if(prev_zone != zone) {
			prev_zone = zone;
			zone_hud fadeovertime(0.25);
			zone_hud.alpha = 0;
			wait 0.25;
			zone_hud settext(zone);
			zone_hud fadeovertime(0.25);
			zone_hud.alpha = 1;
			wait 0.25;
			continue;
		}
		wait 0.05;
	}
}

get_zone_name()
{
	zone = self get_current_zone();
	if (!isDefined(zone)) {
		return "";
	}

	name = zone;

	if (level.script == "zm_transit") {
		if (zone == "zone_pri") {
			name = "Bus Depot";
		} else if (zone == "zone_pri2") {
			name = "Bus Depot Hallway";
		} else if (zone == "zone_station_ext") {
			name = "Outside Bus Depot";
		} else if (zone == "zone_trans_2b") {
			name = "Fog After Bus Depot";
		} else if (zone == "zone_trans_2") {
			name = "Tunnel Entrance";
		} else if (zone == "zone_amb_tunnel") {
			name = "Tunnel";
		} else if (zone == "zone_trans_3") {
			name = "Tunnel Exit";
		} else if (zone == "zone_roadside_west") {
			name = "Outside Diner";
		} else if (zone == "zone_gas") {
			name = "Gas Station";
		} else if (zone == "zone_roadside_east") {
			name = "Outside Garage";
		} else if (zone == "zone_trans_diner") {
			name = "Fog Outside Diner";
		} else if (zone == "zone_trans_diner2") {
			name = "Fog Outside Garage";
		} else if (zone == "zone_gar") {
			name = "Garage";
		} else if (zone == "zone_din") {
			name = "Diner";
		} else if (zone == "zone_diner_roof") {
			name = "Diner Roof";
		} else if (zone == "zone_trans_4") {
			name = "Fog After Diner";
		} else if (zone == "zone_amb_forest") {
			name = "Forest";
		} else if (zone == "zone_trans_10") {
			name = "Outside Church";
		} else if (zone == "zone_town_church") {
			name = "Upper South Town";
		} else if (zone == "zone_trans_5") {
			name = "Fog Before Farm";
		} else if (zone == "zone_far") {
			name = "Outside Farm";
		} else if (zone == "zone_far_ext") {
			name = "Farm";
		} else if (zone == "zone_brn") {
			name = "Barn";
		} else if (zone == "zone_farm_house") {
			name = "Farmhouse";
		} else if (zone == "zone_trans_6") {
			name = "Fog After Farm";
		} else if (zone == "zone_amb_cornfield") {
			name = "Cornfield";
		} else if (zone == "zone_cornfield_prototype") {
			name = "Nacht";
		} else if (zone == "zone_trans_7") {
			name = "Upper Fog Before Power";
		} else if (zone == "zone_trans_pow_ext1") {
			name = "Fog Before Power";
		} else if (zone == "zone_pow") {
			name = "Outside Power Station";
		} else if (zone == "zone_prr") {
			name = "Power Station";
		} else if (zone == "zone_pcr") {
			name = "Power Control Room";
		} else if (zone == "zone_pow_warehouse") {
			name = "Warehouse";
		} else if (zone == "zone_trans_8") {
			name = "Fog After Power";
		} else if (zone == "zone_amb_power2town") {
			name = "Cabin";
		} else if (zone == "zone_trans_9") {
			name = "Fog Before Town";
		} else if (zone == "zone_town_north") {
			name = "North Town";
		} else if (zone == "zone_tow") {
			name = "Center Town";
		} else if (zone == "zone_town_east") {
			name = "East Town";
		} else if (zone == "zone_town_west") {
			name = "West Town";
		} else if (zone == "zone_town_south") {
			name = "South Town";
		} else if (zone == "zone_bar") {
			name = "Bar";
		} else if (zone == "zone_town_barber") {
			name = "Bookstore";
		} else if (zone == "zone_ban") {
			name = "Bank";
		} else if (zone == "zone_ban_vault") {
			name = "Bank Vault";
		} else if (zone == "zone_tbu") {
			name = "Below Bank";
		} else if (zone == "zone_trans_11") {
			name = "Fog After Town";
		} else if (zone == "zone_amb_bridge") {
			name = "Bridge";
		} else if (zone == "zone_trans_1") {
			name = "Fog Before Bus Depot";
		}
	} else if (level.script == "zm_nuked") {
		if (zone == "culdesac_yellow_zone") {
			name = "Yellow House Cul-de-sac";
		} else if (zone == "culdesac_green_zone") {
			name = "Green House Cul-de-sac";
		} else if (zone == "truck_zone") {
			name = "Truck";
		} else if (zone == "openhouse1_f1_zone") {
			name = "Green House Downstairs";
		} else if (zone == "openhouse1_f2_zone") {
			name = "Green House Upstairs";
		} else if (zone == "openhouse1_backyard_zone") {
			name = "Green House Backyard";
		} else if (zone == "openhouse2_f1_zone") {
			name = "Yellow House Downstairs";
		} else if (zone == "openhouse2_f2_zone") {
			name = "Yellow House Upstairs";
		} else if (zone == "openhouse2_backyard_zone") {
			name = "Yellow House Backyard";
		} else if (zone == "ammo_door_zone") {
			name = "Yellow House Backyard Door";
		}
	} else if (level.script == "zm_highrise") {
		if (zone == "zone_green_start") {
			name = "Green Highrise Level 3b";
		} else if (zone == "zone_green_escape_pod") {
			name = "Escape Pod";
		} else if (zone == "zone_green_escape_pod_ground") {
			name = "Escape Pod Shaft";
		} else if (zone == "zone_green_level1") {
			name = "Green Highrise Level 3a";
		} else if (zone == "zone_green_level2a") {
			name = "Green Highrise Level 2a";
		} else if (zone == "zone_green_level2b") {
			name = "Green Highrise Level 2b";
		} else if (zone == "zone_green_level3a") {
			name = "Green Highrise Restaurant";
		} else if (zone == "zone_green_level3b") {
			name = "Green Highrise Level 1a";
		} else if (zone == "zone_green_level3c") {
			name = "Green Highrise Level 1b";
		} else if (zone == "zone_green_level3d") {
			name = "Green Highrise Behind Restaurant";
		} else if (zone == "zone_orange_level1") {
			name = "Upper Orange Highrise Level 2";
		} else if (zone == "zone_orange_level2") {
			name = "Upper Orange Highrise Level 1";
		} else if (zone == "zone_orange_elevator_shaft_top") {
			name = "Elevator Shaft Level 3";
		} else if (zone == "zone_orange_elevator_shaft_middle_1") {
			name = "Elevator Shaft Level 2";
		} else if (zone == "zone_orange_elevator_shaft_middle_2") {
			name = "Elevator Shaft Level 1";
		} else if (zone == "zone_orange_elevator_shaft_bottom") {
			name = "Elevator Shaft Bottom";
		} else if (zone == "zone_orange_level3a") {
			name = "Lower Orange Highrise Level 1a";
		} else if (zone == "zone_orange_level3b") {
			name = "Lower Orange Highrise Level 1b";
		} else if (zone == "zone_blue_level5") {
			name = "Lower Blue Highrise Level 1";
		} else if (zone == "zone_blue_level4a") {
			name = "Lower Blue Highrise Level 2a";
		} else if (zone == "zone_blue_level4b") {
			name = "Lower Blue Highrise Level 2b";
		} else if (zone == "zone_blue_level4c") {
			name = "Lower Blue Highrise Level 2c";
		} else if (zone == "zone_blue_level2a") {
			name = "Upper Blue Highrise Level 1a";
		} else if (zone == "zone_blue_level2b") {
			name = "Upper Blue Highrise Level 1b";
		} else if (zone == "zone_blue_level2c") {
			name = "Upper Blue Highrise Level 1c";
		} else if (zone == "zone_blue_level2d") {
			name = "Upper Blue Highrise Level 1d";
		} else if (zone == "zone_blue_level1a") {
			name = "Upper Blue Highrise Level 2a";
		} else if (zone == "zone_blue_level1b") {
			name = "Upper Blue Highrise Level 2b";
		} else if (zone == "zone_blue_level1c") {
			name = "Upper Blue Highrise Level 2c";
		}
	} else if (level.script == "zm_prison") {
		if (zone == "zone_start") {
			name = "D-Block";
		} else if (zone == "zone_library") {
			name = "Library";
		} else if (zone == "zone_cellblock_west") {
			name = "Cellblock 2nd Floor";
		} else if (zone == "zone_cellblock_west_gondola") {
			name = "Cellblock 3rd Floor";
		} else if (zone == "zone_cellblock_west_gondola_dock") {
			name = "Cellblock Gondola";
		} else if (zone == "zone_cellblock_west_barber") {
			name = "Michigan Avenue";
		} else if (zone == "zone_cellblock_east") {
			name = "Times Square";
		} else if (zone == "zone_cafeteria") {
			name = "Cafeteria";
		} else if (zone == "zone_cafeteria_end") {
			name = "Cafeteria End";
		} else if (zone == "zone_infirmary") {
			name = "Infirmary 1";
		} else if (zone == "zone_infirmary_roof") {
			name = "Infirmary 2";
		} else if (zone == "zone_roof_infirmary") {
			name = "Roof 1";
		} else if (zone == "zone_roof") {
			name = "Roof 2";
		} else if (zone == "zone_cellblock_west_warden") {
			name = "Sally Port";
		} else if (zone == "zone_warden_office") {
			name = "Warden's Office";
		} else if (zone == "cellblock_shower") {
			name = "Showers";
		} else if (zone == "zone_citadel_shower") {
			name = "Citadel To Showers";
		} else if (zone == "zone_citadel") {
			name = "Citadel";
		} else if (zone == "zone_citadel_warden") {
			name = "Citadel To Warden's Office";
		} else if (zone == "zone_citadel_stairs") {
			name = "Citadel Tunnels";
		} else if (zone == "zone_citadel_basement") {
			name = "Citadel Basement";
		} else if (zone == "zone_citadel_basement_building") {
			name = "China Alley";
		} else if (zone == "zone_studio") {
			name = "Building 64";
		} else if (zone == "zone_dock") {
			name = "Docks";
		} else if (zone == "zone_dock_puzzle") {
			name = "Docks Gates";
		} else if (zone == "zone_dock_gondola") {
			name = "Upper Docks";
		} else if (zone == "zone_golden_gate_bridge") {
			name = "Golden Gate Bridge";
		} else if (zone == "zone_gondola_ride") {
			name = "Gondola";
		}
	} else if (level.script == "zm_buried") {
		if (zone == "zone_start") {
			name = "Processing";
		} else if (zone == "zone_start_lower") {
			name = "Lower Processing";
		} else if (zone == "zone_tunnels_center") {
			name = "Center Tunnels";
		} else if (zone == "zone_tunnels_north") {
			name = "Courthouse Tunnels 2";
		} else if (zone == "zone_tunnels_north2") {
			name = "Courthouse Tunnels 1";
		} else if (zone == "zone_tunnels_south") {
			name = "Saloon Tunnels 3";
		} else if (zone == "zone_tunnels_south2") {
			name = "Saloon Tunnels 2";
		} else if (zone == "zone_tunnels_south3") {
			name = "Saloon Tunnels 1";
		} else if (zone == "zone_street_lightwest") {
			name = "Outside General Store & Bank";
		} else if (zone == "zone_street_lightwest_alley") {
			name = "Outside General Store & Bank Alley";
		} else if (zone == "zone_morgue_upstairs") {
			name = "Morgue";
		} else if (zone == "zone_underground_jail") {
			name = "Jail Downstairs";
		} else if (zone == "zone_underground_jail2") {
			name = "Jail Upstairs";
		} else if (zone == "zone_general_store") {
			name = "General Store";
		} else if (zone == "zone_stables") {
			name = "Stables";
		} else if (zone == "zone_street_darkwest") {
			name = "Outside Gunsmith";
		} else if (zone == "zone_street_darkwest_nook") {
			name = "Outside Gunsmith Nook";
		} else if (zone == "zone_gun_store") {
			name = "Gunsmith";
		} else if (zone == "zone_bank") {
			name = "Bank";
		} else if (zone == "zone_tunnel_gun2stables") {
			name = "Stables To Gunsmith Tunnel 2";
		} else if (zone == "zone_tunnel_gun2stables2") {
			name = "Stables To Gunsmith Tunnel";
		} else if (zone == "zone_street_darkeast") {
			name = "Outside Saloon & Toy Store";
		} else if (zone == "zone_street_darkeast_nook") {
			name = "Outside Saloon & Toy Store Nook";
		} else if (zone == "zone_underground_bar") {
			name = "Saloon";
		} else if (zone == "zone_tunnel_gun2saloon") {
			name = "Saloon To Gunsmith Tunnel";
		} else if (zone == "zone_toy_store") {
			name = "Toy Store Downstairs";
		} else if (zone == "zone_toy_store_floor2") {
			name = "Toy Store Upstairs";
		} else if (zone == "zone_toy_store_tunnel") {
			name = "Toy Store Tunnel";
		} else if (zone == "zone_candy_store") {
			name = "Candy Store Downstairs";
		} else if (zone == "zone_candy_store_floor2") {
			name = "Candy Store Upstairs";
		} else if (zone == "zone_street_lighteast") {
			name = "Outside Courthouse & Candy Store";
		} else if (zone == "zone_underground_courthouse") {
			name = "Courthouse Downstairs";
		} else if (zone == "zone_underground_courthouse2") {
			name = "Courthouse Upstairs";
		} else if (zone == "zone_street_fountain") {
			name = "Fountain";
		} else if (zone == "zone_church_graveyard") {
			name = "Graveyard";
		} else if (zone == "zone_church_main") {
			name = "Church Downstairs";
		} else if (zone == "zone_church_upstairs") {
			name = "Church Upstairs";
		} else if (zone == "zone_mansion_lawn") {
			name = "Mansion Lawn";
		} else if (zone == "zone_mansion") {
			name = "Mansion";
		} else if (zone == "zone_mansion_backyard") {
			name = "Mansion Backyard";
		} else if (zone == "zone_maze") {
			name = "Maze";
		} else if (zone == "zone_maze_staircase") {
			name = "Maze Staircase";
		}
	} else if (level.script == "zm_tomb") {
		if (isDefined(self.teleporting) && self.teleporting) {
			return "";
		}

		if (zone == "zone_start") {
			name = "Lower Laboratory";
		} else if (zone == "zone_start_a") {
			name = "Upper Laboratory";
		} else if (zone == "zone_start_b") {
			name = "Generator 1";
		} else if (zone == "zone_bunker_1a") {
			name = "Generator 3 Bunker 1";
		} else if (zone == "zone_fire_stairs") {
			name = "Fire Tunnel";
		} else if (zone == "zone_bunker_1") {
			name = "Generator 3 Bunker 2";
		} else if (zone == "zone_bunker_3a") {
			name = "Generator 3";
		} else if (zone == "zone_bunker_3b") {
			name = "Generator 3 Bunker 3";
		} else if (zone == "zone_bunker_2a") {
			name = "Generator 2 Bunker 1";
		} else if (zone == "zone_bunker_2") {
			name = "Generator 2 Bunker 2";
		} else if (zone == "zone_bunker_4a") {
			name = "Generator 2";
		} else if (zone == "zone_bunker_4b") {
			name = "Generator 2 Bunker 3";
		} else if (zone == "zone_bunker_4c") {
			name = "Tank Station";
		} else if (zone == "zone_bunker_4d") {
			name = "Above Tank Station";
		} else if (zone == "zone_bunker_tank_c") {
			name = "Generator 2 Tank Route 1";
		} else if (zone == "zone_bunker_tank_c1") {
			name = "Generator 2 Tank Route 2";
		} else if (zone == "zone_bunker_4e") {
			name = "Generator 2 Tank Route 3";
		} else if (zone == "zone_bunker_tank_d") {
			name = "Generator 2 Tank Route 4";
		} else if (zone == "zone_bunker_tank_d1") {
			name = "Generator 2 Tank Route 5";
		} else if (zone == "zone_bunker_4f") {
			name = "zone_bunker_4f";
		} else if (zone == "zone_bunker_5a") {
			name = "Workshop Downstairs";
		} else if (zone == "zone_bunker_5b") {
			name = "Workshop Upstairs";
		} else if (zone == "zone_nml_2a") {
			name = "No Man's Land Walkway";
		} else if (zone == "zone_nml_2") {
			name = "No Man's Land Entrance";
		} else if (zone == "zone_bunker_tank_e") {
			name = "Generator 5 Tank Route 1";
		} else if (zone == "zone_bunker_tank_e1") {
			name = "Generator 5 Tank Route 2";
		} else if (zone == "zone_bunker_tank_e2") {
			name = "zone_bunker_tank_e2";
		} else if (zone == "zone_bunker_tank_f") {
			name = "Generator 5 Tank Route 3";
		} else if (zone == "zone_nml_1") {
			name = "Generator 5 Tank Route 4";
		} else if (zone == "zone_nml_4") {
			name = "Generator 5 Tank Route 5";
		} else if (zone == "zone_nml_0") {
			name = "Generator 5 Left Footstep";
		} else if (zone == "zone_nml_5") {
			name = "Generator 5 Right Footstep Walkway";
		} else if (zone == "zone_nml_farm") {
			name = "Generator 5";
		} else if (zone == "zone_nml_celllar") {
			name = "Generator 5 Cellar";
		} else if (zone == "zone_bolt_stairs") {
			name = "Lightning Tunnel";
		} else if (zone == "zone_nml_3") {
			name = "No Man's Land 1st Right Footstep";
		} else if (zone == "zone_nml_2b") {
			name = "No Man's Land Stairs";
		} else if (zone == "zone_nml_6") {
			name = "No Man's Land Left Footstep";
		} else if (zone == "zone_nml_8") {
			name = "No Man's Land 2nd Right Footstep";
		} else if (zone == "zone_nml_10a") {
			name = "Generator 4 Tank Route 1";
		} else if (zone == "zone_nml_10") {
			name = "Generator 4 Tank Route 2";
		} else if (zone == "zone_nml_7") {
			name = "Generator 4 Tank Route 3";
		} else if (zone == "zone_bunker_tank_a") {
			name = "Generator 4 Tank Route 4";
		} else if (zone == "zone_bunker_tank_a1") {
			name = "Generator 4 Tank Route 5";
		} else if (zone == "zone_bunker_tank_a2") {
			name = "zone_bunker_tank_a2";
		} else if (zone == "zone_bunker_tank_b") {
			name = "Generator 4 Tank Route 6";
		} else if (zone == "zone_nml_9") {
			name = "Generator 4 Left Footstep";
		} else if (zone == "zone_air_stairs") {
			name = "Wind Tunnel";
		} else if (zone == "zone_nml_11") {
			name = "Generator 4";
		} else if (zone == "zone_nml_12") {
			name = "Generator 4 Right Footstep";
		} else if (zone == "zone_nml_16") {
			name = "Excavation Site Front Path";
		} else if (zone == "zone_nml_17") {
			name = "Excavation Site Back Path";
		} else if (zone == "zone_nml_18") {
			name = "Excavation Site Level 3";
		} else if (zone == "zone_nml_19") {
			name = "Excavation Site Level 2";
		} else if (zone == "ug_bottom_zone") {
			name = "Excavation Site Level 1";
		} else if (zone == "zone_nml_13") {
			name = "Generator 5 To Generator 6 Path";
		} else if (zone == "zone_nml_14") {
			name = "Generator 4 To Generator 6 Path";
		} else if (zone == "zone_nml_15") {
			name = "Generator 6 Entrance";
		} else if (zone == "zone_village_0") {
			name = "Generator 6 Left Footstep";
		} else if (zone == "zone_village_5") {
			name = "Generator 6 Tank Route 1";
		} else if (zone == "zone_village_5a") {
			name = "Generator 6 Tank Route 2";
		} else if (zone == "zone_village_5b") {
			name = "Generator 6 Tank Route 3";
		} else if (zone == "zone_village_1") {
			name = "Generator 6 Tank Route 4";
		} else if (zone == "zone_village_4b") {
			name = "Generator 6 Tank Route 5";
		} else if (zone == "zone_village_4a") {
			name = "Generator 6 Tank Route 6";
		} else if (zone == "zone_village_4") {
			name = "Generator 6 Tank Route 7";
		} else if (zone == "zone_village_2") {
			name = "Church";
		} else if (zone == "zone_village_3") {
			name = "Generator 6 Right Footstep";
		} else if (zone == "zone_village_3a") {
			name = "Generator 6";
		} else if (zone == "zone_ice_stairs") {
			name = "Ice Tunnel";
		} else if (zone == "zone_bunker_6") {
			name = "Above Generator 3 Bunker";
		} else if (zone == "zone_nml_20") {
			name = "Above No Man's Land";
		} else if (zone == "zone_village_6") {
			name = "Behind Church";
		} else if (zone == "zone_chamber_0") {
			name = "The Crazy Place Lightning Chamber";
		} else if (zone == "zone_chamber_1") {
			name = "The Crazy Place Lightning & Ice";
		} else if (zone == "zone_chamber_2") {
			name = "The Crazy Place Ice Chamber";
		} else if (zone == "zone_chamber_3") {
			name = "The Crazy Place Fire & Lightning";
		} else if (zone == "zone_chamber_4") {
			name = "The Crazy Place Center";
		} else if (zone == "zone_chamber_5") {
			name = "The Crazy Place Ice & Wind";
		} else if (zone == "zone_chamber_6") {
			name = "The Crazy Place Fire Chamber";
		} else if (zone == "zone_chamber_7") {
			name = "The Crazy Place Wind & Fire";
		} else if (zone == "zone_chamber_8") {
			name = "The Crazy Place Wind Chamber";
		} else if (zone == "zone_robot_head") {
			name = "Robot's Head";
		}
	}

	return name;
}