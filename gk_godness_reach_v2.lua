--// GK GODNESS REACH EXTENDER
--// Enhanced Edition with Modern UI
--// YouTube x Spotify Design Language

--// Services
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

--// Variables
local reachSize = 4
local isActive = true
local isMinimized = false
local isVisible = true
local currentColor = Color3.fromRGB(255, 255, 0)
local rainbowMode = false
local rainbowSpeed = 0.5
local hue = 0

--// UI Configuration (YouTube x Spotify Theme)
local UI_CONFIG = {
    Colors = {
        Background = Color3.fromRGB(15, 15, 15),
        Surface = Color3.fromRGB(28, 28, 28),
        Primary = Color3.fromRGB(255, 0, 85),    -- YouTube Red
        Secondary = Color3.fromRGB(30, 215, 96), -- Spotify Green
        Accent = Color3.fromRGB(255, 203, 0),    -- YouTube Gold
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(170, 170, 170),
        Dark = Color3.fromRGB(10, 10, 10)
    },
    Animations = {
        IntroDuration = 2,
        Transition = 0.35,
        Fast = 0.15,
        Bounce = 0.5
    }
}

--// Utility Functions
local function Tween(instance, properties, duration, style, direction)
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(
            duration or UI_CONFIG.Animations.Transition,
            style or Enum.EasingStyle.Quart,
            direction or Enum.EasingDirection.Out
        ),
        properties
    )
    tween:Play()
    return tween
end

local function Corner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or UDim.new(0, 10)
    corner.Parent = parent
    return corner
end

local function Shadow(parent, intensity)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = intensity or 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.Position = UDim2.new(0, -15, 0, -15)
    shadow.ZIndex = -1
    shadow.Parent = parent
    return shadow
end

--// Intro Screen
local IntroGui = Instance.new("ScreenGui")
IntroGui.Name = "GK_Intro"
IntroGui.Parent = CoreGui
IntroGui.DisplayOrder = 10000

local IntroFrame = Instance.new("Frame")
IntroFrame.Size = UDim2.new(1, 0, 1, 0)
IntroFrame.BackgroundColor3 = UI_CONFIG.Colors.Dark
IntroFrame.Parent = IntroGui

-- Animated Gradient Background
local IntroGradient = Instance.new("UIGradient")
IntroGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, UI_CONFIG.Colors.Primary),
    ColorSequenceKeypoint.new(0.5, UI_CONFIG.Colors.Secondary),
    ColorSequenceKeypoint.new(1, UI_CONFIG.Colors.Primary)
})
IntroGradient.Rotation = 0
IntroGradient.Parent = IntroFrame

-- Continuous gradient rotation
spawn(function()
    while IntroGui.Parent do
        Tween(IntroGradient, {Rotation = IntroGradient.Rotation + 180}, 3, Enum.EasingStyle.Linear)
        wait(3)
    end
end)

-- Logo Container
local LogoContainer = Instance.new("Frame")
LogoContainer.Size = UDim2.new(0, 400, 0, 300)
LogoContainer.Position = UDim2.new(0.5, -200, 0.5, -150)
LogoContainer.BackgroundTransparency = 1
LogoContainer.Parent = IntroFrame

-- Main Title with Glow Effect
local TitleGlow = Instance.new("TextLabel")
TitleGlow.Size = UDim2.new(1, 0, 0, 80)
TitleGlow.Position = UDim2.new(0, 0, 0.3, 0)
TitleGlow.BackgroundTransparency = 1
TitleGlow.Text = "GK GODNESS"
TitleGlow.Font = Enum.Font.GothamBlack
TitleGlow.TextSize = 72
TitleGlow.TextColor3 = UI_CONFIG.Colors.Primary
TitleGlow.TextTransparency = 0.7
TitleGlow.Parent = LogoContainer

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 80)
Title.Position = UDim2.new(0, 0, 0.3, 0)
Title.BackgroundTransparency = 1
Title.Text = "GK GODNESS"
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 70
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Parent = LogoContainer

