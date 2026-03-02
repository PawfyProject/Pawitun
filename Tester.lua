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
    SubTitle = "v1.8 - Auto-Update Fixed",
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
-- ======= [ CORE LOGIC: REFRESH SYSTEM ] =======
----------------------------------------------------------------

-- Fungsi Menghitung Jumlah Ikan per Tier
local function getTierValuesWithCount()
    local tierOptions = {"1", "2", "3", "4", "5", "6", "7", "Secret"}
    local finalOptions = {}
    
    local inventory = (DataReplion and DataReplion:Get("Inventory")) or {}
    local items = inventory.Items or {}
    local tierCounts = {["1"]=0, ["2"]=0, ["3"]=0, ["4"]=0, ["5"]=0, ["6"]=0, ["7"]=0, ["Secret"]=0}

    for _, item in ipairs(items) do
        local base = ItemUtility:GetItemData(item.Id)
        if base and base.Data and base.Data.Type == "Fish" then
            local t = tostring(base.Data.Tier)
            if tierCounts[t] ~= nil then
                tierCounts[t] = tierCounts[t] + 1
            end
        end
    end

    for _, t in ipairs(tierOptions) do
        table.insert(finalOptions, "T" .. t .. " (" .. tierCounts[t] .. ")")
    end
    return finalOptions
end

-- Fungsi Grouping Nama Ikan
local function getGroupedFishList(tierString)
    -- Membersihkan string "T7 (10)" menjadi "7"
    local cleanTier = tierString:match("T(%d+)") or tierString:match("T(%a+)") or tierString
    
    local inventory = (DataReplion and DataReplion:Get("Inventory")) or {}
    local items = inventory.Items or {}
    local counts = {}
    
    for _, item in ipairs(items) do
        local base = ItemUtility:GetItemData(item.Id)
        if base and base.Data and base.Data.Type == "Fish" then
            if tostring(base.Data.Tier) == cleanTier then
                local name = base.Data.Name
                counts[name] = (counts[name] or 0) + 1
            end
        end
    end
    
    local displayList = {}
    for name, amount in pairs(counts) do
        table.insert(displayList, name .. " (x" .. amount .. ")")
    end
    
    return #displayList > 0 and displayList or {"Kosong"}
end

----------------------------------------------------------------
-- ======= [ UI TABS ] =======
----------------------------------------------------------------
local Tabs = {
    Main = Window:AddTab({ Title = "Trade", Icon = "send" }),
    Receive = Window:AddTab({ Title = "Accept", Icon = "download" })
}

local MainSection = Tabs.Main:AddSection("Inventory Monitor")

-- Dropdown Player
local PlayerDropdown = MainSection:AddDropdown("TargetPlayer", {
    Title = "Select Player",
    Values = {"Mencari player..."},
    Multi = false,
})

-- Dropdown Tier dengan Jumlah
_G.TierDropdown = MainSection:AddDropdown("TierFilter", {
    Title = "Fish Tiers (Rarity)",
    Values = getTierValuesWithCount(),
    Default = "T7 (0)",
    Callback = function(v) 
        state.SelectedTier = v 
        _G.FishDisplayDropdown:SetValues(getGroupedFishList(v))
    end
})

-- Dropdown Daftar Ikan
_G.FishDisplayDropdown = MainSection:AddDropdown("FishInBackpack", {
    Title = "Fish Found (Name x Quantity)",
    Values = {"Pilih Tier dulu"},
    Multi = false,
})

MainSection:AddButton({
    Title = "Manual Refresh",
    Callback = function()
        _G.TierDropdown:SetValues(getTierValuesWithCount())
        _G.FishDisplayDropdown:SetValues(getGroupedFishList(state.SelectedTier))
        Fluent:Notify({Title = "Updated", Content = "Data tas diperbarui.", Duration = 2})
    end
})

----------------------------------------------------------------
-- ======= [ AUTO-INITIALIZE ] =======
----------------------------------------------------------------

-- Fungsi agar saat script di-run, data langsung muncul
task.spawn(function()
    task.wait(1) -- Tunggu modul load
    local initialTiers = getTierValuesWithCount()
    _G.TierDropdown:SetValues(initialTiers)
    
    -- Ambil daftar player asli
    local pList = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(pList, p.Name) end
    end
    PlayerDropdown:SetValues(#pList > 0 and pList or {"Tidak ada player"})
end)

Window:SelectTab(1)
