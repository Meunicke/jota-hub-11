--// GK GODNESS REACH EXTENDER
--// Draggable Edition with Visual Toggle
--// Minimize to off-screen, keep running in background

--// Services
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

--// CONFIGURATION
local CONFIG = {
    DefaultReach = 4,
    MaxReach = 50,
    MinReach = 1,
    RainbowSpeed = 0.5,
    VisualTransparency = 0.6,
    KeybindToggleUI = Enum.KeyCode.Insert,
    KeybindToggleVisual = Enum.KeyCode.Home, -- Toggle only visual
    AutoStart = true,
    Persist = true
}

--// State
local State = {
    reachSize = CONFIG.DefaultReach,
    isActive = true,           -- Hack is working
    visualVisible = true,      -- Cube is visible
    uiVisible = true,
    isMinimized = false,
    isDragging = false,
    dragStart = nil,
    startPos = nil,
    rainbowMode = false,
    currentColor = Color3.fromRGB(255, 255, 0),
    hue = 0,
    connections = {},
    visualPart = nil,
    selectionBox = nil,
    gui = nil,
    mainFrame = nil
}

--// Theme
local Theme = {
    Background = Color3.fromRGB(15, 15, 15),
    Surface = Color3.fromRGB(28, 28, 28),
    Primary = Color3.fromRGB(255, 0, 85),      -- YouTube Red
    Secondary = Color3.fromRGB(30, 215, 96),   -- Spotify Green
    Accent = Color3.fromRGB(255, 203, 0),      -- YouTube Gold
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(170, 170, 170),
    Dark = Color3.fromRGB(10, 10, 10)
}

--// Utility
local function Tween(instance, props, duration, style, dir)
    return TweenService:Create(instance, TweenInfo.new(
        duration or 0.3,
        style or Enum.EasingStyle.Quart,
        dir or Enum.EasingDirection.Out
    ), props)
end

local function Corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius or UDim.new(0, 10)
    c.Parent = parent
    return c
end

local function Shadow(parent)
    local s = Instance.new("ImageLabel")
    s.Image = "rbxassetid://1316045217"
    s.ImageColor3 = Color3.new(0, 0, 0)
    s.ImageTransparency = 0.5
    s.ScaleType = Enum.ScaleType.Slice
    s.SliceCenter = Rect.new(10, 10, 118, 118)
    s.Size = UDim2.new(1, 30, 1, 30)
    s.Position = UDim2.new(0, -15, 0, -15)
    s.BackgroundTransparency = 1
    s.ZIndex = -1
    s.Parent = parent
    return s
end

