-- [[ SETTINGS REPO PAWITUN ]] --
local user = "PawfyProject"
local repo = "Pawitun"
local path = "Configs"
local branch = "main"

local syncFile = "current_bot_config.txt"
local keyFile = "WinterHub/license/license.key" 
local mainFishIt = "https://raw.githubusercontent.com/FnDXueyi/roblog/refs/heads/main/fishit-78c86024ea87c8eca577549807421962.lua"

-- [[ FUNGSI AUTO-FOLDER ]] --
if not isfolder("WinterHub") then makefolder("WinterHub") end
if not isfolder("WinterHub/license") then makefolder("WinterHub/license") end

-- [[ FUNGSI LOAD CONFIG ]] --
local function ShowConfigSelection(userKey)
    local apiURL = "https://api.github.com/repos/"..user.."/"..repo.."/contents/"..path
    local s_api, r_api = pcall(function() return game:HttpGet(apiURL) end)
    
    if not s_api then warn("GitHub API Error!") return end
    
    local files = game:GetService("HttpService"):JSONDecode(r_api)
    local validFiles = {}
    for _, file in pairs(files) do 
        if file.name:match("%.lua$") then table.insert(validFiles, file) end 
    end

    -- GUI PILIH CONFIG
    local sg = Instance.new("ScreenGui", game.CoreGui)
    local f = Instance.new("Frame", sg)
    f.Size = UDim2.new(0, 250, 0, 70 + (#validFiles * 45))
    f.Position = UDim2.new(0.5, -125, 0.5, -((70 + (#validFiles * 45))/2))
    f.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Instance.new("UICorner", f)

    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, 0, 0, 45)
    l.Text = "SELECT CONFIG"
    l.TextColor3 = Color3.new(1, 1, 1)
    l.BackgroundTransparency = 1

    local yPos = 55
    for _, file in pairs(validFiles) do
        local btn = Instance.new("TextButton", f)
        btn.Size = UDim2.new(0, 210, 0, 38)
        btn.Position = UDim2.new(0.5, -105, 0, yPos)
        btn.Text = file.name:gsub("%.lua$", "")
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        btn.TextColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", btn)

        btn.MouseButton1Click:Connect(function()
            writefile(syncFile, file.name)
            sg:Destroy()
            
            -- Jalankan Script Utama
            local rawURL = "https://raw.githubusercontent.com/"..user.."/"..repo.."/"..branch.."/"..path.."/"..file.name
            loadstring(game:HttpGet(rawURL))()
            _G.script_key = userKey
            loadstring(game:HttpGet(mainFishIt))()
        end)
        yPos = yPos + 45
    end
end

-- [[ MAIN LOGIC FLOW ]] --

if isfile(keyFile) then
    local currentKey = readfile(keyFile)
    if isfile(syncFile) then
        -- Jika sudah ada sync, langsung gas
        local configName = readfile(syncFile)
        loadstring(game:HttpGet("https://raw.githubusercontent.com/"..user.."/"..repo.."/"..branch.."/"..path.."/"..configName))()
        _G.script_key = currentKey
        loadstring(game:HttpGet(mainFishIt))()
    else
        ShowConfigSelection(currentKey)
    end
else
    -- GUI INPUT KEY
    local sg = Instance.new("ScreenGui", game.CoreGui)
    local f = Instance.new("Frame", sg)
    f.Size = UDim2.new(0, 250, 0, 160)
    f.Position = UDim2.new(0.5, -125, 0.5, -80)
    f.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Instance.new("UICorner", f)

    local txt = Instance.new("TextBox", f)
    txt.Size = UDim2.new(0, 210, 0, 35)
    txt.Position = UDim2.new(0.5, -105, 0, 55)
    txt.PlaceholderText = "Paste License Key..."
    txt.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    txt.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", txt)

    local btn = Instance.new("TextButton", f)
    btn.Size = UDim2.new(0, 210, 0, 35)
    btn.Position = UDim2.new(0.5, -105, 0, 105)
    btn.Text = "SAVE & CONTINUE"
    btn.BackgroundColor3 = Color3.fromRGB(70, 150, 70)
    btn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        if txt.Text ~= "" then
            writefile(keyFile, txt.Text)
            local savedKey = txt.Text
            sg:Destroy()
            -- LANGSUNG PANGGIL PEMILIHAN CONFIG
            ShowConfigSelection(savedKey)
        end
    end)
end
