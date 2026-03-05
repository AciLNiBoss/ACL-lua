local GameVersion = "1.0.0"
local ScriptEnabled = true

-- Services
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- Paksa masuk ke PlayerGui (Metode Kotak Merah yang terbukti berhasil di HP kamu)
local guiParent = LocalPlayer:WaitForChild("PlayerGui")

-- Hapus GUI lama jika ada (agar tidak dobel saat di-execute ulang)
if guiParent:FindFirstChild("ACL_HUB_MOBILE") then
	guiParent.ACL_HUB_MOBILE:Destroy()
end

-- Variables Global
local guiFunctions = {
	instantFish = false,
	autoCastPerfect = false,
	autoFish = false,
	caughtDelay = 1,
	recastDelay = 1
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
-- LOGIKA UTAMA (FUNGSI MEMANCING)
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
	if antiAFKConnection then task.cancel(antiAFKConnection); antiAFKConnection = nil end
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

local function disableAutorejoin() autorejoinEnabled = false end

-- Auto Mancing & Bypass (Instant & Perfect)
local autoFishConnection = nil
local function startAutoFish()
	if autoFishConnection then return end
	autoFishConnection = task.spawn(function()
		while guiFunctions.autoFish do
			-- Auto Perfect Cast
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

			-- Instant Fish (Bypass Minigame)
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
	if autoFishConnection then task.cancel(autoFishConnection); autoFishConnection = nil end
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
	if not merchantGui or not merchantGui:FindFirstChild("Main") then return end

	local weatherButtons = { ["Wind"] = nil, ["Cloudy"] = nil, ["Snow"] = nil, ["Storm"] = nil, ["Shining"] = nil, ["SharkHunt"] = nil }
	for _, descendant in pairs(merchantGui.Main:GetDescendants()) do
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

task.spawn(function()
	task.wait(2)
	detectWeatherProductIds()
end)

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
-- PEMBUATAN UI MOBILE (LANGSUNG MUNCUL)
----------------------------------------

local Theme = {
	Background = Color3.fromRGB(20, 20, 25),
	Header = Color3.fromRGB(15, 15, 20),
	Container = Color3.fromRGB(30, 30, 35),
	Button = Color3.fromRGB(45, 45, 50),
	Accent = Color3.fromRGB(0, 120, 215),
	Text = Color3.fromRGB(240, 240, 240),
	TextMuted = Color3.fromRGB(150, 150, 150)
}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ACL_HUB_MOBILE"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999999999 -- Pastikan di atas semua UI Game
screenGui.IgnoreGuiInset = true
screenGui.Parent = guiParent

local window = Instance.new("Frame")
window.Size = UDim2.new(0, 500, 0, 320) -- Ukuran Pas untuk Layar HP Landscape
window.Position = UDim2.new(0.5, -250, 0.5, -160)
window.BackgroundColor3 = Theme.Background
window.BorderSizePixel = 0
window.Active = true
window.Draggable = true -- Bisa digeser dengan disentuh
window.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = window

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 45)
header.BackgroundColor3 = Theme.Header
header.BorderSizePixel = 0
header.Parent = window

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "ACL HUB | Fish It (Mobile)"
title.TextColor3 = Theme.Text
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- Tombol X (Tutup Menu)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 45, 0, 45)
closeBtn.Position = UDim2.new(1, -45, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = header

closeBtn.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

-- Layout Panel
local leftPanel = Instance.new("ScrollingFrame")
leftPanel.Size = UDim2.new(0, 150, 1, -55)
leftPanel.Position = UDim2.new(0, 10, 0, 50)
leftPanel.BackgroundTransparency = 1
leftPanel.BorderSizePixel = 0
leftPanel.ScrollBarThickness = 0
leftPanel.Parent = window

local leftLayout = Instance.new("UIListLayout")
leftLayout.Padding = UDim.new(0, 5)
leftLayout.Parent = leftPanel

local rightPanel = Instance.new("ScrollingFrame")
rightPanel.Size = UDim2.new(1, -170, 1, -55)
rightPanel.Position = UDim2.new(0, 160, 0, 50)
rightPanel.BackgroundTransparency = 1
rightPanel.BorderSizePixel = 0
rightPanel.ScrollBarThickness = 4
rightPanel.ScrollBarImageColor3 = Theme.Button
rightPanel.Parent = window

local currentCategoryBtn = nil

local function clearRightPanel()
	for _, child in pairs(rightPanel:GetChildren()) do
		if not child:IsA("UIListLayout") then child:Destroy() end
	end
end

local function createCategoryButton(name, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 40)
	btn.BackgroundColor3 = Theme.Background
	btn.BorderSizePixel = 0
	btn.Text = "  " .. name
	btn.TextColor3 = Theme.TextMuted
	btn.TextSize = 14
	btn.Font = Enum.Font.GothamMedium
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.Parent = leftPanel

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
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
		
		task.delay(0.05, function()
			rightPanel.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
		end)
	end)

	return btn
