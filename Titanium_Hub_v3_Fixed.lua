--[[
 ╔═══════════════════════════════════════════════════════════════╗
 ║                                                               ║
 ║ ████████╗██╗████████╗ █████╗ ███╗   ██╗██╗██╗   ██╗███████╗ ║
 ║ ╚══██╔══╝██║╚══██╔══╝██╔══██╗████╗  ██║██║██║   ██║██╔════╝ ║
 ║    ██║   ██║   ██║   ███████║██╔██╗ ██║██║██║   ██║█████╗   ║
 ║    ██║   ██║   ██║   ██╔══██║██║╚██╗██║██║╚██╗ ██╔╝██╔══╝   ║
 ║    ██║   ██║   ██║   ██║  ██║██║ ╚████║██║ ╚████╔╝ ███████╗ ║
 ║    ╚═╝   ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═══╝  ╚══════╝ ║
 ║                                                               ║
 ║         TITANIUM HUB v4.0 - MOBILE EDITION                    ║
 ║              Full Screen Adaptive | Material Design           ║
 ║                                                               ║
 ╚═══════════════════════════════════════════════════════════════╝
]]

-- ============================================
-- SERVIÇOS E CONFIGURAÇÕES MOBILE
-- ============================================

local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    Workspace = game:GetService("Workspace"),
    TweenService = game:GetService("TweenService"),
    StarterGui = game:GetService("StarterGui"),
    CoreGui = game:GetService("CoreGui"),
    Debris = game:GetService("Debris"),
    GuiService = game:GetService("GuiService"),
    ContextActionService = game:GetService("ContextActionService")
}

-- Detecção de dispositivo
local IS_MOBILE = Services.UserInputService.TouchEnabled and not Services.UserInputService.KeyboardEnabled
local SCREEN_SIZE = Services.GuiService.AbsoluteWindowSize
local IS_PORTRAIT = SCREEN_SIZE.Y > SCREEN_SIZE.X

-- CORREÇÃO: Aguarda LocalPlayer de forma segura
local LocalPlayer
local function GetLocalPlayer()
    if Services.Players.LocalPlayer then
        return Services.Players.LocalPlayer
    end
    
    local startTime = tick()
    while not Services.Players.LocalPlayer and (tick() - startTime) < 10 do
        task.wait(0.1)
    end
    
    return Services.Players.LocalPlayer
end

LocalPlayer = GetLocalPlayer()
if not LocalPlayer then
    warn("[TITANIUM HUB v4.0] Falha crítica: LocalPlayer não encontrado")
    return
end

-- ============================================
-- CONFIGURAÇÕES RESPONSIVAS
-- ============================================

local CONFIG = {
    -- Mobile detection
    isMobile = IS_MOBILE,
    isPortrait = IS_PORTRAIT,
    
    -- Dimensions responsivas
    frameWidth = IS_MOBILE and (IS_PORTRAIT and 360 or 480) or 450,
    frameHeight = IS_MOBILE and (IS_PORTRAIT and 600 or 400) or 550,
    
    -- Posicionamento
    position = IS_MOBILE and UDim2.new(0.5, 0, 0.5, 0) or UDim2.new(0.5, -225, 0.5, -275),
    
    -- Cores Material Design 3
    colors = {
        background = Color3.fromRGB(30, 30, 35),
        surface = Color3.fromRGB(45, 45, 55),
        surfaceVariant = Color3.fromRGB(55, 55, 70),
        primary = Color3.fromRGB(100, 200, 255),
        primaryContainer = Color3.fromRGB(40, 80, 120),
        secondary = Color3.fromRGB(180, 140, 255),
        secondaryContainer = Color3.fromRGB(60, 50, 90),
        accent = Color3.fromRGB(255, 200, 100),
        success = Color3.fromRGB(100, 220, 150),
        warning = Color3.fromRGB(255, 200, 100),
        error = Color3.fromRGB(255, 120, 120),
        text = Color3.fromRGB(255, 255, 255),
        textSecondary = Color3.fromRGB(180, 180, 190),
        outline = Color3.fromRGB(80, 80, 90)
    },
    
    -- CADU Config
    reach = 15,
    showReachSphere = true,
    autoTouch = true,
    fullBodyTouch = true,
    autoSecondTouch = true,
    scanCooldown = 1.5,
    
    ballNames = {
        "TPS", "TCS", "ESA", "MRS", "PRS", "MPS", "SSS", "AIFA", "RBZ",
        "Ball", "Soccer", "Football", "Basketball", "Baseball",
        "BallTemplate", "GameBall", "Hitbox", "TouchPart", "GoalBall",
        "Bola", "Pelota", "Balloon", "Sphere", "Part", "Ball"
    },
    
    autoSkills = true,
    skillCooldown = 0.5,
    skillButtonNames = {
        "Shoot", "Pass", "Long", "Tackle", "Dribble", "GK", "Throw",
        "Control", "Left", "Right", "High", "Low", "Rainbow",
        "Chip", "Heel", "Volley", "Back Right", "Back Left",
        "Carry", "Fake Shot", "Drag Back", "Header", "Bicycle",
        "Shot", "Slide", "Goalkeeper", "Catch", "Punch",
        "Short Pass", "Through Ball", "Cross", "Curve",
        "Power Shot", "Precision", "First Touch", "Kick", "Dash"
    }
}

