local GameVersion = "3.0.0 Premium"
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

print("=== ACL HUB PREMIUM V3 Diinisialisasi ===")

-- Pengaturan Tema Premium Modern
local Theme = {
	Background = Color3.fromRGB(15, 15, 20),      -- Gelap elegan
	Header = Color3.fromRGB(22, 22, 28),          -- Agak terang untuk header
	Container = Color3.fromRGB(26, 26, 32),       -- Warna box menu
	Button = Color3.fromRGB(35, 35, 45),
	ButtonHover = Color3.fromRGB(45, 45, 60),
	Accent = Color3.fromRGB(0, 160, 255),         -- Biru Neon Modern
	ToggleOff = Color3.fromRGB(60, 60, 70),       -- Abu-abu untuk toggle mati
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
if guiParent:FindFirstChild("ACL_HUB_PREMIUM") then
	guiParent.ACL_HUB_PREMIUM:Destroy()
end

-- Variables Global
local guiFunctions = {
	instantFish = false,
	stableResult = false,
	autoFish = false,
	autoEquipRod = false,
	disableNotif = false,
	autoTotemMix = false,
	autoTrade = false,
	caughtDelay = 1,
	recastDelay = 1,
}
local toggleStates = {}
local sliderValues = {}
local autoWeatherEnabled = { ["Wind"]=false, ["Cloudy"]=false, ["Snow"]=false, ["Storm"]=false, ["Shining"]=false, ["SharkHunt"]=false }
local weatherProductIds = { ["Wind"]=7058120, ["Cloudy"]=7058120, ["Snow"]=7058120, ["Storm"]=7058120, ["Shining"]=7058120, ["SharkHunt"]=7058120 }
local weatherConnections = {}
local antiAFKEnabled = false
local antiAFKConnection = nil
local autorejoinEnabled = false
local autorejoinBound = false

----------------------------------------
-- LOGIKA FITUR (DENGAN FITUR BARU)
----------------------------------------

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
								VirtualInputManager:SendMouseButtonEvent(gui.AbsolutePosition.X + 10, gui.AbsolutePosition.Y + 10, 0, true, game, 1)
								task.wait(0.1)
								VirtualInputManager:SendMouseButtonEvent(gui.AbsolutePosition.X + 10, gui.AbsolutePosition.Y + 10, 0, false, game, 1)
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
						VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
						task.wait(0.1)
						VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
						task.wait(1.5)
					end
				end
			end)
			task.wait(10) -- Jeda antar pemakaian totem
		end
		totemThread = nil
	end)
end

-- Auto Mancing & Instant Fish + Stable Result
local autoFishConnection = nil
local function startAutoFish()
	if autoFishConnection then return end
	autoFishConnection = task.spawn(function()
		while guiFunctions.autoFish do
			-- Simulasi Lempar Pancing
			pcall(function()
				local char = LocalPlayer.Character
				if char and char:FindFirstChildOfClass("Tool") then
					VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
					task.wait(0.1)
					VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
				end
			end)
			
			task.wait(guiFunctions.caughtDelay or 1)

			-- Instant Catch & Stable Result
			if guiFunctions.instantFish or guiFunctions.stableResult then
				pcall(function()
					local repStorage = game:GetService("ReplicatedStorage")
					local events = repStorage:FindFirstChild("Remotes") or repStorage:FindFirstChild("Events") or repStorage
					
					local resultArg = guiFunctions.stableResult and "Perfect" or true
					
					for _, event in pairs(events:GetDescendants()) do
						if event:IsA("RemoteEvent") then
							local name = event.Name:lower()
							if name:match("catch") or name:match("fish") or name:match("reel") then
								event:FireServer(resultArg, 100) -- Parameter Stable
							end
						elseif event:IsA("RemoteFunction") then
							local name = event.Name:lower()
							if name:match("catch") or name:match("fish") or name:match("reel") then
								task.spawn(function() event:InvokeServer(resultArg, 100) end)
							end
						end
					end
				end)
			end
		end
		autoFishConnection = nil
	end)
end

-- Anti AFK
local function enableAntiAFK()
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
-- UI SYSTEM (ANIMASI TOGGLE SWITCH)
----------------------------------------

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ACL_HUB_PREMIUM"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999999999
screenGui.IgnoreGuiInset = true
screenGui.Parent = guiParent

-- TOMBOL OPEN MINIMIZE
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
openCorner.CornerRadius = UDim.new(1, 0) -- Bulat sempurna
openCorner.Parent = openBtn
local openStroke = Instance.new("UIStroke")
openStroke.Color = Theme.Accent
openStroke.Thickness = 2
openStroke.Parent = openBtn

