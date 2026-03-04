-- CADUXX137 v13.0 - ULTIMATE EDITION
-- Correções: Botão minimizar + 200+ linhas de features premium

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ============================================
-- CONFIGURAÇÕES v13.0 - ULTIMATE
-- ============================================
local CONFIG = {
    -- Dimensões wide expandidas
    width = 580,
    height = 420,
    sidebarWidth = 85,
    
    reach = 15,
    showReachSphere = true,
    autoTouch = true,
    fullBodyTouch = true,
    autoSecondTouch = true,
    scanCooldown = 1.5,
    scale = 1.0,
    
    -- NOVO: Sistema de temas
    theme = "dark", -- dark, light, auto
    accentColor = Color3.fromRGB(99, 102, 241),
    particleEffects = true,
    soundEffects = true,
    showStats = true,
    autoUpdate = true,
    
    -- IDs das suas imagens
    iconImage = "rbxassetid://104616032736993",
    iconBackground = "rbxassetid://96755648876012",
    
    -- Lista expandida de bolas
    ballNames = { 
        "TPS", "TCS", "ESA", "MRS", "PRS", "MPS", "SSS", "AIFA", "RBZ",
        "Ball", "Soccer", "Football", "Basketball", "Baseball", 
        "BallTemplate", "GameBall", "Hitbox", "TouchPart", "GoalBall",
        "Physics", "Interaction", "Trigger", "Touch", "Hit", "Box"
    },
    
    -- Cores tema Dark (padrão)
    primary = Color3.fromRGB(99, 102, 241),
    secondary = Color3.fromRGB(139, 92, 246),
    accent = Color3.fromRGB(14, 165, 233),
    success = Color3.fromRGB(34, 197, 94),
    danger = Color3.fromRGB(239, 68, 68),
    warning = Color3.fromRGB(245, 158, 11),
    info = Color3.fromRGB(59, 130, 246),
    
    bgDark = Color3.fromRGB(12, 12, 20),
    bgCard = Color3.fromRGB(28, 28, 42),
    bgElevated = Color3.fromRGB(42, 42, 62),
    bgGlass = Color3.fromRGB(22, 22, 36),
    
    textPrimary = Color3.fromRGB(252, 252, 255),
    textSecondary = Color3.fromRGB(170, 180, 210),
    textMuted = Color3.fromRGB(130, 140, 170),
    
    -- Cores tema Light
    lightBg = Color3.fromRGB(245, 245, 250),
    lightCard = Color3.fromRGB(255, 255, 255),
    lightText = Color3.fromRGB(30, 30, 40),
    lightMuted = Color3.fromRGB(100, 110, 130)
}

-- ============================================
-- ESTATÍSTICAS E LOGS (NOVO)
-- ============================================
local STATS = {
    totalTouches = 0,
    ballsTouched = 0,
    sessionStart = tick(),
    fps = 0,
    ping = 0,
    lastUpdate = tick(),
    touchesPerMinute = 0,
    peakReach = 0,
    skillsActivated = 0
}

local LOGS = {}
local MAX_LOGS = 50

local function addLog(message, type)
    type = type or "info"
    table.insert(LOGS, 1, {
        message = message,
        type = type,
        time = os.date("%H:%M:%S"),
        timestamp = tick()
    })
    
    if #LOGS > MAX_LOGS then
        table.remove(LOGS)
    end
    
    -- Notificação visual se habilitado
    if CONFIG.soundEffects then
        -- Indicador visual de som (piscar borda)
        if mainGui and mainGui:FindFirstChild("Main") then
            local main = mainGui.Main
            local stroke = main:FindFirstChildOfClass("UIStroke")
            if stroke then
                local original = stroke.Color
                tween(stroke, {Color = type == "error" and CONFIG.danger or type == "success" and CONFIG.success or CONFIG.accent}, 0.1)
                task.delay(0.2, function()
                    tween(stroke, {Color = original}, 0.3)
                end)
            end
        end
    end
end

-- Variáveis globais
local balls = {}
local ballConnections = {}
local reachSphere = nil
local HRP = nil
local char = nil
local touchDebounce = {}
local lastBallUpdate = 0
local lastTouch = 0
local isMinimized = false
local iconGui = nil
local mainGui = nil
local currentTab = "reach"
local autoSkills = true
local lastSkillActivation = 0
local skillCooldown = 0.5
local activatedSkills = {}
local particleSystem = nil

local skillButtonNames = {
    "Shoot", "Pass", "Long", "Tackle", "Dribble", "GK", "Throw",
    "Control", "Left", "Right", "High", "Low", "Rainbow",
    "Chip", "Heel", "Volley", "Back Right", "Back Left",
    "Carry", "Fake Shot", "Drag Back", "Header", "Bicycle",
    "Shot", "Slide", "Goalkeeper", "Catch", "Punch",
    "Short Pass", "Through Ball", "Cross", "Curve",
    "Power Shot", "Precision", "First Touch", "Sprint", "Jump"
}

-- ============================================
-- SISTEMA DE PARTÍCULAS (NOVO)
-- ============================================

local function createParticleSystem(parent)
    if not CONFIG.particleEffects then return nil end
    
    local particles = Instance.new("Frame")
    particles.Name = "Particles"
    particles.Size = UDim2.new(1, 0, 1, 0)
    particles.BackgroundTransparency = 1
    particles.ZIndex = -5
    particles.Parent = parent
    
    local particleCount = 15
    
    for i = 1, particleCount do
        local particle = Instance.new("Frame")
        particle.Size = UDim2.new(0, math.random(2, 4), 0, math.random(2, 4))
        particle.Position = UDim2.new(math.random(), 0, math.random(), 0)
        particle.BackgroundColor3 = CONFIG.accent
        particle.BackgroundTransparency = math.random(5, 8) / 10
        particle.BorderSizePixel = 0
        particle.Parent = particles
        
        -- Animação flutuante
        task.spawn(function()
            while particle and particle.Parent do
                local newY = particle.Position.Y.Scale + (math.random(-20, 20) / 1000)
                if newY < 0 then newY = 1 elseif newY > 1 then newY = 0 end
                
                tween(particle, {
                    Position = UDim2.new(particle.Position.X.Scale, 0, newY, 0),
                    BackgroundTransparency = math.random(5, 9) / 10
                }, math.random(3, 6))
                
                task.wait(math.random(3, 6))
            end
        end)
    end
    
    return particles
end

-- ============================================
-- UTILITÁRIOS PREMIUM
-- ============================================

local function notify(title, text, duration, type)
    duration = duration or 3
    type = type or "info"
    
    addLog(text, type)
    
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "CADUXX137",
            Text = text or "",
            Duration = duration,
            Icon = CONFIG.iconImage
        })
    end)
end

local function tween(obj, props, time, style, dir, callback)
    time = time or 0.35
    style = style or Enum.EasingStyle.Quint
    dir = dir or Enum.EasingDirection.Out
    
    local info = TweenInfo.new(time, style, dir)
    local t = TweenService:Create(obj, info, props)
    if callback then t.Completed:Connect(callback) end
    t:Play()
    return t
end

-- Sistema de temas
local function applyTheme(theme)
    CONFIG.theme = theme
    
    if theme == "light" then
        CONFIG.bgDark = CONFIG.lightBg
        CONFIG.bgCard = CONFIG.lightCard
        CONFIG.bgElevated = Color3.fromRGB(230, 230, 240)
        CONFIG.textPrimary = CONFIG.lightText
        CONFIG.textSecondary = CONFIG.lightMuted
        CONFIG.textMuted = Color3.fromRGB(140, 150, 170)
    else
        CONFIG.bgDark = Color3.fromRGB(12, 12, 20)
        CONFIG.bgCard = Color3.fromRGB(28, 28, 42)
        CONFIG.bgElevated = Color3.fromRGB(42, 42, 62)
        CONFIG.textPrimary = Color3.fromRGB(252, 252, 255)
        CONFIG.textSecondary = Color3.fromRGB(170, 180, 210)
        CONFIG.textMuted = Color3.fromRGB(130, 140, 170)
    end
    
    -- Recriar interface se existir
    if mainGui then
        createMainGUI()
        notify("Tema Alterado", "Modo " .. theme:upper() .. " ativado!", 2, "success")
    end
