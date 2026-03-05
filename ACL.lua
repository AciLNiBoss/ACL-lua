local GameVersion = "1.0.0"
local ScriptEnabled = true

-- Services
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

print("=== ACL HUB Diinisialisasi ===")

-- Pengaturan Tema Modern Smooth
local Theme = {
	Background = Color3.fromRGB(20, 20, 25),
	Header = Color3.fromRGB(15, 15, 20),
	Container = Color3.fromRGB(30, 30, 35),
	Button = Color3.fromRGB(40, 40, 45),
	ButtonHover = Color3.fromRGB(55, 55, 65),
	Accent = Color3.fromRGB(0, 120, 215),
	Text = Color3.fromRGB(240, 240, 240),
	TextMuted = Color3.fromRGB(150, 150, 150),
	CornerRadius = UDim.new(0, 6)
}

-- Keamanan GUI (Menggunakan metode yang TERBUKTI berhasil di executor kamu)
local function getSecureGuiParent()
	local targetParent
	pcall(function() targetParent = gethui() end)
	if not targetParent then pcall(function() targetParent = game:GetService("CoreGui") end) end
	if not targetParent then targetParent = LocalPlayer:WaitForChild("PlayerGui", 5) end
	return targetParent
end

local guiParent = getSecureGuiParent()

-- Variables Global
local mainGui = nil
local iconGui = nil
local isGuiVisible = false
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
local menuKeybind = Enum.KeyCode.G
local menuKeybindName = "G"

local autorejoinEnabled = false
local autorejoinBound = false
local antiAFKEnabled = false
local antiAFKConnection = nil
local optimizationV2Active = false
local optimizationV2Connections = {}

----------------------------------------
-- LOGIKA UTAMA (FUNGSI ASLI GAME)
----------------------------------------

-- Anti AFK
local function enableAntiAFK()
	if antiAFKConnection then task.cancel(antiAFKConnection) end
	local VirtualInputService = game:GetService("VirtualInputService")
	antiAFKConnection = task.spawn(function()
		while antiAFKEnabled do
			task.wait(120)
			if not antiAFKEnabled then break end
			pcall(function()
				VirtualInputService:SendKeyEvent(true, Enum.KeyCode.W, false, game)
				task.wait(0.1)
				VirtualInputService:SendKeyEvent(false, Enum.KeyCode.W, false, game)
			end)
		end
	end)
end

local function disableAntiAFK()
	antiAFKEnabled = false
	if antiAFKConnection then
		task.cancel(antiAFKConnection)
		antiAFKConnection = nil
	end
end

-- Auto Rejoin
local function enableAutorejoin()
	if not autorejoinBound then
		autorejoinBound = true
		game:BindToClose(function()
			if autorejoinEnabled then
				local TeleportService = game:GetService("TeleportService")
				pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Players.LocalPlayer) end)
				task.wait(1)
				pcall(function() TeleportService:Teleport(game.PlaceId, Players.LocalPlayer) end)
			end
		end)
	end
end

local function disableAutorejoin()
	autorejoinEnabled = false
end

-- Auto Mancing & Bypass
local autoFishConnection = nil
local function startAutoFish()
	if autoFishConnection then return end
	autoFishConnection = task.spawn(function()
		while guiFunctions.autoFish do
			
			-- 1. Logika Auto Perfect Cast
			if guiFunctions.autoCastPerfect then
				local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
				if playerGui then
					for _, ui in pairs(playerGui:GetDescendants()) do
						if ui:IsA("TextLabel") and (ui.Text:match("Perfect") or ui.Text:match("Good")) then
							if ui.Parent and ui.Parent:IsA("GuiButton") then
								pcall(function() getsenv(ui.Parent.LocalScript).CastPerfect() end)
							end
						end
					end
				end
			end

			-- 2. Logika Instant Fish (Bypass Minigame)
			if guiFunctions.instantFish then
				local replicatedStorage = game:GetService("ReplicatedStorage")
				local remotes = replicatedStorage:FindFirstChild("Remotes") or replicatedStorage:FindFirstChild("Events")
				if remotes then
					pcall(function()
						for _, event in pairs(remotes:GetChildren()) do
							local name = event.Name:lower()
							if name:match("fish") or name:match("catch") or name:match("minigame") then
								if event:IsA("RemoteEvent") then
									event:FireServer("Perfect", true)
								elseif event:IsA("RemoteFunction") then
									event:InvokeServer("Perfect", true)
								end
							end
						end
					end)
				end
			end
			
			task.wait(guiFunctions.caughtDelay or 1)
		end
		autoFishConnection = nil
	end)
