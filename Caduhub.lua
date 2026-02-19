-- ==========================================
-- PREMIUM HUB v5.0 - BALL REACH SYSTEM (NO LAG)
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

-- ==========================================
-- CONFIGURAÇÃO
-- ==========================================
local CONFIG = {
    -- Reach do Jogador (mantido, sem lag)
    playerReach = 15,
    
    -- Reach da Bola (NOVO - camada invisível na bola)
    ballReach = 50,        -- Alcance para "chutar" a bola
    ballHitboxSize = 20,   -- Tamanho da hitbox invisível na bola
    
    -- Funcionalidades
    autoTouch = true,
    showVisuals = false,
    flashEnabled = false,
    antiAFK = true,
    
    -- Otimização
    updateRate = 0.03,     -- Taxa de atualização
    maxBalls = 15,         -- Limite de bolas com hitbox
    
    -- Bolas suportadas
    ballNames = { "TPS", "MPS", "TRS", "TCS", "PRS", "ESA", "MRS", "SSS", "AIFA", "RBZ", "SoccerBall", "Football", "Ball", "Basketball", "Volleyball", "Puck", "Disc", "Sphere", "Balloon" }
}

-- ==========================================
-- TEMA
-- ==========================================
local THEME = {
    bg = Color3.fromRGB(10, 10, 15),
    card = Color3.fromRGB(25, 25, 35),
    accent = Color3.fromRGB(29, 185, 84),
    accent2 = Color3.fromRGB(229, 9, 20),
    text = Color3.fromRGB(255, 255, 255),
    textDim = Color3.fromRGB(150, 150, 170)
}

-- ==========================================
-- VARIÁVEIS
-- ==========================================
local HRP = nil
local character = nil
local isScriptActive = false
local ballHitboxes = {}  -- Hitboxes invisíveis nas bolas
local cachedBalls = {}
local lastScan = 0
local BALL_NAME_SET = {}

for _, n in ipairs(CONFIG.ballNames) do BALL_NAME_SET[n] = true end

-- ==========================================
-- FUNÇÕES SEGURAS
-- ==========================================
local function safeCall(func, ...)
    return pcall(func, ...)
end

local function safeDestroy(obj)
    if obj and obj.Parent then
        pcall(function() obj:Destroy() end)
    end
end

-- ==========================================
-- SISTEMA DE PERSONAGEM (SEM BIGFOOT - SEM LAG)
-- ==========================================
local function setupCharacter(char)
    character = char
    HRP = char:WaitForChild("HumanoidRootPart", 3) or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    return HRP ~= nil
end

-- ==========================================
-- SISTEMA DE HITBOX NA BOLA (NOVO)
-- ==========================================
local function createBallHitbox(ball)
    if not ball or not ball.Parent or ballHitboxes[ball] then return end
    
    safeCall(function()
        -- Cria hitbox invisível GIGANTE na bola
        local hitbox = Instance.new("Part")
        hitbox.Name = "InvisibleHitbox_" .. ball.Name
        hitbox.Shape = Enum.PartType.Ball
        hitbox.Size = Vector3.new(CONFIG.ballHitboxSize * 2, CONFIG.ballHitboxSize * 2, CONFIG.ballHitboxSize * 2)
        hitbox.Transparency = 1  -- Totalmente invisível
        hitbox.CanCollide = false
        hitbox.CanTouch = true   -- Pode ser tocado
        hitbox.CanQuery = false  -- Não interfere em raycasts
        hitbox.Anchored = true   -- Importante: não afeta física da bola
        hitbox.Parent = Workspace
        
        -- Conexão otimizada: apenas posição, sem weld
        local connection = RunService.Heartbeat:Connect(function()
            if ball and ball.Parent and hitbox and hitbox.Parent then
                hitbox.CFrame = ball.CFrame
            else
                safeDestroy(hitbox)
                if ballHitboxes[ball] then
                    ballHitboxes[ball] = nil
                end
            end
        end)
        
        ballHitboxes[ball] = {
            hitbox = hitbox,
            connection = connection,
            lastTouch = 0
        }
    end)
end

local function removeBallHitbox(ball)
    local data = ballHitboxes[ball]
    if data then
        if data.connection then
            pcall(function() data.connection:Disconnect() end)
        end
        safeDestroy(data.hitbox)
        ballHitboxes[ball] = nil
    end
end

-- ==========================================
-- SISTEMA DE TOQUE OTIMIZADO
-- ==========================================
local function touchBall(ball, hitbox)
    if not ball or not ball.Parent or not hitbox or not hitbox.Parent then return end
    
    -- Verifica cooldown (evita spam)
    local data = ballHitboxes[ball]
    if data then
        local now = tick()
        if now - data.lastTouch < 0.1 then return end  -- 0.1s cooldown
        data.lastTouch = now
    end
    
    safeCall(function()
        -- Método 1: Touch direto na hitbox da bola
        firetouchinterest(hitbox, HRP, 0)
        firetouchinterest(hitbox, HRP, 1)
        
        -- Método 2: Toca a bola diretamente também
        firetouchinterest(ball, HRP, 0)
        firetouchinterest(ball, HRP, 1)
        
        -- Método 3: Network ownership (controle total)
        ball:SetNetworkOwner(player)
    end)
end

-- ==========================================
-- SCAN DE BOLAS OTIMIZADO
-- ==========================================
local function scanBalls()
    local now = tick()
    if now - lastScan < 0.3 then  -- Scan a cada 0.3s
        return cachedBalls
    end
    lastScan = now
    
    table.clear(cachedBalls)
    
    safeCall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj and obj:IsA("BasePart") and BALL_NAME_SET[obj.Name] then
                if HRP then
                    local dist = (obj.Position - HRP.Position).Magnitude
                    -- Só pega bolas no alcance + margem
                    if dist < (CONFIG.ballReach + CONFIG.ballHitboxSize + 20) then
                        table.insert(cachedBalls, obj)
                        if #cachedBalls >= CONFIG.maxBalls then break end
                    end
                end
            end
        end
    end)
    
    return cachedBalls
