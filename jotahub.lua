-- ============================================
-- CADUXX137 UI - MOBILE OPTIMIZED v4.0
-- ============================================

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
local CoreGui = game:GetService("CoreGui")

-- JOGADOR
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- VARIÁVEIS GLOBAIS
getgenv().CADUXX137_MainGui = nil
getgenv().CADUXX137_LoadingGui = nil

-- ESTADO
local isLoaded = false
local currentTab = "home"
local mainGui = nil
local loadingGui = nil

-- DETECTAR MOBILE
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local screenSize = workspace.CurrentCamera.ViewportSize

-- CONFIGURAÇÕES RESPONSIVAS
local UI_SCALE = math.min(screenSize.X / 900, screenSize.Y / 600, 1)
if isMobile then
    UI_SCALE = math.min(screenSize.X / 380, screenSize.Y / 680, 0.95)
end

local CONFIG = {
    accentColor = Color3.fromRGB(0, 170, 255),
    secondaryColor = Color3.fromRGB(138, 43, 226),
    reach = 25,
    ballReach = 10,
    quantumReach = 15,
    fullBodyTouch = true,
    autoTouch = true,
    showVisuals = true,
    showReachSphere = false, -- Desativado por padrão no mobile
    flashEnabled = false,    -- Desativado por padrão no mobile
    expandBallHitbox = true,
    optimizerEnabled = true,
    scanRate = 0.05,         -- Mais lento no mobile para economizar bateria
    reactionTime = 0,
    antiAFK = true,
    ballNames = {"Ball", "Bola", "SoccerBall", "Football", "Basketball", "Baseball", "Balloon", "BeachBall"}
}

-- VARIÁVEIS DO SISTEMA
local HRP = nil
local balls = {}
local ballHitboxes = {}
local touchCache = {}
local lastScan = 0
local isVIPServer = false

-- ============================================
-- FUNÇÃO DE NOTIFICAÇÃO MOBILE
-- ============================================
local function notify(message, notifyType, duration)
    duration = duration or 2
    notifyType = notifyType or "info"
    
    pcall(function()
        local notifGui = Instance.new("ScreenGui")
        notifGui.Name = "CADU_Notif_" .. tostring(tick())
        notifGui.ResetOnSpawn = false
        notifGui.Parent = playerGui
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 280 * UI_SCALE, 0, 45 * UI_SCALE)
        frame.Position = UDim2.new(0.5, -140 * UI_SCALE, 0, -60)
        frame.BackgroundColor3 = notifyType == "success" and Color3.fromRGB(0, 200, 0) 
            or notifyType == "error" and Color3.fromRGB(200, 50, 50) 
            or Color3.fromRGB(0, 100, 200)
        frame.BorderSizePixel = 0
        frame.Parent = notifGui
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8 * UI_SCALE)
        corner.Parent = frame
        
        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1, 0, 1, 0)
        text.Text = message
        text.TextColor3 = Color3.fromRGB(255, 255, 255)
        text.Font = Enum.Font.GothamBold
        text.TextSize = 12 * UI_SCALE
        text.BackgroundTransparency = 1
        text.Parent = frame
        
        TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
            Position = UDim2.new(0.5, -140 * UI_SCALE, 0, 15)
        }):Play()
        
        task.delay(duration, function()
            pcall(function()
                TweenService:Create(frame, TweenInfo.new(0.3), {
                    Position = UDim2.new(0.5, -140 * UI_SCALE, 0, -60),
                    BackgroundTransparency = 1
                }):Play()
                task.wait(0.3)
                notifGui:Destroy()
            end)
        end)
    end)
end

-- ============================================
-- CHECK VIP SERVER
-- ============================================
local function checkVIPServer()
    pcall(function()
        if game.PrivateServerId ~= "" and game.PrivateServerId ~= nil then
            isVIPServer = true
        end
    end)
    if #Players:GetPlayers() <= 3 then
        isVIPServer = true
    end
    return isVIPServer
end

local function getCorrectedReach()
    return isVIPServer and CONFIG.reach * 1.4 or CONFIG.reach
end

local function getCorrectedBallReach()
    return isVIPServer and CONFIG.ballReach * 1.5 or CONFIG.ballReach
end

