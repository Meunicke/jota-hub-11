local suc, err = pcall(function()
    return game:GetService("Players")
end)

if not suc then
    repeat
        task.wait(0.1)
        suc, err = pcall(function()
            return game:GetService("Players")
        end)
    until suc
end

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local Debris = game:GetService("Debris")
local Stats = game:GetService("Stats") -- NOVO: Para monitorar ping

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart", 5)

while not LocalPlayer.Character do
    task.wait(0.1)
end

-- ============================================
-- LIMPEZA ANTI-DUPLICAÇÃO
-- ============================================
pcall(function()
    for _, obj in ipairs(CoreGui:GetChildren()) do
        if obj.Name:match("CAFUXZ1") then
            obj:Destroy()
        end
    end
end)

pcall(function()
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj.Name:match("CAFUXZ1") then
            obj:Destroy()
        end
    end
end)

-- ============================================
-- CONFIGURAÇÕES v16.3 (COM PING OPTIMIZATION)
-- ============================================
local CONFIG = {
    width = 650,
    height = 500,
    sidebarWidth = 100,
    
    -- Reach System
    reach = 15,
    showReachSphere = true,
    autoTouch = true,
    fullBodyTouch = true,
    autoSecondTouch = true,
    scanCooldown = 1.0,
    
    -- Arthur Sphere
    arthurSphere = {
        reach = 12,
        color = Color3.fromRGB(0, 255, 255),
        transparency = 0.7,
        material = Enum.Material.ForceField,
        pulseSpeed = 2
    },
    
    -- TOTE SYSTEM v3.0
    tote = {
        enabled = false,
        power = 50,
        curveAmount = 30,
        curveDirection = "Auto",
        height = 15,
        spinRate = 8,
        magnusForce = 0.15,
        autoAim = false,
        prediction = true,
        visualizer = true,
        keybind = Enum.KeyCode.T,
        debounce = 0.3,
        lastKick = 0,
        gravityCompensation = true,
        airResistance = 0.98
    },
    
    -- Anti Lag
    antiLag = {
        enabled = false,
        textures = true,
        visualEffects = true,
        parts = true,
        particles = true,
        sky = true,
        fullBright = false
    },
    
    -- PING OPTIMIZATION SYSTEM (NOVO)
    pingOptimization = {
        enabled = true,              -- Ativa otimização de ping
        adaptiveTiming = true,       -- Timing adaptativo baseado no ping
        smartPriority = true,        -- Prioriza bolas mais próximas em lag
        pingBufferMultiplier = 1.5,  -- Buffer de segurança (1.5x = 50% a mais)
        highPingThreshold = 150,     -- Ping considerado alto (ms)
        criticalPingThreshold = 250,   -- Ping crítico (ms)
        dynamicFPS = true,           -- Reduz qualidade quando FPS baixo
        compensationRange = 0.15,    -- Aumento de range em pings altos (15%)
        showPingMonitor = true       -- Mostrar monitor de ping na UI
    },
    
    -- Cores
    customColors = {
        primary = Color3.fromRGB(99, 102, 241),
        secondary = Color3.fromRGB(139, 92, 246),
        accent = Color3.fromRGB(14, 165, 233),
        success = Color3.fromRGB(34, 197, 94),
        danger = Color3.fromRGB(239, 68, 68),
        warning = Color3.fromRGB(245, 158, 11),
        info = Color3.fromRGB(59, 130, 246),
        tote = Color3.fromRGB(255, 0, 128),
        ping = Color3.fromRGB(0, 255, 200), -- NOVO: Cor para ping
        
        bgDark = Color3.fromRGB(8, 8, 16),
        bgCard = Color3.fromRGB(20, 20, 35),
        bgElevated = Color3.fromRGB(35, 35, 55),
        bgGlass = Color3.fromRGB(15, 15, 28),
        
        textPrimary = Color3.fromRGB(252, 252, 255),
        textSecondary = Color3.fromRGB(180, 190, 220),
        textMuted = Color3.fromRGB(140, 150, 180),
    },
    
    ballNames = { 
        "TPS", "TCS", "ESA", "MRS", "PRS", "MPS", "SSS", "AIFA", "RBZ",
        "Ball", "Soccer", "Football", "Basketball", "Baseball", 
        "BallTemplate", "GameBall", "Hitbox", "TouchPart", "GoalBall",
        "Physics", "Interaction", "Trigger", "Touch", "Hit", "Box",
        "bola", "Bola", "BALL", "SOCCER", "FOOTBALL", "SoccerBall",
        "tote", "Tote", "CurveBall", "ShotBall"
    }
}

-- ============================================
-- ESTATÍSTICAS
-- ============================================
local STATS = {
    totalTouches = 0,
    ballsTouched = 0,
    sessionStart = tick(),
    skillsActivated = 0,
    antiLagItems = 0,
    morphsDone = 0,
    toteKicks = 0,
    toteGoals = 0,
    avgPing = 0,      -- NOVO
    currentPing = 0,  -- NOVO
    fps = 60          -- NOVO
}

local LOGS = {}
local MAX_LOGS = 50

local function addLog(message, type)
    type = type or "info"
    table.insert(LOGS, 1, {
        message = tostring(message),
        type = tostring(type),
        time = os.date("%H:%M:%S"),
        timestamp = tick()
    })
    if #LOGS > MAX_LOGS then table.remove(LOGS) end
end

-- ============================================
-- PING SYSTEM AVANÇADO (NOVO - INTEGRADO)
-- ============================================
local PingSystem = {
    History = {},
    CurrentPing = 0,
    AveragePing = 0,
    PingTrend = "stable", -- "rising", "falling", "stable", "spike"
    LastPingUpdate = 0,
    DesyncCompensation = 0,
    SafetyBuffer = 0,
    FPS = 60,
    FrameTime = 0,
    
    -- Inicializa sistema de ping
    Init = function(self)
        -- Monitor de FPS
        RunService.Heartbeat:Connect(function(deltaTime)
            self.FrameTime = deltaTime
            self.FPS = math.floor(1 / deltaTime)
            STATS.fps = self.FPS
        end)
    end,
    
    -- Atualiza ping com análise avançada
    Update = function(self)
        local now = tick()
        if now - self.LastPingUpdate < 0.1 then return end -- Limita updates
        self.LastPingUpdate = now
        
        local success, ping = pcall(function()
            return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
        end)
        
        if success and ping then
            self.CurrentPing = ping
            STATS.currentPing = ping
            
            -- Adiciona ao histórico (últimos 10 valores)
            table.insert(self.History, 1, ping)
            if #self.History > 10 then table.remove(self.History) end
            
            -- Calcula média móvel
            local sum = 0
            for _, p in ipairs(self.History) do
                sum = sum + p
            end
            local newAverage = sum / #self.History
            
            -- Detecta tendência
            if newAverage > self.AveragePing * 1.2 then
                self.PingTrend = "rising"
            elseif newAverage < self.AveragePing * 0.8 then
                self.PingTrend = "falling"
            elseif math.abs(ping - self.AveragePing) > self.AveragePing * 0.5 then
                self.PingTrend = "spike"
            else
                self.PingTrend = "stable"
            end
            
            self.AveragePing = newAverage
            STATS.avgPing = math.floor(newAverage)
            
            -- Calcula compensação de desync (em segundos)
            self.DesyncCompensation = (self.AveragePing / 1000) * 0.5
            
            -- Buffer de segurança dinâmico
            local multiplier = CONFIG.pingOptimization.pingBufferMultiplier
            if self.PingTrend == "spike" or self.PingTrend == "rising" then
                multiplier = multiplier * 1.3 -- +30% em picos
            end
            self.SafetyBuffer = (self.AveragePing / 1000) * multiplier
            
        end
    end,
    
    -- Retorna delay adaptativo baseado no ping atual
    GetAdaptiveDelay = function(self, baseDelay)
        if not CONFIG.pingOptimization.adaptiveTiming then return baseDelay end
        
        -- Aumenta delay levemente em pings altos para estabilidade
        local pingFactor = math.clamp(self.AveragePing / 100, 0.5, 2.0)
        return baseDelay * pingFactor
    end,
    
    -- Verifica se deve usar modo de alta prioridade (ping alto)
    IsHighLoad = function(self)
        return self.AveragePing > CONFIG.pingOptimization.highPingThreshold or self.FPS < 30
    end,
    
    -- Verifica se está em condição crítica
    IsCritical = function(self)
        return self.AveragePing > CONFIG.pingOptimization.criticalPingThreshold or self.FPS < 20
    end,
    
    -- Retorna jitter otimizado (menos agressivo em pings altos)
    GetOptimizedJitter = function(self)
        local jitterMultiplier = 1.0
        if self.PingTrend == "spike" then
            jitterMultiplier = 0.5 -- Metade do jitter em picos
        end
        
        local baseJitter = self.DesyncCompensation * jitterMultiplier
        
        return Vector3.new(
            math.random(-10, 10) * baseJitter,
            math.random(-5, 5) * baseJitter,
            math.random(-10, 10) * baseJitter
        )
    end,
    
    -- Retorna range efetivo (aumenta levemente em pings altos para compensar)
    GetEffectiveRange = function(self, baseRange)
        if not CONFIG.pingOptimization.enabled then return baseRange end
        
        -- Aumenta range em até 15% quando ping está alto (compensação de latência)
        local compensation = math.clamp(self.AveragePing / 1000, 0, CONFIG.pingOptimization.compensationRange)
        return baseRange * (1 + compensation)
    end,
    
    -- Retorna ícone e cor baseado no status do ping
    GetStatusVisuals = function(self)
        if self.PingTrend == "spike" then
            return "⚠️", Color3.fromRGB(255, 50, 50)
        elseif self.PingTrend == "rising" then
            return "↑", Color3.fromRGB(255, 200, 50)
        elseif self.PingTrend == "falling" then
            return "↓", Color3.fromRGB(100, 255, 100)
        else
            return "●", Color3.fromRGB(100, 200, 255)
        end
    end
}

-- ============================================
-- VARIÁVEIS GLOBAIS
-- ============================================
local balls = {}
local ballConnections = {}
local reachSphere = nil
local arthurSphere = nil
local touchDebounce = {}
local lastBallUpdate = 0
local lastTouch = 0
local isMinimized = false
local isClosed = false
local mainGui = nil
local mainFrame = nil
local iconGui = nil
local introGui = nil
local currentTab = "reach"
local autoSkills = true
local lastSkillActivation = 0
local skillCooldown = 0.5
local activatedSkills = {}
local antiLagActive = false
local originalStates = {}
local antiLagConnection = nil
local currentSkybox = nil
local originalSkybox = nil
local loopRunning = false
local heartbeatConnection = nil
local lastSkillCheck = 0
local skillCheckInterval = 0.1
local lastStatsUpdate = 0
local statsUpdateInterval = 1

-- Tote v3.0 Variables
local toteActive = false
local toteVisualizer = nil
local totePredictionPoints = {}
local currentBall = nil

local skillButtonNames = {
    "Shoot", "Pass", "Long", "Tackle", "Dribble", "GK", "Throw",
    "Control", "Left", "Right", "High", "Low", "Rainbow",
    "Chip", "Heel", "Volley", "Back Right", "Back Left",
    "Carry", "Fake Shot", "Drag Back", "Header", "Bicycle",
    "Shot", "Slide", "Goalkeeper", "Catch", "Punch",
    "Short Pass", "Through Ball", "Cross", "Curve",
    "Power Shot", "Precision", "First Touch", "Sprint", "Jump",
    "Chute", "Passe", "Drible", "Controle", "Defender", "Save",
    "Tote", "Curva", "Spin", "Finesse"
}

-- ============================================
-- SISTEMA DE NOTIFICAÇÕES AVANÇADAS v2.0
-- ============================================
local NOTIF_CONFIG = {
    duration = 3,
    maxNotifications = 5,
    position = "right",
    offset = {
        x = 20,
        y = 100
    },
    animationSpeed = 0.5,
    soundEnabled = false
}

local activeNotifications = {}
local notifCounter = 0