--// Core Logic (Always Running)
local function InitCore()
    if State.visualPart then return end

    -- Visual Cube
    State.visualPart = Instance.new("Part")
    State.visualPart.Name = "GK_Visual_" .. HttpService:GenerateGUID(false)
    State.visualPart.Transparency = State.visualVisible and CONFIG.VisualTransparency or 1
    State.visualPart.CanCollide = false
    State.visualPart.Anchored = true
    State.visualPart.Material = Enum.Material.Neon
    State.visualPart.Color = State.currentColor
    State.visualPart.Size = Vector3.new(State.reachSize, State.reachSize, State.reachSize)
    State.visualPart.Parent = Workspace

    State.selectionBox = Instance.new("SelectionBox")
    State.selectionBox.Name = "Outline"
    State.selectionBox.Adornee = State.visualPart
    State.selectionBox.Color3 = State.currentColor
    State.selectionBox.LineThickness = 0.04
    State.selectionBox.Transparency = State.visualVisible and 0 or 1
    State.selectionBox.Parent = State.visualPart

    -- Main Loop
    local conn = RunService.RenderStepped:Connect(function(dt)
        if not State.isActive then
            if State.visualPart then
                State.visualPart.Transparency = 1
                State.selectionBox.Transparency = 1
            end
            return
        end

        -- Rainbow Effect
        if State.rainbowMode then
            State.hue = (State.hue + dt * CONFIG.RainbowSpeed) % 1
            local color = Color3.fromHSV(State.hue, 1, 1)
            State.visualPart.Color = color
            State.selectionBox.Color3 = color
        else
            State.visualPart.Color = State.currentColor
            State.selectionBox.Color3 = State.currentColor
        end

        -- Get Character
        local char = LocalPlayer.Character
        if not char then return end

        local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
        if not root then return end

        -- Update Visual (respect visualVisible setting)
        State.visualPart.Size = Vector3.new(State.reachSize, State.reachSize, State.reachSize)
        State.visualPart.CFrame = root.CFrame
        State.visualPart.Transparency = State.visualVisible and CONFIG.VisualTransparency or 1
        State.selectionBox.Transparency = State.visualVisible and 0 or 1

        -- REACH LOGIC (Always works if isActive is true, regardless of visual)
        local overlap = OverlapParams.new()
        overlap.FilterDescendantsInstances = {char, State.visualPart}
        overlap.FilterType = Enum.RaycastFilterType.Exclude
        overlap.MaxParts = 100

        local parts = Workspace:GetPartBoundsInBox(State.visualPart.CFrame, State.visualPart.Size, overlap)

        for _, part in ipairs(parts) do
            if part:IsA("BasePart") and not part.Anchored then
                local model = part:FindFirstAncestorOfClass("Model")
                if model and model ~= char then
                    local hum = model:FindFirstChildOfClass("Humanoid")
                    if hum or part.Name:lower():match("ball") or part.Name:lower():match("soccer") then
                        pcall(function()
                            firetouchinterest(part, root, 0)
                            firetouchinterest(part, root, 1)
                        end)
                    end
                end
            end
        end
    end)

    table.insert(State.connections, conn)
end

