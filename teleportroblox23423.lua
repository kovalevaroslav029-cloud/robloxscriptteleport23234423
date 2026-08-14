local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local TextBox = Instance.new("TextBox")
local ToggleBtn = Instance.new("TextButton")

ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -75)
MainFrame.Size = UDim2.new(0, 200, 0, 150)
MainFrame.Active = true
MainFrame.Draggable = true 

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "Smooth Follow & Reset"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

TextBox.Parent = MainFrame
TextBox.Position = UDim2.new(0.05, 0, 0.3, 0)
TextBox.Size = UDim2.new(0.9, 0, 0, 30)
TextBox.PlaceholderText = "Target name (Partial)"
TextBox.Text = ""

ToggleBtn.Parent = MainFrame
ToggleBtn.Position = UDim2.new(0.05, 0, 0.6, 0)
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 40)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ToggleBtn.Text = "OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

local players = game:GetService("Players")
local runService = game:GetService("RunService")
local localPlayer = players.LocalPlayer
local isActive = false

local FLY_SPEED = 0.05 

local function findTarget()
    local text = TextBox.Text:lower()
    if text == "" then return nil end
    for _, p in ipairs(players:GetPlayers()) do
        if p ~= localPlayer and p.Name:lower():sub(1, #text) == text then
            return p
        end
    end
    return nil
end

runService.Heartbeat:Connect(function()
    if not isActive then return end
    
    local target = findTarget()
    if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then return end
    if not localPlayer.Character or not localPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local myRoot = localPlayer.Character.HumanoidRootPart
    local targetRoot = target.Character.HumanoidRootPart
    local myHumanoid = localPlayer.Character:FindFirstChild("Humanoid")
    
    if myHumanoid and myHumanoid.Health > 0 then
        local distance = (myRoot.Position - targetRoot.Position).Magnitude
        
        if distance > 4 then
            myRoot.CFrame = myRoot.CFrame:Lerp(targetRoot.CFrame * CFrame.new(0, 2, 3), FLY_SPEED)
        else
            myHumanoid.Health = 0
            task.wait(1) 
        end
    end
end)

ToggleBtn.MouseButton1Click:Connect(function()
    isActive = not isActive
    if isActive then
        ToggleBtn.Text = "ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    else
        ToggleBtn.Text = "OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)
