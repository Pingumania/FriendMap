local _, ns = ...

local Pins = LibStub("HereBeDragons-Pins-2.0")

local PIN_TEXTURE = 518448
local PIN_SIZE = 12

local worldPins = {}
local minimapPins = {}

local function OnEnter(self)
	local friend = ns:GetFriend(self.unitName)

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:AddLine(Ambiguate(self.unitName, "none"))

	if friend and friend.level then
		GameTooltip:AddLine(format(FRIENDS_LEVEL_TEMPLATE, friend.level, friend.className or ""), 1, 1, 1)
	end

	GameTooltip:Show()
end

local function CreatePin(name)
	local pin = CreateFrame("Frame", nil, UIParent)
	pin:SetSize(PIN_SIZE, PIN_SIZE)

	local texture = pin:CreateTexture(nil, "OVERLAY")
	texture:SetAllPoints()
	texture:SetTexture(PIN_TEXTURE)

	pin.texture = texture
	pin.unitName = name

	pin:SetScript("OnEnter", OnEnter)
	pin:SetScript("OnLeave", GameTooltip_Hide)

	return pin
end

local function SetClassColor(pin, classFile)
	local color = classFile and C_ClassColor.GetClassColor(classFile)

	if color then
		pin.texture:SetVertexColor(color.r, color.g, color.b)
	else
		pin.texture:SetVertexColor(1, 1, 1)
	end
end

function ns:UpdatePin(name, instanceId, x, y)
	local friend = ns:GetFriend(name)
	local worldPin = worldPins[name]
	local minimapPin = minimapPins[name]

	if not worldPin then
		worldPin = CreatePin(name)
		worldPins[name] = worldPin
	end

	if not minimapPin then
		minimapPin = CreatePin(name)
		minimapPins[name] = minimapPin
	end

	SetClassColor(worldPin, friend and friend.classFile)
	SetClassColor(minimapPin, friend and friend.classFile)

	Pins:AddWorldMapIconWorld(ns, worldPin, instanceId, x, y)
	Pins:AddMinimapIconWorld(ns, minimapPin, instanceId, x, y)
end

function ns:RemovePin(name)
	local worldPin = worldPins[name]
	local minimapPin = minimapPins[name]

	if worldPin then
		Pins:RemoveWorldMapIcon(ns, worldPin)
	end

	if minimapPin then
		Pins:RemoveMinimapIcon(ns, minimapPin)
	end
end

function ns:RemoveAllPins()
	Pins:RemoveAllWorldMapIcons(ns)
	Pins:RemoveAllMinimapIcons(ns)
end
