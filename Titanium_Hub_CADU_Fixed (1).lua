--[[
    ╔═══════════════════════════════════════════════════════════════╗
    ║                                                               ║
    ║   ████████╗██╗████████╗ █████╗ ███╗   ██╗██╗██╗   ██╗███████╗ ║
    ║   ╚══██╔══╝██║╚══██╔══╝██╔══██╗████╗  ██║██║██║   ██║██╔════╝ ║
    ║      ██║   ██║   ██║   ███████║██╔██╗ ██║██║██║   ██║█████╗   ║
    ║      ██║   ██║   ██║   ██╔══██║██║╚██╗██║██║╚██╗ ██╔╝██╔══╝   ║
    ║      ██║   ██║   ██║   ██║  ██║██║ ╚████║██║ ╚████╔╝ ███████╗ ║
    ║      ╚═╝   ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═══╝  ╚══════╝ ║
    ║                                                               ║
    ║   TITANIUM HUB v2.0 - CADUXX137 Integration                   ║
    ║   Theme: Cyberpunk Glassmorphism                              ║
    ║   Features: Auto Reach, Ball Touch, Skills, ESP               ║
    ║                                                               ║
    ╚═══════════════════════════════════════════════════════════════╝
]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")

-- ============================================
-- GUARD: LocalPlayer safety (fixes nil value error in executor/server context)
-- ============================================
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    LocalPlayer = Players:GetPropertyChangedSignal("LocalPlayer"):Wait() and Players.LocalPlayer
end
if not LocalPlayer then
    warn("[TITANIUM HUB] LocalPlayer not found. Must run as LocalScript.")
    return
end
local Mouse = LocalPlayer:GetMouse()

-- ============================================
-- CONFIGURAÇÕES DO CADUXX137 INTEGRADAS
-- ============================================
local CADU_CONFIG = {
    -- IDs das imagens do usuário
    iconImage = "rbxassetid://104616032736993",
    iconBackground = "rbxassetid://96755648876012",

    -- Configurações de Reach
    reach = 15,
    showReachSphere = true,
    autoTouch = true,
    fullBodyTouch = true,
    autoSecondTouch = true,
    scanCooldown = 1.5,

    -- Lista de bolas
    ballNames = { 
        "TPS", "TCS", "ESA", "MRS", "PRS", "MPS", "SSS", "AIFA", "RBZ",
        "Ball", "Soccer", "Football", "Basketball", "Baseball", 
        "BallTemplate", "GameBall", "Hitbox", "TouchPart", "GoalBall"
    },

    -- Auto Skills
    autoSkills = true,
    skillCooldown = 0.5,
    skillButtonNames = {
        "Shoot", "Pass", "Long", "Tackle", "Dribble", "GK", "Throw",
        "Control", "Left", "Right", "High", "Low", "Rainbow",
        "Chip", "Heel", "Volley", "Back Right", "Back Left",
        "Carry", "Fake Shot", "Drag Back", "Header", "Bicycle",
        "Shot", "Slide", "Goalkeeper", "Catch", "Punch",
        "Short Pass", "Through Ball", "Cross", "Curve",
        "Power Shot", "Precision", "First Touch"
    }
}

-- Variáveis globais do sistema CADU
local balls = {}
local ballConnections = {}
local reachSphere = nil
local HRP = nil
local char = nil
local touchDebounce = {}
local lastBallUpdate = 0
local lastTouch = 0
local lastSkillActivation = 0
local activatedSkills = {}

-- ============================================
-- TITANIUM HUB CORE
-- ============================================
local TitanHub = {
    Version = "2.0.0 - CADU Edition",
    Name = "TITANIUM HUB",
    Theme = {
        Background = Color3.fromRGB(10, 10, 15),
        Surface = Color3.fromRGB(20, 20, 30),
        SurfaceLight = Color3.fromRGB(30, 30, 45),
        Primary = Color3.fromRGB(0, 180, 255),
        Secondary = Color3.fromRGB(138, 43, 226),
        Accent = Color3.fromRGB(255, 215, 0),
        Success = Color3.fromRGB(0, 255, 128),
        Danger = Color3.fromRGB(255, 50, 100),
        Warning = Color3.fromRGB(255, 200, 0),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(150, 160, 180),
        Glass = Color3.fromRGB(255, 255, 255),

        NeonCyan = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 180, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 100, 255))
        }),
        DarkGlass = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 45)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25))
        })
    },

    Config = {
        UIScale = 1,
        Animations = true,
        ToggleKey = Enum.KeyCode.RightShift,
        Draggable = true,
        MobileMode = false
    },

    State = {
        Opened = true,
        Minimized = false,
        CurrentTab = "Reach",
        Notifications = {},
        Elements = {}
    },

    Icons = {
        Home = "rbxassetid://7733960981",
        User = "rbxassetid://7733955740",
        Settings = "rbxassetid://7734053495",
        Game = "rbxassetid://7733917120",
        Teleport = "rbxassetid://7734022102",
        Code = "rbxassetid://7733942651",
        Sparkles = "rbxassetid://7734182153",
        Zap = "rbxassetid://7734239257",
        Shield = "rbxassetid://7734045100",
        Search = "rbxassetid://7734052925",
        X = "rbxassetid://7733954760",
        Minimize = "rbxassetid://7733954058",
        Maximize = "rbxassetid://7733954246",
        ChevronRight = "rbxassetid://7733717447",
        ChevronDown = "rbxassetid://7733715400",
        Plus = "rbxassetid://7733954628",
        Trash = "rbxassetid://7734053031",
        Copy = "rbxassetid://7733954058",
        Check = "rbxassetid://7733715400",
        Alert = "rbxassetid://7733953987",
        Info = "rbxassetid://7733954044",
        Ball = "rbxassetid://7733917120",
        Target = "rbxassetid://7734022102"
    }
}

