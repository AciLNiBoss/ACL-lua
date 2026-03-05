local GameVersion = "2.0.0"
local ScriptEnabled = true

-- Services
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

print("=== ACL HUB PREMIUM (Mobile Only) ===")

-- Tema Premium Mobile (Lebih Gelap & Elegan)
local Theme = {
	Background = Color3.fromRGB(8, 8, 12),
	Header = Color3.fromRGB(18, 18, 26),
	Container = Color3.fromRGB(22, 22, 32),
	Button = Color3.fromRGB(30, 30, 42),
	ButtonHover = Color3.fromRGB(42, 42, 58),
	Accent = Color3.fromRGB(0, 180, 255),
	Accent2 = Color3.fromRGB(255, 80, 180),
	Outline = Color3.fromRGB(38, 38, 48),
	Text = Color3.fromRGB(255, 255, 255),
	TextMuted = Color3.fromRGB(160, 160, 175),
	Success = Color3.fromRGB(70, 200, 120),
	Danger = Color3.fromRGB(240, 80, 100),
	CornerRadius = UDim.new(0, 10)
}

-- Secure Parent
local function getSecureGuiParent()
	local targetParent
	pcall(function() targetParent = gethui() end)
	if not targetParent then pcall(function() targetParent = game:GetService("CoreGui") end) end
	if not targetParent then targetParent = LocalPlayer:WaitForChild("PlayerGui", 5) end
	return targetParent
end

local guiParent = getSecureGuiParent()

-- Hapus GUI lama
if guiParent:FindFirstChild("ACL_HUB_MOBILE") then
	guiParent.ACL_HUB_MOBILE:Destroy()
end

-- Global Variables
local guiFunctions = {
	instantFish = false,
	autoCastPerfect = false,
	autoFish = false,
	caughtDelay = 1,
	recastDelay = 1,
	optimization = false
}
local webhookUrl = ""
local favoriteRarities = { 
	["Common"] = false, 
	["Uncommon"] = false, 
	["Rare"] = false, 
	["Epic"] = false, 
	["Legendary"] = false, 
	["Mythic"] = false, 
	["SECRET"] = false,
	["Ruby"] = false,
	["Gemstone"] = false
}
local toggleStates = {}
local sliderValues = {}
local autoWeatherEnabled = { ["Wind"] = false, ["Cloudy"] = false, ["Snow"] = false, ["Storm"] = false, ["Shining"] = false, ["SharkHunt"] = false }
local weatherProductIds = { ["Wind"] = 7058120, ["Cloudy"] = 7058120, ["Snow"] = 7058120, ["Storm"] = 7058120, ["Shining"] = 7058120, ["SharkHunt"] = 7058120 }
local weatherConnections = {}
local antiAFKEnabled = false
local antiAFKConnection = nil
local autorejoinEnabled = false
local autorejoinBound = false

-- Auto Sell Settings
_G.AutoSell = false
_G.SellMode = "delay" -- "delay" or "count"
_G.SellDelay = 30
_G.SellCount = 10
local currentFishCount = 0

