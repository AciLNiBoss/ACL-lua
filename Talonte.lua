local ScriptEnabled = true

-- Services
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- RANDOMISASI
local GUI_NAME = HttpService:GenerateGUID(false):gsub("-", "") .. "_" .. math.random(1000,9999)

-- Theme
local Theme = {
	Bg = Color3.fromRGB(18, 18, 22),
	Card = Color3.fromRGB(25, 25, 30),
	Accent = Color3.fromRGB(0, 140, 255),
	Text = Color3.fromRGB(240, 240, 240),
	Sub = Color3.fromRGB(160, 160, 160)
}

-- Anti-Debug Parent
local function secureParent()
	local p = (gethui and pcall(gethui) and gethui()) or 
			 (syn and syn.protected_gui and syn.protected_gui()) or
			 game:GetService("CoreGui") or 
			 LocalPlayer:FindFirstChild("PlayerGui")
	return p
end

-- ========== DATABASE LENGKAP FISH IT ==========
-- 16 AREA MAP [citation:1][citation:4]

local MAPS = {
	{name = "🏝️ Fisherman Island", id = "fisherman"},
	{name = "🌊 Ocean", id = "ocean"},
	{name = "🏖️ Kohana Island", id = "kohana"},
	{name = "🌋 Kohana Volcano", id = "volcano"},
	{name = "🪸 Coral Reefs", id = "coral"},
	{name = "🌌 Esoteric Depths", id = "esoteric"},
	{name = "🌴 Tropical Grove", id = "grove"},
	{name = "🌋 Crater Island", id = "crater"},
	{name = "🏛️ Lost Isle", id = "lost"},
	{name = "🌿 Ancient Jungle", id = "jungle"},
	{name = "🎄 Christmas Island", id = "xmas"},
	{name = "💘 Heart Island", id = "heart"},
	{name = "🏝️ Classic Island", id = "classic"},
	{name = "🌪️ Weather Machine", id = "weather"},
	{name = "🗿 Sissypus Statue", id = "sissypus"},
	{name = "💎 Treasure Room", id = "treasure"}
}

