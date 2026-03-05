local GameVersion = "5.0.0 SAFE PREMIUM FULL"
local ScriptEnabled = true

-- Services
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Stats = game:GetService("Stats")
local LocalPlayer = Players.LocalPlayer

-- RANDOMISASI NAMA GUI (ANTI DETECT BAC-2223)
local GUI_NAME = HttpService:GenerateGUID(false):gsub("-", "")

print("=== ACL HUB SAFE PREMIUM FULL Diinisialisasi ===")

-- Pengaturan Tema Premium Modern
local Theme = {
	Background = Color3.fromRGB(15, 15, 20),
	Header = Color3.fromRGB(22, 22, 28),
	Container = Color3.fromRGB(26, 26, 32),
	Button = Color3.fromRGB(35, 35, 45),
	ButtonHover = Color3.fromRGB(45, 45, 60),
	Accent = Color3.fromRGB(0, 160, 255),
	ToggleOff = Color3.fromRGB(60, 60, 70),
	Outline = Color3.fromRGB(45, 45, 55),
	Text = Color3.fromRGB(250, 250, 250),
	TextMuted = Color3.fromRGB(160, 160, 160),
	CornerRadius = UDim.new(0, 8)
}

-- Keamanan GUI (Bypass Mobile & PC)
local function getSecureGuiParent()
	local targetParent
	pcall(function() targetParent = gethui() end)
	if not targetParent then pcall(function() targetParent = game:GetService("CoreGui") end) end
	if not targetParent then targetParent = LocalPlayer:WaitForChild("PlayerGui", 5) end
	return targetParent
end

local guiParent = getSecureGuiParent()
-- Hapus GUI lama jika tersisa
for _, child in pairs(guiParent:GetChildren()) do
	if child:IsA("ScreenGui") and child:FindFirstChild("MainWindow") then
		child:Destroy()
	end
end

-- Variables Global
local guiFunctions = {
	autoFish = false,
	instantFish = false,
	stableResult = false,
	randomCast = false,
	autoEquipRod = false,
	disableNotif = false,
	autoTotemMix = false,
	autoTrade = false,
	instantFishDelay = 3, 
	caughtDelay = 1
}
local toggleStates = {}
local sliderValues = {}
local webhookUrl = ""
local favoriteRarities = { ["Uncommon"]=false, ["Common"]=false, ["Rare"]=false, ["Epic"]=false, ["Legendary"]=false, ["Mythic"]=false, ["SECRET"]=false }
local autoWeatherEnabled = { ["Wind"]=false, ["Cloudy"]=false, ["Snow"]=false, ["Storm"]=false, ["Shining"]=false, ["SharkHunt"]=false }
local weatherProductIds = { ["Wind"]=7058120, ["Cloudy"]=7058120, ["Snow"]=7058120, ["Storm"]=7058120, ["Shining"]=7058120, ["SharkHunt"]=7058120 }
local weatherConnections = {}
local antiAFKEnabled = false
local antiAFKConnection = nil
local autorejoinEnabled = false
local autorejoinBound = false

----------------------------------------
-- LOGIKA FITUR
----------------------------------------

-- Safe Click Simulation
local function safeClick(x, y)
	VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 1)
	task.wait(0.05)
	VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1)
end

-- Looping Update (Setiap Detik)
task.spawn(function()
	while ScriptEnabled do
		task.wait(0.5)
		
		-- 1. Auto Equip Rod
		if guiFunctions.autoEquipRod then
			pcall(function()
				local char = LocalPlayer.Character
				if char and not char:FindFirstChildOfClass("Tool") then
					local backpack = LocalPlayer:FindFirstChild("Backpack")
					if backpack then
						for _, item in pairs(backpack:GetChildren()) do
							if item:IsA("Tool") and (item.Name:lower():match("rod") or item.Name:lower():match("pancing")) then
								char.Humanoid:EquipTool(item)
								break
							end
						end
					end
				end
			end)
		end

		-- 2. Disable Obtain Notification
		if guiFunctions.disableNotif then
			pcall(function()
				local pg = LocalPlayer:FindFirstChild("PlayerGui")
				if pg then
					for _, gui in pairs(pg:GetChildren()) do
						local name = gui.Name:lower()
						if name:match("obtain") or name:match("catch") or name:match("reward") or name:match("notification") then
							gui.Enabled = false
						end
					end
				end
			end)
		end
		
		-- 3. Auto Accept Trade
		if guiFunctions.autoTrade then
			pcall(function()
				local pg = LocalPlayer:FindFirstChild("PlayerGui")
				if pg then
					for _, gui in pairs(pg:GetDescendants()) do
						if gui:IsA("TextButton") and (gui.Text:lower():match("accept") or gui.Text:lower():match("terima")) then
							local parentName = gui.Parent and gui.Parent.Name:lower() or ""
							if parentName:match("trade") then
								safeClick(gui.AbsolutePosition.X + 10, gui.AbsolutePosition.Y + 10)
							end
						end
					end
				end
			end)
		end
	end
end)

