-- ==========================================
-- MOBILE HUB COMPACTO - TOUCH OPTIMIZED
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
-- CONFIG
-- ==========================================
local THEME = {
    bg = Color3.fromRGB(15, 15, 20),
    card = Color3.fromRGB(30, 30, 40),
    accent = Color3.fromRGB(29, 185, 84),
    accent2 = Color3.fromRGB(229, 9, 20),
    text = Color3.fromRGB(255, 255, 255),
    textDim = Color3.fromRGB(150, 150, 150)
}

local CONFIG = {
    playerReach = 10,
    ballReach = 15,
    autoTouch = true,
    showVisuals = true,
    flashEnabled = false,
    quantumReachEnabled = false,
    quantumReach = 10,
    expandBallHitbox = true,
    antiAFK = true,
    ballNames = { "TPS", "MPS", "TRS", "TCS", "PRS", "ESA", "MRS", "SSS", "AIFA", "RBZ", "SoccerBall", "Football", "Ball" }
}

-- ==========================================
-- VARIÁVEIS
-- ==========================================
local balls = {}
local ballAuras = {}
local ballHitboxes = {}
local playerSphere = nil
local quantumCircle = nil
local bigFoot = nil
local HRP = nil
local isScriptActive = false
local BALL_NAME_SET = {}
local currentTab = "main"
local isMinimized = false

for _, n in ipairs(CONFIG.ballNames) do BALL_NAME_SET[n] = true end

-- ==========================================
-- FUNÇÕES SEGURAS
-- ==========================================
local function safeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then warn("[Error]: " .. tostring(result)) end
    return success, result
end

local function safeDestroy(obj)
    if obj and obj.Parent then safeCall(function() obj:Destroy() end) end
end

local function getHRP()
    local char = player and player.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- ==========================================
-- BIGFOOT SYSTEM
-- ==========================================
local function createBigFoot()
    local char = player.Character
    if not char then return nil end
    
    safeDestroy(bigFoot)
    
    local leg = char:FindFirstChild("Right Leg") or char:FindFirstChild("RightLowerLeg") or char:FindFirstChild("RightFoot") or char:FindFirstChild("HumanoidRootPart")
    if not leg then return nil end
    
    safeCall(function()
        bigFoot = Instance.new("Part")
        bigFoot.Name = "BigFoot"
        bigFoot.Shape = Enum.PartType.Ball
        bigFoot.Size = Vector3.new(8, 8, 8)
        bigFoot.Transparency = 1
        bigFoot.CanCollide = false
        bigFoot.CanTouch = true
        bigFoot.Parent = char
        
        RunService.Heartbeat:Connect(function()
            if bigFoot and bigFoot.Parent and leg and leg.Parent then
                bigFoot.CFrame = leg.CFrame * CFrame.new(0, -leg.Size.Y/2, 0)
            end
        end)
    end)
    
    return bigFoot
end

local function touchBall(ball)
    if not ball or not bigFoot then return end
    safeCall(function()
        firetouchinterest(ball, bigFoot, 0)
        task.wait()
        firetouchinterest(ball, bigFoot, 1)
    end)
end

-- ==========================================
-- BALL SYSTEM
-- ==========================================
local function getBalls()
    table.clear(balls)
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v and v:IsA("BasePart") and BALL_NAME_SET[v.Name] then
            table.insert(balls, v)
        end
    end
    return balls
end

