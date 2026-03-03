-- =========================================================
-- 🔥 LYNX REMOTE SPY + AUTO SAVE LOG
-- =========================================================

pcall(function()
    game.CoreGui:FindFirstChild("LynxSpy"):Destroy()
end)

local UIS = game:GetService("UserInputService")

-- FILE CONFIG
local FILE_NAME = "Lynx_Remote_Log.txt"
local LOG_BUFFER = {}

-- CHECK SUPPORT
local canSave = writefile ~= nil

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "LynxSpy"

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0.9, 0, 0.45, 0)
main.Position = UDim2.new(0.05, 0, 0.5, 0)
main.BackgroundColor3 = Color3.fromRGB(15,15,15)
main.BackgroundTransparency = 0.2
main.Active = true
Instance.new("UICorner", main)

local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(0,255,180)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "🔥 LYNX REMOTE SPY + SAVE"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 14

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -10, 1, -80)
scroll.Position = UDim2.new(0, 5, 0, 35)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 3

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 3)

-- BUTTON SAVE
local saveBtn = Instance.new("TextButton", main)
saveBtn.Size = UDim2.new(0.9, 0, 0, 30)
saveBtn.Position = UDim2.new(0.05, 0, 1, -35)
saveBtn.Text = "💾 SAVE LOG"
saveBtn.BackgroundColor3 = Color3.fromRGB(0,180,120)
saveBtn.TextColor3 = Color3.new(0,0,0)
saveBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", saveBtn)

-- DRAG
local dragging, dragStart, startPos
main.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = i.Position
        startPos = main.Position
    end
end)

UIS.InputChanged:Connect(function(i)
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = i.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- LOGGER
local function log(text)
    table.insert(LOG_BUFFER, text)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -5, 0, 18)
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(200,200,200)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Code
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = scroll

    scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 20)
end

-- SAVE FUNCTION
local function saveLog()
    local content = table.concat(LOG_BUFFER, "\n")

    if canSave then
        writefile(FILE_NAME, content)
        log("✅ Saved to file: "..FILE_NAME)
    else
        if setclipboard then
            setclipboard(content)
            log("📋 Copied to clipboard (no file support)")
        else
            log("❌ Save not supported in this executor")
        end
    end
end

saveBtn.MouseButton1Click:Connect(saveLog)

-- REMOTE SPY
local mt = getrawmetatable(game)
setreadonly(mt, false)

local old = mt.__namecall

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if typeof(self) == "Instance" then
        
        if method == "FireServer" then
            log("🔥 FireServer → "..self:GetFullName())
            for i,v in ipairs(args) do
                log("   ["..i.."] "..tostring(v))
            end
        end
        
        if method == "InvokeServer" then
            log("📞 InvokeServer → "..self:GetFullName())
            for i,v in ipairs(args) do
                log("   ["..i.."] "..tostring(v))
            end
        end
    end

    return old(self, ...)
end)

log("✅ Spy Active (Auto Save Ready)")
log(canSave and "💾 File saving supported" or "📋 Clipboard fallback mode")
