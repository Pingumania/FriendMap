local _, ns = ...

local RESTRICTED_TYPES = {
	[Enum.AddOnRestrictionType.Chat] = true,
	[Enum.AddOnRestrictionType.Map] = true,
}

local friends = {}

local function RefreshCharacterFriends()
	local info, englishClass

	for index = 1, C_FriendList.GetNumFriends() do
		info = C_FriendList.GetFriendInfoByIndex(index)

		if info and info.connected then
			englishClass = select(2, GetPlayerInfoByGUID(info.guid))

			friends[info.name] = {
				classFile = englishClass,
				className = info.className,
				level = info.level,
			}
		end
	end
end

local function RefreshBattleNetFriends()
	local accountInfo, gameAccountInfo, name

	for index = 1, BNGetNumFriends() do
		accountInfo = C_BattleNet.GetFriendAccountInfo(index)
		gameAccountInfo = accountInfo and accountInfo.gameAccountInfo

		if gameAccountInfo and gameAccountInfo.isOnline and gameAccountInfo.characterName then
			name = gameAccountInfo.characterName

			if not friends[name] then
				friends[name] = {
					classFile = gameAccountInfo.classFilename,
					className = gameAccountInfo.className,
					level = gameAccountInfo.characterLevel,
				}
			end
		end
	end
end

function ns:RefreshFriends()
	wipe(friends)

	RefreshCharacterFriends()
	RefreshBattleNetFriends()
end

function ns:GetFriend(name)
	return friends[Ambiguate(name, "none")]
end

function ns:IsFriend(name)
	return ns:GetFriend(name) ~= nil
end

function ns:SetChannel(name, password)
	ns:LeaveChannel()

	FriendMapDB.channel = name
	FriendMapDB.password = password

	if name then
		ns:JoinChannel(name, password)
	end
end

function ns:OnLoad()
	if not FriendMapDB then
		_G.FriendMapDB = {}
	end
end

function ns:OnLogin()
	ns.playerName = UnitName("player")

	ns:RefreshFriends()

	if FriendMapDB.channel then
		ns:JoinChannel(FriendMapDB.channel, FriendMapDB.password)
	end
end

function ns:FRIENDLIST_UPDATE()
	ns:RefreshFriends()
end

function ns:BN_FRIEND_ACCOUNT_ONLINE()
	ns:RefreshFriends()
end

function ns:BN_FRIEND_ACCOUNT_OFFLINE()
	ns:RefreshFriends()
end

function ns:ADDON_RESTRICTION_STATE_CHANGED(restrictionType, state)
	if not RESTRICTED_TYPES[restrictionType] then
		return
	end

	if state == Enum.AddOnRestrictionState.Activating then
		ns:BroadcastGone()
		ns:StopBroadcasting()
		ns:RemoveAllPins()
	elseif state == Enum.AddOnRestrictionState.Inactive then
		ns:StartBroadcasting()
	end
end
