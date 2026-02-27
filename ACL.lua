-- ==============================================
-- ACLXC HUB - PART 1/4
-- CONFIGURATION & BASIC SETUP
-- ==============================================

-- LOAD SERVICES
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

-- CONFIGURATION
local PLAYER = Players.LocalPlayer
local UI_OPACITY = 0.85 -- Sedikit lebih transparan untuk efek glass
local ANIMATION_SPEED = 0.35

-- MODERN COLOR SCHEME (Ultra-Smooth Dark Theme with Indigo Accent)
local MODERN_COLORS = {
    Primary = Color3.fromRGB(15, 15, 20),     -- Deep Dark
    Secondary = Color3.fromRGB(25, 25, 32),   -- Elevated Dark
    Accent = Color3.fromRGB(110, 80, 255),    -- Smooth Indigo/Purple
    Success = Color3.fromRGB(46, 204, 113),   -- Mint Green
    Warning = Color3.fromRGB(241, 196, 15),   -- Clean Yellow
    Danger = Color3.fromRGB(231, 76, 60),     -- Soft Red
    Text = Color3.fromRGB(250, 250, 255),     -- Crisp White
    DarkText = Color3.fromRGB(150, 150, 160)  -- Muted Gray
}

-- GAME DATABASE (From Scan)
local NPC_TARGETS = {
    "Rod Merchant", "Star Merchant", "Mary", "Gilbert", 
    "Electrician", "The Guardian", "Wizard", "Blacksmith"
}

local STAR_LOCATIONS = {
    "Blue Supergiant", "Unstable Star", "Red Supergiant",
    "The First Light", "Collapsar", "Blazar Core",
    "Millisecond Pulsar", "Nebula", "Molecular Cloud",
    "Supernova", "Quasar Core", "X-Ray Binary Star"
}

-- FEATURE STATES
local FeatureStates = {
    AutoFishing = false,
    StarFarming = false,
    SpeedHack = false,
    AutoQuest = false,
    AutoSell = false,
    NightVision = false,
    XRayVision = false,
    NoClip = false,
    InfiniteStamina = false,
    AntiAFK = false,
    ESP = false,
    AutoFarm = false
}

-- PERFORMANCE METRICS
local PerformanceMetrics = {
    FishCaught = 0,
    StarsCollected = 0,
    QuestsCompleted = 0,
    MoneyEarned = 0,
    SessionStart = os.time()
}

-- CREATE MAIN UI CONTAINER
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ACLXC_Hub"
ScreenGui.Parent = PLAYER.PlayerGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- UTILITY FUNCTIONS
function showNotification(message)
    local notif = Instance.new("TextLabel")
    notif.Text = message
    notif.Size = UDim2.new(0, 300, 0, 45)
    notif.Position = UDim2.new(0.5, -150, 1, 0)
    notif.BackgroundColor3 = MODERN_COLORS.Secondary
    notif.BackgroundTransparency = 0.2
    notif.TextColor3 = MODERN_COLORS.Text
    notif.Font = Enum.Font.GothamMedium
    notif.TextSize = 14
    notif.BorderSizePixel = 0
    notif.Parent = ScreenGui
    
    local NotifCorner = Instance.new("UICorner")
    NotifCorner.CornerRadius = UDim.new(0, 12)
    NotifCorner.Parent = notif
    
    local NotifStroke = Instance.new("UIStroke")
    NotifStroke.Color = MODERN_COLORS.Accent
    NotifStroke.Thickness = 1.5
    NotifStroke.Transparency = 0.5
    NotifStroke.Parent = notif
    
    notif.Visible = true
    
    -- Smooth Quart Animation
    TweenService:Create(notif, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -150, 0.9, -20)
    }):Play()
    
    task.wait(3)
    
    TweenService:Create(notif, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
        Position = UDim2.new(0.5, -150, 1, 20),
        BackgroundTransparency = 1,
        TextTransparency = 1
    }):Play()
    
    task.wait(0.5)
    notif:Destroy()
end

function createModernButton(text, size, position, color)
    local button = Instance.new("TextButton")
    button.Text = text
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = color or MODERN_COLORS.Secondary
    button.TextColor3 = MODERN_COLORS.Text
    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    button.AutoButtonColor = false
    button.BorderSizePixel = 0
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 8)
    ButtonCorner.Parent = button
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0.1,
            Size = size + UDim2.new(0, 6, 0, 6),
            Position = position - UDim2.new(0, 3, 0, 3)
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0,
            Size = size,
            Position = position
        }):Play()
    end)
    
    button.MouseButton1Down:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {
            BackgroundTransparency = 0.5,
            Size = size,
            Position = position
        }):Play()
    end)
    
    button.MouseButton1Up:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0.1,
            Size = size + UDim2.new(0, 6, 0, 6),
            Position = position - UDim2.new(0, 3, 0, 3)
        }):Play()
    end)
    
    return button
end

