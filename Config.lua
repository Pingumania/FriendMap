local _, ns = ...

ns:RegisterSettings("FriendMapDB", {
	{
		type = "description",
		title = "Friends who run FriendMap see each other on the map.",
	},
})

ns:RegisterSettingsSlash("/friendmap")
