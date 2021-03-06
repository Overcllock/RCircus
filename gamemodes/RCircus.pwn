//RCircus 1.0
#include <a_samp>
#include <a_mail>
#include <a_engine>
#include <dini>
#include <mxINI>
#include <md5>
#include <morphinc>
#include <streamer>
#include <time>
#include <a_actor>
#include <FCNPC>
#include <float>

#pragma dynamic 31294

//Colors
#define COLOR_WHITE 0xFFFFFFFF
#define COLOR_BLACK 0x000000FF
#define COLOR_RED 0xFF0000FF
#define COLOR_GREEN 0x00FF00FF
#define COLOR_GREY 0xCCCCCCFF
#define COLOR_BLUE 0x0066CCFF
#define COLOR_YELLOW 0xFFFF00AA
#define COLOR_LIGHTRED 0xFF6347FF

//Limits
#define MAX_HP 100.00
#define MAX_RATE 3000
#define MAX_SLOTS 16
#define MAX_EFFECTS 7
#define MAX_SKILLS 5
#define MAX_CL_ACTORS 4
#define MAX_CLOWNS 30
#define MAX_TRANSPORT 6
#define MAX_SOLO_ROUNDTIME 90
#define MAX_TEAM_ROUNDTIME 180
#define MAX_CARNAGE_ROUNDTIME 300
#define MAX_READY_TIME 30

//Effects IDs
#define EFFECT_SHAZOK_GEAR 0
#define EFFECT_LUSI_APRON 1
#define EFFECT_MAYO_POSITIVE 2
#define EFFECT_MAYO_NEGATIVE 3
#define EFFECT_MARMELADE_POSITIVE 4
#define EFFECT_MARMELADE_NEGATIVE 5
#define EFFECT_SALAT_POSITIVE 6
#define EFFECT_SALAT_NEGATIVE 7
#define EFFECT_SOUP 8
#define EFFECT_POTATO 9
#define EFFECT_CAKE 10
#define EFFECT_GOOSE 11
#define EFFECT_CUT 12
#define EFFECT_USELESS 13
#define EFFECT_MINE 14
#define EFFECT_PAIN 15
#define EFFECT_POISON 16

//Player params
#define PARAM_DAMAGE 0
#define PARAM_DEFENSE 1
#define PARAM_DODGE 2
#define PARAM_ACCURACY 3
#define PARAM_CRITICAL_CHANCE 4

//Forwards
forward OnPlayerLogin(playerid);
forward Time();
forward UpdatePlayer(playerid);
forward ReadyTimerTick();
forward StopRound();

//Varialbles
enum pInfo {
	Class,
	Rate,
	Cash,
	Bank,
	Sex,
	Float:PosX,
	Float:PosY,
	Float:PosZ,
	Float:FacingAngle,
	Interior,
	QItem,
	Inventory[MAX_SLOTS],
	InventoryCount[MAX_SLOTS],
	Skin,
	Admin,
	Wins,
	Loses,
	EffectsID[MAX_EFFECTS],
	EffectsTime[MAX_EFFECTS],
	SkillCooldown[MAX_SKILLS],
	Damage,
	Defense,
	Dodge,
	Accuracy,
	TopPosition,
	CriticalChance
};
new PlayerInfo[MAX_PLAYERS][pInfo];
new PlayerUpdater[MAX_PLAYERS];
enum GridItem
{
	blue[255],
	red[255]
};
new grid[MAX_CLOWNS / 2][GridItem];
new currentPair = 0;
new currentTour = 1;
new currentRound = 1;
new SelectedSlot[MAX_PLAYERS] = -1;
new bool:IsInventoryOpen[MAX_PLAYERS] = false;
new class_count[6] = 0;
new bool:IsDeath[MAX_PLAYERS] = false;
new Actors[MAX_CL_ACTORS];
new bool:PlayerConnect[MAX_PLAYERS] = false;
new Transport[MAX_TRANSPORT];
new bool:IsBattleBegins = false;
new bool:IsReady[MAX_PLAYERS] = false;
new bool:IsEntered[MAX_PLAYERS] = false;
new bool:IsMatchRunned = false;
new Registration[2] = { -1, -1 };
new MatchTimer = -1;
new RoundTimer = -1;
new ReadyTimerTicks;
new RoundTimerTicks;
enum TopItem
{
	Name[128],
	Class[64],
	Rate
};
new RatingTop[MAX_CLOWNS][TopItem];

new Text:WorldTime;
new WorldTime_Timer;
new Text:GamemodeName;

//UI
new PlayerText:HPBar[MAX_PLAYERS];
new PlayerText:InvBox[MAX_PLAYERS];
new PlayerText:InvSlot[MAX_PLAYERS][MAX_SLOTS];
new PlayerText:PanelInfo[MAX_PLAYERS];
new PlayerText:PanelInventory[MAX_PLAYERS];
new PlayerText:PanelUndress[MAX_PLAYERS];
new PlayerText:PanelSwitch[MAX_PLAYERS];
new PlayerText:PanelBox[MAX_PLAYERS];
new PlayerText:PanelDelimeter1[MAX_PLAYERS];
new PlayerText:PanelDelimeter2[MAX_PLAYERS];
new PlayerText:PanelDelimeter3[MAX_PLAYERS];
new PlayerText:btn_use[MAX_PLAYERS];
new PlayerText:btn_info[MAX_PLAYERS];
new PlayerText:btn_del[MAX_PLAYERS];
new PlayerText:btn_quick[MAX_PLAYERS];
new PlayerText:inv_ico[MAX_PLAYERS];
new PlayerText:InvSlotCount[MAX_PLAYERS][MAX_SLOTS];
new PlayerText:EBox[MAX_PLAYERS][MAX_EFFECTS];
new PlayerText:EBox_Time[MAX_PLAYERS][MAX_EFFECTS];
new PlayerText:SkillIco[MAX_PLAYERS][MAX_SKILLS];
new PlayerText:SkillButton[MAX_PLAYERS][MAX_SKILLS];
new PlayerText:SkillTime[MAX_PLAYERS][MAX_SKILLS];

//Combat UI
new PlayerText:TourScoreBar[MAX_PLAYERS];
new PlayerText:TourPanelBox[MAX_PLAYERS];
new PlayerText:TourPlayerName1[MAX_PLAYERS];
new PlayerText:TourPlayerName2[MAX_PLAYERS];
new PlayerText:blue_flag[MAX_PLAYERS];
new PlayerText:red_flag[MAX_PLAYERS];
new PlayerText:MatchInfoBox[MAX_PLAYERS];
new PlayerText:MatchRoundInfo[MAX_PLAYERS];
new PlayerText:MatchRoundTime_Circle[MAX_PLAYERS];
new PlayerText:MatchRoundTime[MAX_PLAYERS];
new PlayerText:MatchBlueFlag[MAX_PLAYERS];
new PlayerText:MatchRedFlag[MAX_PLAYERS];
new PlayerText:MatchRank1[MAX_PLAYERS];
new PlayerText:MatchRank2[MAX_PLAYERS];
new PlayerText:MatchHPBar1[MAX_PLAYERS];
new PlayerText:MatchHPBar2[MAX_PLAYERS];
new PlayerText:MatchHPPercents1[MAX_PLAYERS];
new PlayerText:MatchHPPercents2[MAX_PLAYERS];

//Bases
new DimakClowns[10][64] = {
	{"Dmitriy_Staroverov"},
	{"Irina_Novichkova"},
	{"Maxim_Loginov"},
	{"Olga_Tsurikova"},
	{"Lusi_Staroverova"},
	{"Stanislav_Tihov"},
	{"Vladimir_Skorkin"},
	{"Michail_Medvedik"},
	{"Alexander_Shaikin"},
	{"Michail_Edemsky"}
};
new VovakClowns[10][64] = {
	{"Alexander_Zhukov"},
	{"Tatyana_Cherusheva"},
	{"Arkadiy_Zharikov"},
	{"Vladimir_Zuev"},
	{"Ilya_Staroverov"},
	{"Larisa_Zueva"},
	{"Walter_White"},
	{"Andrey_Zhiganov"},
	{"Michail_Staroverov"},
	{"Michail_Krasyukov"}
};
new TanyaClowns[10][64] = {
	{"Tatyana_Lazareva"},
	{"Vladimir_Larkin"},
	{"Gennadiy_Truhanov"},
	{"Konstantin_Volodin"},
	{"Galina_Zueva"},
	{"Maria_Kurbatova"},
	{"Dmitriy_Stramov"},
	{"Anastasia_Panferina"},
	{"Sergey_Kanarev"},
	{"Nikita_Naumenko"}
};
new RateColors[9][16] = {
	{"85200c"},
	{"666666"},
	{"4c1130"},
	{"a61c00"},
	{"999999"},
	{"bf9000"},
	{"b7b7b7"},
	{"76a5af"},
	{"6d9eeb"}
};
new HexRateColors[9][1] = {
	{0x85200cff},
	{0x666666ff},
	{0x4c1130ff},
	{0xa61c00ff},
	{0x999999ff},
	{0xbf9000ff},
	{0xb7b7b7ff},
	{0x76a5afff},
	{0x6d9eebff}
};
//Pickups
new home_enter;
new home_quit;
new adm_enter;
new adm_quit;
new cafe_enter;
new cafe_quit;
new rest_enter;
new rest_quit;
new shop_enter;
new shop_quit;
new start_tp1;
new start_tp2;

main()
{
	print("Welcome to RCircus.");
}

public Time()
{
    new hour, minute, second;
	new string[25];
	gettime(hour, minute, second);
	if (minute <= 9)
		format(string, 25, "%d:0%d", hour, minute);
	else
		format(string, 25, "%d:%d", hour, minute);
	TextDrawSetString(WorldTime, string);
}

public UpdatePlayer(playerid)
{
	for (new i = 0; i < MAX_EFFECTS; i++) {
	    new numbers[16];
	    if (PlayerInfo[playerid][EffectsID][i] != -1) {
	        PlayerInfo[playerid][EffectsTime][i]--;
	        format(numbers, sizeof(numbers), "%d", PlayerInfo[playerid][EffectsTime][i]);
	        PlayerTextDrawSetString(playerid, EBox_Time[playerid][i], numbers);
	        if (PlayerInfo[playerid][EffectsTime][i] <= 0)
	            DisablePlayerEffect(playerid, i);
	    }
	}
}

public OnGameModeInit()
{
	SetGameModeText("RCircus 1.0");
	ShowNameTags(1);
	DisableInteriorEnterExits();
	EnableStuntBonusForAll(0);
	LimitPlayerMarkerRadius(1000.0);
	ShowPlayerMarkers(PLAYER_MARKERS_MODE_GLOBAL);
	DisableNameTagLOS();
	SetNameTagDrawDistance(9999.0);
	CreateMap();
	CreatePickups();
	InitTextDraws();
	WorldTime_Timer = SetTimer("Time", 1000, true);
	UpdateRatingTop();
	return 1;
}

public OnGameModeExit()
{
	DeleteTextDraws();
	KillTimer(WorldTime_Timer);
	for (new i = 0; i < MAX_CL_ACTORS; i++)
		DestroyActor(Actors[i]);
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	SendClientMessage(playerid, COLOR_WHITE, "����� ���������� � RCircus.");
	new listitems[] = "{82eb9d}������� ��������� ��� �����\n{ca0000}����� �� ��������� (������� �������)\n{007dff}����� �� ��������� (����� �������)\n{e5ff11}��������� �����";
	ShowPlayerDialog(playerid, 1000, DIALOG_STYLE_LIST, "���� � ����", listitems, "�������", "�����");
	return 1;
}

public OnPlayerConnect(playerid)
{
    ShowTextDraws(playerid);
    PlayerUpdater[playerid] = SetTimerEx("UpdatePlayer", 1000, true, "i", playerid);
	return 1;
}

public OnPlayerLogin(playerid) {
	InitPlayerTextDraws(playerid);
	PlayerConnect[playerid] = true;
	SpawnPlayer(playerid);
	ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid, PlayerInfo[playerid][Cash]);
	ShowInterface(playerid);
	IsInventoryOpen[playerid] = false;
	SelectedSlot[playerid] = -1;
	for (new j = 0; j < MAX_EFFECTS; j++)
        if (PlayerInfo[playerid][EffectsID][j] != -1)
            SetPlayerEffect(playerid, PlayerInfo[playerid][EffectsID][j], PlayerInfo[playerid][EffectsTime][j], j);
	if (PlayerInfo[playerid][Class] == -1)
	    ShowPlayerDialog(playerid, 2, DIALOG_STYLE_MSGBOX, "����� ���������", "� ��� �� ������ ����� ���������. ������� ������?", "��", "���");
}

public OnPlayerDisconnect(playerid, reason)
{
	KillTimer(PlayerUpdater[playerid]);
	SaveAccount(playerid);
	DeletePlayerTextDraws(playerid);
	IsInventoryOpen[playerid] = false;
	SelectedSlot[playerid] = -1;
	for (new i = 0; i < 10; i++)
	    if (IsPlayerAttachedObjectSlotUsed(playerid, i))
	        RemovePlayerAttachedObject(playerid, i);
	PlayerConnect[playerid] = false;
	for (new i = 0; i < 2; i++)
	    if (Registration[i] == playerid)
	        Registration[i] = -1;
	return 1;
}

public OnPlayerSpawn(playerid)
{
    SetPlayerWorldBounds(playerid, 307.0, 163.0, -1774.0, -1895.0);
	SetPlayerHealth(playerid, MAX_HP);
	if (IsDeath[playerid]) {
	    IsDeath[playerid] = false;
	    SetPlayerInterior(playerid, 1);
	    SetPlayerPos(playerid, -2170.3948,645.6729,1057.5938);
	    SetPlayerFacingAngle(playerid, 180);
	}
	else {
	    SetPlayerInterior(playerid, PlayerInfo[playerid][Interior]);
		SetPlayerPos(playerid, PlayerInfo[playerid][PosX], PlayerInfo[playerid][PosY], PlayerInfo[playerid][PosZ]);
		SetPlayerFacingAngle(playerid, PlayerInfo[playerid][FacingAngle]);
	}
	SetCameraBehindPlayer(playerid);
	SetPlayerSkin(playerid, PlayerInfo[playerid][Skin]);
	SetPlayerColor(playerid, GetHexColorByRate(PlayerInfo[playerid][Rate]));
	UpdateCharacter(playerid);
	ResetPlayerEffects(playerid);
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
    IsDeath[playerid] = true;
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	new name[64];
	GetPlayerName(playerid, name, sizeof(name));
	new message[2048];
	format(message, sizeof(message), "[%s]: %s", name, text);
	SendClientMessageToAll(GetHexColorByRate(PlayerInfo[playerid][Rate]), message);
	return 0;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	new string[255];
	if (strcmp("/showcombatui", cmdtext, true, 10) == 0)
	{
	    ShowMatchInterface(playerid);
		return 1;
	}
	if (strcmp("/creategrid", cmdtext, true, 10) == 0)
	{
	    CreateNewTourGrid();
		return 1;
	}
	if (strcmp("/spawn", cmdtext, true, 10) == 0)
	{
	    SetPlayerPos(playerid, 224.0761,-1839.8217,3.6037);
	    SetPlayerInterior(playerid, 0);
		return 1;
	}
	if (strcmp("/kill", cmdtext, true, 10) == 0)
	{
	    SetPlayerHealthEx(playerid, 0);
		return 1;
	}
	if (strcmp("/arena1", cmdtext, true, 10) == 0)
	{
	    SetPlayerPos(playerid, -2443.683,-1633.3514,767.6721);
	    SetPlayerInterior(playerid, 0);
		return 1;
	}
	if (strcmp("/arena2", cmdtext, true, 10) == 0)
	{
	    SetPlayerPos(playerid, -2256.331,-1625.8031,767.6721);
	    SetPlayerInterior(playerid, 0);
		return 1;
	}
	if (strcmp("/arena3", cmdtext, true, 10) == 0)
	{
	    SetPlayerPos(playerid, -2353.16186,-1630.952,723.561);
	    SetPlayerInterior(playerid, 0);
		return 1;
	}
	if (strcmp("/weapon", cmdtext, true, 10) == 0)
	{
	    GivePlayerWeapon(playerid, 33, 100000);
	    return 1;
	}
	if (strcmp("/add", cmdtext, true, 10) == 0)
	{
	    new File;
	    new path[64];
	    for (new i = 0; i < 10; i++) {
	        format(path, sizeof(path), "Players/%s.ini", TanyaClowns[i]);
	        File = ini_openFile(path);
	        ini_setFloat(File, "PosX", -2170.3948);
		    ini_setFloat(File, "PosY", 645.6729);
		    ini_setFloat(File, "PosZ", 1057.5938);
		    ini_setFloat(File, "Angle", 180);
		    ini_setInteger(File, "Interior", 1);
		    ini_setInteger(File, "Skin", 252);
		    for (new j = 0; j < 16; j++) {
		        format(string, sizeof(string), "InventorySlot%d", j);
		        ini_setInteger(File, string, 0);
		        format(string, sizeof(string), "InventorySlotCount%d", j);
		        ini_setInteger(File, string, 0);
		    }
	    }
        for (new i = 0; i < 10; i++) {
	        format(path, sizeof(path), "Players/%s.ini", DimakClowns[i]);
	        File = ini_openFile(path);
	        ini_setFloat(File, "PosX", -2170.3948);
		    ini_setFloat(File, "PosY", 645.6729);
		    ini_setFloat(File, "PosZ", 1057.5938);
		    ini_setFloat(File, "Angle", 180);
		    ini_setInteger(File, "Interior", 1);
		    ini_setInteger(File, "Skin", 252);
		    for (new j = 0; j < 16; j++) {
		        format(string, sizeof(string), "InventorySlot%d", j);
		        ini_setInteger(File, string, 0);
		        format(string, sizeof(string), "InventorySlotCount%d", j);
		        ini_setInteger(File, string, 0);
		    }
	    }
		return 1;
	}
	return 0;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	switch (newstate) {
	    case PLAYER_STATE_DRIVER:
	    {
	        new vehicleid = GetPlayerVehicleID(playerid);
	        if (vehicleid >= Transport[0] && vehicleid <= Transport[MAX_TRANSPORT - 1]) {
				GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
				SetVehicleParamsEx(vehicleid, 0, lights, alarm, doors, bonnet, boot, objective);
			    if (!IsPlayerHaveItem(playerid, 1581, 1)) {
			        SendClientMessage(playerid, COLOR_GREY, "���������� ������������ �����.");
			        RemovePlayerFromVehicle(playerid);
			    }
			    else
			        SetVehicleParamsEx(vehicleid, 1, lights, alarm, doors, bonnet, boot, objective);
			}
	    }
	}
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	if (pickupid == home_enter) {
	    SetPlayerPos(playerid, -2160.8616,641.5761,1052.3817);
	    SetPlayerFacingAngle(playerid, 90);
	    SetPlayerInterior(playerid, 1);
		SetCameraBehindPlayer(playerid);
	}
	else if (pickupid == home_quit) {
	    SetPlayerPos(playerid, 224.0981,-1839.8425,3.6037);
	    SetPlayerFacingAngle(playerid, 180);
	    SetPlayerInterior(playerid, 0);
	    SetCameraBehindPlayer(playerid);
	}
	else if (pickupid == adm_enter) {
	    SetPlayerPos(playerid, -2029.8918,-117.4907,1035.1719);
	    SetPlayerFacingAngle(playerid, 355);
	    SetPlayerInterior(playerid, 3);
	    SetCameraBehindPlayer(playerid);
	}
	else if (pickupid == adm_quit) {
	    SetPlayerPos(playerid, -2170.3140,637.0324,1052.3750);
	    SetPlayerFacingAngle(playerid, 0);
	    SetPlayerInterior(playerid, 1);
	    SetCameraBehindPlayer(playerid);
	}
	else if (pickupid == cafe_enter) {
	    SetPlayerPos(playerid, 458.0106,-88.7452,999.5547);
	    SetPlayerFacingAngle(playerid, 90);
	    SetPlayerInterior(playerid, 4);
	    SetCameraBehindPlayer(playerid);
	}
	else if (pickupid == cafe_quit) {
	    SetPlayerPos(playerid, 184.4775,-1826.0322,4.1454);
	    SetPlayerFacingAngle(playerid, 180);
	    SetPlayerInterior(playerid, 0);
	    SetCameraBehindPlayer(playerid);
	}
	else if (pickupid == rest_enter) {
	    SetPlayerPos(playerid, 376.8676,-191.2918,1000.6328);
	    SetPlayerFacingAngle(playerid, 0);
	    SetPlayerInterior(playerid, 17);
	    SetCameraBehindPlayer(playerid);
	}
	else if (pickupid == rest_quit) {
	    SetPlayerPos(playerid, 265.0115,-1824.9915,3.9249);
	    SetPlayerFacingAngle(playerid, 180);
	    SetPlayerInterior(playerid, 0);
	    SetCameraBehindPlayer(playerid);
	}
	else if (pickupid == shop_enter) {
	    SetPlayerPos(playerid, -27.0887,-55.6914,1003.5469);
	    SetPlayerFacingAngle(playerid, 355);
	    SetPlayerInterior(playerid, 6);
	    SetCameraBehindPlayer(playerid);
	}
	else if (pickupid == shop_quit) {
	    SetPlayerPos(playerid, 256.2769,-1788.2694,4.2751);
	    SetPlayerFacingAngle(playerid, 180);
	    SetPlayerInterior(playerid, 0);
	    SetCameraBehindPlayer(playerid);
	}
	else if (pickupid == start_tp1) {
	    if (playerid == Registration[1] && IsMatchRunned) {
			SetPlayerWorldBounds(playerid, 20000.0000, -20000.0000, 20000.0000, -20000.0000);
	        SetPlayerPos(playerid, -2444.4160,-1633.3875,767.6721);
	        IsReady[playerid] = false;
	        IsEntered[playerid] = true;
			if (IsEntered[Registration[0]])
			    StartReadyTimer();
	    }
	}
    else if (pickupid == start_tp2) {
	    if (playerid == Registration[0] && IsMatchRunned) {
			SetPlayerWorldBounds(playerid, 20000.0000, -20000.0000, 20000.0000, -20000.0000);
	        SetPlayerPos(playerid, -2256.4973,-1625.5812,767.6721);
	        IsReady[playerid] = false;
	        IsEntered[playerid] = true;
			if (IsEntered[Registration[1]])
			    StartReadyTimer();
	    }
	}
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if(newkeys & 1024) SelectTextDraw(playerid,0xCCCCFF65);
    else if(newkeys & 16) {
        if(IsPlayerInRangeOfPoint(playerid,2.0,-23.4700,-57.3214,1003.5469)) {
			new listitems[] = "�������\t����\n{999999}����������� ����\t{00CC00}25$\n{21aa18}�������\t{00CC00}75$\n{cc0000}������������ �����\t{00CC00}200$\n{e38614}�������� �����\t{00CC00}800$";
            ShowPlayerDialog(playerid, 3000, DIALOG_STYLE_TABLIST_HEADERS, "Circus 24/7", listitems, "������", "�����");
        }
        else if(IsPlayerInRangeOfPoint(playerid,2.0,450.5763,-82.2320,999.5547)) {
			new listitems[] = "�������\t���. ����\t����\n{85200c}������� �������\t{85200c}������\t{00CC00}25$\n{666666}�������� ��������\t{666666}������\t{00CC00}50$\n{4c1130}����� ����\t{4c1130}������\t{00CC00}75$";
            ShowPlayerDialog(playerid, 3100, DIALOG_STYLE_TABLIST_HEADERS, "���� '� ����'", listitems, "������", "�����");
        }
        else if(IsPlayerInRangeOfPoint(playerid,2.0,380.7459,-189.1151,1000.6328)) {
			new listitems[] = "�������\t���. ����\t����\n{a61c00}��� ����\t{a61c00}������\t{00CC00}100$\n{999999}��������� '������ ����������'\t{999999}�������\t{00CC00}150$\n{bf9000}���� �����\t{bf9000}������\t{00CC00}200$\n{b7b7b7}����\t{b7b7b7}�������\t{00CC00}300$";
            ShowPlayerDialog(playerid, 3200, DIALOG_STYLE_TABLIST_HEADERS, "Pepe's Restaurant", listitems, "������", "�����");
        }
        else if(IsPlayerInRangeOfPoint(playerid,1.5,-2166.7527,646.0400,1052.3750)) {
			new listitems[2800] = "�������\t���. ����\t����\n{999999}������������� ����\t{666666}������\t{00CC00}100$\n{21aa18}������� ���\t{4c1130}������\t{00CC00}150$\n{21aa18}��������� ���������\t{a61c00}������\t{00CC00}200$\n{379be3}�������� ������� �����\t{999999}�������\t{00CC00}275$";
			strcat(listitems, "\n{379be3}������ ����\t{bf9000}������\t{00CC00}350$\n{cc0000}����� ���������\t{b7b7b7}�������\t{00CC00}500$\n{8200d9}�������� � ����\t{76a5af}�����\t{00CC00}725$\n{e38614}��������� ������\t{6d9eeb}���������\t{00CC00}1000$\n{a64d79}������ ������\t{bf9000}������\t{00CC00}2000$");
            ShowPlayerDialog(playerid, 3300, DIALOG_STYLE_TABLIST_HEADERS, "�������� ��������� ���������", listitems, "������", "�����");
        }
        else if(IsPlayerInRangeOfPoint(playerid,1.5,244.6122,-1788.8988,4.2897) ||
				IsPlayerInRangeOfPoint(playerid,1.5,259.1209,-1822.9977,4.2996)) {
			new listitems[512];
			format(listitems, sizeof(listitems), "��� ������: %d$\n����� ��������\n��������� ����", PlayerInfo[playerid][Bank]);
			ShowPlayerDialog(playerid, 4000, DIALOG_STYLE_TABLIST_HEADERS, "��������", listitems, "�����", "�����");
        }
        else if(IsPlayerInRangeOfPoint(playerid,1.2,-2171.3132,645.5896,1052.3817)) {
			ShowRatingTop(playerid);
        }
        else if(IsPlayerInRangeOfPoint(playerid,1.0,-2159.0491,640.3581,1052.3817) ||
				IsPlayerInRangeOfPoint(playerid,1.0,-2161.3096,640.3589,1052.3817)) {
			if (IsMatchRunned) {
			    SendClientMessage(playerid, COLOR_GREY, "������ �����������: � ������ ������ ��� ���� ���.");
			 	return 1;
			}
			new name[64];
			GetPlayerName(playerid, name, sizeof(name));
			if (strcmp(name, grid[currentPair][blue], true) == 0) {
			    if (Registration[0] > -1) {
			        SendClientMessage(playerid, COLOR_GREY, "������ �����������: �������� ��� �������.");
			        return 1;
			    }
			    Registration[0] = playerid;
			    SendClientMessage(playerid, COLOR_GREEN, "����������� ������ �������. �� �������� �� ����� �������.");
			}
			else if (strcmp(name, grid[currentPair][red], true) == 0) {
			    if (Registration[1] > -1) {
			        SendClientMessage(playerid, COLOR_GREY, "������ �����������: �������� ��� �������.");
			        return 1;
			    }
			    Registration[1] = playerid;
			    SendClientMessage(playerid, COLOR_GREEN, "����������� ������ �������. �� �������� �� ������� �������.");
			}
			else {
			    SendClientMessage(playerid, COLOR_GREY, "������ �����������: �� �� �������� � ������� ����.");
			 	return 1;
			}
			if (Registration[0] > -1 && Registration[1] > -1) {
			    new msg[255];
			    format(msg, sizeof(msg), "���������� %d ���� %d ����!", currentPair+1, currentTour);
			    SendClientMessageToAll(0xFFCC00FF, msg);
			    StartMatch();
			}
        }
    }
	return 1;
}