-- ==============================================
-- ACLXC HUB - PART 2/4
-- UI COMPONENTS SETUP
-- ==============================================

-- MINIMIZED DOCK (Modern Floating Dock)
local MinimizedDock = Instance.new("Frame")
MinimizedDock.Name = "MinimizedDock"
MinimizedDock.Size = UDim2.new(0, 240, 0, 60)
MinimizedDock.Position = UDim2.new(0.5, -120, 0.96, -30)
MinimizedDock.BackgroundColor3 = MODERN_COLORS.Primary
MinimizedDock.BackgroundTransparency = 0.15
MinimizedDock.BorderSizePixel = 0
MinimizedDock.Parent = ScreenGui

local DockCorner = Instance.new("UICorner")
DockCorner.CornerRadius = UDim.new(0, 16)
DockCorner.Parent = MinimizedDock

local DockStroke = Instance.new("UIStroke")
DockStroke.Color = MODERN_COLORS.Accent
DockStroke.Thickness = 1.5
DockStroke.Transparency = 0.4
DockStroke.Parent = MinimizedDock

-- Dock content
local DockIcon = Instance.new("TextLabel")
DockIcon.Text = "🔮"
DockIcon.Size = UDim2.new(0, 45, 0, 45)
DockIcon.Position = UDim2.new(0, 10, 0.5, -22.5)
DockIcon.BackgroundTransparency = 1
DockIcon.TextSize = 24
DockIcon.Parent = MinimizedDock

local DockTitle = Instance.new("TextLabel")
DockTitle.Text = "ACLXC HUB"
DockTitle.Size = UDim2.new(0, 130, 0, 25)
DockTitle.Position = UDim2.new(0, 55, 0, 10)
DockTitle.BackgroundTransparency = 1
DockTitle.TextColor3 = MODERN_COLORS.Text
DockTitle.Font = Enum.Font.GothamBold
DockTitle.TextSize = 16
DockTitle.TextXAlignment = Enum.TextXAlignment.Left
DockTitle.Parent = MinimizedDock

local DockSubtitle = Instance.new("TextLabel")
DockSubtitle.Text = "Click to open menu"
DockSubtitle.Size = UDim2.new(0, 130, 0, 20)
DockSubtitle.Position = UDim2.new(0, 55, 0, 32)
DockSubtitle.BackgroundTransparency = 1
DockSubtitle.TextColor3 = MODERN_COLORS.DarkText
DockSubtitle.Font = Enum.Font.Gotham
DockSubtitle.TextSize = 11
DockSubtitle.TextXAlignment = Enum.TextXAlignment.Left
DockSubtitle.Parent = MinimizedDock

local StatusLight = Instance.new("Frame")
StatusLight.Name = "StatusLight"
StatusLight.Size = UDim2.new(0, 10, 0, 10)
StatusLight.Position = UDim2.new(1, -25, 0.5, -5)
StatusLight.BackgroundColor3 = MODERN_COLORS.Success
StatusLight.BorderSizePixel = 0
StatusLight.Parent = MinimizedDock

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(1, 0)
StatusCorner.Parent = StatusLight

-- MAIN CONTROL PANEL (Modern Glass Window)
local MainWindow = Instance.new("Frame")
MainWindow.Name = "MainWindow"
MainWindow.Size = UDim2.new(0, 620, 0, 720)
MainWindow.Position = UDim2.new(0.5, -310, 0.5, -360)
MainWindow.BackgroundColor3 = MODERN_COLORS.Primary
MainWindow.BackgroundTransparency = 0.15 -- Glass effect
MainWindow.BorderSizePixel = 0
MainWindow.Visible = false
MainWindow.Parent = ScreenGui

local WindowCorner = Instance.new("UICorner")
WindowCorner.CornerRadius = UDim.new(0, 16)
WindowCorner.Parent = MainWindow

local WindowStroke = Instance.new("UIStroke")
WindowStroke.Color = MODERN_COLORS.Accent
WindowStroke.Thickness = 1.5
WindowStroke.Transparency = 0.5
WindowStroke.Parent = MainWindow

-- HEADER SECTION
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 75)
Header.BackgroundColor3 = MODERN_COLORS.Secondary
Header.BackgroundTransparency = 0.3
Header.BorderSizePixel = 0
Header.Parent = MainWindow

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 16)
HeaderCorner.Parent = Header

-- Header content
local HeaderIcon = Instance.new("TextLabel")
HeaderIcon.Text = "🔮"
HeaderIcon.Size = UDim2.new(0, 50, 0, 50)
HeaderIcon.Position = UDim2.new(0, 20, 0.5, -25)
HeaderIcon.BackgroundTransparency = 1
HeaderIcon.TextSize = 28
HeaderIcon.Parent = Header

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Text = "ACLXC PREMIUM"
HeaderTitle.Size = UDim2.new(0, 300, 0, 35)
HeaderTitle.Position = UDim2.new(0, 75, 0.5, -17.5)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.TextColor3 = MODERN_COLORS.Text
HeaderTitle.Font = Enum.Font.GothamBold
HeaderTitle.TextSize = 22
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.Parent = Header

