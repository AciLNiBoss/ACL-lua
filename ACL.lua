local GameVersion = "2.0.0"
local ScriptEnabled = true

-- Services
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

print("=== ACL HUB PREMIUM Diinisialisasi ===")

-- Pengaturan Tema Modern Premium (Tanpa Emoticon)
local Theme = {
	Background = Color3.fromRGB(15, 15, 20),
	Header = Color3.fromRGB(25, 25, 30),
	Container = Color3.fromRGB(22, 22, 28),
	Button = Color3.fromRGB(35, 35, 45),
	ButtonHover = Color3.fromRGB(45, 45, 60),
	Accent = Color3.fromRGB(0, 140, 255),
	Outline = Color3.fromRGB(40, 40, 50),
	Text = Color3.fromRGB(245, 245, 245),
	TextMuted = Color3.fromRGB(140, 140, 140),
	CornerRadius = UDim.new(0, 6)
}

-- Keamanan GUI (Bypass Executor Mobile)
local function getSecureGuiParent()
	local targetParent
	pcall(function() targetParent = gethui() end)
	if not targetParent then pcall(function() targetParent = game:GetService("CoreGui") end) end
	if not targetParent then targetParent = LocalPlayer:WaitForChild("PlayerGui", 5) end
	return targetParent
end

local guiParent = getSecureGuiParent()

-- Hapus GUI lama jika ada
if guiParent:FindFirstChild("ACL_HUB_MOBILE") then
	guiParent.ACL_HUB_MOBILE:Destroy()
end

-- Variables Global
local guiFunctions = {
	instantFish = false,
	autoCastPerfect = false,
	autoFish = false,
	caughtDelay = 1,
	recastDelay = 1,
	optimization = false
}
local webhookUrl = ""
local favoriteRarities = { ["Uncommon"] = false, ["Common"] = false, ["Rare"] = false, ["Epic"] = false, ["Legendary"] = false, ["Mythic"] = false, ["SECRET"] = false }
local toggleStates = {}
local sliderValues = {}
local autoWeatherEnabled = { ["Wind"] = false, ["Cloudy"] = false, ["Snow"] = false, ["Storm"] = false, ["Shining"] = false, ["SharkHunt"] = false }
local weatherProductIds = { ["Wind"] = 7058120, ["Cloudy"] = 7058120, ["Snow"] = 7058120, ["Storm"] = 7058120, ["Shining"] = 7058120, ["SharkHunt"] = 7058120 }
local weatherConnections = {}
local antiAFKEnabled = false
local antiAFKConnection = nil
local autorejoinEnabled = false
local autorejoinBound = false

----------------------------------------
-- LOGIKA UTAMA (FUNGSI MEMANCING DIPERBAIKI)
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

-- Auto Mancing & Bypass (Sistem Klik Otomatis Universal)
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
						-- Simulasi Tap/Klik Layar untuk Lempar (Cast) dan Tarik (Reel)
						VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
						task.wait(0.05)
						VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
					end
				end
			end)
			
			-- Fitur Bypass Minigame / Instant Catch
			if guiFunctions.instantFish or guiFunctions.autoCastPerfect then
				pcall(function()
					local repStorage = game:GetService("ReplicatedStorage")
					local events = repStorage:FindFirstChild("Remotes") or repStorage:FindFirstChild("Events") or repStorage
					for _, event in pairs(events:GetDescendants()) do
						if event:IsA("RemoteEvent") then
							local name = event.Name:lower()
							if name:match("catch") or name:match("fish") or name:match("reel") or name:match("perfect") then
								event:FireServer(true, "Perfect", 100)
							end
						elseif event:IsA("RemoteFunction") then
							local name = event.Name:lower()
							if name:match("catch") or name:match("fish") or name:match("reel") then
								task.spawn(function() event:InvokeServer(true, "Perfect", 100) end)
							end
						end
					end
				end)
			end
			
			task.wait(guiFunctions.caughtDelay or 1)
		end
		autoFishConnection = nil
	end)
end

local function stopAutoFish()
	guiFunctions.autoFish = false
	if autoFishConnection then task.cancel(autoFishConnection); autoFishConnection = nil end
end

-- Auto Jual
local sellThread = nil
_G.AutoSell = false
_G.SellDelay = 30