--// UI Creation
local function CreateUI()
    if State.gui then State.gui:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "GK_Godness_Drag"
    gui.Parent = CoreGui
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 9999
    State.gui = gui

    -- Main Frame
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 320, 0, 450)
    main.Position = UDim2.new(0.5, -160, 0.5, -225)
    main.BackgroundColor3 = Theme.Background
    main.BorderSizePixel = 0
    main.Active = true           -- Enable input
    main.Selectable = true       -- Enable selection
    main.Draggable = false       -- We handle drag manually for better control
    main.Parent = gui
    Corner(main, UDim.new(0, 12))
    Shadow(main)
    State.mainFrame = main

    -- Drag Handle (Top bar for dragging)
    local dragHandle = Instance.new("Frame")
    dragHandle.Name = "DragHandle"
    dragHandle.Size = UDim2.new(1, 0, 0, 35)
    dragHandle.BackgroundColor3 = Theme.Surface
    dragHandle.BorderSizePixel = 0
    dragHandle.Parent = main
    Corner(dragHandle, UDim.new(0, 12))

    local dragFix = Instance.new("Frame")
    dragFix.Size = UDim2.new(1, 0, 0, 15)
    dragFix.Position = UDim2.new(0, 0, 1, -15)
    dragFix.BackgroundColor3 = Theme.Surface
    dragFix.Parent = dragHandle

    -- Drag Icon
    local dragIcon = Instance.new("TextLabel")
    dragIcon.Size = UDim2.new(0, 30, 0, 30)
    dragIcon.Position = UDim2.new(0, 8, 0, 2)
    dragIcon.BackgroundTransparency = 1
    dragIcon.Text = "⋮⋮"  -- Drag handle icon
    dragIcon.Font = Enum.Font.GothamBold
    dragIcon.TextSize = 14
    dragIcon.TextColor3 = Theme.TextDim
    dragIcon.Parent = dragHandle

    -- Drag Text
    local dragText = Instance.new("TextLabel")
    dragText.Size = UDim2.new(0, 100, 0, 30)
    dragText.Position = UDim2.new(0, 35, 0, 2)
    dragText.BackgroundTransparency = 1
    dragText.Text = "DRAG ME"
    dragText.Font = Enum.Font.GothamSemibold
    dragText.TextSize = 10
    dragText.TextColor3 = Theme.TextDim
    dragText.Parent = dragHandle

    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.5, 0, 0, 35)
    title.Position = UDim2.new(0.25, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "GK GODNESS"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextColor3 = Theme.Text
    title.Parent = dragHandle

    -- Status Dot
    local status = Instance.new("Frame")
    status.Size = UDim2.new(0, 8, 0, 8)
    status.Position = UDim2.new(0.25, -15, 0.5, -4)
    status.BackgroundColor3 = Theme.Secondary
    status.Parent = dragHandle
    Corner(status, UDim.new(1, 0))

    -- Pulse animation
    spawn(function()
        while gui.Parent do
            Tween(status, {Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0.25, -17, 0.5, -6)}, 0.8):Play()
            wait(0.8)
            Tween(status, {Size = UDim2.new(0, 8, 0, 8), Position = UDim2.new(0.25, -15, 0.5, -4)}, 0.8):Play()
            wait(0.8)
        end
    end)

    -- Control Buttons Container
    local controls = Instance.new("Frame")
    controls.Size = UDim2.new(0, 120, 0, 30)
    controls.Position = UDim2.new(1, -125, 0, 2)
    controls.BackgroundTransparency = 1
    controls.Parent = dragHandle

    -- Visual Toggle Button (Eye)
    local visualBtn = Instance.new("TextButton")
    visualBtn.Name = "VisualToggle"
    visualBtn.Size = UDim2.new(0, 28, 0, 28)
    visualBtn.Position = UDim2.new(0, 0, 0, 0)
    visualBtn.BackgroundColor3 = State.visualVisible and Theme.Secondary or Color3.fromRGB(100, 100, 100)
    visualBtn.Text = State.visualVisible and "👁" or "👁‍🗨"
    visualBtn.Font = Enum.Font.GothamBold
    visualBtn.TextSize = 14
    visualBtn.TextColor3 = Color3.new(1, 1, 1)
    visualBtn.Parent = controls
    Corner(visualBtn, UDim.new(1, 0))

    -- Minimize Button (Move off-screen)
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 28, 0, 28)
    minBtn.Position = UDim2.new(0, 33, 0, 0)
    minBtn.BackgroundColor3 = Theme.Primary
    minBtn.Text = "−"
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = 16
    minBtn.TextColor3 = Color3.new(1, 1, 1)
    minBtn.Parent = controls
    Corner(minBtn, UDim.new(1, 0))

    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(0, 66, 0, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    closeBtn.Text = "×"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Parent = controls
    Corner(closeBtn, UDim.new(1, 0))

    -- Drag Logic
    local function updateDrag(input)
        local delta = input.Position - State.dragStart
        main.Position = UDim2.new(
            State.startPos.X.Scale,
            State.startPos.X.Offset + delta.X,
            State.startPos.Y.Scale,
            State.startPos.Y.Offset + delta.Y
        )
    end

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            State.isDragging = true
            State.dragStart = input.Position
            State.startPos = main.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    State.isDragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if State.isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                                 input.UserInputType == Enum.UserInputType.Touch) then
            updateDrag(input)
        end
    end)

    -- Content
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -20, 1, -50)
    content.Position = UDim2.new(0, 10, 0, 45)
    content.BackgroundTransparency = 1
    content.Parent = main

    -- REACH SECTION
    local reachSec = Instance.new("Frame")
    reachSec.Size = UDim2.new(1, 0, 0, 110)
    reachSec.BackgroundColor3 = Theme.Surface
    reachSec.Parent = content
    Corner(reachSec, UDim.new(0, 10))

    local reachLabel = Instance.new("TextLabel")
    reachLabel.Size = UDim2.new(1, -10, 0, 25)
    reachLabel.Position = UDim2.new(0, 5, 0, 5)
    reachLabel.BackgroundTransparency = 1
    reachLabel.Text = "⚡ REACH SIZE"
    reachLabel.Font = Enum.Font.GothamBold
    reachLabel.TextSize = 12
    reachLabel.TextColor3 = Theme.TextDim
    reachLabel.TextXAlignment = Enum.TextXAlignment.Left
    reachLabel.Parent = reachSec

    -- Value Box
    local valBox = Instance.new("Frame")
    valBox.Size = UDim2.new(0, 80, 0, 50)
    valBox.Position = UDim2.new(0.5, -40, 0.5, -5)
    valBox.BackgroundColor3 = Theme.Background
    valBox.Parent = reachSec
    Corner(valBox, UDim.new(0, 8))

    local valText = Instance.new("TextLabel")
    valText.Name = "ValueText"
    valText.Size = UDim2.new(1, 0, 1, 0)
    valText.BackgroundTransparency = 1
    valText.Text = tostring(State.reachSize)
    valText.Font = Enum.Font.GothamBlack
    valText.TextSize = 28
    valText.TextColor3 = Theme.Primary
    valText.Parent = valBox

    -- Buttons
    local function makeBtn(text, pos)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 50, 0, 50)
        btn.Position = pos
        btn.BackgroundColor3 = Theme.Primary
        btn.Text = text
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 24
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Parent = reachSec
        Corner(btn, UDim.new(0, 10))

        btn.MouseEnter:Connect(function()
            Tween(btn, {BackgroundColor3 = Theme.Secondary}, 0.2):Play()
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, {BackgroundColor3 = Theme.Primary}, 0.2):Play()
        end)

        return btn
    end

    local minusBtn = makeBtn("−", UDim2.new(0, 10, 0.5, -5))
    local plusBtn = makeBtn("+", UDim2.new(1, -60, 0.5, -5))

    -- COLOR SECTION
    local colorSec = Instance.new("Frame")
    colorSec.Size = UDim2.new(1, 0, 0, 140)
    colorSec.Position = UDim2.new(0, 0, 0, 120)
    colorSec.BackgroundColor3 = Theme.Surface
    colorSec.Parent = content
    Corner(colorSec, UDim.new(0, 10))

    local colorLabel = Instance.new("TextLabel")
    colorLabel.Size = UDim2.new(1, -10, 0, 25)
    colorLabel.Position = UDim2.new(0, 5, 0, 5)
    colorLabel.BackgroundTransparency = 1
    colorLabel.Text = "🎨 VISUAL COLOR"
    colorLabel.Font = Enum.Font.GothamBold
    colorLabel.TextSize = 12
    colorLabel.TextColor3 = Theme.TextDim
    colorLabel.TextXAlignment = Enum.TextXAlignment.Left
    colorLabel.Parent = colorSec

    -- Color Preview
    local colorPrev = Instance.new("Frame")
    colorPrev.Name = "ColorPreview"
    colorPrev.Size = UDim2.new(0, 45, 0, 45)
    colorPrev.Position = UDim2.new(1, -55, 0, 5)
    colorPrev.BackgroundColor3 = State.currentColor
    colorPrev.Parent = colorSec
    Corner(colorPrev, UDim.new(0, 8))

    -- RGB Sliders (Simplified)
    local function makeSlider(name, color, yPos, value)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, -10, 0, 30)
        container.Position = UDim2.new(0, 5, 0, yPos)
        container.BackgroundTransparency = 1
        container.Parent = colorSec

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0, 20, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = name
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 12
        lbl.TextColor3 = color
        lbl.Parent = container

        local track = Instance.new("Frame")
        track.Size = UDim2.new(1, -30, 0, 6)
        track.Position = UDim2.new(0, 25, 0.5, -3)
        track.BackgroundColor3 = Theme.Background
        track.Parent = container
        Corner(track, UDim.new(1, 0))

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(value/255, 0, 1, 0)
        fill.BackgroundColor3 = color
        fill.Parent = track
        Corner(fill, UDim.new(1, 0))

        return fill
    end

    local rFill = makeSlider("R", Color3.fromRGB(255, 60, 60), 35, 255)
    local gFill = makeSlider("G", Color3.fromRGB(60, 255, 60), 70, 255)
    local bFill = makeSlider("B", Color3.fromRGB(60, 60, 255), 105, 0)

    -- Rainbow Button
    local rainbowBtn = Instance.new("TextButton")
    rainbowBtn.Name = "RainbowBtn"
    rainbowBtn.Size = UDim2.new(1, 0, 0, 40)
    rainbowBtn.Position = UDim2.new(0, 0, 0, 270)
    rainbowBtn.BackgroundColor3 = State.rainbowMode and Theme.Secondary or Theme.Surface
    rainbowBtn.Text = State.rainbowMode and "🌈 RAINBOW: ON" or "🌈 RAINBOW: OFF"
    rainbowBtn.Font = Enum.Font.GothamBold
    rainbowBtn.TextSize = 13
    rainbowBtn.TextColor3 = Theme.Text
    rainbowBtn.Parent = content
    Corner(rainbowBtn, UDim.new(0, 10))

    -- Master Toggle (Active/Inactive)
    local masterToggle = Instance.new("TextButton")
    masterToggle.Name = "MasterToggle"
    masterToggle.Size = UDim2.new(1, 0, 0, 45)
    masterToggle.Position = UDim2.new(0, 0, 0, 320)
    masterToggle.BackgroundColor3 = State.isActive and Theme.Secondary or Color3.fromRGB(100, 100, 100)
    masterToggle.Text = State.isActive and "✅ HACK ACTIVE" or "⛔ HACK DISABLED"
    masterToggle.Font = Enum.Font.GothamBold
    masterToggle.TextSize = 14
    masterToggle.TextColor3 = Color3.new(1, 1, 1)
    masterToggle.Parent = content
    Corner(masterToggle, UDim.new(0, 10))

    -- Info Text
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, 0, 0, 40)
    info.Position = UDim2.new(0, 0, 0, 375)
    info.BackgroundTransparency = 1
    info.Text = "INSERT: Toggle UI | HOME: Toggle Visual\nDrag top bar to move"
    info.Font = Enum.Font.GothamSemibold
    info.TextSize = 10
    info.TextColor3 = Theme.TextDim
    info.TextWrapped = true
    info.Parent = content

    --// Button Functions

    -- Visual Toggle (Only hides cube, keeps hack working)
    visualBtn.MouseButton1Click:Connect(function()
        State.visualVisible = not State.visualVisible
        visualBtn.Text = State.visualVisible and "👁" or "👁‍🗨"
        visualBtn.BackgroundColor3 = State.visualVisible and Theme.Secondary or Color3.fromRGB(100, 100, 100)

        -- Visual feedback
        local notification = Instance.new("TextLabel")
        notification.Size = UDim2.new(0, 200, 0, 30)
        notification.Position = UDim2.new(0.5, -100, 0, -40)
        notification.BackgroundColor3 = State.visualVisible and Theme.Secondary or Color3.fromRGB(100, 100, 100)
        notification.Text = State.visualVisible and "Visual: ON" or "Visual: OFF (Hack still working)"
        notification.Font = Enum.Font.GothamBold
        notification.TextSize = 12
        notification.TextColor3 = Color3.new(1, 1, 1)
        notification.Parent = main
        Corner(notification, UDim.new(0, 6))

        Tween(notification, {Position = UDim2.new(0.5, -100, 0, 10)}, 0.3, Enum.EasingStyle.Back):Play()
        wait(1.5)
        Tween(notification, {Position = UDim2.new(0.5, -100, 0, -40)}, 0.3):Play()
        wait(0.3)
        notification:Destroy()
    end)

    -- Minimize to off-screen (keep running)
    minBtn.MouseButton1Click:Connect(function()
        State.isMinimized = true
        State.uiVisible = false

        -- Animate off-screen (to the right)
        Tween(main, {Position = UDim2.new(1, 50, main.Position.Y.Scale, main.Position.Y.Offset)}, 0.5, Enum.EasingStyle.Quart):Play()

        -- Create floating restore button
        local restoreBtn = Instance.new("TextButton")
        restoreBtn.Name = "RestoreButton"
        restoreBtn.Size = UDim2.new(0, 40, 0, 40)
        restoreBtn.Position = UDim2.new(1, -50, 0.5, -20)
        restoreBtn.BackgroundColor3 = Theme.Primary
        restoreBtn.Text = "⚡"
        restoreBtn.Font = Enum.Font.GothamBold
        restoreBtn.TextSize = 20
        restoreBtn.TextColor3 = Color3.new(1, 1, 1)
        restoreBtn.Parent = gui
        restoreBtn.Active = true
        restoreBtn.Draggable = true
        Corner(restoreBtn, UDim.new(1, 0))

        -- Pulse effect
        spawn(function()
            while restoreBtn.Parent do
                Tween(restoreBtn, {Size = UDim2.new(0, 45, 0, 45)}, 0.8):Play()
                wait(0.8)
                Tween(restoreBtn, {Size = UDim2.new(0, 40, 0, 40)}, 0.8):Play()
                wait(0.8)
            end
        end)

        restoreBtn.MouseButton1Click:Connect(function()
            State.isMinimized = false
            State.uiVisible = true
            restoreBtn:Destroy()
            main.Visible = true
            Tween(main, {Position = UDim2.new(0.5, -160, 0.5, -225)}, 0.5, Enum.EasingStyle.Back):Play()
        end)
    end)

    -- Close (destroy UI but keep hack running)
    closeBtn.MouseButton1Click:Connect(function()
        Tween(main, {Size = UDim2.new(0, 0, 0, 0)}, 0.3):Play()
        wait(0.3)
        gui:Destroy()
        State.gui = nil
        State.uiVisible = false

        -- Create small indicator that hack is still running
        local indicator = Instance.new("TextButton")
        indicator.Size = UDim2.new(0, 30, 0, 30)
        indicator.Position = UDim2.new(0, 10, 0.5, -15)
        indicator.BackgroundColor3 = Theme.Secondary
        indicator.Text = "⚡"
        indicator.Font = Enum.Font.GothamBold
        indicator.TextSize = 14
        indicator.Parent = CoreGui
        Corner(indicator, UDim.new(1, 0))

        indicator.MouseButton1Click:Connect(function()
            indicator:Destroy()
            CreateUI()
        end)

        -- Auto-remove indicator after 3 seconds
        spawn(function()
            wait(3)
            if indicator.Parent then
                Tween(indicator, {BackgroundTransparency = 1, TextTransparency = 1}, 0.5):Play()
                wait(0.5)
                indicator:Destroy()
            end
        end)
    end)

    -- Reach Controls
    plusBtn.MouseButton1Click:Connect(function()
        State.reachSize = math.min(State.reachSize + 1, CONFIG.MaxReach)
        valText.Text = tostring(State.reachSize)
        Tween(valBox, {BackgroundColor3 = Theme.Secondary}, 0.1).Completed:Wait()
        Tween(valBox, {BackgroundColor3 = Theme.Background}, 0.2):Play()
    end)

    minusBtn.MouseButton1Click:Connect(function()
        State.reachSize = math.max(State.reachSize - 1, CONFIG.MinReach)
        valText.Text = tostring(State.reachSize)
        Tween(valBox, {BackgroundColor3 = Theme.Primary}, 0.1).Completed:Wait()
        Tween(valBox, {BackgroundColor3 = Theme.Background}, 0.2):Play()
    end)

    -- Rainbow
    rainbowBtn.MouseButton1Click:Connect(function()
        State.rainbowMode = not State.rainbowMode
        rainbowBtn.Text = State.rainbowMode and "🌈 RAINBOW: ON" or "🌈 RAINBOW: OFF"
        rainbowBtn.BackgroundColor3 = State.rainbowMode and Theme.Secondary or Theme.Surface
    end)

    -- Master Toggle (Actually disables/enables the hack)
    masterToggle.MouseButton1Click:Connect(function()
        State.isActive = not State.isActive
        masterToggle.Text = State.isActive and "✅ HACK ACTIVE" or "⛔ HACK DISABLED"
        masterToggle.BackgroundColor3 = State.isActive and Theme.Secondary or Color3.fromRGB(100, 100, 100)
    end)

    -- Store refs
    State.uiElements = {
        main = main,
        valText = valText,
        colorPrev = colorPrev,
        rainbowBtn = rainbowBtn,
        masterToggle = masterToggle,
        visualBtn = visualBtn
    }

    -- Intro animation
    main.Size = UDim2.new(0, 0, 0, 0)
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Tween(main, {Size = UDim2.new(0, 320, 0, 450), Position = UDim2.new(0.5, -160, 0.5, -225)}, 0.6, Enum.EasingStyle.Back):Play()
end

