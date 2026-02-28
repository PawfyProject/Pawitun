-- [[ SETTINGS REPO PAWITUN ]] --
local user = "PawfyProject" -- Sesuai link URL raw yang kamu buka
local repo = "Pawitun"      -- Nama repository
local path = "Configs"     -- Nama folder dengan 's'
local branch = "main"

local syncFile = "current_bot_config.txt"
local keyFile = "pawitun_key.txt" 
local mainFishIt = "https://raw.githubusercontent.com/FnDXueyi/roblog/refs/heads/main/fishit-78c86024ea87c8eca577549807421962.lua"

-- [[ FUNCTION TO EXECUTE FINAL ]] --
local function ExecuteFinal(configFileName, userKey)
    local rawURL = "https://raw.githubusercontent.com/"..user.."/"..repo.."/"..branch.."/"..path.."/"..configFileName
    
    print("------------------------------------------")
    print("Loading Config: " .. configFileName)
    
    -- 1. Load Tabel Config
    local s, r = pcall(function() return game:HttpGet(rawURL) end)
    if s then 
        local func, err = loadstring(r)
        if func then func() else warn("Error in Config: " .. err) end
    else
        warn("Gagal mengambil config dari GitHub!")
    end
    
    -- 2. Gunakan Key dari Parameter
    _G.script_key = userKey

    -- 3. Load Script Utama FishIt
    local s_main, r_main
    repeat 
        s_main, r_main = pcall(function() return game:HttpGet(mainFishIt) end)
        if not s_main then task.wait(1) end
    until s_main
    
    loadstring(r_main)()
    print("Status: FishIt Started!")
    print("------------------------------------------")
end

-- [[ UI HELPER FUNCTIONS ]] --
local function createBaseGUI(title, height)
    local sg = Instance.new("ScreenGui", game.CoreGui)
    sg.Name = "PawitunUI"
    local f = Instance.new("Frame", sg)
    f.Size = UDim2.new(0, 250, 0, height)
    f.Position = UDim2.new(0.5, -125, 0.5, - (height/2))
    f.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    f.BorderSizePixel = 0
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)

    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, 0, 0, 45)
    l.Text = title
    l.TextColor3 = Color3.new(1, 1, 1)
    l.Font = Enum.Font.GothamBold
    l.BackgroundTransparency = 1
    
    return sg, f
end

-- [[ MAIN LOGIC FLOW ]] --

-- STEP 1: CEK KEY LOKAL
if not isfile(keyFile) then
    local sg, f = createBaseGUI("INPUT SCRIPT KEY", 160)
    
    local txt = Instance.new("TextBox", f)
    txt.Size = UDim2.new(0, 210, 0, 35)
    txt.Position = UDim2.new(0.5, -105, 0, 55)
    txt.PlaceholderText = "Paste Key Here..."
    txt.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    txt.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", txt)

    local btn = Instance.new("TextButton", f)
    btn.Size = UDim2.new(0, 210, 0, 35)
    btn.Position = UDim2.new(0.5, -105, 0, 105)
    btn.Text = "SAVE & CONTINUE"
    btn.BackgroundColor3 = Color3.fromRGB(70, 150, 70)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        if txt.Text ~= "" then
            writefile(keyFile, txt.Text) 
            sg:Destroy()
            game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Success", Text = "Key Saved! Restart Script."})
        end
    end)
    return 
end

local currentKey = readfile(keyFile)

-- STEP 2: CEK CONFIG (AUTO-SYNC ATAU GUI)
if isfile(syncFile) then
    ExecuteFinal(readfile(syncFile), currentKey)
else
    local apiURL = "https://api.github.com/repos/"..user.."/"..repo.."/contents/"..path
    local s_api, r_api = pcall(function() return game:HttpGet(apiURL) end)
    
    if not s_api then warn("GitHub API Error!") return end
    
    local files = game:GetService("HttpService"):JSONDecode(r_api)
    local validFiles = {}
    for _, file in pairs(files) do 
        if file.name:match("%.lua$") then table.insert(validFiles, file) end 
    end

    local sg, f = createBaseGUI("SELECT CONFIG", 70 + (#validFiles * 45))
    local yPos = 55
    for _, file in pairs(validFiles) do
        local btn = Instance.new("TextButton", f)
        btn.Size = UDim2.new(0, 210, 0, 38)
        btn.Position = UDim2.new(0.5, -105, 0, yPos)
        btn.Text = file.name:gsub("%.lua$", "")
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.GothamSemibold
        Instance.new("UICorner", btn)

        btn.MouseButton1Click:Connect(function()
            writefile(syncFile, file.name) 
            sg:Destroy()
            ExecuteFinal(file.name, currentKey)
        end)
        yPos = yPos + 45
    end
end
