-- Floris Desync v2.0 (Quantum-Free + Sexy GUI)
-- Tiny, clean, draggable UI | Pure client desync for Steal a Brainrot
-- Type ;desync or click the floating button to toggle

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local desyncActive = false
local character, hrp, humanoid

-- === COOL LOADING GUI ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlorisDesyncGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local loadFrame = Instance.new("Frame")
loadFrame.Size = UDim2.new(0, 320, 0, 180)
loadFrame.Position = UDim2.new(0.5, -160, 0.5, -90)
loadFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
loadFrame.BorderSizePixel = 0
loadFrame.Parent = screenGui

local corner = Instance.new("UICorner", loadFrame)
corner.CornerRadius = UDim.new(0, 16)

local stroke = Instance.new("UIStroke", loadFrame)
stroke.Color = Color3.fromRGB(130, 90, 255)
stroke.Thickness = 2

local title = Instance.new("TextLabel", loadFrame)
title.Text = "Floris Desync"
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(200, 160, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 28

local status = Instance.new("TextLabel", loadFrame)
status.Position = UDim2.new(0, 0, 0, 60)
status.Size = UDim2.new(1, 0, 0, 30)
status.BackgroundTransparency = 1
status.Text = "Initializing desync engine..."
status.TextColor3 = Color3.fromRGB(180, 180, 255)
status.Font = Enum.Font.Gotham
status.TextSize = 18
status.Parent = loadFrame

local barBG = Instance.new("Frame", loadFrame)
barBG.Position = UDim2.new(0, 20, 0, 110)
barBG.Size = UDim2.new(1, -40, 0, 16)
barBG.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
barBG.BorderSizePixel = 0
local barCorner = Instance.new("UICorner", barBG)
barCorner.CornerRadius = UDim.new(0, 8)

local bar = Instance.new("Frame", barBG)
bar.Size = UDim2.new(0, 0, 1, 0)
bar.BackgroundColor3 = Color3.fromRGB(130, 90, 255)
bar.BorderSizePixel = 0
local barFillCorner = Instance.new("UICorner", bar)
barFillCorner.CornerRadius = UDim.new(0, 8)

-- Loading animation
local loadTween = TweenService:Create(bar, TweenInfo.new(4, Enum.EasingStyle.Linear), {Size = UDim2.new(1, 0, 1, 0)})
loadTween:Play()

-- Tiny sound for vibe
local loadSound = Instance.new("Sound")
loadSound.SoundId = "rbxassetid://9081037256" -- short glitchy whoosh
loadSound.Volume = 0.4
loadSound.Parent = screenGui
loadSound:Play()

wait(4.2)
loadSound:Destroy()
loadFrame:Destroy()

-- === MINI TOGGLE BUTTON (after loading) ===
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 60, 0, 60)
toggleBtn.Position = UDim2.new(0, 20, 0, 20)
toggleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
toggleBtn.Text = "FD"
toggleBtn.TextColor3 = Color3.fromRGB(180, 120, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 20
toggleBtn.Parent = screenGui

local btnCorner = Instance.new("UICorner", toggleBtn)
btnCorner.CornerRadius = UDim.new(1, 0) -- perfect circle
local btnStroke = Instance.new("UIStroke", toggleBtn)
btnStroke.Color = Color3.fromRGB(130, 90, 255)
btnStroke.Thickness = 2

-- Draggable
local dragging = false
local dragInput, mousePos, framePos
toggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        mousePos = input.Position
        framePos = toggleBtn.Position
    end
end)
toggleBtn.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - mousePos
        toggleBtn.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
    end
end)
toggleBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- === DESYNC CORE (Quantum-Free) ===
local function startDesync()
    desyncActive = true
    toggleBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
    
    spawn(function()
        while desyncActive do
            if not character or not character:FindFirstChild("HumanoidRootPart") then
                character = player.Character or player.CharacterAdded:Wait()
                hrp = character:WaitForChild("HumanoidRootPart")
                humanoid = character:WaitForChild("Humanoid")
            end

            -- Pure client-side desync (no remotes = stealthy)
            local fakePos = Vector3.new(math.random(-200,200), math.random(50,500), math.random(-200,200))
            hrp.Velocity = fakePos * 25
            hrp.RotVelocity = Vector3.new(math.random(-2000,2000), math.random(-2000,2000), math.random(-2000,2000))
            
            -- Flicker network ownership
            pcall(function()
                hrp:SetNetworkOwner(nil)
                wait()
                hrp:SetNetworkOwner(player)
            end)

            humanoid.PlatformStand = true
            wait()
            humanoid.PlatformStand = false

            RunService.Heartbeat:Wait()
            wait(0.02)
        end
    end)
end

local function stopDesync()
    desyncActive = false
    toggleBtn.TextColor3 = Color3.fromRGB(180, 120, 255)
    if humanoid then humanoid.PlatformStand = false end
end

-- Toggle on click or chat command
toggleBtn.MouseButton1Click:Connect(function()
    desyncActive = not desyncActive
    if desyncActive then startDesync() else stopDesync() end
end)

player.Chatted:Connect(function(msg)
    if msg:lower() == ";desync" then
        desyncActive = not desyncActive
        if desyncActive then startDesync() else stopDesync() end
    end
end)

-- Character respawn handler
player.CharacterAdded:Connect(function(char)
    character = char
    hrp = char:WaitForChild("HumanoidRootPart")
    humanoid = char:WaitForChild("Humanoid")
end)

print("Floris Desync v2.0 loaded – Click the purple circle or type ;desync")
Initial release
