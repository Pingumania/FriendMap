local _, ns = ...

local LIST_WIDTH = 250
local LIST_ROW_HEIGHT = 24

local blockedList

local function GetBlockedEntries()
	local entries = {}

	for name in next, FriendMapDB.blocked do
		entries[#entries + 1] = {key = name, label = name}
	end

	table.sort(entries, function(a, b) return a.key < b.key end)

	return entries
end

local function Block(name)
	ns:BlockFriend(name)
	blockedList:SetEntries(GetBlockedEntries())
end

local function Unblock(name)
	ns:UnblockFriend(name)
	blockedList:SetEntries(GetBlockedEntries())
end

local function UnblockAll()
	for name in next, FriendMapDB.blocked do
		Unblock(name)
	end
end

ns:RegisterSettings("FriendMapDB", {
	{
		type = "description",
		title = "Friends who run FriendMap see each other on the map. Blocked friends never get your position, and you never see theirs.",
	},
	{
		key = "continentPins",
		type = "toggle",
		title = "Show on continent map",
		tooltip = "Also show pins when the world map shows a whole continent.",
		default = false,
	},
	{
		key = "pinSize",
		type = "slider",
		title = "Pin size",
		default = 20,
		minValue = 8,
		maxValue = 32,
	},
	{
		key = "pinTexture",
		type = "menu",
		title = "Pin texture",
		default = "WhiteCircle-RaidBlips",
		options = {
			{value = "WhiteCircle-RaidBlips", label = "Circle"},
			{value = "WhiteDotCircle-RaidBlips", label = "Dotted circle"},
			{value = "Interface\\WorldMap\\WorldMapPartyIcon", label = "Party icon"},
		},
	},
	{
		type = "custom",
		title = "Block friend",
		tooltip = "Only character friends of your faction are listed.",
		createControl = function(row)
			local dropdown = ns:CreateDropdown(row, ns.GetBlockCandidates, nop, Block)
			dropdown.Dropdown:SetDefaultText(NONE)
			dropdown.IncrementButton:Hide()
			dropdown.DecrementButton:Hide()
			return dropdown
		end,
	},
	{
		type = "custom",
		title = "Blocked",
		onDefaults = UnblockAll,
		createControl = function(row)
			local holder = CreateFrame("Frame", nil, row)
			holder:SetSize(LIST_WIDTH, 1)

			blockedList = ns:CreateOrderedList(holder, LIST_WIDTH, nil, Unblock)
			blockedList:SetPoint("TOPLEFT", holder, "LEFT", 0, LIST_ROW_HEIGHT / 2)
			blockedList:SetEntries(GetBlockedEntries())

			return holder
		end,
	},
})

ns:RegisterSettingsSlash("/friendmap")