local function autosell()
	while _G.AutoSell do
		local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
		if playerGui then
			local merchantGui = playerGui:FindFirstChild("Merchant")
			if merchantGui and merchantGui:FindFirstChild("Main") then
				for _, descendant in pairs(merchantGui.Main:GetDescendants()) do
					if (descendant:IsA("TextButton") or descendant:IsA("ImageButton")) then
						local text = string.lower(descendant.Text or "")
						if text:find("sell") or text:find("jual") then
							pcall(function() descendant.MouseButton1Click:Fire() end)
							break
						end
					end
				end
			end
		end
		task.wait(_G.SellDelay)
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

local function detectWeatherProductIds()
	local pg = LocalPlayer:FindFirstChild("PlayerGui")
	if not pg then return end
	local m = pg:FindFirstChild("Merchant")
	if not m or not m:FindFirstChild("Main") then return end
	local wBtns = { ["Wind"] = nil, ["Cloudy"] = nil, ["Snow"] = nil, ["Storm"] = nil, ["Shining"] = nil, ["SharkHunt"] = nil }
	for _, desc in pairs(m.Main:GetDescendants()) do
		if desc:IsA("TextButton") or desc:IsA("ImageButton") then
			local txt = (desc.Text or ""):lower()
			local nm = (desc.Name or ""):lower()
			for wName, _ in pairs(wBtns) do
				if txt:find(wName:lower()) or nm:find(wName:lower()) then
					local id = desc:GetAttribute("ProductId") or desc:GetAttribute("ProductID")
					if id then weatherProductIds[wName] = tonumber(id) end
				end
			end
		end
	end
end
task.spawn(function() task.wait(2); detectWeatherProductIds() end)

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
-- PEMBUATAN UI MOBILE PREMIUM
----------------------------------------

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ACL_HUB_MOBILE"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999999999
screenGui.IgnoreGuiInset = true
screenGui.Parent = guiParent

-- TOMBOL BUKA (MUNCUL SAAT DI-MINIMIZE)
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 50, 0, 50)
openBtn.Position = UDim2.new(0, 20, 0.5, -25)
openBtn.BackgroundColor3 = Theme.Header
openBtn.Text = "ACL"
openBtn.TextColor3 = Theme.Accent
openBtn.TextSize = 16
openBtn.Font = Enum.Font.GothamBold
openBtn.Visible = false
openBtn.Parent = screenGui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(0, 10)
openCorner.Parent = openBtn

local openStroke = Instance.new("UIStroke")
openStroke.Color = Theme.Accent
openStroke.Thickness = 1
openStroke.Parent = openBtn

-- JENDELA UTAMA
local window = Instance.new("Frame")
window.Size = UDim2.new(0, 520, 0, 320)
window.Position = UDim2.new(0.5, -260, 0.5, -160)
window.BackgroundColor3 = Theme.Background
window.BorderSizePixel = 0
window.Active = true
window.Draggable = true
window.Parent = screenGui

local windowCorner = Instance.new("UICorner")
windowCorner.CornerRadius = UDim.new(0, 8)
windowCorner.Parent = window

local windowStroke = Instance.new("UIStroke")
windowStroke.Color = Theme.Outline
windowStroke.Thickness = 1.5
windowStroke.Parent = window

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = Theme.Header
header.BorderSizePixel = 0
header.Parent = window

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 8)
headerCorner.Parent = header
local headerFix = Instance.new("Frame") -- Menutupi sudut bawah header
headerFix.Size = UDim2.new(1, 0, 0, 10)
headerFix.Position = UDim2.new(0, 0, 1, -10)
headerFix.BackgroundColor3 = Theme.Header
headerFix.BorderSizePixel = 0
headerFix.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -100, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "ACL HUB PREMIUM"
title.TextColor3 = Theme.Accent
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- LOGIKA MINIMIZE & CLOSE
local btnContainer = Instance.new("Frame")
btnContainer.Size = UDim2.new(0, 90, 1, 0)
btnContainer.Position = UDim2.new(1, -90, 0, 0)
btnContainer.BackgroundTransparency = 1
btnContainer.Parent = header

