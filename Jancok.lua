local GameVersion = "2.0.0"
local ScriptEnabled = true

-- Services
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")

print("=== ACL PREMIUM ===")

-- Theme Clean & Simple
local Theme = {
    bg = Color3.fromRGB(15, 15, 20),
    card = Color3.fromRGB(25, 25, 32),
    accent = Color3.fromRGB(90, 140, 255),
    text = Color3.fromRGB(245, 245, 245),
    text2 = Color3.fromRGB(170, 170, 180),
    border = Color3.fromRGB(40, 40, 48)
}

-- GUI Parent
local guiParent = game:GetService("CoreGui")
pcall(function() guiParent = gethui() end)

if guiParent:FindFirstChild("ACL_PREMIUM") then
    guiParent.ACL_PREMIUM:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "ACL_PREMIUM"
gui.Parent = guiParent
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 999999
gui.ResetOnSpawn = false

-- Main Frame
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 340, 0, 500)
main.Position = UDim2.new(0.5, -170, 0.5, -250)
main.BackgroundColor3 = Theme.bg
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui

-- Corner
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 18)
corner.Parent = main

-- Border
local border = Instance.new("UIStroke")
border.Color = Theme.border
border.Thickness = 1.5
border.Parent = main

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 55)
header.BackgroundColor3 = Theme.card
header.BorderSizePixel = 0
header.Parent = main

-- Header Corner (top only)
local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 18)
headerCorner.Parent = header

-- Fix corner overlap
local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 10)
headerFix.Position = UDim2.new(0, 0, 1, -10)
headerFix.BackgroundColor3 = Theme.card
headerFix.BorderSizePixel = 0
headerFix.Parent = header

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -70, 1, 0)
title.Position = UDim2.new(0, 16, 0, 0)
title.BackgroundTransparency = 1
title.Text = "ACL PREMIUM"
title.TextColor3 = Theme.accent
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -48, 0.5, -20)
closeBtn.BackgroundColor3 = Theme.card
closeBtn.BackgroundTransparency = 0.5
closeBtn.Text = "✕"
closeBtn.TextColor3 = Theme.text2
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 12)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Content
local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -20, 1, -65)
content.Position = UDim2.new(0, 10, 0, 60)
content.BackgroundTransparency = 1
content.ScrollBarThickness = 3
content.ScrollBarImageColor3 = Theme.accent
content.Parent = main

local contentList = Instance.new("UIListLayout")
contentList.Padding = UDim.new(0, 12)
contentList.Parent = content

-- Function: Section
local function addSection(titleText)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, 0, 0, 28)
    section.BackgroundTransparency = 1
    section.Parent = content
    
    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 30, 0, 2)
    line.Position = UDim2.new(0, 0, 0.5, -1)
    line.BackgroundColor3 = Theme.accent
    line.Parent = section
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -40, 1, 0)
    title.Position = UDim2.new(0, 40, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = titleText
    title.TextColor3 = Theme.text2
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = section
end

-- Function: Card
local function addCard(height)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, height or 50)
    card.BackgroundColor3 = Theme.card
    card.BorderSizePixel = 0
    card.Parent = content
    
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 12)
    cardCorner.Parent = card
    
    local cardBorder = Instance.new("UIStroke")
    cardBorder.Color = Theme.border
    cardBorder.Thickness = 1
    cardBorder.Parent = card
    
    return card
end

-- Function: Location Button
local function addLocationButton(parent, name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -16, 0, 44)
    btn.Position = UDim2.new(0, 8, 0, 8)
    btn.BackgroundColor3 = Theme.bg
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.Parent = parent
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -30, 1, 0)
    nameLabel.Position = UDim2.new(0, 12, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.TextColor3 = Theme.text
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.GothamMedium
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = btn
    
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -28, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "›"
    arrow.TextColor3 = Theme.accent
    arrow.TextSize = 20
    arrow.Font = Enum.Font.GothamBold
    arrow.Parent = btn
    
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Theme.accent
        nameLabel.TextColor3 = Color3.new(1, 1, 1)
        arrow.TextColor3 = Color3.new(1, 1, 1)
    end)
    
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Theme.bg
        nameLabel.TextColor3 = Theme.text
        arrow.TextColor3 = Theme.accent
    end)
    
    return btn
