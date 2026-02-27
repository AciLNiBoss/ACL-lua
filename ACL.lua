-- ==============================================
-- ACLXC HUB - MOBILE EDITION
-- CONFIGURATION & BASIC SETUP
-- ==============================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")

local PLAYER = Players.LocalPlayer

-- MODERN COLOR SCHEME (Ultra-Smooth Dark Theme with Indigo Accent)
local MODERN_COLORS = {
    Primary = Color3.fromRGB(15, 15, 20),
    Secondary = Color3.fromRGB(25, 25, 32),
    Accent = Color3.fromRGB(110, 80, 255),
    Success = Color3.fromRGB(46, 204, 113),
    Warning = Color3.fromRGB(241, 196, 15),
    Danger = Color3.fromRGB(231, 76, 60),
    Text = Color3.fromRGB(250, 250, 255),
    DarkText = Color3.fromRGB(150, 150, 160)
}

-- GAME DATABASE
local NPC_TARGETS = {"Rod Merchant", "Star Merchant", "Mary", "Gilbert", "Electrician", "The Guardian", "Wizard", "Blacksmith"}
local STAR_LOCATIONS = {"Blue Supergiant", "Unstable Star", "Red Supergiant", "The First Light", "Collapsar", "Blazar Core", "Millisecond Pulsar", "Nebula", "Molecular Cloud", "Supernova", "Quasar Core", "X-Ray Binary Star"}

local FeatureStates = {
    AutoFishing = false, StarFarming = false, SpeedHack = false,
    AutoQuest = false, AutoSell = false, NightVision = false,
    XRayVision = false, NoClip = false, InfiniteStamina = false,
    AntiAFK = false, ESP = false, AutoFarm = false
}

local PerformanceMetrics = {
    FishCaught = 0, StarsCollected = 0, QuestsCompleted = 0, SessionStart = os.time()
}

-- CREATE MAIN UI CONTAINER
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ACLXC_Mobile_Hub"
ScreenGui.Parent = PLAYER.PlayerGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- UTILITY FUNCTIONS
function showNotification(message)
    local notif = Instance.new("TextLabel")
    notif.Text = message
    notif.Size = UDim2.new(0.8, 0, 0, 40)
    notif.Position = UDim2.new(0.5, 0, 1, 50)
    notif.AnchorPoint = Vector2.new(0.5, 0.5)
    notif.BackgroundColor3 = MODERN_COLORS.Secondary
    notif.BackgroundTransparency = 0.1
    notif.TextColor3 = MODERN_COLORS.Text
    notif.Font = Enum.Font.GothamMedium
    notif.TextSize = 13
    notif.BorderSizePixel = 0
    notif.Parent = ScreenGui
    
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke", notif)
    stroke.Color = MODERN_COLORS.Accent
    stroke.Thickness = 1.5
    
    TweenService:Create(notif, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, 0, 0.9, 0)
    }):Play()
    
    task.wait(2.5)
    
    TweenService:Create(notif, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
        Position = UDim2.new(0.5, 0, 1, 50),
        BackgroundTransparency = 1,
        TextTransparency = 1
    }):Play()
    
    task.wait(0.5)
    notif:Destroy()
end

-- ==============================================
-- FLOATING LOGO (Muncul Pertama Kali)
-- ==============================================
local FloatingLogo = Instance.new("TextButton")
FloatingLogo.Name = "FloatingLogo"
FloatingLogo.Size = UDim2.new(0, 50, 0, 50)
FloatingLogo.Position = UDim2.new(0.5, 0, 0, 30) -- Posisi atas tengah layar HP
FloatingLogo.AnchorPoint = Vector2.new(0.5, 0)
FloatingLogo.BackgroundColor3 = MODERN_COLORS.Primary
FloatingLogo.BackgroundTransparency = 0.1
FloatingLogo.Text = "🔮"
FloatingLogo.TextSize = 24
FloatingLogo.BorderSizePixel = 0
FloatingLogo.Parent = ScreenGui

Instance.new("UICorner", FloatingLogo).CornerRadius = UDim.new(1, 0) -- Buat jadi lingkaran penuh
local LogoStroke = Instance.new("UIStroke", FloatingLogo)
LogoStroke.Color = MODERN_COLORS.Accent
LogoStroke.Thickness = 2