end

local function stopAutoFish()
	guiFunctions.autoFish = false
	if autoFishConnection then
		task.cancel(autoFishConnection)
		autoFishConnection = nil
	end
end

-- Auto Jual
local sellThread = nil
_G.AutoSell = false
_G.SellDelay = 30

local function autosell()
	while _G.AutoSell do
		local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
		if playerGui then
			local merchantGui = playerGui:FindFirstChild("Merchant")
			if merchantGui then
				local main = merchantGui:FindFirstChild("Main")
				if main then
					for _, descendant in pairs(main:GetDescendants()) do
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

-- Webhook
local function sendWebhook(fishName, rarity)
	if webhookUrl == "" then return end
	local data = {
		["embeds"] = {{
			["title"] = "Ikan Baru Ditangkap",
			["description"] = string.format("**Ikan:** %s\n**Kelangkaan:** %s", fishName, rarity),
			["color"] = 3447003,
			["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
		}}
	}
	pcall(function()
		HttpService:RequestAsync({
			Url = webhookUrl, Method = "POST",
			Headers = {["Content-Type"] = "application/json"},
			Body = HttpService:JSONEncode(data)
		})
	end)
end

-- Optimalisasi V2 (Potato)
local function enableOptimizationV2()
	if optimizationV2Active then return end
	optimizationV2Active = true
	local Lighting = game:GetService("Lighting")
	local Workspace = game:GetService("Workspace")

	pcall(function()
		Lighting.GlobalShadows = false
		Lighting.FogEnd = 1e9
		Lighting.Brightness = 1
		Lighting.Ambient = Color3.fromRGB(140,140,140)
		Lighting.OutdoorAmbient = Color3.fromRGB(140,140,140)
	end)

	for _,v in ipairs(Lighting:GetChildren()) do
		if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Sky") then v:Destroy() end
	end

	local function cleanPart(part)
		part.CastShadow = false
		part.Reflectance = 0
		part.Material = Enum.Material.Plastic
		part.Color = Color3.fromRGB(150,150,150)
	end

	for _,obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") then
			cleanPart(obj)
		elseif obj:IsA("Decal") or obj:IsA("Texture") or obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
			obj:Destroy()
		end
	end

	settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
end

local function disableOptimizationV2()
	optimizationV2Active = false
	for _, connection in pairs(optimizationV2Connections) do
		if connection then connection:Disconnect() end
	end
	optimizationV2Connections = {}
end

-- Optimalisasi Dasar (V1)
local originalSettings = {}
local optimizationActive = false

local function enableOptimization()
	if optimizationActive then return end
	optimizationActive = true

	local UserGameSettings = game:GetService("UserGameSettings")
	originalSettings.QualityLevel = UserGameSettings.QualityLevel
	UserGameSettings.SavedQualityLevel = Enum.QualityLevel.Level01
	UserGameSettings.QualityLevel = Enum.QualityLevel.Level01

	local Lighting = game:GetService("Lighting")
	Lighting.GlobalShadows = false
	Lighting.Technology = Enum.Technology.Compatibility

	for _, child in pairs(Lighting:GetChildren()) do
		if child:IsA("PostEffect") then child:Destroy() end
	end
end

local function disableOptimization()
	if not optimizationActive then return end
	optimizationActive = false
	local UserGameSettings = game:GetService("UserGameSettings")
	if originalSettings.QualityLevel then UserGameSettings.QualityLevel = originalSettings.QualityLevel end
end

-- Auto Beli Cuaca
local function buyWeather(weatherName)
	local MarketplaceService = game:GetService("MarketplaceService")
	local productId = weatherProductIds[weatherName]
	if productId == 0 then return false end
	pcall(function() MarketplaceService:PromptProductPurchase(Players.LocalPlayer, productId) end)
end

local function detectWeatherProductIds()
	local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
	if not playerGui then return end
	local merchantGui = playerGui:FindFirstChild("Merchant")
	if not merchantGui then return end
	local main = merchantGui:FindFirstChild("Main")
	if not main then return end

	local weatherButtons = { ["Wind"] = nil, ["Cloudy"] = nil, ["Snow"] = nil, ["Storm"] = nil, ["Shining"] = nil, ["SharkHunt"] = nil }

	for _, descendant in pairs(main:GetDescendants()) do
		if descendant:IsA("TextButton") or descendant:IsA("ImageButton") then
			local text = descendant.Text or ""
			local name = descendant.Name or ""
			for weatherName, _ in pairs(weatherButtons) do
				if string.find(text:lower(), weatherName:lower()) or string.find(name:lower(), weatherName:lower()) then
					local productId = descendant:GetAttribute("ProductId") or descendant:GetAttribute("ProductID") or descendant:GetAttribute("ProductIdValue")
					if productId then weatherProductIds[weatherName] = tonumber(productId) end
				end
			end
		end
	end
end

Players.LocalPlayer.CharacterAdded:Connect(function()
	task.wait(2)
	detectWeatherProductIds()
end)
task.wait(2)
detectWeatherProductIds()

local function startAutoBuyWeather(weatherName)
	if weatherConnections[weatherName] then task.cancel(weatherConnections[weatherName]) end
	weatherConnections[weatherName] = task.spawn(function()
		while autoWeatherEnabled[weatherName] do
			buyWeather(weatherName)
			task.wait(5)
		end
	end)
end

local function stopAutoBuyWeather(weatherName)
	if weatherConnections[weatherName] then
		task.cancel(weatherConnections[weatherName])
		weatherConnections[weatherName] = nil
	end
end

----------------------------------------
-- KOMPONEN UI ACL HUB
----------------------------------------

local function applySmoothHover(button, originalColor)
	button.MouseEnter:Connect(function() TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ButtonHover}):Play() end)
	button.MouseLeave:Connect(function() TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = originalColor}):Play() end)