-- Subtitle
local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, 0, 0, 40)
Subtitle.Position = UDim2.new(0, 0, 0.55, 0)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "REACH EXTENDER"
Subtitle.Font = Enum.Font.GothamBold
Subtitle.TextSize = 32
Subtitle.TextColor3 = UI_CONFIG.Colors.Secondary
Subtitle.Parent = LogoContainer

-- Loading Bar Container
local LoadingContainer = Instance.new("Frame")
LoadingContainer.Size = UDim2.new(0, 300, 0, 4)
LoadingContainer.Position = UDim2.new(0.5, -150, 0.75, 0)
LoadingContainer.BackgroundColor3 = UI_CONFIG.Colors.Surface
LoadingContainer.BorderSizePixel = 0
LoadingContainer.Parent = LogoContainer
Corner(LoadingContainer, UDim.new(1, 0))

local LoadingBar = Instance.new("Frame")
LoadingBar.Size = UDim2.new(0, 0, 1, 0)
LoadingBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
LoadingBar.BorderSizePixel = 0
LoadingBar.Parent = LoadingContainer
Corner(LoadingBar, UDim.new(1, 0))

-- Loading Text
local LoadingText = Instance.new("TextLabel")
LoadingText.Size = UDim2.new(1, 0, 0, 20)
LoadingText.Position = UDim2.new(0, 0, 0.8, 0)
LoadingText.BackgroundTransparency = 1
LoadingText.Text = "INITIALIZING..."
LoadingText.Font = Enum.Font.GothamSemibold
LoadingText.TextSize = 14
LoadingText.TextColor3 = UI_CONFIG.Colors.TextDim
LoadingText.Parent = LogoContainer

--// Main GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GK_Godness_Reach"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.Enabled = false

-- Main Container
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainContainer"
MainFrame.Size = UDim2.new(0, 340, 0, 480)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -240)
MainFrame.BackgroundColor3 = UI_CONFIG.Colors.Background
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
Corner(MainFrame, UDim.new(0, 16))
Shadow(MainFrame, 0.4)

-- Glassmorphism Overlay
local GlassOverlay = Instance.new("Frame")
GlassOverlay.Size = UDim2.new(1, 0, 1, 0)
GlassOverlay.BackgroundColor3 = UI_CONFIG.Colors.Surface
GlassOverlay.BackgroundTransparency = 0.7
GlassOverlay.BorderSizePixel = 0
GlassOverlay.Parent = MainFrame
Corner(GlassOverlay, UDim.new(0, 16))

-- Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 65)
Header.BackgroundColor3 = UI_CONFIG.Colors.Surface
Header.BorderSizePixel = 0
Header.Parent = MainFrame
Corner(Header, UDim.new(0, 16))

local HeaderFix = Instance.new("Frame")
HeaderFix.Size = UDim2.new(1, 0, 0, 20)
HeaderFix.Position = UDim2.new(0, 0, 1, -20)
HeaderFix.BackgroundColor3 = UI_CONFIG.Colors.Surface
HeaderFix.BorderSizePixel = 0
HeaderFix.Parent = Header

-- Status Indicator
local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 10, 0, 10)
StatusDot.Position = UDim2.new(0, 15, 0.5, -5)
StatusDot.BackgroundColor3 = UI_CONFIG.Colors.Secondary
StatusDot.Parent = Header
Corner(StatusDot, UDim.new(1, 0))

-- Pulse animation for status
spawn(function()
    while ScreenGui.Parent do
        Tween(StatusDot, {Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 13, 0.5, -7)}, 0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        wait(0.8)
        Tween(StatusDot, {Size = UDim2.new(0, 10, 0, 10), Position = UDim2.new(0, 15, 0.5, -5)}, 0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        wait(0.8)
    end
end)

-- Title
local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Size = UDim2.new(0.5, 0, 1, 0)
HeaderTitle.Position = UDim2.new(0, 35, 0, 0)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "GK GODNESS"
HeaderTitle.Font = Enum.Font.GothamBold
HeaderTitle.TextSize = 20
HeaderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.Parent = Header

-- Control Buttons
local function CreateControlBtn(symbol, color, pos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 32, 0, 32)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.Text = symbol
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Parent = Header
    btn.AutoButtonColor = false
    Corner(btn, UDim.new(1, 0))

    btn.MouseEnter:Connect(function()
        Tween(btn, {BackgroundColor3 = color:Lerp(Color3.fromRGB(255,255,255), 0.2)}, 0.2)
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn, {BackgroundColor3 = color}, 0.2)
    end)

    return btn