-- Utility Functions
local function Create(className, properties, children)
    local instance = Instance.new(className)
    if properties then
        for prop, value in pairs(properties) do
            instance[prop] = value
        end
    end
    if children then
        for _, child in ipairs(children) do
            child.Parent = instance
        end
    end
    return instance
end

local function Tween(instance, duration, properties, style, direction)
    style = style or Enum.EasingStyle.Quint
    direction = direction or Enum.EasingDirection.Out
    local tween = TweenService:Create(instance, TweenInfo.new(duration, style, direction), properties)
    tween:Play()
    return tween
end

local function notify(title, text, duration)
    duration = duration or 3
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "⚡ TITANIUM HUB",
            Text = text or "",
            Duration = duration
        })
    end)
end

-- ============================================
-- SISTEMA CADUXX137 - FUNÇÕES CORE
-- ============================================

local function updateCharacter()
    local newChar = LocalPlayer.Character
    if newChar ~= char then
        char = newChar
        if char then
            HRP = char:WaitForChild("HumanoidRootPart", 2)
            if HRP then
                notify("TITANIUM HUB", "Personagem detectado! Sistema ativo.", 2)
            end
        else
            HRP = nil
        end
    end
end

local function findBalls()
    local now = tick()
    if now - lastBallUpdate < CADU_CONFIG.scanCooldown then return #balls end
    lastBallUpdate = now

    table.clear(balls)
    for _, conn in ipairs(ballConnections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(ballConnections)

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Parent then
            for _, name in ipairs(CADU_CONFIG.ballNames) do
                if obj.Name == name or obj.Name:find(name) then
                    table.insert(balls, obj)
                    local conn = obj.AncestryChanged:Connect(function()
                        if not obj.Parent then findBalls() end
                    end)
                    table.insert(ballConnections, conn)
                    break
                end
            end
        end
    end

    return #balls
end

local function getBodyParts()
    if not char then return {} end
    local parts = {}
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") then
            if CADU_CONFIG.fullBodyTouch then
                table.insert(parts, part)
            elseif part.Name == "HumanoidRootPart" then
                table.insert(parts, part)
            end
        end
    end
    return parts
end

local function updateSphere()
    if not CADU_CONFIG.showReachSphere then
        if reachSphere then 
            reachSphere:Destroy() 
            reachSphere = nil 
        end
        return
    end

    if not reachSphere or not reachSphere.Parent then
        reachSphere = Instance.new("Part")
        reachSphere.Name = "Titanium_ReachSphere"
        reachSphere.Shape = Enum.PartType.Ball
        reachSphere.Anchored = true
        reachSphere.CanCollide = false
        reachSphere.Transparency = 0.88
        reachSphere.Material = Enum.Material.ForceField
        reachSphere.Color = TitanHub.Theme.Primary
        reachSphere.Parent = Workspace
    end

    if HRP and HRP.Parent then
        reachSphere.Position = HRP.Position
        reachSphere.Size = Vector3.new(CADU_CONFIG.reach * 2, CADU_CONFIG.reach * 2, CADU_CONFIG.reach * 2)
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

-- Sistema de Skills
local function findSkillButtons()
    local buttons = {}
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")

    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and not gui.Name:find("Titanium") then
            for _, obj in ipairs(gui:GetDescendants()) do
                if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                    for _, skillName in ipairs(CADU_CONFIG.skillButtonNames) do
                        if obj.Name == skillName or obj.Text == skillName or 
                           (obj.Name:lower():find(skillName:lower()) and #obj.Name < 30) then
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
    if activatedSkills[key] and tick() - activatedSkills[key] < CADU_CONFIG.skillCooldown then 
        return 
    end
    activatedSkills[key] = tick()

    pcall(function()
        if button:IsA("GuiButton") then
            for _, conn in ipairs(getconnections(button.MouseButton1Click)) do
                conn:Fire()
            end
            for _, conn in ipairs(getconnections(button.Activated)) do
                conn:Fire()
            end

            if button.MouseButton1Click then
                button.MouseButton1Click:Fire()
            end
            if button.Activated then
                button.Activated:Fire()
            end
        end
    end)
end

-- ============================================
-- TITANIUM HUB UI CREATION
-- ============================================

function TitanHub:CreateGlassFrame(parent, size, pos, cornerRadius)
    cornerRadius = cornerRadius or 16

    local glass = Create("ImageLabel", {
        Name = "GlassFrame",
        BackgroundTransparency = 1,
        Image = "rbxassetid://8992230677",
        ImageColor3 = self.Theme.Surface,
        ImageTransparency = 0.4,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(99, 99, 99, 99),
        Size = size or UDim2.new(1, 0, 1, 0),
        Position = pos or UDim2.new(0, 0, 0, 0),
        ClipsDescendants = true
    })

    Create("UICorner", {CornerRadius = UDim.new(0, cornerRadius)}).Parent = glass

    Create("UIStroke", {
        Color = self.Theme.Primary,
        Thickness = 1.5,
        Transparency = 0.7
    }).Parent = glass

    Create("UIGradient", {
        Color = self.Theme.DarkGlass,
        Rotation = 45,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.3),
            NumberSequenceKeypoint.new(1, 0.6)
        })
    }).Parent = glass

    glass.Parent = parent
    return glass