-- Estado global
local State = {
    balls = {},
    ballConnections = {},
    reachSphere = nil,
    HRP = nil,
    character = nil,
    touchDebounce = {},
    lastBallUpdate = 0,
    lastTouch = 0,
    lastSkillActivation = 0,
    activatedSkills = {},
    isRunning = true,
    currentTab = "Main",
    isMinimized = false,
    notifications = {}
}

-- ============================================
-- SISTEMA DE NOTIFICAÇÃO AVANÇADO
-- ============================================

local NotificationSystem = {
    active = {},
    queue = {},
    maxVisible = 3
}

function NotificationSystem:Show(title, message, duration, type)
    duration = duration or 3
    type = type or "info"
    
    local colors = {
        info = CONFIG.colors.primary,
        success = CONFIG.colors.success,
        warning = CONFIG.colors.warning,
        error = CONFIG.colors.error
    }
    
    local icons = {
        info = "🔔",
        success = "✅",
        warning = "⚠️",
        error = "❌"
    }
    
    -- Criar notificação
    local notif = {
        title = title,
        message = message,
        duration = duration,
        color = colors[type],
        icon = icons[type],
        startTime = tick()
    }
    
    table.insert(self.queue, notif)
    self:ProcessQueue()
end

function NotificationSystem:ProcessQueue()
    -- Implementação da UI de notificação será no Init
end

local function notify(title, text, duration, type)
    NotificationSystem:Show(title, text, duration, type)
    pcall(function()
        Services.StarterGui:SetCore("SendNotification", {
            Title = title or "⚡ TITANIUM HUB",
            Text = text or "",
            Duration = duration or 3
        })
    end)
end

-- ============================================
-- FUNÇÕES UTILITÁRIAS
-- ============================================

local function Create(className, properties)
    local instance = Instance.new(className)
    if properties then
        for prop, value in pairs(properties) do
            pcall(function()
                instance[prop] = value
            end)
        end
    end
    return instance
end

local function Tween(instance, duration, properties, style, direction)
    if not instance or not instance.Parent then return nil end
    style = style or Enum.EasingStyle.Quint
    direction = direction or Enum.EasingDirection.Out
    
    local success, tween = pcall(function()
        return Services.TweenService:Create(
            instance, 
            TweenInfo.new(duration, style, direction), 
            properties
        )
    end)
    
    if success and tween then
        tween:Play()
        return tween
    end
    return nil
end

local function RippleEffect(parent, x, y, color)
    color = color or CONFIG.colors.primary
    
    local ripple = Create("Frame", {
        BackgroundColor3 = color,
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0, x, 0, y),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 100,
        Parent = parent
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = ripple
    })
    
    Tween(ripple, 0.6, {
        Size = UDim2.new(0, 200, 0, 200),
        BackgroundTransparency = 1
    })
    
    Services.Debris:AddItem(ripple, 0.6)
end

-- ============================================
-- TITANIUM HUB v4.0 - INTERFACE MOBILE
-- ============================================