-- Auto Totem Mix 3
local totemThread = nil
local function startAutoTotem()
	if totemThread then return end
	totemThread = task.spawn(function()
		while guiFunctions.autoTotemMix do
			pcall(function()
				local char = LocalPlayer.Character
				local backpack = LocalPlayer:FindFirstChild("Backpack")
				if char and backpack then
					local totemsToEquip = {}
					for _, item in pairs(backpack:GetChildren()) do
						if item:IsA("Tool") and item.Name:lower():match("totem") then
							table.insert(totemsToEquip, item)
							if #totemsToEquip >= 3 then break end
						end
					end
					
					for _, totem in ipairs(totemsToEquip) do
						char.Humanoid:EquipTool(totem)
						task.wait(0.5)
						safeClick(0, 0)
						task.wait(1.5)
					end
				end
			end)
			task.wait(10)
		end
		totemThread = nil
	end)
end

-- Auto Mancing & Instant Fish
local autoFishConnection = nil
local function startAutoFish()
	if autoFishConnection then return end
	autoFishConnection = task.spawn(function()
		while guiFunctions.autoFish do
			pcall(function()
				local char = LocalPlayer.Character
				local tool = char and char:FindFirstChildOfClass("Tool")
				
				-- Lempar Pancing
				if tool and tool.Name:lower():match("rod") then
					if guiFunctions.randomCast then
						local randX = math.random(100, 400)
						local randY = math.random(100, 400)
						safeClick(randX, randY)
					else
						safeClick(0, 0)
					end
				end
				
				-- LOGIKA INSTANT FISH
				if guiFunctions.instantFish then
					task.wait(guiFunctions.instantFishDelay or 3)
					
					local repStorage = game:GetService("ReplicatedStorage")
					local events = repStorage:FindFirstChild("Remotes") or repStorage:FindFirstChild("Events") or repStorage
					local resultArg = guiFunctions.stableResult and "Perfect" or true
					
					for _, event in pairs(events:GetDescendants()) do
						if event:IsA("RemoteEvent") then
							local name = event.Name:lower()
							if name:match("catch") or name:match("fish") or name:match("reel") then
								event:FireServer(resultArg, 100)
							end
						elseif event:IsA("RemoteFunction") then
							local name = event.Name:lower()
							if name:match("catch") or name:match("fish") or name:match("reel") then
								task.spawn(function() event:InvokeServer(resultArg, 100) end)
							end
						end
					end
				else
					task.wait(guiFunctions.caughtDelay or 0.5)
					local pg = LocalPlayer:FindFirstChild("PlayerGui")
					if pg then
						for _, ui in pairs(pg:GetDescendants()) do
							if (ui:IsA("TextButton") or ui:IsA("ImageButton")) and (ui.Name:lower():match("reel") or ui.Name:lower():match("catch") or ui.Name:lower():match("click")) then
								if ui.Visible and ui.Parent.Visible then
									safeClick(ui.AbsolutePosition.X + (ui.AbsoluteSize.X / 2), ui.AbsolutePosition.Y + (ui.AbsoluteSize.Y / 2))
								end
							end
						end
					end
				end
			end)
			
			task.wait(0.5)
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
							if getconnections then
								for _, conn in ipairs(getconnections(descendant.MouseButton1Click)) do conn:Fire() end
							else
								safeClick(descendant.AbsolutePosition.X + 5, descendant.AbsolutePosition.Y + 5)
							end
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
local function startAutoBuyWeather(wName)
	if weatherConnections[wName] then task.cancel(weatherConnections[wName]) end
	weatherConnections[wName] = task.spawn(function()
		while autoWeatherEnabled[wName] do buyWeather(wName); task.wait(5) end
	end)
end
local function stopAutoBuyWeather(wName)
	if weatherConnections[wName] then task.cancel(weatherConnections[wName]); weatherConnections[wName] = nil end
end

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

----------------------------------------
-- UI SYSTEM PREMIUM 
----------------------------------------

local screenGui = Instance.new("ScreenGui")
screenGui.Name = GUI_NAME 
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999999999
screenGui.IgnoreGuiInset = true
screenGui.Parent = guiParent

-- TOMBOL MINIMIZE ICON
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 50, 0, 50)
openBtn.Position = UDim2.new(0, 20, 0.5, -25)
openBtn.BackgroundColor3 = Theme.Container
openBtn.Text = "ACL"
openBtn.TextColor3 = Theme.Accent
openBtn.TextSize = 16
openBtn.Font = Enum.Font.GothamBold
openBtn.Visible = false
openBtn.Parent = screenGui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(1, 0)
openCorner.Parent = openBtn
local openStroke = Instance.new("UIStroke")
openStroke.Color = Theme.Accent
openStroke.Thickness = 2
openStroke.Parent = openBtn