end

-- Function: Toggle Switch
local function addToggle(parent, text, desc, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -16, 0, 50)
    frame.Position = UDim2.new(0, 8, 0, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -60, 0, 24)
    textLabel.Position = UDim2.new(0, 0, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = Theme.text
    textLabel.TextSize = 15
    textLabel.Font = Enum.Font.GothamMedium
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = frame
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -60, 0, 20)
    descLabel.Position = UDim2.new(0, 0, 0, 22)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = desc
    descLabel.TextColor3 = Theme.text2
    descLabel.TextSize = 12
    descLabel.Font = Enum.Font.GothamMedium
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = frame
    
    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0, 44, 0, 24)
    toggleBg.Position = UDim2.new(1, -52, 0.5, -12)
    toggleBg.BackgroundColor3 = Theme.border
    toggleBg.BorderSizePixel = 0
    toggleBg.Parent = frame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBg
    
    local toggleCircle = Instance.new("Frame")
    toggleCircle.Size = UDim2.new(0, 20, 0, 20)
    toggleCircle.Position = UDim2.new(0, 2, 0.5, -10)
    toggleCircle.BackgroundColor3 = Theme.text2
    toggleCircle.BorderSizePixel = 0
    toggleCircle.Parent = toggleBg
    
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = toggleCircle
    
    local state = false
    
    local function updateToggle()
        if state then
            toggleBg.BackgroundColor3 = Theme.accent
            toggleCircle.Position = UDim2.new(0, 22, 0.5, -10)
            toggleCircle.BackgroundColor3 = Color3.new(1, 1, 1)
        else
            toggleBg.BackgroundColor3 = Theme.border
            toggleCircle.Position = UDim2.new(0, 2, 0.5, -10)
            toggleCircle.BackgroundColor3 = Theme.text2
        end
    end
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(1, 0, 1, 0)
    toggleBtn.BackgroundTransparency = 1
    toggleBtn.Text = ""
    toggleBtn.Parent = toggleBg
    
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        updateToggle()
        if callback then callback(state) end
    end)
end

-- =============================================
-- TELEPORT SECTION
-- =============================================
addSection("TELEPORT")

-- Create multiple location cards (22 lokasi)
local locations = {
    "Pulau Nelayan", "Pedagang Keliling", "Observatorium", 
    "Pulau Kawah", "Hutan Tropis", "Mesin Cuaca",
    "Terumbu Karang", "Teluk Bajak Laut", "Kuil Suci",
    "Gua Bawah Tanah", "Batu Bertuah", "Hutan Kuno",
    "Luar Hutan Kuno", "Lava Kohana", "Tuas Diamond",
    "Tuas Crescent", "Tuas Hourglass", "Tuas Arrow",
    "Kohana", "Pulau Esotoric", "Pulau Es", "Pulau Hilang"
}

