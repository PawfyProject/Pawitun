----------------------------------------------------------------
-- ======= [ CORE SERVICES & CONFIG ] =======
----------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Konfigurasi Warna RGB (Sesuai Permintaan Anda)
local TierSettings = {
    ["1"] = {BG = Color3.fromRGB(255, 255, 255), TXT = Color3.fromRGB(0, 0, 0)},     -- COMMON
    ["2"] = {BG = Color3.fromRGB(126, 255, 28),  TXT = Color3.fromRGB(0, 0, 0)},     -- UNCOMMON
    ["3"] = {BG = Color3.fromRGB(0, 68, 255),    TXT = Color3.fromRGB(0, 0, 0)},     -- RARE
    ["4"] = {BG = Color3.fromRGB(74, 0, 153),    TXT = Color3.fromRGB(255, 255, 255)}, -- EPIC
    ["5"] = {BG = Color3.fromRGB(255, 187, 0),   TXT = Color3.fromRGB(0, 0, 0)},     -- LEGENDARY
    ["6"] = {BG = Color3.fromRGB(255, 0, 0),     TXT = Color3.fromRGB(255, 255, 255)}, -- MYTHIC
    ["7"] = {BG = Color3.fromRGB(17, 217, 157),  TXT = Color3.fromRGB(0, 0, 0)}      -- SECRET
}

----------------------------------------------------------------
-- ======= [ LYNX LIGHT UI ENGINE ] =======
----------------------------------------------------------------
local Lynx = {}
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

function Lynx:CreateWindow(title)
    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, 350, 0, 450)
    Main.Position = UDim2.new(0.5, -175, 0.5, -225)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Main.BorderSizePixel = 0
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
    
    -- Dragging Logic
    local dragging, dragInput, dragStart, startPos
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true dragStart = input.Position startPos = Main.Position
        end
    end)
    Main.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    local Title = Instance.new("TextLabel", Main)
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundTransparency = 1
    Title.Text = title
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14

    local Scroll = Instance.new("ScrollingFrame", Main)
    Scroll.Size = UDim2.new(1, -20, 1, -100)
    Scroll.Position = UDim2.new(0, 10, 0, 45)
    Scroll.BackgroundTransparency = 1
    Scroll.ScrollBarThickness = 2
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local List = Instance.new("UIListLayout", Scroll)
    List.Padding = UDim.new(0, 4)
    List.SortOrder = Enum.SortOrder.LayoutOrder

    local SyncBtn = Instance.new("TextButton", Main)
    SyncBtn.Size = UDim2.new(1, -20, 0, 35)
    SyncBtn.Position = UDim2.new(0, 10, 1, -45)
    SyncBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    SyncBtn.Text = "SYNC BACKPACK"
    SyncBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SyncBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", SyncBtn)

    function Lynx:Clear()
        for _, v in pairs(Scroll:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
    end

    function Lynx:AddFish(name, qty, tier)
        local cfg = TierSettings[tostring(tier)] or TierSettings["1"]
        
        local Box = Instance.new("Frame", Scroll)
        Box.Size = UDim2.new(1, -5, 0, 28)
        Box.BackgroundColor3 = cfg.BG
        Box.BorderSizePixel = 0
        Box.LayoutOrder = -tonumber(tier) -- Ikan tier tinggi di atas
        Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 4)

        local Label = Instance.new("TextLabel", Box)
        Label.Size = UDim2.new(1, 0, 1, 0)
        Label.BackgroundTransparency = 1
        Label.Text = name .. " (" .. qty .. ")"
        Label.TextColor3 = cfg.TXT
        Label.Font = Enum.Font.GothamBold
        Label.TextSize = 12

        Scroll.CanvasSize = UDim2.new(0, 0, 0, List.AbsoluteContentSize.Y)
    end

    return SyncBtn
end

----------------------------------------------------------------
-- ======= [ DATA LOGIC ] =======
----------------------------------------------------------------
local Replion, ItemUtility, DataReplion
task.spawn(function()
    pcall(function()
        Replion = require(ReplicatedStorage.Packages.Replion)
        ItemUtility = require(ReplicatedStorage.Shared.ItemUtility)
        repeat 
            DataReplion = Replion.Client:GetReplion("Data")
            task.wait(1)
        until DataReplion ~= nil
    end)
end)

local function Refresh()
    Lynx:Clear()
    local inv = DataReplion and DataReplion:Get("Inventory")
    local items = (inv and inv.Items) or {}
    
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

    for name, qty in pairs(counts) do
        Lynx:AddFish(name, qty, tierMap[name])
    end
end

----------------------------------------------------------------
-- ======= [ EXECUTION ] =======
----------------------------------------------------------------
local Btn = Lynx:CreateWindow("FISCH CLEAN COLOR v5.4")
Btn.MouseButton1Click:Connect(Refresh)
Refresh() -- Auto-load pertama kali
