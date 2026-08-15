-- LocalScript: FlameVisuals Client (Mobile Optimized)
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

local isMobile = UserInputService.TouchEnabled

--------------------------------------------------------------------------------
-- 1. НАСТРОЙКИ
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
local AutoLoadConfig = {
	Enabled = false
}

--------------------------------------------------------------------------------
-- 2. SCREEN GUI
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
-- ФУНКЦИЯ ПЕРЕТАСКИВАНИЯ
--------------------------------------------------------------------------------
local function makeDraggable(frame, onClick)
	local dragging = false
	local dragStart = nil
	local startPos = nil
	local hasDragged = false
	local dragThreshold = 8

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			hasDragged = false
			dragStart = input.Position
			startPos = frame.Position

			local connection
			connection = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					if not hasDragged and onClick then
						onClick()
					end
					if connection then connection:Disconnect() end
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			if not hasDragged and (math.abs(delta.X) > dragThreshold or math.abs(delta.Y) > dragThreshold) then
				hasDragged = true
			end
			if hasDragged then
				frame.Position = UDim2.new(
					startPos.X.Scale,
					startPos.X.Offset + delta.X,
					startPos.Y.Scale,
					startPos.Y.Offset + delta.Y
				)
			end
		end
	end)
end

--------------------------------------------------------------------------------
-- 3. TARGET HUD (уменьшенный)
--------------------------------------------------------------------------------
local targetHudFrame = Instance.new("Frame")
targetHudFrame.Name = "TargetHUD"
targetHudFrame.Size = UDim2.new(0, 200, 0, 58)
targetHudFrame.Position = UDim2.new(0.5, -100, 0.72, 0)
targetHudFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
targetHudFrame.BorderSizePixel = 0
targetHudFrame.Visible = false
targetHudFrame.Parent = screenGui
makeDraggable(targetHudFrame)

local thCorner = Instance.new("UICorner")
thCorner.CornerRadius = UDim.new(0, 10)
thCorner.Parent = targetHudFrame

local thStroke = Instance.new("UIStroke")
thStroke.Color = Color3.fromRGB(30, 30, 40)
thStroke.Thickness = 1.2
thStroke.Parent = targetHudFrame

local avatarImg = Instance.new("ImageLabel")
avatarImg.Name = "Avatar"
avatarImg.Size = UDim2.new(0, 36, 0, 36)
avatarImg.Position = UDim2.new(0, 9, 0, 8)
avatarImg.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
avatarImg.BorderSizePixel = 0
avatarImg.Parent = targetHudFrame

local avatarCorner = Instance.new("UICorner")
avatarCorner.CornerRadius = UDim.new(0, 7)
avatarCorner.Parent = avatarImg

local targetNameLabel = Instance.new("TextLabel")
targetNameLabel.Name = "TargetName"
targetNameLabel.Size = UDim2.new(1, -55, 0, 18)
targetNameLabel.Position = UDim2.new(0, 52, 0, 6)
targetNameLabel.BackgroundTransparency = 1
targetNameLabel.Text = "Player"
targetNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
targetNameLabel.TextSize = 14
targetNameLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
targetNameLabel.TextXAlignment = Enum.TextXAlignment.Left
targetNameLabel.Parent = targetHudFrame

local targetHpLabel = Instance.new("TextLabel")
targetHpLabel.Name = "TargetHP"
targetHpLabel.Size = UDim2.new(1, -55, 0, 15)
targetHpLabel.Position = UDim2.new(0, 52, 0, 24)
targetHpLabel.BackgroundTransparency = 1
targetHpLabel.Text = "HP / 100.0"
targetHpLabel.TextColor3 = Color3.fromRGB(170, 170, 185)
targetHpLabel.TextSize = 12
targetHpLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
targetHpLabel.TextXAlignment = Enum.TextXAlignment.Left
targetHpLabel.Parent = targetHudFrame

