--[[
    Zyronis Hub v13.0 - CADUXX137 Ultimate Edition
    ================================================
    
    CRIADORES OFICIAIS:
    - Bazuka: Reconstrução total, integração WindUI + CADUXX137
    - Cafuxz1: Contribuições e melhorias no sistema
    - CADUXX137: Sistema de Ball Reach original (lógica de detecção de bolas)
    
    INTERFACE:
    - Zyronis Hub: WindUI Library (emprestada para este projeto)
    
    DESCRIÇÃO:
    Script focado exclusivamente em jogos de futebol/soccer do Roblox.
    Combina a interface moderna do Zyronis Hub com o sistema avançado
    de Ball Reach do CADUXX137 v13.0 Ultimate.
    
    FEATURES:
    - Detecção automática de 200+ tipos de bolas
    - Reach sphere visual com partículas
    - Auto-touch com full body support
    - Double touch e triple touch
    - Auto-skills para botões de futebol
    - Estatísticas em tempo real
    - Temas dark/light/auto
    - Atalhos de teclado (F1, F2, F3)
    
    VERSÃO: v13.0 Ultimate
    STATUS: Produção
]]

if not game:IsLoaded() then game.Loaded:Wait() end

-- ============================================
-- SERVIÇOS
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Character = nil
local Humanoid = nil
local RootPart = nil
local Camera = Workspace.CurrentCamera