end

function TitanHub:CreateToggle(parent, config)
    config = config or {}
    local text = config.Text or "Toggle"
    local default = config.Default or false
    local callback = config.Callback or function() end

    local container = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 40)
    })
    container.Parent = parent

    local label = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = self.Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 15,
        Size = UDim2.new(1, -60, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left
    })
    label.Parent = container

    local switchBg = Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(50, 50, 60),
        BorderSizePixel = 0,
        Size = UDim2.new(0, 50, 0, 26),
        Position = UDim2.new(1, -50, 0.5, -13)
    })
    Create("UICorner", {CornerRadius = UDim.new(1, 0)}).Parent = switchBg

    local stroke = Create("UIStroke", {
        Color = default and self.Theme.Success or Color3.fromRGB(80, 80, 90),
        Thickness = 2,
        Transparency = 0.5
    })
    stroke.Parent = switchBg
    switchBg.Parent = container

    local circle = Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Size = UDim2.new(0, 20, 0, 20),
        Position = default and UDim2.new(1, -24, 0.5, -10) or UDim2.new(0, 4, 0.5, -10)
    })
    Create("UICorner", {CornerRadius = UDim.new(1, 0)}).Parent = circle
    circle.Parent = switchBg

    local state = default

    local clickDetector = Create("TextButton", {
        BackgroundTransparency = 1,
        Text = "",
        Size = UDim2.new(1, 0, 1, 0)
    })
    clickDetector.Parent = container

    clickDetector.MouseButton1Click:Connect(function()
        state = not state

        Tween(circle, 0.3, {Position = state and UDim2.new(1, -24, 0.5, -10) or UDim2.new(0, 4, 0.5, -10)})
        Tween(switchBg, 0.3, {BackgroundColor3 = state and Color3.fromRGB(0, 100, 80) or Color3.fromRGB(50, 50, 60)})
        Tween(stroke, 0.3, {Color = state and self.Theme.Success or Color3.fromRGB(80, 80, 90)})

        callback(state)
    end)

    return {
        Set = function(self, value)
            state = value
            Tween(circle, 0.3, {Position = state and UDim2.new(1, -24, 0.5, -10) or UDim2.new(0, 4, 0.5, -10)})
            Tween(switchBg, 0.3, {BackgroundColor3 = state and Color3.fromRGB(0, 100, 80) or Color3.fromRGB(50, 50, 60)})
            Tween(stroke, 0.3, {Color = state and self.Theme.Success or Color3.fromRGB(80, 80, 90)})
        end,
        Get = function() return state end
    }
