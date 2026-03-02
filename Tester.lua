----------------------------------------------------------------
-- ======= [ PAWFY SYSTEM CONFIG & RGB ] =======
----------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Branding: Pawfy Trade System Color Palette
local PawfyColors = {
    ["1"] = {BG = Color3.fromRGB(255, 255, 255), TXT = Color3.fromRGB(0, 0, 0)},     -- COMMON
    ["2"] = {BG = Color3.fromRGB(126, 255, 28),  TXT = Color3.fromRGB(0, 0, 0)},     -- UNCOMMON
    ["3"] = {BG = Color3.fromRGB(0, 68, 255),    TXT = Color3.fromRGB(0, 0, 0)},     -- RARE
    ["4"] = {BG = Color3.fromRGB(74, 0, 153),    TXT = Color3.fromRGB(255, 255, 255)}, -- EPIC
    ["5"] = {BG = Color3.fromRGB(255, 187, 0),   TXT = Color3.fromRGB(0, 0, 0)},     -- LEGENDARY
    ["6"] = {BG = Color3.fromRGB(255, 0, 0),     TXT = Color3.fromRGB(255, 255, 255)}, -- MYTHIC
    ["7"] = {BG = Color3.fromRGB(17, 217, 157),  TXT = Color3.fromRGB(0, 0, 0)}      -- SECRET
}

----------------------------------------------------------------
-- ======= [ PAWFY CUSTOM UI ENGINE ] =======
----------------------------------------------------------------
local PawfySys = {}
local PawfyGUI = Instance.new("ScreenGui", game.CoreGui)
PawfyGUI.Name = "PawfyTradeSystem_v5"

function PawfySys:CreateInterface(title)
    local MainFrame = Instance.new("Frame", PawfyGUI)
    MainFrame.Size = UDim2.new(0, 330, 0, 450)
    MainFrame.Position = UDim2.new(0.5, -165, 0.5, -225)
    MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    MainFrame.BorderSizePixel = 0
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

    -- Header Pawfy Style
    local Header = Instance.new("Frame", MainFrame)
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundTransparency = 1
    
    local Title = Instance.new("TextLabel", Header)
    Title.Size = UDim2.new(1, 0, 1, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "🐾 " .. title
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 15

    -- Pawfy Search Bar
    local Search = Instance.new("TextBox", MainFrame)
    Search.Size = UDim2.new(1, -24, 0, 32)
    Search.Position = UDim2.new(0, 12, 0, 45)
    Search.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Search.PlaceholderText = "Search Fish in Pawfy System..."
    Search.Text = ""
    Search.TextColor3 = Color3.fromRGB(255, 255, 255)
    Search.Font = Enum.Font.Gotham
    Search.TextSize = 12
    Instance.new("UICorner", Search).CornerRadius = UDim.new(0, 6)

    -- Scrolling List Area
    local Scroll = Instance.new("ScrollingFrame", MainFrame)
    Scroll.Size = UDim2.new(1, -24, 1, -140)
    Scroll.Position = UDim2.new(0, 12, 0, 85)
    Scroll.BackgroundTransparency = 1
    Scroll.ScrollBarThickness = 2
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local Layout = Instance.new("UIListLayout", Scroll)
    Layout.Padding = UDim.new(0, 6)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder

    -- Pawfy Sync Button
    local Sync = Instance.new("TextButton", MainFrame)
    Sync.Size = UDim2.new(1, -24, 0, 38)
    Sync.Position = UDim2.new(0, 12, 1, -48)
    Sync.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Sync.Text = "UPDATE PAWFY DATABASE"
    Sync.TextColor3 = Color3.fromRGB(255, 255, 255)
    Sync.Font = Enum.Font.GothamBold
    Sync.TextSize = 13
    Instance.new("UICorner", Sync).CornerRadius = UDim.new(0, 8)

    -- Function to inject colored bars
    function PawfySys:InjectFish(name, qty, tier)
        local cfg = PawfyColors[tostring(tier)] or PawfyColors["1"]
        
        local Bar = Instance.new("Frame", Scroll)
        Bar.Name = name:lower()
        Bar.Size = UDim2.new(1, -6, 0, 32)
        Bar.BackgroundColor3 = cfg.BG -- WARNA BACKGROUND AKTIF
        Bar.BorderSizePixel = 0
        Bar.LayoutOrder = -tonumber(tier) -- Sorting Kasta
        Instance.new("UICorner", Bar).CornerRadius = UDim.new(0, 6)

        local Label = Instance.new("TextLabel", Bar)
        Label.Size = UDim2.new(1, 0, 1, 0)
        Label.BackgroundTransparency = 1
        Label.Text = name .. " (" .. qty .. ")"
        Label.TextColor3 = cfg.TXT -- WARNA TEKS AKTIF
        Label.Font = Enum.Font.GothamBold
        Label.TextSize = 13

        Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y)
    end

    function PawfySys:Purge()
        for _, v in pairs(Scroll:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
    end

    -- Search Listener
    Search:GetPropertyChangedSignal("Text"):Connect(function()
        local t = Search.Text:lower()
        for _, v in pairs(Scroll:GetChildren()) do
            if v:IsA("Frame") then v.Visible = v.Name:find(t) ~= nil end
        end
    end)

    return Sync
end

----------------------------------------------------------------
-- ======= [ PAWFY DATA HANDLER ] =======
----------------------------------------------------------------
local Replion, ItemUtility, DataReplion
task.spawn(function()
    pcall(function()
        Replion = require(ReplicatedStorage.Packages.Replion)
        ItemUtility = require(ReplicatedStorage.Shared.ItemUtility)
        repeat 
            DataReplion = Replion.Client:GetReplion("Data")
            task.wait(1)
        until DataReplion ~= nil
    end)
end)

local function PawfyRefresh()
    PawfySys:Purge()
    local inv = DataReplion and DataReplion:Get("Inventory")
    local items = (inv and inv.Items) or {}
    
    local counts = {}
    local tierMap = {}
    for _, item in pairs(items) do
        local base = ItemUtility:GetItemData(item.Id)
        if base and base.Data and base.Data.Type == "Fish" then
            local n = base.Data.Name
            counts[n] = (counts[n] or 0) + 1
            tierMap[n] = tostring(base.Data.Tier or "1")
        end
    end

    for name, qty in pairs(counts) do
        PawfySys:InjectFish(name, qty, tierMap[name])
    end
end

----------------------------------------------------------------
-- ======= [ PAWFY EXECUTION ] =======
----------------------------------------------------------------
local FinalButton = PawfySys:CreateInterface("PAWFY TRADE SYSTEM")
FinalButton.MouseButton1Click:Connect(PawfyRefresh)
PawfyRefresh()
