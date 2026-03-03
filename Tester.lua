----------------------------------------------------------------
-- ======= [ 1. CORE SERVICES ] =======
----------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

----------------------------------------------------------------
-- ======= [ 2. CONFIG COLOR ] =======
----------------------------------------------------------------
local TierSettings = {
    ["1"] = {Name="COMMON", BG=Color3.fromRGB(255,255,255), TXT=Color3.fromRGB(0,0,0)},
    ["2"] = {Name="UNCOMMON", BG=Color3.fromRGB(126,255,28), TXT=Color3.fromRGB(0,0,0)},
    ["3"] = {Name="RARE", BG=Color3.fromRGB(0,162,255), TXT=Color3.fromRGB(255,255,255)},
    ["4"] = {Name="EPIC", BG=Color3.fromRGB(170,0,255), TXT=Color3.fromRGB(255,255,255)},
    ["5"] = {Name="LEGENDARY", BG=Color3.fromRGB(255,187,0), TXT=Color3.fromRGB(0,0,0)},
    ["6"] = {Name="MYTHIC", BG=Color3.fromRGB(255,0,0), TXT=Color3.fromRGB(255,255,255)},
    ["7"] = {Name="SECRET", BG=Color3.fromRGB(17,217,157), TXT=Color3.fromRGB(0,0,0)}
}

----------------------------------------------------------------
-- ======= [ 3. VARIABLES ] =======
----------------------------------------------------------------
local ScrollFrame, Layout
local FilterEnabled = true
local MainFrame, FloatingBtn

local Replion, ItemUtility, DataReplion

----------------------------------------------------------------
-- ======= [ 4. LOAD DATA SAFE ] =======
----------------------------------------------------------------
local function LoadModules()
    pcall(function()
        local shared = ReplicatedStorage:WaitForChild("Shared", 10)
        local pack = ReplicatedStorage:WaitForChild("Packages", 10)

        Replion = require(pack:WaitForChild("Replion"))
        ItemUtility = require(shared:WaitForChild("ItemUtility"))

        repeat
            DataReplion = Replion.Client:GetReplion("Data")
            task.wait(0.5)
        until DataReplion
    end)
end

----------------------------------------------------------------
-- ======= [ 5. UI CREATE ] =======
----------------------------------------------------------------
local function CreateUI()
    local old = game.CoreGui:FindFirstChild("Pawfy_Pro")
    if old then old:Destroy() end

    local gui = Instance.new("ScreenGui", game.CoreGui)
    gui.Name = "Pawfy_Pro"

    MainFrame = Instance.new("Frame", gui)
    MainFrame.Size = UDim2.new(0, 360, 0, 420)
    MainFrame.Position = UDim2.new(0.5, -180, 0.5, -210)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15,15,15)
    MainFrame.BackgroundTransparency = 0.2
    MainFrame.Active = true
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0,10)

    local stroke = Instance.new("UIStroke", MainFrame)
    stroke.Color = Color3.fromRGB(17,217,157)

    -- TITLE
    local title = Instance.new("TextLabel", MainFrame)
    title.Size = UDim2.new(1,0,0,40)
    title.Text = "  PAWFY PRO (SIM SAFE)"
    title.TextColor3 = Color3.new(1,1,1)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left

    -- MINIMIZE
    local min = Instance.new("TextButton", MainFrame)
    min.Size = UDim2.new(0,30,0,30)
    min.Position = UDim2.new(1,-35,0,5)
    min.Text = "-"
    min.BackgroundColor3 = Color3.fromRGB(50,50,50)
    Instance.new("UICorner", min).CornerRadius = UDim.new(1,0)

    -- SCROLL
    ScrollFrame = Instance.new("ScrollingFrame", MainFrame)
    ScrollFrame.Size = UDim2.new(1,-20,1,-140)
    ScrollFrame.Position = UDim2.new(0,10,0,45)
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ScrollFrame.ScrollBarThickness = 2

    Layout = Instance.new("UIListLayout", ScrollFrame)
    Layout.Padding = UDim.new(0,5)

    -- BUTTON FILTER
    local toggle = Instance.new("TextButton", MainFrame)
    toggle.Size = UDim2.new(0.9,0,0,30)
    toggle.Position = UDim2.new(0.05,0,1,-85)
    toggle.Text = "FILTER: ON (MYTHIC/SECRET)"
    toggle.BackgroundColor3 = Color3.fromRGB(60,60,60)
    toggle.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", toggle)

    -- BUTTON REFRESH
    local refresh = Instance.new("TextButton", MainFrame)
    refresh.Size = UDim2.new(0.9,0,0,35)
    refresh.Position = UDim2.new(0.05,0,1,-45)
    refresh.Text = "REFRESH BACKPACK"
    refresh.BackgroundColor3 = Color3.fromRGB(17,217,157)
    refresh.TextColor3 = Color3.fromRGB(0,0,0)
    Instance.new("UICorner", refresh)

    ----------------------------------------------------------------
    -- FLOATING BUTTON
    ----------------------------------------------------------------
    FloatingBtn = Instance.new("TextButton", gui)
    FloatingBtn.Size = UDim2.new(0,50,0,50)
    FloatingBtn.Position = UDim2.new(0,50,0.5,0)
    FloatingBtn.Text = "P"
    FloatingBtn.BackgroundColor3 = Color3.fromRGB(17,217,157)
    FloatingBtn.TextColor3 = Color3.new(0,0,0)
    FloatingBtn.Visible = false
    Instance.new("UICorner", FloatingBtn).CornerRadius = UDim.new(1,0)

    ----------------------------------------------------------------
    -- DRAG SYSTEM
    ----------------------------------------------------------------
    local function dragify(obj)
        local drag, start, pos
        obj.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                drag = true
                start = i.Position
                pos = obj.Position
            end
        end)

        UserInputService.InputChanged:Connect(function(i)
            if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = i.Position - start
                obj.Position = UDim2.new(pos.X.Scale, pos.X.Offset + delta.X, pos.Y.Scale, pos.Y.Offset + delta.Y)
            end
        end)

        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                drag = false
            end
        end)
    end

    dragify(MainFrame)
    dragify(FloatingBtn)

    ----------------------------------------------------------------
    -- MINIMIZE
    ----------------------------------------------------------------
    min.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
        FloatingBtn.Visible = true
    end)

    FloatingBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = true
        FloatingBtn.Visible = false
    end)

    return toggle, refresh
