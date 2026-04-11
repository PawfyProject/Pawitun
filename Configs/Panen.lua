loadstring(game:HttpGet("https://raw.githubusercontent.com/FnDXueyi/list/refs/heads/main/game"))()
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
        ["Whitelist Username"] = {"Lumibackup31","Lumibackup32","Lumibackup33","Lumibackup34"},
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
		["Auto Element Rod 2"] = false,
        ["Auto Diamond Rod"] = false,
        ["Unlock Ancient Ruin"] = false,
        ["Allowed Sacrifice"] = {
            "King Crab",
            "Queen Crab",

        },
        ["FARM_LOC_SECRET_SACRIFICE"] = "Treasure Room",

        ["Minimum Rod"] = "Ghostfinn Rod",
    },
    ["WebHook"] = {
        ["Link Webhook"] = "https://discord.com/api/webhooks/1415885672874508431/fxHWodMl_EfflMdoFiSargIauyhxNNlHosDzTVJ3SEt2GhxEIaa3LyWKzX735KQn4WvE",
        ["Auto Sending"] = true,
        ["Category"] = {"Secret"},
            {Name = "Ruby", Variant = "Gemstone"},
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
            ["Mutation Totem"] = 24,
        },
    },
    ["Event"] = {
        ["Start Farm"] = true,
        ["Minimum Rod"] = "Ghostfinn Rod",
        ["Event List"] = {
			["Ancient Lochness Monster"] = true,
            --"Thunderzilla Hunt",
		},
    },
    ["Enchant"] = {
        ["Auto Enchant"] = false,
        ["Roll Enchant"] = false,
        ["Evolved Roll Enchant"] = false,
        ["Enchant List"] = {
            "Cursed I",
            "Reeler I",
            "Empowered I",
        },
        ["Second Enchant"] = false,
        ["Allowed Sacrifice"] = {
            "Ghost Shark",
            "Gladiator Shark", 
            "Blob Shark", 
        },
        ["Second Enchant List"] = {
            "Reeler I",
            "Big Hunter I",
            "Cursed I",
            "Empowered I,",
        },
        ["Minimum Rod"] = "Element Rod",
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
        },
        ["Location Rods"] = {
            ["Kohana Volcano"] = {"Starter Rod"},
            ["Tropical Grove"] = {"Grass Rod", "Midnight Rod"},
            ["Sisyphus Statue"] = {"Astral Rod", "Diamond Rod"},		
            ["Ancient Ruin"] = {"Ghostfinn Rod","Element Rod"},
		},
        ["Endgame"] = "Diamond Rod",
    },

    ["ExtremeFpsBoost"] = true,
    ["UltimatePerformance"] = true,
    ["Disable3DRender"] = true,
    ["AutoRemovePlayer"] = true,

    ["AutoReconnect"] = false,
    ["HideGUI"] = false,
    ["Debug"] = false,
    ["EXIT_MAP_IF_DISCONNECT"] = false,
}
script_key="014D239D29E821534EFDDFAC64E30F95";

local s,r repeat 

s,r=pcall(function()return game:HttpGet("https://raw.githubusercontent.com/FnDXueyi/roblog/refs/heads/main/fishit-78c86024ea87c8eca577549807421962.lua")end)wait(1)until s;loadstring(r)()
