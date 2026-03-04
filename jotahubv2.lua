-- ============================================
-- CADUXX137 v11.0 GLASS EDITION
-- Design inspirado em WindUI + Glassmorphism
-- ============================================

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ============================================
-- CONFIGURAÇÕES GLASS EDITION
-- ============================================
local CONFIG = {
    version = "v11.0 GLASS",
    build = "WindUI Edition",
    
    -- Glassmorphism Settings
    glassTransparency = 0.15,
    glassBlur = 0.05,
    acrylicTint = Color3.fromRGB(20, 20, 30),
    borderLight = Color3.fromRGB(255, 255, 255),
    
    -- Cores WindUI Inspired
    primary = Color3.fromRGB(99, 102, 241),      -- Indigo vibrante
    secondary = Color3.fromRGB(139, 92, 246),    -- Violeta
    accent = Color3.fromRGB(14, 165, 233),       -- Sky blue
    success = Color3.fromRGB(34, 197, 94),       -- Emerald
    warning = Color3.fromRGB(245, 158, 11),      -- Amber
    danger = Color3.fromRGB(239, 68, 68),        -- Red
    
    -- Cores de fundo glass
    bgDark = Color3.fromRGB(10, 10, 15),
    bgGlass = Color3.fromRGB(25, 25, 35),
    bgCard = Color3.fromRGB(30, 30, 45),
    bgElevated = Color3.fromRGB(40, 40, 60),
    
    -- Texto
    textPrimary = Color3.fromRGB(250, 250, 250),
    textSecondary = Color3.fromRGB(160, 160, 180),
    textMuted = Color3.fromRGB(120, 120, 140),
    
    -- Funcionalidades
    reach = 15,
    showReachSphere = true,
    autoTouch = true,
    fullBodyTouch = true,
    autoSecondTouch = true,
    scanCooldown = 1.5,
    scale = 1.0,
    
    -- Imagens
    iconImage = "rbxassetid://104616032736993",
    iconBackground = "rbxassetid://96755648876012",
    
    -- Ball names
    ballNames = { 
        "TPS", "TCS", "ESA", "MRS", "PRS", "MPS", "SSS", "AIFA", "RBZ",
        "Ball", "Soccer", "Football", "Basketball", "Baseball", 
        "BallTemplate", "GameBall", "Hitbox", "TouchPart", "GoalBall"
    },
}

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

-- Skill names
local skillButtonNames = {
    "Shoot", "Pass", "Long", "Tackle", "Dribble", "GK", "Throw",
    "Control", "Left", "Right", "High", "Low", "Rainbow",
    "Chip", "Heel", "Volley", "Back Right", "Back Left",
    "Carry", "Fake Shot", "Drag Back", "Header", "Bicycle",
    "Shot", "Slide", "Goalkeeper", "Catch", "Punch",
    "Short Pass", "Through Ball", "Cross", "Curve",
    "Power Shot", "Precision", "First Touch"
}

-- ============================================
-- SISTEMA DE UTILITÁRIOS PREMIUM
-- ============================================

local function notify(title, text, duration, type)
    duration = duration or 3
    type = type or "info"
    
    local color = CONFIG.accent
    if type == "success" then color = CONFIG.success
    elseif type == "warning" then color = CONFIG.warning
    elseif type == "error" then color = CONFIG.danger
    elseif type == "premium" then color = CONFIG.primary end
    
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "CADUXX137",
            Text = text or "",
            Duration = duration,
            Icon = CONFIG.iconImage
        })
    end)
end

local function tween(obj, props, time, style, direction, callback)
    time = time or 0.35
    style = style or Enum.EasingStyle.Quint
    direction = direction or Enum.EasingDirection.Out
    
    local tweenInfo = TweenInfo.new(time, style, direction)
    local t = TweenService:Create(obj, tweenInfo, props)
    
    if callback then
        t.Completed:Connect(callback)
    end
    
    t:Play()
    return t
end

local function createGlassEffect(parent, intensity)
    intensity = intensity or CONFIG.glassTransparency
    
    -- Camada de glass base
    local glass = Instance.new("Frame")
    glass.Name = "GlassLayer"
    glass.Size = UDim2.new(1, 0, 1, 0)
    glass.BackgroundColor3 = CONFIG.acrylicTint
    glass.BackgroundTransparency = intensity
    glass.BorderSizePixel = 0
    glass.ZIndex = -1
    glass.Parent = parent
    
    -- Borda luminosa sutil (simulação de acrylic)
    local border = Instance.new("UIStroke")
    border.Color = CONFIG.borderLight
    border.Transparency = 0.9
    border.Thickness = 1
    border.Parent = parent
    
    -- Gradient overlay para efeito de profundidade
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
        ColorSequenceKeypoint.new(1, Color3.new(0.8, 0.8, 0.9))
    })
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.95),
        NumberSequenceKeypoint.new(1, 0.98)
    })
    gradient.Rotation = 45
    gradient.Parent = glass
    
    return glass
end

local function createCorner(parent, radius)
    radius = radius or 16
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius * CONFIG.scale)
    corner.Parent = parent
    return corner
end

local function createShadow(parent, intensity, offset)
    intensity = intensity or 0.6
    offset = offset or 20
    
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, offset * 2 * CONFIG.scale, 1, offset * 2 * CONFIG.scale)
    shadow.Position = UDim2.new(0, -offset * CONFIG.scale, 0, -offset * CONFIG.scale)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://131296141"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = intensity
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.ZIndex = -2
    shadow.Parent = parent
    
    return shadow
end

