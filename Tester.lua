----------------------------------------------------------------
-- [ CONFIG & BRANDING ]
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

local GUI = Instance.new("ScreenGui", game.CoreGui)
GUI.Name = "PawfyDynamic_v11"

----------------------------------------------------------------
-- [ MAIN UI STRUCTURE ]
----------------------------------------------------------------
local Main = Instance.new("Frame", GUI)
Main.Size = UDim2.new(0, 380, 0, 480)
Main.Position = UDim2.new(0.5, -190, 0.5, -240)
Main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Main.BackgroundTransparency = 0.3 -- 70% Transparan
Main.BorderSizePixel = 0
Main.Active = true
Main.ClipsDescendants = false -- Agar resizer terlihat sedikit keluar jika mau

local Corner = Instance.new("UICorner", Main)
Corner.CornerRadius = UDim.new(0, 10)

local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(17, 217, 157)
Stroke.Thickness = 1.8
Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Minimize Logo P
local PLogo = Instance.new("TextButton", GUI)
PLogo.Size = UDim2.new(0, 55, 0, 55)
PLogo.Position = UDim2.new(0, 30, 0.5, -27)
PLogo.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
PLogo.BackgroundTransparency = 0.2
PLogo.Text = "P"
PLogo.TextColor3 = Color3.fromRGB(17, 217, 157)
PLogo.Font = Enum.Font.GothamBold
PLogo.TextSize = 28
PLogo.Visible = false
Instance.new("UICorner", PLogo).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", PLogo).Color = Color3.fromRGB(17, 217, 157)

-- Header (Drag Area)
local Header = Instance.new("TextButton", Main)
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundTransparency = 1
Header.Text = "  🐾 PAWFY TRADE SYSTEM"
Header.TextColor3 = Color3.fromRGB(255, 255, 255)
Header.Font = Enum.Font.GothamBold
Header.TextSize = 14
Header.TextXAlignment = Enum.TextXAlignment.Left

-- Container for content (Agar menyesuaikan saat Resize)
local Container = Instance.new("Frame", Main)
Container.Size = UDim2.new(1, -20, 1, -60)
Container.Position = UDim2.new(0, 10, 0, 50)
Container.BackgroundTransparency = 1
local Layout = Instance.new("UIListLayout", Container)
Layout.Padding = UDim.new(0, 10)

-- Trade Controls (Player, Qty, AutoAccept)
local Controls = Instance.new("Frame", Container)
Controls.Size = UDim2.new(1, 0, 0, 110)
Controls.BackgroundTransparency = 1

local TargetInput = Instance.new("TextBox", Controls)
TargetInput.Size = UDim2.new(1, 0, 0, 30)
TargetInput.PlaceholderText = "Target Player Name..."
TargetInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TargetInput.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", TargetInput)

local QtyInput = Instance.new("TextBox", Controls)
QtyInput.Size = UDim2.new(0.4, -5, 0, 30)
QtyInput.Position = UDim2.new(0, 0, 0, 35)
QtyInput.Text = "1"
QtyInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
QtyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", QtyInput)

local AutoAcc = Instance.new("TextButton", Controls)
AutoAcc.Size = UDim2.new(0.6, -5, 0, 30)
AutoAcc.Position = UDim2.new(0.4, 10, 0, 35)
AutoAcc.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
AutoAcc.Text = "Auto Accept: OFF"
AutoAcc.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", AutoAcc)

-- Scroll Area for Fish (Dynamic Height)
local Scroll = Instance.new("ScrollingFrame", Container)
Scroll.Size = UDim2.new(1, 0, 1, -160)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 3
local ScrollList = Instance.new("UIListLayout", Scroll)
ScrollList.Padding = UDim.new(0, 5)

-- Send Button
local SendBtn = Instance.new("TextButton", Container)
SendBtn.Size = UDim2.new(1, 0, 0, 40)
SendBtn.BackgroundColor3 = Color3.fromRGB(17, 217, 157)
SendBtn.Text = "SYNC & TRADE"
SendBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", SendBtn)

----------------------------------------------------------------
-- [ CORE LOGIC: RESIZE, DRAG, SCAN ]
----------------------------------------------------------------

-- Dragging Function
local function EnableDrag(frame)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true dragStart = input.Position startPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
end
EnableDrag(Main)

-- Resizing Function (Pasti Bisa!)
local ResizeHandle = Instance.new("ImageButton", Main)
ResizeHandle.Size = UDim2.new(0, 25, 0, 25)
ResizeHandle.Position = UDim2.new(1, -25, 1, -25)
ResizeHandle.BackgroundTransparency = 1
ResizeHandle.Image = "rbxassetid://15243144665"
ResizeHandle.ZIndex = 5

local resizing = false
ResizeHandle.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then resizing = true end end)
UserInputService.InputChanged:Connect(function(i)
    if resizing and i.UserInputType == Enum.UserInputType.MouseMovement then
        local mousePos = UserInputService:GetMouseLocation()
        local relativePos = mousePos - Main.AbsolutePosition
        -- Minimal Size: 300x350
        Main.Size = UDim2.new(0, math.max(300, relativePos.X), 0, math.max(350, relativePos.Y))
    end
end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then resizing = false end end)

-- Minimize Logic
Header.MouseButton1Click:Connect(function() Main.Visible = false PLogo.Visible = true end)
PLogo.MouseButton1Click:Connect(function() Main.Visible = true PLogo.Visible = false end)

-- Fisch Scanner Logic (Replion)
local function Refresh()
    for _, v in pairs(Scroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    pcall(function()
        local DataReplion = require(ReplicatedStorage.Packages.Replion).Client:GetReplion("Data")
        local ItemUtility = require(ReplicatedStorage.Shared.ItemUtility)
        local inv = DataReplion:Get("Inventory").Items
        
        local counts = {} local tiers = {}
        for _, item in pairs(inv) do
            local base = ItemUtility:GetItemData(item.Id)
            if base.Data.Type == "Fish" then
                local n = base.Data.Name
                counts[n] = (counts[n] or 0) + 1
                tiers[n] = tostring(base.Data.Tier or "1")
            end
        end

        for n, q in pairs(counts) do
            local cfg = PawfyColors[tiers[n]] or PawfyColors["1"]
            local B = Instance.new("TextButton", Scroll)
            B.Size = UDim2.new(1, -8, 0, 35)
            B.BackgroundColor3 = cfg.BG
            B.TextColor3 = cfg.TXT
            B.Text = n .. " (x" .. q .. ")"
            B.Font = Enum.Font.GothamBold
            B.LayoutOrder = -tonumber(tiers[n])
            Instance.new("UICorner", B)
        end
    end)
    Scroll.CanvasSize = UDim2.new(0,0,0, ScrollList.AbsoluteContentSize.Y)
end

SendBtn.MouseButton1Click:Connect(Refresh)
Refresh()
