--[[
    ╔═══════════════════════════════════════════════════════════════════════╗
    ║                                                                       ║
    ║   TITANIUM HUB v2.0 - CADUXX137 Edition (Standalone)                  ║
    ║   Biblioteca UI + Lógica CADU em um único arquivo                     ║
    ║                                                                       ║
    ╚═══════════════════════════════════════════════════════════════════════╝
]]

if not game:IsLoaded() then game.Loaded:Wait() end

-- ============================================
-- PARTE 1: TITANIUM UI LIBRARY
-- ============================================
local Titanium = {
    Version = "1.0.0",
    Name = "Titanium UI",

    Theme = {
        Background = Color3.fromRGB(15, 15, 20),
        Surface = Color3.fromRGB(25, 25, 35),
        SurfaceLight = Color3.fromRGB(35, 35, 50),
        Primary = Color3.fromRGB(0, 170, 255),
        Secondary = Color3.fromRGB(138, 43, 226),
        Success = Color3.fromRGB(0, 255, 136),
        Warning = Color3.fromRGB(255, 193, 7),
        Danger = Color3.fromRGB(255, 71, 87),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(150, 160, 180),
        CornerRadius = 12,
        AnimationSpeed = 0.3
    },

    Services = {},
    Windows = {}
}

-- Services
Titanium.Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    TweenService = game:GetService("TweenService"),
    CoreGui = game:GetService("CoreGui"),
    StarterGui = game:GetService("StarterGui"),
    Workspace = game:GetService("Workspace")
}

Titanium.LocalPlayer = Titanium.Services.Players.LocalPlayer
Titanium.PlayerGui = Titanium.LocalPlayer:WaitForChild("PlayerGui")

-- Utility Functions
function Titanium:Create(className, properties)
    local instance = Instance.new(className)
    if properties then
        for prop, value in pairs(properties) do
            if prop ~= "Parent" then
                instance[prop] = value
            end
        end
    end
    return instance
end

function Titanium:Tween(instance, duration, properties, style, direction)
    style = style or Enum.EasingStyle.Quint
    direction = direction or Enum.EasingDirection.Out
    local tweenInfo = TweenInfo.new(duration or self.Theme.AnimationSpeed, style, direction)
    local tween = self.Services.TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

function Titanium:Notify(title, text, duration)
    duration = duration or 3
    pcall(function()
        self.Services.StarterGui:SetCore("SendNotification", {
            Title = title or "Titanium",
            Text = text or "",
            Duration = duration
        })
    end)
end

