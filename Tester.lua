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
    SubTitle = "v1.7 - Tier Counter",
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
-- ======= [ CORE LOGIC: GROUPING & TIER COUNTER ] =======
----------------------------------------------------------------

-- 1. Fungsi untuk menghitung jumlah ikan per Tier (Untuk Dropdown Tier)
local function getTierValuesWithCount()
    local tierOptions = {"1", "2", "3", "4", "5", "6", "7", "Secret"}
    local finalOptions = {}
    
    if not DataReplion or not ItemUtility then 
        for _, t in ipairs(tierOptions) do table.insert(finalOptions, "T" .. t .. " (0)") end
        return finalOptions 
    end

    local inventory = DataReplion:Get("Inventory")
    local items = (inventory and inventory.Items) or {}
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

-- 2. Fungsi untuk list ikan (Grouping Nama)
local function getGroupedFishList(tier)
    -- Membersihkan input tier dari format "T7 (10)" menjadi "7"
    local cleanTier = tier:match("T(%d+)") or tier:match("T(%a+)") or tier
    
    if not DataReplion or not ItemUtility then return {"Data Not Found"} end
    
    local inventory = DataReplion:Get("Inventory")
    local items = (inventory and inventory.Items) or {}
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
    
    if #displayList == 0 then return {"Kosong"} end
    table.sort(displayList)
    return displayList
end

local function getRealPlayers()
    local pList = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(pList, p.Name) end
    end
    return #pList > 0 and pList or {"Tidak ada player"}
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

-- 2. Dropdown Tier dengan COUNTER (Fitur Baru)
_G.TierDropdown = MainSection:AddDropdown("TierFilter", {
    Title = "Fish Tiers (Rarity)",
    Values = getTierValuesWithCount(),
    Default = "T7 (0)",
    Callback = function(v) 
        state.SelectedTier = v 
        local newList = getGroupedFishList(v)
        _G.FishDisplayDropdown:SetValues(newList)
    end
})

-- 3. Dropdown Ikan (Grouping Nama)
_G.FishDisplayDropdown = MainSection:AddDropdown("FishInBackpack", {
    Title = "Fish Found",
    Values = getGroupedFishList("7"),
    Multi = false,
})

MainSection:AddButton({
    Title = "Refresh All Data",
    Description = "Update Player, Tier Counts, and Fish List",
    Callback = function()
        PlayerDropdown:SetValues(getRealPlayers())
        _G.TierDropdown:SetValues(getTierValuesWithCount())
        _G.FishDisplayDropdown:SetValues(getGroupedFishList(state.SelectedTier))
        Fluent:Notify({Title = "Refresh Success", Content = "Data inventory terbaru telah dimuat.", Duration = 2})
    end
})

MainSection:AddButton({
    Title = "Execute Trade (Sim)",
    Callback = function()
        Fluent:Notify({Title = "Simulation", Content = "Alur pengiriman dimulai...", Duration = 2})
    end
})

-- [[ TAB RECEIVE ]] --
local RecSection = Tabs.Receive:AddSection("Receiver Settings")
RecSection:AddToggle("AutoAccept", { Title = "Auto Accept Trade", Default = false })

Window:SelectTab(1)