end

local MinimizeBtn = CreateControlBtn("−", UI_CONFIG.Colors.Primary, UDim2.new(1, -80, 0.5, -16))
local CloseBtn = CreateControlBtn("×", Color3.fromRGB(255, 60, 60), UDim2.new(1, -42, 0.5, -16))

-- Content Container
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -24, 1, -85)
Content.Position = UDim2.new(0, 12, 0, 75)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

--// REACH SECTION
local ReachSection = Instance.new("Frame")
ReachSection.Name = "ReachSection"
ReachSection.Size = UDim2.new(1, 0, 0, 130)
ReachSection.BackgroundColor3 = UI_CONFIG.Colors.Surface
ReachSection.Parent = Content
Corner(ReachSection, UDim.new(0, 12))

local ReachLabel = Instance.new("TextLabel")
ReachLabel.Size = UDim2.new(1, -20, 0, 25)
ReachLabel.Position = UDim2.new(0, 10, 0, 10)
ReachLabel.BackgroundTransparency = 1
ReachLabel.Text = "⚡ REACH SIZE"
ReachLabel.Font = Enum.Font.GothamBold
ReachLabel.TextSize = 14
ReachLabel.TextColor3 = UI_CONFIG.Colors.TextDim
ReachLabel.TextXAlignment = Enum.TextXAlignment.Left
ReachLabel.Parent = ReachSection

-- Value Display
local ValueBox = Instance.new("Frame")
ValueBox.Size = UDim2.new(0, 90, 0, 55)
ValueBox.Position = UDim2.new(0.5, -45, 0.5, -5)
ValueBox.BackgroundColor3 = UI_CONFIG.Colors.Background
ValueBox.Parent = ReachSection
Corner(ValueBox, UDim.new(0, 10))

local ValueText = Instance.new("TextLabel")
ValueText.Size = UDim2.new(1, 0, 1, 0)
ValueText.BackgroundTransparency = 1
ValueText.Text = tostring(reachSize)
ValueText.Font = Enum.Font.GothamBlack
ValueText.TextSize = 32
ValueText.TextColor3 = UI_CONFIG.Colors.Primary
ValueText.Parent = ValueBox

-- Create Modern Button Function
local function CreateActionBtn(text, pos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 55, 0, 55)
    btn.Position = pos
    btn.BackgroundColor3 = UI_CONFIG.Colors.Primary
    btn.Text = text
    btn.Font = Enum.Font.GothamBlack
    btn.TextSize = 28
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Parent = ReachSection
    btn.AutoButtonColor = false
    Corner(btn, UDim.new(0, 12))

    -- Effects
    btn.MouseEnter:Connect(function()
        Tween(btn, {BackgroundColor3 = UI_CONFIG.Colors.Secondary, Size = UDim2.new(0, 58, 0, 58)}, 0.2)
    end)

    btn.MouseLeave:Connect(function()
        Tween(btn, {BackgroundColor3 = UI_CONFIG.Colors.Primary, Size = UDim2.new(0, 55, 0, 55)}, 0.2)
    end)

    btn.MouseButton1Down:Connect(function()
        Tween(btn, {Size = UDim2.new(0, 50, 0, 50)}, 0.1)
    end)

    btn.MouseButton1Up:Connect(function()
        Tween(btn, {Size = UDim2.new(0, 58, 0, 58)}, 0.15, Enum.EasingStyle.Back)
    end)

    return btn
end

local DecreaseBtn = CreateActionBtn("−", UDim2.new(0, 15, 0.5, -5))
local IncreaseBtn = CreateActionBtn("+", UDim2.new(1, -70, 0.5, -5))