--// Keybinds
local function SetupKeybinds()
    -- Toggle UI
    local conn1 = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == CONFIG.KeybindToggleUI then
            if State.gui and State.gui.Parent then
                local main = State.uiElements.main
                if State.uiVisible then
                    Tween(main, {Position = UDim2.new(1, 100, main.Position.Y.Scale, main.Position.Y.Offset)}, 0.4):Play()
                    State.uiVisible = false
                else
                    Tween(main, {Position = UDim2.new(0.5, -160, 0.5, -225)}, 0.4, Enum.EasingStyle.Back):Play()
                    State.uiVisible = true
                end
            else
                CreateUI()
            end
        elseif input.KeyCode == CONFIG.KeybindToggleVisual then
            -- Toggle only visual (not the hack)
            State.visualVisible = not State.visualVisible
            if State.uiElements and State.uiElements.visualBtn then
                State.uiElements.visualBtn.Text = State.visualVisible and "👁" or "👁‍🗨"
                State.uiElements.visualBtn.BackgroundColor3 = State.visualVisible and Theme.Secondary or Color3.fromRGB(100, 100, 100)
            end
        end
    end)
    table.insert(State.connections, conn1)
end

--// Character Handler
local function SetupCharacter()
    local function onChar(char)
        wait(0.3)
        InitCore()
    end

    if LocalPlayer.Character then
        onChar(LocalPlayer.Character)
    end

    local conn = LocalPlayer.CharacterAdded:Connect(onChar)
    table.insert(State.connections, conn)
end

--// Initialize
local function Init()
    -- Cleanup
    for _, c in pairs(State.connections) do
        pcall(function() c:Disconnect() end)
    end
    State.connections = {}

    if State.gui then
        pcall(function() State.gui:Destroy() end)
    end

    -- Setup
    SetupCharacter()
    SetupKeybinds()

    if CONFIG.AutoStart then
        wait(0.3)
        InitCore()
        CreateUI()
    end

    print("✅ GK Godness Loaded!")
    print("🔥 Features:")
    print("   • Drag the top bar to move")
    print("   • Eye button = Toggle visual only")
    print("   • Minus button = Move off-screen (keeps running)")
    print("   • INSERT = Toggle UI")
    print("   • HOME = Toggle visual quickly")
end

Init()

--// Persist
if CONFIG.Persist then
    LocalPlayer.OnTeleport:Connect(function()
        wait(1)
        Init()
    end)
end
