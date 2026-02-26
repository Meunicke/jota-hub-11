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

func