local TitaniumHub = {
    Version = "4.0.0 Mobile",
    Name = "TITANIUM HUB",
    
    UI = {
        ScreenGui = nil,
        MainFrame = nil,
        BackgroundFrame = nil,
        TopBar = nil,
        TabBar = nil,
        ContentFrame = nil,
        Pages = {},
        BottomBar = nil,
        FloatButton = nil,
        NotificationContainer = nil
    },
    
    Tabs = {
        {Name = "Main", Icon = "rbxassetid://7733960981", Label = "Principal"},
        {Name = "Reach", Icon = "rbxassetid://7734022102", Label = "Alcance"},
        {Name = "Skills", Icon = "rbxassetid://7733917120", Label = "Skills"},
        {Name = "ESP", Icon = "rbxassetid://7734053495", Label = "Visual"},
        {Name = "Settings", Icon = "rbxassetid://7734053495", Label = "Config"}
    }
}

-- ============================================
-- SISTEMA CADU - FUNÇÕES CORE
-- ============================================

local function updateCharacter()
    local newChar = LocalPlayer.Character
    if newChar ~= State.character then
        State.character = newChar
        
        if newChar then
            local startTime = tick()
            repeat
                State.HRP = newChar:FindFirstChild("HumanoidRootPart")
                task.wait(0.1)
            until State.HRP or (tick() - startTime) > 5
            
            if State.HRP then
                notify("Sistema", "Personagem conectado!", 2, "success")
            end
        else
            State.HRP = nil
        end
    end
end

local function findBalls()
    local now = tick()
    if now - State.lastBallUpdate < CONFIG.scanCooldown then 
        return #State.balls 
    end
    
    State.lastBallUpdate = now
    table.clear(State.balls)
    
    for _, conn in ipairs(State.ballConnections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(State.ballConnections)

    for _, obj in ipairs(Services.Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Parent then
            for _, name in ipairs(CONFIG.ballNames) do
                if obj.Name == name or obj.Name:find(name, 1, true) then
                    table.insert(State.balls, obj)
                    
                    local conn = obj.AncestryChanged:Connect(function(_, parent)
                        if not parent then 
                            task.delay(0.1, findBalls)
                        end
                    end)
                    
                    table.insert(State.ballConnections, conn)
                    break
                end
            end
        end
    end

    return #State.balls
end

local function getBodyParts()
    if not State.character then return {} end
    
    local parts = {}
    for _, part in ipairs(State.character:GetChildren()) do
        if part:IsA("BasePart") then
            if CONFIG.fullBodyTouch then
                table.insert(parts, part)
            elseif part.Name == "HumanoidRootPart" then
                table.insert(parts, part)
                break
            end
        end
    end
    return parts
end

local function updateSphere()
    if not CONFIG.showReachSphere then
        if State.reachSphere then
            State.reachSphere:Destroy()
            State.reachSphere = nil
        end
        return
    end

    if not State.reachSphere or not State.reachSphere.Parent then
        State.reachSphere = Create("Part", {
            Name = "Titanium_ReachSphere",
            Shape = Enum.PartType.Ball,
            Anchored = true,
            CanCollide = false,
            Transparency = 0.85,
            Material = Enum.Material.ForceField,
            Color = CONFIG.colors.primary,
            Parent = Services.Workspace
        })
    end

    if State.HRP and State.HRP.Parent then
        local reach = CONFIG.reach
        State.reachSphere.Position = State.HRP.Position
        State.reachSphere.Size = Vector3.new(reach * 2, reach * 2, reach * 2)
    end
end

local function doTouch(ball, part)
    if not ball or not ball.Parent or not part or not part.Parent then 
        return 
    end

    local key = ball.Name .. "_" .. part.Name .. "_" .. tostring(tick())
    
    if State.touchDebounce[key] and (tick() - State.touchDebounce[key]) < 0.1 then 
        return 
    end
    
    State.touchDebounce[key] = tick()

    pcall(function()
        firetouchinterest(ball, part, 0)
        task.wait(0.01)
        firetouchinterest(ball, part, 1)

        if CONFIG.autoSecondTouch then
            task.wait(0.05)
            firetouchinterest(ball, part, 0)
            firetouchinterest(ball, part, 1)
        end
    end)
end

local function findSkillButtons()
    local buttons = {}
    local playerGui = LocalPlayer:WaitForChild("PlayerGui", 5)
    if not playerGui then return buttons end

    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and not gui.Name:find("Titanium") then
            for _, obj in ipairs(gui:GetDescendants()) do
                if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                    local objName = obj.Name
                    local objText = obj:IsA("TextButton") and obj.Text or ""
                    
                    for _, skillName in ipairs(CONFIG.skillButtonNames) do
                        local skillLower = skillName:lower()
                        if objName == skillName or objText == skillName or
                           objName:lower():find(skillLower) or 
                           objText:lower():find(skillLower) then
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
    local now = tick()
    
    if State.activatedSkills[key] and (now - State.activatedSkills[key]) < CONFIG.skillCooldown then
        return
    end
    
    State.activatedSkills[key] = now

    pcall(function()
        if button:IsA("GuiButton") then
            local success1, connections1 = pcall(function()
                return getconnections(button.MouseButton1Click)
            end)
            
            if success1 then
                for _, conn in ipairs(connections1) do
                    pcall(function() conn:Fire() end)
                end
            end
            
            pcall(function() button.MouseButton1Click:Fire() end)
            pcall(function() button.Activated:Fire() end)
        end
    end)
end

-- ============================================
-- COMPONENTES UI AVANÇADOS
-- ============================================

function TitaniumHub:CreateCard(parent, config)
    config = config or {}
    
    local card = Create("Frame", {
        Name = config.Name or "Card",
        BackgroundColor3 = CONFIG.colors.surface,
        BorderSizePixel = 0,
        Size = config.Size or UDim2.new(1, -20, 0, 80),
        Position = config.Position or UDim2.new(0, 10, 0, 0),
        ClipsDescendants = true,
        Parent = parent
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 16),
        Parent = card
    })
    
    Create("UIStroke", {
        Color = CONFIG.colors.outline,
        Thickness = 1,
        Transparency = 0.5,
        Parent = card
    })
    
    if config.Title then
        local title = Create("TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            Text = config.Title,
            TextColor3 = CONFIG.colors.text,
            Font = Enum.Font.GothamBold,
            TextSize = 16,
            Size = UDim2.new(1, -20, 0, 25),
            Position = UDim2.new(0, 15, 0, 12),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = card
        })
    end
    
    -- Efeito de elevação ao tocar
    card.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or 
           input.UserInputType == Enum.UserInputType.MouseButton1 then
            Tween(card, 0.2, {BackgroundColor3 = CONFIG.colors.surfaceVariant})
        end
    end)
    
    card.InputEnded:Connect(function()
        Tween(card, 0.2, {BackgroundColor3 = CONFIG.colors.surface})
    end)
    
    return card