end

function TitanHub:CreateSlider(parent, config)
    config = config or {}
    local text = config.Text or "Slider"
    local min = config.Min or 0
    local max = config.Max or 100
    local default = config.Default or min
    local callback = config.Callback or function() end

    local container = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 60)
    })
    container.Parent = parent

    local label = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = self.Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 15,
        Size = UDim2.new(0.7, 0, 0, 25),
        TextXAlignment = Enum.TextXAlignment.Left
    })
    label.Parent = container

    local valueLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = tostring(default),
        TextColor3 = self.Theme.Primary,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        Size = UDim2.new(0.3, 0, 0, 25),
        Position = UDim2.new(0.7, 0, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Right
    })
    valueLabel.Parent = container

    local track = Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(40, 40, 50),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 8),
        Position = UDim2.new(0, 0, 0, 35)
    })
    Create("UICorner", {CornerRadius = UDim.new(1, 0)}).Parent = track

    Create("UIStroke", {
        Color = self.Theme.Primary,
        Thickness = 1,
        Transparency = 0.6
    }).Parent = track
    track.Parent = container

    local fill = Create("Frame", {
        BackgroundColor3 = self.Theme.Primary,
        BorderSizePixel = 0,
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    })
    Create("UICorner", {CornerRadius = UDim.new(1, 0)}).Parent = fill
    fill.Parent = track

    local thumb = Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new((default - min) / (max - min), -9, 0.5, -9)
    })
    Create("UICorner", {CornerRadius = UDim.new(1, 0)}).Parent = thumb
    thumb.Parent = track

    local dragging = false

    local function update(input)
        local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (pos * (max - min)))

        Tween(fill, 0.1, {Size = UDim2.new(pos, 0, 1, 0)})
        Tween(thumb, 0.1, {Position = UDim2.new(pos, -9, 0.5, -9)})
        valueLabel.Text = tostring(value)

        callback(value)
    end

    thumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            Tween(thumb, 0.2, {Size = UDim2.new(0, 22, 0, 22)})
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            Tween(thumb, 0.2, {Size = UDim2.new(0, 18, 0, 18)})
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            update(input)
        end
    end)

    return {
        Set = function(self, value)
            local pos = (value - min) / (max - min)
            Tween(fill, 0.3, {Size = UDim2.new(pos, 0, 1, 0)})
            Tween(thumb, 0.3, {Position = UDim2.new(pos, -9, 0.5, -9)})
            valueLabel.Text = tostring(value)
        end
    }
end

