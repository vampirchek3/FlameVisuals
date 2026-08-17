-- LocalScript: FlameVisuals Client (финальная версия, цвет частиц не сбрасывается)
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local CORRECT_KEY = "flamevisualsbest"
local KEY_FILE = "FlameVisuals_Key.json"
local DISCORD_LINK = "https://discord.gg/PHd78uaBWC"

--------------------------------------------------------------------------------
-- SCREEN GUI
--------------------------------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlameVisualsClient"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if gethui then
    screenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(screenGui)
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
else
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

--------------------------------------------------------------------------------
-- KEY SYSTEM
--------------------------------------------------------------------------------
local function getTodayDate()
    local t = os.date("*t")
    return string.format("%04d-%02d-%02d", t.year, t.month, t.day)
end

local function isKeyValidToday()
    if not (isfile and readfile) then return false end
    local success, content = pcall(readfile, KEY_FILE)
    if not success or not content then return false end
    local ok, data = pcall(function() return HttpService:JSONDecode(content) end)
    if not ok or type(data) ~= "table" then return false end
    return data.key == CORRECT_KEY and data.date == getTodayDate()
end

local function saveKeyToday()
    if not writefile then return end
    pcall(writefile, KEY_FILE, HttpService:JSONEncode({
        key = CORRECT_KEY,
        date = getTodayDate()
    }))
end

local function openDiscord()
    if setclipboard then pcall(setclipboard, DISCORD_LINK) end
    if syn and syn.open_url then pcall(syn.open_url, DISCORD_LINK)
    elseif open_url then pcall(open_url, DISCORD_LINK) end
end

local function createKeyUI(onSuccess)
    local keyFrame = Instance.new("Frame")
    keyFrame.Name = "KeySystem"
    keyFrame.Size = UDim2.new(0, 340, 0, 230)
    keyFrame.Position = UDim2.new(0.5, -170, 0.5, -115)
    keyFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    keyFrame.BorderSizePixel = 0
    keyFrame.Parent = screenGui
    Instance.new("UICorner", keyFrame).CornerRadius = UDim.new(0, 12)

    local keyStroke = Instance.new("UIStroke", keyFrame)
    keyStroke.Color = Color3.fromRGB(168, 85, 247)
    keyStroke.Thickness = 1.5

    local keyTitle = Instance.new("TextLabel", keyFrame)
    keyTitle.Size = UDim2.new(1, 0, 0, 42)
    keyTitle.Position = UDim2.new(0, 0, 0, 12)
    keyTitle.BackgroundTransparency = 1
    keyTitle.Text = "🔥 FlameVisuals"
    keyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyTitle.TextSize = 22
    keyTitle.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold)

    local keySubtitle = Instance.new("TextLabel", keyFrame)
    keySubtitle.Size = UDim2.new(1, -40, 0, 20)
    keySubtitle.Position = UDim2.new(0, 20, 0, 52)
    keySubtitle.BackgroundTransparency = 1
    keySubtitle.Text = "Введите ключ для активации"
    keySubtitle.TextColor3 = Color3.fromRGB(160, 160, 175)
    keySubtitle.TextSize = 14
    keySubtitle.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold)

    local keyInput = Instance.new("TextBox", keyFrame)
    keyInput.Size = UDim2.new(1, -40, 0, 38)
    keyInput.Position = UDim2.new(0, 20, 0, 82)
    keyInput.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    keyInput.BorderSizePixel = 0
    keyInput.PlaceholderText = "Введите ключ..."
    keyInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
    keyInput.Text = ""
    keyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyInput.TextSize = 15
    keyInput.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold)
    keyInput.ClearTextOnFocus = false
    Instance.new("UICorner", keyInput).CornerRadius = UDim.new(0, 8)
    Instance.new("UIPadding", keyInput).PaddingLeft = UDim.new(0, 12)

    local activateBtn = Instance.new("TextButton", keyFrame)
    activateBtn.Size = UDim2.new(0.5, -25, 0, 38)
    activateBtn.Position = UDim2.new(0, 20, 0, 136)
    activateBtn.BackgroundColor3 = Color3.fromRGB(168, 85, 247)
    activateBtn.Text = "Activation"
    activateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    activateBtn.TextSize = 15
    activateBtn.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold)
    Instance.new("UICorner", activateBtn).CornerRadius = UDim.new(0, 8)

    local getKeyBtn = Instance.new("TextButton", keyFrame)
    getKeyBtn.Size = UDim2.new(0.5, -25, 0, 38)
    getKeyBtn.Position = UDim2.new(0.5, 5, 0, 136)
    getKeyBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    getKeyBtn.Text = "Get Key"
    getKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    getKeyBtn.TextSize = 15
    getKeyBtn.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold)
    Instance.new("UICorner", getKeyBtn).CornerRadius = UDim.new(0, 8)

    local statusLabel = Instance.new("TextLabel", keyFrame)
    statusLabel.Size = UDim2.new(1, -40, 0, 20)
    statusLabel.Position = UDim2.new(0, 20, 0, 188)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = ""
    statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    statusLabel.TextSize = 13
    statusLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold)

    getKeyBtn.MouseButton1Click:Connect(function()
        statusLabel.TextColor3 = Color3.fromRGB(120, 220, 120)
        statusLabel.Text = "Ссылка скопирована + Discord открыт"
        openDiscord()
    end)

    local function tryActivate()
        local entered = keyInput.Text:gsub("%s+", "")
        if entered == CORRECT_KEY then
            statusLabel.TextColor3 = Color3.fromRGB(80, 255, 120)
            statusLabel.Text = "Ключ верный! Загрузка..."
            saveKeyToday()
            task.wait(0.4)
            keyFrame:Destroy()
            onSuccess()
        else
            statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            statusLabel.Text = "Неверный ключ!"
            keyInput.Text = ""
        end
    end

    activateBtn.MouseButton1Click:Connect(tryActivate)
    keyInput.FocusLost:Connect(function(enter)
        if enter then tryActivate() end
    end)
end

