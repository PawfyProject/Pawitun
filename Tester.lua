----------------------------------------------------------------
-- ======= [ CORE SERVICES & CONFIG ] =======
----------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- Definisi Warna RGB Sesuai Permintaan Anda
local TierSettings = {
    ["1"] = Color3.fromRGB(170, 170, 170), -- Common (Abu-abu)
    ["2"] = Color3.fromRGB(85, 255, 127),  -- Uncommon (Hijau)
    ["3"] = Color3.fromRGB(0, 170, 255),  -- Rare (Biru)
    ["4"] = Color3.fromRGB(170, 0, 255),  -- Epic (Ungu)
    ["5"] = Color3.fromRGB(255, 170, 0),  -- Legendary (Oranye)
    ["6"] = Color3.fromRGB(255, 0, 127),  -- Mythic (Pink/Hot Red)
    ["7"] = Color3.fromRGB(0, 255, 255)   -- SECRET (Cyan/Aqua)
}

local LynxLib = {}
function LynxLib:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Size = UDim2.new(0, 400, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    MainFrame.BorderSizePixel = 0
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

    local TitleLabel = Instance.new("TextLabel", MainFrame)
    TitleLabel.Size = UDim2.new(1, 0, 0, 40)
    TitleLabel.Text = "  " .. title
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.TextSize = 16

    local ScrollFrame = Instance.new("ScrollingFrame", MainFrame)
    ScrollFrame.Size = UDim2.new(1, -20, 1, -120)
    ScrollFrame.Position = UDim2.new(0, 10, 0, 50)
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollFrame.ScrollBarThickness = 2
    local Layout = Instance.new("UIListLayout", ScrollFrame)
    Layout.Padding = UDim.new(0, 5)

    -- Fungsi Tambah Item dengan Warna Custom
    function LynxLib:AddItem(name, tier)
        local cfg = TierSettings[tostring(tier)] or TierSettings["1"]
        
        local ItemFrame = Instance.new("Frame", ScrollFrame)
        ItemFrame.Size = UDim2.new(1, -5, 0, 30)
        ItemFrame.BackgroundColor3 = cfg.BG
        ItemFrame.BorderSizePixel = 0
        Instance.new("UICorner", ItemFrame).CornerRadius = UDim.new(0, 4)

        local NameLabel = Instance.new("TextLabel", ItemFrame)
        NameLabel.Size = UDim2.new(1, -10, 1, 0)
        NameLabel.Position = UDim2.new(0, 10, 0, 0)
        NameLabel.BackgroundTransparency = 1
        NameLabel.Text = "[" .. cfg.Name .. "] " .. name
        NameLabel.TextColor3 = cfg.TXT
        NameLabel.Font = Enum.Font.GothamBold
        NameLabel.TextSize = 12
        NameLabel.TextXAlignment = Enum.TextXAlignment.Left

        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 35)
    end

    function LynxLib:ClearItems()
        for _, v in pairs(ScrollFrame:GetChildren()) do
            if v:IsA("Frame") then v:Destroy() end
        end
    end

    -- Control Section (Sync Button)
    local ControlFrame = Instance.new("Frame", MainFrame)
    ControlFrame.Size = UDim2.new(1, 0, 0, 60)
    ControlFrame.Position = UDim2.new(0, 0, 1, -60)
    ControlFrame.BackgroundTransparency = 1

    local SyncBtn = Instance.new("TextButton", ControlFrame)
    SyncBtn.Size = UDim2.new(0.9, 0, 0, 35)
    SyncBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
    SyncBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    SyncBtn.Text = "SYNC BACKPACK & COLORS"
    SyncBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SyncBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", SyncBtn)

    return SyncBtn
end

----------------------------------------------------------------
-- ======= [ DATA LOGIC ] =======
----------------------------------------------------------------
local Replion, ItemUtility, DataReplion
task.spawn(function()
    local shared = ReplicatedStorage:WaitForChild("Shared", 30)
    Replion = require(ReplicatedStorage.Packages.Replion)
    ItemUtility = require(shared:WaitForChild("ItemUtility"))
    repeat 
        DataReplion = Replion.Client:GetReplion("Data")
        task.wait(1)
    until DataReplion ~= nil
end)

local function RefreshList()
    LynxLib:ClearItems()
    local data = DataReplion and DataReplion:Get("Inventory")
    local items = (data and data.Items) or {}
    
    -- Hitung Qty agar tidak terlalu panjang
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

    -- Tampilkan ke UI dengan Warna
    for name, qty in pairs(counts) do
        LynxLib:AddItem(name .. " (x" .. qty .. ")", tierMap[name])
    end
end

----------------------------------------------------------------
-- ======= [ MAIN RUN ] =======
----------------------------------------------------------------
local SyncButton = LynxLib:CreateWindow("FISCH COLOR LIST - LYNX LIGHT")
SyncButton.MouseButton1Click:Connect(function()
    RefreshList()
end)
