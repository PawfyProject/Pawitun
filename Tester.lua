----------------------------------------------------------------
-- ======= [ CONFIGURATION & UI ] =======
----------------------------------------------------------------
local MyLogoID = "https://raw.githubusercontent.com/PawfyProject/Pawitun/refs/heads/main/Logo.jpg" 
local GuiSize = UDim2.fromOffset(460, 530)

if game.CoreGui:FindFirstChild("Fluent") then
    game.CoreGui.Fluent:Destroy()
end

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Fisch Ultimate Trade Control",
    SubTitle = "v2.9 - Rarity Counter Fixed",
    TabWidth = 130,
    Size = GuiSize,
    Acrylic = false, 
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl,
    MinimizeIcon = MyLogoID 
})

----------------------------------------------------------------
-- ======= [ DATA MODULES ] =======
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
        local packages = ReplicatedStorage:WaitForChild("Packages", 20)
        local shared = ReplicatedStorage:WaitForChild("Shared", 20)
        Replion = require(packages:WaitForChild("Replion"))
        ItemUtility = require(shared:WaitForChild("ItemUtility"))
        repeat 
            DataReplion = Replion.Client:GetReplion("Data")
            task.wait(1)
        until DataReplion ~= nil
    end)
end)

----------------------------------------------------------------
-- ======= [ ACCURATE SCANNER ] =======
----------------------------------------------------------------

local function deepScanInventory()
    table.clear(MyInventory) 
    
    local data = DataReplion and DataReplion:Get("Inventory")
    local items = (data and data.Items) or {}
    
    for i, item in pairs(items) do
        local base = ItemUtility:GetItemData(item.Id)
        if base and base.Data and base.Data.Type == "Fish" then
            local isFavorite = item.Favorite or false
            
            -- Filter Favorite
            if not (UnfavoriteOnly and isFavorite) then
                table.insert(MyInventory, {
                    Name = base.Data.Name,
                    Tier = tostring(base.Data.Tier),
                    UUID = item.UUID
                })
            end
        end
        if i % 150 == 0 then task.wait() end 
    end
end

local function getFishDataStrings(mode)
    deepScanInventory()
    local results = {}
    
    if mode == "Specific" then
        local counts = {}
        for _, v in ipairs(MyInventory) do
            counts[v.Name] = (counts[v.Name] or 0) + 1
        end
        for name, count in pairs(counts) do
            table.insert(results, name .. " (" .. count .. ")")
        end
        table.sort(results)
    elseif mode == "Rarity" then
        -- PERBAIKAN TOTAL: Menggunakan accumulator untuk menjumlahkan semua unit ikan
        local totalUnitsPerTier = {["1"]=0, ["2"]=0, ["3"]=0, ["4"]=0, ["5"]=0, ["6"]=0, ["7"]=0}
        
        for _, fish in ipairs(MyInventory) do
            if totalUnitsPerTier[fish.Tier] ~= nil then
                totalUnitsPerTier[fish.Tier] = totalUnitsPerTier[fish.Tier] + 1
            end
        end

        for i = 1, 7 do
            local tierStr = tostring(i)
            local rName = RarityMap[tierStr]
            local totalAmount = totalUnitsPerTier[tierStr]
            
            if totalAmount > 0 then
                table.insert(results, rName .. " (" .. totalAmount .. ")")
            end
        end
    end
    
    return #results > 0 and results or {"No Data - Refresh Again"}
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
local FT_Player = FT_Main:AddDropdown("FT_Player", { Title = "1. Select Player", Values = {"Refresh List"}, Multi = false })
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
local RT_Player = RT_Main:AddDropdown("RT_Player", { Title = "1. Select Player", Values = {"Refresh List"}, Multi = false })
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

-- [ TAB 3: AUTO ACCEPT ]
local AT_Section = Tabs.Accept:AddSection("Automated Receiver")
AT_Section:AddToggle("AutoAccept", { Title = "AUTO ACCEPT TRADE", Default = false })

Tabs.Settings:AddButton({ Title = "Force Close GUI", Callback = function() Window:Destroy() end })

Window:SelectTab(1)
