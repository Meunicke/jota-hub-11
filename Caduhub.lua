-- ==========================================
-- PREMIUM MOBILE HUB v3.0 - PROFESSIONAL
-- ==========================================

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

-- ==========================================
-- CONFIGURAÇÃO PROFISSIONAL
-- ==========================================
local THEME = {
    bg = Color3.fromRGB(10, 10, 15),
    card = Color3.fromRGB(25, 25, 35),
    accent = Color3.fromRGB(29, 185, 84),
    accent2 = Color3.fromRGB(229, 9, 20),
    accent3 = Color3.fromRGB(0, 200, 255),
    text = Color3.fromRGB(255, 255, 255),
    textDim = Color3.fromRGB(150, 150, 170)
}

local CONFIG = {
    -- Alcances
    playerReach = 10,
    ballReach = 15,
    quantumReach = 25,
    
    -- Funcionalidades
    autoTouch = true,
    showVisuals = true,
    flashEnabled = false,
    quantumReachEnabled = false,
    expandBallHitbox = true,
    antiAFK = true,
    
    -- BigFoot Config
    bigFootSize = 10,
    bigFootOffset = 2,
    
    -- Bolas suportadas
    ballNames = { "TPS", "MPS", "TRS", "TCS", "PRS", "ESA", "MRS", "SSS", "AIFA", "RBZ", "SoccerBall", "Football", "Ball", "Basketball", "Volleyball" }
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
local HRP = nil
local humanoid = nil
local character = nil
local isScriptActive = false
local currentTab = "main"
local isMinimized = false
local gui = nil
local mainFrame = nil
local minimizeButton = nil
local BALL_NAME_SET = {}

for _, n in ipairs(CONFIG.ballNames) do BALL_NAME_SET[n] = true end

-- ==========================================
-- SISTEMA DE SEGURANÇA ANTI-ERRO
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

-- ==========================================
-- SISTEMA DE PERSONAGEM E HUMANOIDE
-- ==========================================
local function setupCharacter(char)
    character = char
    humanoid = nil
    HRP = nil
    
    -- Aguarda Humanoid
    humanoid = char:WaitForChild("Humanoid", 5)
    if not humanoid then
        warn("[Character] Humanoid não encontrado!")
        return false
    end
    
    -- Aguarda HumanoidRootPart
    HRP = char:WaitForChild("HumanoidRootPart", 5)
    if not HRP then
        -- Tenta achar em outro lugar
        HRP = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    end
    
    if not HRP then
        warn("[Character] HRP não encontrado!")
        return false
    end
    
    print("[Character] Setup completo: " .. char.Name)
    return true
end

-- ==========================================
-- SISTEMA BIGFOOT PROFISSIONAL
-- ==========================================
local function createBigFoot()
    if not character or not HRP then
        warn("[BigFoot] Sem character ou HRP")
        return nil
    end
    
    -- Remove anterior
    safeDestroy(bigFoot)
    
    -- Encontra a melhor parte para anexar (perna ou HRP)
    local attachPart = nil
    
    -- Tenta achar perna
    local legNames = {"Right Leg", "RightLowerLeg", "RightFoot", "RightUpperLeg", "Left Leg", "LeftLowerLeg", "LeftFoot"}
    for _, name in ipairs(legNames) do
        attachPart = character:FindFirstChild(name)
        if attachPart then break end
    end
    
    -- Fallback para HRP ou torso
    if not attachPart then
        attachPart = HRP or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    end
    
    if not attachPart then
        warn("[BigFoot] Nenhuma parte válida para anexar")
        return nil
    end
    
    print("[BigFoot] Anexando em: " .. attachPart.Name)
    
    local success, result = safeCall(function()
        -- Cria BigFoot
        bigFoot = Instance.new("Part")
        bigFoot.Name = "BigFoot_Collision"
        bigFoot.Shape = Enum.PartType.Ball
        bigFoot.Size = Vector3.new(CONFIG.bigFootSize, CONFIG.bigFootSize, CONFIG.bigFootSize)
        bigFoot.Transparency = 1
        bigFoot.CanCollide = false
        bigFoot.CanQuery = false
        bigFoot.CanTouch = true
        bigFoot.Parent = character
        
        -- Conecta ao movimento da parte
        local connection = RunService.Heartbeat:Connect(function()
            if not bigFoot or not bigFoot.Parent then return end
            if not attachPart or not attachPart.Parent then
                -- Tenta recriar se a parte sumiu
                createBigFoot()
                return
            end
            
            -- Posição abaixo da parte
            local offset = CFrame.new(0, -CONFIG.bigFootOffset, 0)
            
            -- Adiciona jitter aleatório para bypass anti-cheat
            if math.random() > 0.7 then
                offset = offset + CFrame.new(
                    math.random(-5, 5) / 100,
                    math.random(-5, 5) / 100,
                    math.random(-5, 5) / 100
                )
            end
            
            bigFoot.CFrame = attachPart.CFrame * offset
        end)
        
        return bigFoot
    end)
    
    if success and bigFoot then
        print("[BigFoot] Criado com sucesso!")
        return bigFoot
    else
        warn("[BigFoot] Falha ao criar")
        return nil
    end
end

local function touchBall(ball)
    if not ball or not bigFoot or not bigFoot.Parent then return end
    
    safeCall(function()
        -- Método principal
        firetouchinterest(ball, bigFoot, 0)
        task.wait()
        firetouchinterest(ball, bigFoot, 1)
        
        -- Método alternativo: teleporta BigFoot para a bola e toca
        local originalCFrame = bigFoot.CFrame
        bigFoot.CFrame = ball.CFrame
        task.wait()
        firetouchinterest(ball, bigFoot, 0)
        firetouchinterest(ball, bigFoot, 1)
        bigFoot.CFrame = originalCFrame
    end)
end

-- ==========================================
-- SISTEMA DE BOLAS
-- ==========================================
local function getBalls()
    table.clear(balls)
    safeCall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj and obj:IsA("BasePart") and BALL_NAME_SET[obj.Name] then
                table.insert(balls, obj)
            end
        end
    end)
    return balls