local healthBarBg = Instance.new("Frame")
healthBarBg.Name = "HealthBarBG"
healthBarBg.Size = UDim2.new(1, -18, 0, 6)
healthBarBg.Position = UDim2.new(0, 9, 0, 46)
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
-- 4. WATERMARK
--------------------------------------------------------------------------------
local watermarkFrame = Instance.new("Frame")
watermarkFrame.Name = "WatermarkFrame"
watermarkFrame.Position = UDim2.new(0, 15, 0, 15)
watermarkFrame.Size = UDim2.new(0, 0, 0, 28)
watermarkFrame.AutomaticSize = Enum.AutomaticSize.X
watermarkFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
watermarkFrame.BackgroundTransparency = 0.15
watermarkFrame.BorderSizePixel = 0
watermarkFrame.Visible = true
watermarkFrame.Parent = screenGui
makeDraggable(watermarkFrame)

local wmCorner = Instance.new("UICorner")
wmCorner.CornerRadius = UDim.new(0, 14)
wmCorner.Parent = watermarkFrame

local wmStroke = Instance.new("UIStroke")
wmStroke.Color = Color3.fromRGB(25, 25, 35)
wmStroke.Thickness = 1
wmStroke.Transparency = 0.4
wmStroke.Parent = watermarkFrame

local wmLayout = Instance.new("UIListLayout")
wmLayout.FillDirection = Enum.FillDirection.Horizontal
wmLayout.VerticalAlignment = Enum.VerticalAlignment.Center
wmLayout.Padding = UDim.new(0, 6)
wmLayout.Parent = watermarkFrame

local wmPadding = Instance.new("UIPadding")
wmPadding.PaddingLeft = UDim.new(0, 10)
wmPadding.PaddingRight = UDim.new(0, 12)
wmPadding.Parent = watermarkFrame

local wmIcon = Instance.new("TextLabel")
wmIcon.Size = UDim2.new(0, 14, 0, 14)
wmIcon.BackgroundTransparency = 1
wmIcon.Text = "🔥"
wmIcon.TextSize = 12
wmIcon.Parent = watermarkFrame

local wmBrand = Instance.new("TextLabel")
wmBrand.AutomaticSize = Enum.AutomaticSize.X
wmBrand.Size = UDim2.new(0, 0, 1, 0)
wmBrand.BackgroundTransparency = 1
wmBrand.Text = "FlameVisuals"
wmBrand.TextColor3 = Color3.fromRGB(255, 255, 255)
wmBrand.TextSize = 13
wmBrand.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
wmBrand.Parent = watermarkFrame

local wmStats = Instance.new("TextLabel")
wmStats.AutomaticSize = Enum.AutomaticSize.X
wmStats.Size = UDim2.new(0, 0, 1, 0)
wmStats.BackgroundTransparency = 1
wmStats.TextColor3 = Color3.fromRGB(160, 160, 175)
wmStats.TextSize = 13
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
		wmStats.Text = string.format("/ %s / %d ms / %d FPS", LocalPlayer.Name, ping, fps)
	end
end)

--------------------------------------------------------------------------------
-- 5. ГЛАВНОЕ МЕНЮ (компактное)
--------------------------------------------------------------------------------
local menuWidth = isMobile and 340 or 750
local menuHeight = isMobile and 520 or 480
local sidebarWidth = isMobile and 110 or 180

local mainGui = Instance.new("Frame")
mainGui.Name = "MainMenu"
mainGui.Size = UDim2.new(0, menuWidth, 0, menuHeight)
mainGui.Position = UDim2.new(0.5, -menuWidth/2, 0.5, -menuHeight/2)
mainGui.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
mainGui.BorderSizePixel = 0
mainGui.Visible = false
mainGui.Parent = screenGui
makeDraggable(mainGui)

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 12)
menuCorner.Parent = mainGui

local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, sidebarWidth, 1, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(11, 11, 14)
sidebar.BorderSizePixel = 0
sidebar.Parent = mainGui

local sidebarCorner = Instance.new("UICorner")
sidebarCorner.CornerRadius = UDim.new(0, 12)
sidebarCorner.Parent = sidebar