public OnPlayerUpdate(playerid)
{
	UpdateHPBar(playerid);
	switch (PlayerInfo[playerid][Class]) {
	    case 0:
	    {
			new weapon = GetPlayerWeapon(playerid);
			if (weapon != 8) {
				if(IsPlayerAttachedObjectSlotUsed(playerid, 2))
			    	RemovePlayerAttachedObject(playerid, 2);
			    if(!IsPlayerAttachedObjectSlotUsed(playerid, 0))
			   		SetPlayerAttachedObject(playerid,0,339,1,0.314999,-0.140000,-0.183999,-2.000004,-70.100013,0.000000,1.000000,1.000000,1.000000);
			    if(!IsPlayerAttachedObjectSlotUsed(playerid, 1))
			        SetPlayerAttachedObject(playerid,1,18702,1,-0.091000,-0.043999,-0.932000,4.900000,23.299947,-79.600044,0.368001,1.518997,0.576999);
			}
			else {
			    if(IsPlayerAttachedObjectSlotUsed(playerid, 0))
			    	RemovePlayerAttachedObject(playerid, 0);
			    if(IsPlayerAttachedObjectSlotUsed(playerid, 1))
			    	RemovePlayerAttachedObject(playerid, 1);
			    if(!IsPlayerAttachedObjectSlotUsed(playerid, 2))
			    	SetPlayerAttachedObject(playerid,2,18702,6,0.419999,-0.295993,0.066000,-89.599960,-48.299983,1.299939,1.005999,1.638997,0.292999);
			}
		}
        case 1:
	    {
			new weapon = GetPlayerWeapon(playerid);
			if (weapon != 33) {
				if(IsPlayerAttachedObjectSlotUsed(playerid, 2))
			    	RemovePlayerAttachedObject(playerid, 2);
			    if(!IsPlayerAttachedObjectSlotUsed(playerid, 0))
			   		SetPlayerAttachedObject(playerid,0,357,1,0.020000,-0.183000,-0.082999,-2.199997,5.299992,8.400010,1.000000,1.000000,1.000000);
			    if(!IsPlayerAttachedObjectSlotUsed(playerid, 1))
			        SetPlayerAttachedObject(playerid,1,18701,1,-1.767000,-0.110999,-0.000000,0.000000,88.999977,0.000000,0.274999,0.328999,1.581998);
			}
			else {
			    if(IsPlayerAttachedObjectSlotUsed(playerid, 0))
			    	RemovePlayerAttachedObject(playerid, 0);
			    if(IsPlayerAttachedObjectSlotUsed(playerid, 1))
			    	RemovePlayerAttachedObject(playerid, 1);
			    if(!IsPlayerAttachedObjectSlotUsed(playerid, 2))
			    	SetPlayerAttachedObject(playerid,2,18701,6,-0.846999,-0.049999,-0.038001,-0.599998,81.800041,0.000000,1.000000,1.000000,1.000000);
			}
		}
		case 4:
	    {
			new weapon = GetPlayerWeapon(playerid);
			if (weapon != 4) {
				if(IsPlayerAttachedObjectSlotUsed(playerid, 2))
			    	RemovePlayerAttachedObject(playerid, 2);
			    if(!IsPlayerAttachedObjectSlotUsed(playerid, 0))
			   		SetPlayerAttachedObject(playerid,0,335,1,-0.230000,-0.166000,-0.098999,0.000000,0.000000,0.000000,1.000000,1.000000,1.000000);
			    if(!IsPlayerAttachedObjectSlotUsed(playerid, 1))
			        SetPlayerAttachedObject(playerid,1,18700,1,-0.736002,-0.147000,-0.040999,-15.300129,88.900077,101.699996,1.273999,1.680000,0.358000);
			}
			else {
			    if(IsPlayerAttachedObjectSlotUsed(playerid, 0))
			    	RemovePlayerAttachedObject(playerid, 0);
			    if(IsPlayerAttachedObjectSlotUsed(playerid, 1))
			    	RemovePlayerAttachedObject(playerid, 1);
			    if(!IsPlayerAttachedObjectSlotUsed(playerid, 2))
			    	SetPlayerAttachedObject(playerid,2,18700,6,0.000000,0.107999,-1.505000,0.000000,0.000000,0.000000,1.000000,1.000000,1.000000);
			}
		}
	}
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	//1000-1005 - ���� � ����
	//2000 - ���������
	//3000 - circus 24/7
	//3100 - ����
	//3200 - ��������
	//3300 - �������� ��������� ���������
	//4000-4003 - ��������
	//1 - ������
	//2,3 - ����� ������
	
	switch (dialogid) {
	    case 1: { return 1; }
	    case 2:
	    {
	        if (response) {
	            for (new i = 0; i < 6; i++)
	                class_count[i] = 0;
				new listitems[1024];
				new path[64];
				new File;
				for (new i = 0; i < 10; i++) {
				    format(path, sizeof(path), "Players/%s.ini", VovakClowns[i]);
				    File = ini_openFile(path);
				    new pclass;
				    ini_getInteger(File, "Class", pclass);
				    if (pclass > -1)
				        class_count[pclass]++;
				    ini_closeFile(File);
				}
				for (new i = 0; i < 10; i++) {
				    format(path, sizeof(path), "Players/%s.ini", DimakClowns[i]);
				    File = ini_openFile(path);
				    new pclass;
				    ini_getInteger(File, "Class", pclass);
				    if (pclass > -1)
				        class_count[pclass]++;
				    ini_closeFile(File);
				}
				for (new i = 0; i < 10; i++) {
				    format(path, sizeof(path), "Players/%s.ini", TanyaClowns[i]);
				    File = ini_openFile(path);
				    new pclass;
				    ini_getInteger(File, "Class", pclass);
				    if (pclass > -1)
				        class_count[pclass]++;
				    ini_closeFile(File);
				}
				format(listitems, sizeof(listitems), "�����\t����������\n{1155cc}������������\t{ffffff}%d\n{bc351f}��������\t{ffffff}%d\n{134f5c}����\t{ffffff}%d\n{f97403}�������\t{ffffff}%d\n{5b419b}�������\t{ffffff}%d\n{9900ff}�����������\t{ffffff}%d", class_count[0],
				       class_count[1], class_count[2], class_count[3], class_count[4], class_count[5]);
	            ShowPlayerDialog(playerid, 3, DIALOG_STYLE_TABLIST_HEADERS, "����� ������", listitems, "�������", "������");
	        }
	        else return 1;
	    }
		case 3:
		{
		    if (response) {
		        if (class_count[listitem] >= 5) {
					ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "������", "{FF6347}���������� ���������� ���������� ������ �������� ���������. ���������� ������� �����.\n���������� �� �������.", "��", "");
					Kick(playerid);
					return 1;
		        }
		        PlayerInfo[playerid][Class] = listitem;
		        UpdateCharacter(playerid);
		        ShowSkillPanel(playerid);
		        SendClientMessage(playerid, COLOR_LIGHTRED, "����� ������ �������!");
		    }
		    else return 1;
		}
		case 1000:
	    {
			if (response) {
			    switch (listitem)
			    {
			        case 0:
			        {
			            new listitems[] = "{FF0000}��������� ������\n{0066FF}��������� ������\n{33FF66}��������� ����";
			            ShowPlayerDialog(playerid, 1001, DIALOG_STYLE_LIST, "���� � ����", listitems, "�������", "�����");
			        }
			        case 1:
			        {
			        }
			        case 2:
			        {
			        }
			        case 3:
			        {
			            ShowTourGrid(playerid);
			        }
			    }
			}
			else
			    Kick(playerid);
	    }
		case 1001:
	    {
            if (response) {
                new listitems[4000];
			    switch (listitem)
			    {
			        case 0:
			        {
			            listitems = CreateVovakPlayersList();
			            ShowPlayerDialog(playerid, 1002, DIALOG_STYLE_TABLIST_HEADERS, "���� � ����", listitems, "�����", "�����");
			        }
			        case 1:
			        {
			            listitems = CreateDimakPlayersList();
			            ShowPlayerDialog(playerid, 1003, DIALOG_STYLE_TABLIST_HEADERS, "���� � ����", listitems, "�����", "�����");
			        }
			        case 2:
			        {
			        	listitems = CreateTanyaPlayersList();
			            ShowPlayerDialog(playerid, 1004, DIALOG_STYLE_TABLIST_HEADERS, "���� � ����", listitems, "�����", "�����");
			        }
			    }
			}
			else {
			    new listitems[] = "{82eb9d}������� ��������� ��� �����\n{ca0000}����� �� ��������� (������� �������)\n{007dff}����� �� ��������� (����� �������)\n{e5ff11}��������� �����";
				ShowPlayerDialog(playerid, 1000, DIALOG_STYLE_LIST, "���� � ����", listitems, "�������", "�����");
			}
	    }
	    case 1002:
	    {
	        if (response) {
				new name[64];
				for (new i = 0; i < MAX_PLAYERS; i++) {
				    if (!IsPlayerConnected(i)) continue;
					GetPlayerName(i, name, sizeof(name));
					if (strcmp(name, VovakClowns[listitem], true) == 0) {
					    SendClientMessage(playerid, COLOR_GREY, "� ������ ������ ���� �������� ��������� � ����. ������������ ����������.");
					    return 1;
					}
				}
				if (PlayerConnect[playerid])
				    OnPlayerDisconnect(playerid, 1);
				SetPlayerName(playerid, VovakClowns[listitem]);
				LoadAccount(playerid);
	            OnPlayerLogin(playerid);
	        }
	        else {
	            new listitems[] = "{FF0000}��������� ������\n{0066FF}��������� ������\n{33FF66}��������� ����";
			 	ShowPlayerDialog(playerid, 1001, DIALOG_STYLE_LIST, "���� � ����", listitems, "�������", "�����");
	        }
	    }
	    case 1003:
	    {
            if (response) {
                new name[64];
				for (new i = 0; i < MAX_PLAYERS; i++) {
				    if (!IsPlayerConnected(i)) continue;
					GetPlayerName(i, name, sizeof(name));
					if (strcmp(name, DimakClowns[listitem], true) == 0) {
					    SendClientMessage(playerid, COLOR_GREY, "� ������ ������ ���� �������� ��������� � ����. ������������ ����������.");
					    return 1;
					}
				}
				if (PlayerConnect[playerid])
				    OnPlayerDisconnect(playerid, 1);
				SetPlayerName(playerid, DimakClowns[listitem]);
				LoadAccount(playerid);
	            OnPlayerLogin(playerid);
	        }
	        else {
	            new listitems[] = "{FF0000}��������� ������\n{0066FF}��������� ������\n{33FF66}��������� ����";
			 	ShowPlayerDialog(playerid, 1001, DIALOG_STYLE_LIST, "���� � ����", listitems, "�������", "�����");
	        }
	    }
	    case 1004:
	    {
            if (response) {
                new name[64];
				for (new i = 0; i < MAX_PLAYERS; i++) {
				    if (!IsPlayerConnected(i)) continue;
					GetPlayerName(i, name, sizeof(name));
					if (strcmp(name, TanyaClowns[listitem], true) == 0) {
					    SendClientMessage(playerid, COLOR_GREY, "� ������ ������ ���� �������� ��������� � ����. ������������ ����������.");
					    return 1;
					}
				}
				if (PlayerConnect[playerid])
				    OnPlayerDisconnect(playerid, 1);
				SetPlayerName(playerid, TanyaClowns[listitem]);
				LoadAccount(playerid);
	            OnPlayerLogin(playerid);
	        }
	        else {
	            new listitems[] = "{FF0000}��������� ������\n{0066FF}��������� ������\n{33FF66}��������� ����";
			 	ShowPlayerDialog(playerid, 1001, DIALOG_STYLE_LIST, "���� � ����", listitems, "�������", "�����");
	        }
	    }
	    case 1005:
	    {
	        new listitems[] = "{82eb9d}������� ��������� ��� �����\n{ca0000}����� �� ��������� (������� �������)\n{007dff}����� �� ��������� (����� �������)\n{e5ff11}��������� �����";
			ShowPlayerDialog(playerid, 1000, DIALOG_STYLE_LIST, "���� � ����", listitems, "�������", "�����");
	    }
	    case 2000:
	    {
	        if (response)
	        	DeleteSelectedItem(playerid);
	    }
	    case 3000:
	    {
	        if (response) {
	            new buying_item;
	            new price;
	            new count = 1;
	            switch (listitem) {
	                case 0:
	                {
	                    price = 25;
	                    buying_item = 336;
	                }
	                case 1:
	                {
	                    price = 75;
	                    buying_item = 19893;
	                }
	                case 2:
	                {
	                    price = 200;
	                    buying_item = 1581;
	                }
	                case 3:
	                {
	                    price = 800;
	                    buying_item = 2684;
	                }
	            }
	            if (PlayerInfo[playerid][Cash] >= price) {
                    if (GetItemSlot(playerid, buying_item) == -1 && GetInvEmptySlots(playerid) == 0) {
                        ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "������", "���������� ���������� �������: ��������� �����.", "�������", "");
                        return 1;
                    }
                    PlayerInfo[playerid][Cash] -= price;
                    GivePlayerMoney(playerid, -price);
                    AddItem(playerid, buying_item, count);
                    SendClientMessage(playerid, 0xFFFFFFFF, "������� ������.");
                }
                else SendClientMessage(playerid, COLOR_GREY, "������������ �������.");
	        }
	        else return 1;
	    }
	    case 3100:
	    {
	        if (response) {
	            new price;
				new effect;
				new time;
	            switch (listitem) {
	                case 0:
	                {
	                    price = 25;
	                    if (GetRndResult(50)) effect = EFFECT_MAYO_POSITIVE;
	                    else effect = EFFECT_MAYO_NEGATIVE;
	                    time = 100;
	                }
	                case 1:
	                {
	                    if (PlayerInfo[playerid][Rate] < 501) {
	                        SendClientMessage(playerid, COLOR_GREY, "� ��� ������� ������ ������� ��� ����� ��������.");
	                        return 1;
	                    }
	                    price = 50;
	                    if (GetRndResult(50)) effect = EFFECT_MARMELADE_POSITIVE;
	                    else effect = EFFECT_MARMELADE_NEGATIVE;
	                    time = 100;
	                }
	                case 2:
	                {
	                    if (PlayerInfo[playerid][Rate] < 1001) {
	                        SendClientMessage(playerid, COLOR_GREY, "� ��� ������� ������ ������� ��� ����� ��������.");
	                        return 1;
	                    }
	                    price = 75;
	                    if (GetRndResult(50)) effect = EFFECT_SALAT_POSITIVE;
	                    else effect = EFFECT_SALAT_NEGATIVE;
	                    time = 120;
	                }
	            }
	            if (PlayerInfo[playerid][Cash] >= price) {
	                new slot = FindEffectSlotForEat(playerid);
                    PlayerInfo[playerid][Cash] -= price;
                    GivePlayerMoney(playerid, -price);
                    SetPlayerEffect(playerid, effect, time, slot);
                    SendClientMessage(playerid, 0xFFFFFFFF, "������� ������.");
                }
                else SendClientMessage(playerid, COLOR_GREY, "������������ �������.");
	        }
	        else return 1;
	    }
	    case 3200:
	    {
	        if (response) {
	            new price;
				new effect;
				new time;
	            switch (listitem) {
	                case 0:
	                {
	                    if (PlayerInfo[playerid][Rate] < 1201) {
	                        SendClientMessage(playerid, COLOR_GREY, "� ��� ������� ������ ������� ��� ����� ��������.");
	                        return 1;
	                    }
	                    price = 100;
	                    effect = EFFECT_SOUP;
	                    time = 80;
	                }
	                case 1:
	                {
	                    if (PlayerInfo[playerid][Rate] < 1401) {
	                        SendClientMessage(playerid, COLOR_GREY, "� ��� ������� ������ ������� ��� ����� ��������.");
	                        return 1;
	                    }
	                    price = 150;
	                    effect = EFFECT_POTATO;
	                    time = 90;
	                }
	                case 2:
	                {
	                    if (PlayerInfo[playerid][Rate] < 1601) {
	                        SendClientMessage(playerid, COLOR_GREY, "� ��� ������� ������ ������� ��� ����� ��������.");
	                        return 1;
	                    }
	                    price = 200;
	                    effect = EFFECT_CAKE;
	                    time = 100;
	                }
	                case 3:
	                {
	                    if (PlayerInfo[playerid][Rate] < 2001) {
	                        SendClientMessage(playerid, COLOR_GREY, "� ��� ������� ������ ������� ��� ����� ��������.");
	                        return 1;
	                    }
	                    price = 300;
	                    effect = EFFECT_GOOSE;
	                    time = 130;
	                }
	            }
	            if (PlayerInfo[playerid][Cash] >= price) {
	                new slot = FindEffectSlotForEat(playerid);
                    PlayerInfo[playerid][Cash] -= price;
                    GivePlayerMoney(playerid, -price);
                    SetPlayerEffect(playerid, effect, time, slot);
                    SendClientMessage(playerid, 0xFFFFFFFF, "������� ������.");
                }
                else SendClientMessage(playerid, COLOR_GREY, "������������ �������.");
	        }
	        else return 1;
	    }
        case 3300:
	    {
	        if (response) {
	            new buying_item;
	            new price;
	            new count = 1;
	            switch (listitem) {
	                case 0:
	                {
	                    if (PlayerInfo[playerid][Rate] < 501) {
	                        SendClientMessage(playerid, COLOR_GREY, "� ��� ������� ������ ������� ��� ����� ��������.");
	                        return 1;
	                    }
	                    price = 100;
	                    buying_item = 1242;
	                }
	                case 1:
	                {
	                    if (PlayerInfo[playerid][Rate] < 1001) {
	                        SendClientMessage(playerid, COLOR_GREY, "� ��� ������� ������ ������� ��� ����� ��������.");
	                        return 1;
	                    }
	                    price = 150;
	                    buying_item = 19577;
	                }
	                case 2:
	                {
	                    if (PlayerInfo[playerid][Rate] < 1201) {
	                        SendClientMessage(playerid, COLOR_GREY, "� ��� ������� ������ ������� ��� ����� ��������.");
	                        return 1;
	                    }
	                    price = 200;
	                    buying_item = 2726;
	                }
	                case 3:
	                {
	                    if (PlayerInfo[playerid][Rate] < 1401) {
	                        SendClientMessage(playerid, COLOR_GREY, "� ��� ������� ������ ������� ��� ����� ��������.");
	                        return 1;
	                    }
	                    price = 275;
	                    buying_item = 2689;
	                }
	                case 4:
	                {
	                    if (PlayerInfo[playerid][Rate] < 1601) {
	                        SendClientMessage(playerid, COLOR_GREY, "� ��� ������� ������ ������� ��� ����� ��������.");
	                        return 1;
	                    }
	                    price = 350;
	                    buying_item = 2411;
	                }
	                case 5:
	                {
	                    if (PlayerInfo[playerid][Rate] < 2001) {
	                        SendClientMessage(playerid, COLOR_GREY, "� ��� ������� ������ ������� ��� ����� ��������.");
	                        return 1;
	                    }
	                    price = 500;
	                    buying_item = 1252;
	                }
	                case 6:
	                {
	                    if (PlayerInfo[playerid][Rate] < 2301) {
	                        SendClientMessage(playerid, COLOR_GREY, "� ��� ������� ������ ������� ��� ����� ��������.");
	                        return 1;
	                    }
	                    price = 725;
	                    buying_item = 19883;
	                }
	                case 7:
	                {
	                    if (PlayerInfo[playerid][Rate] < 2701) {
	                        SendClientMessage(playerid, COLOR_GREY, "� ��� ������� ������ ������� ��� ����� ��������.");
	                        return 1;
	                    }
	                    price = 1000;
	                    buying_item = 1944;
	                }
	                case 8:
	                {
	                    if (PlayerInfo[playerid][Rate] < 1601) {
	                        SendClientMessage(playerid, COLOR_GREY, "� ��� ������� ������ ������� ��� ����� ��������.");
	                        return 1;
	                    }
	                    price = 2000;
	                    buying_item = 2710;
	                }
	            }
	            if (PlayerInfo[playerid][Cash] >= price) {
                    if (GetItemSlot(playerid, buying_item) == -1 && GetInvEmptySlots(playerid) == 0) {
                        ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "������", "���������� ���������� �������: ��������� �����.", "�������", "");
                        return 1;
                    }
                    PlayerInfo[playerid][Cash] -= price;
                    GivePlayerMoney(playerid, -price);
                    AddItem(playerid, buying_item, count);
                    SendClientMessage(playerid, 0xFFFFFFFF, "������� ������.");
                }
                else SendClientMessage(playerid, COLOR_GREY, "������������ �������.");
	        }
	        else return 1;
	    }
		case 4000:
		{
		    if (response) {
		        switch (listitem) {
		            case 0:
		            {
		                new listitems[512];
						format(listitems, sizeof(listitems), "��� ������: %d$\n10$\n50$\n100$\n500$\n1000$\n������ �����", PlayerInfo[playerid][Bank]);
		                ShowPlayerDialog(playerid, 4001, DIALOG_STYLE_TABLIST_HEADERS, "��������", listitems, "�����", "�����");
                        return 1;
		            }
		            case 1:
		            {
		                ShowPlayerDialog(playerid, 4002, DIALOG_STYLE_INPUT, "��������", "������� �����:", "��", "�����");
                        return 1;
		            }
		        }
		    }
		    else return 1;
		}
		case 4001:
		{
		    if (response) {
		        new amount = 0;
		        switch (listitem) {
		            case 0: amount = 10;
		            case 1: amount = 50;
		            case 2: amount = 100;
		            case 3: amount = 500;
		            case 4: amount = 1000;
		            case 5:
		            {
                        ShowPlayerDialog(playerid, 4003, DIALOG_STYLE_INPUT, "��������", "������� �����:", "��", "�����");
                        return 1;
		            }
		        }
		        if (PlayerInfo[playerid][Bank] < amount) {
		            ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "������", "�� ����� ����� ������������ �������.", "�������", "");
                    return 1;
		        }
                PlayerInfo[playerid][Bank] -= amount;
                PlayerInfo[playerid][Cash] += amount;
                GivePlayerMoney(playerid, amount);
				return 1;
		    }
		    else {
		        new listitems[512];
				format(listitems, sizeof(listitems), "��� ������: %d$\n����� ��������\n��������� ����", PlayerInfo[playerid][Bank]);
				ShowPlayerDialog(playerid, 4000, DIALOG_STYLE_TABLIST_HEADERS, "��������", listitems, "�����", "�����");
		    }
		}
		case 4002:
		{
		    if (response) {
		        new amount = strval(inputtext);
		        new n_amount = floatround(floatmul(amount, 0.9));
		        if (PlayerInfo[playerid][Cash] < amount) {
		            ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "������", "������������ �������.", "�������", "");
                    return 1;
		        }
				PlayerInfo[playerid][Cash] -= amount;
				PlayerInfo[playerid][Bank] += n_amount;
				GivePlayerMoney(playerid, -amount);
				new inf[64];
				format(inf, sizeof(inf), "���� �������� �� %d$.", n_amount);
				SendClientMessage(playerid, COLOR_GREEN, inf);
				return 1;
		    }
		    else {
		        new listitems[512];
				format(listitems, sizeof(listitems), "��� ������: %d$\n����� ��������\n��������� ����", PlayerInfo[playerid][Bank]);
				ShowPlayerDialog(playerid, 4000, DIALOG_STYLE_TABLIST_HEADERS, "��������", listitems, "�����", "�����");
		    }
		}
		case 4003:
		{
		    if (response) {
		        new amount = strval(inputtext);
		        if (PlayerInfo[playerid][Bank] < amount) {
		            ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "������", "�� ����� ����� ������������ �������.", "�������", "");
                    return 1;
		        }
				PlayerInfo[playerid][Cash] += amount;
				PlayerInfo[playerid][Bank] -= amount;
				GivePlayerMoney(playerid, amount);
				new inf[64];
				format(inf, sizeof(inf), "�������� %d$.", amount);
				SendClientMessage(playerid, COLOR_GREEN, inf);
				return 1;
		    }
		    else {
		        new listitems[512];
				format(listitems, sizeof(listitems), "��� ������: %d$\n����� ��������\n��������� ����", PlayerInfo[playerid][Bank]);
				ShowPlayerDialog(playerid, 4000, DIALOG_STYLE_TABLIST_HEADERS, "��������", listitems, "�����", "�����");
		    }
		}
	}
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
    if (playertextid == PanelInventory[playerid])
    {
		ShowInventory(playerid);
		IsInventoryOpen[playerid] = true;
		return 1;
    }
    else if (playertextid == PanelInfo[playerid])
    {
		ShowInfo(playerid);
		return 1;
    }
    else if (playertextid == PanelUndress[playerid])
    {
		if (PlayerInfo[playerid][Skin] == 252 || PlayerInfo[playerid][Skin] == 138) {
		    ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "������", "������ �� ������������.", "��", "");
		    return 1;
		}
		UndressSkin(playerid);
		return 1;
    }
    else if (playertextid == PanelSwitch[playerid])
    {
		new listitems[] = "{82eb9d}������� ��������� ��� �����\n{ca0000}����� �� ��������� (������� �������)\n{007dff}����� �� ��������� (����� �������)\n{e5ff11}��������� �����";
		ShowPlayerDialog(playerid, 1000, DIALOG_STYLE_LIST, "���� � ����", listitems, "�������", "�����");
		return 1;
    }
	else if (playertextid == inv_ico[playerid])
    {
		HideInventory(playerid);
		IsInventoryOpen[playerid] = false;
		return 1;
    }
    else if (playertextid == btn_del[playerid])
    {
		if (SelectedSlot[playerid] == -1 || PlayerInfo[playerid][Inventory][SelectedSlot[playerid]] == 0)
		    ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "������", "�� ������ �� ���� �������.", "��", "");
		else
			ShowPlayerDialog(playerid, 2000, DIALOG_STYLE_MSGBOX, "�������������", "�� ������������� ������ ��������� �������?", "��", "���");
		return 1;
    }
    else if (playertextid == btn_info[playerid])
    {
		if (SelectedSlot[playerid] == -1 || PlayerInfo[playerid][Inventory][SelectedSlot[playerid]] == 0)
		    ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "������", "�� ������ �� ���� �������.", "��", "");
		else {
		    new info[1024];
		    info = GetSelectedItemInfo(playerid);
			ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "����������", info, "�������", "");
		}
		return 1;
    }
    else if (playertextid == btn_use[playerid])
    {
		if (SelectedSlot[playerid] == -1 || PlayerInfo[playerid][Inventory][SelectedSlot[playerid]] == 0)
		    ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "������", "�� ������ �� ���� �������.", "��", "");
		else {
		    UseItem(playerid, SelectedSlot[playerid]);
		}
		return 1;
    }
    for (new i = 0; i < MAX_SLOTS; i++) {
        if (playertextid == InvSlot[playerid][i]) {
            if (SelectedSlot[playerid] != -1) {
                if (PlayerInfo[playerid][Inventory][SelectedSlot[playerid]] != 0 &&
                    PlayerInfo[playerid][Inventory][i] == 0) {
                    PlayerInfo[playerid][Inventory][i] = PlayerInfo[playerid][Inventory][SelectedSlot[playerid]];
                    PlayerInfo[playerid][InventoryCount][i] = PlayerInfo[playerid][InventoryCount][SelectedSlot[playerid]];
                    PlayerInfo[playerid][Inventory][SelectedSlot[playerid]] = 0;
                    PlayerInfo[playerid][InventoryCount][SelectedSlot[playerid]] = 0;
                    new oldslot = SelectedSlot[playerid];
                    SelectedSlot[playerid] = -1;
                    UpdateSlot(playerid, oldslot);
                    UpdateSlot(playerid, i);
                    break;
                }
                SetSlotSelection(playerid, SelectedSlot[playerid], false);
            }
            SelectedSlot[playerid] = i;
            SetSlotSelection(playerid, i, true);
            break;
        }
    }
    return 0;
}