end

local function createToggle(parent, name, callback)
	local toggle = Instance.new("Frame")
	toggle.Name = name:gsub("[^%w]", "") .. "Toggle"
	toggle.Size = UDim2.new(1, 0, 0, 45)
	toggle.BackgroundColor3 = Theme.Container
	toggle.BorderSizePixel = 0
	toggle.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = Theme.CornerRadius
	corner.Parent = toggle

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0, 250, 1, 0)
	nameLabel.Position = UDim2.new(0, 15, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = name
	nameLabel.TextColor3 = Theme.Text
	nameLabel.TextSize = 13
	nameLabel.Font = Enum.Font.GothamMedium
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = toggle

	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Size = UDim2.new(0, 50, 0, 25)
	toggleBtn.Position = UDim2.new(1, -65, 0.5, -12)
	toggleBtn.BorderSizePixel = 0
	toggleBtn.Text = "OFF"
	toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	toggleBtn.TextSize = 11
	toggleBtn.Font = Enum.Font.GothamBold
	toggleBtn.Parent = toggle

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 12)
	btnCorner.Parent = toggleBtn

	local toggleKey = name:gsub("[^%w]", "")
	local isEnabled = toggleStates[toggleKey] or false

	toggleBtn.BackgroundColor3 = isEnabled and Theme.Accent or Theme.Button
	toggleBtn.Text = isEnabled and "ON" or "OFF"

	toggleBtn.MouseButton1Click:Connect(function()
		isEnabled = not isEnabled
		toggleStates[toggleKey] = isEnabled
		TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = isEnabled and Theme.Accent or Theme.Button}):Play()
		toggleBtn.Text = isEnabled and "ON" or "OFF"
		if callback then pcall(callback, isEnabled) end
	end)

	return toggle
end

local function createButton(parent, name, callback)
	local btn = Instance.new("TextButton")
	btn.Name = name:gsub("[^%w]", "") .. "Button"
	btn.Size = UDim2.new(1, 0, 0, 40)
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

	applySmoothHover(btn, Theme.Button)

	btn.MouseButton1Click:Connect(function()
		local clickTween = TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Accent})
		clickTween:Play()
		task.wait(0.1)
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ButtonHover}):Play()
		if callback then pcall(callback) end
	end)

	return btn
end