function TitanHub:CreateButton(parent, config)
    config = config or {}
    local text = config.Text or "Button"
    local callback = config.Callback or function() end
    local color = config.Color or self.Theme.Primary

    local btn = self:CreateGlassFrame(parent, UDim2.new(1, -20, 0, 45), nil, 10)
    btn.Name = "Button"
    btn.UIStroke.Color = color
    btn.UIStroke.Transparency = 0.8

    local btnText = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = self.Theme.Text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 15,
        Size = UDim2.new(1, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Center
    })
    btnText.Parent = btn

    local clickDetector = Create("TextButton", {
        BackgroundTransparency = 1,
        Text = "",
        Size = UDim2.new(1, 0, 1, 0)
    })
    clickDetector.Parent = btn

    clickDetector.MouseEnter:Connect(function()
        Tween(btn, 0.2, {ImageTransparency = 0.2})
        Tween(btn.UIStroke, 0.2, {Transparency = 0.4})
    end)

    clickDetector.MouseLeave:Connect(function()
        Tween(btn, 0.2, {ImageTransparency = 0.4})
        Tween(btn.UIStroke, 0.2, {Transparency = 0.7})
    end)

    clickDetector.MouseButton1Click:Connect(function()
        local ripple = Create("Frame", {
            BackgroundColor3 = color,
            BackgroundTransparency = 0.5,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5)
        })
        Create("UICorner", {CornerRadius = UDim.new(1, 0)}).Parent = ripple
        ripple.Parent = btn

        Tween(ripple, 0.5, {Size = UDim2.new(1.5, 0, 1.5, 0), BackgroundTransparency = 1})
        game:GetService("Debris"):AddItem(ripple, 0.5)

        local success, err = pcall(callback)
        if not success then
            notify("Erro", tostring(err), 3)
        end
    end)

    return btn
end

-- ============================================
-- MAIN UI INITIALIZATION
-- ============================================

function TitanHub:Init()
    -- ScreenGui
    self.ScreenGui = Create("ScreenGui", {
        Name = "TitaniumHub_CADU",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    if syn and syn.protect_gui then
        syn.protect_gui(self.ScreenGui)
        self.ScreenGui.Parent = CoreGui  -- BUG FIX: syn.protect_gui only marks as protected, still needs parent
    elseif gethui then
        self.ScreenGui.Parent = gethui()
    else
        self.ScreenGui.Parent = CoreGui
    end

    -- Main Frame
    self.MainFrame = Create("Frame", {
        Name = "Main",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 400, 0, 550),
        Position = UDim2.new(0.5, -200, 0.5, -275),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Active = true,
        ClipsDescendants = true
    })
    self.MainFrame.Parent = self.ScreenGui

    -- Background
    local background = self:CreateGlassFrame(self.MainFrame, UDim2.new(1, 0, 1, 0), nil, 20)
    background.Name = "Background"
    background.ImageColor3 = self.Theme.Background
    background.ImageTransparency = 0.1

    -- Top Bar
    local topBar = Create("Frame", {
        Name = "TopBar",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 60)
    })
    topBar.Parent = self.MainFrame

    -- Title
    local title = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = self.Name,
        TextColor3 = self.Theme.Text,
        Font = Enum.Font.GothamBlack,
        TextSize = 24,
        Size = UDim2.new(0.6, 0, 0, 35),
        Position = UDim2.new(0, 20, 0, 5),
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local gradient = Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, self.Theme.Primary),
            ColorSequenceKeypoint.new(0.5, self.Theme.Secondary),
            ColorSequenceKeypoint.new(1, self.Theme.Accent)
        }),
        Rotation = 45
    })
    gradient.Parent = title
    title.Parent = topBar

    local subtitle = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = "CADUXX137 v9.0 Integration",
        TextColor3 = self.Theme.TextDim,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        Size = UDim2.new(0.6, 0, 0, 20),
        Position = UDim2.new(0, 20, 0, 38),
        TextXAlignment = Enum.TextXAlignment.Left
    })
    subtitle.Parent = topBar

    -- Close Button
    local closeBtn = Create("ImageButton", {
        BackgroundTransparency = 1,
        Image = self.Icons.X,
        ImageColor3 = self.Theme.Danger,
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -40, 0, 18)
    })
    closeBtn.Parent = topBar

    closeBtn.MouseEnter:Connect(function()
        Tween(closeBtn, 0.2, {ImageColor3 = Color3.fromRGB(255, 100, 100)})
    end)
    closeBtn.MouseLeave:Connect(function()
        Tween(closeBtn, 0.2, {ImageColor3 = self.Theme.Danger})
    end)
    closeBtn.MouseButton1Click:Connect(function()
        self:Close()
    end)

    -- Content Area
    self.ContentArea = Create("ScrollingFrame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -30, 1, -130),
        Position = UDim2.new(0, 15, 0, 70),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = self.Theme.Primary,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })

    local listLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 12),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    listLayout.Parent = self.ContentArea
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.ContentArea.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 20)
    end)

    self.ContentArea.Parent = self.MainFrame

    -- Status Bar
    local statusBar = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -30, 0, 40),
        Position = UDim2.new(0, 15, 1, -50)
    })
    statusBar.Parent = self.MainFrame

    self.StatusLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = "🟢 Sistema Ativo | Bolas: 0",
        TextColor3 = self.Theme.Success,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        Size = UDim2.new(1, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left
    })
    self.StatusLabel.Parent = statusBar

    -- Draggable
    local dragging = false
    local dragInput, dragStart, startPos

    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            self.MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- Toggle Key
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == self.Config.ToggleKey then
            self:Toggle()
        end
    end)

    -- Build UI Sections
    self:BuildReachSection()
    self:BuildControlsSection()
    self:BuildSkillsSection()
    self:BuildInfoSection()

    -- Animation
    self.MainFrame.Size = UDim2.new(0, 0, 0, 0)
    Tween(self.MainFrame, 0.5, {Size = UDim2.new(0, 400, 0, 550)}, Enum.EasingStyle.Back)

    notify("TITANIUM HUB", "CADUXX137 Integration Loaded!", 3)

    return self
