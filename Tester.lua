----------------------------------------------------------------
-- ======= [ CONFIGURATION ] =======
----------------------------------------------------------------
local SimulationMode = true 
local DefaultSize = UDim2.fromOffset(450, 420)

----------------------------------------------------------------
-- ======= [ LOAD FLUENT UI LIBRARY ] =======
----------------------------------------------------------------
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Fisch Trade Tool",
    SubTitle = "v2.3 - Auto Cleanup",
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
-- ======= [ FLOATING TOGGLE BUTTON + CLEANUP ] =======
----------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
local ToggleButton = Instance.new("ImageButton")
local UICorner = Instance.new("UICorner")

ScreenGui.Name = "FischToggleGui_Cleanup"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.Position = UDim2.new(0.05, 0, 0.2, 0)
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Image = "rbxassetid://10723343321" 
ToggleButton.Draggable = true 

UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = ToggleButton

ToggleButton.MouseButton1Click:Connect(function()
    if Window then
        Window:Minimize(not Window.Minimized)
    end
end)

-- FITUR PERBAIKAN: Menghapus Tombol saat Script di-Unload
Window:OnUnload(function()
    if ScreenGui then
        ScreenGui:Destroy()
    end
    print("Script Unloaded: Floating Button Removed.")
end)

----------------------------------------------------------------
-- ======= [ LOGIC FUNCTIONS ] =======
----------------------------------------------------------------

local function getRealPlayers()
    local pList = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(pList, p.Name) end
    end
    return #pList > 0 and pList or {"Tidak ada player"}
end

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
    return #finalArray > 0 and finalArray or {"Kosong"}
end

----------------------------------------------------------------
-- ======= [ UI TABS ] =======
----------------------------------------------------------------
local Tabs = {
    Main = Window:AddTab({ Title = "Trade", Icon = "send" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local MainSection = Tabs.Main:AddSection("Trade & Inventory")

local PlayerDropdown = MainSection:AddDropdown("TargetPlayer", {
    Title = "Select Target Player",
    Values = getRealPlayers(),
    Multi = false,
})

_G.RarityDropdown = MainSection:AddDropdown("RarityFilter", {
    Title = "Filter by Rarity",
    Values = getRarityLabels(),
    Default = "SECRET (0)",
    Callback = function(v) 
        state.SelectedRarity = v 
        _G.FishDropdown:SetValues(getFishDisplayList(v))
    end
})

_G.FishDropdown = MainSection:AddDropdown("FishInBackpack", {
    Title = "Fish Found",
    Values = {"Pilih Rarity dulu"},
    Multi = false,
})

MainSection:AddButton({
    Title = "Refresh All Data",
    Callback = function()
        PlayerDropdown:SetValues(getRealPlayers())
        _G.RarityDropdown:SetValues(getRarityLabels())
        _G.FishDropdown:SetValues(getFishDisplayList(state.SelectedRarity))
        Fluent:Notify({Title = "System", Content = "Data updated.", Duration = 2})
    end
})

-- Bagian Settings untuk Unload Manual
Tabs.Settings:AddButton({
    Title = "Unload Script",
    Description = "Menghapus semua UI (Menu & Tombol)",
    Callback = function()
        Window:Destroy()
    end
})

-- AUTO-INIT
task.spawn(function()
    task.wait(2)
    _G.RarityDropdown:SetValues(getRarityLabels())
    PlayerDropdown:SetValues(getRealPlayers())
end)

Window:SelectTab(1)