-- JENDELA UTAMA
local window = Instance.new("Frame")
window.Size = UDim2.new(0, 550, 0, 350)
window.Position = UDim2.new(0.5, -275, 0.5, -175)
window.BackgroundColor3 = Theme.Background
window.BorderSizePixel = 0
window.Active = true
window.Draggable = true
window.Parent = screenGui

local windowCorner = Instance.new("UICorner")
windowCorner.CornerRadius = UDim.new(0, 10)
windowCorner.Parent = window
local windowStroke = Instance.new("UIStroke")
windowStroke.Color = Theme.Outline
windowStroke.Thickness = 1.5
windowStroke.Parent = window

-- HEADER & PING COUNTER
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 45)
header.BackgroundColor3 = Theme.Header
header.BorderSizePixel = 0
header.Parent = window

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 10)
headerCorner.Parent = header
local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 10)
headerFix.Position = UDim2.new(0, 0, 1, -10)
headerFix.BackgroundColor3 = Theme.Header
headerFix.BorderSizePixel = 0
headerFix.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 200, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "ACL HUB [PREMIUM FULL]"
title.TextColor3 = Theme.Accent
title.TextSize = 15
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local pingLabel = Instance.new("TextLabel")
pingLabel.Size = UDim2.new(0, 100, 1, 0)
pingLabel.Position = UDim2.new(0, 220, 0, 0)
pingLabel.BackgroundTransparency = 1
pingLabel.Text = "Ping: 0 ms"
pingLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
pingLabel.TextSize = 12
pingLabel.Font = Enum.Font.GothamMedium
pingLabel.Parent = header

task.spawn(function()
	while ScriptEnabled do
		pcall(function()
			local ping = math.round(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
			pingLabel.Text = "Ping: " .. tostring(ping) .. " ms"
			if ping > 150 then pingLabel.TextColor3 = Color3.fromRGB(255, 150, 50)
			elseif ping > 300 then pingLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
			else pingLabel.TextColor3 = Color3.fromRGB(100, 255, 100) end
		end)
		task.wait(1)
	end
end)

-- Tombol Min/Close
local btnContainer = Instance.new("Frame")
btnContainer.Size = UDim2.new(0, 90, 1, 0)
btnContainer.Position = UDim2.new(1, -90, 0, 0)
btnContainer.BackgroundTransparency = 1
btnContainer.Parent = header

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 45, 1, 0)
minBtn.BackgroundTransparency = 1
minBtn.Text = "-"
minBtn.TextColor3 = Theme.Text
minBtn.TextSize = 22
minBtn.Font = Enum.Font.GothamBold
minBtn.Parent = btnContainer

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 45, 1, 0)
closeBtn.Position = UDim2.new(0, 45, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = btnContainer

minBtn.MouseButton1Click:Connect(function() window.Visible = false; openBtn.Visible = true end)
closeBtn.MouseButton1Click:Connect(function() ScriptEnabled = false; screenGui:Destroy() end)
openBtn.MouseButton1Click:Connect(function() openBtn.Visible = false; window.Visible = true end)

local isDraggingIcon, dragStartIcon, startPosIcon
openBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		isDraggingIcon = true; dragStartIcon = input.Position; startPosIcon = openBtn.Position
	end
end)
openBtn.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDraggingIcon = false end
end)
UserInputService.InputChanged:Connect(function(input)
	if isDraggingIcon and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStartIcon
		openBtn.Position = UDim2.new(startPosIcon.X.Scale, startPosIcon.X.Offset + delta.X, startPosIcon.Y.Scale, startPosIcon.Y.Offset + delta.Y)
	end
end)