function Titanium:SetDraggable(frame, dragHandle)
    dragHandle = dragHandle or frame
    local dragging = false
    local dragStart, startPos

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    self.Services.UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    self.Services.UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- Create Window
function Titanium:CreateWindow(config)
    config = config or {}
    local title = config.Title or "Titanium Window"
    local size = config.Size or UDim2.new(0, 450, 0, 550)
    local toggleKey = config.ToggleKey or Enum.KeyCode.RightShift
    local theme = self.Theme

    -- ScreenGui
    local screenGui = self:Create("ScreenGui", {
        Name = "TitaniumUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    if syn and syn.protect_gui then
        syn.protect_gui(screenGui)
    elseif gethui then
        screenGui.Parent = gethui()
    else
        screenGui.Parent = self.Services.CoreGui
    end

    -- Main Frame
    local mainFrame = self:Create("Frame", {
        Name = "Main",
        Size = size,
        Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2),
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        Active = true,
        ClipsDescendants = true,
        Parent = screenGui
    })

    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, theme.CornerRadius)

    local stroke = self:Create("UIStroke", {
        Color = theme.Primary,
        Thickness = 2,
        Transparency = 0.5,
        Parent = mainFrame
    })

    -- Header
    local header = self:Create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 55),
        BackgroundColor3 = theme.Surface,
        BorderSizePixel = 0,
        Parent = mainFrame
    })

    Instance.new("UICorner", header).CornerRadius = UDim.new(0, theme.CornerRadius)

    local headerFix = self:Create("Frame", {
        Size = UDim2.new(1, 0, 0.5, 0),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = theme.Surface,
        BorderSizePixel = 0,
        Parent = header
    })

    local titleLabel = self:Create("TextLabel", {
        Size = UDim2.new(0.7, 0, 1, 0),
        Position = UDim2.new(0, 20, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header
    })

    local closeBtn = self:Create("TextButton", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -45, 0, 12),
        BackgroundColor3 = theme.Danger,
        Text = "X",
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        Parent = header
    })
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    -- Content
    local content = self:Create("ScrollingFrame", {
        Name = "Content",
        Size = UDim2.new(1, -30, 1, -130),
        Position = UDim2.new(0, 15, 0, 70),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = theme.Primary,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = mainFrame
    })

    local listLayout = self:Create("UIListLayout", {
        Padding = UDim.new(0, 12),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = content
    })

    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        content.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 20)
    end)

    -- Status Bar
    local statusLabel = self:Create("TextLabel", {
        Size = UDim2.new(1, -30, 0, 30),
        Position = UDim2.new(0, 15, 1, -40),
        BackgroundTransparency = 1,
        Text = "🟢 Ready",
        TextColor3 = theme.Success,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = mainFrame
    })

    self:SetDraggable(mainFrame, header)

    self.Services.UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == toggleKey then
            mainFrame.Visible = not mainFrame.Visible
        end
    end)

    local window = {
        ScreenGui = screenGui,
        MainFrame = mainFrame,
        Content = content,
        StatusLabel = statusLabel,
        Theme = theme
    }

    function window:SetStatus(text, color)
        self.StatusLabel.Text = text
        self.StatusLabel.TextColor3 = color or theme.Success
    end

    function window:AddSection(titleText)
        local section = self:Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundColor3 = theme.SurfaceLight,
            BorderSizePixel = 0,
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = self.Content
        })
        Instance.new("UICorner", section).CornerRadius = UDim.new(0, 10)

        local title = self:Create("TextLabel", {
            Size = UDim2.new(1, -20, 0, 30),
            Position = UDim2.new(0, 10, 0, 8),
            BackgroundTransparency = 1,
            Text = titleText,
            TextColor3 = theme.Primary,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = section
        })

        local container = self:Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.new(0, 0, 0, 35),
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = section
        })

        local list = self:Create("UIListLayout", {
            Padding = UDim.new(0, 10),
            Parent = container
        })

        list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            container.Size = UDim2.new(1, 0, 0, list.AbsoluteContentSize.Y + 15)
            section.Size = UDim2.new(1, 0, 0, 35 + list.AbsoluteContentSize.Y + 15)
        end)

        return {Section = section, Container = container}
    end

    function window:AddToggle(section, config)
        config = config or {}
        local text = config.Text or "Toggle"
        local default = config.Default or false
        local callback = config.Callback or function() end

        local container = self:Create("Frame", {
            Size = UDim2.new(1, -20, 0, 35),
            BackgroundTransparency = 1,
            Parent = section.Container
        })

        local label = self:Create("TextLabel", {
            Size = UDim2.new(1, -55, 1, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = theme.Text,
            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = container
        })

        local bg = self:Create("Frame", {
            Size = UDim2.new(0, 46, 0, 24),
            Position = UDim2.new(1, -46, 0.5, -12),
            BackgroundColor3 = default and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(60, 60, 70),
            Parent = container
        })
        Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)

        local circle = self:Create("Frame", {
            Size = UDim2.new(0, 18, 0, 18),
            Position = default and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
            BackgroundColor3 = Color3.new(1, 1, 1),
            Parent = bg
        })
        Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

        local btn = self:Create("TextButton", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "",
            Parent = container
        })

        local state = default
        btn.MouseButton1Click:Connect(function()
            state = not state
            Titanium:Tween(bg, 0.25, {BackgroundColor3 = state and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(60, 60, 70)})
            Titanium:Tween(circle, 0.25, {Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)})
            callback(state)
        end)
    end

    function window:AddSlider(section, config)
        config = config or {}
        local text = config.Text or "Slider"
        local min = config.Min or 0
        local max = config.Max or 100
        local default = config.Default or min
        local callback = config.Callback or function() end

        local container = self:Create("Frame", {
            Size = UDim2.new(1, -20, 0, 55),
            BackgroundTransparency = 1,
            Parent = section.Container
        })

        local label = self:Create("TextLabel", {
            Size = UDim2.new(0.6, 0, 0, 20),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = theme.Text,
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = container
        })

        local valueLabel = self:Create("TextLabel", {
            Size = UDim2.new(0.4, 0, 0, 20),
            Position = UDim2.new(0.6, 0, 0, 0),
            BackgroundTransparency = 1,
            Text = tostring(default),
            TextColor3 = theme.Primary,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = container
        })

        local track = self:Create("Frame", {
            Size = UDim2.new(1, 0, 0, 6),
            Position = UDim2.new(0, 0, 0, 32),
            BackgroundColor3 = Color3.fromRGB(50, 50, 60),
            Parent = container
        })
        Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

        local fill = self:Create("Frame", {
            Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
            BackgroundColor3 = theme.Primary,
            Parent = track
        })
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

        local knob = self:Create("Frame", {
            Size = UDim2.new(0, 14, 0, 14),
            Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7),
            BackgroundColor3 = Color3.new(1, 1, 1),
            Parent = track
        })
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

        local dragging = false
        local function update(input)
            local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (pos * (max - min)))
            valueLabel.Text = tostring(value)
            fill.Size = UDim2.new(pos, 0, 1, 0)
            knob.Position = UDim2.new(pos, -7, 0.5, -7)
            callback(value)
        end

        knob.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
        end)

        Titanium.Services.UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)

        Titanium.Services.UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end
        end)

        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then update(input) end
        end)
    end

    function window:AddButton(section, config)
        config = config or {}
        local text = config.Text or "Button"
        local color = config.Color or theme.Primary
        local callback = config.Callback or function() end

        local btn = self:Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundColor3 = theme.Surface,
            Text = "",
            AutoButtonColor = false,
            Parent = section.Container
        })
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

        local stroke = self:Create("UIStroke", {
            Color = color,
            Thickness = 1.5,
            Transparency = 0.6,
            Parent = btn
        })

        local lbl = self:Create("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = theme.Text,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            Parent = btn
        })

        btn.MouseEnter:Connect(function()
            Titanium:Tween(btn, 0.2, {BackgroundColor3 = theme.SurfaceLight})
            Titanium:Tween(stroke, 0.2, {Transparency = 0.3})
        end)

        btn.MouseLeave:Connect(function()
            Titanium:Tween(btn, 0.2, {BackgroundColor3 = theme.Surface})
            Titanium:Tween(stroke, 0.2, {Transparency = 0.6})
        end)

        btn.MouseButton1Click:Connect(function()
            Titanium:Tween(btn, 0.1, {Size = UDim2.new(0.98, 0, 0, 38)})
            task.delay(0.1, function()
                Titanium:Tween(btn, 0.1, {Size = UDim2.new(1, 0, 0, 40)})
            end)
            pcall(callback)
        end)
    end

    Titanium:Tween(mainFrame, 0.5, {Size = size}, Enum.EasingStyle.Back)
    table.insert(self.Windows, window)
    return window