-- Tombol Minimize (-)
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 45, 1, 0)
minBtn.Position = UDim2.new(0, 0, 0, 0)
minBtn.BackgroundTransparency = 1
minBtn.Text = "-"
minBtn.TextColor3 = Theme.Text
minBtn.TextSize = 22
minBtn.Font = Enum.Font.GothamBold
minBtn.Parent = btnContainer

-- Tombol Close (X)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 45, 1, 0)
closeBtn.Position = UDim2.new(0, 45, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = btnContainer

minBtn.MouseButton1Click:Connect(function()
	window.Visible = false
	openBtn.Visible = true
end)

closeBtn.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

-- Buka kembali dari Minimize
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

-- LAYOUT PANEL KIRI DAN KANAN
local leftPanel = Instance.new("ScrollingFrame")
leftPanel.Size = UDim2.new(0, 140, 1, -55)
leftPanel.Position = UDim2.new(0, 10, 0, 45)
leftPanel.BackgroundTransparency = 1
leftPanel.BorderSizePixel = 0
leftPanel.ScrollBarThickness = 0
leftPanel.Parent = window

local leftLayout = Instance.new("UIListLayout")
leftLayout.Padding = UDim.new(0, 5)
leftLayout.Parent = leftPanel

local rightPanel = Instance.new("ScrollingFrame")
rightPanel.Size = UDim2.new(1, -165, 1, -55)
rightPanel.Position = UDim2.new(0, 155, 0, 45)
rightPanel.BackgroundTransparency = 1
rightPanel.BorderSizePixel = 0
rightPanel.ScrollBarThickness = 2
rightPanel.ScrollBarImageColor3 = Theme.Outline
rightPanel.Parent = window

local currentCategoryBtn = nil

local function clearRightPanel()
	for _, child in pairs(rightPanel:GetChildren()) do
		if not child:IsA("UIListLayout") then child:Destroy() end
	end
end

local function createCategoryButton(name, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 35)
	btn.BackgroundColor3 = Theme.Background
	btn.BorderSizePixel = 0
	btn.Text = "  " .. name
	btn.TextColor3 = Theme.TextMuted
	btn.TextSize = 13
	btn.Font = Enum.Font.GothamMedium
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.Parent = leftPanel

	local corner = Instance.new("UICorner")
	corner.CornerRadius = Theme.CornerRadius
	corner.Parent = btn

	leftPanel.CanvasSize = UDim2.new(0, 0, 0, leftLayout.AbsoluteContentSize.Y)

	btn.MouseButton1Click:Connect(function()
		if currentCategoryBtn then
			currentCategoryBtn.BackgroundColor3 = Theme.Background
			currentCategoryBtn.TextColor3 = Theme.TextMuted
		end
		currentCategoryBtn = btn
		btn.BackgroundColor3 = Theme.Container
		btn.TextColor3 = Theme.Text

		clearRightPanel()
		local layout = Instance.new("UIListLayout")
		layout.Padding = UDim.new(0, 8)
		layout.Parent = rightPanel

		if callback then callback(rightPanel) end
		task.delay(0.05, function() rightPanel.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20) end)
	end)
	return btn
end

local function createSectionTitle(panel, titleText)
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 25)
	title.BackgroundTransparency = 1
	title.Text = titleText
	title.TextColor3 = Theme.Accent
	title.TextSize = 13
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = panel
end

