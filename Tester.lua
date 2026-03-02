----------------------------------------------------------------
-- ======= [ CONFIGURATION ] =======
----------------------------------------------------------------
local SimulationMode = true 
local GuiSize = UDim2.fromOffset(400, 320) -- UKURAN MINIMALIS

----------------------------------------------------------------
-- ======= [ LOAD FLUENT UI ] =======
----------------------------------------------------------------
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Fisch Trade SIM v1.5",
    SubTitle = "Fixed Detection",
    TabWidth = 100, -- Sidebar lebih ramping
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

-- Fungsi untuk mendapatkan Data Asli Game dengan Proteksi Error
local function InitGameData()
    local success, err = pcall(function()
        -- Mencari Modules & Packages
        local packages = ReplicatedStorage:WaitForChild("Packages", 15)
        local shared = ReplicatedStorage:WaitForChild("Shared", 15)
        
        if packages and shared then
            Replion = require(packages:WaitForChild("Replion"))
            ItemUtility = require(shared:WaitForChild("ItemUtility"))
            
            -- Menunggu Data Client Sinkron
            repeat 
                DataReplion = Replion.Client:GetReplion("Data")
                task.wait(1)
            until DataReplion ~= nil
        end
    end)
    
    if not success then warn("Data Detection Error: " .. tostring(err)) end
end

task.spawn(InitGameData)

----------------------------------------------------------------
-- ======= [ SCANNER LOGIC ] =======
----------------------------------------------------------------

-- Mendeteksi Player (Pasti Terdeteksi)
local function getRealPlayers()
    local pList = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(pList, p.Name) end
    end
    return #pList > 0 and pList or {"No Players Found"}
end

-- Mendeteksi Ikan (Pasti Terdeteksi jika DataReplion Siap)
local function scanInventory(tier)
    if not DataReplion or not ItemUtility then return {} end
    
    local found = {}
    local data = DataReplion:Get("Inventory")
    local items = (data and data.Items) or {}
    
    for _, item in ipairs(items) do
        local base = ItemUtility:GetItemData(item.Id)
        if base and base.Data and base.Data.Type == "Fish" then
            if tostring(base.Data.Tier) == tostring(tier) then
                table.insert(found, {name = base.Data.Name, uuid = item.UUID})
            end
        end
    end
    return found
end

----------------------------------------------------------------
-- ======= [ UI TABS ] =======
----------------------------------------------------------------
local Tabs = {
    Main = Window:AddTab({ Title = "Trade", Icon = "send" }),
    Settings = Window:AddTab({ Title = "Config", Icon = "settings" })
}

local TradeSection = Tabs.Main:AddSection("Scanner & Simulator")

-- DROPDOWN PLAYER
local PlayerDropdown = TradeSection:AddDropdown("TargetPlayer", {
    Title = "Target Player",
    Values = getRealPlayers(),
    Multi = false,
    Default = nil,
})

-- REFRESH BUTTON (Wajib diklik jika player baru masuk)
TradeSection:AddButton({
    Title = "Refresh Data",
    Description = "Update Player & Inventory List",
    Callback = function() 
        PlayerDropdown:SetValues(getRealPlayers()) 
        Fluent:Notify({Title = "System", Content = "Data Refreshed!", Duration = 1})
    end
})

-- DROPDOWN TIER
local TierDropdown = TradeSection:AddDropdown("TierFilter", {
    Title = "Select Tier to Scan",
    Values = {"1", "2", "3", "4", "5", "6", "7", "Secret"},
    Default = "7",
    Callback = function(v) state.SelectedTier = v end
})

-- SCAN BUTTON
TradeSection:AddButton({
    Title = "Scan My Fish",
    Callback = function()
        local fish = scanInventory(state.SelectedTier or "7")
        if #fish > 0 then
            Fluent:Notify({Title = "Success", Content = "Ditemukan " .. #fish .. " Ikan Tier " .. (state.SelectedTier or "7"), Duration = 3})
        else
            Fluent:Notify({Title = "Empty", Content = "Ikan tidak ditemukan di tas.", Duration = 3})
        end
    end
})

-- SIMULATE BUTTON
TradeSection:AddButton({
    Title = "Simulate Trade",
    Callback = function()
        local target = PlayerDropdown.Value
        local fishList = scanInventory(state.SelectedTier or "7")
        
        if not target or target == "No Players Found" then 
            return Fluent:Notify({Title = "Error", Content = "Pilih Player dulu!"}) 
        end
        
        if #fishList == 0 then
            return Fluent:Notify({Title = "Error", Content = "Tidak ada ikan untuk ditrade."})
        end

        Fluent:Notify({
            Title = "Simulation Running",
            Content = "Mengirim " .. fishList[1].name .. " ke " .. target,
            Duration = 4
        })
    end
})

Window:SelectTab(1)
Fluent:Notify({Title = "Ready", Content = "GUI v1.5 Minimalist Loaded", Duration = 3})