end

-- ==========================================
-- HUB UI PROFISSIONAL COM IMAGENS
-- ==========================================

-- IDs de imagens (você pode trocar por seus próprios)
local IMAGES = {
    -- Substitua esses IDs pelos seus próprios no Roblox
    logo = "rbxassetid://0",           -- Logo do hub
    menuIcon = "rbxassetid://0",       -- Ícone do botão flutuante
    tabMain = "rbxassetid://0",        -- Ícone aba Main
    tabVisual = "rbxassetid://0",      -- Ícone aba Visual
    tabConfig = "rbxassetid://0",      -- Ícone aba Config
    
    -- Se não tiver imagens, usa emojis:
    emoji = {
        logo = "⚡",
        menu = "☰",
        main = "🎮",
        visual = "👁",
        config = "⚙",
        close = "✕",
        minimize = "−",
        maximize = "□"
    }
}

local function createPremiumHub()
    -- ScreenGui
    gui = Instance.new("ScreenGui")
    gui.Name = "PremiumHub_" .. tostring(math.random(1000, 9999))
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = CoreGui
    
    -- Frame Principal
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 380, 0, 520)
    mainFrame.Position = UDim2.new(0.5, -190, 0.5, -260)
    mainFrame.BackgroundColor3 = THEME.bg
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = gui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 16)
    mainCorner.Parent = mainFrame
    
    -- Sombra
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.Size = UDim2.new(1, 40, 1, 40)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://6015897843"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.4
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.ZIndex = -1
    shadow.Parent = mainFrame
    
    -- ==========================================
    -- HEADER PROFISSIONAL
    -- ==========================================
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 55)
    header.BackgroundColor3 = THEME.card
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 0)
    headerCorner.Parent = header
    
    -- Logo/Ícone
    local logoContainer = Instance.new("Frame")
    logoContainer.Size = UDim2.new(0, 40, 0, 40)
    logoContainer.Position = UDim2.new(0, 10, 0.5, -20)
    logoContainer.BackgroundColor3 = THEME.accent
    logoContainer.BorderSizePixel = 0
    logoContainer.Parent = header
    
    Instance.new("UICorner", logoContainer).CornerRadius = UDim.new(0, 8)
    
    local logoIcon = Instance.new("TextLabel")
    logoIcon.Size = UDim2.new(1, 0, 1, 0)
    logoIcon.BackgroundTransparency = 1
    logoIcon.Text = IMAGES.emoji.logo
    logoIcon.TextSize = 24
    logoIcon.Parent = logoContainer
    
    -- Título
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 200, 1, 0)
    title.Position = UDim2.new(0, 60, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "PREMIUM HUB"
    title.TextColor3 = THEME.text
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    -- Subtítulo
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(0, 200, 0, 15)
    subtitle.Position = UDim2.new(0, 60, 0, 32)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "v3.0 PRO"
    subtitle.TextColor3 = THEME.accent
    subtitle.TextSize = 11
    subtitle.Font = Enum.Font.GothamSemibold
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Parent = header
    
    -- Botão Minimizar (GRANDE para mobile)
    local minBtn = Instance.new("TextButton")
    minBtn.Name = "MinimizeBtn"
    minBtn.Size = UDim2.new(0, 45, 0, 45)
    minBtn.Position = UDim2.new(1, -100, 0.5, -22.5)
    minBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    minBtn.Text = IMAGES.emoji.minimize
    minBtn.TextColor3 = THEME.text
    minBtn.TextSize = 24
    minBtn.Font = Enum.Font.GothamBold
    minBtn.AutoButtonColor = true
    minBtn.Parent = header
    
    Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 10)
    
    -- Botão Fechar (GRANDE para mobile)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.new(0, 45, 0, 45)
    closeBtn.Position = UDim2.new(1, -50, 0.5, -22.5)
    closeBtn.BackgroundColor3 = THEME.accent2
    closeBtn.Text = IMAGES.emoji.close
    closeBtn.TextColor3 = THEME.text
    closeBtn.TextSize = 20
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.AutoButtonColor = true
    closeBtn.Parent = header
    
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 10)
    
    -- ==========================================
    -- CONTEÚDO (Área das abas)
    -- ==========================================
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, -20, 1, -130)
    contentFrame.Position = UDim2.new(0, 10, 0, 65)
    contentFrame.BackgroundTransparency = 1
    contentFrame.ClipsDescendants = true
    contentFrame.Parent = mainFrame
    
    -- ==========================================
    -- TAB BAR (Na parte inferior)
    -- ==========================================
    local tabBar = Instance.new("Frame")
    tabBar.Name = "TabBar"
    tabBar.Size = UDim2.new(1, 0, 0, 65)
    tabBar.Position = UDim2.new(0, 0, 1, -65)
    tabBar.BackgroundColor3 = THEME.card
    tabBar.BorderSizePixel = 0
    tabBar.Parent = mainFrame
    
    Instance.new("UICorner", tabBar).CornerRadius = UDim.new(0, 0)
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    tabLayout.Padding = UDim.new(0, 15)
    tabLayout.Parent = tabBar
    
    -- ==========================================
    -- SISTEMA DE PÁGINAS
    -- ==========================================
    local pages = {}
    
    local function createPage(name)
        local page = Instance.new("ScrollingFrame")
        page.Name = name .. "Page"
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.ScrollBarThickness = 4
        page.ScrollBarImageColor3 = THEME.accent
        page.CanvasSize = UDim2.new(0, 0, 0, 500)
        page.Visible = false
        page.Parent = contentFrame
        
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 12)
        layout.Parent = page
        
        pages[name] = page
        return page
    end
    
    local mainPage = createPage("main")
    local visualPage = createPage("visual")
    local configPage = createPage("config")
    
    -- ==========================================
    -- CRIAR BOTÕES DE ABA COM IMAGENS
    -- ==========================================
    local function createTabButton(name, icon, pageName, isActive)
        local btn = Instance.new("TextButton")
        btn.Name = name .. "Tab"
        btn.Size = UDim2.new(0, 100, 0, 50)
        btn.BackgroundColor3 = isActive and THEME.accent or Color3.fromRGB(40, 40, 50)
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.Parent = tabBar
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 12)
        btnCorner.Parent = btn
        
        -- Ícone (Texto por enquanto, pode ser ImageLabel)
        local iconLabel = Instance.new("TextLabel")
        iconLabel.Size = UDim2.new(1, 0, 0, 24)
        iconLabel.Position = UDim2.new(0, 0, 0, 5)
        iconLabel.BackgroundTransparency = 1
        iconLabel.Text = icon
        iconLabel.TextSize = 22
        iconLabel.Parent = btn
        
        -- Nome
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0, 16)
        nameLabel.Position = UDim2.new(0, 0, 0, 28)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = name
        nameLabel.TextColor3 = isActive and THEME.text or THEME.textDim
        nameLabel.TextSize = 11
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.Parent = btn
        
        -- Clique
        btn.MouseButton1Click:Connect(function()
            currentTab = pageName
            
            -- Atualiza todos os botões
            for _, child in ipairs(tabBar:GetChildren()) do
                if child:IsA("TextButton") then
                    TweenService:Create(child, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                    }):Play()
                    child:FindFirstChildOfClass("TextLabel").TextColor3 = THEME.textDim
                end
            end
            
            -- Ativa o clicado
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = THEME.accent
            }):Play()
            nameLabel.TextColor3 = THEME.text
            
            -- Troca página
            for _, page in pairs(pages) do
                page.Visible = false
            end
            pages[pageName].Visible = true
        end)
        
        return btn
    end
    
    -- Criar abas
    createTabButton("Main", IMAGES.emoji.main, "main", true)
    createTabButton("Visual", IMAGES.emoji.visual, "visual", false)
    createTabButton("Config", IMAGES.emoji.config, "config", false)
    
    -- Mostrar primeira página
    mainPage.Visible = true
    
    -- ==========================================
    -- COMPONENTES UI
    -- ==========================================
    
    -- Toggle Switch
    local function createToggle(parent, title, desc, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 75)
        frame.BackgroundColor3 = THEME.card
        frame.BorderSizePixel = 0
        frame.Parent = parent
        
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
        
        -- Título
        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, -80, 0, 25)
        t.Position = UDim2.new(0, 15, 0, 10)
        t.BackgroundTransparency = 1
        t.Text = title
        t.TextColor3 = THEME.text
        t.TextSize = 16
        t.Font = Enum.Font.GothamBold
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Parent = frame
        
        -- Descrição
        local d = Instance.new("TextLabel")
        d.Size = UDim2.new(1, -80, 0, 30)
        d.Position = UDim2.new(0, 15, 0, 35)
        d.BackgroundTransparency = 1
        d.Text = desc
        d.TextColor3 = THEME.textDim
        d.TextSize = 12
        d.Font = Enum.Font.Gotham
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.TextWrapped = true
        d.Parent = frame
        
        -- Toggle
        local toggle = Instance.new("Frame")
        toggle.Size = UDim2.new(0, 55, 0, 30)
        toggle.Position = UDim2.new(1, -70, 0.5, -15)
        toggle.BackgroundColor3 = default and THEME.accent or Color3.fromRGB(60, 60, 70)
        toggle.BorderSizePixel = 0
        toggle.Parent = frame
        
        Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)
        
        local circle = Instance.new("Frame")
        circle.Size = UDim2.new(0, 26, 0, 26)
        circle.Position = default and UDim2.new(1, -28, 0.5, -13) or UDim2.new(0, 2, 0.5, -13)
        circle.BackgroundColor3 = THEME.text
        circle.BorderSizePixel = 0
        circle.Parent = toggle
        
        Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
        
        -- Botão invisível grande
        local hitbox = Instance.new("TextButton")
        hitbox.Size = UDim2.new(1, 0, 1, 0)
        hitbox.BackgroundTransparency = 1
        hitbox.Text = ""
        hitbox.Parent = frame
        
        local enabled = default
        
        hitbox.MouseButton1Click:Connect(function()
            enabled = not enabled
            
            TweenService:Create(toggle, TweenInfo.new(0.25), {
                BackgroundColor3 = enabled and THEME.accent or Color3.fromRGB(60, 60, 70)
            }):Play()
            
            TweenService:Create(circle, TweenInfo.new(0.25), {
                Position = enabled and UDim2.new(1, -28, 0.5, -13) or UDim2.new(0, 2, 0.5, -13)
            }):Play()
            
            if callback then callback(enabled) end
        end)
        
        return frame
    end