local function createSlider(parent, name, minVal, maxVal, defaultVal, callback)
	local slider = Instance.new("Frame")
	slider.Name = name:gsub("[^%w]", "") .. "Slider"
	slider.Size = UDim2.new(1, 0, 0, 65)
	slider.BackgroundColor3 = Theme.Container
	slider.BorderSizePixel = 0
	slider.Parent = parent

	local containerCorner = Instance.new("UICorner")
	containerCorner.CornerRadius = Theme.CornerRadius
	containerCorner.Parent = slider

	local sliderKey = name:gsub("[^%w]", "")
	local currentValue = sliderValues[sliderKey] or defaultVal

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -30, 0, 25)
	nameLabel.Position = UDim2.new(0, 15, 0, 5)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = name .. ": " .. tostring(currentValue)
	nameLabel.TextColor3 = Theme.Text
	nameLabel.TextSize = 13
	nameLabel.Font = Enum.Font.GothamMedium
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = slider

	local sliderBar = Instance.new("Frame")
	sliderBar.Size = UDim2.new(1, -30, 0, 6)
	sliderBar.Position = UDim2.new(0, 15, 0, 40)
	sliderBar.BackgroundColor3 = Theme.Button
	sliderBar.BorderSizePixel = 0
	sliderBar.Parent = slider

	local barCorner = Instance.new("UICorner")
	barCorner.CornerRadius = UDim.new(1, 0)
	barCorner.Parent = sliderBar

	local fillBar = Instance.new("Frame")
	fillBar.Size = UDim2.new((currentValue - minVal) / (maxVal - minVal), 0, 1, 0)
	fillBar.BackgroundColor3 = Theme.Accent
	fillBar.BorderSizePixel = 0
	fillBar.Parent = sliderBar

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(1, 0)
	fillCorner.Parent = fillBar

	local sliderBtn = Instance.new("TextButton")
	sliderBtn.Size = UDim2.new(0, 16, 0, 16)
	sliderBtn.Position = UDim2.new(1, -8, 0.5, -8)
	sliderBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	sliderBtn.BorderSizePixel = 0
	sliderBtn.Text = ""
	sliderBtn.Parent = fillBar

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(1, 0)
	btnCorner.Parent = sliderBtn

	local isDragging = false
	sliderBtn.MouseButton1Down:Connect(function() isDragging = true end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = false end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local mousePos = input.Position
			local sliderPos = sliderBar.AbsolutePosition
			local sliderSize = sliderBar.AbsoluteSize

			local relativeX = math.clamp(mousePos.X - sliderPos.X, 0, sliderSize.X)
			local percentage = relativeX / sliderSize.X
			local value = math.floor(minVal + percentage * (maxVal - minVal))

			fillBar.Size = UDim2.new(percentage, 0, 1, 0)
			nameLabel.Text = name .. ": " .. tostring(value)
			sliderValues[sliderKey] = value

			if callback then pcall(callback, value) end
		end
	end)

	return slider
end