end

-- ============================================
-- PARTE 2: LÓGICA CADUXX137
-- ============================================
local CADU_CONFIG = {
    reach = 15,
    showReachSphere = true,
    autoTouch = true,
    fullBodyTouch = true,
    autoSecondTouch = true,
    autoSkills = true,
    scanCooldown = 1.5,
    skillCooldown = 0.5,
    ballNames = { "TPS", "TCS", "ESA", "MRS", "PRS", "MPS", "SSS", "AIFA", "RBZ", "Ball", "Soccer", "Football", "Basketball", "Baseball", "BallTemplate", "GameBall", "Hitbox", "TouchPart", "GoalBall" },
    skillNames = { "Shoot", "Pass", "Long", "Tackle", "Dribble", "GK", "Throw", "Control", "Left", "Right", "High", "Low", "Rainbow", "Chip", "Heel", "Volley", "Back Right", "Back Left", "Carry", "Fake Shot", "Drag Back", "Header", "Bicycle", "Shot", "Slide", "Goalkeeper", "Catch", "Punch", "Short Pass", "Through Ball", "Cross", "Curve", "Power Shot", "Precision", "First Touch" }
}

local balls, ballConnections, reachSphere, HRP, char = {}, {}, nil, nil, nil
local touchDebounce, lastBallUpdate, lastTouch, lastSkillActivation, activatedSkills = {}, 0, 0, 0, {}

local function updateCharacter()
    local newChar = Titanium.LocalPlayer.Character
    if newChar ~= char then
        char = newChar
        if char then
            HRP = char:FindFirstChild("HumanoidRootPart")
            if HRP then Titanium:Notify("TITANIUM HUB", "Sistema ativo!", 2) end
        else
            HRP = nil
        end
    end
end

