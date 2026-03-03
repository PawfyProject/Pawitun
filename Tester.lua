----------------------------------------------------------------
-- ======= [ LINORIA LOADER ] =======
----------------------------------------------------------------
local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"
))()

local Window = Library:CreateWindow({
    Title = "FISCH ULTIMATE CONTROL",
    Center = true,
    AutoShow = true
})

----------------------------------------------------------------
-- ======= [ RARITY COLOR SYSTEM ] =======
----------------------------------------------------------------
local RarityMap = {
    ["1"] = {Name="COMMON", Color=Color3.fromRGB(255,255,255)},
    ["2"] = {Name="UNCOMMON", Color=Color3.fromRGB(126,255,28)},
    ["3"] = {Name="RARE", Color=Color3.fromRGB(0,162,255)},
    ["4"] = {Name="EPIC", Color=Color3.fromRGB(170,0,255)},
    ["5"] = {Name="LEGENDARY", Color=Color3.fromRGB(254,203,0)},
    ["6"] = {Name="MYTHIC", Color=Color3.fromRGB(255,0,85)},
    ["7"] = {Name="SECRET", Color=Color3.fromRGB(0,255,170)}
}

----------------------------------------------------------------
-- ======= [ SERVICES ] =======
----------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Replion, ItemUtility, DataReplion
local MyInventory = {}
local UnfavoriteOnly = false 

----------------------------------------------------------------
-- ======= [ LOAD DATA ] =======
----------------------------------------------------------------
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
-- ======= [ FAVORITE CHECK ] =======
----------------------------------------------------------------
local function checkIsFavoritePro(item)
    if item.InventoryItem and item.InventoryItem.Metadata then
        if item.InventoryItem.Metadata.Favorite or item.InventoryItem.Metadata.IsFavorite then
            return true
        end
    end

    if item.Favorite or item.IsFavorite or item.Fav then
        return true
    end

    if item.Data and type(item.Data) == "table" then
        if item.Data.Favorite or item.Data.IsFavorite then
            return true
        end
    end

    return false
end

----------------------------------------------------------------
-- ======= [ SCAN INVENTORY ] =======
----------------------------------------------------------------
local function scanAndFilter()
    table.clear(MyInventory)

    local data = DataReplion and DataReplion:Get("Inventory")
    local items = (data and data.Items) or {}

    for _, item in pairs(items) do
        local base = ItemUtility:GetItemData(item.Id)

        if base and base.Data and base.Data.Type == "Fish" then
            local isFav = checkIsFavoritePro(item)

            if not (UnfavoriteOnly and isFav) then
                table.insert(MyInventory, {
                    Name = base.Data.Name,
                    UUID = item.UUID,
                    FavStatus = isFav,
                    Rarity = base.Data.Rarity or 1
                })
            end
        end
    end
end

----------------------------------------------------------------
-- ======= [ UI ] =======
----------------------------------------------------------------
local Tabs = {
    Fish = Window:AddTab("Fish Trade"),
    Settings = Window:AddTab("Settings")
}

local FT_Sec = Tabs.Fish:AddLeftGroupbox("Trade Controller")

----------------------------------------------------------------
-- ======= [ PLAYER DROPDOWN NORMAL ] =======
----------------------------------------------------------------
local FT_Player = FT_Sec:AddDropdown("FT_P", {
    Values = {},
    Default = 1,
    Text = "1. Target Player"
})

FT_Sec:AddButton("Refresh Player List", function()
    local p = {}
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer then
            table.insert(p, v.Name)
        end
    end

    FT_Player:SetValues(#p > 0 and p or {"No Players"})
end)

----------------------------------------------------------------
-- ======= [ FILTER ] =======
----------------------------------------------------------------
FT_Sec:AddToggle("FT_Fav", {
    Text = "Filter: Unfavorite Only",
    Default = false
}):OnChanged(function(v)
    UnfavoriteOnly = v
end)

----------------------------------------------------------------
-- ======= [ CUSTOM COLORED DROPDOWN ] =======
----------------------------------------------------------------
local SelectedFish = nil

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1,0,0,150)
ScrollFrame.CanvasSize = UDim2.new(0,0,0,0)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.Parent = FT_Sec.Parent

local UIList = Instance.new("UIListLayout", ScrollFrame)
UIList.Padding = UDim.new(0,4)

local function buildColoredDropdown()
    ScrollFrame:ClearAllChildren()
    UIList.Parent = ScrollFrame

    local counts = {}
    local rarityMapLocal = {}

    for _, v in ipairs(MyInventory) do
        counts[v.Name] = (counts[v.Name] or 0) + 1
        rarityMapLocal[v.Name] = v.Rarity
    end

    for name, qty in pairs(counts) do
        local rarity = rarityMapLocal[name]
        local r = RarityMap[tostring(rarity)] or RarityMap["1"]

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1,0,0,30)
        btn.Text = name .. " (" .. qty .. ")"
        btn.BackgroundColor3 = r.Color
        btn.TextColor3 = Color3.new(0,0,0)
        btn.Parent = ScrollFrame

        btn.MouseButton1Click:Connect(function()
            SelectedFish = name
            Library:Notify("Selected: "..name)
        end)
    end
end

----------------------------------------------------------------
-- ======= [ SYNC BUTTON ] =======
----------------------------------------------------------------
FT_Sec:AddButton("Sync Backpack & Filter", function()
    scanAndFilter()
    buildColoredDropdown()
    Library:Notify("Sync Complete! Found "..#MyInventory.." fish.")
end)

----------------------------------------------------------------
-- ======= [ INPUT & START ] =======
----------------------------------------------------------------
FT_Sec:AddInput("FT_Qty", {
    Default = "1",
    Numeric = true,
    Text = "3. Quantity"
})

FT_Sec:AddToggle("FT_Go", {
    Text = "START AUTO TRADE",
    Default = false
})

----------------------------------------------------------------
-- ======= [ SETTINGS ] =======
----------------------------------------------------------------
Tabs.Settings:AddButton("Debug Console", function()
    scanAndFilter()
    for i,v in pairs(MyInventory) do
        print(i,v.Name,v.Rarity,v.FavStatus)
    end
end)

Tabs.Settings:AddButton("Destroy GUI", function()
    Library:Unload()
end)
