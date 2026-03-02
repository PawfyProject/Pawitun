----------------------------------------------------------------
-- [ CORE CONFIGURATION ]
----------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

local PawfyColors = {
    ["1"] = {BG = Color3.fromRGB(255, 255, 255), TXT = Color3.fromRGB(0, 0, 0)},     -- COMMON
    ["2"] = {BG = Color3.fromRGB(126, 255, 28),  TXT = Color3.fromRGB(0, 0, 0)},     -- UNCOMMON
    ["3"] = {BG = Color3.fromRGB(0, 68, 255),    TXT = Color3.fromRGB(0, 0, 0)},     -- RARE
    ["4"] = {BG = Color3.fromRGB(74, 0, 153),    TXT = Color3.fromRGB(255, 255, 255)}, -- EPIC
    ["5"] = {BG = Color3.fromRGB(255, 187, 0),   TXT = Color3.fromRGB(0, 0, 0)},     -- LEGENDARY
    ["6"] = {BG = Color3.fromRGB(255, 0, 0),     TXT = Color3.fromRGB(255, 255, 255)}, -- MYTHIC
    ["7"] = {BG = Color3.fromRGB(17, 217, 157),  TXT = Color3.fromRGB(0, 0, 0)}      -- SECRET
}

-- Stats & Toggles
local Stats = {Success = 0, Failed = 0}
local Toggles = {Trading = false, AutoAccept = false}
local SelectedFish = {UUID = nil, Name = "None"}

----------------------------------------------------------------
-- [ DYNAMIC UI LIBRARY ]
----------------------------------------------------------------
local GUI = Instance.new("ScreenGui", game.CoreGui)
GUI.Name = "PawfyFluent_v15"

-- Main Window (Draggable)
local Main = Instance.new("Frame", GUI)
Main.Size = UDim2.new(0, 450, 0, 550)
Main.Position = UDim2.new(0.5, -225, 0.5, -275)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BackgroundTransparency = 0.3 -- 70% Transparan
Main.BorderSizePixel = 0
Main.Active = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

-- Header Area (Drag Trigger)
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "🐾 PAWFY TRADE SYSTEM v15.0"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Content Container
local Container = Instance.new("ScrollingFrame", Main)
Container.Size = UDim2.new(1, -20, 1, -60)
Container.Position = UDim2.new(0, 10, 0, 50)
Container.BackgroundTransparency = 1
Container.ScrollBarThickness = 2
local Layout = Instance.new("UIListLayout", Container)
Layout.Padding = UDim.new(0, 10)

----------------------------------------------------------------
-- [ COMPONENT BUILDER ]
----------------------------------------------------------------
local function CreateSection(text)
    local Label = Instance.new("TextLabel", Container)
    Label.Size = UDim2.new(1, 0, 0, 25)
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(17, 217, 157)
    Label.Font = Enum.Font.GothamBold
    Label.BackgroundTransparency = 1
    Label.TextSize = 13
end

local function CreateStatusBox()
    local Box = Instance.new("Frame", Container)
    Box.Size = UDim2.new(1, 0, 0, 45)
    Box.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Instance.new("UICorner", Box)
    
    local StatText = Instance.new("TextLabel", Box)
    StatText.Size = UDim2.new(1, 0, 1, 0)
    StatText.Text = "Success: 0 | Failed: 0\nStatus: IDLE"
    StatText.TextColor3 = Color3.fromRGB(255, 255, 255)
    StatText.Font = Enum.Font.Gotham
    StatText.BackgroundTransparency = 1
    StatText.TextSize = 12
    return StatText
end

-- 1. Fish Trade Section
CreateSection("--- FISH TRADE ---")
local StatusDisp = CreateStatusBox()

-- Select Player Input
local PlayerInp = Instance.new("TextBox", Container)
PlayerInp.Size = UDim2.new(1, 0, 0, 35)
PlayerInp.PlaceholderText = "1. Target Player Name..."
PlayerInp.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
PlayerInp.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", PlayerInp)

-- Fish Inventory List
local FishScroll = Instance.new("ScrollingFrame", Container)
FishScroll.Size = UDim2.new(1, 0, 0, 150)
FishScroll.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
FishScroll.BorderSizePixel = 0
Instance.new("UIListLayout", FishScroll).Padding = UDim.new(0, 5)
Instance.new("UICorner", FishScroll)

-- Start/Stop Button (Toggle)
local StartBtn = Instance.new("TextButton", Container)
StartBtn.Size = UDim2.new(1, 0, 0, 40)
StartBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
StartBtn.Text = "START TRADE (OFF)"
StartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StartBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", StartBtn)

-- 2. Accept Trade Section
CreateSection("--- ACCEPT TRADE ---")
local AutoAccBtn = Instance.new("TextButton", Container)
AutoAccBtn.Size = UDim2.new(1, 0, 0, 40)
AutoAccBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
AutoAccBtn.Text = "AUTO ACCEPT TRADE (OFF)"
AutoAccBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoAccBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", AutoAccBtn)

----------------------------------------------------------------
-- [ LOGIC: DRAGGING & FUNCTIONALITY ]
----------------------------------------------------------------
-- Dragging Logic (Manual Implementation)
local dragging, dragStart, startPos
Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true dragStart = input.Position startPos = Main.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

-- Sync Backpack Logic
local function RefreshBackpack()
    for _, v in pairs(FishScroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    pcall(function()
        local Data = require(ReplicatedStorage.Packages.Replion).Client:GetReplion("Data")
        local ItemUtil = require(ReplicatedStorage.Shared.ItemUtility)
        local inv = Data:Get("Inventory").Items
        
        local items = {}
        for _, item in pairs(inv) do
            local base = ItemUtil:GetItemData(item.Id)
            if base.Data.Type == "Fish" then
                local n = base.Data.Name
                items[n] = (items[n] or 0) + 1
                -- Tambahkan Button Ikan dengan Warna
                local B = Instance.new("TextButton", FishScroll)
                B.Size = UDim2.new(1, -5, 0, 30)
                B.BackgroundColor3 = PawfyColors[tostring(base.Data.Tier)].BG
                B.Text = n .. " (" .. items[n] .. ")"
                B.TextColor3 = PawfyColors[tostring(base.Data.Tier)].TXT
                Instance.new("UICorner", B)
                B.MouseButton1Click:Connect(function() 
                    SelectedFish.UUID = item.UUID
                    StatusDisp.Text = "Selected: " .. n
                end)
            end
        end
    end)
    FishScroll.CanvasSize = UDim2.new(0, 0, 0, FishScroll.UIListLayout.AbsoluteContentSize.Y)
end

-- Toggle Actions
StartBtn.MouseButton1Click:Connect(function()
    Toggles.Trading = not Toggles.Trading
    StartBtn.Text = "START TRADE (" .. (Toggles.Trading and "ON" or "OFF") .. ")"
    StartBtn.BackgroundColor3 = Toggles.Trading and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
end)

AutoAccBtn.MouseButton1Click:Connect(function()
    Toggles.AutoAccept = not Toggles.AutoAccept
    AutoAccBtn.Text = "AUTO ACCEPT (" .. (Toggles.AutoAccept and "ON" or "OFF") .. ")"
    AutoAccBtn.BackgroundColor3 = Toggles.AutoAccept and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
end)

RefreshBackpack()
