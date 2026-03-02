----------------------------------------------------------------
-- [ PAWFY ELITE CONFIGURATION ]
----------------------------------------------------------------
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = game:GetService("Players").LocalPlayer

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
-- [ UI CONSTRUCTION ]
----------------------------------------------------------------
local PawfyGUI = Instance.new("ScreenGui", game.CoreGui)
PawfyGUI.Name = "PawfyElite_v6"

-- Main Container
local Main = Instance.new("Frame", PawfyGUI)
Main.Name = "Main"
Main.Size = UDim2.new(0, 350, 0, 450)
Main.Position = UDim2.new(0.5, -175, 0.5, -225)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
local MainCorner = Instance.new("UICorner", Main)
MainCorner.CornerRadius = UDim.new(0, 12)

-- Resizer Button (Kanan Bawah)
local Resizer = Instance.new("ImageLabel", Main)
Resizer.Name = "Resizer"
Resizer.Size = UDim2.new(0, 20, 0, 20)
Resizer.Position = UDim2.new(1, -20, 1, -20)
Resizer.BackgroundTransparency = 1
Resizer.Image = "rbxassetid://15243144665" -- Icon Resize Ganti jika perlu
Resizer.ImageColor3 = Color3.fromRGB(100, 100, 100)
Resizer.ZIndex = 10

-- Minimize Logo (P)
local MinBtn = Instance.new("TextButton", PawfyGUI)
MinBtn.Name = "MinimizeIcon"
MinBtn.Size = UDim2.new(0, 50, 0, 50)
MinBtn.Position = UDim2.new(0, 20, 0.5, -25)
MinBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MinBtn.Text = "P"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 25
MinBtn.TextColor3 = Color3.fromRGB(17, 217, 157)
MinBtn.Visible = false
local MinCorner = Instance.new("UICorner", MinBtn)
MinCorner.CornerRadius = UDim.new(1, 0)
local MinStroke = Instance.new("UIStroke", MinBtn)
MinStroke.Color = Color3.fromRGB(17, 217, 157)
MinStroke.Thickness = 2

-- Content Scaling (Gunakan UIListLayout untuk adaptasi ukuran)
local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, 0, 1, 0)
Content.BackgroundTransparency = 1

local Padding = Instance.new("UIPadding", Content)
Padding.PaddingTop = UDim.new(0, 10)
Padding.PaddingBottom = UDim.new(0, 10)
Padding.PaddingLeft = UDim.new(0, 10)
Padding.PaddingRight = UDim.new(0, 10)

local Title = Instance.new("TextLabel", Content)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "PAWFY TRADE SYSTEM"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.TextSize = 16

local Scroll = Instance.new("ScrollingFrame", Content)
Scroll.Size = UDim2.new(1, 0, 1, -80)
Scroll.Position = UDim2.new(0, 0, 0, 40)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 2
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)

local ListLayout = Instance.new("UIListLayout", Scroll)
ListLayout.Padding = UDim.new(0, 5)

----------------------------------------------------------------
-- [ ADVANCED LOGIC: DRAG, RESIZE, MINIMIZE ]
----------------------------------------------------------------

-- DRAGGING
local function makeDraggable(obj)
    local dragging, dragInput, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true dragStart = input.Position startPos = obj.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    obj.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
end
makeDraggable(Main)

-- RESIZING
local resizing = false
Resizer.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then resizing = true end
end)
UserInputService.InputChanged:Connect(function(input)
    if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mousePos = UserInputService:GetMouseLocation()
        local relativePos = mousePos - Main.AbsolutePosition
        -- Minimal Size Clamp
        local newX = math.max(250, relativePos.X)
        local newY = math.max(300, relativePos.Y)
        Main.Size = UDim2.new(0, newX, 0, newY)
    end
end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then resizing = false end end)

-- MINIMIZE
Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Main:TweenSize(UDim2.new(0,0,0,0), "Out", "Quint", 0.5, true)
        task.wait(0.5)
        Main.Visible = false
        MinBtn.Visible = true
    end
end)
MinBtn.MouseButton1Click:Connect(function()
    MinBtn.Visible = false
    Main.Visible = true
    Main:TweenSize(UDim2.new(0, 350, 0, 450), "Out", "Back", 0.5, true)
end)

----------------------------------------------------------------
-- [ PAWFY SYSTEM CORE ]
----------------------------------------------------------------
local function AddFish(name, qty, tier)
    local cfg = PawfyColors[tostring(tier)] or PawfyColors["1"]
    local Box = Instance.new("Frame", Scroll)
    Box.Size = UDim2.new(1, -5, 0, 35)
    Box.BackgroundColor3 = cfg.BG
    Box.LayoutOrder = -tonumber(tier)
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 6)
    
    local Label = Instance.new("TextLabel", Box)
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name .. " (" .. qty .. ")"
    Label.TextColor3 = cfg.TXT
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 13
    
    Scroll.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)
end

-- Loader Logika
local function Refresh()
    for _, v in pairs(Scroll:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
    -- Simulasi Data (Ganti dengan DataReplion Anda)
    AddFish("Abyssal Shark", 2, 7)
    AddFish("The Kraken", 5, 6)
    AddFish("Golden Bass", 12, 5)
    AddFish("Mackerel", 300, 1)
end

Refresh()
