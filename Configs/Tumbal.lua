_G.FishItConfig = _G.FishItConfig or {
    ["Fishing"] = {
        ["Auto Perfect"] = false,
        ["Random Result"] = false,

        ["Auto Favorite"] = true,
        ["Auto Unfavorite"] = false,
        ["Fish Name"] = {
	       "Sacred Guardian Squid",
               {Name = "Ruby", Variant = "Gemstone"}, 
            -- {Variant = "Leviathan's Rage"}, -- Variant Only
            -- {Tier = "Secret", Variant = "Leviathan's Rage"},  -- Tier + Variant
        },

        ["Auto Accept Trade"] = true,
        ["Auto Friend Request"] = true,
    },
    ["Auto Trade"] = {
        ["Enabled"] = true,
        ["Whitelist Username"] = {"lumibackup31"},
        ["Category Fish"] = {
            "Secret",
            -- {Tier = "Mythic", Variant = "Stone"}, -- Tier + Variant
        },
        ["Fish Name"] ={
            {Name = "Ruby", Variant = "Gemstone"},
            -- {Variant = "Leviathan's Rage"}, -- Variant Only
        },
        ["Item Name"] = {
            "Evolved Enchant Stone",
        },
    },
    ["Farm Coin Only"] = {
        ["Enabled"] = false, -- Farm coins only [ cant buy rod, bait, enchant, weather ]
        ["Target"] = 190000,
    },
    ["Selling"] = {
        ["Auto Sell"] = true,
        ["Auto Sell Threshold"] = "Mythic",
        ["Auto Sell Every"] = 50,
    },
    ["Doing Quest"] = {
        ["Auto Ghostfinn Rod"] = false,
        ["Auto Element Rod"] = false,
        ["Auto Diamond Rod"] = false,
        ["Unlock Ancient Ruin"] = false,
        ["Allowed Sacrifice"] = {
            "Ghost Shark",
            "Cryoshade Glider",
            "Panther Eel",
            "Queen Crab",
            "King Crab",
            "Giant Squid",
            "Blob Shark",
            "Ghost Shark",
            "King Jelly", 
            "Mosasaur Shark",
            "Elshark Gran Maja", 
            "Bone Whale", 
            "Gladiator Shark", 
            "Frostborn Shark", 
        },
        ["FARM_LOC_SECRET_SACRIFICE"] = "Treasure Room",

        ["Minimum Rod"] = "Element Rod",
    },
    ["WebHook"] = {
        ["Link Webhook"] = "https://discord.com/api/webhooks/1415885672874508431/fxHWodMl_EfflMdoFiSargIauyhxNNlHosDzTVJ3SEt2GhxEIaa3LyWKzX735KQn4WvE",
        ["Auto Sending"] = true,
        ["Category"] = {"Secret"},

        ["Link Webhook Quest Complete"] = "https://discord.com/api/webhooks/1415885672874508431/fxHWodMl_EfflMdoFiSargIauyhxNNlHosDzTVJ3SEt2GhxEIaa3LyWKzX735KQn4WvE",
    },
    ["Weather"] = {
        ["Auto Buying"] = true,
        ["Minimum Rod"] = "Ghostfinn Rod",
        ["Weather List"] = {
            "Cloudy",
            "Wind",
            "Storm",
            "Radiant",
        },
    },
    ["Potions"] = {
        ["Auto Use"] = true,
        ["Minimum Rod"] = "Astral Rod",
    },
    ["Totems"] = {
        ["Auto Use"] = true,
        ["Minimum Rod"] = "Ghostfinn Rod",
        ["Buy List"] = {
            ["Mutation Totem"] = 1,
            "Luck Totem",
            "Shiny Totem",
        },
    },
    ["Event"] = {
        ["Start Farm"] = false,
        ["Minimum Rod"] = "Ghostfinn Rod",
        ["Event List"] = {
            "Megalodon Hunt",
            "Ghost Shark Hunt",
            "Shark Hunt",
            -- ["Ancient Lochness Monster"] = false,
        },
    },
    ["Enchant"] = {
        ["Auto Enchant"] = false,
        ["Roll Enchant"] = false,
        ["Evolved Roll Enchant"] = false,
        ["Enchant List"] = {
            "Reeler II",
            "Reeler I",
            "SECRET Hunter",
        },
        ["Second Enchant"] = false,
        ["Allowed Sacrifice"] = {
            "Ghost Shark",
            "Cryoshade Glider",
            "Panther Eel",
            "Queen Crab",
            "King Crab",
            "Giant Squid",
            "Blob Shark",
            "Ghost Shark",
            "King Jelly", 
            "Mosasaur Shark",
            "Elshark Gran Maja", 
            "Bone Whale", 
            "Gladiator Shark", 
            "Frostborn Shark", 
        },
        ["Second Enchant List"] = {
            "Reeler I",
            "Perfection",
            "Empowered I,",
        },
        ["Minimum Rod"] = "Ghostfinn Rod",
    },
["Bait List"] = {
        ["Auto Buying"] = false,
        ["Buy List"] = {
        "Midnight Bait",
        "Chroma Bait",
        "Corrupt Bait",
        "Singularity Bait",
        },
        ["Endgame"] = "Singularity Bait",
    },
    ["Rod List"] = {
        ["Auto Buying"] = false,
        ["Buy List"] = {
        "Grass Rod",
        "Midnight Rod",
        "Steampunk Rod",
        "Astral Rod",
        "Ares Rod",
        },
        ["Location Rods"] = {
            ["Kohana Volcano"] = {"Starter Rod"},
            ["Tropical Grove"] = {"Grass Rod", "Midnight Rod", "Astral Rod"},
            ["Treasure Room"] = {"Diamond Rod", "Element Rod", "Ghostfinn Rod"},
        },
        ["Endgame"] = "Diamond Rod",
    },

    ["ExtremeFpsBoost"] = true,
    ["UltimatePerformance"] = true,
    ["Disable3DRender"] = false,
    ["AutoRemovePlayer"] = true,

    ["AutoReconnect"] = false,
    ["HideGUI"] = false,
    ["Debug"] = false,
    ["EXIT_MAP_IF_DISCONNECT"] = false,
}
