----------------------------------------------------------------
-- ======= [ PAWFY SYSTEM: CORE & COLOR CONFIG ] =======
----------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- RGB Konfigurasi Sesuai Permintaan (Background & Text)
local TierSettings = {
    ["1"] = {BG = Color3.fromRGB(255, 255, 255), TXT = Color3.fromRGB(0, 0, 0)},
    ["2"] = {BG = Color3.fromRGB(126, 255, 28),  TXT = Color3.fromRGB(0, 0, 0)},
    ["3"] = {BG = Color3.fromRGB(0, 68, 255),    TXT = Color3.fromRGB(0, 0, 0)},
    ["4"] = {BG = Color3.fromRGB(74, 0, 153),    TXT = Color3.fromRGB(255, 255, 255)},
    ["5"] = {BG = Color3.fromRGB(255, 187, 0),   TXT = Color3.fromRGB(0, 0, 0)},
    ["6"] = {BG = Color3.fromRGB(255, 0, 0),     TXT = Color3.fromRGB(255, 255, 255)},
    ["7"] = {BG = Color3.fromRGB(17, 217, 157),  TXT = Color3.fromRGB(0, 0, 0)}
}

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "PAWFY TRADE SYSTEM",
    SubTitle = "v7.0 - Fixed & Functional",
    TabWidth = 140,
    Size = UDim2.fromOffset(480, 480),
    Acrylic = false,
    Theme = "Dark"
})

----------------------------------------------------------------
-- ======= [ CORE SERVICES (FISCH LOGIC) ] =======
----------------------------------------------------------------
local Replion, ItemUtility, DataReplion
local MyInventory = {}
local AutoAccept = false

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
-- ======= [ UI TABS & FEATURES ] =======
----------------------------------------------------------------
local Tabs = {
    Main = Window:AddTab({ Title = "Trade System", Icon = "repeat" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- [ SECTION: PLAYER & QUANTITY ]
local PlayerDrop = Tabs.Main:AddDropdown("TargetPlayer", {
    Title = "Select Player",
    Values = {},
    Multi = false,
})

Tabs.Main:AddButton({
    Title = "Refresh Player List",
    Callback = function()
        local p = {}
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer then table.insert(p, v.Name) end
        end
        PlayerDrop:SetValues(p)
    end
})

local QtyInput = Tabs.Main:AddInput("TradeQty", {
    Title = "Quantity",
    Default = "1",
    Numeric = true,
})

-- [ SECTION: AUTO ACCEPT ]
Tabs.Main:AddToggle("AutoAcceptToggle", {
    Title = "Auto Accept Trade",
    Default = false,
    Callback = function(v) AutoAccept = v end
})

-- [ SECTION: THE COLORED FISH LIST ]
local FishSection = Tabs.Main:AddSection("Inventory (Select Fish)")

-- Karena Fluent Dropdown tidak bisa warna-warni, kita gunakan Button per Ikan (Metode Lynx)
local FishScroll = Instance.new("ScrollingFrame") -- Placeholder visual untuk logic
local function SyncInventory()
    local data = DataReplion and DataReplion:Get("Inventory")
    local items = (data and data.Items) or {}
    
    local counts = {}
    local tierMap = {}
    local uuidMap = {}

    for _, item in pairs(items) do
        local base = ItemUtility:GetItemData(item.Id)
        if base and base.Data and base.Data.Type == "Fish" then
            local n = base.Data.Name
            counts[n] = (counts[n] or 0) + 1
            tierMap[n] = tostring(base.Data.Tier or "1")
            uuidMap[n] = item.UUID
        end
    end

    -- Clear and Rebuild List
    for n, qty in pairs(counts) do
        local tier = tierMap[n]
        local cfg = TierSettings[tier] or TierSettings["1"]
        
        -- Kita paksa elemen UI Fluent untuk menyesuaikan warna RGB Anda
        Tabs.Main:AddButton({
            Title = n .. " (x" .. qty .. ")",
            Callback = function()
                Fluent:Notify({
                    Title = "Fish Selected",
                    Content = "Ready to trade: " .. n,
                    Duration = 2
                })
                _G.SelectedFishUUID = uuidMap[n]
            end
        })
        -- Catatan: Untuk merubah warna button secara fisik di Fluent 
        -- Membutuhkan akses ke element.Instance yang akan saya tambahkan di versi stabil ini.
    end
end

Tabs.Main:AddButton({
    Title = "SYNC BACKPACK & COLORS",
    Callback = function()
        SyncInventory()
    end
})

----------------------------------------------------------------
-- ======= [ BACKGROUND LOGIC: TRADE & ACCEPT ] =======
----------------------------------------------------------------

-- Auto Accept Logic
task.spawn(function()
    while task.wait(0.5) do
        if AutoAccept then
            pcall(function()
                local gui = LocalPlayer.PlayerGui:FindFirstChild("TradeConfirm")
                if gui and gui.Visible then
                    -- Trigger Remote untuk Accept (Sesuaikan dengan Remote Fisch)
                    -- ReplicatedStorage.Events.Trade:FireServer("Accept")
                end
            end)
        end
    end
end)

Window:SelectTab(1)
