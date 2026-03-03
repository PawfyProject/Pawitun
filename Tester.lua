----------------------------------------------------------------
-- [ 1. CONFIGURATION & COLOR MAP ]
----------------------------------------------------------------
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local MyLogoID = "https://raw.githubusercontent.com/PawfyProject/Pawitun/refs/heads/main/Logo.jpg" 

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
-- [ 2. DATA MODULES (LOGIC v4.1) ]
----------------------------------------------------------------
local Replion, ItemUtility, DataReplion
local MyInventory = {}

task.spawn(function()
    pcall(function()
        local packages = ReplicatedStorage:WaitForChild("Packages", 30)
        local shared = ReplicatedStorage:WaitForChild("Shared", 30)
        Replion = require(packages:WaitForChild("Replion"))
        ItemUtility = require(shared:WaitForChild("ItemUtility"))
        repeat 
            DataReplion = Replion.Client:GetReplion("Data")
            task.wait(1)
        until DataReplion ~= nil
    end)
end)

local function fullBruteForceScan()
    table.clear(MyInventory) 
    local data = DataReplion and DataReplion:Get("Inventory")
    local items = (data and data.Items) or {}
    
    for _, item in pairs(items) do
        local base = ItemUtility:GetItemData(item.Id)
        if base and base.Data and base.Data.Type == "Fish" then
            table.insert(MyInventory, {
                Name = base.Data.Name,
                Tier = tostring(base.Data.Tier),
                UUID = item.UUID
            })
        end
    end
    return #MyInventory
end

----------------------------------------------------------------
-- [ 3. UI CONSTRUCTION (COLORED VERSION) ]
----------------------------------------------------------------
local GUI = Instance.new("ScreenGui", game.CoreGui)
GUI.Name = "PawfyColored_v18"

local Main = Instance.new("Frame", GUI)
Main.Size = UDim2.new(0, 520, 0, 420)
Main.Position = UDim2.new(0.5, -260, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BackgroundTransparency = 0.3 -- 70% Opacity
Main.Active = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(45, 45, 45)

-- Sidebar (v4.1 Style)
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 140, 1, 0)
Sidebar.BackgroundTransparency = 1

local Logo = Instance.new("ImageLabel", Sidebar)
Logo.Size = UDim2.new(0, 40, 0, 40)
Logo.Position = UDim2.new(0.5, -20, 0, 15)
Logo.Image = MyLogoID
Instance.new("UICorner", Logo).CornerRadius = UDim.new(1, 0)

local SideLayout = Instance.new("UIListLayout", Sidebar)
SideLayout.Padding = UDim.new(0, 5)
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Content Area
local Container = Instance.new("Frame", Main)
Container.Size = UDim2.new(1, -150, 1, -20)
Container.Position = UDim2.new(0, 145, 0, 10)
Container.BackgroundTransparency = 1

----------------------------------------------------------------
-- [ 4. COMPONENT BUILDER ]
----------------------------------------------------------------
local CurrentPage = nil

local function CreateTab(name, icon)
    local Btn = Instance.new("TextButton", Sidebar)
    Btn.Size = UDim2.new(0.9, 0, 0, 35)
    Btn.BackgroundTransparency = 1
    Btn.Text = name
    Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    Btn.Font = Enum.Font.GothamMedium
    Btn.TextSize = 13
    
    local Page = Instance.new("ScrollingFrame", Container)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 0
    local Layout = Instance.new("UIListLayout", Page)
    Layout.Padding = UDim.new(0, 10)
    
    Btn.MouseButton1Click:Connect(function()
        if CurrentPage then CurrentPage.Visible = false end
        Page.Visible = true
        CurrentPage = Page
    end)
    return Page
end

-- TAB: FISH TRADE
local FishPage = CreateTab("Fish Trade", "")
FishPage.Visible = true
CurrentPage = FishPage

local function AddSectionTitle(txt, parent)
    local l = Instance.new("TextLabel", parent)
    l.Size = UDim2.new(1, 0, 0, 20)
    l.Text = txt:upper()
    l.TextColor3 = Color3.fromRGB(100, 100, 100)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 11
    l.BackgroundTransparency = 1
    l.TextXAlignment = Enum.TextXAlignment.Left
end

AddSectionTitle("Main Fish Trader", FishPage)

-- Dropdown Simulasi (Player)
local PlayerBox = Instance.new("TextBox", FishPage)
PlayerBox.Size = UDim2.new(1, -10, 0, 35)
PlayerBox.PlaceholderText = "1. Target Player Name..."
PlayerBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
PlayerBox.TextColor3 = Color3.white
Instance.new("UICorner", PlayerBox)

-- SCROLL LIST IKAN BERWARNA (Pengganti Dropdown Fluent)
local FishScroll = Instance.new("ScrollingFrame", FishPage)
FishScroll.Size = UDim2.new(1, -10, 0, 150)
FishScroll.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
FishScroll.ScrollBarThickness = 2
local FLayout = Instance.new("UIListLayout", FishScroll)
FLayout.Padding = UDim.new(0, 3)

local function SyncFishDisplay()
    for _, v in pairs(FishScroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    fullBruteForceScan()
    
    local counts = {}
    local tiers = {}
    for _, v in ipairs(MyInventory) do
        counts[v.Name] = (counts[v.Name] or 0) + 1
        tiers[v.Name] = v.Tier
    end
    
    for name, qty in pairs(counts) do
        local t = tiers[name]
        local cfg = RarityMap[t]
        local b = Instance.new("TextButton", FishScroll)
        b.Size = UDim2.new(1, -5, 0, 28)
        b.BackgroundColor3 = cfg.Color
        b.Text = "  " .. name .. " (" .. qty .. ")"
        b.TextColor3 = cfg.Text
        b.Font = Enum.Font.GothamBold
        b.TextSize = 12
        b.TextXAlignment = Enum.TextXAlignment.Left
        Instance.new("UICorner", b)
    end
    FishScroll.CanvasSize = UDim2.new(0,0,0, FLayout.AbsoluteContentSize.Y)
end

local SyncBtn = Instance.new("TextButton", FishPage)
SyncBtn.Size = UDim2.new(1, -10, 0, 35)
SyncBtn.Text = "REFRESH & SYNC BACKPACK"
SyncBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SyncBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
Instance.new("UICorner", SyncBtn)
SyncBtn.MouseButton1Click:Connect(SyncFishDisplay)

-- START BUTTON
local StartBtn = Instance.new("TextButton", FishPage)
StartBtn.Size = UDim2.new(1, -10, 0, 40)
StartBtn.Text = "START AUTO TRADE"
StartBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
StartBtn.TextColor3 = Color3.white
StartBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", StartBtn)

----------------------------------------------------------------
-- [ 5. DRAGGABLE & LOGIC ]
----------------------------------------------------------------
local dragging, dragStart, startPos
Main.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true dragStart = i.Position startPos = Main.Position end end)
UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
    local d = i.Position - dragStart
    Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

SyncFishDisplay() -- Initial Scan