-- DAFTAR IKAN PER AREA [citation:4][citation:8][citation:10]
local FISH_BY_AREA = {
	fisherman = {
		{name = "Orca", rarity = "SECRET", chance = "1:1.5jt"},
		{name = "Crystal Crab", rarity = "SECRET", chance = "1:750rb"},
		{name = "Dotted Stingray", rarity = "Mythic", chance = "1:91rb"},
		{name = "Yellowfin Tuna", rarity = "Legendary", chance = "1:7.5rb"},
		{name = "Dorhey Tang", rarity = "Epic"},
		{name = "Darwin Clownfish", rarity = "Rare"}
	},
	ocean = {
		{name = "Hammerhead Shark", rarity = "Mythic", chance = "1:100rb"},
		{name = "Manta Ray", rarity = "Mythic", chance = "1:50rb"},
		{name = "Ruby Tuna", rarity = "Legendary"},
		{name = "Chrome Tuna", rarity = "Legendary"},
		{name = "Narwhal", rarity = "Epic"}
	},
	kohana = {
		{name = "Prismy Seahorse", rarity = "Mythic", chance = "1:88rb"},
		{name = "Loggerhead Turtle", rarity = "Mythic", chance = "1:55rb"},
		{name = "Lobster", rarity = "Legendary"},
		{name = "Bumblebee Grouper", rarity = "Legendary"},
		{name = "Sushi Cardinal", rarity = "Epic"}
	},
	volcano = {
		{name = "Blueflame Ray", rarity = "Mythic", chance = "1:93rb"},
		{name = "Lavafin Tuna", rarity = "Legendary", chance = "1:10rb"},
		{name = "Magma Goby", rarity = "Legendary"},
		{name = "Firecoal Damsel", rarity = "Epic"},
		{name = "Arowana", rarity = "Uncommon"}
	},
	coral = {
		{name = "Monster Shark", rarity = "SECRET"},
		{name = "Eerie Shark", rarity = "SECRET"},
		{name = "Pink Dolphin", rarity = "Legendary"},
		{name = "Starjam Tang", rarity = "Legendary"},
		{name = "Starfish", rarity = "Rare"},
		{name = "Lion Fish", rarity = "Uncommon"}
	},
	esoteric = {
		{name = "Abyss Seahorse", rarity = "Mythic", chance = "1:95rb"},
		{name = "Magic Tang", rarity = "Legendary"},
		{name = "Enchanted Angelfish", rarity = "Legendary"},
		{name = "Dark Tentacle", rarity = "Rare"}
	},
	grove = {
		{name = "Great Whale", rarity = "SECRET", chance = "1:900rb"},
		{name = "Thresher Shark", rarity = "Mythic"},
		{name = "Pufferfish", rarity = "Epic"},
		{name = "King Mackerel", rarity = "Rare"}
	},
	crater = {
		{name = "Axolotl", rarity = "Legendary", chance = "1:6.5rb"},
		{name = "Parrot Fish", rarity = "Rare"},
		{name = "Catfish", rarity = "Common"},
		{name = "Silver Tuna", rarity = "Common"}
	},
	lost = {
		{name = "Robot Kraken", rarity = "SECRET", chance = "1:3.5jt"},
		{name = "King Crab", rarity = "SECRET"},
		{name = "Queen Crab", rarity = "SECRET"},
		{name = "Kraken", rarity = "Mythic"},
		{name = "Blob Fish", rarity = "Mythic"}
	},
	jungle = {
		{name = "Ancient Relic Crocodile", rarity = "Mythic", chance = "1:245rb"},
		{name = "Crocodile", rarity = "Mythic"},
		{name = "Spear Guardian", rarity = "Mythic"},
		{name = "Goliath Tiger", rarity = "Mythic"},
		{name = "Temple Spokes Tuna", rarity = "Legendary"},
		{name = "Manoai Statue Fish", rarity = "Legendary"}
	},
	xmas = {
		{name = "Santa Fish", rarity = "SECRET"},
		{name = "Ice Crab", rarity = "Mythic"},
		{name = "Snowflake Angelfish", rarity = "Legendary"},
		{name = "Gingerbread Fish", rarity = "Epic"}
	},
	heart = {
		{name = "Cupid Ray", rarity = "SECRET"},
		{name = "Heart Koi", rarity = "Mythic"},
		{name = "Love Shark", rarity = "Legendary"},
		{name = "Pink Kisser", rarity = "Epic"}
	},
	classic = {
		{name = "Golden Fish", rarity = "Mythic"},
		{name = "Classic Bass", rarity = "Legendary"},
		{name = "Retro Trout", rarity = "Epic"}
	},
	weather = {
		{name = "Storm Eel", rarity = "Mythic"},
		{name = "Cloud Ray", rarity = "Legendary"},
		{name = "Wind Koi", rarity = "Epic"}
	},
	sissypus = {
		{name = "Ancient Guardian", rarity = "SECRET", chance = "1:3.5jt"},
		{name = "Stone Serpent", rarity = "Mythic"}
	},
	treasure = {
		{name = "Golden Crab", rarity = "SECRET"},
		{name = "Treasure Chest", rarity = "Mythic"},
		{name = "Gold Barracuda", rarity = "Legendary"}
	}
}