//==============================================================================
//========���=======
//����� �����
stock StartMatch()
{
	IsMatchRunned = true;
	currentRound = 1;
	ShowMatchInterface(Registration[0]);
	ShowMatchInterface(Registration[1]);
}
//����� �����
stock StopMatch()
{
	IsMatchRunned = false;
	KillAllMatchTimers();
}
//������ ������� ������ ���
stock StartReadyTimer()
{
	if (Registration[0] == -1 || Registration[1] == -1)
		return;
	ReadyTimerTicks = MAX_READY_TIME;
	MatchTimer = SetTimer("ReadyTimerTick", 1000, true);
	new str[16];
	format(str, sizeof(str), "~y~%i", ReadyTimerTicks);
	GameTextForPlayer(Registration[0], str, 1000, 6);
	GameTextForPlayer(Registration[1], str, 1000, 6);
}
//��� ������� ������ ������
public ReadyTimerTick()
{
	if (Registration[0] == -1 || Registration[1] == -1) {
		KillAllMatchTimers();
		SendClientMessageToAll(COLOR_LIGHTRED, "������� ���� ��� �������.");
		return;
	}
	ReadyTimerTicks--;
	new str[16];
	format(str, sizeof(str), "~y~%i", ReadyTimerTicks);
	GameTextForPlayer(Registration[0], str, 1000, 6);
	GameTextForPlayer(Registration[1], str, 1000, 6);
	if (ReadyTimerTicks <= 0)
	    StartRound();
}
//������ ������
stock StartRound()
{
	KillAllMatchTimers();
	RoundTimer = SetTimer("StopRound", MAX_SOLO_ROUNDTIME * 1000, false);
	RoundTimerTicks = MAX_SOLO_ROUNDTIME;
}
//����� ������
public StopRound()
{
	currentRound++;
	if (currentRound >= 3) {
		//TODO:
		KillAllMatchTimers();
		return;
	}
	//TODO:
	KillAllMatchTimers();
}
//
//���������� �������� �����
stock KillAllMatchTimers()
{
	if (MatchTimer > -1) {
	    KillTimer(MatchTimer);
	    MatchTimer = -1;
	}
	if (RoundTimer > -1) {
	    KillTimer(RoundTimer);
	    RoundTimer = -1;
	}
}
//���������� ������� ����������
stock KillReadyTimer()
{
	if (MatchTimer > -1) {
	    KillTimer(MatchTimer);
	    MatchTimer = -1;
	}
}
//���������� ������� ������
stock KillRoundTime()
{
	if (RoundTimer > -1) {
	    KillTimer(RoundTimer);
	    RoundTimer = -1;
	}
}
//����� ��������
stock ResetPlayerEffects(playerid)
{
	for (new i = 0; i < MAX_EFFECTS; i++) {
	    if (PlayerInfo[playerid][EffectsID][i] == -1) continue;
	    PlayerTextDrawHide(playerid, EBox[playerid][i]);
		PlayerTextDrawHide(playerid, EBox_Time[playerid][i]);
		PlayerInfo[playerid][EffectsID][i] = -1;
		PlayerInfo[playerid][EffectsTime][i] = 0;
	}
}
//��������� ������
stock SetPlayerEffect(playerid, effectid, time, slot)
{
	//red = 0xCC000044
	//green = 0x00CC0044
	new model = 0;
	new Float:rotX = 0, Float:rotY = 0, Float:rotZ = 0;
	switch (effectid) {
	    case EFFECT_SHAZOK_GEAR:
	    {
	        SetPVarInt(playerid, "sgear", 1);
	        model = 2689;
	        PlayerTextDrawBackgroundColor(playerid, EBox[playerid][slot], 0x00CC0044);
	    }
	    case EFFECT_LUSI_APRON:
	    {
            SetPVarInt(playerid, "lusiap", 1);
	        model = 2411;
	        PlayerTextDrawBackgroundColor(playerid, EBox[playerid][slot], 0x00CC0044);
	    }
	    case EFFECT_MAYO_POSITIVE:
	    {
			PlayerInfo[playerid][Defense] += 10;
			rotX = 270;
			model = 19580;
			PlayerTextDrawBackgroundColor(playerid, EBox[playerid][slot], 0x00CC0044);
	    }
	    case EFFECT_MAYO_NEGATIVE:
	    {
            PlayerInfo[playerid][Dodge] = 0;
            rotX = 270;
			model = 19580;
			PlayerTextDrawBackgroundColor(playerid, EBox[playerid][slot], 0xCC000044);
	    }
	    case EFFECT_MARMELADE_POSITIVE:
	    {
            PlayerInfo[playerid][Damage] = floatround(floatmul(PlayerInfo[playerid][Damage], 1.1));
            rotX = 270;
			model = 19580;
			PlayerTextDrawBackgroundColor(playerid, EBox[playerid][slot], 0x00CC0044);
	    }
	    case EFFECT_MARMELADE_NEGATIVE:
	    {
            PlayerInfo[playerid][Accuracy] = PlayerInfo[playerid][Accuracy] / 2;
            rotX = 270;
			model = 19580;
			PlayerTextDrawBackgroundColor(playerid, EBox[playerid][slot], 0xCC000044);
	    }
	    case EFFECT_SALAT_POSITIVE:
	    {
            PlayerInfo[playerid][CriticalChance] += 10;
            rotX = 270;
			model = 19580;
			PlayerTextDrawBackgroundColor(playerid, EBox[playerid][slot], 0x00CC0044);
	    }
	    case EFFECT_SALAT_NEGATIVE:
	    {
            PlayerInfo[playerid][Damage] = floatround(floatmul(PlayerInfo[playerid][Damage], 0.85));
            rotX = 270;
			model = 19580;
			PlayerTextDrawBackgroundColor(playerid, EBox[playerid][slot], 0xCC000044);
	    }
	    case EFFECT_SOUP:
	    {
            PlayerInfo[playerid][Accuracy] += 15;
            rotX = 270;
			model = 19580;
			PlayerTextDrawBackgroundColor(playerid, EBox[playerid][slot], 0x00CC0044);
	    }
	    case EFFECT_POTATO:
	    {
            PlayerInfo[playerid][Dodge] += 10;
            rotX = 270;
			model = 19580;
			PlayerTextDrawBackgroundColor(playerid, EBox[playerid][slot], 0x00CC0044);
	    }
	    case EFFECT_CAKE:
	    {
            SetPVarInt(playerid, "cake", 1);
            rotX = 270;
			model = 19580;
			PlayerTextDrawBackgroundColor(playerid, EBox[playerid][slot], 0x00CC0044);
	    }
	    case EFFECT_GOOSE:
	    {
            SetPVarInt(playerid, "goose", 1);
            rotX = 270;
			model = 19580;
			PlayerTextDrawBackgroundColor(playerid, EBox[playerid][slot], 0x00CC0044);
	    }
	    case EFFECT_CUT:
	    {
            PlayerInfo[playerid][Defense] -= 15;
            SetPVarInt(playerid, "cut", 1);
			model = 1240;
			PlayerTextDrawBackgroundColor(playerid, EBox[playerid][slot], 0xCC000044);
	    }
	    case EFFECT_USELESS:
	    {
	        PlayerInfo[playerid][Defense] -= 50;
            PlayerInfo[playerid][Defense] = floatround(floatmul(PlayerInfo[playerid][Defense], 0.5));
            PlayerInfo[playerid][Damage] = floatround(floatmul(PlayerInfo[playerid][Damage], 0.1));
            model = 3092;
            rotZ = 180;
			PlayerTextDrawBackgroundColor(playerid, EBox[playerid][slot], 0xCC000044);
	    }
	    case EFFECT_MINE:
	    {
	        SetPVarInt(playerid, "mine", 1);
            model = 1252;
			PlayerTextDrawBackgroundColor(playerid, EBox[playerid][slot], 0xCC000044);
	    }
	    case EFFECT_PAIN:
	    {
            PlayerInfo[playerid][Dodge] = 0;
            PlayerInfo[playerid][CriticalChance] = 0;
            PlayerInfo[playerid][Defense] -= 20;
            PlayerInfo[playerid][Damage] = floatround(floatmul(PlayerInfo[playerid][Damage], 0.9));
            SetPVarInt(playerid, "pain", slot);
            model = 1254;
			PlayerTextDrawBackgroundColor(playerid, EBox[playerid][slot], 0xCC000044);
	    }
	    case EFFECT_POISON:
	    {
            SetPVarInt(playerid, "poison", GetPVarInt(playerid, "poison") + 1);
            model = 1313;
			PlayerTextDrawBackgroundColor(playerid, EBox[playerid][slot], 0xCC000044);
	    }
	    default:
	        return;
	}
	if (PlayerInfo[playerid][Defense] < 0)
    	PlayerInfo[playerid][Defense] = 0;
	new numbers[16];
	format(numbers, sizeof(numbers), "%d", time);
	PlayerTextDrawSetPreviewModel(playerid, EBox[playerid][slot], model);
	PlayerTextDrawSetPreviewRot(playerid, EBox[playerid][slot], rotX, rotY, rotZ, 1.0);
	PlayerTextDrawSetString(playerid, EBox_Time[playerid][slot], numbers);
	PlayerTextDrawShow(playerid, EBox[playerid][slot]);
	PlayerTextDrawShow(playerid, EBox_Time[playerid][slot]);
	PlayerInfo[playerid][EffectsID][slot] = effectid;
	PlayerInfo[playerid][EffectsTime][slot] = time;
}

//�������� ������
stock DisablePlayerEffect(playerid, slot)
{
	switch (PlayerInfo[playerid][EffectsID][slot]) {
	    case EFFECT_SHAZOK_GEAR:
	    {
	        DeletePVar(playerid, "sgear");
	    }
	    case EFFECT_LUSI_APRON:
	    {
	        DeletePVar(playerid, "lusiap");
	    }
	    case EFFECT_MAYO_POSITIVE:
	    {
			SetPlayerBaseParam(playerid, PARAM_DEFENSE);
	    }
	    case EFFECT_MAYO_NEGATIVE:
	    {
            SetPlayerBaseParam(playerid, PARAM_DODGE);
	    }
	    case EFFECT_MARMELADE_POSITIVE:
	    {
            SetPlayerBaseParam(playerid, PARAM_DAMAGE);
	    }
	    case EFFECT_MARMELADE_NEGATIVE:
	    {
            SetPlayerBaseParam(playerid, PARAM_ACCURACY);
	    }
	    case EFFECT_SALAT_POSITIVE:
	    {
            SetPlayerBaseParam(playerid, PARAM_CRITICAL_CHANCE);
	    }
	    case EFFECT_SALAT_NEGATIVE:
	    {
            SetPlayerBaseParam(playerid, PARAM_DAMAGE);
	    }
	    case EFFECT_SOUP:
	    {
            SetPlayerBaseParam(playerid, PARAM_ACCURACY);
	    }
	    case EFFECT_POTATO:
	    {
            SetPlayerBaseParam(playerid, PARAM_DODGE);
	    }
	    case EFFECT_CAKE:
	    {
	        DeletePVar(playerid, "cake");
	    }
	    case EFFECT_GOOSE:
	    {
	        DeletePVar(playerid, "goose");
	    }
	    case EFFECT_CUT:
	    {
	        SetPlayerBaseParam(playerid, PARAM_DEFENSE);
	        DeletePVar(playerid, "cut");
	    }
	    case EFFECT_USELESS:
	    {
	        SetPlayerBaseParam(playerid, PARAM_DAMAGE);
	        SetPlayerBaseParam(playerid, PARAM_DEFENSE);
	    }
	    case EFFECT_MINE:
	    {
	        DeletePVar(playerid, "mine");
	    }
	    case EFFECT_PAIN:
	    {
	        SetPlayerBaseParam(playerid, PARAM_DAMAGE);
	        SetPlayerBaseParam(playerid, PARAM_DEFENSE);
	        SetPlayerBaseParam(playerid, PARAM_DODGE);
	        SetPlayerBaseParam(playerid, PARAM_CRITICAL_CHANCE);
	        DeletePVar(playerid, "pain");
	    }
	    case EFFECT_POISON:
	    {
	        DeletePVar(playerid, "poison");
	    }
	}
	PlayerInfo[playerid][EffectsID][slot] = -1;
	PlayerInfo[playerid][EffectsTime][slot] = 0;
	for (new i = slot; i < MAX_EFFECTS - 1; i++) {
	    if (PlayerInfo[playerid][EffectsID][i+1] == -1) break;
	    PlayerInfo[playerid][EffectsID][i] = PlayerInfo[playerid][EffectsID][i+1];
		PlayerInfo[playerid][EffectsTime][i] = PlayerInfo[playerid][EffectsTime][i+1];
		PlayerInfo[playerid][EffectsID][i+1] = -1;
		PlayerInfo[playerid][EffectsTime][i+1] = 0;
	}
	UpdateEffects(playerid);
}

//��������� �������
stock UpdateEffects(playerid)
{
	for (new i = 0; i < MAX_EFFECTS; i++) {
	    PlayerTextDrawHide(playerid, EBox[playerid][i]);
	    PlayerTextDrawHide(playerid, EBox_Time[playerid][i]);
	}
	for (new i = 0; i < MAX_EFFECTS; i++) {
	    if (PlayerInfo[playerid][EffectsID][i] == -1) break;
	    new model = 0;
		new Float:rotX = 0, Float:rotY = 0, Float:rotZ = 0;
	    switch (PlayerInfo[playerid][EffectsID][i]) {
		    case EFFECT_SHAZOK_GEAR:
		    {
		        model = 2689;
		        PlayerTextDrawBackgroundColor(playerid, EBox[playerid][i], 0x00CC0044);
		    }
		    case EFFECT_LUSI_APRON:
		    {
		        model = 2411;
		        PlayerTextDrawBackgroundColor(playerid, EBox[playerid][i], 0x00CC0044);
		    }
		    case EFFECT_MAYO_POSITIVE:
		    {
				rotX = 270;
				model = 19580;
				PlayerTextDrawBackgroundColor(playerid, EBox[playerid][i], 0x00CC0044);
		    }
		    case EFFECT_MAYO_NEGATIVE:
		    {
	            rotX = 270;
				model = 19580;
				PlayerTextDrawBackgroundColor(playerid, EBox[playerid][i], 0xCC000044);
		    }
		    case EFFECT_MARMELADE_POSITIVE:
		    {
	            rotX = 270;
				model = 19580;
				PlayerTextDrawBackgroundColor(playerid, EBox[playerid][i], 0x00CC0044);
		    }
		    case EFFECT_MARMELADE_NEGATIVE:
		    {
	            rotX = 270;
				model = 19580;
				PlayerTextDrawBackgroundColor(playerid, EBox[playerid][i], 0xCC000044);
		    }
		    case EFFECT_SALAT_POSITIVE:
		    {
	            rotX = 270;
				model = 19580;
				PlayerTextDrawBackgroundColor(playerid, EBox[playerid][i], 0x00CC0044);
		    }
		    case EFFECT_SALAT_NEGATIVE:
		    {
	            rotX = 270;
				model = 19580;
				PlayerTextDrawBackgroundColor(playerid, EBox[playerid][i], 0xCC000044);
		    }
		    case EFFECT_SOUP:
		    {
	            rotX = 270;
				model = 19580;
				PlayerTextDrawBackgroundColor(playerid, EBox[playerid][i], 0x00CC0044);
		    }
		    case EFFECT_POTATO:
		    {
	            rotX = 270;
				model = 19580;
				PlayerTextDrawBackgroundColor(playerid, EBox[playerid][i], 0x00CC0044);
		    }
		    case EFFECT_CAKE:
		    {
	            rotX = 270;
				model = 19580;
				PlayerTextDrawBackgroundColor(playerid, EBox[playerid][i], 0x00CC0044);
		    }
		    case EFFECT_GOOSE:
		    {
	            rotX = 270;
				model = 19580;
				PlayerTextDrawBackgroundColor(playerid, EBox[playerid][i], 0x00CC0044);
		    }
		    case EFFECT_CUT:
		    {
	            SetPVarInt(playerid, "cut", 1);
				model = 1240;
				PlayerTextDrawBackgroundColor(playerid, EBox[playerid][i], 0xCC000044);
		    }
		    case EFFECT_USELESS:
		    {
	            model = 3092;
	            rotZ = 180;
				PlayerTextDrawBackgroundColor(playerid, EBox[playerid][i], 0xCC000044);
		    }
		    case EFFECT_MINE:
		    {
	            model = 1252;
				PlayerTextDrawBackgroundColor(playerid, EBox[playerid][i], 0xCC000044);
		    }
		    case EFFECT_PAIN:
		    {
	            model = 1254;
				PlayerTextDrawBackgroundColor(playerid, EBox[playerid][i], 0xCC000044);
		    }
		    case EFFECT_POISON:
		    {
	            model = 1313;
				PlayerTextDrawBackgroundColor(playerid, EBox[playerid][i], 0xCC000044);
		    }
	    }
	    new numbers[16];
		format(numbers, sizeof(numbers), "%d", PlayerInfo[playerid][EffectsTime][i]);
		PlayerTextDrawSetPreviewModel(playerid, EBox[playerid][i], model);
		PlayerTextDrawSetPreviewRot(playerid, EBox[playerid][i], rotX, rotY, rotZ, 1.0);
		PlayerTextDrawSetString(playerid, EBox_Time[playerid][i], numbers);
		PlayerTextDrawShow(playerid, EBox[playerid][i]);
		PlayerTextDrawShow(playerid, EBox_Time[playerid][i]);
	}
}

//���������� ������ ������ ���� ��� ���
stock FindEffectSlotForEat(playerid)
{
	new slot = MAX_EFFECTS - 1;
	for (new i = 0; i < MAX_EFFECTS; i++) {
	    switch (PlayerInfo[playerid][EffectsID][i]) {
	        case EFFECT_MAYO_POSITIVE..EFFECT_GOOSE:
	        {
	            DisablePlayerEffect(playerid, i);
	            return i;
	        }
	    }
	}
	for (new i = 0; i < MAX_EFFECTS; i++) {
	    if (PlayerInfo[playerid][EffectsID][i] == -1)
	        return i;
	}
	DisablePlayerEffect(playerid, slot);
	return slot;
}

//���������� ���� ��� ������ �������
stock FindEffectSlot(playerid)
{
	new slot = MAX_EFFECTS - 1;
	for (new i = 0; i < MAX_EFFECTS; i++) {
	    if (PlayerInfo[playerid][EffectsID][i] == -1)
	        return i;
	}
	DisablePlayerEffect(playerid, slot);
	return slot;
}

//���������� ���� ���������� �������
stock GetEffectSlot(playerid, effectid)
{
	for (new i = 0; i < MAX_EFFECTS; i++) {
	    if (PlayerInfo[playerid][EffectID] == effectid)
	        return i;
	}
	return -1;
}

//����������� �������� �� ����
stock GetRndResult(chance)
{
	new rnd = random(100);
	if (rnd < chance) return true;
	return false;
}

//���������� �������� �� ���������
stock SetPlayerBaseParam(playerid, param)
{
	switch (param) {
	    case PARAM_DAMAGE:
	    {
	        switch (PlayerInfo[playerid][Class]) {
	            case 0: PlayerInfo[playerid][Damage] = 750;
	            case 1: PlayerInfo[playerid][Damage] = 830;
	            case 2: PlayerInfo[playerid][Damage] = 440;
	            case 3: PlayerInfo[playerid][Damage] = 1030;
	            case 4: PlayerInfo[playerid][Damage] = 520;
	            case 5: PlayerInfo[playerid][Damage] = 790;
	        }
	    }
	    case PARAM_DEFENSE:
	    {
            switch (PlayerInfo[playerid][Class]) {
                case 0: PlayerInfo[playerid][Defense] = 36;
	            case 1: PlayerInfo[playerid][Defense] = 17;
	            case 2: PlayerInfo[playerid][Defense] = 30;
	            case 3: PlayerInfo[playerid][Defense] = 10;
	            case 4: PlayerInfo[playerid][Defense] = 15;
	            case 5: PlayerInfo[playerid][Defense] = 5;
	        }
	    }
	    case PARAM_DODGE:
	    {
            switch (PlayerInfo[playerid][Class]) {
                case 0: PlayerInfo[playerid][Dodge] = 15;
	            case 1: PlayerInfo[playerid][Dodge] = 22;
	            case 2: PlayerInfo[playerid][Dodge] = 13;
	            case 3: PlayerInfo[playerid][Dodge] = 19;
	            case 4: PlayerInfo[playerid][Dodge] = 35;
	            case 5: PlayerInfo[playerid][Dodge] = 27;
	        }
	    }
	    case PARAM_ACCURACY:
	    {
            switch (PlayerInfo[playerid][Class]) {
                case 0: PlayerInfo[playerid][Accuracy] = 97;
	            case 1: PlayerInfo[playerid][Accuracy] = 93;
	            case 2: PlayerInfo[playerid][Accuracy] = 98;
	            case 3: PlayerInfo[playerid][Accuracy] = 82;
	            case 4: PlayerInfo[playerid][Accuracy] = 99;
	            case 5: PlayerInfo[playerid][Accuracy] = 85;
	        }
	    }
	    case PARAM_CRITICAL_CHANCE:
	    {
            switch (PlayerInfo[playerid][Class]) {
                case 0: PlayerInfo[playerid][CriticalChance] = 45;
	            case 1: PlayerInfo[playerid][CriticalChance] = 50;
	            case 2: PlayerInfo[playerid][CriticalChance] = 55;
	            case 3: PlayerInfo[playerid][CriticalChance] = 39;
	            case 4: PlayerInfo[playerid][CriticalChance] = 60;
	            case 5: PlayerInfo[playerid][CriticalChance] = 50;
	        }
	    }
	}
}

//���������� ��������� ���������
stock SetPlayerParams(playerid)
{
    SetPlayerBaseParam(playerid, PARAM_DAMAGE);
    SetPlayerBaseParam(playerid, PARAM_DEFENSE);
    SetPlayerBaseParam(playerid, PARAM_DODGE);
    SetPlayerBaseParam(playerid, PARAM_ACCURACY);
    SetPlayerBaseParam(playerid, PARAM_CRITICAL_CHANCE);
}

//���������� ��������� �����
stock ShowTourGrid(playerid)
{
	new out[3096] = "{0099FF}����� �������\t{ffffff}vs\t{FF0000}������� �������";
	for (new i = 0; i < MAX_CLOWNS / 2; i++) {
	    if (strcmp(grid[i][red], "*") == 0 && strcmp(grid[i][blue], "*") == 0)
	        break;
		new name[80];
		if (strcmp(grid[i][red], "*") == 0)
			format(name, sizeof(name), "\n{%s}%s", GetColorByRate(GetRateFromPFile(grid[i][blue])), grid[i][blue]);
		else if (strcmp(grid[i][blue], "*") == 0)
		    format(name, sizeof(name), "\n\t\t{%s}%s", GetColorByRate(GetRateFromPFile(grid[i][red])), grid[i][red]);
		else
			format(name, sizeof(name), "\n{%s}%s \t{ffffff}- \t{%s}%s", GetColorByRate(GetRateFromPFile(grid[i][blue])), grid[i][blue], GetColorByRate(GetRateFromPFile(grid[i][red])), grid[i][red]);
		strcat(out, name);
	}
	new tourinfo[64];
	format(tourinfo, sizeof(tourinfo), "\n{FFCC00}������ ���� %d ���.", 1);
	strcat(out, tourinfo);
	ShowPlayerDialog(playerid, 1005, DIALOG_STYLE_TABLIST_HEADERS, "��������� �����", out, "�����", "");
}

//�������� ��������� �����
stock CreateNewTourGrid() 
{
	new bool:used[MAX_CLOWNS] = false;
	new idx;
	new pairs_count = 0;
	new bool:IsBlue = true;
	new blue_rate = 0;
	new red_rate = 0;
	for (new ii = 0; ii < MAX_CLOWNS; ii++) {
		//���� �������� 1 ����
		if (pairs_count >= MAX_CLOWNS / 2 - 1) {
			for (new i = 0; i < MAX_CLOWNS; i++)
				if (!used[i]) {
					used[i] = true;
					format(grid[pairs_count][blue], 80, "%s", GetOwner(i));
					break;
				}
			for (new i = 0; i < MAX_CLOWNS; i++)
				if (!used[i]) {
					used[i] = true;
					format(grid[pairs_count][red], 80, "%s", GetOwner(i));
					break;
				}
			return;
		}
		do {
			idx = random(MAX_CLOWNS);
		}
		while (used[idx]);
		if (IsBlue) {
			used[idx] = true;
			format(grid[pairs_count][blue], 80, "%s", GetOwner(idx));
			IsBlue = false;
			blue_rate = GetRateFromPFile(GetOwner(idx));
			continue;
		}
		red_rate = GetRateFromPFile(GetOwner(idx));
		if (floatabs(red_rate - blue_rate) <= 200) {
			used[idx] = true;
			format(grid[pairs_count][red], 80, "%s", GetOwner(idx));
			IsBlue = true;
			pairs_count++;
			continue;
		}
		//����� ����������� ����������� �� ��������
		idx = -1;
		new min_rate = 3000;
		for (new i = 0; i < MAX_CLOWNS; i++) {
			if (used[i]) continue;
			red_rate = GetRateFromPFile(GetOwner(i));
			new rate = floatround(floatabs(red_rate - blue_rate));
			if (rate < min_rate) {
				min_rate = rate;
				idx = i;
			}
		}
		used[idx] = true;
		format(grid[pairs_count][red], 80, "%s", GetOwner(idx));
		IsBlue = true;
		pairs_count++;
	}
}

//�������� ������� �� ����� �� �������
stock GetRateFromPFile(name[])
{
	new string[255];
	new rate;
	format(string, sizeof(string), "Players/%s.ini", name);
	new File = ini_openFile(string);
	ini_getInteger(File, "Rate", rate);
	ini_closeFile(File);
	return rate;
}

//�������� ��������� ���������
stock GetOwner(idx)
{
	new name[80];
	switch (idx) {
		case 0..9: format(name, sizeof(name), "%s", VovakClowns[idx]);
		case 10..19: format(name, sizeof(name), "%s", DimakClowns[idx - 10]);
		default: format(name, sizeof(name), "%s", TanyaClowns[idx - 20]);
	}
	return name;
}

//���������� � ���������
stock ShowInfo(playerid)
{
	new info[2000];
	new pinfo[768];
	new name[64];
	GetPlayerName(playerid, name, sizeof(name));
	format(info, sizeof(info), "{FFFFFF}���:\t%s\n���:\t%s\n�����:\t%s\n{FFFFFF}�������:\t{%s}%d\n{FFFFFF}����:\t{%s}%s\n{3399FF}������� � ����:\t{%s}%d\n{66CC00}������:\t%d\n{CC0000}���������:\t%d\n{FFCC00}������� �����:\t%d%%\n{FFFFFF}________________________\n",
		   name, GetPlayerSex(playerid), GetClassNameByID(PlayerInfo[playerid][Class]), GetColorByRate(PlayerInfo[playerid][Rate]), PlayerInfo[playerid][Rate], GetColorByRate(PlayerInfo[playerid][Rate]), GetRateInterval(PlayerInfo[playerid][Rate]), GetPlaceColor(PlayerInfo[playerid][TopPosition]), PlayerInfo[playerid][TopPosition],
		   PlayerInfo[playerid][Wins], PlayerInfo[playerid][Loses], GetPlayerWinPercent(playerid));
	format(pinfo, sizeof(pinfo), "{0066CC}�����:\t%d\n{CC0000}������:\t%d%%\n{FF9900}��������:\t%d%%\n{33CC99}���������:\t%d%%\n{FF6600}���� �����:\t%d%%",
		   PlayerInfo[playerid][Damage], PlayerInfo[playerid][Defense], PlayerInfo[playerid][Accuracy], PlayerInfo[playerid][Dodge], PlayerInfo[playerid][CriticalChance]);
	strcat(info, pinfo);
	ShowPlayerDialog(playerid, 1, DIALOG_STYLE_TABLIST, "����������", info, "�������", "");
}

//�������� ������� �����
stock GetPlayerWinPercent(playerid)
{
	new percent = floatround(floatmul(floatdiv(PlayerInfo[playerid][Wins], PlayerInfo[playerid][Loses]), 100));
	return percent;
}

//�������� ��� ���������
stock GetPlayerSex(playerid) {
	new sex[32];
	switch (PlayerInfo[playerid][Sex]) {
	    case 0: sex = "�������";
		default: sex = "�������";
	}
	return sex;
}

//����� ������
stock UndressSkin(playerid)
{
    if (GetInvEmptySlots(playerid) == 0) {
	    ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "������", "���������� ����� ������: ��������� �����.", "��", "");
	    return;
	}
	AddItem(playerid, PlayerInfo[playerid][Skin], 1);
	if (PlayerInfo[playerid][Sex] == 0)
	    PlayerInfo[playerid][Skin] = 252;
	else
	    PlayerInfo[playerid][Skin] = 138;
	SetPlayerSkin(playerid, PlayerInfo[playerid][Skin]);
}

