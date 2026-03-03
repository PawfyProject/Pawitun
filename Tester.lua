----------------------------------------------------------------
-- ======= [ CORE SERVICES & CONFIG ] =======
----------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local TierSettings = {
    ["1"] = {Name = "COMMON",    BG = Color3.fromRGB(255,255,255), TXT = Color3.fromRGB(0,0,0)},
    ["2"] = {Name = "UNCOMMON",  BG = Color3.fromRGB(126,255,28),  TXT = Color3.fromRGB(0,0,0)},
    ["3"] = {Name = "RARE",      BG = Color3.fromRGB(0,68,255),    TXT = Color3.fromRGB(0,0,0)},
    ["4"] = {Name = "EPIC",      BG = Color3.fromRGB(74,0,153),    TXT = Color3.fromRGB(255,255,255)},
    ["5"] = {Name = "LEGENDARY", BG = Color3.fromRGB(255,187,0),   TXT = Color3.fromRGB(0,0,0)},
    ["6"] = {Name = "MYTHIC",    BG = Color3.fromRGB(255,0,0),     TXT = Color3.fromRGB(255,255,255)},
    ["7"] = {Name = "SECRET",    BG = Color3.fromRGB(17,217,157),  TXT = Color3.fromRGB(0,0,0)}
}

----------------------------------------------------------------
-- ======= [ LYNX UI ENGINE V2 ] =======
----------------------------------------------------------------
local LynxLib = {}
local ScrollFrame, Layout
local FilterEnabled = true

function LynxLib:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Size = UDim2.new(0, 400, 0, 520)
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -260)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
    Instance.new("UICorner", MainFrame)

    local Title = Instance.new("TextLabel", MainFrame)
    Title.Size = UDim2.new(1,0,0,40)
    Title.Text = "  "..title
    Title.TextColor3 = Color3.new(1,1,1)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left

    ScrollFrame = Instance.new("ScrollingFrame", MainFrame)
    ScrollFrame.Size = UDim2.new(1,-20,1,-150)
    ScrollFrame.Position = UDim2.new(0,10,0,50)
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.ScrollBarThickness = 2

    Layout = Instance.new("UIListLayout", ScrollFrame)
    Layout.Padding = UDim.new(0,5)

    -- ===== BUTTON AREA =====
    local Bottom = Instance.new("Frame", MainFrame)
    Bottom.Size = UDim2.new(1,0,0,90)
    Bottom.Position = UDim2.new(0,0,1,-90)
    Bottom.BackgroundTransparency = 1

    -- Toggle Button
    local ToggleBtn = Instance.new("TextButton", Bottom)
    ToggleBtn.Size = UDim2.new(0.9,0,0,30)
    ToggleBtn.Position = UDim2.new(0.05,0,0,5)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    ToggleBtn.Text = "FILTER: ON (MYTHIC/SECRET)"
    ToggleBtn.TextColor3 = Color3.new(1,1,1)
    ToggleBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", ToggleBtn)

    -- Refresh Button
    local RefreshBtn = Instance.new("TextButton", Bottom)
    RefreshBtn.Size = UDim2.new(0.9,0,0,35)
    RefreshBtn.Position = UDim2.new(0.05,0,0,45)
    RefreshBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
    RefreshBtn.Text = "REFRESH BACKPACK"
    RefreshBtn.TextColor3 = Color3.new(1,1,1)
    RefreshBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", RefreshBtn)

    -- Toggle Logic
    ToggleBtn.MouseButton1Click:Connect(function()
        FilterEnabled = not FilterEnabled
        if FilterEnabled then
            ToggleBtn.Text = "FILTER: ON (MYTHIC/SECRET)"
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
        else
            ToggleBtn.Text = "FILTER: OFF (ALL ITEMS)"
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(90,60,60)
        end
    end)

    return RefreshBtn
end

function LynxLib:AddItem(name, tier)
    local cfg = TierSettings[tostring(tier)] or TierSettings["1"]

    local Item = Instance.new("Frame", ScrollFrame)
    Item.Size = UDim2.new(1,-5,0,30)
    Item.BackgroundColor3 = cfg.BG
    Instance.new("UICorner", Item)

    local Label = Instance.new("TextLabel", Item)
    Label.Size = UDim2.new(1,-10,1,0)
    Label.Position = UDim2.new(0,10,0,0)
    Label.BackgroundTransparency = 1
    Label.Text = "["..cfg.Name.."] "..name
    Label.TextColor3 = cfg.TXT
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left

    ScrollFrame.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y+35)
end

function LynxLib:Clear()
    for _,v in pairs(ScrollFrame:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end
end

----------------------------------------------------------------
-- ======= [ DATA LOGIC ] =======
----------------------------------------------------------------
local Replion, ItemUtility, DataReplion

task.spawn(function()
    local shared = ReplicatedStorage:WaitForChild("Shared",30)
    Replion = require(ReplicatedStorage.Packages.Replion)
    ItemUtility = require(shared:WaitForChild("ItemUtility"))

    repeat
        DataReplion = Replion.Client:GetReplion("Data")
        task.wait(1)
    until DataReplion
end)

local function RefreshList()
    LynxLib:Clear()

    local data = DataReplion and DataReplion:Get("Inventory")
    local items = (data and data.Items) or {}

    local counts = {}
    local tierMap = {}

    for _, item in pairs(items) do
        local base = ItemUtility:GetItemData(item.Id)
        if base and base.Data and base.Data.Type == "Fish" then
            local name = base.Data.Name
            local tier = tostring(base.Data.Tier or "1")

            -- FILTER LOGIC
            if FilterEnabled then
                if tier ~= "6" and tier ~= "7" then
                    continue
                end
            end

            counts[name] = (counts[name] or 0) + 1
            tierMap[name] = tier
        end
    end

    for name, qty in pairs(counts) do
        LynxLib:AddItem(name.." (x"..qty..")", tierMap[name])
    end
end

----------------------------------------------------------------
-- ======= [ MAIN ] =======
----------------------------------------------------------------
local RefreshButton = LynxLib:CreateWindow("FISCH LYNX V2")

RefreshButton.MouseButton1Click:Connect(function()
    RefreshList()
end)
