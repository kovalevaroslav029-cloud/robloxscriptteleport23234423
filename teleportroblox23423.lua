local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local CloseBtn = Instance.new("TextButton")

local ContentFrame = Instance.new("Frame")
local UIList = Instance.new("UIListLayout")

local TextBox = Instance.new("TextBox")
local DropdownBtn = Instance.new("TextButton")
local DropdownFrame = Instance.new("ScrollingFrame")
local DropdownLayout = Instance.new("UIListLayout")
local LimitBox = Instance.new("TextBox")
local CounterLabel = Instance.new("TextLabel")
local ToggleBtn = Instance.new("TextButton")

ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -180)
MainFrame.Size = UDim2.new(0, 220, 0, 360)
MainFrame.Active = true
MainFrame.Draggable = true 

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "RMT Auto-Drop System"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

CloseBtn.Parent = MainFrame
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 18

ContentFrame.Parent = MainFrame
ContentFrame.Position = UDim2.new(0, 0, 0, 35)
ContentFrame.Size = UDim2.new(1, 0, 1, -35)
ContentFrame.BackgroundTransparency = 1

UIList.Parent = ContentFrame
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 8)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

TextBox.Parent = ContentFrame
TextBox.Size = UDim2.new(0.9, 0, 0, 25)
TextBox.PlaceholderText = "Type Username Manually"
TextBox.Text = ""
TextBox.LayoutOrder = 1

DropdownBtn.Parent = ContentFrame
DropdownBtn.Size = UDim2.new(0.9, 0, 0, 25)
DropdownBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
DropdownBtn.Text = "Select Player from List v"
DropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DropdownBtn.LayoutOrder = 2

DropdownFrame.Parent = ContentFrame
DropdownFrame.Size = UDim2.new(0.9, 0, 0, 80)
DropdownFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
DropdownFrame.Visible = false
DropdownFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
DropdownFrame.ScrollBarThickness = 6
DropdownFrame.LayoutOrder = 3

DropdownLayout.Parent = DropdownFrame
DropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder

LimitBox.Parent = ContentFrame
LimitBox.Size = UDim2.new(0.9, 0, 0, 25)
LimitBox.PlaceholderText = "Limit Respawns (e.g. 50)"
LimitBox.Text = ""
LimitBox.LayoutOrder = 4

CounterLabel.Parent = ContentFrame
CounterLabel.Size = UDim2.new(0.9, 0, 0, 20)
CounterLabel.Text = "Progress: 0 / 0"
CounterLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
CounterLabel.BackgroundTransparency = 1
CounterLabel.LayoutOrder = 5

ToggleBtn.Parent = ContentFrame
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 40)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ToggleBtn.Text = "OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.LayoutOrder = 6

local players = game:GetService("Players")
local runService = game:GetService("RunService")
local localPlayer = players.LocalPlayer
local isActive = false
local FLY_SPEED = 0.05 

local respawnCount = 0
local respawnLimit = 0
local hasCountedThisLife = false

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

local function updateDropdown()
    for _, child in ipairs(DropdownFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    local count = 0
    for _, p in ipairs(players:GetPlayers()) do
        if p ~= localPlayer then
            count = count + 1
            local pBtn = Instance.new("TextButton")
            pBtn.Parent = DropdownFrame
            pBtn.Size = UDim2.new(1, 0, 0, 20)
            pBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            pBtn.Text = p.Name
            pBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            
            pBtn.MouseButton1Click:Connect(function()
                TextBox.Text = p.Name
                DropdownFrame.Visible = false
            end)
        end
    end
    DropdownFrame.CanvasSize = UDim2.new(0, 0, 0, count * 20)
end

DropdownBtn.MouseButton1Click:Connect(function()
    DropdownFrame.Visible = not DropdownFrame.Visible
    if DropdownFrame.Visible then 
        updateDropdown() 
    end
end)

localPlayer.CharacterAdded:Connect(function(character)
    hasCountedThisLife = false
end)

local connection
connection = runService.Heartbeat:Connect(function()
    if not isActive then return end
    
    if respawnLimit > 0 and respawnCount >= respawnLimit then
        isActive = false
        ToggleBtn.Text = "OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        return
    end
    
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
            if not hasCountedThisLife then
                hasCountedThisLife = true
                respawnCount = respawnCount + 1
                CounterLabel.Text = "Progress: " .. tostring(respawnCount) .. " / " .. tostring(respawnLimit)
            end
            myHumanoid.Health = 0
            task.wait(1)
        end
    end
end)

ToggleBtn.MouseButton1Click:Connect(function()
    isActive = not isActive
    if isActive then
        respawnCount = 0
        respawnLimit = tonumber(LimitBox.Text) or 0
        CounterLabel.Text = "Progress: 0 / " .. tostring(respawnLimit)
        ToggleBtn.Text = "ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    else
        ToggleBtn.Text = "OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    isActive = false
    if connection then connection:Disconnect() end
    ScreenGui:Destroy()
end)
