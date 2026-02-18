-- ==========================================
-- NETFLIX x SPOTIFY HUB - PREMIUM UI
-- ==========================================

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- ==========================================
-- CONFIGURAÇÃO DE CORES (Netflix + Spotify)
-- ==========================================
local THEME = {
    -- Backgrounds
    bgPrimary = Color3.fromRGB(20, 20, 25),      -- Preto azulado Netflix
    bgSecondary = Color3.fromRGB(30, 30, 40),    -- Cinza escuro
    bgCard = Color3.fromRGB(40, 40, 55),         -- Cards
    bgHover = Color3.fromRGB(55, 55, 75),        -- Hover state
    
    -- Cores de Destaque (Spotify Green + Netflix Red)
    accentPrimary = Color3.fromRGB(29, 185, 84),   -- Spotify Green
    accentSecondary = Color3.fromRGB(229, 9, 20),  -- Netflix Red
    accentPurple = Color3.fromRGB(155, 89, 182),   -- Roxo moderno
    accentCyan = Color3.fromRGB(0, 255, 255),      -- Cyan neon
    
    -- Textos
    textPrimary = Color3.fromRGB(255, 255, 255),
    textSecondary = Color3.fromRGB(179, 179, 179),
    textMuted = Color3.fromRGB(120, 120, 140),
    
    -- Estados
    success = Color3.fromRGB(29, 185, 84),
    warning = Color3.fromRGB(255, 193, 7),
    danger = Color3.fromRGB(229, 9, 20),
    info = Color3.fromRGB(33, 150, 243),
    
    -- Gradientes
    gradientStart = Color3.fromRGB(229, 9, 20),    -- Netflix Red
    gradientEnd = Color3.fromRGB(29, 185, 84),     -- Spotify Green
    
    -- Transparências
    glass = 0.15,
    card = 0.08
}

-- ==========================================
-- CONFIGURAÇÃO DO HACK
-- ==========================================
local CONFIG = {
    playerReach = 10,
    ballReach = 15,
    autoTouch = true,
    showVisuals = true,
    flashEnabled = false,
    antiAFK = true,
    quantumReachEnabled = false,
    quantumReach = 10,
    expandBallHitbox = true,
    ballNames = { "TPS", "MPS", "TRS", "TCS", "PRS", "ESA", "MRS", "SSS", "AIFA", "RBZ", "SoccerBall", "Football", "Ball" },
    
    stealth = {
        bigFootSize = 8,
        touchRate = 0,
        useSpoof = true,
        randomOffset = true,
        bypassAC = true
    }
}

-- ==========================================
-- VARIÁVEIS GLOBAIS
-- ==========================================
local balls = {}
local ballAuras = {}
local ballHitboxes = {}
local playerSphere = nil
local quantumCircle = nil
local bigFoot = nil
local spoofPart = nil
local HRP = nil
local character = nil
local lastTouch = 0
local isScriptActive = false
local connections = {}
local BALL_NAME_SET = {}

-- Inicializa set de bolas
for _, n in ipairs(CONFIG.ballNames) do
    BALL_NAME_SET[n] = true
end

-- ==========================================
-- SISTEMA DE PROTEÇÃO ANTI-NIL
-- ==========================================
local function safeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("[SafeCall Error]: " .. tostring(result))
    end
    return success, result
end

local function safeDestroy(obj)
    if obj and obj.Parent then
        safeCall(function() obj:Destroy() end)
    end
end

local function getCharacter()
    return player and player.Character
end

