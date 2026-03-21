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
-- CONFIGURAÇÕES v16.3
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
    toteGoals = 0
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
-- INTRO ANIMADA
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
        versionBadge.Size = UDim2.new(0, 160, 0, 30)
        versionBadge.Position = UDim2.new(0.5, -80, 0, 225)
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
        version.Text = "v16.3 REVOLUTION"
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
        updatesText.Text = "NOVIDADES v16.3:\n\n" ..
                           "• NOTIFICAÇÕES AVANÇADAS v2.0\n" ..
                           "• Sistema de notificações moderno\n" ..
                           "• Tipos: Success, Error, Tote, Morph\n" ..
                           "• Animações suaves e glassmorphism\n" ..
                           "• Barra de progresso visual"
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
    notifyInfo("ℹ️ Skybox", "Céu original restaurado", 2)
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
-- REACH SYSTEM
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
    if now - lastBallUpdate < CONFIG.scanCooldown then 
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
-- ESFERAS
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
            reachSphere.Size = Vector3.new(CONFIG.reach * 2, CONFIG.reach * 2, CONFIG.reach * 2)
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
            arthurSphere.Size = Vector3.new(CONFIG.arthurSphere.reach * 2, CONFIG.arthurSphere.reach * 2, CONFIG.arthurSphere.reach * 2)
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
-- TOUCH SYSTEM
-- ============================================
local function doTouch(ball, part)
    if not ball or not ball.Parent or not part or not part.Parent then 
        return 
    end
    
    local key = tostring(ball.Name) .. "_" .. tostring(part.Name) .. "_" .. tostring(ball:GetFullName())
    if touchDebounce[key] and tick() - touchDebounce[key] < 0.05 then 
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
    if now - lastTouch < 0.03 then 
        return 
    end
    
    local hrpPos = HRP.Position
    local characterParts = getBodyParts()
    if #characterParts == 0 then 
        return 
    end
    
    local ballInRange = false
    local closestBall = nil
    local closestDistance = CONFIG.reach
    
    for _, ball in ipairs(balls) do
        if ball and ball.Parent then
            local success, distance = pcall(function()
                return (ball.Position - hrpPos).Magnitude
            end)
            
            if success and distance and distance <= CONFIG.reach and distance < closestDistance then
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
            if success and dist and dist <= CONFIG.reach then
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
            local closestDist = CONFIG.reach
            
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
-- INTERFACE WINDUI v16.3
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
        headerSubtitle.Text = "Revolution v16.3"
        headerSubtitle.TextColor3 = CONFIG.customColors.textMuted
        headerSubtitle.TextSize = 11
        headerSubtitle.Font = Enum.Font.Gotham
        headerSubtitle.TextXAlignment = Enum.TextXAlignment.Left
        headerSubtitle.Parent = header
        
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
        
    
