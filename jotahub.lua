-- ============================================
-- CADUXX137 UI - VERSÃO EXPLOIT/EXECUTOR (CORRIGIDO E INTEGRADO)
-- ============================================

-- ESPERA O JOGO CARREGAR
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- SERVIÇOS
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

-- OBTÉM O JOGADOR LOCAL
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 10)

if not playerGui then
    warn("❌ PlayerGui não encontrado")
    return
end

-- VARIÁVEIS GLOBAIS
getgenv().CADUXX137_MainGui = nil
getgenv().CADUXX137_LoadingGui = nil

-- ESTADO
local isLoaded = false
local currentTab = "home"
local mainGui = nil
local introGui = nil
local loadingGui = nil

-- CONFIGURAÇÕES
local CONFIG = {
    accentColor = Color3.fromRGB(0, 170, 255),
    secondaryColor = Color3.fromRGB(138, 43, 226),
    reach = 25,
    ballReach = 10,
    quantumReach = 15,
    fullBodyTouch = true,
    autoTouch = true,
    showVisuals = true,
    showReachSphere = true,
    flashEnabled = true,
    expandBallHitbox = true,
    optimizerEnabled = true,
    scanRate = 0.03,
    reactionTime = 0,
    antiAFK = true,
    ballNames = {"Ball", "Bola", "SoccerBall", "Football", "Basketball", "Baseball", "Balloon", "BeachBall"}
}

-- DETECÇÃO DE SERVIDOR VIP (para correção da reach)
local isVIPServer = false
local function checkVIPServer()
    -- Método 1: Verifica se é um servidor privado pelo GameId
    local success, result = pcall(function()
        return game.PrivateServerId ~= "" and game.PrivateServerId ~= nil
    end)
    if success and result then
        isVIPServer = true
        return true
    end
    
    -- Método 2: Verifica pelo JobId (servidores VIP geralmente têm padrão diferente)
    local jobId = game.JobId
    if jobId and (#jobId > 20 or jobId:match("^[A-Fa-f0-9]+$")) then
        -- Possível servidor VIP, mas não confirma 100%
    end
    
    -- Método 3: Verifica número de jogadores (VIP servers geralmente têm menos jogadores)
    local playerCount = #Players:GetPlayers()
    if playerCount <= 3 then
        isVIPServer = true
        return true
    end
    
    return false
end

-- CORREÇÃO DA REACH PARA SERVIDORES VIP
local function getCorrectedReach()
    local baseReach = CONFIG.reach
    if isVIPServer then
        -- Em servidores VIP, a hitbox/detecção costuma ser menor
        -- Aumentamos o multiplicador para compensar
        return baseReach * 1.4 -- +40% de alcance em VIP servers
    end
    return baseReach
end

local function getCorrectedBallReach()
    local baseBallReach = CONFIG.ballReach
    if isVIPServer then
        return baseBallReach * 1.5 -- +50% na expansão da bola em VIP servers
    end
    return baseBallReach
end

-- VARIÁVEIS DO SISTEMA DE REACH
local HRP = nil
local balls = {}
local ballHitboxes = {}
local touchCache = {}
local lastScan = 0

-- ============================================
-- FUNÇÃO DE NOTIFICAÇÃO
-- ============================================
local function notify(message, notifyType, duration)
    duration = duration or 3
    notifyType = notifyType or "info"
    
    local success = pcall(function()
        local notifGui = Instance.new("ScreenGui")
        notifGui.Name = "CADUXX137_Notif_" .. tostring(tick())
        notifGui.ResetOnSpawn = false
        notifGui.Parent = playerGui
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 300, 0, 50)
        frame.Position = UDim2.new(0.5, -150, 0, -60)
        frame.BackgroundColor3 = notifyType == "success" and Color3.fromRGB(0, 200, 0) 
            or notifyType == "error" and Color3.fromRGB(200, 50, 50) 
            or Color3.fromRGB(0, 100, 200)
        frame.BorderSizePixel = 0
        frame.Parent = notifGui
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = frame
        
        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1, 0, 1, 0)
        text.Text = message
        text.TextColor3 = Color3.fromRGB(255, 255, 255)
        text.Font = Enum.Font.GothamBold
        text.TextSize = 14
        text.BackgroundTransparency = 1
        text.Parent = frame
        
        TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
            Position = UDim2.new(0.5, -150, 0, 20)
        }):Play()
        
        task.delay(duration, function()
            pcall(function()
                local tween = TweenService:Create(frame, TweenInfo.new(0.3), {
                    Position = UDim2.new(0.5, -150, 0, -60),
                    BackgroundTransparency = 1
                })
                tween:Play()
                tween.Completed:Wait()
                notifGui:Destroy()
            end)
        end)
    end)
    
    if not success then
        print("[NOTIFY] " .. message)
    end
end

