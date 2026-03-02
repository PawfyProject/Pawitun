----------------------------------------------------------------
-- [ CONFIG & THEME ]
----------------------------------------------------------------
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local PawfyColors = {
    ["1"] = Color3.fromRGB(255, 255, 255), -- Common
    ["2"] = Color3.fromRGB(126, 255, 28),  -- Uncommon
    ["3"] = Color3.fromRGB(0, 162, 255),   -- Rare
    ["4"] = Color3.fromRGB(170, 0, 255),   -- Epic
    ["5"] = Color3.fromRGB(254, 203, 0),   -- Legendary
    ["6"] = Color3.fromRGB(255, 0, 85),    -- Mythic
    ["7"] = Color3.fromRGB(0, 255, 170)    -- Secret
}

----------------------------------------------------------------
-- [ UI CORE STRUCTURE ]
----------------------------------------------------------------
local GUI = Instance.new("ScreenGui", game.CoreGui)
GUI.Name = "PawfyLegacy_v17"

local Main = Instance.new("Frame", GUI)
Main.Size = UDim2.new(0, 550, 0, 380) -- Ukuran Compact mirip v4.1
Main.Position = UDim2.new(0.5, -275, 0.5, -190)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.BackgroundTransparency = 0.3 -- 70% Transparan
Main.Active = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(50, 50, 50)

-- Sidebar (Left)
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 150, 1, 0)
Sidebar.BackgroundTransparency = 1
local SideLayout = Instance.new("UIListLayout", Sidebar)
SideLayout.Padding = UDim.new(0, 5)

-- Content Area (Right)
local Container = Instance.new("Frame", Main)
Container.Size = UDim2.new(1, -160, 1, -20)
Container.Position = UDim2.new(0, 155, 0, 10)
Container.BackgroundTransparency = 1

----------------------------------------------------------------
-- [ TAB SYSTEM LOGIC ]
----------------------------------------------------------------
local Tabs = {}
local CurrentTab = nil

local function CreateTabButton(name, iconText)
    local Btn = Instance.new("TextButton", Sidebar)
    Btn.Size = UDim2.new(1, -10, 0, 40)
    Btn.BackgroundTransparency = 0.9
    Btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    Btn.Text = "  " .. iconText .. "  " .. name
    Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    Btn.Font = Enum.Font.GothamMedium
    Btn.TextSize = 13
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", Btn)
    
    local Page = Instance.new("ScrollingFrame", Container)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 2
    Instance.new("UIListLayout", Page).Padding = UDim.new(0, 10)
    
    Btn.MouseButton1Click:Connect(function()
        if CurrentTab then CurrentTab.Page.Visible = false end
        Page.Visible = true
        CurrentTab = {Page = Page, Btn = Btn}
    end)
    
    return Page
end

----------------------------------------------------------------
-- [ PAGE 1: RARITY TRADE (FITUR LENGKAP v4.1) ]
----------------------------------------------------------------
local TradePage = CreateTabButton("Rarity Trade", "📦")
TradePage.Visible = true -- Default Tab

local function CreateLabel(text, parent)
    local L = Instance.new("TextLabel", parent)
    L.Size = UDim2.new(1, 0, 0, 20)
    L.Text = text
    L.TextColor3 = Color3.fromRGB(150, 150, 150)
    L.Font = Enum.Font.Gotham
    L.TextSize = 12
    L.BackgroundTransparency = 1
    L.TextXAlignment = Enum.TextXAlignment.Left
end

-- 1. Target Player
CreateLabel("1. Target Player", TradePage)
local PlayerBox = Instance.new("TextBox", TradePage)
PlayerBox.Size = UDim2.new(1, -10, 0, 35)
PlayerBox.PlaceholderText = "Select Player Name..."
PlayerBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
PlayerBox.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", PlayerBox)

-- 2. Select Rarity (Berwarna)
CreateLabel("2. Select Fish (Backpack Sync)", TradePage)
local FishList = Instance.new("Frame", TradePage)
FishList.Size = UDim2.new(1, -10, 0, 120)
FishList.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Instance.new("UICorner", FishList)

local FishScroll = Instance.new("ScrollingFrame", FishList)
FishScroll.Size = UDim2.new(1, -10, 1, -10)
FishScroll.Position = UDim2.new(0, 5, 0, 5)
FishScroll.BackgroundTransparency = 1
FishScroll.ScrollBarThickness = 2
local FishLayout = Instance.new("UIListLayout", FishScroll)
FishLayout.Padding = UDim.new(0, 5)

-- 3. Quantity
CreateLabel("3. Quantity", TradePage)
local QtyBox = Instance.new("TextBox", TradePage)
QtyBox.Size = UDim2.new(0.3, 0, 0, 35)
QtyBox.Text = "1"
QtyBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
QtyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", QtyBox)

-- Action Buttons
local StartBtn = Instance.new("TextButton", TradePage)
StartBtn.Size = UDim2.new(1, -10, 0, 40)
StartBtn.Text = "START BULK TRADE"
StartBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
StartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StartBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", StartBtn)

----------------------------------------------------------------
-- [ PAGE 2: AUTO ACCEPT ]
----------------------------------------------------------------
local AccPage = CreateTabButton("Auto Accept", "✅")
local AccToggle = Instance.new("TextButton", AccPage)
AccToggle.Size = UDim2.new(1, -10, 0, 40)
AccToggle.Text = "AUTO ACCEPT: OFF"
AccToggle.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
AccToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", AccToggle)

----------------------------------------------------------------
-- [ SIMULASI DATA BERWARNA ]
----------------------------------------------------------------
local function AddFishUI(name, qty, tier)
    local B = Instance.new("TextButton", FishScroll)
    B.Size = UDim2.new(1, 0, 0, 30)
    B.BackgroundColor3 = PawfyColors[tostring(tier)]
    B.Text = name .. " (" .. qty .. ")"
    B.TextColor3 = (tier == "1" or tier == "2" or tier == "5" or tier == "7") and Color3.new(0,0,0) or Color3.new(1,1,1)
    B.Font = Enum.Font.GothamBold
    Instance.new("UICorner", B)
    FishScroll.CanvasSize = UDim2.new(0,0,0, FishLayout.AbsoluteContentSize.Y)
end

-- Contoh Data Muncul Otomatis
AddFishUI("Abyssal Shark", 1, 7)
AddFishUI("Kraken", 3, 6)
AddFishUI("Golden Bass", 12, 5)
AddFishUI("Mackerel", 300, 1)

----------------------------------------------------------------
-- [ DRAGGABLE LOGIC ]
----------------------------------------------------------------
local dragging, dragStart, startPos
Main.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true dragStart = i.Position startPos = Main.Position end end)
UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
    local d = i.Position - dragStart
    Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
