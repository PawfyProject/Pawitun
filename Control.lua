-- [[ SETTINGS REPO PAWITUN ]] --
local user = "PawfyProject"
local repo = "Pawitun"
local path = "Configs"
local branch = "main"

local syncFile = "current_bot_config.txt"

-- [[ FUNCTION TO RUN SELECTED CONFIG ]] --
local function RunConfig(configName)
    local rawURL = "https://raw.githubusercontent.com/"..user.."/"..repo.."/"..branch.."/"..path.."/"..configName
    
    -- Ambil isi file Raw
    local s, r = pcall(function() return game:HttpGet(rawURL) end)
    
    if s and r then 
        -- MEMBERSIHKAN STRING (PENTING!)
        -- Menghapus karakter aneh di awal file yang sering merusak script_key
        local cleanCode = r:gsub("^\239\187\191", "") 
        
        -- Beri jeda 0.5 detik agar Global Environment siap
        task.wait(0.5)
        
        local func, err = loadstring(cleanCode)
        if func then 
            func() 
        else
            warn("Error Loading Script: " .. tostring(err))
        end
    else
        warn("Gagal mengambil Raw URL: " .. rawURL)
    end
end

-- [[ MENU PEMILIH CONFIG ]] --
local function ShowMenu()
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
        f.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        Instance.new("UICorner", f)

        local yPos = 55
        for _, file in pairs(validFiles) do
            local btn = Instance.new("TextButton", f)
            btn.Size = UDim2.new(0, 210, 0, 38)
            btn.Position = UDim2.new(0.5, -105, 0, yPos)
            btn.Text = file.name:gsub("%.lua$", "")
            btn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
            btn.TextColor3 = Color3.new(1,1,1)
            Instance.new("UICorner", btn)

            btn.MouseButton1Click:Connect(function()
                writefile(syncFile, file.name)
                sg:Destroy()
                RunConfig(file.name)
            end)
            yPos = yPos + 45
        end
    end
end

-- [[ LOGIC ]] --
if isfile(syncFile) then
    RunConfig(readfile(syncFile))
else
    ShowMenu()
end
