--// GK REACH FIXED - Based on Original Script
--// R6/R15 Compatible + Enhanced GK Detection

--// Services
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

--// Variables
local reachSize = 4
local isActive = true
local visualVisible = true
local currentColor = Color3.fromRGB(255, 255, 0)

--// GUI (Original Style - Improved)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GK_Reach_Fixed"
ScreenGui.Parent = game:GetService("CoreGui") -- Use CoreGui instead of PlayerGui for better persistence
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main Frame (Draggable)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Size = UDim2.new(0, 220, 0, 140)
MainFrame.Position = UDim2.new(0.5, -110, 0.8, -70)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderColor3 = currentColor
MainFrame.BorderSizePixel = 2
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Corner radius
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = MainFrame

-- Title
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 25)
TitleLabel.Position = UDim2.new(0, 0, 0, 5)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "GK REACH"
TitleLabel.TextColor3 = currentColor
TitleLabel.TextSize = 18
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Parent = MainFrame

-- Value Display
local ValueLabel = Instance.new("TextLabel")
ValueLabel.Name = "ValueLabel"
ValueLabel.Size = UDim2.new(0, 80, 0, 50)
ValueLabel.Position = UDim2.new(0.5, -40, 0.5, -15)
ValueLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ValueLabel.Text = tostring(reachSize)
ValueLabel.TextColor3 = Color3.new(1, 1, 1)
ValueLabel.TextSize = 28
ValueLabel.Font = Enum.Font.GothamBlack
ValueLabel.Parent = MainFrame

local valueCorner = Instance.new("UICorner")
valueCorner.CornerRadius = UDim.new(0, 6)
valueCorner.Parent = ValueLabel

-- Button Creator
local function CreateBtn(text, pos, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 45, 0, 45)
    btn.Position = pos
    btn.BackgroundColor3 = color or Color3.fromRGB(255, 50, 50)
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 24
    btn.Font = Enum.Font.GothamBold
    btn.Parent = MainFrame
    btn.AutoButtonColor = false

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(1, 0)
    btnCorner.Parent = btn

    -- Hover effects
    btn.MouseEnter:Connect(function()
        game:GetService("TweenService"):Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 255, 50)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        game:GetService("TweenService"):Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = color or Color3.fromRGB(255, 50, 50)}):Play()
    end)

    return btn
end

local MinusBtn = CreateBtn("−", UDim2.new(0.05, 0, 0.5, -10), Color3.fromRGB(200, 50, 50))
local PlusBtn = CreateBtn("+", UDim2.new(0.75, 0, 0.5, -10), Color3.fromRGB(50, 200, 50))

-- Visual Toggle Button
local VisualBtn = Instance.new("TextButton")
VisualBtn.Size = UDim2.new(0, 30, 0, 30)
VisualBtn.Position = UDim2.new(1, -35, 0, 5)
VisualBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
VisualBtn.Text = "👁"
VisualBtn.TextColor3 = Color3.new(1, 1, 1)
VisualBtn.TextSize = 14
VisualBtn.Parent = MainFrame

local visualCorner = Instance.new("UICorner")
visualCorner.CornerRadius = UDim.new(0, 6)
visualCorner.Parent = VisualBtn

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Position = UDim2.new(0, 0, 1, -25)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "● ACTIVE"
StatusLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.Parent = MainFrame

--// Visual Cube (FIXED)
local VisualPart = Instance.new("Part")
VisualPart.Name = "GK_VisualCube"
VisualPart.Transparency = 0.7
VisualPart.CanCollide = false
VisualPart.Anchored = true
VisualPart.Material = Enum.Material.Neon
VisualPart.Color = currentColor
VisualPart.Size = Vector3.new(reachSize, reachSize, reachSize)
VisualPart.Parent = Workspace

local SelectionBox = Instance.new("SelectionBox")
SelectionBox.Name = "Outline"
SelectionBox.Adornee = VisualPart
SelectionBox.Color3 = currentColor
SelectionBox.LineThickness = 0.08
SelectionBox.Parent = VisualPart