-- PANEL KIRI (TAB) & KANAN (KONTEN)
local leftPanel = Instance.new("ScrollingFrame")
leftPanel.Size = UDim2.new(0, 150, 1, -55)
leftPanel.Position = UDim2.new(0, 10, 0, 45)
leftPanel.BackgroundTransparency = 1
leftPanel.BorderSizePixel = 0
leftPanel.ScrollBarThickness = 0
leftPanel.Parent = window
local leftLayout = Instance.new("UIListLayout")
leftLayout.Padding = UDim.new(0, 5)
leftLayout.Parent = leftPanel

local rightPanel = Instance.new("ScrollingFrame")
rightPanel.Size = UDim2.new(1, -175, 1, -55)
rightPanel.Position = UDim2.new(0, 165, 0, 45)
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
	Instance.new("UICorner", btn).CornerRadius = Theme.CornerRadius

	leftPanel.CanvasSize = UDim2.new(0, 0, 0, leftLayout.AbsoluteContentSize.Y)

	btn.MouseButton1Click:Connect(function()
		if currentCategoryBtn then
			TweenService:Create(currentCategoryBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Background, TextColor3 = Theme.TextMuted}):Play()
		end
		currentCategoryBtn = btn
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Container, TextColor3 = Theme.Text}):Play()

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
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, -10, 0, 45)
	container.BackgroundColor3 = Theme.Container
	container.BorderSizePixel = 0
	container.Parent = parent
	Instance.new("UICorner", container).CornerRadius = Theme.CornerRadius
	
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -70, 1, 0)
	nameLabel.Position = UDim2.new(0, 15, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = name
	nameLabel.TextColor3 = Theme.Text
	nameLabel.TextSize = 13
	nameLabel.Font = Enum.Font.GothamMedium
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = container

	local switchBg = Instance.new("TextButton")
	switchBg.Size = UDim2.new(0, 40, 0, 20)
	switchBg.Position = UDim2.new(1, -55, 0.5, -10)
	switchBg.BackgroundColor3 = Theme.ToggleOff
	switchBg.Text = ""
	switchBg.Parent = container
	Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1, 0)

	local switchCircle = Instance.new("Frame")
	switchCircle.Size = UDim2.new(0, 16, 0, 16)
	switchCircle.Position = UDim2.new(0, 2, 0.5, -8)
	switchCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	switchCircle.Parent = switchBg
	Instance.new("UICorner", switchCircle).CornerRadius = UDim.new(1, 0)

	local toggleKey = name:gsub("[^%w]", "")
	local isEnabled = toggleStates[toggleKey] or false
	
	if isEnabled then
		switchBg.BackgroundColor3 = Theme.Accent
		switchCircle.Position = UDim2.new(1, -18, 0.5, -8)
	end

	switchBg.MouseButton1Click:Connect(function()
		isEnabled = not isEnabled
		toggleStates[toggleKey] = isEnabled
		
		TweenService:Create(switchBg, TweenInfo.new(0.25), {BackgroundColor3 = isEnabled and Theme.Accent or Theme.ToggleOff}):Play()
		TweenService:Create(switchCircle, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Position = isEnabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
		}):Play()

		if callback then pcall(callback, isEnabled) end
	end)
end