function advancedNotify(title, text, notifType, duration)
    duration = duration or NOTIF_CONFIG.duration
    notifType = notifType or "info"
    
    local styles = {
        success = {
            color = CONFIG.customColors.success,
            icon = "✅",
            gradient = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(34, 197, 94)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 120, 60))
            })
        },
        warning = {
            color = CONFIG.customColors.warning,
            icon = "⚠️",
            gradient = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(245, 158, 11)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 100, 10))
            })
        },
        error = {
            color = CONFIG.customColors.danger,
            icon = "❌",
            gradient = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(239, 68, 68)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 30, 30))
            })
        },
        info = {
            color = CONFIG.customColors.info,
            icon = "ℹ️",
            gradient = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(59, 130, 246)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 80, 180))
            })
        },
        tote = {
            color = CONFIG.customColors.tote,
            icon = "🎯",
            gradient = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 128)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 0, 90))
            })
        },
        morph = {
            color = CONFIG.customColors.secondary,
            icon = "✨",
            gradient = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(139, 92, 246)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 60, 180))
            })
        },
        sky = {
            color = CONFIG.customColors.accent,
            icon = "☁️",
            gradient = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(14, 165, 233)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 120, 180))
            })
        },
        block = {
            color = Color3.fromRGB(255, 140, 0),
            icon = "🛡️",
            gradient = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 140, 0)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 100, 0))
            })
        },
        ping = { -- NOVO: Estilo para notificações de ping
            color = CONFIG.customColors.ping,
            icon = "📶",
            gradient = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 200)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 180, 140))
            })
        }
    }
    
    local style = styles[notifType] or styles.info
    
    notifCounter = notifCounter + 1
    local notifId = "CAFUXZ1_Notif_" .. notifCounter .. "_" .. tick()
    
    local notifGui = Instance.new("ScreenGui")
    notifGui.Name = notifId
    notifGui.ResetOnSpawn = false
    notifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    notifGui.Parent = CoreGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 340, 0, 90)
    frame.Position = UDim2.new(1, 60, 0.85, 0)
    frame.BackgroundColor3 = CONFIG.customColors.bgCard
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    frame.Parent = notifGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = style.color
    stroke.Thickness = 2.5
    stroke.Transparency = 0.4
    stroke.Parent = frame
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = style.gradient
    gradient.Rotation = 45
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.9),
        NumberSequenceKeypoint.new(1, 0.95)
    })
    gradient.Parent = frame
    
    local iconContainer = Instance.new("Frame")
    iconContainer.Size = UDim2.new(0, 55, 0, 55)
    iconContainer.Position = UDim2.new(0, 12, 0, 17)
    iconContainer.BackgroundColor3 = style.color
    iconContainer.BackgroundTransparency = 0.2
    iconContainer.BorderSizePixel = 0
    iconContainer.Parent = frame
    
    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(0, 12)
    iconCorner.Parent = iconContainer
    
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(1, 0, 1, 0)
    icon.BackgroundTransparency = 1
    icon.Text = style.icon
    icon.TextSize = 32
    icon.Font = Enum.Font.GothamBold
    icon.Parent = iconContainer
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -80, 0, 28)
    titleLabel.Position = UDim2.new(0, 75, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = style.color
    titleLabel.TextSize = 17
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
    titleLabel.Parent = frame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -80, 0, 45)
    textLabel.Position = UDim2.new(0, 75, 0, 38)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = CONFIG.customColors.textSecondary
    textLabel.TextSize = 13
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextWrapped = true
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Top
    textLabel.Parent = frame
    
    local progressBarBg = Instance.new("Frame")
    progressBarBg.Size = UDim2.new(1, 0, 0, 4)
    progressBarBg.Position = UDim2.new(0, 0, 1, -4)
    progressBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    progressBarBg.BorderSizePixel = 0
    progressBarBg.Parent = frame
    
    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(1, 0, 1, 0)
    progressBar.BackgroundColor3 = style.color
    progressBar.BorderSizePixel = 0
    progressBar.Parent = progressBarBg
    
    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(0, 2)
    progressCorner.Parent = progressBarBg
    
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.Size = UDim2.new(1.5, 0, 2, 0)
    glow.Position = UDim2.new(-0.25, 0, -0.5, 0)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://4996891979"
    glow.ImageColor3 = style.color
    glow.ImageTransparency = 0.9
    glow.ScaleType = Enum.ScaleType.Slice
    glow.SliceCenter = Rect.new(10, 10, 118, 118)
    glow.Parent = frame
    
    local function tweenNotif(obj, props, time, style, dir, callback)
        if not obj or not obj.Parent then return nil end
        local info = TweenInfo.new(time, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out)
        local t = TweenService:Create(obj, info, props)
        if callback and typeof(callback) == "function" then
            t.Completed:Connect(callback)
        end
        t:Play()
        return t
    end
    
    local yOffset = 0
    for _, existingNotif in ipairs(activeNotifications) do
        if existingNotif and existingNotif.Parent then
            yOffset = yOffset - 100
        end
    end
    
    tweenNotif(frame, {
        Position = UDim2.new(1, -360, 0.85, yOffset)
    }, 0.6, Enum.EasingStyle.Back)
    
    tweenNotif(iconContainer, {Size = UDim2.new(0, 58, 0, 58), Position = UDim2.new(0, 10.5, 0, 15.5)}, 0.3)
    task.delay(0.15, function()
        tweenNotif(iconContainer, {Size = UDim2.new(0, 55, 0, 55), Position = UDim2.new(0, 12, 0, 17)}, 0.2)
    end)
    
    tweenNotif(progressBar, {Size = UDim2.new(0, 0, 1, 0)}, duration, Enum.EasingStyle.Linear)
    
    table.insert(activeNotifications, 1, notifGui)
    
    while #activeNotifications > NOTIF_CONFIG.maxNotifications do
        local old = table.remove(activeNotifications)
        if old and old.Parent then
            old:Destroy()
        end
    end
    
    task.delay(duration, function()
        tweenNotif(frame, {
            Position = UDim2.new(1, 60, 0.85, yOffset),
            BackgroundTransparency = 1
        }, 0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In, function()
            for i, notif in ipairs(activeNotifications) do
                if notif == notifGui then
                    table.remove(activeNotifications, i)
                    break
                end
            end
            notifGui:Destroy()
        end)
    end)
    
    return notifGui
end

-- Funções helper para tipos específicos
local function notify(title, text, duration)
    advancedNotify(title, text, "info", duration or 3)
end

local function notifySuccess(title, text, duration)
    advancedNotify(title, text, "success", duration or 3)
end

local function notifyError(title, text, duration)
    advancedNotify(title, text, "error", duration or 3)
end

local function notifyWarning(title, text, duration)
    advancedNotify(title, text, "warning", duration or 3)
end

local function notifyTote(title, text, duration)
    advancedNotify(title, text, "tote", duration or 3)
end

local function notifyMorph(title, text, duration)
    advancedNotify(title, text, "morph", duration or 3)
end

local function notifySky(title, text, duration)
    advancedNotify(title, text, "sky", duration or 3)
end

local function notifyPing(title, text, duration) -- NOVO
    advancedNotify(title, text, "ping", duration or 3)
end

-- ============================================
-- FUNÇÕES UTILITÁRIAS
-- ============================================
local function tween(obj, props, time, style, dir, callback)
    if not obj or not obj.Parent then return nil end
    time = tonumber(time) or 0.35
    style = style or Enum.EasingStyle.Quint
    dir = dir or Enum.EasingDirection.Out
    
    local success, result = pcall(function()
        local info = TweenInfo.new(time, style, dir)
        local t = TweenService:Create(obj, info, props)
        if callback and typeof(callback) == "function" then
            t.Completed:Connect(callback)
        end
        t:Play()
        return t
    end)
    
    return success and result or nil
end

