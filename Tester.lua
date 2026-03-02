----------------------------------------------------------------
-- ======= [ CONFIGURATION & PRE-LOADING ] =======
----------------------------------------------------------------
local MyLogoID = "https://raw.githubusercontent.com/PawfyProject/Pawitun/refs/heads/main/Logo.jpg" 

local ContentProvider = game:GetService("ContentProvider")
local ImageLabel = Instance.new("ImageLabel")
ImageLabel.Image = MyLogoID
pcall(function() ContentProvider:PreloadAsync({ImageLabel}) end)

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "FISCH ULTIMATE CONTROL",
    SubTitle = "v4.1 - Fix Callback Error",
    TabWidth = 140,
    Size = UDim2.fromOffset(480, 560),
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
        local packages = ReplicatedStorage:WaitForChild("Packages", 30)
        local shared = ReplicatedStorage:WaitForChild("Shared", 30)
        Replion = require(packages:WaitForChild("Replion"))
        ItemUtility = require(shared:WaitForChild("ItemUtility"))
        repeat 
            DataReplion = Replion.Client:GetReplion("Data")
            task.wait(1)
        until DataReplion ~= nil
    end)
end)

----------------------------------------------------------------
-- ======= [ ULTIMATE SCANNER LOGIC ] =======
----------------------------------------------------------------

local function fullBruteForceScan()
    table.clear(MyInventory) 
    local data = DataReplion and DataReplion:Get("Inventory")
    local items = (data and data.Items) or {}
    
    local count = 0
    for _, item in pairs(items) do
        local base = ItemUtility:GetItemData(item.Id)
        if base and base.Data and base.Data.Type == "Fish" then
            local isFav = item.Favorite or item.IsFavorite or false
            local canAdd = true
            if UnfavoriteOnly and isFav then canAdd = false end
            
            if canAdd then
                count = count + 1
                table.insert(MyInventory, {
                    Name = base.Data.Name,
                    Tier = tostring(base.Data.Tier),
                    UUID = item.UUID
                })
            end
        end
    end
    return count
end

local function updateDropdowns(mode)
    fullBruteForceScan()
    local displayStrings = {}
    
    if mode == "Specific" then
        local counts = {}
        for _, v in ipairs(MyInventory) do
            counts[v.Name] = (counts[v.Name] or 0) + 1
        end
        for name, qty in pairs(counts) do
            table.insert(displayStrings, name .. " (" .. qty .. ")")
        end
        table.sort(displayStrings)
    elseif mode == "Rarity" then
        local tierCounts = {["1"]=0, ["2"]=0, ["3"]=0, ["4"]=0, ["5"]=0, ["6"]=0, ["7"]=0}
        for _, v in ipairs(MyInventory) do
            if tierCounts[v.Tier] then tierCounts[v.Tier] = tierCounts[v.Tier] + 1 end
        end
        for i = 1, 7 do
            local tStr = tostring(i)
            if tierCounts[tStr] > 0 then
                table.insert(displayStrings, RarityMap[tStr] .. " (" .. tierCounts[tStr] .. ")")
            end
        end
    end
    return #displayStrings > 0 and displayStrings or {"NO DATA - SCROLL BACKPACK!"}
end

----------------------------------------------------------------
-- ======= [ UI TABS ] =======
----------------------------------------------------------------
local Tabs = {
    Fish = Window:AddTab({ Title = "Fish Trade", Icon = "fish" }),
    Rarity = Window:AddTab({ Title = "Rarity Trade", Icon = "layers" }),
    Accept = Window:AddTab({ Title = "Auto Accept", Icon = "check-circle" }),
    Settings = Window:AddTab({ Title = "Ultimate Config", Icon = "settings" })
}

-- [ TAB: FISH TRADE ]
local FT_Sec = Tabs.Fish:AddSection("Main Fish Trader")

local FT_Player = FT_Sec:AddDropdown("FT_P", { Title = "1. Target Player", Values = {"Refresh Player First"}, Multi = false })
FT_Sec:AddButton({ Title = "Refresh Player List", Callback = function()
    local p = {}
    for _, v in pairs(Players:GetPlayers()) do if v ~= LocalPlayer then table.insert(p, v.Name) end end
    FT_Player:SetValues(#p > 0 and p or {"No Players"})
end })

FT_Sec:AddToggle("FT_Fav", { Title = "Filter: Unfavorite Only", Default = false, Callback = function(v) UnfavoriteOnly = v end })

local FT_Drop = FT_Sec:AddDropdown("FT_Item", { Title = "2. Select Fish", Values = {"Click Refresh!"}, Multi = false })
FT_Sec:AddButton({ Title = "Refresh & Sync Backpack", Callback = function()
    local vals = updateDropdowns("Specific")
    FT_Drop:SetValues(vals)
    Fluent:Notify({Title = "Backpack Synced", Content = "Total: " .. #MyInventory .. " fish found.", Duration = 3})
end })

FT_Sec:AddInput("FT_Qty", { Title = "3. Quantity", Default = "1", Numeric = true })
FT_Sec:AddToggle("FT_Go", { Title = "START AUTO TRADE", Default = false })

-- [ TAB: RARITY TRADE ]
local RT_Sec = Tabs.Rarity:AddSection("Bulk Rarity Trader")

local RT_Player = RT_Sec:AddDropdown("RT_P", { Title = "1. Target Player", Values = {"Refresh Player First"}, Multi = false })
RT_Sec:AddButton({ Title = "Refresh Player List", Callback = function()
    local p = {}
    for _, v in pairs(Players:GetPlayers()) do if v ~= LocalPlayer then table.insert(p, v.Name) end end
    RT_Player:SetValues(#p > 0 and p or {"No Players"})
end })

RT_Sec:AddToggle("RT_Fav", { Title = "Filter: Unfavorite Only", Default = false, Callback = function(v) UnfavoriteOnly = v end })

local RT_Drop = RT_Sec:AddDropdown("RT_Tier", { Title = "2. Select Rarity", Values = {"Click Refresh!"}, Multi = false })
RT_Sec:AddButton({ Title = "Refresh & Sync Rarity", Callback = function()
    local vals = updateDropdowns("Rarity")
    RT_Drop:SetValues(vals)
    Fluent:Notify({Title = "Rarity Synced", Content = "Scanned Total: " .. #MyInventory, Duration = 3})
end })

RT_Sec:AddInput("RT_Qty", { Title = "3. Quantity", Default = "1", Numeric = true })
RT_Sec:AddToggle("RT_Go", { Title = "START BULK TRADE", Default = false })

-- [ TAB: AUTO ACCEPT ]
local AT_Sec = Tabs.Accept:AddSection("Receiver Settings")
AT_Sec:AddToggle("AutoAccept", { Title = "Enable Auto-Accept Trade", Default = false })

-- [ TAB: CONFIG ]
local Conf = Tabs.Settings:AddSection("Diagnostics")
Conf:AddButton({ Title = "Check Sync (F9 Console)", Callback = function()
    print("--- ULTIMATE SYNC CHECK ---")
    print("Items Scanned: " .. #MyInventory)
end })

Tabs.Settings:AddButton({ Title = "Destroy GUI", Callback = function() Window:Destroy() end })

Window:SelectTab(1)
