----------------------------------------------------------------
-- ======= [ CORE SERVICES & CONFIG ] =======
----------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local TierSettings = {
    ["1"] = {Name = "COMMON",    BG = Color3.fromRGB(255,255,255), TXT = Color3.fromRGB(0,0,0)},
    ["2"] = {Name = "UNCOMMON",  BG = Color3.fromRGB(126,255,28), TXT = Color3.fromRGB(0,0,0)},
    ["3"] = {Name = "RARE",      BG = Color3.fromRGB(0,68,255), TXT = Color3.fromRGB(255,255,255)},
    ["4"] = {Name = "EPIC",      BG = Color3.fromRGB(74,0,153), TXT = Color3.fromRGB(255,255,255)},
    ["5"] = {Name = "LEGENDARY", BG = Color3.fromRGB(255,187,0), TXT = Color3.fromRGB(0,0,0)},
    ["6"] = {Name = "MYTHIC",    BG = Color3.fromRGB(255,0,0), TXT = Color3.fromRGB(255,255,255)},
    ["7"] = {Name = "SECRET",    BG = Color3.fromRGB(17,217,157), TXT = Color3.fromRGB(0,0,0)}
}

----------------------------------------------------------------
-- ======= [ LYNX UI ENGINE ] =======
----------------------------------------------------------------
local LynxLib = {}
local ScrollFrame, Layout

function LynxLib:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0,400,0,500)
    Main.Position = UDim2.new(0.5,-200,0.5,-250)
    Main.BackgroundColor3 = Color3.fromRGB(25,25,25)
    Instance.new("UICorner", Main)

    local Title = Instance.new("TextLabel", Main)
    Title.Size = UDim2.new(1,0,0,40)
    Title.Text = "  "..title
    Title.TextColor3 = Color3.white
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextSize = 16

    ScrollFrame = Instance.new("ScrollingFrame", Main)
    ScrollFrame.Size = UDim2.new(1,-20,1,-120)
    ScrollFrame.Position = UDim2.new(0,10,0,50)
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.ScrollBarThickness = 2

    Layout = Instance.new("UIListLayout", ScrollFrame)
    Layout.Padding = UDim.new(0,5)

    local SyncBtn = Instance.new("TextButton", Main)
    SyncBtn.Size = UDim2.new(0.9,0,0,35)
    SyncBtn.Position = UDim2.new(0.05,0,1,-50)
    SyncBtn.Text = "SYNC MYTHIC / SECRET"
    SyncBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
    SyncBtn.TextColor3 = Color3.white
    SyncBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", SyncBtn)

    return SyncBtn
end

function LynxLib:AddItem(name, tier)
    local cfg = TierSettings[tostring(tier)] or TierSettings["1"]

    local f = Instance.new("Frame", ScrollFrame)
    f.Size = UDim2.new(1,-5,0,30)
    f.BackgroundColor3 = cfg.BG
    Instance.new("UICorner", f)

    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1,-10,1,0)
    l.Position = UDim2.new(0,10,0,0)
    l.Text = "["..cfg.Name.."] "..name
    l.TextColor3 = cfg.TXT
    l.Font = Enum.Font.GothamBold
    l.TextSize = 12
    l.BackgroundTransparency = 1
    l.TextXAlignment = Enum.TextXAlignment.Left

    ScrollFrame.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y + 35)
end

function LynxLib:ClearItems()
    for _, v in pairs(ScrollFrame:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end
end

----------------------------------------------------------------
-- ======= [ SAFE DATA LOADER ] =======
----------------------------------------------------------------
local Replion, ItemUtility, DataReplion

task.spawn(function()
    local success = pcall(function()
        local shared = ReplicatedStorage:WaitForChild("Shared",10)
        local packages = ReplicatedStorage:WaitForChild("Packages",10)

        Replion = require(packages:WaitForChild("Replion"))
        ItemUtility = require(shared:WaitForChild("ItemUtility"))

        -- retry system (ANTI BLANK)
        for i = 1,10 do
            local ok, repl = pcall(function()
                return Replion.Client:GetReplion("Data")
            end)

            if ok and repl then
                DataReplion = repl
                break
            end

            task.wait(0.5)
        end
    end)

    if not success then
        warn("FAILED LOAD DATA SYSTEM")
    end
end)

----------------------------------------------------------------
-- ======= [ CORE FILTER LOGIC - AKURAT ] =======
----------------------------------------------------------------
local function RefreshList()
    LynxLib:ClearItems()

    if not DataReplion then
        LynxLib:AddItem("WAITING DATA...", 4)
        return
    end

    local success, data = pcall(function()
        return DataReplion:Get("Inventory")
    end)

    if not success or not data then
        LynxLib:AddItem("DATA ERROR", 6)
        return
    end

    local items = data.Items or data or {}

    local counts = {}
    local tierMap = {}
    local total = 0

    for _, item in pairs(items) do
        if item and item.Id then

            local ok, base = pcall(function()
                return ItemUtility:GetItemData(item.Id)
            end)

            if ok and base and base.Data then
                local d = base.Data

                if d.Type == "Fish" then
                    local tier = tostring(d.Tier or "1")

                    -- 🔥 FILTER ONLY MYTHIC & SECRET
                    if tier == "6" or tier == "7" then
                        local name = d.Name or "Unknown"

                        counts[name] = (counts[name] or 0) + 1
                        tierMap[name] = tier
                        total += 1
                    end
                end
            end
        end
    end

    if total == 0 then
        LynxLib:AddItem("NO MYTHIC / SECRET FOUND", 4)
        return
    end

    -- sorting biar rapi
    local sorted = {}
    for name, qty in pairs(counts) do
        table.insert(sorted, {name = name, qty = qty, tier = tierMap[name]})
    end

    table.sort(sorted, function(a,b)
        return a.qty > b.qty
    end)

    for _, v in ipairs(sorted) do
        LynxLib:AddItem(
            v.name.." (x"..v.qty..")",
            v.tier
        )
    end

    LynxLib:AddItem("TOTAL: "..total, 5)
end

----------------------------------------------------------------
-- ======= [ MAIN ] =======
----------------------------------------------------------------
local SyncButton = LynxLib:CreateWindow("PAWFY TRADE FILTER - STABLE")

SyncButton.MouseButton1Click:Connect(function()
    RefreshList()
end)
