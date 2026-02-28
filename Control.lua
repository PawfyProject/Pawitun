-- [[ SETTINGS REPO PAWITUN ]] --
local user = "PawfyProject"
local repo = "Pawitun"
local path = "Configs"
local branch = "main"

local syncFile = "current_bot_config.txt"

-- [[ AUTO-FOLDER CREATION (Optional for Main Script) ]] --
if not isfolder("WinterHub") then makefolder("WinterHub") end
if not isfolder("WinterHub/license") then makefolder("WinterHub/license") end

-- [[ FUNCTION TO RUN SELECTED CONFIG ]] --
local function RunConfig(configName)
    local rawURL = "https://raw.githubusercontent.com/"..user.."/"..repo.."/"..branch.."/"..path.."/"..configName
    
    local s, r = pcall(function() return game:HttpGet(rawURL) end)
    if s then 
        -- Menjalankan config yang sudah berisi Settings + Key + Loadstring FishIt
        loadstring(r)()
    else
        warn("Gagal mengambil config: " .. configName)
    end
end

-- [[ MAIN LOGIC FLOW ]] --

-- 1. Cek apakah ada config yang sudah di-sync (Auto-Run)
if isfile(syncFile) then
    local lastConfig = readfile(syncFile)
    RunConfig(lastConfig)
else
    -- 2. Jika tidak ada sync, tampilkan Menu Pilih Config
    local apiURL = "https://api.github.com/repos/"..user.."/"..repo.."/contents/"..path
    local s_api, r_api = pcall(function() return game:HttpGet(apiURL) end)
    
    if s_api then
        local files = game:GetService("HttpService"):JSONDecode(r_api)
        local validFiles = {}
        for _, file in pairs(files) do 
            if file.name:match("%.lua$") then table.insert(validFiles, file) end 
        end

        -- GUI PILIH CONFIG
        local sg = Instance.new("ScreenGui", game.CoreGui)
        local f = Instance.new("Frame", sg)
        -- Tinggi frame otomatis menyesuaikan jumlah file .lua di folder Configs
        f.Size = UDim2.new(0, 250, 0, 70 + (#validFiles * 45))
        f.Position = UDim2.new(0.5, -125, 0.5, -((70 + (#validFiles * 45))/2))
        f.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Instance.new("UICorner", f)

        local l = Instance.new("TextLabel", f)
        l.Size = UDim2.new(1, 0, 0, 45)
        l.Text = "SELECT PAWITUN CONFIG"
        l.TextColor3 = Color3.new(1, 1, 1)
        l.Font = Enum.Font.GothamBold
        l.BackgroundTransparency = 1

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
                writefile(syncFile, file.name) -- Simpan pilihan agar auto-run kedepannya
                sg:Destroy()
                RunConfig(file.name)
            end)
            yPos = yPos + 45
        end
    else
        warn("Gagal terhubung ke GitHub API. Pastikan folder 'Configs' ada.")
    end
end
