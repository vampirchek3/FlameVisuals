-- LocalScript: FlameVisuals Client (PC Full + Configs)
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
	local keyPad = Instance.new("UIPadding", keyInput)
	keyPad.PaddingLeft = UDim.new(0, 12)

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
	-- CONFIGS
	--------------------------------------------------------------------------------
	local ESPConfig = {
		Enabled = false,
		Boxes = true,
		Names = true,
		Health = true,
		Color = Color3.fromRGB(168, 85, 247)
	}

	local TargetHUDConfig = {
		Enabled = false
	}

	local ParticleConfig = {
		Enabled = false,
		Type = "Stars",
		Color = Color3.fromRGB(255, 215, 0)
	}

	local InterfaceConfig = {
		AccentColor = Color3.fromRGB(168, 85, 247)
	}

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
	avatarImg.Name = "Avatar"
	avatarImg.Size = UDim2.new(0, 42, 0, 42)
	avatarImg.Position = UDim2.new(0, 12, 0, 10)
	avatarImg.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
	avatarImg.BorderSizePixel = 0
	Instance.new("UICorner", avatarImg).CornerRadius = UDim.new(0, 8)

	local targetNameLabel = Instance.new("TextLabel", targetHudFrame)
	targetNameLabel.Name = "TargetName"
	targetNameLabel.Size = UDim2.new(1, -70, 0, 22)
	targetNameLabel.Position = UDim2.new(0, 62, 0, 8)
	targetNameLabel.BackgroundTransparency = 1
	targetNameLabel.Text = "Player"
	targetNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	targetNameLabel.TextSize = 16
	targetNameLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold)
	targetNameLabel.TextXAlignment = Enum.TextXAlignment.Left

	local targetHpLabel = Instance.new("TextLabel", targetHudFrame)
	targetHpLabel.Name = "TargetHP"
	targetHpLabel.Size = UDim2.new(1, -70, 0, 18)
	targetHpLabel.Position = UDim2.new(0, 62, 0, 30)
	targetHpLabel.BackgroundTransparency = 1
	targetHpLabel.Text = "HP / 100.0"
	targetHpLabel.TextColor3 = Color3.fromRGB(170, 170, 185)
	targetHpLabel.TextSize = 13
	targetHpLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold)
	targetHpLabel.TextXAlignment = Enum.TextXAlignment.Left

	local healthBarBg = Instance.new("Frame", targetHudFrame)
	healthBarBg.Name = "HealthBarBG"
	healthBarBg.Size = UDim2.new(1, -24, 0, 8)
	healthBarBg.Position = UDim2.new(0, 12, 0, 58)
	healthBarBg.BackgroundColor3 = Color3.fromRGB(25, 22, 35)
	healthBarBg.BorderSizePixel = 0
	Instance.new("UICorner", healthBarBg).CornerRadius = UDim.new(1, 0)

	local healthBarFill = Instance.new("Frame", healthBarBg)
	healthBarFill.Name = "HealthBarFill"
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
	sidebar.Name = "Sidebar"
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

	local tabs = {}
	local tabButtons = {}
	local categories = {"Visuals", "HUD", "Utilities", "Configs"}

	local navContainer = Instance.new("Frame", sidebar)
	navContainer.Size = UDim2.new(1, -20, 0, 220)
	navContainer.Position = UDim2.new(0, 10, 0, 65)
	navContainer.BackgroundTransparency = 1

	local navList = Instance.new("UIListLayout", navContainer)
	navList.Padding = UDim.new(0, 6)

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
		scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
		scroll.Visible = false

		if name ~= "Configs" then
			local gridLayout = Instance.new("UIGridLayout", scroll)
			gridLayout.CellSize = UDim2.new(0, 260, 0, 70)
			gridLayout.CellPadding = UDim2.new(0, 15, 0, 15)
		end

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
				btn.BackgroundColor3 = InterfaceConfig.AccentColor
				btn.BackgroundTransparency = 0
			else
				btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				btn.BackgroundTransparency = 1
			end
		end
	end

	for _, name in ipairs(categories) do
		createTabContent(name)

		local btn = Instance.new("TextButton", navContainer)
		btn.Size = UDim2.new(1, 0, 0, 36)
		btn.Text = "    " .. name
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.TextSize = 14
		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold)
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

		tabButtons[name] = btn
		btn.MouseButton1Click:Connect(function()
			switchTab(name)
		end)
	end

	switchTab("Visuals")

	--------------------------------------------------------------------------------
	-- SETTINGS MODAL + ANIMATIONS
	--------------------------------------------------------------------------------
	local settingsModal = Instance.new("Frame")
	settingsModal.Name = "SettingsModal"
	settingsModal.Size = UDim2.new(0, 240, 0, 0)
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
	modalPadding.PaddingLeft = UDim.new(0, 12)
	modalPadding.PaddingRight = UDim.new(0, 12)

	local modalLayout = Instance.new("UIListLayout", settingsModal)
	modalLayout.Padding = UDim.new(0, 8)
	modalLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local function openSettingsModal(x, y)
		settingsModal.Position = UDim2.new(0, x, 0, y)
		settingsModal.Visible = true
		settingsModal.BackgroundTransparency = 1
		modalStroke.Transparency = 1

		for _, child in ipairs(settingsModal:GetChildren()) do
			if child:IsA("TextLabel") or child:IsA("TextButton") then
				child.TextTransparency = 1
				if child:IsA("TextButton") then
					child.BackgroundTransparency = 1
				end
			end
		end

		TweenService:Create(settingsModal, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0
		}):Play()

		TweenService:Create(modalStroke, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 0
		}):Play()

		task.delay(0.05, function()
			for _, child in ipairs(settingsModal:GetChildren()) do
				if child:IsA("TextLabel") or child:IsA("TextButton") then
					TweenService:Create(child, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						TextTransparency = 0
					}):Play()
					if child:IsA("TextButton") then
						TweenService:Create(child, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							BackgroundTransparency = 0
						}):Play()
					end
				end
			end
		end)
	end

	local function closeSettingsModal()
		TweenService:Create(settingsModal, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			BackgroundTransparency = 1
		}):Play()

		TweenService:Create(modalStroke, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Transparency = 1
		}):Play()

		for _, child in ipairs(settingsModal:GetChildren()) do
			if child:IsA("TextLabel") or child:IsA("TextButton") then
				TweenService:Create(child, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					TextTransparency = 1
				}):Play()
				if child:IsA("TextButton") then
					TweenService:Create(child, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
						BackgroundTransparency = 1
					}):Play()
				end
			end
		end

		task.delay(0.19, function()
			settingsModal.Visible = false
		end)
	end

	UserInputService.InputBegan:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2) and settingsModal.Visible then
			local mousePos = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
			local mPos = settingsModal.AbsolutePosition
			local mSize = settingsModal.AbsoluteSize
			if mousePos.X < mPos.X or mousePos.X > (mPos.X + mSize.X) or mousePos.Y < mPos.Y or mousePos.Y > (mPos.Y + mSize.Y) then
				closeSettingsModal()
			end
		end
	end)

	--------------------------------------------------------------------------------
	-- UPDATE INTERFACE COLOR
	--------------------------------------------------------------------------------
	local function updateInterfaceColor(newColor)
		InterfaceConfig.AccentColor = newColor
		wmStroke.Color = newColor
		thStroke.Color = newColor
		healthBarFill.BackgroundColor3 = newColor

		for name, btn in pairs(tabButtons) do
			if btn.BackgroundTransparency == 0 then
				btn.BackgroundColor3 = newColor
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

		local toggleCircle = Instance.new("Frame", toggleBtn)
		toggleCircle.Size = UDim2.new(0, 14, 0, 14)
		toggleCircle.Position = defaultValue and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
		toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		toggleCircle.BorderSizePixel = 0
		Instance.new("UICorner", toggleCircle).CornerRadius = UDim.new(1, 0)

		local state = defaultValue

		local function setVisualState(newState)
			state = newState
			local targetBg = state and InterfaceConfig.AccentColor or Color3.fromRGB(45, 45, 55)
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
				local mousePos = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
				onRightClick()
				openSettingsModal(mousePos.X + 5, mousePos.Y - 10)
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
				TweenService:Create(btn, TweenInfo.new(0.2), {
					BackgroundColor3 = state and InterfaceConfig.AccentColor or Color3.fromRGB(35, 35, 45)
				}):Play()
				TweenService:Create(circle, TweenInfo.new(0.2), {
					Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
				}):Play()
				callback(state)
			end)
		end

		addToggle("Боксы (Boxes)", ESPConfig.Boxes, function(v) ESPConfig.Boxes = v end)
		addToggle("Имена (Names)", ESPConfig.Names, function(v) ESPConfig.Names = v end)
		addToggle("Здоровье (Health)", ESPConfig.Health, function(v) ESPConfig.Health = v end)
	end)

	cardReferences.WorldParticles = createModuleCard(tabs["Visuals"], "World Particles", "ПКМ - настройки частиц", ParticleConfig.Enabled, function(v)
		ParticleConfig.Enabled = v
	end, function()
		for _, child in ipairs(settingsModal:GetChildren()) do
			if not (child:IsA("UIListLayout") or child:IsA("UICorner") or child:IsA("UIStroke") or child:IsA("UIPadding")) then
				child:Destroy()
			end
		end

		local typeHeader = Instance.new("TextLabel", settingsModal)
		typeHeader.Size = UDim2.new(1, 0, 0, 20)
		typeHeader.BackgroundTransparency = 1
		typeHeader.Text = "Тип частиц"
		typeHeader.TextColor3 = Color3.fromRGB(140, 140, 160)
		typeHeader.TextSize = 12
		typeHeader.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold)
		typeHeader.TextXAlignment = Enum.TextXAlignment.Left
		typeHeader.ZIndex = 101

		local particleTypes = {
			{Name = "💵  Dollars", Value = "Dollars"},
			{Name = "⭐  Stars", Value = "Stars"},
			{Name = "❤️  Hearts", Value = "Hearts"}
		}

		local typeButtons = {}

		for _, item in ipairs(particleTypes) do
			local btn = Instance.new("TextButton", settingsModal)
			btn.Size = UDim2.new(1, 0, 0, 32)
			btn.BackgroundColor3 = (ParticleConfig.Type == item.Value) and InterfaceConfig.AccentColor or Color3.fromRGB(30, 30, 38)
			btn.Text = item.Name
			btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			btn.TextSize = 14
			btn.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold)
			btn.AutoButtonColor = false
			btn.ZIndex = 101
			Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

			typeButtons[item.Value] = btn

			btn.MouseButton1Click:Connect(function()
				ParticleConfig.Type = item.Value
				for value, b in pairs(typeButtons) do
					TweenService:Create(b, TweenInfo.new(0.18), {
						BackgroundColor3 = (value == item.Value) and InterfaceConfig.AccentColor or Color3.fromRGB(30, 30, 38)
					}):Play()
				end
			end)
		end

		local colorHeader = Instance.new("TextLabel", settingsModal)
		colorHeader.Size = UDim2.new(1, 0, 0, 20)
		colorHeader.BackgroundTransparency = 1
		colorHeader.Text = "Цвет"
		colorHeader.TextColor3 = Color3.fromRGB(140, 140, 160)
		colorHeader.TextSize = 12
		colorHeader.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold)
		colorHeader.TextXAlignment = Enum.TextXAlignment.Left
		colorHeader.ZIndex = 101

		local colors = {
			{Name = "Золотой", Color = Color3.fromRGB(255, 215, 0)},
			{Name = "Фиолетовый", Color = Color3.fromRGB(168, 85, 247)},
			{Name = "Красный", Color = Color3.fromRGB(255, 80, 80)},
			{Name = "Голубой", Color = Color3.fromRGB(80, 180, 255)},
			{Name = "Зелёный", Color = Color3.fromRGB(80, 255, 120)},
			{Name = "Белый", Color = Color3.fromRGB(255, 255, 255)}
		}

		local colorButtons = {}

		for _, item in ipairs(colors) do
			local btn = Instance.new("TextButton", settingsModal)
			btn.Size = UDim2.new(1, 0, 0, 32)
			btn.BackgroundColor3 = (ParticleConfig.Color == item.Color) and item.Color or Color3.fromRGB(30, 30, 38)
			btn.Text = item.Name
			btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			btn.TextSize = 14
			btn.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold)
			btn.AutoButtonColor = false
			btn.ZIndex = 101
			Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

			local stroke = Instance.new("UIStroke", btn)
			stroke.Color = item.Color
			stroke.Thickness = 1.2
			stroke.Transparency = (ParticleConfig.Color == item.Color) and 0 or 0.7

			colorButtons[item.Name] = {btn = btn, stroke = stroke, color = item.Color}

			btn.MouseButton1Click:Connect(function()
				ParticleConfig.Color = item.Color
				for _, data in pairs(colorButtons) do
					local isSelected = (data.color == item.Color)
					TweenService:Create(data.btn, TweenInfo.new(0.18), {
						BackgroundColor3 = isSelected and item.Color or Color3.fromRGB(30, 30, 38)
					}):Play()
					TweenService:Create(data.stroke, TweenInfo.new(0.18), {
						Transparency = isSelected and 0 or 0.7
					}):Play()
				end
			end)
		end
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

	cardReferences.InterfaceColor = createModuleCard(tabs["HUD"], "Interface Color", "ПКМ - цвет интерфейса", true, function() end, function()
		for _, child in ipairs(settingsModal:GetChildren()) do
			if not (child:IsA("UIListLayout") or child:IsA("UICorner") or child:IsA("UIStroke") or child:IsA("UIPadding")) then
				child:Destroy()
			end
		end

		local header = Instance.new("TextLabel", settingsModal)
		header.Size = UDim2.new(1, 0, 0, 20)
		header.BackgroundTransparency = 1
		header.Text = "Цвет интерфейса"
		header.TextColor3 = Color3.fromRGB(140, 140, 160)
		header.TextSize = 12
		header.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold)
		header.TextXAlignment = Enum.TextXAlignment.Left
		header.ZIndex = 101

		local colors = {
			{Name = "Фиолетовый", Color = Color3.fromRGB(168, 85, 247)},
			{Name = "Синий", Color = Color3.fromRGB(59, 130, 246)},
			{Name = "Голубой", Color = Color3.fromRGB(34, 211, 238)},
			{Name = "Зелёный", Color = Color3.fromRGB(34, 197, 94)},
			{Name = "Жёлтый", Color = Color3.fromRGB(234, 179, 8)},
			{Name = "Оранжевый", Color = Color3.fromRGB(249, 115, 22)},
			{Name = "Красный", Color = Color3.fromRGB(239, 68, 68)},
			{Name = "Розовый", Color = Color3.fromRGB(236, 72, 153)},
			{Name = "Белый", Color = Color3.fromRGB(255, 255, 255)}
		}

		local colorButtons = {}

		for _, item in ipairs(colors) do
			local btn = Instance.new("TextButton", settingsModal)
			btn.Size = UDim2.new(1, 0, 0, 32)
			btn.BackgroundColor3 = (InterfaceConfig.AccentColor == item.Color) and item.Color or Color3.fromRGB(30, 30, 38)
			btn.Text = item.Name
			btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			btn.TextSize = 14
			btn.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold)
			btn.AutoButtonColor = false
			btn.ZIndex = 101
			Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

			local stroke = Instance.new("UIStroke", btn)
			stroke.Color = item.Color
			stroke.Thickness = 1.3
			stroke.Transparency = (InterfaceConfig.AccentColor == item.Color) and 0 or 0.6

			colorButtons[item.Name] = {
				btn = btn,
				stroke = stroke,
				color = item.Color
			}

			btn.MouseButton1Click:Connect(function()
				updateInterfaceColor(item.Color)

				for name, data in pairs(colorButtons) do
					local isSelected = (data.color == item.Color)
					TweenService:Create(data.btn, TweenInfo.new(0.18), {
						BackgroundColor3 = isSelected and item.Color or Color3.fromRGB(30, 30, 38)
					}):Play()
					TweenService:Create(data.stroke, TweenInfo.new(0.18), {
						Transparency = isSelected and 0 or 0.6
					}):Play()
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
	if origAtmosphere then
		origAtmosphere:SetAttribute("OriginalDensity", origAtmosphere.Density)
	end

	cardReferences.Fullbright = createModuleCard(tabs["Utilities"], "Fullbright", "Максимальная яркость окружения", false, function(v)
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
			if origAtmosphere then
				origAtmosphere.Density = 0
			end
		else
			Lighting.FogEnd = origFogEnd
			Lighting.FogStart = origFogStart
			if origAtmosphere then
				origAtmosphere.Density = origAtmosphere:GetAttribute("OriginalDensity") or 0.3
			end
		end
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
	-- CONFIGS SYSTEM
	--------------------------------------------------------------------------------
	local HAS_FS = (writefile ~= nil and readfile ~= nil and listfiles ~= nil and delfile ~= nil)
	local CONFIG_FOLDER = "FlameVisuals_Configs"
	local memoryConfigs = {}

	local function serializeConfig()
		return {
			ESP = {
				Enabled = ESPConfig.Enabled,
				Boxes = ESPConfig.Boxes,
				Names = ESPConfig.Names,
				Health = ESPConfig.Health
			},
			TargetHUD = {
				Enabled = TargetHUDConfig.Enabled
			},
			Particles = {
				Enabled = ParticleConfig.Enabled,
				Type = ParticleConfig.Type,
				Color = {ParticleConfig.Color.R, ParticleConfig.Color.G, ParticleConfig.Color.B}
			},
			Interface = {
				AccentColor = {InterfaceConfig.AccentColor.R, InterfaceConfig.AccentColor.G, InterfaceConfig.AccentColor.B}
			},
			Watermark = {
				Enabled = watermarkFrame.Visible
			}
		}
	end

	local function applyConfig(data)
		if not data then return end

		if data.ESP then
			ESPConfig.Enabled = data.ESP.Enabled or false
			ESPConfig.Boxes = data.ESP.Boxes ~= false
			ESPConfig.Names = data.ESP.Names ~= false
			ESPConfig.Health = data.ESP.Health ~= false
			if cardReferences.ESP then
				cardReferences.ESP.SetState(ESPConfig.Enabled)
			end
		end

		if data.TargetHUD then
			TargetHUDConfig.Enabled = data.TargetHUD.Enabled or false
			if cardReferences.TargetHUD then
				cardReferences.TargetHUD.SetState(TargetHUDConfig.Enabled)
			end
		end

		if data.Particles then
			ParticleConfig.Enabled = data.Particles.Enabled or false
			ParticleConfig.Type = data.Particles.Type or "Stars"
			if data.Particles.Color then
				ParticleConfig.Color = Color3.new(data.Particles.Color[1], data.Particles.Color[2], data.Particles.Color[3])
			end
			if cardReferences.WorldParticles then
				cardReferences.WorldParticles.SetState(ParticleConfig.Enabled)
			end
		end

		if data.Interface and data.Interface.AccentColor then
			local c = data.Interface.AccentColor
			updateInterfaceColor(Color3.new(c[1], c[2], c[3]))
		end

		if data.Watermark then
			local state = data.Watermark.Enabled ~= false
			watermarkFrame.Visible = state
			if cardReferences.Watermark then
				cardReferences.Watermark.SetState(state)
			end
		end
	end

	local function saveConfigToFile(name)
		local data = serializeConfig()
		local json = HttpService:JSONEncode(data)

		if HAS_FS then
			if isfolder and not isfolder(CONFIG_FOLDER) then
				pcall(makefolder, CONFIG_FOLDER)
			end
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
				local ok, data = pcall(function()
					return HttpService:JSONDecode(content)
				end)
				if ok then return data end
			end
		else
			if memoryConfigs[name] then
				local ok, data = pcall(function()
					return HttpService:JSONDecode(memoryConfigs[name])
				end)
				if ok then return data end
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
						if fileName then
							table.insert(list, fileName)
						end
					end
				end
			end
		else
			for name, _ in pairs(memoryConfigs) do
				table.insert(list, name)
			end
		end
		table.sort(list)
		return list
	end

	-- UI Configs
	local configsTab = tabs["Configs"]

	local configsListLayout = Instance.new("UIListLayout")
	configsListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	configsListLayout.Padding = UDim.new(0, 10)
	configsListLayout.Parent = configsTab

	local createBar = Instance.new("Frame")
	createBar.Size = UDim2.new(1, -10, 0, 42)
	createBar.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
	createBar.BorderSizePixel = 0
	createBar.Parent = configsTab
	Instance.new("UICorner", createBar).CornerRadius = UDim.new(0, 8)

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
	configNameInput.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold)
	configNameInput.TextXAlignment = Enum.TextXAlignment.Left
	configNameInput.Parent = createBar
	Instance.new("UICorner", configNameInput).CornerRadius = UDim.new(0, 6)
	Instance.new("UIPadding", configNameInput).PaddingLeft = UDim.new(0, 10)

	local createBtn = Instance.new("TextButton")
	createBtn.Size = UDim2.new(0, 95, 1, -12)
	createBtn.Position = UDim2.new(1, -105, 0, 6)
	createBtn.BackgroundColor3 = InterfaceConfig.AccentColor
	createBtn.Text = "Создать"
	createBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	createBtn.TextSize = 13
	createBtn.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold)
	createBtn.Parent = createBar
	Instance.new("UICorner", createBtn).CornerRadius = UDim.new(0, 6)

	local cardsContainer = Instance.new("Frame")
	cardsContainer.Size = UDim2.new(1, -10, 0, 0)
	cardsContainer.AutomaticSize = Enum.AutomaticSize.Y
	cardsContainer.BackgroundTransparency = 1
	cardsContainer.Parent = configsTab

	local cardsLayout = Instance.new("UIListLayout")
	cardsLayout.SortOrder = Enum.SortOrder.LayoutOrder
	cardsLayout.Padding = UDim.new(0, 8)
	cardsLayout.Parent = cardsContainer

	local function refreshConfigList()
		for _, child in ipairs(cardsContainer:GetChildren()) do
			if child:IsA("Frame") or child:IsA("TextLabel") then
				child:Destroy()
			end
		end

		local names = getAllConfigNames()

		if #names == 0 then
			local emptyLabel = Instance.new("TextLabel")
			emptyLabel.Size = UDim2.new(1, 0, 0, 40)
			emptyLabel.BackgroundTransparency = 1
			emptyLabel.Text = "Нет сохранённых конфигов"
			emptyLabel.TextColor3 = Color3.fromRGB(120, 120, 140)
			emptyLabel.TextSize = 14
			emptyLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold)
			emptyLabel.Parent = cardsContainer
			return
		end

		for _, configName in ipairs(names) do
			local card = Instance.new("Frame")
			card.Size = UDim2.new(1, 0, 0, 48)
			card.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
			card.BorderSizePixel = 0
			card.Parent = cardsContainer
			Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

			local titleLabel = Instance.new("TextLabel")
			titleLabel.Size = UDim2.new(1, -200, 1, 0)
			titleLabel.Position = UDim2.new(0, 14, 0, 0)
			titleLabel.BackgroundTransparency = 1
			titleLabel.Text = configName
			titleLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
			titleLabel.TextSize = 14
			titleLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold)
			titleLabel.TextXAlignment = Enum.TextXAlignment.Left
			titleLabel.Parent = card

			local loadBtn = Instance.new("TextButton")
			loadBtn.Size = UDim2.new(0, 70, 0, 28)
			loadBtn.Position = UDim2.new(1, -160, 0.5, -14)
			loadBtn.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
			loadBtn.Text = "Load"
			loadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			loadBtn.TextSize = 13
			loadBtn.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold)
			loadBtn.Parent = card
			Instance.new("UICorner", loadBtn).CornerRadius = UDim.new(0, 6)

			local deleteBtn = Instance.new("TextButton")
			deleteBtn.Size = UDim2.new(0, 70, 0, 28)
			deleteBtn.Position = UDim2.new(1, -80, 0.5, -14)
			deleteBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
			deleteBtn.Text = "Delete"
			deleteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			deleteBtn.TextSize = 13
			deleteBtn.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold)
			deleteBtn.Parent = card
			Instance.new("UICorner", deleteBtn).CornerRadius = UDim.new(0, 6)

			loadBtn.MouseButton1Click:Connect(function()
				local data = loadConfigFromFile(configName)
				if data then
					applyConfig(data)
				end
			end)

			deleteBtn.MouseButton1Click:Connect(function()
				deleteConfigFile(configName)
				refreshConfigList()
			end)
		end
	end

	createBtn.MouseButton1Click:Connect(function()
		local name = configNameInput.Text:gsub("%s+", "")
		if name == "" then return end
		saveConfigToFile(name)
		configNameInput.Text = ""
		refreshConfigList()
	end)

	refreshConfigList()

	--------------------------------------------------------------------------------
	-- WORLD PARTICLES SYSTEM
	--------------------------------------------------------------------------------
	local particleFolder = Instance.new("Folder")
	particleFolder.Name = "FlameParticles"
	particleFolder.Parent = workspace

	local particleSymbols = {
		Dollars = "💵",
		Stars = "⭐",
		Hearts = "❤️"
	}

	local activeParticles = {}

	local function createFloatingParticle()
		if not ParticleConfig.Enabled then return end
		local character = LocalPlayer.Character
		if not character or not character:FindFirstChild("HumanoidRootPart") then return end

		local root = character.HumanoidRootPart
		local offset = Vector3.new(
			math.random(-8, 8),
			math.random(2, 6),
			math.random(-8, 8)
		)

		local part = Instance.new("Part")
		part.Size = Vector3.new(0.1, 0.1, 0.1)
		part.Transparency = 1
		part.Anchored = true
		part.CanCollide = false
		part.Position = root.Position + offset
		part.Parent = particleFolder

		local billboard = Instance.new("BillboardGui")
		billboard.Size = UDim2.new(0, 30, 0, 30)
		billboard.AlwaysOnTop = true
		billboard.Parent = part

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.Text = particleSymbols[ParticleConfig.Type] or "⭐"
		label.TextColor3 = ParticleConfig.Color
		label.TextSize = 20
		label.Font = Enum.Font.SourceSansBold
		label.Parent = billboard

		table.insert(activeParticles, {
			part = part,
			start = tick(),
			max = 2.5 + math.random() * 1.5
		})
	end

	task.spawn(function()
		while true do
			task.wait(0.35)
			if ParticleConfig.Enabled then
				createFloatingParticle()
			end
		end
	end)

	RunService.Heartbeat:Connect(function()
		for i = #activeParticles, 1, -1 do
			local p = activeParticles[i]
			local age = tick() - p.start
			if age >= p.max then
				p.part:Destroy()
				table.remove(activeParticles, i)
			else
				p.part.Position = p.part.Position + Vector3.new(0, 0.04, 0)
				local gui = p.part:FindFirstChildOfClass("BillboardGui")
				if gui then
					local label = gui:FindFirstChildOfClass("TextLabel")
					if label then
						label.TextTransparency = age / p.max
					end
				end
			end
		end
	end)

	--------------------------------------------------------------------------------
	-- ESP SYSTEM
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
		nameLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold)
		nameLabel.TextStrokeTransparency = 0.4
		nameLabel.Visible = false
		nameLabel.Parent = espContainer

		local hpLabel = Instance.new("TextLabel")
		hpLabel.BackgroundTransparency = 1
		hpLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
		hpLabel.TextSize = 12
		hpLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold)
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
	-- HOTKEYS
	--------------------------------------------------------------------------------
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		local isTyping = UserInputService:GetFocusedTextBox() ~= nil
		if not isTyping then
			if input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.Insert then
				mainGui.Visible = not mainGui.Visible
				if not mainGui.Visible then
					closeSettingsModal()
				end
			end
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