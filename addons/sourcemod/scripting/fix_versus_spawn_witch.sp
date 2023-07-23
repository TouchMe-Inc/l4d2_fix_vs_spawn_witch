#pragma semicolon              1
#pragma newdecls               required

#include <sourcemod>
#include <sdktools>
#include <colors>


public Plugin myinfo =
{
	name = "FixVersusSpawnWitch",
	author = "TouchMe",
	description = "The plugin corrects the position of the witch in versus mode",
	version = "build_0000",
	url = "https://github.com/TouchMe-Inc/l4d2_versus_spawn_witch"
};


// Gamemode
#define GAMEMODE_VERSUS         "versus"
#define GAMEMODE_VERSUS_REALISM "mutation12"


bool
	g_bGamemodeAvailable = false;

ConVar
	g_cvGameMode = null;


public void OnPluginStart()
{
	(g_cvGameMode = FindConVar("mp_gamemode")).AddChangeHook(OnGamemodeChanged);

	HookEvent("witch_spawn", Event_WitchSpawn);
}

/**
 * Called when a console variable value is changed.
 *
 * @param convar            Ignored.
 * @param sOldGameMode      Ignored.
 * @param sNewGameMode      String containing new gamemode.
 */
public void OnGamemodeChanged(ConVar hConVar, const char[] sOldGameMode, const char[] sNewGameMode) {
	g_bGamemodeAvailable = IsVersusMode(sNewGameMode);
}

/**
 * Called when the map has loaded, servercfgfile (server.cfg) has been executed, and all
 * plugin configs are done executing. This will always be called once and only once per map.
 * It will be called after OnMapStart().
*/
public void OnConfigsExecuted()
{
	char sGameMode[16];
	GetConVarString(g_cvGameMode, sGameMode, sizeof(sGameMode));
	g_bGamemodeAvailable = IsVersusMode(sGameMode);
}

/**
 * Surivivor Killed Witch.
 */
public Action Event_WitchSpawn(Event event, char[] sEventName, bool bDontBroadcast)
{
	if (g_bGamemodeAvailable == false) {
		return Plugin_Continue;
	}

	int iWitchId = event.GetInt("witchid");

	static float vWitch[3];
	if (!InSecondHalfOfRound()) {
		GetClientAbsOrigin(iWitchId, vWitch);
		CPrintToChatAll("Первый спавн ведьмы %f %f %f!", vWitch[0], vWitch[1], vWitch[2]);
	} else {
		TeleportEntity(iWitchId, vWitch, NULL_VECTOR, NULL_VECTOR);
		CPrintToChatAll("Второй спавн ведьмы %f %f %f!", vWitch[0], vWitch[1], vWitch[2]);
	}

	return Plugin_Continue;
}
/**
 * Checks if the current round is the second.
 *
 * @return                  Returns true if is second round, otherwise false.
 */
bool InSecondHalfOfRound() {
	return view_as<bool>(GameRules_GetProp("m_bInSecondHalfOfRound"));
}

/**
 * Is the game mode versus.
 *
 * @param sGameMode         A string containing the name of the game mode.
 *
 * @return                  Returns true if verus, otherwise false.
 */
bool IsVersusMode(const char[] sGameMode) {
	return (StrEqual(sGameMode, GAMEMODE_VERSUS, false) || StrEqual(sGameMode, GAMEMODE_VERSUS_REALISM, false));
}