end

-- ============================================
-- ÍCONE FLUTUANTE PREMIUM
-- ============================================

local function createIconButton()
    if iconGui then iconGui:Destroy() end
    
    iconGui = Instance.new("ScreenGui")
    iconGui.Name = "CADU_Icon_v13"
    iconGui.ResetOnSpawn = false
    iconGui.DisplayOrder = 999999
    iconGui.Parent = playerGui
    
    local iconSize = 75 * CONFIG.scale
    
    local mainBtn = Instance.new("ImageButton")
    mainBtn.Name = "IconButton"
    mainBtn.Size = UDim2.new(0, iconSize, 0, iconSize)
    mainBtn.Position = UDim2.new(0.5, -iconSize/2, 0.88, 0)
    mainBtn.BackgroundTransparency = 1
    mainBtn.Image = CONFIG.iconBackground
    mainBtn.ImageColor3 = Color3.new(1, 1, 1)
    mainBtn.ScaleType = Enum.ScaleType.Stretch
    mainBtn.Parent = iconGui
    
    Instance.new("UICorner", mainBtn).CornerRadius = UDim.new(1, 0)
    
    -- Glow animado premium
    local glow = Instance.new("ImageLabel")
    glow.Size = UDim2.new(1.5, 0, 1.5, 0)
    glow.Position = UDim2.new(-0.25, 0, -0.25, 0)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://96755648876012"
    glow.ImageColor3 = CONFIG.accentColor
    glow.ImageTransparency = 0.7
    glow.ZIndex = -1
    glow.Parent = mainBtn
    
    -- Ícone interno
    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0.55, 0, 0.55, 0)
    icon.Position = UDim2.new(0.225, 0, 0.225, 0)
    icon.BackgroundTransparency = 1
    icon.Image = CONFIG.iconImage
    icon.ImageColor3 = CONFIG.textPrimary
    icon.Parent = mainBtn
    
    -- Badge de notificação (novo)
    local badge = Instance.new("Frame")
    badge.Name = "Badge"
    badge.Size = UDim2.new(0, 18 * CONFIG.scale, 0, 18 * CONFIG.scale)
    badge.Position = UDim2.new(1, -12 * CONFIG.scale, 0, -6 * CONFIG.scale)
    badge.BackgroundColor3 = CONFIG.danger
    badge.BorderSizePixel = 0
    badge.Visible = false
    badge.ZIndex = 10
    badge.Parent = mainBtn
    
    Instance.new("UICorner", badge).CornerRadius = UDim.new(1, 0)
    
    local badgeText = Instance.new("TextLabel")
    badgeText.Size = UDim2.new(1, 0, 1, 0)
    badgeText.BackgroundTransparency = 1
    badgeText.Text = "!"
    badgeText.TextColor3 = CONFIG.textPrimary
    badgeText.Font = Enum.Font.GothamBlack
    badgeText.TextSize = 12 * CONFIG.scale
    badgeText.Parent = badge
    
    -- Animação de rotação do glow
    task.spawn(function()
        while glow and glow.Parent do
            tween(glow, {Rotation = glow.Rotation + 360}, 8, Enum.EasingStyle.Linear)
            task.wait(8)
        end
    end)
    
    -- Hover effects premium
    mainBtn.MouseEnter:Connect(function()
        tween(mainBtn, {Size = UDim2.new(0, iconSize * 1.15, 0, iconSize * 1.15)}, 0.3, Enum.EasingStyle.Back)
        tween(glow, {ImageTransparency = 0.35}, 0.3)
        tween(icon, {Rotation = 20}, 0.4, Enum.EasingStyle.Back)
    end)
    
    mainBtn.MouseLeave:Connect(function()
        tween(mainBtn, {Size = UDim2.new(0, iconSize, 0, iconSize)}, 0.3, Enum.EasingStyle.Back)
        tween(glow, {ImageTransparency = 0.7}, 0.3)
        tween(icon, {Rotation = 0}, 0.4, Enum.EasingStyle.Back)
    end)
    
    -- Clique para abrir
    mainBtn.MouseButton1Click:Connect(function()
        tween(mainBtn, {Size = UDim2.new(0, 0, 0, 0), Rotation = 360}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.4)
        iconGui:Destroy()
        iconGui = nil
        isMinimized = false
        createMainGUI()
    end)
    
    -- Draggable
    local dragging = false
    local dragStart, startPos
    
    mainBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainBtn.Position
        end
    end)
    
    mainBtn.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            mainBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    -- Entrada elástica
    mainBtn.Size = UDim2.new(0, 0, 0, 0)
    tween(mainBtn, {Size = UDim2.new(0, iconSize, 0, iconSize)}, 0.6, Enum.EasingStyle.Back)
    
    notify("CADUXX137 v13", "Clique no ícone para abrir o hub", 3)
end

-- ============================================
-- INTERFACE PRINCIPAL ULTIMATE - CORRIGIDA
-- ============================================