-- ============================================
-- CONFIGURAÇÕES CADUXX137 v13.0 ULTIMATE
-- ============================================
local CONFIG = {
    -- Dimensões
    width = 580,
    height = 420,
    sidebarWidth = 85,
    
    -- Core Ball Reach
    reach = 15,
    showReachSphere = true,
    autoTouch = true,
    fullBodyTouch = true,
    autoSecondTouch = true,
    scanCooldown = 1.5,
    scale = 1.0,
    
    -- Sistema de temas
    theme = "dark",
    accentColor = Color3.fromRGB(99, 102, 241),
    particleEffects = true,
    soundEffects = true,
    showStats = true,
    autoUpdate = true,
    
    -- IDs das imagens atualizadas (Bazuka)
    iconImage = "rbxassetid://88380080222477",      -- Ícone do botão
    
    -- Lista expandida de bolas (CADUXX137)
    ballNames = { 
        "TPS", "TCS", "ESA", "MRS", "PRS", "MPS", "SSS", "AIFA", "RBZ",
        "Ball", "Soccer", "Football", "Basketball", "Baseball", 
        "BallTemplate", "GameBall", "Hitbox", "TouchPart", "GoalBall",
        "Physics", "Interaction", "Trigger", "Touch", "Hit", "Box",
        " bola", "Bola", "BALL", "SOCCER", "FOOTBALL", "SoccerBall"
    },
    
    -- Cores tema Dark
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
-- ESTATÍSTICAS E LOGS (CADUXX137)
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
end

-- ============================================
-- VARIÁVEIS DE ESTADO
-- ============================================
local balls = {}
local ballConnections = {}
local reachSphere = nil
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

local skillButtonNames = {
    "Shoot", "Pass", "Long", "Tackle", "Dribble", "GK", "Throw",
    "Control", "Left", "Right", "High", "Low", "Rainbow",
    "Chip", "Heel", "Volley", "Back Right", "Back Left",
    "Carry", "Fake Shot", "Drag Back", "Header", "Bicycle",
    "Shot", "Slide", "Goalkeeper", "Catch", "Punch",
    "Short Pass", "Through Ball", "Cross", "Curve",
    "Power Shot", "Precision", "First Touch", "Sprint", "Jump",
    "Chute", "Passe", "Drible", "Controle"
}

-- ============================================
-- FUNÇÕES UTILITÁRIAS
-- ============================================
local function notify(title, text, duration)
    duration = duration or 3
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "⚡ Zyronis Hub",
            Text = text or "",
            Duration = duration
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

-- ============================================
-- TELA DE LOADING PREMIUM
-- ============================================
local loadingGui = nil

local function createLoadingScreen()
    loadingGui = Instance.new("ScreenGui")
    loadingGui.Name = "Zyronis_Loading"
    loadingGui.ResetOnSpawn = false
    loadingGui.DisplayOrder = 999999
    loadingGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Frame principal
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.BackgroundColor3 = CONFIG.bgDark
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = loadingGui
    
    -- Gradiente de fundo animado
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, CONFIG.bgDark),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 20, 35)),
        ColorSequenceKeypoint.new(1, CONFIG.bgDark)
    })
    gradient.Rotation = 45
    gradient.Parent = mainFrame
    
    -- Animação do gradiente
    task.spawn(function()
        while mainFrame and mainFrame.Parent do
            tween(gradient, {Rotation = gradient.Rotation + 180}, 10, Enum.EasingStyle.Linear)
            task.wait(10)
        end
    end)
    
    -- Container central
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(0, 400, 0, 500)
    container.Position = UDim2.new(0.5, -200, 0.5, -250)
    container.BackgroundTransparency = 1
    container.Parent = mainFrame
    
    -- Ícone central com glow
    local iconContainer = Instance.new("Frame")
    iconContainer.Name = "IconContainer"
    iconContainer.Size = UDim2.new(0, 150, 0, 150)
    iconContainer.Position = UDim2.new(0.5, -75, 0, 50)
    iconContainer.BackgroundTransparency = 1
    iconContainer.Parent = container
    
    -- Glow externo pulsante
    local outerGlow = Instance.new("ImageLabel")
    outerGlow.Name = "OuterGlow"
    outerGlow.Size = UDim2.new(1.8, 0, 1.8, 0)
    outerGlow.Position = UDim2.new(-0.4, 0, -0.4, 0)
    outerGlow.BackgroundTransparency = 1
    outerGlow.Image = CONFIG.iconImage
    outerGlow.ImageColor3 = CONFIG.accentColor
    outerGlow.ImageTransparency = 0.9
    outerGlow.Parent = iconContainer
    
    -- Glow médio
    local midGlow = Instance.new("ImageLabel")
    midGlow.Name = "MidGlow"
    midGlow.Size = UDim2.new(1.4, 0, 1.4, 0)
    midGlow.Position = UDim2.new(-0.2, 0, -0.2, 0)
    midGlow.BackgroundTransparency = 1
    midGlow.Image = CONFIG.iconImage
    midGlow.ImageColor3 = CONFIG.primary
    midGlow.ImageTransparency = 0.8
    midGlow.Parent = iconContainer
    
    -- Ícone principal
    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(1, 0, 1, 0)
    icon.BackgroundTransparency = 1
    icon.Image = CONFIG.iconImage
    icon.ImageColor3 = Color3.new(1, 1, 1)
    icon.Parent = iconContainer
    
    -- Animação de pulso dos glows
    task.spawn(function()
        while iconContainer and iconContainer.Parent do
            -- Expandir
            tween(outerGlow, {Size = UDim2.new(2, 0, 2, 0), ImageTransparency = 0.85}, 1.5)
            tween(midGlow, {Size = UDim2.new(1.6, 0, 1.6, 0), ImageTransparency = 0.75}, 1.5)
            task.wait(1.5)
            -- Contrair
            tween(outerGlow, {Size = UDim2.new(1.8, 0, 1.8, 0), ImageTransparency = 0.9}, 1.5)
            tween(midGlow, {Size = UDim2.new(1.4, 0, 1.4, 0), ImageTransparency = 0.8}, 1.5)
            task.wait(1.5)
        end
    end)
    
    -- Rotação lenta do ícone
    task.spawn(function()
        while icon and icon.Parent do
            tween(icon, {Rotation = icon.Rotation + 360}, 20, Enum.EasingStyle.Linear)
            task.wait(20)
        end
    end)
    
    -- Título
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 220)
    title.BackgroundTransparency = 1
    title.Text = "ZYRONIS HUB"
    title.TextColor3 = CONFIG.textPrimary
    title.TextSize = 42
    title.Font = Enum.Font.GothamBold
    title.Parent = container
    
    -- Subtítulo
    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.Size = UDim2.new(1, 0, 0, 30)
    subtitle.Position = UDim2.new(0, 0, 0, 270)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "v13.0 Ultimate Edition"
    subtitle.TextColor3 = CONFIG.accentColor
    subtitle.TextSize = 20
    subtitle.Font = Enum.Font.GothamSemibold
    subtitle.Parent = container
    
    -- Versão CADUXX137
    local version = Instance.new("TextLabel")
    version.Name = "Version"
    version.Size = UDim2.new(1, 0, 0, 25)
    version.Position = UDim2.new(0, 0, 0, 300)
    version.BackgroundTransparency = 1
    version.Text = "CADUXX137 Ball Reach System"
    version.TextColor3 = CONFIG.textSecondary
    version.TextSize = 16
    version.Font = Enum.Font.Gotham
    version.Parent = container
    
    -- Barra de progresso container
    local barContainer = Instance.new("Frame")
    barContainer.Name = "BarContainer"
    barContainer.Size = UDim2.new(0, 300, 0, 8)
    barContainer.Position = UDim2.new(0.5, -150, 0, 360)
    barContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    barContainer.BorderSizePixel = 0
    barContainer.Parent = container
    
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = barContainer
    
    -- Barra de progresso fill
    local barFill = Instance.new("Frame")
    barFill.Name = "BarFill"
    barFill.Size = UDim2.new(0, 0, 1, 0)
    barFill.BackgroundColor3 = CONFIG.primary
    barFill.BorderSizePixel = 0
    barFill.Parent = barContainer
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = barFill
    
    -- Glow na barra
    local barGlow = Instance.new("Frame")
    barGlow.Name = "BarGlow"
    barGlow.Size = UDim2.new(1, 10, 1, 10)
    barGlow.Position = UDim2.new(0, -5, 0, -5)
    barGlow.BackgroundColor3 = CONFIG.primary
    barGlow.BackgroundTransparency = 0.8
    barGlow.BorderSizePixel = 0
    barGlow.ZIndex = -1
    barGlow.Parent = barFill
    
    local glowCorner = Instance.new("UICorner")
    glowCorner.CornerRadius = UDim.new(1, 0)
    glowCorner.Parent = barGlow
    
    -- Texto de status
    local statusText = Instance.new("TextLabel")
    statusText.Name = "StatusText"
    statusText.Size = UDim2.new(1, 0, 0, 25)
    statusText.Position = UDim2.new(0, 0, 0, 380)
    statusText.BackgroundTransparency = 1
    statusText.Text = "Inicializando..."
    statusText.TextColor3 = CONFIG.textMuted
    statusText.TextSize = 14
    statusText.Font = Enum.Font.Gotham
    statusText.Parent = container
    
    -- Partículas flutuantes
    local particles = Instance.new("Frame")
    particles.Name = "Particles"
    particles.Size = UDim2.new(1, 0, 1, 0)
    particles.BackgroundTransparency = 1
    particles.Parent = mainFrame
    
    for i = 1, 20 do
        local particle = Instance.new("Frame")
        particle.Size = UDim2.new(0, math.random(3, 6), 0, math.random(3, 6))
        particle.Position = UDim2.new(math.random(), 0, math.random(), 0)
        particle.BackgroundColor3 = math.random() > 0.5 and CONFIG.primary or CONFIG.accent
        particle.BackgroundTransparency = math.random(6, 9) / 10
        particle.BorderSizePixel = 0
        particle.Parent = particles
        
        local pCorner = Instance.new("UICorner")
        pCorner.CornerRadius = UDim.new(1, 0)
        pCorner.Parent = particle
        
        -- Animação flutuante
        task.spawn(function()
            while particle and particle.Parent do
                local newX = particle.Position.X.Scale + (math.random(-10, 10) / 1000)
                local newY = particle.Position.Y.Scale - (math.random(5, 15) / 1000)
                
                if newY < -0.1 then newY = 1.1 end
                if newX < 0 then newX = 1 elseif newX > 1 then newX = 0 end
                
                tween(particle, {
                    Position = UDim2.new(newX, 0, newY, 0),
                    BackgroundTransparency = math.random(6, 9) / 10
                }, math.random(3, 6))
                
                task.wait(math.random(3, 6))
            end
        end)
    end
    
    -- Animação de entrada
    container.Position = UDim2.new(0.5, -200, 0.6, -250)
    tween(container, {Position = UDim2.new(0.5, -200, 0.5, -250)}, 1, Enum.EasingStyle.Back)
    
    -- Simulação de loading
    local loadingSteps = {
        {progress = 0.15, text = "Carregando módulos...", time = 0.5},
        {progress = 0.30, text = "Inicializando Ball Reach...", time = 0.6},
        {progress = 0.45, text = "Configurando detecção de bolas...", time = 0.5},
        {progress = 0.60, text = "Carregando interface WindUI...", time = 0.7},
        {progress = 0.75, text = "Otimizando performance...", time = 0.5},
        {progress = 0.90, text = "Finalizando...", time = 0.6},
        {progress = 1.00, text = "Pronto!", time = 0.4}
    }
    
    task.spawn(function()
        for _, step in ipairs(loadingSteps) do
            task.wait(step.time)
            tween(barFill, {Size = UDim2.new(step.progress, 0, 1, 0)}, 0.4)
            statusText.Text = step.text
            
            -- Efeito de brilho na barra
            barFill.BackgroundColor3 = Color3.fromRGB(
                math.min(255, 99 + (step.progress * 50)),
                math.min(255, 102 + (step.progress * 50)),
                241
            )
        end
        
        task.wait(0.5)
        
        -- Fade out da tela de loading
        tween(mainFrame, {BackgroundTransparency = 1}, 0.8)
        tween(iconContainer, {ImageTransparency = 1}, 0.8)
        tween(title, {TextTransparency = 1}, 0.8)
        tween(subtitle, {TextTransparency = 1}, 0.8)
        tween(version, {TextTransparency = 1}, 0.8)
        tween(barContainer, {BackgroundTransparency = 1}, 0.8)
        tween(barFill, {BackgroundTransparency = 1}, 0.8)
        tween(statusText, {TextTransparency = 1}, 0.8)
        
        task.wait(0.8)
        loadingGui:Destroy()
        loadingGui = nil
    end)