local logoContainer = Instance.new("Frame")
logoContainer.Size = UDim2.new(1, -12, 0, 44)
logoContainer.Position = UDim2.new(0, 8, 0, 8)
logoContainer.BackgroundTransparency = 1
logoContainer.Parent = sidebar

local logoIcon = Instance.new("TextLabel")
logoIcon.Size = UDim2.new(0, 20, 1, 0)
logoIcon.BackgroundTransparency = 1
logoIcon.Text = "🔥"
logoIcon.TextSize = isMobile and 15 or 18
logoIcon.Parent = logoContainer

local logoText = Instance.new("TextLabel")
logoText.Size = UDim2.new(1, -24, 1, 0)
logoText.Position = UDim2.new(0, 22, 0, 0)
logoText.BackgroundTransparency = 1
logoText.Text = isMobile and "Flame" or "FlameVisuals"
logoText.TextColor3 = Color3.fromRGB(255, 255, 255)
logoText.TextSize = isMobile and 14 or 17
logoText.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
logoText.TextXAlignment = Enum.TextXAlignment.Left
logoText.Parent = logoContainer

local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -(sidebarWidth + 8), 1, -14)
contentArea.Position = UDim2.new(0, sidebarWidth + 4, 0, 7)
contentArea.BackgroundTransparency = 1
contentArea.Parent = mainGui

local headerText = Instance.new("TextLabel")
headerText.Size = UDim2.new(1, 0, 0, 30)
headerText.BackgroundTransparency = 1
headerText.Text = "Visuals"
headerText.TextColor3 = Color3.fromRGB(255, 255, 255)
headerText.TextSize = isMobile and 16 or 20
headerText.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
headerText.TextXAlignment = Enum.TextXAlignment.Left
headerText.Parent = contentArea

local tabs = {}
local tabButtons = {}
local categories = {"Visuals", "HUD", "Utilities", "Configs"}

local navContainer = Instance.new("Frame")
navContainer.Size = UDim2.new(1, -8, 0, 210)
navContainer.Position = UDim2.new(0, 4, 0, 52)
navContainer.BackgroundTransparency = 1
navContainer.Parent = sidebar

local navList = Instance.new("UIListLayout")
navList.Padding = UDim.new(0, 4)
navList.Parent = navContainer

local function createTabContent(name)
	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = name .. "Tab"
	scroll.Size = UDim2.new(1, -2, 1, -36)
	scroll.Position = UDim2.new(0, 0, 0, 34)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 3
	scroll.ScrollBarImageColor3 = Color3.fromRGB(168, 85, 247)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.Visible = false
	scroll.Parent = contentArea

	local gridLayout = Instance.new("UIGridLayout")
	if isMobile then
		gridLayout.CellSize = UDim2.new(0, 200, 0, 58)
		gridLayout.CellPadding = UDim2.new(0, 6, 0, 6)
	else
		gridLayout.CellSize = UDim2.new(0, 260, 0, 70)
		gridLayout.CellPadding = UDim2.new(0, 15, 0, 15)
	end
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
	btn.Size = UDim2.new(1, 0, 0, isMobile and 30 or 36)
	btn.Text = "  " .. name
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextSize = isMobile and 12 or 14
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
	btn.Parent = navContainer

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 6)
	btnCorner.Parent = btn

	tabButtons[name] = btn
	btn.MouseButton1Click:Connect(function()
		switchTab(name)
	end)
end

switchTab("Visuals")

--------------------------------------------------------------------------------
-- 6. МОДАЛЬНОЕ ОКНО ESP
--------------------------------------------------------------------------------
local settingsModal = Instance.new("Frame")
settingsModal.Name = "SettingsModal"
settingsModal.Size = UDim2.new(0, 200, 0, 0)
settingsModal.AutomaticSize = Enum.AutomaticSize.Y
settingsModal.BackgroundColor3 = Color3.fromRGB(13, 13, 18)
settingsModal.BorderSizePixel = 0
settingsModal.Visible = false
settingsModal.ZIndex = 100
settingsModal.Parent = screenGui

