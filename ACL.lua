-- ACL FISH UI (LEGAL VERSION)
-- By Request

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local player = Players.LocalPlayer

-- Hapus kalau sudah ada
if player.PlayerGui:FindFirstChild("ACL_UI") then
    player.PlayerGui.ACL_UI:Destroy()
end

-- GUI
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "ACL_UI"

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 300, 0, 200)
main.Position = UDim2.new(0.5, -150, 0.6, 0)
main.BackgroundColor3 = Color3.fromRGB(18,18,25)
main.Active = true
main.Draggable = true

Instance.new("UICorner", main).CornerRadius = UDim.new(0,16)

-- Title
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,40)
title.BackgroundTransparency = 1
title.Text = "🎣 ACL FISH PANEL"
title.Font = Enum.Font.GothamBlack
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(0,255,200)

-- Status
local status = Instance.new("TextLabel", main)
status.Size = UDim2.new(1,0,0,30)
status.Position = UDim2.new(0,0,0.25,0)
status.BackgroundTransparency = 1
status.Text = "Status: Idle"
status.Font = Enum.Font.Gotham
status.TextSize = 14
status.TextColor3 = Color3.fromRGB(255,255,255)

-- SOUND
local sound = Instance.new("Sound", main)
sound.SoundId = "rbxassetid://9118823103" -- efek klik generic
sound.Volume = 1

-- FAKE NOTIF FUNCTION
local function fakeNotif(text)
    status.Text = text
    sound:Play()
    task.wait(1.5)
    status.Text = "Status: Idle"
end

-- Pull Button
local pullBtn = Instance.new("TextButton", main)
pullBtn.Size = UDim2.new(0.8,0,0,35)
pullBtn.Position = UDim2.new(0.1,0,0.55,0)
pullBtn.BackgroundColor3 = Color3.fromRGB(0,200,150)
pullBtn.Text = "START PULL"
pullBtn.Font = Enum.Font.GothamBold
pullBtn.TextColor3 = Color3.new(1,1,1)

Instance.new("UICorner", pullBtn).CornerRadius = UDim.new(0,12)

pullBtn.MouseButton1Click:Connect(function()
    fakeNotif("🎣 Pulling...")
    task.wait(0.5)
    
    local random = math.random(1,3)
    
    if random == 1 then
        fakeNotif("✨ PERFECT!")
    elseif random == 2 then
        fakeNotif("💎 SECRET FISH!")
    else
        fakeNotif("⚡ GOOD CATCH!")
    end
end)

-- TELEPORT (LEGAL VIA PLACE ID)
local tpBtn = Instance.new("TextButton", main)
tpBtn.Size = UDim2.new(0.8,0,0,35)
tpBtn.Position = UDim2.new(0.1,0,0.75,0)
tpBtn.BackgroundColor3 = Color3.fromRGB(100,120,255)
tpBtn.Text = "TELEPORT (Your Place)"
tpBtn.Font = Enum.Font.GothamBold
tpBtn.TextColor3 = Color3.new(1,1,1)

Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0,12)

tpBtn.MouseButton1Click:Connect(function()
    -- Ganti dengan PlaceId game kamu sendiri
    local placeId = game.PlaceId
    TeleportService:Teleport(placeId, player)
end)
