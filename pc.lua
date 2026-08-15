-- LocalScript: FlameVisuals Client (PC + Key System)
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
-- СОХРАНЕНИЕ КЛЮЧА (сброс после 00:00)
--------------------------------------------------------------------------------
local function getTodayDate()
	local t = os.date("*t")
	return string.format("%04d-%02d-%02d", t.year, t.month, t.day)
end

local function isKeyValidToday()
	if not (isfile and readfile) then return false end
	local success, content = pcall(readfile, KEY_FILE)
	if not success or not content then return false end

	local ok, data = pcall(function()
		return HttpService:JSONDecode(content)
	end)
	if not ok or type(data) ~= "table" then return false end

	return data.key == CORRECT_KEY and data.date == getTodayDate()
end

local function saveKeyToday()
	if not writefile then return end
	local payload = {
		key = CORRECT_KEY,
		date = getTodayDate()
	}
	pcall(writefile, KEY_FILE, HttpService:JSONEncode(payload))
end

local function openDiscord()
	if setclipboard then
		pcall(setclipboard, DISCORD_LINK)
	end
	if syn and syn.open_url then
		pcall(syn.open_url, DISCORD_LINK)
	elseif open_url then
		pcall(open_url, DISCORD_LINK)
	end
end

--------------------------------------------------------------------------------
-- ОКНО ВВОДА КЛЮЧА
--------------------------------------------------------------------------------
local function createKeyUI(onSuccess)
	local keyFrame = Instance.new("Frame")
	keyFrame.Name = "KeySystem"
	keyFrame.Size = UDim2.new(0, 340, 0, 230)
	keyFrame.Position = UDim2.new(0.5, -170, 0.5, -115)
	keyFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
	keyFrame.BorderSizePixel = 0
	keyFrame.Parent = screenGui

	local keyCorner = Instance.new("UICorner")
	keyCorner.CornerRadius = UDim.new(0, 12)
	keyCorner.Parent = keyFrame

	local keyStroke = Instance.new("UIStroke")
	keyStroke.Color = Color3.fromRGB(168, 85, 247)
	keyStroke.Thickness = 1.5
	keyStroke.Parent = keyFrame

	local keyTitle = Instance.new("TextLabel")
	keyTitle.Size = UDim2.new(1, 0, 0, 42)
	keyTitle.Position = UDim2.new(0, 0, 0, 12)
	keyTitle.BackgroundTransparency = 1
	keyTitle.Text = "🔥 FlameVisuals"
	keyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	keyTitle.TextSize = 22
	keyTitle.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	keyTitle.Parent = keyFrame

	local keySubtitle = Instance.new("TextLabel")
	keySubtitle.Size = UDim2.new(1, -40, 0, 20)
	keySubtitle.Position = UDim2.new(0, 20, 0, 52)
	keySubtitle.BackgroundTransparency = 1
	keySubtitle.Text = "Введите ключ для активации"
	keySubtitle.TextColor3 = Color3.fromRGB(160, 160, 175)
	keySubtitle.TextSize = 14
	keySubtitle.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
	keySubtitle.Parent = keyFrame

	local keyInput = Instance.new("TextBox")
	keyInput.Size = UDim2.new(1, -40, 0, 38)
	keyInput.Position = UDim2.new(0, 20, 0, 82)
	keyInput.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
	keyInput.BorderSizePixel = 0
	keyInput.PlaceholderText = "Введите ключ..."
	keyInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
	keyInput.Text = ""
	keyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
	keyInput.TextSize = 15
	keyInput.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
	keyInput.ClearTextOnFocus = false
	keyInput.Parent = keyFrame

	local keyInputCorner = Instance.new("UICorner")
	keyInputCorner.CornerRadius = UDim.new(0, 8)
	keyInputCorner.Parent = keyInput

	local keyInputPadding = Instance.new("UIPadding")
	keyInputPadding.PaddingLeft = UDim.new(0, 12)
	keyInputPadding.Parent = keyInput

	local activateBtn = Instance.new("TextButton")
	activateBtn.Size = UDim2.new(0.5, -25, 0, 38)
	activateBtn.Position = UDim2.new(0, 20, 0, 136)
	activateBtn.BackgroundColor3 = Color3.fromRGB(168, 85, 247)
	activateBtn.Text = "Activation"
	activateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	activateBtn.TextSize = 15
	activateBtn.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	activateBtn.Parent = keyFrame

	local activateCorner = Instance.new("UICorner")
	activateCorner.CornerRadius = UDim.new(0, 8)
	activateCorner.Parent = activateBtn

	local getKeyBtn = Instance.new("TextButton")
	getKeyBtn.Size = UDim2.new(0.5, -25, 0, 38)
	getKeyBtn.Position = UDim2.new(0.5, 5, 0, 136)
	getKeyBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
	getKeyBtn.Text = "Get Key"
	getKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	getKeyBtn.TextSize = 15
	getKeyBtn.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	getKeyBtn.Parent = keyFrame

	local getKeyCorner = Instance.new("UICorner")
	getKeyCorner.CornerRadius = UDim.new(0, 8)
	getKeyCorner.Parent = getKeyBtn

	local statusLabel = Instance.new("TextLabel")
	statusLabel.Size = UDim2.new(1, -40, 0, 20)
	statusLabel.Position = UDim2.new(0, 20, 0, 188)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Text = ""
	statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
	statusLabel.TextSize = 13
	statusLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
	statusLabel.Parent = keyFrame

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
-- ОСНОВНОЙ СКРИПТ
--------------------------------------------------------------------------------
local function startMainScript()
	local function makeDraggable(frame)
		local dragging = false
		local dragStart = nil
		local startPos = nil

		frame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				dragStart = input.Position
				startPos = frame.Position
			end
		end)

		frame.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				local delta = input.Position - dragStart
				frame.Position = UDim2.new(
					startPos.X.Scale,
					startPos.X.Offset + delta.X,
					startPos.Y.Scale,
					startPos.Y.Offset + delta.Y
				)
			end
		end)
	end

	--------------------------------------------------------------------------------
	-- НАСТРОЙКИ
	--------------------------------------------------------------------------------
	local ESPConfig = {
		Enabled = false,
		Boxes = true,
		Names = true,
		Health = true,
		Color = Color3.fromRGB(168, 85, 247)
	}
	local TargetHUDConfig = { Enabled = false }
	local AutoLoadConfig = { Enabled = false }

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

	local thCorner = Instance.new("UICorner")
	thCorner.CornerRadius = UDim.new(0, 12)
	thCorner.Parent = targetHudFrame

	local thStroke = Instance.new("UIStroke")
	thStroke.Color = Color3.fromRGB(30, 30, 40)
	thStroke.Thickness = 1.5
	thStroke.Parent = targetHudFrame

	local avatarImg = Instance.new("ImageLabel")
	avatarImg.Name = "Avatar"
	avatarImg.Size = UDim2.new(0, 42, 0, 42)
	avatarImg.Position = UDim2.new(0, 12, 0, 10)
	avatarImg.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
	avatarImg.BorderSizePixel = 0
	avatarImg.Parent = targetHudFrame

	local avatarCorner = Instance.new("UICorner")
	avatarCorner.CornerRadius = UDim.new(0, 8)
	avatarCorner.Parent = avatarImg

	local targetNameLabel = Instance.new("TextLabel")
	targetNameLabel.Name = "TargetName"
	targetNameLabel.Size = UDim2.new(1, -70, 0, 22)
	targetNameLabel.Position = UDim2.new(0, 62, 0, 8)
	targetNameLabel.BackgroundTransparency = 1
	targetNameLabel.Text = "Player"
	targetNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	targetNameLabel.TextSize = 16
	targetNameLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	targetNameLabel.TextXAlignment = Enum.TextXAlignment.Left
	targetNameLabel.Parent = targetHudFrame

	local targetHpLabel = Instance.new("TextLabel")
	targetHpLabel.Name = "TargetHP"
	targetHpLabel.Size = UDim2.new(1, -70, 0, 18)
	targetHpLabel.Position = UDim2.new(0, 62, 0, 30)
	targetHpLabel.BackgroundTransparency = 1
	targetHpLabel.Text = "HP / 100.0"
	targetHpLabel.TextColor3 = Color3.fromRGB(170, 170, 185)
	targetHpLabel.TextSize = 13
	targetHpLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
	targetHpLabel.TextXAlignment = Enum.TextXAlignment.Left
	targetHpLabel.Parent = targetHudFrame

	local healthBarBg = Instance.new("Frame")
	healthBarBg.Name = "HealthBarBG"
	healthBarBg.Size = UDim2.new(1, -24, 0, 8)
	healthBarBg.Position = UDim2.new(0, 12, 0, 58)
	healthBarBg.BackgroundColor3 = Color3.fromRGB(25, 22, 35)
	healthBarBg.BorderSizePixel = 0
	healthBarBg.Parent = targetHudFrame

	local barBgCorner = Instance.new("UICorner")
	barBgCorner.CornerRadius = UDim.new(1, 0)
	barBgCorner.Parent = healthBarBg

	local healthBarFill = Instance.new("Frame")
	healthBarFill.Name = "HealthBarFill"
	healthBarFill.Size = UDim2.new(1, 0, 1, 0)
	healthBarFill.BackgroundColor3 = Color3.fromRGB(140, 70, 255)
	healthBarFill.BorderSizePixel = 0
	healthBarFill.Parent = healthBarBg

	local barFillCorner = Instance.new("UICorner")
	barFillCorner.CornerRadius = UDim.new(1, 0)
	barFillCorner.Parent = healthBarFill

	--------------------------------------------------------------------------------
	-- WATERMARK
	--------------------------------------------------------------------------------
	local watermarkFrame = Instance.new("Frame")
	watermarkFrame.Name = "WatermarkFrame"
	watermarkFrame.Position = UDim2.new(0, 20, 0, 20)
	watermarkFrame.Size = UDim2.new(0, 0, 0, 32)
	watermarkFrame.AutomaticSize = Enum.AutomaticSize.X
	watermarkFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
	watermarkFrame.BackgroundTransparency = 0.15
	watermarkFrame.BorderSizePixel = 0
	watermarkFrame.Visible = true
	watermarkFrame.Parent = screenGui
	makeDraggable(watermarkFrame)

	local wmCorner = Instance.new("UICorner")
	wmCorner.CornerRadius = UDim.new(0, 16)
	wmCorner.Parent = watermarkFrame

	local wmStroke = Instance.new("UIStroke")
	wmStroke.Color = Color3.fromRGB(25, 25, 35)
	wmStroke.Thickness = 1
	wmStroke.Transparency = 0.4
	wmStroke.Parent = watermarkFrame

	local wmLayout = Instance.new("UIListLayout")
	wmLayout.FillDirection = Enum.FillDirection.Horizontal
	wmLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	wmLayout.Padding = UDim.new(0, 8)
	wmLayout.Parent = watermarkFrame

	local wmPadding = Instance.new("UIPadding")
	wmPadding.PaddingLeft = UDim.new(0, 12)
	wmPadding.PaddingRight = UDim.new(0, 14)
	wmPadding.Parent = watermarkFrame

	local wmIcon = Instance.new("TextLabel")
	wmIcon.Size = UDim2.new(0, 16, 0, 16)
	wmIcon.BackgroundTransparency = 1
	wmIcon.Text = "🔥"
	wmIcon.TextSize = 14
	wmIcon.Parent = watermarkFrame

	local wmBrand = Instance.new("TextLabel")
	wmBrand.AutomaticSize = Enum.AutomaticSize.X
	wmBrand.Size = UDim2.new(0, 0, 1, 0)
	wmBrand.BackgroundTransparency = 1
	wmBrand.Text = "FlameVisuals"
	wmBrand.TextColor3 = Color3.fromRGB(255, 255, 255)
	wmBrand.TextSize = 14
	wmBrand.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	wmBrand.Parent = watermarkFrame

	local wmStats = Instance.new("TextLabel")
	wmStats.AutomaticSize = Enum.AutomaticSize.X
	wmStats.Size = UDim2.new(0, 0, 1, 0)
	wmStats.BackgroundTransparency = 1
	wmStats.TextColor3 = Color3.fromRGB(160, 160, 175)
	wmStats.TextSize = 14
	wmStats.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
	wmStats.Parent = watermarkFrame

	local lastUpdate = tick()
	local frameCount = 0
	local fps = 0

	RunService.RenderStepped:Connect(function()
		frameCount = frameCount + 1
		local currentTime = tick()
		if currentTime - lastUpdate >= 0.5 then
			fps = math.floor(frameCount / (currentTime - lastUpdate))
			frameCount = 0
			lastUpdate = currentTime
			local ping = 0
			pcall(function()
				ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
			end)
			wmStats.Text = string.format("/  %s  /  %d ms  /  %d FPS", LocalPlayer.Name, ping, fps)
		end
	end)

	--------------------------------------------------------------------------------
	-- ГЛАВНОЕ МЕНЮ
	--------------------------------------------------------------------------------
	local mainGui = Instance.new("Frame")
	mainGui.Name = "MainMenu"
	mainGui.Size = UDim2.new(0, 750, 0, 480)
	mainGui.Position = UDim2.new(0.5, -375, 0.5, -240)
	mainGui.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
	mainGui.BorderSizePixel = 0
	mainGui.Parent = screenGui
	makeDraggable(mainGui)

	local menuCorner = Instance.new("UICorner")
	menuCorner.CornerRadius = UDim.new(0, 12)
	menuCorner.Parent = mainGui

	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.Size = UDim2.new(0, 180, 1, 0)
	sidebar.BackgroundColor3 = Color3.fromRGB(11, 11, 14)
	sidebar.BorderSizePixel = 0
	sidebar.Parent = mainGui

	local sidebarCorner = Instance.new("UICorner")
	sidebarCorner.CornerRadius = UDim.new(0, 12)
	sidebarCorner.Parent = sidebar

	local logoContainer = Instance.new("Frame")
	logoContainer.Size = UDim2.new(1, -20, 0, 50)
	logoContainer.Position = UDim2.new(0, 12, 0, 10)
	logoContainer.BackgroundTransparency = 1
	logoContainer.Parent = sidebar

	local logoIcon = Instance.new("TextLabel")
	logoIcon.Size = UDim2.new(0, 24, 1, 0)
	logoIcon.BackgroundTransparency = 1
	logoIcon.Text = "🔥"
	logoIcon.TextSize = 18
	logoIcon.Parent = logoContainer

	local logoText = Instance.new("TextLabel")
	logoText.Size = UDim2.new(1, -30, 1, 0)
	logoText.Position = UDim2.new(0, 28, 0, 0)
	logoText.BackgroundTransparency = 1
	logoText.Text = "FlameVisuals"
	logoText.TextColor3 = Color3.fromRGB(255, 255, 255)
	logoText.TextSize = 17
	logoText.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	logoText.TextXAlignment = Enum.TextXAlignment.Left
	logoText.Parent = logoContainer

	local contentArea = Instance.new("Frame")
	contentArea.Size = UDim2.new(1, -190, 1, -20)
	contentArea.Position = UDim2.new(0, 190, 0, 10)
	contentArea.BackgroundTransparency = 1
	contentArea.Parent = mainGui

	local headerText = Instance.new("TextLabel")
	headerText.Size = UDim2.new(1, 0, 0, 40)
	headerText.BackgroundTransparency = 1
	headerText.Text = "Visuals"
	headerText.TextColor3 = Color3.fromRGB(255, 255, 255)
	headerText.TextSize = 20
	headerText.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	headerText.TextXAlignment = Enum.TextXAlignment.Left
	headerText.Parent = contentArea

	local tabs = {}
	local tabButtons = {}
	local categories = {"Visuals", "HUD", "Utilities", "Configs"}

	local navContainer = Instance.new("Frame")
	navContainer.Size = UDim2.new(1, -20, 0, 220)
	navContainer.Position = UDim2.new(0, 10, 0, 65)
	navContainer.BackgroundTransparency = 1
	navContainer.Parent = sidebar

	local navList = Instance.new("UIListLayout")
	navList.Padding = UDim.new(0, 6)
	navList.Parent = navContainer

	local function createTabContent(name)
		local scroll = Instance.new("ScrollingFrame")
		scroll.Name = name .. "Tab"
		scroll.Size = UDim2.new(1, -10, 1, -50)
		scroll.Position = UDim2.new(0, 0, 0, 45)
		scroll.BackgroundTransparency = 1
		scroll.BorderSizePixel = 0
		scroll.ScrollBarThickness = 3
		scroll.ScrollBarImageColor3 = Color3.fromRGB(168, 85, 247)
		scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
		scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
		scroll.Visible = false
		scroll.Parent = contentArea

		local gridLayout = Instance.new("UIGridLayout")
		gridLayout.CellSize = UDim2.new(0, 260, 0, 70)
		gridLayout.CellPadding = UDim2.new(0, 15, 0, 15)
		gridLayout.Parent = scroll

		tabs[name] = scroll
		return scroll
	end

	local function switchTab(selectedName)
		headerText.Text = selectedName
		for name, frame in pairs(tabs) do
			frame.Visible = (name == selectedName)
		end
		for name, btn in pairs(tabButtons) do
			if name == selectedName then
				btn.BackgroundColor3 = Color3.fromRGB(168, 85, 247)
				btn.BackgroundTransparency = 0
			else
				btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				btn.BackgroundTransparency = 1
			end
		end
	end

	for _, name in ipairs(categories) do
		createTabContent(name)

		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 36)
		btn.Text = "    " .. name
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.TextSize = 14
		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
		btn.Parent = navContainer

		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(0, 8)
		btnCorner.Parent = btn

		tabButtons[name] = btn
		btn.MouseButton1Click:Connect(function()
			switchTab(name)
		end)
	end

	switchTab("Visuals")

	--------------------------------------------------------------------------------
	-- МОДАЛЬНОЕ ОКНО ESP
	--------------------------------------------------------------------------------
	local settingsModal = Instance.new("Frame")
	settingsModal.Name = "SettingsModal"
	settingsModal.Size = UDim2.new(0, 220, 0, 0)
	settingsModal.AutomaticSize = Enum.AutomaticSize.Y
	settingsModal.BackgroundColor3 = Color3.fromRGB(13, 13, 18)
	settingsModal.BorderSizePixel = 0
	settingsModal.Visible = false
	settingsModal.ZIndex = 100
	settingsModal.Parent = screenGui

	local modalCorner = Instance.new("UICorner")
	modalCorner.CornerRadius = UDim.new(0, 14)
	modalCorner.Parent = settingsModal

	local modalStroke = Instance.new("UIStroke")
	modalStroke.Color = Color3.fromRGB(25, 25, 35)
	modalStroke.Thickness = 1
	modalStroke.Parent = settingsModal

	local modalPadding = Instance.new("UIPadding")
	modalPadding.PaddingTop = UDim.new(0, 12)
	modalPadding.PaddingBottom = UDim.new(0, 12)
	modalPadding.PaddingLeft = UDim.new(0, 12)
	modalPadding.PaddingRight = UDim.new(0, 12)
	modalPadding.Parent = settingsModal

	local modalLayout = Instance.new("UIListLayout")
	modalLayout.Padding = UDim.new(0, 8)
	modalLayout.SortOrder = Enum.SortOrder.LayoutOrder
	modalLayout.Parent = settingsModal

	UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
			if settingsModal.Visible then
				local rawMousePos = UserInputService:GetMouseLocation()
				local guiInset = GuiService:GetGuiInset()
				local mousePos = rawMousePos - guiInset
				local mPos = settingsModal.AbsolutePosition
				local mSize = settingsModal.AbsoluteSize
				if mousePos.X < mPos.X or mousePos.X > (mPos.X + mSize.X) or mousePos.Y < mPos.Y or mousePos.Y > (mPos.Y + mSize.Y) then
					settingsModal.Visible = false
				end
			end
		end
	end)

	local function createRefHeader(text)
		local header = Instance.new("TextLabel")
		header.Size = UDim2.new(1, 0, 0, 18)
		header.BackgroundTransparency = 1
		header.Text = text
		header.TextColor3 = Color3.fromRGB(120, 120, 140)
		header.TextSize = 13
		header.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
		header.TextXAlignment = Enum.TextXAlignment.Center
		header.ZIndex = 101
		header.Parent = settingsModal
	end

	local function createRefToggle(title, defaultValue, onToggle)
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 26)
		row.BackgroundTransparency = 1
		row.ZIndex = 101
		row.Parent = settingsModal

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, -45, 1, 0)
		label.BackgroundTransparency = 1
		label.Text = title
		label.TextColor3 = Color3.fromRGB(220, 220, 230)
		label.TextSize = 13
		label.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.ZIndex = 101
		label.Parent = row

		local toggleBtn = Instance.new("TextButton")
		toggleBtn.Size = UDim2.new(0, 38, 0, 20)
		toggleBtn.Position = UDim2.new(1, -38, 0.5, -10)
		toggleBtn.BackgroundColor3 = defaultValue and Color3.fromRGB(120, 80, 230) or Color3.fromRGB(35, 35, 45)
		toggleBtn.Text = ""
		toggleBtn.AutoButtonColor = false
		toggleBtn.ZIndex = 101
		toggleBtn.Parent = row

		local toggleCorner = Instance.new("UICorner")
		toggleCorner.CornerRadius = UDim.new(1, 0)
		toggleCorner.Parent = toggleBtn

		local toggleCircle = Instance.new("Frame")
		toggleCircle.Size = UDim2.new(0, 14, 0, 14)
		toggleCircle.Position = defaultValue and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
		toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		toggleCircle.BorderSizePixel = 0
		toggleCircle.ZIndex = 102
		toggleCircle.Parent = toggleBtn

		local circleCorner = Instance.new("UICorner")
		circleCorner.CornerRadius = UDim.new(1, 0)
		circleCorner.Parent = toggleCircle

		local state = defaultValue
		toggleBtn.MouseButton1Click:Connect(function()
			state = not state
			local targetBg = state and Color3.fromRGB(120, 80, 230) or Color3.fromRGB(35, 35, 45)
			local targetPos = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
			TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = targetBg}):Play()
			TweenService:Create(toggleCircle, TweenInfo.new(0.2), {Position = targetPos}):Play()
			if onToggle then onToggle(state) end
		end)
	end

	--------------------------------------------------------------------------------
	-- КАРТОЧКИ МОДУЛЕЙ
	--------------------------------------------------------------------------------
	local cardReferences = {}

	local function createModuleCard(parentTab, title, description, defaultValue, onToggle, onRightClick)
		local card = Instance.new("TextButton")
		card.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
		card.BorderSizePixel = 0
		card.Text = ""
		card.AutoButtonColor = false
		card.Parent = parentTab

		local cardCorner = Instance.new("UICorner")
		cardCorner.CornerRadius = UDim.new(0, 8)
		cardCorner.Parent = card

		local cardTitle = Instance.new("TextLabel")
		cardTitle.Size = UDim2.new(1, -60, 0, 25)
		cardTitle.Position = UDim2.new(0, 12, 0, 10)
		cardTitle.BackgroundTransparency = 1
		cardTitle.Text = title
		cardTitle.TextColor3 = Color3.fromRGB(240, 240, 245)
		cardTitle.TextSize = 15
		cardTitle.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
		cardTitle.TextXAlignment = Enum.TextXAlignment.Left
		cardTitle.Parent = card

		local cardDesc = Instance.new("TextLabel")
		cardDesc.Size = UDim2.new(1, -20, 0, 25)
		cardDesc.Position = UDim2.new(0, 12, 0, 35)
		cardDesc.BackgroundTransparency = 1
		cardDesc.Text = description
		cardDesc.TextColor3 = Color3.fromRGB(120, 120, 135)
		cardDesc.TextSize = 12
		cardDesc.TextXAlignment = Enum.TextXAlignment.Left
		cardDesc.Parent = card

		local toggleBtn = Instance.new("TextButton")
		toggleBtn.Size = UDim2.new(0, 40, 0, 20)
		toggleBtn.Position = UDim2.new(1, -50, 0, 12)
		toggleBtn.BackgroundColor3 = defaultValue and Color3.fromRGB(168, 85, 247) or Color3.fromRGB(45, 45, 55)
		toggleBtn.Text = ""
		toggleBtn.AutoButtonColor = false
		toggleBtn.Parent = card

		local toggleCorner = Instance.new("UICorner")
		toggleCorner.CornerRadius = UDim.new(0, 10)
		toggleCorner.Parent = toggleBtn

		local toggleCircle = Instance.new("Frame")
		toggleCircle.Size = UDim2.new(0, 14, 0, 14)
		toggleCircle.Position = defaultValue and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
		toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		toggleCircle.BorderSizePixel = 0
		toggleCircle.Parent = toggleBtn

		local circleCorner = Instance.new("UICorner")
		circleCorner.CornerRadius = UDim.new(1, 0)
		circleCorner.Parent = toggleCircle

		local state = defaultValue

		local function setVisualState(newState)
			state = newState
			local targetBg = state and Color3.fromRGB(168, 85, 247) or Color3.fromRGB(45, 45, 55)
			local targetPos = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
			TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = targetBg}):Play()
			TweenService:Create(toggleCircle, TweenInfo.new(0.2), {Position = targetPos}):Play()
			if onToggle then onToggle(state) end
		end

		toggleBtn.MouseButton1Click:Connect(function()
			setVisualState(not state)
		end)

		card.MouseButton2Click:Connect(function()
			if onRightClick then
				local rawMousePos = UserInputService:GetMouseLocation()
				local guiInset = GuiService:GetGuiInset()
				local mousePos = rawMousePos - guiInset
				settingsModal.Position = UDim2.new(0, mousePos.X + 5, 0, mousePos.Y - 10)
				settingsModal.Visible = true
				onRightClick()
			end
		end)

		return {
			SetState = setVisualState,
			GetState = function() return state end
		}
	end

	-- VISUALS
	cardReferences.ESP = createModuleCard(tabs["Visuals"], "ESP", "ПКМ - индивидуальные настройки", ESPConfig.Enabled, function(v)
		ESPConfig.Enabled = v
	end, function()
		for _, child in ipairs(settingsModal:GetChildren()) do
			if not child:IsA("UIListLayout") and not child:IsA("UICorner") and not child:IsA("UIStroke") and not child:IsA("UIPadding") then
				child:Destroy()
			end
		end
		createRefHeader("Настройки ESP")
		createRefToggle("Боксы (Boxes)", ESPConfig.Boxes, function(v) ESPConfig.Boxes = v end)
		createRefToggle("Имена (Names)", ESPConfig.Names, function(v) ESPConfig.Names = v end)
		createRefToggle("Здоровье (Health)", ESPConfig.Health, function(v) ESPConfig.Health = v end)
	end)

	-- HUD
	cardReferences.Watermark = createModuleCard(tabs["HUD"], "Watermark", "Отображение верхнего HUD", true, function(v)
		watermarkFrame.Visible = v
	end, nil)

	cardReferences.TargetHUD = createModuleCard(tabs["HUD"], "Target HUD", "Информация о выбранном игроке", TargetHUDConfig.Enabled, function(v)
		TargetHUDConfig.Enabled = v
		if not v then
			targetHudFrame.Visible = false
		end
	end, nil)

	--------------------------------------------------------------------------------
	-- КОНФИГИ
	--------------------------------------------------------------------------------
	local HAS_FS = (writefile ~= nil and readfile ~= nil and listfiles ~= nil and delfile ~= nil)
	local CONFIG_FOLDER = "FlameVisuals_Configs"
	local AUTOLOAD_FILE = CONFIG_FOLDER .. "/_autoload_state.json"
	local memoryConfigs = {}

	local function serializeConfig()
		return {
			ESP = {
				Enabled = ESPConfig.Enabled,
				Boxes = ESPConfig.Boxes,
				Names = ESPConfig.Names,
				Health = ESPConfig.Health,
				Color = {ESPConfig.Color.R, ESPConfig.Color.G, ESPConfig.Color.B}
			},
			TargetHUD = { Enabled = TargetHUDConfig.Enabled },
			Watermark = { Enabled = watermarkFrame.Visible },
			Utilities = {
				Fullbright = cardReferences.Fullbright and cardReferences.Fullbright.GetState() or false,
				AutoLoad = AutoLoadConfig.Enabled
			}
		}
	end

	local function deserializeConfig(data)
		if not data then return end
		if data.ESP then
			ESPConfig.Enabled = data.ESP.Enabled or false
			ESPConfig.Boxes = data.ESP.Boxes or false
			ESPConfig.Names = data.ESP.Names or false
			ESPConfig.Health = data.ESP.Health or false
			if data.ESP.Color then
				ESPConfig.Color = Color3.new(data.ESP.Color[1], data.ESP.Color[2], data.ESP.Color[3])
			end
			if cardReferences.ESP then cardReferences.ESP.SetState(ESPConfig.Enabled) end
		end
		if data.TargetHUD then
			TargetHUDConfig.Enabled = data.TargetHUD.Enabled or false
			if cardReferences.TargetHUD then cardReferences.TargetHUD.SetState(TargetHUDConfig.Enabled) end
		end
		if data.Watermark then
			local wmState = data.Watermark.Enabled or false
			if cardReferences.Watermark then cardReferences.Watermark.SetState(wmState) end
		end
		if data.Utilities then
			if data.Utilities.Fullbright ~= nil and cardReferences.Fullbright then
				cardReferences.Fullbright.SetState(data.Utilities.Fullbright)
			end
			if data.Utilities.AutoLoad ~= nil and cardReferences.AutoLoad then
				AutoLoadConfig.Enabled = data.Utilities.AutoLoad
				cardReferences.AutoLoad.SetState(AutoLoadConfig.Enabled)
			end
		end
	end

	local function saveAutoLoadData(state)
		local payload = { Enabled = state, Config = serializeConfig() }
		local json = HttpService:JSONEncode(payload)
		if HAS_FS then
			if isfolder and not isfolder(CONFIG_FOLDER) then pcall(makefolder, CONFIG_FOLDER) end
			pcall(writefile, AUTOLOAD_FILE, json)
		else
			memoryConfigs["_AUTOLOAD_PAYLOAD_"] = json
		end
	end

	local function loadAutoLoadData()
		if HAS_FS then
			if isfile and isfile(AUTOLOAD_FILE) then
				local success, content = pcall(readfile, AUTOLOAD_FILE)
				if success and content then
					local successDec, data = pcall(function() return HttpService:JSONDecode(content) end)
					if successDec then return data end
				end
			end
		else
			if memoryConfigs["_AUTOLOAD_PAYLOAD_"] then
				local successDec, data = pcall(function() return HttpService:JSONDecode(memoryConfigs["_AUTOLOAD_PAYLOAD_"]) end)
				if successDec then return data end
			end
		end
		return nil
	end

	local function saveConfigToFile(name, data)
		local json = HttpService:JSONEncode(data)
		if HAS_FS then
			if isfolder and not isfolder(CONFIG_FOLDER) then pcall(makefolder, CONFIG_FOLDER) end
			pcall(writefile, CONFIG_FOLDER .. "/" .. name .. ".json", json)
		else
			memoryConfigs[name] = json
		end
	end

	local function loadConfigFromFile(name)
		if HAS_FS then
			local path = CONFIG_FOLDER .. "/" .. name .. ".json"
			local success, content = pcall(readfile, path)
			if success and content then
				local successDec, data = pcall(function() return HttpService:JSONDecode(content) end)
				if successDec then return data end
			end
		else
			if memoryConfigs[name] then
				local successDec, data = pcall(function() return HttpService:JSONDecode(memoryConfigs[name]) end)
				if successDec then return data end
			end
		end
		return nil
	end

	local function deleteConfigFile(name)
		if HAS_FS then
			pcall(delfile, CONFIG_FOLDER .. "/" .. name .. ".json")
		else
			memoryConfigs[name] = nil
		end
	end

	local function getAllConfigNames()
		local list = {}
		if HAS_FS then
			if isfolder and isfolder(CONFIG_FOLDER) then
				local success, files = pcall(listfiles, CONFIG_FOLDER)
				if success and files then
					for _, file in ipairs(files) do
						local fileName = file:match("([^/\\]+)%.json$")
						if fileName and not fileName:find("^_") then
							table.insert(list, fileName)
						end
					end
				end
			end
		else
			for name, _ in pairs(memoryConfigs) do
				if not name:find("^_") then
					table.insert(list, name)
				end
			end
		end
		table.sort(list)
		return list
	end

	--------------------------------------------------------------------------------
	-- UTILITIES
	--------------------------------------------------------------------------------
	local origAmbient = Lighting.Ambient
	local origOutdoor = Lighting.OutdoorAmbient

	cardReferences.AutoLoad = createModuleCard(tabs["Utilities"], "AutoLoad", "Автоматическая активация при перезаходе", false, function(v)
		AutoLoadConfig.Enabled = v
		saveAutoLoadData(v)
	end, nil)

	cardReferences.Fullbright = createModuleCard(tabs["Utilities"], "Fullbright", "Максимальная яркость окружения", false, function(v)
		if v then
			Lighting.Ambient = Color3.fromRGB(255, 255, 255)
			Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
		else
			Lighting.Ambient = origAmbient
			Lighting.OutdoorAmbient = origOutdoor
		end
		if AutoLoadConfig.Enabled then saveAutoLoadData(true) end
	end, nil)

	cardReferences.Rejoin = createModuleCard(tabs["Utilities"], "Rejoin Game", "Включите для перезахода на сервер", false, function(v)
		if v then
			TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
		end
	end, nil)

	cardReferences.ServerHop = createModuleCard(tabs["Utilities"], "Server Hop", "Перейти на другой случайный сервер", false, function(v)
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
	-- CONFIGS TAB
	--------------------------------------------------------------------------------
	local configsTab = tabs["Configs"]
	local defaultGrid = configsTab:FindFirstChildOfClass("UIGridLayout")
	if defaultGrid then defaultGrid:Destroy() end

	local configsListLayout = Instance.new("UIListLayout")
	configsListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	configsListLayout.Padding = UDim.new(0, 10)
	configsListLayout.Parent = configsTab

	local createBar = Instance.new("Frame")
	createBar.Size = UDim2.new(1, -10, 0, 42)
	createBar.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
	createBar.BorderSizePixel = 0
	createBar.Parent = configsTab

	local createBarCorner = Instance.new("UICorner")
	createBarCorner.CornerRadius = UDim.new(0, 8)
	createBarCorner.Parent = createBar

	local configNameInput = Instance.new("TextBox")
	configNameInput.Size = UDim2.new(1, -120, 1, -12)
	configNameInput.Position = UDim2.new(0, 10, 0, 6)
	configNameInput.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
	configNameInput.BorderSizePixel = 0
	configNameInput.PlaceholderText = "Имя конфига..."
	configNameInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
	configNameInput.Text = ""
	configNameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
	configNameInput.TextSize = 14
	configNameInput.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
	configNameInput.TextXAlignment = Enum.TextXAlignment.Left
	configNameInput.Parent = createBar

	local inputPadding = Instance.new("UIPadding")
	inputPadding.PaddingLeft = UDim.new(0, 10)
	inputPadding.Parent = configNameInput

	local inputCorner = Instance.new("UICorner")
	inputCorner.CornerRadius = UDim.new(0, 6)
	inputCorner.Parent = configNameInput

	local createBtn = Instance.new("TextButton")
	createBtn.Size = UDim2.new(0, 95, 1, -12)
	createBtn.Position = UDim2.new(1, -105, 0, 6)
	createBtn.BackgroundColor3 = Color3.fromRGB(168, 85, 247)
	createBtn.Text = "Создать"
	createBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	createBtn.TextSize = 13
	createBtn.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	createBtn.Parent = createBar

	local createBtnCorner = Instance.new("UICorner")
	createBtnCorner.CornerRadius = UDim.new(0, 6)
	createBtnCorner.Parent = createBtn

	local cardsContainer = Instance.new("Frame")
	cardsContainer.Size = UDim2.new(1, -10, 0, 0)
	cardsContainer.AutomaticSize = Enum.AutomaticSize.Y
	cardsContainer.BackgroundTransparency = 1
	cardsContainer.Parent = configsTab

	local cardsLayout = Instance.new("UIListLayout")
	cardsLayout.SortOrder = Enum.SortOrder.LayoutOrder
	cardsLayout.Padding = UDim.new(0, 8)
	cardsLayout.Parent = cardsContainer

	local refreshConfigList

	local function createConfigCard(configName)
		local card = Instance.new("Frame")
		card.Size = UDim2.new(1, 0, 0, 48)
		card.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
		card.BorderSizePixel = 0
		card.Parent = cardsContainer

		local cardCorner = Instance.new("UICorner")
		cardCorner.CornerRadius = UDim.new(0, 8)
		cardCorner.Parent = card

		local titleLabel = Instance.new("TextLabel")
		titleLabel.Size = UDim2.new(1, -240, 1, 0)
		titleLabel.Position = UDim2.new(0, 14, 0, 0)
		titleLabel.BackgroundTransparency = 1
		titleLabel.Text = configName
		titleLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
		titleLabel.TextSize = 14
		titleLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
		titleLabel.TextXAlignment = Enum.TextXAlignment.Left
		titleLabel.Parent = card

		local btnContainer = Instance.new("Frame")
		btnContainer.Size = UDim2.new(0, 220, 1, 0)
		btnContainer.Position = UDim2.new(1, -225, 0, 0)
		btnContainer.BackgroundTransparency = 1
		btnContainer.Parent = card

		local btnLayout = Instance.new("UIListLayout")
		btnLayout.FillDirection = Enum.FillDirection.Horizontal
		btnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		btnLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		btnLayout.Padding = UDim.new(0, 6)
		btnLayout.Parent = btnContainer

		local function makeActionButton(text, width, color, onClick)
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(0, width, 0, 28)
			btn.BackgroundColor3 = color
			btn.Text = text
			btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			btn.TextSize = 12
			btn.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
			btn.Parent = btnContainer
			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 6)
			corner.Parent = btn
			btn.MouseButton1Click:Connect(onClick)
		end

		makeActionButton("Загрузить", 70, Color3.fromRGB(120, 80, 230), function()
			local data = loadConfigFromFile(configName)
			if data then
				deserializeConfig(data)
				if AutoLoadConfig.Enabled then saveAutoLoadData(true) end
			end
		end)

		makeActionButton("Сохранить", 70, Color3.fromRGB(45, 120, 60), function()
			saveConfigToFile(configName, serializeConfig())
			if AutoLoadConfig.Enabled then saveAutoLoadData(true) end
		end)

		makeActionButton("Удалить", 60, Color3.fromRGB(180, 50, 50), function()
			deleteConfigFile(configName)
			refreshConfigList()
		end)
	end

	refreshConfigList = function()
		for _, child in ipairs(cardsContainer:GetChildren()) do
			if not child:IsA("UIListLayout") then
				child:Destroy()
			end
		end
		for _, name in ipairs(getAllConfigNames()) do
			createConfigCard(name)
		end
	end

	createBtn.MouseButton1Click:Connect(function()
		local text = configNameInput.Text:gsub("^%s*(.-)%s*$", "%1")
		if #text > 0 then
			saveConfigToFile(text, serializeConfig())
			configNameInput.Text = ""
			refreshConfigList()
		end
	end)

	refreshConfigList()

	--------------------------------------------------------------------------------
	-- AUTOLOAD
	--------------------------------------------------------------------------------
	task.spawn(function()
		task.wait(0.2)
		local autoData = loadAutoLoadData()
		if autoData and autoData.Enabled and autoData.Config then
			deserializeConfig(autoData.Config)
		end
	end)

	--------------------------------------------------------------------------------
	-- TARGET HUD LOGIC
	--------------------------------------------------------------------------------
	local currentTargetPlayer = nil

	local function getMouseTargetPlayer()
		local mousePos = UserInputService:GetMouseLocation()
		local unitRay = Camera:ViewportPointToRay(mousePos.X, mousePos.Y)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		local ignoreList = {LocalPlayer.Character}
		if screenGui then table.insert(ignoreList, screenGui) end
		raycastParams.FilterDescendantsInstances = ignoreList
		local raycastResult = workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, raycastParams)
		if raycastResult and raycastResult.Instance then
			local character = raycastResult.Instance:FindFirstAncestorOfClass("Model")
			if character then
				local player = Players:GetPlayerFromCharacter(character)
				if player and player ~= LocalPlayer then
					return player, character
				end
			end
		end
		return nil, nil
	end

	RunService.RenderStepped:Connect(function()
		if TargetHUDConfig.Enabled then
			local player, character = getMouseTargetPlayer()
			if player and character then
				local humanoid = character:FindFirstChildOfClass("Humanoid")
				if humanoid and humanoid.Health > 0 then
					if currentTargetPlayer ~= player then
						currentTargetPlayer = player
						targetNameLabel.Text = player.Name
						task.spawn(function()
							local content = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
							if currentTargetPlayer == player then
								avatarImg.Image = content
							end
						end)
					end
					local hp = math.max(0, humanoid.Health)
					local maxHp = humanoid.MaxHealth
					targetHpLabel.Text = string.format("HP / %.1f", hp)
					local hpPercent = math.clamp(hp / maxHp, 0, 1)
					TweenService:Create(healthBarFill, TweenInfo.new(0.1), {Size = UDim2.new(hpPercent, 0, 1, 0)}):Play()
					targetHudFrame.Visible = true
				else
					targetHudFrame.Visible = false
					currentTargetPlayer = nil
				end
			else
				targetHudFrame.Visible = false
				currentTargetPlayer = nil
			end
		else
			targetHudFrame.Visible = false
			currentTargetPlayer = nil
		end
	end)

	--------------------------------------------------------------------------------
	-- ESP
	--------------------------------------------------------------------------------
	local espContainer = Instance.new("Folder")
	espContainer.Name = "ESPContainer"
	espContainer.Parent = screenGui

	local espCache = {}

	local function createESPObject(player)
		local box = Instance.new("Frame")
		box.BackgroundTransparency = 1
		box.BorderSizePixel = 0
		box.Visible = false
		box.Parent = espContainer

		local stroke = Instance.new("UIStroke")
		stroke.Color = ESPConfig.Color
		stroke.Thickness = 1.5
		stroke.Parent = box

		local nameLabel = Instance.new("TextLabel")
		nameLabel.BackgroundTransparency = 1
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLabel.TextSize = 13
		nameLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
		nameLabel.TextStrokeTransparency = 0.4
		nameLabel.Visible = false
		nameLabel.Parent = espContainer

		local hpLabel = Instance.new("TextLabel")
		hpLabel.BackgroundTransparency = 1
		hpLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
		hpLabel.TextSize = 12
		hpLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
		hpLabel.TextStrokeTransparency = 0.4
		hpLabel.Visible = false
		hpLabel.Parent = espContainer

		espCache[player] = {
			Box = box,
			Name = nameLabel,
			Health = hpLabel
		}
	end

	local function removeESPObject(player)
		if espCache[player] then
			espCache[player].Box:Destroy()
			espCache[player].Name:Destroy()
			espCache[player].Health:Destroy()
			espCache[player] = nil
		end
	end

	Players.PlayerRemoving:Connect(removeESPObject)

	RunService.RenderStepped:Connect(function()
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer then
				if not espCache[player] then
					createESPObject(player)
				end
				local data = espCache[player]
				local character = player.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				local rootPart = character and character:FindFirstChild("HumanoidRootPart")

				if ESPConfig.Enabled and character and humanoid and humanoid.Health > 0 and rootPart then
					local rootPos = rootPart.Position
					local topPosition = rootPos + Vector3.new(0, 2.7, 0)
					local bottomPosition = rootPos - Vector3.new(0, 3.2, 0)
					local topScreen, topVis = Camera:WorldToViewportPoint(topPosition)
					local bottomScreen, bottomVis = Camera:WorldToViewportPoint(bottomPosition)

					if topVis and bottomVis then
						local height = math.abs(bottomScreen.Y - topScreen.Y)
						local width = height / 1.6
						local boxX = topScreen.X - (width / 2)
						local boxY = topScreen.Y

						if ESPConfig.Boxes then
							data.Box.Size = UDim2.new(0, width, 0, height)
							data.Box.Position = UDim2.new(0, boxX, 0, boxY)
							data.Box.Visible = true
						else
							data.Box.Visible = false
						end

						if ESPConfig.Names then
							data.Name.Text = player.Name
							data.Name.Position = UDim2.new(0, boxX + (width / 2) - 100, 0, boxY - 18)
							data.Name.Size = UDim2.new(0, 200, 0, 16)
							data.Name.Visible = true
						else
							data.Name.Visible = false
						end

						if ESPConfig.Health then
							local hp = math.floor(humanoid.Health)
							local maxHp = math.floor(humanoid.MaxHealth)
							data.Health.Text = string.format("%d HP", hp)
							data.Health.Position = UDim2.new(0, boxX + (width / 2) - 100, 0, boxY + height + 2)
							data.Health.Size = UDim2.new(0, 200, 0, 15)
							local hpPercent = math.clamp(hp / maxHp, 0, 1)
							data.Health.TextColor3 = Color3.fromRGB(255 * (1 - hpPercent), 255 * hpPercent, 80)
							data.Health.Visible = true
						else
							data.Health.Visible = false
						end
					else
						data.Box.Visible = false
						data.Name.Visible = false
						data.Health.Visible = false
					end
				else
					if data then
						data.Box.Visible = false
						data.Name.Visible = false
						data.Health.Visible = false
					end
				end
			end
		end
	end)

	--------------------------------------------------------------------------------
	-- ГОРЯЧАЯ КЛАВИША
	--------------------------------------------------------------------------------
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		local isTyping = UserInputService:GetFocusedTextBox() ~= nil
		if not isTyping then
			if input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.Insert then
				mainGui.Visible = not mainGui.Visible
				if not mainGui.Visible then
					settingsModal.Visible = false
				end
			end
		end
	end)
end

--------------------------------------------------------------------------------
-- ЗАПУСК
--------------------------------------------------------------------------------
if isKeyValidToday() then
	startMainScript()
else
	createKeyUI(startMainScript)
end