-- ============================================
-- INTRO ANIMADA (ATUALIZADA COM PING INFO)
-- ============================================
local function createIntro()
    local success = pcall(function()
        introGui = Instance.new("ScreenGui")
        introGui.Name = "CAFUXZ1_Intro_v16"
        introGui.ResetOnSpawn = false
        introGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        introGui.Parent = CoreGui
        
        local bg = Instance.new("Frame")
        bg.Name = "Background"
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.BackgroundColor3 = CONFIG.customColors.bgDark
        bg.BorderSizePixel = 0
        bg.Parent = introGui
        
        local container = Instance.new("Frame")
        container.Name = "Container"
        container.Size = UDim2.new(0, 550, 0, 450)
        container.Position = UDim2.new(0.5, -275, 0.5, -225)
        container.BackgroundTransparency = 1
        container.Parent = bg
        
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, 0, 1, 0)
        card.BackgroundColor3 = CONFIG.customColors.bgGlass
        card.BackgroundTransparency = 0.15
        card.BorderSizePixel = 0
        card.Parent = container
        
        local cardCorner = Instance.new("UICorner")
        cardCorner.CornerRadius = UDim.new(0, 20)
        cardCorner.Parent = card
        
        local cardStroke = Instance.new("UIStroke")
        cardStroke.Color = CONFIG.customColors.primary
        cardStroke.Thickness = 2
        cardStroke.Transparency = 0.6
        cardStroke.Parent = card
        
        local iconContainer = Instance.new("Frame")
        iconContainer.Size = UDim2.new(0, 120, 0, 120)
        iconContainer.Position = UDim2.new(0.5, -60, 0, 40)
        iconContainer.BackgroundTransparency = 1
        iconContainer.Parent = card
        
        local iconGlow = Instance.new("Frame")
        iconGlow.Size = UDim2.new(1.4, 0, 1.4, 0)
        iconGlow.Position = UDim2.new(-0.2, 0, -0.2, 0)
        iconGlow.BackgroundColor3 = CONFIG.customColors.primary
        iconGlow.BackgroundTransparency = 0.9
        iconGlow.BorderSizePixel = 0
        iconGlow.Parent = iconContainer
        
        local glowCorner = Instance.new("UICorner")
        glowCorner.CornerRadius = UDim.new(1, 0)
        glowCorner.Parent = iconGlow
        
        local icon = Instance.new("TextLabel")
        icon.Name = "Icon"
        icon.Size = UDim2.new(1, 0, 1, 0)
        icon.BackgroundTransparency = 1
        icon.Text = "⚡"
        icon.TextColor3 = CONFIG.customColors.primary
        icon.TextSize = 70
        icon.Font = Enum.Font.GothamBold
        icon.Parent = iconContainer
        
        local title = Instance.new("TextLabel")
        title.Name = "Title"
        title.Size = UDim2.new(1, 0, 0, 50)
        title.Position = UDim2.new(0, 0, 0, 170)
        title.BackgroundTransparency = 1
        title.Text = "CAFUXZ1 Hub"
        title.TextColor3 = CONFIG.customColors.textPrimary
        title.TextSize = 42
        title.Font = Enum.Font.GothamBold
        title.Parent = card
        
        local versionBadge = Instance.new("Frame")
        versionBadge.Size = UDim2.new(0, 180, 0, 30)
        versionBadge.Position = UDim2.new(0.5, -90, 0, 225)
        versionBadge.BackgroundColor3 = CONFIG.customColors.tote
        versionBadge.BackgroundTransparency = 0.2
        versionBadge.BorderSizePixel = 0
        versionBadge.Parent = card
        
        local badgeCorner = Instance.new("UICorner")
        badgeCorner.CornerRadius = UDim.new(0, 15)
        badgeCorner.Parent = versionBadge
        
        local version = Instance.new("TextLabel")
        version.Size = UDim2.new(1, 0, 1, 0)
        version.BackgroundTransparency = 1
        version.Text = "v16.3 PING+"
        version.TextColor3 = Color3.new(1, 1, 1)
        version.TextSize = 14
        version.Font = Enum.Font.GothamBold
        version.Parent = versionBadge
        
        local line = Instance.new("Frame")
        line.Name = "Line"
        line.Size = UDim2.new(0, 0, 0, 2)
        line.Position = UDim2.new(0.5, 0, 0, 270)
        line.BackgroundColor3 = CONFIG.customColors.primary
        line.BorderSizePixel = 0
        line.Parent = card
        
        local updatesText = Instance.new("TextLabel")
        updatesText.Name = "Updates"
        updatesText.Size = UDim2.new(1, -60, 0, 150)
        updatesText.Position = UDim2.new(0, 30, 0, 290)
        updatesText.BackgroundTransparency = 1
        updatesText.Text = "NOVIDADES v16.3 PING+:\n\n" ..
                           "• SISTEMA DE PING ADAPTATIVO\n" ..
                           "• Compensação automática de lag\n" ..
                           "• Range dinâmico baseado no ping\n" ..
                           "• Monitor de ping em tempo real\n" ..
                           "• Priorização inteligente de bolas\n" ..
                           "• Buffer de segurança anti-spike"
        updatesText.TextColor3 = CONFIG.customColors.textSecondary
        updatesText.TextSize = 15
        updatesText.Font = Enum.Font.Gotham
        updatesText.TextWrapped = true
        updatesText.TextYAlignment = Enum.TextYAlignment.Top
        updatesText.Parent = card
        
        local enterBtn = Instance.new("TextButton")
        enterBtn.Name = "EnterBtn"
        enterBtn.Size = UDim2.new(0, 220, 0, 50)
        enterBtn.Position = UDim2.new(0.5, -110, 1, -70)
        enterBtn.BackgroundColor3 = CONFIG.customColors.primary
        enterBtn.Text = "ENTRAR NO HUB"
        enterBtn.TextColor3 = Color3.new(1, 1, 1)
        enterBtn.TextSize = 18
        enterBtn.Font = Enum.Font.GothamBold
        enterBtn.Parent = card
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 12)
        btnCorner.Parent = enterBtn
        
        task.spawn(function()
            task.wait(0.3)
            
            iconContainer.Position = UDim2.new(0.5, -60, 0, -150)
            tween(iconContainer, {Position = UDim2.new(0.5, -60, 0, 40)}, 0.8, Enum.EasingStyle.Back)
            
            task.wait(0.2)
            title.TextTransparency = 1
            tween(title, {TextTransparency = 0}, 0.6)
            
            task.wait(0.1)
            tween(versionBadge, {BackgroundTransparency = 0.2}, 0.5)
            
            task.wait(0.2)
            tween(line, {Size = UDim2.new(0.7, 0, 0, 2)}, 0.7, Enum.EasingStyle.Quint)
            
            task.wait(0.3)
            updatesText.TextTransparency = 1
            tween(updatesText, {TextTransparency = 0}, 0.6)
            
            task.wait(0.2)
            enterBtn.BackgroundTransparency = 1
            enterBtn.TextTransparency = 1
            tween(enterBtn, {BackgroundTransparency = 0.2, TextTransparency = 0}, 0.5)
        end)
        
        local function closeIntro()
            pcall(function()
                tween(card, {Position = UDim2.new(0, 0, 0, 50), Size = UDim2.new(1, 0, 0, 0)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
                tween(bg, {BackgroundTransparency = 1}, 0.4)
                task.wait(0.5)
                if introGui then
                    introGui:Destroy()
                    introGui = nil
                end
            end)
        end
        
        enterBtn.MouseButton1Click:Connect(closeIntro)
        task.delay(12, function()
            if introGui and introGui.Parent then 
                closeIntro() 
            end
        end)
    end)
    
    if not success then
        introGui = nil
    end
end

-- ============================================
-- ANTI LAG
-- ============================================
local function saveOriginalState(obj, property, value)
    if not obj or typeof(obj) ~= "Instance" then return end
    if not originalStates[obj] then originalStates[obj] = {} end
    if originalStates[obj][property] == nil then
        originalStates[obj][property] = value
    end
end

local function applyAntiLag()
    if antiLagActive then return end
    antiLagActive = true
    
    local batchSize = 150
    local Stuff = {}
    
    local function processBatch(descendants, startIdx)
        local endIdx = math.min(startIdx + batchSize - 1, #descendants)
        
        for i = startIdx, endIdx do
            local v = descendants[i]
            if not v then continue end
            
            pcall(function()
                if CONFIG.antiLag.parts and (v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("BasePart")) then
                    saveOriginalState(v, "Material", v.Material)
                    v.Material = Enum.Material.SmoothPlastic
                    table.insert(Stuff, v)
                end
                
                if CONFIG.antiLag.particles and (v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Explosion") or v:IsA("Sparkles") or v:IsA("Fire")) then
                    saveOriginalState(v, "Enabled", v.Enabled)
                    v.Enabled = false
                    table.insert(Stuff, v)
                end
                
                if CONFIG.antiLag.visualEffects and (v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("SunRaysEffect")) then
                    saveOriginalState(v, "Enabled", v.Enabled)
                    v.Enabled = false
                    table.insert(Stuff, v)
                end
                
                if CONFIG.antiLag.textures and (v:IsA("Decal") or v:IsA("Texture")) then
                    saveOriginalState(v, "Texture", v.Texture)
                    v.Texture = ""
                    table.insert(Stuff, v)
                end
                
                if CONFIG.antiLag.sky and v:IsA("Sky") then
                    saveOriginalState(v, "Parent", v.Parent)
                    v.Parent = nil
                    table.insert(Stuff, v)
                end
            end)
        end
        
        if endIdx < #descendants then
            task.wait()
            processBatch(descendants, endIdx + 1)
        else
            STATS.antiLagItems = #Stuff
            addLog("Anti Lag ATIVADO - " .. #Stuff .. " itens", "success")
            notifySuccess("🚀 Anti-Lag", #Stuff .. " objetos otimizados com sucesso!", 3)
        end
    end
    
    local allDescendants = game:GetDescendants()
    processBatch(allDescendants, 1)
    
    antiLagConnection = game.DescendantAdded:Connect(function(v)
        if not antiLagActive then return end
        task.wait(0.1)
        pcall(function()
            if CONFIG.antiLag.parts and (v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("BasePart")) then
                saveOriginalState(v, "Material", v.Material)
                v.Material = Enum.Material.SmoothPlastic
            end
        end)
    end)
end

local function disableAntiLag()
    if not antiLagActive then return end
    antiLagActive = false
    
    if antiLagConnection then
        pcall(function()
            antiLagConnection:Disconnect()
        end)
        antiLagConnection = nil
    end
    
    local states = {}
    for obj, props in pairs(originalStates) do
        if obj and typeof(obj) == "Instance" then
            table.insert(states, {obj = obj, props = props})
        end
    end
    
    local batchSize = 150
    local function restoreBatch(startIdx)
        local endIdx = math.min(startIdx + batchSize - 1, #states)
        
        for i = startIdx, endIdx do
            local data = states[i]
            local obj = data.obj
            if obj and obj.Parent then
                for prop, value in pairs(data.props) do
                    pcall(function()
                        if prop == "Parent" then 
                            obj.Parent = value
                        else 
                            obj[prop] = value 
                        end
                    end)
                end
            end
        end
        
        if endIdx < #states then
            task.wait()
            restoreBatch(endIdx + 1)
        else
            originalStates = {}
            STATS.antiLagItems = 0
            addLog("Anti Lag DESATIVADO", "warning")
            notifyWarning("⚠️ Anti-Lag", "Otimização desativada!", 3)
        end
    end
    
    if #states > 0 then
        restoreBatch(1)
    end
end

-- ============================================
-- MORPH SYSTEM
-- ============================================
local PRESET_MORPHS = {
    { name = "Miguelcalebegamer202", userId = nil, displayName = "Miguelcalebegamer202" },
    { name = "Tottxii", userId = nil, displayName = "Tottxii" },
    { name = "Feliou23", userId = nil, displayName = "Feliou23 (cb)" },
    { name = "venxcore", userId = nil, displayName = "venxcore (cb)" },
    { name = "AlissonGkBe", userId = nil, displayName = "AlissonGkBe (extra,gk)" }
}

task.spawn(function()
    for _, preset in ipairs(PRESET_MORPHS) do
        if not preset.userId then
            pcall(function()
                preset.userId = Players:GetUserIdFromNameAsync(preset.name)
            end)
        end
        task.wait(0.1)
    end
end)

local function morphToUser(userId, targetName)
    if not userId then 
        notifyError("❌ Morph", "User ID não encontrado!", 3) 
        return 
    end
    
    if userId == LocalPlayer.UserId then 
        notifyWarning("⚠️ Morph", "Não pode morphar em si mesmo!", 3) 
        return 
    end
    
    local character = LocalPlayer.Character
    if not character then
        notifyError("❌ Morph", "Character não encontrado!", 3)
        return
    end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then 
        notifyError("❌ Morph", "Humanoid não encontrado!", 3) 
        return 
    end

    local desc
    local success = pcall(function()
        desc = Players:GetHumanoidDescriptionFromUserId(userId)
    end)
    
    if not success or not desc then 
        notifyError("❌ Morph", "Falha ao carregar avatar!", 3) 
        return 
    end

    pcall(function()
        for _, obj in ipairs(character:GetChildren()) do
            if obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("ShirtGraphic") or obj:IsA("Accessory") or obj:IsA("BodyColors") then
                obj:Destroy()
            end
        end
        
        local head = character:FindFirstChild("Head")
        if head then
            for _, decal in ipairs(head:GetChildren()) do
                if decal:IsA("Decal") then 
                    decal:Destroy() 
                end
            end
        end

        humanoid:ApplyDescriptionClientServer(desc)
    end)
    
    STATS.morphsDone = STATS.morphsDone + 1
    notifyMorph("✨ Transformação Completa", "Você agora é: " .. tostring(targetName), 3)
    addLog("Morph: " .. tostring(targetName), "success")
end

-- ============================================
-- SKYBOX SYSTEM
-- ============================================
local SkyboxDatabase = {
    { id = 14828385099, name = "Night Sky With Moon HD", category = "1" },
    { id = 109488540432307, name = "Cosmic Sky A", category = "1" },
    { id = 109844440994380, name = "Cosmic Sky B", category = "1" },
    { id = 277098164, name = "Night/Space Classic", category = "1" },
    { id = 6681543281, name = "Deep Space", category = "1" },
    { id = 77407612452946, name = "Galaxy Nebula", category = "1" },
    { id = 2900944368, name = "Space/Sci-Fi Sky", category = "2" },
    { id = 290982885, name = "Atmospheric Sky", category = "2" },
    { id = 295604372, name = "Cloudy/Weather Sky", category = "2" },
    { id = 17124418086, name = "Custom Sky A", category = "3" },
    { id = 17480150596, name = "Custom Sky B", category = "3" },
    { id = 16553683517, name = "Custom Sky C", category = "3" },
    { id = 264910951, name = "Vintage/Retro Sky", category = "3" },
    { id = 119314959302386, name = "Special Effect Sky", category = "4" },
}

local function ClearSkies()
    pcall(function()
        for _, child in ipairs(Lighting:GetChildren()) do
            if child:IsA("Sky") then 
                child:Destroy() 
            end
        end
    end)
end

local function ApplySkybox(assetId, skyName)
    if not assetId or assetId == 0 then 
        return false 
    end
    
    ClearSkies()
    
    local success = pcall(function()
        local objects = game:GetObjects("rbxassetid://" .. tostring(assetId))
        if objects and #objects > 0 then
            local source = objects[1]
            if source:IsA("Sky") then
                local sky = source:Clone()
                sky.Name = "CAFUXZ1_Sky_" .. tostring(assetId)
                sky.Parent = Lighting
                return true
            end
            if source:IsA("Model") or source:IsA("Folder") then
                for _, child in ipairs(source:GetDescendants()) do
                    if child:IsA("Sky") then
                        local sky = child:Clone()
                        sky.Name = "CAFUXZ1_Sky_" .. tostring(assetId)
                        sky.Parent = Lighting
                        source:Destroy()
                        return true
                    end
                end
                source:Destroy()
            end
        end
        return false
    end)
    
    if success then 
        currentSkybox = assetId 
        notifySky("☁️ Skybox Alterado", "Novo céu aplicado: " .. tostring(skyName), 2)
        addLog("Skybox aplicado: " .. tostring(skyName), "success")
        return true 
    end
    
    success = pcall(function()
        local sky = Instance.new("Sky")
        sky.Name = "CAFUXZ1_Sky_Generic_" .. tostring(assetId)
        local url = "rbxassetid://" .. tostring(assetId)
        sky.SkyboxBk = url
        sky.SkyboxDn = url
        sky.SkyboxFt = url
        sky.SkyboxLf = url
        sky.SkyboxRt = url
        sky.SkyboxUp = url
        sky.Parent = Lighting
        return true
    end)
    
    if success then 
        currentSkybox = assetId 
        notifySky("☁️ Skybox Genérico", "Céu aplicado com sucesso!", 2)
        addLog("Skybox genérico aplicado", "success")
    end
    
    return success
end

local function restoreOriginalSkybox()
    ClearSkies()
    if originalSkybox and typeof(originalSkybox) == "Instance" then
        pcall(function()
            originalSkybox.Parent = Lighting
        end)
        originalSkybox = nil
    end
    currentSkybox = nil
    notify("ℹ️ Skybox", "Céu original restaurado", 2)
    addLog("Skybox restaurado", "info")
end

local function saveOriginalSkybox()
    if not originalSkybox then
        for _, child in ipairs(Lighting:GetChildren()) do
            if child:IsA("Sky") then
                originalSkybox = child:Clone()
                break
            end
        end
    end
end

-- ============================================
-- REACH SYSTEM (OTIMIZADO COM PING)
-- ============================================
local function updateCharacter()
    local newChar = LocalPlayer.Character
    if newChar then
        Character = newChar
        local newHRP = newChar:FindFirstChild("HumanoidRootPart")
        if newHRP then
            HRP = newHRP
        end
    end
end

local function findBalls()
    local now = tick()
    -- Ajusta cooldown baseado no ping (NOVO)
    local cooldown = CONFIG.scanCooldown
    if PingSystem:IsHighLoad() then
        cooldown = cooldown * 1.5 -- Aumenta cooldown em lag
    end
    
    if now - lastBallUpdate < cooldown then 
        return #balls 
    end
    lastBallUpdate = now
    
    for i = #balls, 1, -1 do
        balls[i] = nil
    end
    
    for _, conn in ipairs(ballConnections) do
        pcall(function() 
            conn:Disconnect() 
        end)
    end
    for i = #ballConnections, 1, -1 do
        ballConnections[i] = nil
    end
    
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj and obj:IsA("BasePart") and obj.Parent then
                for _, name in ipairs(CONFIG.ballNames) do
                    if obj.Name == name or (string.find(obj.Name, name, 1, true)) then
                        table.insert(balls, obj)
                        local conn = obj.AncestryChanged:Connect(function()
                            if not obj.Parent then 
                                findBalls() 
                            end
                        end)
                        table.insert(ballConnections, conn)
                        break
                    end
                end
            end
        end
    end)
    
    return #balls
end

local function getBodyParts()
    if not Character then 
        return {} 
    end
    
    local parts = {}
    for _, part in ipairs(Character:GetChildren()) do
        if part and part:IsA("BasePart") then
            if CONFIG.fullBodyTouch then
                table.insert(parts, part)
            elseif part.Name == "HumanoidRootPart" then
                table.insert(parts, part)
            end
        end
    end
    return parts
end

-- ============================================
-- ESFERAS (COM PING COMPENSATION)
-- ============================================
local function createReachSphere()
    if reachSphere and reachSphere.Parent then 
        return 
    end
    
    pcall(function()
        reachSphere = Instance.new("Part")
        reachSphere.Name = "CAFUXZ1_ReachSphere_v16"
        reachSphere.Shape = Enum.PartType.Ball
        reachSphere.Anchored = true
        reachSphere.CanCollide = false
        reachSphere.Transparency = 0.88
        reachSphere.Material = Enum.Material.ForceField
        reachSphere.Color = CONFIG.customColors.primary
        reachSphere.Parent = Workspace
    end)
end

local function destroyReachSphere()
    if reachSphere then
        pcall(function()
            reachSphere:Destroy()
        end)
        reachSphere = nil
    end
end

local function updateReachSphere()
    if not CONFIG.showReachSphere then
        destroyReachSphere()
        return
    end
    
    createReachSphere()
    
    if not reachSphere then 
        return 
    end
    
    if HRP and HRP.Parent then
        pcall(function()
            reachSphere.Position = HRP.Position
            -- Range efetivo com compensação de ping (NOVO)
            local effectiveRange = PingSystem:GetEffectiveRange(CONFIG.reach)
            reachSphere.Size = Vector3.new(effectiveRange * 2, effectiveRange * 2, effectiveRange * 2)
            reachSphere.Color = CONFIG.customColors.primary
        end)
    end
end

local function createArthurSphere()
    if arthurSphere and arthurSphere.Parent then 
        return 
    end
    
    pcall(function()
        arthurSphere = Instance.new("Part")
        arthurSphere.Name = "CAFUXZ1_ArthurSphere_v16"
        arthurSphere.Shape = Enum.PartType.Ball
        arthurSphere.Anchored = true
        arthurSphere.CanCollide = false
        arthurSphere.Material = CONFIG.arthurSphere.material
        arthurSphere.Transparency = 1
        arthurSphere.Color = CONFIG.arthurSphere.color
        arthurSphere.Parent = Workspace
    end)
end

local function destroyArthurSphere()
    if arthurSphere then
        pcall(function()
            arthurSphere:Destroy()
        end)
        arthurSphere = nil
    end
end

local function updateArthurSphere()
    createArthurSphere()
    
    if not arthurSphere then 
        return 
    end
    
    local shouldShow = CONFIG.showReachSphere and CONFIG.autoSecondTouch
    
    if HRP and HRP.Parent then
        pcall(function()
            arthurSphere.Position = HRP.Position
            -- Range efetivo com compensação de ping (NOVO)
            local effectiveRange = PingSystem:GetEffectiveRange(CONFIG.arthurSphere.reach)
            arthurSphere.Size = Vector3.new(effectiveRange * 2, effectiveRange * 2, effectiveRange * 2)
            arthurSphere.Color = CONFIG.arthurSphere.color
            arthurSphere.Transparency = shouldShow and CONFIG.arthurSphere.transparency or 1
            
            if shouldShow then
                local pulse = (math.sin(tick() * CONFIG.arthurSphere.pulseSpeed) + 1) / 2
                arthurSphere.Transparency = CONFIG.arthurSphere.transparency + (pulse * 0.1)
            end
        end)
    end
end

local function updateBothSpheres()
    updateReachSphere()
    updateArthurSphere()
end

local function destroyBothSpheres()
    destroyReachSphere()
    destroyArthurSphere()
end

local function setSpheresVisible(visible)
    CONFIG.showReachSphere = visible
    if not visible then
        destroyBothSpheres()
    else
        updateBothSpheres()
    end
    addLog("Esferas " .. (visible and "VISÍVEIS" or "OCULTAS"), "info")
end

-- ============================================
-- TOUCH SYSTEM (OTIMIZADO COM PING)
-- ============================================
local function doTouch(ball, part)
    if not ball or not ball.Parent or not part or not part.Parent then 
        return 
    end
    
    local key = tostring(ball.Name) .. "_" .. tostring(part.Name) .. "_" .. tostring(ball:GetFullName())
    -- Ajusta debounce baseado no ping (NOVO)
    local debounceTime = 0.05
    if PingSystem:IsHighLoad() then
        debounceTime = 0.08 -- Mais conservador em lag
    end
    
    if touchDebounce[key] and tick() - touchDebounce[key] < debounceTime then 
        return 
    end
    touchDebounce[key] = tick()
    
    pcall(function()
        firetouchinterest(ball, part, 0)
        task.wait(0.01)
        firetouchinterest(ball, part, 1)
        
        if CONFIG.autoSecondTouch then
            task.wait(0.03)
            firetouchinterest(ball, part, 0)
            firetouchinterest(ball, part, 1)
        end
    end)
end

local function processAutoTouch()
    if not CONFIG.autoTouch then 
        return 
    end
    
    if not HRP or not HRP.Parent then 
        return 
    end
    
    local now = tick()
    -- Ajusta cooldown baseado no ping (NOVO)
    local touchCooldown = 0.03
    if PingSystem:IsHighLoad() then
        touchCooldown = 0.05
    end
    
    if now - lastTouch < touchCooldown then 
        return 
    end
    
    local hrpPos = HRP.Position
    local characterParts = getBodyParts()
    if #characterParts == 0 then 
        return 
    end
    
    local ballInRange = false
    local closestBall = nil
    local closestDistance = PingSystem:GetEffectiveRange(CONFIG.reach) -- Range compensado
    
    -- Ordena por distância se smart priority estiver ativo (NOVO)
    local ballsToProcess = balls
    if CONFIG.pingOptimization.smartPriority and #balls > 1 then
        table.sort(balls, function(a, b)
            if not a or not b then return false end
            local distA = (a.Position - hrpPos).Magnitude
            local distB = (b.Position - hrpPos).Magnitude
            return distA < distB
        end)
        -- Limita processamento em pings altos
        if PingSystem:IsCritical() then
            ballsToProcess = {balls[1]} -- Só a mais próxima
        elseif PingSystem:IsHighLoad() then
            ballsToProcess = {balls[1], balls[2]} -- As duas mais próximas
        end
    end
    
    for _, ball in ipairs(ballsToProcess) do
        if ball and ball.Parent then
            local success, distance = pcall(function()
                return (ball.Position - hrpPos).Magnitude
            end)
            
            if success and distance and distance <= closestDistance then
                ballInRange = true
                closestDistance = distance
                closestBall = ball
            end
        end
    end
    
    if ballInRange and closestBall then
        lastTouch = now
        
        for _, part in ipairs(characterParts) do
            doTouch(closestBall, part)
        end
        
        STATS.totalTouches = STATS.totalTouches + 1
        STATS.ballsTouched = STATS.ballsTouched + 1
        currentBall = closestBall
    end
end

-- ============================================
-- AUTO SKILLS
-- ============================================
local cachedSkillButtons = nil
local lastSkillCache = 0

local function findSkillButtons()
    local buttons = {}
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then 
        return buttons 
    end
    
    pcall(function()
        for _, gui in ipairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and not gui.Name:match("CAFUXZ1") then
                for _, obj in ipairs(gui:GetDescendants()) do
                    if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                        for _, skillName in ipairs(skillButtonNames) do
                            if obj.Name == skillName or obj.Text == skillName then
                                table.insert(buttons, obj)
                                break
                            end
                        end
                    end
                end
            end
        end
    end)
    
    return buttons
end

local function activateSkillButton(button)
    if not button or not button.Parent then 
        return 
    end
    
    local key = tostring(button)
    if activatedSkills[key] and tick() - activatedSkills[key] < skillCooldown then 
        return 
    end
    activatedSkills[key] = tick()
    
    pcall(function()
        if button:IsA("GuiButton") then
            if button.MouseButton1Click then
                button.MouseButton1Click:Fire()
            end
            if button.Activated then
                button.Activated:Fire()
            end
            button.BackgroundColor3 = CONFIG.customColors.accent
            task.wait(0.1)
            button.BackgroundColor3 = CONFIG.customColors.bgElevated
        end
    end)
end

local function processAutoSkills()
    if not autoSkills then 
        return 
    end
    
    local now = tick()
    if now - lastSkillCheck < skillCheckInterval then 
        return 
    end
    lastSkillCheck = now
    
    if now - lastSkillActivation < skillCooldown then 
        return 
    end
    
    if not cachedSkillButtons or now - lastSkillCache > 5 then
        cachedSkillButtons = findSkillButtons()
        lastSkillCache = now
    end
    
    if not HRP or not HRP.Parent then 
        return 
    end
    
    local hrpPos = HRP.Position
    local ballInRange = false
    
    for _, ball in ipairs(balls) do
        if ball and ball.Parent then
            local success, dist = pcall(function()
                return (ball.Position - hrpPos).Magnitude
            end)
            if success and dist and dist <= PingSystem:GetEffectiveRange(CONFIG.reach) then
                ballInRange = true
                break
            end
        end
    end
    
    if not ballInRange then 
        return 
    end
    
    lastSkillActivation = now
    
    local mainSkills = {"Shoot", "Pass", "Dribble", "Control", "Tote", "Curva"}
    for _, button in ipairs(cachedSkillButtons) do
        for _, mainSkill in ipairs(mainSkills) do
            if button.Name == mainSkill or button.Text == mainSkill then
                activateSkillButton(button)
                STATS.skillsActivated = STATS.skillsActivated + 1
                return
            end
        end
    end
end

-- ============================================
-- TOTE SYSTEM v3.0 - CORRIGIDO
-- ============================================
local function getPerpendicularDirection(lookVector, direction)
    local right = Vector3.new(lookVector.Z, 0, -lookVector.X).Unit
    local left = -right
    
    if direction == "Right" then
        return right
    elseif direction == "Left" then
        return left
    else
        if currentBall and HRP then
            local ballPos = currentBall.Position
            local playerPos = HRP.Position
            local toBall = (ballPos - playerPos).Unit
            local dot = toBall:Dot(right)
            return dot > 0 and right or left
        end
        return right
    end
end

local function createToteVisualizer()
    if toteVisualizer then
        toteVisualizer:Destroy()
    end
    
    toteVisualizer = Instance.new("Folder")
    toteVisualizer.Name = "CAFUXZ1_ToteVisualizer"
    toteVisualizer.Parent = Workspace
    
    totePredictionPoints = {}
end

local function calculateTrajectory(startPos, endPos, curveHeight, curveSide)
    local points = {}
    local distance = (endPos - startPos).Magnitude
    local steps = 20
    
    local midPoint = (startPos + endPos) / 2
    local curveDirection = getPerpendicularDirection((endPos - startPos).Unit, curveSide)
    local controlPoint = midPoint + (curveDirection * curveHeight) + Vector3.new(0, CONFIG.tote.height, 0)
    
    for i = 0, steps do
        local t = i / steps
        local l1 = startPos:Lerp(controlPoint, t)
        local l2 = controlPoint:Lerp(endPos, t)
        local point = l1:Lerp(l2, t)
        table.insert(points, point)
    end
    
    return points
end

local function updateToteVisualizer()
    if not CONFIG.tote.visualizer or not toteActive then
        if toteVisualizer then
            toteVisualizer:Destroy()
            toteVisualizer = nil
        end
        return
    end
    
    if not currentBall or not HRP then return end
    
    if not toteVisualizer or not toteVisualizer.Parent then
        createToteVisualizer()
    end
    
    local ballPos = currentBall.Position
    local lookDir = HRP.CFrame.LookVector
    local targetPos = ballPos + (lookDir * CONFIG.tote.power)
    
    if CONFIG.tote.autoAim then
        pcall(function()
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj.Name:match("Goal") or obj.Name:match("Gol") then
                    local goalPos = obj.Position or obj:GetPivot().Position
                    if (goalPos - ballPos).Magnitude < 200 then
                        targetPos = goalPos
                        break
                    end
                end
            end
        end)
    end
    
    local points = calculateTrajectory(ballPos, targetPos, CONFIG.tote.curveAmount, CONFIG.tote.curveDirection)
    
    for i, point in ipairs(points) do
        local part = toteVisualizer:FindFirstChild("Point_" .. i)
        if not part then
            part = Instance.new("Part")
            part.Name = "Point_" .. i
            part.Shape = Enum.PartType.Ball
            part.Size = Vector3.new(0.3, 0.3, 0.3)
            part.Anchored = true
            part.CanCollide = false
            part.Material = Enum.Material.Neon
            part.Parent = toteVisualizer
        end
        
        part.Position = point
        part.Color = CONFIG.customColors.tote
        part.Transparency = 0.3 + (i / #points) * 0.5
        
        local size = 0.3 * (1 - (i / #points) * 0.5)
        part.Size = Vector3.new(size, size, size)
    end
    
    for i = #points + 1, 50 do
        local old = toteVisualizer:FindFirstChild("Point_" .. i)
        if old then old:Destroy() end
    end
end

local function applyTotePhysics(ball, direction, power, curveAmount)
    if not ball or not ball.Parent then return end
    
    local now = tick()
    if now - CONFIG.tote.lastKick < CONFIG.tote.debounce then return end
    CONFIG.tote.lastKick = now
    
    pcall(function()
        ball:SetNetworkOwner(nil)
        if ball.Anchored then
            ball.Anchored = false
        end
        
        local lookDir = HRP.CFrame.LookVector
        local baseVelocity = lookDir * power
        
        ball.AssemblyLinearVelocity = baseVelocity + Vector3.new(0, CONFIG.tote.height * 2, 0)
        
        local curveDir = getPerpendicularDirection(lookDir, direction)
        local spinAxis = Vector3.new(0, 1, 0):Cross(curveDir)
        
        local attachment = Instance.new("Attachment")
        attachment.Name = "ToteAttachment"
        attachment.Parent = ball
        
        local angularVel = Instance.new("AngularVelocity")
        angularVel.Name = "ToteAngularVelocity"
        angularVel.Attachment0 = attachment
        angularVel.AngularVelocity = spinAxis * CONFIG.tote.spinRate * (curveAmount / 50)
        angularVel.MaxTorque = 50000
        angularVel.Parent = ball
        
        local vectorForce = Instance.new("VectorForce")
        vectorForce.Name = "ToteVectorForce"
        vectorForce.Attachment0 = attachment
        vectorForce.Force = Vector3.new(0, 0, 0)
        
        local velocity = ball.AssemblyLinearVelocity
        local magnusDirection = velocity:Cross(Vector3.new(0, 1, 0)).Unit * (curveAmount / 100) * CONFIG.tote.magnusForce * power * 100
        vectorForce.Force = magnusDirection
        vectorForce.Parent = ball
        
        Debris:AddItem(attachment, 0.8)
        Debris:AddItem(angularVel, 0.8)
        Debris:AddItem(vectorForce, 0.8)
        
        local conn
        conn = RunService.Heartbeat:Connect(function()
            if not ball or not ball.Parent then
                conn:Disconnect()
                return
            end
            
            ball.AssemblyLinearVelocity = ball.AssemblyLinearVelocity * CONFIG.tote.airResistance
            
            if CONFIG.tote.gravityCompensation then
                ball.AssemblyLinearVelocity = ball.AssemblyLinearVelocity + Vector3.new(0, Workspace.Gravity * 0.016 * 0.3, 0)
            end
        end)
        
        task.delay(2, function()
            pcall(function() conn:Disconnect() end)
        end)
        
        STATS.toteKicks = STATS.toteKicks + 1
        notifyTote("🎯 Chute Executado!", "Tote aplicado com " .. power .. "% de força", 2)
        addLog("Tote executado! Power: " .. power .. " | Curva: " .. curveAmount, "success")
        
        pcall(function()
            local explosion = Instance.new("ParticleEmitter")
            explosion.Texture = "rbxassetid://258128463"
            explosion.Size = NumberSequence.new(2, 0)
            explosion.Lifetime = NumberRange.new(0.5)
            explosion.Rate = 0
            explosion.BurstCount = 10
            explosion.Color = ColorSequence.new(CONFIG.customColors.tote)
            explosion.Parent = ball
            explosion:Emit(10)
            Debris:AddItem(explosion, 1)
        end)
    end)
end

local function executeTote()
    if not CONFIG.tote.enabled then 
        notifyWarning("⚠️ Tote", "Ative o Tote na aba 🎯 primeiro!", 2)
        return 
    end
    
    if not currentBall or not currentBall.Parent then
        if HRP then
            local closest = nil
            local closestDist = PingSystem:GetEffectiveRange(CONFIG.reach)
            
            for _, ball in ipairs(balls) do
                if ball and ball.Parent then
                    local dist = (ball.Position - HRP.Position).Magnitude
                    if dist < closestDist then
                        closest = ball
                        closestDist = dist
                    end
                end
            end
            
            if closest then
                currentBall = closest
            else
                notifyTote("🎯 Tote", "Nenhuma bola próxima encontrada!", 2)
                return
            end
        end
    end
    
    applyTotePhysics(
        currentBall,
        CONFIG.tote.curveDirection,
        CONFIG.tote.power,
        CONFIG.tote.curveAmount
    )
end

local function toggleTote(enabled)
    CONFIG.tote.enabled = enabled
    toteActive = enabled
    
    if enabled then
        notifyTote("🎯 Tote Ativado", "Pressione " .. CONFIG.tote.keybind.Name .. " para chutes curvos!", 3)
        addLog("Tote System v3.0 ATIVADO", "success")
        
        task.spawn(function()
            while toteActive and CONFIG.tote.enabled do
                updateToteVisualizer()
                task.wait(0.1)
            end
            if toteVisualizer then
                toteVisualizer:Destroy()
                toteVisualizer = nil
            end
        end)
    else
        notifyWarning("⚠️ Tote Desativado", "Sistema de chutes curvos desligado.", 3)
        addLog("Tote System DESATIVADO", "warning")
        if toteVisualizer then
            toteVisualizer:Destroy()
            toteVisualizer = nil
        end
    end
end

-- ============================================
-- INTERFACE WINDUI v16.3 (COM PING MONITOR)
-- ============================================
local function createWindUI()
    local success = pcall(function()
        local existing = CoreGui:FindFirstChild("CAFUXZ1_Hub_v16")
        if existing then
            existing:Destroy()
        end
        
        isClosed = false
        
        mainGui = Instance.new("ScreenGui")
        mainGui.Name = "CAFUXZ1_Hub_v16"
        mainGui.ResetOnSpawn = false
        mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        mainGui.Parent = CoreGui
                mainFrame = Instance.new("Frame")
        mainFrame.Name = "MainFrame"
        
        if UserInputService.TouchEnabled then
            mainFrame.Size = UDim2.new(0, 380, 0, 450)
        else
            mainFrame.Size = UDim2.new(0, CONFIG.width, 0, CONFIG.height)
        end
        
        mainFrame.Position = UDim2.new(0.5, -mainFrame.Size.X.Offset/2, 0.5, -mainFrame.Size.Y.Offset/2)
        mainFrame.BackgroundColor3 = CONFIG.customColors.bgGlass
        mainFrame.BackgroundTransparency = 0.15
        mainFrame.BorderSizePixel = 0
        mainFrame.ClipsDescendants = true
        mainFrame.Parent = mainGui
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 16)
        corner.Parent = mainFrame
        
        local stroke = Instance.new("UIStroke")
        stroke.Name = "UIStroke"
        stroke.Color = CONFIG.customColors.primary
        stroke.Thickness = 2.5
        stroke.Transparency = 0.4
        stroke.Parent = mainFrame
        
        local gradient = Instance.new("UIGradient")
        gradient.Name = "UIGradient"
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, CONFIG.customColors.bgDark),
            ColorSequenceKeypoint.new(0.5, CONFIG.customColors.bgCard),
            ColorSequenceKeypoint.new(1, CONFIG.customColors.bgGlass)
        })
        gradient.Rotation = 135
        gradient.Parent = mainFrame
        
        local sidebar = Instance.new("Frame")
        sidebar.Name = "Sidebar"
        sidebar.Size = UDim2.new(0, CONFIG.sidebarWidth, 1, 0)
        sidebar.BackgroundColor3 = CONFIG.customColors.bgCard
        sidebar.BackgroundTransparency = 0.2
        sidebar.BorderSizePixel = 0
        sidebar.Parent = mainFrame
        
        local sidebarCorner = Instance.new("UICorner")
        sidebarCorner.CornerRadius = UDim.new(0, 16)
        sidebarCorner.Parent = sidebar
        
        local logoContainer = Instance.new("Frame")
        logoContainer.Size = UDim2.new(1, 0, 0, 80)
        logoContainer.BackgroundTransparency = 1
        logoContainer.Parent = sidebar
        
        local logoIcon = Instance.new("TextLabel")
        logoIcon.Size = UDim2.new(1, 0, 0, 50)
        logoIcon.Position = UDim2.new(0, 0, 0, 10)
        logoIcon.BackgroundTransparency = 1
        logoIcon.Text = "⚡"
        logoIcon.TextColor3 = CONFIG.customColors.primary
        logoIcon.TextSize = 36
        logoIcon.Font = Enum.Font.GothamBold
        logoIcon.Parent = logoContainer
        
        local logoText = Instance.new("TextLabel")
        logoText.Size = UDim2.new(1, 0, 0, 25)
        logoText.Position = UDim2.new(0, 0, 0, 55)
        logoText.BackgroundTransparency = 1
        logoText.Text = "v16.3"
        logoText.TextColor3 = CONFIG.customColors.tote
        logoText.TextSize = 12
        logoText.Font = Enum.Font.GothamBold
        logoText.Parent = logoContainer
        
        local tabs = {
            {name = "reach", icon = "⚽", label = "Reach"},
            {name = "tote", icon = "🎯", label = "Tote"},
            {name = "visual", icon = "👁️", label = "Visual"},
            {name = "char", icon = "👤", label = "Char"},
            {name = "sky", icon = "☁️", label = "Sky"},
            {name = "config", icon = "⚙️", label = "Config"},
            {name = "stats", icon = "📊", label = "Stats"}
        }
        
        local tabButtons = {}
        local contentFrames = {}
        
        for i, tab in ipairs(tabs) do
            local btn = Instance.new("TextButton")
            btn.Name = tab.name .. "Btn"
            btn.Size = UDim2.new(0.85, 0, 0, 42)
            btn.Position = UDim2.new(0.075, 0, 0, 95 + (i-1) * 50)
            btn.BackgroundColor3 = CONFIG.customColors.bgElevated
            btn.BackgroundTransparency = 0.6
            btn.Text = tab.icon .. " " .. tab.label
            btn.TextColor3 = CONFIG.customColors.textSecondary
            btn.TextSize = 12
            btn.Font = Enum.Font.GothamBold
            btn.Parent = sidebar
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 10)
            btnCorner.Parent = btn
            
            local indicator = Instance.new("Frame")
            indicator.Name = "Indicator"
            indicator.Size = UDim2.new(0, 3, 0.6, 0)
            indicator.Position = UDim2.new(0, 0, 0.2, 0)
            indicator.BackgroundColor3 = CONFIG.customColors.primary
            indicator.BorderSizePixel = 0
            indicator.Visible = false
            indicator.Parent = btn
            
            tabButtons[tab.name] = btn
            
            local content = Instance.new("ScrollingFrame")
            content.Name = tab.name .. "Content"
            content.Size = UDim2.new(1, -CONFIG.sidebarWidth - 15, 1, -70)
            content.Position = UDim2.new(0, CONFIG.sidebarWidth + 10, 0, 60)
            content.BackgroundTransparency = 1
            content.BorderSizePixel = 0
            content.ScrollBarThickness = 6
            content.ScrollBarImageColor3 = CONFIG.customColors.primary
            content.Visible = false
            content.Parent = mainFrame
            
            local layout = Instance.new("UIListLayout")
            layout.Padding = UDim.new(0, 15)
            layout.Parent = content
            
            contentFrames[tab.name] = content
        end
        
        local header = Instance.new("Frame")
        header.Name = "Header"
        header.Size = UDim2.new(1, -CONFIG.sidebarWidth, 0, 50)
        header.Position = UDim2.new(0, CONFIG.sidebarWidth, 0, 5)
        header.BackgroundTransparency = 1
        header.Parent = mainFrame
        
        local headerTitle = Instance.new("TextLabel")
        headerTitle.Name = "HeaderTitle"
        headerTitle.Size = UDim2.new(0.5, 0, 1, 0)
        headerTitle.Position = UDim2.new(0, 20, 0, 0)
        headerTitle.BackgroundTransparency = 1
        headerTitle.Text = "CAFUXZ1 Hub"
        headerTitle.TextColor3 = CONFIG.customColors.textPrimary
        headerTitle.TextSize = 22
        headerTitle.Font = Enum.Font.GothamBold
        headerTitle.TextXAlignment = Enum.TextXAlignment.Left
        headerTitle.Parent = header
        
        local headerSubtitle = Instance.new("TextLabel")
        headerSubtitle.Size = UDim2.new(0.5, 0, 0, 20)
        headerSubtitle.Position = UDim2.new(0, 20, 0, 30)
        headerSubtitle.BackgroundTransparency = 1
        headerSubtitle.Text = "Revolution v16.3 PING+"
        headerSubtitle.TextColor3 = CONFIG.customColors.textMuted
        headerSubtitle.TextSize = 11
        headerSubtitle.Font = Enum.Font.Gotham
        headerSubtitle.TextXAlignment = Enum.TextXAlignment.Left
        headerSubtitle.Parent = header
        
        -- MONITOR DE PING NO HEADER (NOVO)
        local pingMonitor = Instance.new("TextLabel")
        pingMonitor.Name = "PingMonitor"
        pingMonitor.Size = UDim2.new(0, 120, 0, 25)
        pingMonitor.Position = UDim2.new(1, -140, 0, 12)
        pingMonitor.BackgroundColor3 = CONFIG.customColors.bgElevated
        pingMonitor.BackgroundTransparency = 0.5
        pingMonitor.Text = "📶 -- ms"
        pingMonitor.TextColor3 = CONFIG.customColors.ping
        pingMonitor.TextSize = 12
        pingMonitor.Font = Enum.Font.GothamBold
        pingMonitor.Parent = header
        
        local pingCorner = Instance.new("UICorner")
        pingCorner.CornerRadius = UDim.new(0, 8)
        pingCorner.Parent = pingMonitor
        
        -- Atualiza monitor de ping
        task.spawn(function()
            while mainGui and mainGui.Parent do
                local icon, color = PingSystem:GetStatusVisuals()
                pingMonitor.Text = icon .. " " .. PingSystem.AveragePing .. " ms"
                pingMonitor.TextColor3 = color
                task.wait(0.5)
            end
        end)
        
        local minimizeBtn = Instance.new("TextButton")
        minimizeBtn.Name = "MinimizeBtn"
        minimizeBtn.Size = UDim2.new(0, 38, 0, 38)
        minimizeBtn.Position = UDim2.new(1, -90, 0, 6)
        minimizeBtn.BackgroundColor3 = CONFIG.customColors.warning
        minimizeBtn.Text = "−"
        minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
        minimizeBtn.TextSize = 24
        minimizeBtn.Font = Enum.Font.GothamBold
        minimizeBtn.Parent = header
        
        local minCorner = Instance.new("UICorner")
        minCorner.CornerRadius = UDim.new(0, 10)
        minCorner.Parent = minimizeBtn
        
        local closeBtn = Instance.new("TextButton")
        closeBtn.Name = "CloseBtn"
        closeBtn.Size = UDim2.new(0, 38, 0, 38)
        closeBtn.Position = UDim2.new(1, -45, 0, 6)
        closeBtn.BackgroundColor3 = CONFIG.customColors.danger
        closeBtn.Text = "×"
        closeBtn.TextColor3 = Color3.new(1, 1, 1)
        closeBtn.TextSize = 24
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.Parent = header
        
        local closeCorner = Instance.new("UICorner")
        closeCorner.CornerRadius = UDim.new(0, 10)
        closeCorner.Parent = closeBtn
        
        -- FUNÇÕES UI
        local function createSection(parent, title, accentColor)
            accentColor = accentColor or CONFIG.customColors.primary
            
            local section = Instance.new("Frame")
            section.Size = UDim2.new(0.96, 0, 0, 0)
            section.AutomaticSize = Enum.AutomaticSize.Y
            section.BackgroundColor3 = CONFIG.customColors.bgCard
            section.BackgroundTransparency = 0.3
            section.BorderSizePixel = 0
            section.Parent = parent
            
            local sectionCorner = Instance.new("UICorner")
            sectionCorner.CornerRadius = UDim.new(0, 12)
            sectionCorner.Parent = section
            
            local sectionStroke = Instance.new("UIStroke")
            sectionStroke.Color = accentColor
            sectionStroke.Thickness = 1
            sectionStroke.Transparency = 0.7
            sectionStroke.Parent = section
            
            local sectionTitle = Instance.new("TextLabel")
            sectionTitle.Size = UDim2.new(1, -20, 0, 30)
            sectionTitle.Position = UDim2.new(0, 10, 0, 8)
            sectionTitle.BackgroundTransparency = 1
            sectionTitle.Text = "◆ " .. tostring(title)
            sectionTitle.TextColor3 = accentColor
            sectionTitle.TextSize = 15
            sectionTitle.Font = Enum.Font.GothamBold
            sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            sectionTitle.Parent = section
            
            local sectionContent = Instance.new("Frame")
            sectionContent.Name = "Content"
            sectionContent.Size = UDim2.new(1, -20, 0, 0)
            sectionContent.Position = UDim2.new(0, 10, 0, 38)
            sectionContent.AutomaticSize = Enum.AutomaticSize.Y
            sectionContent.BackgroundTransparency = 1
            sectionContent.Parent = section
            
            local sectionLayout = Instance.new("UIListLayout")
            sectionLayout.Padding = UDim.new(0, 12)
            sectionLayout.Parent = sectionContent
            
            return section, sectionContent
        end
        
        local function createToggle(parent, text, default, callback, accent)
            accent = accent or CONFIG.customColors.success
            
            local toggleFrame = Instance.new("Frame")
            toggleFrame.Size = UDim2.new(1, 0, 0, 45)
            toggleFrame.BackgroundTransparency = 1
            toggleFrame.Parent = parent
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.65, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = tostring(text)
            label.TextColor3 = CONFIG.customColors.textSecondary
            label.TextSize = 14
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = toggleFrame
            
            local toggleBtn = Instance.new("TextButton")
            toggleBtn.Size = UDim2.new(0, 60, 0, 32)
            toggleBtn.Position = UDim2.new(1, -60, 0.5, -16)
            toggleBtn.BackgroundColor3 = default and accent or CONFIG.customColors.bgElevated
            toggleBtn.Text = default and "ON" or "OFF"
            toggleBtn.TextColor3 = Color3.new(1, 1, 1)
            toggleBtn.TextSize = 14
            toggleBtn.Font = Enum.Font.GothamBold
            toggleBtn.Parent = toggleFrame
            
            local toggleCorner = Instance.new("UICorner")
            toggleCorner.CornerRadius = UDim.new(0, 16)
            toggleCorner.Parent = toggleBtn
            
            local enabled = default
            
            toggleBtn.MouseButton1Click:Connect(function()
                enabled = not enabled
                toggleBtn.BackgroundColor3 = enabled and accent or CONFIG.customColors.bgElevated
                toggleBtn.Text = enabled and "ON" or "OFF"
                
                pcall(function()
                    tween(toggleBtn, {Size = UDim2.new(0, 58, 0, 30)}, 0.05)
                    task.wait(0.05)
                    tween(toggleBtn, {Size = UDim2.new(0, 60, 0, 32)}, 0.1)
                end)
                
                if callback then 
                    callback(enabled) 
                end
            end)
            
            return toggleFrame, toggleBtn
        end
        
        local function createSlider(parent, labelText, min, max, default, callback, accent)
            accent = accent or CONFIG.customColors.primary
            
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 70)
            frame.BackgroundTransparency = 1
            frame.Parent = parent
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.7, 0, 0, 25)
            label.BackgroundTransparency = 1
            label.Text = tostring(labelText)
            label.TextColor3 = CONFIG.customColors.textSecondary
            label.TextSize = 14
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = frame
            
            local valueLabel = Instance.new("TextLabel")
            valueLabel.Size = UDim2.new(0.3, 0, 0, 25)
            valueLabel.Position = UDim2.new(0.7, 0, 0, 0)
            valueLabel.BackgroundTransparency = 1
            valueLabel.Text = tostring(default)
            valueLabel.TextColor3 = accent
            valueLabel.TextSize = 16
            valueLabel.Font = Enum.Font.GothamBold
            valueLabel.TextXAlignment = Enum.TextXAlignment.Right
            valueLabel.Parent = frame
            
            local sliderBg = Instance.new("Frame")
            sliderBg.Size = UDim2.new(1, 0, 0, 10)
            sliderBg.Position = UDim2.new(0, 0, 0, 35)
            sliderBg.BackgroundColor3 = CONFIG.customColors.bgElevated
            sliderBg.BorderSizePixel = 0
            sliderBg.Parent = frame
            
            local sliderBgCorner = Instance.new("UICorner")
            sliderBgCorner.CornerRadius = UDim.new(0, 5)
            sliderBgCorner.Parent = sliderBg
            
            local sliderFill = Instance.new("Frame")
            sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            sliderFill.BackgroundColor3 = accent
            sliderFill.BorderSizePixel = 0
            sliderFill.Parent = sliderBg
            
            local sliderFillCorner = Instance.new("UICorner")
            sliderFillCorner.CornerRadius = UDim.new(0, 5)
            sliderFillCorner.Parent = sliderFill
            
            local dragging = false
            
            local function updateSlider(input)
                local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                local value = math.floor(min + (pos * (max - min)))
                
                sliderFill.Size = UDim2.new(pos, 0, 1, 0)
                valueLabel.Text = tostring(value)
                
                if callback then
                    callback(value)
                end
            end
            
            sliderBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    updateSlider(input)
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(input)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            
            return frame
        end
        
        local function createButton(parent, text, color, callback, icon)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 45)
            btn.BackgroundColor3 = color or CONFIG.customColors.primary
            btn.Text = (icon or "") .. " " .. tostring(text)
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.TextSize = 14
            btn.Font = Enum.Font.GothamBold
            btn.Parent = parent
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 10)
            btnCorner.Parent = btn
            
            btn.MouseButton1Click:Connect(function()
                pcall(function()
                    tween(btn, {Size = UDim2.new(0.97, 0, 0, 43)}, 0.05)
                    task.wait(0.05)
                    tween(btn, {Size = UDim2.new(1, 0, 0, 45)}, 0.1)
                end)
                if callback then 
                    callback() 
                end
            end)
            
            return btn
        end
        
        local function createDropdown(parent, labelText, options, default, callback)
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 80)
            frame.BackgroundTransparency = 1
            frame.Parent = parent
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 0, 25)
            label.BackgroundTransparency = 1
            label.Text = tostring(labelText)
            label.TextColor3 = CONFIG.customColors.textSecondary
            label.TextSize = 14
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = frame
            
            local dropdown = Instance.new("TextButton")
            dropdown.Size = UDim2.new(1, 0, 0, 40)
            dropdown.Position = UDim2.new(0, 0, 0, 30)
            dropdown.BackgroundColor3 = CONFIG.customColors.bgElevated
            dropdown.Text = tostring(default)
            dropdown.TextColor3 = CONFIG.customColors.textPrimary
            dropdown.TextSize = 14
            dropdown.Font = Enum.Font.GothamBold
            dropdown.Parent = frame
            
            local dropdownCorner = Instance.new("UICorner")
            dropdownCorner.CornerRadius = UDim.new(0, 8)
            dropdownCorner.Parent = dropdown
            
            local arrow = Instance.new("TextLabel")
            arrow.Size = UDim2.new(0, 30, 1, 0)
            arrow.Position = UDim2.new(1, -35, 0, 0)
            arrow.BackgroundTransparency = 1
            arrow.Text = "▼"
            arrow.TextColor3 = CONFIG.customColors.textMuted
            arrow.TextSize = 12
            arrow.Font = Enum.Font.GothamBold
            arrow.Parent = dropdown
            
            local expanded = false
            local optionsFrame = nil
            
            dropdown.MouseButton1Click:Connect(function()
                expanded = not expanded
                arrow.Text = expanded and "▲" or "▼"
                
                if expanded then
                    optionsFrame = Instance.new("Frame")
                    optionsFrame.Size = UDim2.new(1, 0, 0, #options * 35)
                    optionsFrame.Position = UDim2.new(0, 0, 1, 5)
                    optionsFrame.BackgroundColor3 = CONFIG.customColors.bgElevated
                    optionsFrame.BorderSizePixel = 0
                    optionsFrame.ZIndex = 10
                    optionsFrame.Parent = dropdown
                    
                    local optionsCorner = Instance.new("UICorner")
                    optionsCorner.CornerRadius = UDim.new(0, 8)
                    optionsCorner.Parent = optionsFrame
                    
                    for i, option in ipairs(options) do
                        local optBtn = Instance.new("TextButton")
                        optBtn.Size = UDim2.new(1, 0, 0, 35)
                        optBtn.Position = UDim2.new(0, 0, 0, (i-1) * 35)
                        optBtn.BackgroundTransparency = 1
                        optBtn.Text = tostring(option)
                        optBtn.TextColor3 = CONFIG.customColors.textSecondary
                        optBtn.TextSize = 13
                        optBtn.Font = Enum.Font.Gotham
                        optBtn.ZIndex = 11
                        optBtn.Parent = optionsFrame
                        
                        optBtn.MouseButton1Click:Connect(function()
                            dropdown.Text = tostring(option)
                            expanded = false
                            arrow.Text = "▼"
                            optionsFrame:Destroy()
                            if callback then
                                callback(option)
                            end
                        end)
                    end
                else
                    if optionsFrame then
                        optionsFrame:Destroy()
                    end
                end
            end)
            
            return frame
        end
        
        -- POPULAR ABAS
        local reachSection, reachContent = createSection(contentFrames.reach, "Configurações de Reach")
        
        createToggle(reachContent, "Auto Touch", CONFIG.autoTouch, function(val)
            CONFIG.autoTouch = val
            addLog("Auto Touch: " .. (val and "ON" or "OFF"), val and "success" or "warning")
            notify(val and "✅ Auto Touch ON" or "⚠️ Auto Touch OFF", val and "Sistema de toque automático ativado!" or "Toque automático desativado.", 2)
        end)
        
        createToggle(reachContent, "Full Body Touch", CONFIG.fullBodyTouch, function(val)
            CONFIG.fullBodyTouch = val
            notify(val and "✅ Full Body ON" or "⚠️ Full Body OFF", val and "Toque em todo o corpo ativado!" or "Apenas HRP para toque.", 2)
        end)
        
        createToggle(reachContent, "Double Touch (Arthur)", CONFIG.autoSecondTouch, function(val)
            CONFIG.autoSecondTouch = val
            updateArthurSphere()
            notify(val and "✅ Double Touch ON" or "⚠️ Double Touch OFF", val and "Sistema Arthur ativado!" or "Double touch desativado.", 2)
        end, CONFIG.arthurSphere.color)
        
        createToggle(reachContent, "Mostrar Esferas", CONFIG.showReachSphere, function(val)
            setSpheresVisible(val)
            notify(val and "👁️ Esferas Visíveis" or "👁️‍🗨️ Esferas Ocultas", val and "Visualização de alcance ativada!" or "Esferas de alcance ocultas.", 2)
        end)
        
        createToggle(reachContent, "Auto Skills", autoSkills, function(val)
            autoSkills = val
            notify(val and "⚡ Auto Skills ON" or "⚠️ Auto Skills OFF", val and "Ativação automática de skills!" or "Auto skills desativado.", 2)
        end)
        
        -- NOVO: Toggle de otimização de ping na aba reach
        createToggle(reachContent, "Otimização de Ping", CONFIG.pingOptimization.enabled, function(val)
            CONFIG.pingOptimization.enabled = val
            notifyPing(val and "📶 Ping Optimization ON" or "📶 Ping Optimization OFF", 
                val and "Sistema adaptativo de ping ativado!" or "Otimização de ping desativada.", 3)
        end, CONFIG.customColors.ping)
        
        createSlider(reachContent, "Alcance Principal", 5, 100, CONFIG.reach, function(val)
            CONFIG.reach = val
        end)
        
        createSlider(reachContent, "Alcance Arthur", 1, 150, CONFIG.arthurSphere.reach, function(val)
            CONFIG.arthurSphere.reach = val
        end, CONFIG.arthurSphere.color)
        
        -- NOVO: Slider de compensação de ping
        createSlider(reachContent, "Compensação de Ping", 0, 30, CONFIG.pingOptimization.compensationRange * 100, function(val)
            CONFIG.pingOptimization.compensationRange = val / 100
            notifyPing("📶 Compensação", "Range aumentado em " .. val .. "% quando ping alto", 2)
        end, CONFIG.customColors.ping)
        
        -- ABA TOTE
        local toteSection, toteContent = createSection(contentFrames.tote, "Tote System v3.0", CONFIG.customColors.tote)
        
        createToggle(toteContent, "Ativar Tote", CONFIG.tote.enabled, function(val)
            toggleTote(val)
        end, CONFIG.customColors.tote)
        
        createToggle(toteContent, "Visualizador de Trajetória", CONFIG.tote.visualizer, function(val)
            CONFIG.tote.visualizer = val
            notify(val and "👁️ Visualizador ON" or "👁️‍🗨️ Visualizador OFF", val and "Trajetória 3D visível!" or "Visualizador desativado.", 2)
        end, CONFIG.customColors.tote)
        
        createToggle(toteContent, "Auto-Aim no Gol", CONFIG.tote.autoAim, function(val)
            CONFIG.tote.autoAim = val
            notify(val and "🎯 Auto-Aim ON" or "⚠️ Auto-Aim OFF", val and "Mira automática no gol!" or "Mira manual ativada.", 2)
        end)
        
        createToggle(toteContent, "Predição de Bola", CONFIG.tote.prediction, function(val)
            CONFIG.tote.prediction = val
            notify(val and "🔮 Predição ON" or "⚠️ Predição OFF", val and "Predição de trajetória ativa!" or "Predição desativada.", 2)
        end)
        
        createSlider(toteContent, "Força do Chute", 10, 100, CONFIG.tote.power, function(val)
            CONFIG.tote.power = val
        end, CONFIG.customColors.tote)
        
        createSlider(toteContent, "Intensidade da Curva", 0, 100, CONFIG.tote.curveAmount, function(val)
            CONFIG.tote.curveAmount = val
        end, CONFIG.customColors.tote)
        
        createSlider(toteContent, "Altura do Chute", 0, 50, CONFIG.tote.height, function(val)
            CONFIG.tote.height = val
        end)
        
        createSlider(toteContent, "Taxa de Rotação", 1, 20, CONFIG.tote.spinRate, function(val)
            CONFIG.tote.spinRate = val
        end, CONFIG.customColors.tote)
        
        createDropdown(toteContent, "Direção da Curva", {"Auto", "Left", "Right"}, CONFIG.tote.curveDirection, function(val)
            CONFIG.tote.curveDirection = val
            notify("🔄 Direção", "Curva definida para: " .. val, 2)
        end)
        
        createButton(toteContent, "EXECUTAR CHUTE TOTE", CONFIG.customColors.tote, function()
            executeTote()
        end, "🎯")
        
        local toteInfo = Instance.new("TextLabel")
        toteInfo.Size = UDim2.new(1, 0, 0, 60)
        toteInfo.BackgroundTransparency = 1
        toteInfo.Text = "💡 DICA: Pressione " .. CONFIG.tote.keybind.Name .. " para executar o chute curvo perfeito!"
        toteInfo.TextColor3 = CONFIG.customColors.textMuted
        toteInfo.TextSize = 12
        toteInfo.Font = Enum.Font.Gotham
        toteInfo.TextWrapped = true
        toteInfo.Parent = toteContent
        
        -- ABA VISUAL
        local visualSection, visualContent = createSection(contentFrames.visual, "Anti Lag & Efeitos")
        
        createToggle(visualContent, "Ativar Anti Lag", CONFIG.antiLag.enabled, function(val)
            CONFIG.antiLag.enabled = val
            if val then 
                applyAntiLag() 
            else 
                disableAntiLag() 
            end
        end)
        
        createToggle(visualContent, "Full Bright", CONFIG.antiLag.fullBright, function(val)
            CONFIG.antiLag.fullBright = val
            if val then
                Lighting.Brightness = 10
                Lighting.GlobalShadows = false
                notifySuccess("☀️ Full Bright", "Iluminação máxima ativada!", 2)
            else
                Lighting.Brightness = 2
                Lighting.GlobalShadows = true
                notify("🌑 Full Bright OFF", "Iluminação normal restaurada.", 2)
            end
        end)
        
        -- ABA CHAR
        local charSection, charContent = createSection(contentFrames.char, "Morph Avatar", CONFIG.customColors.secondary)
        
        local usernameInput = Instance.new("TextBox")
        usernameInput.Size = UDim2.new(1, 0, 0, 40)
        usernameInput.BackgroundColor3 = CONFIG.customColors.bgElevated
        usernameInput.Text = ""
        usernameInput.PlaceholderText = "Digite o username..."
        usernameInput.PlaceholderColor3 = CONFIG.customColors.textMuted
        usernameInput.TextColor3 = CONFIG.customColors.textPrimary
        usernameInput.TextSize = 14
        usernameInput.Font = Enum.Font.Gotham
        usernameInput.Parent = charContent
        
        local inputCorner = Instance.new("UICorner")
        inputCorner.CornerRadius = UDim.new(0, 10)
        inputCorner.Parent = usernameInput
        
        createButton(charContent, "Aplicar Morph", CONFIG.customColors.primary, function()
            local username = usernameInput.Text
            if username and username ~= "" then
                task.spawn(function()
                    local userId
                    local success = pcall(function()
                        userId = Players:GetUserIdFromNameAsync(username)
                    end)
                    if success and userId then 
                        morphToUser(userId, username) 
                    else
                        notifyError("❌ Erro", "Usuário não encontrado!", 3)
                    end
                end)
            else
                notifyWarning("⚠️ Atenção", "Digite um username válido!", 2)
            end
        end)
        
        local presetsLabel = Instance.new("TextLabel")
        presetsLabel.Size = UDim2.new(1, 0, 0, 25)
        presetsLabel.BackgroundTransparency = 1
        presetsLabel.Text = "Presets Rápidos:"
        presetsLabel.TextColor3 = CONFIG.customColors.textSecondary
        presetsLabel.TextSize = 13
        presetsLabel.Font = Enum.Font.GothamBold
        presetsLabel.TextXAlignment = Enum.TextXAlignment.Left
        presetsLabel.Parent = charContent
        
        for _, preset in ipairs(PRESET_MORPHS) do
            createButton(charContent, preset.displayName, CONFIG.customColors.bgElevated, function()
                if preset.userId then 
                    morphToUser(preset.userId, preset.displayName) 
                else
                    notifyWarning("⏳ Aguarde", "Carregando ID do usuário...", 2)
                end
            end)
        end
        
        -- ABA SKYBOX
        local skySection, skyContent = createSection(contentFrames.sky, "Skybox System", CONFIG.customColors.accent)
        
        local CategoryColors = {
            ["1"] = Color3.fromRGB(0, 120, 255),
            ["2"] = Color3.fromRGB(0, 200, 100),
            ["3"] = Color3.fromRGB(255, 170, 0),
            ["4"] = Color3.fromRGB(180, 0, 220),
        }
        
        local function loadSkyCategory(categoryNum)
            for _, child in ipairs(skyContent:GetChildren()) do
                if child.Name ~= "UIListLayout" and child:IsA("Frame") then
                    child:Destroy()
                end
            end
            
            local skyItemsFrame = Instance.new("Frame")
            skyItemsFrame.Size = UDim2.new(1, 0, 0, 0)
            skyItemsFrame.AutomaticSize = Enum.AutomaticSize.Y
            skyItemsFrame.BackgroundTransparency = 1
            skyItemsFrame.Parent = skyContent
            
            local itemsLayout = Instance.new("UIListLayout")
            itemsLayout.Padding = UDim.new(0, 8)
            itemsLayout.Parent = skyItemsFrame
            
            for _, sky in ipairs(SkyboxDatabase) do
                if sky.category == categoryNum then
                    createButton(skyItemsFrame, sky.name, CategoryColors[categoryNum], function()
                        saveOriginalSkybox()
                        ApplySkybox(sky.id, sky.name)
                    end)
                end
            end
        end
        
        createButton(skyContent, "🌌 Cosmos", CategoryColors["1"], function() loadSkyCategory("1") end)
        createButton(skyContent, "🌅 Atmosféricos", CategoryColors["2"], function() loadSkyCategory("2") end)
        createButton(skyContent, "🎨 Custom", CategoryColors["3"], function() loadSkyCategory("3") end)
        createButton(skyContent, "✨ Especiais", CategoryColors["4"], function() loadSkyCategory("4") end)
        createButton(skyContent, "↩️ Resetar Skybox", CONFIG.customColors.danger, function()
            restoreOriginalSkybox()
            notify("↩️ Skybox", "Céu original restaurado com sucesso!", 2)
        end)
        
        -- ABA CONFIG
        local configSection, configContent = createSection(contentFrames.config, "Personalização")
        
        createSlider(configContent, "Cor Primária (R)", 0, 255, CONFIG.customColors.primary.R * 255, function(val)
            CONFIG.customColors.primary = Color3.fromRGB(val, CONFIG.customColors.primary.G * 255, CONFIG.customColors.primary.B * 255)
        end)
        
        createSlider(configContent, "Cor Tote (R)", 0, 255, CONFIG.customColors.tote.R * 255, function(val)
            CONFIG.customColors.tote = Color3.fromRGB(val, CONFIG.customColors.tote.G * 255, CONFIG.customColors.tote.B * 255)
        end, CONFIG.customColors.tote)
        
        createSlider(configContent, "Cor Ping (R)", 0, 255, CONFIG.customColors.ping.R * 255, function(val)
            CONFIG.customColors.ping = Color3.fromRGB(val, CONFIG.customColors.ping.G * 255, CONFIG.customColors.ping.B * 255)
        end, CONFIG.customColors.ping)
        
        createButton(configContent, "🔄 Resetar Configurações", CONFIG.customColors.warning, function()
            CONFIG.reach = 15
            CONFIG.tote.power = 50
            CONFIG.tote.curveAmount = 30
            CONFIG.pingOptimization.compensationRange = 0.15
            notifySuccess("🔄 Reset", "Configurações padrão restauradas!", 3)
        end)
        
        -- ABA STATS
        local statsSection, statsContent = createSection(contentFrames.stats, "Estatísticas da Sessão", CONFIG.customColors.info)
        
        local statsContainer = Instance.new("Frame")
        statsContainer.Size = UDim2.new(1, 0, 0, 0)
        statsContainer.AutomaticSize = Enum.AutomaticSize.Y
        statsContainer.BackgroundTransparency = 1
        statsContainer.Parent = statsContent
        
        local statsLayout = Instance.new("UIListLayout")
        statsLayout.Padding = UDim.new(0, 10)
        statsLayout.Parent = statsContainer
        
        local statsLabels = {}
        local statItems = {
            {k="totalTouches", l="Total de Toques", icon="👆"},
            {k="ballsTouched", l="Bolas Tocadas", icon="⚽"},
            {k="skillsActivated", l="Skills Ativadas", icon="⚡"},
            {k="toteKicks", l="Chutes Tote", icon="🎯"},
            {k="morphsDone", l="Morphs Realizados", icon="👤"},
            {k="antiLagItems", l="Itens Otimizados", icon="🚀"},
            {k="avgPing", l="Ping Médio", icon="📶"}, -- NOVO
            {k="fps", l="FPS Atual", icon="🎮"} -- NOVO
        }
        
        for _, item in ipairs(statItems) do
            local f = Instance.new("Frame")
            f.Size = UDim2.new(1, 0, 0, 50)
            f.BackgroundColor3 = CONFIG.customColors.bgElevated
            f.BackgroundTransparency = 0.5
            f.BorderSizePixel = 0
            
            local fCorner = Instance.new("UICorner")
            fCorner.CornerRadius = UDim.new(0, 10)
            fCorner.Parent = f
            
            local icon = Instance.new("TextLabel")
            icon.Size = UDim2.new(0, 40, 1, 0)
            icon.BackgroundTransparency = 1
            icon.Text = item.icon
            icon.TextSize = 24
            icon.Font = Enum.Font.Gotham
            icon.Parent = f
            
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0.5, 0, 1, 0)
            lbl.Position = UDim2.new(0, 45, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = item.l
            lbl.TextColor3 = CONFIG.customColors.textSecondary
            lbl.TextSize = 14
            lbl.Font = Enum.Font.Gotham
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = f
            
            local val = Instance.new("TextLabel")
            val.Size = UDim2.new(0.3, 0, 1, 0)
            val.Position = UDim2.new(0.7, 0, 0, 0)
            val.BackgroundTransparency = 1
            val.Text = "0"
            val.TextColor3 = CONFIG.customColors.primary
            val.TextSize = 20
            val.Font = Enum.Font.GothamBold
            val.Parent = f
            
            statsLabels[item.k] = val
            f.Parent = statsContainer
        end
        
        local timeFrame = Instance.new("Frame")
        timeFrame.Size = UDim2.new(1, 0, 0, 40)
        timeFrame.BackgroundColor3 = CONFIG.customColors.bgElevated
        timeFrame.BackgroundTransparency = 0.3
        timeFrame.BorderSizePixel = 0
        
        local timeCorner = Instance.new("UICorner")
        timeCorner.CornerRadius = UDim.new(0, 10)
        timeCorner.Parent = timeFrame
        
        local timeIcon = Instance.new("TextLabel")
        timeIcon.Size = UDim2.new(0, 40, 1, 0)
        timeIcon.BackgroundTransparency = 1
        timeIcon.Text = "⏱️"
        timeIcon.TextSize = 20
        timeIcon.Parent = timeFrame
        
        local timeLabel = Instance.new("TextLabel")
        timeLabel.Size = UDim2.new(0.6, 0, 1, 0)
        timeLabel.Position = UDim2.new(0, 45, 0, 0)
        timeLabel.BackgroundTransparency = 1
        timeLabel.Text = "Tempo de Sessão"
        timeLabel.TextColor3 = CONFIG.customColors.textSecondary
        timeLabel.TextSize = 14
        timeLabel.Font = Enum.Font.Gotham
        timeLabel.TextXAlignment = Enum.TextXAlignment.Left
        timeLabel.Parent = timeFrame
        
        local timeValue = Instance.new("TextLabel")
        timeValue.Size = UDim2.new(0.3, 0, 1, 0)
        timeValue.Position = UDim2.new(0.7, 0, 0, 0)
        timeValue.BackgroundTransparency = 1
        timeValue.Text = "00:00"
        timeValue.TextColor3 = CONFIG.customColors.success
        timeValue.TextSize = 16
        timeValue.Font = Enum.Font.GothamBold
        timeValue.Parent = timeFrame
        
        timeFrame.Parent = statsContainer
        
        task.spawn(function()
            while mainGui and mainGui.Parent do
                local now = tick()
                if now - lastStatsUpdate >= statsUpdateInterval then
                    lastStatsUpdate = now
                    for k, lbl in pairs(statsLabels) do
                        pcall(function()
                            lbl.Text = tostring(STATS[k] or 0)
                        end)
                    end
                    
                    local elapsed = now - STATS.sessionStart
                    local mins = math.floor(elapsed / 60)
                    local secs = math.floor(elapsed % 60)
                    timeValue.Text = string.format("%02d:%02d", mins, secs)
                end
                task.wait(0.1)
            end
        end)
        
        -- NAVEGAÇÃO
        local function switchTab(tabName)
            currentTab = tabName
            for name, btn in pairs(tabButtons) do
                local indicator = btn:FindFirstChild("Indicator")
                if name == tabName then
                    pcall(function()
                        tween(btn, {BackgroundColor3 = CONFIG.customColors.bgElevated, BackgroundTransparency = 0.2}, 0.2)
                    end)
                    btn.TextColor3 = CONFIG.customColors.textPrimary
                    if indicator then indicator.Visible = true end
                else
                    pcall(function()
                        tween(btn, {BackgroundColor3 = CONFIG.customColors.bgElevated, BackgroundTransparency = 0.6}, 0.2)
                    end)
                    btn.TextColor3 = CONFIG.customColors.textSecondary
                    if indicator then indicator.Visible = false end
                end
            end
            for name, frame in pairs(contentFrames) do
                frame.Visible = (name == tabName)
            end
        end
        
        for name, btn in pairs(tabButtons) do
            btn.MouseButton1Click:Connect(function() 
                switchTab(name) 
            end)
        end
        
        switchTab("reach")
        
        -- MINIMIZAR/RESTAURAR
        local function minimizeUI()
            isMinimized = true
            mainFrame.Visible = false
            if not iconGui or not iconGui.Parent then
                createIconGui()
            else
                iconGui.Enabled = true
            end
            notify("🔄 Minimizado", "Clique no ícone flutuante para restaurar.", 2)
            addLog("Interface minimizada", "info")
        end
        
        local function restoreUI()
            isMinimized = false
            mainFrame.Visible = true
            if iconGui then 
                iconGui.Enabled = false 
            end
            notifySuccess("🎉 Bem-vindo de volta!", "CAFUXZ1 Hub v16.3 PING+ ativo.", 2)
            addLog("Interface restaurada", "info")
        end
        
        minimizeBtn.MouseButton1Click:Connect(minimizeUI)
        closeBtn.MouseButton1Click:Connect(minimizeUI)
        
        -- DRAG DO MAIN FRAME
        local dragging = false
        local dragStart, startPos
        
        header.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or 
               input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = mainFrame.Position
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                            input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, 
                                               startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or 
               input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        
        -- ÍCONE FLUTUANTE
        function createIconGui()
            pcall(function()
                local existing = CoreGui:FindFirstChild("CAFUXZ1_Icon_v16")
                if existing then
                    existing:Destroy()
                end
                
                iconGui = Instance.new("ScreenGui")
                iconGui.Name = "CAFUXZ1_Icon_v16"
                iconGui.ResetOnSpawn = false
                iconGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                iconGui.Parent = CoreGui
                
                local iconContainer = Instance.new("Frame")
                iconContainer.Name = "IconContainer"
                iconContainer.Size = UDim2.new(0, 80, 0, 80)
                iconContainer.Position = UDim2.new(0, 25, 0.5, -40)
                iconContainer.BackgroundTransparency = 1
                iconContainer.Parent = iconGui
                
                local iconGlow = Instance.new("Frame")
                iconGlow.Size = UDim2.new(1.3, 0, 1.3, 0)
                iconGlow.Position = UDim2.new(-0.15, 0, -0.15, 0)
                iconGlow.BackgroundColor3 = CONFIG.customColors.primary
                iconGlow.BackgroundTransparency = 0.9
                iconGlow.BorderSizePixel = 0
                iconGlow.Parent = iconContainer
                
                local glowCorner = Instance.new("UICorner")
                glowCorner.CornerRadius = UDim.new(1, 0)
                glowCorner.Parent = iconGlow
                
                local iconBtn = Instance.new("TextButton")
                iconBtn.Name = "IconButton"
                iconBtn.Size = UDim2.new(0, 70, 0, 70)
                iconBtn.Position = UDim2.new(0.5, -35, 0.5, -35)
                iconBtn.BackgroundColor3 = CONFIG.customColors.primary
                iconBtn.Text = "⚡"
                iconBtn.TextColor3 = Color3.new(1, 1, 1)
                iconBtn.TextSize = 36
                iconBtn.Font = Enum.Font.GothamBold
                iconBtn.Parent = iconContainer
                
                local iconCorner = Instance.new("UICorner")
                iconCorner.CornerRadius = UDim.new(1, 0)
                iconCorner.Parent = iconBtn
                
                task.spawn(function()
                    while iconContainer and iconContainer.Parent do
                        tween(iconGlow, {Size = UDim2.new(1.5, 0, 1.5, 0), BackgroundTransparency = 0.95}, 1.5)
                        task.wait(1.5)
                        if not iconContainer or not iconContainer.Parent then break end
                        tween(iconGlow, {Size = UDim2.new(1.3, 0, 1.3, 0), BackgroundTransparency = 0.9}, 1.5)
                        task.wait(1.5)
                    end
                end)
                
                local dragLabel = Instance.new("TextLabel")
                dragLabel.Size = UDim2.new(1, 0, 0, 20)
                dragLabel.Position = UDim2.new(0, 0, 1, -5)
                dragLabel.BackgroundTransparency = 1
                dragLabel.Text = "ARRASTE"
                dragLabel.TextColor3 = CONFIG.customColors.textMuted
                dragLabel.TextSize = 10
                dragLabel.Font = Enum.Font.GothamBold
                dragLabel.Parent = iconContainer
                
                iconBtn.MouseButton1Click:Connect(restoreUI)
                
                local iconDragging = false
                local iconDragStart, iconStartPos
                
                iconBtn.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
                       input.UserInputType == Enum.UserInputType.Touch then
                        iconDragging = true
                        iconDragStart = input.Position
                        iconStartPos = iconContainer.Position
                        
                        pcall(function()
                            tween(iconBtn, {Size = UDim2.new(0, 75, 0, 75), 
                                          Position = UDim2.new(0.5, -37.5, 0.5, -37.5)}, 0.1)
                        end)
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if iconDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                                        input.UserInputType == Enum.UserInputType.Touch) then
                        local delta = input.Position - iconDragStart
                        iconContainer.Position = UDim2.new(iconStartPos.X.Scale, iconStartPos.X.Offset + delta.X, 
                                                           iconStartPos.Y.Scale, iconStartPos.Y.Offset + delta.Y)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
                       input.UserInputType == Enum.UserInputType.Touch then
                        iconDragging = false
                        
                        pcall(function()
                            tween(iconBtn, {Size = UDim2.new(0, 70, 0, 70), 
                                          Position = UDim2.new(0.5, -35, 0.5, -35)}, 0.1)
                        end)
                    end
                end)
            end)
        end
        
        notifySuccess("🎉 CAFUXZ1 Hub v16.3 PING+", "Sistema de ping adaptativo ativo!", 4)
        addLog("CAFUXZ1 Hub v16.3 PING+ iniciado!", "success")
    end)
    
    if not success then
        notifyError("❌ Erro Crítico", "Falha ao criar interface!", 5)
    end