local function getHRP()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- ==========================================
-- SISTEMA BIGFOOT (CORRIGIDO)
-- ==========================================
local function createStealthBigFoot()
    local char = getCharacter()
    if not char then return nil end
    
    safeDestroy(bigFoot)
    safeDestroy(spoofPart)
    
    local rightLeg = char:FindFirstChild("Right Leg") or 
                     char:FindFirstChild("RightLowerLeg") or
                     char:FindFirstChild("RightFoot") or
                     char:FindFirstChild("RightUpperLeg")
    
    if not rightLeg then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and (part.Name:lower():match("leg") or part.Name:lower():match("foot")) then
                rightLeg = part
                break
            end
        end
    end
    
    if not rightLeg then
        rightLeg = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart")
    end
    
    if not rightLeg then return nil end
    
    local success = safeCall(function()
        bigFoot = Instance.new("Part")
        bigFoot.Name = "HumanoidRootPart_BigFoot"
        bigFoot.Shape = Enum.PartType.Ball
        bigFoot.Size = Vector3.new(CONFIG.stealth.bigFootSize, CONFIG.stealth.bigFootSize, CONFIG.stealth.bigFootSize)
        bigFoot.Transparency = 1
        bigFoot.CanCollide = false
        bigFoot.CanQuery = false
        bigFoot.CanTouch = true
        bigFoot.Parent = char
        
        if CONFIG.stealth.useSpoof then
            spoofPart = Instance.new("Part")
            spoofPart.Name = "LegSpoof"
            spoofPart.Size = rightLeg.Size
            spoofPart.Transparency = 1
            spoofPart.CanCollide = false
            spoofPart.Parent = Workspace
        end
        
        table.insert(connections, RunService.Heartbeat:Connect(function()
            if not bigFoot or not bigFoot.Parent then return end
            if not rightLeg or not rightLeg.Parent then return end
            
            local offset = CFrame.new(0, -rightLeg.Size.Y/2 - 0.5, 0)
            if CONFIG.stealth.randomOffset then
                offset = offset + CFrame.new(
                    math.random(-10, 10)/100,
                    math.random(-10, 10)/100,
                    math.random(-10, 10)/100
                )
            end
            
            bigFoot.CFrame = rightLeg.CFrame * offset
            
            if spoofPart then
                spoofPart.CFrame = rightLeg.CFrame
                spoofPart.Velocity = rightLeg.Velocity or Vector3.new()
            end
        end))
    end)
    
    return success and bigFoot or nil
end

local function stealthTouch(ball)
    if not ball or not bigFoot or not bigFoot.Parent then return end
    
    local now = tick()
    if now - lastTouch < CONFIG.stealth.touchRate then return end
    lastTouch = now
    
    safeCall(function()
        firetouchinterest(ball, bigFoot, 0)
        task.wait()
        firetouchinterest(ball, bigFoot, 1)
    end)
    
    if CONFIG.stealth.bypassAC then
        local originalCF = bigFoot.CFrame
        safeCall(function()
            bigFoot.CFrame = ball.CFrame
            task.wait()
            firetouchinterest(ball, bigFoot, 0)
            firetouchinterest(ball, bigFoot, 1)
        end)
        bigFoot.CFrame = originalCF
    end
end

-- ==========================================
-- SISTEMA DE BOLAS
-- ==========================================
local function getBalls()
    table.clear(balls)
    if not Workspace then return balls end
    
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v and v:IsA("BasePart") and BALL_NAME_SET[v.Name] then
            table.insert(balls, v)
        end
    end
    return balls
end

local function createBallHitbox(ball)
    if not ball or not ball.Parent or ballHitboxes[ball] then return end
    
    safeCall(function()
        local hitbox = Instance.new("Part")
        hitbox.Name = "Hitbox_" .. ball.Name
        hitbox.Shape = Enum.PartType.Ball
        hitbox.Size = Vector3.new(CONFIG.ballReach * 2, CONFIG.ballReach * 2, CONFIG.ballReach * 2)
        hitbox.Transparency = 1
        hitbox.Anchored = true
        hitbox.CanCollide = false
        hitbox.Parent = Workspace
        
        local conn = RunService.Heartbeat:Connect(function()
            if ball and ball.Parent and hitbox and hitbox.Parent then
                hitbox.CFrame = ball.CFrame
            else
                safeDestroy(hitbox)
            end
        end)
        table.insert(connections, conn)
        
        ballHitboxes[ball] = {hitbox = hitbox, conn = conn}
    end)
end

local function createBallAura(ball)
    if not ball or not ball.Parent or ballAuras[ball] or not CONFIG.showVisuals then return end
    
    safeCall(function()
        local aura = Instance.new("Part")
        aura.Name = "Aura_" .. ball.Name
        aura.Shape = Enum.PartType.Ball
        aura.Size = Vector3.new(CONFIG.ballReach * 2, CONFIG.ballReach * 2, CONFIG.ballReach * 2)
        aura.Transparency = 0.85
        aura.Anchored = true
        aura.CanCollide = false
        aura.Material = Enum.Material.ForceField
        aura.Color = ball.Name == "TPS" and THEME.accentCyan or THEME.accentSecondary
        aura.Parent = Workspace
        
        local highlight = Instance.new("Highlight")
        highlight.Adornee = ball
        highlight.FillColor = aura.Color
        highlight.OutlineColor = Color3.new(1, 1, 1)
        highlight.FillTransparency = 0.7
        highlight.Parent = ball
        
        local conn = RunService.RenderStepped:Connect(function()
            if ball and ball.Parent and aura and aura.Parent then
                aura.CFrame = ball.CFrame
            else
                safeDestroy(aura)
                safeDestroy(highlight)
            end
        end)
        table.insert(connections, conn)
        
        ballAuras[ball] = {aura = aura, highlight = highlight, conn = conn}
    end)