local function createToggle(parent, name, callback)
	local toggle = Instance.new("TextButton")
	toggle.Size = UDim2.new(1, -10, 0, 40)
	toggle.BackgroundColor3 = Theme.Container
	toggle.BorderSizePixel = 0
	toggle.Text = ""
	toggle.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = Theme.CornerRadius
	corner.Parent = toggle
	
	local stroke = Instance.new("UIStroke")
	stroke.Color = Theme.Outline
	stroke.Thickness = 1
	stroke.Parent = toggle

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -70, 1, 0)
	nameLabel.Position = UDim2.new(0, 15, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = name
	nameLabel.TextColor3 = Theme.Text
	nameLabel.TextSize = 13
	nameLabel.Font = Enum.Font.GothamMedium
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = toggle

	local statusLabel = Instance.new("TextLabel")
	statusLabel.Size = UDim2.new(0, 50, 1, 0)
	statusLabel.Position = UDim2.new(1, -60, 0, 0)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Text = "OFF"
	statusLabel.TextColor3 = Color3.fromRGB(200, 80, 80)
	statusLabel.TextSize = 12
	statusLabel.Font = Enum.Font.GothamBold
	statusLabel.Parent = toggle

	local toggleKey = name:gsub("[^%w]", "")
	local isEnabled = toggleStates[toggleKey] or false
	if isEnabled then
		statusLabel.Text = "ON"
		statusLabel.TextColor3 = Color3.fromRGB(80, 200, 80)
		stroke.Color = Theme.Accent
	end

	toggle.MouseButton1Click:Connect(function()
		isEnabled = not isEnabled
		toggleStates[toggleKey] = isEnabled
		if isEnabled then
			statusLabel.Text = "ON"
			statusLabel.TextColor3 = Color3.fromRGB(80, 200, 80)
			stroke.Color = Theme.Accent
		else
			statusLabel.Text = "OFF"
			statusLabel.TextColor3 = Color3.fromRGB(200, 80, 80)
			stroke.Color = Theme.Outline
		end
		if callback then pcall(callback, isEnabled) end
	end)
end

local function createButton(parent, name, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 35)
	btn.BackgroundColor3 = Theme.Button
	btn.BorderSizePixel = 0
	btn.Text = name
	btn.TextColor3 = Theme.Text
	btn.TextSize = 13
	btn.Font = Enum.Font.GothamMedium
	btn.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = Theme.CornerRadius
	corner.Parent = btn
	
	local stroke = Instance.new("UIStroke")
	stroke.Color = Theme.Outline
	stroke.Thickness = 1
	stroke.Parent = btn

	btn.MouseButton1Click:Connect(function() if callback then pcall(callback) end end)
end

local function createSlider(parent, name, minVal, maxVal, defaultVal, callback)
	local slider = Instance.new("Frame")
	slider.Size = UDim2.new(1, -10, 0, 55)
	slider.BackgroundColor3 = Theme.Container
	slider.BorderSizePixel = 0
	slider.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = Theme.CornerRadius
	corner.Parent = slider
	
	local stroke = Instance.new("UIStroke")
	stroke.Color = Theme.Outline
	stroke.Thickness = 1
	stroke.Parent = slider

	local sliderKey = name:gsub("[^%w]", "")
	local currentValue = sliderValues[sliderKey] or defaultVal

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -20, 0, 20)
	nameLabel.Position = UDim2.new(0, 15, 0, 5)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = name .. " : " .. tostring(currentValue)
	nameLabel.TextColor3 = Theme.Text
	nameLabel.TextSize = 13
	nameLabel.Font = Enum.Font.GothamMedium
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = slider

	local sliderBtn = Instance.new("TextButton")
	sliderBtn.Size = UDim2.new(1, -30, 0, 8)
	sliderBtn.Position = UDim2.new(0, 15, 0, 35)
	sliderBtn.BackgroundColor3 = Theme.Button
	sliderBtn.Text = ""
	sliderBtn.Parent = slider
	
	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(1, 0)
	btnCorner.Parent = sliderBtn

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((currentValue - minVal) / (maxVal - minVal), 0, 1, 0)
	fill.BackgroundColor3 = Theme.Accent
	fill.BorderSizePixel = 0
	fill.Parent = sliderBtn
	
	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(1, 0)
	fillCorner.Parent = fill

	local isDragging = false
	sliderBtn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDragging = true end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDragging = false end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local mousePos = input.Position.X
			local sliderPos = sliderBtn.AbsolutePosition.X
			local sliderSize = sliderBtn.AbsoluteSize.X
			local relativeX = math.clamp(mousePos - sliderPos, 0, sliderSize)
			local percentage = relativeX / sliderSize
			local value = math.floor(minVal + percentage * (maxVal - minVal))

			fill.Size = UDim2.new(percentage, 0, 1, 0)
			nameLabel.Text = name .. " : " .. tostring(value)
			sliderValues[sliderKey] = value
			if callback then pcall(callback, value) end
		end
	end)
end

-- KATEGORI MENU

