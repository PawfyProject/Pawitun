----------------------------------------------------------------
-- [ 1. CONFIG & RESPONSIVE SETTINGS ]
----------------------------------------------------------------
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local MyLogoID = "rbxassetid://15243144665" -- Logo default jika URL gagal

-- Color Mapping Kasta Ikan
local RarityMap = {
    ["1"] = {Name = "COMMON", Color = Color3.fromRGB(255, 255, 255), Text = Color3.new(0,0,0)},
    ["2"] = {Name = "UNCOMMON", Color = Color3.fromRGB(126, 255, 28), Text = Color3.new(0,0,0)},
    ["3"] = {Name = "RARE", Color = Color3.fromRGB(0, 162, 255), Text = Color3.new(1,1,1)},
    ["4"] = {Name = "EPIC", Color = Color3.fromRGB(170, 0, 255), Text = Color3.new(1,1,1)},
    ["5"] = {Name = "LEGENDARY", Color = Color3.fromRGB(254, 203, 0), Text = Color3.new(0,0,0)},
    ["6"] = {Name = "MYTHIC", Color = Color3.fromRGB(255, 0, 85), Text = Color3.new(1,1,1)},
    ["7"] = {Name = "SECRET", Color = Color3.fromRGB(0, 255, 170), Text = Color3.new(0,0,0)}
}

----------------------------------------------------------------
-- [ 2. UI CONSTRUCTION (COMPACT & RESPONSIVE) ]
----------------------------------------------------------------
local GUI = Instance.new("ScreenGui", game.CoreGui)
GUI.Name = "PawfyCompact_v4_4"

-- Main Window (Menggunakan Scale agar tidak terlalu besar)
local Main = Instance.new("Frame", GUI)
Main.Size = UDim2.new(0.35, 0, 0.55, 0) -- 35% lebar layar, 55% tinggi
Main.Position = UDim2.new(0.32, 0, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BackgroundTransparency = 0.3 -- 70% Transparansi
Main.Active = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(17, 217, 157)
Stroke.Thickness = 1.2

-- Minimize Logo (P)
local PLogo = Instance.new("TextButton", GUI)
PLogo.Size = UDim2.new(0, 45, 0, 45)
PLogo.Position = UDim2.new(0, 20, 0.5, -22)
PLogo.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
PLogo.BackgroundTransparency = 0.3
PLogo.Text = "P"
PLogo.TextColor3 = Color3.fromRGB(17, 217, 157)
PLogo.Font = Enum.Font.GothamBold
PLogo.TextSize = 22
PLogo.Visible = false
Instance.new("UICorner", PLogo).CornerRadius = UDim.new(1, 0)

-- Header ringkas dengan tombol Close/Minimize
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0.1, 0)
Header.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(0.8, 0, 1, 0)
Title.Position = UDim2.new(0.05, 0, 0, 0)
Title.Text = "🐾 PAWFY ULTIMATE v4.4"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

local MinBtn = Instance.new("TextButton", Header)
MinBtn.Size = UDim2.new(0.1, 0, 0.8, 0)
MinBtn.Position = UDim2.new(0.88, 0, 0.1, 0)
MinBtn.Text = "X"
MinBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
MinBtn.BackgroundTransparency = 1
MinBtn.Font = Enum.Font.GothamBold

-- Sidebar (Left) - Responsive
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0.28, 0, 0.88, 0)
Sidebar.Position = UDim2.new(0, 0, 0.1, 0)
Sidebar.BackgroundTransparency = 1
local SideLayout = Instance.new("UIListLayout", Sidebar)
SideLayout.Padding = UDim.new(0, 4)
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Content Area (Right)
local Container = Instance.new("Frame", Main)
Container.Size = UDim2.new(0.68, 0, 0.85, 0)
Container.Position = UDim2.new(0.3, 0, 0.12, 0)
Container.BackgroundTransparency = 1

----------------------------------------------------------------
-- [ 3. TAB & CONTENT SYSTEM ]
----------------------------------------------------------------
local CurrentPage = nil

local function CreateTab(name, icon)
    local Btn = Instance.new("TextButton", Sidebar)
    Btn.Size = UDim2.new(0.9, 0, 0, 32)
    Btn.BackgroundTransparency = 0.9
    Btn.Text = name
    Btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    Btn.Font = Enum.Font.GothamMedium
    Btn.TextSize = 10
    Instance.new("UICorner", Btn)
    
    local Page = Instance.new("ScrollingFrame", Container)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 1
    Instance.new("UIListLayout", Page).Padding = UDim.new(0, 8)
    
    Btn.MouseButton1Click:Connect(function()
        if CurrentPage then CurrentPage.Visible = false end
        Page.Visible = true
        CurrentPage = Page
    end)
    return Page
end

-- PAGE: FISH TRADE
local FishPage = CreateTab("FISH", "🐟")
FishPage.Visible = true
CurrentPage = FishPage

local function AddInput(placeholder, parent)
    local I = Instance.new("TextBox", parent)
    I.Size = UDim2.new(1, -10, 0, 30)
    I.PlaceholderText = placeholder
    I.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    I.TextColor3 = Color3.white
    I.TextSize = 11
    Instance.new("UICorner", I)
    return I
end

local TargetPlayer = AddInput("Target Player...", FishPage)

-- Berwarna List Ikan (Kompak)
local FishScroll = Instance.new("ScrollingFrame", FishPage)
FishScroll.Size = UDim2.new(1, -10, 0, 120)
FishScroll.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
FishScroll.BorderSizePixel = 0
Instance.new("UIListLayout", FishScroll).Padding = UDim.new(0, 2)
Instance.new("UICorner", FishScroll)

-- Simulasi Tombol Ikan Berwarna
local function AddFishItem(name, tier)
    local cfg = RarityMap[tostring(tier)]
    local b = Instance.new("TextButton", FishScroll)
    b.Size = UDim2.new(1, 0, 0, 24)
    b.BackgroundColor3 = cfg.Color
    b.Text = " " .. name
    b.TextColor3 = cfg.Text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 10
    b.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", b)
end

-- Tombol Aksi
local StartBtn = Instance.new("TextButton", FishPage)
StartBtn.Size = UDim2.new(1, -10, 0, 35)
StartBtn.Text = "START TRADE (OFF)"
StartBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
StartBtn.TextColor3 = Color3.white
StartBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", StartBtn)

----------------------------------------------------------------
-- [ 4. DRAG, MINIMIZE & INTERACTION ]
----------------------------------------------------------------
-- Draggable (Seluruh Window bisa digeser)
local dragging, dragStart, startPos
Main.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true dragStart = i.Position startPos = Main.Position end end)
UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
    local d = i.Position - dragStart
    Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

-- Minimize Logic
MinBtn.MouseButton1Click:Connect(function() Main.Visible = false PLogo.Visible = true end)
PLogo.MouseButton1Click:Connect(function() Main.Visible = true PLogo.Visible = false end)

-- Contoh data agar terlihat di Studio
AddFishItem("Abyssal Shark", 7)
AddFishItem("Kraken", 6)
AddFishItem("Mackerel", 1)

print("🐾 Pawfy v4.4 Loaded! Gunakan 'X' untuk minimize.")