-- DAFTAR 22 LOKASI TELEPORT
local teleportLocations = {
    {name = "Fisherman Island", pos = Vector3.new(13.06, 24.53, 2911.16)},
    {name = "Traveling Merchant", pos = Vector3.new(-137.52, 3.26, 2768.21)},
    {name = "Planetary Observatory", pos = Vector3.new(394.75, 7.25, 2157.10)},
    {name = "Crater Island", pos = Vector3.new(1012.045, 22.676, 5080.221)},
    {name = "Tropical Grove", pos = Vector3.new(-2092.897, 6.268, 3693.929)},
    {name = "Weather Machine", pos = Vector3.new(-1495.25, 6.5, 1889.92)},
    {name = "Coral Reefs", pos = Vector3.new(-2949.359, 63.25, 2213.966)},
    {name = "Pirate Cove", pos = Vector3.new(3358.00, 4.19, 3519.95)},
    {name = "Sacred Temple", pos = Vector3.new(1476.2323, -21.8499775, -630.891541)},
    {name = "Underground Cellar", pos = Vector3.new(2097.20483, -91.1976471, -703.738708)},
    {name = "Transcended Stone", pos = Vector3.new(1480.33191, 127.624985, -595.777588)},
    {name = "Ancient Jungle", pos = Vector3.new(1281.76147, 7.79100895, -202.018097)},
    {name = "Outside Ancient Jungle", pos = Vector3.new(1489.62927, 7.99596596, -511.278839)},
    {name = "Kohana Lava", pos = Vector3.new(-593.32, 59.0, 130.82)},
    {name = "LEVER | Diamond", pos = Vector3.new(1819, 8.44944572, -284)},
    {name = "LEVER | Crescent", pos = Vector3.new(1420, 31.1994438, 79)},
    {name = "LEVER | Hourglass Diamond", pos = Vector3.new(1486, 6.82499933, -857)},
    {name = "LEVER | Arrow", pos = Vector3.new(898.137085, 8.44949913, -363.172699)},
    {name = "Kohana", pos = Vector3.new(-643.14, 16.03, 623.61)},
    {name = "Esotoric Island", pos = Vector3.new(2024.49, 27.397, 1391.62)},
    {name = "Ice Island", pos = Vector3.new(1766.46, 19.16, 3086.23)},
    {name = "Lost Isle", pos = Vector3.new(-3660.07, 5.426, -1053.02)},
    {name = "Sishypus Statue", pos = Vector3.new(-3693.96, -135.57, -1027.28)},
    {name = "Treasure Hall", pos = Vector3.new(-3598.39, -275.82, -1641.46)},
    {name = "Teleport To Enchant", pos = Vector3.new(3236.12, -1302.855, 1399.491)}
}

----------------------------------------
-- LOGIKA UTAMA
----------------------------------------

-- Anti AFK
local function enableAntiAFK()
	if antiAFKConnection then task.cancel(antiAFKConnection) end
	antiAFKConnection = task.spawn(function()
		while antiAFKEnabled do
			task.wait(120)
			pcall(function()
				VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, game)
				task.wait(0.1)
				VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, game)
			end)
		end
	end)
end
local function disableAntiAFK()
	antiAFKEnabled = false
	if antiAFKConnection then task.cancel(antiAFKConnection); antiAFKConnection = nil end
end

-- Auto Rejoin
local function enableAutorejoin()
	if not autorejoinBound then
		autorejoinBound = true
		game:BindToClose(function()
			if autorejoinEnabled then
				pcall(function() game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end)
				task.wait(1)
				pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer) end)
			end
		end)
	end
end
local function disableAutorejoin() autorejoinEnabled = false end

-- Auto Mancing (Opsional, bisa diaktifkan kembali jika diperlukan)
local autoFishConnection = nil
local function startAutoFish()
	if autoFishConnection then return end
	autoFishConnection = task.spawn(function()
		while guiFunctions.autoFish do
			pcall(function()
				local char = LocalPlayer.Character
				if char then
					local tool = char:FindFirstChildOfClass("Tool")
					if tool then
						VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
						task.wait(0.05)
						VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
					end
				end
			end)
			task.wait(guiFunctions.caughtDelay or 1)
		end
		autoFishConnection = nil
	end)
end

local function stopAutoFish()
	guiFunctions.autoFish = false
	if autoFishConnection then task.cancel(autoFishConnection); autoFishConnection = nil end
end

-- Auto Jual dengan 2 Mode
local sellThread = nil

local function sellFishAction()
	local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
	if playerGui then
		local merchantGui = playerGui:FindFirstChild("Merchant")
		if merchantGui and merchantGui:FindFirstChild("Main") then
			for _, descendant in pairs(merchantGui.Main:GetDescendants()) do
				if (descendant:IsA("TextButton") or descendant:IsA("ImageButton")) then
					local text = string.lower(descendant.Text or "")
					if text:find("sell") or text:find("jual") or text:find("all") then
						pcall(function() descendant.MouseButton1Click:Fire() end)
						break
					end
				end
			end
		end
	end
end

local function autosell()
	while _G.AutoSell do
		if _G.SellMode == "delay" then
			sellFishAction()
			task.wait(_G.SellDelay)
		elseif _G.SellMode == "count" then
			-- Reset counter setiap kali menjual
			currentFishCount = 0
			sellFishAction()
			-- Tunggu sampai jumlah ikan mencapai batas
			while currentFishCount < _G.SellCount and _G.AutoSell do
				task.wait(1)
			end
		end
	end