end

-- ==========================================
-- CRIAÇÃO DA INTERFACE NETFLIX x SPOTIFY
-- ==========================================
local function createPremiumHub()
    -- ScreenGui principal
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PremiumHub_" .. HttpService:GenerateGUID(false)
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = CoreGui
    
    -- Frame principal com blur/glass effect
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 900, 0, 600)
    mainFrame.Position = UDim2.new(0.5, -450, 0.5, -300)
    mainFrame.BackgroundColor3 = THEME.bgPrimary
    mainFrame.BackgroundTransparency = 0.05
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    
    -- Cantos arredondados
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    -- Sombra premium
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.Size = UDim2.new(1, 60, 1, 60)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://6015897843"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.3
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.ZIndex = -1
    shadow.Parent = mainFrame
    
    -- Gradiente de fundo sutil
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, THEME.bgPrimary),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(25, 25, 35)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 30))
    })
    gradient.Rotation = 45
    gradient.Parent = mainFrame
    
    -- ==========================================
    -- HEADER (Estilo Netflix)
    -- ==========================================
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 70)
    header.BackgroundColor3 = THEME.bgSecondary
    header.BackgroundTransparency = 0.5
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 0)
    headerCorner.Parent = header
    
    -- Logo/Texto
    local logo = Instance.new("TextLabel")
    logo.Name = "Logo"
    logo.Size = UDim2.new(0, 300, 1, 0)
    logo.Position = UDim2.new(0, 20, 0, 0)
    logo.BackgroundTransparency = 1
    logo.Text = "PREMIUM HUB"
    logo.TextColor3 = THEME.textPrimary
    logo.TextSize = 28
    logo.Font = Enum.Font.GothamBold
    logo.TextXAlignment = Enum.TextXAlignment.Left
    logo.Parent = header
    
    -- Gradiente no texto do logo
    local logoGradient = Instance.new("UIGradient")
    logoGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, THEME.accentSecondary),
        ColorSequenceKeypoint.new(0.5, THEME.accentPrimary),
        ColorSequenceKeypoint.new(1, THEME.accentPurple)
    })
    logoGradient.Parent = logo
    
    -- Versão
    local version = Instance.new("TextLabel")
    version.Name = "Version"
    version.Size = UDim2.new(0, 100, 0, 20)
    version.Position = UDim2.new(0, 25, 0, 45)
    version.BackgroundTransparency = 1
    version.Text = "v2.0 PRO"
    version.TextColor3 = THEME.accentPrimary
    version.TextSize = 12
    version.Font = Enum.Font.GothamSemibold
    version.TextXAlignment = Enum.TextXAlignment.Left
    version.Parent = header
    
    -- Botão fechar (X)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.new(0, 40, 0, 40)
    closeBtn.Position = UDim2.new(1, -50, 0.5, -20)
    closeBtn.BackgroundColor3 = THEME.danger
    closeBtn.BackgroundTransparency = 0.8
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = THEME.textPrimary
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = header
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn
    
    -- Minimizar
    local minBtn = Instance.new("TextButton")
    minBtn.Name = "MinBtn"
    minBtn.Size = UDim2.new(0, 40, 0, 40)
    minBtn.Position = UDim2.new(1, -95, 0.5, -20)
    minBtn.BackgroundColor3 = THEME.bgHover
    minBtn.BackgroundTransparency = 0.5
    minBtn.Text = "−"
    minBtn.TextColor3 = THEME.textPrimary
    minBtn.TextSize = 24
    minBtn.Font = Enum.Font.GothamBold
    minBtn.Parent = header
    
    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 8)
    minCorner.Parent = minBtn
    
    -- ==========================================
    -- SIDEBAR (Estilo Spotify)
    -- ==========================================
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 220, 1, -70)
    sidebar.Position = UDim2.new(0, 0, 0, 70)
    sidebar.BackgroundColor3 = THEME.bgSecondary
    sidebar.BackgroundTransparency = 0.3
    sidebar.BorderSizePixel = 0
    sidebar.Parent = mainFrame
    
    local sidebarCorner = Instance.new("UICorner")
    sidebarCorner.CornerRadius = UDim.new(0, 0)
    sidebarCorner.Parent = sidebar
    
    -- Perfil do usuário
    local profileFrame = Instance.new("Frame")
    profileFrame.Name = "Profile"
    profileFrame.Size = UDim2.new(1, -20, 0, 80)
    profileFrame.Position = UDim2.new(0, 10, 0, 10)
    profileFrame.BackgroundColor3 = THEME.bgCard
    profileFrame.BackgroundTransparency = 0.5
    profileFrame.Parent = sidebar
    
    local profileCorner = Instance.new("UICorner")
    profileCorner.CornerRadius = UDim.new(0, 10)
    profileCorner.Parent = profileFrame
    
    local avatar = Instance.new("Frame")
    avatar.Name = "Avatar"
    avatar.Size = UDim2.new(0, 50, 0, 50)
    avatar.Position = UDim2.new(0, 15, 0.5, -25)
    avatar.BackgroundColor3 = THEME.accentPrimary
    avatar.Parent = profileFrame
    
    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(1, 0)
    avatarCorner.Parent = avatar
    
    local avatarIcon = Instance.new("TextLabel")
    avatarIcon.Size = UDim2.new(1, 0, 1, 0)
    avatarIcon.BackgroundTransparency = 1
    avatarIcon.Text = "👤"
    avatarIcon.TextSize = 24
    avatarIcon.Parent = avatar
    
    local username = Instance.new("TextLabel")
    username.Name = "Username"
    username.Size = UDim2.new(1, -80, 0, 25)
    username.Position = UDim2.new(0, 75, 0, 15)
    username.BackgroundTransparency = 1
    username.Text = player and player.Name or "Guest"
    username.TextColor3 = THEME.textPrimary
    username.TextSize = 16
    username.Font = Enum.Font.GothamBold
    username.TextXAlignment = Enum.TextXAlignment.Left
    username.Parent = profileFrame
    
    local status = Instance.new("TextLabel")
    status.Name = "Status"
    status.Size = UDim2.new(1, -80, 0, 20)
    status.Position = UDim2.new(0, 75, 0, 40)
    status.BackgroundTransparency = 1
    status.Text = "● Online"
    status.TextColor3 = THEME.success
    status.TextSize = 12
    status.Font = Enum.Font.Gotham
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Parent = profileFrame
    
    -- Container de abas
    local tabContainer = Instance.new("ScrollingFrame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(1, -20, 1, -100)
    tabContainer.Position = UDim2.new(0, 10, 0, 100)
    tabContainer.BackgroundTransparency = 1
    tabContainer.ScrollBarThickness = 4
    tabContainer.ScrollBarImageColor3 = THEME.accentPrimary
    tabContainer.Parent = sidebar
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, 8)
    tabLayout.Parent = tabContainer
    
    -- Função criar botão de aba
    local function createTabButton(name, icon, isActive)
        local btn = Instance.new("TextButton")
        btn.Name = name .. "Tab"
        btn.Size = UDim2.new(1, 0, 0, 45)
        btn.BackgroundColor3 = isActive and THEME.accentPrimary or THEME.bgCard
        btn.BackgroundTransparency = isActive and 0.2 or 0.5
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.Parent = tabContainer
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn
        
        local iconLabel = Instance.new("TextLabel")
        iconLabel.Size = UDim2.new(0, 30, 1, 0)
        iconLabel.Position = UDim2.new(0, 12, 0, 0)
        iconLabel.BackgroundTransparency = 1
        iconLabel.Text = icon
        iconLabel.TextSize = 18
        iconLabel.Parent = btn
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, -50, 1, 0)
        textLabel.Position = UDim2.new(0, 45, 0, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = name
        textLabel.TextColor3 = isActive and THEME.textPrimary or THEME.textSecondary
        textLabel.TextSize = 14
        textLabel.Font = Enum.Font.GothamSemibold
        textLabel.TextXAlignment = Enum.TextXAlignment.Left
        textLabel.Parent = btn
        
        -- Hover effect
        btn.MouseEnter:Connect(function()
            if not isActive then
                TweenService:Create(btn, TweenInfo.new(0.2), {
                    BackgroundColor3 = THEME.bgHover,
                    BackgroundTransparency = 0.3
                }):Play()
            end
        end)
        
        btn.MouseLeave:Connect(function()
            if not isActive then
                TweenService:Create(btn, TweenInfo.new(0.2), {
                    BackgroundColor3 = THEME.bgCard,
                    BackgroundTransparency = 0.5
                }):Play()
            end
        end)
        
        return btn
    end
        -- Criar abas
    local mainTab = createTabButton("Main", "⚡", true)
    local visualTab = createTabButton("Visuals", "👁", false)
    local settingsTab = createTabButton("Settings", "⚙", false)
    
    -- ==========================================
    -- CONTEÚDO PRINCIPAL (Área de funcionalidades)
    -- ==========================================
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, -240, 1, -90)
    contentFrame.Position = UDim2.new(0, 230, 0, 80)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame
    
    -- Título da seção
    local sectionTitle = Instance.new("TextLabel")
    sectionTitle.Name = "SectionTitle"
    sectionTitle.Size = UDim2.new(1, 0, 0, 40)
    sectionTitle.BackgroundTransparency = 1
    sectionTitle.Text = "MAIN CONTROLS"
    sectionTitle.TextColor3 = THEME.textPrimary
    sectionTitle.TextSize = 24
    sectionTitle.Font = Enum.Font.GothamBold
    sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    sectionTitle.Parent = contentFrame
    
    -- Grid de funcionalidades
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "FeaturesGrid"
    scrollFrame.Size = UDim2.new(1, 0, 1, -50)
    scrollFrame.Position = UDim2.new(0, 0, 0, 50)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollBarImageColor3 = THEME.accentPrimary
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 600)
    scrollFrame.Parent = contentFrame
    
    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellSize = UDim2.new(0, 280, 0, 140)
    gridLayout.CellPadding = UDim2.new(0, 15, 0, 15)
    gridLayout.Parent = scrollFrame
    
    -- Função criar card de feature
    local function createFeatureCard(title, description, defaultState, callback)
        local card = Instance.new("Frame")
        card.Name = title .. "Card"
        card.BackgroundColor3 = THEME.bgCard
        card.BackgroundTransparency = 0.3
        card.BorderSizePixel = 0
        card.ClipsDescendants = true
        
        local cardCorner = Instance.new("UICorner")
        cardCorner.CornerRadius = UDim.new(0, 12)
        cardCorner.Parent = card
        
        -- Gradiente sutil no card
        local cardGradient = Instance.new("UIGradient")
        cardGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, THEME.bgCard),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 50, 70))
        })
        cardGradient.Rotation = 90
        cardGradient.Parent = card
        
        -- Título
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Name = "Title"
        titleLabel.Size = UDim2.new(1, -20, 0, 30)
        titleLabel.Position = UDim2.new(0, 15, 0, 15)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = title
        titleLabel.TextColor3 = THEME.textPrimary
        titleLabel.TextSize = 18
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Parent = card
        
        -- Descrição
        local descLabel = Instance.new("TextLabel")
        descLabel.Name = "Description"
        descLabel.Size = UDim2.new(1, -20, 0, 40)
        descLabel.Position = UDim2.new(0, 15, 0, 45)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = description
        descLabel.TextColor3 = THEME.textSecondary
        descLabel.TextSize = 12
        descLabel.Font = Enum.Font.Gotham
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.TextWrapped = true
        descLabel.Parent = card
        
        -- Toggle Switch (Estilo moderno)
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Name = "Toggle"
        toggleFrame.Size = UDim2.new(0, 50, 0, 26)
        toggleFrame.Position = UDim2.new(1, -65, 1, -41)
        toggleFrame.BackgroundColor3 = defaultState and THEME.accentPrimary or THEME.bgHover
        toggleFrame.BorderSizePixel = 0
        toggleFrame.Parent = card
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(1, 0)
        toggleCorner.Parent = toggleFrame
        
        local circle = Instance.new("Frame")
        circle.Name = "Circle"
        circle.Size = UDim2.new(0, 22, 0, 22)
        circle.Position = defaultState and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)
        circle.BackgroundColor3 = THEME.textPrimary
        circle.BorderSizePixel = 0
        circle.Parent = toggleFrame
        
        local circleCorner = Instance.new("UICorner")
        circleCorner.CornerRadius = UDim.new(1, 0)
        circleCorner.Parent = circle
        
        -- Botão invisível para clicar
        local clickBtn = Instance.new("TextButton")
        clickBtn.Name = "ClickArea"
        clickBtn.Size = UDim2.new(1, 0, 1, 0)
        clickBtn.BackgroundTransparency = 1
        clickBtn.Text = ""
        clickBtn.Parent = card
        
        local isEnabled = defaultState
        
        local function updateToggle()
            isEnabled = not isEnabled
            local targetColor = isEnabled and THEME.accentPrimary or THEME.bgHover
            local targetPos = isEnabled and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)
            
            TweenService:Create(toggleFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                BackgroundColor3 = targetColor
            }):Play()
            
            TweenService:Create(circle, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                Position = targetPos
            }):Play()
            
            if callback then
                callback(isEnabled)
            end
        end
        
        clickBtn.MouseButton1Click:Connect(updateToggle)
        
        -- Hover no card
        card.MouseEnter:Connect(function()
            TweenService:Create(card, TweenInfo.new(0.3), {
                BackgroundTransparency = 0.1
            }):Play()
        end)
        
        card.MouseLeave:Connect(function()
            TweenService:Create(card, TweenInfo.new(0.3), {
                BackgroundTransparency = 0.3
            }):Play()
        end)
        
        return card
    end
    
    -- Criar cards de funcionalidades
    createFeatureCard("Auto Touch", "Touch automático nas bolas próximas", CONFIG.autoTouch, function(state)
        CONFIG.autoTouch = state
        print("Auto Touch:", state)
    end).Parent = scrollFrame
    
    createFeatureCard("Show Visuals", "Mostrar auras e hitboxes visuais", CONFIG.showVisuals, function(state)
        CONFIG.showVisuals = state
        if not state then
            -- Limpar visuais
            for ball, data in pairs(ballAuras) do
                safeDestroy(data.aura)
                safeDestroy(data.highlight)
            end
            ballAuras = {}
            safeDestroy(playerSphere)
            safeDestroy(quantumCircle)
        end
    end).Parent = scrollFrame
    
    createFeatureCard("Flash Effect", "Efeito de flash ao tocar bolas", CONFIG.flashEnabled, function(state)
        CONFIG.flashEnabled = state
    end).Parent = scrollFrame
    
    createFeatureCard("Quantum Reach", "Alcance quântico extendido", CONFIG.quantumReachEnabled, function(state)
        CONFIG.quantumReachEnabled = state
    end).Parent = scrollFrame
    
    createFeatureCard("Expand Hitbox", "Expandir hitbox das bolas", CONFIG.expandBallHitbox, function(state)
        CONFIG.expandBallHitbox = state
        if not state then
            for ball, data in pairs(ballHitboxes) do
                safeDestroy(data.hitbox)
            end
            ballHitboxes = {}
        end
    end).Parent = scrollFrame
    
    createFeatureCard("Anti AFK", "Prevenir kick por inatividade", CONFIG.antiAFK, function(state)
        CONFIG.antiAFK = state
    end).Parent = scrollFrame
    
    -- ==========================================
    -- SLIDERS DE ALCANCE (Na parte inferior)
    -- ==========================================
    local sliderContainer = Instance.new("Frame")
    sliderContainer.Name = "Sliders"
    sliderContainer.Size = UDim2.new(1, 0, 0, 150)
    sliderContainer.Position = UDim2.new(0, 0, 1, -160)
    sliderContainer.BackgroundTransparency = 1
    sliderContainer.Parent = contentFrame
    
    local sliderTitle = Instance.new("TextLabel")
    sliderTitle.Size = UDim2.new(1, 0, 0, 30)
    sliderTitle.BackgroundTransparency = 1
    sliderTitle.Text = "RANGE SETTINGS"
    sliderTitle.TextColor3 = THEME.textPrimary
    sliderTitle.TextSize = 18
    sliderTitle.Font = Enum.Font.GothamBold
    sliderTitle.TextXAlignment = Enum.TextXAlignment.Left
    sliderTitle.Parent = sliderContainer
    
    -- Função criar slider
    local function createSlider(name, min, max, default, callback)
        local frame = Instance.new("Frame")
        frame.Name = name .. "Slider"
        frame.Size = UDim2.new(1, 0, 0, 50)
        frame.BackgroundTransparency = 1
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.5, 0, 0, 20)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = THEME.textSecondary
        label.TextSize = 14
        label.Font = Enum.Font.GothamSemibold
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0.5, 0, 0, 20)
        valueLabel.Position = UDim2.new(0.5, 0, 0, 0)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = tostring(default)
        valueLabel.TextColor3 = THEME.accentPrimary
        valueLabel.TextSize = 14
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.Parent = frame
        
        local track = Instance.new("Frame")
        track.Name = "Track"
        track.Size = UDim2.new(1, 0, 0, 6)
        track.Position = UDim2.new(0, 0, 0, 30)
        track.BackgroundColor3 = THEME.bgHover
        track.BorderSizePixel = 0
        track.Parent = frame
        
        local trackCorner = Instance.new("UICorner")
        trackCorner.CornerRadius = UDim.new(1, 0)
        trackCorner.Parent = track
        
        local fill = Instance.new("Frame")
        fill.Name = "Fill"
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = THEME.accentPrimary
        fill.BorderSizePixel = 0
        fill.Parent = track
        
        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(1, 0)
        fillCorner.Parent = fill
        
        local knob = Instance.new("Frame")
        knob.Name = "Knob"
        knob.Size = UDim2.new(0, 16, 0, 16)
        knob.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
        knob.BackgroundColor3 = THEME.textPrimary
        knob.BorderSizePixel = 0
        knob.Parent = track
        
        local knobCorner = Instance.new("UICorner")
        knobCorner.CornerRadius = UDim.new(1, 0)
        knobCorner.Parent = knob
        
        -- Interatividade
        local dragging = false
        
        local function updateSlider(input)
            local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (pos * (max - min)))
            
            fill.Size = UDim2.new(pos, 0, 1, 0)
            knob.Position = UDim2.new(pos, -8, 0.5, -8)
            valueLabel.Text = tostring(value)
            
            if callback then
                callback(value)
            end
        end
        
        knob.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
            end
        end)
        
        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                updateSlider(input)
                dragging = true
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
    
    -- Criar sliders
    createSlider("Player Reach", 1, 50, CONFIG.playerReach, function(val)
        CONFIG.playerReach = val
    end).Parent = sliderContainer
    
    createSlider("Ball Reach", 1, 50, CONFIG.ballReach, function(val)
        CONFIG.ballReach = val
    end).Parent = sliderContainer
    
    createSlider("Quantum Reach", 1, 100, CONFIG.quantumReach, function(val)
        CONFIG.quantumReach = val
    end).Parent = sliderContainer
    
    -- Ajustar posições dos sliders
    sliderContainer.SlidersLayout = Instance.new("UIListLayout")
    sliderContainer.SlidersLayout.Padding = UDim.new(0, 10)
    sliderContainer.SlidersLayout.Parent = sliderContainer
    
    for i, child in ipairs(sliderContainer:GetChildren()) do
        if child:IsA("Frame") then
            child.Position = UDim2.new(0, 0, 0, (i-1) * 60 + 40)
        end
    end
    
    -- ==========================================
    -- ANIMAÇÕES E FUNCIONALIDADES DA UI
    -- ==========================================
    
    -- Animação de entrada
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, 900, 0, 600),
        Position = UDim2.new(0.5, -450, 0.5, -300)
    }):Play()
    
    -- Fechar
    closeBtn.MouseButton1Click:Connect(function()
        TweenService:Create(mainFrame, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }):Play()
        task.wait(0.3)
        screenGui:Destroy()
        isScriptActive = false
    end)
    
    -- Minimizar (placeholder)
    local minimized = false
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            TweenService:Create(mainFrame, TweenInfo.new(0.3), {
                Size = UDim2.new(0, 300, 0, 70),
                Position = UDim2.new(0.5, -150, 0, 10)
            }):Play()
            sidebar.Visible = false
            contentFrame.Visible = false
        else
            TweenService:Create(mainFrame, TweenInfo.new(0.3), {
                Size = UDim2.new(0, 900, 0, 600),
                Position = UDim2.new(0.5, -450, 0.5, -300)
            }):Play()
            task.wait(0.1)
            sidebar.Visible = true
            contentFrame.Visible = true
        end
    end)
    
    -- Dragging da janela
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X, 
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    return screenGui
end