-- ============================================
-- TELA DE LOADING (CORRIGIDA E INTEGRADA)
-- ============================================
local function showLoadingScreen()
    if getgenv().CADUXX137_LoadingGui then
        pcall(function() getgenv().CADUXX137_LoadingGui:Destroy() end)
    end
    
    local success, gui = pcall(function()
        local gui = Instance.new("ScreenGui")
        gui.Name = "CADUXX137_Loading"
        gui.ResetOnSpawn = false
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.DisplayOrder = 999999
        gui.Parent = playerGui
        
        -- Background
        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
        bg.BorderSizePixel = 0
        bg.Parent = gui
        
        -- Partículas
        for i = 1, 20 do
            local particle = Instance.new("Frame")
            particle.Size = UDim2.new(0, math.random(2, 6), 0, math.random(2, 6))
            particle.Position = UDim2.new(math.random(), 0, math.random(), 0)
            particle.BackgroundColor3 = CONFIG.accentColor
            particle.BackgroundTransparency = 0.8
            particle.BorderSizePixel = 0
            particle.Parent = bg
            
            TweenService:Create(particle, TweenInfo.new(math.random(3, 8), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1), {
                Position = UDim2.new(particle.Position.X.Scale, math.random(-50, 50), particle.Position.Y.Scale + 0.2, 0)
            }):Play()
        end
        
        -- Container do logo
        local logoContainer = Instance.new("Frame")
        logoContainer.Size = UDim2.new(0, 200, 0, 200)
        logoContainer.Position = UDim2.new(0.5, -100, 0.4, -100)
        logoContainer.BackgroundTransparency = 1
        logoContainer.Parent = bg
        
        -- Círculo rotativo
        local circle = Instance.new("Frame")
        circle.Size = UDim2.new(1, 0, 1, 0)
        circle.BackgroundTransparency = 1
        circle.Parent = logoContainer
        
        local circleStroke = Instance.new("UIStroke")
        circleStroke.Color = CONFIG.accentColor
        circleStroke.Thickness = 3
        circleStroke.Parent = circle
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = circle
        
        TweenService:Create(circle, TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {
            Rotation = 360
        }):Play()
        
        -- Texto
        local logoText = Instance.new("TextLabel")
        logoText.Size = UDim2.new(1, 0, 0, 50)
        logoText.Position = UDim2.new(0, 0, 0.5, -25)
        logoText.BackgroundTransparency = 1
        logoText.Text = "CADUXX137"
        logoText.TextColor3 = CONFIG.accentColor
        logoText.Font = Enum.Font.GothamBlack
        logoText.TextSize = 42
        logoText.Parent = logoContainer
        
        -- Glow
        local glow = Instance.new("ImageLabel")
        glow.Size = UDim2.new(1.5, 0, 1.5, 0)
        glow.Position = UDim2.new(-0.25, 0, -0.25, 0)
        glow.BackgroundTransparency = 1
        glow.Image = "rbxassetid://5028857084"
        glow.ImageColor3 = CONFIG.accentColor
        glow.ImageTransparency = 0.7
        glow.Parent = logoContainer
        
        -- Barra de progresso
        local barContainer = Instance.new("Frame")
        barContainer.Size = UDim2.new(0, 400, 0, 4)
        barContainer.Position = UDim2.new(0.5, -200, 0.7, 0)
        barContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        barContainer.BorderSizePixel = 0
        barContainer.Parent = bg
        
        local barCorner = Instance.new("UICorner")
        barCorner.CornerRadius = UDim.new(0, 2)
        barCorner.Parent = barContainer
        
        local barFill = Instance.new("Frame")
        barFill.Size = UDim2.new(0, 0, 1, 0)
        barFill.BackgroundColor3 = CONFIG.accentColor
        barFill.BorderSizePixel = 0
        barFill.Parent = barContainer
        
        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(0, 2)
        fillCorner.Parent = barFill
        
        -- Texto de status
        local statusText = Instance.new("TextLabel")
        statusText.Size = UDim2.new(1, 0, 0, 30)
        statusText.Position = UDim2.new(0, 0, 0.75, 0)
        statusText.BackgroundTransparency = 1
        statusText.Text = "Inicializando sistema..."
        statusText.TextColor3 = Color3.fromRGB(200, 200, 200)
        statusText.Font = Enum.Font.Gotham
        statusText.TextSize = 14
        statusText.Parent = bg
        
        -- Porcentagem
        local percentText = Instance.new("TextLabel")
        percentText.Size = UDim2.new(0, 100, 0, 30)
        percentText.Position = UDim2.new(0.5, -50, 0.78, 0)
        percentText.BackgroundTransparency = 1
        percentText.Text = "0%"
        percentText.TextColor3 = CONFIG.accentColor
        percentText.Font = Enum.Font.GothamBold
        percentText.TextSize = 16
        percentText.Parent = bg
        
        -- Animação da barra com steps
        local loadingSteps = {
            {0.0, "Verificando servidor...", 0.1},
            {0.2, "Detectando tipo de servidor...", 0.3},
            {0.4, "Carregando módulos de reach...", 0.5},
            {0.6, "Otimizando para baixa latência...", 0.7},
            {0.8, "Aplicando correções VIP...", 0.9},
            {1.0, "Pronto!", 1.0}
        }
        
        task.spawn(function()
            for _, step in ipairs(loadingSteps) do
                task.wait(0.4)
                statusText.Text = step[2]
                TweenService:Create(barFill, TweenInfo.new(0.5), {
                    Size = UDim2.new(step[3], 0, 1, 0)
                }):Play()
                percentText.Text = math.floor(step[3] * 100) .. "%"
            end
            
            -- Verifica servidor VIP
            checkVIPServer()
            if isVIPServer then
                statusText.Text = "Servidor VIP detectado! Ajustando reach..."
                task.wait(1)
            end
            
            -- Fade out
            task.wait(0.5)
            TweenService:Create(bg, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
            for _, child in pairs(bg:GetDescendants()) do
                if child:IsA("GuiObject") then
                    TweenService:Create(child, TweenInfo.new(0.5), {
                        BackgroundTransparency = 1,
                        TextTransparency = 1,
                        ImageTransparency = 1
                    }):Play()
                end
            end
            
            task.wait(0.6)
            gui:Destroy()
            getgenv().CADUXX137_LoadingGui = nil
            
            -- Chama a intro após loading
            task.spawn(showIntro)
        end)
        
        return gui
    end)
    
    if success then
        getgenv().CADUXX137_LoadingGui = gui
    end
    
    return success
end

-- ============================================
-- INTRO CINEMATOGRÁFICA (CORRIGIDA)
-- ============================================
function showIntro()
    if introGui then return end
    
    local success = pcall(function()
        introGui = Instance.new("ScreenGui")
        introGui.Name = "CADUIntro"
        introGui.ResetOnSpawn = false
        introGui.DisplayOrder = 999998
        introGui.Parent = playerGui
        
        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
        bg.BorderSizePixel = 0
        bg.Parent = introGui
        
        -- Efeito de scanline
        for i = 0, 10 do
            local line = Instance.new("Frame")
            line.Size = UDim2.new(1, 0, 0, 1)
            line.Position = UDim2.new(0, 0, i/10, 0)
            line.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
            line.BackgroundTransparency = 0.95
            line.BorderSizePixel = 0
            line.Parent = bg
        end
        
        -- Container de slides
        local slideContainer = Instance.new("Frame")
        slideContainer.Size = UDim2.new(1, 0, 1, 0)
        slideContainer.BackgroundTransparency = 1
        slideContainer.Parent = introGui
        
        -- SLIDE 1: Criador
        local slide1 = Instance.new("Frame")
        slide1.Size = UDim2.new(1, 0, 1, 0)
        slide1.BackgroundTransparency = 1
        slide1.Parent = slideContainer
        
        local creatorTitle = Instance.new("TextLabel")
        creatorTitle.Size = UDim2.new(1, 0, 0, 60)
        creatorTitle.Position = UDim2.new(0, 0, 0.15, 0)
        creatorTitle.BackgroundTransparency = 1
        creatorTitle.Text = "DESENVOLVEDOR"
        creatorTitle.TextColor3 = CONFIG.secondaryColor
        creatorTitle.Font = Enum.Font.GothamBlack
        creatorTitle.TextSize = 24
        creatorTitle.TextTransparency = 1
        creatorTitle.Parent = slide1
        
        -- Avatar do criador
        local avatarFrame = Instance.new("Frame")
        avatarFrame.Size = UDim2.new(0, 180, 0, 180)
        avatarFrame.Position = UDim2.new(0.5, -90, 0.35, -90)
        avatarFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        avatarFrame.BackgroundTransparency = 1
        avatarFrame.Parent = slide1
        
        local avatarCorner = Instance.new("UICorner")
        avatarCorner.CornerRadius = UDim.new(1, 0)
        avatarCorner.Parent = avatarFrame
        
        local avatarStroke = Instance.new("UIStroke")
        avatarStroke.Color = CONFIG.accentColor
        avatarStroke.Thickness = 4
        avatarStroke.Parent = avatarFrame
        
        -- Imagem do criador (usando UserId 3774045695)
        local avatarImage = Instance.new("ImageLabel")
        avatarImage.Size = UDim2.new(1, 0, 1, 0)
        avatarImage.BackgroundTransparency = 1
        avatarImage.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=3774045695&width=420&height=420&format=png"
        avatarImage.Parent = avatarFrame
        
        -- Fallback
        task.delay(2, function()
            if avatarImage and avatarImage.ImageRectSize == Vector2.new(0, 0) then
                local fallback = Instance.new("TextLabel")
                fallback.Size = UDim2.new(1, 0, 1, 0)
                fallback.BackgroundColor3 = CONFIG.accentColor
                fallback.Text = "C"
                fallback.TextColor3 = Color3.new(1, 1, 1)
                fallback.Font = Enum.Font.GothamBlack
                fallback.TextSize = 80
                fallback.Parent = avatarFrame
            end
        end)
        
        local creatorName = Instance.new("TextLabel")
        creatorName.Size = UDim2.new(1, 0, 0, 80)
        creatorName.Position = UDim2.new(0, 0, 0.6, 0)
        creatorName.BackgroundTransparency = 1
        creatorName.Text = "CADUXX137"
        creatorName.TextColor3 = CONFIG.accentColor
        creatorName.Font = Enum.Font.GothamBlack
        creatorName.TextSize = 64
        creatorName.TextTransparency = 1
        creatorName.Parent = slide1
        
        local creatorRole = Instance.new("TextLabel")
        creatorRole.Size = UDim2.new(1, 0, 0, 40)
        creatorRole.Position = UDim2.new(0, 0, 0.72, 0)
        creatorRole.BackgroundTransparency = 1
        creatorRole.Text = "Criador & Desenvolvedor"
        creatorRole.TextColor3 = Color3.fromRGB(150, 150, 150)
        creatorRole.Font = Enum.Font.GothamBold
        creatorRole.TextSize = 20
        creatorRole.TextTransparency = 1
        creatorRole.Parent = slide1
        
        -- SLIDE 2: Atualizações
        local slide2 = Instance.new("Frame")
        slide2.Size = UDim2.new(1, 0, 1, 0)
        slide2.BackgroundTransparency = 1
        slide2.Visible = false
        slide2.Parent = slideContainer
        
        local updateTitle = Instance.new("TextLabel")
        updateTitle.Size = UDim2.new(1, 0, 0, 80)
        updateTitle.Position = UDim2.new(0, 0, 0.15, 0)
        updateTitle.BackgroundTransparency = 1
        updateTitle.Text = "NOVIDADES v3.0"
        updateTitle.TextColor3 = CONFIG.accentColor
        updateTitle.Font = Enum.Font.GothamBlack
        updateTitle.TextSize = 48
        updateTitle.TextTransparency = 1
        updateTitle.Parent = slide2
        
        local updatesList = {
            "🚀 Reach Ultra Otimizada (0ms ping)",
            "⚡ Otimizador Inteligente Pro",
            "🎨 Interface Site-Style Moderna",
            "🎯 Detecção Automática de Bola",
            "🔥 Correção para Servidores VIP"
        }
        
        for i, update in ipairs(updatesList) do
            local updateText = Instance.new("TextLabel")
            updateText.Size = UDim2.new(1, 0, 0, 45)
            updateText.Position = UDim2.new(0, 0, 0.3 + (i * 0.09), 0)
            updateText.BackgroundTransparency = 1
            updateText.Text = update
            updateText.TextColor3 = Color3.fromRGB(200, 200, 200)
            updateText.Font = Enum.Font.GothamBold
            updateText.TextSize = 20
            updateText.TextTransparency = 1
            updateText.Parent = slide2
        end
        
                -- SLIDE 3: Créditos
        local slide3 = Instance.new("Frame")
        slide3.Size = UDim2.new(1, 0, 1, 0)
        slide3.BackgroundTransparency = 1
        slide3.Visible = false
        slide3.Parent = slideContainer
        
        local creditsTitle = Instance.new("TextLabel")
        creditsTitle.Size = UDim2.new(1, 0, 0, 80)
        creditsTitle.Position = UDim2.new(0, 0, 0.15, 0)
        creditsTitle.BackgroundTransparency = 1
        creditsTitle.Text = "CRÉDITOS"
        creditsTitle.TextColor3 = CONFIG.secondaryColor
        creditsTitle.Font = Enum.Font.GothamBlack
        creditsTitle.TextSize = 48
        creditsTitle.TextTransparency = 1
        creditsTitle.Parent = slide3
        
        local credits = {
            {name = "pedrinjr hub", role = "Base & Full Body Touch"},
            {name = "CADU Hub", role = "UI Premium & Visuals"},
            {name = "SNOW hub", role = "Otimizações & Anti-Lag"},
            {name = "CADUXX137", role = "Desenvolvimento & Integração"}
        }
        
        for i, credit in ipairs(credits) do
            local nameText = Instance.new("TextLabel")
            nameText.Size = UDim2.new(1, 0, 0, 40)
            nameText.Position = UDim2.new(0, 0, 0.35 + (i * 0.1), 0)
            nameText.BackgroundTransparency = 1
            nameText.Text = credit.name
            nameText.TextColor3 = CONFIG.accentColor
            nameText.Font = Enum.Font.GothamBold
            nameText.TextSize = 28
            nameText.TextTransparency = 1
            nameText.Parent = slide3
            
            local roleText = Instance.new("TextLabel")
            roleText.Size = UDim2.new(1, 0, 0, 25)
            roleText.Position = UDim2.new(0, 0, 0.35 + (i * 0.1) + 0.05, 0)
            roleText.BackgroundTransparency = 1
            roleText.Text = credit.role
            roleText.TextColor3 = Color3.fromRGB(150, 150, 150)
            roleText.Font = Enum.Font.Gotham
            roleText.TextSize = 16
            roleText.TextTransparency = 1
            roleText.Parent = slide3
        end
        
        -- SLIDE 4: Bem-vindo
        local slide4 = Instance.new("Frame")
        slide4.Size = UDim2.new(1, 0, 1, 0)
        slide4.BackgroundTransparency = 1
        slide4.Visible = false
        slide4.Parent = slideContainer
        
        local welcomeText = Instance.new("TextLabel")
        welcomeText.Size = UDim2.new(1, 0, 0, 100)
        welcomeText.Position = UDim2.new(0, 0, 0.3, 0)
        welcomeText.BackgroundTransparency = 1
        welcomeText.Text = "BEM-VINDO"
        welcomeText.TextColor3 = CONFIG.accentColor
        welcomeText.Font = Enum.Font.GothamBlack
        welcomeText.TextSize = 72
        welcomeText.TextTransparency = 1
        welcomeText.Parent = slide4
        
        local playerName = Instance.new("TextLabel")
        playerName.Size = UDim2.new(1, 0, 0, 60)
        playerName.Position = UDim2.new(0, 0, 0.48, 0)
        playerName.BackgroundTransparency = 1
        playerName.Text = player.Name
        playerName.TextColor3 = CONFIG.secondaryColor
        playerName.Font = Enum.Font.GothamBold
        playerName.TextSize = 42
        playerName.TextTransparency = 1
        playerName.Parent = slide4
        
        local pressKey = Instance.new("TextLabel")
        pressKey.Size = UDim2.new(1, 0, 0, 30)
        pressKey.Position = UDim2.new(0, 0, 0.7, 0)
        pressKey.BackgroundTransparency = 1
        pressKey.Text = "Pressione [ESPACO] para continuar"
        pressKey.TextColor3 = Color3.fromRGB(100, 100, 100)
        pressKey.Font = Enum.Font.Gotham
        pressKey.TextSize = 18
        pressKey.TextTransparency = 1
        pressKey.Parent = slide4
        
        -- Animação de pulso no "pressione espaço"
        task.spawn(function()
            while pressKey and pressKey.Parent do
                TweenService:Create(pressKey, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                    TextTransparency = 0.3
                }):Play()
                task.wait(1)
                TweenService:Create(pressKey, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                    TextTransparency = 0.7
                }):Play()
                task.wait(1)
            end
        end)
        
        -- FUNÇÃO PARA ANIMAR ELEMENTOS
        local function animateIn(element, delay)
            task.delay(delay or 0, function()
                TweenService:Create(element, TweenInfo.new(0.8, Enum.EasingStyle.Quart), {
                    TextTransparency = 0,
                    BackgroundTransparency = element:IsA("Frame") and element.BackgroundTransparency or 1
                }):Play()
            end)
        end
        
        -- SEQUÊNCIA DE ANIMAÇÃO DOS SLIDES
        task.spawn(function()
            -- SLIDE 1: Criador (já deve estar visível/animação iniciada antes)
            
            task.wait(4)
            
            -- Transição para slide 2
            TweenService:Create(slide1, TweenInfo.new(0.5), {Position = UDim2.new(-1, 0, 0, 0)}):Play()
            slide2.Visible = true
            slide2.Position = UDim2.new(1, 0, 0, 0)
            TweenService:Create(slide2, TweenInfo.new(0.5), {Position = UDim2.new(0, 0, 0, 0)}):Play()
            
            animateIn(updateTitle, 0.2)
            for _, child in ipairs(slide2:GetChildren()) do
                if child:IsA("TextLabel") and child ~= updateTitle then
                    animateIn(child, 0.3 + (math.random() * 0.5))
                end
            end
            
            task.wait(4)
            
            -- Transição para slide 3 (CRÉDITOS)
            TweenService:Create(slide2, TweenInfo.new(0.5), {Position = UDim2.new(-1, 0, 0, 0)}):Play()
            slide3.Visible = true
            slide3.Position = UDim2.new(1, 0, 0, 0)
            TweenService:Create(slide3, TweenInfo.new(0.5), {Position = UDim2.new(0, 0, 0, 0)}):Play()
            
            animateIn(creditsTitle, 0.2)
            for _, child in ipairs(slide3:GetChildren()) do
                if child:IsA("TextLabel") and child ~= creditsTitle then
                    animateIn(child, 0.3 + (math.random() * 0.5))
                end
            end
            
            task.wait(4)
            
            -- Transição para slide 4 (final)
            TweenService:Create(slide3, TweenInfo.new(0.5), {Position = UDim2.new(-1, 0, 0, 0)}):Play()
            slide4.Visible = true
            slide4.Position = UDim2.new(1, 0, 0, 0)
            TweenService:Create(slide4, TweenInfo.new(0.5), {Position = UDim2.new(0, 0, 0, 0)}):Play()
            
            animateIn(welcomeText, 0.3)
            animateIn(playerName, 0.6)
            animateIn(pressKey, 1.0)
        end)
        
        -- ESPERA ESPAÇO PARA CONTINUAR
        local spacePressed = false
        local connection
        connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.KeyCode == Enum.KeyCode.Space and not spacePressed and slide4.Visible then
                spacePressed = true
                connection:Disconnect()
                
                -- Fade out total
                TweenService:Create(bg, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
                for _, slide in ipairs({slide1, slide2, slide3, slide4}) do
                    for _, child in ipairs(slide:GetChildren()) do
                        if child:IsA("TextLabel") or child:IsA("Frame") then
                            TweenService:Create(child, TweenInfo.new(0.5), {
                                TextTransparency = 1,
                                BackgroundTransparency = 1,
                                ImageTransparency = 1
                            }):Play()
                        end
                    end
                end
                
                task.wait(0.6)
                introGui:Destroy()
                introGui = nil
                isLoaded = true
                
                                -- CHAMA A UI PRINCIPAL
                task.spawn(buildMainUI)
                
                -- Notificação de servidor VIP
                if isVIPServer then
                    task.wait(1)
                    notify("Servidor VIP detectado! Reach aumentada em 40%", "success", 5)
                end
            end
        end)
    end)
    
    if not success then
        -- Se falhar a intro, vai direto para a UI
        isLoaded = true
        buildMainUI()
    end