--// COLOR SECTION
local ColorSection = Instance.new("Frame")
ColorSection.Name = "ColorSection"
ColorSection.Size = UDim2.new(1, 0, 0, 160)
ColorSection.Position = UDim2.new(0, 0, 0, 145)
ColorSection.BackgroundColor3 = UI_CONFIG.Colors.Surface
ColorSection.Parent = Content
Corner(ColorSection, UDim.new(0, 12))

local ColorLabel = Instance.new("TextLabel")
ColorLabel.Size = UDim2.new(1, -20, 0, 25)
ColorLabel.Position = UDim2.new(0, 10, 0, 10)
ColorLabel.BackgroundTransparency = 1
ColorLabel.Text = "🎨 VISUAL COLOR"
ColorLabel.Font = Enum.Font.GothamBold
ColorLabel.TextSize = 14
ColorLabel.TextColor3 = UI_CONFIG.Colors.TextDim
ColorLabel.TextXAlignment = Enum.TextXAlignment.Left
ColorLabel.Parent = ColorSection

-- Color Preview
local ColorPreview = Instance.new("Frame")
ColorPreview.Size = UDim2.new(0, 50, 0, 50)
ColorPreview.Position = UDim2.new(1, -60, 0, 10)
ColorPreview.BackgroundColor3 = currentColor
ColorPreview.Parent = ColorSection
Corner(ColorPreview, UDim.new(0, 8))

-- RGB Controls
local function CreateColorSlider(letter, color, yPos, defaultValue)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 35)
    container.Position = UDim2.new(0, 10, 0, yPos)
    container.BackgroundTransparency = 1
    container.Parent = ColorSection

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 25, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = letter
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextColor3 = color
    label.Parent = container

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -35, 0, 8)
    track.Position = UDim2.new(0, 30, 0.5, -4)
    track.BackgroundColor3 = UI_CONFIG.Colors.Background
    track.BorderSizePixel = 0
    track.Parent = container
    Corner(track, UDim.new(1, 0))

    local fill = Instance.new("Frame")
    fill.Name = letter.."Fill"
    fill.Size = UDim2.new(defaultValue/255, 0, 1, 0)
    fill.BackgroundColor3 = color
    fill.BorderSizePixel = 0
    fill.Parent = track
    Corner(fill, UDim.new(1, 0))

    return fill
end

local R_Fill = CreateColorSlider("R", Color3.fromRGB(255, 60, 60), 45, 255)
local G_Fill = CreateColorSlider("G", Color3.fromRGB(60, 255, 60), 80, 255)
local B_Fill = CreateColorSlider("B", Color3.fromRGB(60, 60, 255), 115, 0)

--// RAINBOW TOGGLE
local RainbowBtn = Instance.new("TextButton")
RainbowBtn.Size = UDim2.new(1, 0, 0, 45)
RainbowBtn.Position = UDim2.new(0, 0, 0, 315)
RainbowBtn.BackgroundColor3 = UI_CONFIG.Colors.Surface
RainbowBtn.Text = "🌈 RAINBOW MODE: OFF"
RainbowBtn.Font = Enum.Font.GothamBold
RainbowBtn.TextSize = 14
RainbowBtn.TextColor3 = UI_CONFIG.Colors.Text
RainbowBtn.Parent = Content
RainbowBtn.AutoButtonColor = false
Corner(RainbowBtn, UDim.new(0, 10))

RainbowBtn.MouseEnter:Connect(function()
    if not rainbowMode then
        Tween(RainbowBtn, {BackgroundColor3 = UI_CONFIG.Colors.Primary}, 0.2)
    end
end)

RainbowBtn.MouseLeave:Connect(function()
    if not rainbowMode then
        Tween(RainbowBtn, {BackgroundColor3 = UI_CONFIG.Colors.Surface}, 0.2)
    end
end)

--// VISUAL CUBE
local VisualPart = Instance.new("Part")
VisualPart.Name = "GK_VisualCube"
VisualPart.Transparency = 0.6
VisualPart.CanCollide = false
VisualPart.Anchored = true
VisualPart.Material = Enum.Material.Neon
VisualPart.Color = currentColor
VisualPart.Parent = workspace