local function findBalls()
    local now = tick()
    if now - lastBallUpdate < CADU_CONFIG.scanCooldown then return end
    lastBallUpdate = now
    table.clear(balls)
    for _, conn in pairs(ballConnections) do pcall(function() conn:Disconnect() end) end
    table.clear(ballConnections)

    for _, obj in pairs(Titanium.Services.Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            for _, name in pairs(CADU_CONFIG.ballNames) do
                if obj.Name == name or string.find(obj.Name, name) then
                    table.insert(balls, obj)
                    table.insert(ballConnections, obj.AncestryChanged:Connect(function() if not obj.Parent then findBalls() end end))
                    break
                end
            end
        end
    end
end

local function getBodyParts()
    if not char then return {} end
    local parts = {}
    for _, part in pairs(char:GetChildren()) do
        if part:IsA("BasePart") then
            if CADU_CONFIG.fullBodyTouch then table.insert(parts, part)
            elseif part.Name == "HumanoidRootPart" then table.insert(parts, part) end
        end
    end
    return parts
end

local function updateSphere()
    if not CADU_CONFIG.showReachSphere then
        if reachSphere then pcall(function() reachSphere:Destroy() end) reachSphere = nil end
        return
    end
    if not reachSphere or not reachSphere.Parent then
        reachSphere = Instance.new("Part")
        reachSphere.Name = "ReachSphere"
        reachSphere.Shape = Enum.PartType.Ball
        reachSphere.Anchored = true
        reachSphere.CanCollide = false
        reachSphere.Transparency = 0.9
        reachSphere.Material = Enum.Material.ForceField
        reachSphere.Color = Titanium.Theme.Primary
        reachSphere.Parent = Titanium.Services.Workspace
    end
    if HRP and HRP.Parent then
        pcall(function()
            reachSphere.Position = HRP.Position
            reachSphere.Size = Vector3.new(CADU_CONFIG.reach * 2, CADU_CONFIG.reach * 2, CADU_CONFIG.reach * 2)
        end)
    end
end

local function doTouch(ball, part)
    if not ball or not ball.Parent or not part or not part.Parent then return end
    local key = ball.Name .. "_" .. part.Name .. "_" .. tostring(ball)
    if touchDebounce[key] and tick() - touchDebounce[key] < 0.1 then return end
    touchDebounce[key] = tick()
    pcall(function()
        firetouchinterest(ball, part, 0)
        task.wait(0.01)
        firetouchinterest(ball, part, 1)
        if CADU_CONFIG.autoSecondTouch then
            task.wait(0.05)
            firetouchinterest(ball, part, 0)
            firetouchinterest(ball, part, 1)
        end
    end)
end

local function findSkillButtons()
    local buttons = {}
    for _, gui in pairs(Titanium.PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and not string.find(gui.Name, "Titanium") then
            for _, obj in pairs(gui:GetDescendants()) do
                if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                    for _, skillName in pairs(CADU_CONFIG.skillNames) do
                        if obj.Name == skillName or obj.Text == skillName then
                            table.insert(buttons, obj)
                            break
                        end
                    end
                end
            end
        end
    end
    return buttons
end

local function activateSkillButton(button)
    if not button or not button.Parent then return end
    local key = tostring(button)
    if activatedSkills[key] and tick() - activatedSkills[key] < CADU_CONFIG.skillCooldown then return end
    activatedSkills[key] = tick()
    pcall(function()
        if button:IsA("GuiButton") then
            for _, conn in pairs(getconnections(button.MouseButton1Click)) do conn:Fire() end
            for _, conn in pairs(getconnections(button.Activated)) do conn:Fire() end
        end
    end)
end

-- ============================================
-- PARTE 3: INTERFACE
-- ============================================
local Window = Titanium:CreateWindow({
    Title = "TITANIUM HUB - CADUXX137",
    Size = UDim2.new(0, 400, 0, 550),
    ToggleKey = Enum.KeyCode.RightShift
})

-- Reach Section
local ReachSection = Window:AddSection("⚡ ALCANCE")

local ReachDisplay = Titanium:Create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 40),
    BackgroundTransparency = 1,
    Text = tostring(CADU_CONFIG.reach) .. " studs",
    TextColor3 = Titanium.Theme.Primary,
    Font = Enum.Font.GothamBold,
    TextSize = 28,
    TextXAlignment = Enum.TextXAlignment.Center
})
ReachDisplay.Parent = ReachSection.Container

Window:AddSlider(ReachSection, {
    Text = "Distância",
    Min = 1, Max = 50, Default = CADU_CONFIG.reach,
    Callback = function(value)
        CADU_CONFIG.reach = value
        ReachDisplay.Text = tostring(value) .. " studs"
    end
})

Window:AddToggle(ReachSection, {
    Text = "Mostrar Esfera Visual",
    Default = CADU_CONFIG.showReachSphere,
    Callback = function(state)
        CADU_CONFIG.showReachSphere = state
        Titanium:Notify("Reach", "Esfera " .. (state and "ativada" or "desativada"), 2)
    end
})