-- ============================================
-- LOADING SCREEN OTIMIZADO
-- ============================================
local function showLoadingScreen()
    if getgenv().CADUXX137_LoadingGui then
        pcall(function() getgenv().CADUXX137_LoadingGui:Destroy() end)
    end
    
    local success, gui = pcall(function()
        local gui = Instance.new("ScreenGui")
        gui.Name = "CADU_Loading"
        gui.ResetOnSpawn = false
        gui.DisplayOrder = 999999
        gui.Parent = playerGui
        
        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
        bg.BorderSizePixel = 0
        bg.Parent = gui
        
        -- Partículas reduzidas para mobile
        local particleCount = isMobile and 8 or 15
        for i = 1, particleCount do
            local particle = Instance.new("Frame")
            particle.Size = UDim2.new(0, math.random(2, 4), 0, math.random(2, 4))
            particle.Position = UDim2.new(math.random(), 0, math.random(), 0)
            particle.BackgroundColor3 = CONFIG.accentColor
            particle.BackgroundTransparency = 0.8
            particle.BorderSizePixel = 0
            particle.Parent = bg
            
            TweenService:Create(particle, TweenInfo.new(math.random(3, 6), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1), {
                Position = UDim2.new(particle.Position.X.Scale, math.random(-30, 30), particle.Position.Y.Scale + 0.15, 0)
            }):Play()
        end
        
        -- Logo container
        local logoContainer = Instance.new("Frame")
        logoContainer.Size = UDim2.new(0, 150 * UI_SCALE, 0, 150 * UI_SCALE)
        logoContainer.Position = UDim2.new(0.5, -75 * UI_SCALE, 0.4, -75 * UI_SCALE)
        logoContainer.BackgroundTransparency = 1
        logoContainer.Parent = bg
        
        -- Círculo rotativo
        local circle = Instance.new("Frame")
        circle.Size = UDim2.new(1, 0, 1, 0)
        circle.BackgroundTransparency = 1
        circle.Parent = logoContainer
        
        local circleStroke = Instance.new("UIStroke")
        circleStroke.Color = CONFIG.accentColor
        circleStroke.Thickness = 2 * UI_SCALE
        circleStroke.Parent = circle
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = circle
        
        TweenService:Create(circle, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {
            Rotation = 360
        }):Play()
        
        -- Texto
        local logoText = Instance.new("TextLabel")
        logoText.Size = UDim2.new(1, 0, 0, 40 * UI_SCALE)
        logoText.Position = UDim2.new(0, 0, 0.5, -20 * UI_SCALE)
        logoText.BackgroundTransparency = 1
        logoText.Text = "CADUXX137"
        logoText.TextColor3 = CONFIG.accentColor
        logoText.Font = Enum.Font.GothamBlack
        logoText.TextSize = 28 * UI_SCALE
        logoText.Parent = logoContainer
        
        -- Barra de progresso
        local barContainer = Instance.new("Frame")
        barContainer.Size = UDim2.new(0, 250 * UI_SCALE, 0, 3 * UI_SCALE)
        barContainer.Position = UDim2.new(0.5, -125 * UI_SCALE, 0.65, 0)
        barContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        barContainer.BorderSizePixel = 0
        barContainer.Parent = bg
        
        local barCorner = Instance.new("UICorner")
        barCorner.CornerRadius = UDim.new(0, 2 * UI_SCALE)
        barCorner.Parent = barContainer
        
        local barFill = Instance.new("Frame")
        barFill.Size = UDim2.new(0, 0, 1, 0)
        barFill.BackgroundColor3 = CONFIG.accentColor
        barFill.BorderSizePixel = 0
        barFill.Parent = barContainer
        
        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(0, 2 * UI_SCALE)
        fillCorner.Parent = barFill
        
        -- Status
        local statusText = Instance.new("TextLabel")
        statusText.Size = UDim2.new(1, 0, 0, 25 * UI_SCALE)
        statusText.Position = UDim2.new(0, 0, 0.7, 0)
        statusText.BackgroundTransparency = 1
        statusText.Text = "Inicializando..."
        statusText.TextColor3 = Color3.fromRGB(200, 200, 200)
        statusText.Font = Enum.Font.Gotham
        statusText.TextSize = 12 * UI_SCALE
        statusText.Parent = bg
        
        -- Animação rápida
        task.spawn(function()
            local steps = {"Carregando...", "Verificando servidor...", "Otimizando...", "Quase pronto..."}
            for i, step in ipairs(steps) do
                statusText.Text = step
                TweenService:Create(barFill, TweenInfo.new(0.4), {
                    Size = UDim2.new(i / #steps, 0, 1, 0)
                }):Play()
                task.wait(0.5)
            end
            
            checkVIPServer()
            
            -- Fade out rápido
            TweenService:Create(bg, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
            for _, child in pairs(bg:GetDescendants()) do
                if child:IsA("GuiObject") then
                    TweenService:Create(child, TweenInfo.new(0.4), {
                        BackgroundTransparency = 1,
                        TextTransparency = 1,
                        ImageTransparency = 1
                    }):Play()
                end
            end
            
            task.wait(0.5)
            gui:Destroy()
            getgenv().CADUXX137_LoadingGui = nil
            
            -- Chama UI direto (sem intro no mobile para ser mais rápido)
            task.spawn(buildMainUI)
        end)
        
        return gui
    end)
    
    if success then
        getgenv().CADUXX137_LoadingGui = gui
    end
end

-- ============================================
-- UI PRINCIPAL MOBILE OTIMIZADA
-- ============================================
function buildMainUI()
    if getgenv().CADUXX137_MainGui and getgenv().CADUXX137_MainGui.Parent then
        getgenv().CADUXX137_MainGui:Destroy()
    end
    
    local success = pcall(function()
        mainGui = Instance.new("ScreenGui")
        mainGui.Name = "CADUXX137_Mobile"
        mainGui.ResetOnSpawn = false
        mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        mainGui.Parent = playerGui
        
        getgenv().CADUXX137_MainGui = mainGui
        
        -- Tamanho baseado no mobile
        local baseWidth = isMobile and 340 or 800
        local baseHeight = isMobile and 500 or 500
        
        -- Container principal com escala
        local mainContainer = Instance.new("Frame")
        mainContainer.Name = "MainContainer"
        mainContainer.Size = UDim2.new(0, 0, 0, 0)
        mainContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
        mainContainer.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
        mainContainer.BorderSizePixel = 0
        mainContainer.ClipsDescendants = true
        mainContainer.Parent = mainGui
        
        -- Borda neon
        local neonBorder = Instance.new("UIStroke")
        neonBorder.Color = CONFIG.accentColor
        neonBorder.Thickness = 1.5 * UI_SCALE
        neonBorder.Parent = mainContainer
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 12 * UI_SCALE)
        corner.Parent = mainContainer
        
        -- Animação de entrada
        TweenService:Create(mainContainer, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
            Size = UDim2.new(0, baseWidth * UI_SCALE, 0, baseHeight * UI_SCALE),
            Position = UDim2.new(0.5, -(baseWidth * UI_SCALE) / 2, 0.5, -(baseHeight * UI_SCALE) / 2)
        }):Play()
        
        -- HEADER COMPACTO
        local header = Instance.new("Frame")
        header.Size = UDim2.new(1, 0, 0, 50 * UI_SCALE)
        header.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
        header.BorderSizePixel = 0
        header.Parent = mainContainer
        
        local headerCorner = Instance.new("UICorner")
        headerCorner.CornerRadius = UDim.new(0, 12 * UI_SCALE)
        headerCorner.Parent = header
        
        -- Logo
        local headerLogo = Instance.new("TextLabel")
        headerLogo.Size = UDim2.new(0, 150 * UI_SCALE, 1, 0)
        headerLogo.Position = UDim2.new(0, 12 * UI_SCALE, 0, 0)
        headerLogo.BackgroundTransparency = 1
        headerLogo.Text = "CADUXX137"
        headerLogo.TextColor3 = CONFIG.accentColor
        headerLogo.Font = Enum.Font.GothamBlack
        headerLogo.TextSize = 18 * UI_SCALE
        headerLogo.TextXAlignment = Enum.TextXAlignment.Left
        headerLogo.Parent = header
        
        -- Versão/VIP
        local headerSub = Instance.new("TextLabel")
        headerSub.Size = UDim2.new(0, 100 * UI_SCALE, 0, 15 * UI_SCALE)
        headerSub.Position = UDim2.new(0, 12 * UI_SCALE, 0.6, 0)
        headerSub.BackgroundTransparency = 1
        headerSub.Text = isVIPServer and "🔥 VIP MODE" or "v4.0 Mobile"
        headerSub.TextColor3 = isVIPServer and Color3.fromRGB(255, 215, 0) or CONFIG.secondaryColor
        headerSub.Font = Enum.Font.GothamBold
        headerSub.TextSize = 9 * UI_SCALE
        headerSub.TextXAlignment = Enum.TextXAlignment.Left
        headerSub.Parent = header
        
        -- Botão fechar (X)
        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0, 30 * UI_SCALE, 0, 30 * UI_SCALE)
        closeBtn.Position = UDim2.new(1, -38 * UI_SCALE, 0.5, -15 * UI_SCALE)
        closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        closeBtn.Text = "✕"
        closeBtn.TextColor3 = Color3.new(1, 1, 1)
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.TextSize = 12 * UI_SCALE
        closeBtn.AutoButtonColor = false
        closeBtn.Parent = header
        
        local closeCorner = Instance.new("UICorner")
        closeCorner.CornerRadius = UDim.new(0, 6 * UI_SCALE)
        closeCorner.Parent = closeBtn
        
        closeBtn.MouseButton1Click:Connect(function()
            TweenService:Create(mainContainer, TweenInfo.new(0.3), {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0)
            }):Play()
            task.wait(0.3)
            mainGui.Enabled = false
            toggleButton.Visible = true
        end)
        
        -- BOTÃO TOGGLE FLUTUANTE (para reabrir)
        local toggleButton = Instance.new("TextButton")
        toggleButton.Name = "ToggleBtn"
        toggleButton.Size = UDim2.new(0, 45 * UI_SCALE, 0, 45 * UI_SCALE)
        toggleButton.Position = UDim2.new(0, 10, 0.5, -22.5 * UI_SCALE)
        toggleButton.BackgroundColor3 = CONFIG.accentColor
        toggleButton.Text = "⚡"
        toggleButton.TextColor3 = Color3.new(1, 1, 1)
        toggleButton.Font = Enum.Font.GothamBold
        toggleButton.TextSize = 20 * UI_SCALE
        toggleButton.Visible = false
        toggleButton.Parent = mainGui
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(1, 0)
        toggleCorner.Parent = toggleButton
        
        -- Drag do botão toggle
        local dragging = false
        local dragStart, startPos
        
        toggleButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = toggleButton.Position
            end
        end)
        
        toggleButton.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
                local delta = input.Position - dragStart
                toggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        
        toggleButton.MouseButton1Click:Connect(function()
            if not dragging then
                mainGui.Enabled = true
                toggleButton.Visible = false
                TweenService:Create(mainContainer, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
                    Size = UDim2.new(0, baseWidth * UI_SCALE, 0, baseHeight * UI_SCALE),
                    Position = UDim2.new(0.5, -(baseWidth * UI_SCALE) / 2, 0.5, -(baseHeight * UI_SCALE) / 2)
                }):Play()
            end
        end)
        
        -- NAVBAR SIMPLIFICADA (Abas embaixo no mobile)
        local navFrame = Instance.new("Frame")
        navFrame.Size = UDim2.new(1, 0, 0, 45 * UI_SCALE)
        navFrame.Position = UDim2.new(0, 0, 1, -45 * UI_SCALE)
        navFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
        navFrame.BorderSizePixel = 0
        navFrame.Parent = mainContainer
        
        local navCorner = Instance.new("UICorner")
        navCorner.CornerRadius = UDim.new(0, 12 * UI_SCALE)
        navCorner.Parent = navFrame
        
        local navLinks = {"Home", "Reach", "Visual", "Set"}
        local navButtons = {}
        
        for i, link in ipairs(navLinks) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.25, 0, 1, 0)
            btn.Position = UDim2.new((i-1) * 0.25, 0, 0, 0)
            btn.BackgroundTransparency = 1
            btn.Text = link
            btn.TextColor3 = currentTab == link:lower() and CONFIG.accentColor or Color3.fromRGB(120, 120, 120)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 11 * UI_SCALE
            btn.Parent = navFrame
            
            -- Indicador de aba ativa
            local indicator = Instance.new("Frame")
            indicator.Size = UDim2.new(0.5, 0, 0, 2 * UI_SCALE)
            indicator.Position = UDim2.new(0.25, 0, 1, -2 * UI_SCALE)
            indicator.BackgroundColor3 = CONFIG.accentColor
            indicator.BorderSizePixel = 0
            indicator.Visible = currentTab == link:lower()
            indicator.Parent = btn
            
            btn.MouseButton1Click:Connect(function()
                currentTab = link:lower()
                for _, b in ipairs(navButtons) do
                    b.TextColor3 = Color3.fromRGB(120, 120, 120)
                    b:FindFirstChildOfClass("Frame").Visible = false
                end
                btn.TextColor3 = CONFIG.accentColor
                indicator.Visible = true
                switchPage(link:lower())
            end)
            
            table.insert(navButtons, btn)
        end
        
        -- CONTENT AREA
        local contentArea = Instance.new("ScrollingFrame")
        contentArea.Size = UDim2.new(1, -16 * UI_SCALE, 1, -100 * UI_SCALE)
        contentArea.Position = UDim2.new(0, 8 * UI_SCALE, 0, 55 * UI_SCALE)
        contentArea.BackgroundTransparency = 1
        contentArea.ScrollBarThickness = 2 * UI_SCALE
        contentArea.ScrollBarImageColor3 = CONFIG.accentColor
        contentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
        contentArea.Parent = mainContainer
        
       