local modalCorner = Instance.new("UICorner")
modalCorner.CornerRadius = UDim.new(0, 12)
modalCorner.Parent = settingsModal

local modalStroke = Instance.new("UIStroke")
modalStroke.Color = Color3.fromRGB(25, 25, 35)
modalStroke.Thickness = 1
modalStroke.Parent = settingsModal

local modalPadding = Instance.new("UIPadding")
modalPadding.PaddingTop = UDim.new(0, 10)
modalPadding.PaddingBottom = UDim.new(0, 10)
modalPadding.PaddingLeft = UDim.new(0, 10)
modalPadding.PaddingRight = UDim.new(0, 10)
modalPadding.Parent = settingsModal

local modalLayout = Instance.new("UIListLayout")
modalLayout.Padding = UDim.new(0, 6)
modalLayout.SortOrder = Enum.SortOrder.LayoutOrder
modalLayout.Parent = settingsModal

UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.Touch then
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
	header.Size = UDim2.new(1, 0, 0, 16)
	header.BackgroundTransparency = 1
	header.Text = text
	header.TextColor3 = Color3.fromRGB(120, 120, 140)
	header.TextSize = 12
	header.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	header.TextXAlignment = Enum.TextXAlignment.Center
	header.ZIndex = 101
	header.Parent = settingsModal
end

local function createRefToggle(title, defaultValue, onToggle)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 24)
	row.BackgroundTransparency = 1
	row.ZIndex = 101
	row.Parent = settingsModal

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -42, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = title
	label.TextColor3 = Color3.fromRGB(220, 220, 230)
	label.TextSize = 12
	label.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.ZIndex = 101
	label.Parent = row

	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Size = UDim2.new(0, 34, 0, 18)
	toggleBtn.Position = UDim2.new(1, -34, 0.5, -9)
	toggleBtn.BackgroundColor3 = defaultValue and Color3.fromRGB(120, 80, 230) or Color3.fromRGB(35, 35, 45)
	toggleBtn.Text = ""
	toggleBtn.AutoButtonColor = false
	toggleBtn.ZIndex = 101
	toggleBtn.Parent = row

	local toggleCorner = Instance.new("UICorner")
	toggleCorner.CornerRadius = UDim.new(1, 0)
	toggleCorner.Parent = toggleBtn

	local toggleCircle = Instance.new("Frame")
	toggleCircle.Size = UDim2.new(0, 12, 0, 12)
	toggleCircle.Position = defaultValue and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
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
		local targetPos = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
		TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = targetBg}):Play()
		TweenService:Create(toggleCircle, TweenInfo.new(0.2), {Position = targetPos}):Play()
		if onToggle then onToggle(state) end
	end)
end

--------------------------------------------------------------------------------
-- 7. КАРТОЧКИ МОДУЛЕЙ
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
	cardTitle.Size = UDim2.new(1, -48, 0, isMobile and 18 or 24)
	cardTitle.Position = UDim2.new(0, 10, 0, isMobile and 6 or 9)
	cardTitle.BackgroundTransparency = 1
	cardTitle.Text = title
	cardTitle.TextColor3 = Color3.fromRGB(240, 240, 245)
	cardTitle.TextSize = isMobile and 13 or 15
	cardTitle.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	cardTitle.TextXAlignment = Enum.TextXAlignment.Left
	cardTitle.Parent = card

	local cardDesc = Instance.new("TextLabel")
	cardDesc.Size = UDim2.new(1, -16, 0, isMobile and 18 or 22)
	cardDesc.Position = UDim2.new(0, 10, 0, isMobile and 26 or 33)
	cardDesc.BackgroundTransparency = 1
	cardDesc.Text = description
	cardDesc.TextColor3 = Color3.fromRGB(120, 120, 135)
	cardDesc.TextSize = isMobile and 11 or 12
	cardDesc.TextXAlignment = Enum.TextXAlignment.Left
	cardDesc.Parent = card

	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Size = UDim2.new(0, isMobile and 34 or 40, 0, isMobile and 17 or 20)
	toggleBtn.Position = UDim2.new(1, isMobile and -42 or -50, 0, isMobile and 8 or 11)
	toggleBtn.BackgroundColor3 = defaultValue and Color3.fromRGB(168, 85, 247) or Color3.fromRGB(45, 45, 55)
	toggleBtn.Text = ""
	toggleBtn.AutoButtonColor = false
	toggleBtn.Parent = card

	local toggleCorner = Instance.new("UICorner")
	toggleCorner.CornerRadius = UDim.new(0, 9)
	toggleCorner.Parent = toggleBtn

	local toggleCircle = Instance.new("Frame")
	toggleCircle.Size = UDim2.new(0, 12, 0, 12)
	toggleCircle.Position = defaultValue and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
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
		local targetPos = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
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