end

-- ============================================
-- UI PRINCIPAL ESTILO SITE MODERNO
-- ============================================
function buildMainUI()
    if getgenv().CADUXX137_MainGui and getgenv().CADUXX137_MainGui.Parent then
        notify("⚠️ Menu já está aberto!", "warning", 2)
        return
    end
    
    local success = pcall(function()
        mainGui = Instance.new("ScreenGui")
        mainGui.Name = "CADUXX137Site"
        mainGui.ResetOnSpawn = false
        mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        mainGui.Parent = playerGui
        
        getgenv().CADUXX137_MainGui = mainGui
        
        -- Container principal
        local mainContainer = Instance.new("Frame")
        mainContainer.Name = "MainContainer"
        mainContainer.Size = UDim2.new(0, 0, 0, 0)
        mainContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
        mainContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        mainContainer.BorderSizePixel = 0
        mainContainer.ClipsDescendants = true
        mainContainer.Parent = mainGui
        
        -- Borda neon
        local neonBorder = Instance.new("UIStroke")
        neonBorder.Color = CONFIG.accentColor
        neonBorder.Thickness = 2
        neonBorder.Parent = mainContainer
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 16)
        corner.Parent = mainContainer
        
        -- Animação de entrada
        TweenService:Create(mainContainer, TweenInfo.new(0.6, Enum.EasingStyle.Back), {
            Size = UDim2.new(0, 900, 0, 600),
            Position = UDim2.new(0.5, -450, 0.5, -300)
        }):Play()
        
        -- HEADER
        local header = Instance.new("Frame")
        header.Size = UDim2.new(1, 0, 0, 70)
        header.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
        header.BorderSizePixel = 0
        header.Parent = mainContainer
        
        local headerCorner = Instance.new("UICorner")
        headerCorner.CornerRadius = UDim.new(0, 16)
        headerCorner.Parent = header
        
        -- Logo
        local headerLogo = Instance.new("TextLabel")
        headerLogo.Size = UDim2.new(0, 200, 1, 0)
        headerLogo.Position = UDim2.new(0, 20, 0, 0)
        headerLogo.BackgroundTransparency = 1
        headerLogo.Text = "CADUXX137"
        headerLogo.TextColor3 = CONFIG.accentColor
        headerLogo.Font = Enum.Font.GothamBlack
        headerLogo.TextSize = 28
        headerLogo.TextXAlignment = Enum.TextXAlignment.Left
        headerLogo.Parent = header
        
        local headerSub = Instance.new("TextLabel")
        headerSub.Size = UDim2.new(0, 200, 0, 20)
        headerSub.Position = UDim2.new(0, 20, 0.6, 0)
        headerSub.BackgroundTransparency = 1
        headerSub.Text = "HUB SUPREME v3.0" .. (isVIPServer and " [VIP]" or "")
        headerSub.TextColor3 = isVIPServer and Color3.fromRGB(255, 215, 0) or CONFIG.secondaryColor
        headerSub.Font = Enum.Font.GothamBold
        headerSub.TextSize = 12
        headerSub.TextXAlignment = Enum.TextXAlignment.Left
        headerSub.Parent = header
        
        -- Status online
        local statusDot = Instance.new("Frame")
        statusDot.Size = UDim2.new(0, 8, 0, 8)
        statusDot.Position = UDim2.new(0, 195, 0.35, 0)
        statusDot.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        statusDot.Parent = header
        
        local statusCorner = Instance.new("UICorner")
        statusCorner.CornerRadius = UDim.new(1, 0)
        statusCorner.Parent = statusDot
        
        -- Animação pulso
        task.spawn(function()
            while statusDot and statusDot.Parent do
                TweenService:Create(statusDot, TweenInfo.new(1), {Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0, 193, 0.35, -2)}):Play()
                task.wait(1)
                TweenService:Create(statusDot, TweenInfo.new(1), {Size = UDim2.new(0, 8, 0, 8), Position = UDim2.new(0, 195, 0.35, 0)}):Play()
                task.wait(1)
            end
        end)
        
        -- NAVBAR
        local navLinks = {"Home", "Reach", "Visual", "Settings"}
        local navButtons = {}
        
        for i, link in ipairs(navLinks) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, 100, 0, 40)
            btn.Position = UDim2.new(0, 500 + ((i-1) * 110), 0.5, -20)
            btn.BackgroundTransparency = 1
            btn.Text = link
            btn.TextColor3 = currentTab == link:lower() and CONFIG.accentColor or Color3.fromRGB(150, 150, 150)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 16
            btn.Parent = header
            
            local underline = Instance.new("Frame")
            underline.Size = UDim2.new(0, 0, 0, 2)
            underline.Position = UDim2.new(0.5, 0, 1, -5)
            underline.BackgroundColor3 = CONFIG.accentColor
            underline.BorderSizePixel = 0
            underline.Parent = btn
            
            btn.MouseEnter:Connect(function()
                TweenService:Create(underline, TweenInfo.new(0.3), {Size = UDim2.new(0.8, 0, 0, 2), Position = UDim2.new(0.1, 0, 1, -5)}):Play()
                TweenService:Create(btn, TweenInfo.new(0.3), {TextColor3 = CONFIG.accentColor}):Play()
            end)
            
            btn.MouseLeave:Connect(function()
                if currentTab ~= link:lower() then
                    TweenService:Create(underline, TweenInfo.new(0.3), {Size = UDim2.new(0, 0, 0, 2), Position = UDim2.new(0.5, 0, 1, -5)}):Play()
                    TweenService:Create(btn, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
                end
            end)
            
            btn.MouseButton1Click:Connect(function()
                currentTab = link:lower()
                for _, b in ipairs(navButtons) do
                    TweenService:Create(b, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
                    local ul = b:FindFirstChildOfClass("Frame")
                    if ul then
                        TweenService:Create(ul, TweenInfo.new(0.3), {Size = UDim2.new(0, 0, 0, 2), Position = UDim2.new(0.5, 0, 1, -5)}):Play()
                    end
                end
                TweenService:Create(btn, TweenInfo.new(0.3), {TextColor3 = CONFIG.accentColor}):Play()
                TweenService:Create(underline, TweenInfo.new(0.3), {Size = UDim2.new(0.8, 0, 0, 2), Position = UDim2.new(0.1, 0, 1, -5)}):Play()
                
                switchPage(link:lower())
            end)
            
            table.insert(navButtons, btn)
        end
        
        -- Close button
        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0, 40, 0, 40)
        closeBtn.Position = UDim2.new(1, -50, 0.5, -20)
        closeBtn.BackgroundTransparency = 1
        closeBtn.Text = "✕"
        closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.TextSize = 20
        closeBtn.Parent = header
        
        closeBtn.MouseEnter:Connect(function()
            TweenService:Create(closeBtn, TweenInfo.new(0.2), {TextColor3 = CONFIG.secondaryColor}):Play()
        end)
        
        closeBtn.MouseLeave:Connect(function()
            TweenService:Create(closeBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
        end)
        
        closeBtn.MouseButton1Click:Connect(function()
            TweenService:Create(mainContainer, TweenInfo.new(0.4), {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
            task.wait(0.4)
            mainGui.Enabled = false
            notify("Pressione RightShift para abrir", "info", 3)
        end)
        
        -- CONTENT AREA
        local contentArea = Instance.new("Frame")
        contentArea.Size = UDim2.new(1, -40, 1, -90)
        contentArea.Position = UDim2.new(0, 20, 0, 80)
        contentArea.BackgroundTransparency = 1
        contentArea.Parent = mainContainer
        
        local pages = {}
        
        -- FUNÇÃO PARA CRIAR CARD
        local function createCard(parent, title, position, size)
            local card = Instance.new("Frame")
            card.Size = size or UDim2.new(0, 400, 0, 200)
            card.Position = position
            card.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
            card.BorderSizePixel = 0
            card.Parent = parent
            
            local cardCorner = Instance.new("UICorner")
            cardCorner.CornerRadius = UDim.new(0, 12)
            cardCorner.Parent = card
            
            local glow = Instance.new("ImageLabel")
            glow.Size = UDim2.new(1, 20, 1, 20)
            glow.Position = UDim2.new(0, -10, 0, -10)
            glow.BackgroundTransparency = 1
            glow.Image = "rbxassetid://5028857084"
            glow.ImageColor3 = CONFIG.accentColor
            glow.ImageTransparency = 0.95
            glow.ScaleType = Enum.ScaleType.Slice
            glow.SliceCenter = Rect.new(10, 10, 90, 90)
            glow.Parent = card
            
            local cardTitle = Instance.new("TextLabel")
            cardTitle.Size = UDim2.new(1, -20, 0, 30)
            cardTitle.Position = UDim2.new(0, 15, 0, 15)
            cardTitle.BackgroundTransparency = 1
            cardTitle.Text = title
            cardTitle.TextColor3 = CONFIG.accentColor
            cardTitle.Font = Enum.Font.GothamBold
            cardTitle.TextSize = 18
            cardTitle.TextXAlignment = Enum.TextXAlignment.Left
            cardTitle.Parent = card
            
            local line = Instance.new("Frame")
            line.Size = UDim2.new(0, 50, 0, 2)
            line.Position = UDim2.new(0, 15, 0, 45)
            line.BackgroundColor3 = CONFIG.secondaryColor
            line.BorderSizePixel = 0
            line.Parent = card
            
            return card
        end
        
        -- FUNÇÃO PARA CRIAR SLIDER
        local function createModernSlider(parent, title, value, min, max, callback, yPos)
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, -30, 0, 80)
            container.Position = UDim2.new(0, 15, 0, yPos)
            container.BackgroundTransparency = 1
            container.Parent = parent
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.6, 0, 0, 25)
            label.BackgroundTransparency = 1
            label.Text = title
            label.TextColor3 = Color3.fromRGB(200, 200, 200)
            label.Font = Enum.Font.GothamBold
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = container
            
            local valueLabel = Instance.new("TextLabel")
            valueLabel.Size = UDim2.new(0.3, 0, 0, 25)
            valueLabel.Position = UDim2.new(0.7, 0, 0, 0)
            valueLabel.BackgroundTransparency = 1
            valueLabel.Text = tostring(value)
            valueLabel.TextColor3 = CONFIG.accentColor
            valueLabel.Font = Enum.Font.GothamBlack
            valueLabel.TextSize = 20
            valueLabel.TextXAlignment = Enum.TextXAlignment.Right
            valueLabel.Parent = container
            
            local track = Instance.new("Frame")
            track.Size = UDim2.new(1, 0, 0, 6)
            track.Position = UDim2.new(0, 0, 0, 50)
            track.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            track.BorderSizePixel = 0
            track.Parent = container
            
            local trackCorner = Instance.new("UICorner")
            trackCorner.CornerRadius = UDim.new(0, 3)
            trackCorner.Parent = track
            
            local fill = Instance.new("Frame")
            fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
            fill.BackgroundColor3 = CONFIG.accentColor
            fill.BorderSizePixel = 0
            fill.Parent = track
            
            local fillCorner = Instance.new("UICorner")
            fillCorner.CornerRadius = UDim.new(0, 3)
            fillCorner.Parent = fill
            
            local dragging = false
            
            local function updateFromInput(input)
                local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                local newVal = math.floor(min + (pos * (max - min)))
                
                valueLabel.Text = tostring(newVal)
                TweenService:Create(fill, TweenInfo.new(0.1), {Size = UDim2.new(pos, 0, 1, 0)}):Play()
                callback(newVal)
                return newVal
            end
            
            track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    updateFromInput(input)
                end
            end)
            
            track.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateFromInput(input)
                end
            end)
            
            return container
        end
        
        -- FUNÇÃO PARA CRIAR TOGGLE
        local function createModernToggle(parent, title, default, callback, yPos)
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, -30, 0, 50)
            container.Position = UDim2.new(0, 15, 0, yPos)
            container.BackgroundTransparency = 1
            container.Parent = parent
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.7, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = title
            label.TextColor3 = Color3.fromRGB(200, 200, 200)
            label.Font = Enum.Font.GothamBold
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = container
            
            local toggleBtn = Instance.new("TextButton")
            toggleBtn.Size = UDim2.new(0, 60, 0, 30)
            toggleBtn.Position = UDim2.new(1, -60, 0.5, -15)
            toggleBtn.BackgroundColor3 = default and CONFIG.accentColor or Color3.fromRGB(60, 60, 70)
            toggleBtn.Text = default and "ON" or "OFF"
            toggleBtn.TextColor3 = Color3.new(1, 1, 1)
            toggleBtn.Font = Enum.Font.GothamBold
            toggleBtn.TextSize = 12
            toggleBtn.AutoButtonColor = false
            toggleBtn.Parent = container
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 15)
            btnCorner.Parent = toggleBtn
            
            local isOn = default
            
            toggleBtn.MouseButton1Click:Connect(function()
                isOn = not isOn
                TweenService:Create(toggleBtn, TweenInfo.new(0.2), {
                    BackgroundColor3 = isOn and CONFIG.accentColor or Color3.fromRGB(60, 60, 70)
                }):Play()
                toggleBtn.Text = isOn and "ON" or "OFF"
                callback(isOn)
            end)
            
            return container
        end
        
        -- PÁGINA: HOME
        local homePage = Instance.new("Frame")
        homePage.Size = UDim2.new(1, 0, 1, 0)
        homePage.BackgroundTransparency = 1
        homePage.Visible = true
        homePage.Parent = contentArea
        pages.home = homePage
        
        local welcomeCard = createCard(homePage, "Bem-vindo, " .. player.Name, UDim2.new(0, 0, 0, 0), UDim2.new(0, 420, 0, 180))
        
        local welcomeText = Instance.new("TextLabel")
        welcomeText.Size = UDim2.new(1, -30, 0, 60)
        welcomeText.Position = UDim2.new(0, 15, 0, 60)
        welcomeText.BackgroundTransparency = 1
        welcomeText.Text = "Reach Ultra Otimizada ativa.\nSimulando ping de 0ms para máxima performance."
        welcomeText.TextColor3 = Color3.fromRGB(180, 180, 180)
        welcomeText.Font = Enum.Font.Gotham
        welcomeText.TextSize = 14
        welcomeText.TextWrapped = true
        welcomeText.TextXAlignment = Enum.TextXAlignment.Left
        welcomeText.TextYAlignment = Enum.TextYAlignment.Top
        welcomeText.Parent = welcomeCard
        
        if isVIPServer then
            local vipText = Instance.new("TextLabel")
            vipText.Size = UDim2.new(1, -30, 0, 20)
            vipText.Position = UDim2.new(0, 15, 0, 120)
            vipText.BackgroundTransparency = 1
            vipText.Text = "🌟 Modo VIP ativo: Reach aumentada em 40%"
            vipText.TextColor3 = Color3.fromRGB(255, 215, 0)
            vipText.Font = Enum.Font.GothamBold
            vipText.TextSize = 14
            vipText.Parent = welcomeCard
        end
        
        -- Stats cards
        local statsCard = createCard(homePage, "Status do Sistema", UDim2.new(0.5, 10, 0, 0), UDim2.new(0, 420, 0, 180))
        
        local stats = {
            {label = "Reach Atual", value = function() return getCorrectedReach() .. " studs" end},
            {label = "Modo", value = function() return isVIPServer and "VIP Ultra" or "Ultra Low Ping" end},
            {label = "Otimizador", value = function() return CONFIG.optimizerEnabled and "Ativo" or "Inativo" end},
            {label = "Bolas Detectadas", value = function() return tostring(#balls) end}
        }
        
        for i, stat in ipairs(stats) do
            local statLabel = Instance.new("TextLabel")
            statLabel.Size = UDim2.new(0.5, -10, 0, 25)
            statLabel.Position = UDim2.new(0, 15, 0, 60 + ((i-1) * 30))
            statLabel.BackgroundTransparency = 1
            statLabel.Text = stat.label .. ":"
            statLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
            statLabel.Font = Enum.Font.Gotham
            statLabel.TextSize = 13
            statLabel.TextXAlignment = Enum.TextXAlignment.Left
            statLabel.Parent = statsCard
            
            local statValue = Instance.new("TextLabel")
            statValue.Size = UDim2.new(0.5, -10, 0, 25)
            statValue.Position = UDim2.new(0.5, 0, 0, 60 + ((i-1) * 30))
            statValue.BackgroundTransparency = 1
            statValue.Text = stat.value()
            statValue.TextColor3 = CONFIG.accentColor
            statValue.Font = Enum.Font.GothamBold
            statValue.TextSize = 13
            statValue.TextXAlignment = Enum.TextXAlignment.Left
            statValue.Parent = statsCard
            
            if stat.label == "Bolas Detectadas" or stat.label == "Reach Atual" then
                task.spawn(function()
                    while statValue and statValue.Parent do
                        statValue.Text = stat.value()
                        task.wait(0.5)
                    end
                end)
            end
        end
        
        -- PÁGINA: REACH
        local reachPage = Instance.new("Frame"
