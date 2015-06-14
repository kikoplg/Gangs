public int Native_IsClientInGang(Handle plugin, int numParams)
{
	return g_bIsInGang[GetNativeCell(1)];
}

public int Native_GetClientGang(Handle plugin, int numParams)
{
	return g_iClientGang[GetNativeCell(1)];
}

public int Native_GetGangName(Handle plugin, int numParams)
{
	char sName[64];
	int gangid = GetNativeCell(1);
	
	for (int i = 0; i < g_aCacheGang.Length; i++)
	{
		int iGang[Cache_Gang];
		g_aCacheGang.GetArray(i, iGang[0]);

		if (iGang[iGangID] == gangid)
		{
			strcopy(sName, sizeof(sName), iGang[sGangName]);
			break;
		}
	}

	SetNativeString(2, sName, GetNativeCell(3), false);
}

public int Native_GetClientAccessLevel(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	char sBuffer[64];
	GetClientAuthId(client, AuthId_SteamID64, sBuffer, sizeof(sBuffer));
	
	for (int i = 0; i < g_aCacheGangMembers.Length; i++)
	{
		int iGangMembers[Cache_Gang_Members];
		g_aCacheGangMembers.GetArray(i, iGangMembers[0]);
		
		if(StrEqual(sBuffer, iGangMembers[sCommunityID], false))
		{
			return iGangMembers[iAccessLevel];
		}
		break;
	}
	return -1;
}

public int Native_LeftClientGang(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	RemoveClientFromGang(client, Gang_GetClientGang(client));
	
	g_bIsInGang[client] = false;
	g_iClientGang[client] = 0;
}

public int Native_CreateClientGang(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if(client < 1 || !IsClientInGame(client))
	{
		ThrowNativeError(SP_ERROR_ABORTED, "Client %d is invalid!");
		return;
	}
	
	char sGang[64];
	GetNativeString(2, sGang, sizeof(sGang));
	
	if(!CheckGangName(client, sGang))
	{
		PrintToChat(client, "Die Gang (%s) konnte nicht erstellt werden!", sGang); // TODO: Translation
		return;
	}
	
	CreateGang(client, sGang);
}

public int Native_RenameClientGang(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int gangid = GetNativeCell(2);
	
	char sGang[64];
	GetNativeString(3, sGang, sizeof(sGang));
	
	if(client < 1 || !IsClientInGame(client))
	{
		ThrowNativeError(SP_ERROR_ABORTED, "Client %d is invalid!");
		return;
	}
	
	if(!CheckGangRename(client, sGang))
	{
		PrintToChat(client, "Die Gang (%s) konnte nicht umbenannt werden!", sGang); // TODO: Translation
		return;
	}
	
	if (Gang_GetClientAccessLevel(client) < g_cGangRenameRank.IntValue)
	{
		PrintToChat(client, "Sie besitzen nicht genügend Rechte!"); // TODO: Translation
		return;
	}
	
	if(Gang_GetGangPoints(gangid) < g_cGangRenameCost.IntValue)
	{
		PrintToChat(client, "Die Gang besitzt nicht genug Punkte!"); // TODO: Translation
		return;
	}
	
	RenameGang(client, gangid, sGang);
}

public int Native_DeleteClientGang(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int gangid = GetNativeCell(2);
	
	if (client < 1 || !IsClientInGame(client))
	{
		ThrowNativeError(SP_ERROR_ABORTED, "Client %d is invalid!");
		return;
	}
	
	if (!g_bIsInGang[client])
	{
		PrintToChat(client, "Sie sind in keiner Gang!"); // TODO: Translation
		return;
	}
	
	if(Gang_GetClientAccessLevel(client) < GANG_LEADER)
	{
		PrintToChat(client, "Sie sind nicht Founder der Gang!"); // TODO: Translation
		return;
	}
	
	DeleteGang(client, gangid);
}

public int Native_OpenClientGang(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (client < 1 || !IsClientInGame(client))
	{
		ThrowNativeError(SP_ERROR_ABORTED, "Client %d is invalid!");
		return;
	}
	
	if (!g_bIsInGang[client])
	{
		PrintToChat(client, "Sie sind in keiner Gang!"); // TODO: Translation
		return;
	}
	
	OpenClientGang(client);
}

public int Native_GetGangMaxMembers(Handle plugin, int numParams)
{
	int gangid = GetNativeCell(1);
	
	for (int i = 0; i < g_aCacheGang.Length; i++)
	{
		int iGang[Cache_Gang];
		g_aCacheGang.GetArray(i, iGang[0]);

		if (iGang[iGangID] == gangid)
		{
			return iGang[iMaxMembers];
		}
	}
	return 0;
}

public int Native_GetGangMembersCount(Handle plugin, int numParams)
{
	int gangid = GetNativeCell(1);
	
	for (int i = 0; i < g_aCacheGang.Length; i++)
	{
		int iGang[Cache_Gang];
		g_aCacheGang.GetArray(i, iGang[0]);

		if (iGang[iGangID] == gangid)
		{
			return iGang[iMembers];
		}
	}
	return 0;
}

public int Native_GetOnlinePlayerCount(Handle plugin, int numParams)
{
	int gangid = GetNativeCell(1);
	
	return GetOnlinePlayerCount(gangid);
}

public int Native_GetGangPoints(Handle plugin, int numParams)
{
	int gangid = GetNativeCell(1);
	
	for (int i = 0; i < g_aCacheGang.Length; i++)
	{
		int iGang[Cache_Gang];
		g_aCacheGang.GetArray(i, iGang[0]);

		if (iGang[iGangID] == gangid)
		{
			return iGang[iPoints];
		}
	}
	return 0;
}

public int Native_AddGangPoints(Handle plugin, int numParams)
{
	int gangid = GetNativeCell(1);
	int points = GetNativeCell(2);
	
	return AddGangPoints(gangid, points);
}

public int Native_RemoveGangPoints(Handle plugin, int numParams)
{
	int gangid = GetNativeCell(1);
	int points = GetNativeCell(2);
	
	return RemoveGangPoints(gangid, points);
}