-- ==========================================
-- MOBILE HUB UI
-- ==========================================
local function createMobileHub()
    local gui = Instance.new("ScreenGui")
    gui.Name = "MobileHub"
    gui.ResetOnSpawn = false
    gui.Parent = CoreGui
    
    -- Frame Principal (Menor para mobile)
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 350, 0, 500)
    main.Position = UDim2.new(0.5, -175, 0.5, -250)
    main.BackgroundColor3 = THEME.bg
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true
    main.Parent = gui
    
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
    
    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = THEME.card
    header.BorderSizePixel = 0
    header.Parent = main
    
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 0)
    
    -- Título
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -120, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "⚡ PREMIUM HUB"
    title.TextColor3 = THEME.accent
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    -- Botão Minimizar (GRANDE para mobile)
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 40, 0, 40)
    minBtn.Position = UDim2.new(1, -90, 0.5, -20)
    minBtn.BackgroundColor3 = THEME.card
    minBtn.Text = "−"
    minBtn.TextColor3 = THEME.text
    minBtn.TextSize = 24
    minBtn.Font = Enum.Font.GothamBold
    minBtn.Parent = header
    
    Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 8)
    
    -- Botão Fechar (GRANDE para mobile)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 40, 0, 40)
    closeBtn.Position = UDim2.new(1, -45, 0.5, -20)
    closeBtn.BackgroundColor3 = THEME.accent2
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = THEME.text
    closeBtn.TextSize = 20
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = header
    
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    
    -- Container de Abas (NA PARTE DE BAIXO para fácil acesso no mobile)
    local tabBar = Instance.new("Frame")
    tabBar.Name = "TabBar"
    tabBar.Size = UDim2.new(1, 0, 0, 60)
    tabBar.Position = UDim2.new(0, 0, 1, -60)
    tabBar.BackgroundColor3 = THEME.card
    tabBar.BorderSizePixel = 0
    tabBar.Parent = main
    
    Instance.new("UICorner", tabBar).CornerRadius = UDim.new(0, 0)
    
    -- Layout das abas
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    tabLayout.Padding = UDim.new(0, 10)
    tabLayout.Parent = tabBar
    
    -- Container de conteúdo
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -20, 1, -130)
    content.Position = UDim2.new(0, 10, 0, 60)
    content.BackgroundTransparency = 1
    content.ClipsDescendants = true
    content.Parent = main
    
    -- Páginas
    local pages = {}
    
    local function createPage(name)
        local page = Instance.new("ScrollingFrame")
        page.Name = name .. "Page"
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.ScrollBarThickness = 4
        page.ScrollBarImageColor3 = THEME.accent
        page.CanvasSize = UDim2.new(0, 0, 0, 400)
        page.Visible = false
        page.Parent = content
        
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 10)
        layout.Parent = page
        
        pages[name] = page
        return page
    end
    
    local mainPage = createPage("main")
    local visualPage = createPage("visual")
    local settingsPage = createPage("settings")
    
    -- Função criar botão de aba (GRANDE para mobile)
    local function createTabButton(name, icon, pageName)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 90, 0, 45)
        btn.BackgroundColor3 = (currentTab == pageName) and THEME.accent or THEME.bg
        btn.Text = icon .. " " .. name
        btn.TextColor3 = THEME.text
        btn.TextSize = 12
        btn.Font = Enum.Font.GothamBold
        btn.AutoButtonColor = true
        btn.Parent = tabBar
        
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        
        btn.MouseButton1Click:Connect(function()
            currentTab = pageName
            
            -- Atualiza visual dos botões
            for _, child in ipairs(tabBar:GetChildren()) do
                if child:IsA("TextButton") then
                    child.BackgroundColor3 = THEME.bg
                end
            end
            btn.BackgroundColor3 = THEME.accent
            
            -- Troca página
            for _, page in pairs(pages) do
                page.Visible = false
            end
            pages[pageName].Visible = true
        end)
        
        return btn
    end
    
    -- Criar abas
    createTabButton("Main", "⚡", "main")
    createTabButton("Visual", "👁", "visual")
    createTabButton("Config", "⚙", "settings")
    
    -- Mostrar página inicial
    mainPage.Visible = true
    
    -- ==========================================
    -- FUNÇÃO CRIAR TOGGLE (Mobile-friendly)
    -- ==========================================
    local function createToggle(parent, title, desc, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 70)
        frame.BackgroundColor3 = THEME.card
        frame.BorderSizePixel = 0
        frame.Parent = parent
        
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
        
        -- Título
        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, -70, 0, 25)
        t.Position = UDim2.new(0, 12, 0, 8)
        t.BackgroundTransparency = 1
        t.Text = title
        t.TextColor3 = THEME.text
        t.TextSize = 16
        t.Font = Enum.Font.GothamBold
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Parent = frame
        
        -- Descrição
        local d = Instance.new("TextLabel")
        d.Size = UDim2.new(1, -70, 0, 30)
        d.Position = UDim2.new(0, 12, 0, 32)
        d.BackgroundTransparency = 1
        d.Text = desc
        d.TextColor3 = THEME.textDim
        d.TextSize = 11
        d.Font = Enum.Font.Gotham
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.TextWrapped = true
        d.Parent = frame
        
        -- Toggle (MAIOR para mobile)
        local toggle = Instance.new("Frame")
        toggle.Size = UDim2.new(0, 50, 0, 28)
        toggle.Position = UDim2.new(1, -60, 0.5, -14)
        toggle.BackgroundColor3 = default and THEME.accent or Color3.fromRGB(60, 60, 70)
        toggle.BorderSizePixel = 0
        toggle.Parent = frame
        
        Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)
        
        local circle = Instance.new("Frame")
        circle.Size = UDim2.new(0, 24, 0, 24)
        circle.Position = default and UDim2.new(1, -26, 0.5, -12) or UDim2.new(0, 2, 0.5, -12)
        circle.BackgroundColor3 = THEME.text
        circle.BorderSizePixel = 0
        circle.Parent = toggle
        
        Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
        
        -- Botão invisível maior para facilitar toque
        local hitbox = Instance.new("TextButton")
        hitbox.Size = UDim2.new(1, 0, 1, 0)
        hitbox.BackgroundTransparency = 1
        hitbox.Text = ""
        hitbox.Parent = frame
        
        local enabled = default
        
        hitbox.MouseButton1Click:Connect(function()
            enabled = not enabled
            
            TweenService:Create(toggle, TweenInfo.new(0.2), {
                BackgroundColor3 = enabled and THEME.accent or Color3.fromRGB(60, 60, 70)
            }):Play()
            
            TweenService:Create(circle, TweenInfo.new(0.2), {
                Position = enabled and UDim2.new(1, -26, 0.5, -12) or UDim2.new(0, 2, 0.5, -12)
            }):Play()
            
            if callback then callback(enabled) end
        end)
        
        return frame
    end
    
    -- ==========================================
    -- FUNÇÃO CRIAR SLIDER (Mobile-friendly)
    -- ==========================================
    local function createSlider(parent, title, min, max, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 60)
        frame.BackgroundColor3 = THEME.card
        frame.BorderSizePixel = 0
        frame.Parent = parent
        
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
        
        -- Título e valor
        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(0.5, 0, 0, 20)
        t.Position = UDim2.new(0, 12, 0, 8)
        t.BackgroundTransparency = 1
        t.Text = title
        t.TextColor3 = THEME.text
        t.TextSize = 14
        t.Font = Enum.Font.GothamBold
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Parent = frame
        
        local val = Instance.new("TextLabel")
        val.Size = UDim2.new(0.5, 0, 0, 20)
        val.Position = UDim2.new(0.5, -12, 0, 8)
        val.BackgroundTransparency = 1
        val.Text = tostring(default)
        val.TextColor3 = THEME.accent
        val.TextSize = 14
        val.Font = Enum.Font.GothamBold
        val.TextXAlignment = Enum.TextXAlignment.Right
        val.Parent = frame
        
        -- Track
        local track = Instance.new("Frame")
        track.Size = UDim2.new(1, -24, 0, 8)
        track.Position = UDim2.new(0, 12, 0, 35)
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
        
        -- Knob (MAIOR para mobile)
        local knob = Instance.new("TextButton")
        knob.Size = UDim2.new(0, 20, 0, 20)
        knob.Position = UDim2.new((default - min) / (max - min), -10, 0.5, -10)
        knob.BackgroundColor3 = THEME.text
        knob.Text = ""
        knob.Parent = track
        
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
        
        -- Área de toque maior (invisível)
        local touchArea = Instance.new("TextButton")
        touchArea.Size = UDim2.new(1, 0, 3, 0)
        touchArea.Position = UDim2.new(0, 0, 0.5, -1.5)
        touchArea.BackgroundTransparency = 1
        touchArea.Text = ""
        touchArea.Parent = track
        
        local dragging = false
        
        local function update(input)
            local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (pos * (max - min)))
            
            fill.Size = UDim2.new(pos, 0, 1, 0)
            knob.Position = UDim2.new(pos, -10, 0.5, -10)
            val.Text = tostring(value)
            
            if callback then callback(value) end
        end
        
        knob.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        
        touchArea.InputBegan:Connect(function(input)
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
    
    createToggle(mainPage, "Expand Hitbox", "Hitboxes maiores", CONFIG.expandBallHitbox, function(v)
        CONFIG.expandBallHitbox = v
        if not v then
            for ball, data in pairs(ballHitboxes) do
                safeDestroy(data.hitbox)
            end
            ballHitboxes = {}
        end
    end)
    
    createToggle(mainPage, "Anti AFK", "Prevenir kick", CONFIG.antiAFK, function(v)
        CONFIG.antiAFK = v
    end)
    
    createSlider(mainPage, "Player Reach", 1, 50, CONFIG.playerReach, function(v)
        CONFIG.playerReach = v
    end)
    
    createSlider(mainPage, "Ball Reach", 1, 50, CONFIG.ballReach, function(v)
        CONFIG.ballReach = v
    end)
    
    -- VISUAL PAGE
    createToggle(visualPage, "Show Visuals", "Mostrar auras", CONFIG.showVisuals, function(v)
        CONFIG.showVisuals = v
        if not v then
            for ball, data in pairs(ballAuras) do
                safeDestroy(data.aura)
                safeDestroy(data.highlight)
            end
            ballAuras = {}
            safeDestroy(playerSphere)
            safeDestroy(quantumCircle)
        end
    end)
    
    createToggle(visualPage, "Flash Effect", "Flash ao tocar", CONFIG.flashEnabled, function(v)
        CONFIG.flashEnabled = v
    end)
    
    -- SETTINGS PAGE
    createToggle(settingsPage, "Quantum Reach", "Alcance quântico", CONFIG.quantumReachEnabled, function(v)
        CONFIG.quantumReachEnabled = v
    end)
    
    createSlider(settingsPage, "Quantum Range", 1, 100, CONFIG.quantumReach, function(v)
        CONFIG.quantumReach = v
    end)
    
    -- ==========================================
    -- BOTÕES DE AÇÃO (Fechar/Minimizar)
    -- ==========================================
    
    -- Fechar (funciona no mobile)
    closeBtn.MouseButton1Click:Connect(function()
        -- Animação de saída
        TweenService:Create(main, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }):Play()
        
        task.wait(0.3)
        gui:Destroy()
        isScriptActive = false
        
        -- Limpar tudo
        for ball, data in pairs(ballAuras) do
            safeDestroy(data.aura)
            safeDestroy(data.highlight)
        end
        for ball, data in pairs(ballHitboxes) do
            safeDestroy(data.hitbox)
        end
        safeDestroy(playerSphere)
        safeDestroy(quantumCircle)
        safeDestroy(bigFoot)
    end)
    
    -- Minimizar (funciona no mobile)
    minBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        
        if isMinimized then
            -- Minimizar para um botão flutuante pequeno
            TweenService:Create(main, TweenInfo.new(0.3), {
                Size = UDim2.new(0, 60, 0, 60),
                Position = UDim2.new(1, -70, 0, 10)
            }):Play()
            
                -- Esconder conteúdo
            for _, child in ipairs(main:GetChildren()) do
                if child.Name ~= "Header" then
                    child.Visible = false
                end
            end
            
            -- Esconder header também
            header.Visible = false
            
            -- Criar indicador visual
            local indicator = Instance.new("TextLabel")
            indicator.Name = "Indicator"
            indicator.Size = UDim2.new(1, 0, 1, 0)
            indicator.BackgroundTransparency = 1
            indicator.Text = "⚡"
            indicator.TextSize = 30
            indicator.Parent = main
            
            -- Tocar para restaurar
            main.InputBegan:Connect(function(input)
                if isMinimized and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
                    isMinimized = false
                    
                    safeDestroy(indicator)
                    header.Visible = true
                    
                    for _, child in ipairs(main:GetChildren()) do
                        child.Visible = true
                    end
                    
                    TweenService:Create(main, TweenInfo.new(0.3), {
                        Size = UDim2.new(0, 350, 0, 500),
                        Position = UDim2.new(0.5, -175, 0.5, -250)
                    }):Play()
                end
            end)
            
        else
            -- Restaurar (código acima já restaura no clique)
        end
    end)
    
    -- Animação de entrada
    main.Size = UDim2.new(0, 0, 0, 0)
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    TweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, 350, 0, 500),
        Position = UDim2.new(0.5, -175, 0.5, -250)
    }):Play()
    
    return gui
