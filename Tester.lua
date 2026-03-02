----------------------------------------------------------------
-- ======= [ CONFIGURATION ] =======
----------------------------------------------------------------
local SimulationMode = true -- TETAP TRUE (Hanya simulasi visual)
local DefaultSize = UDim2.fromOffset(450, 380) 

----------------------------------------------------------------
-- ======= [ LOAD FLUENT UI LIBRARY ] =======
----------------------------------------------------------------
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Fisch Trade SIMULATOR",
    SubTitle = "v1.4 - Discovery Mode",
    TabWidth = 120,
    Size = DefaultSize,
    Acrylic = false, 
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

----------------------------------------------------------------
-- ======= [ DATA SCANNER (REAL DETECTION) ] =======
----------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Replion, ItemUtility, DataReplion

-- Mendeteksi Modul Data Asli Game
pcall(function()
    local packages = ReplicatedStorage:WaitForChild("Packages")
    Replion = require(packages:WaitForChild("Replion"))
    ItemUtility = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ItemUtility"))
    DataReplion = Replion.Client:WaitReplion("Data")
end)

local state = {
    SelectedTier = "7",
    TradeQuantity = 0,
    AutoAccept = false,
    Category = "Fish"
}

----------------------------------------------------------------
-- ======= [ REAL-TIME SCANNER FUNCTIONS ] =======
----------------------------------------------------------------

-- 1. Mendeteksi SEMUA Player Asli di Server
local function getRealPlayers()
    local pList = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then 
            table.insert(pList, p.Name) 
        end
    end
    if #pList == 0 then return {"Tidak ada player lain"} end
    return pList
end

-- 2. Mendeteksi SEMUA Ikan Asli di Inventory Anda
local function scanInventoryForFish(tier)
    if not DataReplion or not ItemUtility then 
        return { {name = "Data Not Linked", uuid = "0"} } 
    end
    
    local found = {}
    local inventory = DataReplion:Get("Inventory")
    local items = (inventory and inventory.Items) or {}
    
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
    Main = Window:AddTab({ Title = "Send Trade", Icon = "send" }),
    Receive = Window:AddTab({ Title = "Accept", Icon = "download" })
}

local MainSection = Tabs.Main:AddSection("Discovery & Simulation")

MainSection:AddParagraph({
    Title = "Mode Deteksi Aktif",
    Content = "Script ini MEMBACA player & ikan asli Anda, tapi TIDAK melakukan trade."
})

-- DROPDOWN: Player (Real Detection)
local PlayerDropdown = MainSection:AddDropdown("TargetPlayer", {
    Title = "Select Real Player",
    Values = getRealPlayers(),
    Multi = false,
    Default = nil,
})

MainSection:AddButton({
    Title = "Refresh Players",
    Callback = function() 
        PlayerDropdown:SetValues(getRealPlayers()) 
        Fluent:Notify({Title = "Scanner", Content = "Daftar player diperbarui", Duration = 1})
    end
})

-- DROPDOWN: Tier Filter
local TierDropdown = MainSection:AddDropdown("TierFilter", {
    Title = "Select Fish Tier to Scan",
    Values = {"1", "2", "3", "4", "5", "6", "7", "Secret"},
    Default = "7",
    Callback = function(v) state.SelectedTier = v end
})

-- BUTTON: Cek Inventory (Test Detection)
MainSection:AddButton({
    Title = "Scan My Inventory (Tier " .. state.SelectedTier .. ")",
    Description = "Mengetes apakah script bisa melihat ikan Anda",
    Callback = function()
        local myFish = scanInventoryForFish(state.SelectedTier)
        if #myFish > 0 then
            Fluent:Notify({
                Title = "Scanner Berhasil",
                Content = "Ditemukan " .. #myFish .. " ikan Tier " .. state.SelectedTier .. " di tas Anda.",
                Duration = 4
            })
        else
            Fluent:Notify({
                Title = "Scanner Kosong",
                Content = "Tidak ada ikan Tier " .. state.SelectedTier .. " di inventory.",
                Duration = 3
            })
        end
    end
})

-- BUTTON: Simulasi Eksekusi
MainSection:AddButton({
    Title = "Simulate Trade Execution",
    Description = "Tes alur tanpa mengirim data ke server",
    Callback = function()
        local target = PlayerDropdown.Value
        if not target or target == "Tidak ada player lain" then 
            return Fluent:Notify({Title = "Error", Content = "Pilih player asli!"}) 
        end

        local myFish = scanInventoryForFish(state.SelectedTier)
        if #myFish == 0 then
            return Fluent:Notify({Title = "Aborted", Content = "Ikan tidak ditemukan, simulasi berhenti."})
        end

        Fluent:Notify({
            Title = "SIMULASI BERJALAN",
            Content = "Mencoba mengirim " .. myFish[1].name .. " ke " .. target,
            Duration = 5
        })
        print("DEBUG: Simulasi berhasil. Ikan terdeteksi: " .. myFish[1].name .. " (" .. myFish[1].uuid .. ")")
    end
})

-- [[ RECEIVE TAB ]] --
local RecSection = Tabs.Receive:AddSection("Receiver Simulation")
RecSection:AddToggle("AutoAccept", {
    Title = "Auto Accept (Visual Only)",
    Default = false,
    Callback = function(v) state.AutoAccept = v end
})

Window:SelectTab(1)
Fluent:Notify({Title = "Safe Mode v1.4", Content = "Deteksi Player & Inventory Aktif. Resize pojok kanan bawah.", Duration = 5})
