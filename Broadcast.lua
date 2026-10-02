local _, ns = ...

local AceComm = LibStub("AceComm-3.0")
local HBD = LibStub("HereBeDragons-2.0")

local PREFIX = "FriendMap"
local TICK_INTERVAL = 2
local HELLO = "hello"
local ACK = "ack"
local GONE = "gone"

local peers = {}
local ticker
local paused

local function Serialize(instanceId, x, y)
	if not instanceId then
		return GONE
	end

	return string.format("%d:%.4f:%.4f", instanceId, x, y)
end

local function Deserialize(message)
	local instanceId, x, y = string.match(message, "^(%d+):([%d%.]+):([%d%.]+)$")
	if not instanceId then
		return nil
	end

	return tonumber(instanceId), tonumber(x), tonumber(y)
end

local function Send(message, name)
	AceComm:SendCommMessage(PREFIX, message, "WHISPER", name)
end

local function AddPeer(name)
	peers[name] = true

	ns:StartBroadcasting()
end

function ns:IsPeer(name)
	return peers[name] ~= nil
end

function ns:RemovePeer(name)
	peers[name] = nil

	ns:RemovePin(name)

	if not next(peers) then
		ns:StopBroadcasting()
	end
end

function ns:Ping(name)
	Send(HELLO, name)
end

function ns:SendGone(name)
	Send(GONE, name)
end

function ns:Broadcast()
	local x, y, instanceId = HBD:GetPlayerWorldPosition()
	local message = Serialize(instanceId, x, y)

	for name in next, peers do
		Send(message, name)
	end
end

function ns:StartBroadcasting()
	if ticker or paused or not next(peers) then
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

function ns:PauseBroadcasting()
	for name in next, peers do
		Send(GONE, name)
	end

	paused = true

	ns:StopBroadcasting()
end

function ns:ResumeBroadcasting()
	paused = nil

	ns:StartBroadcasting()
end

function ns:OnCommReceived(prefix, message, distribution, sender)
	if prefix ~= PREFIX or distribution ~= "WHISPER" or paused then
		return
	end

	sender = Ambiguate(sender, "none")

	if not ns:IsFriend(sender) then
		return
	end

	if message == HELLO then
		Send(ACK, sender)
		AddPeer(sender)
	elseif message == ACK then
		AddPeer(sender)
	elseif message == GONE then
		ns:RemovePin(sender)
	else
		local instanceId, x, y = Deserialize(message)

		if instanceId then
			ns:UpdatePin(sender, instanceId, x, y)
		end
	end
end

AceComm:RegisterComm(PREFIX, function(...) ns:OnCommReceived(...) end)
