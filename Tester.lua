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
    SubTitle = "v4.7 - Strict UI Sync",
    TabWidth = 140,
    Size = UDim2.fromOffset(480, 450),
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
-- ======= [ CORE LOGIC: FILTER & SYNC ] =======
----------------------------------------------------------------

local function checkIsFavorite(item)
    -- Deteksi Favorit dari berbagai layer data
    local fav = false
    if item.Favorite == true or item.IsFavorite == true or item.Fav == true then
        fav = true
    elseif item.Data and type(item.Data) == "table" then
        if item.Data.Favorite == true or item.Data.IsFavorite == true or item.Data.Fav == true then
            fav = true
        end
    end
    return fav
end

local function scanAndFilter()
    -- 1. Kosongkan tabel inventory script sepenuhnya
    table.clear(MyInventory)
    
    local data = DataReplion and DataReplion:Get("Inventory")
    local items = (data and data.Items) or {}
    
    for _, item in pairs(items) do
        local base = ItemUtility:GetItemData(item.Id)
        if base and base.Data and base.Data.Type == "Fish" then
            
            local isFav = checkIsFavorite(item)
            
            -- 2. LOGIKA FILTER KETAT: 
            -- Jika toggle Unfavorite AKTIF, dan ikan adalah FAV, maka JANGAN dimasukkan ke tabel
            local canEntry = true
            if UnfavoriteOnly == true and isFav == true then
                canEntry = false
            end
            
            if canEntry then
                table.insert(MyInventory, {
                    Name = base.Data.Name,
                    UUID = item.UUID,
                    FavStatus = isFav
                })
            end
        end
    end
end

local function refreshDropdownUI()
    -- Jalankan scan dan filter terlebih dahulu
    scanAndFilter()
    
    local counts = {}
    local finalDisplay = {}
    
    -- Hitung jumlah ikan yang lolos filter
    for _, v in ipairs(MyInventory) do
        counts[v.Name] = (counts[v.Name] or 0) + 1
    end
    
    -- Konversi ke format string dropdown
    for name, qty in pairs(counts) do
        table.insert(finalDisplay, name .. " (" .. qty .. ")")
    end
    
    table.sort(finalDisplay)
    
    -- Jika kosong, beri keterangan
    if #finalDisplay == 0 then
        finalDisplay = {"NO FISH FOUND (Check Filter/Scroll)"}
    end
    
    return finalDisplay
end

----------------------------------------------------------------
-- ======= [ UI TABS ] =======
----------------------------------------------------------------
local Tabs = {
    Fish = Window:AddTab({ Title = "Fish Trade", Icon = "fish" }),
    Accept = Window:AddTab({ Title = "Auto Accept", Icon = "check-circle" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local FT_Sec = Tabs.Fish:AddSection("Trade Controller")

-- Player List
local FT_Player = FT_Sec:AddDropdown("FT_P", { Title = "1. Target Player", Values = {"Refresh Player First"}, Multi = false })
FT_Sec:AddButton({ Title = "Refresh Player List", Callback = function()
    local p = {}
    for _, v in pairs(Players:GetPlayers()) do if v ~= LocalPlayer then table.insert(p, v.Name) end end
    FT_Player:SetValues(#p > 0 and p or {"No Players Found"})
end })

-- Toggle Unfavorite
FT_Sec:AddToggle("FT_Fav", { Title = "Filter: Unfavorite Only", Default = false, Callback = function(v) 
    UnfavoriteOnly = v 
    Fluent:Notify({Title = "Filter Updated", Content = "Unfavorite Only is now: " .. tostring(v), Duration = 2})
end })

-- Dropdown Ikan (Point Utama Perbaikan)
local FT_Drop = FT_Sec:AddDropdown("FT_Item", { Title = "2. Select Fish", Values = {"Click Sync!"}, Multi = false })

FT_Sec:AddButton({ Title = "Sync Backpack & Filter", Callback = function()
    -- [CRITICAL FIX] Paksa dropdown Reset sebelum diisi data baru
    FT_Drop:SetValues({"Processing..."}) 
    task.wait(0.1)
    
    local newList = refreshDropdownUI()
    FT_Drop:SetValues(newList)
    
    Fluent:Notify({
        Title = "Backpack Synced", 
        Content = "Found " .. #MyInventory .. " fishes matching your filter.", 
        Duration = 3
    })
end })

FT_Sec:AddInput("FT_Qty", { Title = "3. Quantity", Default = "1", Numeric = true })
FT_Sec:AddToggle("FT_Go", { Title = "START AUTO TRADE", Default = false })

-- Auto Accept
local AT_Sec = Tabs.Accept:AddSection("Receiver Settings")
AT_Sec:AddToggle("AutoAccept", { Title = "Enable Auto-Accept Trade", Default = false })

-- Diagnostics
local Conf = Tabs.Settings:AddSection("Diagnostics")
Conf:AddButton({ Title = "Check Fav Status (F9 Console)", Callback = function()
    print("--- DIAGNOSTIC v4.7 ---")
    scanAndFilter()
    for i, v in pairs(MyInventory) do
        print(string.format("[%d] %s | Fav: %s", i, v.Name, tostring(v.FavStatus)))
    end
end })

Tabs.Settings:AddButton({ Title = "Destroy GUI", Callback = function() Window:Destroy() end })

Window:SelectTab(1)