-- Slider
    local function createSlider(parent, title, min, max, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 70)
        frame.BackgroundColor3 = THEME.card
        frame.BorderSizePixel = 0
        frame.Parent = parent
        
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
        
        -- Labels
        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(0.5, 0, 0, 20)
        t.Position = UDim2.new(0, 15, 0, 10)
        t.BackgroundTransparency = 1
        t.Text = title
        t.TextColor3 = THEME.text
        t.TextSize = 14
        t.Font = Enum.Font.GothamBold
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Parent = frame
        
        local val = Instance.new("TextLabel")
        val.Size = UDim2.new(0.5, 0, 0, 20)
        val.Position = UDim2.new(0.5, -15, 0, 10)
        val.BackgroundTransparency = 1
        val.Text = tostring(default)
        val.TextColor3 = THEME.accent
        val.TextSize = 14
        val.Font = Enum.Font.GothamBold
        val.TextXAlignment = Enum.TextXAlignment.Right
        val.Parent = frame
        
        -- Track
        local track = Instance.new("Frame")
        track.Size = UDim2.new(1, -30, 0, 8)
        track.Position = UDim2.new(0, 15, 0, 40)
        track.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        track.BorderSizePixel = 0
        track.Parent = frame
        
        Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
        
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = THEME.accent
        fill.BorderSizePixel = 0
        fill.Parent = track
        
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
        
        -- Knob maior para mobile
        local knob = Instance.new("TextButton")
        knob.Size = UDim2.new(0, 24, 0, 24)
        knob.Position = UDim2.new((default - min) / (max - min), -12, 0.5, -12)
        knob.BackgroundColor3 = THEME.text
        knob.Text = ""
        knob.Parent = track
        
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
        
        -- Área de toque expandida
        local touchPad = Instance.new("TextButton")
        touchPad.Size = UDim2.new(1, 0, 3, 0)
        touchPad.Position = UDim2.new(0, 0, 0.5, -1.5)
        touchPad.BackgroundTransparency = 1
        touchPad.Text = ""
        touchPad.Parent = track
        
        local dragging = false
        
        local function update(input)
            local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (pos * (max - min)))
            
            fill.Size = UDim2.new(pos, 0, 1, 0)
            knob.Position = UDim2.new(pos, -12, 0.5, -12)
            val.Text = tostring(value)
            
            if callback then callback(value) end
        end
        
        knob.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        
        touchPad.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                update(input)
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
                update(input)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        return frame
    end
    
    -- ==========================================
    -- PREENCHER PÁGINAS
    -- ==========================================
    
    -- MAIN PAGE
    createToggle(mainPage, "Auto Touch", "Touch automático nas bolas", CONFIG.autoTouch, function(v)
        CONFIG.autoTouch = v
    end)
    
    createToggle(mainPage, "Expand Hitbox", "Aumentar hitbox das bolas", CONFIG.expandBallHitbox, function(v)
        CONFIG.expandBallHitbox = v
        if not v then
            for ball, data in pairs(ballHitboxes) do
                safeDestroy(data.hitbox)
            end
            ballHitboxes = {}
        end
    end)
    
    createToggle(mainPage, "Anti AFK", "Prevenir desconexão por AFK", CONFIG.antiAFK, function(v)
        CONFIG.antiAFK = v
    end)
    
    createSlider(mainPage, "Player Reach", 1, 50, CONFIG.playerReach, function(v)
        CONFIG.playerReach = v
    end)
    
    createSlider(mainPage, "Ball Reach", 1, 50, CONFIG.ballReach, function(v)
        CONFIG.ballReach = v
    end)
    
    -- VISUAL PAGE
    createToggle(visualPage, "Show Visuals", "Mostrar auras e esferas", CONFIG.showVisuals, function(v)
        CONFIG.showVisuals = v
        if not v then
            for ball, data in pairs(ballAuras) do
                safeDestroy(data.aura)
            end
            ballAuras = {}
            safeDestroy(playerSphere)
            safeDestroy(quantumCircle)
        end
    end)
    
    createToggle(visualPage, "Flash Effect", "Flash ao tocar na bola", CONFIG.flashEnabled, function(v)
        CONFIG.flashEnabled = v
    end)
    
    -- CONFIG PAGE
    createToggle(configPage, "Quantum Reach", "Alcance quântico extendido", CONFIG.quantumReachEnabled, function(v)
        CONFIG.quantumReachEnabled = v
    end)
    
    createSlider(configPage, "Quantum Range", 1, 100, CONFIG.quantumReach, function(v)
        CONFIG.quantumReach = v
    end)
    
    createSlider(configPage, "BigFoot Size", 5, 20, CONFIG.bigFootSize, function(v)
        CONFIG.bigFootSize = v
        createBigFoot() -- Recria com novo tamanho
    end)
    
    -- ==========================================
    -- BOTÃO FLUTUANTE (Minimizado)
    -- ==========================================
    minimizeButton = Instance.new("TextButton")
    minimizeButton.Name = "FloatButton"
    minimizeButton.Size = UDim2.new(0, 60, 0, 60)
    minimizeButton.Position = UDim2.new(1, -70, 0, 10)
    minimizeButton.BackgroundColor3 = THEME.accent
    minimizeButton.Text = IMAGES.emoji.menu
    minimizeButton.TextSize = 28
    minimizeButton.Font = Enum.Font.GothamBold
    minimizeButton.Visible = false
    minimizeButton.Parent = gui
    
    Instance.new("UICorner", minimizeButton).CornerRadius = UDim.new(1, 0)
    
    -- Sombra do botão flutuante
    local floatShadow = Instance.new("ImageLabel")
    floatShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    floatShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    floatShadow.Size = UDim2.new(1, 20, 1, 20)
    floatShadow.BackgroundTransparency = 1
    floatShadow.Image = "rbxassetid://6015897843"
    floatShadow.ImageColor3 = Color3.new(0, 0, 0)
    floatShadow.ImageTransparency = 0.5
    floatShadow.ScaleType = Enum.ScaleType.Slice
    floatShadow.SliceCenter = Rect.new(49, 49, 450, 450)
    floatShadow.ZIndex = -1
    floatShadow.Parent = minimizeButton
    
    -- ==========================================
    -- SISTEMA DE MINIMIZAR/RESTAURAR CORRIGIDO
    -- ==========================================
    
    local function minimizeHub()
        isMinimized = true
        
        -- Animação de minimizar
        TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }):Play()
        
        task.wait(0.3)
        mainFrame.Visible = false
        
        -- Mostrar botão flutuante com animação
        minimizeButton.Visible = true
        minimizeButton.Size = UDim2.new(0, 0, 0, 0)
        
        TweenService:Create(minimizeButton, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
            Size = UDim2.new(0, 60, 0, 60)
        }):Play()
    end
    
    local function restoreHub()
        isMinimized = false
        
        -- Esconder botão flutuante
        TweenService:Create(minimizeButton, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 0, 0, 0)
        }):Play()
        
        task.wait(0.2)
        minimizeButton.Visible = false
        
        -- Restaurar hub
        mainFrame.Visible = true
        TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
            Size = UDim2.new(0, 380, 0, 520),
            Position = UDim2.new(0.5, -190, 0.5, -260)
        }):Play()
    end
    
    -- Conectar botões
    minBtn.MouseButton1Click:Connect(minimizeHub)
    minimizeButton.MouseButton1Click:Connect(restoreHub)
    
    -- Fechar completamente
    closeBtn.MouseButton1Click:Connect(function()
        TweenService:Create(mainFrame, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }):Play()
        
        task.wait(0.3)
        gui:Destroy()
        isScriptActive = false
        
        -- Limpar objetos
        for ball, data in pairs(ballAuras) do
            safeDestroy(data.aura)
        end
        for ball, data in pairs(ballHitboxes) do
            safeDestroy(data.hitbox)
        end
        safeDestroy(playerSphere)
        safeDestroy(quantumCircle)
        safeDestroy(bigFoot)
    end)
    
    -- Animação de entrada
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, 380, 0, 520),
        Position = UDim2.new(0.5, -190, 0.5, -260)
    }):Play()
    
    return gui