end

-- ==========================================
-- HUB UI
-- ==========================================
local function createHub()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BallReachHub"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = CoreGui
    
    -- Frame Principal
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 340, 0, 450)
    main.Position = UDim2.new(0.5, -170, 0.5, -225)
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
    title.Text = "⚡ BALL REACH v5.0"
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
    content.Size = UDim2.new(1, -20, 1, -110)
    content.Position = UDim2.new(0, 10, 0, 60)
    content.BackgroundTransparency = 1
    content.ScrollBarThickness = 4
    content.CanvasSize = UDim2.new(0, 0, 0, 350)
    content.Parent = main
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.Parent = content
    
    -- Toggle
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
    
    -- Slider
    local function createSlider(title, min, max, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 60)
        frame.BackgroundColor3 = THEME.card
        frame.BorderSizePixel = 0
        frame.Parent = content
        
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
        
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
        
        local track = Instance.new("Frame")
        track.Size = UDim2.new(1, -24, 0, 6)
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
        
        local knob = Instance.new("TextButton")
        knob.Size = UDim2.new(0, 20, 0, 20)
        knob.Position = UDim2.new((default - min) / (max - min), -10, 0.5, -10)
        knob.BackgroundColor3 = THEME.text
        knob.Text = ""
        knob.Parent = track
        
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
        
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
    end
    
    -- Criar controles
    createToggle("Ball Reach", "Hitbox invisível nas bolas", true, function(v)
        CONFIG.autoTouch = v
    end)
    
    createToggle("Anti AFK", "Prevenir kick", CONFIG.antiAFK, function(v)
        CONFIG.antiAFK = v
    end)
    
    createSlider("Player Reach", 5, 30, CONFIG.playerReach, function(v)
        CONFIG.playerReach = v
    end)
    
    createSlider("Ball Reach", 10, 100, CONFIG.ballReach, function(v)
        CONFIG.ballReach = v
    end)
    
    createSlider("Hitbox Size", 5, 40, CONFIG.ballHitboxSize, function(v)
        CONFIG.ballHitboxSize = v
        -- Atualiza hitboxes existentes
        for ball, data in pairs(ballHitboxes) do
            if data.hitbox then
                data.hitbox.Size = Vector3.new(v * 2, v * 2, v * 2)
            end
        end
    end)
    
    -- Status
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, 0, 0, 25)
    status.Position = UDim2.new(0, 0, 1, -30)
    status.BackgroundTransparency = 1
    status.Text = "● Sistema Ativo (Sem Lag)"
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
            Size = UDim2.new(0, 340, 0, 450),
            Position = UDim2.new(0.5, -170, 0.5, -225)
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
        -- Limpa todas as hitboxes
        for ball, data in pairs(ballHitboxes) do
            removeBallHitbox(ball)
        end
    end)
    
    -- Animação entrada
    main.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, 340, 0, 450)
    }):Play()
    
    return screenGui
end

-- ==========================================
-- MAIN LOOP OTIMIZADO (SEM LAG)
-- ==========================================
local function mainLoop()
    local lastUpdate = 0
    
    while isScriptActive do
        local now = tick()
        
        if now - lastUpdate >= CONFIG.updateRate then
            lastUpdate = now
            
            safeCall(function()
                -- Atualiza HRP
                if not character or not character.Parent then
                    character = player.Character
                    if character then setupCharacter(character) end
                end
                
                if not HRP or not HRP.Parent then
                    HRP = character and character:FindFirstChild("HumanoidRootPart")
                end
                
                if not HRP then return end
                
                -- Scan de bolas
                local ballsList = scanBalls()
                
                -- Gerencia hitboxes nas bolas
                for _, ball in ipairs(ballsList) do
                    if ball and ball.Parent then
                        local dist = (ball.Position - HRP.Position).Magnitude
                        
                        -- Cria hitbox se está no alcance
                        if dist < CONFIG.ballReach then
                            if not ballHitboxes[ball] then
                                createBallHitbox(ball)
                            end
                            
                                                        -- Toca na bola (chuta de longe)
                            if CONFIG.autoTouch then
                                local data = ballHitboxes[ball]
                                if data and data.hitbox then
                                    touchBall(ball, data.hitbox)
                                end
                            end
                        else
                            -- Remove hitbox se saiu do alcance
                            removeBallHitbox(ball)
                        end
                    end
                end
                
                -- Limpa hitboxes de bolas que não existem mais
                for ball, data in pairs(ballHitboxes) do
                    if not ball or not ball.Parent then
                        removeBallHitbox(ball)
                    end
                end
                
            end)
        end
        
        task.wait(0.01)
    end
end

-- ==========================================
-- INICIALIZAÇÃO
-- ==========================================
local function init()
    -- Setup
    if player.Character then
        setupCharacter(player.Character)
    end
    
    player.CharacterAdded:Connect(function(char)
        task.wait(0.3)
        setupCharacter(char)
    end)
    
    -- Aguarda HRP
    if not HRP then
        repeat task.wait(0.1) until HRP
    end
    
    -- Cria UI
    createHub()
    
    -- Anti-AFK
    player.Idled:Connect(function()
        if CONFIG.antiAFK then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end)
    
    -- Inicia
    isScriptActive = true
    task.spawn(mainLoop)
    
    print("[Ball Reach v5.0] Iniciado!")
    print("[Sistema] Sem BigFoot = Sem Lag")
    print("[Sistema] Hitbox nas bolas ativa")
end

init()