local farmBtn = createCategoryButton("Farming", function(panel)
	createSectionTitle(panel, "Main Features")
	createToggle(panel, "Auto Mancing", function(state) guiFunctions.autoFish = state if state then startAutoFish() else stopAutoFish() end end)
	createToggle(panel, "Auto Perfect/Instant", function(state) guiFunctions.autoCastPerfect = state; guiFunctions.instantFish = state end)
	createSlider(panel, "Jeda Tangkapan", 0.1, 5, 1, function(val) guiFunctions.caughtDelay = val end)
	createSectionTitle(panel, "Auto Sell")
	createToggle(panel, "Auto Jual", function(state) _G.AutoSell = state if state then sellFish() end end)
	createSlider(panel, "Jeda Jual", 1, 120, 30, function(val) _G.SellDelay = val end)
end)

createCategoryButton("Teleport", function(panel)
	local locations = {
		{["name"] = "Fisherman Island", ["pos"] = Vector3.new(34.26, 9.62, 2803.64)},
		{["name"] = "Traveling Merchant", ["pos"] = Vector3.new(-137.52, 3.26, 2768.21)},
		{["name"] = "Planetary Observatory", ["pos"] = Vector3.new(394.75, 7.25, 2157.10)},
		{["name"] = "Crater Island", ["pos"] = Vector3.new(969.09, 7.36, 4872.45)},
		{["name"] = "Tropical Grove", ["pos"] = Vector3.new(-2129.40, 53.48, 3741.83)},
		{["name"] = "Weather Machine", ["pos"] = Vector3.new(-1519.58, 6.49, 1884.58)},
		{["name"] = "Coral Reefs", ["pos"] = Vector3.new(-3186.43, 10.02, 2250.93)},
		{["name"] = "Pirate Cove", ["pos"] = Vector3.new(3358.00, 4.19, 3519.95)}
	}
	createSectionTitle(panel, "Lokasi Utama")
	for _, loc in ipairs(locations) do
		createButton(panel, loc.name, function()
			local char = Players.LocalPlayer.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				char.HumanoidRootPart.CFrame = CFrame.new(loc.pos)
			end
		end)
	end
end)

createCategoryButton("Shop & Weather", function(panel)
	createSectionTitle(panel, "Toko")
	createButton(panel, "Buka/Tutup Toko", function()
		local m = Players.LocalPlayer:FindFirstChild("PlayerGui") and Players.LocalPlayer.PlayerGui:FindFirstChild("Merchant")
		if m and m:FindFirstChild("Main") then m.Main.Enabled = not m.Main.Enabled end
	end)
	createSectionTitle(panel, "Auto Buy")
	createToggle(panel, "Wind", function(state) autoWeatherEnabled["Wind"] = state if state then startAutoBuyWeather("Wind") else stopAutoBuyWeather("Wind") end end)
	createToggle(panel, "Storm", function(state) autoWeatherEnabled["Storm"] = state if state then startAutoBuyWeather("Storm") else stopAutoBuyWeather("Storm") end end)
	createToggle(panel, "Shark Hunt", function(state) autoWeatherEnabled["SharkHunt"] = state if state then startAutoBuyWeather("SharkHunt") else stopAutoBuyWeather("SharkHunt") end end)
end)

createCategoryButton("Auto Favorite", function(panel)
	createSectionTitle(panel, "Filter Kelangkaan")
	createToggle(panel, "Common", function(state) favoriteRarities["Common"] = state end)
	createToggle(panel, "Uncommon", function(state) favoriteRarities["Uncommon"] = state end)
	createToggle(panel, "Rare", function(state) favoriteRarities["Rare"] = state end)
	createToggle(panel, "Epic", function(state) favoriteRarities["Epic"] = state end)
	createToggle(panel, "Legendary", function(state) favoriteRarities["Legendary"] = state end)
	createToggle(panel, "Mythic", function(state) favoriteRarities["Mythic"] = state end)
	createToggle(panel, "SECRET", function(state) favoriteRarities["SECRET"] = state end)
end)

createCategoryButton("Settings", function(panel)
	createSectionTitle(panel, "Sistem")
	createToggle(panel, "Anti AFK", function(state) antiAFKEnabled = state if state then enableAntiAFK() else disableAntiAFK() end end)
	createToggle(panel, "Auto Rejoin", function(state) autorejoinEnabled = state if state then enableAutorejoin() else disableAutorejoin() end end)
	createToggle(panel, "Mode Malam", function(state) game.Lighting.ClockTime = state and 0 or 12 end)
end)

-- Buka tab pertama secara default
farmBtn.MouseButton1Click:Fire()
