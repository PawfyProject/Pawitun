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
    SubTitle = "v4.5 - Pure Trade & Anti-Fav",
    TabWidth = 140,
    Size = UDim2.fromOffset(480, 450), -- Ukuran disesuaikan karena Rarity Trade dihapus
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
-- ======= [ ENHANCED ACCURACY SCANNER ] =======
----------------------------------------------------------------

local function fullBruteForceScan()
    table.clear(MyInventory) -- Membersihkan cache memori script
    local data = DataReplion and DataReplion:Get("Inventory")
    local items = (data and data.Items) or {}
    
    for _, item in pairs(items) do
        local base = ItemUtility:GetItemData(item.Id)
        if base and base.Data and base.Data.Type == "Fish" then
            
            -- [STRICT CHECK] Deteksi Favorit Berlapis
            local isFav = false
            if item.Favorite == true or item.IsFavorite == true or item.Fav == true then
                isFav = true
            elseif item.Data and (item.Data.Favorite == true or item.Data.IsFavorite == true) then
                isFav = true
            end
            
            -- Filter Logika: Jika UnfavoriteOnly AKTIF, lewati item Favorit
            local canAdd = true
            if UnfavoriteOnly == true and isFav == true then 
                canAdd = false 
            end
            
            if canAdd then
                table.insert(MyInventory, {
                    Name = base.Data.Name,
                    Tier = tostring(base.Data.Tier),
                    UUID = item.UUID,
                    IsFavorite = isFav -- Simpan status untuk debug
                })
            end
        end
    end
end

local function getFishDropdownList()
    fullBruteForceScan()
    local counts = {}
    local displayStrings = {}
    
    for _, v in ipairs(MyInventory) do
        counts[v.Name] = (counts[v.Name] or 0) + 1
    end
    
    for name, qty in pairs(counts) do
        table.insert(displayStrings, name .. " (" .. qty .. ")")
    end
    
    table.sort(displayStrings)
    return #displayStrings > 0 and displayStrings or {"NO DATA - SCROLL BACKPACK!"}
end

----------------------------------------------------------------
-- ======= [ UI TABS ] =======
----------------------------------------------------------------
local Tabs = {
    Fish = Window:AddTab({ Title = "Fish Trade", Icon = "fish" }),
    Accept = Window:AddTab({ Title = "Auto Accept", Icon = "check-circle" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- [ SECTION: FISH TRADE ]
local FT_Sec = Tabs.Fish:AddSection("Trade Controller")

local FT_Player = FT_Sec:AddDropdown("FT_P", { Title = "1. Target Player", Values = {"Refresh Player First"}, Multi = false })
FT_Sec:AddButton({ Title = "Refresh Player List", Callback = function()
    local p = {}
    for _, v in pairs(Players:GetPlayers()) do if v ~= LocalPlayer then table.insert(p, v.Name) end end
    FT_Player:SetValues(#p > 0 and p or {"No Players Found"})
end })

FT_Sec:AddToggle("FT_Fav", { Title = "Filter: Unfavorite Only", Default = false, Callback = function(v) 
    UnfavoriteOnly = v 
    Fluent:Notify({Title = "Filter Updated", Content = "Unfavorite Only: " .. tostring(v), Duration = 2})
end })

local FT_Drop = FT_Sec:AddDropdown("FT_Item", { Title = "2. Select Fish", Values = {"Click Sync!"}, Multi = false })
FT_Sec:AddButton({ Title = "Sync Backpack & Filter", Callback = function()
    FT_Drop:SetValues(getFishDropdownList())
    Fluent:Notify({Title = "Backpack Synced", Content = "Found " .. #MyInventory .. " fishes in current filter.", Duration = 3})
end })

FT_Sec:AddInput("FT_Qty", { Title = "3. Quantity", Default = "1", Numeric = true })
FT_Sec:AddToggle("FT_Go", { Title = "START AUTO TRADE", Default = false })

-- [ SECTION: AUTO ACCEPT ]
local AT_Sec = Tabs.Accept:AddSection("Receiver Settings")
AT_Sec:AddToggle("AutoAccept", { Title = "Enable Auto-Accept Trade", Default = false })

-- [ SECTION: SETTINGS ]
local Conf = Tabs.Settings:AddSection("Diagnostics")
Conf:AddButton({ Title = "Check Fav Status (F9 Console)", Callback = function()
    print("--- DIAGNOSTIC UNFAVORITE v4.5 ---")
    print("Mode Unfavorite Only: " .. tostring(UnfavoriteOnly))
    fullBruteForceScan() -- Re-scan untuk data murni
    for i, v in pairs(MyInventory) do
        print(string.format("[%d] %s | Fav: %s | UUID: %s", i, v.Name, tostring(v.IsFavorite), v.UUID))
    end
end })

Tabs.Settings:AddButton({ Title = "Destroy GUI", Callback = function() Window:Destroy() end })

Window:SelectTab(1)
