-- [[ SETTINGS REPO PAWITUN ]] --
local user = "PawfyProject"
local repo = "Pawitun"
local path = "Configs"
local branch = "main"

local syncFile = "current_bot_config.txt"
local keyFile = "WinterHub/license/license.key" 
-- Script Utama FishIt
local mainFishIt = "https://raw.githubusercontent.com/FnDXueyi/roblog/refs/heads/main/fishit-78c86024ea87c8eca577549807421962.lua"

-- [[ AUTO-FOLDER CREATION ]] --
if not isfolder("WinterHub") then makefolder("WinterHub") end
if not isfolder("WinterHub/license") then makefolder("WinterHub/license") end

-- [[ FUNCTION TO RUN SCRIPT ]] --
local function RunMain(configName, userKey)
    local rawURL = "https://raw.githubusercontent.com/"..user.."/"..repo.."/"..branch.."/"..path.."/"..configName
    
    -- 1. Set Global Key agar Main Script Valid
    _G.script_key = userKey
    
    -- 2. Load Config (Tabel Settings)
    local s, r = pcall(function() return game:HttpGet(rawURL) end)
    if s then 
        local func = loadstring(r)
        if func then func() end 
    end

    -- 3. Load Main Script FishIt
    -- Kita jalankan dari sini agar Config di GitHub tetap bersih (hanya tabel)
    local s_main, r_main = pcall(function() return game:HttpGet(mainFishIt) end)
    if s_main then 
        loadstring(r_main)() 
    end
end

-- [[ FUNCTION SELECT CONFIG ]] --
local function ShowConfigSelection(userKey)
    local apiURL = "https://api.github.com/repos/"..user.."/"..repo.."/contents/"..path
    local s_api, r_api = pcall(function() return game:HttpGet(apiURL) end)
    
    if s_api then
        local files = game:GetService("HttpService"):JSONDecode(r_api)
        local validFiles = {}
        for _, file in pairs(files) do 
            if file.name:match("%.lua$") then table.insert(validFiles, file) end 
        end

        local sg = Instance.new("ScreenGui", game.CoreGui)
        local f = Instance.new("Frame", sg)
        f.Size = UDim2.new(0, 250, 0, 70 + (#validFiles * 45))
        f.Position = UDim2.new(0.5, -125, 0.5, -((70 + (#validFiles * 45))/2))
        f.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Instance.new("UICorner", f)

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
                RunMain(file.name, userKey)
            end)
            yPos = yPos + 45
        end
    end
end

-- [[ MAIN LOGIC FLOW ]] --
if isfile(keyFile) then
    local currentKey = readfile(keyFile):gsub("%s+", "") -- Membersihkan key dari spasi
    if isfile(syncFile) then
        RunMain(readfile(syncFile), currentKey)
    else
        ShowConfigSelection(currentKey)
    end
else
    -- GUI INPUT LICENSE (Safe & Direct)
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
    txt.TextPassword = true -- Menyembunyikan key agar aman
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
        local cleanKey = txt.Text:gsub("%s+", "") -- Hapus karakter ilegal
        if cleanKey ~= "" then
            pcall(function() writefile(keyFile, cleanKey) end)
            sg:Destroy()
            ShowConfigSelection(cleanKey) -- Langsung ke pilih config tanpa restart
        end
    end)
end
