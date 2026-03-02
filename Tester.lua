----------------------------------------------------------------
-- [ CORE CONFIGURATION ]
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

-- Stats & States
local SuccessCount = 0
local FailedCount = 0
local IsTrading = false
local AutoAccept = false
local SelectedFishUUID = nil

----------------------------------------------------------------
-- [ UI CONSTRUCTION ]
----------------------------------------------------------------
local GUI = Instance.new("ScreenGui", game.CoreGui)
GUI.Name = "PawfyMaster_v13"

local Main = Instance.new("Frame", GUI)
Main.Size = UDim2.new(0, 420, 0, 550)
Main.Position = UDim2.new(0.5, -210, 0.5, -275)
Main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Main.BackgroundTransparency = 0.3 -- 70% Transparent
Main.BorderSizePixel = 0
Main.Active = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = Color3.fromRGB(17, 217, 157)
MainStroke.Thickness = 1.5

-- Minimize Button (P)
local PLogo = Instance.new("TextButton", GUI)
PLogo.Size = UDim2.new(0, 50, 0, 50)
PLogo.Position = UDim2.new(0, 20, 0.5, -25)
PLogo.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
PLogo.BackgroundTransparency = 0.3
PLogo.Text = "P"
PLogo.TextColor3 = Color3.fromRGB(17, 217, 157)
PLogo.Font = Enum.Font.GothamBold
PLogo.TextSize = 25
PLogo.Visible = false
Instance.new("UICorner", PLogo).CornerRadius = UDim.new(1, 0)

-- Content Wrapper
local Content = Instance.new("ScrollingFrame", Main)
Content.Size = UDim2.new(1, -20, 1, -20)
Content.Position = UDim2.new(0, 10, 0, 10)
Content.BackgroundTransparency = 1
Content.CanvasSize = UDim2.new(0, 0, 0, 650)
Content.ScrollBarThickness = 2
local List = Instance.new("UIListLayout", Content)
List.Padding = UDim.new(0, 12)

----------------------------------------------------------------
-- [ SECTION: FISH TRADE ]
----------------------------------------------------------------
local function CreateSection(title, parent)
    local T = Instance.new("TextLabel", parent)
    T.Size = UDim2.new(1, 0, 0, 25)
    T.Text = "--- " .. title .. " ---"
    T.TextColor3 = Color3.fromRGB(17, 217, 157)
    T.Font = Enum.Font.GothamBold
    T.BackgroundTransparency = 1
    T.TextSize = 14
end

CreateSection("FISH TRADE", Content)

-- Status Trade Label
local StatLabel = Instance.new("TextLabel", Content)
StatLabel.Size = UDim2.new(1, 0, 0, 40)
StatLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
StatLabel.Text = "Success Trade: 0 | Failed Trade: 0\nStatus: IDLE"
StatLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatLabel.Font = Enum.Font.Gotham
StatLabel.TextSize = 12
Instance.new("UICorner", StatLabel)

-- 1. Select Player
local PlayerInput = Instance.new("TextBox", Content)
PlayerInput.Size = UDim2.new(1, 0, 0, 35)
PlayerInput.PlaceholderText = "1. Target Player Name..."
PlayerInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
PlayerInput.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", PlayerInput)

local RefreshPlayerBtn = Instance.new("TextButton", Content)
RefreshPlayerBtn.Size = UDim2.new(1, 0, 0, 30)
RefreshPlayerBtn.Text = "Refresh Player List"
RefreshPlayerBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
RefreshPlayerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", RefreshPlayerBtn)

-- 2. Select Fish Area
local FishListFrame = Instance.new("ScrollingFrame", Content)
FishListFrame.Size = UDim2.new(1, 0, 0, 150)
FishListFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
FishListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
FishListFrame.ScrollBarThickness = 2
Instance.new("UIListLayout", FishListFrame).Padding = UDim.new(0, 4)
Instance.new("UICorner", FishListFrame)

local RefreshBackpackBtn = Instance.new("TextButton", Content)
RefreshBackpackBtn.Size = UDim2.new(1, 0, 0, 30)
RefreshBackpackBtn.Text = "Refresh Backpack"
RefreshBackpackBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
RefreshBackpackBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", RefreshBackpackBtn)

-- 3. Quantity
local QtyInput = Instance.new("TextBox", Content)
QtyInput.Size = UDim2.new(1, 0, 0, 35)
QtyInput.PlaceholderText = "3. Quantity"
QtyInput.Text = "1"
QtyInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
QtyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", QtyInput)