--// FIXED GK REACH LOGIC
local function GetCharacterRoot(char)
    -- Try R15 first, then R6
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
end

local function FindBall()
    -- Search for ball in workspace
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = obj.Name:lower()
            -- Common ball names
            if name:match("ball") or name:match("soccer") or name:match("football") or 
               name:match("pelota") or name:match("bola") or obj:FindFirstChild("Ball") then
                return obj
            end
        end
    end
    return nil
end

--// Main Loop (FIXED)
RunService.RenderStepped:Connect(function()
    if not isActive then
        VisualPart.Transparency = 1
        SelectionBox.Transparency = 1
        return
    end

    local char = LocalPlayer.Character
    if not char then return end

    local root = GetCharacterRoot(char)
    if not root then return end

    -- Update visual cube
    VisualPart.Size = Vector3.new(reachSize, reachSize, reachSize)
    VisualPart.CFrame = root.CFrame
    VisualPart.Transparency = visualVisible and 0.7 or 1
    SelectionBox.Transparency = visualVisible and 0 or 1

    -- GK REACH LOGIC (Fixed)
    local overlap = OverlapParams.new()
    overlap.FilterDescendantsInstances = {char, VisualPart}
    overlap.FilterType = Enum.RaycastFilterType.Exclude
    overlap.MaxParts = 100

    local partsInRange = Workspace:GetPartBoundsInBox(VisualPart.CFrame, VisualPart.Size, overlap)

    for _, obj in pairs(partsInRange) do
        if obj:IsA("BasePart") and not obj.Anchored then
            -- Check if it's a ball
            local objName = obj.Name:lower()
            local isBall = objName:match("ball") or objName:match("soccer") or objName:match("football")

            -- Check parent model
            local parentModel = obj:FindFirstAncestorOfClass("Model")
            local isPlayer = false
            if parentModel then
                isPlayer = parentModel:FindFirstChildOfClass("Humanoid") ~= nil
            end

            -- Fire touch for BOTH ball and players (GK needs both)
            if isBall or isPlayer then
                -- Use root part for touch (works for both R6 and R15)
                pcall(function()
                    firetouchinterest(obj, root, 0)
                    firetouchinterest(obj, root, 1)
                end)
            end
        end
    end

    -- Also try to find and track ball specifically
    local ball = FindBall()
    if ball then
        local dist = (ball.Position - root.Position).Magnitude
        if dist <= reachSize * 2 then -- Within extended range
            pcall(function()
                firetouchinterest(ball, root, 0)
                firetouchinterest(ball, root, 1)
            end)
        end
    end
end)

--// Button Functions
PlusBtn.MouseButton1Click:Connect(function()
    reachSize = reachSize + 1
    ValueLabel.Text = tostring(reachSize)
    -- Visual feedback
    game:GetService("TweenService"):Create(ValueLabel, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(50, 255, 50)}):Play()
    wait(0.1)
    game:GetService("TweenService"):Create(ValueLabel, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
end)

MinusBtn.MouseButton1Click:Connect(function()
    if reachSize > 1 then
        reachSize = reachSize - 1
        ValueLabel.Text = tostring(reachSize)
        game:GetService("TweenService"):Create(ValueLabel, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(255, 50, 50)}):Play()
        wait(0.1)
        game:GetService("TweenService"):Create(ValueLabel, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
    end
end)

VisualBtn.MouseButton1Click:Connect(function()
    visualVisible = not visualVisible
    VisualBtn.Text = visualVisible and "👁" or "👁‍🗨"
    VisualBtn.BackgroundColor3 = visualVisible and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(50, 50, 50)
end)

-- Dragging visual feedback
MainFrame.DragBegin:Connect(function()
    MainFrame.BorderColor3 = Color3.fromRGB(50, 255, 50)
end)

MainFrame.DragStopped:Connect(function()
    MainFrame.BorderColor3 = currentColor
end)

print("✅ GK Reach Fixed Loaded!")
print("🔧 Fixes: R6/R15 Compatible | Ball Detection | Visual Toggle")
