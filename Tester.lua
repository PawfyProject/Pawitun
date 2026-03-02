----------------------------------------------------------------
-- ======= [ LYNX CONFIG & PRE-LOADING ] =======
----------------------------------------------------------------
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Mengambil asset logo untuk sinkronisasi visual [cite: 111, 158]
local MyLogoID = "rbxassetid://104332967321169" 

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Pawfy Trade System",
    SubTitle = "v4.9 - Mumet Kontol",
    TabWidth = 140,
    Size = UDim2.fromOffset(480, 480),
    Acrylic = false, 
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

----------------------------------------------------------------
-- ======= [ CORE DATA & NET SCANNER ] =======
----------------------------------------------------------------
local MyInventory = {}
local UnfavoriteOnly = false 
local Replion, ItemUtility, DataReplion

-- Deteksi Sleitnick Net secara dinamis (Logic dari script teman Anda) [cite: 156]
local NetFolder = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index")
local FavoriteRemote

task.spawn(function()
    for _, v in pairs(NetFolder:GetDescendants()) do
        if v.Name == "RE/FavoriteItem" or (v.Name == "net" and v:IsA("RemoteEvent")) then
            FavoriteRemote = v
            break
        end
    end
    
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
-- ======= [ ADVANCED FILTER SYSTEM ] =======
----------------------------------------------------------------

local function isFishFavorite(item)
    -- 1. Cek Metadata (Paling Akurat di Fisch) [cite: 156]
    if item.InventoryItem and item.InventoryItem.Metadata then
        if item.InventoryItem.Metadata.Favorite or item.InventoryItem.Metadata.IsFavorite then
            return true
        end
    end
    
    -- 2. Cek Properti Langsung 
    if item.Favorite or item.IsFavorite or item.Fav then
        return true
    end
    
    return false
end

local function scanAndSync()
    table.clear(MyInventory)
    
    local data = DataReplion and DataReplion:Get("Inventory")
    local items = (data and data.Items) or {}
    
    for _, item in pairs(items) do
        local base = ItemUtility:GetItemData(item.Id)
        if base and base.Data and base.Data.Type == "Fish" then
            
            local isFav = isFishFavorite(item)
            
            -- Filter Logika: Jika Unfavorite Only AKTIF dan ikan adalah FAV, maka SKIP.
            if UnfavoriteOnly and isFav then
                continue 
            end
            
            table.insert(MyInventory, {
                Name = base.Data.Name,
                UUID = item.UUID,
                IsFav = isFav
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

-- Filter Toggle
FT_Sec:AddToggle("FT_Fav", { 
    Title = "Strict Filter: Hide Favorites", 
    Default = false, 
    Callback = function(v) 
        UnfavoriteOnly = v 
    end 
})

-- Dropdown Select Fish
local FT_Drop = FT_Sec:AddDropdown("FT_Item", { 
    Title = "Select Fish", 
    Values = {"Sync to start"}, 
    Multi = false 
})

FT_Sec:AddButton({ 
    Title = "Sync Backpack (Lynx Method)", 
    Callback = function()
        -- [CRITICAL FIX] Paksa UI reset agar tidak ada sisa data lama
        FT_Drop:SetValues({"[CLEANING UI...]"})
        task.wait(0.2)
        
        scanAndSync()
        
        local display = {}
        local countMap = {}
        for _, v in ipairs(MyInventory) do
            countMap[v.Name] = (countMap[v.Name] or 0) + 1
        end
        for name, qty in pairs(countMap) do
            table.insert(display, name .. " (" .. qty .. ")")
        end
        table.sort(display)
        
        FT_Drop:SetValues(#display > 0 and display or {"NO FISH MATCH FILTER"})
        
        Fluent:Notify({
            Title = "Lynx Sync Success", 
            Content = "Filtered " .. #MyInventory .. " fishes.", 
            Duration = 2
        })
    end 
})

FT_Sec:AddInput("FT_Qty", { Title = "Quantity", Default = "1", Numeric = true })
FT_Sec:AddToggle("FT_Go", { Title = "START AUTO TRADE", Default = false })

-- Diagnostics
Tabs.Settings:AddButton({ Title = "Deep Debug (F9)", Callback = function()
    print("--- LYNX DEBUG v4.9 ---")
    scanAndSync()
    for _, v in pairs(MyInventory) do
        print(string.format("Fish: %s | UUID: %s | Favorite: %s", v.Name, v.UUID, tostring(v.IsFav)))
    end
end })

Window:SelectTab(1)
