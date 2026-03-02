----------------------------------------------------------------
-- ======= [ CONFIGURATION ] =======
----------------------------------------------------------------
local SimulationMode = true 
local GuiSize = UDim2.fromOffset(420, 380) 

----------------------------------------------------------------
-- ======= [ LOAD FLUENT UI ] =======
----------------------------------------------------------------
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Fisch Trade SIM v1.6",
    SubTitle = "Manual Fish Selection",
    TabWidth = 110,
    Size = GuiSize,
    Acrylic = false, 
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

----------------------------------------------------------------
-- ======= [ ADVANCED DATA DETECTOR ] =======
----------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Replion, ItemUtility, DataReplion
local MyInventoryFish = {} -- Tabel untuk menyimpan data ikan hasil scan

local function InitGameData()
    pcall(function()
        local packages = ReplicatedStorage:WaitForChild("Packages", 15)
        local shared = ReplicatedStorage:WaitForChild("Shared", 15)
        if packages and shared then
            Replion = require(packages:WaitForChild("Replion"))
            ItemUtility = require(shared:WaitForChild("ItemUtility"))
            repeat 
                DataReplion = Replion.Client:GetReplion("Data")
                task.wait(1)
            until DataReplion ~= nil
        end
    end)
end
task.spawn(InitGameData)

----------------------------------------------------------------
-- ======= [ SCANNER LOGIC ] =======
----------------------------------------------------------------

-- Mendeteksi Player Asli
local function getRealPlayers()
    local pList = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(pList, p.Name) end
    end
    return #pList > 0 and pList or {"No Players Found"}
end

-- Mendeteksi Ikan Spesifik (Nama & UUID)
local function scanBackpack()
    MyInventoryFish = {} -- Reset data lama
    local fishNames = {}
    
    if not DataReplion or not ItemUtility then return {"Data Not Loaded"} end
    
    local data = DataReplion:Get("Inventory")
    local items = (data and data.Items) or {}
    
    for _, item in ipairs(items) do
        local base = ItemUtility:GetItemData(item.Id)
        if base and base.Data and base.Data.Type == "Fish" then
            -- Simpan ke tabel referensi
            table.insert(MyInventoryFish, {
                Name = base.Data.Name,
                Tier = tostring(base.Data.Tier),
                UUID = item.UUID
            })
            -- Tambahkan ke daftar dropdown (Nama [Tier])
            table.insert(fishNames, base.Data.Name .. " [T" .. base.Data.Tier .. "]")
        end
    end
    
    return #fishNames > 0 and fishNames or {"No Fish Found"}
end

----------------------------------------------------------------
-- ======= [ UI TABS ] =======
----------------------------------------------------------------
local Tabs = {
    Main = Window:AddTab({ Title = "Trade", Icon = "send" }),
    Settings = Window:AddTab({ Title = "Config", Icon = "settings" })
}

local TradeSection = Tabs.Main:AddSection("Manual Selection Trade")

-- 1. PILIH TARGET PLAYER
local PlayerDropdown = TradeSection:AddDropdown("TargetPlayer", {
    Title = "Select Target Player",
    Values = getRealPlayers(),
    Multi = false,
})

-- 2. MENU PILIH IKAN (Daftar Ikan di Backpack)
local FishDropdown = TradeSection:AddDropdown("FishSelect", {
    Title = "Select Fish from Backpack",
    Values = {"Please Refresh Backpack First"},
    Multi = false,
})

-- 3. TOMBOL REFRESH (Player & Backpack)
TradeSection:AddButton({
    Title = "Refresh Players & Backpack",
    Description = "Klik ini untuk menscan ulang isi tas Anda",
    Callback = function() 
        -- Update Player
        PlayerDropdown:SetValues(getRealPlayers()) 
        -- Update Ikan
        local currentFishList = scanBackpack()
        FishDropdown:SetValues(currentFishList)
        
        Fluent:Notify({
            Title = "Scanner", 
            Content = "Ditemukan " .. #MyInventoryFish .. " ikan di tas.", 
            Duration = 2
        })
    end
})

TradeSection:AddInput("TradeAmt", {
    Title = "Quantity (Total)",
    Default = "1",
    Numeric = true,
    Callback = function(v) _G.TradeAmt = tonumber(v) or 1 end
})

-- 4. TOMBOL SIMULASI / EKSEKUSI
TradeSection:AddButton({
    Title = "Start Simulated Trade",
    Callback = function()
        local target = PlayerDropdown.Value
        local selectedFishName = FishDropdown.Value
        
        if not target or target == "No Players Found" then 
            return Fluent:Notify({Title = "Error", Content = "Pilih Player!"}) 
        end
        if not selectedFishName or selectedFishName == "No Fish Found" or selectedFishName == "Please Refresh Backpack First" then
            return Fluent:Notify({Title = "Error", Content = "Pilih Ikan di Menu!"})
        end

        Fluent:Notify({
            Title = "Simulasi Berjalan",
            Content = "Mencoba mengirim: " .. selectedFishName .. " ke " .. target,
            Duration = 4
        })
        
        print("SIMULASI: Mengirim ikan " .. selectedFishName .. " (Manual Selection)")
    end
})

Window:SelectTab(1)
Fluent:Notify({Title = "V1.6 Loaded", Content = "Manual Selection & Backpack Scanner Ready", Duration = 3})