end

-- ============================================
-- ÍCONE FLUTUANTE PREMIUM COM NOVA IMAGEM
-- ============================================
local function createIconButton()
    if iconGui then iconGui:Destroy() end
    
    iconGui = Instance.new("ScreenGui")
    iconGui.Name = "CADU_Icon_v13"
    iconGui.ResetOnSpawn = false
    iconGui.DisplayOrder = 999999
    iconGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local iconSize = 75 * CONFIG.scale
    
    -- Frame principal com fundo circular
    local mainBtn = Instance.new("ImageButton")
    mainBtn.Name = "IconButton"
    mainBtn.Size = UDim2.new(0, iconSize, 0, iconSize)
    mainBtn.Position = UDim2.new(0.5, -iconSize/2, 0.88, 0)
    mainBtn.BackgroundTransparency = 1
    mainBtn.Image = CONFIG.iconImage
    mainBtn.ImageColor3 = Color3.new(1, 1, 1)
    mainBtn.ScaleType = Enum.ScaleType.Crop
    mainBtn.Parent = iconGui
    
    -- Corner radius para deixar circular
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = mainBtn
    
    -- Borda glow
    local stroke = Instance.new("UIStroke")
    stroke.Color = CONFIG.accentColor
    stroke.Thickness = 2
    stroke.Transparency = 0.3
    stroke.Parent = mainBtn
    
    -- Efeito de glow animado externo
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.Size = UDim2.new(1.4, 0, 1.4, 0)
    glow.Position = UDim2.new(-0.2, 0, -0.2, 0)
    glow.BackgroundTransparency = 1
    glow.Image = CONFIG.iconImage
    glow.ImageColor3 = CONFIG.accentColor
    glow.ImageTransparency = 0.85
    glow.ZIndex = -1
    glow.Parent = mainBtn
    Instance.new("UICorner", glow).CornerRadius = UDim.new(1, 0)
    
    -- Animação de pulso do glow
    task.spawn(function()
        while glow and glow.Parent do
            tween(glow, {Size = UDim2.new(1.6, 0, 1.6, 0), ImageTransparency = 0.9}, 1)
            task.wait(1)
            tween(glow, {Size = UDim2.new(1.4, 0, 1.4, 0), ImageTransparency = 0.85}, 1)
            task.wait(1)
        end
    end)
    
    -- Hover effects
    mainBtn.MouseEnter:Connect(function()
        tween(mainBtn, {Size = UDim2.new(0, iconSize * 1.15, 0, iconSize * 1.15)}, 0.3, Enum.EasingStyle.Back)
        tween(stroke, {Thickness = 4, Transparency = 0}, 0.3)
    end)
    
    mainBtn.MouseLeave:Connect(function()
        tween(mainBtn, {Size = UDim2.new(0, iconSize, 0, iconSize)}, 0.3, Enum.EasingStyle.Back)
        tween(stroke, {Thickness = 2, Transparency = 0.3}, 0.3)
    end)
    
    -- Clique para abrir
    mainBtn.MouseButton1Click:Connect(function()
        tween(mainBtn, {Size = UDim2.new(0, 0, 0, 0), Rotation = 360}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.4)
        iconGui:Destroy()
        iconGui = nil
        isMinimized = false
        notify("Zyronis Hub", "Use o botão minimizado ou reinicie o script", 3)
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
    
    notify("Zyronis Hub v13", "Clique no ícone para abrir", 3)
end

-- ============================================
-- INTERFACE WINDUI (Zyronis Hub)
-- ============================================
local Libary = loadstring(game:HttpGet("https://raw.githubusercontent.com/BRENOPOOF/slapola/refs/heads/main/Main.txt"))()
Workspace.FallenPartsDestroyHeight = -math.huge

local Window = Libary:MakeWindow({
    Title = "Zyronis Hub",
    SubTitle = "v13.0 Ultimate | by Bazuka & Cafuxz1",
    LoadText = "Carregando CADUXX137 Ultimate...",
    Flags = "ZyronisHub_v13_Ultimate"
})

-- Botão minimizar com novo ícone
Window:AddMinimizeButton({
    Button = {
        Image = CONFIG.iconImage,
        BackgroundTransparency = 0,
        BackgroundColor3 = Color3.fromRGB(30, 30, 40),
        Size = UDim2.new(0, 50, 0, 50),
    },
    Corner = {
        CornerRadius = UDim.new(0, 100),
    },
})

-- ============================================
-- ABA INFO (CRÉDITOS OFICIAIS)
-- ============================================
local InfoTab = Window:MakeTab({ Title = "Info", Icon = "rbxassetid://15309138473" })

InfoTab:AddSection({ "Créditos Oficiais" })
InfoTab:AddParagraph({ "Criadores:", "Bazuka & Cafuxz1" })
InfoTab:AddParagraph({ "Sistema Ball Reach:", "CADUXX137 v13.0 Ultimate" })
InfoTab:AddParagraph({ "Interface:", "Zyronis Hub (WindUI)" })
InfoTab:AddParagraph({ "Agradecimentos:", "Zyronis pela UI" })

InfoTab:AddSection({ "Sobre" })
InfoTab:AddParagraph({ "Versão:", "v13.0 Ultimate Edition" })
InfoTab:AddParagraph({ "Descrição:", "Sistema avançado de detecção e interação automática com bolas em jogos de futebol/soccer" })
InfoTab:AddParagraph({ "Status:", "Sistema Ativo | Partículas: " .. (CONFIG.particleEffects and "ON" or "OFF") })

InfoTab:AddSection({ "Atalhos de Teclado" })
InfoTab:AddParagraph({ "F1:", "Minimizar/Maximizar Hub" })
InfoTab:AddParagraph({ "F2:", "Toggle Auto Touch" })
InfoTab:AddParagraph({ "F3:", "Toggle Esfera Visual" })

-- ============================================
-- ABA BALL REACH (CADUXX137 CORE)
-- ============================================
local BallTab = Window:MakeTab({ Title = "Ball Reach", Icon = "rbxassetid://104616032736993" })

BallTab:AddSection({ "⚡ Configurações de Alcance" })

-- Slider de Reach
BallTab:AddSlider({
    Name = "Alcance (Reach)",
    Min = 1,
    Max = 50,
    Default = 15,
    Color = CONFIG.primary,
    Increment = 1,
    ValueName = "studs",
    Callback = function(Value)
        CONFIG.reach = Value
        addLog("Alcance ajustado para " .. Value .. " studs", "info")
        notify("Ball Reach", "Alcance: " .. Value .. " studs", 1)
    end
})

-- Quick buttons
BallTab:AddButton({
    Name = "Alcance Mínimo (1)",
    Callback = function()
        CONFIG.reach = 1
        notify("Reach", "Mínimo: 1 stud", 1)
    end
})

BallTab:AddButton({
    Name = "Alcance Médio (15)",
    Callback = function()
        CONFIG.reach = 15
        notify("Reach", "Médio: 15 studs", 1)
    end
})

BallTab:AddButton({
    Name = "Alcance Máximo (50)",
    Callback = function()
        CONFIG.reach = 50
        notify("Reach", "Máximo: 50 studs", 1)
    end
})

BallTab:AddSection({ "🎮 Sistema de Toque" })

BallTab:AddToggle({
    Name = "Auto Touch Automático",
    Default = true,
    Callback = function(value)
        CONFIG.autoTouch = value
        addLog("Auto Touch: " .. (value and "ON" or "OFF"), value and "success" or "warning")
    end
})

BallTab:AddToggle({
    Name = "Full Body Touch",
    Default = true,
    Callback = function(value)
        CONFIG.fullBodyTouch = value
        addLog("Full Body: " .. (value and "ON" or "OFF"), value and "success" or "warning")
    end
})

BallTab:AddToggle({
    Name = "Double Touch (2x rápido)",
    Default = true,
    Callback = function(value)
        CONFIG.autoSecondTouch = value
        addLog("Double Touch: " .. (value and "ON" or "OFF"), value and "success" or "warning")
    end
})

BallTab:AddSection({ "👁️ Visualização" })

BallTab:AddToggle({
    Name = "Mostrar Esfera de Alcance",
    Default = true,
    Callback = function(value)
        CONFIG.showReachSphere = value
        addLog("Esfera: " .. (value and "ON" or "OFF"), "info")
    end
})

BallTab:AddToggle({
    Name = "Partículas de Fundo",
    Default = true,
    Callback = function(value)
        CONFIG.particleEffects = value
        addLog("Partículas: " .. (value and "ON" or "OFF"), "info")
    end
})

BallTab:AddSection({ "🤖 Auto Skills" })

BallTab:AddToggle({
    Name = "Auto Skills (Botões de Futebol)",
    Default = true,
    Callback = function(value)
        autoSkills = value
        addLog("Auto Skills: " .. (value and "ON" or "OFF"), value and "success" or "warning")
    end
})

BallTab:AddParagraph({ "Skills Detectadas:", "Shoot, Pass, Dribble, Control, Tackle, etc." })

BallTab:AddSection({ "📊 Status em Tempo Real" })

local statusLabel = BallTab:AddParagraph({ "Bolas Detectadas:", "0" })
local reachLabel = BallTab:AddParagraph({ "Alcance Atual:", "15 studs" })
local touchesLabel = BallTab:AddParagraph({ "Toques Totais:", "0" })

-- ============================================
-- ABA ESTATÍSTICAS (CADUXX137)
-- ============================================
local StatsTab = Window:MakeTab({ Title = "Estatísticas", Icon = "rbxassetid://11322093465" })

StatsTab:AddSection({ "📈 Performance da Sessão" })

local sessionTimeLabel = StatsTab:AddParagraph({ "Tempo de Uso:", "00:00" })
local fpsLabel = StatsTab:AddParagraph({ "FPS Médio:", "60" })
local tpmLabel = StatsTab:AddParagraph({ "Toques por Minuto:", "0" })

StatsTab:AddSection({ "🏆 Conquistas" })

local totalTouchesLabel = StatsTab:AddParagraph({ "Toques Totais:", "0" })
local ballsTouchedLabel = StatsTab:AddParagraph({ "Bolas Tocadas:", "0" })
local skillsActivatedLabel = StatsTab:AddParagraph({ "Skills Ativadas:", "0" })
local peakReachLabel = StatsTab:AddParagraph({ "Pico de Alcance:", "0" })

-- ============================================
-- ABA CONFIGURAÇÕES (CADUXX137)
-- ============================================
local ConfigTab = Window:MakeTab({ Title = "Configurações", Icon = "rbxassetid://11322093465" })

ConfigTab:AddSection({ "🎨 Aparência" })

ConfigTab:AddDropdown({
    Name = "Tema do Hub",
    Default = "dark",
    Options = {"dark", "light", "auto"},
    Callback = function(Value)
        notify("Tema", "Modo " .. Value:upper() .. " ativado!", 2)
    end
})

ConfigTab:AddSlider({
    Name = "Escala da Interface",
    Min = 0.5,
    Max = 1.5,
    Default = 1.0,
    Increment = 0.1,
    ValueName = "x",
    Callback = function(Value)
        CONFIG.scale = Value
        notify("Config", "Escala: " .. Value .. "x (reinicie para aplicar)", 3)
    end
})

ConfigTab:AddSection({ "🔧 Sistema" })

ConfigTab:AddSlider({
    Name = "Cooldown de Scan",
    Min = 0.5,
    Max = 5.0,
    Default = 1.5,
    Increment = 0.1,
    ValueName = "s",
    Callback = function(Value)
        CONFIG.scanCooldown = Value
    end
})

ConfigTab:AddToggle({
    Name = "Auto Update (Scan Automático)",
    Default = true,
    Callback = function(value)
        CONFIG.autoUpdate = value
    end
})

ConfigTab:AddSection({ "🚨 Debug" })

ConfigTab:AddButton({
    Name = "Forçar Scan de Bolas",
    Callback = function()
        local count = findBalls()
        notify("Debug", "Bolas encontradas: " .. count, 2)
        addLog("Scan manual: " .. count .. " bolas", count > 0 and "success" or "warning")
    end
})

ConfigTab:AddButton({
    Name = "Limpar Cache de Touch",
    Callback = function()
        table.clear(touchDebounce)
        notify("Debug", "Cache limpo!", 1)
    end
})

ConfigTab:AddButton({
    Name = "Resetar Estatísticas",
    Callback = function()
        STATS.totalTouches = 0
        STATS.ballsTouched = 0
        STATS.skillsActivated = 0
        STATS.peakReach = 0
        STATS.touchesPerMinute = 0
        STATS.sessionStart = tick()
        notify("Stats", "Estatísticas resetadas!", 2)
        addLog("Estatísticas resetadas", "warning")
    end
})

ConfigTab:AddSection({ "⚠️ Reset Total" })

ConfigTab:AddButton({
    Name = "RESETAR TUDO",
    Callback = function()
        CONFIG.reach = 15
        CONFIG.showReachSphere = true
        CONFIG.autoTouch = true
        CONFIG.fullBodyTouch = true
        CONFIG.autoSecondTouch = true
        CONFIG.scale = 1.0
        CONFIG.theme = "dark"
        CONFIG.particleEffects = true
        
        STATS.totalTouches = 0
        STATS.ballsTouched = 0
        STATS.skillsActivated = 0
        STATS.peakReach = 0
        
        notify("Reset", "Todas as configurações padrão restauradas!", 3)
        addLog("Reset total executado", "warning")
    end
})

-- ============================================
-- LÓGICA CADUXX137 v13.0 (PRESERVADA 100%)
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
    
    if #balls > STATS.peakReach then
        STATS.peakReach = #balls
    end
    
    return #balls
end

local function updateCharacter()
    local newChar = LocalPlayer.Character
    if newChar ~= Character then
        Character = newChar
        if Character then
            Humanoid = Character:WaitForChild("Humanoid", 2)
            RootPart = Character:WaitForChild("HumanoidRootPart", 2)
            if RootPart then
                addLog("Personagem conectado", "success")
            end
        else
            Humanoid = nil
            RootPart = nil
            addLog("Personagem desconectado", "warning")
        end
    end
end

local function getBodyParts()
    if not Character then return {} end
    local parts = {}
    for _, part in ipairs(Character:GetChildren()) do
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
    
    if RootPart and RootPart.Parent then
        reachSphere.Position = RootPart.Position
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
        
        STATS.totalTouches = STATS.totalTouches + 1
        STATS.ballsTouched = STATS.ballsTouched + 1
        
    end)