--------------------------------------------------------------------------------
-- MAIN SCRIPT
--------------------------------------------------------------------------------
local function startMainScript()
    local function makeDraggable(frame)
        local dragging, dragStart, startPos = false, nil, nil
        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
            end
        end)
        frame.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end

    local ESPConfig = {
        Enabled = false,
        Boxes = true,
        Names = true,
        Health = true,
        Skeleton = true,
        BoxStyle = "Normal",
        Color = Color3.fromRGB(168, 85, 247)
    }
    local TargetHUDConfig = { Enabled = false }
    local ParticleConfig = {
        Enabled = false,
        Type = "Stars",
        Color = Color3.fromRGB(255, 215, 0)  -- по умолчанию золотой
    }
    local InterfaceConfig = { AccentColor = Color3.fromRGB(168, 85, 247) }

    local function shadeColor(color, factor)
        if factor >= 0 then
            return Color3.fromRGB(
                math.floor(color.R + (1 - color.R) * factor),
                math.floor(color.G + (1 - color.G) * factor),
                math.floor(color.B + (1 - color.B) * factor)
            )
        end
        local f = -factor
        return Color3.fromRGB(
            math.floor(color.R * (1 - f)),
            math.floor(color.G * (1 - f)),
            math.floor(color.B * (1 - f))
        )
    end

    local function isLightColor(color)
        return (color.R * 0.299 + color.G * 0.587 + color.B * 0.114) > 0.6
    end

    --------------------------------------------------------------------------------
    -- ХРАНИЛИЩЕ КОНФИГОВ В ПАМЯТИ
    --------------------------------------------------------------------------------
    local configStorage = {}
    local activeParticles = {}
    local espCache = {}

    local function getConfigList()
        local names = {}
        for name, _ in pairs(configStorage) do
            table.insert(names, name)
        end
        table.sort(names)
        return names
    end

    local function saveESPConfig(name)
        if name == nil or name == "" then return false end
        local data = {
            Enabled = ESPConfig.Enabled,
            Boxes = ESPConfig.Boxes,
            Names = ESPConfig.Names,
            Health = ESPConfig.Health,
            BoxStyle = ESPConfig.BoxStyle,
            Skeleton = ESPConfig.Skeleton,
            Color = {
                R = ESPConfig.Color.R,
                G = ESPConfig.Color.G,
                B = ESPConfig.Color.B
            },
            ParticleColor = {
                R = ParticleConfig.Color.R,
                G = ParticleConfig.Color.G,
                B = ParticleConfig.Color.B
            },
            ParticleType = ParticleConfig.Type
        }
        configStorage[name] = data
        print("[Config] '" .. name .. "' сохранён в памяти")
        return true
    end

    local function loadESPConfig(name)
        local data = configStorage[name]
        if not data then
            print("[Config] Конфиг '" .. name .. "' не найден")
            return false
        end
        ESPConfig.Enabled = data.Enabled or false
        ESPConfig.Boxes = data.Boxes or true
        ESPConfig.Names = data.Names or true
        ESPConfig.Health = data.Health or true
        ESPConfig.BoxStyle = data.BoxStyle or "Normal"
        ESPConfig.Skeleton = data.Skeleton or true
        if data.Color then
            ESPConfig.Color = Color3.fromRGB(data.Color.R, data.Color.G, data.Color.B)
        end
        -- Загружаем цвет частиц
        if data.ParticleColor then
            ParticleConfig.Color = Color3.fromRGB(data.ParticleColor.R, data.ParticleColor.G, data.ParticleColor.B)
        end
        if data.ParticleType then
            ParticleConfig.Type = data.ParticleType
        end
        -- Обновляем UI
        if cardReferences and cardReferences.ESP then
            cardReferences.ESP:SetState(ESPConfig.Enabled)
        end
        -- Обновляем цвет у всех существующих частиц
        for _, entry in ipairs(activeParticles) do
            local g = entry.part:FindFirstChildOfClass("BillboardGui")
            if g then
                local l = g:FindFirstChildOfClass("TextLabel")
                if l then
                    l.TextColor3 = ParticleConfig.Color
                end
            end
        end
        -- Обновляем цвет боксов и скелетов
        for _, entry in pairs(espCache) do
            entry.Stroke.Color = ESPConfig.Color
            for _, line in ipairs(entry.Skeleton) do
                line.BackgroundColor3 = ESPConfig.Color
            end
        end
        print("[Config] '" .. name .. "' загружен (цвет частиц: " .. tostring(ParticleConfig.Color) .. ")")
        return true
    end

    local function deleteESPConfig(name)
        if configStorage[name] then
            configStorage[name] = nil
            print("[Config] '" .. name .. "' удалён")
            return true
        else
            print("[Config] Конфиг '" .. name .. "' не найден")
            return false
        end
    end

    --------------------------------------------------------------------------------
    -- TARGET HUD
    --------------------------------------------------------------------------------
    local targetHudFrame = Instance.new("Frame")
    targetHudFrame.Name = "TargetHUD"
    targetHudFrame.Size = UDim2.new(0, 240, 0, 75)
    targetHudFrame.Position = UDim2.new(0.5, -120, 0.7, 0)
    targetHudFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
    targetHudFrame.BorderSizePixel = 0
    targetHudFrame.Visible = false
    targetHudFrame.Parent = screenGui
    makeDraggable(targetHudFrame)
    Instance.new("UICorner", targetHudFrame).CornerRadius = UDim.new(0, 12)

    local thStroke = Instance.new("UIStroke", targetHudFrame)
    thStroke.Color = InterfaceConfig.AccentColor
    thStroke.Thickness = 1.5

    local avatarImg = Instance.new("ImageLabel", targetHudFrame)
    avatarImg.Size = UDim2.new(0, 42, 0, 42)
    avatarImg.Position = UDim2.new(0, 12, 0, 10)
    avatarImg.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    avatarImg.BorderSizePixel = 0
    Instance.new("UICorner", avatarImg).CornerRadius = UDim.new(0, 8)

    local targetNameLabel = Instance.new("TextLabel", targetHudFrame)
    targetNameLabel.Size = UDim2.new(1, -70, 0, 22)
    targetNameLabel.Position = UDim2.new(0, 62, 0, 8)
    targetNameLabel.BackgroundTransparency = 1
    targetNameLabel.Text = "Player"
    targetNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    targetNameLabel.TextSize = 16
    targetNameLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold)
    targetNameLabel.TextXAlignment = Enum.TextXAlignment.Left

    local targetHpLabel = Instance.new("TextLabel", targetHudFrame)
    targetHpLabel.Size = UDim2.new(1, -70, 0, 18)
    targetHpLabel.Position = UDim2.new(0, 62, 0, 30)
    targetHpLabel.BackgroundTransparency = 1
    targetHpLabel.Text = "HP / 100.0"
    targetHpLabel.TextColor3 = Color3.fromRGB(170, 170, 185)
    targetHpLabel.TextSize = 13
    targetHpLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold)
    targetHpLabel.TextXAlignment = Enum.TextXAlignment.Left

    local healthBarBg = Instance.new("Frame", targetHudFrame)
    healthBarBg.Size = UDim2.new(1, -24, 0, 8)
    healthBarBg.Position = UDim2.new(0, 12, 0, 58)
    healthBarBg.BackgroundColor3 = Color3.fromRGB(25, 22, 35)
    healthBarBg.BorderSizePixel = 0
    Instance.new("UICorner", healthBarBg).CornerRadius = UDim.new(1, 0)

    local healthBarFill = Instance.new("Frame", healthBarBg)
    healthBarFill.Size = UDim2.new(1, 0, 1, 0)
    healthBarFill.BackgroundColor3 = InterfaceConfig.AccentColor
    healthBarFill.BorderSizePixel = 0
    Instance.new("UICorner", healthBarFill).CornerRadius = UDim.new(1, 0)

    --------------------------------------------------------------------------------
    -- WATERMARK
    --------------------------------------------------------------------------------
    local watermarkFrame = Instance.new("Frame")
    watermarkFrame.Name = "WatermarkFrame"
    watermarkFrame.Position = UDim2.new(0, 18, 0, 18)
    watermarkFrame.Size = UDim2.new(0, 0, 0, 32)
    watermarkFrame.AutomaticSize = Enum.AutomaticSize.X
    watermarkFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
    watermarkFrame.BackgroundTransparency = 0.15
    watermarkFrame.BorderSizePixel = 0
    watermarkFrame.Visible = true
    watermarkFrame.Parent = screenGui
    makeDraggable(watermarkFrame)
    Instance.new("UICorner", watermarkFrame).CornerRadius = UDim.new(0, 16)

    local wmStroke = Instance.new("UIStroke", watermarkFrame)
    wmStroke.Color = InterfaceConfig.AccentColor
    wmStroke.Thickness = 1
    wmStroke.Transparency = 0.4

    local wmLayout = Instance.new("UIListLayout", watermarkFrame)
    wmLayout.FillDirection = Enum.FillDirection.Horizontal
    wmLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    wmLayout.Padding = UDim.new(0, 8)

    local wmPadding = Instance.new("UIPadding", watermarkFrame)
    wmPadding.PaddingLeft = UDim.new(0, 12)
    wmPadding.PaddingRight = UDim.new(0, 14)

    local wmIcon = Instance.new("TextLabel", watermarkFrame)
    wmIcon.Size = UDim2.new(0, 16, 0, 16)
    wmIcon.BackgroundTransparency = 1
    wmIcon.Text = "🔥"
    wmIcon.TextSize = 14

    local wmBrand = Instance.new("TextLabel", watermarkFrame)
    wmBrand.AutomaticSize = Enum.AutomaticSize.X
    wmBrand.Size = UDim2.new(0, 0, 1, 0)
    wmBrand.BackgroundTransparency = 1
    wmBrand.Text = "FlameVisuals"
    wmBrand.TextColor3 = Color3.fromRGB(255, 255, 255)
    wmBrand.TextSize = 14
    wmBrand.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold)

    local wmStats = Instance.new("TextLabel", watermarkFrame)
    wmStats.AutomaticSize = Enum.AutomaticSize.X
    wmStats.Size = UDim2.new(0, 0, 1, 0)
    wmStats.BackgroundTransparency = 1
    wmStats.TextColor3 = Color3.fromRGB(160, 160, 175)
    wmStats.TextSize = 14
    wmStats.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold)

    local lastUpdate, frameCount, fps = tick(), 0, 0
    RunService.RenderStepped:Connect(function()
        frameCount += 1
        local now = tick()
        if now - lastUpdate >= 0.5 then
            fps = math.floor(frameCount / (now - lastUpdate))
            frameCount = 0
            lastUpdate = now
            local ping = 0
            pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
            wmStats.Text = string.format("/  %s  /  %d ms  /  %d FPS", LocalPlayer.Name, ping, fps)
        end
    end)

    --------------------------------------------------------------------------------
    -- MAIN MENU
    --------------------------------------------------------------------------------
    local mainGui = Instance.new("Frame")
    mainGui.Name = "MainMenu"
    mainGui.Size = UDim2.new(0, 750, 0, 480)
    mainGui.Position = UDim2.new(0.5, -375, 0.5, -240)
    mainGui.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    mainGui.BorderSizePixel = 0
    mainGui.Parent = screenGui
    makeDraggable(mainGui)
    Instance.new("UICorner", mainGui).CornerRadius = UDim.new(0, 12)

    local sidebar = Instance.new("Frame", mainGui)
    sidebar.Size = UDim2.new(0, 180, 1, 0)
    sidebar.BackgroundColor3 = Color3.fromRGB(11, 11, 14)
    sidebar.BorderSizePixel = 0
    Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 12)

    local logoContainer = Instance.new("Frame", sidebar)
    logoContainer.Size = UDim2.new(1, -20, 0, 50)
    logoContainer.Position = UDim2.new(0, 12, 0, 10)
    logoContainer.BackgroundTransparency = 1

    local logoIcon = Instance.new("TextLabel", logoContainer)
    logoIcon.Size = UDim2.new(0, 24, 1, 0)
    logoIcon.BackgroundTransparency = 1
    logoIcon.Text = "🔥"
    logoIcon.TextSize = 18

    local logoText = Instance.new("TextLabel", logoContainer)
    logoText.Size = UDim2.new(1, -30, 1, 0)
    logoText.Position = UDim2.new(0, 28, 0, 0)
    logoText.BackgroundTransparency = 1
    logoText.Text = "FlameVisuals"
    logoText.TextColor3 = Color3.fromRGB(255, 255, 255)
    logoText.TextSize = 17
    logoText.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold)
    logoText.TextXAlignment = Enum.TextXAlignment.Left

    local contentArea = Instance.new("Frame", mainGui)
    contentArea.Size = UDim2.new(1, -190, 1, -20)
    contentArea.Position = UDim2.new(0, 190, 0, 10)
    contentArea.BackgroundTransparency = 1

    local headerText = Instance.new("TextLabel", contentArea)
    headerText.Size = UDim2.new(1, 0, 0, 40)
    headerText.BackgroundTransparency = 1
    headerText.Text = "Visuals"
    headerText.TextColor3 = Color3.fromRGB(255, 255, 255)
    headerText.TextSize = 20
    headerText.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold)
    headerText.TextXAlignment = Enum.TextXAlignment.Left

    local tabs, tabButtons = {}, {}
    local categories = {"Visuals", "HUD", "Utilities", "Configs"}

    local navContainer = Instance.new("Frame", sidebar)
    navContainer.Size = UDim2.new(1, -20, 0, 220)
    navContainer.Position = UDim2.new(0, 10, 0, 65)
    navContainer.BackgroundTransparency = 1
    Instance.new("UIListLayout", navContainer).Padding = UDim.new(0, 6)

    local function createTabContent(name)
        local scroll = Instance.new("ScrollingFrame", contentArea)
        scroll.Name = name .. "Tab"
        scroll.Size = UDim2.new(1, -10, 1, -50)
        scroll.Position = UDim2.new(0, 0, 0, 45)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 3
        scroll.ScrollBarImageColor3 = InterfaceConfig.AccentColor
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scroll.Visible = false
        if name ~= "Configs" then
            local grid = Instance.new("UIGridLayout", scroll)
            grid.CellSize = UDim2.new(0, 260, 0, 70)
            grid.CellPadding = UDim2.new(0, 15, 0, 15)
        else
            local padding = Instance.new("UIPadding", scroll)
            padding.PaddingTop = UDim.new(0, 12)
            padding.PaddingBottom = UDim.new(0, 12)
            padding.PaddingLeft = UDim.new(0, 12)
            padding.PaddingRight = UDim.new(0, 12)
            local layout = Instance.new("UIListLayout", scroll)
            layout.Padding = UDim.new(0, 12)
            layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            layout.SortOrder = Enum.SortOrder.LayoutOrder
            scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        end
        tabs[name] = scroll
        return scroll
    end

    local function switchTab(name)
        headerText.Text = name
        for n, frame in pairs(tabs) do frame.Visible = (n == name) end
        for n, btn in pairs(tabButtons) do
            local selected = (n == name)
            btn.BackgroundColor3 = selected and InterfaceConfig.AccentColor or Color3.fromRGB(0, 0, 0)
            btn.BackgroundTransparency = selected and 0 or 1
            local label = btn:FindFirstChildOfClass("TextLabel")
            if label then
                label.TextColor3 = selected and (isLightColor(InterfaceConfig.AccentColor) and Color3.fromRGB(20, 20, 30) or Color3.fromRGB(255, 255, 255)) or Color3.fromRGB(255, 255, 255)
            end
            local grad = btn:FindFirstChildOfClass("UIGradient")
            if grad then
                grad.Color = ColorSequence.new(
                    InterfaceConfig.AccentColor,
                    selected and shadeColor(InterfaceConfig.AccentColor, -0.5) or Color3.fromRGB(0, 0, 0)
                )
            end
        end
        if name == "Configs" then
            if _G.refreshConfigsList then
                _G.refreshConfigsList()
            end
        end
    end

    for _, name in ipairs(categories) do
        createTabContent(name)
        local btn = Instance.new("TextButton", navContainer)
        btn.Size = UDim2.new(1, 0, 0, 36)
        btn.Text = ""
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        local grad = Instance.new("UIGradient", btn)
        grad.Rotation = 45
        local btnText = Instance.new("TextLabel", btn)
        btnText.Size = UDim2.new(1, 0, 1, 0)
        btnText.BackgroundTransparency = 1
        btnText.Text = name
        btnText.TextColor3 = Color3.fromRGB(255, 255, 255)
        btnText.TextSize = 14
        btnText.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold)
        btnText.TextXAlignment = Enum.TextXAlignment.Left
        Instance.new("UIPadding", btnText).PaddingLeft = UDim.new(0, 12)
        tabButtons[name] = btn
        btn.MouseButton1Click:Connect(function() switchTab(name) end)
    end
    switchTab("Visuals")

    --------------------------------------------------------------------------------
    -- SETTINGS MODAL
    --------------------------------------------------------------------------------
    local settingsModal = Instance.new("Frame")
    settingsModal.Name = "SettingsModal"
    settingsModal.Size = UDim2.new(0, 270, 0, 0)
    settingsModal.AutomaticSize = Enum.AutomaticSize.Y
    settingsModal.BackgroundColor3 = Color3.fromRGB(13, 13, 18)
    settingsModal.BorderSizePixel = 0
    settingsModal.Visible = false
    settingsModal.ZIndex = 100
    settingsModal.BackgroundTransparency = 1
    settingsModal.Parent = screenGui
    Instance.new("UICorner", settingsModal).CornerRadius = UDim.new(0, 14)

    local modalStroke = Instance.new("UIStroke", settingsModal)
    modalStroke.Color = Color3.fromRGB(25, 25, 35)
    modalStroke.Thickness = 1
    modalStroke.Transparency = 1

    local modalPadding = Instance.new("UIPadding", settingsModal)
    modalPadding.PaddingTop = UDim.new(0, 12)
    modalPadding.PaddingBottom = UDim.new(0, 12)
    modalPadding.PaddingLeft = UDim.new(0, 14)
    modalPadding.PaddingRight = UDim.new(0, 14)
    Instance.new("UIListLayout", settingsModal).Padding = UDim.new(0, 8)

    local activeDropdown = nil

    local function openSettingsModal(x, y)
        if activeDropdown then activeDropdown() end
        settingsModal.Position = UDim2.new(0, x, 0, y)
        settingsModal.Visible = true
        settingsModal.BackgroundTransparency = 1
        modalStroke.Transparency = 1
        TweenService:Create(settingsModal, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
        TweenService:Create(modalStroke, TweenInfo.new(0.22), {Transparency = 0}):Play()
    end

    local function closeSettingsModal()
        if activeDropdown then activeDropdown() end
        TweenService:Create(settingsModal, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
        TweenService:Create(modalStroke, TweenInfo.new(0.18), {Transparency = 1}):Play()
        task.delay(0.19, function() settingsModal.Visible = false end)
    end

    UserInputService.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2) and settingsModal.Visible then
            local mousePos = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
            local mPos, mSize = settingsModal.AbsolutePosition, settingsModal.AbsoluteSize
            if mousePos.X < mPos.X or mousePos.X > mPos.X + mSize.X or mousePos.Y < mPos.Y or mousePos.Y > mPos.Y + mSize.Y then
                closeSettingsModal()
            end
        end
    end)

    local function updateInterfaceColor(newColor)
        InterfaceConfig.AccentColor = newColor
        wmStroke.Color = newColor
        thStroke.Color = newColor
        healthBarFill.BackgroundColor3 = newColor
        for _, btn in pairs(tabButtons) do
            if btn.BackgroundTransparency == 0 then
                btn.BackgroundColor3 = newColor
                local label = btn:FindFirstChildOfClass("TextLabel")
                if label then
                    label.TextColor3 = isLightColor(newColor) and Color3.fromRGB(20, 20, 30) or Color3.fromRGB(255, 255, 255)
                end
                local grad = btn:FindFirstChildOfClass("UIGradient")
                if grad then
                    grad.Color = ColorSequence.new(newColor, shadeColor(newColor, -0.5))
                end
            end
        end
    end

    --------------------------------------------------------------------------------
    -- MODULE CARDS
    --------------------------------------------------------------------------------
    local cardReferences = {}

    local function createModuleCard(parentTab, title, description, defaultValue, onToggle, onRightClick)
        local card = Instance.new("TextButton", parentTab)
        card.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
        card.BorderSizePixel = 0
        card.Text = ""
        card.AutoButtonColor = false
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

        local cardTitle = Instance.new("TextLabel", card)
        cardTitle.Size = UDim2.new(1, -60, 0, 25)
        cardTitle.Position = UDim2.new(0, 12, 0, 10)
        cardTitle.BackgroundTransparency = 1
        cardTitle.Text = title
        cardTitle.TextColor3 = Color3.fromRGB(240, 240, 245)
        cardTitle.TextSize = 15
        cardTitle.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold)
        cardTitle.TextXAlignment = Enum.TextXAlignment.Left

        local cardDesc = Instance.new("TextLabel", card)
        cardDesc.Size = UDim2.new(1, -20, 0, 25)
        cardDesc.Position = UDim2.new(0, 12, 0, 35)
        cardDesc.BackgroundTransparency = 1
        cardDesc.Text = description
        cardDesc.TextColor3 = Color3.fromRGB(120, 120, 135)
        cardDesc.TextSize = 12
        cardDesc.TextXAlignment = Enum.TextXAlignment.Left

        local toggleBtn = Instance.new("TextButton", card)
        toggleBtn.Size = UDim2.new(0, 40, 0, 20)
        toggleBtn.Position = UDim2.new(1, -50, 0, 12)
        toggleBtn.BackgroundColor3 = defaultValue and InterfaceConfig.AccentColor or Color3.fromRGB(45, 45, 55)
        toggleBtn.Text = ""
        toggleBtn.AutoButtonColor = false
        Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 10)

        local circle = Instance.new("Frame", toggleBtn)
        circle.Size = UDim2.new(0, 14, 0, 14)
        circle.Position = defaultValue and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        circle.BorderSizePixel = 0
        Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

        local state = defaultValue
        local function setVisualState(newState)
            state = newState
            TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = state and InterfaceConfig.AccentColor or Color3.fromRGB(45, 45, 55)}):Play()
            TweenService:Create(circle, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)}):Play()
            if onToggle then onToggle(state) end
        end

        toggleBtn.MouseButton1Click:Connect(function() setVisualState(not state) end)
        card.MouseButton2Click:Connect(function()
            if onRightClick then
                local mousePos = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
                onRightClick()
                openSettingsModal(mousePos.X + 5, mousePos.Y - 10)
            end
        end)

        return { SetState = setVisualState, GetState = function() return state end }
    end

    -- Анимированный Dropdown (абсолютное позиционирование поверх всего)
    local function createAnimatedDropdown(parent, title, options, currentValue, onSelect)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 36)
        container.BackgroundTransparency = 1
        container.ZIndex = 200
        container.Parent = parent

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.40, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = title
        label.TextColor3 = Color3.fromRGB(200, 200, 210)
        label.TextSize = 13
        label.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.ZIndex = 201
        label.Parent = container

        local mainBtn = Instance.new("TextButton")
        mainBtn.Size = UDim2.new(0.58, 0, 0, 28)
        mainBtn.Position = UDim2.new(0.42, 0, 0, 4)
        mainBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
        mainBtn.Text = "  " .. currentValue
        mainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        mainBtn.TextSize = 13
        mainBtn.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold)
        mainBtn.TextXAlignment = Enum.TextXAlignment.Left
        mainBtn.AutoButtonColor = false
        mainBtn.ZIndex = 202
        mainBtn.Parent = container
        Instance.new("UICorner", mainBtn).CornerRadius = UDim.new(0, 8)

        local mainStroke = Instance.new("UIStroke", mainBtn)
        mainStroke.Color = Color3.fromRGB(50, 50, 60)
        mainStroke.Thickness = 1

        local arrow = Instance.new("TextLabel")
        arrow.Size = UDim2.new(0, 20, 1, 0)
        arrow.Position = UDim2.new(1, -22, 0, 0)
        arrow.BackgroundTransparency = 1
        arrow.Text = "▼"
        arrow.TextColor3 = Color3.fromRGB(160, 160, 170)
        arrow.TextSize = 11
        arrow.ZIndex = 203
        arrow.Parent = mainBtn

        local dropFrame = Instance.new("Frame")
        dropFrame.Size = UDim2.new(0, 0, 0, 0)
        dropFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
        dropFrame.BorderSizePixel = 0
        dropFrame.ClipsDescendants = false
        dropFrame.ZIndex = 999
        dropFrame.Visible = false
        dropFrame.Parent = screenGui
        Instance.new("UICorner", dropFrame).CornerRadius = UDim.new(0, 8)

        local dropStroke = Instance.new("UIStroke", dropFrame)
        dropStroke.Color = Color3.fromRGB(50, 50, 60)
        dropStroke.Thickness = 1

        local layout = Instance.new("UIListLayout", dropFrame)
        layout.SortOrder = Enum.SortOrder.LayoutOrder

        local isOpen = false
        local function closeDropdown()
            if not isOpen then return end
            isOpen = false
            arrow.Text = "▼"
            activeDropdown = nil
            TweenService:Create(dropFrame, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0)
            }):Play()
            task.delay(0.17, function()
                if not isOpen then dropFrame.Visible = false end
            end)
        end

        for index, opt in ipairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 30)
            optBtn.LayoutOrder = index
            optBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
            optBtn.BackgroundTransparency = 1
            optBtn.Text = "  " .. opt
            optBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
            optBtn.TextSize = 13
            optBtn.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold)
            optBtn.TextXAlignment = Enum.TextXAlignment.Left
            optBtn.AutoButtonColor = false
            optBtn.ZIndex = 501
            optBtn.Parent = dropFrame

            optBtn.MouseEnter:Connect(function()
                TweenService:Create(optBtn, TweenInfo.new(0.12), {BackgroundTransparency = 0}):Play()
            end)
            optBtn.MouseLeave:Connect(function()
                TweenService:Create(optBtn, TweenInfo.new(0.12), {BackgroundTransparency = 1}):Play()
            end)

            optBtn.MouseButton1Click:Connect(function()
                mainBtn.Text = "  " .. opt
                if onSelect then onSelect(opt) end
                closeDropdown()
            end)
        end

        mainBtn.MouseButton1Click:Connect(function()
            if activeDropdown and activeDropdown ~= closeDropdown then
                activeDropdown()
            end

            isOpen = not isOpen
            if isOpen then
                activeDropdown = closeDropdown
                dropFrame.Visible = true
                dropFrame.Size = UDim2.new(0, 0, 0, 0)

                local btnAbsPos = mainBtn.AbsolutePosition
                local btnAbsSize = mainBtn.AbsoluteSize
                local screenSize = Camera.ViewportSize
                local listHeight = #options * 30
                local listWidth = btnAbsSize.X + 12

                local openUp = false
                local spaceBelow = screenSize.Y - (btnAbsPos.Y + btnAbsSize.Y) - 10
                local spaceAbove = btnAbsPos.Y - 10

                if spaceBelow < listHeight and spaceAbove >= listHeight then
                    openUp = true
                end

                local x = btnAbsPos.X - 6
                local y = openUp and (btnAbsPos.Y - listHeight) or (btnAbsPos.Y + btnAbsSize.Y)

                if x + listWidth > screenSize.X then
                    x = screenSize.X - listWidth - 6
                end
                if x < 0 then
                    x = 6
                end

                dropFrame.Position = UDim2.new(0, x, 0, y)
                dropFrame.Size = UDim2.new(0, listWidth, 0, listHeight)

                arrow.Text = openUp and "▲" or "▲"

                dropFrame.Size = UDim2.new(0, listWidth, 0, 0)
                TweenService:Create(dropFrame, TweenInfo.new(0.20, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, listWidth, 0, listHeight)
                }):Play()
            else
                closeDropdown()
            end
        end)
    end

    --------------------------------------------------------------------------------
    -- VISUALS
    --------------------------------------------------------------------------------
    cardReferences.ESP = createModuleCard(tabs["Visuals"], "ESP", "ПКМ - настройки", ESPConfig.Enabled, function(v)
        ESPConfig.Enabled = v
    end, function()
        for _, child in ipairs(settingsModal:GetChildren()) do
            if not (child:IsA("UIListLayout") or child:IsA("UICorner") or child:IsA("UIStroke") or child:IsA("UIPadding")) then
                child:Destroy()
            end
        end

        local header = Instance.new("TextLabel", settingsModal)
        header.Size = UDim2.new(1, 0, 0, 18)
        header.BackgroundTransparency = 1
        header.Text = "Настройки ESP"
        header.TextColor3 = Color3.fromRGB(140, 140, 160)
        header.TextSize = 12
        header.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold)
        header.ZIndex = 101

        local function addToggle(name, current, callback)
            local row = Instance.new("Frame", settingsModal)
            row.Size = UDim2.new(1, 0, 0, 28)
            row.BackgroundTransparency = 1
            row.ZIndex = 101

            local label = Instance.new("TextLabel", row)
            label.Size = UDim2.new(1, -50, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = name
            label.TextColor3 = Color3.fromRGB(220, 220, 230)
            label.TextSize = 13
            label.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold)
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.ZIndex = 101

            local btn = Instance.new("TextButton", row)
            btn.Size = UDim2.new(0, 38, 0, 20)
            btn.Position = UDim2.new(1, -38, 0.5, -10)
            btn.BackgroundColor3 = current and InterfaceConfig.AccentColor or Color3.fromRGB(35, 35, 45)
            btn.Text = ""
            btn.ZIndex = 101
            Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

            local circle = Instance.new("Frame", btn)
            circle.Size = UDim2.new(0, 14, 0, 14)
            circle.Position = current and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
            circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            circle.ZIndex = 102
            Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

            local state = current
            btn.MouseButton1Click:Connect(function()
                state = not state
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = state and InterfaceConfig.AccentColor or Color3.fromRGB(35, 35, 45)}):Play()
                TweenService:Create(circle, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)}):Play()
                callback(state)
            end)
        end

        addToggle("Боксы", ESPConfig.Boxes, function(v) ESPConfig.Boxes = v end)
        addToggle("Имена", ESPConfig.Names, function(v) ESPConfig.Names = v end)
        addToggle("Здоровье", ESPConfig.Health, function(v) ESPConfig.Health = v end)
        addToggle("Скелет", ESPConfig.Skeleton, function(v) ESPConfig.Skeleton = v end)

        createAnimatedDropdown(settingsModal, "Стиль бокса", {"Normal", "Rounded", "Thick"}, ESPConfig.BoxStyle, function(val)
            ESPConfig.BoxStyle = val
        end)
    end)

    -- Глобальный список активных частиц
    cardReferences.WorldParticles = createModuleCard(tabs["Visuals"], "World Particles", "ПКМ - настройки частиц", ParticleConfig.Enabled, function(v)
        ParticleConfig.Enabled = v
    end, function()
        for _, child in ipairs(settingsModal:GetChildren()) do
            if not (child:IsA("UIListLayout") or child:IsA("UICorner") or child:IsA("UIStroke") or child:IsA("UIPadding")) then
                child:Destroy()
            end
        end

        local header = Instance.new("TextLabel", settingsModal)
        header.Size = UDim2.new(1, 0, 0, 18)
        header.BackgroundTransparency = 1
        header.Text = "Настройки частиц"
        header.TextColor3 = Color3.fromRGB(140, 140, 160)
        header.TextSize = 12
        header.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold)
        header.ZIndex = 101

        local typeDisplay = ParticleConfig.Type == "Dollars" and "💵 Dollars" or ParticleConfig.Type == "Stars" and "⭐ Stars" or "❤️ Hearts"

        createAnimatedDropdown(settingsModal, "Тип частиц", {"💵 Dollars", "⭐ Stars", "❤️ Hearts"}, typeDisplay, function(val)
            if val:find("Dollars") then ParticleConfig.Type = "Dollars"
            elseif val:find("Stars") then ParticleConfig.Type = "Stars"
            else ParticleConfig.Type = "Hearts" end
        end)

        -- Дропдаун для цвета с исправленным обновлением
        createAnimatedDropdown(settingsModal, "Цвет", {"Золотой", "Фиолетовый", "Красный", "Голубой", "Зелёный", "Белый"}, "Золотой", function(val)
            local map = {
                ["Золотой"] = Color3.fromRGB(255, 215, 0),
                ["Фиолетовый"] = Color3.fromRGB(168, 85, 247),
                ["Красный"] = Color3.fromRGB(255, 80, 80),
                ["Голубой"] = Color3.fromRGB(80, 180, 255),
                ["Зелёный"] = Color3.fromRGB(80, 255, 120),
                ["Белый"] = Color3.fromRGB(255, 255, 255)
            }
            local newColor = map[val] or Color3.fromRGB(255, 215, 0)
            ParticleConfig.Color = newColor
            -- Обновляем все существующие частицы
            for _, entry in ipairs(activeParticles) do
                local g = entry.part:FindFirstChildOfClass("BillboardGui")
                if g then
                    local l = g:FindFirstChildOfClass("TextLabel")
                    if l then
                        l.TextColor3 = newColor
                    end
                end
            end
            print("[Цвет] Изменён на " .. val .. " (" .. tostring(newColor) .. ")")
        end)
    end)

    -- HUD
    cardReferences.Watermark = createModuleCard(tabs["HUD"], "Watermark", "Верхний HUD", true, function(v) watermarkFrame.Visible = v end, nil)
    cardReferences.TargetHUD = createModuleCard(tabs["HUD"], "Target HUD", "Инфо о цели", false, function(v)
        TargetHUDConfig.Enabled = v
        if not v then targetHudFrame.Visible = false end
    end, nil)

    cardReferences.InterfaceColor = createModuleCard(tabs["HUD"], "Interface Color", "ПКМ - цвет интерфейса", true, function() end, function()
        for _, child in ipairs(settingsModal:GetChildren()) do
            if not (child:IsA("UIListLayout") or child:IsA("UICorner") or child:IsA("UIStroke") or child:IsA("UIPadding")) then child:Destroy() end
        end
        local header = Instance.new("TextLabel", settingsModal)
        header.Size = UDim2.new(1, 0, 0, 18)
        header.BackgroundTransparency = 1
        header.Text = "Цвет интерфейса"
        header.TextColor3 = Color3.fromRGB(140, 140, 160)
        header.TextSize = 12
        header.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold)
        header.ZIndex = 101

        local colors = {
            {"Фиолетовый", Color3.fromRGB(168, 85, 247)},
            {"Синий", Color3.fromRGB(59, 130, 246)},
            {"Голубой", Color3.fromRGB(34, 211, 238)},
            {"Зелёный", Color3.fromRGB(34, 197, 94)},
            {"Жёлтый", Color3.fromRGB(234, 179, 8)},
            {"Оранжевый", Color3.fromRGB(249, 115, 22)},
            {"Красный", Color3.fromRGB(239, 68, 68)},
            {"Розовый", Color3.fromRGB(236, 72, 153)},
            {"Белый", Color3.fromRGB(255, 255, 255)}
        }
        local colorButtons = {}
        for _, item in ipairs(colors) do
            local btn = Instance.new("TextButton", settingsModal)
            btn.Size = UDim2.new(1, 0, 0, 32)
            btn.BackgroundColor3 = (InterfaceConfig.AccentColor == item[2]) and item[2] or Color3.fromRGB(30, 30, 38)
            btn.Text = item[1]
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextSize = 14
            btn.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold)
            btn.ZIndex = 101
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
            local st = Instance.new("UIStroke", btn)
            st.Color = item[2]
            st.Thickness = 1.3
            st.Transparency = (InterfaceConfig.AccentColor == item[2]) and 0 or 0.6
            colorButtons[item[1]] = {btn = btn, stroke = st, color = item[2]}
            btn.MouseButton1Click:Connect(function()
                updateInterfaceColor(item[2])
                for _, data in pairs(colorButtons) do
                    local sel = data.color == item[2]
                    TweenService:Create(data.btn, TweenInfo.new(0.18), {BackgroundColor3 = sel and item[2] or Color3.fromRGB(30, 30, 38)}):Play()
                    TweenService:Create(data.stroke, TweenInfo.new(0.18), {Transparency = sel and 0 or 0.6}):Play()
                end
            end)
        end
    end)

    -- UTILITIES
    local origAmbient = Lighting.Ambient
    local origOutdoor = Lighting.OutdoorAmbient
    local origFogEnd = Lighting.FogEnd
    local origFogStart = Lighting.FogStart
    local origAtmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
    if origAtmosphere then origAtmosphere:SetAttribute("OriginalDensity", origAtmosphere.Density) end

    cardReferences.Fullbright = createModuleCard(tabs["Utilities"], "Fullbright", "Макс. яркость", false, function(v)
        if v then
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        else
            Lighting.Ambient = origAmbient
            Lighting.OutdoorAmbient = origOutdoor
        end
    end, nil)

    cardReferences.NoFog = createModuleCard(tabs["Utilities"], "No Fog", "Убирает туман", false, function(v)
        if v then
            Lighting.FogEnd = 100000
            Lighting.FogStart = 0
            if origAtmosphere then origAtmosphere.Density = 0 end
        else
            Lighting.FogEnd = origFogEnd
            Lighting.FogStart = origFogStart
            if origAtmosphere then origAtmosphere.Density = origAtmosphere:GetAttribute("OriginalDensity") or 0.3 end
        end
    end, nil)

    cardReferences.Rejoin = createModuleCard(tabs["Utilities"], "Rejoin", "Перезайти", false, function(v)
        if v then TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end
    end, nil)

    cardReferences.ServerHop = createModuleCard(tabs["Utilities"], "Server Hop", "Сменить сервер", false, function(v)
        if v then
            pcall(function()
                local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/0?sortOrder=Asc&limit=100")).data
                for _, server in ipairs(servers) do
                    if server.playing < server.maxPlayers and server.id ~= game.JobId then
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                        break
                    end
                end
            end)
        end
    end, nil)

    --------------------------------------------------------------------------------
    -- CONFIGS (в памяти)
    --------------------------------------------------------------------------------
    local configsTab = tabs["Configs"]
    if configsTab then
        local topFrame = Instance.new("Frame", configsTab)
        topFrame.Size = UDim2.new(1, 0, 0, 50)
        topFrame.BackgroundTransparency = 1

        local nameBox = Instance.new("TextBox", topFrame)
        nameBox.Size = UDim2.new(0.7, -10, 0, 38)
        nameBox.Position = UDim2.new(0, 0, 0.5, -19)
        nameBox.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
        nameBox.BorderSizePixel = 0
        nameBox.PlaceholderText = "Имя конфига..."
        nameBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
        nameBox.Text = ""
        nameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameBox.TextSize = 14
        nameBox.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold)
        Instance.new("UICorner", nameBox).CornerRadius = UDim.new(0, 8)
        Instance.new("UIPadding", nameBox).PaddingLeft = UDim.new(0, 12)

        local createBtn = Instance.new("TextButton", topFrame)
        createBtn.Size = UDim2.new(0.3, 0, 0, 38)
        createBtn.Position = UDim2.new(0.7, 5, 0.5, -19)
        createBtn.BackgroundColor3 = InterfaceConfig.AccentColor
        createBtn.Text = "Создать"
        createBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        createBtn.TextSize = 15
        createBtn.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold)
        Instance.new("UICorner", createBtn).CornerRadius = UDim.new(0, 8)

        local listFrame = Instance.new("ScrollingFrame", configsTab)
        listFrame.Size = UDim2.new(1, 0, 1, -60)
        listFrame.Position = UDim2.new(0, 0, 0, 55)
        listFrame.BackgroundTransparency = 1
        listFrame.BorderSizePixel = 0
        listFrame.ScrollBarThickness = 3
        listFrame.ScrollBarImageColor3 = InterfaceConfig.AccentColor
        listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        local listLayout = Instance.new("UIListLayout", listFrame)
        listLayout.Padding = UDim.new(0, 8)
        listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder

        local function refreshConfigsList()
            for _, child in ipairs(listFrame:GetChildren()) do
                if child ~= listLayout then
                    child:Destroy()
                end
            end
            local configs = getConfigList()
            if #configs == 0 then
                local empty = Instance.new("TextLabel", listFrame)
                empty.Size = UDim2.new(1, 0, 0, 30)
                empty.BackgroundTransparency = 1
                empty.Text = "Нет сохранённых конфигов"
                empty.TextColor3 = Color3.fromRGB(120, 120, 140)
                empty.TextSize = 14
                empty.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold)
            end
            for _, name in ipairs(configs) do
                local row = Instance.new("Frame", listFrame)
                row.Size = UDim2.new(0.95, 0, 0, 44)
                row.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
                row.BorderSizePixel = 0
                Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

                local nameLabel = Instance.new("TextLabel", row)
                nameLabel.Size = UDim2.new(0.5, -10, 1, 0)
                nameLabel.Position = UDim2.new(0, 12, 0, 0)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Text = name
                nameLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
                nameLabel.TextSize = 15
                nameLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold)
                nameLabel.TextXAlignment = Enum.TextXAlignment.Left

                local btnLoad = Instance.new("TextButton", row)
                btnLoad.Size = UDim2.new(0, 60, 0, 32)
                btnLoad.Position = UDim2.new(0.5, 5, 0.5, -16)
                btnLoad.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                btnLoad.Text = "Загрузить"
                btnLoad.TextColor3 = Color3.fromRGB(255, 255, 255)
                btnLoad.TextSize = 12
                btnLoad.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold)
                Instance.new("UICorner", btnLoad).CornerRadius = UDim.new(0, 6)
                btnLoad.MouseButton1Click:Connect(function()
                    loadESPConfig(name)
                    refreshConfigsList()
                end)

                local btnSave = Instance.new("TextButton", row)
                btnSave.Size = UDim2.new(0, 60, 0, 32)
                btnSave.Position = UDim2.new(0.5, 70, 0.5, -16)
                btnSave.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                btnSave.Text = "Сохранить"
                btnSave.TextColor3 = Color3.fromRGB(255, 255, 255)
                btnSave.TextSize = 12
                btnSave.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold)
                Instance.new("UICorner", btnSave).CornerRadius = UDim.new(0, 6)
                btnSave.MouseButton1Click:Connect(function()
                    saveESPConfig(name)
                end)

                local btnDelete = Instance.new("TextButton", row)
                btnDelete.Size = UDim2.new(0, 60, 0, 32)
                btnDelete.Position = UDim2.new(0.5, 135, 0.5, -16)
                btnDelete.BackgroundColor3 = Color3.fromRGB(55, 30, 30)
                btnDelete.Text = "Удалить"
                btnDelete.TextColor3 = Color3.fromRGB(255, 255, 255)
                btnDelete.TextSize = 12
                btnDelete.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold)
                Instance.new("UICorner", btnDelete).CornerRadius = UDim.new(0, 6)
                btnDelete.MouseButton1Click:Connect(function()
                    deleteESPConfig(name)
                    refreshConfigsList()
                end)
            end
        end

        createBtn.MouseButton1Click:Connect(function()
            local newName = nameBox.Text:gsub("^%s*(.-)%s*$", "%1")
            if newName == "" then
                warn("[Config] Имя пустое")
                return
            end
            if configStorage[newName] then
                warn("[Config] Конфиг с именем '" .. newName .. "' уже существует")
                return
            end
            local ok = saveESPConfig(newName)
            if ok then
                nameBox.Text = ""
                refreshConfigsList()
                print("[Config] Конфиг '" .. newName .. "' создан")
            end
        end)

        _G.refreshConfigsList = refreshConfigsList
        refreshConfigsList()
    end

    --------------------------------------------------------------------------------
    -- PARTICLES + ESP + TARGET HUD + HOTKEYS
    --------------------------------------------------------------------------------
    local particleFolder = Instance.new("Folder", workspace)
    particleFolder.Name = "FlameParticles"
    local symbols = {Dollars = "💵", Stars = "⭐", Hearts = "❤️"}

    task.spawn(function()
        while true do
            task.wait(0.35)
            if ParticleConfig.Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local root = LocalPlayer.Character.HumanoidRootPart
                local part = Instance.new("Part")
                part.Size = Vector3.new(0.1, 0.1, 0.1)
                part.Transparency = 1
                part.Anchored = true
                part.CanCollide = false
                part.Position = root.Position + Vector3.new(math.random(-8,8), math.random(2,6), math.random(-8,8))
                part.Parent = particleFolder
                local bill = Instance.new("BillboardGui", part)
                bill.Size = UDim2.new(0, 28, 0, 28)
                bill.AlwaysOnTop = true
                local lab = Instance.new("TextLabel", bill)
                lab.Size = UDim2.new(1, 0, 1, 0)
                lab.BackgroundTransparency = 1
                lab.Text = symbols[ParticleConfig.Type] or "⭐"
                lab.TextColor3 = ParticleConfig.Color  -- используем актуальный цвет
                lab.TextSize = 18
                lab.Font = Enum.Font.SourceSansBold
                local entry = {part = part, start = tick(), max = 2.8}
                table.insert(activeParticles, entry)
            end
        end
    end)

    RunService.Heartbeat:Connect(function()
        for i = #activeParticles, 1, -1 do
            local p = activeParticles[i]
            local age = tick() - p.start
            if age > p.max then
                p.part:Destroy()
                table.remove(activeParticles, i)
            else
                p.part.Position += Vector3.new(0, 0.035, 0)
                local g = p.part:FindFirstChildOfClass("BillboardGui")
                if g then
                    local l = g:FindFirstChildOfClass("TextLabel")
                    if l then l.TextTransparency = age / p.max end
                end
            end
        end
    end)

    -- ESP
    local espContainer = Instance.new("Folder", screenGui)
    espContainer.Name = "ESPContainer"

    local SKELETON_SEGMENTS = {
        {"Head", "Neck"},
        {"Neck", "Torso"},
        {"Torso", "Pelvis"},
        {"Torso", "LShoulder"},
        {"LShoulder", "LElbow", "LHand"},
        {"Torso", "RShoulder"},
        {"RShoulder", "RElbow", "RHand"},
        {"Pelvis", "LHip"},
        {"LHip", "LKnee", "LFoot"},
        {"Pelvis", "RHip"},
        {"RHip", "RKnee", "RFoot"}
    }

    local function getSkeletonPoints(character)
        local head = character:FindFirstChild("Head")
        local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
        if not head or not torso then return nil end

        local pts = {}
        local headUp = head.CFrame.UpVector
        pts.Head = head.Position + headUp * (head.Size.Y / 2)
        pts.Neck = head.Position - headUp * (head.Size.Y / 2)
        pts.Torso = torso.Position
        local pelvis = character:FindFirstChild("LowerTorso") or character:FindFirstChild("Torso") or torso
        pts.Pelvis = pelvis.Position

        local torsoPos = torso.Position

        -- конец части, ближний к торсу (плечо/бедро/локоть/колено)
        local function nearEnd(part)
            local a = part.Position + part.CFrame.UpVector * (part.Size.Y / 2)
            local b = part.Position - part.CFrame.UpVector * (part.Size.Y / 2)
            return (a - torsoPos).Magnitude < (b - torsoPos).Magnitude and a or b
        end

        -- конец части, дальний от торса (кисть/стопа)
        local function farEnd(part)
            local a = part.Position + part.CFrame.UpVector * (part.Size.Y / 2)
            local b = part.Position - part.CFrame.UpVector * (part.Size.Y / 2)
            return (a - torsoPos).Magnitude > (b - torsoPos).Magnitude and a or b
        end

        local function addLimb(prefix, upperName, lowerName, handName, r6Name)
            local upper = character:FindFirstChild(upperName)
            local lower = character:FindFirstChild(lowerName)
            local handPart = character:FindFirstChild(handName)
            local r6Part = character:FindFirstChild(r6Name)

            if upper then
                pts[prefix .. "Shoulder"] = nearEnd(upper)
                if lower then
                    pts[prefix .. "Elbow"] = nearEnd(lower)
                end
                if handPart then
                    pts[prefix .. "Hand"] = handPart.Position
                elseif lower then
                    pts[prefix .. "Hand"] = farEnd(lower)
                end
            elseif r6Part then
                pts[prefix .. "Shoulder"] = nearEnd(r6Part)
                pts[prefix .. "Hand"] = farEnd(r6Part)
            end
        end

        addLimb("L", "LeftUpperArm", "LeftLowerArm", "LeftHand", "Left Arm")
        addLimb("R", "RightUpperArm", "RightLowerArm", "RightHand", "Right Arm")
        addLimb("L", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "Left Leg")
        addLimb("R", "RightUpperLeg", "RightLowerLeg", "RightFoot", "Right Leg")

        return pts
    end

    local function createESPObject(player)
        local box = Instance.new("Frame", espContainer)
        box.BackgroundTransparency = 1
        box.BorderSizePixel = 0
        box.Visible = false
        local stroke = Instance.new("UIStroke", box)
        stroke.Color = ESPConfig.Color
        stroke.Thickness = 1.5

        local nameLabel = Instance.new("TextLabel", espContainer)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextSize = 13
        nameLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold)
        nameLabel.TextStrokeTransparency = 0.4
        nameLabel.Visible = false

        local hpLabel = Instance.new("TextLabel", espContainer)
        hpLabel.BackgroundTransparency = 1
        hpLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        hpLabel.TextSize = 12
        hpLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold)
        hpLabel.TextStrokeTransparency = 0.4
        hpLabel.Visible = false

        local skeletonLines = {}
        for i = 1, 15 do
            local line = Instance.new("Frame", espContainer)
            line.BackgroundColor3 = ESPConfig.Color
            line.BackgroundTransparency = 0
            line.BorderSizePixel = 0
            line.AnchorPoint = Vector2.new(0, 0.5)
            line.ZIndex = 10
            line.Visible = false
            skeletonLines[i] = line
        end

        espCache[player] = {
            Box = box,
            Name = nameLabel,
            Health = hpLabel,
            Stroke = stroke,
            Skeleton = skeletonLines
        }
    end

    Players.PlayerRemoving:Connect(function(player)
        if espCache[player] then
            espCache[player].Box:Destroy()
            espCache[player].Name:Destroy()
            espCache[player].Health:Destroy()
            for _, line in ipairs(espCache[player].Skeleton) do
                line:Destroy()
            end
            espCache[player] = nil
        end
    end)

    RunService.RenderStepped:Connect(function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                if not espCache[player] then createESPObject(player) end
                local data = espCache[player]
                local character = player.Character
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                local rootPart = character and character:FindFirstChild("HumanoidRootPart")

                if ESPConfig.Enabled and character and humanoid and humanoid.Health > 0 and rootPart then
                    local topPos = rootPart.Position + Vector3.new(0, 2.7, 0)
                    local bottomPos = rootPart.Position - Vector3.new(0, 3.2, 0)
                    local topScreen, topVis = Camera:WorldToViewportPoint(topPos)
                    local bottomScreen, bottomVis = Camera:WorldToViewportPoint(bottomPos)

                    if topVis and bottomVis and topScreen.Z > 0 and bottomScreen.Z > 0 then
                        local height = math.abs(bottomScreen.Y - topScreen.Y)
                        local width = height / 1.6
                        local boxX = topScreen.X - width / 2
                        local boxY = topScreen.Y

                        if ESPConfig.BoxStyle == "Rounded" then
                            data.Stroke.Thickness = 1.5
                            if not data.Box:FindFirstChildOfClass("UICorner") then
                                Instance.new("UICorner", data.Box).CornerRadius = UDim.new(0, 4)
                            end
                        elseif ESPConfig.BoxStyle == "Thick" then
                            data.Stroke.Thickness = 3
                            local corner = data.Box:FindFirstChildOfClass("UICorner")
                            if corner then corner:Destroy() end
                        else
                            data.Stroke.Thickness = 1.5
                            local corner = data.Box:FindFirstChildOfClass("UICorner")
                            if corner then corner:Destroy() end
                        end

                        if ESPConfig.Boxes then
                            data.Box.Size = UDim2.new(0, width, 0, height)
                            data.Box.Position = UDim2.new(0, boxX, 0, boxY)
                            data.Box.Visible = true
                        else
                            data.Box.Visible = false
                        end
                    else
                        data.Box.Visible = false
                    end

                    if ESPConfig.Names then
                        local screenPos, visible = Camera:WorldToViewportPoint(rootPart.Position + Vector3.new(0, 3.2, 0))
                        if visible and screenPos.Z > 0 then
                            data.Name.Text = player.Name
                            data.Name.Position = UDim2.new(0, screenPos.X - 100, 0, screenPos.Y - 18)
                            data.Name.Size = UDim2.new(0, 200, 0, 16)
                            data.Name.Visible = true
                        else
                            data.Name.Visible = false
                        end
                    else
                        data.Name.Visible = false
                    end

                    if ESPConfig.Health then
                        local hp = math.floor(humanoid.Health)
                        data.Health.Text = hp .. " HP"
                        local screenPos, visible = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3.3, 0))
                        if visible and screenPos.Z > 0 then
                            data.Health.Position = UDim2.new(0, screenPos.X - 100, 0, screenPos.Y + 2)
                            data.Health.Size = UDim2.new(0, 200, 0, 15)
                            local pct = math.clamp(hp / math.max(humanoid.MaxHealth, 1), 0, 1)
                            data.Health.TextColor3 = Color3.fromRGB(255 * (1 - pct), 255 * pct, 80)
                            data.Health.Visible = true
                        else
                            data.Health.Visible = false
                        end
                    else
                        data.Health.Visible = false
                    end

                    if ESPConfig.Skeleton then
                        local pts = getSkeletonPoints(character)
                        if pts then
                            local screenPts = {}
                            local allVisible = true
                            for name, pos in pairs(pts) do
                                local sp, vis = Camera:WorldToViewportPoint(pos)
                                if vis and sp.Z > 0 then
                                    screenPts[name] = Vector2.new(sp.X, sp.Y)
                                else
                                    allVisible = false
                                    break
                                end
                            end
                            if allVisible then
                                local idx = 1
                                for _, seg in ipairs(SKELETON_SEGMENTS) do
                                    local prev = nil
                                    for _, name in ipairs(seg) do
                                        local p = screenPts[name]
                                        if p then
                                            if prev and data.Skeleton[idx] then
                                                local line = data.Skeleton[idx]
                                                local dx, dy = p.X - prev.X, p.Y - prev.Y
                                                local len = math.sqrt(dx * dx + dy * dy)
                                                if len < 3 then
                                                    line.Visible = false
                                                else
                                                    line.Size = UDim2.new(0, len, 0, 1.5)
                                                    line.Position = UDim2.new(0, prev.X, 0, prev.Y)
                                                    line.Rotation = math.deg(math.atan2(dy, dx))
                                                    line.Visible = true
                                                end
                                                idx += 1
                                            end
                                            prev = p
                                        else
                                            prev = nil
                                        end
                                    end
                                end
                                for i = idx, #data.Skeleton do
                                    data.Skeleton[i].Visible = false
                                end
                            else
                                for i = 1, #data.Skeleton do
                                    data.Skeleton[i].Visible = false
                                end
                            end
                        end
                    else
                        for i = 1, #data.Skeleton do
                            data.Skeleton[i].Visible = false
                        end
                    end
                else
                    data.Box.Visible = false
                    data.Name.Visible = false
                    data.Health.Visible = false
                    for i = 1, #data.Skeleton do
                        data.Skeleton[i].Visible = false
                    end
                end
            end
        end
    end)

    -- Target HUD
    local currentTarget = nil
    RunService.RenderStepped:Connect(function()
        if not TargetHUDConfig.Enabled then
            targetHudFrame.Visible = false
            currentTarget = nil
            return
        end
        local mousePos = UserInputService:GetMouseLocation()
        local ray = Camera:ViewportPointToRay(mousePos.X, mousePos.Y)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {LocalPlayer.Character, screenGui}
        local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
        if result and result.Instance then
            local char = result.Instance:FindFirstAncestorOfClass("Model")
            if char then
                local plr = Players:GetPlayerFromCharacter(char)
                if plr and plr ~= LocalPlayer then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        if currentTarget ~= plr then
                            currentTarget = plr
                            targetNameLabel.Text = plr.Name
                            task.spawn(function()
                                local ok, content = pcall(Players.GetUserThumbnailAsync, Players, plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
                                if ok and currentTarget == plr then avatarImg.Image = content end
                            end)
                        end
                        local hp = math.max(0, hum.Health)
                        targetHpLabel.Text = string.format("HP / %.1f", hp)
                        TweenService:Create(healthBarFill, TweenInfo.new(0.1), {Size = UDim2.new(math.clamp(hp / hum.MaxHealth, 0, 1), 0, 1, 0)}):Play()
                        targetHudFrame.Visible = true
                        return
                    end
                end
            end
        end
        targetHudFrame.Visible = false
        currentTarget = nil
    end)

    -- Hotkeys
    UserInputService.InputBegan:Connect(function(input)
        if UserInputService:GetFocusedTextBox() then return end
        if input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.Insert then
            mainGui.Visible = not mainGui.Visible
            if not mainGui.Visible then closeSettingsModal() end
        end
    end)
end

--------------------------------------------------------------------------------
-- START
--------------------------------------------------------------------------------
if isKeyValidToday() then
    startMainScript()
else
    createKeyUI(startMainScript)
end