end

function TitaniumHub:CreateModernToggle(parent, config)
    config = config or {}
    local text = config.Text or "Toggle"
    local default = config.Default or false
    local callback = config.Callback or function() end
    
    local container = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -30, 0, 55),
        Parent = parent
    })
    
    -- Label
    local label = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = CONFIG.colors.text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 15,
        Size = UDim2.new(1, -70, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = container
    })
    
    -- Track do switch
    local switchWidth = 52
    local switchHeight = 32
    
    local switchBg = Create("Frame", {
        BackgroundColor3 = default and CONFIG.colors.primary or CONFIG.colors.outline,
        BorderSizePixel = 0,
        Size = UDim2.new(0, switchWidth, 0, switchHeight),
        Position = UDim2.new(1, -switchWidth, 0.5, -switchHeight/2),
        Parent = container
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = switchBg
    })
    
    -- Thumb (círculo que se move)
    local thumbSize = 26
    local thumb = Create("Frame", {
        Name = "Thumb",
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Size = UDim2.new(0, thumbSize, 0, thumbSize),
        Position = default and 
            UDim2.new(1, -thumbSize-3, 0.5, -thumbSize/2) or 
            UDim2.new(0, 3, 0.5, -thumbSize/2),
        Parent = switchBg
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = thumb
    })
    
    -- Sombra do thumb
    Create("UIStroke", {
        Color = Color3.fromRGB(0, 0, 0),
        Thickness = 1,
        Transparency = 0.9,
        Parent = thumb
    })
    
    local state = default
    
    local function updateVisual()
        local targetPos = state and 
            UDim2.new(1, -thumbSize-3, 0.5, -thumbSize/2) or 
            UDim2.new(0, 3, 0.5, -thumbSize/2)
        
        local targetColor = state and CONFIG.colors.primary or CONFIG.colors.outline
        
        Tween(thumb, 0.25, {
            Position = targetPos
        }, Enum.EasingStyle.Quart)
        
        Tween(switchBg, 0.25, {
            BackgroundColor3 = targetColor
        }, Enum.EasingStyle.Quart)
    end
    
    -- Área de clique expandida
    local clickArea = Create("TextButton", {
        BackgroundTransparency = 1,
        Text = "",
        Size = UDim2.new(1, 0, 1, 0),
        Parent = container
    })
    
    clickArea.MouseButton1Click:Connect(function()
        state = not state
        updateVisual()
        callback(state)
        
        -- Haptic feedback se disponível
        pcall(function()
            Services.UserInputService:SetHapticFeedbackEnabled(true)
        end)
    end)
    
        -- Touch ripple
    clickArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            local pos = input.Position
            local relativePos = Vector2.new(pos.X, pos.Y) - switchBg.AbsolutePosition
            RippleEffect(switchBg, relativePos.X, relativePos.Y, CONFIG.colors.primary)
        end
    end)
    
    return {
        Instance = container,
        Set = function(_, value)
            state = value
            updateVisual()
        end,
        Get = function() return state end
    }