end

-- ============================================
-- LOOP PRINCIPAL (OTIMIZADO COM PING)
-- ============================================
local function mainLoop()
    if loopRunning then 
        return 
    end
    loopRunning = true
    
    -- Inicializa sistema de ping
    PingSystem:Init()
    
    heartbeatConnection = RunService.Heartbeat:Connect(function()
        if isClosed then 
            return 
        end
        
        -- Atualiza ping a cada frame
        PingSystem:Update()
        
        pcall(updateCharacter)
        pcall(updateBothSpheres)
        pcall(findBalls)
        
        if HRP and HRP.Parent then
            pcall(processAutoTouch)
            pcall(processAutoSkills)
        else
            pcall(destroyBothSpheres)
        end
    end)
    
    addLog("Sistema Reach iniciado com Ping Optimization", "success")
    notifySuccess("⚡ Sistema Reach PING+", "Auto-touch adaptativo ativo!", 3)
end

-- ============================================
-- ATALHOS
-- ============================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then 
        return 
    end
    
    if input.KeyCode == Enum.KeyCode.F1 then
        CONFIG.autoTouch = not CONFIG.autoTouch
        notify(CONFIG.autoTouch and "✅ Auto Touch ON" or "⚠️ Auto Touch OFF", 
               CONFIG.autoTouch and "Sistema de toque automático ativado!" or "Toque automático desativado.", 2)
        addLog("F1: Auto Touch " .. (CONFIG.autoTouch and "ON" or "OFF"), "info")
        
    elseif input.KeyCode == Enum.KeyCode.F2 then
        setSpheresVisible(not CONFIG.showReachSphere)
        notify(CONFIG.showReachSphere and "👁️ Esferas Visíveis" or "👁️‍🗨️ Esferas Ocultas", 
               CONFIG.showReachSphere and "Visualização de alcance ativada!" or "Esferas de alcance ocultas.", 2)
        
    elseif input.KeyCode == Enum.KeyCode.F3 then
        CONFIG.autoSecondTouch = not CONFIG.autoSecondTouch
        pcall(updateArthurSphere)
        notify(CONFIG.autoSecondTouch and "✅ Double Touch ON" or "⚠️ Double Touch OFF", 
               CONFIG.autoSecondTouch and "Sistema Arthur ativado!" or "Double touch desativado.", 2)
        
    elseif input.KeyCode == Enum.KeyCode.F4 then
        CONFIG.antiLag.enabled = not CONFIG.antiLag.enabled
        if CONFIG.antiLag.enabled then 
            applyAntiLag() 
        else 
            disableAntiLag() 
        end
        notify(CONFIG.antiLag.enabled and "🚀 Anti-Lag ON" or "⚠️ Anti-Lag OFF", 
               CONFIG.antiLag.enabled and "Otimização de performance ativada!" or "Anti-lag desativado.", 2)
        
    elseif input.KeyCode == Enum.KeyCode.F5 then -- NOVO: Toggle ping optimization
        CONFIG.pingOptimization.enabled = not CONFIG.pingOptimization.enabled
        notifyPing(CONFIG.pingOptimization.enabled and "📶 Ping Optimization ON" or "📶 Ping Optimization OFF",
            CONFIG.pingOptimization.enabled and "Sistema adaptativo de ping ativado!" or "Otimização de ping desativada.", 3)
        addLog("F5: Ping Optimization " .. (CONFIG.pingOptimization.enabled and "ON" or "OFF"), "info")
        
    elseif input.KeyCode == CONFIG.tote.keybind then
        if CONFIG.tote.enabled then
            executeTote()
        else
            notifyTote("🎯 Tote", "Ative o Tote na aba 🎯 primeiro!", 2)
        end
        
    elseif input.KeyCode == Enum.KeyCode.Insert then
        pcall(function()
            if mainGui and mainGui.Parent then
                if mainGui.Enabled then
                    local header = mainFrame:FindFirstChild("Header")
                    if header then
                        local minimizeBtn = header:FindFirstChild("MinimizeBtn")
                        if minimizeBtn then
                            minimizeBtn.MouseButton1Click:Fire()
                        end
                    end
                else
                    mainGui.Enabled = true
                end
            else
                createWindUI()
            end
        end)
    end
