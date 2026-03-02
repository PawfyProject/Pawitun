----------------------------------------------------------------
-- ======= [ PAWFY ELITE CONFIG & SERVICES ] =======
----------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

local PawfyColors = {
    ["1"] = {BG = Color3.fromRGB(255, 255, 255), TXT = Color3.fromRGB(0, 0, 0)},
    ["2"] = {BG = Color3.fromRGB(126, 255, 28),  TXT = Color3.fromRGB(0, 0, 0)},
    ["3"] = {BG = Color3.fromRGB(0, 68, 255),    TXT = Color3.fromRGB(0, 0, 0)},
    ["4"] = {BG = Color3.fromRGB(74, 0, 153),    TXT = Color3.fromRGB(255, 255, 255)},
    ["5"] = {BG = Color3.fromRGB(255, 187, 0),   TXT = Color3.fromRGB(0, 0, 0)},
    ["6"] = {BG = Color3.fromRGB(255, 0, 0),     TXT = Color3.fromRGB(255, 255, 255)},
    ["7"] = {BG = Color3.fromRGB(17, 217, 157),  TXT = Color3.fromRGB(0, 0, 0)}
}

local SelectedPlayer = ""
local SelectedFishUUID = nil
local SelectedFishName = "None"
local AutoAccept = false

----------------------------------------------------------------
-- ======= [ PAWFY UI ENGINE ] =======
----------------------------------------------------------------
local GUI = Instance.new("ScreenGui", game.CoreGui)
GUI.Name = "PawfyTradeSystem_v9"

-- Main Window
local Main = Instance.new("Frame", GUI)
Main.Size = UDim2.new(0, 350, 0, 500)
Main.Position = UDim2.new(0.5, -175, 0.5, -250)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

-- Minimize Icon (P)
local PLogo = Instance.new("TextButton", GUI)
PLogo.Size = UDim2.new(0, 50, 0, 50)
PLogo.Position = UDim2.new(0, 20, 0.5, -25)
PLogo.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
PLogo.Text = "P"
PLogo.TextColor3 = Color3.fromRGB(17, 217, 157)
PLogo.Font = Enum.Font.GothamBold
PLogo.TextSize = 24
PLogo.Visible = false
Instance.new("UICorner", PLogo).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", PLogo).Color = Color3.fromRGB(17, 217, 157)

-- Content Adaptive
local Header = Instance.new("TextButton", Main)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundTransparency = 1
Header.Text = "  🐾 PAWFY TRADE SYSTEM"
Header.TextColor3 = Color3.fromRGB(255, 255, 255)
Header.Font = Enum.Font.GothamBold
Header.TextSize = 14
Header.TextXAlignment = Enum.TextXAlignment.Left

-- Controls Panel
local Controls = Instance.new("Frame", Main)
Controls.Size = UDim2.new(1, -20, 0, 110)
Controls.Position = UDim2.new(0, 10, 0, 45)
Controls.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
Instance.new("UICorner", Controls)

local PlayerInput = Instance.new("TextBox", Controls)
PlayerInput.Size = UDim2.new(1, -20, 0, 25)
PlayerInput.Position = UDim2.new(0, 10, 0, 10)
PlayerInput.PlaceholderText = "Target Player Name..."
PlayerInput.Text = ""
PlayerInput.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
PlayerInput.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", PlayerInput)

local QtyInput = Instance.new("TextBox", Controls)
QtyInput.Size = UDim2.new(0.4, -10, 0, 25)
QtyInput.Position = UDim2.new(0, 10, 0, 40)
QtyInput.PlaceholderText = "Qty"
QtyInput.Text = "1"
QtyInput.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
QtyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", QtyInput)

local AutoAcceptBtn = Instance.new("TextButton", Controls)
AutoAcceptBtn.Size = UDim2.new(0.6, -15, 0, 25)
AutoAcceptBtn.Position = UDim2.new(0.4, 5, 0, 40)
AutoAcceptBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
AutoAcceptBtn.Text = "Auto Accept: OFF"
AutoAcceptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", AutoAcceptBtn)

local StatusLabel = Instance.new("TextLabel", Controls)
StatusLabel.Size = UDim2.new(1, -20, 0, 20)
StatusLabel.Position = UDim2.new(0, 10, 0, 75)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Selected: None"
StatusLabel.TextColor3 = Color3.fromRGB(17, 217, 157)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 11

-- Scrolling Area
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -20, 1, -210)
Scroll.Position = UDim2.new(0, 10, 0, 160)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.ScrollBarThickness = 2
local List = Instance.new("UIListLayout", Scroll)
List.Padding = UDim.new(0, 5)