local VersionTag = Instance.new("Frame")
VersionTag.Size = UDim2.new(0, 80, 0, 26)
VersionTag.Position = UDim2.new(0, 330, 0.5, -13)
VersionTag.BackgroundColor3 = MODERN_COLORS.Accent
VersionTag.BackgroundTransparency = 0.1
VersionTag.BorderSizePixel = 0
VersionTag.Parent = Header

local VersionCorner = Instance.new("UICorner")
VersionCorner.CornerRadius = UDim.new(0, 8)
VersionCorner.Parent = VersionTag

local VersionText = Instance.new("TextLabel")
VersionText.Text = "v1.0"
VersionText.Size = UDim2.new(1, 0, 1, 0)
VersionText.BackgroundTransparency = 1
VersionText.TextColor3 = Color3.fromRGB(255, 255, 255)
VersionText.Font = Enum.Font.GothamBold
VersionText.TextSize = 12
VersionText.Parent = VersionTag

-- Control buttons
local CloseBtn = createModernButton("✕", UDim2.new(0, 40, 0, 40), UDim2.new(1, -55, 0.5, -20), MODERN_COLORS.Danger)
CloseBtn.Parent = Header

local MinimizeBtn = createModernButton("–", UDim2.new(0, 40, 0, 40), UDim2.new(1, -105, 0.5, -20), MODERN_COLORS.Secondary)
MinimizeBtn.Parent = Header

-- PERFORMANCE DASHBOARD
local Dashboard = Instance.new("Frame")
Dashboard.Size = UDim2.new(1, -50, 0, 140)
Dashboard.Position = UDim2.new(0, 25, 0, 95)
Dashboard.BackgroundColor3 = MODERN_COLORS.Secondary
Dashboard.BackgroundTransparency = 0.4
Dashboard.BorderSizePixel = 0
Dashboard.Parent = MainWindow

local DashboardCorner = Instance.new("UICorner")
DashboardCorner.CornerRadius = UDim.new(0, 12)
DashboardCorner.Parent = Dashboard

local DashboardTitle = Instance.new("TextLabel")
DashboardTitle.Text = "OVERVIEW"
DashboardTitle.Size = UDim2.new(1, 0, 0, 35)
DashboardTitle.Position = UDim2.new(0, 15, 0, 5)
DashboardTitle.BackgroundTransparency = 1
DashboardTitle.TextColor3 = MODERN_COLORS.Text
DashboardTitle.Font = Enum.Font.GothamBold
DashboardTitle.TextSize = 14
DashboardTitle.TextXAlignment = Enum.TextXAlignment.Left
DashboardTitle.Parent = Dashboard

-- Performance metrics grid
local metricsGrid = {
    {name = "FISH", value = "0", icon = "🎣", color = MODERN_COLORS.Accent},
    {name = "STARS", value = "0", icon = "🌟", color = MODERN_COLORS.Warning},
    {name = "QUESTS", value = "0", icon = "📜", color = MODERN_COLORS.Success},
    {name = "TIME", value = "00:00", icon = "⏱️", color = MODERN_COLORS.DarkText}
}

for i, metric in ipairs(metricsGrid) do
    local metricCard = Instance.new("Frame")
    metricCard.Size = UDim2.new(0.22, 0, 0, 75)
    metricCard.Position = UDim2.new((i-1)*0.245 + 0.02, 0, 0, 45)
    metricCard.BackgroundColor3 = MODERN_COLORS.Primary
    metricCard.BackgroundTransparency = 0.3
    metricCard.BorderSizePixel = 0
    metricCard.Parent = Dashboard
    
    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, 10)
    CardCorner.Parent = metricCard
    
    local metricIcon = Instance.new("TextLabel")
    metricIcon.Text = metric.icon
    metricIcon.Size = UDim2.new(0, 30, 0, 30)
    metricIcon.Position = UDim2.new(0, 10, 0, 10)
    metricIcon.BackgroundTransparency = 1
    metricIcon.TextColor3 = metric.color
    metricIcon.Font = Enum.Font.SourceSansBold
    metricIcon.TextSize = 20
    metricIcon.Parent = metricCard
    
    local metricName = Instance.new("TextLabel")
    metricName.Text = metric.name
    metricName.Size = UDim2.new(0, 100, 0, 20)
    metricName.Position = UDim2.new(0, 45, 0, 10)
    metricName.BackgroundTransparency = 1
    metricName.TextColor3 = MODERN_COLORS.DarkText
    metricName.Font = Enum.Font.Gotham
    metricName.TextSize = 10
    metricName.TextXAlignment = Enum.TextXAlignment.Left
    metricName.Parent = metricCard
    
    local metricValue = Instance.new("TextLabel")
    metricValue.Name = metric.name
    metricValue.Text = metric.value
    metricValue.Size = UDim2.new(0, 100, 0, 25)
    metricValue.Position = UDim2.new(0, 45, 0, 30)
    metricValue.BackgroundTransparency = 1
    metricValue.TextColor3 = MODERN_COLORS.Text
    metricValue.Font = Enum.Font.GothamBold
    metricValue.TextSize = 16
    metricValue.TextXAlignment = Enum.TextXAlignment.Left
    metricValue.Parent = metricCard