end)

-- ============================================
-- EVENTOS DO JOGADOR
-- ============================================
LocalPlayer.CharacterAdded:Connect(function(newChar)
    addLog("Character respawnado", "info")
    
    Character = newChar
    HRP = nil
    
    pcall(destroyBothSpheres)
    
    task.spawn(function()
        local newHRP = newChar:WaitForChild("HumanoidRootPart", 5)
        if newHRP then
            HRP = newHRP
            addLog("HRP reconectado", "success")
        end
    end)
    
    task.delay(1, function()
        if CONFIG.antiLag.enabled then
            applyAntiLag()
        end
    end)
end)

-- ============================================
-- INICIALIZAÇÃO
-- ============================================
task.spawn(function()
    task.wait(0.5)
    pcall(createIntro)
    
    task.delay(0.5, function()
        pcall(createWindUI)
        task.wait(0.2)
        pcall(mainLoop)
    end)
end)

print("========================================")
print("CAFUXZ1 Hub v16.3 PING+ - REVOLUTION")
print("========================================")
print("SISTEMAS ATIVOS:")
print("   ⚽ Reach System (Double Sphere + Ping+)")
print("   🎯 Tote System v3.0 (Curva Realista)")
print("   👤 Morph System")
print("   ☁️  Skybox System")
print("   🚀 Anti Lag")
print("   🔔 Notificações Avançadas v2.0")
print("   📶 Ping Optimization System")
print("========================================")
print("🎮 Atalhos:")
print("   F1 = Auto Touch")
print("   F2 = Toggle Esferas")
print("   F3 = Double Touch")
print("   F4 = Anti Lag")
print("   F5 = Ping Optimization") -- NOVO
print("   T  = Executar Tote")
print("   Insert = Minimizar/Restaurar")
print("========================================")

       