end

local function createSectionTitle(panel, titleText)
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 25)
	title.BackgroundTransparency = 1
	title.Text = titleText
	title.TextColor3 = Theme.Text
	title.TextSize = 14
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = panel
end

local function createToggle(parent, name, callback)
	local toggle = Instance.new("TextButton")
	toggle.Size = UDim2.new(1, -10, 0, 45)
	toggle.BackgroundColor3 = Theme.Container
	toggle.BorderSizePixel = 0
	toggle.Text = ""
	toggle.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = toggle

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -70, 1, 0)
	nameLabel.Position = UDim2.new(0, 15, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = name
	nameLabel.TextColor3 = Theme.Text
	nameLabel.TextSize = 14
	nameLabel.Font = Enum.Font.GothamMedium
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = toggle

	local statusLabel = Instance.new("TextLabel")
	statusLabel.Size = UDim2.new(0, 50, 1, 0)
	statusLabel.Position = UDim2.new(1, -60, 0, 0)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Text = "OFF"
	statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
	statusLabel.TextSize = 14
	statusLabel.Font = Enum.Font.GothamBold
	statusLabel.Parent = toggle

	local toggleKey = name:gsub("[^%w]", "")
	local isEnabled = toggleStates[toggleKey] or false
	if isEnabled then
		statusLabel.Text = "ON"
		statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
	end

	toggle.MouseButton1Click:Connect(function()
		isEnabled = not isEnabled
		toggleStates[toggleKey] = isEnabled
		if isEnabled then
			statusLabel.Text = "ON"
			statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
		else
			statusLabel.Text = "OFF"
			statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
		end
		if callback then pcall(callback, isEnabled) end
	end)
end

local function createButton(parent, name, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 40)
	btn.BackgroundColor3 = Theme.Button
	btn.BorderSizePixel = 0
	btn.Text = name
	btn.TextColor3 = Theme.Text
	btn.TextSize = 14
	btn.Font = Enum.Font.GothamMedium
	btn.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = btn

	btn.MouseButton1Click:Connect(function()
		if callback then pcall(callback) end
	end)
end

local function createSlider(parent, name, minVal, maxVal, defaultVal, callback)
	local slider = Instance.new("Frame")
	slider.Size = UDim2.new(1, -10, 0, 60)
	slider.BackgroundColor3 = Theme.Container
	slider.BorderSizePixel = 0
	slider.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = slider

	local sliderKey = name:gsub("[^%w]", "")
	local currentValue = sliderValues[sliderKey] or defaultVal

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -20, 0, 25)
	nameLabel.Position = UDim2.new(0, 10, 0, 5)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = name .. ": " .. tostring(currentValue)
	nameLabel.TextColor3 = Theme.Text
	nameLabel.TextSize = 14
	nameLabel.Font = Enum.Font.GothamMedium
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = slider

	local sliderBtn = Instance.new("TextButton")
	sliderBtn.Size = UDim2.new(1, -20, 0, 15)
	sliderBtn.Position = UDim2.new(0, 10, 0, 35)
	sliderBtn.BackgroundColor3 = Theme.Button
	sliderBtn.Text = ""
	sliderBtn.Parent = slider

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((currentValue - minVal) / (maxVal - minVal), 0, 1, 0)
	fill.BackgroundColor3 = Theme.Accent
	fill.BorderSizePixel = 0
	fill.Parent = sliderBtn

	local isDragging = false
	sliderBtn.InputBegan:Connect(function(input)
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
			local sliderPos = sliderBtn.AbsolutePosition.X
			local sliderSize = sliderBtn.AbsoluteSize.X
			local relativeX = math.clamp(mousePos - sliderPos, 0, sliderSize)
			local percentage = relativeX / sliderSize
			local value = math.floor(minVal + percentage * (maxVal - minVal))

			fill.Size = UDim2.new(percentage, 0, 1, 0)
			nameLabel.Text = name .. ": " .. tostring(value)
			sliderValues[sliderKey] = value
			if callback then pcall(callback, value) end
		end
	end)