end

function TitaniumHub:CreateModernSlider(parent, config)
    config = config or {}
    local text = config.Text or "Slider"
    local min = config.Min or 0
    local max = config.Max or 100
    local default = math.clamp(config.Default or min, min, max)
    local suffix = config.Suffix or ""
    local callback = config.Callback or function() end
    
    local container = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -30, 0, 70),
        Parent = parent
    })
    
    -- Header com título e valor
    local header = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 25),
        Parent = container
    })
    
    local titleLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = CONFIG.colors.text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 15,
        Size = UDim2.new(0.6, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header
    })
    
    local valueLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = tostring(default) .. suffix,
        TextColor3 = CONFIG.colors.primary,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        Size = UDim2.new(0.4, 0, 1, 0),
        Position = UDim2.new(0.6, 0, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = header
    })
    
    -- Track container
    local trackContainer = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 35),
        Parent = container
    })
    
    -- Track background
    local trackHeight = 8
    local track = Create("Frame", {
        BackgroundColor3 = CONFIG.colors.outline,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, trackHeight),
        Position = UDim2.new(0, 0, 0.5, -trackHeight/2),
        Parent = trackContainer
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = track
    })
    
    -- Fill
    local fillPercent = (default - min) / (max - min)
    local fill = Create("Frame", {
        BackgroundColor3 = CONFIG.colors.primary,
        BorderSizePixel = 0,
        Size = UDim2.new(fillPercent, 0, 1, 0),
        Parent = track
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = fill
    })
    
    -- Thumb maior e mais fácil de pegar em mobile
    local thumbSize = 24
    local thumb = Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Size = UDim2.new(0, thumbSize, 0, thumbSize),
        Position = UDim2.new(fillPercent, -thumbSize/2, 0.5, -thumbSize/2),
        ZIndex = 5,
        Parent = track
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = thumb
    })
    
    -- Sombra do thumb
    Create("UIStroke", {
        Color = Color3.fromRGB(0, 0, 0),
        Thickness = 2,
        Transparency = 0.8,
        Parent = thumb
    })
    
    -- Glow effect
    local glow = Create("Frame", {
        BackgroundColor3 = CONFIG.colors.primary,
        BackgroundTransparency = 0.8,
        BorderSizePixel = 0,
        Size = UDim2.new(1.5, 0, 1.5, 0),
        Position = UDim2.new(-0.25, 0, -0.25, 0),
        ZIndex = 4,
        Visible = false,
        Parent = thumb
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = glow
    })
    
    local dragging = false
    
    local function updateFromInput(input)
        local trackAbsPos = track.AbsolutePosition.X
        local trackAbsSize = track.AbsoluteSize.X
        
        if trackAbsSize <= 0 then return end
        
        local pos = math.clamp((input.Position.X - trackAbsPos) / trackAbsSize, 0, 1)
        local value = math.floor(min + (pos * (max - min)))
        
        fill.Size = UDim2.new(pos, 0, 1, 0)
        thumb.Position = UDim2.new(pos, -thumbSize/2, 0.5, -thumbSize/2)
        valueLabel.Text = tostring(value) .. suffix
        
        callback(value)
        return value
    end
    
    -- Eventos de input
    thumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or 
           input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            glow.Visible = true
            Tween(thumb, 0.15, {Size = UDim2.new(0, thumbSize + 8, 0, thumbSize + 8)})
            Tween(glow, 0.15, {BackgroundTransparency = 0.5})
        end
    end)
    
    Services.UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or 
           input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            glow.Visible = false
            Tween(thumb, 0.15, {Size = UDim2.new(0, thumbSize, 0, thumbSize)})
        end
    end)
    
    Services.UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                        input.UserInputType == Enum.UserInputType.Touch) then
            updateFromInput(input)
        end
    end)
    
    -- Click na track para pular
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or 
           input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateFromInput(input)
            
            -- Animação de ripple
            local relativeX = input.Position.X - track.AbsolutePosition.X
            RippleEffect(track, relativeX, track.AbsoluteSize.Y/2, CONFIG.colors.primary)
        end
    end)
    
    return {
        Instance = container,
        Set = function(_, value)
            local clamped = math.clamp(value, min, max)
            local pos = (clamped - min) / (max - min)
            Tween(fill, 0.3, {Size = UDim2.new(pos, 0, 1, 0)})
            Tween(thumb, 0.3, {Position = UDim2.new(pos, -thumbSize/2, 0.5, -thumbSize/2)})
            valueLabel.Text = tostring(clamped) .. suffix
        end
    }