-- DAFTAR MUTASI LENGKAP [citation:2][citation:5]
local MUTATIONS = {
	{name = "Galaxy", value = "+500%", rarity = "Ultra Rare", chance = "0.5%"},
	{name = "Corrupt", value = "+400%", rarity = "Ultra Rare", chance = "0.5%"},
	{name = "Midnight", value = "+280%", rarity = "Very Rare", chance = "0.7%"},
	{name = "Gemstone", value = "+280%", rarity = "Very Rare", chance = "0.6%"},
	{name = "Radioactive", value = "+200%", rarity = "Very Rare", chance = "0.9%"},
	{name = "Lightning", value = "+200%", rarity = "Very Rare", chance = "0.9%"},
	{name = "Holographic", value = "+200%", rarity = "Very Rare", chance = "0.9%"},
	{name = "Fairy Dust", value = "+180%", rarity = "Very Rare", chance = "0.6%"},
	{name = "Color Burn", value = "+180%", rarity = "Very Rare", chance = "0.71%"},
	{name = "Festive", value = "+160%", rarity = "Rare", chance = "2.2%"},
	{name = "Gold", value = "+150%", rarity = "Rare", chance = "1.6%"},
	{name = "Ghost", value = "+120%", rarity = "Rare", chance = "1.4%"},
	{name = "Frozen", value = "+100%", rarity = "Rare", chance = "2.0%"},
	{name = "Albino", value = "+50%", rarity = "Common", chance = "2.5%"},
	{name = "Stone", value = "+20%", rarity = "Common", chance = "4.0%"},
	{name = "Disco", value = "+150%", rarity = "Event"},
	{name = "1x1x1x", value = "+300%", rarity = "Event", chance = "Limited"}
}

-- ========== UI SYSTEM ==========
local sg = Instance.new("ScreenGui")
sg.Name = GUI_NAME
sg.ResetOnSpawn = false
sg.Parent = secureParent()

-- Main Window (320x480)
local w = Instance.new("Frame")
w.Size = UDim2.new(0, 320, 0, 480)
w.Position = UDim2.new(0.5, -160, 0.5, -240)
w.BackgroundColor3 = Theme.Bg
w.BackgroundTransparency = 0.1
w.Active = true
w.Draggable = true
w.Parent = sg
Instance.new("UICorner", w).CornerRadius = UDim.new(0, 8)

-- Header
local h = Instance.new("Frame")
h.Size = UDim2.new(1, 0, 0, 35)
h.BackgroundColor3 = Theme.Card
h.Parent = w
Instance.new("UICorner", h).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -30, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🐟 FISH IT HUB (16 MAPS)"
title.TextColor3 = Theme.Accent
title.TextSize = 13
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = h

-- Close
local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 25, 0, 25)
close.Position = UDim2.new(1, -30, 0, 5)
close.BackgroundTransparency = 1
close.Text = "✕"
close.TextColor3 = Color3.fromRGB(200, 80, 80)
close.TextSize = 16
close.Font = Enum.Font.GothamBold
close.Parent = h
close.MouseButton1Click:Connect(function() sg:Destroy() ScriptEnabled = false end)

-- Tab Selector
local tabs = Instance.new("Frame")
tabs.Size = UDim2.new(1, -10, 0, 35)
tabs.Position = UDim2.new(0, 5, 0, 40)
tabs.BackgroundTransparency = 1
tabs.Parent = w

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 5)
tabLayout.Parent = tabs

-- Content Area (SCROLLABLE)
local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -10, 1, -85)
content.Position = UDim2.new(0, 5, 0, 80)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 3
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.Parent = w

local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 5)
contentLayout.Parent = content

-- Helper Functions
local function clearContent()
	for _, v in pairs(content:GetChildren()) do
		if not v:IsA("UIListLayout") then
			v:Destroy()
		end
	end
end

local function createTab(name, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 70, 1, 0)
	btn.BackgroundColor3 = Theme.Card
	btn.Text = name
	btn.TextColor3 = Theme.Sub
	btn.TextSize = 12
	btn.Font = Enum.Font.GothamMedium
	btn.Parent = tabs
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
	
	btn.MouseButton1Click:Connect(function()
		for _, b in pairs(tabs:GetChildren()) do
			if b:IsA("TextButton") then
				b.BackgroundColor3 = Theme.Card
				b.TextColor3 = Theme.Sub
			end
		end
		btn.BackgroundColor3 = Theme.Accent
		btn.TextColor3 = Color3.new(1,1,1)
		clearContent()
		callback()
	end)
	return btn
end

local function createSection(title)
	local section = Instance.new("TextLabel")
	section.Size = UDim2.new(1, 0, 0, 25)
	section.BackgroundTransparency = 1
	section.Text = "⚡ " .. title
	section.TextColor3 = Theme.Accent
	section.TextSize = 12
	section.Font = Enum.Font.GothamBold
	section.TextXAlignment = Enum.TextXAlignment.Left
	section.Parent = content
