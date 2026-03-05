--[[
FISH IT HUB - STEALTH MODE v3.0
- Full obfuscated
- No detectable patterns
- Anti-BAC-2223
]]

-- Enkripsi string sederhana
local function decrypt(str)
    local result = ""
    for i = 1, #str do
        result = result .. string.char(string.byte(str, i) - 1)
    end
    return result
end

-- Load services dengan aman
local gameService = game
local playersService = gameService:GetService(decrypt("!Qmbzfst"))
local localPlayer = playersService.LocalPlayer
local userInputService = gameService:GetService(decrypt("!VtfSfqvuTfsjdf"))
local virtualInputManager = gameService:GetService(decrypt("!Wjsuvbm!Jqvq!Nbobhfs"))
local coreGui = gameService:GetService(decrypt("!DpsfHvj")) or localPlayer:FindFirstChild(decrypt("!QmbzfsHvj"))

-- Variable random
local guiName = string.char(math.random(65,90)) .. string.char(math.random(65,90)) .. string.char(math.random(65,90)) .. math.random(1000,9999)
local featureStates = {}
local randomDelays = {}

-- GUI utama (tersembunyi)
local screenGui = Instance.new(decrypt("!TdsffoHvj"))
screenGui.Name = guiName
screenGui.ResetOnSpawn = false
screenGui.Parent = coreGui

-- Main frame kecil di pojok
local mainFrame = Instance.new(decrypt("!Gsfnf"))
mainFrame.Size = UDim2.new(0, 180, 0, 40)
mainFrame.Position = UDim2.new(1, -190, 0, 20)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BackgroundTransparency = 0.2
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new(decrypt("!VJ$psof s"))
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = mainFrame

-- Tombol utama
local mainButton = Instance.new(decrypt("!UfyuCvuupo"))
mainButton.Size = UDim2.new(1, 0, 1, 0)
mainButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainButton.BackgroundTransparency = 0.3
mainButton.Text = "⚡ FISH"
mainButton.TextColor3 = Color3.fromRGB(0, 200, 255)
mainButton.TextSize = 14
mainButton.Font = Enum.Font.SourceSansBold
mainButton.Parent = mainFrame

local buttonCorner = Instance.new(decrypt("!VJ$psof s"))
buttonCorner.CornerRadius = UDim.new(0, 8)
buttonCorner.Parent = mainButton

-- Menu dropdown (hidden)
local menuFrame = Instance.new(decrypt("!Gsfnf"))
menuFrame.Size = UDim2.new(0, 180, 0, 300)
menuFrame.Position = UDim2.new(0, 0, 1, 5)
menuFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
menuFrame.BackgroundTransparency = 0.2
menuFrame.Visible = false
menuFrame.Parent = mainFrame

local menuCorner = Instance.new(decrypt("!VJ$psof s"))
menuCorner.CornerRadius = UDim.new(0, 8)
menuCorner.Parent = menuFrame

-- Scroll area
local scrollFrame = Instance.new(decrypt("!TdspmmjohGsfnf"))
scrollFrame.Size = UDim2.new(1, -10, 1, -10)
scrollFrame.Position = UDim2.new(0, 5, 0, 5)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 2
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 200, 255)
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.Parent = menuFrame

local scrollLayout = Instance.new(decrypt("!VJ-JtuMbzpvu"))
scrollLayout.Padding = UDim.new(0, 3)
scrollLayout.Parent = scrollFrame

-- Toggle menu
mainButton.MouseButton1Click:Connect(function()
    menuFrame.Visible = not menuFrame.Visible
    mainButton.Text = menuFrame.Visible and "⚡ FISH ▼" or "⚡ FISH ▲"
end)

-- Fungsi membuat toggle button
local function createToggle(text, defaultState, callback)
    local btn = Instance.new(decrypt("!UfyuCvuupo"))
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = defaultState and Color3.fromRGB(0, 100, 50) or Color3.fromRGB(25, 25, 25)
    btn.BackgroundTransparency = 0.2
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    btn.TextSize = 13
    btn.Font = Enum.Font.SourceSans
    btn.Parent = scrollFrame
    
    local btnCorner = Instance.new(decrypt("!VJ$psof s"))
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = btn
    
    local state = defaultState
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 100, 50) or Color3.fromRGB(25, 25, 25)
        if callback then
            pcall(function() callback(state) end)
        end
    end)
    
    return btn
end

-- Fungsi membuat button biasa
local function createButton(text, color, callback)
    local btn = Instance.new(decrypt("!UfyuCvuupo"))
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = color or Color3.fromRGB(40, 40, 80)
    btn.BackgroundTransparency = 0.2
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 13
    btn.Font = Enum.Font.SourceSansBold
    btn.Parent = scrollFrame
    
    local btnCorner = Instance.new(decrypt("!VJ$psof s"))
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        task.wait(0.1)
        btn.BackgroundColor3 = color or Color3.fromRGB(40, 40, 80)
        if callback then
            pcall(callback)
        end
    end)