end

-- ==========================================
-- INICIALIZAÇÃO DO SISTEMA
-- ==========================================
local function initialize()
    -- Setup do personagem
    if player.Character then
        setupCharacter(player.Character)
    end
    
    player.CharacterAdded:Connect(function(char)
        task.wait(0.5) -- Aguarda personagem carregar completamente
        if setupCharacter(char) then
            task.wait(0.5)
            createBigFoot()
        end
    end)
    
    player.CharacterRemoving:Connect(function()
        safeDestroy(bigFoot)
        HRP = nil
        humanoid = nil
        character = nil
    end)
    
    -- Aguarda setup inicial
    if not HRP then
        repeat task.wait(0.1) until HRP
    end
    
    -- Cria BigFoot inicial
    task.delay(1, createBigFoot)
    
    -- Cria UI
    createPremiumHub()
    
    -- Anti-AFK
    player.Idled:Connect(function()
        if CONFIG.antiAFK then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end)
    
    -- Main Loop
    isScriptActive = true
    
    task.spawn(function()
        while isScriptActive do
            safeCall(function()
                -- Atualiza referências
                if not character or not character.Parent then
                    character = player.Character
                end
                if not HRP or not HRP.Parent then
                    HRP = character and character:FindFirstChild("HumanoidRootPart")
                end
                if not humanoid or not humanoid.Parent then
                    humanoid = character and character:FindFirstChild("Humanoid")
                end
                
                if not HRP then return end
                
                -- Recria BigFoot se necessário
                if not bigFoot or not bigFoot.Parent then
                    createBigFoot()
                end
                
                local currentBalls = getBalls()
                
                -- Visuals
                if CONFIG.showVisuals then
                    -- Cria auras
                    for _, ball in ipairs(currentBalls) do
                        if ball and ball.Parent and not ballAuras[ball] then
                            safeCall(function()
                                local aura = Instance.new("Part")
                                aura.Shape = Enum.PartType.Ball
                                aura.Size = Vector3.new(CONFIG.ballReach * 2, CONFIG.ballReach * 2, CONFIG.ballReach * 2)
                                aura.Transparency = 0.85
                                aura.Anchored = true
                                aura.CanCollide = false
                                aura.Material = Enum.Material.ForceField
                                aura.Color = ball.Name == "TPS" and THEME.accent3 or THEME.accent2
                                aura.Parent = Workspace
                                
                                local conn = RunService.Heartbeat:Connect(function()
                                    if ball and ball.Parent and aura and aura.Parent then
                                        aura.CFrame = ball.CFrame
                                    else
                                        safeDestroy(aura)
                                    end
                                end)
                                
                                ballAuras[ball] = {aura = aura, conn = conn}
                            end)
                        end
                    end
                    
                    -- Limpa auras antigas
                    for ball, data in pairs(ballAuras) do
                        if not ball or not ball.Parent then
                            safeDestroy(data.aura)
                            ballAuras[ball] = nil
                        end
                    end
                    
                    -- Player Sphere
                    if not playerSphere then
                        safeCall(function()
                            playerSphere = Instance.new("Part")
                            playerSphere.Name = "PlayerAura"
                            playerSphere.Shape = Enum.PartType.Ball
                            playerSphere.Anchored = true
                            playerSphere.CanCollide = false
                            playerSphere.Material = Enum.Material.ForceField
                            playerSphere.Color = THEME.accent
                            playerSphere.Transparency = 0.8
                            playerSphere.Parent = Workspace
                        end)
                    end
                    
                    if playerSphere then
                        playerSphere.Size = Vector3.new(CONFIG.playerReach * 2, CONFIG.playerReach * 2, CONFIG.playerReach * 2)
                        playerSphere.CFrame = HRP.CFrame
                    end
                else
                    for ball, data in pairs(ballAuras) do
                        safeDestroy(data.aura)
                        ballAuras[ball] = nil
                    end
                    safeDestroy(playerSphere)
                end
                
                -- Hitboxes
                if CONFIG.expandBallHitbox then
                    for _, ball in ipairs(currentBalls) do
                        if ball and ball.Parent and not ballHitboxes[ball] then
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
                                
                                ballHitboxes[ball] = {hitbox = hitbox, conn = conn}
                            end)
                        end
                    end
                else
                    for ball, data in pairs(ballHitboxes) do
                        safeDestroy(data.hitbox)
                        ballHitboxes[ball] = nil
                    end
                end
                
                -- Auto Touch
                if CONFIG.autoTouch and bigFoot and HRP then
                    for _, ball in ipairs(currentBalls) do
                        if ball and ball.Parent then
                            local dist = (ball.Position - HRP.Position).Magnitude
                            if dist < (CONFIG.playerReach + CONFIG.ballReach) then
                                touchBall(ball)
                                
                                if CONFIG.flashEnabled then
                                    safeCall(function()
                                        local flash = Instance.new("Part")
                                        flash.Size = Vector3.new(1, 1, 1)
                                        flash.CFrame = ball.CFrame
                                        flash.Anchored = true
                                        flash.CanCollide = false
                                        flash.Material = Enum.Material.Neon
                                        flash.Color = Color3.fromRGB(255, 255, 100)
                                        flash.Parent = Workspace
                                        
                                        TweenService:Create(flash, TweenInfo.new(0.15), {
                                            Size = Vector3.new(6, 6, 6),
                                            Transparency = 1
                                        }):Play()
                                        
                                        Debris:AddItem(flash, 0.15)
                                    end)
                                end
                            end
                        end
                    end
                end
                
                                -- Quantum Reach
                if CONFIG.quantumReachEnabled and bigFoot and HRP then
                    for _, ball in ipairs(currentBalls) do
                        if ball and ball.Parent then
                            local dist = (ball.Position - HRP.Position).Magnitude
                            if dist < CONFIG.quantumReach then
                                touchBall(ball)
                            end
                        end
                    end
                    
                    if CONFIG.showVisuals then
                        if not quantumCircle then
                            safeCall(function()
                                quantumCircle = Instance.new("Part")
                                quantumCircle.Name = "QuantumAura"
                                quantumCircle.Shape = Enum.PartType.Ball
                                quantumCircle.Anchored = true
                                quantumCircle.CanCollide = false
                                quantumCircle.Material = Enum.Material.ForceField
                                quantumCircle.Color = THEME.accent3
                                quantumCircle.Transparency = 0.8
                                quantumCircle.Parent = Workspace
                            end)
                        end
                        
                        if quantumCircle then
                            quantumCircle.Size = Vector3.new(CONFIG.quantumReach * 2, CONFIG.quantumReach * 2, CONFIG.quantumReach * 2)
                            quantumCircle.CFrame = HRP.CFrame
                        end
                    end
                else
                    safeDestroy(quantumCircle)
                end
            end)
            
            task.wait(0.03)
        end
    end)
    
    print("[Premium Hub v3.0] Iniciado com sucesso!")
    print("[Sistema] Humanoid + BigFoot configurados")
end

-- Iniciar
initialize()