//������������ �������
stock UseItem(playerid, slot)
{
	new item = PlayerInfo[playerid][Inventory][slot];
	switch (item) {
	    case 83,91,84,214,120,141,264,152,147,150,127,169,204,298,114,195,97,140,161,198,287,191:
	    {
            PlayerInfo[playerid][InventoryCount][slot]--;
	        if (PlayerInfo[playerid][InventoryCount][slot] <= 0) {
	            PlayerInfo[playerid][InventoryCount][slot] = 0;
	            PlayerInfo[playerid][Inventory][slot] = 0;
	        }
	        UpdateSlot(playerid, slot);
			if (PlayerInfo[playerid][Skin] != 252 && PlayerInfo[playerid][Skin] != 138)
			    UndressSkin(playerid);
	        PlayerInfo[playerid][Skin] = item;
	        SetPlayerSkin(playerid, PlayerInfo[playerid][Skin]);
	    }
	    case 296:
	    {
	        if (PlayerInfo[playerid][Sex] == 1) {
	            ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "������", "������ ������� ����� ������ ������ ��������� �������� ����.", "�������", "");
	        	return;
	        }
	        PlayerInfo[playerid][InventoryCount][slot]--;
	        if (PlayerInfo[playerid][InventoryCount][slot] <= 0) {
	            PlayerInfo[playerid][InventoryCount][slot] = 0;
	            PlayerInfo[playerid][Inventory][slot] = 0;
	        }
	        UpdateSlot(playerid, slot);
			if (PlayerInfo[playerid][Skin] != 252 && PlayerInfo[playerid][Skin] != 138)
			    UndressSkin(playerid);
	        PlayerInfo[playerid][Skin] = item;
	        SetPlayerSkin(playerid, PlayerInfo[playerid][Skin]);
	    }
	    case 1581, 2684:
	    {
	        ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "������", "������ ������� �������� ���������. ������������� ����������.", "�������", "");
	        return;
	    }
	    //������������� ����
	    case 1242:
	    {
	        if (!IsBattleBegins) {
	            ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "������", "�� �� ���������� � ������ ���. ������������� ����������.", "�������", "");
				return;
	        }
	        //activity
	    }
	    //������� ���
	    case 19577:
	    {
	        if (!IsBattleBegins) {
	            ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "������", "�� �� ���������� � ������ ���. ������������� ����������.", "�������", "");
				return;
	        }
	        //activity
	    }
	    //��������� ���������
	    case 2726:
	    {
	        if (!IsBattleBegins) {
	            ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "������", "�� �� ���������� � ������ ���. ������������� ����������.", "�������", "");
				return;
	        }
	        //activity
	    }
        //�������� ������� �����
	    case 2689:
	    {
	        if (!IsBattleBegins) {
	            ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "������", "�� �� ���������� � ������ ���. ������������� ����������.", "�������", "");
				return;
	        }
			SetPlayerEffect(playerid, EFFECT_SHAZOK_GEAR, 10, FindEffectSlot(playerid));
	    }
	    //������ ����
	    case 2411:
	    {
	        if (!IsBattleBegins) {
	            ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "������", "�� �� ���������� � ������ ���. ������������� ����������.", "�������", "");
				return;
	        }
			SetPlayerEffect(playerid, EFFECT_LUSI_APRON, 6, FindEffectSlot(playerid));
	    }
	    //����� ���������
	    case 1252:
	    {
	        if (!IsBattleBegins) {
	            ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "������", "�� �� ���������� � ������ ���. ������������� ����������.", "�������", "");
				return;
	        }
	        //activity
	    }
	    //�������� � ����
	    case 19883:
	    {
	        if (!IsBattleBegins) {
	            ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "������", "�� �� ���������� � ������ ���. ������������� ����������.", "�������", "");
				return;
	        }
	        //activity
	    }
	    //��������� ������
	    case 1944:
	    {
	        if (!IsBattleBegins) {
	            ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "������", "�� �� ���������� � ������ ���. ������������� ����������.", "�������", "");
				return;
	        }
	        //activity
	    }
	    case 2710:
	    {
	        if (GetInvEmptySlots(playerid) == 0) {
	            ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "������", "���������� ������������ �������: ��������� �����.", "�������", "");
                return;
	        }
	        new rnd = random(100);
	        switch (rnd) {
	            case 0..55:
	            {
					if (PlayerInfo[playerid][Sex] == 0)
	                	AddItem(playerid, 287, 1);
					else
					    AddItem(playerid, 191, 1);
                    ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "{a64d79}������ ������", "{ffffff}�� ��������: [{a64d79}������� �����{ffffff}].", "�������", "");
	            }
	            case 56..70:
	            {
					if (PlayerInfo[playerid][Sex] == 0)
	                	AddItem(playerid, 161, 1);
					else
					    AddItem(playerid, 198, 1);
                    ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "{a64d79}������ ������", "{ffffff}�� ��������: [{a64d79}������ �������{ffffff}].", "�������", "");
	            }
	            case 71..82:
	            {
					if (PlayerInfo[playerid][Sex] == 0)
	                	AddItem(playerid, 97, 1);
					else
					    AddItem(playerid, 140, 1);
                    ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "{a64d79}������ ������", "{ffffff}�� ��������: [{a64d79}��������� ������{ffffff}].", "�������", "");
	            }
	            case 83..89:
	            {
					if (PlayerInfo[playerid][Sex] == 0)
	                	AddItem(playerid, 114, 1);
					else
					    AddItem(playerid, 195, 1);
                    ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "{a64d79}������ ������", "{ffffff}�� ��������: [{a64d79}������ '����� ������'{ffffff}].", "�������", "");
	            }
	            case 90..94:
	            {
					if (PlayerInfo[playerid][Sex] == 0)
	                	AddItem(playerid, 204, 1);
					else
					    AddItem(playerid, 298, 1);
                    ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "{a64d79}������ ������", "{ffffff}�� ��������: [{a64d79}������ ������� ������ ��������{ffffff}].", "�������", "");
	            }
	            case 95..97:
	            {
					if (PlayerInfo[playerid][Sex] == 0)
	                	AddItem(playerid, 127, 1);
					else
					    AddItem(playerid, 169, 1);
                    ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "{a64d79}������ ������", "{ffffff}�� ��������: [{a64d79}������ ������ ���� �����{ffffff}].", "�������", "");
	            }
	            default:
	            {
					if (PlayerInfo[playerid][Sex] == 0)
	                	AddItem(playerid, 147, 1);
					else
					    AddItem(playerid, 150, 1);
                    ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "{a64d79}������ ������", "{ffffff}�� ��������: [{a64d79}������ '����'{ffffff}].", "�������", "");
	            }
	        }
	        PlayerInfo[playerid][InventoryCount][slot]--;
	        if (PlayerInfo[playerid][InventoryCount][slot] <= 0) {
	            PlayerInfo[playerid][InventoryCount][slot] = 0;
	            PlayerInfo[playerid][Inventory][slot] = 0;
	        }
	        UpdateSlot(playerid, slot);
	    }
	}
}
//�������� ��������� � ������������ � �������
stock UpdateCharacter(playerid)
{
	switch (PlayerInfo[playerid][Class]) {
	    case 0:
	    {
	        GivePlayerWeapon(playerid, 8, 1);
	    }
	    case 1:
	    {
	        GivePlayerWeapon(playerid, 33, 100000);
	        SetPlayerAttachedObject(playerid,3,363,4,0.015000,0.127999,0.019000,115.300048,-95.399864,0.600000,0.572999,0.606999,0.613000);
			SetPlayerAttachedObject(playerid,4,342,7,0.121000,0.007000,-0.167000,-2.200000,-99.100006,0.000000,1.203999,1.071999,1.096000);
	    }
	    case 2:
	    {
	        GivePlayerWeapon(playerid, 1, 1);
	        SetPlayerAttachedObject(playerid,0,331,5,0.041999,-0.014999,-0.030000,0.000000,0.000000,0.000000,1.000000,1.000000,1.000000);
			SetPlayerAttachedObject(playerid,1,18699,6,-1.827999,-0.049000,-0.470999,0.000000,76.099990,-0.900001,1.000000,1.000000,1.223000);
			SetPlayerAttachedObject(playerid,2,18699,5,-2.509998,-0.056998,-0.145999,-1.899993,86.999679,-1.600000,1.000000,1.000000,1.657000);
			SetPlayerAttachedObject(playerid,3,18704,11,-1.743998,0.071000,-0.170000,0.000000,85.799987,0.000000,0.185000,1.293000,1.261000);
			SetPlayerAttachedObject(playerid,4,18704,12,-2.188002,0.045999,0.215000,0.000000,95.900070,0.000000,0.337999,0.457999,1.513999);
	    }
	    case 3:
	    {
	        SetPlayerAttachedObject(playerid,0,19591,1,-0.054999,-0.162000,-0.032000,-8.399995,88.999908,4.499998,0.939999,0.836999,1.021999);
			SetPlayerAttachedObject(playerid,1,1254,1,0.000000,0.000000,0.620000,0.000000,89.800010,0.000000,0.591000,0.442000,0.653000);
			SetPlayerAttachedObject(playerid,2,1254,1,0.054999,0.000000,-0.632001,0.000000,88.199966,0.000000,0.595000,0.507999,0.636000);
			SetPlayerAttachedObject(playerid,3,18693,5,1.076000,-0.008999,0.083999,0.000000,-94.399932,0.000000,0.526999,0.602999,0.596999);
			SetPlayerAttachedObject(playerid,4,18701,1,0.205002,0.004999,0.625000,0.000000,-91.799919,0.000000,1.000000,1.000000,0.178000);
			SetPlayerAttachedObject(playerid,5,18701,1,0.230000,0.014000,-0.624000,0.000000,-93.599960,0.000000,1.000000,1.000000,0.157999);
	    }
	    case 4:
		{
		    GivePlayerWeapon(playerid, 4, 1);
		    SetPlayerAttachedObject(playerid,3,18912,2,0.082000,0.009999,0.004999,-91.100120,12.099998,-91.600090,1.099000,1.029000,1.140002);
		}
		case 5:
		{
		    SetPlayerAttachedObject(playerid,0,19528,2,0.145000,0.000000,0.000000,-0.299998,-1.900013,-22.799934,1.000000,1.000000,1.000000);
			SetPlayerAttachedObject(playerid,1,19078,4,-0.009000,0.057999,0.046999,-153.999969,-160.700210,-11.299998,0.579000,1.000000,0.688999);
			SetPlayerAttachedObject(playerid,2,1598,6,0.086999,0.044000,0.012000,0.000000,0.000000,0.000000,0.219000,0.193000,0.183000);
			SetPlayerAttachedObject(playerid,3,18700,5,0.109000,0.129999,-1.676997,0.000000,0.000000,0.000000,0.475000,0.720999,0.996999);
		}
	}
	SetPlayerParams(playerid);
}
//�������� ���� � ��������� ��������
stock GetSelectedItemInfo(playerid)
{
	new info[1024];
    switch (PlayerInfo[playerid][Inventory][SelectedSlot[playerid]]) {
		//�������
        case 1242:
        {
			info = "{999999}������������� ����\n________________________________________\n";
			strcat(info, "������� �������\n\n{ffffff}����������� �������: {666666}������\n{ffffff}������� ���������:\n  �������� ������\n  �������� ��������� ���������\n������� �������������: �� ����� ���\n\n{76a5af}��������� ������ � ���� �� ����� �����.");
        }
        case 336:
        {
			info = "{999999}����������� ����\n__________________________________________________________________\n";
			strcat(info, "������� �������\n\n{ffffff}����������� �������: {85200c}������\n{ffffff}������� ���������:\n  Circus 24/7\n������� �������������: ��� ������ ���\n\n{76a5af}��������� ������� ������ � ������� 5 �. � ������ 30%.\n��� ������ �������� � ������ �� 10 �� 75$,\n��� ������� ��������� ����� ��� ������ � ��������� �� 10 �� 30$,\n� ���� ����� �� ������� �� �������� ������� �� 10.");
        }
        case 1221:
        {
			info = "{999999}���������� ������\n_______________________________________________\n";
			strcat(info, "������� �������\n\n{ffffff}����������� �������: {85200c}������\n{ffffff}������� ���������:\n  ������� �� ������\n  ������� �� �������\n������� �������������: ��� ������ ���\n\n{76a5af}��������� � ��������� ������ �������� ��������:\n\n {00CC00}100$");
        }
        case 1224:
        {
			info = "{999999}�������� ������\n_______________________________________________\n";
			strcat(info, "������� �������\n\n{ffffff}����������� �������: {666666}������\n{ffffff}������� ���������:\n  ������� �� ������\n  ������� �� �������\n������� �������������: ��� ������ ���\n\n{76a5af}��������� � ��������� ������ �������� ��������:\n\n {00CC00}200$\n {999999}������������� ���� 1-2 ��.");
        }
		//������������
		case 19577:
        {
			info = "{21aa18}������� ���\n_________________________________________________________\n";
			strcat(info, "������������ �������\n\n{ffffff}����������� �������: {4c1130}������\n{ffffff}������� ���������:\n  �������� ������\n  �������� ��������� ���������\n������� �������������: �� ����� ���\n\n{76a5af}� ������ 50% ��������� �� 10 ��� ����� ��������� ������.");
        }
        case 2726:
        {
			info = "{21aa18}��������� ���������\n______________________________________\n";
			strcat(info, "������������ �������\n\n{ffffff}����������� �������: {a61c00}������\n{ffffff}������� ���������:\n  ��������� ������\n  �������� ��������� ���������\n������� �������������: �� ����� ���\n\n{76a5af}������������ ����.");
        }
        case 19893:
        {
			info = "{21aa18}�������\n_______________________________________\n";
			strcat(info, "������������ �������\n\n{ffffff}����������� �������: {85200c}������\n{ffffff}������� ���������:\n  Circus 24/7\n������� �������������: ��� ������ ���\n\n{76a5af}��������� ����������� �������\n�������� ������� ������� ������.");
        }
        case 19572:
        {
			info = "{21aa18}�������� ������\n_______________________________________________\n";
			strcat(info, "������������ �������\n\n{ffffff}����������� �������: {4c1130}������\n{ffffff}������� ���������:\n  ������� �� ������\n  ������� �� �������\n������� �������������: ��� ������ ���\n\n{76a5af}��������� � ��������� ������ �������� ��������:\n\n {00CC00}300$\n {21aa18}������� ��� 1-2 ��.");
        }
        case 19918:
        {
			info = "{21aa18}��������� ������\n_______________________________________________\n";
			strcat(info, "������������ �������\n\n{ffffff}����������� �������: {a61c00}������\n{ffffff}������� ���������:\n  ������� �� ������\n  ������� �� �������\n������� �������������: ��� ������ ���\n\n{76a5af}��������� � ��������� ������ �������� ��������:\n\n {00CC00}400$\n {21aa18}��������� ��������� 1-2 ��.");
        }
		//�����������
		case 2689:
        {
			info = "{379be3}�������� ������� �����\n_____________________________________________\n";
			strcat(info, "����������� �������\n\n{ffffff}����������� �������: {999999}�������\n{ffffff}������� ���������:\n  ���������� ������\n  �������� ��������� ���������\n������� �������������: �� ����� ���\n\n{76a5af}��������� ������������� ������������� ������\n�������� ������ ������. ��������� 10 ���.");
        }
        case 2411:
        {
			info = "{379be3}������ ����\n_____________________________________________\n";
			strcat(info, "����������� �������\n\n{ffffff}����������� �������: {bf9000}������\n{ffffff}������� ���������:\n  ������� ������\n  �������� ��������� ���������\n������� �������������: �� ����� ���\n\n{76a5af}��������� ������������� ������������� ������\n������ ������ ������. ��������� 6 ���.");
        }
        case 19054:
        {
			info = "{379be3}���������� ������\n_______________________________________________\n";
			strcat(info, "����������� �������\n\n{ffffff}����������� �������: {999999}�������\n{ffffff}������� ���������:\n  ������� �� ������\n  ������� �� �������\n������� �������������: ��� ������ ���\n\n{76a5af}��������� � ��������� ������ �������� ��������:\n\n {00CC00}500$\n {379be3}�������� ������� ����� 1-2 ��.");
        }
        case 19055:
        {
			info = "{379be3}������� ������\n_______________________________________________\n";
			strcat(info, "����������� �������\n\n{ffffff}����������� �������: {bf9000}������\n{ffffff}������� ���������:\n  ������� �� ������\n  ������� �� �������\n������� �������������: ��� ������ ���\n\n{76a5af}��������� � ��������� ������ �������� ��������:\n\n {00CC00}600$\n {379be3}������ ���� 1-2 ��.");
        }
        //������
        case 1252:
        {
			info = "{cc0000}����� ���������\n_______________________________________________\n";
			strcat(info, "������ �������\n\n{ffffff}����������� �������: {b7b7b7}�������\n{ffffff}������� ���������:\n  ���������� ������\n  �������� ��������� ���������\n������� �������������: �� ����� ���\n\n{76a5af}��������� 5 ��� � ������ ���� ������ ���������.");
        }
        case 1581:
        {
			info = "{cc0000}������������ �����\n_________________________________________________________________\n";
			strcat(info, "������ �������\n\n{ffffff}����������� �������: {85200c}������\n{ffffff}������� ���������:\n  Circus 24/7\n������� �������������: ���������\n\n{76a5af}����� ������������ ��������� �� ������� ��� ����������� �� ����.\n��������� 1 ������.");
        }
        case 19057:
        {
			info = "{cc0000}���������� ������\n_______________________________________________\n";
			strcat(info, "������ �������\n\n{ffffff}����������� �������: {b7b7b7}�������\n{ffffff}������� ���������:\n  ������� �� ������\n  ������� �� �������\n������� �������������: ��� ������ ���\n\n{76a5af}��������� � ��������� ������ �������� ��������:\n\n {00CC00}700$\n {cc0000}����� ��������� 1-2 ��.");
        }
        //���������
        case 19883:
        {
			info = "{8200d9}�������� � ����\n_______________________________________________________________________\n";
			strcat(info, "��������� �������\n\n{ffffff}����������� �������: {76a5af}�����\n{ffffff}������� ���������:\n  �������� ������\n  �������� ��������� ���������\n������� �������������: �� ����� ���\n\n{76a5af}���������� ���-�������� � � ������� 10 ���. ��������� �� ������� ������.");
        }
        case 19058:
        {
			info = "{8200d9}�������� ������\n_______________________________________________\n";
			strcat(info, "��������� �������\n\n{ffffff}����������� �������: {76a5af}�����\n{ffffff}������� ���������:\n  ������� �� ������\n  ������� �� �������\n������� �������������: ��� ������ ���\n\n{76a5af}��������� � ��������� ������ �������� ��������:\n\n {00CC00}800$\n {8200d9}�������� � ���� 1-2 ��.");
        }
		//�����������
		case 1944:
        {
			info = "{e38614}��������� ������\n_____________________________________________\n";
			strcat(info, "����������� �������\n\n{ffffff}����������� �������: {6d9eeb}���������\n{ffffff}������� ���������:\n  ������������� ������\n  �������� ��������� ���������\n������� �������������: �� ����� ���\n\n{76a5af}� ������� 3 ������ ������ �������\n���������� ����� ����������� ���� ������.");
        }
        case 2684:
        {                                                                                                                                                                                                     
			info = "{e38614}�������� �����\n__________________________________________________________________________\n";
			strcat(info, "����������� �������\n\n{ffffff}����������� �������: {85200c}������\n{ffffff}������� ���������:\n  Circus 24/7\n������� �������������: ���������\n\n{76a5af}��������� ����������� ��������, ��������� ��� ��������� ������� ��������.\n��������� 1 ������.");
        }
        case 19056:
        {
			info = "{e38614}������������� ������\n_______________________________________________\n";
			strcat(info, "����������� �������\n\n{ffffff}����������� �������: {6d9eeb}���������\n{ffffff}������� ���������:\n  ������� �� ������\n  ������� �� �������\n������� �������������: ��� ������ ���\n\n{76a5af}��������� � ��������� ������ �������� ��������:\n\n {00CC00}900$\n {e38614}��������� ������ 1-2 ��.");
        }
        //�������
        case 83,91:
        {
			info = "{a64d79}������ ��������\n\n{ffffff}���: �������, �������\n\n{76a5af}������, ���������� ������ ����� �������������� ������.";
        }
        case 84,214:
        {
			info = "{a64d79}������ '���'\n\n{ffffff}���: �������, �������\n\n{76a5af}���� ������ ����� ���, ��� ������ ���� ���� ������.";
        }
        case 120,141:
        {
			info = "{a64d79}������ '�������'\n\n{ffffff}���: �������, �������\n\n{76a5af}����� ���������� ������. �������� ���� ���������� ������ ���.";
        }
        case 264,152:
        {
			info = "{a64d79}������ ������\n\n{ffffff}���: �������, �������\n\n{76a5af}������ � ���������� �����. �� ������ ������� ������ ���.";
        }
        case 147,150:
        {
			info = "{a64d79}������ '����'\n\n{ffffff}���: �������, �������\n\n{76a5af}���, ��� ������� ����� ������, ������� ���� �������.";
        }
        case 127,169:
        {
			info = "{a64d79}������ ������ ���� �����\n\n{ffffff}���: �������, �������\n\n{76a5af}��� ����� ��� ������ ����������� ������������ ������ ����� �������.";
        }
        case 204,298:
        {
			info = "{a64d79}������ ������� ������ ��������\n\n{ffffff}���: �������, �������\n\n{76a5af}���� ���������� ������ � ����� ������.";
        }
        case 114,195:
        {
			info = "{a64d79}������ '����� ������'\n\n{ffffff}���: �������, �������\n\n{76a5af}���, ��� ����� ��� ������, ����������� � �������.";
        }
        case 97,140:
        {
			info = "{a64d79}��������� ������\n\n{ffffff}���: �������, �������\n\n{76a5af}������ ������ ������.";
        }
        case 161,198:
        {
			info = "{a64d79}������ �������\n\n{ffffff}���: �������, �������\n\n{76a5af}�������� ������������ ������ ������ ����� ������.";
        }
        case 287,191:
        {
			info = "{a64d79}������� �����\n\n{ffffff}���: �������, �������\n\n{76a5af}������ �� � �����!";
        }
        case 296:
        {
			info = "{a64d79}������ ���\n\n{ffffff}���: �������\n\n{76a5af}����������� ��� �������� ����.\n���� ������� ��� ����� ����� ������.";
        }
        case 2710:
        {
            info = "{a64d79}������ ������\n_______________________________________________\n";
			strcat(info, "������� �������\n\n{ffffff}����������� �������: {bf9000}������\n{ffffff}������� ���������:\n  �������� ��������� ���������\n������� �������������: ��� ������ ���\n\n{76a5af}��������� � ��������� ������ �������� ��������:\n\n{a64d79}������ '����'\n������ ������ ���� �����\n������ ������� ������ ��������\n������ '����� ������'\n");
			strcat(info, "{a64d79}��������� ������\n������ �������\n������� �����\n������ ���");
        }
    }
    return info;
}
//���������� ��������� ���� ��� ���������
stock SetSlotSelection(playerid, slot, bool:selection)
{
	if (selection) {
		switch (PlayerInfo[playerid][Inventory][slot]) {
		    case 19577, 2726, 19893, 19572, 19918:
		    {
		        PlayerTextDrawBackgroundColor(playerid, InvSlot[playerid][slot], 0x21aa1833);
		    }
		    case 2689, 2411, 19054, 19055:
		    {
		        PlayerTextDrawBackgroundColor(playerid, InvSlot[playerid][slot], 0x379be333);
		    }
		    case 1252, 1581, 19057:
		    {
		        PlayerTextDrawBackgroundColor(playerid, InvSlot[playerid][slot], 0xcc000033);
		    }
		    case 19883, 19058:
		    {
		        PlayerTextDrawBackgroundColor(playerid, InvSlot[playerid][slot], 0x8200d933);
		    }
		    case 1944, 2684, 19056:
		    {
		        PlayerTextDrawBackgroundColor(playerid, InvSlot[playerid][slot], 0xe3861433);
		    }
		    case 83,91,84,214,120,141,264,152,147,150,127,169,204,298,114,195,97,140,161,198,287,191,296,2710:
		    {
		        PlayerTextDrawBackgroundColor(playerid, InvSlot[playerid][slot], 0xa64d7933);
		    }
		    default:
		    {
		        PlayerTextDrawBackgroundColor(playerid, InvSlot[playerid][slot], 0x999999AA);
		    }
		}
	}
	else {
	    switch (PlayerInfo[playerid][Inventory][slot]) {
		    case 19577, 2726, 19893, 19572, 19918:
		    {
		        PlayerTextDrawBackgroundColor(playerid, InvSlot[playerid][slot], 0x21aa1866);
		    }
		    case 2689, 2411, 19054, 19055:
		    {
		        PlayerTextDrawBackgroundColor(playerid, InvSlot[playerid][slot], 0x379be366);
		    }
		    case 1252, 1581, 19057:
		    {
		        PlayerTextDrawBackgroundColor(playerid, InvSlot[playerid][slot], 0xcc000066);
		    }
		    case 19883, 19058:
		    {
		        PlayerTextDrawBackgroundColor(playerid, InvSlot[playerid][slot], 0x8200d966);
		    }
		    case 1944, 2684, 19056:
		    {
		        PlayerTextDrawBackgroundColor(playerid, InvSlot[playerid][slot], 0xe3861477);
		    }
		    case 83,91,84,214,120,141,264,152,147,150,127,169,204,298,114,195,97,140,161,198,287,191,296,2710:
		    {
		        PlayerTextDrawBackgroundColor(playerid, InvSlot[playerid][slot], 0xa64d7966);
		    }
            default:
		    {
		        PlayerTextDrawBackgroundColor(playerid, InvSlot[playerid][slot], -1061109505);
		    }
		}
	}
	PlayerTextDrawHide(playerid, InvSlot[playerid][slot]);
	PlayerTextDrawShow(playerid, InvSlot[playerid][slot]);
}

//�������� ���������
stock GetInvEmptySlots(playerid)
{
	new count = 0;
	for (new i = 0; i < MAX_SLOTS; i++) {
	    if (PlayerInfo[playerid][Inventory][i] == 0)
			count++;
	}
	return count;
}

//�������� ������ ��������� ������
stock GetFirstEmptySlot(playerid)
{
	new slot = -1;
	for (new i = 0; i < MAX_SLOTS; i++) {
	    if (PlayerInfo[playerid][Inventory][i] == 0) {
	        slot = i;
	        break;
	    }
	}
	return slot;
}

//�������� ������ ��������
stock GetItemSlot(playerid, item)
{
    new slot = -1;
	for (new i = 0; i < MAX_SLOTS; i++) {
	    if (PlayerInfo[playerid][Inventory][i] == item) {
	        slot = i;
	        break;
	    }
	}
	return slot;
}

//���������� �������� � ���������
stock AddItem(playerid, item, count)
{
    new slot;
	switch (item) {
	    case 83,91,84,214,120,141,264,152,147,150,127,169,204,298,114,195,97,140,161,198,287,191,296:
	    {
	        slot = GetFirstEmptySlot(playerid);
	    }
	    default:
	    {
	        slot = GetItemSlot(playerid, item);
			if (slot == -1)
			    slot = GetFirstEmptySlot(playerid);
	    }
	}
    if (slot == -1) {
        SendClientMessage(playerid, COLOR_LIGHTRED, "������ ��� ���������� ��������: ��������� �����.");
        return -1;
    }
    PlayerInfo[playerid][Inventory][slot] = item;
    PlayerInfo[playerid][InventoryCount][slot] += count;
    UpdateSlot(playerid, slot);
    return slot;
}

//�������� ���������� �������� �� ���������
stock DeleteSelectedItem(playerid)
{
	if (SelectedSlot[playerid] == -1) return;
    PlayerInfo[playerid][Inventory][SelectedSlot[playerid]] = 0;
    PlayerInfo[playerid][InventoryCount][SelectedSlot[playerid]] = 0;
    new oldslot = SelectedSlot[playerid];
    SelectedSlot[playerid] = -1;
    UpdateSlot(playerid, oldslot);
}