end

-- Fungsi membuat section header
local function createSection(text)
    local section = Instance.new(decrypt("!UfyuMbcfm"))
    section.Size = UDim2.new(1, 0, 0, 25)
    section.BackgroundTransparency = 1
    section.Text = "── " .. text .. " ──"
    section.TextColor3 = Color3.fromRGB(0, 200, 255)
    section.TextSize = 11
    section.Font = Enum.Font.SourceSansBold
    section.Parent = scrollFrame
end

-- Fungsi teleport dengan random delay
local function teleportTo(position)
    local character = localPlayer.Character
    if character and character:FindFirstChild(decrypt("!IvnbojeSpvuQbsu")) then
        local hrp = character:FindFirstChild(decrypt("!IvnbojeSpvuQbsu"))
        -- Random delay biar ga keliatan bot
        task.wait(math.random(10, 30) / 100)
        hrp.CFrame = CFrame.new(position)
    end
end

-- ===== MENU ITEMS =====
createSection("AUTO FISHING")

-- Auto Cast
createToggle("🎣 Auto Cast", false, function(state)
    featureStates.autoCast = state
end)

-- Auto Reel
createToggle("🎣 Auto Reel", false, function(state)
    featureStates.autoReel = state
end)

-- Instant Catch
createToggle("⚡ Instant Catch", false, function(state)
    featureStates.instantCatch = state
end)

-- Auto Sell
createToggle("💰 Auto Sell", false, function(state)
    featureStates.autoSell = state
end)

createSection("PLAYER")

-- Anti AFK
createToggle("💤 Anti AFK", false, function(state)
    featureStates.antiAfk = state
end)

-- No Fall Damage
createToggle("🛡️ No Fall", false, function(state)
    featureStates.noFall = state
end)

createSection("TELEPORT")

-- Teleport buttons
local teleportLocations = {
    {name = "🏝️ Fisherman Island", pos = Vector3.new(34, 9, 2803)},
    {name = "🏖️ Kohana Island", pos = Vector3.new(-643, 16, 615)},
    {name = "🌋 Kohana Volcano", pos = Vector3.new(-497, 22, 177)},
    {name = "🪸 Coral Reefs", pos = Vector3.new(-3186, 10, 2250)},
    {name = "🌌 Esoteric Depths", pos = Vector3.new(3193, -1302, 1420)},
    {name = "🌴 Tropical Grove", pos = Vector3.new(-2129, 53, 3741)},
    {name = "🌋 Crater Island", pos = Vector3.new(969, 7, 4872)},
    {name = "🌿 Ancient Jungle", pos = Vector3.new(1453, 7, -329)},
    {name = "🎄 Christmas Island", pos = Vector3.new(-500, 10, 3500)},
    {name = "💘 Heart Island", pos = Vector3.new(800, 10, -500)},
    {name = "🌪️ Weather Machine", pos = Vector3.new(-1519, 6, 1884)},
    {name = "🗿 Sissypus Statue", pos = Vector3.new(-3698, -135, -1026)},
    {name = "💎 Treasure Room", pos = Vector3.new(-3599, -266, -1572)}
}

for _, loc in ipairs(teleportLocations) do
    createButton(loc.name, Color3.fromRGB(50, 50, 100), function()
        teleportTo(loc.pos)
    end)
end

createSection("MUTATIONS")

local mutations = {
    {name = "✨ Galaxy", color = Color3.fromRGB(180, 0, 255)},
    {name = "💫 Corrupt", color = Color3.fromRGB(255, 0, 100)},
    {name = "🌙 Midnight", color = Color3.fromRGB(50, 0, 100)},
    {name = "💎 Gemstone", color = Color3.fromRGB(255, 100, 255)},
    {name = "☢️ Radioactive", color = Color3.fromRGB(0, 255, 0)},
    {name = "⚡ Lightning", color = Color3.fromRGB(255, 255, 0)},
    {name = "🌈 Holographic", color = Color3.fromRGB(100, 200, 255)},
    {name = "👑 Gold", color = Color3.fromRGB(255, 215, 0)},
    {name = "👻 Ghost", color = Color3.fromRGB(200, 200, 255)}
}

for _, mut in ipairs(mutations) do
    createButton(mut.name, mut.color, function()
        -- Set target mutation
        featureStates.targetMutation = mut.name
    end)
end

createSection("SETTINGS")

-- Close button
createButton("❌ Close GUI", Color3.fromRGB(150, 50, 50), function()
    screenGui:Destroy()
    ScriptEnabled = false
end)

-- ===== BACKGROUND PROCESSES =====

-- Auto Cast loop
task.spawn(function()
    while true do
        task.wait(math.random(30, 80) / 10)
        if featureStates.autoCast then
            pcall(function()
                local character = localPlayer.Character
                local tool = character and character:FindFirstChildOfClass(decrypt("!Uppm"))
                if tool and tool.Name:lower():find(decrypt("!spe")) then
                    -- Random click position
                    local x = math.random(100, 500)
                    local y = math.random(100, 500)
                    virtualInputManager:SendMouseButtonEvent(x, y, 0, true, gameService, 1)
                    task.wait(math.random(3, 8) / 100)
                    virtualInputManager:SendMouseButtonEvent(x, y, 0, false, gameService, 1)
                end
            end)
        end
    end
end)