local SelectionBox = Instance.new("SelectionBox")
SelectionBox.Name = "CubeOutline"
SelectionBox.Adornee = VisualPart
SelectionBox.Color3 = currentColor
SelectionBox.LineThickness = 0.04
SelectionBox.Parent = VisualPart

--// LOGIC FUNCTIONS
local function UpdateVisualColor()
    if not rainbowMode then
        VisualPart.Color = currentColor
        SelectionBox.Color3 = currentColor
        ColorPreview.BackgroundColor3 = currentColor
    end
end

local function SetReachSize(newSize)
    reachSize = math.clamp(newSize, 1, 50)
    ValueText.Text = tostring(reachSize)

    -- Pulse animation
    Tween(ValueBox, {BackgroundColor3 = UI_CONFIG.Colors.Secondary}, 0.1)
    wait(0.1)
    Tween(ValueBox, {BackgroundColor3 = UI_CONFIG.Colors.Background}, 0.3)
end

-- Button Connections
IncreaseBtn.MouseButton1Click:Connect(function()
    SetReachSize(reachSize + 1)
end)

DecreaseBtn.MouseButton1Click:Connect(function()
    SetReachSize(reachSize - 1)
end)

RainbowBtn.MouseButton1Click:Connect(function()
    rainbowMode = not rainbowMode
    if rainbowMode then
        RainbowBtn.Text = "🌈 RAINBOW MODE: ON"
        RainbowBtn.BackgroundColor3 = UI_CONFIG.Colors.Secondary
        Tween(ColorPreview, {BackgroundTransparency = 0.5}, 0.3)
    else
        RainbowBtn.Text = "🌈 RAINBOW MODE: OFF"
        RainbowBtn.BackgroundColor3 = UI_CONFIG.Colors.Surface
        Tween(ColorPreview, {BackgroundTransparency = 0}, 0.3)
        UpdateVisualColor()
    end
end)

-- Minimize Functionality
local normalSize = UDim2.new(0, 340, 0, 480)
local normalPos = UDim2.new(0.5, -170, 0.5, -240)
local miniSize = UDim2.new(0, 60, 0, 60)
local miniPos = UDim2.new(0.5, -30, 0.9, -30)

MinimizeBtn.MouseButton1Click:Connect(function()
    if not isMinimized then
        isMinimized = true

        -- Hide content
        for _, child in pairs(Content:GetChildren()) do
            child.Visible = false
        end
        HeaderFix.Visible = false
        HeaderTitle.Visible = false
        StatusDot.Visible = false
        MinimizeBtn.Visible = false
        CloseBtn.Visible = false

        -- Shrink animation
        Tween(MainFrame, {Size = miniSize, Position = miniPos}, 0.4, Enum.EasingStyle.Back)

        -- Create restore button
        local RestoreBtn = Instance.new("TextButton")
        RestoreBtn.Name = "RestoreButton"
        RestoreBtn.Size = UDim2.new(1, 0, 1, 0)
        RestoreBtn.BackgroundColor3 = UI_CONFIG.Colors.Primary
        RestoreBtn.Text = "⚡"
        RestoreBtn.Font = Enum.Font.GothamBold
        RestoreBtn.TextSize = 28
        RestoreBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        RestoreBtn.Parent = MainFrame
        RestoreBtn.ZIndex = 10
        Corner(RestoreBtn, UDim.new(1, 0))

        -- Hover effect
        RestoreBtn.MouseEnter:Connect(function()
            Tween(RestoreBtn, {BackgroundColor3 = UI_CONFIG.Colors.Secondary, Size = UDim2.new(1.1, 0, 1.1, 0), Position = UDim2.new(-0.05, 0, -0.05, 0)}, 0.2)
        end)

        RestoreBtn.MouseLeave:Connect(function()
            Tween(RestoreBtn, {BackgroundColor3 = UI_CONFIG.Colors.Primary, Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0)}, 0.2)
        end)

        RestoreBtn.MouseButton1Click:Connect(function()
            isMinimized = false
            RestoreBtn:Destroy()

            -- Restore animation
            Tween(MainFrame, {Size = normalSize, Position = normalPos}, 0.4, Enum.EasingStyle.Back)

            wait(0.2)
            -- Show content with stagger
            HeaderFix.Visible = true
            HeaderTitle.Visible = true
            StatusDot.Visible = true
            MinimizeBtn.Visible = true
            CloseBtn.Visible = true

            for i, child in pairs(Content:GetChildren()) do
                child.Visible = true
                child.Position = child.Position + UDim2.new(0, 0, 0.05, 0)
                Tween(child, {Position = child.Position - UDim2.new(0, 0, 0.05, 0)}, 0.3 + (i * 0.05))
            end
        end)
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    -- Close animation
    Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.3)
    wait(0.3)
    ScreenGui:Destroy()
    IntroGui:Destroy()
    VisualPart:Destroy()
    isActive = false
