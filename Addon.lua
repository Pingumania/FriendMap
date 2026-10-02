local _, ns = ...

local RESTRICTED_TYPES = {
	[Enum.AddOnRestrictionType.Chat] = true,
	[Enum.AddOnRestrictionType.Map] = true,
}

local MAX_RACE_ID = 100

local friends = {}
local previous = {}
local raceFactions = {}
local playerFaction

local function CacheRaceFactions()
	local race, faction

	for raceID = 1, MAX_RACE_ID do
		race = C_CreatureInfo.GetRaceInfo(raceID)
		faction = race and C_CreatureInfo.GetFactionInfo(raceID)

		if faction then
			raceFactions[race.clientFileString] = faction.groupTag
		end
	end
end

local function IsOtherFaction(englishRace)
	local faction = raceFactions[englishRace]

	return faction ~= nil and faction ~= "Neutral" and faction ~= playerFaction
end

local function IsCandidate(info)
	if not info then
		return false
	end

	local _, englishClass, _, englishRace = GetPlayerInfoByGUID(info.guid)

	return not IsOtherFaction(englishRace), englishClass
end

local function RefreshCharacterFriends()
	local info, candidate, englishClass

	for index = 1, C_FriendList.GetNumFriends() do
		info = C_FriendList.GetFriendInfoByIndex(index)
		candidate, englishClass = IsCandidate(info)

		if candidate and info.connected then
			friends[info.name] = {
				classFile = englishClass,
				className = info.className,
				level = info.level,
			}
		end
	end
end

function ns:RefreshFriends()
	if not playerFaction then
		return
	end

	friends, previous = previous, friends
	wipe(friends)

	RefreshCharacterFriends()

	for name in next, friends do
		if not previous[name] then
			ns:Ping(name)
		end
	end

	for name in next, previous do
		if not friends[name] then
			ns:RemovePeer(name)
		end
	end
end

function ns:PingFriends()
	for name in next, friends do
		if not ns:IsPeer(name) then
			ns:Ping(name)
		end
	end
end

function ns:GetFriend(name)
	return friends[Ambiguate(name, "none")]
end

function ns:IsFriend(name)
	return ns:GetFriend(name) ~= nil
end

function ns:OnLoad()
	if not FriendMapDB then
		_G.FriendMapDB = {}
	end

	FriendMapDB.channel = nil
	FriendMapDB.password = nil
end

function ns:OnLogin()
	playerFaction = UnitFactionGroup("player")

	CacheRaceFactions()
	ns:RefreshFriends()
end

function ns:FRIENDLIST_UPDATE()
	ns:RefreshFriends()
end

function ns:ADDON_RESTRICTION_STATE_CHANGED(restrictionType, state)
	if not RESTRICTED_TYPES[restrictionType] then
		return
	end

	if state == Enum.AddOnRestrictionState.Activating then
		ns:PauseBroadcasting()
		ns:RemoveAllPins()
	elseif state == Enum.AddOnRestrictionState.Inactive then
		ns:ResumeBroadcasting()
		ns:PingFriends()
	end
end
