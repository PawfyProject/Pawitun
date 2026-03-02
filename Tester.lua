----------------------------------------------------------------
-- ======= [ CONFIGURATION ] =======
----------------------------------------------------------------
local SimulationMode = true 
local DefaultSize = UDim2.fromOffset(450, 400)

----------------------------------------------------------------
-- ======= [ LOAD FLUENT UI LIBRARY ] =======
----------------------------------------------------------------
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Fisch Trade Tool",
    SubTitle = "v1.9 - Restoration Fix",
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
-- ======= [ FIX LOGIC: RESTORE DISPLAY ] =======
----------------------------------------------------------------

-- 1. Menghitung jumlah per Tier untuk label Dropdown
local function getTierLabels()
    local tierOptions = {"1", "2", "3", "4", "5", "6", "7", "Secret"}
    local finalLabels = {}
    
    local inventory = (DataReplion and DataReplion:Get("Inventory")) or {}
    local items = inventory.Items or {}
    local counts = {["1"]=0, ["2"]=0, ["3"]=0, ["4"]=0, ["5"]=0, ["6"]=0, ["7"]=0, ["Secret"]=0}

    for _, item in ipairs(items) do
        local base = ItemUtility:GetItemData(item.Id)
        if base and base.Data and base.Data.Type == "Fish" then
            local t = tostring(base.Data.Tier)
            if counts[t] ~= nil then counts[t] = counts[t] + 1 end
        end
    end

    for _, t in ipairs(tierOptions) do
        table.insert(finalLabels, "T" .. t .. " (" .. counts[t] .. ")")
    end
    return finalLabels
end

-- 2. Mengambil daftar ikan dengan format "Nama [Tier] (Quantity)"
local function getFishDisplayList(tierInput)
    -- Membersihkan input "T7 (10)" menjadi "7"
    local cleanTier = tierInput:match("T(%d+)") or tierInput:match("T(%a+)") or tierInput
    
    local inventory = (DataReplion and DataReplion:Get("Inventory")) or {}
    local items = inventory.Items or {}
    local grouped = {}
    
    for _, item in ipairs(items) do
        local base = ItemUtility:GetItemData(item.Id)
        if base and base.Data and base.Data.Type == "Fish" then
            if tostring(base.Data.Tier) == cleanTier then
                local displayName = base.Data.Name .. " [T" .. base.Data.Tier .. "]"
                grouped[displayName] = (grouped[displayName] or 0) + 1
            end
        end
    end
    
    local finalArray = {}
    for name, qty in pairs(grouped) do
        table.insert(finalArray, name .. " (x" .. qty .. ")")
    end
    
    table.sort(finalArray)
    return #finalArray > 0 and finalArray or {"Kosong di Tier ini"}
end

----------------------------------------------------------------
-- ======= [ UI TABS ] =======
----------------------------------------------------------------
local Tabs = {
    Main = Window:AddTab({ Title = "Trade", Icon = "send" }),
    Receive = Window:AddTab({ Title = "Accept", Icon = "download" })
}

local MainSection = Tabs.Main:AddSection("Inventory Monitor")

-- Dropdown Tier (Rarity)
_G.TierDropdown = MainSection:AddDropdown("TierFilter", {
    Title = "Select Rarity",
    Values = getTierLabels(),
    Default = "T7 (0)",
    Callback = function(v) 
        state.SelectedTier = v 
        _G.FishDropdown:SetValues(getFishDisplayList(v))
    end
})

-- Dropdown Ikan (Sekarang akan muncul Nama [T7] (xJumlah))
_G.FishDropdown = MainSection:AddDropdown("FishInBackpack", {
    Title = "Fish in Backpack",
    Values = {"Pilih Tier untuk scan"},
    Multi = false,
})

MainSection:AddButton({
    Title = "Refresh Data",
    Callback = function()
        _G.TierDropdown:SetValues(getTierLabels())
        _G.FishDropdown:SetValues(getFishDisplayList(state.SelectedTier))
        Fluent:Notify({Title = "Updated", Content = "Daftar ikan telah diperbarui.", Duration = 2})
    end
})

-- Auto-Init saat start
task.spawn(function()
    task.wait(1.5)
    _G.TierDropdown:SetValues(getTierLabels())
end)

Window:SelectTab(1)