end

function TitaniumHub:CreateModernButton(parent, config)
    config = config or {}
    local text = config.Text or "Button"
    local icon = config.Icon
    local callback = config.Callback or function() end
    local style = config.Style or "filled" -- filled, outlined, text
    local color = config.Color or CONFIG.colors.primary
    
    local height = config.Height or 50
    
    local btn = Create("Frame", {
        BackgroundColor3 = style == "filled" and color or CONFIG.colors.surface,
        BackgroundTransparency = style == "text" and 1 or 0,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -30, 0, height),
        Position = config.Position or UDim2.new(0, 15, 0, 0),
        ClipsDescendants = true,
        Parent = parent
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 12),
        Parent = btn
    })
    
    if style == "outlined" then
        Create("UIStroke", {
            Color = color,
            Thickness = 2,
            Parent = btn
        })
    end
    
    -- Conteúdo
    local contentPadding = 16
    
    local label = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = style == "filled" and Color3.fromRGB(0, 0, 0) or color,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        Size = UDim2.new(1, -contentPadding * 2, 1, 0),
        Position = UDim2.new(0, contentPadding, 0, 0),
        TextXAlignment = icon and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center,
        Parent = btn
    })
    
    if icon then
        local iconImg = Create("ImageLabel", {
            BackgroundTransparency = 1,
            Image = icon,
            ImageColor3 = style == "filled" and Color3.fromRGB(0, 0, 0) or color,
            Size = UDim2.new(0, 24, 0, 24),
            Position = UDim2.new(1, -40, 0.5, -12),
            Parent = btn
        })
    end
    
    -- Interatividade
    local clickArea = Create("TextButton", {
        BackgroundTransparency = 1,
        Text = "",
        Size = UDim2.new(1, 0, 1, 0),
        Parent = btn
    })
    
    local originalColor = btn.BackgroundColor3
    
    clickArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or 
           input.UserInputType == Enum.UserInputType.MouseButton1 then
            Tween(btn, 0.1, {
                BackgroundColor3 = style == "filled" and 
                    color:Lerp(Color3.fromRGB(0, 0, 0), 0.2) or 
                    CONFIG.colors.surfaceVariant
            })
            
            local pos = Vector2.new(input.Position.X, input.Position.Y) - btn.AbsolutePosition
            RippleEffect(btn, pos.X, pos.Y, color)
        end
    end)
    
    clickArea.InputEnded:Connect(function()
        Tween(btn, 0.2, {BackgroundColor3 = originalColor})
    end)
    
    clickArea.MouseButton1Click:Connect(function()
        local success, err = pcall(callback)
        if not success then
            notify("Erro", tostring(err), 3, "error")
        end
    end)
    
    return btn
end