-- Main Trade Button
local TradeBtn = Instance.new("TextButton", Main)
TradeBtn.Size = UDim2.new(1, -20, 0, 35)
TradeBtn.Position = UDim2.new(0, 10, 1, -45)
TradeBtn.BackgroundColor3 = Color3.fromRGB(17, 217, 157)
TradeBtn.Text = "SEND TRADE"
TradeBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
TradeBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", TradeBtn)

-- Resizer
local Resizer = Instance.new("ImageButton", Main)
Resizer.Size = UDim2.new(0, 15, 0, 15)
Resizer.Position = UDim2.new(1, -15, 1, -15)
Resizer.BackgroundTransparency = 1
Resizer.Image = "rbxassetid://15243144665"

----------------------------------------------------------------
-- ======= [ CORE LOGIC: DATA & TRADING ] =======
----------------------------------------------------------------
local Replion, ItemUtility, DataReplion
task.spawn(function()
    pcall(function()
        Replion = require(ReplicatedStorage.Packages.Replion)
        ItemUtility = require(ReplicatedStorage.Shared.ItemUtility)
        repeat DataReplion = Replion.Client:GetReplion("Data") task.wait(1) until DataReplion ~= nil
    end)
end)

local function RefreshList()
    for _, v in pairs(Scroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    local inv = DataReplion and DataReplion:Get("Inventory")
    local items = (inv and inv.Items) or {}
    local counts = {} local tierMap = {} local uuidMap = {}

    for _, item in pairs(items) do
        local base = ItemUtility:GetItemData(item.Id)
        if base and base.Data and base.Data.Type == "Fish" then
            local n = base.Data.Name
            counts[n] = (counts[n] or 0) + 1
            tierMap[n] = tostring(base.Data.Tier or "1")
            uuidMap[n] = item.UUID
        end
    end

    for name, qty in pairs(counts) do
        local tier = tierMap[name]
        local cfg = PawfyColors[tier] or PawfyColors["1"]
        local Bar = Instance.new("TextButton", Scroll)
        Bar.Size = UDim2.new(1, -5, 0, 32)
        Bar.BackgroundColor3 = cfg.BG
        Bar.Text = name .. " (x" .. qty .. ")"
        Bar.TextColor3 = cfg.TXT
        Bar.Font = Enum.Font.GothamBold
        Bar.LayoutOrder = -tonumber(tier)
        Instance.new("UICorner", Bar)

        Bar.MouseButton1Click:Connect(function()
            SelectedFishUUID = uuidMap[name]
            SelectedFishName = name
            StatusLabel.Text = "Selected: " .. name
        end)
    end
    Scroll.CanvasSize = UDim2.new(0, 0, 0, List.AbsoluteContentSize.Y)
end

-- Function Trade Execution
TradeBtn.MouseButton1Click:Connect(function()
    local target = PlayerInput.Text
    local qty = tonumber(QtyInput.Text) or 1
    if SelectedFishUUID and target ~= "" then
        print("Pawfy System: Trading " .. qty .. "x " .. SelectedFishName .. " to " .. target)
        -- Masukkan Remote Event Trade Game Fisch Anda di sini
        -- ReplicatedStorage.Events.Trade:FireServer(target, SelectedFishUUID, qty)
    else
        RefreshList() -- Jika belum pilih ikan, tombol ini jadi tombol Refresh
    end
end)

-- Auto Accept Loop
task.spawn(function()
    while task.wait(1) do
        if AutoAccept then
            local gui = LocalPlayer.PlayerGui:FindFirstChild("TradeConfirm")
            if gui and gui.Visible then
                -- ReplicatedStorage.Events.TradeAccept:FireServer()
            end
        end
    end
end)

-- UI Interactions (Minimize & Resize)
Header.MouseButton1Click:Connect(function() Main.Visible = false PLogo.Visible = true end)
PLogo.MouseButton1Click:Connect(function() Main.Visible = true PLogo.Visible = false end)
AutoAcceptBtn.MouseButton1Click:Connect(function()
    AutoAccept = not AutoAccept
    AutoAcceptBtn.Text = "Auto Accept: " .. (AutoAccept and "ON" or "OFF")
    AutoAcceptBtn.BackgroundColor3 = AutoAccept and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
end)

-- Resizing Logic
local resizing = false
Resizer.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then resizing = true end end)
UserInputService.InputChanged:Connect(function(i)
    if resizing and i.UserInputType == Enum.UserInputType.MouseMovement then
        local m = UserInputService:GetMouseLocation()
        local rel = m - Main.AbsolutePosition
        Main.Size = UDim2.new(0, math.max(280, rel.X), 0, math.max(350, rel.Y))
    end
end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then resizing = false end end)

RefreshList()