end

function TitanHub:BuildReachSection()
    -- Section Header
    local section = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 180),
        LayoutOrder = 1
    })
    section.Parent = self.ContentArea

    local header = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = "⚡ ALCANCE (REACH)",
        TextColor3 = self.Theme.Primary,
        Font = Enum.Font.GothamBlack,
        TextSize = 16,
        Size = UDim2.new(1, 0, 0, 25),
        TextXAlignment = Enum.TextXAlignment.Left
    })
    header.Parent = section

    -- Reach Value Display
    local reachDisplay = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = tostring(CADU_CONFIG.reach),
        TextColor3 = self.Theme.Primary,
        Font = Enum.Font.GothamBlack,
        TextSize = 48,
        Size = UDim2.new(0.5, 0, 0, 60),
        Position = UDim2.new(0.5, 0, 0, 30),
        TextXAlignment = Enum.TextXAlignment.Right
    })
    reachDisplay.Parent = section

    local reachUnit = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = "studs",
        TextColor3 = self.Theme.TextDim,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        Size = UDim2.new(0.5, 0, 0, 20),
        Position = UDim2.new(0.5, 0, 0, 75),
        TextXAlignment = Enum.TextXAlignment.Right
    })
    reachUnit.Parent = section

    -- Reach Slider
    local reachSlider = self:CreateSlider(section, {
        Text = "Distância do Reach",
        Min = 1,
        Max = 50,
        Default = CADU_CONFIG.reach,
        Callback = function(value)
            CADU_CONFIG.reach = value
            reachDisplay.Text = tostring(value)
        end
    })
    reachSlider.Instance.Position = UDim2.new(0, 0, 0, 100)

    -- Show Sphere Toggle
    local sphereToggle = self:CreateToggle(section, {
        Text = "Mostrar Esfera Visual",
        Default = CADU_CONFIG.showReachSphere,
        Callback = function(state)
            CADU_CONFIG.showReachSphere = state
            notify("Reach", "Esfera " .. (state and "ativada" or "desativada"), 2)
        end
    })
    sphereToggle.Instance.Position = UDim2.new(0, 0, 0, 140)
end

