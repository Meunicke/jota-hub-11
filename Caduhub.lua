-- ==========================================
-- PREMIUM HUB v4.0 - OPTIMIZED SILENT REACH
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- ==========================================
-- CONFIGURAÇÃO OTIMIZADA
-- ==========================================
local CONFIG = {
    -- Alcances (aumentados para silent reach)
    playerReach = 50,      -- Alcance do jogador
    ballReach = 30,        -- Alcance extra das bolas
    silentReach = 100,     -- NOVO: Alcance silencioso (camada invisível)
    
    -- Funcionalidades
    autoTouch = true,
    showVisuals = false,   -- Desativado por padrão para performance
    flashEnabled = false,
    quantumReachEnabled = true,  -- Ativado por padrão
    quantumReach = 150,    -- Alcance quântico massivo
    expandBallHitbox = true,
    antiAFK = true,
    
    -- BigFoot
    bigFootSize = 15,
    
    -- Otimização
    updateRate = 0.05,     -- Taxa de atualização (menos lag)
    ballScanRate = 0.5,    -- Scan de bolas a cada 0.5s
    maxBalls = 20,         -- Limite de bolas processadas
    
    -- Bolas suportadas
    ballNames = { "TPS", "MPS", "TRS", "TCS", "PRS", "ESA", "MRS", "SSS", "AIFA", "RBZ", "SoccerBall", "Football", "Ball", "Basketball", "Volleyball", "Puck", "Disc", "Sphere" }
}

-- ==========================================
-- TEMA
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

-- ==========================================
-- VARIÁVEIS OTIMIZADAS
-- ==========================================
local HRP = nil
local humanoid = nil
local character = nil
local bigFoot = nil
local silentLayer = nil  -- NOVO: Camada invisível de alcance
local isScriptActive = false
local lastBallScan = 0
local cachedBalls = {}
local BALL_NAME_SET = {}

for _, n in ipairs(CONFIG.ballNames) do BALL_NAME_SET[n] = true end

-- ==========================================
-- FUNÇÕES SEGURAS
-- ==========================================
local function safeCall(func, ...)
    local success = pcall(func, ...)
    return success
end

local function safeDestroy(obj)
    if obj and obj.Parent then
        pcall(function() obj:Destroy() end)
    end
end

-- ==========================================
-- SISTEMA DE PERSONAGEM
-- ==========================================
local function setupCharacter(char)
    character = char
    humanoid = char:FindFirstChildOfClass("Humanoid")
    HRP = char:WaitForChild("HumanoidRootPart", 3) or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    return HRP ~= nil
end

-- ==========================================
-- SISTEMA BIGFOOT OTIMIZADO
-- ==========================================
local function createBigFoot()
    if not character or not HRP then return nil end
    safeDestroy(bigFoot)
    
    local leg = character:FindFirstChild("Right Leg") or character:FindFirstChild("RightLowerLeg") or HRP
    
    safeCall(function()
        bigFoot = Instance.new("Part")
        bigFoot.Name = "BigFoot"
        bigFoot.Shape = Enum.PartType.Ball
        bigFoot.Size = Vector3.new(CONFIG.bigFootSize, CONFIG.bigFootSize, CONFIG.bigFootSize)
        bigFoot.Transparency = 1
        bigFoot.CanCollide = false
        bigFoot.CanTouch = true
        bigFoot.CanQuery = false
        bigFoot.Parent = character
        
        -- Conexão única otimizada
        RunService.Heartbeat:Connect(function()
            if bigFoot and bigFoot.Parent and leg and leg.Parent then
                bigFoot.CFrame = leg.CFrame * CFrame.new(0, -2, 0)
            end
        end)
    end)
    
    return bigFoot
end

-- ==========================================
-- CAMADA SILENCIOSA INVISÍVEL (NOVO SISTEMA)
-- ==========================================
local function createSilentLayer()
    if not character or not HRP then return nil end
    safeDestroy(silentLayer)
    
    safeCall(function()
        -- Cria uma esfera GIGANTE invisível ao redor do jogador
        silentLayer = Instance.new("Part")
        silentLayer.Name = "SilentReachLayer"
        silentLayer.Shape = Enum.PartType.Ball
        silentLayer.Size = Vector3.new(CONFIG.silentReach * 2, CONFIG.silentReach * 2, CONFIG.silentReach * 2)
        silentLayer.Transparency = 1  -- Totalmente invisível
        silentLayer.CanCollide = false
        silentLayer.CanTouch = true     -- Importante: pode tocar
        silentLayer.CanQuery = false    -- Não interfere em raycasts
        silentLayer.Parent = character
        
        -- Anexa ao HRP para seguir o jogador
        local weld = Instance.new("Weld")
        weld.Part0 = HRP
        weld.Part1 = silentLayer
        weld.C0 = CFrame.new(0, 0, 0)
        weld.Parent = silentLayer
        
        print("[Silent Layer] Criada com alcance: " .. CONFIG.silentReach)
    end)
    
    return silentLayer