-- Auto Reel loop
task.spawn(function()
    while true do
        task.wait(math.random(20, 50) / 10)
        if featureStates.autoReel then
            pcall(function()
                local playerGui = localPlayer:FindFirstChild(decrypt("!QmbzfsHvj"))
                if playerGui then
                    for _, descendant in pairs(playerGui:GetDescendants()) do
                        if descendant:IsA(decrypt("!UfyuCvuupo")) or descendant:IsA(decrypt("!JnbhfCvuupo")) then
                            local name = descendant.Name:lower()
                            if name:find(decrypt("!sffm")) or name:find(decrypt("!dbudi")) or name:find(decrypt("!sffm")) then
                                if descendant.Visible and descendant.Parent and descendant.Parent.Visible then
                                    local x = descendant.AbsolutePosition.X + descendant.AbsoluteSize.X / 2
                                    local y = descendant.AbsolutePosition.Y + descendant.AbsoluteSize.Y / 2
                                    virtualInputManager:SendMouseButtonEvent(x, y, 0, true, gameService, 1)
                                    task.wait(math.random(2, 5) / 100)
                                    virtualInputManager:SendMouseButtonEvent(x, y, 0, false, gameService, 1)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- Instant Catch (remote spoofing dengan delay random)
task.spawn(function()
    while true do
        task.wait(math.random(30, 70) / 10)
        if featureStates.instantCatch then
            pcall(function()
                local replicatedStorage = gameService:GetService(decrypt("!SfqmjdbufeTupsbhf"))
                local remotes = replicatedStorage:FindFirstChild(decrypt("!Sfnpuf t")) or replicatedStorage:FindFirstChild(decrypt("!Fwfout")) or replicatedStorage
                
                for _, remote in pairs(remotes:GetDescendants()) do
                    if remote:IsA(decrypt("!SfnpufFwfou")) then
                        local name = remote.Name:lower()
                        if name:find(decrypt("!dbudi")) or name:find(decrypt("!gfti")) or name:find(decrypt("!sfqmz")) then
                            -- Random result (Perfect or Great)
                            local result = math.random() > 0.3 and decrypt("!Qfsgfdu") or decrypt("!Hsfbu")
                            remote:FireServer(result, math.random(95, 100))
                            task.wait(math.random(10, 30) / 100)
                        end
                    end
                end
            end)
        end
    end
end)

-- Auto Sell loop
task.spawn(function()
    while true do
        task.wait(math.random(250, 350))
        if featureStates.autoSell then
            pcall(function()
                local playerGui = localPlayer:FindFirstChild(decrypt("!QmbzfsHvj"))
                if playerGui then
                    local merchant = playerGui:FindFirstChild(decrypt("!Nfsdibou"))
                    if merchant and merchant:FindFirstChild(decrypt("!Nbjo")) then
                        for _, btn in pairs(merchant.Main:GetDescendants()) do
                            if btn:IsA(decrypt("!UfyuCvuupo")) and btn.Text:lower():find(decrypt("!tfm m")) then
                                virtualInputManager:SendMouseButtonEvent(
                                    btn.AbsolutePosition.X + 5,
                                    btn.AbsolutePosition.Y + 5,
                                    0, true, gameService, 1
                                )
                                task.wait(0.05)
                                virtualInputManager:SendMouseButtonEvent(
                                    btn.AbsolutePosition.X + 5,
                                    btn.AbsolutePosition.Y + 5,
                                    0, false, gameService, 1
                                )
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- Anti AFK loop (dengan random key)
task.spawn(function()
    while true do
        task.wait(math.random(120, 240))
        if featureStates.antiAfk then
            pcall(function()
                local keys = {Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D}
                local key = keys[math.random(#keys)]
                virtualInputManager:SendKeyEvent(true, key, false, gameService)
                task.wait(math.random(5, 15) / 100)
                virtualInputManager:SendKeyEvent(false, key, false, gameService)
            end)
        end
    end
end)

-- No Fall Damage
gameService:GetService(decrypt("!SvoTfsjdf")).Heartbeat:Connect(function()
    if featureStates.noFall then
        pcall(function()
            local character = localPlayer.Character
            if character and character:FindFirstChild(decrypt("!Ivnboje")) then
                local humanoid = character:FindFirstChild(decrypt("!Ivnboje"))
                if humanoid then
                    humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                end
            end
        end)
    end
end)

-- Bersihkan jejak
getgenv()._G = nil
getgenv()._VERSION = nil
getgenv().script = nil

print("✅ FISH IT HUB - STEALTH MODE ACTIVATED")
print("📍 GUI di pojok kanan atas (klik FISH untuk membuka)")
