----------------------------------------------------------------
-- ======= [ CONFIGURATION & PRE-LOADING ] =======
----------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "PAWFY TRADE",
    SubTitle = "v1.0.0",
    TabWidth = 140,
    Size = UDim2.fromOffset(300, 380),
    Acrylic = false, 
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

----------------------------------------------------------------
-- ======= [ CORE DATA SERVICES ] =======
----------------------------------------------------------------
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
-- ======= [ THE "IMPOSSIBLE TO FAIL" FILTER ] =======
----------------------------------------------------------------

local function scanAndSync()
    table.clear(MyInventory)
    
    local data = DataReplion and DataReplion:Get("Inventory")
    local favData = DataReplion and DataReplion:Get("Favorites") -- MENGAMBIL TABEL FAVORIT TERPISAH
    local items = (data and data.Items) or {}
    
    -- Buat Map UUID Favorit untuk pengecekan super cepat & akurat
    local favoriteMap = {}
    if favData and type(favData) == "table" then
        for _, favUUID in pairs(favData) do
            favoriteMap[favUUID] = true
        end
    end
    
    for _, item in pairs(items) do
        local base = ItemUtility:GetItemData(item.Id)
        if base and base.Data and base.Data.Type == "Fish" then
            
            -- CEK APAKAH UUID IKAN INI ADA DI DAFTAR FAVORIT GAME
            local isFav = favoriteMap[item.UUID] or false
            
            -- Jika Unfavorite Only AKTIF dan ikan ini FAVORIT, maka jangan masukkan (SKIP)
            local shouldEntry = true
            if UnfavoriteOnly == true and isFav == true then
                shouldEntry = false
            end
            
            if shouldEntry then
                table.insert(MyInventory, {
                    Name = base.Data.Name,
                    UUID = item.UUID,
                    IsFav = isFav
                })
            end
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

-- Toggle Filter
FT_Sec:AddToggle("FT_Fav", { 
    Title = "Unfavorite Only (Hide Starred)", 
    Default = false, 
    Callback = function(v) 
        UnfavoriteOnly = v 
        Fluent:Notify({Title = "Filter Changed", Content = "Filter is now: " .. (v and "ON" or "OFF"), Duration = 2})
    end 
})

-- Dropdown Ikan
local FT_Drop = FT_Sec:AddDropdown("FT_Item", { 
    Title = "Select Fish", 
    Values = {"Sync to start"}, 
    Multi = false 
})

FT_Sec:AddButton({ 
    Title = "Sync Backpack", 
    Callback = function()
        FT_Drop:SetValues({"Loading..."})
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
        
        FT_Drop:SetValues(#display > 0 and display or {"NO FISH FOUND"})
        
        Fluent:Notify({
            Title = "Sync Success", 
            Content = "Showing " .. #MyInventory .. " non-favorite fishes.", 
            Duration = 3
        })
    end 
})

FT_Sec:AddInput("FT_Qty", { Title = "Quantity", Default = "1", Numeric = true })
FT_Sec:AddToggle("FT_Go", { Title = "START AUTO TRADE", Default = false })

-- Debugging
Tabs.Settings:AddButton({ Title = "Check Favorites Table (F9)", Callback = function()
    local favData = DataReplion:Get("Favorites")
    print("--- RAW FAVORITES DATA ---")
    if favData then
        for i, uuid in pairs(favData) do print(i, uuid) end
    else
        print("Favorites table not found!")
    end
end })

Window:SelectTab(1)