-- 4. Start Trade Toggle
local StartTradeBtn = Instance.new("TextButton", Content)
StartTradeBtn.Size = UDim2.new(1, 0, 0, 40)
StartTradeBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
StartTradeBtn.Text = "START TRADE: OFF"
StartTradeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StartTradeBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", StartTradeBtn)

----------------------------------------------------------------
-- [ SECTION: ACCEPT TRADE ]
----------------------------------------------------------------
CreateSection("ACCEPT TRADE", Content)

local AutoAccBtn = Instance.new("TextButton", Content)
AutoAccBtn.Size = UDim2.new(1, 0, 0, 40)
AutoAccBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
AutoAccBtn.Text = "AUTO ACCEPT TRADE: OFF"
AutoAccBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoAccBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", AutoAccBtn)

----------------------------------------------------------------
-- [ CORE LOGIC: TRADING, RESIZE, DRAG ]
----------------------------------------------------------------

-- Resize & Drag System
local function SetupInteractive(obj)
    local Resizer = Instance.new("ImageButton", obj)
    Resizer.Size = UDim2.new(0, 20, 0, 20)
    Resizer.Position = UDim2.new(1, -20, 1, -20)
    Resizer.Image = "rbxassetid://15243144665"
    Resizer.BackgroundTransparency = 1
    
    local resizing = false
    Resizer.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then resizing = true end end)
    UserInputService.InputChanged:Connect(function(i)
        if resizing and i.UserInputType == Enum.UserInputType.MouseMovement then
            local m = UserInputService:GetMouseLocation()
            local r = m - obj.AbsolutePosition
            obj.Size = UDim2.new(0, math.max(350, r.X), 0, math.max(400, r.Y))
        end
    end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then resizing = false end end)
end
SetupInteractive(Main)

-- Data Logic (Backpack Scanner)
local function RefreshBackpack()
    for _, v in pairs(FishListFrame:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    pcall(function()
        local Data = require(ReplicatedStorage.Packages.Replion).Client:GetReplion("Data")
        local ItemUtil = require(ReplicatedStorage.Shared.ItemUtility)
        local inv = Data:Get("Inventory").Items
        
        local counts, tiers, uuids = {}, {}, {}
        for _, item in pairs(inv) do
            local base = ItemUtil:GetItemData(item.Id)
            if base.Data.Type == "Fish" then
                local n = base.Data.Name
                counts[n] = (counts[n] or 0) + 1
                tiers[n] = tostring(base.Data.Tier or "1")
                uuids[n] = item.UUID
            end
        end

        for n, q in pairs(counts) do
            local cfg = PawfyColors[tiers[n]] or PawfyColors["1"]
            local B = Instance.new("TextButton", FishListFrame)
            B.Size = UDim2.new(1, -5, 0, 30)
            B.BackgroundColor3 = cfg.BG
            B.TextColor3 = cfg.TXT
            B.Text = n .. " (" .. q .. ")"
            B.Font = Enum.Font.GothamBold
            B.LayoutOrder = -tonumber(tiers[n])
            Instance.new("UICorner", B)
            B.MouseButton1Click:Connect(function() 
                SelectedFishUUID = uuids[n] 
                StatLabel.Text = "Success Trade: "..SuccessCount.." | Failed: "..FailedCount.."\nSelected: "..n 
            end)
        end
    end)
    FishListFrame.CanvasSize = UDim2.new(0,0,0, FishListFrame.UIListLayout.AbsoluteContentSize.Y)
end

-- Toggles
StartTradeBtn.MouseButton1Click:Connect(function()
    IsTrading = not IsTrading
    StartTradeBtn.Text = "START TRADE: " .. (IsTrading and "ON" or "OFF")
    StartTradeBtn.BackgroundColor3 = IsTrading and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
end)

AutoAccBtn.MouseButton1Click:Connect(function()
    AutoAccept = not AutoAccept
    AutoAccBtn.Text = "AUTO ACCEPT TRADE: " .. (AutoAccept and "ON" or "OFF")
    AutoAccBtn.BackgroundColor3 = AutoAccept and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
end)

-- Minimize
local HeaderTrigger = Instance.new("TextButton", Main)
HeaderTrigger.Size = UDim2.new(1, 0, 0, 40)
HeaderTrigger.BackgroundTransparency = 1
HeaderTrigger.Text = ""
HeaderTrigger.MouseButton1Click:Connect(function() Main.Visible = false PLogo.Visible = true end)
PLogo.MouseButton1Click:Connect(function() Main.Visible = true PLogo.Visible = false end)

RefreshBackpackBtn.MouseButton1Click:Connect(RefreshBackpack)
RefreshBackpack()