end

local function sellFish()
	if _G.AutoSell then
		if sellThread then task.cancel(sellThread) end
		sellThread = task.spawn(autosell)
	else
		_G.AutoSell = false
		if sellThread then task.cancel(sellThread) end
		sellThread = nil
	end
end

-- Auto Beli Cuaca
local function buyWeather(wName)
	local id = weatherProductIds[wName]
	if id ~= 0 then pcall(function() game:GetService("MarketplaceService"):PromptProductPurchase(LocalPlayer, id) end) end
end

local function startAutoBuyWeather(wName)
	if weatherConnections[wName] then task.cancel(weatherConnections[wName]) end
	weatherConnections[wName] = task.spawn(function()
		while autoWeatherEnabled[wName] do buyWeather(wName); task.wait(5) end
	end)
end
local function stopAutoBuyWeather(wName)
	if weatherConnections[wName] then task.cancel(weatherConnections[wName]); weatherConnections[wName] = nil end
end

----------------------------------------
-- UI MOBILE PREMIUM (LEBIH RAMPING)
----------------------------------------

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ACL_HUB_MOBILE"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999999999
screenGui.IgnoreGuiInset = true
screenGui.Parent = guiParent

-- Floating Button
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 55, 0, 55)
openBtn.Position = UDim2.new(0, 15, 0.5, -27.5)
openBtn.BackgroundColor3 = Theme.Accent
openBtn.Text = "ACL"
openBtn.TextColor3 = Theme.Text
openBtn.TextSize = 16
openBtn.Font = Enum.Font.GothamBold
openBtn.Visible = false
openBtn.Parent = screenGui
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", openBtn).Color = Theme.Text

-- Main Window (Lebih Ramping: 340x500)
local window = Instance.new("Frame")
window.Size = UDim2.new(0, 340, 0, 500)
window.Position = UDim2.new(0.5, -170, 0.5, -250)
window.BackgroundColor3 = Theme.Background
window.BorderSizePixel = 0
window.Active = true
window.Draggable = true
window.Parent = screenGui
Instance.new("UICorner", window).CornerRadius = UDim.new(0, 16)
Instance.new("UIStroke", window).Color = Theme.Outline

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 48)
header.BackgroundColor3 = Theme.Header
header.BorderSizePixel = 0
header.Parent = window
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 16)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -90, 1, 0)
title.Position = UDim2.new(0, 18, 0, 0)
title.BackgroundTransparency = 1
title.Text = "ACL PREMIUM"
title.TextColor3 = Theme.Accent
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- Header Buttons
local btnContainer = Instance.new("Frame")
btnContainer.Size = UDim2.new(0, 90, 1, 0)
btnContainer.Position = UDim2.new(1, -90, 0, 0)
btnContainer.BackgroundTransparency = 1
btnContainer.Parent = header

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 45, 1, 0)
minBtn.BackgroundTransparency = 1
minBtn.Text = "−"
minBtn.TextColor3 = Theme.Text
minBtn.TextSize = 24
minBtn.Font = Enum.Font.GothamBold
minBtn.Parent = btnContainer

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 45, 1, 0)
closeBtn.Position = UDim2.new(0, 45, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.TextColor3 = Theme.Danger
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = btnContainer

minBtn.MouseButton1Click:Connect(function()
	window.Visible = false
	openBtn.Visible = true
end)

closeBtn.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

-- Open button logic
local isDraggingIcon, dragStartIcon, startPosIcon
openBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		isDraggingIcon = true
		dragStartIcon = input.Position
		startPosIcon = openBtn.Position
	end
end)
openBtn.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		isDraggingIcon = false
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if isDraggingIcon and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStartIcon
		openBtn.Position = UDim2.new(startPosIcon.X.Scale, startPosIcon.X.Offset + delta.X, startPosIcon.Y.Scale, startPosIcon.Y.Offset + delta.Y)
	end
end)

openBtn.MouseButton1Click:Connect(function()
	openBtn.Visible = false
	window.Visible = true
end)