end

local function createToggle(text, default, callback)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 30)
	card.BackgroundColor3 = Theme.Card
	card.Parent = content
	Instance.new("UICorner", card).CornerRadius = UDim.new(0, 4)
	
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -50, 1, 0)
	lbl.Position = UDim2.new(0, 10, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.TextColor3 = Theme.Text
	lbl.TextSize = 12
	lbl.Font = Enum.Font.GothamMedium
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = card
	
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 40, 0, 20)
	btn.Position = UDim2.new(1, -45, 0.5, -10)
	btn.BackgroundColor3 = default and Theme.Accent or Color3.fromRGB(60, 60, 70)
	btn.Text = ""
	btn.Parent = card
	Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
	
	local state = default
	btn.MouseButton1Click:Connect(function()
		state = not state
		btn.BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(60, 60, 70)
		if callback then pcall(callback, state) end
	end)
end

local function getRarityColor(rarity)
	local colors = {
		Common = Color3.fromRGB(200, 200, 200),
		Uncommon = Color3.fromRGB(120, 255, 120),
		Rare = Color3.fromRGB(80, 160, 255),
		Epic = Color3.fromRGB(200, 100, 255),
		Legendary = Color3.fromRGB(255, 200, 80),
		Mythic = Color3.fromRGB(255, 80, 255),
		SECRET = Color3.fromRGB(255, 70, 70),
		["Ultra Rare"] = Color3.fromRGB(255, 50, 150),
		Event = Color3.fromRGB(255, 180, 50)
	}
	return colors[rarity] or Color3.fromRGB(255,255,255)
end