end

-- ==============================================
-- ACLXC HUB - PART 3/4
-- FEATURE CONTROLS & UI
-- ==============================================

-- FEATURES PANEL
local FeaturesTitle = Instance.new("TextLabel")
FeaturesTitle.Text = "MODULES"
FeaturesTitle.Size = UDim2.new(1, -50, 0, 30)
FeaturesTitle.Position = UDim2.new(0, 25, 0, 250)
FeaturesTitle.BackgroundTransparency = 1
FeaturesTitle.TextColor3 = MODERN_COLORS.Text
FeaturesTitle.Font = Enum.Font.GothamBold
FeaturesTitle.TextSize = 14
FeaturesTitle.TextXAlignment = Enum.TextXAlignment.Left
FeaturesTitle.Parent = MainWindow

local FeaturesContainer = Instance.new("ScrollingFrame")
FeaturesContainer.Size = UDim2.new(1, -40, 0, 370)
FeaturesContainer.Position = UDim2.new(0, 25, 0, 285)
FeaturesContainer.BackgroundTransparency = 1
FeaturesContainer.BorderSizePixel = 0
FeaturesContainer.ScrollBarThickness = 4
FeaturesContainer.ScrollBarImageColor3 = MODERN_COLORS.Accent
FeaturesContainer.CanvasSize = UDim2.new(0, 0, 0, 800)
FeaturesContainer.Parent = MainWindow

-- Feature definitions
local featuresList = {
    {name = "AUTO FISHING", icon = "🎣", color = MODERN_COLORS.Accent, desc = "Auto fish with teleport", key = "AutoFishing"},
    {name = "STAR FARMER", icon = "🌟", color = MODERN_COLORS.Warning, desc = "Collect all stars", key = "StarFarming"},
    {name = "SPEED HACK", icon = "⚡", color = MODERN_COLORS.Success, desc = "10x speed boost", key = "SpeedHack"},
    {name = "TELEPORT", icon = "📍", color = Color3.fromRGB(100, 200, 255), desc = "Instant teleport", key = "Teleport"},
    {name = "AUTO QUEST", icon = "📜", color = Color3.fromRGB(200, 150, 255), desc = "Complete quests", key = "AutoQuest"},
    {name = "AUTO SELL", icon = "💰", color = Color3.fromRGB(0, 220, 150), desc = "Auto sell items", key = "AutoSell"},
    {name = "NIGHT VISION", icon = "🌙", color = Color3.fromRGB(150, 100, 255), desc = "Enhanced vision", key = "NightVision"},
    {name = "X-RAY VISION", icon = "🔍", color = Color3.fromRGB(255, 100, 200), desc = "See through objects", key = "XRayVision"},
    {name = "NO-CLIP", icon = "🚫", color = Color3.fromRGB(255, 150, 50), desc = "Walk through walls", key = "NoClip"},
    {name = "INFINITE STAMINA", icon = "♾️", color = Color3.fromRGB(50, 220, 100), desc = "Never get tired", key = "InfiniteStamina"},
    {name = "ANTI-AFK", icon = "🛡️", color = Color3.fromRGB(100, 100, 255), desc = "Prevent AFK", key = "AntiAFK"},
    {name = "PANIC MODE", icon = "🆘", color = MODERN_COLORS.Danger, desc = "Disable all hacks", key = "Panic"}
}