-- Visuals
cardReferences.ESP = createModuleCard(tabs["Visuals"], "ESP", "ПКМ - настройки", ESPConfig.Enabled, function(v)
	ESPConfig.Enabled = v
end, function()
	for _, child in ipairs(settingsModal:GetChildren()) do
		if not child:IsA("UIListLayout") and not child:IsA("UICorner") and not child:IsA("UIStroke") and not child:IsA("UIPadding") then
			child:Destroy()
		end
	end
	createRefHeader("Настройки ESP")
	createRefToggle("Боксы", ESPConfig.Boxes, function(v) ESPConfig.Boxes = v end)
	createRefToggle("Имена", ESPConfig.Names, function(v) ESPConfig.Names = v end)
	createRefToggle("Здоровье", ESPConfig.Health, function(v) ESPConfig.Health = v end)
end)

-- HUD
cardReferences.Watermark = createModuleCard(tabs["HUD"], "Watermark", "Верхний HUD", true, function(v)
	watermarkFrame.Visible = v
end, nil)

cardReferences.TargetHUD = createModuleCard(tabs["HUD"], "Target HUD", "Инфо о цели", TargetHUDConfig.Enabled, function(v)
	TargetHUDConfig.Enabled = v
	if not v then targetHudFrame.Visible = false end
end, nil)

--------------------------------------------------------------------------------
-- 8. КОНФИГИ
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
				local ok, data = pcall(function() return HttpService:JSONDecode(content) end)
				if ok then return data end
			end
		end
	else
		if memoryConfigs["_AUTOLOAD_PAYLOAD_"] then
			local ok, data = pcall(function() return HttpService:JSONDecode(memoryConfigs["_AUTOLOAD_PAYLOAD_"]) end)
			if ok then return data end
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
		local success, content = pcall(readfile, CONFIG_FOLDER .. "/" .. name .. ".json")
		if success and content then
			local ok, data = pcall(function() return HttpService:JSONDecode(content) end)
			if ok then return data end
		end
	else
		if memoryConfigs[name] then
			local ok, data = pcall(function() return HttpService:JSONDecode(memoryConfigs[name]) end)
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
					if fileName and not fileName:find("^_") then
						table.insert(list, fileName)
					end
				end
			end
		end
	else
		for name in pairs(memoryConfigs) do
			if not name:find("^_") then table.insert(list, name) end
		end
	end
	table.sort(list)
	return list
end

--------------------------------------------------------------------------------
-- 9. UTILITIES
--------------------------------------------------------------------------------
local origAmbient = Lighting.Ambient
local origOutdoor = Lighting.OutdoorAmbient

cardReferences.AutoLoad = createModuleCard(tabs["Utilities"], "AutoLoad", "Автозагрузка", false, function(v)
	AutoLoadConfig.Enabled = v
	saveAutoLoadData(v)
end, nil)

cardReferences.Fullbright = createModuleCard(tabs["Utilities"], "Fullbright", "Макс. яркость", false, function(v)
	if v then
		Lighting.Ambient = Color3.fromRGB(255, 255, 255)
		Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
	else
		Lighting.Ambient = origAmbient
		Lighting.OutdoorAmbient = origOutdoor
	end
	if AutoLoadConfig.Enabled then saveAutoLoadData(true) end
end, nil)

