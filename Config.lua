local _, ns = ...

local channelBox, passwordBox

local function Normalize(text)
	text = text and strtrim(text)

	if text == "" then
		return nil
	end

	return text
end

local function GetChannel()
	return FriendMapDB.channel
end

local function SetChannel(text)
	ns:SetChannel(Normalize(text), FriendMapDB.password)
	channelBox:Refresh()
end

local function GetPassword()
	return FriendMapDB.password
end

local function SetPassword(text)
	ns:SetChannel(FriendMapDB.channel, Normalize(text))
	passwordBox:Refresh()
end

ns:RegisterSettings("FriendMapDB", {
	{
		type = "description",
		title = "Pick a channel name and password and share them with your friends. Only players in the same channel see each other. FriendMap stays inactive until a channel is set.",
	},
	{
		type = "custom",
		title = "Channel",
		tooltip = "Press Enter to join the channel. Clear it to leave.",
		onDefaults = function() SetChannel(nil) end,
		createControl = function(row)
			channelBox = ns:CreateEditBox(row, GetChannel, SetChannel)
			return channelBox
		end,
	},
	{
		type = "custom",
		title = "Password",
		tooltip = "Press Enter to rejoin the channel with this password.",
		onDefaults = function() SetPassword(nil) end,
		createControl = function(row)
			passwordBox = ns:CreateEditBox(row, GetPassword, SetPassword)
			passwordBox:SetPassword(true)
			return passwordBox
		end,
	},
})

ns:RegisterSettingsSlash("/friendmap")
