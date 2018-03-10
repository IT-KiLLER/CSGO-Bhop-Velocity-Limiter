
/*	Copyright (C) 2018 IT-KiLLER
	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.
	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
	
	You should have received a copy of the GNU General Public License
	along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

#include <sdktools>
#include <cstrike>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = 
{
	name = "[CS:GO/CS:S] Bhop Velocity Limiter",
	author = "IT-KILLER",
	description = "The velocity it adjusted only for players who actually jumps on the ground.",
	version = "1.0",
	url = "https://github.com/IT-KiLLER"
};

ConVar g_cvarVelocityTs, g_cvarVelocityCTs;
float g_fBhopVelocityT, g_fBhopVelocityTSquare, g_fBhopVelocityCTs, g_fBhopVelocityCTsSquare;

public void OnPluginStart()
{
	g_cvarVelocityTs = CreateConVar("sm_bhopvelocity_ts", "300.0", "Max velocity for Ts.", _, true, 0.0, true, 2000.0);
	g_cvarVelocityCTs = CreateConVar("sm_bhopvelocity_cts", "300.0", "Max velocity for CTs.", _, true, 0.0, true, 2000.0);
	
	g_cvarVelocityTs.AddChangeHook(OnCvarChanged);
	g_cvarVelocityCTs.AddChangeHook(OnCvarChanged);
	
	AutoExecConfig(true, "BhopVelocityLimiter", "sourcemod");
}

public void OnConfigsExecuted()
{
	g_fBhopVelocityT  = g_cvarVelocityTs.FloatValue;
	g_fBhopVelocityTSquare = Pow(g_cvarVelocityTs.FloatValue, 2.0);
	g_fBhopVelocityCTs  = g_cvarVelocityCTs.FloatValue;
	g_fBhopVelocityCTsSquare = Pow(g_cvarVelocityCTs.FloatValue, 2.0);
}

public void OnCvarChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(StrEqual(oldValue, newValue)) return;

	if(convar == g_cvarVelocityTs)
	{
		g_fBhopVelocityT  = g_cvarVelocityTs.FloatValue;
		g_fBhopVelocityTSquare = Pow(g_cvarVelocityTs.FloatValue, 2.0);
	}
	else if(convar == g_cvarVelocityCTs)
	{
		g_fBhopVelocityCTs  = g_cvarVelocityCTs.FloatValue;
		g_fBhopVelocityCTsSquare = Pow(g_cvarVelocityCTs.FloatValue, 2.0);
	}
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	if(buttons & IN_JUMP && IsPlayerAlive(client) && GetEntityFlags(client) & FL_ONGROUND & ~FL_ATCONTROLS && GetEntityMoveType(client) == MOVETYPE_WALK)
	{
		float flAbsVelocity[3];
		float flVelocity;
		GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", flAbsVelocity);
		flVelocity = flAbsVelocity[0]*flAbsVelocity[0] + flAbsVelocity[1]*flAbsVelocity[1];
		
		if(GetClientTeam(client) == CS_TEAM_CT) 
		{
			if(flVelocity > g_fBhopVelocityCTsSquare)
			{
				NormalizeVector(flAbsVelocity, flAbsVelocity);
				ScaleVector(flAbsVelocity, g_fBhopVelocityCTs);
				TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, flAbsVelocity);
			}
		} 
		else if(GetClientTeam(client) == CS_TEAM_T) 
		{
			if(flVelocity > g_fBhopVelocityTSquare)
			{
				NormalizeVector(flAbsVelocity, flAbsVelocity);
				ScaleVector(flAbsVelocity, g_fBhopVelocityT);
				TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, flAbsVelocity);
			}
		}
	}

	return Plugin_Continue;
}