-- ==========================================
-- INICIALIZAÇÃO DO SISTEMA
-- ==========================================
local function initialize()
    -- Aguarda personagem
    if not player.Character then
        player.CharacterAdded:Wait()
    end
    
    HRP = getHRP()
    if not HRP then
        warn("[Init] Aguardando HumanoidRootPart...")
        repeat
            task.wait(0.1)
            HRP = getHRP()
        until HRP or not player.Character
    end
    
    if not HRP then
        warn("[Init] Falha ao encontrar HRP")
        return
    end
    
    -- Cria BigFoot
    task.delay(1, function()
        createStealthBigFoot()
    end)
    
    -- Cria UI
    local ui = createPremiumHub()
    
    -- Anti-AFK
    if CONFIG.antiAFK then
        player.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
    
    -- Main Loop
    isScriptActive = true
    
    task.spawn(function()
        while isScriptActive do
            safeCall(function()
                -- Atualiza HRP
                if not HRP or not HRP.Parent then
                    HRP = getHRP()
                end
                
                if not HRP then return end
                
                -- Atualiza BigFoot
                if not bigFoot or not bigFoot.Parent then
                    createStealthBigFoot()
                end
                
                -- Atualiza bolas
                local currentBalls = getBalls()
                
                -- Visuals
                if CONFIG.showVisuals then
                    for _, ball in ipairs(currentBalls) do
                        if ball and ball.Parent then
                            createBallAura(ball)
                        end
                    end
                    
                    -- Limpa auras antigas
                    for ball, data in pairs(ballAuras) do
                        if not ball or not ball.Parent then
                            safeDestroy(data.aura)
                            safeDestroy(data.highlight)
                            ballAuras[ball] = nil
                        end
                    end
                    
                    -- Player Sphere
                    if not playerSphere then
                        safeCall(function()
                            playerSphere = Instance.new("Part")
                            playerSphere.Name = "PlayerSphere"
                            playerSphere.Shape = Enum.PartType.Ball
                            playerSphere.Anchored = true
                            playerSphere.CanCollide = false
                            playerSphere.Material = Enum.Material.ForceField
                            playerSphere.Color = THEME.accentPrimary
                            playerSphere.Parent = Workspace
                        end)
                    end
                    
                    if playerSphere then
                        safeCall(function()
                            playerSphere.Size = Vector3.new(CONFIG.playerReach * 2, CONFIG.playerReach * 2, CONFIG.playerReach * 2)
                            playerSphere.Position = HRP.Position
                            playerSphere.Transparency = 0.8
                        end)
                    end
                else
                    safeDestroy(playerSphere)
                    playerSphere = nil
                end
                
                                -- Hitboxes
                if CONFIG.expandBallHitbox then
                    for _, ball in ipairs(currentBalls) do
                        createBallHitbox(ball)
                    end
                else
                    for ball, data in pairs(ballHitboxes) do
                        safeDestroy(data.hitbox)
                        ballHitboxes[ball] = nil
                    end
                end
                
                -- Auto Touch
                if CONFIG.autoTouch and bigFoot then
                    for _, ball in ipairs(currentBalls) do
                        if ball and ball.Parent then
                            local dist = (ball.Position - HRP.Position).Magnitude
                            if dist < (CONFIG.playerReach + CONFIG.ballReach) then
                                stealthTouch(ball)
                                
                                if CONFIG.flashEnabled then
                                    safeCall(function()
                                        local flash = Instance.new("Part")
                                        flash.Size = Vector3.new(1, 1, 1)
                                        flash.Position = ball.Position
                                        flash.Anchored = true
                                        flash.CanCollide = false
                                        flash.Material = Enum.Material.Neon
                                        flash.Color = THEME.warning
                                        flash.Parent = Workspace
                                        
                                        TweenService:Create(flash, TweenInfo.new(0.1), {
                                            Size = Vector3.new(5, 5, 5),
                                            Transparency = 1
                                        }):Play()
                                        
                                        Debris:AddItem(flash, 0.1)
                                    end)
                                end
                            end
                        end
                    end
                end
                
                -- Quantum Reach
                if CONFIG.quantumReachEnabled and bigFoot then
                    for _, ball in ipairs(currentBalls) do
                        if ball and ball.Parent then
                            local dist = (ball.Position - HRP.Position).Magnitude
                            if dist < CONFIG.quantumReach then
                                stealthTouch(ball)
                            end
                        end
                    end
                    
                    -- Visual do quantum
                    if CONFIG.showVisuals then
                        if not quantumCircle then
                            safeCall(function()
                                quantumCircle = Instance.new("Part")
                                quantumCircle.Name = "QuantumCircle"
                                quantumCircle.Shape = Enum.PartType.Ball
                                quantumCircle.Anchored = true
                                quantumCircle.CanCollide = false
                                quantumCircle.Material = Enum.Material.ForceField
                                quantumCircle.Color = THEME.accentCyan
                                quantumCircle.Parent = Workspace
                            end)
                        end
                        
                        if quantumCircle then
                            safeCall(function()
                                quantumCircle.Size = Vector3.new(CONFIG.quantumReach * 2, CONFIG.quantumReach * 2, CONFIG.quantumReach * 2)
                                quantumCircle.Position = HRP.Position
                                quantumCircle.Transparency = 0.8
                            end)
                        end
                    end
                else
                    safeDestroy(quantumCircle)
                    quantumCircle = nil
                end
            end)
            
            task.wait(0.03)
        end
    end)
    
    print("[Premium Hub] Inicializado com sucesso!")
end

-- Inicia tudo
initialize()
