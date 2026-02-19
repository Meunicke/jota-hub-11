--// GK GODNESS REACH EXTENDER
--// Background Edition - Works without active tab
--// Auto-execution & Persistent Mode

--// Services
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// CONFIGURATION
local CONFIG = {
    AutoExecute = true,           -- Auto-start on load
    BackgroundMode = true,        -- Works without focus
    Persistent = true,            -- Survive respawn
    DefaultReach = 4,
    MaxReach = 50,
    RainbowSpeed = 0.5,
    UpdateRate = 0,               -- 0 = every frame (RenderStepped)
    VisualTransparency = 0.7,
    Keybind = Enum.KeyCode.Insert, -- Toggle UI
    SilentMode = false             -- No notifications
}

--// State Management
local State = {
    reachSize = CONFIG.DefaultReach,
    isActive = true,
    isMinimized = false,
    isVisible = true,
    rainbowMode = false,
    currentColor = Color3.fromRGB(255, 255, 0),
    hue = 0,
    connections = {},
    visualPart = nil,
    selectionBox = nil,
    gui = nil,
    isRunning = false
}

--// UI Theme (YouTube × Spotify)
local Theme = {
    Background = Color3.fromRGB(15, 15, 15),
    Surface = Color3.fromRGB(28, 28, 28),
    Primary = Color3.fromRGB(255, 0, 85),
    Secondary = Color3.fromRGB(30, 215, 96),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(170, 170, 170)
}

--// Utility Functions
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

--// Core Logic (Background Execution)
local function InitCoreLogic()
    if State.isRunning then return end
    State.isRunning = true

    -- Create Visual Cube
    State.visualPart = Instance.new("Part")
    State.visualPart.Name = "GK_VisualCube_" .. HttpService:GenerateGUID(false)
    State.visualPart.Transparency = CONFIG.VisualTransparency
    State.visualPart.CanCollide = false
    State.visualPart.Anchored = true
    State.visualPart.Material = Enum.Material.Neon
    State.visualPart.Color = State.currentColor
    State.visualPart.Size = Vector3.new(State.reachSize, State.reachSize, State.reachSize)
    State.visualPart.Parent = Workspace

    State.selectionBox = Instance.new("SelectionBox")
    State.selectionBox.Name = "CubeOutline"
    State.selectionBox.Adornee = State.visualPart
    State.selectionBox.Color3 = State.currentColor
    State.selectionBox.LineThickness = 0.04
    State.selectionBox.Parent = State.visualPart

    -- Main Loop (RenderStepped for maximum performance)
    local connection = RunService.RenderStepped:Connect(function(dt)
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

        -- Character Detection (Auto-detect even without focus)
        local char = LocalPlayer.Character
        if not char then return end

        local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
        if not root then return end

        -- Update Visual
        State.visualPart.Size = Vector3.new(State.reachSize, State.reachSize, State.reachSize)
        State.visualPart.CFrame = root.CFrame
        State.visualPart.Transparency = State.isMinimized and 1 or CONFIG.VisualTransparency
        State.selectionBox.Transparency = State.isMinimized and 1 or 0

        -- GK Reach Logic (Optimized)
        if not State.isMinimized then
            local overlap = OverlapParams.new()
            overlap.FilterDescendantsInstances = {char, State.visualPart}
            overlap.FilterType = Enum.RaycastFilterType.Exclude
            overlap.MaxParts = 100

            local parts = Workspace:GetPartBoundsInBox(State.visualPart.CFrame, State.visualPart.Size, overlap)

            for _, part in ipairs(parts) do
                if part:IsA("BasePart") and not part.Anchored then
                    local model = part:FindFirstAncestorOfClass("Model")
                    if model and model ~= char then
                        -- Check if it's a ball or player
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
        end
    end)

    table.insert(State.connections, connection)
end