-- Create feature cards
for i, feature in ipairs(featuresList) do
    local row = math.floor((i-1)/2)
    local col = (i-1)%2
    
    local featureCard = Instance.new("Frame")
    featureCard.Size = UDim2.new(0.48, 0, 0, 90)
    featureCard.Position = UDim2.new(col * 0.51, 0, 0, row * 100)
    featureCard.BackgroundColor3 = MODERN_COLORS.Secondary
    featureCard.BackgroundTransparency = 0.4
    featureCard.BorderSizePixel = 0
    featureCard.Parent = FeaturesContainer
    
    local FeatureCorner = Instance.new("UICorner")
    FeatureCorner.CornerRadius = UDim.new(0, 10)
    FeatureCorner.Parent = featureCard
    
    local FeatureStroke = Instance.new("UIStroke")
    FeatureStroke.Color = feature.color
    FeatureStroke.Thickness = 1
    FeatureStroke.Transparency = 0.8
    FeatureStroke.Parent = featureCard
    
    -- Smooth Hover effect
    featureCard.MouseEnter:Connect(function()
        TweenService:Create(featureCard, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0.2
        }):Play()
        TweenService:Create(FeatureStroke, TweenInfo.new(0.3), {
            Transparency = 0.2
        }):Play()
    end)
    
    featureCard.MouseLeave:Connect(function()
        TweenService:Create(featureCard, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0.4
        }):Play()
        TweenService:Create(FeatureStroke, TweenInfo.new(0.3), {
            Transparency = 0.8
        }):Play()
    end)
    
    -- Card content
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Text = feature.icon
    iconLabel.Size = UDim2.new(0, 60, 1, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.TextColor3 = feature.color
    iconLabel.Font = Enum.Font.SourceSansBold
    iconLabel.TextSize = 28
    iconLabel.Parent = featureCard
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Text = feature.name
    nameLabel.Size = UDim2.new(0, 180, 0, 25)
    nameLabel.Position = UDim2.new(0, 60, 0, 15)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = MODERN_COLORS.Text
    nameLabel.Font = Enum.Font.GothamMedium
    nameLabel.TextSize = 13
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = featureCard
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Text = feature.desc
    descLabel.Size = UDim2.new(0, 180, 0, 20)
    descLabel.Position = UDim2.new(0, 60, 0, 40)
    descLabel.BackgroundTransparency = 1
    descLabel.TextColor3 = MODERN_COLORS.DarkText
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 11
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = featureCard
    
    -- Toggle switch
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(0, 44, 0, 22)
    toggleFrame.Position = UDim2.new(1, -55, 0.5, -11)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Parent = featureCard
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(1, 0)
    ToggleCorner.Parent = toggleFrame
    
    local toggleKnob = Instance.new("Frame")
    toggleKnob.Name = "ToggleKnob"
    toggleKnob.Size = UDim2.new(0, 18, 0, 18)
    toggleKnob.Position = UDim2.new(0, 2, 0.5, -9)
    toggleKnob.BackgroundColor3 = MODERN_COLORS.DarkText
    toggleKnob.BorderSizePixel = 0
    toggleKnob.Parent = toggleFrame
    
    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = toggleKnob
    
    -- Click functionality
    featureCard.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if feature.key == "Panic" then
                panicSystem()
                return
            end
            
            FeatureStates[feature.key] = not FeatureStates[feature.key]
            
            if FeatureStates[feature.key] then
                -- Smooth toggle on
                TweenService:Create(toggleKnob, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    Position = UDim2.new(1, -20, 0.5, -9),
                    BackgroundColor3 = MODERN_COLORS.Text
                }):Play()
                
                TweenService:Create(toggleFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    BackgroundColor3 = feature.color
                }):Play()
                
                showNotification("✅ " .. feature.name .. " ENABLED")
                activateFeature(feature.key, true)
            else
                -- Smooth toggle off
                TweenService:Create(toggleKnob, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0, 2, 0.5, -9),
                    BackgroundColor3 = MODERN_COLORS.DarkText
                }):Play()
                
                TweenService:Create(toggleFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                }):Play()
                
                showNotification("❌ " .. feature.name .. " DISABLED")
                activateFeature(feature.key, false)
            end
            updateStatusLight()
        end
    end)
    
    FeaturesContainer.CanvasSize = UDim2.new(0, 0, 0, (row+1) * 100 + 20)
end

-- FOOTER CONTROLS
local Footer = Instance.new("Frame")
Footer.Size = UDim2.new(1, -50, 0, 55)
Footer.Position = UDim2.new(0, 25, 0, 650)
Footer.BackgroundColor3 = MODERN_COLORS.Secondary
Footer.BackgroundTransparency = 0.4
Footer.BorderSizePixel = 0
Footer.Parent = MainWindow

local FooterCorner = Instance.new("UICorner")
FooterCorner.CornerRadius = UDim.new(0, 12)
FooterCorner.Parent = Footer

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Text = "🟢 SYSTEM: IDLE | MODULES: 0 ACTIVE"
StatusLabel.Size = UDim2.new(0.6, 0, 1, 0)
StatusLabel.Position = UDim2.new(0, 15, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = MODERN_COLORS.Success
StatusLabel.Font = Enum.Font.GothamMedium
StatusLabel.TextSize = 12
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = Footer

local BoostAllBtn = createModernButton("🚀 ENABLE ALL", UDim2.new(0, 130, 0, 35), UDim2.new(1, -140, 0.5, -17.5), MODERN_COLORS.Accent)
BoostAllBtn.Parent = Footer

-- UTILITY FUNCTIONS
function updateStatusLight()
    local activeCount = 0
    for _, state in pairs(FeatureStates) do
        if state then activeCount = activeCount + 1 end
    end
    
    StatusLabel.Text = string.format("🟢 SYSTEM: ACTIVE | MODULES: %d ACTIVE", activeCount)
    
    if activeCount > 0 then
        StatusLight.BackgroundColor3 = MODERN_COLORS.Success
    else
        StatusLight.BackgroundColor3 = MODERN_COLORS.DarkText
    end
    
    -- Smooth breathing light
    TweenService:Create(StatusLight, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(1, -27, 0.5, -7)
    }):Play()
    
    task.wait(0.3)
    
    TweenService:Create(StatusLight, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 10, 0, 10),
        Position = UDim2.new(1, -25, 0.5, -5)
    }):Play()
