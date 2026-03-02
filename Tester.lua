----------------------------------------------------------------
-- ======= [ CONFIGURATION & CLEANUP ] =======
----------------------------------------------------------------
local SimulationMode = true 
local GuiSize = UDim2.fromOffset(400, 350) -- Ukuran Compact agar tidak memenuhi layar

-- Membersihkan UI lama jika ada yang tersangkut
if game.CoreGui:FindFirstChild("Fluent") then
    game.CoreGui.Fluent:Destroy()
end

----------------------------------------------------------------
-- ======= [ LOAD FLUENT UI ] =======
----------------------------------------------------------------
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Fisch Trade Ultimate SIM",
    SubTitle = "v1.8 - All Features",
    TabWidth = 110,
    Size = GuiSize,
    Acrylic = false, -- Dimatikan agar tidak meninggalkan bekas blur
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
local MyInventoryFish = {} 

-- Inisialisasi Data Game Asli
task.spawn(function()
    pcall(function()
        local packages = ReplicatedStorage:WaitForChild("Packages", 10)
        local shared = ReplicatedStorage:WaitForChild("Shared", 10)
        if packages and shared then
            Replion = require(packages:WaitForChild("Replion"))
            ItemUtility = require(shared:WaitForChild("ItemUtility"))
            repeat 
                DataReplion = Replion.Client:GetReplion("Data")
                task.wait(1)
            until DataReplion ~= nil
        end
    end)
end)

----------------------------------------------------------------
-- ======= [ CORE FUNCTIONS ] =======
----------------------------------------------------------------

local function getRealPlayers()
    local pList = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(pList, p.Name) end
    end
    return #pList > 0 and pList or {"No Players Found"}
end

local function scanBackpack()
    MyInventoryFish = {} 
    local fishNames = {}
    if not DataReplion or not ItemUtility then return {"Data Not Loaded"} end
    
    local data = DataReplion:Get("Inventory")
    local items = (data and data.Items) or {}
    
    for _, item in ipairs(items) do
        local base = ItemUtility:GetItemData(item.Id)
        if base and base.Data and base.Data.Type == "Fish" then
            table.insert(MyInventoryFish, {Name = base.Data.Name, Tier = tostring(base.Data.Tier), UUID = item.UUID})
            table.insert(fishNames, base.Data.Name .. " [T" .. base.Data.Tier .. "]")
        end
    end
    return #fishNames > 0 and fishNames or {"No Fish Found"}
end

----------------------------------------------------------------
-- ======= [ UI TABS ] =======
----------------------------------------------------------------
local Tabs = {
    Main = Window:AddTab({ Title = "Send Trade", Icon = "send" }),
    Receive = Window:AddTab({ Title = "Accept", Icon = "download" }),
    Settings = Window:AddTab({ Title = "Cleanup", Icon = "trash-2" })
}

-- [[ TAB SEND TRADE ]] --
local TradeSection = Tabs.Main:AddSection("Trade & Manual Selection")

local PlayerDropdown = TradeSection:AddDropdown("TargetPlayer", {
    Title = "1. Select Target Player",
    Values = getRealPlayers(),
    Multi = false,
})

local FishDropdown = TradeSection:AddDropdown("FishSelect", {
    Title = "2. Select Fish from Backpack",
    Values = {"Click Refresh Backpack First"},
    Multi = false,
})

TradeSection:AddButton({
    Title = "3. Refresh Players & Backpack",
    Description = "Klik untuk menscan ulang isi tas Anda",
    Callback = function() 
        PlayerDropdown:SetValues(getRealPlayers()) 
        local currentFishList = scanBackpack()
        FishDropdown:SetValues(currentFishList)
        Fluent:Notify({Title = "Scanner", Content = "Ditemukan " .. #MyInventoryFish .. " ikan.", Duration = 2})
    end
})

TradeSection:AddInput("TradeAmt", {
    Title = "Quantity",
    Default = "1",
    Numeric = true,
    Callback = function(v) _G.TradeAmt = tonumber(v) or 1 end
})

TradeSection:AddButton({
    Title = "EXECUTE SIMULATION",
    Callback = function()
        local target = PlayerDropdown.Value
        local fish = FishDropdown.Value
        if not target or target == "No Players Found" then return Fluent:Notify({Title = "Error", Content = "Pilih Player!"}) end
        if not fish or fish:find("Refresh") then return Fluent:Notify({Title = "Error", Content = "Pilih Ikan!"}) end

        Fluent:Notify({Title = "Simulation", Content = "Mengirim " .. fish .. " ke " .. target, Duration = 4})
    end
})

-- [[ TAB RECEIVE ]] --
local RecSection = Tabs.Receive:AddSection("Auto Accept Settings")
RecSection:AddToggle("AutoAccept", {
    Title = "Auto Accept Trade (Sim)",
    Default = false,
    Callback = function(v) 
        Fluent:Notify({Title = "Receiver", Content = "Auto Accept set to: " .. tostring(v), Duration = 2})
    end
})

-- [[ TAB CLEANUP ]] --
local CleanSection = Tabs.Settings:AddSection("Force Cleanup")
CleanSection:AddButton({
    Title = "Destroy GUI Permanently",
    Description = "Gunakan ini jika GUI 'nyangkut' atau ingin berhenti total",
    Callback = function()
        Window:Destroy()
    end
})

Window:SelectTab(1)
Fluent:Notify({Title = "Ready", Content = "v1.8 Loaded. Resize pojok kanan bawah jika diperlukan.", Duration = 5})