local function createGlow(parent, color, size, transparency)
    color = color or CONFIG.primary
    size = size or 1.2
    transparency = transparency or 0.85
    
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.Size = UDim2.new(size, 0, size, 0)
    glow.Position = UDim2.new(-(size-1)/2, 0, -(size-1)/2, 0)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://5028857084"
    glow.ImageColor3 = color
    glow.ImageTransparency = transparency
    glow.ScaleType = Enum.ScaleType.Slice
    glow.SliceCenter = Rect.new(10, 10, 90, 90)
    glow.ZIndex = -1
    glow.Parent = parent
    
    return glow
end

local function makeDraggable(frame, handle)
    local dragging = false
    local dragInput, dragStart, startPos
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            -- Efeito de pressão glass
            tween(frame, {BackgroundTransparency = frame.BackgroundTransparency - 0.05}, 0.1)
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                        input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    local function endDrag()
        if dragging then
            dragging = false
            tween(frame, {BackgroundTransparency = frame.BackgroundTransparency + 0.05}, 0.2)
        end
    end
    
    handle.InputEnded:Connect(endDrag)
    UserInputService.InputEnded:Connect(endDrag)
end

local function addRippleEffect(button, color)
    color = color or Color3.new(1, 1, 1)
    
    button.MouseButton1Click:Connect(function()
        local ripple = Instance.new("Frame")
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
        ripple.BackgroundColor3 = color
        ripple.BackgroundTransparency = 0.7
        ripple.BorderSizePixel = 0
        ripple.ZIndex = button.ZIndex + 10
        ripple.Parent = button
        
        createCorner(ripple, 50)
        
        local targetSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2.5
        
        tween(ripple, {
            Size = UDim2.new(0, targetSize, 0, targetSize),
            Position = UDim2.new(0.5, -targetSize/2, 0.5, -targetSize/2),
            BackgroundTransparency = 1
        }, 0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, function()
            ripple:Destroy()
        end)
    end)
end

-- ============================================
-- SISTEMA DE ÍCONE FLUTUANTE (Glass Edition)
-- ============================================

local function createIconButton()
    if iconGui then iconGui:Destroy() end
    
    iconGui = Instance.new("ScreenGui")
    iconGui.Name = "CADU_Icon_Glass"
    iconGui.ResetOnSpawn = false
    iconGui.DisplayOrder = 999999
    iconGui.Parent = playerGui
    
    local iconSize = 70 * CONFIG.scale
    
    -- Frame principal glass
    local iconFrame = Instance.new("Frame")
    iconFrame.Name = "IconFrame"
    iconFrame.Size = UDim2.new(0, iconSize, 0, iconSize)
    iconFrame.Position = UDim2.new(0.5, -iconSize/2, 0.85, 0)
    iconFrame.BackgroundColor3 = CONFIG.bgGlass
    iconFrame.BackgroundTransparency = 0.2
    iconFrame.BorderSizePixel = 0
    iconFrame.Parent = iconGui
    
    createCorner(iconFrame, 24)
    createGlassEffect(iconFrame, 0.25)
    createGlow(iconFrame, CONFIG.primary, 1.4, 0.8)
    createShadow(iconFrame, 0.5, 15)
    
    -- Anel de energia rotativo
    local energyRing = Instance.new("ImageLabel")
    energyRing.Size = UDim2.new(1.3, 0, 1.3, 0)
    energyRing.Position = UDim2.new(-0.15, 0, -0.15, 0)
    energyRing.BackgroundTransparency = 1
    energyRing.Image = "rbxassetid://96755648876012"
    energyRing.ImageColor3 = CONFIG.primary
    energyRing.ImageTransparency = 0.6
    energyRing.ZIndex = -1
    energyRing.Parent = iconFrame
    
    task.spawn(function()
        while energyRing and energyRing.Parent do
            tween(energyRing, {Rotation = energyRing.Rotation + 360}, 12, Enum.EasingStyle.Linear)
            task.wait(12)
        end
    end)
    
    -- Ícone central
    local iconImage = Instance.new("ImageLabel")
    iconImage.Size = UDim2.new(0.55, 0, 0.55, 0)
    iconImage.Position = UDim2.new(0.225, 0, 0.225, 0)
    iconImage.BackgroundTransparency = 1
    iconImage.Image = CONFIG.iconImage
    iconImage.ImageColor3 = CONFIG.textPrimary
    iconImage.ScaleType = Enum.ScaleType.Fit
    iconImage.Parent = iconFrame
    
    -- Botão invisível
    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.Parent = iconFrame
    
    -- Hover effects premium
    clickBtn.MouseEnter:Connect(function()
        tween(iconFrame, {Size = UDim2.new(0, iconSize * 1.1, 0, iconSize * 1.1)}, 0.3, Enum.EasingStyle.Back)
        tween(iconImage, {Rotation = 15}, 0.4, Enum.EasingStyle.Back)
        tween(energyRing, {ImageTransparency = 0.3}, 0.3)
    end)
    
    clickBtn.MouseLeave:Connect(function()
        tween(iconFrame, {Size = UDim2.new(0, iconSize, 0, iconSize)}, 0.3, Enum.EasingStyle.Back)
        tween(iconImage, {Rotation = 0}, 0.4, Enum.EasingStyle.Back)
        tween(energyRing, {ImageTransparency = 0.6}, 0.3)
    end)
    
    clickBtn.MouseButton1Click:Connect(function()
        tween(iconFrame, {Size = UDim2.new(0, 0, 0, 0), Rotation = 360}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.4)
        iconGui:Destroy()
        iconGui = nil
        isMinimized = false
        createMainGUI()
    end)
    
    makeDraggable(iconFrame, clickBtn)
    
    -- Animação de entrada elástica
    iconFrame.Size = UDim2.new(0, 0, 0, 0)
    tween(iconFrame, {Size = UDim2.new(0, iconSize, 0, iconSize)}, 0.6, Enum.EasingStyle.Back)
    
    notify("CADUXX137 Glass", "Clique no ícone para abrir o hub", 3, "premium")