-- SIDEBAR PROFESIONAL (Lebih Tipis & Elegan)
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 90, 1, -58)
sidebar.Position = UDim2.new(0, 8, 0, 50)
sidebar.BackgroundColor3 = Theme.Container
sidebar.BorderSizePixel = 0
sidebar.Parent = window
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", sidebar).Color = Theme.Outline

local sidebarLayout = Instance.new("UIListLayout")
sidebarLayout.Padding = UDim.new(0, 4)
sidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
sidebarLayout.Parent = sidebar

local contentPanel = Instance.new("ScrollingFrame")
contentPanel.Size = UDim2.new(1, -106, 1, -58)
contentPanel.Position = UDim2.new(0, 102, 0, 50)
contentPanel.BackgroundColor3 = Theme.Container
contentPanel.BorderSizePixel = 0
contentPanel.ScrollBarThickness = 3
contentPanel.ScrollBarImageColor3 = Theme.Accent
contentPanel.Parent = window
Instance.new("UICorner", contentPanel).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", contentPanel).Color = Theme.Outline

local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 8)
contentLayout.Parent = contentPanel

local currentSidebarBtn = nil

local function clearContent()
	for _, child in pairs(contentPanel:GetChildren()) do
		if not child:IsA("UIListLayout") then child:Destroy() end
	end
end

-- Sidebar Button Profesional
local function createSidebarButton(icon, name, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -8, 0, 60)
	btn.BackgroundColor3 = Theme.Background
	btn.BorderSizePixel = 0
	btn.Parent = sidebar

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = btn

	local iconLabel = Instance.new("TextLabel")
	iconLabel.Size = UDim2.new(1, 0, 0, 30)
	iconLabel.Position = UDim2.new(0, 0, 0, 5)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Text = icon
	iconLabel.TextColor3 = Theme.TextMuted
	iconLabel.TextSize = 20
	iconLabel.Font = Enum.Font.GothamBold
	iconLabel.Parent = btn

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0, 20)
	nameLabel.Position = UDim2.new(0, 0, 0, 35)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = name
	nameLabel.TextColor3 = Theme.TextMuted
	nameLabel.TextSize = 11
	nameLabel.Font = Enum.Font.GothamMedium
	nameLabel.Parent = btn

	sidebar.CanvasSize = UDim2.new(0, 0, 0, sidebarLayout.AbsoluteContentSize.Y + 10)

	btn.MouseButton1Click:Connect(function()
		if currentSidebarBtn then
			currentSidebarBtn.BackgroundColor3 = Theme.Background
			currentSidebarBtn:FindFirstChild("TextLabel").TextColor3 = Theme.TextMuted
			currentSidebarBtn:FindFirstChild("TextLabel", true).TextColor3 = Theme.TextMuted
		end
		currentSidebarBtn = btn
		btn.BackgroundColor3 = Theme.Accent
		iconLabel.TextColor3 = Theme.Text
		nameLabel.TextColor3 = Theme.Text

		clearContent()
		if callback then callback(contentPanel) end
		task.delay(0.05, function() 
			contentPanel.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20) 
		end)
	end)
	return btn
end