function createMainGUI()
    pcall(function()
        for _, v in pairs(playerGui:GetChildren()) do
            if v.Name:find("CADU") then v:Destroy() end
        end
    end)
    
    mainGui = Instance.new("ScreenGui")
    mainGui.Name = "CADU_Main_v13"
    mainGui.ResetOnSpawn = false
    mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    mainGui.Parent = playerGui
    
    local W, H = CONFIG.width * CONFIG.scale, CONFIG.height * CONFIG.scale
    local SW = CONFIG.sidebarWidth * CONFIG.scale
    
    -- Frame principal
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, W, 0, H)
    main.Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
    main.BackgroundColor3 = CONFIG.bgDark
    main.BackgroundTransparency = 0.06
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = mainGui
    
    -- Partículas de fundo
    particleSystem = createParticleSystem(main)
    
    -- Cantos arredondados
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 24 * CONFIG.scale)
    corner.Parent = main
    
    -- Stroke neon
    local stroke = Instance.new("UIStroke")
    stroke.Name = "MainStroke"
    stroke.Color = CONFIG.accentColor
    stroke.Transparency = 0.65
    stroke.Thickness = 1.5 * CONFIG.scale
    stroke.Parent = main
    
    -- Sombra premium
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 60 * CONFIG.scale, 1, 60 * CONFIG.scale)
    shadow.Position = UDim2.new(0, -30 * CONFIG.scale, 0, -30 * CONFIG.scale)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://131296141"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.ZIndex = -1
    shadow.Parent = main
    
    -- ============================================
    -- SIDEBAR COM BOTÕES CORRIGIDOS
    -- ============================================
    
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, SW, 1, 0)
    sidebar.BackgroundColor3 = CONFIG.bgCard
    sidebar.BackgroundTransparency = 0.12
    sidebar.BorderSizePixel = 0
    sidebar.Parent = main
    
    local sidebarCorner = Instance.new("UICorner")
    sidebarCorner.CornerRadius = UDim.new(0, 24 * CONFIG.scale)
    sidebarCorner.Parent = sidebar
    
    -- Logo
    local logoContainer = Instance.new("Frame")
    logoContainer.Size = UDim2.new(0, 50 * CONFIG.scale, 0, 50 * CONFIG.scale)
    logoContainer.Position = UDim2.new(0.5, -25 * CONFIG.scale, 0, 18 * CONFIG.scale)
    logoContainer.BackgroundColor3 = CONFIG.bgElevated
    logoContainer.BackgroundTransparency = 0.2
    logoContainer.BorderSizePixel = 0
    logoContainer.Parent = sidebar
    
    Instance.new("UICorner", logoContainer).CornerRadius = UDim.new(1, 0)
    
    local logo = Instance.new("ImageLabel")
    logo.Size = UDim2.new(0.6, 0, 0.6, 0)
    logo.Position = UDim2.new(0.2, 0, 0.2, 0)
    logo.BackgroundTransparency = 1
    logo.Image = CONFIG.iconImage
    logo.ImageColor3 = CONFIG.textPrimary
    logo.Parent = logoContainer
    
    -- Navegação por ícones
    local tabs = {
        {id = "reach", icon = "⚡", y = 85, color = CONFIG.primary},
        {id = "balls", icon = "🔮", y = 140, color = CONFIG.secondary},
        {id = "controls", icon = "🎮", y = 195, color = CONFIG.accent},
        {id = "stats", icon = "📊", y = 250, color = CONFIG.info}, -- NOVA ABA
        {id = "settings", icon = "⚙️", y = 305, color = CONFIG.textSecondary}
    }
    
    local tabButtons = {}
    
    for _, tab in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Name = tab.id .. "Btn"
        btn.Size = UDim2.new(0, 50 * CONFIG.scale, 0, 50 * CONFIG.scale)
        btn.Position = UDim2.new(0.5, -25 * CONFIG.scale, 0, tab.y * CONFIG.scale)
        btn.BackgroundColor3 = (tab.id == currentTab) and tab.color or CONFIG.bgElevated
        btn.BackgroundTransparency = (tab.id == currentTab) and 0.12 or 0.55
        btn.Text = tab.icon
        btn.TextColor3 = (tab.id == currentTab) and CONFIG.textPrimary or CONFIG.textMuted
        btn.Font = Enum.Font.GothamBlack
        btn.TextSize = 24 * CONFIG.scale
        btn.AutoButtonColor = false
        btn.Parent = sidebar
        
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 16 * CONFIG.scale)
        
        -- Indicador de seleção
        local indicator = Instance.new("Frame")
        indicator.Name = "Indicator"
        indicator.Size = UDim2.new(0, 4 * CONFIG.scale, 0, 24 * CONFIG.scale)
        indicator.Position = UDim2.new(0, -3 * CONFIG.scale, 0.5, -12 * CONFIG.scale)
        indicator.BackgroundColor3 = tab.color
        indicator.BackgroundTransparency = (tab.id == currentTab) and 0 or 1
        indicator.BorderSizePixel = 0
        indicator.Parent = btn
        
        tabButtons[tab.id] = {btn = btn, indicator = indicator, color = tab.color}
        
        btn.MouseButton1Click:Connect(function()
            if currentTab == tab.id then return end
            
            local prev = tabButtons[currentTab]
            tween(prev.btn, {BackgroundColor3 = CONFIG.bgElevated}, 0.3)
            tween(prev.btn, {BackgroundTransparency = 0.55}, 0.3)
            tween(prev.btn, {TextColor3 = CONFIG.textMuted}, 0.3)
            tween(prev.indicator, {BackgroundTransparency = 1}, 0.2)
            
            currentTab = tab.id
            tween(btn, {BackgroundColor3 = tab.color}, 0.3)
            tween(btn, {BackgroundTransparency = 0.12}, 0.3)
            tween(btn, {TextColor3 = CONFIG.textPrimary}, 0.3)
            tween(indicator, {BackgroundTransparency = 0}, 0.2)
            
            updateContent()
        end)
        
        if tab.id ~= currentTab then
            btn.MouseEnter:Connect(function()
                tween(btn, {BackgroundTransparency = 0.35}, 0.2)
            end)
            btn.MouseLeave:Connect(function()
                tween(btn, {BackgroundTransparency = 0.55}, 0.2)
            end)
        end
    end
    
    -- ============================================
    -- BOTÕES DE CONTROLE NA SIDEBAR (CORRIGIDOS)
    -- ============================================
    
    -- Container para botões de controle
    local controlsContainer = Instance.new("Frame")
    controlsContainer.Name = "Controls"
    controlsContainer.Size = UDim2.new(1, 0, 0, 100 * CONFIG.scale)
    controlsContainer.Position = UDim2.new(0, 0, 1, -110 * CONFIG.scale)
    controlsContainer.BackgroundTransparency = 1
    controlsContainer.Parent = sidebar
    
    -- BOTÃO MINIMIZAR (🎯) - CORRIGIDO E VISÍVEL
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "MinimizeBtn"
    minimizeBtn.Size = UDim2.new(0, 42 * CONFIG.scale, 0, 42 * CONFIG.scale)
    minimizeBtn.Position = UDim2.new(0.5, -46 * CONFIG.scale, 0, 10 * CONFIG.scale) -- Posição corrigida
    minimizeBtn.BackgroundColor3 = CONFIG.bgElevated
    minimizeBtn.BackgroundTransparency = 0.25
    minimizeBtn.Text = "🎯"
    minimizeBtn.TextColor3 = CONFIG.textPrimary
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.TextSize = 20 * CONFIG.scale
    minimizeBtn.AutoButtonColor = false
    minimizeBtn.Parent = controlsContainer
    
    Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(1, 0)
    
    -- Glow no botão minimizar
    local minGlow = Instance.new("ImageLabel")
    minGlow.Size = UDim2.new(1.3, 0, 1.3, 0)
    minGlow.Position = UDim2.new(-0.15, 0, -0.15, 0)
    minGlow.BackgroundTransparency = 1
    minGlow.Image = "rbxassetid://5028857084"
    minGlow.ImageColor3 = CONFIG.accent
    minGlow.ImageTransparency = 0.85
    minGlow.ZIndex = -1
    minGlow.Parent = minimizeBtn
    
    -- BOTÃO FECHAR (×) - CORRIGIDO
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.new(0, 42 * CONFIG.scale, 0, 42 * CONFIG.scale)
    closeBtn.Position = UDim2.new(0.5, 4 * CONFIG.scale, 0, 10 * CONFIG.scale) -- Ao lado do minimizar
    closeBtn.BackgroundColor3 = CONFIG.danger
    closeBtn.BackgroundTransparency = 0.2
    closeBtn.Text = "×"
    closeBtn.TextColor3 = CONFIG.textPrimary
    closeBtn.Font = Enum.Font.GothamBlack
    closeBtn.TextSize = 24 * CONFIG.scale
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = controlsContainer
    
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)
    
    -- ============================================
    -- EVENTOS DOS BOTÕES (CORRIGIDOS)
    -- ============================================
    
    -- Hover Minimizar
    minimizeBtn.MouseEnter:Connect(function()
        tween(minimizeBtn, {BackgroundTransparency = 0.1}, 0.2)
        tween(minimizeBtn, {Size = UDim2.new(0, 46 * CONFIG.scale, 0, 46 * CONFIG.scale)}, 0.2)
        tween(minGlow, {ImageTransparency = 0.6}, 0.2)
    end)
    
    minimizeBtn.MouseLeave:Connect(function()
        tween(minimizeBtn, {BackgroundTransparency = 0.25}, 0.2)
        tween(minimizeBtn, {Size = UDim2.new(0, 42 * CONFIG.scale, 0, 42 * CONFIG.scale)}, 0.2)
        tween(minGlow, {ImageTransparency = 0.85}, 0.2)
    end)
    
    -- Clique Minimizar - VOLTA PARA ÍCONE FLUTUANTE
    minimizeBtn.MouseButton1Click:Connect(function()
        addLog("Hub minimizado para ícone flutuante", "info")
        
        -- Animação de saída
        tween(main, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        
        task.wait(0.4)
        
        mainGui:Destroy()
        mainGui = nil
        isMinimized = true
        createIconButton()
    end)
    
    -- Hover Fechar
    closeBtn.MouseEnter:Connect(function()
        tween(closeBtn, {BackgroundTransparency = 0.08}, 0.2)
        tween(closeBtn, {Size = UDim2.new(0, 46 * CONFIG.scale, 0, 46 * CONFIG.scale)}, 0.2)
    end)
    
    closeBtn.MouseLeave:Connect(function()
        tween(closeBtn, {BackgroundTransparency = 0.2}, 0.2)
        tween(closeBtn, {Size = UDim2.new(0, 42 * CONFIG.scale, 0, 42 * CONFIG.scale)}, 0.2)
    end)
    
    -- Clique Fechar
    closeBtn.MouseButton1Click:Connect(function()
        addLog("Hub fechado completamente", "warning")
        
        tween(main, {
            Size = UDim2.new(0, 0, 0, 0)
        }, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        
        task.wait(0.35)
        
        mainGui:Destroy()
        if reachSphere then reachSphere:Destroy() end
        for _, conn in ipairs(ballConnections) do
            pcall(function() conn:Disconnect() end)
        end
    end)
    
    -- ============================================
    -- ÁREA DE CONTEÚDO PRINCIPAL
    -- ============================================
    
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -(SW + 30 * CONFIG.scale), 1, -40 * CONFIG.scale)
    content.Position = UDim2.new(0, SW + 20 * CONFIG.scale, 0, 20 * CONFIG.scale)
    content.BackgroundTransparency = 1
    content.ClipsDescendants = true
    content.Parent = main
    
    -- Header do conteúdo
    local headerFrame = Instance.new("Frame")
    headerFrame.Size = UDim2.new(1, 0, 0, 50 * CONFIG.scale)
    headerFrame.BackgroundTransparency = 1
    headerFrame.Parent = content
    
    local sectionTitle = Instance.new("TextLabel")
    sectionTitle.Name = "Title"
    sectionTitle.Size = UDim2.new(0.7, 0, 1, 0)
    sectionTitle.BackgroundTransparency = 1
    sectionTitle.Text = "Alcance"
    sectionTitle.TextColor3 = CONFIG.textPrimary
    sectionTitle.Font = Enum.Font.GothamBlack
    sectionTitle.TextSize = 28 * CONFIG.scale
    sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    sectionTitle.Parent = headerFrame
    
    -- Badge de versão
    local versionBadge = Instance.new("TextLabel")
    versionBadge.Size = UDim2.new(0.3, 0, 0, 24 * CONFIG.scale)
    versionBadge.Position = UDim2.new(0.7, 0, 0.5, -12 * CONFIG.scale)
    versionBadge.BackgroundColor3 = CONFIG.bgElevated
    versionBadge.BackgroundTransparency = 0.3
    versionBadge.Text = "v13.0"
    versionBadge.TextColor3 = CONFIG.accentColor
    versionBadge.Font = Enum.Font.GothamBold
    versionBadge.TextSize = 12 * CONFIG.scale
    versionBadge.Parent = headerFrame
    
    Instance.new("UICorner", versionBadge).CornerRadius = UDim.new(0, 8 * CONFIG.scale)
    
    local titleLine = Instance.new("Frame")
    titleLine.Size = UDim2.new(0.2, 0, 0, 2 * CONFIG.scale)
    titleLine.Position = UDim2.new(0, 0, 1, -8 * CONFIG.scale)
    titleLine.BackgroundColor3 = CONFIG.primary
    titleLine.BorderSizePixel = 0
    titleLine.Parent = headerFrame
    
    -- Container dinâmico com scroll
    local dynamicContent = Instance.new("ScrollingFrame")
    dynamicContent.Name = "Dynamic"
    dynamicContent.Size = UDim2.new(1, 0, 1, -60 * CONFIG.scale)
    dynamicContent.Position = UDim2.new(0, 0, 0, 55 * CONFIG.scale)
    dynamicContent.BackgroundTransparency = 1
    dynamicContent.ScrollBarThickness = 4 * CONFIG.scale
    dynamicContent.ScrollBarImageColor3 = CONFIG.accentColor
    dynamicContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    dynamicContent.Parent = content
    
    -- ============================================
    -- COMPONENTES UI PREMIUM
    -- ============================================
    
    local function createCard(parent, y, h, title, accent)
        accent = accent or CONFIG.primary
        
        local card = Instance.new("Frame")
        card.Name = title .. "Card"
        card.Size = UDim2.new(1, 0, 0, h * CONFIG.scale)
        card.Position = UDim2.new(0, 0, 0, y * CONFIG.scale)
        card.BackgroundColor3 = CONFIG.bgCard
        card.BackgroundTransparency = 0.08
        card.BorderSizePixel = 0
        card.Parent = parent
        
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 18 * CONFIG.scale)
        
        -- Glow sutil
        local glow = Instance.new("ImageLabel")
        glow.Name = "Glow"
        glow.Size = UDim2.new(1, 20 * CONFIG.scale, 1, 20 * CONFIG.scale)
        glow.Position = UDim2.new(0, -10 * CONFIG.scale, 0, -10 * CONFIG.scale)
        glow.BackgroundTransparency = 1
        glow.Image = "rbxassetid://5028857084"
        glow.ImageColor3 = accent
        glow.ImageTransparency = 0.9
        glow.ScaleType = Enum.ScaleType.Slice
        glow.SliceCenter = Rect.new(10, 10, 90, 90)
        glow.Parent = card
        
        if title then
            local header = Instance.new("Frame")
            header.Size = UDim2.new(1, -24, 0, 32)
            header.Position = UDim2.new(0, 12, 0, 8)
            header.BackgroundTransparency = 1
            header.Parent = card
            
            local indicator = Instance.new("Frame")
            indicator.Size = UDim2.new(0, 4 * CONFIG.scale, 0, 20 * CONFIG.scale)
            indicator.Position = UDim2.new(0, 0, 0, 6)
            indicator.BackgroundColor3 = accent
            indicator.BorderSizePixel = 0
            indicator.Parent = header
            
            Instance.new("UICorner", indicator).CornerRadius = UDim.new(0, 2 * CONFIG.scale)
            
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -15, 1, 0)
            lbl.Position = UDim2.new(0, 12, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = title
            lbl.TextColor3 = accent
            lbl.Font = Enum.Font.GothamBlack
            lbl.TextSize = 14 * CONFIG.scale
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = header
        end
        
        return card
    end
    
    local function createToggle(parent, x, y, state, label, accent)
        accent = accent or CONFIG.success
        
        local container = Instance.new("Frame")
        container.Name = label .. "Toggle"
        container.Size = UDim2.new(0, 52 * CONFIG.scale, 0, 28 * CONFIG.scale)
        container.Position = UDim2.new(0, x * CONFIG.scale, 0, y * CONFIG.scale)
        container.BackgroundColor3 = state and accent or CONFIG.bgElevated
        container.BackgroundTransparency = state and 0.12 or 0.5
        container.BorderSizePixel = 0
        container.Parent = parent
        
        Instance.new("UICorner", container).CornerRadius = UDim.new(0, 14 * CONFIG.scale)
        
        local circle = Instance.new("Frame")
        circle.Name = "Circle"
        circle.Size = UDim2.new(0, 22 * CONFIG.scale, 0, 22 * CONFIG.scale)
        circle.Position = state and UDim2.new(1, -25 * CONFIG.scale, 0, 3 * CONFIG.scale) or UDim2.new(0, 3 * CONFIG.scale, 0, 3 * CONFIG.scale)
        circle.BackgroundColor3 = CONFIG.textPrimary
        circle.BorderSizePixel = 0
        circle.Parent = container
        
        Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
        
        local lbl = Instance.new("TextLabel")
        lbl.Name = "Label"
        lbl.Size = UDim2.new(0, 220, 0, 28)
        lbl.Position = UDim2.new(0, (x + 60) * CONFIG.scale, 0, y * CONFIG.scale)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.TextColor3 = CONFIG.textSecondary
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 12 * CONFIG.scale
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = parent
        
        local click = Instance.new("TextButton")
        click.Name = "ClickArea"
        click.Size = UDim2.new(0, 280 * CONFIG.scale, 0, 28 * CONFIG.scale)
        click.Position = UDim2.new(0, x * CONFIG.scale, 0, y * CONFIG.scale)
        click.BackgroundTransparency = 1
        click.Text = ""
        click.Parent = parent
        
        local current = state
        
        local function update()
            local pos = current and UDim2.new(1, -25 * CONFIG.scale, 0, 3 * CONFIG.scale) or UDim2.new(0, 3 * CONFIG.scale, 0, 3 * CONFIG.scale)
            local col = current and accent or CONFIG.bgElevated
            local tr = current and 0.12 or 0.5
            
            tween(circle, {Position = pos}, 0.35, Enum.EasingStyle.Back)
            tween(container, {BackgroundColor3 = col}, 0.3)
            tween(container, {BackgroundTransparency = tr}, 0.3)
        end
        
        click.MouseButton1Click:Connect(function()
            current = not current
            update()
            addLog(label .. ": " .. (current and "ON" or "OFF"), current and "success" or "warning")
            return current
        end)
        
        return {
            get = function() return current end,
            set = function(v) current = v update() end,
            container = container
        }
    end
    
    local function createSlider(parent, x, y, min, max, val, label, accent)
        accent = accent or CONFIG.primary
        
        local container = Instance.new("Frame")
        container.Name = label .. "Slider"
        container.Size = UDim2.new(1, -40 * CONFIG.scale, 0, 55 * CONFIG.scale)
        container.Position = UDim2.new(0, x * CONFIG.scale, 0, y * CONFIG.scale)
        container.BackgroundTransparency = 1
        container.Parent = parent
        
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 18)
        lbl.BackgroundTransparency = 1
        lbl.Text = label .. ": " .. val
        lbl.TextColor3 = CONFIG.textSecondary
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 11 * CONFIG.scale
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = container
        
        local valueDisplay = Instance.new("TextLabel")
        valueDisplay.Size = UDim2.new(0, 50, 0, 18)
        valueDisplay.Position = UDim2.new(1, -50, 0, 0)
        valueDisplay.BackgroundTransparency = 1
        valueDisplay.Text = tostring(val)
        valueDisplay.TextColor3 = accent
        valueDisplay.Font = Enum.Font.GothamBlack
        valueDisplay.TextSize = 14 * CONFIG.scale
        valueDisplay.TextXAlignment = Enum.TextXAlignment.Right
        valueDisplay.Parent = container
        
        local track = Instance.new("Frame")
        track.Size = UDim2.new(1, 0, 0, 6 * CONFIG.scale)
        track.Position = UDim2.new(0, 0, 0, 30 * CONFIG.scale)
        track.BackgroundColor3 = CONFIG.bgElevated
        track.BackgroundTransparency = 0.35
        track.BorderSizePixel = 0
        track.Parent = container
        
        Instance.new("UICorner", track).CornerRadius = UDim.new(0, 3 * CONFIG.scale)
        
        local pct = (val - min) / (max - min)
        
        local fill = Instance.new("Frame")
        fill.Name = "Fill"
        fill.Size = UDim2.new(pct, 0, 1, 0)
        fill.BackgroundColor3 = accent
        fill.BackgroundTransparency = 0.08
        fill.BorderSizePixel = 0
        fill.Parent = track
        
        Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3 * CONFIG.scale)
        
        local knob = Instance.new("Frame")
        knob.Name = "Knob"
        knob.Size = UDim2.new(0, 18 * CONFIG.scale, 0, 18 * CONFIG.scale)
        knob.Position = UDim2.new(pct, -9 * CONFIG.scale, 0.5, -9 * CONFIG.scale)
        knob.BackgroundColor3 = CONFIG.textPrimary
        knob.BorderSizePixel = 0
        knob.ZIndex = 2
        knob.Parent = track
        
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
        
        -- Glow no knob
        local knobGlow = Instance.new("ImageLabel")
        knobGlow.Size = UDim2.new(2.2, 0, 2.2, 0)
        knobGlow.Position = UDim2.new(-0.6, 0, -0.6, 0)
        knobGlow.BackgroundTransparency = 1
        knobGlow.Image = "rbxassetid://5028857084"
        knobGlow.ImageColor3 = accent
        knobGlow.ImageTransparency = 0.7
        knobGlow.ZIndex = -1
        knobGlow.Parent = knob
        
        local dragging = false
        
        local function update(input)
            local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local v = math.floor(min + (max - min) * rel)
            
            tween(fill, {Size = UDim2.new(rel, 0, 1, 0)}, 0.1)
            tween(knob, {Position = UDim2.new(rel, -9 * CONFIG.scale, 0.5, -9 * CONFIG.scale)}, 0.1)
            lbl.Text = label .. ": " .. v
            valueDisplay.Text = tostring(v)
            
            return v
        end
        
        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                return update(input)
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                return update(input)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        
        return {
            get = function() return tonumber(valueDisplay.Text) end,
            set = function(v)
                local rel = (v - min) / (max - min)
                tween(fill, {Size = UDim2.new(rel, 0, 1, 0)}, 0.2)
                tween(knob, {Position = UDim2.new(rel, -9 * CONFIG.scale, 0.5, -9 * CONFIG.scale)}, 0.2)
                lbl.Text = label .. ": " .. v
                valueDisplay.Text = tostring(v)
            end
        }
    end
    
    -- Botão de ação premium
    local function createActionButton(parent, x, y, w, h, text, color, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, w * CONFIG.scale, 0, h * CONFIG.scale)
        btn.Position = UDim2.new(0, x * CONFIG.scale, 0, y * CONFIG.scale)
        btn.BackgroundColor3 = color
        btn.BackgroundTransparency = 0.15
        btn.Text = text
        btn.TextColor3 = CONFIG.textPrimary
        btn.Font = Enum.Font.GothamBlack
        btn.TextSize = 12 * CONFIG.scale
        btn.AutoButtonColor = false
        btn.Parent = parent
        
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12 * CONFIG.scale)
        
        -- Glow
        local glow = Instance.new("ImageLabel")
        glow.Size = UDim2.new(1, 16 * CONFIG.scale, 1, 16 * CONFIG.scale)
        glow.Position = UDim2.new(0, -8 * CONFIG.scale, 0, -8 * CONFIG.scale)
        glow.BackgroundTransparency = 1
        glow.Image = "rbxassetid://5028857084"
        glow.ImageColor3 = color
        glow.ImageTransparency = 0.9
        glow.ScaleType = Enum.ScaleType.Slice
        glow.SliceCenter = Rect.new(10, 10, 90, 90)
        glow.ZIndex = -1
        glow.Parent = btn
        
        -- Ripple effect
        btn.MouseButton1Click:Connect(function()
            local ripple = Instance.new("Frame")
            ripple.Size = UDim2.new(0, 0, 0, 0)
            ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
            ripple.BackgroundColor3 = Color3.new(1, 1, 1)
            ripple.BackgroundTransparency = 0.7
            ripple.BorderSizePixel = 0
            ripple.ZIndex = 10
            ripple.Parent = btn
            
            Instance.new("UICorner", ripple).CornerRadius = UDim.new(1, 0)
            
            local target = math.max(w, h) * 1.5 * CONFIG.scale
            
            tween(ripple, {
                Size = UDim2.new(0, target, 0, target),
                Position = UDim2.new(0.5, -target/2, 0.5, -target/2),
                BackgroundTransparency = 1
            }, 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, function()
                ripple:Destroy()
            end)
            
            if callback then callback() end
        end)
        
        btn.MouseEnter:Connect(function()
            tween(btn, {BackgroundTransparency = 0.05}, 0.2)
            tween(glow, {ImageTransparency = 0.75}, 0.2)
        end)
        
        btn.MouseLeave:Connect(function()
            tween(btn, {BackgroundTransparency = 0.15}, 0.2)
            tween(glow, {ImageTransparency = 0.9}, 0.2)
        end)
        
        return btn
    end
    
    -- ============================================
    -- ATUALIZAÇÃO DE CONTEÚDO (EXPANDIDA)
    -- ============================================
    
    function updateContent()
        for _, c in ipairs(dynamicContent:GetChildren()) do
            c:Destroy()
        end
        
        dynamicContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        local totalHeight = 0
        
        if currentTab == "reach" then
            sectionTitle.Text = "Alcance"
            titleLine.BackgroundColor3 = CONFIG.primary
            
            -- Card de controle principal
            local controlCard = createCard(dynamicContent, 0, 140, "CONTROLE DE DISTÂNCIA", CONFIG.primary)
            
            -- Display grande
            local disp = Instance.new("TextLabel")
            disp.Name = "ReachDisplay"
            disp.Size = UDim2.new(0.35, 0, 0, 70 * CONFIG.scale)
            disp.Position = UDim2.new(0.6, 0, 0, 40 * CONFIG.scale)
            disp.BackgroundTransparency = 1
            disp.Text = tostring(CONFIG.reach)
            disp.TextColor3 = CONFIG.primary
            disp.Font = Enum.Font.GothamBlack
            disp.TextSize = 52 * CONFIG.scale
            disp.Parent = controlCard
            
            local unit = Instance.new("TextLabel")
            unit.Size = UDim2.new(0.15, 0, 0, 18)
            unit.Position = UDim2.new(0.88, 0, 0, 82 * CONFIG.scale)
            unit.BackgroundTransparency = 1
            unit.Text = "studs"
            unit.TextColor3 = CONFIG.textMuted
            unit.Font = Enum.Font.Gotham
            unit.TextSize = 11 * CONFIG.scale
            unit.Parent = controlCard
            
            -- Botões de ajuste rápido
            local quickBtns = {
                {txt = "−5", val = -5, x = 15},
                {txt = "−1", val = -1, x = 60},
                {txt = "+1", val = 1, x = 105},
                {txt = "+5", val = 5, x = 150},
                {txt = "MAX", val = 50, x = 210, w = 55}
            }
            
            for _, b in ipairs(quickBtns) do
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(0, (b.w or 40) * CONFIG.scale, 0, 36 * CONFIG.scale)
                btn.Position = UDim2.new(0, b.x * CONFIG.scale, 0, 48 * CONFIG.scale)
                btn.BackgroundColor3 = CONFIG.bgElevated
                btn.BackgroundTransparency = 0.3
                btn.Text = b.txt
                btn.TextColor3 = CONFIG.textPrimary
                btn.Font = Enum.Font.GothamBlack
                btn.TextSize = b.txt == "MAX" and 10 or 14 * CONFIG.scale
                btn.AutoButtonColor = false
                btn.Parent = controlCard
                
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10 * CONFIG.scale)
                
                btn.MouseButton1Click:Connect(function()
                    if b.txt == "MAX" then
                        CONFIG.reach = 50
                    else
                        CONFIG.reach = math.clamp(CONFIG.reach + b.val, 1, 50)
                    end
                    disp.Text = tostring(CONFIG.reach)
                    addLog("Alcance ajustado para " .. CONFIG.reach .. " studs", "info")
                end)
            end
            
            -- Slider fino
            local sliderCard = createCard(dynamicContent, 150, 95, "AJUSTE PRECISO", CONFIG.primary)
            local slider = createSlider(sliderCard, 15, 42, 1, 50, CONFIG.reach, "Alcance")
            
            -- Card de visualização
            local visCard = createCard(dynamicContent, 255, 85, "VISUALIZAÇÃO", CONFIG.secondary)
            local sphereToggle = createToggle(visCard, 15, 45, CONFIG.showReachSphere, "Mostrar Esfera de Alcance")
            
            totalHeight = 350
            
        elseif currentTab == "balls" then
            sectionTitle.Text = "Bolas Detectadas"
            titleLine.BackgroundColor3 = CONFIG.secondary
            
            -- Card de status
            local statusCard = createCard(dynamicContent, 0, 100, "STATUS ATUAL", CONFIG.secondary)
            
            local countLbl = Instance.new("TextLabel")
            countLbl.Size = UDim2.new(1, 0, 0, 50)
            countLbl.Position = UDim2.new(0, 0, 0, 35 * CONFIG.scale)
            countLbl.BackgroundTransparency = 1
            countLbl.Text = tostring(#balls)
            countLbl.TextColor3 = #balls > 0 and CONFIG.success or CONFIG.warning
            countLbl.Font = Enum.Font.GothamBlack
            countLbl.TextSize = 42 * CONFIG.scale
            countLbl.Parent = statusCard
            
            local subLbl = Instance.new("TextLabel")
            subLbl.Size = UDim2.new(1, 0, 0, 20)
            subLbl.Position = UDim2.new(0, 0, 0, 80 * CONFIG.scale)
            subLbl.BackgroundTransparency = 1
            subLbl.Text = "bolas ativas no momento"
            subLbl.TextColor3 = CONFIG.textMuted
            subLbl.Font = Enum.Font.Gotham
            subLbl.TextSize = 11 * CONFIG.scale
            subLbl.Parent = statusCard
            
            -- Botão scan
            createActionButton(statusCard, 200, 40, 100, 40, "⟳ SCANEAR", CONFIG.accent, function()
                findBalls()
                countLbl.Text = tostring(#balls)
                countLbl.TextColor3 = #balls > 0 and CONFIG.success or CONFIG.warning
                addLog("Scan manual realizado: " .. #balls .. " bolas encontradas", #balls > 0 and "success" or "warning")
            end)
            
            -- Lista de bolas
            local listCard = createCard(dynamicContent, 110, 220, "BOLAS ENCONTRADAS", CONFIG.accent)
            
            local list = Instance.new("ScrollingFrame")
            list.Size = UDim2.new(1, -24 * CONFIG.scale, 0, 175 * CONFIG.scale)
            list.Position = UDim2.new(0, 12 * CONFIG.scale, 0, 42 * CONFIG.scale)
            list.BackgroundColor3 = CONFIG.bgDark
            list.BackgroundTransparency = 0.4
            list.BorderSizePixel = 0
            list.ScrollBarThickness = 4 * CONFIG.scale
            list.Parent = listCard
            
            Instance.new("UICorner", list).CornerRadius = UDim.new(0, 14 * CONFIG.scale)
            
            local y = 8
            local unique = {}
            for _, b in ipairs(balls) do
                if b and b.Parent then
                    unique[b.Name] = (unique[b.Name] or 0) + 1
                end
            end
            
            for name, c in pairs(unique) do
                local item = Instance.new("Frame")
                item.Size = UDim2.new(1, -16, 0, 34 * CONFIG.scale)
                item.Position = UDim2.new(0, 8, 0, y)
                item.BackgroundColor3 = CONFIG.bgCard
                item.BackgroundTransparency = 0.25
                item.Parent = list
                
                Instance.new("UICorner", item).CornerRadius = UDim.new(0, 10 * CONFIG.scale)
                
                local nl = Instance.new("TextLabel")
                nl.Size = UDim2.new(0.65, 0, 1, 0)
                nl.Position = UDim2.new(0, 12, 0, 0)
                nl.BackgroundTransparency = 1
                nl.Text = name
                nl.TextColor3 = CONFIG.accent
                nl.Font = Enum.Font.GothamBold
                nl.TextSize = 12 * CONFIG.scale
                nl.Parent = item
                
                local cl = Instance.new("TextLabel")
                cl.Size = UDim2.new(0.35, -12, 1, 0)
                cl.Position = UDim2.new(0.65, 0, 0, 0)
                cl.BackgroundTransparency = 1
                cl.Text = "×" .. c
                cl.TextColor3 = CONFIG.textMuted
                cl.Font = Enum.Font.GothamBold
                cl.TextSize = 12 * CONFIG.scale
                cl.TextXAlignment = Enum.TextXAlignment.Right
                cl.Parent = item
                
                y = y + 38
            end
            
            list.CanvasSize = UDim2.new(0, 0, 0, math.max(y, 175))
            totalHeight = 340
            
        elseif currentTab == "controls" then
            sectionTitle.Text = "Controles"
            titleLine.BackgroundColor3 = CONFIG.accent
            
            -- Card de automação
            local autoCard = createCard(dynamicContent, 0, 180, "AUTOMAÇÃO DE TOQUE", CONFIG.accent)
            local autoToggle = createToggle(autoCard, 15, 50, CONFIG.autoTouch, "Auto Touch Automático")
            local bodyToggle = createToggle(autoCard, 15, 95, CONFIG.fullBodyTouch, "Full Body Touch (Todas as partes)")
            local secondToggle = createToggle(autoCard, 15, 140, CONFIG.autoSecondTouch, "Double Touch (2x toque rápido)")
            
            -- Card de skills
            local skillsCard = createCard(dynamicContent, 190, 130, "AUTO SKILLS", CONFIG.warning)
            local skillsToggle = createToggle(skillsCard, 15, 50, autoSkills, "Ativar Skills Automáticas")
            
            -- Info sobre skills
            local info = Instance.new("TextLabel")
            info.Size = UDim2.new(1, -30, 0, 50)
            info.Position = UDim2.new(0, 15, 0, 95)
            info.BackgroundTransparency = 1
            info.Text = "Detecta botões: Shoot, Pass, Dribble, Control automaticamente"
            info.TextColor3 = CONFIG.textMuted
            info.Font = Enum.Font.Gotham
            info.TextSize = 10 * CONFIG.scale
            info.TextWrapped = true
            info.Parent = skillsCard
            
            skillsToggle.container.MouseButton1Click:Connect(function()
                autoSkills = skillsToggle.get()
                addLog("Auto Skills: " .. (autoSkills and "ON" or "OFF"), autoSkills and "success" or "warning")
            end)
            
            totalHeight = 330
            
        elseif currentTab == "stats" then
            sectionTitle.Text = "Estatísticas"
            titleLine.BackgroundColor3 = CONFIG.info
            
            -- Card de performance
            local perfCard = createCard(dynamicContent, 0, 140, "PERFORMANCE", CONFIG.info)
            
            -- Grid de stats
            local stats = {
                {label = "Toques Totais", value = STATS.totalTouches, color = CONFIG.success},
                {label = "Bolas Tocadas", value = STATS.ballsTouched, color = CONFIG.primary},
                {label = "Skills Ativadas", value = STATS.skillsActivated, color = CONFIG.warning},
                {label = "Toques/Min", value = math.floor(STATS.touchesPerMinute), color = CONFIG.accent}
            }
            
            for i, stat in ipairs(stats) do
                local x = ((i-1) % 2) * 140
                local y = math.floor((i-1) / 2) * 65
                
                local box = Instance.new("Frame")
                box.Size = UDim2.new(0, 125 * CONFIG.scale, 0, 55 * CONFIG.scale)
                box.Position = UDim2.new(0, (15 + x) * CONFIG.scale, 0, (45 + y) * CONFIG.scale)
                box.BackgroundColor3 = CONFIG.bgElevated
                box.BackgroundTransparency = 0.3
                box.Parent = perfCard
                
                Instance.new("UICorner", box).CornerRadius = UDim.new(0, 12 * CONFIG.scale)
                
                local val = Instance.new("TextLabel")
                val.Size = UDim2.new(1, 0, 0.6, 0)
                val.BackgroundTransparency = 1
                val.Text = tostring(stat.value)
                val.TextColor3 = stat.color
                val.Font = Enum.Font.GothamBlack
                val.TextSize = 22 * CONFIG.scale
                val.Parent = box
                
                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1, 0, 0.4, 0)
                lbl.Position = UDim2.new(0, 0, 0.6, 0)
                lbl.BackgroundTransparency = 1
                lbl.Text = stat.label
                lbl.TextColor3 = CONFIG.textMuted
                lbl.Font = Enum.Font.GothamBold
                lbl.TextSize = 9 * CONFIG.scale
                lbl.Parent = box
            end
            
            -- Card de sessão
            local sessionCard = createCard(dynamicContent, 150, 100, "SESSÃO ATUAL", CONFIG.secondary)
            
            local sessionTime = tick() - STATS.sessionStart
            local mins = math.floor(sessionTime / 60)
            local secs = math.floor(sessionTime % 60)
            
            local timeLbl = Instance.new("TextLabel")
            timeLbl.Size = UDim2.new(1, 0, 0, 40)
            timeLbl.Position = UDim2.new(0, 0, 0, 45)
            timeLbl.BackgroundTransparency = 1
            timeLbl.Text = string.format("%02d:%02d", mins, secs)
            timeLbl.TextColor3 = CONFIG.textPrimary
            timeLbl.Font = Enum.Font.GothamBlack
            timeLbl.TextSize = 32 * CONFIG.scale
            timeLbl.Parent = sessionCard
            
            local timeSub = Instance.new("TextLabel")
            timeSub.Size = UDim2.new(1, 0, 0, 20)
            timeSub.Position = UDim2.new(0, 0, 0, 85)
            timeSub.BackgroundTransparency = 1
            timeSub.Text = "tempo de uso"
            timeSub.TextColor3 = CONFIG.textMuted
            timeSub.Font = Enum.Font.Gotham
            timeSub.TextSize = 11 * CONFIG.scale
            timeSub.Parent = sessionCard
            
            -- Atualização em tempo real das stats
            task.spawn(function()
                while sessionCard and sessionCard.Parent do
                    local st = tick() - STATS.sessionStart
                    local m = math.floor(st / 60)
                    local s = math.floor(st % 60)
                    timeLbl.Text = string.format("%02d:%02d", m, s)
                    
                    -- Calcular toques por minuto
                    if st > 0 then
                        STATS.touchesPerMinute = (STATS.totalTouches / st) * 60
                    end
                    
                    task.wait(1)
                end
            end)
            
            totalHeight = 260
            
        elseif currentTab == "settings" then
            sectionTitle.Text = "Configurações"
            titleLine.BackgroundColor3 = CONFIG.textSecondary
            
            -- Card de tema
            local themeCard = createCard(dynamicContent, 0, 120, "APARÊNCIA", CONFIG.textSecondary)
            
            local themeLbl = Instance.new("TextLabel")
            themeLbl.Size = UDim2.new(0, 100, 0, 30)
            themeLbl.Position = UDim2.new(0, 15, 0, 45)
            themeLbl.BackgroundTransparency = 1
            themeLbl.Text = "Tema:"
            themeLbl.TextColor3 = CONFIG.textSecondary
            themeLbl.Font = Enum.Font.GothamBold
            themeLbl.TextSize = 12 * CONFIG.scale
            themeLbl.TextXAlignment = Enum.TextXAlignment.Left
            themeLbl.Parent = themeCard
            
            -- Botões de tema
            local themes = {"dark", "light", "auto"}
            for i, th in ipairs(themes) do
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(0, 70 * CONFIG.scale, 0, 32 * CONFIG.scale)
                btn.Position = UDim2.new(0, (80 + (i-1)*80) * CONFIG.scale, 0, 45 * CONFIG.scale)
                btn.BackgroundColor3 = CONFIG.theme == th and CONFIG.accent or CONFIG.bgElevated
                btn.BackgroundTransparency = CONFIG.theme == th and 0.1 or 0.4
                btn.Text = th:upper()
                btn.TextColor3 = CONFIG.theme == th and CONFIG.textPrimary or CONFIG.textMuted
                btn.Font = Enum.Font.GothamBlack
                btn.TextSize = 10 * CONFIG.scale
                btn.AutoButtonColor = false
                btn.Parent = themeCard
                
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8 * CONFIG.scale)
                
                btn.MouseButton1Click:Connect(function()
                    applyTheme(th)
                end)
            end
            
            -- Card de efeitos
            local effectsCard = createCard(dynamicContent, 130, 130, "EFEITOS", CONFIG.accent)
            local particleToggle = createToggle(effectsCard, 15, 50, CONFIG.particleEffects, "Partículas de Fundo")
            local soundToggle = createToggle(effectsCard, 15, 95, CONFIG.soundEffects, "Indicadores Visuais")
            
            -- Card de escala
            local scaleCard = createCard(dynamicContent, 270, 110, "INTERFACE", CONFIG.primary)
            local scaleSlider = createSlider(scaleCard, 15, 45, 0.5, 1.5, CONFIG.scale, "Escala do Hub")
            
            -- Botão reset
            createActionButton(scaleCard, 200, 42, 90, 38, "APLICAR", CONFIG.success, function()
                CONFIG.scale = scaleSlider.get()
                addLog("Escala alterada para " .. CONFIG.scale, "success")
                createMainGUI()
            end)
            
            -- Card sistema
            local sysCard = createCard(dynamicContent, 390, 90, "SISTEMA", CONFIG.danger)
            createActionButton(sysCard, 15, 40, 120, 38, "RESETAR TUDO", CONFIG.danger, function()
                CONFIG.reach = 15
                CONFIG.showReachSphere = true
                CONFIG.autoTouch = true
                CONFIG.fullBodyTouch = true
                CONFIG.autoSecondTouch = true
                CONFIG.scale = 1.0
                CONFIG.theme = "dark"
                
                -- Reset stats
                STATS.totalTouches = 0
                STATS.ballsTouched = 0
                STATS.skillsActivated = 0
                
                addLog("Todas as configurações resetadas!", "warning")
                applyTheme("dark")
            end)
            
            totalHeight = 490
        end
        
        dynamicContent.CanvasSize = UDim2.new(0, 0, 0, totalHeight * CONFIG.scale)
    end
    
    -- ============================================
    -- DRAGGABLE E ANIMAÇÕES
    -- ============================================
    
    local dragging = false
    local dragStart, startPos
    
    headerFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)
    
    headerFrame.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    -- Animação de entrada épica
    main.Size = UDim2.new(0, 0, 0, 0)
    main.Rotation = -10
    
    tween(main, {Size = UDim2.new(0, W, 0, H), Rotation = 0}, 0.7, Enum.EasingStyle.Back)
    
    -- Notificação de inicialização
    addLog("CADUXX137 v13.0 Ultimate iniciado", "success")
    addLog("Sistema de partículas: " .. (CONFIG.particleEffects and "ON" or "OFF"), "info")
    addLog("Tema atual: " .. CONFIG.theme:upper(), "info")
    
    notify("CADUXX137 v13.0", "Ultimate Edition ativada!", 4, "success")
