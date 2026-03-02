----------------------------------------------------------------
-- ======= [ PAWFY SYSTEM CONFIG & RGB ] =======
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

----------------------------------------------------------------
-- ======= [ PAWFY CUSTOM UI ENGINE ] =======
----------------------------------------------------------------
local PawfySys = {}
local GUI = Instance.new("ScreenGui", game.CoreGui)
GUI.Name = "PawfyTradeSystem"

function PawfySys:CreateMain()
    -- Main Frame (Resizable & Draggable)
    local Main = Instance.new("Frame", GUI)
    Main.Size = UDim2.new(0, 350, 0, 450)
    Main.Position = UDim2.new(0.5, -175, 0.5, -225)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true -- Standard Draggable
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

    -- Resizer Corner (Dynamic Scaling)
    local Resizer = Instance.new("ImageButton", Main)
    Resizer.Size = UDim2.new(0, 20, 0, 20)
    Resizer.Position = UDim2.new(1, -20, 1, -20)
    Resizer.BackgroundTransparency = 1
    Resizer.Image = "rbxassetid://15243144665"
    Resizer.ImageColor3 = Color3.fromRGB(200, 200, 200)

    -- Header & Minimize
    local Header = Instance.new("TextButton", Main)
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundTransparency = 1
    Header.Text = "  🐾 PAWFY TRADE SYSTEM"
    Header.TextColor3 = Color3.fromRGB(255, 255, 255)
    Header.Font = Enum.Font.GothamBold
    Header.TextSize = 14
    Header.TextXAlignment = Enum.TextXAlignment.Left

    -- Minimize Icon (Floating P)
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

    -- Scrolling Area
    local Scroll = Instance.new("ScrollingFrame", Main)
    Scroll.Size = UDim2.new(1, -20, 1, -100)
    Scroll.Position = UDim2.new(0, 10, 0, 50)
    Scroll.BackgroundTransparency = 1
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    Scroll.ScrollBarThickness = 2
    local List = Instance.new("UIListLayout", Scroll)
    List.Padding = UDim.new(0, 5)

    -- Sync Button
    local Sync = Instance.new("TextButton", Main)
    Sync.Size = UDim2.new(1, -20, 0, 35)
    Sync.Position = UDim2.new(0, 10, 1, -45)
    Sync.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Sync.Text = "SCAN BACKPACK"
    Sync.TextColor3 = Color3.fromRGB(255, 255, 255)
    Sync.Font = Enum.Font.GothamBold
    Instance.new("UICorner", Sync)

    -- Scaling Logic
    Resizer.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local startSize = Main.Size
            local startMouse = UserInputService:GetMouseLocation()
            local connection
            connection = UserInputService.InputChanged:Connect(function(move)
                if move.UserInputType == Enum.UserInputType.MouseMovement then
                    local currMouse = UserInputService:GetMouseLocation()
                    local diff = currMouse - startMouse
                    Main.Size = UDim2.new(0, math.max(250, startSize.X.Offset + diff.X), 0, math.max(300, startSize.Y.Offset + diff.Y))
                end
            end)
            UserInputService.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == Enum.UserInputType.MouseButton1 then connection:Disconnect() end
            end)
        end
    end)

    -- Minimize Logic
    Header.MouseButton1Click:Connect(function() Main.Visible = false PLogo.Visible = true end)
    PLogo.MouseButton1Click:Connect(function() Main.Visible = true PLogo.Visible = false end)

    return Main, Scroll, Sync
end

----------------------------------------------------------------
-- ======= [ DATA HANDLER (FISCH SCANNER) ] =======
----------------------------------------------------------------
local Replion, ItemUtility, DataReplion
task.spawn(function()
    pcall(function()
        Replion = require(ReplicatedStorage.Packages.Replion)
        ItemUtility = require(ReplicatedStorage.Shared.ItemUtility)
        repeat DataReplion = Replion.Client:GetReplion("Data") task.wait(1) until DataReplion ~= nil
    end)
end)

local MainFrame, ScrollFrame, SyncBtn = PawfySys:CreateMain()

local function RefreshPawfy()
    for _, v in pairs(ScrollFrame:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
    
    local inv = DataReplion and DataReplion:Get("Inventory")
    local items = (inv and inv.Items) or {}
    local counts = {}
    local tierMap = {}

    for _, item in pairs(items) do
        local base = ItemUtility:GetItemData(item.Id)
        if base and base.Data and base.Data.Type == "Fish" then
            local name = base.Data.Name
            counts[name] = (counts[name] or 0) + 1
            tierMap[name] = tostring(base.Data.Tier or "1")
        end
    end

    for name, qty in pairs(counts) do
        local tier = tierMap[name]
        local cfg = PawfyColors[tier] or PawfyColors["1"]
        
        local Box = Instance.new("Frame", ScrollFrame)
        Box.Size = UDim2.new(1, -5, 0, 32)
        Box.BackgroundColor3 = cfg.BG
        Box.LayoutOrder = -tonumber(tier)
        Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 6)

        local Label = Instance.new("TextLabel", Box)
        Label.Size = UDim2.new(1, 0, 1, 0)
        Label.BackgroundTransparency = 1
        Label.Text = name .. " (x" .. qty .. ")"
        Label.TextColor3 = cfg.TXT
        Label.Font = Enum.Font.GothamBold
        Label.TextSize = 13
    end
    ScrollFrame.CanvasSize = UDim2.new(0,0,0, ScrollFrame.UIListLayout.AbsoluteContentSize.Y)
end

SyncBtn.MouseButton1Click:Connect(RefreshPawfy)
RefreshPawfy()