-- ==============================================
-- MAIN UI WINDOW (Mobile Optimized)
-- ==============================================
local MainWindow = Instance.new("Frame")
MainWindow.Name = "MainWindow"
MainWindow.Size = UDim2.new(0.9, 0, 0.85, 0) -- 90% Lebar Layar, 85% Tinggi Layar
MainWindow.Position = UDim2.new(0.5, 0, 0.5, 0)
MainWindow.AnchorPoint = Vector2.new(0.5, 0.5)
MainWindow.BackgroundColor3 = MODERN_COLORS.Primary
MainWindow.BackgroundTransparency = 0.15
MainWindow.BorderSizePixel = 0
MainWindow.Visible = false -- Disembunyikan awalnya
MainWindow.ClipsDescendants = true
MainWindow.Parent = ScreenGui

Instance.new("UICorner", MainWindow).CornerRadius = UDim.new(0, 16)
local WindowStroke = Instance.new("UIStroke", MainWindow)
WindowStroke.Color = MODERN_COLORS.Accent
WindowStroke.Thickness = 1.5
WindowStroke.Transparency = 0.3

-- HEADER
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 60)
Header.BackgroundColor3 = MODERN_COLORS.Secondary
Header.BackgroundTransparency = 0.3
Header.BorderSizePixel = 0
Header.Parent = MainWindow
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 16)

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Text = "🔮 ACLXC PREMIUM"
HeaderTitle.Size = UDim2.new(0.6, 0, 1, 0)
HeaderTitle.Position = UDim2.new(0, 15, 0, 0)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.TextColor3 = MODERN_COLORS.Text
HeaderTitle.Font = Enum.Font.GothamBold
HeaderTitle.TextSize = 18
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "✕"
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -50, 0.5, -20)
CloseBtn.BackgroundColor3 = MODERN_COLORS.Danger
CloseBtn.TextColor3 = MODERN_COLORS.Text
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = Header
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 10)

-- SCROLLING FEATURES (Kolom Tunggal untuk HP)
local FeaturesContainer = Instance.new("ScrollingFrame")
FeaturesContainer.Size = UDim2.new(1, -20, 1, -80)
FeaturesContainer.Position = UDim2.new(0, 10, 0, 70)
FeaturesContainer.BackgroundTransparency = 1
FeaturesContainer.BorderSizePixel = 0
FeaturesContainer.ScrollBarThickness = 4
FeaturesContainer.ScrollBarImageColor3 = MODERN_COLORS.Accent
FeaturesContainer.Parent = MainWindow

local UIListLayout = Instance.new("UIListLayout", FeaturesContainer)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)

-- Feature definitions
local featuresList = {
    {name = "AUTO FISHING", icon = "🎣", color = MODERN_COLORS.Accent, key = "AutoFishing"},
    {name = "STAR FARMER", icon = "🌟", color = MODERN_COLORS.Warning, key = "StarFarming"},
    {name = "SPEED HACK", icon = "⚡", color = MODERN_COLORS.Success, key = "SpeedHack"},
    {name = "TELEPORT", icon = "📍", color = Color3.fromRGB(100, 200, 255), key = "Teleport"},
    {name = "AUTO QUEST", icon = "📜", color = Color3.fromRGB(200, 150, 255), key = "AutoQuest"},
    {name = "AUTO SELL", icon = "💰", color = Color3.fromRGB(0, 220, 150), key = "AutoSell"},
    {name = "NIGHT VISION", icon = "🌙", color = Color3.fromRGB(150, 100, 255), key = "NightVision"},
    {name = "INFINITE STAMINA", icon = "♾️", color = Color3.fromRGB(50, 220, 100), key = "InfiniteStamina"},
    {name = "PANIC MODE", icon = "🆘", color = MODERN_COLORS.Danger, key = "Panic"}
}

