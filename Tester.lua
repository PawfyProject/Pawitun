----------------------------------------------------------------
-- ======= [ CONFIGURATION ] =======
----------------------------------------------------------------
local SimulationMode = true 
local DefaultSize = UDim2.fromOffset(450, 380)

----------------------------------------------------------------
-- ======= [ LOAD FLUENT UI LIBRARY ] =======
----------------------------------------------------------------
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Fisch Trade Tool",
    SubTitle = "v1.6 - Fixed Grouping",
    TabWidth = 110,
    Size = DefaultSize,
    Acrylic = false, 
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

pcall(function()
    local packages = ReplicatedStorage:WaitForChild("Packages")
    Replion = require(packages:WaitForChild("Replion"))
    ItemUtility = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ItemUtility"))
    DataReplion = Replion.Client:WaitReplion("Data")
end)

local state = {
    SelectedTier = "7",
}

----------------------------------------------------------------
-- ======= [ CORE LOGIC: GROUPING SYSTEM ] =======
----------------------------------------------------------------

-- Fungsi utama untuk scan dan menggabungkan nama yang sama
local function getGroupedFishList(tier)
    if not DataReplion or not ItemUtility then 
        return {"Data Not Found"} 
    end
    
    local inventory = DataReplion:Get("Inventory")
    local items = (inventory and inventory.Items) or {}
    
    local counts = {} -- Tempat menyimpan jumlah ikan berdasarkan nama
    
    for _, item in ipairs(items) do
        local base = ItemUtility:GetItemData(item.Id)
        if base and base.Data and base.Data.Type == "Fish" then
            if tostring(base.Data.Tier) == tostring(tier) then
                local name = base.Data.Name
                counts[name] = (counts[name] or 0) + 1
            end
        end
    end
    
    local displayList = {}
    for name, amount in pairs(counts) do
        -- Format: "Nama Ikan (xJumlah)"
        table.insert(displayList, name .. " (x" .. amount .. ")")
    end
    
    if #displayList == 0 then return {"Tidak ada ikan di Tier ini"} end
    table.sort(displayList) -- Urutkan sesuai abjad
    return displayList
end

local function getRealPlayers()
    local pList = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(pList, p.Name) end
    end
    return #pList > 0 and pList or {"Tidak ada player lain"}
end

----------------------------------------------------------------
-- ======= [ UI TABS ] =======
----------------------------------------------------------------
local Tabs = {
    Main = Window:AddTab({ Title = "Trade", Icon = "send" }),
    Receive = Window:AddTab({ Title = "Accept", Icon = "download" })
}

local MainSection = Tabs.Main:AddSection("Inventory & Trade")

-- 1. Dropdown Player
local PlayerDropdown = MainSection:AddDropdown("TargetPlayer", {
    Title = "Select Player",
    Values = getRealPlayers(),
    Multi = false,
})

-- 2. Dropdown Tier (Memicu update pada daftar ikan)
local TierDropdown = MainSection:AddDropdown("TierFilter", {
    Title = "Pilih Tier",
    Values = {"1", "2", "3", "4", "5", "6", "7", "Secret"},
    Default = "7",
    Callback = function(v) 
        state.SelectedTier = v 
        -- Update otomatis daftar ikan saat tier diganti
        local newList = getGroupedFishList(v)
        _G.FishDisplayDropdown:SetValues(newList)
    end
})

-- 3. DROPDOWN HASIL SCAN (Ini yang memperbaiki tampilan berulang Anda)
_G.FishDisplayDropdown = MainSection:AddDropdown("FishInBackpack", {
    Title = "Ikan Ditemukan (Grouped)",
    Values = getGroupedFishList(state.SelectedTier),
    Multi = false,
    Description = "Ikan dengan nama sama otomatis digabung"
})

MainSection:AddButton({
    Title = "Refresh Data",
    Description = "Update daftar player dan isi backpack",
    Callback = function()
        PlayerDropdown:SetValues(getRealPlayers())
        _G.FishDisplayDropdown:SetValues(getGroupedFishList(state.SelectedTier))
        Fluent:Notify({Title = "Updated", Content = "Data inventory telah diperbarui.", Duration = 2})
    end
})

MainSection:AddButton({
    Title = "Simulasi Trade",
    Callback = function()
        Fluent:Notify({
            Title = "Simulation",
            Content = "Menyiapkan pengiriman ikan yang dipilih...",
            Duration = 3
        })
    end
})

-- [[ TAB RECEIVE ]] --
local RecSection = Tabs.Receive:AddSection("Receiver Settings")
RecSection:AddToggle("AutoAccept", {
    Title = "Auto Accept Trade",
    Default = false,
})

Window:SelectTab(1)