local function createSlider(parent, name, minVal, maxVal, defaultVal, callback)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, -10, 0, 60)
	container.BackgroundColor3 = Theme.Container
	container.BorderSizePixel = 0
	container.Parent = parent
	Instance.new("UICorner", container).CornerRadius = Theme.CornerRadius

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
	nameLabel.Parent = container

	local sliderBg = Instance.new("TextButton")
	sliderBg.Size = UDim2.new(1, -30, 0, 6)
	sliderBg.Position = UDim2.new(0, 15, 0, 40)
	sliderBg.BackgroundColor3 = Theme.Button
	sliderBg.Text = ""
	sliderBg.Parent = container
	Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((currentValue - minVal) / (maxVal - minVal), 0, 1, 0)
	fill.BackgroundColor3 = Theme.Accent
	fill.BorderSizePixel = 0
	fill.Parent = sliderBg
	Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

	local circle = Instance.new("Frame")
	circle.Size = UDim2.new(0, 14, 0, 14)
	circle.Position = UDim2.new(1, -7, 0.5, -7)
	circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	circle.Parent = fill
	Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

	local isDragging = false
	sliderBg.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDragging = true end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDragging = false end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local mousePos = input.Position.X
			local sliderPos = sliderBg.AbsolutePosition.X
			local sliderSize = sliderBg.AbsoluteSize.X
			local relativeX = math.clamp(mousePos - sliderPos, 0, sliderSize)
			local percentage = relativeX / sliderSize
			local value = math.floor(minVal + percentage * (maxVal - minVal))

			TweenService:Create(fill, TweenInfo.new(0.1), {Size = UDim2.new(percentage, 0, 1, 0)}):Play()
			nameLabel.Text = name .. " : " .. tostring(value)
			sliderValues[sliderKey] = value
			if callback then pcall(callback, value) end
		end
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
	Instance.new("UICorner", btn).CornerRadius = Theme.CornerRadius

	btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ButtonHover}):Play() end)
	btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Button}):Play() end)

	btn.MouseButton1Click:Connect(function()
		local t = TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Accent})
		t:Play(); t.Completed:Wait()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ButtonHover}):Play()
		if callback then pcall(callback) end
	end)
end

----------------------------------------
-- KATEGORI MENU (TABS FULL COMPLETE)
----------------------------------------

local farmBtn = createCategoryButton("Farm & Catch", function(panel)
	createSectionTitle(panel, "Fishing Automation")
	createToggle(panel, "Auto Mancing", function(state) guiFunctions.autoFish = state if state then startAutoFish() else stopAutoFish() end end)
	
	createSectionTitle(panel, "Modifikasi Tangkapan")
	createToggle(panel, "Instant Fishing", function(state) guiFunctions.instantFish = state end)
	createSlider(panel, "Delay Instant Fish (Detik)", 1, 10, 3, function(val) guiFunctions.instantFishDelay = val end)
	createToggle(panel, "Stable Result (Selalu Perfect)", function(state) guiFunctions.stableResult = state end)
	createToggle(panel, "Random Cast (Anti-Detect)", function(state) guiFunctions.randomCast = state end)
	
	createSectionTitle(panel, "Auto Sell")
	createToggle(panel, "Auto Jual", function(state) _G.AutoSell = state if state then sellFish() end end)
	createSlider(panel, "Jeda Jual (Detik)", 1, 120, 30, function(val) _G.SellDelay = val end)
end)

createCategoryButton("Support Features", function(panel)
	createSectionTitle(panel, "Player Utilities")
	createToggle(panel, "Auto Equip Rod", function(state) guiFunctions.autoEquipRod = state end)
	createToggle(panel, "Sembunyikan Notif Reward", function(state) guiFunctions.disableNotif = state end)
	createToggle(panel, "Auto Pasang 3 Totem", function(state) guiFunctions.autoTotemMix = state if state then startAutoTotem() end end)
	createToggle(panel, "Auto Accept Trade", function(state) guiFunctions.autoTrade = state end)
end)

createCategoryButton("Teleport Map", function(panel)
	-- SEMUA 22 LOKASI DIMASUKKAN KEMBALI
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
	createSectionTitle(panel, "Fast Teleport Island")
	for _, loc in ipairs(locations) do
		createButton(panel, "📍 " .. loc.name, function()
			local char = LocalPlayer.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				char.HumanoidRootPart.CFrame = CFrame.new(loc.pos)
			end
		end)
	end
	
	createSectionTitle(panel, "Teleport Ke Pemain")
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			createButton(panel, "👤 " .. player.Name, function()
				local myChar = LocalPlayer.Character
				local targetChar = player.Character
				if myChar and targetChar and myChar:FindFirstChild("HumanoidRootPart") and targetChar:FindFirstChild("HumanoidRootPart") then
					myChar.HumanoidRootPart.CFrame = targetChar.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
				end
			end)
		end
	end
end)