-- Create feature cards
for i, feature in ipairs(featuresList) do
    local featureCard = Instance.new("Frame")
    featureCard.Size = UDim2.new(1, -10, 0, 60)
    featureCard.BackgroundColor3 = MODERN_COLORS.Secondary
    featureCard.BackgroundTransparency = 0.4
    featureCard.Parent = FeaturesContainer
    
    Instance.new("UICorner", featureCard).CornerRadius = UDim.new(0, 12)
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Text = feature.icon
    iconLabel.Size = UDim2.new(0, 50, 1, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.TextColor3 = feature.color
    iconLabel.TextSize = 24
    iconLabel.Parent = featureCard
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Text = feature.name
    nameLabel.Size = UDim2.new(0.6, 0, 1, 0)
    nameLabel.Position = UDim2.new(0, 50, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = MODERN_COLORS.Text
    nameLabel.Font = Enum.Font.GothamMedium
    nameLabel.TextSize = 14
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = featureCard
    
    -- Toggle switch
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(0, 44, 0, 22)
    toggleFrame.Position = UDim2.new(1, -55, 0.5, -11)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    toggleFrame.Parent = featureCard
    Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(1, 0)
    
    local toggleKnob = Instance.new("Frame")
    toggleKnob.Name = "ToggleKnob"
    toggleKnob.Size = UDim2.new(0, 18, 0, 18)
    toggleKnob.Position = UDim2.new(0, 2, 0.5, -9)
    toggleKnob.BackgroundColor3 = MODERN_COLORS.DarkText
    toggleKnob.Parent = toggleFrame
    Instance.new("UICorner", toggleKnob).CornerRadius = UDim.new(1, 0)
    
    -- Click functionality
    local triggerBtn = Instance.new("TextButton", featureCard)
    triggerBtn.Size = UDim2.new(1,0,1,0)
    triggerBtn.BackgroundTransparency = 1
    triggerBtn.Text = ""
    
    triggerBtn.MouseButton1Click:Connect(function()
        if feature.key == "Panic" then
            for key, _ in pairs(FeatureStates) do FeatureStates[key] = false end
            showNotification("🆘 PANIC: ALL DISABLED")
            -- Tutup UI
            CloseBtn.MouseButton1Click:Fire()
            return
        end
        
        FeatureStates[feature.key] = not FeatureStates[feature.key]
        
        if FeatureStates[feature.key] then
            TweenService:Create(toggleKnob, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Position = UDim2.new(1, -20, 0.5, -9), BackgroundColor3 = MODERN_COLORS.Text}):Play()
            TweenService:Create(toggleFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {BackgroundColor3 = feature.color}):Play()
            showNotification("✅ " .. feature.name .. " ON")
        else
            TweenService:Create(toggleKnob, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Position = UDim2.new(0, 2, 0.5, -9), BackgroundColor3 = MODERN_COLORS.DarkText}):Play()
            TweenService:Create(toggleFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}):Play()
            showNotification("❌ " .. feature.name .. " OFF")
        end
    end)
end

-- Update Canvas Size based on items
UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    FeaturesContainer.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 20)
end)


-- ==============================================
-- ANIMATION & LOGIC
-- ==============================================

-- Buka UI Utama
FloatingLogo.MouseButton1Click:Connect(function()
    FloatingLogo.Visible = false
    MainWindow.Size = UDim2.new(0.5, 0, 0.5, 0) -- Mulai kecil
    MainWindow.Visible = true
    
    TweenService:Create(MainWindow, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0.9, 0, 0.85, 0) -- Membesar sesuai layar
    }):Play()
end)

-- Tutup UI Utama
CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(MainWindow, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
        Size = UDim2.new(0.5, 0, 0.5, 0)
    }):Play()
    
    task.wait(0.3)
    MainWindow.Visible = false
    FloatingLogo.Visible = true
    
    -- Efek pantul untuk logo
    FloatingLogo.Size = UDim2.new(0, 30, 0, 30)
    TweenService:Create(FloatingLogo, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 50, 0, 50)
    }):Play()
end)

-- ==============================================
-- DRAG SYSTEM (Meskipun Mobile, logo bisa digeser)
-- ==============================================
local draggingLogo = false
local dragStart, startPos

FloatingLogo.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingLogo = true
        dragStart = input.Position
        startPos = FloatingLogo.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingLogo and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        FloatingLogo.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X, 
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingLogo = false
    end
end)

showNotification("✅ ACLXC MOBILE LOADED")