end

function updatePerformanceMetrics()
    local sessionTime = os.time() - PerformanceMetrics.SessionStart
    local minutes = math.floor(sessionTime / 60)
    local seconds = sessionTime % 60
    local timeString = string.format("%02d:%02d", minutes, seconds)
    
    for _, metric in ipairs(metricsGrid) do
        local display = Dashboard:FindFirstChild(metric.name)
        if display then
            if metric.name == "FISH" then
                display.Text = tostring(PerformanceMetrics.FishCaught)
            elseif metric.name == "STARS" then
                display.Text = tostring(PerformanceMetrics.StarsCollected)
            elseif metric.name == "QUESTS" then
                display.Text = tostring(PerformanceMetrics.QuestsCompleted)
            elseif metric.name == "TIME" then
                display.Text = timeString
            end
        end
    end
end

-- ==============================================
-- ACLXC HUB - PART 4/4
-- FEATURE IMPLEMENTATIONS & EVENTS
-- ==============================================

-- FEATURE IMPLEMENTATIONS
function activateFeature(featureKey, enable)
    if featureKey == "AutoFishing" then
        if enable then
            spawn(function()
                while FeatureStates.AutoFishing do
                    if PLAYER.Character then
                        local humanoidRoot = PLAYER.Character:FindFirstChild("HumanoidRootPart")
                        if humanoidRoot then
                            for _, obj in ipairs(Workspace:GetDescendants()) do
                                if obj:IsA("Part") and obj.Material == EnumMaterial.Water then
                                    humanoidRoot.CFrame = CFrame.new(obj.Position + Vector3.new(0, 5, 0))
                                    break
                                end
                            end
                            
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, nil)
                            task.wait(0.1)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, nil)
                            task.wait(1)
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, nil, 0)
                            task.wait(0.1)
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, nil, 0)
                            PerformanceMetrics.FishCaught = PerformanceMetrics.FishCaught + 1
                            updatePerformanceMetrics()
                        end
                    end
                    task.wait(2)
                end
            end)
        end
    elseif featureKey == "StarFarming" then
        if enable then
            spawn(function()
                while FeatureStates.StarFarming do
                    local starsFolder = Workspace:FindFirstChild("Stars")
                    if starsFolder and PLAYER.Character then
                        local humanoidRoot = PLAYER.Character:FindFirstChild("HumanoidRootPart")
                        if humanoidRoot then
                            for _, starName in ipairs(STAR_LOCATIONS) do
                                local star = starsFolder:FindFirstChild(starName)
                                if star and FeatureStates.StarFarming then
                                    humanoidRoot.CFrame = CFrame.new(star:GetPivot().Position + Vector3.new(0, 5, 0))
                                    task.wait(0.5)
                                    firetouchinterest(humanoidRoot, star, 0)
                                    task.wait(0.1)
                                    firetouchinterest(humanoidRoot, star, 1)
                                    PerformanceMetrics.StarsCollected = PerformanceMetrics.StarsCollected + 1
                                    updatePerformanceMetrics()
                                end
                            end
                        end
                    end
                    task.wait(3)
                end
            end)
        end
    elseif featureKey == "SpeedHack" then
        if PLAYER.Character then
            local humanoid = PLAYER.Character:FindFirstChild("Humanoid")
            if humanoid then
                if enable then
                    humanoid.WalkSpeed = 80
                    humanoid.JumpPower = 150
                else
                    humanoid.WalkSpeed = 16
                    humanoid.JumpPower = 50
                end
            end
        end
    elseif featureKey == "Teleport" then
        if enable then
            local teleportMenu = Instance.new("Frame")
            teleportMenu.Size = UDim2.new(0, 350, 0, 450)
            teleportMenu.Position = UDim2.new(0.5, -175, 0.5, -225)
            teleportMenu.BackgroundColor3 = MODERN_COLORS.Primary
            teleportMenu.BackgroundTransparency = 0.15
            teleportMenu.Parent = ScreenGui
            
            Instance.new("UICorner", teleportMenu).CornerRadius = UDim.new(0, 12)
            local stroke = Instance.new("UIStroke", teleportMenu)
            stroke.Color = MODERN_COLORS.Accent
            stroke.Thickness = 1.5
            
            local title = Instance.new("TextLabel")
            title.Text = "📍 TELEPORT LOCATIONS"
            title.Size = UDim2.new(1, 0, 0, 50)
            title.BackgroundColor3 = MODERN_COLORS.Secondary
            title.BackgroundTransparency = 0.2
            title.TextColor3 = MODERN_COLORS.Text
            title.Font = Enum.Font.GothamBold
            title.TextSize = 16
            title.Parent = teleportMenu
            
            local closeBtn = createModernButton("✕", UDim2.new(0, 40, 0, 40), UDim2.new(1, -45, 0, 5), MODERN_COLORS.Danger)
            closeBtn.Parent = teleportMenu
            
            closeBtn.MouseButton1Click:Connect(function()
                -- Smooth Close
                TweenService:Create(teleportMenu, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
                task.wait(0.3)
                teleportMenu:Destroy()
            end)
            
            local yPos = 60
            for _, npc in ipairs(NPC_TARGETS) do
                local btn = createModernButton("👤 " .. npc, UDim2.new(0.9, 0, 0, 40), UDim2.new(0.05, 0, 0, yPos), MODERN_COLORS.Secondary)
                btn.Parent = teleportMenu
                
                btn.MouseButton1Click:Connect(function()
                    local npcFolder = Workspace:FindFirstChild("NonPlayableCharacters")
                    if npcFolder then
                        local targetNPC = npcFolder:FindFirstChild(npc)
                        if targetNPC and PLAYER.Character then
                            local humanoidRoot = PLAYER.Character:FindFirstChild("HumanoidRootPart")
                            if humanoidRoot then
                                humanoidRoot.CFrame = CFrame.new(targetNPC:GetPivot().Position + Vector3.new(0, 0, 5))
                                showNotification("✅ Teleported to " .. npc)
                            end
                        end
                    end
                    teleportMenu:Destroy()
                end)
                
                yPos = yPos + 45
            end
        end
    elseif featureKey == "AutoQuest" then
        if enable then
            spawn(function()
                while FeatureStates.AutoQuest do
                    local npcFolder = Workspace:FindFirstChild("NonPlayableCharacters")
                    if npcFolder and PLAYER.Character then
                        local humanoidRoot = PLAYER.Character:FindFirstChild("HumanoidRootPart")
                        if humanoidRoot then
                            for _, npcName in ipairs({"Mary", "Gilbert", "Electrician"}) do
                                local npc = npcFolder:FindFirstChild(npcName)
                                if npc and FeatureStates.AutoQuest then
                                    humanoidRoot.CFrame = CFrame.new(npc:GetPivot().Position + Vector3.new(0, 0, 5))
                                    task.wait(1)
                                    local prompt = npc:FindFirstChild("ProximityPrompt", true)
                                    if prompt then
                                        fireproximityprompt(prompt)
                                        task.wait(0.5)
                                        fireproximityprompt(prompt)
                                        PerformanceMetrics.QuestsCompleted = PerformanceMetrics.QuestsCompleted + 1
                                        updatePerformanceMetrics()
                                    end
                                end
                            end
                        end
                    end
                    task.wait(10)
                end
            end)
        end
    elseif featureKey == "AutoSell" then
        if enable then
            spawn(function()
                while FeatureStates.AutoSell do
                    task.wait(30)
                    local npcFolder = Workspace:FindFirstChild("NonPlayableCharacters")
                    if npcFolder then
                        local merchant = npcFolder:FindFirstChild("Star Merchant")
                        if merchant and PLAYER.Character then
                            local humanoidRoot = PLAYER.Character:FindFirstChild("HumanoidRootPart")
                            if humanoidRoot then
                                humanoidRoot.CFrame = CFrame.new(merchant:GetPivot().Position + Vector3.new(0, 0, 5))
                                task.wait(1)
                                for i = 1, 5 do
                                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, nil)
                                    task.wait(0.2)
                                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, nil)
                                end
                                showNotification("💰 Auto Sell Completed")
                            end
                        end
                    end
                end
            end)
        end
    elseif featureKey == "NightVision" then
        if enable then
            Lighting.Ambient = Color3.fromRGB(100, 100, 100)
            Lighting.Brightness = 2
            Lighting.OutdoorAmbient = Color3.fromRGB(150, 150, 150)
        else
            Lighting.Ambient = Color3.fromRGB(200, 200, 200)
            Lighting.Brightness = 1
        end
    elseif featureKey == "XRayVision" then
        if enable then
            spawn(function()
                while FeatureStates.XRayVision do
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if obj:IsA("Part") and obj.Material == EnumMaterial.Water then
                            obj.Transparency = 0.5
                        end
                    end
                    task.wait(1)
                end
            end)
        else
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("Part") and obj.Material == EnumMaterial.Water then
                    obj.Transparency = 0.8
                end
            end
        end
    elseif featureKey == "NoClip" then
        if enable then
            spawn(function()
                while FeatureStates.NoClip do
                    if PLAYER.Character then
                        for _, part in ipairs(PLAYER.Character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                    task.wait(0.5)
                end
            end)
        else
            if PLAYER.Character then
                for _, part in ipairs(PLAYER.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    elseif featureKey == "InfiniteStamina" then
        if enable then
            spawn(function()
                while FeatureStates.InfiniteStamina do
                    if PLAYER.Character then
                        local humanoid = PLAYER.Character:FindFirstChild("Humanoid")
                        if humanoid and humanoid.Health < humanoid.MaxHealth then
                            humanoid.Health = humanoid.MaxHealth
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    elseif featureKey == "AntiAFK" then
        if enable then
            spawn(function()
                while FeatureStates.AntiAFK do
                    task.wait(25)
                    if PLAYER.Character then
                        local humanoid = PLAYER.Character:FindFirstChild("Humanoid")
                        if humanoid then
                            humanoid:Move(Vector3.new(0.1, 0, 0))
                            task.wait(0.1)
                            humanoid:Move(Vector3.new(-0.1, 0, 0))
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, nil)
                            task.wait(0.1)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, nil)
                        end
                    end
                end
            end)
        end
    end
end

function panicSystem()
    for key, _ in pairs(FeatureStates) do
        FeatureStates[key] = false
    end
    
    for _, card in ipairs(FeaturesContainer:GetChildren()) do
        if card:IsA("Frame") then
            local toggleKnob = card:FindFirstChild("ToggleKnob", true)
            if toggleKnob then
                TweenService:Create(toggleKnob, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0, 2, 0.5, -9),
                    BackgroundColor3 = MODERN_COLORS.DarkText
                }):Play()
            end
            
            local toggleFrame = toggleKnob and toggleKnob.Parent
            if toggleFrame then
                TweenService:Create(toggleFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                }):Play()
            end
        end
    end
    
    if PLAYER.Character then
        local humanoid = PLAYER.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16
            humanoid.JumpPower = 50
        end
    end
    
    Lighting.Ambient = Color3.fromRGB(200, 200, 200)
    Lighting.Brightness = 1
    
    showNotification("🆘 PANIC MODE: MODULES DISABLED")
    updateStatusLight()