-- Komponen UI Modern
local function createSectionTitle(parent, titleText)
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -16, 0, 30)
	title.Position = UDim2.new(0, 8, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = titleText
	title.TextColor3 = Theme.Accent
	title.TextSize = 14
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = parent
end

local function createToggle(parent, name, desc, callback)
	local toggle = Instance.new("Frame")
	toggle.Size = UDim2.new(1, -16, 0, 55)
	toggle.Position = UDim2.new(0, 8, 0, 0)
	toggle.BackgroundColor3 = Theme.Button
	toggle.BorderSizePixel = 0
	toggle.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = toggle

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -70, 0, 20)
	nameLabel.Position = UDim2.new(0, 12, 0, 8)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = name
	nameLabel.TextColor3 = Theme.Text
	nameLabel.TextSize = 14
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = toggle

	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(1, -70, 0, 15)
	descLabel.Position = UDim2.new(0, 12, 0, 28)
	descLabel.BackgroundTransparency = 1
	descLabel.Text = desc
	descLabel.TextColor3 = Theme.TextMuted
	descLabel.TextSize = 11
	descLabel.Font = Enum.Font.GothamMedium
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.Parent = toggle

	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Size = UDim2.new(0, 50, 0, 26)
	toggleBtn.Position = UDim2.new(1, -60, 0, 14)
	toggleBtn.BackgroundColor3 = Theme.Container
	toggleBtn.BorderSizePixel = 0
	toggleBtn.Text = ""
	toggleBtn.Parent = toggle
	Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

	local toggleCircle = Instance.new("Frame")
	toggleCircle.Size = UDim2.new(0, 22, 0, 22)
	toggleCircle.Position = UDim2.new(0, 2, 0.5, -11)
	toggleCircle.BackgroundColor3 = Theme.TextMuted
	toggleCircle.BorderSizePixel = 0
	toggleCircle.Parent = toggleBtn
	Instance.new("UICorner", toggleCircle).CornerRadius = UDim.new(1, 0)

	local toggleKey = name:gsub("[^%w]", "")
	local isEnabled = toggleStates[toggleKey] or false

	local function updateToggle()
		if isEnabled then
			toggleBtn.BackgroundColor3 = Theme.Accent
			toggleCircle.Position = UDim2.new(0, 26, 0.5, -11)
			toggleCircle.BackgroundColor3 = Theme.Text
		else
			toggleBtn.BackgroundColor3 = Theme.Container
			toggleCircle.Position = UDim2.new(0, 2, 0.5, -11)
			toggleCircle.BackgroundColor3 = Theme.TextMuted
		end
	end
	updateToggle()

	toggleBtn.MouseButton1Click:Connect(function()
		isEnabled = not isEnabled
		toggleStates[toggleKey] = isEnabled
		updateToggle()
		if callback then pcall(callback, isEnabled) end
	end)
end

local function createButton(parent, name, icon, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -16, 0, 45)
	btn.Position = UDim2.new(0, 8, 0, 0)
	btn.BackgroundColor3 = Theme.Button
	btn.BorderSizePixel = 0
	btn.Text = ""
	btn.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = btn

	local iconLabel = Instance.new("TextLabel")
	iconLabel.Size = UDim2.new(0, 30, 1, 0)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Text = icon
	iconLabel.TextColor3 = Theme.Accent
	iconLabel.TextSize = 16
	iconLabel.Font = Enum.Font.GothamBold
	iconLabel.Parent = btn

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -40, 1, 0)
	nameLabel.Position = UDim2.new(0, 30, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = name
	nameLabel.TextColor3 = Theme.Text
	nameLabel.TextSize = 13
	nameLabel.Font = Enum.Font.GothamMedium
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = btn

	btn.MouseButton1Click:Connect(function() if callback then pcall(callback) end end)
end

local function createDropdown(parent, name, options, default, callback)
	local dropdown = Instance.new("Frame")
	dropdown.Size = UDim2.new(1, -16, 0, 55)
	dropdown.Position = UDim2.new(0, 8, 0, 0)
	dropdown.BackgroundColor3 = Theme.Button
	dropdown.BorderSizePixel = 0
	dropdown.Parent = parent
	Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 10)

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -20, 0, 20)
	nameLabel.Position = UDim2.new(0, 12, 0, 6)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = name
	nameLabel.TextColor3 = Theme.Text
	nameLabel.TextSize = 13
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = dropdown

	local selectBtn = Instance.new("TextButton")
	selectBtn.Size = UDim2.new(1, -24, 0, 26)
	selectBtn.Position = UDim2.new(0, 12, 0, 26)
	selectBtn.BackgroundColor3 = Theme.Container
	selectBtn.BorderSizePixel = 0
	selectBtn.Text = default
	selectBtn.TextColor3 = Theme.Text
	selectBtn.TextSize = 12
	selectBtn.Font = Enum.Font.GothamMedium
	selectBtn.Parent = dropdown
	Instance.new("UICorner", selectBtn).CornerRadius = UDim.new(0, 6)

	selectBtn.MouseButton1Click:Connect(function()
		local menu = Instance.new("Frame")
		menu.Size = UDim2.new(1, 0, 0, #options * 35)
		menu.Position = UDim2.new(0, 0, 1, 5)
		menu.BackgroundColor3 = Theme.Container
		menu.BorderSizePixel = 0
		menu.Parent = dropdown
		Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 8)
		Instance.new("UIStroke", menu).Color = Theme.Outline

		for i, opt in ipairs(options) do
			local optBtn = Instance.new("TextButton")
			optBtn.Size = UDim2.new(1, -10, 0, 30)
			optBtn.Position = UDim2.new(0, 5, 0, (i-1)*35 + 2.5)
			optBtn.BackgroundColor3 = opt == selectBtn.Text and Theme.Accent or Theme.Button
			optBtn.Text = opt
			optBtn.TextColor3 = Theme.Text
			optBtn.TextSize = 12
			optBtn.Font = Enum.Font.GothamMedium
			optBtn.Parent = menu
			Instance.new("UICorner", optBtn).CornerRadius = UDim.new(0, 6)

			optBtn.MouseButton1Click:Connect(function()
				selectBtn.Text = opt
				if callback then callback(opt) end
				menu:Destroy()
			end)
		end

		menu.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch then
				task.wait(0.1)
				menu:Destroy()
			end
		end)
	end)
