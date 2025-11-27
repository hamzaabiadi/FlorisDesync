local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local desyncActive = false
local character, hrp, humanoid

-- ===== DELTA-SAFE LOADING SCREEN =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlorisGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local loadFrame = Instance.new("Frame")
loadFrame.Size = UDim2.new(0, 300, 0, 160)
loadFrame.Position = UDim2.new(0.5, -150, 0.5, -80)
loadFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
loadFrame.BorderSizePixel = 0
loadFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = loadFrame

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 40, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 60, 255))
}
gradient.Parent = loadFrame

local title = Instance.new("TextLabel")
title.Text = "Floris Desync"
title.Size = UDim2.new(1,0,0,50)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBlack
title.TextSize = 30
title.Parent = loadFrame

local status = Instance.new("TextLabel")
status.Position = UDim2.new(0,0,0,60)
status.Size = UDim2.new(1,0,0,30)
status.BackgroundTransparency = 1
status.Text = "Loading chaos engine..."
status.TextColor3 = Color3.new(0.9,0.9,1)
status.Font = Enum.Font.Gotham
status.TextSize = 18
status.Parent = loadFrame

local bar = Instance.new("Frame")
bar.Position = UDim2.new(0,20,0,110)
bar.Size = UDim2.new(1,-40,0,12)
bar.BackgroundColor3 = Color3.fromRGB(40,40,50)
bar.BorderSizePixel = 0
bar.Parent = loadFrame
Instance.new("UICorner", bar).CornerRadius = UDim.new(0,6)

local fill = Instance.new("Frame")
fill.Size = UDim2.new(0,0,1,0)
fill.BackgroundColor3 = Color3.fromRGB(150, 80, 255)
fill.BorderSizePixel = 0
fill.Parent = bar
Instance.new("UICorner", fill).CornerRadius = UDim.new(0,6)

-- Safe tween (Delta compatible)
spawn(function()
    for i = 0, 1, 0.02 do
        fill.Size = UDim2.new(i,0,1,0)
        task.wait(0.06)
    end
    task.wait(0.5)
    loadFrame:TweenPosition(UDim2.new(0.5,-150,-0.5,-80), "Out", "Quad", 0.6, true)
    task.wait(0.7)
    loadFrame:Destroy()
end)

-- ===== TINY FLOATING ORB (Draggable) =====
task.wait(4.5) -- Wait for loading to finish

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0, 58, 0, 58)
toggle.Position = UDim2.new(0, 15, 0, 15)
toggle.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
toggle.Text = "FD"
toggle.TextColor3 = Color3.fromRGB(170, 100, 255)
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 22
toggle.Parent = screenGui

local tc = Instance.new("UICorner")
tc.CornerRadius = UDim.new(1, 0)
tc.Parent = toggle

local ts = Instance.new("UIStroke")
ts.Color = Color3.fromRGB(140, 80, 255)
ts.Thickness = 2.5
ts.Parent = toggle

-- Draggable (Delta safe)
local dragging = false
toggle.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
    end
end)
toggle.InputChanged:Connect(function(i)
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        toggle.Position = UDim2.new(0, i.Position.X - 29, 0, i.Position.Y - 29)
    end
end)
toggle.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- ===== PURE DESYNC (No remotes, no sounds, no crashes) =====
local function startDesync()
    desyncActive = true
    toggle.TextColor3 = Color3.fromRGB(255, 70, 70)
    spawn(function()
        while desyncActive do
            pcall(function()
                if not character or not character:FindFirstChild("HumanoidRootPart") then
                    character = player.Character or player.CharacterAdded:Wait()
                    hrp = character:WaitForChild("HumanoidRootPart")
                    humanoid = character:WaitForChild("Humanoid")
                end

                -- Insane client-side desync
                hrp.Velocity = Vector3.new(math.random(-300,300), math.random(400,1200), math.random(-300,300))
                hrp.RotVelocity = Vector3.new(math.random(-2500,2500), math.random(-2500,2500), math.random(-2500,2500))
                
                -- Network ownership flick (100% Delta safe)
                hrp:SetNetworkOwner(nil)
                task.wait()
                hrp:SetNetworkOwner(player)
                
                humanoid.PlatformStand = true
                task.wait()
                humanoid.PlatformStand = false
            end)
            task.wait(0.02)
        end
    end)
end

local function stopDesync()
    desyncActive = false
    toggle.TextColor3 = Color3.fromRGB(170, 100, 255)
    if humanoid then humanoid.PlatformStand = false end
end

-- Toggle
toggle.MouseButton1Click:Connect(function()
    desyncActive = not desyncActive
    if desyncActive then startDesync() else stopDesync() end
end)

player.Chatted:Connect(function(msg)
    if msg:lower() == ";desync" or msg:lower() == ";fd" then
        desyncActive = not desyncActive
        if desyncActive then startDesync() else stopDesync() end
    end
end)

-- Respawn handler
player  player.CharacterAdded:Connect(function(c)
    character = c
    hrp = c:WaitForChild("HumanoidRootPart")
    humanoid = c:WaitForChild("Humanoid")
end)

print("Floris Desync v2.1 Delta Edition loaded!")
print("Click the purple orb or type ;desync")
