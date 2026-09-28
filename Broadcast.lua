local _, ns = ...

local AceComm = LibStub("AceComm-3.0")
local HBD = LibStub("HereBeDragons-2.0")

local PREFIX = "FriendMap"
local TICK_INTERVAL = 2
local GONE = "gone"

local channelName
local ticker

local function Serialize(instanceId, x, y)
	if not instanceId then
		return GONE
	end

	return string.format("%d:%.4f:%.4f", instanceId, x, y)
end

local function Deserialize(message)
	if message == GONE then
		return nil
	end

	local instanceId, x, y = string.match(message, "^(%d+):([%d%.]+):([%d%.]+)$")
	if not instanceId then
		return nil
	end

	return tonumber(instanceId), tonumber(x), tonumber(y)
end

local function Send(message)
	if not channelName then
		return
	end

	local channelId = GetChannelName(channelName)
	if channelId == 0 then
		return
	end

	AceComm:SendCommMessage(PREFIX, message, "CHANNEL", channelId)
end

function ns:Broadcast()
	local x, y, instanceId = HBD:GetPlayerWorldPosition()

	Send(Serialize(instanceId, x, y))
end

function ns:BroadcastGone()
	Send(GONE)
end

function ns:StartBroadcasting()
	if ticker or not channelName then
		return
	end

	ticker = C_Timer.NewTicker(TICK_INTERVAL, function() ns:Broadcast() end)
end

function ns:StopBroadcasting()
	if not ticker then
		return
	end

	ticker:Cancel()
	ticker = nil
end

function ns:JoinChannel(name, password)
	JoinTemporaryChannel(name, password)

	channelName = name

	for index = 1, NUM_CHAT_WINDOWS do
		ChatFrame_RemoveChannel(_G["ChatFrame" .. index], name)
	end

	ns:StartBroadcasting()
end

function ns:LeaveChannel()
	if not channelName then
		return
	end

	ns:BroadcastGone()
	ns:StopBroadcasting()
	LeaveChannelByName(channelName)

	channelName = nil

	ns:RemoveAllPins()
end

function ns:OnCommReceived(prefix, message, distribution, sender)
	if prefix ~= PREFIX or sender == ns.playerName then
		return
	end

	if not ns:IsFriend(sender) then
		return
	end

	local instanceId, x, y = Deserialize(message)

	if instanceId then
		ns:UpdatePin(sender, instanceId, x, y)
	else
		ns:RemovePin(sender)
	end
end

AceComm:RegisterComm(PREFIX, function(...) ns:OnCommReceived(...) end)