cardReferences.Rejoin = createModuleCard(tabs["Utilities"], "Rejoin", "Перезайти", false, function(v)
	if v then
		TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
	end
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
-- 10. CONFIGS TAB
--------------------------------------------------------------------------------
local configsTab = tabs["Configs"]
local defaultGrid = configsTab:FindFirstChildOfClass("UIGridLayout")
if defaultGrid then defaultGrid:Destroy() end

local configsListLayout = Instance.new("UIListLayout")
configsListLayout.SortOrder = Enum.SortOrder.LayoutOrder
configsListLayout.Padding = UDim.new(0, 8)
configsListLayout.Parent = configsTab

local createBar = Instance.new("Frame")
createBar.Size = UDim2.new(1, -6, 0, 38)
createBar.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
createBar.BorderSizePixel = 0
createBar.Parent = configsTab

local createBarCorner = Instance.new("UICorner")
createBarCorner.CornerRadius = UDim.new(0, 7)
createBarCorner.Parent = createBar

local configNameInput = Instance.new("TextBox")
configNameInput.Size = UDim2.new(1, -100, 1, -10)
configNameInput.Position = UDim2.new(0, 8, 0, 5)
configNameInput.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
configNameInput.BorderSizePixel = 0
configNameInput.PlaceholderText = "Имя конфига..."
configNameInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
configNameInput.Text = ""
configNameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
configNameInput.TextSize = 13
configNameInput.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
configNameInput.TextXAlignment = Enum.TextXAlignment.Left
configNameInput.Parent = createBar

local inputPadding = Instance.new("UIPadding")
inputPadding.PaddingLeft = UDim.new(0, 8)
inputPadding.Parent = configNameInput

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 5)
inputCorner.Parent = configNameInput

local createBtn = Instance.new("TextButton")
createBtn.Size = UDim2.new(0, 80, 1, -10)
createBtn.Position = UDim2.new(1, -88, 0, 5)
createBtn.BackgroundColor3 = Color3.fromRGB(168, 85, 247)
createBtn.Text = "Создать"
createBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
createBtn.TextSize = 12
createBtn.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
createBtn.Parent = createBar

local createBtnCorner = Instance.new("UICorner")
createBtnCorner.CornerRadius = UDim.new(0, 5)
createBtnCorner.Parent = createBtn

local cardsContainer = Instance.new("Frame")
cardsContainer.Size = UDim2.new(1, -6, 0, 0)
cardsContainer.AutomaticSize = Enum.AutomaticSize.Y
cardsContainer.BackgroundTransparency = 1
cardsContainer.Parent = configsTab

local cardsLayout = Instance.new("UIListLayout")
cardsLayout.SortOrder = Enum.SortOrder.LayoutOrder
cardsLayout.Padding = UDim.new(0, 6)
cardsLayout.Parent = cardsContainer

local refreshConfigList

local function createConfigCard(configName)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 42)
	card.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
	card.BorderSizePixel = 0
	card.Parent = cardsContainer

	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 7)
	cardCorner.Parent = card

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -200, 1, 0)
	titleLabel.Position = UDim2.new(0, 10, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = configName
	titleLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
	titleLabel.TextSize = 13
	titleLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = card

	local btnContainer = Instance.new("Frame")
	btnContainer.Size = UDim2.new(0, 190, 1, 0)
	btnContainer.Position = UDim2.new(1, -195, 0, 0)
	btnContainer.BackgroundTransparency = 1
	btnContainer.Parent = card

	local btnLayout = Instance.new("UIListLayout")
	btnLayout.FillDirection = Enum.FillDirection.Horizontal
	btnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	btnLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	btnLayout.Padding = UDim.new(0, 5)
	btnLayout.Parent = btnContainer

	local function makeActionButton(text, width, color, onClick)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, width, 0, 26)
		btn.BackgroundColor3 = color
		btn.Text = text
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.TextSize = 11
		btn.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
		btn.Parent = btnContainer
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 5)
		corner.Parent = btn
		btn.MouseButton1Click:Connect(onClick)
	end

	makeActionButton("Загр.", 55, Color3.fromRGB(120, 80, 230), function()
		local data = loadConfigFromFile(configName)
		if data then
			deserializeConfig(data)
			if AutoLoadConfig.Enabled then saveAutoLoadData(true) end
		end
	end)

	makeActionButton("Сохр.", 55, Color3.fromRGB(45, 120, 60), function()
		saveConfigToFile(configName, serializeConfig())
		if AutoLoadConfig.Enabled then saveAutoLoadData(true) end
	end)

	makeActionButton("Удал.", 50, Color3.fromRGB(180, 50, 50), function()
		deleteConfigFile(configName)
		refreshConfigList()
	end)