function TitanHub:BuildControlsSection()
    local section = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 200),
        LayoutOrder = 2
    })
    section.Parent = self.ContentArea

    local header = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = "🎮 CONTROLES",
        TextColor3 = self.Theme.Primary,
        Font = Enum.Font.GothamBlack,
        TextSize = 16,
        Size = UDim2.new(1, 0, 0, 25),
        TextXAlignment = Enum.TextXAlignment.Left
    })
    header.Parent = section

    -- Auto Touch Toggle
    local autoTouchToggle = self:CreateToggle(section, {
        Text = "Auto Touch (Pegar Bolas)",
        Default = CADU_CONFIG.autoTouch,
        Callback = function(state)
            CADU_CONFIG.autoTouch = state
            notify("Auto Touch", state and "Ativado" or "Desativado", 2)
        end
    })
    autoTouchToggle.Instance.Position = UDim2.new(0, 0, 0, 35)

    -- Full Body Toggle
    local fullBodyToggle = self:CreateToggle(section, {
        Text = "Full Body Touch",
        Default = CADU_CONFIG.fullBodyTouch,
        Callback = function(state)
            CADU_CONFIG.fullBodyTouch = state
            notify("Full Body", state and "Ativado" or "Desativado", 2)
        end
    })
    fullBodyToggle.Instance.Position = UDim2.new(0, 0, 0, 80)

    -- Double Touch Toggle
    local doubleTouchToggle = self:CreateToggle(section, {
        Text = "Double Touch (2x toque)",
        Default = CADU_CONFIG.autoSecondTouch,
        Callback = function(state)
            CADU_CONFIG.autoSecondTouch = state
            notify("Double Touch", state and "Ativado" or "Desativado", 2)
        end
    })
    doubleTouchToggle.Instance.Position = UDim2.new(0, 0, 0, 125)
end

function TitanHub:BuildSkillsSection()
    local section = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 120),
        LayoutOrder = 3
    })
    section.Parent = self.ContentArea

    local header = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = "⚽ AUTO SKILLS",
        TextColor3 = self.Theme.Primary,
        Font = Enum.Font.GothamBlack,
        TextSize = 16,
        Size = UDim2.new(1, 0, 0, 25),
        TextXAlignment = Enum.TextXAlignment.Left
    })
    header.Parent = section

    -- Auto Skills Toggle
    local skillsToggle = self:CreateToggle(section, {
        Text = "Ativar Auto Skills",
        Default = CADU_CONFIG.autoSkills,
        Callback = function(state)
            CADU_CONFIG.autoSkills = state
            notify("Auto Skills", state and "Ativado" or "Desativado", 2)
        end
    })
    skillsToggle.Instance.Position = UDim2.new(0, 0, 0, 35)

    -- Info label
    local infoLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = "Detecta botões: Shoot, Pass, Dribble, etc.",
        TextColor3 = self.Theme.TextDim,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 80),
        TextXAlignment = Enum.TextXAlignment.Left
    })
    infoLabel.Parent = section
end

function TitanHub:BuildInfoSection()
    local section = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 150),
        LayoutOrder = 4
    })
    section.Parent = self.ContentArea

    local header = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = "📊 INFORMAÇÕES",
        TextColor3 = self.Theme.Primary,
        Font = Enum.Font.GothamBlack,
        TextSize = 16,
        Size = UDim2.new(1, 0, 0, 25),
        TextXAlignment = Enum.TextXAlignment.Left
    })
    header.Parent = section

    -- Balls Count
    self.BallsCountLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = "Bolas detectadas: 0",
        TextColor3 = self.Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        Size = UDim2.new(1, 0, 0, 25),
        Position = UDim2.new(0, 0, 0, 35),
        TextXAlignment = Enum.TextXAlignment.Left
    })
    self.BallsCountLabel.Parent = section

    -- Character Status
    self.CharStatusLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = "Personagem: Aguardando...",
        TextColor3 = self.Theme.Warning,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 65),
        TextXAlignment = Enum.TextXAlignment.Left
    })
    self.CharStatusLabel.Parent = section

    -- Keybind Info
    local keybindInfo = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = "Tecla para abrir/fechar: " .. self.Config.ToggleKey.Name,
        TextColor3 = self.Theme.TextDim,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 95),
        TextXAlignment = Enum.TextXAlignment.Left
    })
    keybindInfo.Parent = section

    -- Close Button
    local closeHubBtn = self:CreateButton(section, {
        Text = "Fechar Hub",
        Color = self.Theme.Danger,
        Callback = function()
            self:Close()
        end
    })
    closeHubBtn.Position = UDim2.new(0, 0, 0, 120)