end

-- ==========================================
-- SISTEMA DE TOQUE OTIMIZADO
-- ==========================================
local function touchBall(ball)
    if not ball or not ball.Parent then return end
    
    -- Método 1: BigFoot (para bolas próximas)
    if bigFoot and bigFoot.Parent then
        safeCall(function()
            firetouchinterest(ball, bigFoot, 0)
            firetouchinterest(ball, bigFoot, 1)
        end)
    end
    
    -- Método 2: Silent Layer (para bolas longe) - NOVO
    if silentLayer and silentLayer.Parent then
        safeCall(function()
            firetouchinterest(ball, silentLayer, 0)
            firetouchinterest(ball, silentLayer, 1)
        end)
    end
    
    -- Método 3: Teleporta BigFoot para a bola (bypass)
    if bigFoot and bigFoot.Parent then
        safeCall(function()
            local originalCF = bigFoot.CFrame
            bigFoot.CFrame = ball.CFrame
            task.wait()
            firetouchinterest(ball, bigFoot, 0)
            firetouchinterest(ball, bigFoot, 1)
            bigFoot.CFrame = originalCF
        end)
    end
    
    -- Método 4: Network Ownership (toma controle da bola)
    safeCall(function()
        ball:SetNetworkOwner(player)
    end)
end

-- ==========================================
-- SCAN DE BOLAS OTIMIZADO
-- ==========================================
local function scanBalls()
    local now = tick()
    if now - lastBallScan < CONFIG.ballScanRate then
        return cachedBalls
    end
    lastBallScan = now
    
    table.clear(cachedBalls)
    
    safeCall(function()
        local descendants = Workspace:GetDescendants()
        local count = 0
        
        for _, obj in ipairs(descendants) do
            if count >= CONFIG.maxBalls then break end
            
            if obj and obj:IsA("BasePart") and BALL_NAME_SET[obj.Name] then
                -- Verifica se está no alcance antes de adicionar
                if HRP then
                    local dist = (obj.Position - HRP.Position).Magnitude
                    if dist < (CONFIG.silentReach + 50) then  -- Só pega bolas próximas
                        table.insert(cachedBalls, obj)
                        count = count + 1
                    end
                else
                    table.insert(cachedBalls, obj)
                    count = count + 1
                end
            end
        end
    end)
    
    return cachedBalls
end