end

-- ============================================
-- LÓGICA ORIGINAL 100% PRESERVADA (EXPANDIDA)
-- ============================================

local function findBalls()
    local now = tick()
    if now - lastBallUpdate < CONFIG.scanCooldown then return #balls end
    lastBallUpdate = now
    
    table.clear(balls)
    for _, conn in ipairs(ballConnections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(ballConnections)
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Parent then
            for _, name in ipairs(CONFIG.ballNames) do
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
    
    -- Atualizar estatísticas
    if #balls > STATS.peakReach then
        STATS.peakReach = #balls
    end
    
    return #balls
end

local function updateCharacter()
    local newChar = player.Character
    if newChar ~= char then
        char = newChar
        if char then
            HRP = char:WaitForChild("HumanoidRootPart", 2)
            if HRP then
                addLog("Personagem conectado: " .. char.Name, "success")
                notify("Personagem Detectado", "Sistema de reach ativo!", 2, "success")
            end
        else
            HRP = nil
            addLog("Personagem desconectado", "warning")
        end
    end
end

local function getBodyParts()
    if not char then return {} end
    local parts = {}
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") then
            if CONFIG.fullBodyTouch then
                table.insert(parts, part)
            elseif part.Name == "HumanoidRootPart" then
                table.insert(parts, part)
            end
        end
    end
    return parts
end

local function updateSphere()
    if not CONFIG.showReachSphere then
        if reachSphere then
            reachSphere:Destroy()
            reachSphere = nil
        end
        return
    end
    
    if not reachSphere or not reachSphere.Parent then
        reachSphere = Instance.new("Part")
        reachSphere.Name = "CADU_ReachSphere_v13"
        reachSphere.Shape = Enum.PartType.Ball
        reachSphere.Anchored = true
        reachSphere.CanCollide = false
        reachSphere.Transparency = 0.92
        reachSphere.Material = Enum.Material.ForceField
        reachSphere.Color = CONFIG.accentColor
        reachSphere.Parent = Workspace
    end
    
    if HRP and HRP.Parent then
        reachSphere.Position = HRP.Position
        reachSphere.Size = Vector3.new(CONFIG.reach * 2, CONFIG.reach * 2, CONFIG.reach * 2)
    end
end

local function doTouch(ball, part)
    if not ball or not ball.Parent or not part or not part.Parent then return end
    
    local key = ball.Name .. "_" .. part.Name .. "_" .. tostring(ball)
    if touchDebounce[key] and tick() - touchDebounce[key] < 0.08 then return end
    touchDebounce[key] = tick()
    
    pcall(function()
        firetouchinterest(ball, part, 0)
        task.wait(0.01)
        firetouchinterest(ball, part, 1)
        
        if CONFIG.autoSecondTouch then
            task.wait(0.04)
            firetouchinterest(ball, part, 0)
            firetouchinterest(ball, part, 1)
        end
        
        -- Atualizar estatísticas
        STATS.totalTouches = STATS.totalTouches + 1
        if not STATS.ballsTouched then STATS.ballsTouched = 0 end
        STATS.ballsTouched = STATS.ballsTouched + 1
        
    end)
end

local function findSkillButtons()
    local buttons = {}
    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and not gui.Name:find("CADU") then
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
    return buttons
end

local function activateSkillButton(button)
    if not button or not button.Parent then return end
    
    local key = tostring(button)
    if activatedSkills[key] and tick() - activatedSkills[key] < skillCooldown then return end
    activatedSkills[key] = tick()
    
    pcall(function()
        if button:IsA("GuiButton") then
            for _, conn in ipairs(getconnections(button.MouseButton1Click)) do
                conn:Fire()
            end
            for _, conn in ipairs(getconnections(button.Activated)) do
                conn:Fire()
            end
            
            STATS.skillsActivated = STATS.skillsActivated + 1
        end
    end)
end

-- ============================================
-- LOOP PRINCIPAL OTIMIZADO
-- ============================================

RunService.Heartbeat:Connect(function()
    -- Atualizar FPS
    STATS.fps = math.floor(1 / RunService.Heartbeat:Wait())
    
    updateCharacter()
    updateSphere()
    
    if CONFIG.autoUpdate then
        findBalls()
    end
    
    if not HRP then return end
    
    local now = tick()
    if now - lastTouch < 0.05 then return end
    
    local hrpPos = HRP.Position
    local characterParts = getBodyParts()
    if #characterParts == 0 then return end
    
    local closestBall = nil
    local closestDistance = CONFIG.reach
    
    for _, ball in ipairs(balls) do
        if ball and ball.Parent then
            local distance = (ball.Position - hrpPos).Magnitude
            if distance <= CONFIG.reach and distance < closestDistance then
                closestDistance = distance
                closestBall = ball
            end
        end
    end
    
    if CONFIG.autoTouch and closestBall then
        lastTouch = now
        for _, part in ipairs(characterParts) do
            doTouch(closestBall, part)
        end
    end
    
    if autoSkills and closestBall and (now - lastSkillActivation > skillCooldown) then
        lastSkillActivation = now
        local skillButtons = findSkillButtons()
        for _, button in ipairs(skillButtons) do
            if button.Name == "Shoot" or button.Name == "Pass" or button.Name == "Dribble" or button.Name == "Control" then
                activateSkillButton(button)
            end
        end
    end
end)

-- ============================================
-- ATALHOS DE TECLADO (NOVO)
-- ============================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- F1: Minimizar/Maximizar
    if input.KeyCode == Enum.KeyCode.F1 then
        if mainGui then
            -- Minimizar
            local main = mainGui:FindFirstChild("Main")
            if main then
                tween(main, {Size = UDim2.new(0, 0, 0, 0)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
                task.wait(0.4)
                mainGui:Destroy()
                mainGui = nil
                isMinimized = true
                createIconButton()
            end
        else
            -- Maximizar
            if iconGui then
                iconGui:Destroy()
                iconGui = nil
            end
            isMinimized = false
            createMainGUI()
        end
    end
    
    -- F2: Toggle Auto Touch
    if input.KeyCode == Enum.KeyCode.F2 then
        CONFIG.autoTouch = not CONFIG.autoTouch
        addLog("Auto Touch: " .. (CONFIG.autoTouch and "ON" or "OFF"), CONFIG.autoTouch and "success" or "warning")
        if mainGui then
            createMainGUI() -- Recriar para atualizar UI
        end
    end
    
    -- F3: Toggle Esfera
    if input.KeyCode == Enum.KeyCode.F3 then
        CONFIG.showReachSphere = not CONFIG.showReachSphere
        addLog("Esfera: " .. (CONFIG.showReachSphere and "ON" or "OFF"), "info")
    end
end)

-- ============================================
-- INICIALIZAÇÃO SEGURA
-- ============================================

task.spawn(function()
    -- Aguardar jogo carregar completamente
    repeat 
        task.wait(0.1)
    until game:IsLoaded() and player.Character
    
    task.wait(0.8) -- Delay para garantir que tudo está pronto
    
    createMainGUI()
    
    -- Mensagem de boas-vindas no console
    print("========================================")
    print("  CADUXX137 v13.0 - ULTIMATE EDITION")
    print("  Status: ONLINE")
    print("  Atalhos: F1 (Minimizar) | F2 (Auto Touch) | F3 (Esfera)")
    print("========================================")
end)