end

-- ISI KATEGORI (DISEDERHANAKAN & OPTIMAL UNTUK MOBILE)

local farmBtn = createCategoryButton("Farming", function(panel)
	createToggle(panel, "Auto Mancing", function(state) guiFunctions.autoFish = state if state then startAutoFish() else stopAutoFish() end end)
	createToggle(panel, "Auto Perfect/Good Cast", function(state) guiFunctions.autoCastPerfect = state end)
	createToggle(panel, "Instant Fish", function(state) guiFunctions.instantFish = state end)
	createSlider(panel, "Jeda Tangkapan", 0.1, 5, 1, function(val) guiFunctions.caughtDelay = val end)
	createSlider(panel, "Jeda Lempar", 0.1, 5, 1, function(val) guiFunctions.recastDelay = val end)
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
		{["name"] = "Pirate Cove", ["pos"] = Vector3.new(3358.00, 4.19, 3519.95)},
		{["name"] = "Leviathan's Lair", ["pos"] = Vector3.new(3473.52, -287.84, 3474.17)},
		{["name"] = "Crystal Depths", ["pos"] = Vector3.new(5686.94, -891.06, 15294.73)},
		{["name"] = "Kohana", ["pos"] = Vector3.new(-643.00, 16.03, 615.07)},
		{["name"] = "Lava Basin", ["pos"] = Vector3.new(1042.16, 85.89, -10246.27)},
		{["name"] = "Ancient Jungle", ["pos"] = Vector3.new(1453.71, 7.62, -329.97)}
	}
	createSectionTitle(panel, "Lokasi Pulau:")
	for _, loc in ipairs(locations) do
		createButton(panel, "📍 " .. loc.name, function()
			local char = Players.LocalPlayer.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				char.HumanoidRootPart.CFrame = CFrame.new(loc.pos)
			end
		end)
	end
end)

createCategoryButton("Toko & Cuaca", function(panel)
	createButton(panel, "Buka/Tutup Toko", function()
		local m = Players.LocalPlayer:FindFirstChild("PlayerGui") and Players.LocalPlayer.PlayerGui:FindFirstChild("Merchant")
		if m and m:FindFirstChild("Main") then m.Main.Enabled = not m.Main.Enabled end
	end)
	createSectionTitle(panel, "Auto Beli Cuaca:")
	createToggle(panel, "Angin (Wind)", function(state) autoWeatherEnabled["Wind"] = state if state then startAutoBuyWeather("Wind") else stopAutoBuyWeather("Wind") end end)
	createToggle(panel, "Mendung (Cloudy)", function(state) autoWeatherEnabled["Cloudy"] = state if state then startAutoBuyWeather("Cloudy") else stopAutoBuyWeather("Cloudy") end end)
	createToggle(panel, "Salju (Snow)", function(state) autoWeatherEnabled["Snow"] = state if state then startAutoBuyWeather("Snow") else stopAutoBuyWeather("Snow") end end)
	createToggle(panel, "Badai (Storm)", function(state) autoWeatherEnabled["Storm"] = state if state then startAutoBuyWeather("Storm") else stopAutoBuyWeather("Storm") end end)
	createToggle(panel, "Cerah (Shining)", function(state) autoWeatherEnabled["Shining"] = state if state then startAutoBuyWeather("Shining") else stopAutoBuyWeather("Shining") end end)
	createToggle(panel, "Shark Hunt", function(state) autoWeatherEnabled["SharkHunt"] = state if state then startAutoBuyWeather("SharkHunt") else stopAutoBuyWeather("SharkHunt") end end)
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

createCategoryButton("Lainnya", function(panel)
	createToggle(panel, "Anti AFK", function(state) antiAFKEnabled = state if state then enableAntiAFK() else disableAntiAFK() end end)
	createToggle(panel, "Auto Rejoin", function(state) autorejoinEnabled = state if state then enableAutorejoin() else disableAutorejoin() end end)
	createToggle(panel, "Mode Malam", function(state) game.Lighting.ClockTime = state and 0 or 12 end)
end)

-- Buka tab pertama secara default
farmBtn.MouseButton1Click:Fire()