end

function TitanHub:Toggle()
    self.State.Opened = not self.State.Opened

    if self.State.Opened then
        self.MainFrame.Visible = true
        Tween(self.MainFrame, 0.4, {Size = UDim2.new(0, 400, 0, 550)}, Enum.EasingStyle.Back)
    else
        Tween(self.MainFrame, 0.3, {Size = UDim2.new(0, 0, 0, 0)}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        wait(0.3)
        self.MainFrame.Visible = false
    end
end

function TitanHub:Close()
    Tween(self.MainFrame, 0.3, {Size = UDim2.new(0, 0, 0, 0)})
    wait(0.3)
    self.ScreenGui:Destroy()
    if reachSphere then reachSphere:Destroy() end
    for _, conn in ipairs(ballConnections) do
        pcall(function() conn:Disconnect() end)
    end
end

function TitanHub:UpdateStatus()
    if not self.StatusLabel or not self.StatusLabel.Parent then return end

    local ballCount = #balls
    local hasChar = HRP ~= nil

    self.StatusLabel.Text = string.format("%s Sistema %s | Bolas: %d", 
        hasChar and "🟢" or "🟡",
        hasChar and "Ativo" or "Aguardando",
        ballCount
    )
    self.StatusLabel.TextColor3 = hasChar and self.Theme.Success or self.Theme.Warning

    if self.BallsCountLabel then
        self.BallsCountLabel.Text = "Bolas detectadas: " .. ballCount
    end

    if self.CharStatusLabel then
        if hasChar then
            self.CharStatusLabel.Text = "Personagem: Conectado ✓"
            self.CharStatusLabel.TextColor3 = self.Theme.Success
        else
            self.CharStatusLabel.Text = "Personagem: Aguardando..."
            self.CharStatusLabel.TextColor3 = self.Theme.Warning
        end
    end
end

-- ============================================
-- MAIN LOOP
-- ============================================

-- Initialize Hub
local Hub = TitanHub:Init()

-- Main Loop
RunService.Heartbeat:Connect(function()
    updateCharacter()
    updateSphere()
    findBalls()
    Hub:UpdateStatus()

    if not HRP then return end

    local now = tick()
    if now - lastTouch < 0.05 then return end

    local hrpPos = HRP.Position
    local characterParts = getBodyParts()
    if #characterParts == 0 then return end

    local ballInRange = false
    local closestBall = nil
    local closestDistance = CADU_CONFIG.reach

    for _, ball in ipairs(balls) do
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

        for _, part in ipairs(characterParts) do
            doTouch(closestBall, part)
        end
    end

    if CADU_CONFIG.autoSkills and ballInRange and (now - lastSkillActivation > CADU_CONFIG.skillCooldown) then
        lastSkillActivation = now

        local skillButtons = findSkillButtons()
        local mainSkills = {"Shoot", "Pass", "Dribble", "Control"}

        for _, button in ipairs(skillButtons) do
            for _, mainSkill in ipairs(mainSkills) do
                if button.Name == mainSkill or button.Text == mainSkill then
                    activateSkillButton(button)
                    break
                end
            end
        end
    end
end)

-- Cleanup
spawn(function()
    while true do
        task.wait(5)
        local now = tick()
        for key, time in pairs(activatedSkills) do
            if now - time > 10 then
                activatedSkills[key] = nil
            end
        end
    end
end)

print([[
    ╔═══════════════════════════════════════════════════════════════╗
    ║                                                               ║
    ║         TITANIUM HUB v2.0 - CADUXX137 LOADED                  ║
    ║                                                               ║
    ╚═══════════════════════════════════════════════════════════════╝
]])
