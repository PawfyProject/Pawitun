----------------------------------------------------------------
-- ======= [ CONFIGURATION ] =======
----------------------------------------------------------------
local MyLogoID = "https://raw.githubusercontent.com/PawfyProject/Pawitun/refs/heads/main/Logo.jpg" 
local GuiSize = UDim2.fromOffset(460, 520) 

-- Pembersihan UI lama agar tidak menumpuk
if game.CoreGui:FindFirstChild("Fluent") then
    game.CoreGui.Fluent:Destroy()
end

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Fisch Ultimate Trade Control",
    SubTitle = "v2.6 - Custom Logo Edition",
    TabWidth = 130,
    Size = GuiSize,
    Acrylic = false, 
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl,
    MinimizeIcon = MyLogoID -- Ikon kustom dari link GitHub Anda
})

----------------------------------------------------------------
-- ======= [ DATA SCANNER & MAPPING ] =======
----------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Replion, ItemUtility, DataReplion
local MyInventory = {}
local UnfavoriteOnly = false 

local RarityMap = {
    ["1"] = "COMMON", ["2"] = "UNCOMMON", ["3"] = "RARE", 
    ["4"] = "EPIC", ["5"] = "LEGENDARY", ["6"] = "MYTHIC", ["7"] = "SECRET"
}

task.spawn(function()
    pcall(function()
        local packages = ReplicatedStorage:WaitForChild("Packages", 10)
        local shared = ReplicatedStorage:WaitForChild("Shared", 10)
        Replion = require(packages:WaitForChild("Replion"))
        ItemUtility = require(shared:WaitForChild("ItemUtility"))
        repeat 
            DataReplion = Replion.Client:GetReplion("Data")
            task.wait(1)
        until DataReplion ~= nil
    end)
end)

----------------------------------------------------------------
-- ======= [ IMPROVED LOGIC: ACCURATE GROUPING ] =======
----------------------------------------------------------------

local function scanInventory()
    MyInventory = {}
    local data = DataReplion and DataReplion:Get("Inventory")
    local items = (data and data.Items) or {}
    
    for _, item in ipairs(items) do
        local base = ItemUtility:GetItemData(item.Id)
        if base and base.Data and base.Data.Type == "Fish" then
            local isFavorite = item.Favorite or false
            
            -- Filter: Lewati jika ikan difavoritkan dan toggle Unfavorite aktif
            if not (UnfavoriteOnly and isFavorite) then
                table.insert(MyInventory, {
                    Name = base.Data.Name, -- Nama dasar tanpa Variant
                    Tier = tostring(base.Data.Tier),
                    UUID = item.UUID
                })
            end
        end
    end
end

local function getFishDataStrings(mode)
    scanInventory()
    local results = {}
    local counts = {}

    if mode == "Specific" then
        for _, v in ipairs(MyInventory) do
            -- Kelompokkan ikan berdasarkan nama (Variant digabung)
            counts[v.Name] = (counts[v.Name] or 0) + 1
        end
        for name, count in pairs(counts) do
            table.insert(results, name .. " (" .. count .. ")")
        end
    elseif mode == "Rarity" then
        for _, v in ipairs(MyInventory) do
            local rarityName = RarityMap[v.Tier] or "UNKNOWN"
            counts[rarityName] = (counts[rarityName] or 0) + 1
        end
        -- Urutkan berdasarkan tingkat kelangkaan
        for i=1, 7 do
            local rName = RarityMap[tostring(i)]
            if counts[rName] then
                table.insert(results, rName .. " (" .. counts[rName] .. ")")
            end
        end
    end
    
    table.sort(results) -- Mengurutkan abjad agar rapi
    return #results > 0 and results or {"Empty"}
end

----------------------------------------------------------------
-- ======= [ UI TABS ] =======
----------------------------------------------------------------
local Tabs = {
    Fish = Window:AddTab({ Title = "Fish Trade", Icon = "fish" }),
    Rarity = Window:AddTab({ Title = "Rarity Trade", Icon = "layers" }),
    Accept = Window:AddTab({ Title = "Accept Trade", Icon = "check-circle" }),
    Settings = Window:AddTab({ Title = "Config", Icon = "settings" })
}

-- [ TAB 1: FISH TRADE ]
local FT_Status = Tabs.Fish:AddSection("Trade Status")
local FT_Label = FT_Status:AddParagraph({ Title = "Status: Idle", Content = "Success: 0 | Failed: 0" })

local FT_Main = Tabs.Fish:AddSection("Configuration")
local FT_Player = FT_Main:AddDropdown("FT_Player", { Title = "1. Select Player", Values = {"Refresh Player List"}, Multi = false })
FT_Main:AddButton({ Title = "Refresh Player", Callback = function() 
    local pList = {}
    for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(pList, p.Name) end end
    FT_Player:SetValues(#pList > 0 and pList or {"No Players Found"})
end })

FT_Main:AddToggle("FT_Fav", { Title = "Unfavorite Only", Default = false, Callback = function(v) UnfavoriteOnly = v end })
local FT_Fish = FT_Main:AddDropdown("FT_Fish", { Title = "2. Select Fish", Values = {"Refresh to Load"}, Multi = false })
FT_Main:AddButton({ Title = "Refresh Backpack", Callback = function() FT_Fish:SetValues(getFishDataStrings("Specific")) end })
FT_Main:AddInput("FT_Qty", { Title = "3. Quantity", Default = "1", Numeric = true })
FT_Main:AddToggle("FT_Start", { Title = "4. Start Trade", Default = false, Callback = function(v) FT_Label:SetTitle(v and "Status: RUNNING" or "Status: PAUSED") end })

-- [ TAB 2: RARITY TRADE ]
local RT_Status = Tabs.Rarity:AddSection("Trade Status")
local RT_Label = RT_Status:AddParagraph({ Title = "Status: Idle", Content = "Success: 0 | Failed: 0" })

local RT_Main = Tabs.Rarity:AddSection("Configuration")
local RT_Player = RT_Main:AddDropdown("RT_Player", { Title = "1. Select Player", Values = {"Refresh Player List"}, Multi = false })
RT_Main:AddButton({ Title = "Refresh Player", Callback = function() 
    local pList = {}
    for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(pList, p.Name) end end
    RT_Player:SetValues(#pList > 0 and pList or {"No Players Found"})
end })

RT_Main:AddToggle("RT_Fav", { Title = "Unfavorite Only", Default = false, Callback = function(v) UnfavoriteOnly = v end })
local RT_Tier = RT_Main:AddDropdown("RT_Tier", { Title = "2. Select Rarity", Values = {"Refresh to Load"}, Multi = false })
RT_Main:AddButton({ Title = "Refresh Backpack", Callback = function() RT_Tier:SetValues(getFishDataStrings("Rarity")) end })
RT_Main:AddInput("RT_Qty", { Title = "3. Quantity", Default = "1", Numeric = true })
RT_Main:AddToggle("RT_Start", { Title = "4. Start Trade", Default = false, Callback = function(v) RT_Label:SetTitle(v and "Status: RUNNING" or "Status: PAUSED") end })

-- [ TAB 3: ACCEPT TRADE ]
local AT_Section = Tabs.Accept:AddSection("Automated Receiver")
AT_Section:AddToggle("AutoAccept", { Title = "AUTO ACCEPT TRADE", Default = false })

-- [ CONFIG ]
Tabs.Settings:AddButton({ Title = "Force Close GUI", Callback = function() Window:Destroy() end })

Window:SelectTab(1)