end

local function createSlider(parent, name, minVal, maxVal, defaultVal, suffix, callback)
	local slider = Instance.new("Frame")
	slider.Size = UDim2.new(1, -16, 0, 60)
	slider.Position = UDim2.new(0, 8, 0, 0)
	slider.BackgroundColor3 = Theme.Button
	slider.BorderSizePixel = 0
	slider.Parent = parent
	Instance.new("UICorner", slider).CornerRadius = UDim.new(0, 10)

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -20, 0, 20)
	nameLabel.Position = UDim2.new(0, 12, 0, 6)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = name
	nameLabel.TextColor3 = Theme.Text
	nameLabel.TextSize = 13
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = slider

	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(0, 60, 0, 20)
	valueLabel.Position = UDim2.new(1, -70, 0, 6)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Text = tostring(defaultVal) .. " " .. suffix
	valueLabel.TextColor3 = Theme.Accent
	valueLabel.TextSize = 12
	valueLabel.Font = Enum.Font.GothamBold
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Parent = slider

	local sliderKey = name:gsub("[^%w]", "")
	local currentValue = sliderValues[sliderKey] or defaultVal

	local sliderBar = Instance.new("Frame")
	sliderBar.Size = UDim2.new(1, -24, 0, 6)
	sliderBar.Position = UDim2.new(0, 12, 0, 38)
	sliderBar.BackgroundColor3 = Theme.Container
	sliderBar.BorderSizePixel = 0
	sliderBar.Parent = slider
	Instance.new("UICorner", sliderBar).CornerRadius = UDim.new(1, 0)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((currentValue - minVal) / (maxVal - minVal), 0, 1, 0)
	fill.BackgroundColor3 = Theme.Accent
	fill.BorderSizePixel = 0
	fill.Parent = sliderBar
	Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

	local dragBtn = Instance.new("TextButton")
	dragBtn.Size = UDim2.new(0, 20, 0, 20)
	dragBtn.Position = UDim2.new((currentValue - minVal) / (maxVal - minVal), -10, 0, 28)
	dragBtn.BackgroundColor3 = Theme.Accent
	dragBtn.BorderSizePixel = 0
	dragBtn.Text = ""
	dragBtn.Parent = slider
	Instance.new("UICorner", dragBtn).CornerRadius = UDim.new(1, 0)

	local isDragging = false
	dragBtn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isDragging = true
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isDragging = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local mousePos = input.Position.X
			local barPos = sliderBar.AbsolutePosition.X
			local barSize = sliderBar.AbsoluteSize.X
			local relativeX = math.clamp(mousePos - barPos, 0, barSize)
			local percentage = relativeX / barSize
			local value = math.floor(minVal + percentage * (maxVal - minVal))

			fill.Size = UDim2.new(percentage, 0, 1, 0)
			dragBtn.Position = UDim2.new(percentage, -10, 0, 28)
			valueLabel.Text = tostring(value) .. " " .. suffix
			sliderValues[sliderKey] = value
			if callback then pcall(callback, value) end
		end
	end)
end

----------------------------------------
-- MENU KATEGORI
----------------------------------------

-- Teleport Menu (22 Lokasi)
createSidebarButton("🌍", "Teleport", function(panel)
	createSectionTitle(panel, "🌍 22 Lokasi")
	
	table.sort(teleportLocations, function(a, b) return a.name < b.name end)
	for _, loc in ipairs(teleportLocations) do
		createButton(panel, loc.name, "📍", function()
			local char = LocalPlayer.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				char.HumanoidRootPart.CFrame = CFrame.new(loc.pos)
			end
		end)
	end
end)

