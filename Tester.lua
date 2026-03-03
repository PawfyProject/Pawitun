----------------------------------------------------------------
-- [ 1. CONFIGURATION & THEME ]
----------------------------------------------------------------
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local TierSettings = {
    ["1"] = {Name = "COMMON",    BG = Color3.fromRGB(255, 255, 255), TXT = Color3.fromRGB(0, 0, 0)},
    ["2"] = {Name = "UNCOMMON",  BG = Color3.fromRGB(126, 255, 28),  TXT = Color3.fromRGB(0, 0, 0)},
    ["3"] = {Name = "RARE",      BG = Color3.fromRGB(0, 162, 255),   TXT = Color3.fromRGB(255, 255, 255)},
    ["4"] = {Name = "EPIC",      BG = Color3.fromRGB(170, 0, 255),   TXT = Color3.fromRGB(255, 255, 255)},
    ["5"] = {Name = "LEGENDARY", BG = Color3.fromRGB(255, 187, 0),   TXT = Color3.fromRGB(0, 0, 0)},
    ["6"] = {Name = "MYTHIC",    BG = Color3.fromRGB(255, 0, 0),     TXT = Color3.fromRGB(255, 255, 255)},
    ["7"] = {Name = "SECRET",    BG = Color3.fromRGB(17, 217, 157),  TXT = Color3.fromRGB(0, 0, 0)}
}

----------------------------------------------------------------
-- [ 2. UI ENGINE (COMPACT & RESPONSIVE) ]
----------------------------------------------------------------
local GUI = Instance.new("ScreenGui", game.CoreGui)
GUI.Name = "Pawfy_v4_4_Fixed"

local Main = Instance.new("Frame", GUI)
Main.Size = UDim2.new(0, 360, 0, 420) -- Ukuran lebih ramping
Main.Position = UDim2.new(0.5, -180, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.BackgroundTransparency = 0.3 -- 70% Transparansi
Main.Active = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(17, 217, 157)
Stroke.Thickness = 1.5

-- Header (Drag Area)
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "🐾 PAWFY TRADE v4.4"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

local MinBtn = Instance.new("TextButton", Header)
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -40, 0.5, -15)
MinBtn.Text = "—"
MinBtn.TextColor3 = Color3.white
MinBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(1, 0)

-- Content Area
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -20, 1, -110)
Scroll.Position = UDim2.new(0, 10, 0, 50)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 2
local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0, 5)

-- Footer Controls
local SyncBtn = Instance.new("TextButton", Main)
SyncBtn.Size = UDim2.new(1, -20, 0, 40)
SyncBtn.Position = UDim2.new(0, 10, 1, -50)
SyncBtn.BackgroundColor3 = Color3.fromRGB(17, 217, 157)
SyncBtn.Text = "SYNC BACKPACK & COLORS"
SyncBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
SyncBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", SyncBtn)

----------------------------------------------------------------
-- [ 3. LOGIC & FUNCTIONALITY ]
----------------------------------------------------------------
local Replion, ItemUtility, DataReplion

-- Safe Data Loader
task.spawn(function()
    pcall(function()
        local shared = ReplicatedStorage:WaitForChild("Shared", 10)
        local packages = ReplicatedStorage:WaitForChild("Packages", 10)
        if shared and packages then
            Replion = require(packages.Replion)
            ItemUtility = require(shared.ItemUtility)
            DataReplion = Replion.Client:GetReplion("Data")
        end
    end)
end)

local function AddItem(name, tier)
    local cfg = TierSettings[tostring(tier)] or TierSettings["1"]
    local f = Instance.new("Frame", Scroll)
    f.Size = UDim2.new(1, -5, 0, 30)
    f.BackgroundColor3 = cfg.BG
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 5)
    
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, -10, 1, 0)
    l.Position = UDim2.new(0, 10, 0, 0)
    l.Text = "[" .. cfg.Name .. "] " .. name
    l.TextColor3 = cfg.TXT
    l.Font = Enum.Font.GothamBold
    l.TextSize = 11
    l.BackgroundTransparency = 1
    l.TextXAlignment = Enum.TextXAlignment.Left
    
    Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y)
end

SyncBtn.MouseButton1Click:Connect(function()
    for _, v in pairs(Scroll:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
    
    if not DataReplion then
        -- Simulasi data jika di Studio/Baseplate
        AddItem("Sample Shark (Simulated)", 7)
        AddItem("Sample Whale (Simulated)", 6)
        return
    end

    local data = DataReplion:Get("Inventory")
    local items = (data and data.Items) or {}
    local counts = {}
    local tiers = {}

    for _, item in pairs(items) do
        local base = ItemUtility:GetItemData(item.Id)
        if base and base.Data and base.Data.Type == "Fish" then
            local n = base.Data.Name
            counts[n] = (counts[n] or 0) + 1
            tiers[n] = tostring(base.Data.Tier or "1")
        end
    end

    for name, qty in pairs(counts) do
        AddItem(name .. " (x" .. qty .. ")", tiers[name])
    end
end)

-- Draggable Script
local dragging, dragStart, startPos
Header.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true dragStart = i.Position startPos = Main.Position end end)
UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
    local d = i.Position - dragStart
    Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

-- Minimize
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    Scroll.Visible = not minimized
    SyncBtn.Visible = not minimized
    Main:TweenSize(minimized and UDim2.new(0, 360, 0, 40) or UDim2.new(0, 360, 0, 420), "Out", "Quart", 0.3, true)
end)
