public Action Command_RenameGang(int client, int args)
{
	if (client < 1 || !IsClientInGame(client) )
		return Plugin_Handled;
	
	if(!g_cGangRenameEnable.BoolValue)
	{
		ReplyToCommand(client, "Gang Renaming is currently disabled!"); // TODO: Translation
		return Plugin_Handled;
	}
	
	if(args != 1)
	{
		ReplyToCommand(client, "Syntax: sm_renamegang <Name>"); // TODO: Translation
		return Plugin_Handled;
	}
	
	char sArg[64];
	GetCmdArgString(sArg, sizeof(sArg));
	
	Gang_RenameClientGang(client, Gang_GetClientGang(client), sArg);
	return Plugin_Handled;
}

public int Native_RenameClientGang(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int gangid = GetNativeCell(2);
	
	char sGang[64];
	GetNativeString(3, sGang, sizeof(sGang));
	
	if(client < 1 || !IsClientInGame(client))
	{
		return;
	}
	
	if(!CheckGangRename(client, sGang))
		return;
	
	RenameGang(client, gangid, sGang);
}

stock bool CheckGangRename(int client, const char[] sGang)
{
	char sRegex[128];
	g_cGangCreateRegex.GetString(sRegex, sizeof(sRegex));
	Handle hRegex = CompileRegex(sRegex);
	
	if(MatchRegex(hRegex, sGang) != 1)
	{
		PrintToChat(client, "Forbidden chars in gang name"); // TODO: Translation
		return false;
	}
	
	if (strlen(sGang) < g_cGangCreateMinLen.IntValue)
	{
		PrintToChat(client, "Gang name is too short"); // TODO: Translation
		return false;
	}
	
	if (strlen(sGang) > g_cGangCreateMaxLen.IntValue)
	{
		PrintToChat(client, "Gang name is too long"); // TODO: Translation
		return false;
	}
	
	for (int i = 0; i < g_aCacheGang.Length; i++)
	{
		int iGang[Cache_Gang];
		g_aCacheGang.GetArray(i, iGang[0]);

		if (StrEqual(iGang[sGangName], sGang, false))
		{
			PrintToChat(client, "Gang name already in use"); // TODO: Translation
			return false;
		}
	}
	
	int GangID = Gang_GetClientGang(client);
	
	char sOGang[64];
	Gang_GetName(GangID, sOGang, sizeof(sOGang));
	
	if(StrEqual(sOGang, sGang, false))
	{
		ReplyToCommand(client, "Gang name must be different"); // TODO: Translation
		return false;
	}
	
	if(Gang_GetClientLevel(client) < g_cGangRenameRank.IntValue)
	{
		ReplyToCommand(client, "You've not enough access to do this");
		return false;
	}
	
	if(g_cGangRenameCost.IntValue > 0 && Gang_GetPoints(GangID) < g_cGangRenameCost.IntValue)
	{
		ReplyToCommand(client, "Gang hasn't enough points for renaming");
		return false;
	}
	return true;
}

stock void RenameGang(int client, int gangid, const char[] newgangname)
{
	char sQuery[512];
	Format(sQuery, sizeof(sQuery), "UPDATE `gang` SET `GangName` = '%s' WHERE `GangID` = '%d'", newgangname, gangid);
	
	char oldgangname[64];
	Gang_GetName(gangid, oldgangname, sizeof(oldgangname));
	
	Handle hDP = CreateDataPack();
	WritePackCell(hDP, GetClientUserId(client));
	WritePackCell(hDP, gangid);
	WritePackString(hDP, oldgangname);
	WritePackString(hDP, newgangname);
	SQL_TQuery(g_hDatabase, SQL_RenameGang, sQuery, hDP);
}

public void SQL_RenameGang(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (error[0])
	{
		Log_File(_, _, ERROR, "(SQL_RenameGang) Query failed: %s", error);
		CloseHandle(pack);
		return;
	}
		
	char oldgangname[64], newgangname[64];

	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	int gangid = ReadPackCell(pack);
	ReadPackString(pack, oldgangname, sizeof(oldgangname));
	ReadPackString(pack, newgangname, sizeof(newgangname));
	CloseHandle(pack);
	
	PrintToChatAll("%N renamed %s to %s!", client, oldgangname, newgangname); // TODO: Translation
	Log_File(_, _, INFO, "\"%L\" renamed %s to %s!", client, oldgangname, newgangname); // TODO: Translation
	
	for (int i = 0; i < g_aCacheGang.Length; i++)
	{
		int iGang[Cache_Gang];
		g_aCacheGang.GetArray(i, iGang[0]);

		if (iGang[iGangID] == gangid)
		{
			int itmpGang[Cache_Gang];
			
			itmpGang[iGangID] = iGang[iGangID];
			strcopy(itmpGang[sGangName], 64, newgangname);
			itmpGang[iPoints] = iGang[iPoints];
			itmpGang[bChat] = iGang[bChat];
			itmpGang[bPrefix] = iGang[bPrefix];
			strcopy(itmpGang[sPrefixColor], 64, iGang[sPrefixColor]);
			itmpGang[iMaxMembers] = iGang[iMaxMembers];
			itmpGang[iMembers] = iGang[iMembers];

			Log_File(_, _, DEBUG, "(SQL_RenameGang) GangID: %d - OldGangName: %s - NewGangName: %s", gangid, oldgangname, newgangname);

			g_aCacheGang.Erase(i);
			g_aCacheGang.PushArray(itmpGang[0]);
			break;
		}
	}
	
	Call_StartForward(g_hGangRename);
	Call_PushCell(client);
	Call_PushCell(gangid);
	Call_PushString(oldgangname);
	Call_PushString(newgangname);
	Call_Finish();
}
