----------------------------------------------------------------
-- ======= [ CONFIGURATION ] =======
----------------------------------------------------------------
local SimulationMode = true 
local DefaultSize = UDim2.fromOffset(450, 400)

----------------------------------------------------------------
-- ======= [ LOAD FLUENT UI LIBRARY ] =======
----------------------------------------------------------------
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Fisch Trade Tool",
    SubTitle = "v2.1 - Floating Toggle",
    TabWidth = 110,
    Size = DefaultSize,
    Acrylic = false, 
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

----------------------------------------------------------------
-- ======= [ DATA SCANNER MODULE ] =======
----------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Replion, ItemUtility, DataReplion

pcall(function()
    local packages = ReplicatedStorage:WaitForChild("Packages")
    Replion = require(packages:WaitForChild("Replion"))
    ItemUtility = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ItemUtility"))
    DataReplion = Replion.Client:WaitReplion("Data")
end)

local ReverseRarityMap = {
    ["COMMON"] = "1", ["UNCOMMON"] = "2", ["RARE"] = "3", 
    ["EPIC"] = "4", ["LEGENDARY"] = "5", ["MYTHIC"] = "6", ["SECRET"] = "7"
}

local state = { SelectedRarity = "SECRET" }

----------------------------------------------------------------
-- ======= [ FLOATING TOGGLE BUTTON ] =======
----------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
local ToggleButton = Instance.new("ImageButton")
local UICorner = Instance.new("UICorner")

ScreenGui.Name = "FischToggleGui"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.Position = UDim2.new(0.05, 0, 0.15, 0) -- Posisi di kiri atas
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Image = "rbxassetid://10723343321" -- Logo Ikan/Hook
ToggleButton.Draggable = true -- Bisa digeser manual di layar

UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = ToggleButton

-- Fungsi Klik Tombol untuk Toggle GUI Utama
ToggleButton.MouseButton1Click:Connect(function()
    if Window then
        -- Library Fluent menggunakan fungsi internal untuk Minimize
        local isMinimized = Window.Minimized
        Window:Minimize(not isMinimized)
        
        -- Beri efek visual pada tombol saat diklik
        ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        task.wait(0.1)
        ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    end
end)

----------------------------------------------------------------
-- ======= [ CORE LOGIC: RARITY SYSTEM ] =======
----------------------------------------------------------------

local function getRarityLabels()
    local order = {"COMMON", "UNCOMMON", "RARE", "EPIC", "LEGENDARY", "MYTHIC", "SECRET"}
    local finalLabels = {}
    local inventory = (DataReplion and DataReplion:Get("Inventory")) or {}
    local items = inventory.Items or {}
    local counts = {["1"]=0, ["2"]=0, ["3"]=0, ["4"]=0, ["5"]=0, ["6"]=0, ["7"]=0}

    for _, item in ipairs(items) do
        local base = ItemUtility:GetItemData(item.Id)
        if base and base.Data and base.Data.Type == "Fish" then
            local t = tostring(base.Data.Tier)
            if counts[t] ~= nil then counts[t] = counts[t] + 1 end
        end
    end

    for _, name in ipairs(order) do
        local tierNum = ReverseRarityMap[name]
        table.insert(finalLabels, name .. " (" .. counts[tierNum] .. ")")
    end
    return finalLabels
end

local function getFishDisplayList(rarityInput)
    local cleanName = rarityInput:match("([%a]+)")
    local targetTier = ReverseRarityMap[cleanName] or "7"
    local inventory = (DataReplion and DataReplion:Get("Inventory")) or {}
    local items = inventory.Items or {}
    local grouped = {}
    
    for _, item in ipairs(items) do
        local base = ItemUtility:GetItemData(item.Id)
        if base and base.Data and base.Data.Type == "Fish" then
            if tostring(base.Data.Tier) == targetTier then
                local displayName = base.Data.Name .. " [" .. cleanName .. "]"
                grouped[displayName] = (grouped[displayName] or 0) + 1
            end
        end
    end
    
    local finalArray = {}
    for name, qty in pairs(grouped) do
        table.insert(finalArray, name .. " (x" .. qty .. ")")
    end
    table.sort(finalArray)
    return #finalArray > 0 and finalArray or {"Kosong di Rarity ini"}
end

----------------------------------------------------------------
-- ======= [ UI TABS ] =======
----------------------------------------------------------------
local Tabs = {
    Main = Window:AddTab({ Title = "Trade", Icon = "send" }),
    Receive = Window:AddTab({ Title = "Accept", Icon = "download" })
}

local MainSection = Tabs.Main:AddSection("Inventory Monitor")

_G.RarityDropdown = MainSection:AddDropdown("RarityFilter", {
    Title = "Select Rarity",
    Values = getRarityLabels(),
    Default = "SECRET (0)",
    Callback = function(v) 
        state.SelectedRarity = v 
        _G.FishDropdown:SetValues(getFishDisplayList(v))
    end
})

_G.FishDropdown = MainSection:AddDropdown("FishInBackpack", {
    Title = "Fish in Backpack",
    Values = {"Pilih Rarity untuk scan"},
    Multi = false,
})

MainSection:AddButton({
    Title = "Refresh Data",
    Callback = function()
        _G.RarityDropdown:SetValues(getRarityLabels())
        _G.FishDropdown:SetValues(getFishDisplayList(state.SelectedRarity))
        Fluent:Notify({Title = "Updated", Content = "Data telah diperbarui.", Duration = 2})
    end
})

task.spawn(function()
    task.wait(1.5)
    _G.RarityDropdown:SetValues(getRarityLabels())
end)

Window:SelectTab(1)