end

refreshConfigList = function()
	for _, child in ipairs(cardsContainer:GetChildren()) do
		if not child:IsA("UIListLayout") then child:Destroy() end
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
	task.wait(0.25)
	local autoData = loadAutoLoadData()
	if autoData and autoData.Enabled and autoData.Config then
		deserializeConfig(autoData.Config)
	end
end)

--------------------------------------------------------------------------------
-- 11. TARGET HUD LOGIC
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
-- 12. ESP
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
	nameLabel.TextSize = 12
	nameLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	nameLabel.TextStrokeTransparency = 0.4
	nameLabel.Visible = false
	nameLabel.Parent = espContainer

	local hpLabel = Instance.new("TextLabel")
	hpLabel.BackgroundTransparency = 1
	hpLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
	hpLabel.TextSize = 11
	hpLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	hpLabel.TextStrokeTransparency = 0.4
	hpLabel.Visible = false
	hpLabel.Parent = espContainer

	espCache[player] = { Box = box, Name = nameLabel, Health = hpLabel }
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
			if not espCache[player] then createESPObject(player) end
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
						data.Name.Position = UDim2.new(0, boxX + (width / 2) - 90, 0, boxY - 16)
						data.Name.Size = UDim2.new(0, 180, 0, 14)
						data.Name.Visible = true
					else
						data.Name.Visible = false
					end

					if ESPConfig.Health then
						local hp = math.floor(humanoid.Health)
						local maxHp = math.floor(humanoid.MaxHealth)
						data.Health.Text = string.format("%d HP", hp)
						data.Health.Position = UDim2.new(0, boxX + (width / 2) - 90, 0, boxY + height + 1)
						data.Health.Size = UDim2.new(0, 180, 0, 13)
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
-- 13. МОБИЛЬНАЯ ИКОНКА + КЛАВИШИ
--------------------------------------------------------------------------------
local mobileToggle = Instance.new("TextButton")
mobileToggle.Name = "MobileToggle"
mobileToggle.Size = UDim2.new(0, 52, 0, 52)
mobileToggle.Position = UDim2.new(1, -68, 0.5, -26)
mobileToggle.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
mobileToggle.BackgroundTransparency = 0.12
mobileToggle.Text = "🔥"
mobileToggle.TextSize = 26
mobileToggle.BorderSizePixel = 0
mobileToggle.ZIndex = 50
mobileToggle.Parent = screenGui

local mobileCorner = Instance.new("UICorner")
mobileCorner.CornerRadius = UDim.new(1, 0)
mobileCorner.Parent = mobileToggle

local mobileStroke = Instance.new("UIStroke")
mobileStroke.Color = Color3.fromRGB(168, 85, 247)
mobileStroke.Thickness = 1.5
mobileStroke.Parent = mobileToggle

makeDraggable(mobileToggle, function()
	mainGui.Visible = not mainGui.Visible
	if not mainGui.Visible then
		settingsModal.Visible = false
	end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if UserInputService:GetFocusedTextBox() then return end
	if input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.Insert then
		mainGui.Visible = not mainGui.Visible
		if not mainGui.Visible then
			settingsModal.Visible = false
		end
	end
end)
