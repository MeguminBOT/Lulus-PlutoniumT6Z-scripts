/* Based on "[GSC] [ZM] NightMode" by andresito_20
https://forum.plutonium.pw/topic/37109/gsc-zm-nightmode */

init()
{
	level endon("game_ended");
	level thread on_player_connect();
	level thread on_player_say();
}

on_player_connect()
{
	self endon("end_game");
	wait 0.5;

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
		self.fog = 0;
		self.dof = 0;
		self.lod = 0;
	}
}

fog()
{
	self endon("disconnect");
	wait 0.1;

	if (self.fog == 0) {
		self.fog++;
		self SetClientDvar("r_fog", "0");
		self SetClientDvar("scr_fog_disable", "1");
		self SetClientDvar("r_fog_disable", "1");
		self SetClientDvar("r_fogSunOpacity", "0");

	} else if (self.fog == 1) {
		self.fog--;
		self SetClientDvar("r_fog", "1");
		self SetClientDvar("scr_fog_disable", "0");
		self SetClientDvar("r_fog_disable", "0");
		self SetClientDvar("r_fogSunOpacity", "1");
	}
}

dof()
{
	self endon("disconnect");
	wait 0.1;

	if (self.dof == 0) {
		self.dof++;
		self SetClientDvar("r_dof_enable", "0");

	} else if (self.dof == 1) {
		self.dof--;
		self SetClientDvar("r_dof_enable", "1");
	}
}

lod()
{
	self endon("disconnect");
	wait 0.1;

	if (self.lod == 0) {
		self.lod++;
		self SetClientDvar("r_lodBiasRigid", "-1000");
		self SetClientDvar("r_lodBiasSkinned", "-1000");
		self SetClientDvar("r_lodScaleRigid", "1");
		self SetClientDvar("r_lodScaleSkinned", "1");

	} else if (self.lod == 1) {
		self.lod--;
		self SetClientDvar("r_lodBiasRigid", "0");
		self SetClientDvar("r_lodBiasSkinned", "0");
		self SetClientDvar("r_lodScaleRigid", "1");
		self SetClientDvar("r_lodScaleSkinned", "1");
	}
}

on_player_say()
{
	level endon("end_game");

	prefix = "#";

	for (;;) {
		level waittill("say", message, player);
		message = toLower(message);

		if (message[0] == prefix) {
			args = strtok(message, " ");
			command = getSubStr(args[0], 1);

            switch (command) {
                case "fog":
					player thread fog();
                    break;

                case "dof":
					player thread dof();
                    break;

                case "lod":
                    player thread lod();
                    break;

                case "all":
                   	player thread fog();
					player thread dof();
					player thread lod();
                    break;
            }
		}
	}
}