-- ==========================================
-- HUB UI OTIMIZADO
-- ==========================================
local function createOptimizedHub()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "OptimizedHub"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = CoreGui
    
    -- Frame Principal
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 360, 0, 480)
    main.Position = UDim2.new(0.5, -180, 0.5, -240)
    main.BackgroundColor3 = THEME.bg
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true
    main.Parent = screenGui
    
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)
    
    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = THEME.card
    header.BorderSizePixel = 0
    header.Parent = main
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -100, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "⚡ SILENT HUB v4.0"
    title.TextColor3 = THEME.accent
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    -- Botões
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 40, 0, 40)
    minBtn.Position = UDim2.new(1, -90, 0.5, -20)
    minBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    minBtn.Text = "−"
    minBtn.TextColor3 = THEME.text
    minBtn.TextSize = 22
    minBtn.Font = Enum.Font.GothamBold
    minBtn.Parent = header
    
    Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 8)
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 40, 0, 40)
    closeBtn.Position = UDim2.new(1, -45, 0.5, -20)
    closeBtn.BackgroundColor3 = THEME.accent2
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = THEME.text
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = header
    
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    
    -- Conteúdo
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, -20, 1, -120)
    content.Position = UDim2.new(0, 10, 0, 60)
    content.BackgroundTransparency = 1
    content.ScrollBarThickness = 4
    content.CanvasSize = UDim2.new(0, 0, 0, 400)
    content.Parent = main
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.Parent = content
    
    -- Toggle otimizado
    local function createToggle(text, subtext, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 65)
        frame.BackgroundColor3 = THEME.card
        frame.BorderSizePixel = 0
        frame.Parent = content
        
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
        
        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, -70, 0, 22)
        t.Position = UDim2.new(0, 12, 0, 8)
        t.BackgroundTransparency = 1
        t.Text = text
        t.TextColor3 = THEME.text
        t.TextSize = 15
        t.Font = Enum.Font.GothamBold
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Parent = frame
        
        local s = Instance.new("TextLabel")
        s.Size = UDim2.new(1, -70, 0, 25)
        s.Position = UDim2.new(0, 12, 0, 30)
        s.BackgroundTransparency = 1
        s.Text = subtext
        s.TextColor3 = THEME.textDim
        s.TextSize = 11
        s.Font = Enum.Font.Gotham
        s.TextXAlignment = Enum.TextXAlignment.Left
        s.Parent = frame
        
        local toggle = Instance.new("Frame")
        toggle.Size = UDim2.new(0, 50, 0, 26)
        toggle.Position = UDim2.new(1, -60, 0.5, -13)
        toggle.BackgroundColor3 = default and THEME.accent or Color3.fromRGB(60, 60, 70)
        toggle.BorderSizePixel = 0
        toggle.Parent = frame
        
        Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)
        
        local circle = Instance.new("Frame")
        circle.Size = UDim2.new(0, 22, 0, 22)
        circle.Position = default and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)
        circle.BackgroundColor3 = THEME.text
        circle.BorderSizePixel = 0
        circle.Parent = toggle
        
        Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.Parent = frame
        
        local enabled = default
        
        btn.MouseButton1Click:Connect(function()
            enabled = not enabled
            TweenService:Create(toggle, TweenInfo.new(0.2), {
                BackgroundColor3 = enabled and THEME.accent or Color3.fromRGB(60, 60, 70)
            }):Play()
            TweenService:Create(circle, TweenInfo.new(0.2), {
                Position = enabled and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)
            }):Play()
            if callback then callback(enabled) end
        end)
    end
    
    -- Criar toggles
    createToggle("Silent Reach", "Alcance invisível massivo", true, function(v)
        CONFIG.autoTouch = v
        if v then
            createSilentLayer()
        else
            safeDestroy(silentLayer)
        end
    end)
    
    createToggle("Quantum Mode", "Alcance quântico ultra", CONFIG.quantumReachEnabled, function(v)
        CONFIG.quantumReachEnabled = v
    end)
    
    createToggle("Show Visuals", "Mostrar hitboxes (lag)", CONFIG.showVisuals, function(v)
        CONFIG.showVisuals = v
    end)
    
    createToggle("Flash Effect", "Flash ao tocar (lag)", CONFIG.flashEnabled, function(v)
        CONFIG.flashEnabled = v
    end)
    
    createToggle("Anti AFK", "Prevenir kick", CONFIG.antiAFK, function(v)
        CONFIG.antiAFK = v
    end)
    
    -- Status
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, 0, 0, 30)
    status.Position = UDim2.new(0, 0, 1, -35)
    status.BackgroundTransparency = 1
    status.Text = "● Sistema Ativo"
    status.TextColor3 = THEME.accent
    status.TextSize = 12
    status.Font = Enum.Font.GothamSemibold
    status.Parent = main
    
    -- Botão flutuante
    local floatBtn = Instance.new("TextButton")
    floatBtn.Size = UDim2.new(0, 55, 0, 55)
    floatBtn.Position = UDim2.new(1, -65, 0, 10)
    floatBtn.BackgroundColor3 = THEME.accent
    floatBtn.Text = "⚡"
    floatBtn.TextSize = 26
    floatBtn.Font = Enum.Font.GothamBold
    floatBtn.Visible = false
    floatBtn.Parent = screenGui
    
    Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(1, 0)
    
    -- Sistema minimizar
    local minimized = false
    
    local function minimize()
        minimized = true
        TweenService:Create(main, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }):Play()
        task.wait(0.3)
        main.Visible = false
        floatBtn.Visible = true
        TweenService:Create(floatBtn, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 55, 0, 55)
        }):Play()
    end
    
    local function restore()
        minimized = false
        TweenService:Create(floatBtn, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 0, 0, 0)
        }):Play()
        task.wait(0.2)
        floatBtn.Visible = false
        main.Visible = true
        TweenService:Create(main, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 360, 0, 480),
            Position = UDim2.new(0.5, -180, 0.5, -240)
        }):Play()
    end
    
    minBtn.MouseButton1Click:Connect(minimize)
    floatBtn.MouseButton1Click:Connect(restore)
    
    closeBtn.MouseButton1Click:Connect(function()
        TweenService:Create(main, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 0, 0, 0)
        }):Play()
        task.wait(0.3)
        screenGui:Destroy()
        isScriptActive = false
        safeDestroy(silentLayer)
        safeDestroy(bigFoot)
    end)
    
    -- Animação entrada
    main.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, 360, 0, 480)
    }):Play()
    
    return screenGui
end