end

-- ============================================
-- INTERFACE PRINCIPAL GLASS
-- ============================================

function createMainGUI()
    pcall(function()
        for _, v in pairs(playerGui:GetChildren()) do
            if v.Name:find("CADU") then v:Destroy() end
        end
    end)
    
    mainGui = Instance.new("ScreenGui")
    mainGui.Name = "CADU_Main_Glass"
    mainGui.ResetOnSpawn = false
    mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    mainGui.Parent = playerGui
    
    local W, H = 420 * CONFIG.scale, 580 * CONFIG.scale
    
    -- Frame principal com glassmorphism
    local main = Instance.new("Frame")
    main.Name = "MainFrame"
    main.Size = UDim2.new(0, W, 0, H)
    main.Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
    main.BackgroundColor3 = CONFIG.bgGlass
    main.BackgroundTransparency = 0.15
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = mainGui
    
    createCorner(main, 28)
    createGlassEffect(main, 0.2)
    createShadow(main, 0.4, 30)
    
    -- Header Glass
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 90 * CONFIG.scale)
    header.BackgroundColor3 = CONFIG.bgElevated
    header.BackgroundTransparency = 0.1
    header.BorderSizePixel = 0
    header.ZIndex = 10
    header.Parent = main
    
    createCorner(header, 28)
    
    -- Gradiente de fundo do header
    local headerGradient = Instance.new("UIGradient")
    headerGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, CONFIG.primary),
        ColorSequenceKeypoint.new(0.5, CONFIG.secondary),
        ColorSequenceKeypoint.new(1, CONFIG.accent)
    })
    headerGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.85),
        NumberSequenceKeypoint.new(0.5, 0.9),
        NumberSequenceKeypoint.new(1, 0.85)
    })
    headerGradient.Rotation = 45
    headerGradient.Parent = header
    
    -- Logo container
    local logoContainer = Instance.new("Frame")
    logoContainer.Size = UDim2.new(0, 60 * CONFIG.scale, 0, 60 * CONFIG.scale)
    logoContainer.Position = UDim2.new(0, 25 * CONFIG.scale, 0, 15 * CONFIG.scale)
    logoContainer.BackgroundColor3 = CONFIG.bgCard
    logoContainer.BackgroundTransparency = 0.3
    logoContainer.BorderSizePixel = 0
    logoContainer.ZIndex = 11
    logoContainer.Parent = header
    
    createCorner(logoContainer, 20)
    
    -- Glow no logo
    createGlow(logoContainer, CONFIG.primary, 1.3, 0.7)
    
    local logoIcon = Instance.new("ImageLabel")
    logoIcon.Size = UDim2.new(0.6, 0, 0.6, 0)
    logoIcon.Position = UDim2.new(0.2, 0, 0.2, 0)
    logoIcon.BackgroundTransparency = 1
    logoIcon.Image = CONFIG.iconImage
    logoIcon.ImageColor3 = CONFIG.textPrimary
    logoIcon.ZIndex = 12
    logoIcon.Parent = logoContainer
    
    -- Títulos
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 200 * CONFIG.scale, 0, 35 * CONFIG.scale)
    title.Position = UDim2.new(0, 100 * CONFIG.scale, 0, 18 * CONFIG.scale)
    title.BackgroundTransparency = 1
    title.Text = "CADUXX137"
    title.TextColor3 = CONFIG.textPrimary
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 26 * CONFIG.scale
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 11
    title.Parent = header
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(0, 200 * CONFIG.scale, 0, 20 * CONFIG.scale)
    subtitle.Position = UDim2.new(0, 102 * CONFIG.scale, 0, 52 * CONFIG.scale)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = CONFIG.version .. " • " .. CONFIG.build
    subtitle.TextColor3 = CONFIG.accent
    subtitle.Font = Enum.Font.GothamBold
    subtitle.TextSize = 12 * CONFIG.scale
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.ZIndex = 11
    subtitle.Parent = header
    
    -- Botões de controle
    local btnSize = UDim2.new(0, 42 * CONFIG.scale, 0, 42 * CONFIG.scale)
    
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "Minimize"
    minimizeBtn.Size = btnSize
    minimizeBtn.Position = UDim2.new(1, -100 * CONFIG.scale, 0, 24 * CONFIG.scale)
    minimizeBtn.BackgroundColor3 = CONFIG.bgCard
    minimizeBtn.BackgroundTransparency = 0.3
    minimizeBtn.Text = "−"
    minimizeBtn.TextColor3 = CONFIG.textPrimary
    minimizeBtn.Font = Enum.Font.GothamBlack
    minimizeBtn.TextSize = 24 * CONFIG.scale
    minimizeBtn.AutoButtonColor = false
    minimizeBtn.ZIndex = 11
    minimizeBtn.Parent = header
    
    createCorner(minimizeBtn, 14)
    addRippleEffect(minimizeBtn, CONFIG.textPrimary)
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "Close"
    closeBtn.Size = btnSize
    closeBtn.Position = UDim2.new(1, -52 * CONFIG.scale, 0, 24 * CONFIG.scale)
    closeBtn.BackgroundColor3 = CONFIG.danger
    closeBtn.BackgroundTransparency = 0.2
    closeBtn.Text = "×"
    closeBtn.TextColor3 = CONFIG.textPrimary
    closeBtn.Font = Enum.Font.GothamBlack
    closeBtn.TextSize = 24 * CONFIG.scale
    closeBtn.AutoButtonColor = false
    closeBtn.ZIndex = 11
    closeBtn.Parent = header
    
    createCorner(closeBtn, 14)
    addRippleEffect(closeBtn, CONFIG.textPrimary)
    
    -- Navegação por Tabs (Estilo WindUI)
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(1, -40 * CONFIG.scale, 0, 55 * CONFIG.scale)
    tabContainer.Position = UDim2.new(0, 20 * CONFIG.scale, 0, 100 * CONFIG.scale)
    tabContainer.BackgroundColor3 = CONFIG.bgCard
    tabContainer.BackgroundTransparency = 0.4
    tabContainer.BorderSizePixel = 0
    tabContainer.ZIndex = 10
    tabContainer.Parent = main
    
    createCorner(tabContainer, 16)
    
    local tabs = {
        {id = "reach", name = "Alcance", icon = "⚡", color = CONFIG.primary},
        {id = "balls", name = "Bolas", icon = "🔮", color = CONFIG.secondary},
        {id = "controls", name = "Controles", icon = "🎮", color = CONFIG.accent},
        {id = "settings", name = "Ajustes", icon = "⚙️", color = CONFIG.textSecondary}
    }
    
    local tabWidth = 1 / #tabs
    local tabButtons = {}
    
    for i, tab in ipairs(tabs) do
        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = tab.id .. "Tab"
        tabBtn.Size = UDim2.new(tabWidth, -8 * CONFIG.scale, 1, -8 * CONFIG.scale)
        tabBtn.Position = UDim2.new((i-1) * tabWidth, 4 * CONFIG.scale, 0, 4 * CONFIG.scale)
        tabBtn.BackgroundColor3 = (tab.id == currentTab) and tab.color or Color3.new(0, 0, 0)
        tabBtn.BackgroundTransparency = (tab.id == currentTab) and 0.2 or 0.9
        tabBtn.Text = tab.icon .. " " .. tab.name
        tabBtn.TextColor3 = (tab.id == currentTab) and CONFIG.textPrimary or CONFIG.textMuted
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.TextSize = 13 * CONFIG.scale
        tabBtn.AutoButtonColor = false
        tabBtn.ZIndex = 11
        tabBtn.Parent = tabContainer
        
        createCorner(tabBtn, 12)
        
        tabButtons[tab.id] = tabBtn
        
        -- Animação de seleção
        tabBtn.MouseButton1Click:Connect(function()
            if currentTab == tab.id then return end
            
            -- Deselecionar anterior
            local prevBtn = tabButtons[currentTab]
            if prevBtn then
                tween(prevBtn, {BackgroundColor3 = Color3.new(0, 0, 0)}, 0.3)
                tween(prevBtn, {BackgroundTransparency = 0.9}, 0.3)
                tween(prevBtn, {TextColor3 = CONFIG.textMuted}, 0.3)
            end
            
            -- Selecionar novo
            currentTab = tab.id
            tween(tabBtn, {BackgroundColor3 = tab.color}, 0.3)
            tween(tabBtn, {BackgroundTransparency = 0.2}, 0.3)
            tween(tabBtn, {TextColor3 = CONFIG.textPrimary}, 0.3)
            
            -- Atualizar conteúdo
            updateContent()
        end)
        
        -- Hover
        if tab.id ~= currentTab then
            tabBtn.MouseEnter:Connect(function()
                tween(tabBtn, {BackgroundTransparency = 0.7}, 0.2)
            end)
            tabBtn.MouseLeave:Connect(function()
                tween(tabBtn, {BackgroundTransparency = 0.9}, 0.2)
            end)
        end
    end
    
    -- Container de conteúdo
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "Content"
    contentContainer.Size = UDim2.new(1, -40 * CONFIG.scale, 1, -175 * CONFIG.scale)
    contentContainer.Position = UDim2.new(0, 20 * CONFIG.scale, 0, 165 * CONFIG.scale)
    contentContainer.BackgroundTransparency = 1
    contentContainer.ClipsDescendants = true
    contentContainer.ZIndex = 5
    contentContainer.Parent = main
    
    -- Função para criar cards glass
    local function createGlassCard(parent, y, height, title, accentColor)
        accentColor = accentColor or CONFIG.primary
        
        local card = Instance.new("Frame")
        card.Name = (title or "Card") .. "_Glass"
        card.Size = UDim2.new(1, 0, 0, height * CONFIG.scale)
        card.Position = UDim2.new(0, 0, 0, y * CONFIG.scale)
        card.BackgroundColor3 = CONFIG.bgCard
        card.BackgroundTransparency = 0.2
        card.BorderSizePixel = 0
        card.Parent = parent
        
        createCorner(card, 20)
        createGlassEffect(card, 0.3)
        createShadow(card, 0.5, 10)
        
        if title then
            -- Indicador de cor
            local indicator = Instance.new("Frame")
            indicator.Size = UDim2.new(0, 4 * CONFIG.scale, 0, 24 * CONFIG.scale)
            indicator.Position = UDim2.new(0, 16 * CONFIG.scale, 0, 18 * CONFIG.scale)
            indicator.BackgroundColor3 = accentColor
            indicator.BorderSizePixel = 0
            indicator.Parent = card
            
            createCorner(indicator, 2)
            
            local titleLabel = Instance.new("TextLabel")
            titleLabel.Size = UDim2.new(1, -40 * CONFIG.scale, 0, 30 * CONFIG.scale)
            titleLabel.Position = UDim2.new(0, 28 * CONFIG.scale, 0, 15 * CONFIG.scale)
            titleLabel.BackgroundTransparency = 1
            titleLabel.Text = title
            titleLabel.TextColor3 = CONFIG.textPrimary
            titleLabel.Font = Enum.Font.GothamBlack
            titleLabel.TextSize = 16 * CONFIG.scale
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
            titleLabel.Parent = card
        end
        
        return card
    end
    
    -- Função para criar toggle moderno
    local function createModernToggle(parent, x, y, state, label, accent)
        accent = accent or CONFIG.success
        
        local container = Instance.new("Frame")
        container.Size = UDim2.new(0, 52 * CONFIG.scale, 0, 28 * CONFIG.scale)
        container.Position = UDim2.new(0, x * CONFIG.scale, 0, y * CONFIG.scale)
        container.BackgroundColor3 = state and accent or CONFIG.bgLight
        container.BackgroundTransparency = state and 0.2 or 0.5
        container.BorderSizePixel = 0
        container.Parent = parent
        
        createCorner(container, 14)
        
        -- Círculo deslizante
        local circle = Instance.new("Frame")
        circle.Size = UDim2.new(0, 22 * CONFIG.scale, 0, 22 * CONFIG.scale)
        circle.Position = state and UDim2.new(1, -25 * CONFIG.scale, 0, 3 * CONFIG.scale) or UDim2.new(0, 3 * CONFIG.scale, 0, 3 * CONFIG.scale)
        circle.BackgroundColor3 = CONFIG.textPrimary
        circle.BorderSizePixel = 0
        circle.Parent = container
        
        createCorner(circle, 11)
        
        -- Label
        local labelText = Instance.new("TextLabel")
        labelText.Size = UDim2.new(0, 200 * CONFIG.scale, 0, 28 * CONFIG.scale)
        labelText.Position = UDim2.new(0, (x + 60) * CONFIG.scale, 0, y * CONFIG.scale)
        labelText.BackgroundTransparency = 1
        labelText.Text = label
        labelText.TextColor3 = CONFIG.textSecondary
        labelText.Font = Enum.Font.GothamBold
        labelText.TextSize = 14 * CONFIG.scale
        labelText.TextXAlignment = Enum.TextXAlignment.Left
        labelText.Parent = parent
        
        local clickArea = Instance.new("TextButton")
        clickArea.Size = UDim2.new(0, 260 * CONFIG.scale, 0, 28 * CONFIG.scale)
        clickArea.Position = UDim2.new(0, x * CONFIG.scale, 0, y * CONFIG.scale)
        clickArea.BackgroundTransparency = 1
        clickArea.Text = ""
        clickArea.Parent = parent
        
        local currentState = state
        
        local function updateVisuals()
            local targetPos = currentState and UDim2.new(1, -25 * CONFIG.scale, 0, 3 * CONFIG.scale) or UDim2.new(0, 3 * CONFIG.scale, 0, 3 * CONFIG.scale)
            local targetColor = currentState and accent or CONFIG.bgLight
            local targetTrans = currentState and 0.2 or 0.5
            
            tween(circle, {Position = targetPos}, 0.3, Enum.EasingStyle.Back)
            tween(container, {BackgroundColor3 = targetColor}, 0.3)
            tween(container, {BackgroundTransparency = targetTrans}, 0.3)
        end
        
        clickArea.MouseButton1Click:Connect(function()
            currentState = not currentState
            updateVisuals()
            return currentState
        end)
        
        return {
            getState = function() return currentState end,
            setState = function(newState)
                currentState = newState
                updateVisuals()
            end,
            container = container
        }
    end
    
    -- Função para criar slider premium
    local function createPremiumSlider(parent, x, y, min, max, current, label, accent)
        accent = accent or CONFIG.primary
        
        local width = 220 * CONFIG.scale
        
        local container = Instance.new("Frame")
        container.Size = UDim2.new(0, width, 0, 50 * CONFIG.scale)
        container.Position = UDim2.new(0, x * CONFIG.scale, 0, y * CONFIG.scale)
        container.BackgroundTransparency = 1
        container.Parent = parent
        
        -- Label
        local labelText = Instance.new("TextLabel")
        labelText.Size = UDim2.new(1, 0, 0, 20 * CONFIG.scale)
        labelText.BackgroundTransparency = 1
        labelText.Text = label
        labelText.TextColor3 = CONFIG.textMuted
        labelText.Font = Enum.Font.GothamBold
        labelText.TextSize = 12 * CONFIG.scale
        labelText.TextXAlignment = Enum.TextXAlignment.Left
        labelText.Parent = container
        
        -- Valor
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0, 50 * CONFIG.scale, 0, 20 * CONFIG.scale)
        valueLabel.Position = UDim2.new(1, -50 * CONFIG.scale, 0, 0)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = tostring(current)
        valueLabel.TextColor3 = accent
        valueLabel.Font = Enum.Font.GothamBlack
        valueLabel.TextSize = 14 * CONFIG.scale
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.Parent = container
        
        -- Track
        local track = Instance.new("Frame")
        track.Size = UDim2.new(1, 0, 0, 6 * CONFIG.scale)
        track.Position = UDim2.new(0, 0, 0, 30 * CONFIG.scale)
        track.BackgroundColor3 = CONFIG.bgLight
        track.BackgroundTransparency = 0.5
        track.BorderSizePixel = 0
        track.Parent = container
        
        createCorner(track, 3)
        
        -- Fill com gradiente
        local percent = (current - min) / (max - min)
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(percent, 0, 1, 0)
        fill.BackgroundColor3 = accent
        fill.BackgroundTransparency = 0.1
        fill.BorderSizePixel = 0
        fill.Parent = track
        
        createCorner(fill, 3)
        
        local fillGradient = Instance.new("UIGradient")
        fillGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, accent),
            ColorSequenceKeypoint.new(1, CONFIG.secondary)
        })
        fillGradient.Parent = fill
        
        -- Knob com glow
        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 18 * CONFIG.scale, 0, 18 * CONFIG.scale)
        knob.Position = UDim2.new(percent, -9 * CONFIG.scale, 0.5, -9 * CONFIG.scale)
        knob.BackgroundColor3 = CONFIG.textPrimary
        knob.BorderSizePixel = 0
        knob.ZIndex = 2
        knob.Parent = track
        
        createCorner(knob, 9)
        
        local knobGlow = createGlow(knob, accent, 1.5, 0.6)
        knobGlow.ZIndex = 1
        
        -- Interação
        local dragging = false
        
        local function updateSlider(input)
            local relativeX = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (max - min) * relativeX)
            
            tween(fill, {Size = UDim2.new(relativeX, 0, 1, 0)}, 0.1)
            tween(knob, {Position = UDim2.new(relativeX, -9 * CONFIG.scale, 0.5, -9 * CONFIG.scale)}, 0.1)
            valueLabel.Text = tostring(value)
            
            return value
        end
        
        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                local val = updateSlider(input)
                current = val
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local val = updateSlider(input)
                current = val
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        
        return {
            getValue = function() return current end,
            setValue = function(val)
                current = math.clamp(val, min, max)
                local relativeX = (current - min) / (max - min)
                tween(fill, {Size = UDim2.new(relativeX, 0, 1, 0)}, 0.2)
                tween(knob, {Position = UDim2.new(relativeX, -9 * CONFIG.scale, 0.5, -9 * CONFIG.scale)}, 0.2)
                valueLabel.Text = tostring(current)
            end
        }
    end
    
    -- Variáveis para armazenar referências
    local reachSlider, sphereToggle, autoToggle, bodyToggle, secondToggle
    
    -- Função de atualização de conteúdo
    function updateContent()
        -- Limpar conteúdo anterior
        for _, child in ipairs(contentContainer:GetChildren()) do
            tween(child, {Position = UDim2.new(-0.2, 0, child.Position.Y.Scale, child.Position.Y.Offset)}, 0.2)
            task.delay(0.2, function() child:Destroy() end)
        end
        
        task.delay(0.25, function()
            if currentTab == "reach" then
                -- Card de alcance
                local reachCard = createGlassCard(contentContainer, 0, 180, "⚡ Alcance de Toque", CONFIG.primary)
                
                -- Display grande do valor
                local reachValue = Instance.new("TextLabel")
                reachValue.Name = "ReachValue"
                reachValue.Size = UDim2.new(0.4, 0, 0, 60 * CONFIG.scale)
                reachValue.Position = UDim2.new(0.6, 0, 0, 50 * CONFIG.scale)
                reachValue.BackgroundTransparency = 1
                reachValue.Text = tostring(CONFIG.reach)
                reachValue.TextColor3 = CONFIG.primary
                reachValue.Font = Enum.Font.GothamBlack
                reachValue.TextSize = 48 * CONFIG.scale
                reachValue.TextXAlignment = Enum.TextXAlignment.Right
                reachValue.Parent = reachCard
                
                local reachUnit = Instance.new("TextLabel")
                reachUnit.Size = UDim2.new(0.15, 0, 0, 20 * CONFIG.scale)
                reachUnit.Position = UDim2.new(0.85, 0, 0, 75 * CONFIG.scale)
                reachUnit.BackgroundTransparency = 1
                reachUnit.Text = "studs"
                reachUnit.TextColor3 = CONFIG.textMuted
                reachUnit.Font = Enum.Font.Gotham
                reachUnit.TextSize = 12 * CONFIG.scale
                reachUnit.Parent = reachCard
                
                -- Slider premium
                reachSlider = createPremiumSlider(reachCard, 20, 110, 1, 50, CONFIG.reach, "Distância de Interação", CONFIG.primary)
                
                -- Botões rápidos
                local quickBtns = {"−", "+", "MAX"}
                for i, btnText in ipairs(quickBtns) do
                    local btn = Instance.new("TextButton")
                    btn.Size = UDim2.new(0, 45 * CONFIG.scale, 0, 40 * CONFIG.scale)
                    btn.Position = UDim2.new(0, 20 + (i-1) * 55 * CONFIG.scale, 0, 55 * CONFIG.scale)
                    btn.BackgroundColor3 = CONFIG.bgElevated
                    btn.BackgroundTransparency = 0.3
                    btn.Text = btnText
                    btn.TextColor3 = CONFIG.textPrimary
                    btn.Font = Enum.Font.GothamBlack
                    btn.TextSize = 20 * CONFIG.scale
                    btn.AutoButtonColor = false
                    btn.Parent = reachCard
                    
                    createCorner(btn, 12)
                    addRippleEffect(btn, CONFIG.textPrimary)
                    
                    btn.MouseButton1Click:Connect(function()
                        if btnText == "−" then
                            CONFIG.reach = math.max(1, CONFIG.reach - 1)
                        elseif btnText == "+" then
                            CONFIG.reach = math.min(50, CONFIG.reach + 1)
                        elseif btnText == "MAX" then
                            CONFIG.reach = 50
                        end
                        reachSlider.setValue(CONFIG.reach)
                        reachValue.Text = tostring(CONFIG.reach)
                    end)
                end
                
                -- Card de visualização
                local visualCard = createGlassCard(contentContainer, 190, 100, "👁️ Visualização", CONFIG.secondary)
                sphereToggle = createModernToggle(visualCard, 20, 50, CONFIG.showReachSphere, "Mostrar Esfera de Alcance", CONFIG.secondary)
                
            elseif currentTab == "balls" then
                -- Card de detecção
                local detectCard = createGlassCard(contentContainer, 0, 120, "🔮 Detecção de Bolas", CONFIG.secondary)
                
                local scanBtn = Instance.new("TextButton")
                scanBtn.Size = UDim2.new(0, 180 * CONFIG.scale, 0, 45 * CONFIG.scale)
                scanBtn.Position = UDim2.new(0.5, -90 * CONFIG.scale, 0, 50 * CONFIG.scale)
                scanBtn.BackgroundColor3 = CONFIG.secondary
                scanBtn.BackgroundTransparency = 0.2
                scanBtn.Text = "⟳ ESCANEAR AGORA"
                scanBtn.TextColor3 = CONFIG.textPrimary
                scanBtn.Font = Enum.Font.GothamBlack
                scanBtn.TextSize = 14 * CONFIG.scale
                scanBtn.AutoButtonColor = false
                scanBtn.Parent = detectCard
                
                createCorner(scanBtn, 14)
                addRippleEffect(scanBtn, CONFIG.textPrimary)
                
                local countLabel = Instance.new("TextLabel")
                countLabel.Size = UDim2.new(1, 0, 0, 30 * CONFIG.scale)
                countLabel.Position = UDim2.new(0, 0, 0, 100 * CONFIG.scale)
                countLabel.BackgroundTransparency = 1
                countLabel.Text = #balls .. " bolas ativas"
                countLabel.TextColor3 = #balls > 0 and CONFIG.success or CONFIG.textMuted
                countLabel.Font = Enum.Font.GothamBold
                countLabel.TextSize = 14 * CONFIG.scale
                countLabel.Parent = detectCard
                
                scanBtn.MouseButton1Click:Connect(function()
                    findBalls()
                    countLabel.Text = #balls .. " bolas detectadas"
                    countLabel.TextColor3 = #balls > 0 and CONFIG.success or CONFIG.warning
                    tween(scanBtn, {Rotation = 360}, 0.5, Enum.EasingStyle.Back)
                    scanBtn.Rotation = 0
                end)
                
                -- Lista de bolas
                local listCard = createGlassCard(contentContainer, 130, 250, "📋 Bolas Encontradas", CONFIG.accent)
                
                local scrollFrame = Instance.new("ScrollingFrame")
                scrollFrame.Size = UDim2.new(1, -30 * CONFIG.scale, 0, 190 * CONFIG.scale)
                scrollFrame.Position = UDim2.new(0, 15 * CONFIG.scale, 0, 45 * CONFIG.scale)
                scrollFrame.BackgroundColor3 = CONFIG.bgDark
                scrollFrame.BackgroundTransparency = 0.5
                scrollFrame.BorderSizePixel = 0
                scrollFrame.ScrollBarThickness = 4
                scrollBarThickness = 4
                scrollFrame.ScrollBarImageColor3 = CONFIG.accent
                scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
                scrollFrame.Parent = listCard
                
                createCorner(scrollFrame, 12)
                
                -- Popular lista
                local yOffset = 10
                local uniqueBalls = {}
                for _, ball in ipairs(balls) do
                    if ball and ball.Parent then
                        uniqueBalls[ball.Name] = (uniqueBalls[ball.Name] or 0) + 1
                    end
                end
                
                for name, count in pairs(uniqueBalls) do
                    local item = Instance.new("Frame")
                    item.Size = UDim2.new(1, -20 * CONFIG.scale, 0, 35 * CONFIG.scale)
                    item.Position = UDim2.new(0, 10 * CONFIG.scale, 0, yOffset)
                    item.BackgroundColor3 = CONFIG.bgCard
                    item.BackgroundTransparency = 0.5
                    item.BorderSizePixel = 0
                    item.Parent = scrollFrame
                    
                    createCorner(item, 8)
                    
                    local nameLbl = Instance.new("TextLabel")
                    nameLbl.Size = UDim2.new(0.7, 0, 1, 0)
                    nameLbl.Position = UDim2.new(0, 10 * CONFIG.scale, 0, 0)
                    nameLbl.BackgroundTransparency = 1
                    nameLbl.Text = name
                    nameLbl.TextColor3 = CONFIG.accent
                    nameLbl.Font = Enum.Font.GothamBold
                    nameLbl.TextSize = 12 * CONFIG.scale
                    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
                    nameLbl.Parent = item
                    
                    local countLbl = Instance.new("TextLabel")
                    countLbl.Size = UDim2.new(0.3, -10 * CONFIG.scale, 1, 0)
                    countLbl.Position = UDim2.new(0.7, 0, 0, 0)
                    countLbl.BackgroundTransparency = 1
                    countLbl.Text = "x" .. count
                    countLbl.TextColor3 = CONFIG.textMuted
                    countLbl.Font = Enum.Font.GothamBold
                    countLbl.TextSize = 12 * CONFIG.scale
                    countLbl.TextXAlignment = Enum.TextXAlignment.Right
                    countLbl.Parent = item
                    
                    yOffset = yOffset + 40
                end
                
                scrollFrame.CanvasSize = UDim2.new(0, 0, 0, math.max(yOffset, 190))
                
            elseif currentTab == "controls" then
                -- Card de auto-touch
                local autoCard = createGlassCard(contentContainer, 0, 140, "🤖 Automação", CONFIG.success)
                autoToggle = createModernToggle(autoCard, 20, 50, CONFIG.autoTouch, "Auto Touch Automático", CONFIG.success)
                bodyToggle = createModernToggle(autoCard, 20, 90, CONFIG.fullBodyTouch, "Full Body Touch", CONFIG.success)
                secondToggle = createModernToggle(autoCard, 20, 130, CONFIG.autoSecondTouch, "Double Touch (2x)", CONFIG.success)
                
                -- Card de skills
                local skillsCard = createGlassCard(contentContainer, 150, 100, "⚡ Auto Skills", CONFIG.warning)
                local skillsToggle = createModernToggle(skillsCard, 20, 50, autoSkills, "Ativar Skills Automáticas", CONFIG.warning)
                
                skillsToggle.container.MouseButton1Click:Connect(function()
                    autoSkills = skillsToggle.getState()
                end)
                
            elseif currentTab == "settings" then
                -- Card de escala
                local scaleCard = createGlassCard(contentContainer, 0, 120, "📐 Escala da Interface", CONFIG.textSecondary)
                local scaleSlider = createPremiumSlider(scaleCard, 20, 50, 0.5, 1.5, CONFIG.scale, "Tamanho do Hub", CONFIG.textSecondary)
                
                local applyBtn = Instance.new("TextButton")
                applyBtn.Size = UDim2.new(0, 150 * CONFIG.scale, 0, 40 * CONFIG.scale)
                applyBtn.Position = UDim2.new(0.5, -75 * CONFIG.scale, 0, 70 * CONFIG.scale)
                applyBtn.BackgroundColor3 = CONFIG.success
                applyBtn.BackgroundTransparency = 0.2
                applyBtn.Text = "APLICAR ESCALA"
                applyBtn.TextColor3 = CONFIG.textPrimary
                applyBtn.Font = Enum.Font.GothamBlack
                applyBtn.TextSize = 14 * CONFIG.scale
                applyBtn.AutoButtonColor = false
                applyBtn.Parent = scaleCard
                
                createCorner(applyBtn, 12)
                addRippleEffect(applyBtn, CONFIG.textPrimary)
                
                applyBtn.MouseButton1Click:Connect(function()
                    CONFIG.scale = scaleSlider.getValue()
                    notify("CADUXX137", "Reiniciando com nova escala...", 2, "warning")
                    task.delay(0.5, function()
                        createMainGUI()
                    end)
                end)
                
                -- Card de reset
                local resetCard = createGlassCard(contentContainer, 130, 100, "🔄 Resetar", CONFIG.danger)
                local resetBtn = Instance.new("TextButton")
                resetBtn.Size = UDim2.new(0, 160 * CONFIG.scale, 0, 45 * CONFIG.scale)
                resetBtn.Position = UDim2.new(0.5, -80 * CONFIG.scale, 0, 45 * CONFIG.scale)
                resetBtn.BackgroundColor3 = CONFIG.danger
                resetBtn.BackgroundTransparency = 0.2
                resetBtn.Text = "RESETAR TUDO"
                resetBtn.TextColor3 = CONFIG.textPrimary
                resetBtn.Font = Enum.Font.GothamBlack
                resetBtn.TextSize = 14 * CONFIG.scale
                resetBtn.AutoButtonColor = false
                resetBtn.Parent = resetCard
                
                createCorner(resetBtn, 12)
                addRippleEffect(resetBtn, CONFIG.textPrimary)
                
                resetBtn.MouseButton1Click:Connect(function()
                    CONFIG.reach = 15
                    CONFIG.showReachSphere = true
                    CONFIG.autoTouch = true
                    CONFIG.fullBodyTouch = true
                    CONFIG.autoSecondTouch = true
                    CONFIG.scale = 1.0
                    notify("CADUXX137", "Configurações resetadas!", 2, "warning")
                    createMainGUI()
                end)
            end
            
            -- Animação de entrada
            for _, child in ipairs(contentContainer:GetChildren()) do
                child.Position = UDim2.new(0.2, 0, child.Position.Y.Scale, child.Position.Y.Offset)
                child.BackgroundTransparency = 1
                tween(child, {Position = UDim2.new(0, 0, child.Position.Y.Scale, child.Position.Y.Offset)}, 0.3, Enum.EasingStyle.Quint)
                tween(child, {BackgroundTransparency = 0.2}, 0.3)
            end
        end)
    end
    
    -- Eventos dos botões principais
    minimizeBtn.MouseButton1Click:Connect(function()
        tween(main, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.4)
        mainGui:Destroy()
        mainGui = nil
        isMinimized = true
        createIconButton()
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        tween(main, {Size = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.3)
        mainGui:Destroy()
        if reachSphere then reachSphere:Destroy() end
        for _, conn in ipairs(ballConnections) do
            pcall(function() conn:Disconnect() end)
        end
    end)
    
    -- Draggable
    makeDraggable(main, header)
    
    -- Animação de entrada
    main.Size = UDim2.new(0, 0, 0, 0)
    tween(main, {Size = UDim2.new(0, W, 0, H)}, 0.6, Enum.EasingStyle.Back)
    
    -- Inicializar conteúdo
    updateContent()
    
    notify("CADUXX137 Glass", "Hub inicializado com sucesso!", 3, "premium")
end

-- ============================================
-- SISTEMA DE FUNCIONALIDADES (Mantido da sua lógica)
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
    
    return #balls
end

local function updateCharacter()
    local newChar = player.Character
    if newChar ~= char then
        char = newChar
        if char then
            HRP = char:WaitForChild("HumanoidRootPart", 2)
            if HRP then
                notify("CADUXX137", "Personagem conectado!", 2, "success")
            end
        else
            HRP = nil
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
        reachSphere.Name = "CADU_ReachSphere"
        reachSphere.Shape = Enum.PartType.Ball
        reachSphere.Anchored = true
        reachSphere.CanCollide = false
        reachSphere.Transparency = 0.9
        reachSphere.Material = Enum.Material.ForceField
        reachSphere.Color = CONFIG.primary
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
    if touchDebounce[key] and tick() - touchDebounce[key] < 0.1 then return end
    touchDebounce[key] = tick()
    
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
        end
    end)
end

-- ============================================
-- LOOPS PRINCIPAIS
-- ============================================

RunService.Heartbeat:Connect(function()
    updateCharacter()
    updateSphere()
    findBalls()
    
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
            if button.Name == "Shoot" or button.Name == "Pass" or button.Name == "Dribble" then
                activateSkillButton(button)
            end
        end
    end
end)

-- ============================================
-- INICIALIZAÇÃO
-- ============================================

createMainGUI()
