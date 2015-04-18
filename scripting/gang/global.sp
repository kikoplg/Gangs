enum Cache_Gang
{
	iGangID = 0,
	String:sGangName[64],
	iPoints,
	bool:bChat,
	bool:bPrefix,
	String:sPrefixColor[64],
	iMaxMembers,
	iMembers
};

enum Cache_Gang_Members
{
	iGangID = 0,
	String:sCommunityID[64],
	iAccessLevel
};

enum Cache_Gang_Skills
{
	iGangID = 0,
	iSkillID,
	iLevel
};

enum Cache_Skills
{
	iSkillID = 0,
	String:sSkillName[64],
	iMaxLevel
}

// Cache
int g_iCacheGang[Cache_Gang];
ArrayList g_aCacheGang = null;

int g_iCacheGangMembers[Cache_Gang_Members];
ArrayList g_aCacheGangMembers = null;

int g_iCacheGangSkills[Cache_Gang_Skills];
ArrayList g_aCacheGangSkills = null;

int g_iCacheSkills[Cache_Skills];
ArrayList g_aCacheSkills = null;

// Database
Handle g_hDatabase;

// Fowards
Handle g_hSQLConnected;
Handle g_hGangCreated;
Handle g_hGangLeft;
Handle g_hGangDelete;
Handle g_hGangRename;

// Client stuff
char g_sClientID[MAXPLAYERS + 1][64];
bool g_bIsInGang[MAXPLAYERS + 1] =  { false, ... };
int g_iClientGang[MAXPLAYERS + 1] =  { 0, ... };

// Cvars
// CreateGang
ConVar g_cGangCreateEnable = null;
ConVar g_cGangCreateMinLen = null;
ConVar g_cGangCreateMaxLen = null;
ConVar g_cGangCreateRegex = null;

// RenameGang
ConVar g_cGangRenameEnable = null;
ConVar g_cGangRenameRank = null;
ConVar g_cGangRenameCost = null;

// General settings
ConVar g_cGangMenuDisplayTime = null;