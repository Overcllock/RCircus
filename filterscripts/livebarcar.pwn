//3D Live bar car by Studio FS(Games,Apec,AHTOXA)

#include <a_samp>

new PlayerText3D:CarLabel[MAX_PLAYERS];
new bool:LabelActive[MAX_PLAYERS];

new Float:OldHealth[MAX_PLAYERS];
new Float:OldDamage[MAX_PLAYERS];
new Float:CDamage[MAX_PLAYERS];

new timercar[MAX_PLAYERS];

public OnPlayerConnect(playerid)
{
	LabelActive[playerid] = false;
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(newstate == PLAYER_STATE_DRIVER)
	{
		CarLabel[playerid] = CreatePlayer3DTextLabel(playerid," ",-1,0,0,0.9,10.0,INVALID_PLAYER_ID,GetPlayerVehicleID(playerid),1);
		UpdateBar(playerid);
	}
	else
	{
		DeletePlayer3DTextLabel(playerid,CarLabel[playerid]);
	}
	return 1;
}

public OnPlayerUpdate(playerid)
{
	UpdateHP(playerid);
	return 1;
}

stock UpdateHP(playerid)
{
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return 1;
	new Float:HP,veh;
 	veh = GetPlayerVehicleID(playerid);
	GetVehicleHealth(veh, HP);
	if(HP != OldHealth[playerid])
	{
		OldDamage[playerid]=OldHealth[playerid]-HP;
		OldHealth[playerid] = HP;
		if(OldDamage[playerid] > 0)
		{
		
			new texts[128];
			if(LabelActive[playerid])
			{
				CDamage[playerid]+=OldDamage[playerid];
				format(texts,sizeof(texts),"{ffd800}-%.0f\n%s",CDamage[playerid],UpdateString(HP));
				KillTimer(timercar[playerid]);
				timercar[playerid] = SetTimerEx("DeleteText", 2000, 0, "i", playerid);
			}
			else
			{
				LabelActive[playerid] = true;
				format(texts,sizeof(texts),"{ffd800}-%.0f\n%s",OldDamage[playerid],UpdateString(HP));
				timercar[playerid] = SetTimerEx("DeleteText", 2000, 0, "i", playerid);
			}
			UpdatePlayer3DTextLabelText(playerid, CarLabel[playerid], -1, texts);
		}
	}
	return 1;
}

stock UpdateBar(playerid)
{
	new Float:HP,veh;
 	veh = GetPlayerVehicleID(playerid);
	GetVehicleHealth(veh, HP);
	UpdateString(HP);
	UpdatePlayer3DTextLabelText(playerid, CarLabel[playerid], -1, UpdateString(HP));
	return 1;
}

stock UpdateString(Float:HP)
{
	new str[30];
	if(HP == 1000)          format(str,sizeof(str),"{00ff00}••••••••••");
	else if(HP >= 900)  	format(str,sizeof(str),"{66ff00}•••••••••{ffffff}•");
	else if(HP >= 800) 		format(str,sizeof(str),"{7fff00}••••••••{ffffff}••");
	else if(HP >= 700)		format(str,sizeof(str),"{ccff00}•••••••{ffffff}•••");
	else if(HP >= 600)		format(str,sizeof(str),"{f7f21a}••••••{ffffff}••••");
	else if(HP >= 500)		format(str,sizeof(str),"{f4c430}•••••{ffffff}•••••");
	else if(HP >= 400)		format(str,sizeof(str),"{e49b0f}••••{ffffff}••••••");
	else if(HP >= 300)		format(str,sizeof(str),"{e4650e}•••{ffffff}•••••••");
	else if(HP >= 250)		format(str,sizeof(str),"{ff2400}••{ffffff}••••••••");
	else 					format(str,sizeof(str),"{ff2400}Boom!");
	return str;
}


forward DeleteText(playerid);
public DeleteText(playerid)
{
	KillTimer(timercar[playerid]);
	LabelActive[playerid] = false;
	UpdateBar(playerid);
	CDamage[playerid]=0;
	return 1;
}