local function createMainGUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ACL_HUB_Main"
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 999999998 -- Memaksa UI tampil di depan
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = guiParent

	local window = Instance.new("Frame")
	window.Name = "MainWindow"
	-- UI LANGSUNG UKURAN PENUH TANPA ANIMASI (Fix untuk Mobile Executor)
	window.Size = UDim2.new(0, 600, 0, 380)
	window.Position = UDim2.new(0.5, -300, 0.5, -190)
	window.BackgroundColor3 = Theme.Background
	window.BorderSizePixel = 0
	window.Parent = screenGui
	window.ClipsDescendants = true

	local corner = Instance.new("UICorner")
	corner.CornerRadius = Theme.CornerRadius
	corner.Parent = window

	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 40)
	header.BackgroundColor3 = Theme.Header
	header.BorderSizePixel = 0
	header.Parent = window

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -20, 1, 0)
	title.Position = UDim2.new(0, 15, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "ACL HUB - Fish It"
	title.TextColor3 = Theme.Text
	title.TextSize = 14
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = header

	-- Window Dragging Logic
	local isDragging, dragStart, startPos
	header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isDragging = true
			dragStart = input.Position
			startPos = window.Position
		end
	end)
	header.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDragging = false end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and isDragging then
			local delta = input.Position - dragStart
			window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	-- Close Button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 40, 0, 40)
	closeBtn.Position = UDim2.new(1, -40, 0, 0)
	closeBtn.BackgroundTransparency = 1
	closeBtn.Text = "X"
	closeBtn.TextColor3 = Theme.TextMuted
	closeBtn.TextSize = 14
	closeBtn.Font = Enum.Font.GothamMedium
	closeBtn.Parent = header

	closeBtn.MouseEnter:Connect(function() closeBtn.TextColor3 = Color3.fromRGB(255, 50, 50) end)
	closeBtn.MouseLeave:Connect(function() closeBtn.TextColor3 = Theme.TextMuted end)
	
	closeBtn.MouseButton1Click:Connect(function()
		screenGui:Destroy()
		if iconGui then iconGui:Destroy() end
		ScriptEnabled = false
		if autoFishConnection then task.cancel(autoFishConnection) end
		if sellThread then task.cancel(sellThread) end
		for _, conn in pairs(weatherConnections) do task.cancel(conn) end
	end)

	-- Layout configuration
	local leftPanel = Instance.new("ScrollingFrame")
	leftPanel.Size = UDim2.new(0, 160, 1, -55)
	leftPanel.Position = UDim2.new(0, 10, 0, 50)
	leftPanel.BackgroundTransparency = 1
	leftPanel.BorderSizePixel = 0
	leftPanel.ScrollBarThickness = 2
	leftPanel.ScrollBarImageColor3 = Theme.Button
	leftPanel.CanvasSize = UDim2.new(0, 0, 0, 0)
	leftPanel.Parent = window

	local leftLayout = Instance.new("UIListLayout")
	leftLayout.Padding = UDim.new(0, 8)
	leftLayout.Parent = leftPanel

	local rightPanel = Instance.new("ScrollingFrame")
	rightPanel.Size = UDim2.new(1, -190, 1, -55)
	rightPanel.Position = UDim2.new(0, 180, 0, 50)
	rightPanel.BackgroundTransparency = 1
	rightPanel.BorderSizePixel = 0
	rightPanel.ScrollBarThickness = 4
	rightPanel.ScrollBarImageColor3 = Theme.Button
	rightPanel.CanvasSize = UDim2.new(0, 0, 0, 0)
	rightPanel.Parent = window

	local currentCategoryBtn = nil

	local function clearRightPanel()
		for _, child in pairs(rightPanel:GetChildren()) do
			if not child:IsA("UIListLayout") then child:Destroy() end
		end
	end

	local function createCategoryButton(name, callback)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, -5, 0, 35)
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
				TweenService:Create(currentCategoryBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Background, TextColor3 = Theme.TextMuted}):Play()
			end
			currentCategoryBtn = btn
			TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Container, TextColor3 = Theme.Text}):Play()

			clearRightPanel()

			local layout = Instance.new("UIListLayout")
			layout.Padding = UDim.new(0, 10)
			layout.Parent = rightPanel

			if callback then callback(rightPanel) end
			
			task.delay(0.05, function()
				rightPanel.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
			end)
		end)

		return btn
	end

	local function createSectionTitle(panel, titleText)
		local title = Instance.new("TextLabel")
		title.Size = UDim2.new(1, 0, 0, 30)
		title.BackgroundTransparency = 1
		title.Text = titleText
		title.TextColor3 = Theme.Text
		title.TextSize = 14
		title.Font = Enum.Font.GothamBold
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.Parent = panel
		return title
	end

	-- KATEGORI MENU
	createCategoryButton("Farming", function(panel)
		createToggle(panel, "Auto Mancing", function(state) guiFunctions.autoFish = state if state then startAutoFish() else stopAutoFish() end end)
		createToggle(panel, "Auto Perfect/Good Cast", function(state) guiFunctions.autoCastPerfect = state end)
		createToggle(panel, "Instant Fish (Skip Minigame)", function(state) guiFunctions.instantFish = state end)
		createSlider(panel, "Jeda Tangkapan", 0.1, 5, 1, function(val) guiFunctions.caughtDelay = val end)
		createSlider(panel, "Jeda Lempar", 0.1, 5, 1, function(val) guiFunctions.recastDelay = val end)
		createToggle(panel, "Auto Jual", function(state) _G.AutoSell = state if state then sellFish() end end)
		createSlider(panel, "Jeda Jual", 1, 120, 30, function(val) _G.SellDelay = val end)
	end)

	createCategoryButton("Teleportasi", function(panel)
		createButton(panel, "Teleportasi ke Pulau", function()
			clearRightPanel()
			local layout = Instance.new("UIListLayout")
			layout.Padding = UDim.new(0, 10)
			layout.Parent = rightPanel
			
			createSectionTitle(rightPanel, "Pilih Lokasi:")

			local locations = {
				{["name"] = "Fisherman Island", ["pos"] = Vector3.new(34.26, 9.62, 2803.64)},
				{["name"] = "Traveling Merchant", ["pos"] = Vector3.new(-137.52, 3.26, 2768.21)},
				{["name"] = "Planetary Observatory", ["pos"] = Vector3.new(394.75, 7.25, 2157.10)},
				{["name"] = "Crater Island", ["pos"] = Vector3.new(969.09, 7.36, 4872.45)},
				{["name"] = "Tropical Grove", ["pos"] = Vector3.new(-2129.40, 53.48, 3741.83)},
				{["name"] = "Weather Machine", ["pos"] = Vector3.new(-1519.58, 6.49, 1884.58)},
				{["name"] = "Coral Reefs", ["pos"] = Vector3.new(-3186.43, 10.02, 2250.93)},
				{["name"] = "Crater Island 2", ["pos"] = Vector3.new(986.12, 30.20, 4952.65)},
				{["name"] = "Pirate Cove", ["pos"] = Vector3.new(3358.00, 4.19, 3519.95)},
				{["name"] = "Pirate Treasure Room", ["pos"] = Vector3.new(3302.26, -299.50, 3016.65)},
				{["name"] = "Leviathan's Lair", ["pos"] = Vector3.new(3473.52, -287.84, 3474.17)},
				{["name"] = "Crystal Depths", ["pos"] = Vector3.new(5686.94, -891.06, 15294.73)},
				{["name"] = "Esoteric Depths", ["pos"] = Vector3.new(3193.72, -1302.73, 1420.59)},
				{["name"] = "Kohana", ["pos"] = Vector3.new(-643.00, 16.03, 615.07)},
				{["name"] = "Kohana Volcano", ["pos"] = Vector3.new(-497.61, 22.39, 177.54)},
				{["name"] = "Lava Basin", ["pos"] = Vector3.new(1042.16, 85.89, -10246.27)},
				{["name"] = "Ancient Jungle", ["pos"] = Vector3.new(1453.71, 7.62, -329.97)},
				{["name"] = "Sacred Temple", ["pos"] = Vector3.new(1475.95, -21.84, -630.01)},
				{["name"] = "Ancient Ruin", ["pos"] = Vector3.new(6050.23, -585.92, 4713.17)},
				{["name"] = "Treasure Room", ["pos"] = Vector3.new(-3599.53, -266.57, -1572.31)},
				{["name"] = "Sisiphys Statue", ["pos"] = Vector3.new(-3698.33, -135.57, -1026.42)},
				{["name"] = "Underground Cellar", ["pos"] = Vector3.new(2135.52, -91.19, -699.44)}
			}

			for _, loc in ipairs(locations) do
				createButton(rightPanel, loc.name, function()
					local char = Players.LocalPlayer.Character
					if char and char:FindFirstChild("HumanoidRootPart") then
						char.HumanoidRootPart.CFrame = CFrame.new(loc.pos)
					end
				end)
			end
			
			task.delay(0.05, function()
				rightPanel.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
			end)
		end)

		createButton(panel, "Teleportasi ke Pemain", function()
			clearRightPanel()
			local layout = Instance.new("UIListLayout")
			layout.Padding = UDim.new(0, 10)
			layout.Parent = rightPanel

			createSectionTitle(rightPanel, "Pilih Pemain:")

			for _, player in pairs(Players:GetPlayers()) do
				if player ~= Players.LocalPlayer then
					createButton(rightPanel, player.Name, function()
						local myChar = Players.LocalPlayer.Character
						local targetChar = player.Character
						if myChar and targetChar and myChar:FindFirstChild("HumanoidRootPart") and targetChar:FindFirstChild("HumanoidRootPart") then
							myChar.HumanoidRootPart.CFrame = targetChar.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
						end
					end)
				end
			end
			
			task.delay(0.05, function()
				rightPanel.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
			end)
		end)
	end)

	createCategoryButton("Toko & Cuaca", function(panel)
		createButton(panel, "Buka/Tutup Toko", function()
			local merchantGui = Players.LocalPlayer:FindFirstChild("PlayerGui") and Players.LocalPlayer.PlayerGui:FindFirstChild("Merchant")
			if merchantGui and merchantGui:FindFirstChild("Main") then
				merchantGui.Main.Enabled = not merchantGui.Main.Enabled
			end
		end)
		createSectionTitle(panel, "Auto Beli Cuaca")
		createToggle(panel, "Auto Beli Wind", function(state) autoWeatherEnabled["Wind"] = state if state then startAutoBuyWeather("Wind") else stopAutoBuyWeather("Wind") end end)
		createToggle(panel, "Auto Beli Cloudy", function(state) autoWeatherEnabled["Cloudy"] = state if state then startAutoBuyWeather("Cloudy") else stopAutoBuyWeather("Cloudy") end end)
		createToggle(panel, "Auto Beli Snow", function(state) autoWeatherEnabled["Snow"] = state if state then startAutoBuyWeather("Snow") else stopAutoBuyWeather("Snow") end end)
		createToggle(panel, "Auto Beli Storm", function(state) autoWeatherEnabled["Storm"] = state if state then startAutoBuyWeather("Storm") else stopAutoBuyWeather("Storm") end end)
		createToggle(panel, "Auto Beli Shining", function(state) autoWeatherEnabled["Shining"] = state if state then startAutoBuyWeather("Shining") else stopAutoBuyWeather("Shining") end end)
		createToggle(panel, "Auto Beli SharkHunt", function(state) autoWeatherEnabled["SharkHunt"] = state if state then startAutoBuyWeather("SharkHunt") else stopAutoBuyWeather("SharkHunt") end end)
	end)

	createCategoryButton("Auto Favorit", function(panel)
		createToggle(panel, "Common", function(state) favoriteRarities["Common"] = state end)
		createToggle(panel, "Uncommon", function(state) favoriteRarities["Uncommon"] = state end)
		createToggle(panel, "Rare", function(state) favoriteRarities["Rare"] = state end)
		createToggle(panel, "Epic", function(state) favoriteRarities["Epic"] = state end)
		createToggle(panel, "Legendary", function(state) favoriteRarities["Legendary"] = state end)
		createToggle(panel, "Mythic", function(state) favoriteRarities["Mythic"] = state end)
		createToggle(panel, "SECRET", function(state) favoriteRarities["SECRET"] = state end)
	end)

	createCategoryButton("Webhook", function(panel)
		local webhookContainer = Instance.new("Frame")
		webhookContainer.Size = UDim2.new(1, 0, 0, 45)
		webhookContainer.BackgroundColor3 = Theme.Container
		webhookContainer.BorderSizePixel = 0
		webhookContainer.Parent = panel

		local corner = Instance.new("UICorner")
		corner.CornerRadius = Theme.CornerRadius
		corner.Parent = webhookContainer

		local webhookInput = Instance.new("TextBox")
		webhookInput.Size = UDim2.new(1, -30, 1, 0)
		webhookInput.Position = UDim2.new(0, 15, 0, 0)
		webhookInput.BackgroundTransparency = 1
		webhookInput.PlaceholderText = "URL Webhook Discord"
		webhookInput.Text = webhookUrl
		webhookInput.TextColor3 = Theme.Text
		webhookInput.PlaceholderColor3 = Theme.TextMuted
		webhookInput.TextSize = 13
		webhookInput.Font = Enum.Font.GothamMedium
		webhookInput.TextXAlignment = Enum.TextXAlignment.Left
		webhookInput.Parent = webhookContainer

		webhookInput.FocusLost:Connect(function(enterPressed)
			if enterPressed then webhookUrl = webhookInput.Text end
		end)
	end)

	local settingsBtn = createCategoryButton("Pengaturan", function(panel)
		local keybindFrame = Instance.new("Frame")
		keybindFrame.Size = UDim2.new(1, 0, 0, 45)
		keybindFrame.BackgroundColor3 = Theme.Container
		keybindFrame.BorderSizePixel = 0
		keybindFrame.Parent = panel

		local corner = Instance.new("UICorner")
		corner.CornerRadius = Theme.CornerRadius
		corner.Parent = keybindFrame

		local keybindLabel = Instance.new("TextLabel")
		keybindLabel.Size = UDim2.new(0, 200, 1, 0)
		keybindLabel.Position = UDim2.new(0, 15, 0, 0)
		keybindLabel.BackgroundTransparency = 1
		keybindLabel.Text = "Tombol Menu: " .. menuKeybindName
		keybindLabel.TextColor3 = Theme.Text
		keybindLabel.TextSize = 13
		keybindLabel.Font = Enum.Font.GothamMedium
		keybindLabel.TextXAlignment = Enum.TextXAlignment.Left
		keybindLabel.Parent = keybindFrame

		local keybindBtn = Instance.new("TextButton")
		keybindBtn.Size = UDim2.new(0, 80, 0, 25)
		keybindBtn.Position = UDim2.new(1, -95, 0.5, -12)
		keybindBtn.BackgroundColor3 = Theme.Button
		keybindBtn.BorderSizePixel = 0
		keybindBtn.Text = "Ubah"
		keybindBtn.TextColor3 = Theme.Text
		keybindBtn.TextSize = 11
		keybindBtn.Font = Enum.Font.GothamBold
		keybindBtn.Parent = keybindFrame

		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(0, 6)
		btnCorner.Parent = keybindBtn

		local isWaitingForKey = false
		keybindBtn.MouseButton1Click:Connect(function()
			if isWaitingForKey then return end
			isWaitingForKey = true
			keybindBtn.Text = "..."
			keybindBtn.BackgroundColor3 = Theme.Accent

			local inputConnection
			inputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
				if gameProcessed then return end
				if input.KeyCode ~= nil and input.KeyCode ~= Enum.KeyCode.Unknown then
					menuKeybind = input.KeyCode
					menuKeybindName = input.KeyCode.Name
					keybindLabel.Text = "Tombol Menu: " .. menuKeybindName
					keybindBtn.Text = "Ubah"
					keybindBtn.BackgroundColor3 = Theme.Button
					isWaitingForKey = false
					inputConnection:Disconnect()
				end
			end)
		end)

		createToggle(panel, "Anti AFK", function(state) antiAFKEnabled = state if state then enableAntiAFK() else disableAntiAFK() end end)
		createToggle(panel, "Auto Rejoin", function(state) autorejoinEnabled = state if state then enableAutorejoin() else disableAutorejoin() end end)
		createToggle(panel, "Optimalisasi V1 (Ringan)", function(state) guiFunctions.optimization = state if state then enableOptimization() else disableOptimization() end end)
		createToggle(panel, "Optimalisasi V2 (Potato)", function(state) optimizationV2Active = state if state then enableOptimizationV2() else disableOptimizationV2() end end)
		createToggle(panel, "Mode Malam", function(state) game.Lighting.ClockTime = state and 0 or 12 end)
	end)

	createCategoryButton("Info", function(panel)
		local infoContainer = Instance.new("Frame")
		infoContainer.Size = UDim2.new(1, 0, 0, 150)
		infoContainer.BackgroundColor3 = Theme.Container
		infoContainer.BorderSizePixel = 0
		infoContainer.Parent = panel

		local corner = Instance.new("UICorner")
		corner.CornerRadius = Theme.CornerRadius
		corner.Parent = infoContainer

		local infoText = Instance.new("TextLabel")
		infoText.Size = UDim2.new(1, -30, 1, -30)
		infoText.Position = UDim2.new(0, 15, 0, 15)
		infoText.BackgroundTransparency = 1
		infoText.Text = "ACL HUB - Roblox Fish It\n\nSkrip ini telah diperbaiki dan dibuat khusus agar kompatibel dengan Executor Mobile. Tekan ikon ACL biru untuk menyembunyikan atau memunculkan menu."
		infoText.TextColor3 = Theme.TextMuted
		infoText.TextSize = 13
		infoText.Font = Enum.Font.Gotham
		infoText.TextXAlignment = Enum.TextXAlignment.Left
		infoText.TextYAlignment = Enum.TextYAlignment.Top
		infoText.TextWrapped = true
		infoText.Parent = infoContainer
	end)

	settingsBtn:Fire()
	return screenGui