end

-- UI CONTROL FUNCTIONS
function toggleUI()
    local isVisible = MainWindow.Visible
    MainWindow.Visible = not isVisible
    MinimizedDock.Visible = isVisible
    
    if not isVisible then
        MainWindow.Position = UDim2.new(0.5, -310, 0.4, -360)
        TweenService:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, -310, 0.5, -360)
        }):Play()
    else
        TweenService:Create(MainWindow, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, -310, 0.6, -360),
            BackgroundTransparency = 1
        }):Play()
    end
end

-- EVENT CONNECTIONS
MinimizedDock.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        toggleUI()
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    showNotification("🔴 ACLXC SHUTDOWN")
end)

MinimizeBtn.MouseButton1Click:Connect(toggleUI)

BoostAllBtn.MouseButton1Click:Connect(function()
    for _, feature in ipairs(featuresList) do
        if feature.key ~= "Panic" and not FeatureStates[feature.key] then
            FeatureStates[feature.key] = true
            
            for _, card in ipairs(FeaturesContainer:GetChildren()) do
                if card:IsA("Frame") then
                    local nameLabel = card:FindFirstChildOfClass("TextLabel")
                    if nameLabel and nameLabel.Text:find(feature.name) then
                        local toggleKnob = card:FindFirstChild("ToggleKnob", true)
                        local toggleFrame = toggleKnob and toggleKnob.Parent
                        
                        if toggleKnob and toggleFrame then
                            TweenService:Create(toggleKnob, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                                Position = UDim2.new(1, -20, 0.5, -9),
                                BackgroundColor3 = MODERN_COLORS.Text
                            }):Play()
                            
                            TweenService:Create(toggleFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                                BackgroundColor3 = feature.color
                            }):Play()
                        end
                    end
                end
            end
            
            activateFeature(feature.key, true)
        end
    end
    
    showNotification("🚀 ALL MODULES ENABLED!")
    updateStatusLight()
