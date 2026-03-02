----------------------------------------------------------------
-- ======= [ CONFIGURATION & COLOR TABLE ] =======
----------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- Definisi Warna sesuai permintaan Anda (RGB)
local TierSettings = {
    ["1"] = {Name = "COMMON",    BG = Color3.fromRGB(255, 255, 255), Text = Color3.fromRGB(0, 0, 0)},
    ["2"] = {Name = "UNCOMMON",  BG = Color3.fromRGB(126, 255, 28),  Text = Color3.fromRGB(0, 0, 0)},
    ["3"] = {Name = "RARE",      BG = Color3.fromRGB(0, 68, 255),    Text = Color3.fromRGB(0, 0, 0)},
    ["4"] = {Name = "EPIC",      BG = Color3.fromRGB(74, 0, 153),    Text = Color3.fromRGB(255, 255, 255)},
    ["5"] = {Name = "LEGENDARY", BG = Color3.fromRGB(255, 187, 0),   Text = Color3.fromRGB(0, 0, 0)},
    ["6"] = {Name = "MYTHIC",    BG = Color3.fromRGB(255, 0, 0),     Text = Color3.fromRGB(255, 255, 255)},
    ["7"] = {Name = "SECRET",    BG = Color3.fromRGB(17, 217, 157),  Text = Color3.fromRGB(0, 0, 0)}
}

local Window = Fluent:CreateWindow({
    Title = "FISCH ULTIMATE CONTROL",
    SubTitle = "v5.2 - Color Tier Management",
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
-- ======= [ SCANNER LOGIC ] =======
----------------------------------------------------------------

local function scanBackpack()
    table.clear(MyInventory)
    local data = DataReplion and DataReplion:Get("Inventory")
    local items = (data and data.Items) or {}
    
    for _, item in pairs(items) do
        local base = ItemUtility:GetItemData(item.Id)
        if base and base.Data and base.Data.Type == "Fish" then
            local tierStr = tostring(base.Data.Tier or "1")
            table.insert(MyInventory, {
                Name = base.Data.Name,
                Tier = tierStr,
                TierName = TierSettings[tierStr].Name,
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

-- Target Player
local FT_Player = FT_Sec:AddDropdown("FT_P", { Title = "1. Target Player", Values = {}, Multi = false })
FT_Sec:AddButton({ Title = "Refresh Player List", Callback = function()
    local p = {}
    for _, v in pairs(Players:GetPlayers()) do if v ~= LocalPlayer then table.insert(p, v.Name) end end
    FT_Player:SetValues(#p > 0 and p or {"No Players"})
end })

-- Dropdown Ikan dengan Label Tier
local FT_Drop = FT_Sec:AddDropdown("FT_Item", { Title = "2. Select Fish (Sorted by Rarity)", Values = {"Sync First"}, Multi = false })

FT_Sec:AddButton({ 
    Title = "Sync & Sort by Color Tier", 
    Callback = function()
        scanBackpack()
        
        -- Mengelompokkan ikan berdasarkan Tier untuk visualisasi lebih rapi
        local display = {}
        local countMap = {}
        
        for _, v in ipairs(MyInventory) do
            -- Format: [TIER] Nama Ikan (Qty)
            local key = "[" .. v.TierName .. "] " .. v.Name
            countMap[key] = (countMap[key] or 0) + 1
        end
        
        -- Memasukkan ke list dengan urutan Tier tertinggi ke terendah
        for nameWithTier, qty in pairs(countMap) do
            table.insert(display, nameWithTier .. " x" .. qty)
        end
        table.sort(display) -- Ini akan mengurutkan berdasarkan nama Tier secara alfabetis
        
        FT_Drop:SetValues(#display > 0 and display or {"EMPTY"})
        
        Fluent:Notify({
            Title = "Backpack Color-Synced", 
            Content = "Successfully identified " .. #MyInventory .. " fishes.", 
            Duration = 3
        })
    end 
})

FT_Sec:AddInput("FT_Qty", { Title = "Quantity", Default = "1", Numeric = true })
FT_Sec:AddToggle("FT_Go", { Title = "START AUTO TRADE", Default = false })

-- Diagnostics (Menampilkan Palet Warna Anda di Console)
Tabs.Settings:AddButton({ Title = "Preview RGB Config (F9)", Callback = function()
    print("--- CUSTOM RGB CONFIGURATION ---")
    for tier, cfg in pairs(TierSettings) do
        print(string.format("Tier %s (%s): BG(%d,%d,%d) Text(%d,%d,%d)", 
            tier, cfg.Name, 
            cfg.BG.R*255, cfg.BG.G*255, cfg.BG.B*255,
            cfg.Text.R*255, cfg.Text.G*255, cfg.Text.B*255))
    end
end })

Window:SelectTab(1)