-- Controls Section
local ControlSection = Window:AddSection("🎮 CONTROLES")
Window:AddToggle(ControlSection, { Text = "Auto Touch", Default = CADU_CONFIG.autoTouch, Callback = function(s) CADU_CONFIG.autoTouch = s end })
Window:AddToggle(ControlSection, { Text = "Full Body Touch", Default = CADU_CONFIG.fullBodyTouch, Callback = function(s) CADU_CONFIG.fullBodyTouch = s end })
Window:AddToggle(ControlSection, { Text = "Double Touch", Default = CADU_CONFIG.autoSecondTouch, Callback = function(s) CADU_CONFIG.autoSecondTouch = s end })

-- Skills Section
local SkillsSection = Window:AddSection("⚽ AUTO SKILLS")
Window:AddToggle(SkillsSection, { Text = "Ativar Auto Skills", Default = CADU_CONFIG.autoSkills, Callback = function(s) CADU_CONFIG.autoSkills = s end })

local InfoLabel = Titanium:Create("TextLabel", {
    Size = UDim2.new(1, -20, 0, 30),
    BackgroundTransparency = 1,
    Text = "Detecta: Shoot, Pass, Dribble, Control...",
    TextColor3 = Titanium.Theme.TextDim,
    Font = Enum.Font.Gotham,
    TextSize = 11,
    TextWrapped = true
})
InfoLabel.Parent = SkillsSection.Container

-- Status Section
local StatusSection = Window:AddSection("📊 STATUS")
local BallsCountLabel = Titanium:Create("TextLabel", { Size = UDim2.new(1, -20, 0, 25), BackgroundTransparency = 1, Text = "Bolas: 0", TextColor3 = Titanium.Theme.Text, Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left })
BallsCountLabel.Parent = StatusSection.Container

local CharStatusLabel = Titanium:Create("TextLabel", { Size = UDim2.new(1, -20, 0, 25), Position = UDim2.new(0, 0, 0, 30), BackgroundTransparency = 1, Text = "Personagem: Aguardando...", TextColor3 = Titanium.Theme.Warning, Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left })
CharStatusLabel.Parent = StatusSection.Container

Window:AddButton(StatusSection, {
    Text = "Fechar Hub",
    Color = Titanium.Theme.Danger,
    Callback = function()
        Window.ScreenGui:Destroy()
        if reachSphere then reachSphere:Destroy() end
        for _, conn in pairs(ballConnections) do pcall(function() conn:Disconnect() end) end
    end
})

-- ============================================
-- PARTE 4: MAIN LOOP
-- ============================================
Titanium.Services.RunService.Heartbeat:Connect(function()
    updateCharacter()
    updateSphere()
    findBalls()

    local ballCount = #balls
    local hasChar = HRP ~= nil

    BallsCountLabel.Text = "Bolas: " .. ballCount

    if hasChar then
        CharStatusLabel.Text = "Personagem: Conectado ✓"
        CharStatusLabel.TextColor3 = Titanium.Theme.Success
        Window:SetStatus("🟢 Ativo | Bolas: " .. ballCount, Titanium.Theme.Success)
    else
        CharStatusLabel.Text = "Personagem: Aguardando..."
        CharStatusLabel.TextColor3 = Titanium.Theme.Warning
        Window:SetStatus("🟡 Aguardando...", Titanium.Theme.Warning)
    end

    if not HRP then return end

    local now = tick()
    if now - lastTouch < 0.05 then return end

    local hrpPos = HRP.Position
    local characterParts = getBodyParts()
    if #characterParts == 0 then return end

    local ballInRange, closestBall, closestDistance = false, nil, CADU_CONFIG.reach

    for _, ball in pairs(balls) do
        if ball and ball.Parent then
            local distance = (ball.Position - hrpPos).Magnitude
            if distance <= CADU_CONFIG.reach and distance < closestDistance then
                ballInRange = true
                closestDistance = distance
                closestBall = ball
            end
        end
    end

    if CADU_CONFIG.autoTouch and ballInRange and closestBall then
        lastTouch = now
        for _, part in pairs(characterParts) do doTouch(closestBall, part) end
    end

    if CADU_CONFIG.autoSkills and ballInRange and (now - lastSkillActivation > CADU_CONFIG.skillCooldown) then
        lastSkillActivation = now
        for _, button in pairs(findSkillButtons()) do
            for _, skill in pairs({"Shoot", "Pass", "Dribble", "Control"}) do
                if button.Name == skill or button.Text == skill then activateSkillButton(button) break end
            end
        end
    end
end)

spawn(function()
    while true do
        task.wait(5)
        local now = tick()
        for key, time in pairs(activatedSkills) do if now - time > 10 then activatedSkills[key] = nil end end
    end
end)

Titanium:Notify("TITANIUM HUB", "CADUXX137 v9.0 Loaded!", 4)
print("[TITANIUM HUB] Standalone Version Active")