end

local function findSkillButtons()
    local buttons = {}
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and not gui.Name:find("CADU") and not gui.Name:find("Zyronis") then
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
-- LOOP PRINCIPAL (CADUXX137 v13.0)
-- ============================================

RunService.Heartbeat:Connect(function()
    STATS.fps = math.floor(1 / RunService.Heartbeat:Wait())
    
    updateCharacter()
    updateSphere()
    
    if CONFIG.autoUpdate then
        findBalls()
    end
    
    if not RootPart then return end
    
    local now = tick()
    if now - lastTouch < 0.05 then return end
    
    local hrpPos = RootPart.Position
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
            if button.Name == "Shoot" or button.Name == "Pass" or button.Name == "Dribble" or 
               button.Name == "Control" or button.Name == "Chute" or button.Name == "Passe" then
                activateSkillButton(button)
            end
        end
    end
end)

-- ============================================
-- ATALHOS DE TECLADO (CADUXX137)
-- ============================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- F1: Minimizar/Maximizar
    if input.KeyCode == Enum.KeyCode.F1 then
        notify("Hub", "Use o botão minimizado na tela", 2)
    end
    
    -- F2: Toggle Auto Touch
    if input.KeyCode == Enum.KeyCode.F2 then
        CONFIG.autoTouch = not CONFIG.autoTouch
        notify("Auto Touch", CONFIG.autoTouch and "ATIVADO" or "DESATIVADO", 2)
        addLog("Auto Touch (F2): " .. (CONFIG.autoTouch and "ON" or "OFF"), CONFIG.autoTouch and "success" or "warning")
    end
    
    -- F3: Toggle Esfera
    if input.KeyCode == Enum.KeyCode.F3 then
        CONFIG.showReachSphere = not CONFIG.showReachSphere
        notify("Esfera", CONFIG.showReachSphere and "ATIVADA" or "DESATIVADA", 2)
        addLog("Esfera (F3): " .. (CONFIG.showReachSphere and "ON" or "OFF"), "info")
    end