end)

-- Draggable window
local dragging = false
local dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    -- Menambahkan sedikit delay pada drag update untuk kesan smooth (opsional, disederhanakan dengan posisi real-time)
    MainWindow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainWindow.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Keybinds
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F1 then
        toggleUI()
    elseif input.KeyCode == Enum.KeyCode.F2 then
        panicSystem()
    elseif input.KeyCode == Enum.KeyCode.F3 then
        BoostAllBtn.MouseButton1Click()
    end
end)

-- INITIALIZATION
spawn(function()
    while ScreenGui.Parent do
        updatePerformanceMetrics()
        
        TweenService:Create(StatusLight, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            BackgroundTransparency = 0.5
        }):Play()
        task.wait(1.5)
        TweenService:Create(StatusLight, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            BackgroundTransparency = 0
        }):Play()
        task.wait(1.5)
    end
end)

task.wait(1)
showNotification("✅ ACLXC HUB v1.0 LOADED")

print("=========================================")
print("🔮 ACLXC ULTIMATE HUB v1.0")
print("=========================================")
print("• 12+ Premium Modules")
print("• Modern Glassmorphism UI")
print("• Real-time Performance Stats")
print("=========================================")
print("Hotkeys: F1=UI, F2=Panic, F3=Enable All")
print("=========================================")