end

----------------------------------------------------------------
-- ======= [ 6. DATA RENDER + SIMULATION SAFE ] =======
----------------------------------------------------------------
local function Clear()
    for _, v in pairs(ScrollFrame:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end
    ScrollFrame.CanvasPosition = Vector2.new(0,0)
end

local function AddItem(name, tier)
    local cfg = TierSettings[tostring(tier)] or TierSettings["1"]

    local f = Instance.new("Frame", ScrollFrame)
    f.Size = UDim2.new(1,-5,0,32)
    f.BackgroundColor3 = cfg.BG
    Instance.new("UICorner", f)

    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1,-10,1,0)
    l.Position = UDim2.new(0,10,0,0)
    l.Text = "["..cfg.Name.."] "..name
    l.TextColor3 = cfg.TXT
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.GothamBold
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
end

local function Refresh()
    Clear()

    -- ===== SIMULATION MODE =====
    if not DataReplion then
        AddItem("Abyssal Leviathan (x2)", "6")
        AddItem("Phantom Koi (x1)", "7")
        AddItem("Infernal Shark (x3)", "6")
        AddItem("Celestial Whale (x1)", "7")
        return
    end

    -- ===== REAL DATA =====
    local data = DataReplion:Get("Inventory")
    local items = (data and data.Items) or {}

    local counts, tierMap = {}, {}

    for _, item in pairs(items) do
        local base = ItemUtility:GetItemData(item.Id)
        if base and base.Data and base.Data.Type == "Fish" then
            local name = base.Data.Name
            local tier = tostring(base.Data.Tier or "1")

            if not FilterEnabled or (tier == "6" or tier == "7") then
                counts[name] = (counts[name] or 0) + 1
                tierMap[name] = tier
            end
        end
    end

    for name, qty in pairs(counts) do
        AddItem(name.." (x"..qty..")", tierMap[name])
    end

    if next(counts) == nil then
        AddItem("NO ITEM FOUND", "1")
    end
end

----------------------------------------------------------------
-- ======= [ 7. RUN ] =======
----------------------------------------------------------------
task.spawn(LoadModules)

local toggle, refresh = CreateUI()

toggle.MouseButton1Click:Connect(function()
    FilterEnabled = not FilterEnabled
    toggle.Text = FilterEnabled and 
        "FILTER: ON (MYTHIC/SECRET)" or 
        "FILTER: OFF (ALL ITEMS)"
    Refresh()
end)

refresh.MouseButton1Click:Connect(Refresh)

-- Auto first load
task.delay(1, Refresh)