-- JENDELA UTAMA
local window = Instance.new("Frame")
window.Size = UDim2.new(0, 550, 0, 340)
window.Position = UDim2.new(0.5, -275, 0.5, -170)
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
title.Text = "ACL HUB PREMIUM"
title.TextColor3 = Theme.Accent
title.TextSize = 15
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- Indikator PING
local pingLabel = Instance.new("TextLabel")
pingLabel.Size = UDim2.new(0, 100, 1, 0)
pingLabel.Position = UDim2.new(0, 200, 0, 0)
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

-- Buka kembali drag icon
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

-- ANIMATED TOGGLE SWITCH
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

	-- Switch Frame
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
		
		-- Animasi Toggle
		TweenService:Create(switchBg, TweenInfo.new(0.25), {BackgroundColor3 = isEnabled and Theme.Accent or Theme.ToggleOff}):Play()
		TweenService:Create(switchCircle, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Position = isEnabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
		}):Play()

		if callback then pcall(callback, isEnabled) end
	end)
end

-- ANIMATED SLIDER
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
	btn.Size = UDim2.new(1, -10, 0, 40)
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
-- KATEGORI MENU (TABS)
----------------------------------------

local farmBtn = createCategoryButton("Farm & Catch", function(panel)
	createSectionTitle(panel, "Fishing Automation")
	createToggle(panel, "Auto Mancing", function(state) guiFunctions.autoFish = state if state then startAutoFish() else stopAutoFish() end end)
	createToggle(panel, "Instant Fishing", function(state) guiFunctions.instantFish = state end)
	createToggle(panel, "Stable Result (Anti Fail)", function(state) guiFunctions.stableResult = state end)
	createSlider(panel, "Jeda Tangkapan", 0.1, 5, 1, function(val) guiFunctions.caughtDelay = val end)
end)

createCategoryButton("Support Features", function(panel)
	createSectionTitle(panel, "Player Utilities")
	createToggle(panel, "Auto Equip Rod", function(state) guiFunctions.autoEquipRod = state end)
	createToggle(panel, "Disable Obtain Notif", function(state) guiFunctions.disableNotif = state end)
	createToggle(panel, "Auto Pasang 3 Totem", function(state) guiFunctions.autoTotemMix = state if state then startAutoTotem() end end)
	createToggle(panel, "Auto Accept Trade", function(state) guiFunctions.autoTrade = state end)
end)

createCategoryButton("Teleport Map", function(panel)
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
	createSectionTitle(panel, "Fast Teleport")
	for _, loc in ipairs(locations) do
		createButton(panel, loc.name, function()
			local char = LocalPlayer.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				char.HumanoidRootPart.CFrame = CFrame.new(loc.pos)
			end
		end)
	end
end)

createCategoryButton("Shop & Weather", function(panel)
	createSectionTitle(panel, "Toko Cepat")
	createButton(panel, "Buka/Tutup Toko", function()
		local m = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("Merchant")
		if m and m:FindFirstChild("Main") then m.Main.Enabled = not m.Main.Enabled end
	end)
	createSectionTitle(panel, "Auto Buy Weather")
	createToggle(panel, "Angin (Wind)", function(state) autoWeatherEnabled["Wind"] = state if state then startAutoBuyWeather("Wind") else stopAutoBuyWeather("Wind") end end)
	createToggle(panel, "Mendung (Cloudy)", function(state) autoWeatherEnabled["Cloudy"] = state if state then startAutoBuyWeather("Cloudy") else stopAutoBuyWeather("Cloudy") end end)
	createToggle(panel, "Badai (Storm)", function(state) autoWeatherEnabled["Storm"] = state if state then startAutoBuyWeather("Storm") else stopAutoBuyWeather("Storm") end end)
	createToggle(panel, "Shark Hunt", function(state) autoWeatherEnabled["SharkHunt"] = state if state then startAutoBuyWeather("SharkHunt") else stopAutoBuyWeather("SharkHunt") end end)
end)

createCategoryButton("Settings & Misc", function(panel)
	createSectionTitle(panel, "Sistem Perlindungan")
	createToggle(panel, "Anti AFK", function(state) antiAFKEnabled = state if state then enableAntiAFK() else disableAntiAFK() end end)
	createToggle(panel, "Auto Rejoin", function(state) autorejoinEnabled = state if state then enableAutorejoin() else disableAutorejoin() end end)
	
	createSectionTitle(panel, "Optimalisasi Game")
	createToggle(panel, "Mode Malam (Night)", function(state) game.Lighting.ClockTime = state and 0 or 14 end)
	createToggle(panel, "Hapus Bayangan (No Shadow)", function(state) game.Lighting.GlobalShadows = not state end)
end)

-- Buka tab pertama secara default
farmBtn.MouseButton1Click:Fire()