end)

--// MAIN LOOP
RunService.RenderStepped:Connect(function(dt)
    if not isActive then return end

    -- Rainbow effect
    if rainbowMode then
        hue = (hue + dt * rainbowSpeed) % 1
        local rainbowColor = Color3.fromHSV(hue, 1, 1)
        VisualPart.Color = rainbowColor
        SelectionBox.Color3 = rainbowColor
        ColorPreview.BackgroundColor3 = rainbowColor
    end

    -- Character check
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")

    if root and humanoid then
        -- Update visual cube
        VisualPart.Size = Vector3.new(reachSize, reachSize, reachSize)
        VisualPart.CFrame = root.CFrame
        VisualPart.Transparency = isMinimized and 1 or 0.6
        SelectionBox.Transparency = isMinimized and 1 or 0

        if not isMinimized then
            -- Enhanced GK Detection
            local overlapParams = OverlapParams.new()
            overlapParams.FilterDescendantsInstances = {char, VisualPart}
            overlapParams.FilterType = Enum.RaycastFilterType.Exclude
            overlapParams.MaxParts = 50

            local partsInRange = workspace:GetPartBoundsInBox(VisualPart.CFrame, VisualPart.Size, overlapParams)

            for _, part in ipairs(partsInRange) do
                if part:IsA("BasePart") and not part.Anchored then
                    local model = part:FindFirstAncestorOfClass("Model")
                    if model and model ~= char then
                        local targetHumanoid = model:FindFirstChildOfClass("Humanoid")
                        if targetHumanoid then
                            -- Fire touch for GK mechanics
                            pcall(function()
                                firetouchinterest(part, root, 0)
                                firetouchinterest(part, root, 1)
                            end)
                        end
                    end
                end
            end
        end
    end
end)

--// INTRO SEQUENCE
-- Animate loading bar
Tween(LoadingBar, {Size = UDim2.new(1, 0, 1, 0)}, 1.5, Enum.EasingStyle.Quart)

wait(1.5)
LoadingText.Text = "READY!"

wait(0.3)

-- Fade out intro
Tween(Title, {TextTransparency = 1, Position = UDim2.new(0, 0, 0.25, 0)}, 0.4)
Tween(TitleGlow, {TextTransparency = 1}, 0.4)
Tween(Subtitle, {TextTransparency = 1, Position = UDim2.new(0, 0, 0.65, 0)}, 0.4)
Tween(LoadingContainer, {BackgroundTransparency = 1}, 0.4)
Tween(LoadingBar, {BackgroundTransparency = 1}, 0.4)
Tween(LoadingText, {TextTransparency = 1}, 0.4)

wait(0.4)
Tween(IntroFrame, {BackgroundTransparency = 1}, 0.6)

wait(0.6)

-- Enable main GUI
ScreenGui.Enabled = true
IntroGui:Destroy()

-- Pop in animation
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)

Tween(MainFrame, {Size = normalSize, Position = normalPos}, 0.6, Enum.EasingStyle.Back)

-- Staggered content reveal
for _, child in pairs(Content:GetChildren()) do
    child.Visible = false
end

wait(0.3)

for i, child in pairs(Content:GetChildren()) do
    child.Visible = true
    local originalPos = child.Position
    child.Position = originalPos + UDim2.new(0, 0, 0.1, 0)
    Tween(child, {Position = originalPos}, 0.4 + (i * 0.05))
end

print("✅ GK Godness Reach Extender Loaded Successfully!")