createCategoryButton("Shop & Weather", function(panel)
	createSectionTitle(panel, "Toko Cepat")
	createButton(panel, "Buka/Tutup Toko", function()
		local m = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("Merchant")
		if m and m:FindFirstChild("Main") then m.Main.Enabled = not m.Main.Enabled end
	end)
	
	-- SEMUA 6 CUACA DIMASUKKAN KEMBALI
	createSectionTitle(panel, "Auto Buy Weather")
	createToggle(panel, "Angin (Wind)", function(state) autoWeatherEnabled["Wind"] = state if state then startAutoBuyWeather("Wind") else stopAutoBuyWeather("Wind") end end)
	createToggle(panel, "Mendung (Cloudy)", function(state) autoWeatherEnabled["Cloudy"] = state if state then startAutoBuyWeather("Cloudy") else stopAutoBuyWeather("Cloudy") end end)
	createToggle(panel, "Salju (Snow)", function(state) autoWeatherEnabled["Snow"] = state if state then startAutoBuyWeather("Snow") else stopAutoBuyWeather("Snow") end end)
	createToggle(panel, "Badai (Storm)", function(state) autoWeatherEnabled["Storm"] = state if state then startAutoBuyWeather("Storm") else stopAutoBuyWeather("Storm") end end)
	createToggle(panel, "Cerah (Shining)", function(state) autoWeatherEnabled["Shining"] = state if state then startAutoBuyWeather("Shining") else stopAutoBuyWeather("Shining") end end)
	createToggle(panel, "Shark Hunt", function(state) autoWeatherEnabled["SharkHunt"] = state if state then startAutoBuyWeather("SharkHunt") else stopAutoBuyWeather("SharkHunt") end end)
end)

createCategoryButton("Auto Favorite", function(panel)
	-- FITUR AUTO FAVORITE DIKEMBALIKAN FULL
	createSectionTitle(panel, "Pilih Kelangkaan")
	createToggle(panel, "Common", function(state) favoriteRarities["Common"] = state end)
	createToggle(panel, "Uncommon", function(state) favoriteRarities["Uncommon"] = state end)
	createToggle(panel, "Rare", function(state) favoriteRarities["Rare"] = state end)
	createToggle(panel, "Epic", function(state) favoriteRarities["Epic"] = state end)
	createToggle(panel, "Legendary", function(state) favoriteRarities["Legendary"] = state end)
	createToggle(panel, "Mythic", function(state) favoriteRarities["Mythic"] = state end)
	createToggle(panel, "SECRET", function(state) favoriteRarities["SECRET"] = state end)
end)

createCategoryButton("Settings & Misc", function(panel)
	createSectionTitle(panel, "Sistem Perlindungan")
	createToggle(panel, "Anti AFK", function(state) antiAFKEnabled = state if state then enableAntiAFK() else disableAntiAFK() end end)
	createToggle(panel, "Auto Rejoin", function(state) autorejoinEnabled = state if state then enableAutorejoin() else disableAutorejoin() end end)
	
	createSectionTitle(panel, "Optimalisasi Game")
	createToggle(panel, "Mode Malam (Night)", function(state) game.Lighting.ClockTime = state and 0 or 14 end)
	createToggle(panel, "Hapus Bayangan (No Shadow)", function(state) game.Lighting.GlobalShadows = not state end)
	
	createSectionTitle(panel, "Webhook Notifikasi")
	local webhookInput = Instance.new("TextBox")
	webhookInput.Size = UDim2.new(1, -10, 0, 35)
	webhookInput.BackgroundColor3 = Theme.Container
	webhookInput.BorderSizePixel = 0
	webhookInput.PlaceholderText = "Paste Discord Webhook URL..."
	webhookInput.Text = webhookUrl
	webhookInput.TextColor3 = Theme.Text
	webhookInput.TextSize = 12
	webhookInput.Font = Enum.Font.Gotham
	webhookInput.Parent = panel
	Instance.new("UICorner", webhookInput).CornerRadius = Theme.CornerRadius
	
	webhookInput.FocusLost:Connect(function(enterPressed)
		if enterPressed then webhookUrl = webhookInput.Text end
	end)
end)

-- Buka tab pertama secara default
farmBtn.MouseButton1Click:Fire()