--// UI Creation
local function CreateUI()
    if State.gui then State.gui:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "GK_Godness_BG"
    gui.Parent = CoreGui
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 9999
    State.gui = gui

    -- Main Frame
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 300, 0, 400)
    main.Position = UDim2.new(0.5, -150, 0.5, -200)
    main.BackgroundColor3 = Theme.Background
    main.BorderSizePixel = 0
    main.Visible = false -- Start hidden, show after intro
    main.Parent = gui
    Corner(main, UDim.new(0, 12))

    -- Shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.Position = UDim2.new(0, -15, 0, -15)
    shadow.BackgroundTransparency = 1
    shadow.ZIndex = -1
    shadow.Parent = main

    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = Theme.Surface
    header.Parent = main
    Corner(header, UDim.new(0, 12))

    local headerFix = Instance.new("Frame")
    headerFix.Size = UDim2.new(1, 0, 0, 20)
    headerFix.Position = UDim2.new(0, 0, 1, -20)
    headerFix.BackgroundColor3 = Theme.Surface
    headerFix.Parent = header

    -- Status Dot (Pulsing)
    local status = Instance.new("Frame")
    status.Size = UDim2.new(0, 8, 0, 8)
    status.Position = UDim2.new(0, 12, 0.5, -4)
    status.BackgroundColor3 = Theme.Secondary
    status.Parent = header
    Corner(status, UDim.new(1, 0))

    spawn(function()
        while gui.Parent do
            Tween(status, {Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0, 10, 0.5, -6)}, 0.8):Play()
            wait(0.8)
            Tween(status, {Size = UDim2.new(0, 8, 0, 8), Position = UDim2.new(0, 12, 0.5, -4)}, 0.8):Play()
            wait(0.8)
        end
    end)

    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.6, 0, 1, 0)
    title.Position = UDim2.new(0, 28, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "GK GODNESS"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextColor3 = Theme.Text
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    -- Minimize Button
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 28, 0, 28)
    minBtn.Position = UDim2.new(1, -68, 0.5, -14)
    minBtn.BackgroundColor3 = Theme.Primary
    minBtn.Text = "−"
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = 16
    minBtn.TextColor3 = Color3.new(1, 1, 1)
    minBtn.Parent = header
    Corner(minBtn, UDim.new(1, 0))

    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -36, 0.5, -14)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    closeBtn.Text = "×"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Parent = header
    Corner(closeBtn, UDim.new(1, 0))

    -- Content
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -20, 1, -70)
    content.Position = UDim2.new(0, 10, 0, 60)
    content.BackgroundTransparency = 1
    content.Parent = main

    -- Reach Control
    local reachSec = Instance.new("Frame")
    reachSec.Size = UDim2.new(1, 0, 0, 100)
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
    valBox.Size = UDim2.new(0, 70, 0, 45)
    valBox.Position = UDim2.new(0.5, -35, 0.5, -5)
    valBox.BackgroundColor3 = Theme.Background
    valBox.Parent = reachSec
    Corner(valBox, UDim.new(0, 8))

    local valText = Instance.new("TextLabel")
    valText.Size = UDim2.new(1, 0, 1, 0)
    valText.BackgroundTransparency = 1
    valText.Text = tostring(State.reachSize)
    valText.Font = Enum.Font.GothamBlack
    valText.TextSize = 26
    valText.TextColor3 = Theme.Primary
    valText.Parent = valBox

    -- Buttons
    local function makeBtn(text, pos)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 45, 0, 45)
        btn.Position = pos
        btn.BackgroundColor3 = Theme.Primary
        btn.Text = text
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 22
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
    local plusBtn = makeBtn("+", UDim2.new(1, -55, 0.5, -5))

    -- Color Section
    local colorSec = Instance.new("Frame")
    colorSec.Size = UDim2.new(1, 0, 0, 120)
    colorSec.Position = UDim2.new(0, 0, 0, 110)
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
    colorPrev.Size = UDim2.new(0, 40, 0, 40)
    colorPrev.Position = UDim2.new(1, -50, 0, 5)
    colorPrev.BackgroundColor3 = State.currentColor
    colorPrev.Parent = colorSec
    Corner(colorPrev, UDim.new(0, 6))

    -- Rainbow Button
    local rainbowBtn = Instance.new("TextButton")
    rainbowBtn.Size = UDim2.new(1, -10, 0, 35)
    rainbowBtn.Position = UDim2.new(0, 5, 0, 75)
    rainbowBtn.BackgroundColor3 = Theme.Background
    rainbowBtn.Text = "🌈 RAINBOW: OFF"
    rainbowBtn.Font = Enum.Font.GothamBold
    rainbowBtn.TextSize = 12
    rainbowBtn.TextColor3 = Theme.Text
    rainbowBtn.Parent = colorSec
    Corner(rainbowBtn, UDim.new(0, 8))

    -- Toggle Button
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(1, 0, 0, 40)
    toggleBtn.Position = UDim2.new(0, 0, 0, 240)
    toggleBtn.BackgroundColor3 = State.isActive and Theme.Secondary or Color3.fromRGB(100, 100, 100)
    toggleBtn.Text = State.isActive and "✅ ACTIVE" or "⛔ DISABLED"
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 14
    toggleBtn.TextColor3 = Color3.new(1, 1, 1)
    toggleBtn.Parent = content
    Corner(toggleBtn, UDim.new(0, 10))

    -- Info Label
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, 0, 0, 30)
    infoLabel.Position = UDim2.new(0, 0, 0, 290)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = "Press INSERT to toggle UI"
    infoLabel.Font = Enum.Font.GothamSemibold
    infoLabel.TextSize = 11
    infoLabel.TextColor3 = Theme.TextDim
    infoLabel.Parent = content

    --// Button Logic
    plusBtn.MouseButton1Click:Connect(function()
        State.reachSize = math.min(State.reachSize + 1, CONFIG.MaxReach)
        valText.Text = tostring(State.reachSize)
        Tween(valBox, {BackgroundColor3 = Theme.Secondary}, 0.1).Completed:Wait()
        Tween(valBox, {BackgroundColor3 = Theme.Background}, 0.2):Play()
    end)

    minusBtn.MouseButton1Click:Connect(function()
        State.reachSize = math.max(State.reachSize - 1, 1)
        valText.Text = tostring(State.reachSize)
        Tween(valBox, {BackgroundColor3 = Theme.Primary}, 0.1).Completed:Wait()
        Tween(valBox, {BackgroundColor3 = Theme.Background}, 0.2):Play()
    end)

    rainbowBtn.MouseButton1Click:Connect(function()
        State.rainbowMode = not State.rainbowMode
        rainbowBtn.Text = State.rainbowMode and "🌈 RAINBOW: ON" or "🌈 RAINBOW: OFF"
        rainbowBtn.BackgroundColor3 = State.rainbowMode and Theme.Secondary or Theme.Background
    end)

    toggleBtn.MouseButton1Click:Connect(function()
        State.isActive = not State.isActive
        toggleBtn.Text = State.isActive and "✅ ACTIVE" or "⛔ DISABLED"
        toggleBtn.BackgroundColor3 = State.isActive and Theme.Secondary or Color3.fromRGB(100, 100, 100)
    end)

    -- Minimize Logic
    local miniSize = UDim2.new(0, 50, 0, 50)
    local miniPos = UDim2.new(0.5, -25, 0.9, -25)
    local normalSize = UDim2.new(0, 300, 0, 400)
    local normalPos = UDim2.new(0.5, -150, 0.5, -200)

    minBtn.MouseButton1Click:Connect(function()
        if not State.isMinimized then
            State.isMinimized = true
            for _, child in pairs(content:GetChildren()) do
                child.Visible = false
            end
            headerFix.Visible = false
            title.Visible = false
            status.Visible = false
            minBtn.Visible = false
            closeBtn.Visible = false

            Tween(main, {Size = miniSize, Position = miniPos}, 0.4, Enum.EasingStyle.Back):Play()

            local restore = Instance.new("TextButton")
            restore.Size = UDim2.new(1, 0, 1, 0)
            restore.BackgroundColor3 = Theme.Primary
            restore.Text = "⚡"
            restore.Font = Enum.Font.GothamBold
            restore.TextSize = 24
            restore.TextColor3 = Color3.new(1, 1, 1)
            restore.Parent = main
            Corner(restore, UDim.new(1, 0))

            restore.MouseButton1Click:Connect(function()
                State.isMinimized = false
                restore:Destroy()
                Tween(main, {Size = normalSize, Position = normalPos}, 0.4, Enum.EasingStyle.Back):Play()
                wait(0.2)
                for _, child in pairs(content:GetChildren()) do
                    child.Visible = true
                end
                headerFix.Visible = true
                title.Visible = true
                status.Visible = true
                minBtn.Visible = true
                closeBtn.Visible = true
            end)
        end
    end)

    closeBtn.MouseButton1Click:Connect(function()
        Tween(main, {Size = UDim2.new(0, 0, 0, 0)}, 0.3):Play()
        wait(0.3)
        State.isVisible = false
        main.Visible = false
    end)

    -- Store references for updates
    State.uiElements = {
        main = main,
        valText = valText,
        colorPrev = colorPrev,
        rainbowBtn = rainbowBtn,
        toggleBtn = toggleBtn
    }

    -- Show UI with animation
    main.Visible = true
    main.Size = UDim2.new(0, 0, 0, 0)
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Tween(main, {Size = normalSize, Position = normalPos}, 0.6, Enum.EasingStyle.Back):Play()
end