end

-- ==========================================
-- INICIALIZAÇÃO
-- ==========================================
local function init()
    -- Aguardar personagem
    if not player.Character then
        player.CharacterAdded:Wait()
    end
    
    HRP = getHRP()
    while not HRP do
        task.wait(0.1)
        HRP = getHRP()
    end
    
    -- Criar BigFoot
    task.delay(1, createBigFoot)
    
    -- Criar UI
    createMobileHub()
    
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
                if not HRP or not HRP.Parent then
                    HRP = getHRP()
                end
                if not HRP then return end
                
                if not bigFoot or not bigFoot.Parent then
                    createBigFoot()
                end
                
                local currentBalls = getBalls()
                
                -- Visuals
                if CONFIG.showVisuals then
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
                                aura.Color = THEME.accent2
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
                    
                    -- Player Sphere
                    if not playerSphere then
                        safeCall(function()
                            playerSphere = Instance.new("Part")
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
                        playerSphere.Position = HRP.Position
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
                if CONFIG.autoTouch and bigFoot then
                    for _, ball in ipairs(currentBalls) do
                        if ball and ball.Parent then
                            local dist = (ball.Position - HRP.Position).Magnitude
                            if dist < (CONFIG.playerReach + CONFIG.ballReach) then
                                touchBall(ball)
                                
                                if CONFIG.flashEnabled then
                                    safeCall(function()
                                        local flash = Instance.new("Part")
                                        flash.Size = Vector3.new(1, 1, 1)
                                        flash.Position = ball.Position
                                        flash.Anchored = true
                                        flash.CanCollide = false
                                        flash.Material = Enum.Material.Neon
                                        flash.Color = Color3.fromRGB(255, 255, 0)
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
                                touchBall(ball)
                            end
                        end
                    end
                    
                    if CONFIG.showVisuals then
                        if not quantumCircle then
                            safeCall(function()
                                quantumCircle = Instance.new("Part")
                                quantumCircle.Shape = Enum.PartType.Ball
                                quantumCircle.Anchored = true
                                quantumCircle.CanCollide = false
                                quantumCircle.Material = Enum.Material.ForceField
                                quantumCircle.Color = Color3.fromRGB(0, 255, 255)
                                quantumCircle.Transparency = 0.8
                                quantumCircle.Parent = Workspace
                            end)
                        end
                        
                        if quantumCircle then
                            quantumCircle.Size = Vector3.new(CONFIG.quantumReach * 2, CONFIG.quantumReach * 2, CONFIG.quantumReach * 2)
                            quantumCircle.Position = HRP.Position
                        end
                    end
                else
                    safeDestroy(quantumCircle)
                end
            end)
            
            task.wait(0.03)
        end
    end)
    
    print("[Mobile Hub] Iniciado! Tamanho: 350x500")
end

-- Iniciar
init()