end

-- Floating Icon Setup (ACL Bypass)
local function createMenuIcon()
	local ig = Instance.new("ScreenGui")
	ig.Name = "ACL_Icon_Bypass"
	ig.ResetOnSpawn = false
	ig.DisplayOrder = 999999999 -- MEMAKSA TAMPIL DI DEPAN GAME
	ig.IgnoreGuiInset = true
	ig.Parent = guiParent

	local iconButton = Instance.new("TextButton")
	iconButton.Size = UDim2.new(0, 50, 0, 50)
	iconButton.Position = UDim2.new(0, 20, 0.5, 0)
	iconButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	iconButton.BorderSizePixel = 0
	iconButton.Text = "ACL"
	iconButton.TextColor3 = Color3.fromRGB(0, 120, 215)
	iconButton.TextSize = 16
	iconButton.Font = Enum.Font.GothamBold
	iconButton.Parent = ig

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = iconButton

	local isDragging = false
	local dragStart, startPos
	local isClick = true

	iconButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isDragging = true
			isClick = true
			dragStart = input.Position
			startPos = iconButton.Position
		end
	end)

	iconButton.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isDragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and isDragging then
			local delta = input.Position - dragStart
			if delta.Magnitude > 5 then isClick = false end
			iconButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	iconButton.MouseButton1Click:Connect(function()
		if isClick then
			toggleGUI()
		end
	end)

	return ig
end

-- Toggle Handler
toggleGUI = function()
	if not mainGui then
		mainGui = createMainGUI()
		if mainGui then isGuiVisible = true mainGui.Enabled = true end
	else
		isGuiVisible = not isGuiVisible
		mainGui.Enabled = isGuiVisible
	end
end

-- Keybind
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == menuKeybind then toggleGUI() end
end)

-- Start
iconGui = createMenuIcon()
task.wait(0.5)
toggleGUI()