function TitaniumHub:CreateSegmentedControl(parent, config)
    config = config or {}
    local options = config.Options or {"Opção 1", "Opção 2"}
    local default = config.Default or 1
    local callback = config.Callback or function() end
    
    local container = Create("Frame", {
        BackgroundColor3 = CONFIG.colors.surfaceVariant,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -30, 0, 44),
        Parent = parent
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = container
    })
    
    local padding = 4
    local optionWidth = 1 / #options
    
    local indicators = {}
    local buttons = {}
    
    for i, option in ipairs(options) do
        local btn = Create("TextButton", {
            Name = "Option_" .. i,
            BackgroundTransparency = 1,
            Text = option,
            TextColor3 = i == default and CONFIG.colors.primary or CONFIG.colors.textSecondary,
            Font = i == default and Enum.Font.GothamBold or Enum.Font.GothamMedium,
            TextSize = 13,
            Size = UDim2.new(optionWidth, 0, 1, 0),
            Position = UDim2.new((i-1) * optionWidth, 0, 0, 0),
            Parent = container
        })
        
        table.insert(buttons, btn)
        
        btn.MouseButton1Click:Connect(function()
            -- Atualiza visual
            for j, b in ipairs(buttons) do
                if j == i then
                    Tween(b, 0.2, {TextColor3 = CONFIG.colors.primary})
                    b.Font = Enum.Font.GothamBold
                else
                    Tween(b, 0.2, {TextColor3 = CONFIG.colors.textSecondary})
                    b.Font = Enum.Font.GothamMedium
                end
            end
            
            -- Move indicador
            Tween(indicators[1], 0.3, {
                Position = UDim2.new((i-1) * optionWidth, padding, 0, padding),
                Size = UDim2.new(optionWidth, -padding * 2, 1, -padding * 2)
            }, Enum.EasingStyle.Quart)
            
            callback(i, option)
        end)
    end
    
    -- Indicador de seleção
    local indicator = Create("Frame", {
        Name = "Indicator",
        BackgroundColor3 = CONFIG.colors.surface,
        BorderSizePixel = 0,
        Size = UDim2.new(optionWidth, -padding * 2, 1, -padding * 2),
        Position = UDim2.new((default-1) * optionWidth, padding, 0, padding),
        ZIndex = 0,
        Parent = container
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = indicator
    })
    
    table.insert(indicators, indicator)
    
    return {
        Instance = container,
        Select = function(_, index)
            buttons[index].MouseButton1Click:Fire()
        end
    }
end

-- ============================================
-- CONSTRUÇÃO DAS PÁGINAS
-- ============================================