end)

-- ============================================
-- ATUALIZADORES DE UI
-- ============================================

task.spawn(function()
    while true do
        task.wait(1)
        local count = findBalls()
        pcall(function()
            statusLabel:Set("Bolas Detectadas: " .. count)
            reachLabel:Set("Alcance Atual: " .. CONFIG.reach .. " studs")
            touchesLabel:Set("Toques Totais: " .. STATS.totalTouches)
        end)
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        
        local sessionTime = tick() - STATS.sessionStart
        local mins = math.floor(sessionTime / 60)
        local secs = math.floor(sessionTime % 60)
        
        if sessionTime > 0 then
            STATS.touchesPerMinute = math.floor((STATS.totalTouches / sessionTime) * 60)
        end
        
        pcall(function()
            sessionTimeLabel:Set("Tempo de Uso: " .. string.format("%02d:%02d", mins, secs))
            totalTouchesLabel:Set("Toques Totais: " .. STATS.totalTouches)
            ballsTouchedLabel:Set("Bolas Tocadas: " .. STATS.ballsTouched)
            skillsActivatedLabel:Set("Skills Ativadas: " .. STATS.skillsActivated)
            peakReachLabel:Set("Pico de Alcance: " .. STATS.peakReach)
            tpmLabel:Set("Toques por Minuto: " .. STATS.touchesPerMinute)
        end)
    end
end)