//������ ������� �������� � ���������
stock IsPlayerHaveItem(playerid, itemid, count)
{
	for (new i = 0; i < MAX_SLOTS; i++)
	    if (PlayerInfo[playerid][Inventory][i] == itemid)
	        if (PlayerInfo[playerid][InventoryCount][i] >= count)
	            return true;
	return false;
}

//���������� ��
stock SetPlayerHealthEx(playerid, Float:health)
{
	SetPlayerHealth(playerid, health);
    UpdateHPBar(playerid);
}

//�������� hpbar
stock UpdateHPBar(playerid)
{
	new Float:hp;
	GetPlayerHealth(playerid, hp);
	new percents = floatround(hp);
	new string[64];
	format(string, sizeof(string), "%d%% %d/%d", percents, floatround(floatmul(hp, 100)), 10000);
	PlayerTextDrawSetString(playerid, HPBar[playerid], string);
}

//�������� ������ ���������
stock UpdateSlot(playerid, slot)
{
	if (!IsInventoryOpen[playerid]) return;
    PlayerTextDrawHide(playerid, InvSlot[playerid][slot]);
    PlayerTextDrawHide(playerid, InvSlotCount[playerid][slot]);
    if (PlayerInfo[playerid][Inventory][slot] == 0) {
	    SetInvModel(playerid, slot);
	    PlayerTextDrawShow(playerid, InvSlot[playerid][slot]);
	    return;
	}
    new string[16];
    format(string, sizeof(string), "%d", PlayerInfo[playerid][InventoryCount][slot]);
    PlayerTextDrawSetString(playerid, InvSlotCount[playerid][slot], string);
    SetInvModel(playerid, slot);
    PlayerTextDrawShow(playerid, InvSlot[playerid][slot]);
    PlayerTextDrawShow(playerid, InvSlotCount[playerid][slot]);
}

//���������� ������ ������ ���������
stock SetInvModel(playerid, slot)
{
    SetSlotSelection(playerid, slot, SelectedSlot[playerid] == slot);
	if (PlayerInfo[playerid][Inventory][slot] == 0) {
	    PlayerTextDrawSetPreviewRot(playerid, InvSlot[playerid][slot], 0, 0, 0, -1);
	    PlayerTextDrawSetPreviewModel(playerid, InvSlot[playerid][slot], -1);
	    return;
	}
    PlayerTextDrawSetPreviewModel(playerid, InvSlot[playerid][slot], PlayerInfo[playerid][Inventory][slot]);
	switch (PlayerInfo[playerid][Inventory][slot]) {
	    case 336, 1221, 1224, 19577:
	    {
			PlayerTextDrawSetPreviewRot(playerid, InvSlot[playerid][slot], 45.0, 30.0, 0.0, 1.0);
	    }
	    case 19893, 1581:
	    {
            PlayerTextDrawSetPreviewRot(playerid, InvSlot[playerid][slot], 0.0, 0.0, 180.0, 1.0);
	    }
	    case 19572, 19918:
	    {
            PlayerTextDrawSetPreviewRot(playerid, InvSlot[playerid][slot], 45.0, 0.0, 0.0, 1.0);
	    }
	    case 19054..19058:
	    {
            PlayerTextDrawSetPreviewRot(playerid, InvSlot[playerid][slot], 330.0, 0.0, 0.0, 1.0);
	    }
	    case 19883:
	    {
            PlayerTextDrawSetPreviewRot(playerid, InvSlot[playerid][slot], 90.0, 0.0, 0.0, 1.0);
	    }
        case 2710:
	    {
            PlayerTextDrawSetPreviewRot(playerid, InvSlot[playerid][slot], 0.0, 0.0, 90.0, 1.0);
	    }
	    default:
	    {
            PlayerTextDrawSetPreviewRot(playerid, InvSlot[playerid][slot], 0.0, 0.0, 0.0, 1.0);
	    }
	}	
}

//�������� ������ �������
stock ShowSkillPanel(playerid)
{
    switch (PlayerInfo[playerid][Class]) {
	    case 0:
	    {
	        PlayerTextDrawSetPreviewModel(playerid, SkillIco[playerid][0], 13646);
	        PlayerTextDrawSetPreviewRot(playerid, SkillIco[playerid][0], 90, 0, 0, 1);

	        PlayerTextDrawSetPreviewModel(playerid, SkillIco[playerid][1], 2916);
	        PlayerTextDrawSetPreviewRot(playerid, SkillIco[playerid][1], 0, 0, 0, 1);

	        PlayerTextDrawSetPreviewModel(playerid, SkillIco[playerid][2], 19590);
	        PlayerTextDrawSetPreviewRot(playerid, SkillIco[playerid][2], 0, 90, 90, 1);

	        PlayerTextDrawSetPreviewModel(playerid, SkillIco[playerid][3], 19134);
	        PlayerTextDrawSetPreviewRot(playerid, SkillIco[playerid][3], 0, 0, 90, 1);

	        PlayerTextDrawSetPreviewModel(playerid, SkillIco[playerid][4], 1634);
	        PlayerTextDrawSetPreviewRot(playerid, SkillIco[playerid][4], 330, 0, 180, 1);
	    }
	    case 1:
	    {
            PlayerTextDrawSetPreviewModel(playerid, SkillIco[playerid][0], 2619);
	        PlayerTextDrawSetPreviewRot(playerid, SkillIco[playerid][0], 0, 0, 0, 1);

	        PlayerTextDrawSetPreviewModel(playerid, SkillIco[playerid][1], 9525);
	        PlayerTextDrawSetPreviewRot(playerid, SkillIco[playerid][1], 0, 0, 0, 1);

	        PlayerTextDrawSetPreviewModel(playerid, SkillIco[playerid][2], 2035);
	        PlayerTextDrawSetPreviewRot(playerid, SkillIco[playerid][2], 90, 0, 0, 1);

	        PlayerTextDrawSetPreviewModel(playerid, SkillIco[playerid][3], 1252);
	        PlayerTextDrawSetPreviewRot(playerid, SkillIco[playerid][3], 0, 0, 0, 1);

	        PlayerTextDrawSetPreviewModel(playerid, SkillIco[playerid][4], 3056);
	        PlayerTextDrawSetPreviewRot(playerid, SkillIco[playerid][4], 0, 0, 90, 1);
	    }
	    case 2:
	    {
            PlayerTextDrawSetPreviewModel(playerid, SkillIco[playerid][0], 2051);
	        PlayerTextDrawSetPreviewRot(playerid, SkillIco[playerid][0], 0, 0, 0, 1);

	        PlayerTextDrawSetPreviewModel(playerid, SkillIco[playerid][1], 14467);
	        PlayerTextDrawSetPreviewRot(playerid, SkillIco[playerid][1], 0, 0, 0, 1);

	        PlayerTextDrawSetPreviewModel(playerid, SkillIco[playerid][2], 1976);
	        PlayerTextDrawSetPreviewRot(playerid, SkillIco[playerid][2], 0, 0, 0, 1);

	        PlayerTextDrawSetPreviewModel(playerid, SkillIco[playerid][3], 1975);
	        PlayerTextDrawSetPreviewRot(playerid, SkillIco[playerid][3], 0, 0, 0, 1);

	        PlayerTextDrawSetPreviewModel(playerid, SkillIco[playerid][4], 10281);
	        PlayerTextDrawSetPreviewRot(playerid, SkillIco[playerid][4], 0, 0, 0, 1);
	    }
	    case 3:
	    {
            PlayerTextDrawSetPreviewModel(playerid, SkillIco[playerid][0], 19591);
	        PlayerTextDrawSetPreviewRot(playerid, SkillIco[playerid][0], 0, 0, 0, 1);

	        PlayerTextDrawSetPreviewModel(playerid, SkillIco[playerid][1], 11735);
	        PlayerTextDrawSetPreviewRot(playerid, SkillIco[playerid][1], 0, 0, 90, 1);

	        PlayerTextDrawSetPreviewModel(playerid, SkillIco[playerid][2], 2049);
	        PlayerTextDrawSetPreviewRot(playerid, SkillIco[playerid][2], 0, 0, 0, 1);

	        PlayerTextDrawSetPreviewModel(playerid, SkillIco[playerid][3], 18646);
	        PlayerTextDrawSetPreviewRot(playerid, SkillIco[playerid][3], 0, 0, 0, 1);

	        PlayerTextDrawSetPreviewModel(playerid, SkillIco[playerid][4], 1247);
	        PlayerTextDrawSetPreviewRot(playerid, SkillIco[playerid][4], 0, 0, 0, 1);
	    }
	    case 4:
	    {
            PlayerTextDrawSetPreviewModel(playerid, SkillIco[playerid][0], 2050);
	        PlayerTextDrawSetPreviewRot(playerid, SkillIco[playerid][0], 0, 0, 0, 1);

	        PlayerTextDrawSetPreviewModel(playerid, SkillIco[playerid][1], 1313);
	        PlayerTextDrawSetPreviewRot(playerid, SkillIco[playerid][1], 0, 0, 0, 1);

	        PlayerTextDrawSetPreviewModel(playerid, SkillIco[playerid][2], 1314);
	        PlayerTextDrawSetPreviewRot(playerid, SkillIco[playerid][2], 0, 0, 0, 1);

	        PlayerTextDrawSetPreviewModel(playerid, SkillIco[playerid][3], 14467);
	        PlayerTextDrawSetPreviewRot(playerid, SkillIco[playerid][3], 0, 0, 0, 1);

	        PlayerTextDrawSetPreviewModel(playerid, SkillIco[playerid][4], 3082);
	        PlayerTextDrawSetPreviewRot(playerid, SkillIco[playerid][4], 0, 0, 0, 1);
	    }
	    case 5:
	    {
            PlayerTextDrawSetPreviewModel(playerid, SkillIco[playerid][0], 2025);
	        PlayerTextDrawSetPreviewRot(playerid, SkillIco[playerid][0], 0, 0, 0, 1);

	        PlayerTextDrawSetPreviewModel(playerid, SkillIco[playerid][1], 11735);
	        PlayerTextDrawSetPreviewRot(playerid, SkillIco[playerid][1], 0, 0, 90, 1);

	        PlayerTextDrawSetPreviewModel(playerid, SkillIco[playerid][2], 1314);
	        PlayerTextDrawSetPreviewRot(playerid, SkillIco[playerid][2], 0, 0, 0, 1);

	        PlayerTextDrawSetPreviewModel(playerid, SkillIco[playerid][3], 3092);
	        PlayerTextDrawSetPreviewRot(playerid, SkillIco[playerid][3], 0, 0, 180, 1);

	        PlayerTextDrawSetPreviewModel(playerid, SkillIco[playerid][4], 19345);
	        PlayerTextDrawSetPreviewRot(playerid, SkillIco[playerid][4], 90, 0, 0, 1);
	    }
		default: return;
	}
	for (new i = 0; i < MAX_SKILLS; i++) {
	    PlayerTextDrawShow(playerid, SkillIco[playerid][i]);
	    PlayerTextDrawShow(playerid, SkillButton[playerid][i]);
	    if (PlayerInfo[playerid][SkillCooldown][i] > 0) {
	        new cooldown[16];
	        format(cooldown, sizeof(cooldown), "%d", PlayerInfo[playerid][SkillCooldown][i]);
	        PlayerTextDrawSetString(playerid, SkillTime[playerid][i], cooldown);
	        PlayerTextDrawShow(playerid, SkillTime[playerid][i]);
	    }
	}
}

//�������� ���������
stock ShowInterface(playerid)
{
    PlayerTextDrawShow(playerid, HPBar[playerid]);
    PlayerTextDrawShow(playerid, PanelBox[playerid]);
    PlayerTextDrawShow(playerid, PanelInfo[playerid]);
	PlayerTextDrawShow(playerid, PanelInventory[playerid]);
	PlayerTextDrawShow(playerid, PanelUndress[playerid]);
	PlayerTextDrawShow(playerid, PanelSwitch[playerid]);
	PlayerTextDrawShow(playerid, PanelDelimeter1[playerid]);
	PlayerTextDrawShow(playerid, PanelDelimeter2[playerid]);
	PlayerTextDrawShow(playerid, PanelDelimeter3[playerid]);
	ShowSkillPanel(playerid);
}

//�������� ��������� ���
stock ShowMatchInterface(playerid)
{
	PlayerTextDrawShow(playerid, TourScoreBar[playerid]);
    PlayerTextDrawShow(playerid, TourPanelBox[playerid]);
    PlayerTextDrawShow(playerid, TourPlayerName1[playerid]);
	PlayerTextDrawShow(playerid, TourPlayerName2[playerid]);
	PlayerTextDrawShow(playerid, blue_flag[playerid]);
	PlayerTextDrawShow(playerid, red_flag[playerid]);
	PlayerTextDrawShow(playerid, MatchInfoBox[playerid]);
	PlayerTextDrawShow(playerid, MatchRoundInfo[playerid]);
	PlayerTextDrawShow(playerid, MatchRoundTime_Circle[playerid]);
	PlayerTextDrawShow(playerid, MatchRoundTime[playerid]);
	PlayerTextDrawShow(playerid, MatchBlueFlag[playerid]);
	PlayerTextDrawShow(playerid, MatchRedFlag[playerid]);
	PlayerTextDrawShow(playerid, MatchRank1[playerid]);
	PlayerTextDrawShow(playerid, MatchRank2[playerid]);
	PlayerTextDrawShow(playerid, MatchHPBar1[playerid]);
	PlayerTextDrawShow(playerid, MatchHPBar2[playerid]);
	PlayerTextDrawShow(playerid, MatchHPPercents1[playerid]);
	PlayerTextDrawShow(playerid, MatchHPPercents2[playerid]);
}

//�������� ���������
stock ShowInventory(playerid)
{
    SelectedSlot[playerid] = -1;
	PlayerTextDrawShow(playerid, InvBox[playerid]);
	for (new i = 0; i < MAX_SLOTS; i++) {
		PlayerTextDrawSetPreviewRot(playerid, InvSlot[playerid][i], 0.0, 0.0, 0.0, -1.0);
		PlayerTextDrawBackgroundColor(playerid, InvSlot[playerid][i], -1061109505);
		if (PlayerInfo[playerid][Inventory][i] != 0) {
			new string[16];
    		format(string, sizeof(string), "%d", PlayerInfo[playerid][InventoryCount][i]);
    		PlayerTextDrawSetString(playerid, InvSlotCount[playerid][i], string);
			PlayerTextDrawShow(playerid, InvSlotCount[playerid][i]);
			SetInvModel(playerid, i);
		}
		PlayerTextDrawShow(playerid, InvSlot[playerid][i]);
	}
	PlayerTextDrawShow(playerid, btn_use[playerid]);
	PlayerTextDrawShow(playerid, btn_del[playerid]);
	PlayerTextDrawShow(playerid, btn_quick[playerid]);
	PlayerTextDrawShow(playerid, btn_info[playerid]);
	PlayerTextDrawShow(playerid, inv_ico[playerid]);
}

//������ ���������
stock HideInventory(playerid)
{
	PlayerTextDrawHide(playerid, InvBox[playerid]);
	for (new i = 0; i < MAX_SLOTS; i++) {
		PlayerTextDrawHide(playerid, InvSlot[playerid][i]);
		PlayerTextDrawHide(playerid, InvSlotCount[playerid][i]);
	}
	PlayerTextDrawHide(playerid, btn_use[playerid]);
	PlayerTextDrawHide(playerid, btn_del[playerid]);
	PlayerTextDrawHide(playerid, btn_quick[playerid]);
	PlayerTextDrawHide(playerid, btn_info[playerid]);
	PlayerTextDrawHide(playerid, inv_ico[playerid]);
	SelectedSlot[playerid] = -1;
}

//��������� ������ ���������� ������
stock CreateVovakPlayersList() {
	new players[4000] = "���\t�����\t�������";
	new string[128];
	new data[512];
	new rate;
	new classid;
	for (new i = 0; i < 10; i++) {
		format(string, sizeof(string), "Players/%s.ini", VovakClowns[i]);
		new File = ini_openFile(string);
		if (File < 0) {
		    SendClientMessageToAll(COLOR_LIGHTRED, "������ ������������� ���� ������.");
		    players = "";
		    break;
		}
		ini_getInteger(File, "Rate", rate);
		ini_getInteger(File, "Class", classid);
		ini_closeFile(File);
		format(data, sizeof(data), "\n{%s}%s\t%s\t{%s}%d", GetColorByRate(rate), VovakClowns[i], GetClassNameByID(classid), GetColorByRate(rate), rate);
		strcat(players, data);
	}
	return players;
}

//��������� ������ ���������� ������
stock CreateDimakPlayersList() {
	new players[4000] = "���\t�����\t�������";
	new string[128];
	new data[512];
	new rate;
	new classid;
	for (new i = 0; i < 10; i++) {
		format(string, sizeof(string), "Players/%s.ini", DimakClowns[i]);
		new File = ini_openFile(string);
		if (File < 0) {
		    SendClientMessageToAll(COLOR_LIGHTRED, "������ ������������� ���� ������.");
		    players = "";
		    break;
		}
		ini_getInteger(File, "Rate", rate);
		ini_getInteger(File, "Class", classid);
		ini_closeFile(File);
		format(data, sizeof(data), "\n{%s}%s\t%s\t{%s}%d", GetColorByRate(rate), DimakClowns[i], GetClassNameByID(classid), GetColorByRate(rate), rate);
		strcat(players, data);
	}
	return players;
}

//��������� ������ ���������� ����
stock CreateTanyaPlayersList() {
	new players[4000] = "���\t�����\t�������";
	new string[128];
	new data[512];
	new rate;
	new classid;
	for (new i = 0; i < 10; i++) {
		format(string, sizeof(string), "Players/%s.ini", TanyaClowns[i]);
		new File = ini_openFile(string);
		if (File < 0) {
		    SendClientMessageToAll(COLOR_LIGHTRED, "������ ������������� ���� ������.");
		    players = "";
		    break;
		}
		ini_getInteger(File, "Rate", rate);
		ini_getInteger(File, "Class", classid);
		ini_closeFile(File);
		format(data, sizeof(data), "\n{%s}%s\t%s\t{%s}%d", GetColorByRate(rate), TanyaClowns[i], GetClassNameByID(classid), GetColorByRate(rate), rate);
		strcat(players, data);
	}
	return players;
}

//���������� ���� �� ��������
stock GetColorByRate(rate) {
	new color[16];
	switch (rate) {
	    case 501..1000: color = RateColors[1];
	    case 1001..1200: color = RateColors[2];
	    case 1201..1400: color = RateColors[3];
	    case 1401..1600: color = RateColors[4];
	    case 1601..2000: color = RateColors[5];
	    case 2001..2300: color = RateColors[6];
	    case 2301..2700: color = RateColors[7];
	    case 2701..3000: color = RateColors[8];
	    default: color = RateColors[0];
	}
	return color;
}

//���������� ���� �� �������� (hex)
stock GetHexColorByRate(rate) {
	new color;
	switch (rate) {
	    case 501..1000: color = HexRateColors[1][0];
	    case 1001..1200: color = HexRateColors[2][0];
	    case 1201..1400: color = HexRateColors[3][0];
	    case 1401..1600: color = HexRateColors[4][0];
	    case 1601..2000: color = HexRateColors[5][0];
	    case 2001..2300: color = HexRateColors[6][0];
	    case 2301..2700: color = HexRateColors[7][0];
	    case 2701..3000: color = HexRateColors[8][0];
	    default: color = HexRateColors[0][0];
	}
	return color;
}

//���������� ��� ������ �� ID
stock GetClassNameByID(id) {
	new classname[32];
	switch (id) {
	    case 0: classname = "{1155cc}������������";
	    case 1: classname = "{bc351f}��������";
	    case 2: classname = "{134f5c}����";
	    case 3: classname = "{f97403}�������";
	    case 4: classname = "{5b419b}�������";
	    case 5: classname = "{9900ff}�����������";
	    default: classname = "{ffffff}�� ������";
	}
	return classname;
}

//���������� �������� �������� �� ��������
stock GetRateInterval(rate) {
	new interval[32];
	switch (rate) {
	    case 501..1000: interval = "������";
	    case 1001..1200: interval = "������";
	    case 1201..1400: interval = "������";
	    case 1401..1600: interval = "�������";
	    case 1601..2000: interval = "������";
	    case 2001..2300: interval = "�������";
	    case 2301..2700: interval = "�����";
	    case 2701..3000: interval = "���������";
	    default: interval = "������";
	}
	return interval;
}

//�������� playerid �� �����
stock GetPlayerID(const player_name[])
{
    for(new i; i<MAX_PLAYERS; i++) {
        if(IsPlayerConnected(i)) {
            new pName[MAX_PLAYER_NAME];
            GetPlayerName(i, pName, sizeof(pName));
            if(strcmp(player_name, pName, true) == 0)
                return i;
        }
    }
    return -1;
}

//��������� ������� �������
stock UpdateRatingTop()
{
    new name[128];
    new classid;
    new rate;
	new path[64];
    for (new i = 0; i < MAX_CLOWNS; i++) {
    	name = GetOwner(i);
        new playerid = GetPlayerID(name);
        if (playerid > -1) {
			RatingTop[i][Name] = name;
			format(RatingTop[i][Class], 60, "%s", GetClassNameByID(PlayerInfo[playerid][Class]));
			RatingTop[i][Rate] = PlayerInfo[playerid][Rate];
			continue;
        }
		format(path, sizeof(path), "Players/%s.ini", name);
		new File = ini_openFile(path);
		ini_getInteger(File, "Class", classid);
		ini_getInteger(File, "Rate", rate);
		ini_closeFile(File);
		RatingTop[i][Name] = name;
		format(RatingTop[i][Class], 60, "%s", GetClassNameByID(classid));
		RatingTop[i][Rate] = rate;
	}
	new tmp[TopItem];
	for(new i = 0; i < MAX_CLOWNS; i++) {
        for(new j = MAX_CLOWNS - 1; j > i; j--) {
            if(RatingTop[j-1][Rate] < RatingTop[j][Rate]) {
                tmp = RatingTop[j-1];
                RatingTop[j-1] = RatingTop[j];
                RatingTop[j] = tmp;
            }
        }
    }
    for(new i = 0; i < MAX_CLOWNS; i++) {
        new playerid = GetPlayerID(RatingTop[i][Name]);
        if (playerid > -1) {
            PlayerInfo[playerid][TopPosition] = i + 1;
			continue;
        }
        format(path, sizeof(path), "Players/%s.ini", RatingTop[i][Name]);
		new File = ini_openFile(path);
		ini_setInteger(File, "TopPosition", i+1);
		ini_closeFile(File);
    }
}

//�������� ���� �����
stock GetPlaceColor(place)
{
    new color[16];
	switch (place) {
	    case 1: color = "FFCC00";
	    case 2: color = "FF6600";
	    case 3: color = "FF3300";
	    case 4,5: color = "CC0099";
	    case 6..8: color = "CC33FF";
	    case 9..12: color = "6666FF";
	    case 13..17: color = "0066CC";
	    case 18..22: color = "66CCCC";
	    case 23..25: color = "66CC00";
	    default: color = "CCCCCC";
	}
	return color;
}

//���������� ��� ���������� ��� ������
stock ShowRatingTop(playerid)
{
	new top[4000] = "�����\t���\t�����\t�������";
	new string[455];
	for (new i = 0; i < MAX_CLOWNS; i++) {
		format(string, sizeof(string), "\n{%s}%d\t{%s}%s\t%s\t{%s}%d", GetPlaceColor(i+1), i+1, GetColorByRate(RatingTop[i][Rate]), RatingTop[i][Name], RatingTop[i][Class], GetColorByRate(RatingTop[i][Rate]), RatingTop[i][Rate]);
		strcat(top, string);
	}
	ShowPlayerDialog(playerid, 1, DIALOG_STYLE_TABLIST_HEADERS, "������� �������", top, "�������", "");
}

//�������� ��������
stock LoadAccount(playerid) {
	new name[64];
	new string[255];
	GetPlayerName(playerid, name, sizeof(name));
    new path[128];
	format(path, sizeof(path), "Players/%s.ini", name);
	new File = ini_openFile(path);
	ini_getInteger(File, "Sex", PlayerInfo[playerid][Sex]);
	ini_getInteger(File, "Rate", PlayerInfo[playerid][Rate]);
    ini_getInteger(File, "Class", PlayerInfo[playerid][Class]);
    ini_getInteger(File, "Cash", PlayerInfo[playerid][Cash]);
    ini_getInteger(File, "Bank", PlayerInfo[playerid][Bank]);
    ini_getInteger(File, "QItem", PlayerInfo[playerid][QItem]);
    ini_getInteger(File, "Admin", PlayerInfo[playerid][Admin]);
    ini_getInteger(File, "Skin", PlayerInfo[playerid][Skin]);
    ini_getInteger(File, "Wins", PlayerInfo[playerid][Wins]);
    ini_getInteger(File, "Loses", PlayerInfo[playerid][Loses]);
    ini_getInteger(File, "TopPosition", PlayerInfo[playerid][TopPosition]);
    ini_getFloat(File, "PosX", PlayerInfo[playerid][PosX]);
    ini_getFloat(File, "PosY", PlayerInfo[playerid][PosY]);
    ini_getFloat(File, "PosZ", PlayerInfo[playerid][PosZ]);
    ini_getFloat(File, "Angle", PlayerInfo[playerid][FacingAngle]);
    ini_getInteger(File, "Interior", PlayerInfo[playerid][Interior]);
    for (new j = 0; j < MAX_SLOTS; j++) {
        format(string, sizeof(string), "InventorySlot%d", j);
        ini_getInteger(File, string, PlayerInfo[playerid][Inventory][j]);
        format(string, sizeof(string), "InventorySlotCount%d", j);
        ini_getInteger(File, string, PlayerInfo[playerid][InventoryCount][j]);
    }
    for (new j = 0; j < MAX_EFFECTS; j++) {
        format(string, sizeof(string), "EffectID%d", j);
        ini_getInteger(File, string, PlayerInfo[playerid][EffectsID][j]);
    }
    for (new j = 0; j < MAX_EFFECTS; j++) {
        format(string, sizeof(string), "EffectTime%d", j);
        ini_getInteger(File, string, PlayerInfo[playerid][EffectsTime][j]);
    }
    for (new j = 0; j < MAX_SKILLS; j++) {
        format(string, sizeof(string), "SkillCooldown%d", j);
        ini_getInteger(File, string, PlayerInfo[playerid][SkillCooldown][j]);
    }
    ini_closeFile(File);
    SetPlayerName(playerid, name);
    SetPlayerParams(playerid);
}

//���������� ��������
stock SaveAccount(playerid) {
	new name[64];
	new string[255];
	GetPlayerPos(playerid, PlayerInfo[playerid][PosX], PlayerInfo[playerid][PosY], PlayerInfo[playerid][PosZ]);
	GetPlayerFacingAngle(playerid, PlayerInfo[playerid][FacingAngle]);
	PlayerInfo[playerid][Interior] = GetPlayerInterior(playerid);
	GetPlayerName(playerid, name, sizeof(name));
	new path[128];
	format(path, sizeof(path), "Players/%s.ini", name);
	new File = ini_openFile(path);
	ini_setInteger(File, "Sex", PlayerInfo[playerid][Sex]);
	ini_setInteger(File, "Rate", PlayerInfo[playerid][Rate]);
    ini_setInteger(File, "Class", PlayerInfo[playerid][Class]);
    ini_setInteger(File, "Cash", PlayerInfo[playerid][Cash]);
    ini_setInteger(File, "Bank", PlayerInfo[playerid][Bank]);
    ini_setInteger(File, "QItem", PlayerInfo[playerid][QItem]);
    ini_setInteger(File, "Admin", PlayerInfo[playerid][Admin]);
    ini_setInteger(File, "Skin", PlayerInfo[playerid][Skin]);
    ini_setInteger(File, "Wins", PlayerInfo[playerid][Wins]);
    ini_setInteger(File, "Loses", PlayerInfo[playerid][Loses]);
    ini_setInteger(File, "TopPosition", PlayerInfo[playerid][TopPosition]);
    ini_setFloat(File, "PosX", PlayerInfo[playerid][PosX]);
    ini_setFloat(File, "PosY", PlayerInfo[playerid][PosY]);
    ini_setFloat(File, "PosZ", PlayerInfo[playerid][PosZ]);
    ini_setFloat(File, "Angle", PlayerInfo[playerid][FacingAngle]);
    ini_setInteger(File, "Interior", PlayerInfo[playerid][Interior]);
    for (new j = 0; j < MAX_SLOTS; j++) {
        format(string, sizeof(string), "InventorySlot%d", j);
        ini_setInteger(File, string, PlayerInfo[playerid][Inventory][j]);
        format(string, sizeof(string), "InventorySlotCount%d", j);
        ini_setInteger(File, string, PlayerInfo[playerid][InventoryCount][j]);
    }
    for (new j = 0; j < MAX_EFFECTS; j++) {
        format(string, sizeof(string), "EffectID%d", j);
        ini_setInteger(File, string, PlayerInfo[playerid][EffectsID][j]);
    }
    for (new j = 0; j < MAX_EFFECTS; j++) {
        format(string, sizeof(string), "EffectTime%d", j);
        ini_setInteger(File, string, PlayerInfo[playerid][EffectsTime][j]);
    }
    for (new j = 0; j < MAX_SKILLS; j++) {
        format(string, sizeof(string), "SkillCooldown%d", j);
        ini_setInteger(File, string, PlayerInfo[playerid][SkillCooldown][j]);
    }
    ini_closeFile(File);
    for (new j = 0; j < MAX_EFFECTS; j++)
        if (PlayerInfo[playerid][EffectsID][j] != -1)
            DisablePlayerEffect(playerid, PlayerInfo[playerid][EffectsID][j]);
}