function TitaniumHub:BuildMainPage()
    local page = Create("ScrollingFrame", {
        Name = "MainPage",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = CONFIG.colors.primary,
        CanvasSize = UDim2.new(0, 0, 0, 800),
        Parent = self.UI.ContentFrame
    })
    
    local layout = Create("UIListLayout", {
        Padding = UDim.new(0, 16),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = page
    })
    
    -- Header do jogador
    local profileCard = self:CreateCard(page, {
        Name = "ProfileCard",
        Title = "👤 " .. LocalPlayer.Name,
        Size = UDim2.new(1, -20, 0, 100),
        LayoutOrder = 1
    })
    
    -- Status do sistema
    local statusText = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = "🟢 Sistema Ativo",
        TextColor3 = CONFIG.colors.success,
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        Size = UDim2.new(1, -30, 0, 20),
        Position = UDim2.new(0, 15, 0, 45),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = profileCard
    })
    
    -- Contador de bolas
    local ballsText = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = "⚽ Bolas: 0",
        TextColor3 = CONFIG.colors.textSecondary,
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        Size = UDim2.new(1, -30, 0, 20),
        Position = UDim2.new(0, 15, 0, 70),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = profileCard
    })
    
    -- Atualizador de status
    spawn(function()
        while task.wait(0.5) do
            if not statusText or not statusText.Parent then break end
            
            local hasChar = State.HRP ~= nil
            statusText.Text = hasChar and "🟢 Sistema Ativo" or "🟡 Aguardando..."
            statusText.TextColor3 = hasChar and CONFIG.colors.success or CONFIG.colors.warning
            ballsText.Text = "⚽ Bolas: " .. tostring(#State.balls)
        end
    end)
    
    -- Quick Actions
    local actionsTitle = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = "AÇÕES RÁPIDAS",
        TextColor3 = CONFIG.colors.textSecondary,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        Size = UDim2.new(1, -30, 0, 20),
        Position = UDim2.new(0, 15, 0, 0),
        LayoutOrder = 2,
        Parent = page
    })
    
    -- Botão de emergência (desativa tudo)
    self:CreateModernButton(page, {
        Text = "🛑 DESATIVAR TUDO",
        Style = "filled",
        Color = CONFIG.colors.error,
        Height = 55,
        Position = UDim2.new(0, 15, 0, 0),
        Callback = function()
            CONFIG.autoTouch = false
            CONFIG.autoSkills = false
            CONFIG.showReachSphere = false
            notify("Sistema", "Todas as funções desativadas", 2, "warning")
        end,
        LayoutOrder = 3
    })
    
    -- Botão de reativar
    self:CreateModernButton(page, {
        Text = "▶️ REATIVAR SISTEMA",
        Style = "filled",
        Color = CONFIG.colors.success,
        Height = 55,
        Position = UDim2.new(0, 15, 0, 0),
        Callback = function()
            CONFIG.autoTouch = true
            CONFIG.autoSkills = true
            CONFIG.showReachSphere = true
            notify("Sistema", "Sistema reativado!", 2, "success")
        end,
        LayoutOrder = 4
    })
    
    -- Estatísticas
    local statsTitle = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = "ESTATÍSTICAS",
        TextColor3 = CONFIG.colors.textSecondary,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        Size = UDim2.new(1, -30, 0, 20),
        Position = UDim2.new(0, 15, 0, 0),
        LayoutOrder = 5,
        Parent = page
    })
    
    local statsCard = self:CreateCard(page, {
        Size = UDim2.new(1, -20, 0, 150),
        LayoutOrder = 6
    })
    
    -- Grid de estatísticas
    local stats = {
        {Label = "Toques", Value = "0", Color = CONFIG.colors.primary},
        {Label = "Skills", Value = "0", Color = CONFIG.colors.secondary},
        {Label = "Bolas", Value = "0", Color = CONFIG.colors.accent},
        {Label = "Reach", Value = tostring(CONFIG.reach), Color = CONFIG.colors.success}
    }
    
    for i, stat in ipairs(stats) do
        local row = math.floor((i-1) / 2)
        local col = (i-1) % 2
        
        local statFrame = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0.5, -5, 0, 60),
            Position = UDim2.new(col * 0.5, 5, 0, 10 + row * 70),
            Parent = statsCard
        })
        
        Create("TextLabel", {
            BackgroundTransparency = 1,
            Text = stat.Value,
            TextColor3 = stat.Color,
            Font = Enum.Font.GothamBlack,
            TextSize = 28,
            Size = UDim2.new(1, 0, 0, 35),
            Parent = statFrame
        })
        
        Create("TextLabel", {
            BackgroundTransparency = 1,
            Text = stat.Label,
            TextColor3 = CONFIG.colors.textSecondary,
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
            Position = UDim2.new(0, 0, 0, 38),
            Size = UDim2.new(1, 0, 0, 20),
            Parent = statFrame
        })
    end
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end)
    
    self.UI.Pages.Main = page
end

function TitaniumHub:BuildReachPage()
    local page = Create("ScrollingFrame", {
        Name = "ReachPage",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = CONFIG.colors.primary,
        CanvasSize = UDim2.new(0, 0, 0, 600),
        Visible = false,
        Parent = self.UI.ContentFrame
    })
    
    local layout = Create("UIListLayout", {
        Padding = UDim.new(0, 16),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = page
    })
    
    -- Header visual grande
    local headerCard = self:CreateCard(page, {
        Size = UDim2.new(1, -20, 0, 120),
        LayoutOrder = 1
    })
    
    -- Display do reach em destaque
    local reachDisplay = Create("TextLabel", {
        Name = "ReachDisplay",
        BackgroundTransparency = 1,
        Text = tostring(CONFIG.reach),
        TextColor3 = CONFIG.colors.primary,
        Font = Enum.Font.GothamBlack,
        TextSize = 64,
        Size = UDim2.new(1, 0, 0, 70),
        Position = UDim2.new(0, 0, 0, 10),
        Parent = headerCard
    })
    
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = "STUDS DE ALCANCE",
        TextColor3 = CONFIG.colors.textSecondary,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 85),
        Parent = headerCard
    })
    
    -- Slider de reach
    local reachSlider = self:CreateModernSlider(page, {
        Text = "Distância de Alcance",
        Min = 1,
        Max = 50,
        Default = CONFIG.reach,
        Suffix = " studs",
        Callback = function(value)
            CONFIG.reach = value