-- Auto Favorite Menu
createSidebarButton("⭐", "Favorite", function(panel)
	createSectionTitle(panel, "⭐ Auto Favorite")
	createToggle(panel, "Common", "Ikan biasa", function(state) favoriteRarities["Common"] = state end)
	createToggle(panel, "Uncommon", "Ikan jarang", function(state) favoriteRarities["Uncommon"] = state end)
	createToggle(panel, "Rare", "Ikan langka", function(state) favoriteRarities["Rare"] = state end)
	createToggle(panel, "Epic", "Ikan epik", function(state) favoriteRarities["Epic"] = state end)
	createToggle(panel, "Legendary", "Ikan legendaris", function(state) favoriteRarities["Legendary"] = state end)
	createToggle(panel, "Mythic", "Ikan mitis", function(state) favoriteRarities["Mythic"] = state end)
	createToggle(panel, "SECRET", "Ikan rahasia", function(state) favoriteRarities["SECRET"] = state end)
	createSectionTitle(panel, "💎 Spesial")
	createToggle(panel, "Ruby", "Batu rubi", function(state) favoriteRarities["Ruby"] = state end)
	createToggle(panel, "Gemstone", "Batu permata", function(state) favoriteRarities["Gemstone"] = state end)
end)

-- Auto Sell Menu
createSidebarButton("💰", "Auto Sell", function(panel)
	createSectionTitle(panel, "💰 Pengaturan Jual")
	
	createToggle(panel, "Auto Jual", "Aktifkan auto sell", function(state) 
		_G.AutoSell = state 
		if state then sellFish() end
	end)
	
	createDropdown(panel, "Mode Jual", {"By Delay", "By Count"}, "By Delay", function(opt)
		_G.SellMode = opt == "By Delay" and "delay" or "count"
	end)
	
	createSlider(panel, "Delay", 5, 120, 30, "detik", function(val)
		_G.SellDelay = val
	end)
	
	createSlider(panel, "Jumlah", 1, 50, 10, "ekor", function(val)
		_G.SellCount = val
	end)
end)

-- Shop & Weather Menu
createSidebarButton("🏪", "Shop", function(panel)
	createSectionTitle(panel, "🏪 Toko")
	createButton(panel, "Buka/Tutup Toko", "🛒", function()
		local m = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("Merchant")
		if m and m:FindFirstChild("Main") then m.Main.Enabled = not m.Main.Enabled end
	end)
	
	createSectionTitle(panel, "🌦️ Auto Buy Cuaca")
	createToggle(panel, "Wind", "Beli angin", function(state) autoWeatherEnabled["Wind"] = state if state then startAutoBuyWeather("Wind") else stopAutoBuyWeather("Wind") end end)
	createToggle(panel, "Storm", "Beli badai", function(state) autoWeatherEnabled["Storm"] = state if state then startAutoBuyWeather("Storm") else stopAutoBuyWeather("Storm") end end)
	createToggle(panel, "Shark Hunt", "Beli shark", function(state) autoWeatherEnabled["SharkHunt"] = state if state then startAutoBuyWeather("SharkHunt") else stopAutoBuyWeather("SharkHunt") end end)
end)

-- Settings Menu
createSidebarButton("⚙️", "Settings", function(panel)
	createSectionTitle(panel, "⚙️ Sistem")
	createToggle(panel, "Anti AFK", "Cegah kick", function(state) antiAFKEnabled = state if state then enableAntiAFK() else disableAntiAFK() end end)
	createToggle(panel, "Auto Rejoin", "Rejoin otomatis", function(state) autorejoinEnabled = state if state then enableAutorejoin() else disableAutorejoin() end end)
	createToggle(panel, "Mode Malam", "Gelapkan map", function(state) game.Lighting.ClockTime = state and 0 or 12 end)
end)

-- Buka menu Teleport secara default
local firstBtn = sidebar:FindFirstChildWhichIsA("TextButton")
if firstBtn then
	task.wait(0.1)
	firstBtn.MouseButton1Click:Fire()
end