//�������� �������
stock CreatePickups()
{
    home_enter = CreatePickup(1318,23,224.0201,-1837.3518,4.2787);
    home_quit = CreatePickup(1318,23,-2158.6240,642.8425,1052.3750);
    adm_enter = CreatePickup(19130,23,-2170.3340,635.3892,1052.3750);
    adm_quit = CreatePickup(19130,23,-2029.7946,-119.6238,1035.1719);
    cafe_enter = CreatePickup(19133,23,184.5765,-1823.2200,5.1312);
    cafe_quit = CreatePickup(19133,23,460.5555,-88.6005,999.5547);
    rest_enter = CreatePickup(19133,23,265.0125,-1822.7384,4.2996);
    rest_quit = CreatePickup(19133,23,377.0888,-193.3045,1000.6328);
    shop_enter = CreatePickup(19133,23,255.8797,-1786.0399,4.2521);
    shop_quit = CreatePickup(19133,23,-27.4040,-58.2740,1003.5469);
    start_tp1 = CreatePickup(19605,23,243.1539,-1831.6542,3.3772);
    start_tp2 = CreatePickup(19607,23,204.7617,-1831.6539,3.3772);
    
    Create3DTextLabel("Clown's House",0xf2622bFF,224.0201,-1837.3518,4.2787,70.0,0,1);
    Create3DTextLabel("�������������",0x990000FF,-2170.3340,635.3892,1052.3750,70.0,0,1);
    Create3DTextLabel("���� '� ����'",0x9fc91fFF,184.5765,-1823.2200,5.1312,70.0,0,1);
    Create3DTextLabel("Pepe's Restaurant",0xead11fFF,265.0125,-1822.7384,4.2996,70.0,0,1);
    Create3DTextLabel("Circus 24/7",0x1f95eaFF,255.8797,-1786.0399,4.2521,70.0,0,1);
    Create3DTextLabel("���� �� �����",0xeaeaeaFF,243.1539,-1831.6542,3.9772,70.0,0,1);
    Create3DTextLabel("���� �� �����",0xeaeaeaFF,204.7617,-1831.6539,4.1772,70.0,0,1);
    Create3DTextLabel("����� ������",0xFFCC00FF,-2171.3132,645.5896,1053.3817,5.0,0,1);
    
    Create3DTextLabel("������� [F] ��� ��������������",0xFFCC00FF,-23.4700,-57.3214,1003.5469,5.0,0,1);
    Create3DTextLabel("������� [F] ��� ��������������",0xFFCC00FF,380.7459,-189.1151,1000.6328,5.0,0,1);
    Create3DTextLabel("������� [F] ��� ��������������",0xFFCC00FF,450.5763,-82.2320,999.5547,5.0,0,1);
    Create3DTextLabel("������� [F] ��� ��������������",0xFFCC00FF,-2166.7527,646.0400,1052.3750,5.0,0,1);
    
	Actors[0] =	CreateActor(155,450.5763,-82.2320,999.5547,180.2773);
	Actors[1] =	CreateActor(171,380.7459,-189.1151,1000.6328,180.5317);
	Actors[2] =	CreateActor(226,-23.4700,-57.3214,1003.5469,354.9999);
	Actors[3] =	CreateActor(61,-2166.7527,646.0400,1052.3750,179.9041);
}

//����������� textdraw-��
stock ShowTextDraws(playerid)
{
	TextDrawShowForPlayer(playerid,GamemodeName);
	TextDrawShowForPlayer(playerid,WorldTime);
}

//���������� ���� textdraws
stock ShowAllTextDraws(playerid)
{
	PlayerTextDrawShow(playerid, TourPanelBox[playerid]);
	PlayerTextDrawShow(playerid, TourPlayerName1[playerid]);
	PlayerTextDrawShow(playerid, TourPlayerName2[playerid]);
	PlayerTextDrawShow(playerid, TourScoreBar[playerid]);
	PlayerTextDrawShow(playerid, HPBar[playerid]);
	PlayerTextDrawShow(playerid, InvBox[playerid]);
	for (new i = 0; i < MAX_SLOTS; i++) {
		PlayerTextDrawShow(playerid, InvSlot[playerid][i]);
		PlayerTextDrawShow(playerid, InvSlotCount[playerid][i]);
	}
	PlayerTextDrawShow(playerid, PanelInfo[playerid]);
	PlayerTextDrawShow(playerid, PanelInventory[playerid]);
	PlayerTextDrawShow(playerid, PanelUndress[playerid]);
	PlayerTextDrawShow(playerid, PanelBox[playerid]);
	PlayerTextDrawShow(playerid, PanelDelimeter1[playerid]);
	PlayerTextDrawShow(playerid, PanelDelimeter2[playerid]);
	PlayerTextDrawShow(playerid, btn_use[playerid]);
	PlayerTextDrawShow(playerid, btn_del[playerid]);
	PlayerTextDrawShow(playerid, btn_quick[playerid]);
	PlayerTextDrawShow(playerid, btn_info[playerid]);
	PlayerTextDrawShow(playerid, blue_flag[playerid]);
	PlayerTextDrawShow(playerid, red_flag[playerid]);
	PlayerTextDrawShow(playerid, inv_ico[playerid]);
	for (new i = 0; i < MAX_EFFECTS; i++) {
		PlayerTextDrawShow(playerid, EBox[playerid][i]);
		PlayerTextDrawShow(playerid, EBox_Time[playerid][i]);
	}
	for (new i = 0; i < MAX_SKILLS; i++) {
		PlayerTextDrawShow(playerid, SkillIco[playerid][i]);
		PlayerTextDrawShow(playerid, SkillButton[playerid][i]);
		PlayerTextDrawShow(playerid, SkillTime[playerid][i]);
	}
}

//�������� textdraw-��
stock DeleteTextDraws()
{
	TextDrawDestroy(GamemodeName);
	TextDrawDestroy(WorldTime);
}

//�������� textdraw-�� (�����)
stock DeletePlayerTextDraws(playerid)
{
	PlayerTextDrawDestroy(playerid, TourPanelBox[playerid]);
	PlayerTextDrawDestroy(playerid, TourPlayerName1[playerid]);
	PlayerTextDrawDestroy(playerid, TourPlayerName2[playerid]);
	PlayerTextDrawDestroy(playerid, HPBar[playerid]);
	PlayerTextDrawDestroy(playerid, InvBox[playerid]);
	for (new i = 0; i < MAX_SLOTS; i++) {
		PlayerTextDrawDestroy(playerid, InvSlot[playerid][i]);
		PlayerTextDrawDestroy(playerid, InvSlotCount[playerid][i]);
	}
	PlayerTextDrawDestroy(playerid, PanelInfo[playerid]);
	PlayerTextDrawDestroy(playerid, PanelInventory[playerid]);
	PlayerTextDrawDestroy(playerid, PanelUndress[playerid]);
	PlayerTextDrawDestroy(playerid, PanelBox[playerid]);
	PlayerTextDrawDestroy(playerid, PanelDelimeter1[playerid]);
	PlayerTextDrawDestroy(playerid, PanelDelimeter2[playerid]);
	PlayerTextDrawDestroy(playerid, btn_use[playerid]);
	PlayerTextDrawDestroy(playerid, btn_del[playerid]);
	PlayerTextDrawDestroy(playerid, btn_quick[playerid]);
	PlayerTextDrawDestroy(playerid, btn_info[playerid]);
	PlayerTextDrawDestroy(playerid, blue_flag[playerid]);
	PlayerTextDrawDestroy(playerid, red_flag[playerid]);
	PlayerTextDrawDestroy(playerid, inv_ico[playerid]);
	for (new i = 0; i < MAX_EFFECTS; i++) {
		PlayerTextDrawDestroy(playerid, EBox[playerid][i]);
		PlayerTextDrawDestroy(playerid, EBox_Time[playerid][i]);
	}
	for (new i = 0; i < MAX_SKILLS; i++) {
		PlayerTextDrawDestroy(playerid, SkillIco[playerid][i]);
		PlayerTextDrawDestroy(playerid, SkillButton[playerid][i]);
		PlayerTextDrawDestroy(playerid, SkillTime[playerid][i]);
	}
}

//������������� textdraw-��
stock InitTextDraws()
{
    GamemodeName = TextDrawCreate(547.367431, 22.980691, "RCircus 1.0");
	TextDrawLetterSize(GamemodeName, 0.415998, 1.886222);
	TextDrawAlignment(GamemodeName, 1);
	TextDrawColor(GamemodeName, -5963521);
	TextDrawSetShadow(GamemodeName, 1);
	TextDrawSetOutline(GamemodeName, 0);
	TextDrawBackgroundColor(GamemodeName, 51);
	TextDrawFont(GamemodeName, 1);
	TextDrawSetProportional(GamemodeName, 1);
	TextDrawSetPreviewModel(GamemodeName, 0);
	TextDrawSetPreviewRot(GamemodeName, 0.000000, 0.000000, 0.000000, 0.000000);

    WorldTime = TextDrawCreate(578.033020, 42.103794, "00:00");
	TextDrawLetterSize(WorldTime, 0.433663, 2.168296);
	TextDrawAlignment(WorldTime, 2);
	TextDrawColor(WorldTime, -1061109505);
	TextDrawSetShadow(WorldTime, 0);
	TextDrawSetOutline(WorldTime, 1);
	TextDrawBackgroundColor(WorldTime, 51);
	TextDrawFont(WorldTime, 2);
	TextDrawSetProportional(WorldTime, 1);
}

