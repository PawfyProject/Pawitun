----------------------------------------------------------------
-- ======= [ CONFIGURATION ] =======
----------------------------------------------------------------
local SimulationMode = true 
local DefaultSize = UDim2.fromOffset(420, 350) -- Ukuran lebih compact

----------------------------------------------------------------
-- ======= [ LOAD FLUENT UI LIBRARY ] =======
----------------------------------------------------------------
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Fisch Trade SIM v1.5",
    SubTitle = "Grouping & Discovery",
    TabWidth = 110,
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

pcall(function()
    local packages = ReplicatedStorage:WaitForChild("Packages")
    Replion = require(packages:WaitForChild("Replion"))
    ItemUtility = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ItemUtility"))
    DataReplion = Replion.Client:WaitReplion("Data")
end)

local state = {
    SelectedTier = "7",
    AutoAccept = false
}

----------------------------------------------------------------
-- ======= [ GROUPING LOGIC FUNCTIONS ] =======
----------------------------------------------------------------

-- 1. Deteksi Player Asli
local function getRealPlayers()
    local pList = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(pList, p.Name) end
    end
    return #pList > 0 and pList or {"Tidak ada player"}
end

-- 2. Deteksi Ikan dengan Fitur Grouping (Nama (Quantity))
local function scanAndGroupInventory(tier)
    if not DataReplion or not ItemUtility then 
        return { {display = "Data Not Linked", count = 0} } 
    end
    
    local inventory = DataReplion:Get("Inventory")
    local items = (inventory and inventory.Items) or {}
    
    local fishCounts = {} -- Tabel untuk menghitung jumlah per nama
    
    for _, item in ipairs(items) do
        local base = ItemUtility:GetItemData(item.Id)
        if base and base.Data and base.Data.Type == "Fish" then
            if tostring(base.Data.Tier) == tostring(tier) then
                local fishName = base.Data.Name
                -- Tambahkan ke hitungan jika nama sudah ada
                fishCounts[fishName] = (fishCounts[fishName] or 0) + 1
            end
        end
    end
    
    -- Ubah hasil hitungan menjadi array untuk tampilan UI
    local result = {}
    for name, count in pairs(fishCounts) do
        table.insert(result, {
            display = name .. " (" .. count .. ")",
            rawName = name,
            count = count
        })
    end
    return result
end

----------------------------------------------------------------
-- ======= [ UI TABS ] =======
----------------------------------------------------------------
local Tabs = {
    Main = Window:AddTab({ Title = "Trade", Icon = "send" }),
    Receive = Window:AddTab({ Title = "Accept", Icon = "download" })
}

local MainSection = Tabs.Main:AddSection("Inventory Scanner")

MainSection:AddParagraph({
    Title = "Fitur Grouping Aktif",
    Content = "Ikan dengan nama yang sama akan ditampilkan sebagai: Nama (Jumlah)."
})

-- Player Selection
local PlayerDropdown = MainSection:AddDropdown("TargetPlayer", {
    Title = "Target Player",
    Values = getRealPlayers(),
    Multi = false,
})

-- Tier Selection
local TierDropdown = MainSection:AddDropdown("TierFilter", {
    Title = "Pilih Tier untuk Di-scan",
    Values = {"1", "2", "3", "4", "5", "6", "7", "Secret"},
    Default = "7",
    Callback = function(v) state.SelectedTier = v end
})

-- Tombol Scan & Lihat Hasil Grouping
MainSection:AddButton({
    Title = "Cek Backpack (Grouped)",
    Description = "Lihat daftar ikan yang ditemukan",
    Callback = function()
        local groupedFish = scanAndGroupInventory(state.SelectedTier)
        
        if #groupedFish > 0 then
            local fullList = ""
            local totalFish = 0
            for _, fish in ipairs(groupedFish) do
                fullList = fullList .. "- " .. fish.display .. "\n"
                totalFish = totalFish + fish.count
            end
            
            Fluent:Notify({
                Title = "Hasil Scan Tier " .. state.SelectedTier,
                Content = "Total " .. totalFish .. " ikan ditemukan:\n" .. fullList,
                Duration = 6
            })
        else
            Fluent:Notify({
                Title = "Kosong",
                Content = "Tidak ada ikan Tier " .. state.SelectedTier .. " di backpack.",
                Duration = 3
            })
        end
    end
})

MainSection:AddButton({
    Title = "Simulasikan Trade",
    Callback = function()
        local target = PlayerDropdown.Value
        if not target or target == "Tidak ada player" then 
            return Fluent:Notify({Title = "Error", Content = "Pilih player dulu!"}) 
        end
        
        Fluent:Notify({
            Title = "Simulation Mode",
            Content = "Menjalankan alur trade ke " .. target .. " (Hanya Visual)",
            Duration = 3
        })
    end
})

-- [[ TAB RECEIVE ]] --
local RecSection = Tabs.Receive:AddSection("Settings")
RecSection:AddToggle("AutoAccept", {
    Title = "Auto Accept Trade",
    Default = false,
    Callback = function(v) state.AutoAccept = v end
})

Window:SelectTab(1)

-- Resize Manual Tetap Aktif di Pojok Kanan Bawah
Fluent:Notify({
    Title = "Safe Mode v1.5",
    Content = "Grouping Nama (Quantity) Berhasil Ditambahkan.",
    Duration = 5
})