-- ==========================================
-- MAIN LOOP ULTRA OTIMIZADO
-- ==========================================
local function mainLoop()
    local lastUpdate = 0
    
    while isScriptActive do
        local now = tick()
        
        -- Só executa a cada updateRate segundos (menos lag)
        if now - lastUpdate >= CONFIG.updateRate then
            lastUpdate = now
            
            safeCall(function()
                -- Atualiza referências (mínimo necessário)
                if not character or not character.Parent then
                    character = player.Character
                    if character then
                        setupCharacter(character)
                        task.delay(0.5, function()
                            createBigFoot()
                            createSilentLayer()  -- Cria camada silenciosa
                        end)
                    end
                end
                
                if not HRP or not HRP.Parent then
                    HRP = character and character:FindFirstChild("HumanoidRootPart")
                end
                
                if not HRP then return end
                
                -- Recria sistemas se necessário
                if not bigFoot or not bigFoot.Parent then
                    createBigFoot()
                end
                
                if not silentLayer or not silentLayer.Parent then
                    createSilentLayer()
                end
                
                -- Scan otimizado de bolas
                local ballsList = scanBalls()
                
                -- SISTEMA PRINCIPAL: Touch em TODAS as bolas no alcance
                if CONFIG.autoTouch then
                    for _, ball in ipairs(ballsList) do
                        if ball and ball.Parent then
                            local dist = (ball.Position - HRP.Position).Magnitude
                            
                            -- Se está no alcance silencioso, toca
                            if dist < CONFIG.silentReach then
                                touchBall(ball)
                                
                                -- Flash opcional (desativado por padrão)
                                if CONFIG.flashEnabled then
                                    safeCall(function()
                                        local flash = Instance.new("Part")
                                        flash.Size = Vector3.new(1, 1, 1)
                                        flash.CFrame = ball.CFrame
                                        flash.Anchored = true
                                        flash.CanCollide = false
                                        flash.Material = Enum.Material.Neon
                                        flash.Color = Color3.fromRGB(255, 255, 0)
                                        flash.Parent = Workspace
                                        Debris:AddItem(flash, 0.1)
                                    end)
                                end
                            end
                        end
                    end
                end
                
                                -- Quantum Reach (alcance extra)
                if CONFIG.quantumReachEnabled then
                    for _, ball in ipairs(ballsList) do
                        if ball and ball.Parent then
                            local dist = (ball.Position - HRP.Position).Magnitude
                            if dist < CONFIG.quantumReach and dist >= CONFIG.silentReach then
                                -- Só toca se não foi pega pelo silent reach
                                touchBall(ball)
                            end
                        end
                    end
                end
                
                -- Visuals (só se ativado, causa lag)
                if CONFIG.showVisuals then
                    -- Player Sphere (simplificado)
                    if not playerSphere then
                        safeCall(function()
                            playerSphere = Instance.new("Part")
                            playerSphere.Shape = Enum.PartType.Ball
                            playerSphere.Anchored = true
                            playerSphere.CanCollide = false
                            playerSphere.Material = Enum.Material.ForceField
                            playerSphere.Color = THEME.accent
                            playerSphere.Transparency = 0.9
                            playerSphere.Parent = Workspace
                        end)
                    end
                    
                    if playerSphere then
                        playerSphere.Size = Vector3.new(CONFIG.silentReach * 2, CONFIG.silentReach * 2, CONFIG.silentReach * 2)
                        playerSphere.CFrame = HRP.CFrame
                    end
                else
                    safeDestroy(playerSphere)
                end
                
            end)
        end
        
        task.wait(0.01) -- Espera mínima
    end
end

-- ==========================================
-- INICIALIZAÇÃO
-- ==========================================
local function init()
    -- Setup inicial
    if player.Character then
        setupCharacter(player.Character)
    end
    
    player.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        if setupCharacter(char) then
            task.wait(0.5)
            createBigFoot()
            createSilentLayer()  -- Cria a camada invisível
        end
    end)
    
    -- Aguarda HRP
    if not HRP then
        repeat task.wait(0.1) until HRP
    end
    
    -- Cria sistemas
    createBigFoot()
    createSilentLayer()
    createOptimizedHub()
    
    -- Anti-AFK
    player.Idled:Connect(function()
        if CONFIG.antiAFK then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end)
    
    -- Inicia loop
    isScriptActive = true
    task.spawn(mainLoop)
    
    print("[Silent Hub v4.0] Iniciado!")
    print("[Sistema] Silent Layer ativa - Alcance: " .. CONFIG.silentReach)
    print("[Otimização] Update rate: " .. CONFIG.updateRate .. "s")
end

init()
