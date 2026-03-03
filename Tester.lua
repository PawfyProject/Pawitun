----------------------------------------------------------------
-- ======= [ CONFIGURATION & PRE-LOADING ] =======
----------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- [WARNA TIER] - Format: Color3.fromRGB(R, G, B)
local TierColors = {
    ["1"] = Color3.fromRGB(170, 170, 170), -- Common (Abu-abu)
    ["2"] = Color3.fromRGB(85, 255, 127),  -- Uncommon (Hijau)
    ["3"] = Color3.fromRGB(0, 170, 255),  -- Rare (Biru)
    ["4"] = Color3.fromRGB(170, 0, 255),  -- Epic (Ungu)
    ["5"] = Color3.fromRGB(255, 170, 0),  -- Legendary (Oranye)
    ["6"] = Color3.fromRGB(255, 0, 127),  -- Mythic (Pink/Hot Red)
    ["7"] = Color3.fromRGB(0, 255, 255)   -- SECRET (Cyan/Aqua)
}

local Window = Fluent:CreateWindow({
    Title = "FISCH ULTIMATE CONTROL",
    SubTitle = "v5.1 - Color Tier Edition",
    TabWidth = 140,
    Size = UDim2.fromOffset(480, 480),
    Acrylic = false, 
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

----------------------------------------------------------------
-- ======= [ DATA SERVICES ] =======
----------------------------------------------------------------
local Replion, ItemUtility, DataReplion
local MyInventory = {}

task.spawn(function()
    pcall(function()
        local shared = ReplicatedStorage:WaitForChild("Shared", 30)
        Replion = require(ReplicatedStorage.Packages.Replion)
        ItemUtility = require(shared:WaitForChild("ItemUtility"))
        repeat 
            DataReplion = Replion.Client:GetReplion("Data")
            task.wait(1)
        until DataReplion ~= nil
    end)
end)

----------------------------------------------------------------
-- ======= [ CORE LOGIC ] =======
----------------------------------------------------------------

local function scanBackpack()
    table.clear(MyInventory)
    local data = DataReplion and DataReplion:Get("Inventory")
    local items = (data and data.Items) or {}
    
    for _, item in pairs(items) do
        local base = ItemUtility:GetItemData(item.Id)
        if base and base.Data and base.Data.Type == "Fish" then
            table.insert(MyInventory, {
                Name = base.Data.Name,
                Tier = tostring(base.Data.Tier or "1"),
                UUID = item.UUID
            })
        end
    end
end

----------------------------------------------------------------
-- ======= [ UI TABS ] =======
----------------------------------------------------------------
local Tabs = {
    Fish = Window:AddTab({ Title = "Fish Trade", Icon = "fish" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local FT_Sec = Tabs.Fish:AddSection("Trade Controller")

-- Player List
local FT_Player = FT_Sec:AddDropdown("FT_P", { Title = "1. Target Player", Values = {}, Multi = false })
FT_Sec:AddButton({ Title = "Refresh Player List", Callback = function()
    local p = {}
    for _, v in pairs(Players:GetPlayers()) do if v ~= LocalPlayer then table.insert(p, v.Name) end end
    FT_Player:SetValues(#p > 0 and p or {"No Players"})
end })

-- Dropdown Ikan
local FT_Drop = FT_Sec:AddDropdown("FT_Item", { Title = "2. Select Fish", Values = {"Sync Required"}, Multi = false })

FT_Sec:AddButton({ 
    Title = "Sync Backpack", 
    Callback = function()
        scanBackpack()
        
        local display = {}
        local countMap = {}
        for _, v in ipairs(MyInventory) do
            countMap[v.Name] = (countMap[v.Name] or 0) + 1
        end
        
        for name, qty in pairs(countMap) do
            table.insert(display, name .. " (" .. qty .. ")")
        end
        table.sort(display)
        
        FT_Drop:SetValues(#display > 0 and display or {"EMPTY BACKPACK"})
        
        Fluent:Notify({
            Title = "Sync Success", 
            Content = "Loaded " .. #MyInventory .. " fishes from your bag.", 
            Duration = 3
        })
    end 
})

FT_Sec:AddInput("FT_Qty", { Title = "3. Quantity", Default = "1", Numeric = true })
FT_Sec:AddToggle("FT_Go", { Title = "START AUTO TRADE", Default = false })

-- Diagnostics Console
Tabs.Settings:AddButton({ Title = "Print Tier Colors to Console", Callback = function()
    print("--- TIER COLOR LIST ---")
    for tier, color in pairs(TierColors) do
        print("Tier " .. tier .. ": " .. tostring(color))
    end
end })

Window:SelectTab(1)