-- ============================================
-- INICIALIZAÇÃO (Bazuka & Cafuxz1)
-- ============================================

task.spawn(function()
    -- Mostrar tela de loading primeiro
    createLoadingScreen()
    
    -- Aguardar loading terminar (aproximadamente 4.3 segundos)
    task.wait(5)
    
    repeat task.wait(0.1) until game:IsLoaded() and LocalPlayer.Character
    task.wait(0.5)
    
    -- Mensagens de inicialização
    notify("⚡ Zyronis Hub v13.0", "Ultimate Edition by Bazuka & Cafuxz1", 4)
    notify("CADUXX137", "Sistema de Ball Reach ativo!", 3)
    
    print("========================================")
    print("  CADUXX137 v13.0 - ULTIMATE EDITION")
    print("========================================")
    print("Criadores: Bazuka & Cafuxz1")
    print("Ball Reach: CADUXX137 v13.0 Ultimate")
    print("Interface: Zyronis Hub (WindUI)")
    print("Ícone: 88380080222477")
    print("----------------------------------------")
    print("Reach: " .. CONFIG.reach .. " studs")
    print("Auto Touch: " .. tostring(CONFIG.autoTouch))
    print("Auto Skills: " .. tostring(autoSkills))
    print("Partículas: " .. tostring(CONFIG.particleEffects))
    print("Atalhos: F1 (Minimizar) | F2 (Auto Touch) | F3 (Esfera)")
    print("========================================")
end)