--// Keybind Handler
local function SetupKeybind()
    local conn = game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == CONFIG.Keybind then
            if State.gui and State.gui.Parent then
                local main = State.uiElements.main
                if main.Visible then
                    State.isVisible = false
                    Tween(main, {Size = UDim2.new(0, 0, 0, 0)}, 0.3).Completed:Connect(function()
                        main.Visible = false
                    end)
                else
                    State.isVisible = true
                    main.Visible = true
                    main.Size = UDim2.new(0, 0, 0, 0)
                    Tween(main, {Size = UDim2.new(0, 300, 0, 400)}, 0.4, Enum.EasingStyle.Back):Play()
                end
            else
                CreateUI()
            end
        end
    end)
    table.insert(State.connections, conn)
end

--// Character Handler (Auto-reconnect)
local function SetupCharacterHandler()
    local function onCharAdded(char)
        wait(0.5) -- Wait for character to load
        if not State.isRunning then
            InitCoreLogic()
        end
    end

    if LocalPlayer.Character then
        onCharAdded(LocalPlayer.Character)
    end

    local conn = LocalPlayer.CharacterAdded:Connect(onCharAdded)
    table.insert(State.connections, conn)
end

--// Initialize
local function Initialize()
    -- Clean up old instances
    for _, conn in pairs(State.connections) do
        pcall(function() conn:Disconnect() end)
    end
    State.connections = {}

    if State.gui then
        pcall(function() State.gui:Destroy() end)
    end

    if State.visualPart then
        pcall(function() State.visualPart:Destroy() end)
    end

    -- Setup
    SetupCharacterHandler()
    SetupKeybind()

    -- Auto-start logic
    if CONFIG.AutoExecute then
        wait(0.5)
        InitCoreLogic()
        if not CONFIG.SilentMode then
            CreateUI()
        end
    end

    print("✅ GK Godness Background Mode Initialized!")
    print("🔥 Works without active tab!")
    print("⌨️ Press INSERT to toggle UI")
end

--// Start
Initialize()

--// Respawn Handler (Persistent)
if CONFIG.Persistent then
    LocalPlayer.OnTeleport:Connect(function()
        wait(1)
        Initialize()
    end)
end