-- SELECTOR IKAN PER AREA
local function createFishSelector()
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 200)
	card.BackgroundColor3 = Theme.Card
	card.Parent = content
	Instance.new("UICorner", card).CornerRadius = UDim.new(0, 4)
	
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -10, 0, 25)
	title.Position = UDim2.new(0, 10, 0, 5)
	title.BackgroundTransparency = 1
	title.Text = "🎣 Pilih Area & Ikan Target"
	title.TextColor3 = Theme.Accent
	title.TextSize = 12
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = card
	
	-- Area Dropdown
	local areaDropdown = Instance.new("TextButton")
	areaDropdown.Size = UDim2.new(1, -20, 0, 30)
	areaDropdown.Position = UDim2.new(0, 10, 0, 30)
	areaDropdown.BackgroundColor3 = Theme.Bg
	areaDropdown.Text = "Pilih Area..."
	areaDropdown.TextColor3 = Theme.Sub
	areaDropdown.TextSize = 11
	areaDropdown.Font = Enum.Font.Gotham
	areaDropdown.Parent = card
	Instance.new("UICorner", areaDropdown).CornerRadius = UDim.new(0, 4)
	
	-- Area List
	local areaList = Instance.new("ScrollingFrame")
	areaList.Size = UDim2.new(1, -20, 0, 100)
	areaList.Position = UDim2.new(0, 10, 0, 65)
	areaList.BackgroundColor3 = Theme.Bg
	areaList.BorderSizePixel = 0
	areaList.Visible = false
	areaList.Parent = card
	Instance.new("UICorner", areaList).CornerRadius = UDim.new(0, 4)
	
	local areaLayout = Instance.new("UIListLayout")
	areaLayout.Padding = UDim.new(0, 1)
	areaLayout.Parent = areaList
	
	-- Fish Dropdown (berdasarkan area terpilih)
	local fishDropdown = Instance.new("TextButton")
	fishDropdown.Size = UDim2.new(1, -20, 0, 30)
	fishDropdown.Position = UDim2.new(0, 10, 0, 170)
	fishDropdown.BackgroundColor3 = Theme.Bg
	fishDropdown.Text = "Pilih Ikan..."
	fishDropdown.TextColor3 = Theme.Sub
	fishDropdown.TextSize = 11
	fishDropdown.Font = Enum.Font.Gotham
	fishDropdown.Parent = card
	Instance.new("UICorner", fishDropdown).CornerRadius = UDim.new(0, 4)
	
	-- Fish List
	local fishList = Instance.new("ScrollingFrame")
	fishList.Size = UDim2.new(1, -20, 0, 100)
	fishList.Position = UDim2.new(0, 10, 0, 205)
	fishList.BackgroundColor3 = Theme.Bg
	fishList.BorderSizePixel = 0
	fishList.Visible = false
	fishList.Parent = card
	Instance.new("UICorner", fishList).CornerRadius = UDim.new(0, 4)
	
	local fishLayout = Instance.new("UIListLayout")
	fishLayout.Padding = UDim.new(0, 1)
	fishLayout.Parent = fishList
	
	-- Selected indicator
	local selectedLbl = Instance.new("TextLabel")
	selectedLbl.Size = UDim2.new(1, -10, 0, 20)
	selectedLbl.Position = UDim2.new(0, 10, 0, 240)
	selectedLbl.BackgroundTransparency = 1
	selectedLbl.Text = "Target: -"
	selectedLbl.TextColor3 = Theme.Accent
	selectedLbl.TextSize = 10
	selectedLbl.Font = Enum.Font.GothamMedium
	selectedLbl.TextXAlignment = Enum.TextXAlignment.Left
	selectedLbl.Parent = card
	
	local selectedArea = nil
	local selectedFish = nil
	
	-- Populate areas
	for _, map in ipairs(MAPS) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 22)
		btn.BackgroundTransparency = 0.9
		btn.BackgroundColor3 = Theme.Accent
		btn.Text = map.name
		btn.TextColor3 = Theme.Text
		btn.TextSize = 11
		btn.Font = Enum.Font.Gotham
		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.Parent = areaList
		
		btn.MouseButton1Click:Connect(function()
			selectedArea = map.id
			areaDropdown.Text = map.name
			areaList.Visible = false
			fishDropdown.Text = "Pilih Ikan..."
			selectedFish = nil
			selectedLbl.Text = "Target: -"
			
			-- Update fish list
			for _, v in pairs(fishList:GetChildren()) do
				if v:IsA("TextButton") then v:Destroy() end
			end
			
			local fishData = FISH_BY_AREA[selectedArea] or {}
			for _, fish in ipairs(fishData) do
				local fbtn = Instance.new("TextButton")
				fbtn.Size = UDim2.new(1, 0, 0, 22)
				fbtn.BackgroundTransparency = 0.9
				fbtn.BackgroundColor3 = getRarityColor(fish.rarity)
				fbtn.Text = fish.name .. " [" .. fish.rarity .. "]"
				fbtn.TextColor3 = Color3.new(1,1,1)
				fbtn.TextSize = 10
				fbtn.Font = Enum.Font.GothamBold
				fbtn.TextXAlignment = Enum.TextXAlignment.Left
				fbtn.Parent = fishList
				
				fbtn.MouseButton1Click:Connect(function()
					selectedFish = fish
					fishDropdown.Text = fish.name
					selectedLbl.Text = "Target: " .. fish.name .. " (" .. fish.rarity .. ")"
					fishList.Visible = false
				end)
			end
			fishList.CanvasSize = UDim2.new(0, 0, 0, #fishData * 23)
		end)
	end
	areaList.CanvasSize = UDim2.new(0, 0, 0, #MAPS * 23)
	
	-- Toggle dropdowns
	areaDropdown.MouseButton1Click:Connect(function()
		areaList.Visible = not areaList.Visible
		fishList.Visible = false
	end)
	
	fishDropdown.MouseButton1Click:Connect(function()
		if selectedArea then
			fishList.Visible = not fishList.Visible
			areaList.Visible = false
		end
	end)
	
	-- Close dropdowns when clicking outside
	UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			task.wait()
			local mousePos = UserInputService:GetMouseLocation()
			
			local inArea = mousePos.X >= areaDropdown.AbsolutePosition.X and 
						 mousePos.X <= areaDropdown.AbsolutePosition.X + areaDropdown.AbsoluteSize.X and
						 mousePos.Y >= areaDropdown.AbsolutePosition.Y and 
						 mousePos.Y <= areaDropdown.AbsolutePosition.Y + areaDropdown.AbsoluteSize.Y
			
			local inFish = mousePos.X >= fishDropdown.AbsolutePosition.X and 
						 mousePos.X <= fishDropdown.AbsolutePosition.X + fishDropdown.AbsoluteSize.X and
						 mousePos.Y >= fishDropdown.AbsolutePosition.Y and 
						 mousePos.Y <= fishDropdown.AbsolutePosition.Y + fishDropdown.AbsoluteSize.Y
			
			if not inArea and not inFish then
				areaList.Visible = false
				fishList.Visible = false
			end
		end
	end)
	
	return card
end

-- SELECTOR MUTASI
local function createMutationSelector()
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 150)
	card.BackgroundColor3 = Theme.Card
	card.Parent = content
	Instance.new("UICorner", card).CornerRadius = UDim.new(0, 4)
	
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -10, 0, 25)
	title.Position = UDim2.new(0, 10, 0, 5)
	title.BackgroundTransparency = 1
	title.Text = "✨ Target Mutasi"
	title.TextColor3 = Theme.Accent
	title.TextSize = 12
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = card
	
	local dropdown = Instance.new("TextButton")
	dropdown.Size = UDim2.new(1, -20, 0, 30)
	dropdown.Position = UDim2.new(0, 10, 0, 30)
	dropdown.BackgroundColor3 = Theme.Bg
	dropdown.Text = "Pilih mutasi target..."
	dropdown.TextColor3 = Theme.Sub
	dropdown.TextSize = 11
	dropdown.Font = Enum.Font.Gotham
	dropdown.Parent = card
	Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 4)
	
	local list = Instance.new("ScrollingFrame")
	list.Size = UDim2.new(1, -20, 0, 80)
	list.Position = UDim2.new(0, 10, 0, 65)
	list.BackgroundColor3 = Theme.Bg
	list.BorderSizePixel = 0
	list.Visible = false
	list.Parent = card
	Instance.new("UICorner", list).CornerRadius = UDim.new(0, 4)
	
	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 1)
	listLayout.Parent = list
	
	local selectedLbl = Instance.new("TextLabel")
	selectedLbl.Size = UDim2.new(1, -10, 0, 20)
	selectedLbl.Position = UDim2.new(0, 10, 0, 150)
	selectedLbl.BackgroundTransparency = 1
	selectedLbl.Text = "Selected: -"
	selectedLbl.TextColor3 = Theme.Accent
	selectedLbl.TextSize = 10
	selectedLbl.Font = Enum.Font.GothamMedium
	selectedLbl.TextXAlignment = Enum.TextXAlignment.Left
	selectedLbl.Parent = card
	
	local selectedMut = nil
	
	for _, mut in ipairs(MUTATIONS) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 22)
		btn.BackgroundTransparency = 0.9
		btn.BackgroundColor3 = getRarityColor(mut.rarity)
		btn.Text = mut.name .. " [" .. mut.rarity .. "] " .. mut.value
		btn.TextColor3 = Color3.new(1,1,1)
		btn.TextSize = 10
		btn.Font = Enum.Font.GothamBold
		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.Parent = list
		
		btn.MouseButton1Click:Connect(function()
			selectedMut = mut
			dropdown.Text = mut.name
			selectedLbl.Text = "Selected: " .. mut.name .. " (" .. mut.rarity .. ")"
			list.Visible = false
		end)
	end
	list.CanvasSize = UDim2.new(0, 0, 0, #MUTATIONS * 23)
	
	dropdown.MouseButton1Click:Connect(function()
		list.Visible = not list.Visible
	end)
	
	return card
end

-- TELEPORT LOCATIONS (16 MAPS)
local teleportSpots = {
	{name = "🏝️ Fisherman Island", pos = Vector3.new(34, 9, 2803)},
	{name = "🌊 Ocean", pos = Vector3.new(500, 5, 500)},
	{name = "🏖️ Kohana Island", pos = Vector3.new(-643, 16, 615)},
	{name = "🌋 Kohana Volcano", pos = Vector3.new(-497, 22, 177)},
	{name = "🪸 Coral Reefs", pos = Vector3.new(-3186, 10, 2250)},
	{name = "🌌 Esoteric Depths", pos = Vector3.new(3193, -1302, 1420)},
	{name = "🌴 Tropical Grove", pos = Vector3.new(-2129, 53, 3741)},
	{name = "🌋 Crater Island", pos = Vector3.new(969, 7, 4872)},
	{name = "🏛️ Lost Isle", pos = Vector3.new(200, -50, 600)},
	{name = "🌿 Ancient Jungle", pos = Vector3.new(1453, 7, -329)},
	{name = "🎄 Christmas Island", pos = Vector3.new(-500, 10, 3500)},
	{name = "💘 Heart Island", pos = Vector3.new(800, 10, -500)},
	{name = "🏝️ Classic Island", pos = Vector3.new(0, 10, 1000)},
	{name = "🌪️ Weather Machine", pos = Vector3.new(-1519, 6, 1884)},
	{name = "🗿 Sissypus Statue", pos = Vector3.new(-3698, -135, -1026)},
	{name = "💎 Treasure Room", pos = Vector3.new(-3599, -266, -1572)}
}

-- ========== TABS ==========
local tab1 = createTab("Fishing", function()
	createSection("Auto Features")
	createToggle("Auto Cast", false, function(s) _G.AutoCast = s end)
	createToggle("Auto Reel", false, function(s) _G.AutoReel = s end)
	createToggle("Instant Catch", false, function(s) _G.Instant = s end)
	createToggle("Auto Sell", false, function(s) _G.AutoSell = s end)
	
	createSection("Target Settings")
	createFishSelector() -- Pilih area & ikan
	
	createSection("Mutation Settings")
	createMutationSelector() -- Pilih mutasi target
end)

local tab2 = createTab("Maps", function()
	createSection("📍 16 Maps Teleport")
	for _, spot in ipairs(teleportSpots) do
		local card = Instance.new("TextButton")
		card.Size = UDim2.new(1, 0, 0, 30)
		card.BackgroundColor3 = Theme.Card
		card.Text = spot.name
		card.TextColor3 = Theme.Text
		card.TextSize = 12
		card.Font = Enum.Font.GothamMedium
		card.Parent = content
		Instance.new("UICorner", card).CornerRadius = UDim.new(0, 4)
		
		card.MouseButton1Click:Connect(function()
			local char = LocalPlayer.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				char.HumanoidRootPart.CFrame = CFrame.new(spot.pos)
			end
		end)
	end
end)

local tab3 = createTab("Player", function()
	createSection("Movement")
	createToggle("Anti AFK", false, function(s) _G.AntiAfk = s end)
	createToggle("No Clip", false, function(s) _G.Noclip = s end)
	createToggle("Infinite Jump", false, function(s) _G.InfJump = s end)
	createToggle("Speed Boost", false, function(s) _G.Speed = s end)
	
	createSection("Visual")
	createToggle("Fullbright", false, function(s) 
		game.Lighting.Brightness = s and 2 or 1
	end)
	createToggle("No Shadows", false, function(s)
		game.Lighting.GlobalShadows = not s
	end)
end)

local tab4 = createTab("Misc", function()
	createSection("Utilities")
	createToggle("Hide Notifications", false, function(s) _G.HideNotif = s end)
	createToggle("Auto Rejoin", false, function(s) _G.Rejoin = s end)
	createToggle("FPS Boost", false, function(s) 
		settings().Rendering.QualityLevel = s and 1 or 21
	end)
end)

-- Activate first tab
tab1.MouseButton1Click:Fire()

-- Anti AFK Loop
task.spawn(function()
	while ScriptEnabled do
		task.wait(240)
		if _G.AntiAfk then
			pcall(function()
				VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, game)
				task.wait(0.1)
				VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, game)
			end)
		end
	end
end)

print("✅ FISH IT HUB LOADED - 16 MAPS + MUTASI")
