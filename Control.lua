-- [[ SETTINGS ]] --
local user = "PawfyProject"
local repo = "Pawitun"
local path = "Configs"
local branch = "main"
local syncFile = "current_bot_config.txt"

-- [[ SAFETY DELAY ]] --
-- Menggunakan task.wait lebih aman daripada game:IsLoaded() yang sering nyangkut
task.wait(0.5)

-- [[ FUNCTION TO RUN CONFIG ]] --
local function RunConfig(configName)
    if not configName or configName == "" then return end
    
    local rawURL = "https://raw.githubusercontent.com/"..user.."/"..repo.."/"..branch.."/"..path.."/"..configName
    
    local success, result = pcall(function() return game:HttpGet(rawURL) end)
    
    if success and result then
        -- Hapus karakter aneh (BOM/Whitespace)
        local cleanCode = result:gsub("^\239\187\191", ""):gsub("\13", "")
        
        local func, err = loadstring(cleanCode)
        if func then
            print("Executing Config: " .. configName)
            func()
        else
            warn("Loadstring Error: " .. tostring(err))
        end
    else
        warn("Failed to fetch Config from GitHub.")
    end
end

-- [[ FUNCTION SHOW MENU ]] --
local function ShowMenu()
    local apiURL = "https://api.github.com/repos/"..user.."/"..repo.."/contents/"..path
    local s_api, r_api = pcall(function() return game:HttpGet(apiURL) end)
    
    if s_api then
        local files = game:GetService("HttpService"):JSONDecode(r_api)
        local validFiles = {}
        for _, file in pairs(files) do 
            if file.name:match("%.lua$") then table.insert(validFiles, file) end 
        end

        -- Membuat GUI
        local sg = Instance.new("ScreenGui", game.CoreGui)
        sg.Name = "PawitunMenu"

        local f = Instance.new("Frame", sg)
        f.Size = UDim2.new(0, 260, 0, 70 + (#validFiles * 45))
        f.Position = UDim2.new(0.5, -130, 0.5, -100)
        f.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        f.Active = true
        f.Draggable = true -- Bisa digeser jika menutupi layar
        Instance.new("UICorner", f)

        local title = Instance.new("TextLabel", f)
        title.Size = UDim2.new(1, 0, 0, 45)
        title.Text = "PAWITUN CONFIGS"
        title.TextColor3 = Color3.new(1, 1, 1)
        title.BackgroundTransparency = 1
        title.Font = Enum.Font.GothamBold

        local yPos = 55
        for _, file in pairs(validFiles) do
            local btn = Instance.new("TextButton", f)
            btn.Size = UDim2.new(0, 220, 0, 38)
            btn.Position = UDim2.new(0.5, -110, 0, yPos)
            btn.Text = file.name:gsub("%.lua$", "")
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            btn.TextColor3 = Color3.new(1, 1, 1)
            Instance.new("UICorner", btn)

            btn.MouseButton1Click:Connect(function()
                writefile(syncFile, file.name)
                sg:Destroy()
                RunConfig(file.name)
            end)
            yPos = yPos + 45
        end
    else
        -- Jika API Gagal (Rate Limit), paksa input manual atau tampilkan error
        warn("GitHub API Rate Limited. Please wait 1 minute.")
    end
end

-- [[ START LOGIC ]] --
local hasSync = isfile(syncFile)
if hasSync then
    local content = readfile(syncFile)
    if content and content ~= "" then
        RunConfig(content)
    else
        ShowMenu()
    end
else
    ShowMenu()
end