//������������� textdraw-�� (�����)
stock InitPlayerTextDraws(playerid)
{
    TourPanelBox[playerid] = CreatePlayerTextDraw(playerid, 641.666687, 429.174072, "TourPanelBox");
	PlayerTextDrawLetterSize(playerid, TourPanelBox[playerid], 0.000000, 1.895681);
	PlayerTextDrawTextSize(playerid, TourPanelBox[playerid], -2.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, TourPanelBox[playerid], 1);
	PlayerTextDrawColor(playerid, TourPanelBox[playerid], 0);
	PlayerTextDrawUseBox(playerid, TourPanelBox[playerid], true);
	PlayerTextDrawBoxColor(playerid, TourPanelBox[playerid], 102);
	PlayerTextDrawSetShadow(playerid, TourPanelBox[playerid], 0);
	PlayerTextDrawSetOutline(playerid, TourPanelBox[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, TourPanelBox[playerid], -16776961);
	PlayerTextDrawFont(playerid, TourPanelBox[playerid], 0);

	TourPlayerName1[playerid] = CreatePlayerTextDraw(playerid, 36.000045, 429.042816, "Dimak [GR]");
	PlayerTextDrawLetterSize(playerid, TourPlayerName1[playerid], 0.240364, 1.031702);
	PlayerTextDrawAlignment(playerid, TourPlayerName1[playerid], 1);
	PlayerTextDrawColor(playerid, TourPlayerName1[playerid], -1061109505);
	PlayerTextDrawSetShadow(playerid, TourPlayerName1[playerid], 0);
	PlayerTextDrawSetOutline(playerid, TourPlayerName1[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, TourPlayerName1[playerid], 51);
	PlayerTextDrawFont(playerid, TourPlayerName1[playerid], 1);
	PlayerTextDrawSetProportional(playerid, TourPlayerName1[playerid], 1);

	TourPlayerName2[playerid] = CreatePlayerTextDraw(playerid, 604.134399, 429.171447, "ShazokVsemog [IL]");
	PlayerTextDrawLetterSize(playerid, TourPlayerName2[playerid], 0.239996, 1.000000);
	PlayerTextDrawAlignment(playerid, TourPlayerName2[playerid], 3);
	PlayerTextDrawColor(playerid, TourPlayerName2[playerid], -5963521);
	PlayerTextDrawSetShadow(playerid, TourPlayerName2[playerid], 0);
	PlayerTextDrawSetOutline(playerid, TourPlayerName2[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, TourPlayerName2[playerid], 51);
	PlayerTextDrawFont(playerid, TourPlayerName2[playerid], 1);
	PlayerTextDrawSetProportional(playerid, TourPlayerName2[playerid], 1);

	HPBar[playerid] = CreatePlayerTextDraw(playerid, 577.659973, 67.550003, "100% 10000/10000");
	PlayerTextDrawLetterSize(playerid, HPBar[playerid], 0.134663, 0.666665);
	PlayerTextDrawAlignment(playerid, HPBar[playerid], 2);
	PlayerTextDrawColor(playerid, HPBar[playerid], 255);
	PlayerTextDrawSetShadow(playerid, HPBar[playerid], 0);
	PlayerTextDrawSetOutline(playerid, HPBar[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, HPBar[playerid], 51);
	PlayerTextDrawFont(playerid, HPBar[playerid], 2);
	PlayerTextDrawSetProportional(playerid, HPBar[playerid], 1);
	PlayerTextDrawSetPreviewModel(playerid, HPBar[playerid], 0);
	PlayerTextDrawSetPreviewRot(playerid, HPBar[playerid], 0.000000, 0.000000, 0.000000, 0.000000);

	TourScoreBar[playerid] = CreatePlayerTextDraw(playerid, 20.833555, 201.226608, "1  -  0");
	PlayerTextDrawLetterSize(playerid, TourScoreBar[playerid], 0.508665, 2.085334);
	PlayerTextDrawAlignment(playerid, TourScoreBar[playerid], 1);
	PlayerTextDrawColor(playerid, TourScoreBar[playerid], -5963521);
	PlayerTextDrawSetShadow(playerid, TourScoreBar[playerid], 0);
	PlayerTextDrawSetOutline(playerid, TourScoreBar[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, TourScoreBar[playerid], 51);
	PlayerTextDrawFont(playerid, TourScoreBar[playerid], 1);
	PlayerTextDrawSetProportional(playerid, TourScoreBar[playerid], 1);

	InvBox[playerid] = CreatePlayerTextDraw(playerid, 513.499938, 181.944458, "InvBox");
	PlayerTextDrawLetterSize(playerid, InvBox[playerid], 0.000000, 14.641860);
	PlayerTextDrawTextSize(playerid, InvBox[playerid], 614.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, InvBox[playerid], 1);
	PlayerTextDrawColor(playerid, InvBox[playerid], 0);
	PlayerTextDrawUseBox(playerid, InvBox[playerid], true);
	PlayerTextDrawBoxColor(playerid, InvBox[playerid], 102);
	PlayerTextDrawSetShadow(playerid, InvBox[playerid], 0);
	PlayerTextDrawSetOutline(playerid, InvBox[playerid], 0);
	PlayerTextDrawFont(playerid, InvBox[playerid], 0);
	PlayerTextDrawSetPreviewModel(playerid, InvBox[playerid], 0);
	PlayerTextDrawSetPreviewRot(playerid, InvBox[playerid], 0.000000, 0.000000, 0.000000, 0.000000);

	new inv_slot_x = 514;
	new inv_slot_y = 183;
	new idx = 0;
	for (new i = 1; i <= 4; i++) {
	    for (new j = 1; j <= 4; j++) {
	        InvSlot[playerid][idx] = CreatePlayerTextDraw(playerid, inv_slot_x, inv_slot_y, "LD_SPAC:white");
	        PlayerTextDrawLetterSize(playerid, InvSlot[playerid][idx], 0.000000, 0.000000);
			PlayerTextDrawTextSize(playerid, InvSlot[playerid][idx], 24.000000, 25.000000);
			PlayerTextDrawAlignment(playerid, InvSlot[playerid][idx], 2);
			PlayerTextDrawColor(playerid, InvSlot[playerid][idx], -1);
			PlayerTextDrawUseBox(playerid, InvSlot[playerid][idx], true);
			PlayerTextDrawBoxColor(playerid, InvSlot[playerid][idx], 0);
			PlayerTextDrawSetShadow(playerid, InvSlot[playerid][idx], 0);
			PlayerTextDrawSetOutline(playerid, InvSlot[playerid][idx], 0);
			PlayerTextDrawBackgroundColor(playerid, InvSlot[playerid][idx], -1061109505);
			PlayerTextDrawFont(playerid, InvSlot[playerid][idx], 5);
			PlayerTextDrawSetProportional(playerid, InvSlot[playerid][idx], 1);
			PlayerTextDrawSetSelectable(playerid, InvSlot[playerid][idx], true);
			PlayerTextDrawSetPreviewModel(playerid, InvSlot[playerid][idx], -1);
			PlayerTextDrawSetPreviewRot(playerid, InvSlot[playerid][idx], 0.000000, 0.000000, 0.000000, 1.000000);
	        inv_slot_x += 25;
	        idx++;
	    }
	    inv_slot_x = 514;
	    inv_slot_y += 26;
	}
	
	PanelBox[playerid] = CreatePlayerTextDraw(playerid, 621.566833, 181.529617, "PanelBox");
	PlayerTextDrawLetterSize(playerid, PanelBox[playerid], 0.000000, 9.711589);
	PlayerTextDrawTextSize(playerid, PanelBox[playerid], 637.333251, 0.000000);
	PlayerTextDrawAlignment(playerid, PanelBox[playerid], 1);
	PlayerTextDrawColor(playerid, PanelBox[playerid], 0);
	PlayerTextDrawUseBox(playerid, PanelBox[playerid], true);
	PlayerTextDrawBoxColor(playerid, PanelBox[playerid], 102);
	PlayerTextDrawSetShadow(playerid, PanelBox[playerid], 0);
	PlayerTextDrawSetOutline(playerid, PanelBox[playerid], 0);
	PlayerTextDrawFont(playerid, PanelBox[playerid], 0);

	PanelInfo[playerid] = CreatePlayerTextDraw(playerid, 620.666625, 181.688888, "PanelInfo");
	PlayerTextDrawLetterSize(playerid, PanelInfo[playerid], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, PanelInfo[playerid], 16.666687, 17.837036);
	PlayerTextDrawAlignment(playerid, PanelInfo[playerid], 2);
	PlayerTextDrawColor(playerid, PanelInfo[playerid], -1);
	PlayerTextDrawUseBox(playerid, PanelInfo[playerid], true);
	PlayerTextDrawBoxColor(playerid, PanelInfo[playerid], 0x00000000);
	PlayerTextDrawBackgroundColor(playerid, PanelInfo[playerid], 0x00000000);
	PlayerTextDrawSetShadow(playerid, PanelInfo[playerid], 0);
	PlayerTextDrawSetOutline(playerid, PanelInfo[playerid], 0);
	PlayerTextDrawFont(playerid, PanelInfo[playerid], 5);
	PlayerTextDrawSetSelectable(playerid, PanelInfo[playerid], true);
	PlayerTextDrawSetPreviewModel(playerid, PanelInfo[playerid], 1239);
	PlayerTextDrawSetPreviewRot(playerid, PanelInfo[playerid], 0.000000, 0.000000, 180.000000, 1.000000);

	PanelInventory[playerid] = CreatePlayerTextDraw(playerid, 620.666625, 204.503707, "PanelInventory");
	PlayerTextDrawLetterSize(playerid, PanelInventory[playerid], 0.000000, -0.066665);
	PlayerTextDrawTextSize(playerid, PanelInventory[playerid], 18.666687, 20.740722);
	PlayerTextDrawAlignment(playerid, PanelInventory[playerid], 1);
	PlayerTextDrawColor(playerid, PanelInventory[playerid], -2147483393);
	PlayerTextDrawUseBox(playerid, PanelInventory[playerid], true);
	PlayerTextDrawBoxColor(playerid, PanelInventory[playerid], 0x00000000);
	PlayerTextDrawBackgroundColor(playerid, PanelInventory[playerid], 0x00000000);
	PlayerTextDrawSetShadow(playerid, PanelInventory[playerid], 0);
	PlayerTextDrawSetOutline(playerid, PanelInventory[playerid], 0);
	PlayerTextDrawFont(playerid, PanelInventory[playerid], 5);
	PlayerTextDrawSetSelectable(playerid, PanelInventory[playerid], true);
	PlayerTextDrawSetPreviewModel(playerid, PanelInventory[playerid], 1210);
	PlayerTextDrawSetPreviewRot(playerid, PanelInventory[playerid], 0.000000, 0.000000, 0.000000, 1.000000);
	
	PanelUndress[playerid] = CreatePlayerTextDraw(playerid, 620.999877, 228.562988, "PanelUndress");
	PlayerTextDrawLetterSize(playerid, PanelUndress[playerid], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, PanelUndress[playerid], 17.333396, 18.251846);
	PlayerTextDrawAlignment(playerid, PanelUndress[playerid], 1);
	PlayerTextDrawColor(playerid, PanelUndress[playerid], -1);
	PlayerTextDrawUseBox(playerid, PanelUndress[playerid], true);
	PlayerTextDrawBoxColor(playerid, PanelUndress[playerid], 0x00000000);
	PlayerTextDrawBackgroundColor(playerid, PanelUndress[playerid], 0x00000000);
	PlayerTextDrawSetShadow(playerid, PanelUndress[playerid], 0);
	PlayerTextDrawSetOutline(playerid, PanelUndress[playerid], 0);
	PlayerTextDrawFont(playerid, PanelUndress[playerid], 5);
	PlayerTextDrawSetSelectable(playerid, PanelUndress[playerid], true);
	PlayerTextDrawSetPreviewModel(playerid, PanelUndress[playerid], 1275);
	PlayerTextDrawSetPreviewRot(playerid, PanelUndress[playerid], 0.000000, 0.000000, 0.000000, 1.000000);
	
	PanelSwitch[playerid] = CreatePlayerTextDraw(playerid, 621.233093, 249.557052, "PanelSwitch");
	PlayerTextDrawLetterSize(playerid, PanelSwitch[playerid], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, PanelSwitch[playerid], 16.566728, 18.251846);
	PlayerTextDrawAlignment(playerid, PanelSwitch[playerid], 1);
	PlayerTextDrawColor(playerid, PanelSwitch[playerid], -1);
	PlayerTextDrawUseBox(playerid, PanelSwitch[playerid], true);
	PlayerTextDrawBoxColor(playerid, PanelSwitch[playerid], 0x00000000);
	PlayerTextDrawBackgroundColor(playerid, PanelSwitch[playerid], 0x00000000);
	PlayerTextDrawSetShadow(playerid, PanelSwitch[playerid], 0);
	PlayerTextDrawSetOutline(playerid, PanelSwitch[playerid], 0);
	PlayerTextDrawFont(playerid, PanelSwitch[playerid], 5);
	PlayerTextDrawSetSelectable(playerid, PanelSwitch[playerid], true);
	PlayerTextDrawSetPreviewModel(playerid, PanelSwitch[playerid], 18963);
	PlayerTextDrawSetPreviewRot(playerid, PanelSwitch[playerid], 0.000000, 0.000000, 0.000000, 1.000000);
	
	PanelDelimeter1[playerid] = CreatePlayerTextDraw(playerid, 621.333312, 202.014846, "PanelDelimeter1");
	PlayerTextDrawLetterSize(playerid, PanelDelimeter1[playerid], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, PanelDelimeter1[playerid], 17.666624, 1.244444);
	PlayerTextDrawAlignment(playerid, PanelDelimeter1[playerid], 1);
	PlayerTextDrawColor(playerid, PanelDelimeter1[playerid], -1);
	PlayerTextDrawUseBox(playerid, PanelDelimeter1[playerid], true);
 	PlayerTextDrawBoxColor(playerid, PanelDelimeter1[playerid], 0x00000000);
	PlayerTextDrawBackgroundColor(playerid, PanelDelimeter1[playerid], 0x00000000);
	PlayerTextDrawSetShadow(playerid, PanelDelimeter1[playerid], 0);
	PlayerTextDrawSetOutline(playerid, PanelDelimeter1[playerid], 0);
	PlayerTextDrawFont(playerid, PanelDelimeter1[playerid], 5);
	PlayerTextDrawSetPreviewModel(playerid, PanelDelimeter1[playerid], 18657);
	PlayerTextDrawSetPreviewRot(playerid, PanelDelimeter1[playerid], 0.000000, 0.000000, 0.000000, 1.000000);

	PanelDelimeter2[playerid] = CreatePlayerTextDraw(playerid, 620.333312, 226.074050, "PanelDelimeter2");
	PlayerTextDrawLetterSize(playerid, PanelDelimeter2[playerid], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, PanelDelimeter2[playerid], 17.666687, 1.244475);
	PlayerTextDrawAlignment(playerid, PanelDelimeter2[playerid], 1);
	PlayerTextDrawColor(playerid, PanelDelimeter2[playerid], -1);
	PlayerTextDrawUseBox(playerid, PanelDelimeter2[playerid], true);
	PlayerTextDrawBoxColor(playerid, PanelDelimeter2[playerid], 0x00000000);
	PlayerTextDrawBackgroundColor(playerid, PanelDelimeter2[playerid], 0x00000000);
	PlayerTextDrawSetShadow(playerid, PanelDelimeter2[playerid], 0);
	PlayerTextDrawSetOutline(playerid, PanelDelimeter2[playerid], 0);
	PlayerTextDrawFont(playerid, PanelDelimeter2[playerid], 5);
	PlayerTextDrawSetPreviewModel(playerid, PanelDelimeter2[playerid], 18657);
	PlayerTextDrawSetPreviewRot(playerid, PanelDelimeter2[playerid], 0.000000, 0.000000, 0.000000, 1.000000);
	
	PanelDelimeter3[playerid] = CreatePlayerTextDraw(playerid, 620.333007, 248.000000, "PanelDelimeter3");
	PlayerTextDrawLetterSize(playerid, PanelDelimeter3[playerid], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, PanelDelimeter3[playerid], 17.666687, 1.244475);
	PlayerTextDrawAlignment(playerid, PanelDelimeter3[playerid], 1);
	PlayerTextDrawColor(playerid, PanelDelimeter3[playerid], -1);
	PlayerTextDrawUseBox(playerid, PanelDelimeter3[playerid], true);
	PlayerTextDrawBoxColor(playerid, PanelDelimeter3[playerid], 0x00000000);
	PlayerTextDrawBackgroundColor(playerid, PanelDelimeter3[playerid], 0x00000000);
	PlayerTextDrawSetShadow(playerid, PanelDelimeter3[playerid], 0);
	PlayerTextDrawSetOutline(playerid, PanelDelimeter3[playerid], 0);
	PlayerTextDrawFont(playerid, PanelDelimeter3[playerid], 5);
	PlayerTextDrawSetPreviewModel(playerid, PanelDelimeter3[playerid], 18657);
	PlayerTextDrawSetPreviewRot(playerid, PanelDelimeter3[playerid], 0.000000, 0.000000, 0.000000, 1.000000);

	btn_use[playerid] = CreatePlayerTextDraw(playerid, 514.000000, 290.000000, "btn_use");
	PlayerTextDrawLetterSize(playerid, btn_use[playerid], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, btn_use[playerid], 24.000000, 25.000000);
	PlayerTextDrawAlignment(playerid, btn_use[playerid], 2);
	PlayerTextDrawColor(playerid, btn_use[playerid], -1);
	PlayerTextDrawUseBox(playerid, btn_use[playerid], true);
	PlayerTextDrawBoxColor(playerid, btn_use[playerid], 0);
	PlayerTextDrawSetShadow(playerid, btn_use[playerid], 0);
	PlayerTextDrawSetOutline(playerid, btn_use[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, btn_use[playerid], 2424832);
	PlayerTextDrawFont(playerid, btn_use[playerid], 5);
	PlayerTextDrawSetProportional(playerid, btn_use[playerid], 1);
	PlayerTextDrawSetSelectable(playerid, btn_use[playerid], true);
	PlayerTextDrawSetPreviewModel(playerid, btn_use[playerid], 19131);
	PlayerTextDrawSetPreviewRot(playerid, btn_use[playerid], 0.000000, 90.000000, 90.000000, 1.000000);

	btn_info[playerid] = CreatePlayerTextDraw(playerid, 539.000000, 290.000000, "btn_info");
	PlayerTextDrawLetterSize(playerid, btn_info[playerid], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, btn_info[playerid], 24.000000, 25.000000);
	PlayerTextDrawAlignment(playerid, btn_info[playerid], 2);
	PlayerTextDrawColor(playerid, btn_info[playerid], -1);
	PlayerTextDrawUseBox(playerid, btn_info[playerid], true);
	PlayerTextDrawBoxColor(playerid, btn_info[playerid], 0);
	PlayerTextDrawSetShadow(playerid, btn_info[playerid], 0);
	PlayerTextDrawSetOutline(playerid, btn_info[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, btn_info[playerid], 2424832);
	PlayerTextDrawFont(playerid, btn_info[playerid], 5);
	PlayerTextDrawSetProportional(playerid, btn_info[playerid], 1);
	PlayerTextDrawSetSelectable(playerid, btn_info[playerid], true);
	PlayerTextDrawSetPreviewModel(playerid, btn_info[playerid], 1239);
	PlayerTextDrawSetPreviewRot(playerid, btn_info[playerid], 0.000000, 0.000000, 180.000000, 1.000000);

	btn_del[playerid] = CreatePlayerTextDraw(playerid, 564.000000, 290.000000, "btn_del");
	PlayerTextDrawLetterSize(playerid, btn_del[playerid], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, btn_del[playerid], 24.000000, 25.000000);
	PlayerTextDrawAlignment(playerid, btn_del[playerid], 2);
	PlayerTextDrawColor(playerid, btn_del[playerid], -1);
	PlayerTextDrawUseBox(playerid, btn_del[playerid], true);
	PlayerTextDrawBoxColor(playerid, btn_del[playerid], 0);
	PlayerTextDrawSetShadow(playerid, btn_del[playerid], 0);
	PlayerTextDrawSetOutline(playerid, btn_del[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, btn_del[playerid], 2424832);
	PlayerTextDrawFont(playerid, btn_del[playerid], 5);
	PlayerTextDrawSetProportional(playerid, btn_del[playerid], 1);
	PlayerTextDrawSetSelectable(playerid, btn_del[playerid], true);
	PlayerTextDrawSetPreviewModel(playerid, btn_del[playerid], 1409);
	PlayerTextDrawSetPreviewRot(playerid, btn_del[playerid], 0.000000, 0.000000, 180.000000, 1.000000);

	btn_quick[playerid] = CreatePlayerTextDraw(playerid, 589.000000, 290.000000, "btn_quick");
	PlayerTextDrawLetterSize(playerid, btn_quick[playerid], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, btn_quick[playerid], 24.000000, 25.000000);
	PlayerTextDrawAlignment(playerid, btn_quick[playerid], 2);
	PlayerTextDrawColor(playerid, btn_quick[playerid], -1);
	PlayerTextDrawUseBox(playerid, btn_quick[playerid], true);
	PlayerTextDrawBoxColor(playerid, btn_quick[playerid], 0);
	PlayerTextDrawSetShadow(playerid, btn_quick[playerid], 0);
	PlayerTextDrawSetOutline(playerid, btn_quick[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, btn_quick[playerid], 2424832);
	PlayerTextDrawFont(playerid, btn_quick[playerid], 5);
	PlayerTextDrawSetProportional(playerid, btn_quick[playerid], 1);
	PlayerTextDrawSetSelectable(playerid, btn_quick[playerid], true);
	PlayerTextDrawSetPreviewModel(playerid, btn_quick[playerid], 1273);
	PlayerTextDrawSetPreviewRot(playerid, btn_quick[playerid], 0.000000, 0.000000, 180.000000, 1.000000);

	blue_flag[playerid] = CreatePlayerTextDraw(playerid, 2.366585, 200.853591, "blue_flag");
	PlayerTextDrawLetterSize(playerid, blue_flag[playerid], -0.091999, -2.642074);
	PlayerTextDrawTextSize(playerid, blue_flag[playerid], 17.166725, 21.733358);
	PlayerTextDrawAlignment(playerid, blue_flag[playerid], 1);
	PlayerTextDrawColor(playerid, blue_flag[playerid], -1);
	PlayerTextDrawUseBox(playerid, blue_flag[playerid], true);
	PlayerTextDrawBoxColor(playerid, blue_flag[playerid], 0x00000000);
	PlayerTextDrawBackgroundColor(playerid, blue_flag[playerid], 0x00000000);
	PlayerTextDrawSetShadow(playerid, blue_flag[playerid], 0);
	PlayerTextDrawSetOutline(playerid, blue_flag[playerid], 0);
	PlayerTextDrawFont(playerid, blue_flag[playerid], 5);
	PlayerTextDrawSetPreviewModel(playerid, blue_flag[playerid], 19307);
	PlayerTextDrawSetPreviewRot(playerid, blue_flag[playerid], 0.000000, 0.000000, 0.000000, 1.000000);

	red_flag[playerid] = CreatePlayerTextDraw(playerid, 26.666576, 199.980773, "red_flag");
	PlayerTextDrawLetterSize(playerid, red_flag[playerid], 0.028000, 3.901925);
	PlayerTextDrawTextSize(playerid, red_flag[playerid], 53.866683, 22.148172);
	PlayerTextDrawAlignment(playerid, red_flag[playerid], 1);
	PlayerTextDrawColor(playerid, red_flag[playerid], -1);
	PlayerTextDrawUseBox(playerid, red_flag[playerid], true);
	PlayerTextDrawBoxColor(playerid, red_flag[playerid], 0x00000000);
	PlayerTextDrawBackgroundColor(playerid, red_flag[playerid], 0x00000000);
	PlayerTextDrawSetShadow(playerid, red_flag[playerid], 0);
	PlayerTextDrawSetOutline(playerid, red_flag[playerid], 0);
	PlayerTextDrawFont(playerid, red_flag[playerid], 5);
	PlayerTextDrawSetPreviewModel(playerid, red_flag[playerid], 19306);
	PlayerTextDrawSetPreviewRot(playerid, red_flag[playerid], 0.000000, 0.000000, 200.000000, 1.000000);

	inv_ico[playerid] = CreatePlayerTextDraw(playerid, 547.766601, 162.358520, "inv_ico");
	PlayerTextDrawLetterSize(playerid, inv_ico[playerid], 0.000000, 1.666666);
	PlayerTextDrawTextSize(playerid, inv_ico[playerid], 30.433334, 23.000000);
	PlayerTextDrawAlignment(playerid, inv_ico[playerid], 1);
	PlayerTextDrawColor(playerid, inv_ico[playerid], -1);
	PlayerTextDrawUseBox(playerid, inv_ico[playerid], true);
 	PlayerTextDrawBoxColor(playerid, inv_ico[playerid], 0x00000000);
	PlayerTextDrawBackgroundColor(playerid, inv_ico[playerid], 0x00000000);
	PlayerTextDrawSetShadow(playerid, inv_ico[playerid], 0);
	PlayerTextDrawSetOutline(playerid, inv_ico[playerid], 0);
	PlayerTextDrawFont(playerid, inv_ico[playerid], 5);
	PlayerTextDrawSetSelectable(playerid, inv_ico[playerid], true);
	PlayerTextDrawSetPreviewModel(playerid, inv_ico[playerid], 1210);
	PlayerTextDrawSetPreviewRot(playerid, inv_ico[playerid], 0.000000, 0.000000, 0.000000, 1.000000);

	new invslot_count_x = 537;
	new invslot_count_y = 200;
	idx = 0;
	for (new i = 1; i <= 4; i++) {
	    for (new j = 1; j <= 4; j++) {
	        InvSlotCount[playerid][idx] = CreatePlayerTextDraw(playerid, invslot_count_x, invslot_count_y, "0");
			PlayerTextDrawLetterSize(playerid, InvSlotCount[playerid][idx], 0.196998, 0.762072);
			PlayerTextDrawAlignment(playerid, InvSlotCount[playerid][idx], 3);
			PlayerTextDrawColor(playerid, InvSlotCount[playerid][idx], 255);
			PlayerTextDrawSetShadow(playerid, InvSlotCount[playerid][idx], 0);
			PlayerTextDrawSetOutline(playerid, InvSlotCount[playerid][idx], 0);
			PlayerTextDrawBackgroundColor(playerid, InvSlotCount[playerid][idx], 51);
			PlayerTextDrawFont(playerid, InvSlotCount[playerid][idx], 1);
			PlayerTextDrawSetProportional(playerid, InvSlotCount[playerid][idx], 1);
	        invslot_count_x += 25;
	        idx++;
	    }
	    invslot_count_x = 537;
	    invslot_count_y += 26;
	}

	new ebox_x = 503;
	new ebox_y = 101;
	new Float:ebox_time_x = 510.5;
	for (new i = 0; i < MAX_EFFECTS; i++) {
	    EBox[playerid][i] = CreatePlayerTextDraw(playerid, ebox_x, ebox_y, "ebox");
		PlayerTextDrawLetterSize(playerid, EBox[playerid][i], 0.000000, 0.000000);
		PlayerTextDrawTextSize(playerid, EBox[playerid][i], 14.000000, 15.000000);
		PlayerTextDrawAlignment(playerid, EBox[playerid][i], 1);
		PlayerTextDrawColor(playerid, EBox[playerid][i], -1);
		PlayerTextDrawUseBox(playerid, EBox[playerid][i], true);
		PlayerTextDrawBoxColor(playerid, EBox[playerid][i], 0);
		PlayerTextDrawSetShadow(playerid, EBox[playerid][i], 0);
		PlayerTextDrawSetOutline(playerid, EBox[playerid][i], 0);
		PlayerTextDrawBackgroundColor(playerid, EBox[playerid][i], 68);
		PlayerTextDrawFont(playerid, EBox[playerid][i], 5);
		PlayerTextDrawSetPreviewModel(playerid, EBox[playerid][i], -1);
		PlayerTextDrawSetPreviewRot(playerid, EBox[playerid][i], 100.000000, 0.000000, 343.000000, 1.000000);

		EBox_Time[playerid][i] = CreatePlayerTextDraw(playerid, ebox_time_x, 117.0, "0");
		PlayerTextDrawLetterSize(playerid, EBox_Time[playerid][i], 0.201666, 0.786962);
		PlayerTextDrawAlignment(playerid, EBox_Time[playerid][i], 2);
		PlayerTextDrawColor(playerid, EBox_Time[playerid][i], -1);
		PlayerTextDrawSetShadow(playerid, EBox_Time[playerid][i], 0);
		PlayerTextDrawSetOutline(playerid, EBox_Time[playerid][i], 1);
		PlayerTextDrawBackgroundColor(playerid, EBox_Time[playerid][i], 51);
		PlayerTextDrawFont(playerid, EBox_Time[playerid][i], 1);
		PlayerTextDrawSetProportional(playerid, EBox_Time[playerid][i], 1);

		ebox_x += 15;
		ebox_time_x += 15;
	}

	new skill_x = 248;
	new skill_y = 376;
	new skill_btn_x = 261;
	new skill_btn_y = 366;
	new skill_time_x = 262;
	new skill_time_y = 381;

	for (new i = 0; i < MAX_SKILLS; i++) {
	    SkillIco[playerid][i] = CreatePlayerTextDraw(playerid, skill_x, skill_y, "skill1");
		PlayerTextDrawLetterSize(playerid, SkillIco[playerid][i], 0.000000, 0.000000);
		PlayerTextDrawTextSize(playerid, SkillIco[playerid][i], 27.000000, 28.000000);
		PlayerTextDrawAlignment(playerid, SkillIco[playerid][i], 1);
		PlayerTextDrawColor(playerid, SkillIco[playerid][i], -1);
		PlayerTextDrawUseBox(playerid, SkillIco[playerid][i], true);
		PlayerTextDrawBoxColor(playerid, SkillIco[playerid][i], 0);
		PlayerTextDrawSetShadow(playerid, SkillIco[playerid][i], 0);
		PlayerTextDrawSetOutline(playerid, SkillIco[playerid][i], 0);
		PlayerTextDrawBackgroundColor(playerid, SkillIco[playerid][i], 102);
		PlayerTextDrawFont(playerid, SkillIco[playerid][i], 5);
		PlayerTextDrawSetPreviewModel(playerid, SkillIco[playerid][i], -1);
		PlayerTextDrawSetPreviewRot(playerid, SkillIco[playerid][i], 100.000000, 0.000000, 343.000000, 1.000000);

		SkillButton[playerid][i] = CreatePlayerTextDraw(playerid, skill_btn_x, skill_btn_y, "C");
		PlayerTextDrawLetterSize(playerid, SkillButton[playerid][i], 0.262000, 0.961185);
		PlayerTextDrawAlignment(playerid, SkillButton[playerid][i], 2);
		PlayerTextDrawColor(playerid, SkillButton[playerid][i], -1);
		PlayerTextDrawSetShadow(playerid, SkillButton[playerid][i], 0);
		PlayerTextDrawSetOutline(playerid, SkillButton[playerid][i], 1);
		PlayerTextDrawBackgroundColor(playerid, SkillButton[playerid][i], 51);
		PlayerTextDrawFont(playerid, SkillButton[playerid][i], 1);
		PlayerTextDrawSetProportional(playerid, SkillButton[playerid][i], 1);

		SkillTime[playerid][i] = CreatePlayerTextDraw(playerid, skill_time_x, skill_time_y, "01");
		PlayerTextDrawLetterSize(playerid, SkillTime[playerid][i], 0.466666, 1.952592);
		PlayerTextDrawAlignment(playerid, SkillTime[playerid][i], 2);
		PlayerTextDrawColor(playerid, SkillTime[playerid][i], -1061109505);
		PlayerTextDrawSetShadow(playerid, SkillTime[playerid][i], 0);
		PlayerTextDrawSetOutline(playerid, SkillTime[playerid][i], 1);
		PlayerTextDrawBackgroundColor(playerid, SkillTime[playerid][i], 51);
		PlayerTextDrawFont(playerid, SkillTime[playerid][i], 1);
		PlayerTextDrawSetProportional(playerid, SkillTime[playerid][i], 1);

		skill_x += 30;
		skill_btn_x += 30;
		skill_time_x += 30;
	}
	PlayerTextDrawSetString(playerid, SkillButton[playerid][0], "C");
	PlayerTextDrawSetString(playerid, SkillButton[playerid][1], "Num2");
	PlayerTextDrawSetString(playerid, SkillButton[playerid][2], "Num4");
	PlayerTextDrawSetString(playerid, SkillButton[playerid][3], "Num6");
	PlayerTextDrawSetString(playerid, SkillButton[playerid][4], "Num8");
	

	MatchInfoBox[playerid] = CreatePlayerTextDraw(playerid, 85.566619, 182.732574, "matchinfo_box");
	PlayerTextDrawLetterSize(playerid, MatchInfoBox[playerid], 0.000000, 4.530230);
	PlayerTextDrawTextSize(playerid, MatchInfoBox[playerid], 0.599999, 0.000000);
	PlayerTextDrawAlignment(playerid, MatchInfoBox[playerid], 1);
	PlayerTextDrawColor(playerid, MatchInfoBox[playerid], 0);
	PlayerTextDrawUseBox(playerid, MatchInfoBox[playerid], true);
	PlayerTextDrawBoxColor(playerid, MatchInfoBox[playerid], 51);
	PlayerTextDrawSetShadow(playerid, MatchInfoBox[playerid], 0);
	PlayerTextDrawSetOutline(playerid, MatchInfoBox[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, MatchInfoBox[playerid], 51);
	PlayerTextDrawFont(playerid, MatchInfoBox[playerid], 0);

	MatchRoundInfo[playerid] = CreatePlayerTextDraw(playerid, 20.966676, 184.799987, "Round 1");
	PlayerTextDrawLetterSize(playerid, MatchRoundInfo[playerid], 0.345665, 1.317924);
	PlayerTextDrawAlignment(playerid, MatchRoundInfo[playerid], 1);
	PlayerTextDrawColor(playerid, MatchRoundInfo[playerid], -5963521);
	PlayerTextDrawSetShadow(playerid, MatchRoundInfo[playerid], 0);
	PlayerTextDrawSetOutline(playerid, MatchRoundInfo[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, MatchRoundInfo[playerid], 51);
	PlayerTextDrawFont(playerid, MatchRoundInfo[playerid], 1);
	PlayerTextDrawSetProportional(playerid, MatchRoundInfo[playerid], 1);

	MatchRoundTime_Circle[playerid] = CreatePlayerTextDraw(playerid, 15.399992, 221.013031, "roundtime_circle");
	PlayerTextDrawLetterSize(playerid, MatchRoundTime_Circle[playerid], 0.020997, 1.482666);
	PlayerTextDrawTextSize(playerid, MatchRoundTime_Circle[playerid], 51.333335, 48.118495);
	PlayerTextDrawAlignment(playerid, MatchRoundTime_Circle[playerid], 1);
	PlayerTextDrawColor(playerid, MatchRoundTime_Circle[playerid], -1);
	PlayerTextDrawUseBox(playerid, MatchRoundTime_Circle[playerid], true);
	PlayerTextDrawBoxColor(playerid, MatchRoundTime_Circle[playerid], 0x00000000);
	PlayerTextDrawBackgroundColor(playerid, MatchRoundTime_Circle[playerid], 0x00000000);
	PlayerTextDrawSetShadow(playerid, MatchRoundTime_Circle[playerid], 0);
	PlayerTextDrawSetOutline(playerid, MatchRoundTime_Circle[playerid], 0);
	PlayerTextDrawFont(playerid, MatchRoundTime_Circle[playerid], 5);
	PlayerTextDrawSetPreviewModel(playerid, MatchRoundTime_Circle[playerid], 13594);
	PlayerTextDrawSetPreviewRot(playerid, MatchRoundTime_Circle[playerid], 0.000000, 180.000000, 0.000000, 1.000000);

	MatchRoundTime[playerid] = CreatePlayerTextDraw(playerid, 41.933540, 241.011962, "180");
	PlayerTextDrawLetterSize(playerid, MatchRoundTime[playerid], 0.378663, 1.691259);
	PlayerTextDrawAlignment(playerid, MatchRoundTime[playerid], 2);
	PlayerTextDrawColor(playerid, MatchRoundTime[playerid], -1);
	PlayerTextDrawSetShadow(playerid, MatchRoundTime[playerid], 0);
	PlayerTextDrawSetOutline(playerid, MatchRoundTime[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, MatchRoundTime[playerid], 51);
	PlayerTextDrawFont(playerid, MatchRoundTime[playerid], 1);
	PlayerTextDrawSetProportional(playerid, MatchRoundTime[playerid], 1);

	MatchBlueFlag[playerid] = CreatePlayerTextDraw(playerid, -5.099925, 424.194610, "blue_flag");
	PlayerTextDrawLetterSize(playerid, MatchBlueFlag[playerid], -0.091999, -2.642074);
	PlayerTextDrawTextSize(playerid, MatchBlueFlag[playerid], 28.600114, 27.374824);
	PlayerTextDrawAlignment(playerid, MatchBlueFlag[playerid], 1);
	PlayerTextDrawColor(playerid, MatchBlueFlag[playerid], -1);
	PlayerTextDrawUseBox(playerid, MatchBlueFlag[playerid], true);
	PlayerTextDrawBoxColor(playerid, MatchBlueFlag[playerid], 0x00000000);
	PlayerTextDrawBackgroundColor(playerid, MatchBlueFlag[playerid], 0x00000000);
	PlayerTextDrawSetShadow(playerid, MatchBlueFlag[playerid], 0);
	PlayerTextDrawSetOutline(playerid, MatchBlueFlag[playerid], 0);
	PlayerTextDrawFont(playerid, MatchBlueFlag[playerid], 5);
	PlayerTextDrawSetPreviewModel(playerid, MatchBlueFlag[playerid], 19307);
	PlayerTextDrawSetPreviewRot(playerid, MatchBlueFlag[playerid], 0.000000, 0.000000, 0.000000, 1.000000);

	MatchRedFlag[playerid] = CreatePlayerTextDraw(playerid, 614.299255, 425.395629, "red_flag");
	PlayerTextDrawLetterSize(playerid, MatchRedFlag[playerid], 0.028000, 3.901925);
	PlayerTextDrawTextSize(playerid, MatchRedFlag[playerid], 30.266883, 25.964469);
	PlayerTextDrawAlignment(playerid, MatchRedFlag[playerid], 1);
	PlayerTextDrawColor(playerid, MatchRedFlag[playerid], -1);
	PlayerTextDrawUseBox(playerid, MatchRedFlag[playerid], true);
	PlayerTextDrawBoxColor(playerid, MatchRedFlag[playerid], 0x00000000);
	PlayerTextDrawBackgroundColor(playerid, MatchRedFlag[playerid], 0x00000000);
	PlayerTextDrawSetShadow(playerid, MatchRedFlag[playerid], 0);
	PlayerTextDrawSetOutline(playerid, MatchRedFlag[playerid], 0);
	PlayerTextDrawFont(playerid, MatchRedFlag[playerid], 5);
	PlayerTextDrawSetPreviewModel(playerid, MatchRedFlag[playerid], 19306);
	PlayerTextDrawSetPreviewRot(playerid, MatchRedFlag[playerid], 0.000000, 0.000000, 0.000000, 1.000000);

	MatchRank1[playerid] = CreatePlayerTextDraw(playerid, 13.799933, 418.963134, "rank_1");
	PlayerTextDrawLetterSize(playerid, MatchRank1[playerid], -0.006666, 4.157330);
	PlayerTextDrawTextSize(playerid, MatchRank1[playerid], 25.666671, 38.577754);
	PlayerTextDrawAlignment(playerid, MatchRank1[playerid], 2);
	PlayerTextDrawColor(playerid, MatchRank1[playerid], -1);
	PlayerTextDrawUseBox(playerid, MatchRank1[playerid], true);
	PlayerTextDrawBoxColor(playerid, MatchRank1[playerid], 0x00000000);
	PlayerTextDrawBackgroundColor(playerid, MatchRank1[playerid], 0x00000000);
	PlayerTextDrawSetShadow(playerid, MatchRank1[playerid], 0);
	PlayerTextDrawSetOutline(playerid, MatchRank1[playerid], 0);
	PlayerTextDrawFont(playerid, MatchRank1[playerid], 5);
	PlayerTextDrawSetPreviewModel(playerid, MatchRank1[playerid], 19785);
	PlayerTextDrawSetPreviewRot(playerid, MatchRank1[playerid], 90.000000, 0.000000, 180.000000, 1.000000);

	MatchRank2[playerid] = CreatePlayerTextDraw(playerid, 600.066467, 418.884704, "rank_2");
	PlayerTextDrawLetterSize(playerid, MatchRank2[playerid], -0.006666, 4.157330);
	PlayerTextDrawTextSize(playerid, MatchRank2[playerid], 25.666671, 38.577754);
	PlayerTextDrawAlignment(playerid, MatchRank2[playerid], 2);
	PlayerTextDrawColor(playerid, MatchRank2[playerid], -1);
	PlayerTextDrawUseBox(playerid, MatchRank2[playerid], true);
	PlayerTextDrawBoxColor(playerid, MatchRank2[playerid], 0x00000000);
	PlayerTextDrawBackgroundColor(playerid, MatchRank2[playerid], 0x00000000);
	PlayerTextDrawSetShadow(playerid, MatchRank2[playerid], 0);
	PlayerTextDrawSetOutline(playerid, MatchRank2[playerid], 0);
	PlayerTextDrawFont(playerid, MatchRank2[playerid], 5);
	PlayerTextDrawSetPreviewModel(playerid, MatchRank2[playerid], 19785);
	PlayerTextDrawSetPreviewRot(playerid, MatchRank2[playerid], 90.000000, 0.000000, 180.000000, 1.000000);

	MatchHPBar2[playerid] = CreatePlayerTextDraw(playerid, 603.565917, 440.579559, "match_hp_bar_2");
	PlayerTextDrawLetterSize(playerid, MatchHPBar2[playerid], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, MatchHPBar2[playerid], -283.999908, 8.379254);
	PlayerTextDrawAlignment(playerid, MatchHPBar2[playerid], 1);
	PlayerTextDrawColor(playerid, MatchHPBar2[playerid], -16776961);
	PlayerTextDrawUseBox(playerid, MatchHPBar2[playerid], true);
	PlayerTextDrawBoxColor(playerid, MatchHPBar2[playerid], 0);
	PlayerTextDrawSetShadow(playerid, MatchHPBar2[playerid], 0);
	PlayerTextDrawSetOutline(playerid, MatchHPBar2[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, MatchHPBar2[playerid], -16777046);
	PlayerTextDrawFont(playerid, MatchHPBar2[playerid], 5);
	PlayerTextDrawSetPreviewModel(playerid, MatchHPBar2[playerid], 18657);
	PlayerTextDrawSetPreviewRot(playerid, MatchHPBar2[playerid], 0.000000, 0.000000, 0.000000, 0.000000);

	MatchHPPercents1[playerid] = CreatePlayerTextDraw(playerid, 175.066619, 440.459564, "100%");
	PlayerTextDrawLetterSize(playerid, MatchHPPercents1[playerid], 0.151030, 0.667495);
	PlayerTextDrawAlignment(playerid, MatchHPPercents1[playerid], 2);
	PlayerTextDrawColor(playerid, MatchHPPercents1[playerid], 255);
	PlayerTextDrawSetShadow(playerid, MatchHPPercents1[playerid], 0);
	PlayerTextDrawSetOutline(playerid, MatchHPPercents1[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, MatchHPPercents1[playerid], 51);
	PlayerTextDrawFont(playerid, MatchHPPercents1[playerid], 1);
	PlayerTextDrawSetProportional(playerid, MatchHPPercents1[playerid], 1);

	MatchHPBar1[playerid] = CreatePlayerTextDraw(playerid, 35.999008, 440.376739, "match_hp_bar_1");
	PlayerTextDrawLetterSize(playerid, MatchHPBar1[playerid], -0.026333, -8.227705);
	PlayerTextDrawTextSize(playerid, MatchHPBar1[playerid], 284.000274, 22.939250);
	PlayerTextDrawAlignment(playerid, MatchHPBar1[playerid], 1);
	PlayerTextDrawColor(playerid, MatchHPBar1[playerid], -16776961);
	PlayerTextDrawUseBox(playerid, MatchHPBar1[playerid], true);
	PlayerTextDrawBoxColor(playerid, MatchHPBar1[playerid], 0);
	PlayerTextDrawSetShadow(playerid, MatchHPBar1[playerid], 0);
	PlayerTextDrawSetOutline(playerid, MatchHPBar1[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, MatchHPBar1[playerid], -16777046);
	PlayerTextDrawFont(playerid, MatchHPBar1[playerid], 5);
	PlayerTextDrawSetPreviewModel(playerid, MatchHPBar1[playerid], 18657);
	PlayerTextDrawSetPreviewRot(playerid, MatchHPBar1[playerid], 0.000000, 0.000000, 0.000000, 0.000000);

	MatchHPPercents2[playerid] = CreatePlayerTextDraw(playerid, 461.066650, 440.795989, "100%");
	PlayerTextDrawLetterSize(playerid, MatchHPPercents2[playerid], 0.151030, 0.667495);
	PlayerTextDrawAlignment(playerid, MatchHPPercents2[playerid], 2);
	PlayerTextDrawColor(playerid, MatchHPPercents2[playerid], 255);
	PlayerTextDrawSetShadow(playerid, MatchHPPercents2[playerid], 0);
	PlayerTextDrawSetOutline(playerid, MatchHPPercents2[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, MatchHPPercents2[playerid], 51);
	PlayerTextDrawFont(playerid, MatchHPPercents2[playerid], 1);
	PlayerTextDrawSetProportional(playerid, MatchHPPercents2[playerid], 1);
}

//�������� ��������
stock CreateMap()
{
    AddStaticVehicleEx(481,211.3000000,-1836.1000000,3.3000000,90.0000000,228,4,60); //BMX
	AddStaticVehicleEx(481,211.3999900,-1834.5000000,3.3000000,90.0000000,228,4,60); //BMX
	AddStaticVehicleEx(481,211.6000100,-1832.7000000,3.3000000,90.0000000,228,4,60); //BMX
	AddStaticVehicleEx(481,211.8000000,-1830.6000000,3.3000000,90.0000000,228,4,60); //BMX
	AddStaticVehicleEx(481,236.7000000,-1836.8000000,3.3000000,270.0000000,228,4,60); //BMX
	AddStaticVehicleEx(481,236.6000100,-1834.7000000,3.3000000,269.9950000,228,4,60); //BMX
	AddStaticVehicleEx(481,236.6000100,-1832.9000000,3.3000000,269.9950000,228,4,60); //BMX
	AddStaticVehicleEx(481,236.3999900,-1831.1000000,3.3000000,269.9950000,228,4,60); //BMX
	Transport[0] = AddStaticVehicleEx(522,198.7000000,-1835.9000000,3.4000000,270.0000000,228,222,60); //NRG-500
	Transport[1] = AddStaticVehicleEx(522,198.6000100,-1833.5000000,3.4000000,270.0000000,228,222,60); //NRG-500
	Transport[2] = AddStaticVehicleEx(522,198.3999900,-1830.5000000,3.4000000,270.0000000,228,222,60); //NRG-500
	Transport[3] = AddStaticVehicleEx(522,248.8999900,-1836.3000000,3.4000000,90.0000000,228,222,60); //NRG-500
	Transport[4] = AddStaticVehicleEx(522,249.0000000,-1833.5000000,3.4000000,89.9950000,228,222,60); //NRG-500
	Transport[5] = AddStaticVehicleEx(522,249.3000000,-1830.9000000,3.4000000,89.9950000,228,222,60); //NRG-500
	CreateObject(16006,224.0000000,-1830.0000000,2.2000000,0.0000000,0.0000000,270.0000000); //object(ros_townhall) (1)
	CreateObject(9339,235.0000000,-1826.7998000,3.2000000,0.0000000,0.0000000,0.0000000); //object(sfnvilla001_cm) (3)
	CreateObject(9339,213.1904300,-1826.7998000,2.7000000,0.0000000,0.0000000,0.0000000); //object(sfnvilla001_cm) (5)
	CreateObject(9339,213.1796900,-1826.7998000,3.2000000,0.0000000,0.0000000,0.0000000); //object(sfnvilla001_cm) (6)
	CreateObject(9339,227.0000000,-1813.7998000,3.2000000,0.0000000,0.0000000,90.0000000); //object(sfnvilla001_cm) (7)
	CreateObject(1597,214.0996100,-1818.9004000,5.7000000,1.5000000,0.0000000,0.0000000); //object(cntrlrsac1) (1)
	CreateObject(1597,214.0996100,-1826.9004000,5.5000000,0.0000000,0.0000000,0.0000000); //object(cntrlrsac1) (2)
	CreateObject(1597,214.0996100,-1834.9004000,5.5000000,0.0000000,0.0000000,0.0000000); //object(cntrlrsac1) (3)
	CreateObject(9339,215.4502000,-1826.7998000,3.2000000,0.0000000,0.0000000,0.0000000); //object(sfnvilla001_cm) (8)
	CreateObject(748,214.2002000,-1815.4004000,3.7000000,0.0000000,0.0000000,270.0000000); //object(sm_scrb_grp1) (3)
	CreateObject(748,214.3554700,-1838.0898000,3.1000000,0.0000000,0.0000000,90.0000000); //object(sm_scrb_grp1) (5)
	CreateObject(1231,219.4697300,-1839.7197000,4.7000000,0.0000000,0.0000000,353.9960000); //object(streetlamp2) (1)
	CreateObject(748,233.9003900,-1838.0000000,3.0000000,0.0000000,0.0000000,90.0000000); //object(sm_scrb_grp1) (1)
	CreateObject(1597,233.7002000,-1834.2998000,5.5000000,0.0000000,0.0000000,0.0000000); //object(cntrlrsac1) (4)
	CreateObject(1597,233.7002000,-1826.2998000,5.5000000,0.0000000,0.0000000,0.0000000); //object(cntrlrsac1) (5)
	CreateObject(1597,233.7002000,-1818.5996000,5.7000000,1.0000000,0.0000000,0.0000000); //object(cntrlrsac1) (6)
	CreateObject(748,233.8999900,-1815.4000000,3.7000000,0.0000000,0.0000000,270.0000000); //object(sm_scrb_grp1) (2)
	CreateObject(9339,232.7998000,-1826.7998000,3.2000000,0.0000000,0.0000000,0.0000000); //object(sfnvilla001_cm) (1)
	CreateObject(1231,228.0996100,-1839.6895000,4.7000000,0.0000000,0.0000000,179.9950000); //object(streetlamp2) (2)
	CreateObject(10401,210.5996100,-1826.7998000,5.0000000,2.9990000,0.0000000,314.9950000); //object(hc_shed02_sfs) (1)
	CreateObject(10401,248.8496100,-1826.7998000,5.0000000,2.9940000,0.0000000,314.9950000); //object(hc_shed02_sfs) (2)
	CreateObject(5848,224.2000000,-1780.5000000,8.7000000,0.0000000,0.0000000,351.8000000); //object(mainblk_lawn) (1)
	CreateObject(9339,220.9900100,-1813.7998000,3.2000000,0.0000000,0.0000000,90.0000000); //object(sfnvilla001_cm) (2)
	CreateObject(9339,259.0000000,-1813.7998000,3.2000000,0.0000000,0.0000000,90.0000000); //object(sfnvilla001_cm) (4)
	CreateObject(9339,251.4003900,-1826.7998000,3.2000000,0.0000000,0.0000000,0.0000000); //object(sfnvilla001_cm) (9)
	CreateObject(9339,196.7998000,-1826.7998000,3.2000000,0.0000000,0.0000000,0.0000000); //object(sfnvilla001_cm) (10)
	CreateObject(9339,189.0000000,-1813.7998000,3.2000000,0.0000000,0.0000000,90.0000000); //object(sfnvilla001_cm) (11)
	CreateObject(18241,194.5000000,-1780.5898000,3.0000000,0.0000000,0.0000000,358.0000000); //object(cuntw_weebuild) (1)
	CreateObject(18241,254.3500100,-1780.2000000,3.0000000,0.0000000,0.0000000,0.0000000); //object(cuntw_weebuild) (2)
	CreateObject(7231,223.6000100,-1796.8000000,23.0000000,0.0000000,0.0000000,0.0000000); //object(clwnpocksgn_d) (1)
	CreateObject(1368,199.3000000,-1814.4000000,4.1300000,0.0000000,0.0000000,0.0000000); //object(cj_blocker_bench) (1)
	CreateObject(1361,201.1000100,-1814.6000000,4.2000000,0.0000000,0.0000000,0.0000000); //object(cj_bush_prop2) (1)
	CreateObject(1361,197.5000000,-1814.6000000,4.2000000,0.0000000,0.0000000,0.0000000); //object(cj_bush_prop2) (2)
	CreateObject(2631,224.0000000,-1840.1000000,2.5500000,0.0000000,0.0000000,0.0000000); //object(gym_mat1) (1)
	CreateObject(1361,212.3999900,-1814.6000000,4.2000000,0.0000000,0.0000000,0.0000000); //object(cj_bush_prop2) (3)
	CreateObject(1368,210.6600000,-1814.6000000,4.1000000,0.0000000,0.0000000,0.0000000); //object(cj_blocker_bench) (2)
	CreateObject(1361,208.8000000,-1814.6000000,4.2000000,0.0000000,0.0000000,0.0000000); //object(cj_bush_prop2) (4)
	CreateObject(3640,183.8999900,-1819.8000000,7.6000000,0.0000000,0.0000000,0.0000000); //object(glenphouse02_lax) (1)
	CreateObject(2027,178.3000000,-1830.4000000,3.6000000,0.0000000,0.0000000,0.0000000); //object(dinerseat_4) (2)
	CreateObject(2027,182.3000000,-1833.1000000,3.6000000,0.0000000,0.0000000,0.0000000); //object(dinerseat_4) (3)
	CreateObject(2027,178.3000000,-1837.1000000,3.6000000,0.0000000,0.0000000,0.0000000); //object(dinerseat_4) (4)
	CreateObject(642,182.3000000,-1833.1200000,4.4000000,0.0000000,0.0000000,0.0000000); //object(kb_canopy_test) (1)
	CreateObject(642,178.3000000,-1830.4000000,4.4000000,0.0000000,0.0000000,0.0000000); //object(kb_canopy_test) (2)
	CreateObject(716,194.2000000,-1816.8000000,3.4000000,0.0000000,0.0000000,0.0000000); //object(sjmpalmbigpv) (1)
	CreateObject(716,194.2000000,-1819.9000000,3.4000000,0.0000000,0.0000000,0.0000000); //object(sjmpalmbigpv) (2)
	CreateObject(716,194.2000000,-1823.0000000,3.4000000,0.0000000,0.0000000,0.0000000); //object(sjmpalmbigpv) (3)
	CreateObject(642,178.3000000,-1837.1000000,4.4000000,0.0000000,0.0000000,0.0000000); //object(kb_canopy_test) (3)
	CreateObject(716,174.5000000,-1823.0000000,3.4000000,0.0000000,0.0000000,0.0000000); //object(sjmpalmbigpv) (4)
	CreateObject(716,174.5000000,-1819.9000000,3.4000000,0.0000000,0.0000000,0.0000000); //object(sjmpalmbigpv) (5)
	CreateObject(716,174.5000000,-1816.8000000,3.4000000,0.0000000,0.0000000,0.0000000); //object(sjmpalmbigpv) (6)
	CreateObject(1368,196.1000100,-1828.0000000,3.7300000,0.0000000,2.0000000,270.0000000); //object(cj_blocker_bench) (3)
	CreateObject(1368,196.1000100,-1832.0000000,3.6000000,0.0000000,2.0000000,270.0000000); //object(cj_blocker_bench) (4)
	CreateObject(1368,196.1000100,-1836.1000000,3.4800000,0.0000000,2.0000000,270.0000000); //object(cj_blocker_bench) (5)
	CreateObject(1361,196.1000100,-1830.0300000,3.7300000,0.0000000,0.0000000,0.0000000); //object(cj_bush_prop2) (5)
	CreateObject(1361,196.1000100,-1834.0500000,3.6000000,0.0000000,0.0000000,0.0000000); //object(cj_bush_prop2) (6)
	CreateObject(1361,196.1000100,-1826.0500000,3.7300000,0.0000000,0.0000000,0.0000000); //object(cj_bush_prop2) (7)
	CreateObject(1361,196.1000100,-1838.1000000,3.4800000,0.0000000,0.0000000,0.0000000); //object(cj_bush_prop2) (8)
	CreateObject(1231,212.9600100,-1839.6700000,4.7000000,0.0000000,0.0000000,175.0000000); //object(streetlamp2) (3)
	CreateObject(1231,197.0300000,-1839.7000000,4.7000000,0.0000000,0.0000000,359.0000000); //object(streetlamp2) (4)
	CreateObject(1231,251.2000000,-1839.7000000,4.7000000,0.0000000,0.0000000,179.9950000); //object(streetlamp2) (5)
	CreateObject(1231,235.2000000,-1839.7100000,4.7000000,0.0000000,0.0000000,358.9950000); //object(streetlamp2) (6)
	CreateObject(1445,185.7000000,-1826.4000000,3.7000000,0.0000000,0.0000000,0.0000000); //object(dyn_ff_stand) (1)
	CreateObject(1445,183.2000000,-1826.4000000,3.7000000,0.0000000,0.0000000,0.0000000); //object(dyn_ff_stand) (2)
	CreateObject(3618,261.7000100,-1820.8800000,5.5000000,0.0000000,0.0000000,0.0000000); //object(nwlaw2husjm3_law2) (1)
	CreateObject(1646,254.0000000,-1832.5000000,3.0000000,0.0000000,0.0000000,0.0000000); //object(lounge_towel_up) (1)
	CreateObject(1646,255.0000000,-1832.5000000,3.0000000,0.0000000,0.0000000,0.0000000); //object(lounge_towel_up) (2)
	CreateObject(1646,256.0000000,-1832.5000000,3.0000000,0.0000000,0.0000000,0.0000000); //object(lounge_towel_up) (3)
	CreateObject(1597,257.1000100,-1830.6000000,5.3000000,0.0000000,0.0000000,90.0000000); //object(cntrlrsac1) (7)
	CreateObject(642,257.0000000,-1832.5000000,4.0000000,0.0000000,0.0000000,0.0000000); //object(kb_canopy_test) (4)
	CreateObject(1646,258.0000000,-1832.5000000,3.0000000,0.0000000,0.0000000,0.0000000); //object(lounge_towel_up) (4)
	CreateObject(1646,259.0000000,-1832.5000000,3.0000000,0.0000000,0.0000000,0.0000000); //object(lounge_towel_up) (5)
	CreateObject(1646,260.0000000,-1832.5000000,3.0000000,0.0000000,0.0000000,0.0000000); //object(lounge_towel_up) (6)
	CreateObject(1361,235.6000100,-1814.5000000,4.0000000,0.0000000,0.0000000,0.0000000); //object(cj_bush_prop2) (9)
	CreateObject(1368,237.3999900,-1814.5000000,3.9500000,0.0000000,1.0000000,0.0000000); //object(cj_blocker_bench) (6)
	CreateObject(1361,239.2000000,-1814.5000000,4.0000000,0.0000000,0.0000000,0.0000000); //object(cj_bush_prop2) (10)
	CreateObject(1361,250.6000100,-1814.5000000,4.0000000,0.0000000,0.0000000,0.0000000); //object(cj_bush_prop2) (11)
	CreateObject(1368,248.8000000,-1814.5000000,3.9000000,0.0000000,0.0000000,0.0000000); //object(cj_blocker_bench) (7)
	CreateObject(1361,246.9299900,-1814.5000000,4.0000000,0.0000000,0.0000000,0.0000000); //object(cj_bush_prop2) (12)
	CreateObject(2226,257.0000000,-1832.8000000,2.7000000,0.0000000,0.0000000,0.0000000); //object(low_hi_fi_3) (1)
	CreateObject(2754,244.6000100,-1788.1000000,4.2000000,0.0000000,0.0000000,90.0000000); //object(otb_machine) (1)
	CreateObject(2754,259.1000100,-1822.2000000,4.2000000,0.0000000,0.0000000,90.0000000); //object(otb_machine) (2)
	CreateObject(2755,204.8000000,-1831.0000000,3.0000000,90.0000000,0.0000000,0.0000000); //object(dojo_wall) (1)
	CreateObject(2755,243.1000100,-1831.0000000,2.8000000,90.0000000,0.0000000,0.0000000); //object(dojo_wall) (2)
	CreateObject(2098,204.8000000,-1831.1000000,5.0000000,0.0000000,0.0000000,0.0000000); //object(cj_slotcover1) (1)
	CreateObject(2098,243.1000100,-1831.1000000,4.7000000,0.0000000,0.0000000,0.0000000); //object(cj_slotcover1) (2)
	CreateObject(13607,-2351.8999000,-1630.5000000,726.0999800,0.0000000,0.0000000,0.0000000); //object(ringwalls) (1)
	CreateObject(8417,-2372.2000000,-1651.9000000,722.2999900,0.0000000,0.0000000,0.0000000); //object(bballcourt01_lvs) (2)
	CreateObject(8417,-2331.3000500,-1651.9000200,722.2999900,0.0000000,0.0000000,0.0000000); //object(bballcourt01_lvs) (3)
	CreateObject(8417,-2372.5000000,-1609.1999500,722.2999900,0.0000000,0.0000000,0.0000000); //object(bballcourt01_lvs) (4)
	CreateObject(8417,-2331.3999000,-1609.4000000,722.2999900,0.0000000,0.0000000,0.0000000); //object(bballcourt01_lvs) (5)
	CreateObject(3452,-2378.0000000,-1680.4004000,725.4000200,0.0000000,0.0000000,0.0000000); //object(bballintvgn1) (3)
	CreateObject(3452,-2334.8000000,-1680.3000000,725.4000200,0.0000000,0.0000000,0.0000000); //object(bballintvgn1) (5)
	CreateObject(3453,-2307.5000000,-1673.9000000,725.4000200,0.0000000,0.0000000,0.0000000); //object(bballintvgn2) (3)
	CreateObject(3452,-2348.4001000,-1680.4000000,725.4000200,0.0000000,0.0000000,0.0000000); //object(bballintvgn1) (7)
	CreateObject(3453,-2394.7000000,-1674.9000000,725.4000200,0.0000000,0.0000000,270.0000000); //object(bballintvgn2) (4)
	CreateObject(3452,-2401.1001000,-1645.6000000,725.4000200,0.0000000,0.0000000,270.0000000); //object(bballintvgn1) (8)
	CreateObject(3453,-2308.3999000,-1586.2000000,725.4000200,0.0000000,0.0000000,90.0000000); //object(bballintvgn2) (5)
	CreateObject(3453,-2395.7000000,-1587.2000000,725.4000200,0.0000000,0.0000000,180.0000000); //object(bballintvgn2) (6)
	CreateObject(3452,-2401.1001000,-1616.0000000,725.4000200,0.0000000,0.0000000,270.0000000); //object(bballintvgn1) (9)
	CreateObject(3452,-2366.5996000,-1580.7998000,725.4000200,0.0000000,0.0000000,179.9950000); //object(bballintvgn1) (10)
	CreateObject(3452,-2337.2000000,-1580.8000000,725.4000200,0.0000000,0.0000000,179.9950000); //object(bballintvgn1) (11)
	CreateObject(3452,-2302.0015000,-1615.3000000,725.4000200,0.0000000,0.0000000,90.0000000); //object(bballintvgn1) (12)
	CreateObject(3452,-2302.0000000,-1644.2002000,725.4000200,0.0000000,0.0000000,89.9840000); //object(bballintvgn1) (13)
	CreateObject(7617,-2355.3000000,-1570.6000000,738.7999900,0.0000000,0.0000000,0.0000000); //object(vgnbballscorebrd) (1)
	CreateObject(7617,-2352.3999000,-1690.5000000,738.7999900,0.0000000,0.0000000,0.0000000); //object(vgnbballscorebrd) (2)
	CreateObject(3398,-2313.1001000,-1688.6000000,741.7000100,0.0000000,0.0000000,0.0000000); //object(cxrf_floodlite_) (1)
	CreateObject(3398,-2390.2000000,-1689.2000000,741.7000100,0.0000000,0.0000000,0.0000000); //object(cxrf_floodlite_) (2)
	CreateObject(3398,-2390.0000000,-1572.1000000,741.7000100,0.0000000,0.0000000,0.0000000); //object(cxrf_floodlite_) (3)
	CreateObject(3398,-2312.8000000,-1572.2000000,741.7000100,0.0000000,0.0000000,0.0000000); //object(cxrf_floodlite_) (4)
	CreateObject(1232,-2370.3000000,-1672.2000000,724.4000200,0.0000000,0.0000000,0.0000000); //object(streetlamp1) (1)
	CreateObject(1232,-2365.3999000,-1672.2000000,724.4000200,0.0000000,0.0000000,0.0000000); //object(streetlamp1) (2)
	CreateObject(1232,-2322.5000000,-1671.9000000,724.4002700,0.0000000,0.0000000,0.0000000); //object(streetlamp1) (3)
	CreateObject(1232,-2327.0000000,-1672.1000000,724.4000200,0.0000000,0.0000000,0.0000000); //object(streetlamp1) (4)
	CreateObject(1232,-2310.1001000,-1631.4000000,724.4000200,0.0000000,0.0000000,0.0000000); //object(streetlamp1) (5)
	CreateObject(1232,-2310.5000000,-1636.6000000,724.4000200,0.0000000,0.0000000,0.0000000); //object(streetlamp1) (6)
	CreateObject(1232,-2310.7000000,-1602.8000000,724.4000200,0.0000000,0.0000000,0.0000000); //object(streetlamp1) (7)
	CreateObject(1232,-2310.7000000,-1607.8000000,724.4000200,0.0000000,0.0000000,0.0000000); //object(streetlamp1) (8)
	CreateObject(1232,-2349.8000000,-1589.2000000,724.4000200,0.0000000,0.0000000,0.0000000); //object(streetlamp1) (9)
	CreateObject(1232,-2344.7998000,-1589.4004000,724.4000200,0.0000000,0.0000000,0.0000000); //object(streetlamp1) (10)
	CreateObject(1232,-2379.2000000,-1588.9000000,724.4000200,0.0000000,0.0000000,0.0000000); //object(streetlamp1) (11)
	CreateObject(1232,-2373.8999000,-1589.0000000,724.4000200,0.0000000,0.0000000,0.0000000); //object(streetlamp1) (12)
	CreateObject(1232,-2392.3000000,-1628.7000000,724.4000200,0.0000000,0.0000000,0.0000000); //object(streetlamp1) (13)
	CreateObject(1232,-2392.2000000,-1623.4000000,724.4000200,0.0000000,0.0000000,0.0000000); //object(streetlamp1) (14)
	CreateObject(1232,-2392.1001000,-1658.4000000,724.4000200,0.0000000,0.0000000,0.0000000); //object(streetlamp1) (15)
	CreateObject(1232,-2392.3000000,-1653.1000000,724.4000200,0.0000000,0.0000000,0.0000000); //object(streetlamp1) (16)
	CreateObject(3434,-2295.1001000,-1627.7000000,741.7999900,0.0000000,0.0000000,270.0000000); //object(skllsgn01_lvs) (2)
	CreateObject(7313,-2352.6001000,-1689.1000000,733.7999900,0.0000000,0.0000000,180.0000000); //object(vgsn_scrollsgn01) (1)
	CreateObject(7313,-2355.5000000,-1572.1000000,733.7999900,0.0000000,0.0000000,0.0000000); //object(vgsn_scrollsgn01) (2)
	CreateObject(7231,-2412.1001000,-1631.4000000,749.2000100,0.0000000,0.0000000,90.0000000); //object(clwnpocksgn_d) (2)
	CreateObject(996,-2361.7000000,-1671.5000000,723.5000000,0.0000000,0.0000000,0.0000000); //object(lhouse_barrier1) (1)
	CreateObject(996,-2383.3000000,-1671.5000000,723.5000000,0.0000000,0.0000000,0.0000000); //object(lhouse_barrier1) (2)
	CreateObject(996,-2353.3000000,-1671.5000000,723.5000000,0.0000000,0.0000000,0.0000000); //object(lhouse_barrier1) (3)
	CreateObject(996,-2345.0000000,-1671.5000000,723.5000000,0.0000000,0.0000000,0.0000000); //object(lhouse_barrier1) (4)
	CreateObject(996,-2336.7000000,-1671.5000000,723.5000000,0.0000000,0.0000000,0.0000000); //object(lhouse_barrier1) (5)
	CreateObject(996,-2316.2000000,-1670.8000000,723.5000000,0.0000000,0.0000000,46.0000000); //object(lhouse_barrier1) (6)
	CreateObject(996,-2311.0000000,-1664.7000000,723.5000000,0.0000000,0.0000000,90.0000000); //object(lhouse_barrier1) (7)
	CreateObject(996,-2311.0000000,-1656.4000000,723.5000000,0.0000000,0.0000000,89.9950000); //object(lhouse_barrier1) (8)
	CreateObject(996,-2311.0000000,-1648.1000000,723.5000000,0.0000000,0.0000000,89.9950000); //object(lhouse_barrier1) (9)
	CreateObject(996,-2310.8999000,-1628.9000000,723.5000000,0.0000000,0.0000000,89.9950000); //object(lhouse_barrier1) (10)
	CreateObject(996,-2310.8999000,-1620.6000000,723.5000000,0.0000000,0.0000000,89.9950000); //object(lhouse_barrier1) (11)
	CreateObject(996,-2311.2000000,-1595.0000000,723.5000000,0.0000000,0.0000000,133.9950000); //object(lhouse_barrier1) (12)
	CreateObject(996,-2317.3999000,-1589.5000000,723.5000000,0.0000000,0.0000000,179.9890000); //object(lhouse_barrier1) (13)
	CreateObject(996,-2325.7000000,-1589.6000000,723.5000000,0.0000000,0.0000000,179.9890000); //object(lhouse_barrier1) (14)
	CreateObject(996,-2334.0000000,-1589.7000000,723.5000000,0.0000000,0.0000000,179.9890000); //object(lhouse_barrier1) (15)
	CreateObject(996,-2353.3000000,-1589.8000000,723.5000000,0.0000000,0.0000000,179.9890000); //object(lhouse_barrier1) (16)
	CreateObject(996,-2362.0000000,-1589.7000000,723.5000000,0.0000000,0.0000000,179.9890000); //object(lhouse_barrier1) (17)
	CreateObject(996,-2386.3999000,-1590.2000000,723.5000000,0.0000000,0.0000000,219.9890000); //object(lhouse_barrier1) (18)
	CreateObject(996,-2392.2000000,-1596.2000000,723.5000000,0.0000000,0.0000000,269.9850000); //object(lhouse_barrier1) (19)
	CreateObject(996,-2392.2000000,-1604.5000000,723.5000000,0.0000000,0.0000000,269.9840000); //object(lhouse_barrier1) (20)
	CreateObject(996,-2392.2000000,-1612.8000000,723.5000000,0.0000000,0.0000000,269.9840000); //object(lhouse_barrier1) (21)
	CreateObject(996,-2392.2000000,-1631.9000000,723.5000000,0.0000000,0.0000000,269.9840000); //object(lhouse_barrier1) (22)
	CreateObject(996,-2392.2000000,-1640.4000000,723.5000000,0.0000000,0.0000000,269.9840000); //object(lhouse_barrier1) (23)
	CreateObject(996,-2391.6001000,-1666.0000000,723.5000000,0.0000000,0.0000000,315.9840000); //object(lhouse_barrier1) (24)
	CreateObject(5154,-2442.3999000,-1633.4000000,763.5000000,0.0000000,0.0000000,0.0000000); //object(dk_cargoshp03d) (1)
	CreateObject(5154,-2256.7000000,-1624.8000000,763.5000000,0.0000000,0.0000000,0.0000000); //object(dk_cargoshp03d) (2)
	CreateObject(3524,-2250.5000000,-1615.0000000,769.5999800,0.0000000,0.0000000,322.0000000); //object(skullpillar01_lvs) (2)
	CreateObject(3524,-2250.5000000,-1634.5000000,769.5999800,0.0000000,0.0000000,225.9980000); //object(skullpillar01_lvs) (3)
	CreateObject(3524,-2263.3000000,-1634.7000000,769.5999800,0.0000000,0.0000000,137.9940000); //object(skullpillar01_lvs) (4)
	CreateObject(3524,-2263.1001000,-1615.1000000,769.5999800,0.0000000,0.0000000,41.9940000); //object(skullpillar01_lvs) (5)
	CreateObject(3524,-2435.8999000,-1623.7000000,769.5999800,0.0000000,0.0000000,321.9980000); //object(skullpillar01_lvs) (6)
	CreateObject(3524,-2448.8999000,-1623.8000000,769.5999800,0.0000000,0.0000000,47.9980000); //object(skullpillar01_lvs) (7)
	CreateObject(3524,-2448.8999000,-1643.2000000,769.5999800,0.0000000,0.0000000,141.9940000); //object(skullpillar01_lvs) (8)
	CreateObject(3524,-2435.8999000,-1643.2000000,769.5999800,0.0000000,0.0000000,223.9930000); //object(skullpillar01_lvs) (9)
	CreateObject(2611,-2171.6001000,645.5999800,1053.3000000,0.0000000,0.0000000,90.0000000); //object(police_nb1) (1)
}