-- Group locations in cards (4 locations per card)
for i = 1, #locations, 4 do
    local card = addCard(200)
    
    for j = i, math.min(i+3, #locations) do
        local btn = addLocationButton(card, locations[j])
        btn.MouseButton1Click:Connect(function()
            print("Teleport ke:", locations[j])
            -- Tambahkan logic teleport
        end)
        
        -- Add spacing between buttons
        if j < math.min(i+3, #locations) then
            local spacer = Instance.new("Frame")
            spacer.Size = UDim2.new(1, 0, 0, 4)
            spacer.BackgroundTransparency = 1
            spacer.Parent = card
        end
    end
end

-- =============================================
-- AUTO FAVORITE SECTION
-- =============================================
addSection("AUTO FAVORITE")

local favCard = addCard(280)
local favLayout = Instance.new("UIListLayout")
favLayout.Padding = UDim.new(0, 4)
favLayout.Parent = favCard

addToggle(favCard, "Common", "Ikan biasa", function(s) end)
addToggle(favCard, "Uncommon", "Ikan jarang", function(s) end)
addToggle(favCard, "Rare", "Ikan langka", function(s) end)
addToggle(favCard, "Epic", "Ikan epik", function(s) end)
addToggle(favCard, "Legendary", "Ikan legendaris", function(s) end)
addToggle(favCard, "Mythic", "Ikan mitis", function(s) end)
addToggle(favCard, "SECRET", "Ikan rahasia", function(s) end)
addToggle(favCard, "Ruby", "Batu rubi", function(s) end)
addToggle(favCard, "Gemstone", "Batu permata", function(s) end)

-- =============================================
-- SETTINGS SECTION
-- =============================================
addSection("SETTINGS")

local settingsCard = addCard(120)
local settingsLayout = Instance.new("UIListLayout")
settingsLayout.Padding = UDim.new(0, 4)
settingsLayout.Parent = settingsCard

addToggle(settingsCard, "Anti AFK", "Cegah kick otomatis", function(state)
    if state then
        -- Logic anti AFK
        print("Anti AFK ON")
    else
        print("Anti AFK OFF")
    end
end)

addToggle(settingsCard, "Mode Malam", "Gelapkan map", function(state)
    game.Lighting.ClockTime = state and 0 or 12
end)

-- =============================================
-- INFO BOTTOM
-- =============================================
local infoCard = addCard(65)

local luckLabel = Instance.new("TextLabel")
luckLabel.Size = UDim2.new(0.5, -10, 0, 20)
luckLabel.Position = UDim2.new(0, 12, 0, 12)
luckLabel.BackgroundTransparency = 1
luckLabel.Text = "Friend Luck: +30%"
luckLabel.TextColor3 = Theme.accent
luckLabel.TextSize = 13
luckLabel.Font = Enum.Font.GothamBold
luckLabel.TextXAlignment = Enum.TextXAlignment.Left
luckLabel.Parent = infoCard

local moneyLabel = Instance.new("TextLabel")
moneyLabel.Size = UDim2.new(0.5, -10, 0, 20)
moneyLabel.Position = UDim2.new(0.5, 2, 0, 12)
moneyLabel.BackgroundTransparency = 1
moneyLabel.Text = "373.43K"
moneyLabel.TextColor3 = Theme.text
moneyLabel.TextSize = 13
moneyLabel.Font = Enum.Font.GothamBold
moneyLabel.TextXAlignment = Enum.TextXAlignment.Right
moneyLabel.Parent = infoCard

local locationLabel = Instance.new("TextLabel")
locationLabel.Size = UDim2.new(0.5, -10, 0, 18)
locationLabel.Position = UDim2.new(0, 12, 0, 35)
locationLabel.BackgroundTransparency = 1
locationLabel.Text = "Pulau Nelayan"
locationLabel.TextColor3 = Theme.text2
locationLabel.TextSize = 12
locationLabel.Font = Enum.Font.GothamMedium
locationLabel.TextXAlignment = Enum.TextXAlignment.Left
locationLabel.Parent = infoCard

local timeLabel = Instance.new("TextLabel")
timeLabel.Size = UDim2.new(0.5, -10, 0, 18)
timeLabel.Position = UDim2.new(0.5, 2, 0, 35)
timeLabel.BackgroundTransparency = 1
timeLabel.Text = "02:30"
timeLabel.TextColor3 = Theme.text2
timeLabel.TextSize = 12
timeLabel.Font = Enum.Font.GothamMedium
timeLabel.TextXAlignment = Enum.TextXAlignment.Right
timeLabel.Parent = infoCard

-- Update canvas size
content.CanvasSize = UDim2.new(0, 0, 0, contentList.AbsoluteContentSize.Y + 20)
contentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    content.CanvasSize = UDim2.new(0, 0, 0, contentList.AbsoluteContentSize.Y + 20)
end)
