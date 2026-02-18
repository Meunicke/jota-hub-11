-- SERVICES
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer

-- CONFIG - DESIGN MODERNO ESTILO DISCORD/SPOTIFY
local CONFIG = {
    playerReach = 10,
    ballReach = 15,
    autoTouch = true,
    showVisuals = true,
    flashEnabled = false,
    antiAFK = true,
    quantumReachEnabled = false,
    quantumReach = 10,
    -- CORREÇÃO: TPS adicionado explicitamente
    ballNames = { "TPS", "MPS", "TRS", "TCS", "PRS", "ESA", "MRS", "SSS", "AIFA", "RBZ", "SoccerBall", "Football", "Ball" },
    
    colors = {
        -- Tema escuro moderno
        bg = Color3.fromRGB(18, 18, 23),          -- Fundo principal quase preto
        tabBg = Color3.fromRGB(30, 30, 38),       -- Sidebar
        cardBg = Color3.fromRGB(35, 35, 47),      -- Cards/Seções
        accent = Color3.fromRGB(88, 101, 242),    -- Roxo Discord
        accent2 = Color3.fromRGB(235, 69, 158),   -- Rosa neon
        accent3 = Color3.fromRGB(0, 255, 255),    -- Cyan Quantum
        success = Color3.fromRGB(59, 165, 93),    -- Verde Discord
        warning = Color3.fromRGB(250, 168, 26),   -- Amarelo
        danger = Color3.fromRGB(237, 66, 69),     -- Vermelho Discord
        text = Color3.fromRGB(255, 255, 255),
        textDim = Color3.fromRGB(148, 155, 164),  -- Cinza Discord
        textDark = Color3.fromRGB(78, 86, 96),
        flash = Color3.fromRGB(255, 255, 100),
        toggleOn = Color3.fromRGB(59, 165, 93),
        toggleOff = Color3.fromRGB(78, 86, 96),
        gradient1 = Color3.fromRGB(88, 101, 242),
        gradient2 = Color3.fromRGB(235, 69, 158)
    }
}

-- VARIABLES
local balls = {}
local ballAuras = {}
local playerSphere = nil
local quantumCircle = nil
local HRP = nil
local gui, mainWindow, currentTab = nil, nil, "Reach"
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local connections = {}
local isUIOpen = true

-- BALL SET - CORREÇÃO: TPS prioritário
local BALL_NAME_SET = {}
for _, n in ipairs(CONFIG.ballNames) do
    BALL_NAME_SET[n] = true
end

-- UTILITY FUNCTIONS
local function disconnectAll()
    for _, conn in pairs(connections) do
        if conn then conn:Disconnect() end
    end
    connections = {}
end

local function createConnection(signal, callback)
    local conn = signal:Connect(callback)
    table.insert(connections, conn)
    return conn
end

-- UPDATE HRP
task.spawn(function()
    while true do
        task.wait(0.5)
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            HRP = player.Character.HumanoidRootPart
        end
    end
end)

-- ANTI-AFK
if CONFIG.antiAFK then
    local VirtualUser = game:GetService("VirtualUser")
    player.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

-- GET BALLS - CORREÇÃO: Prioriza TPS e verificação melhorada
local lastBallUpdate = 0
local function getBalls()
    local now = tick()
    if now - lastBallUpdate < 0.05 then return balls end -- Atualizado mais rápido
    lastBallUpdate = now
    
    table.clear(balls)
    
    -- Procura em Workspace e descendants
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            -- Verifica se é uma bola pelo nome
            if BALL_NAME_SET[v.Name] then
                table.insert(balls, v)
            end
        end
    end
    
    return balls
end

-- CORREÇÃO: Função específica para TPS
local function findTPSBall()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name == "TPS" then
            return v
        end
    end
    return nil
end

-- CREATE BALL AURA - CORREÇÃO: Atualização em tempo real do tamanho
local function createBallAura(ball)
    if ballAuras[ball] or not CONFIG.showVisuals then return end
    
    local aura = Instance.new("Part")
    aura.Name = "BallAura_" .. ball.Name
    aura.Shape = Enum.PartType.Ball
    -- CORREÇÃO: Tamanho baseado no ballReach atual
    aura.Size = Vector3.new(CONFIG.ballReach * 2, CONFIG.ballReach * 2, CONFIG.ballReach * 2)
    aura.Transparency = 0.85
    aura.Anchored = true
    aura.CanCollide = false
    aura.Material = Enum.Material.ForceField
    aura.Color = ball.Name == "TPS" and CONFIG.colors.accent3 or CONFIG.colors.accent2 -- TPS é cyan
    aura.Parent = Workspace
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "BallHighlight_" .. ball.Name
    highlight.Adornee = ball
    highlight.FillColor = ball.Name == "TPS" and CONFIG.colors.accent3 or CONFIG.colors.accent2
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = ball
    
    local conn = RunService.RenderStepped:Connect(function()
        if ball and ball.Parent and aura and aura.Parent then
            aura.CFrame = ball.CFrame
            -- CORREÇÃO: Atualiza tamanho dinamicamente
            local targetSize = Vector3.new(CONFIG.ballReach * 2, CONFIG.ballReach * 2, CONFIG.ballReach * 2)
            if aura.Size ~= targetSize then
                aura.Size = targetSize
            end
        else
            if aura then aura:Destroy() end
        end
    end)
    
    ballAuras[ball] = {aura = aura, highlight = highlight, conn = conn}
end

-- REMOVE BALL AURA
local function removeBallAura(ball)
    if ballAuras[ball] then
        if ballAuras[ball].conn then ballAuras[ball].conn:Disconnect() end
        if ballAuras[ball].aura then ballAuras[ball].aura:Destroy() end
        if ballAuras[ball].highlight then ballAuras[ball].highlight:Destroy() end
        ballAuras[ball] = nil
    end
end

-- UPDATE AURAS - CORREÇÃO: Atualiza tamanho existente
local function updateBallAuras()
    -- Remove auras inválidas
    for ball, _ in pairs(ballAuras) do
        if not ball or not ball.Parent then removeBallAura(ball) end
    end
    
    if not CONFIG.showVisuals then return end
    
    -- Cria ou atualiza auras
    for _, ball in ipairs(balls) do
        if ball and ball.Parent then
            if ballAuras[ball] then
                -- CORREÇÃO: Atualiza tamanho de auras existentes
                local targetSize = Vector3.new(CONFIG.ballReach * 2, CONFIG.ballReach * 2, CONFIG.ballReach * 2)
                if ballAuras[ball].aura and ballAuras[ball].aura.Size ~= targetSize then
                    ballAuras[ball].aura.Size = targetSize
                end
            else
                createBallAura(ball)
            end
        end
    end
end

-- CLEAR ALL AURAS
local function clearAllAuras()
    for ball, data in pairs(ballAuras) do
        if data.conn then data.conn:Disconnect() end
        if data.aura then data.aura:Destroy() end
        if data.highlight then data.highlight:Destroy() end
    end
    ballAuras = {}
    if playerSphere then
        playerSphere:Destroy()
        playerSphere = nil
    end
    if quantumCircle then
        quantumCircle:Destroy()
        quantumCircle = nil
    end
end

-- UPDATE PLAYER SPHERE
local function updatePlayerSphere()
    if not CONFIG.showVisuals then
        if playerSphere then playerSphere:Destroy() playerSphere = nil end
        return
    end
    if not HRP then return end
    
    if not playerSphere then
        playerSphere = Instance.new("Part")
        playerSphere.Name = "PlayerSphere"
        playerSphere.Shape = Enum.PartType.Ball
        playerSphere.Anchored = true
        playerSphere.CanCollide = false
        playerSphere.Material = Enum.Material.ForceField
        playerSphere.Color = CONFIG.colors.accent
        playerSphere.Parent = Workspace
    end
    
    playerSphere.Size = Vector3.new(CONFIG.playerReach * 2, CONFIG.playerReach * 2, CONFIG.playerReach * 2)
    playerSphere.Position = HRP.Position
    playerSphere.Transparency = 0.8
end

-- UPDATE QUANTUM CIRCLE
local function updateQuantumCircle()
    if not quantumCircle then
        quantumCircle = Instance.new("Part")
        quantumCircle.Name = "QuantumCircle"
        quantumCircle.Shape = Enum.PartType.Ball
        quantumCircle.Anchored = true
        quantumCircle.CanCollide = false
        quantumCircle.Material = Enum.Material.ForceField
        quantumCircle.Color = CONFIG.colors.accent3
        quantumCircle.Parent = Workspace
    end
    quantumCircle.Size = Vector3.new(CONFIG.quantumReach * 2, CONFIG.quantumReach * 2, CONFIG.quantumReach * 2)
    quantumCircle.Transparency = (CONFIG.quantumReachEnabled and CONFIG.showVisuals) and 0.8 or 1
end

-- CORREÇÃO: DO REACH PARA TPS - Agora verifica TPS especificamente
local function doReach()
    if not CONFIG.autoTouch or not player.Character or not HRP then return end
    
    local now = tick()
    
    local rightLeg = player.Character:FindFirstChild("Right Leg") or 
                     player.Character:FindFirstChild("RightLowerLeg") or
                     player.Character:FindFirstChild("RightFoot") or
                     player.Character:FindFirstChild("HumanoidRootPart")
    if not rightLeg then return end
    
    getBalls()
    
    -- CORREÇÃO: Procura específica por TPS primeiro
    local tpsBall = findTPSBall()
    if tpsBall and tpsBall.Parent then
        local dist = (tpsBall.Position - HRP.Position).Magnitude
        local effectiveReach = CONFIG.playerReach + CONFIG.ballReach
        
        if dist < effectiveReach then
            -- Tenta touch no TPS com prioridade máxima
            pcall(function()
                firetouchinterest(tpsBall, rightLeg, 0)
                firetouchinterest(tpsBall, rightLeg, 1)
            end)
            
            -- Procura TouchInterest também
            for _, desc in ipairs(rightLeg:GetDescendants()) do
                if desc.Name == "TouchInterest" then
                    pcall(function()
                        firetouchinterest(tpsBall, desc.Parent, 0)
                        firetouchinterest(tpsBall, desc.Parent, 1)
                    end)
                end
            end
        end
    end
    
    -- Depois processa outras bolas
    for _, ball in ipairs(balls) do
        if not ball or not ball.Parent or ball.Name == "TPS" then continue end -- Pula TPS já processado
        
        local dist = (ball.Position - HRP.Position).Magnitude
        local effectiveReach = CONFIG.playerReach + CONFIG.ballReach
        
        if CONFIG.flashEnabled and dist < effectiveReach * 2 then
            pcall(function()
                firetouchinterest(ball, rightLeg, 0)
                firetouchinterest(ball, rightLeg, 1)
            end)
            
            if CONFIG.showVisuals then
                local flash = Instance.new("Part")
                flash.Size = Vector3.new(1, 1, 1)
                flash.Position = ball.Position
                flash.Anchored = true
                flash.CanCollide = false
                flash.Material = Enum.Material.Neon
                flash.Color = CONFIG.colors.flash
                flash.Parent = Workspace
                
                TweenService:Create(flash, TweenInfo.new(0.1), {
                    Size = Vector3.new(5, 5, 5),
                    Transparency = 1
                }):Play()
                
                Debris:AddItem(flash, 0.1)
            end
            
        elseif dist < effectiveReach then
            local touched = false
            for _, desc in ipairs(rightLeg:GetDescendants()) do
                if desc.Name == "TouchInterest" then
                    pcall(function()
                        firetouchinterest(ball, desc.Parent, 0)
                        firetouchinterest(ball, desc.Parent, 1)
                    end)
                    touched = true
                    break
                end
            end
            
            if not touched then
                pcall(function()
                    firetouchinterest(ball, rightLeg, 0)
                    firetouchinterest(ball, rightLeg, 1)
                end)
            end
        end
    end
end

-- DO QUANTUM REACH TOUCH
local function doQuantumReach()
    if not CONFIG.quantumReachEnabled or not player.Character or not HRP then return end
    
    local rightLeg = player.Character:FindFirstChild("Right Leg") or 
                     player.Character:FindFirstChild("RightLowerLeg") or
                     player.Character:FindFirstChild("RightFoot")
    if not rightLeg then return end

    local ballsList = getBalls()
    for _, ball in ipairs(ballsList) do
        if ball and ball.Parent and (ball.Position - HRP.Position).Magnitude < CONFIG.quantumReach then
            local touched = false
            for _, d in ipairs(rightLeg:GetDescendants()) do
                if d.Name == "TouchInterest" then
                    pcall(function()
                        firetouchinterest(ball, d.Parent, 0)
                        firetouchinterest(ball, d.Parent, 1)
                    end)
                    touched = true
                    break
                end
            end
            
            if not touched then
                pcall(function()
                    firetouchinterest(ball, rightLeg, 0)
                    firetouchinterest(ball, rightLeg, 1)
                end)
            end
        end
    end
end

-- UI FUNCTIONS MODERNAS
local function createCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

local function createStroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or CONFIG.colors.accent
    s.Thickness = thickness or 1
    s.Parent = parent
    return s
end

local function createGradient(parent, color1, color2)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color1 or CONFIG.colors.gradient1),
        ColorSequenceKeypoint.new(1, color2 or CONFIG.colors.gradient2)
    })
    gradient.Rotation = 45
    gradient.Parent = parent
    return gradient
end

local function createShadow(parent)
    local s = Instance.new("ImageLabel")
    s.Name = "Shadow"
    s.Size = UDim2.new(1, 40, 1, 40)
    s.Position = UDim2.new(0, -20, 0, -20)
    s.BackgroundTransparency = 1
    s.Image = "rbxassetid://5554236805"
    s.ImageColor3 = Color3.new(0, 0, 0)
    s.ImageTransparency = 0.4
    s.ScaleType = Enum.ScaleType.Slice
    s.SliceCenter = Rect.new(23, 23, 277, 277)
    s.Parent = parent
    return s
end

-- CREATE MODERN TOGGLE
local function createToggle(parent, text, defaultValue, callback, yPos)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 70)
    toggleFrame.Position = UDim2.new(0, 0, 0, yPos or 0)
    toggleFrame.BackgroundColor3 = CONFIG.colors.cardBg
    toggleFrame.Parent = parent
    createCorner(toggleFrame, 12)
    
    -- Ícone/Indicator
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 4, 0, 40)
    indicator.Position = UDim2.new(0, 0, 0.5, -20)
    indicator.BackgroundColor3 = defaultValue and CONFIG.colors.success or CONFIG.colors.textDark
    indicator.BorderSizePixel = 0
    indicator.Parent = toggleFrame
    createCorner(indicator, 2)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -100, 1, 0)
    label.Position = UDim2.new(0, 20, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = CONFIG.colors.text
    label.Font = Enum.Font.GothamBold
    label.TextSize = 15
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame
    
    -- Toggle Button Moderno
    local toggleBtn = Instance.new("Frame")
    toggleBtn.Size = UDim2.new(0, 50, 0, 28)
    toggleBtn.Position = UDim2.new(1, -65, 0.5, -14)
    toggleBtn.BackgroundColor3 = defaultValue and CONFIG.colors.success or CONFIG.colors.toggleOff
    toggleBtn.Parent = toggleFrame
    createCorner(toggleBtn, 14)
    
    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 22, 0, 22)
    circle.Position = UDim2.new(0, defaultValue and 26 or 2, 0.5, -11)
    circle.BackgroundColor3 = Color3.new(1, 1, 1)
    circle.Parent = toggleBtn
    createCorner(circle, 11)
    
    local isOn = defaultValue
    
    local clickArea = Instance.new("TextButton")
    clickArea.Size = UDim2.new(1, 0, 1, 0)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""
    clickArea.Parent = toggleFrame
    
    clickArea.MouseButton1Click:Connect(function()
        isOn = not isOn
        
        -- Animação suave
        TweenService:Create(toggleBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = isOn and CONFIG.colors.success or CONFIG.colors.toggleOff
        }):Play()
        
        TweenService:Create(circle, TweenInfo.new(0.2), {
            Position = UDim2.new(0, isOn and 26 or 2, 0.5, -11)
        }):Play()
        
        TweenService:Create(indicator, TweenInfo.new(0.2), {
            BackgroundColor3 = isOn and CONFIG.colors.success or CONFIG.colors.textDark
        }):Play()
        
        callback(isOn)
    end)
    
    return toggleFrame
end

-- CREATE MODERN SLIDER
local function createSlider(parent, text, value, min, max, color, callback, yPos)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, 0, 0, 140)
    section.Position = UDim2.new(0, 0, 0, yPos or 0)
    section.BackgroundColor3 = CONFIG.colors.cardBg
    section.Parent = parent
    createCorner(section, 12)
    
    -- Indicator colorido
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 4, 0, 60)
    indicator.Position = UDim2.new(0, 0, 0, 20)
    indicator.BackgroundColor3 = color
    indicator.BorderSizePixel = 0
    indicator.Parent = section
    createCorner(indicator, 2)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -30, 0, 25)
    label.Position = UDim2.new(0, 20, 0, 15)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = section
    
    local valueContainer = Instance.new("Frame")
    valueContainer.Size = UDim2.new(0, 80, 0, 40)
    valueContainer.Position = UDim2.new(1, -95, 0, 10)
    valueContainer.BackgroundColor3 = CONFIG.colors.tabBg
    valueContainer.Parent = section
    createCorner(valueContainer, 8)
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(1, 0, 1, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(value)
    valueLabel.TextColor3 = CONFIG.colors.text
    valueLabel.Font = Enum.Font.GothamBlack
    valueLabel.TextSize = 24
    valueLabel.Parent = valueContainer
    
    local studsLabel = Instance.new("TextLabel")
    studsLabel.Size = UDim2.new(0, 50, 0, 20)
    studsLabel.Position = UDim2.new(0, 105, 0, 28)
    studsLabel.BackgroundTransparency = 1
    studsLabel.Text = "studs"
    studsLabel.TextColor3 = CONFIG.colors.textDim
    studsLabel.Font = Enum.Font.Gotham
    studsLabel.TextSize = 12
    studsLabel.Parent = section
    
        -- Slider Track
    local sliderTrack = Instance.new("Frame")
    sliderTrack.Size = UDim2.new(1, -40, 0, 8)
    sliderTrack.Position = UDim2.new(0, 20, 0, 95)
    sliderTrack.BackgroundColor3 = CONFIG.colors.tabBg
    sliderTrack.BorderSizePixel = 0
    sliderTrack.Parent = section
    createCorner(sliderTrack, 4)
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = color
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderTrack
    createCorner(sliderFill, 4)
    
    -- Glow effect no fill
    local glow = Instance.new("ImageLabel")
    glow.Size = UDim2.new(1, 20, 1, 20)
    glow.Position = UDim2.new(0, -10, 0, -6)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://5028857084"
    glow.ImageColor3 = color
    glow.ImageTransparency = 0.7
    glow.ScaleType = Enum.ScaleType.Slice
    glow.SliceCenter = Rect.new(10, 10, 90, 90)
    glow.Parent = sliderFill
    
    local function updateValue(newVal)
        newVal = math.clamp(math.floor(newVal + 0.5), min, max)
        valueLabel.Text = tostring(newVal)
        TweenService:Create(sliderFill, TweenInfo.new(0.15), {
            Size = UDim2.new((newVal - min) / (max - min), 0, 1, 0)
        }):Play()
        callback(newVal)
        return newVal
    end
    
    -- Drag functionality
    local dragging = false
    
    sliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            local pos = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
            updateValue(min + (pos * (max - min)))
        end
    end)
    
    sliderTrack.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local pos = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
            updateValue(min + (pos * (max - min)))
        end
    end)
    
    -- Buttons
    local btnContainer = Instance.new("Frame")
    btnContainer.Size = UDim2.new(0, 90, 0, 35)
    btnContainer.Position = UDim2.new(1, -105, 0, 55)
    btnContainer.BackgroundTransparency = 1
    btnContainer.Parent = section
    
    local minusBtn = Instance.new("TextButton")
    minusBtn.Size = UDim2.new(0, 40, 1, 0)
    minusBtn.Position = UDim2.new(0, 0, 0, 0)
    minusBtn.BackgroundColor3 = CONFIG.colors.tabBg
    minusBtn.Text = "−"
    minusBtn.TextColor3 = CONFIG.colors.text
    minusBtn.Font = Enum.Font.GothamBold
    minusBtn.TextSize = 18
    minusBtn.Parent = btnContainer
    createCorner(minusBtn, 8)
    
    local plusBtn = Instance.new("TextButton")
    plusBtn.Size = UDim2.new(0, 40, 1, 0)
    plusBtn.Position = UDim2.new(1, -40, 0, 0)
    plusBtn.BackgroundColor3 = color
    plusBtn.Text = "+"
    plusBtn.TextColor3 = Color3.new(0, 0, 0)
    plusBtn.Font = Enum.Font.GothamBold
    plusBtn.TextSize = 18
    plusBtn.Parent = btnContainer
    createCorner(plusBtn, 8)
    
    local currentValue = value
    
    minusBtn.MouseButton1Click:Connect(function()
        currentValue = updateValue(currentValue - 1)
    end)
    
    plusBtn.MouseButton1Click:Connect(function()
        currentValue = updateValue(currentValue + 1)
    end)
    
    return section
end

-- BUILD MAIN GUI - DESIGN MODERNO
function buildMainGUI()
    if gui then return end
    
    gui = Instance.new("ScreenGui")
    gui.Name = "CaduHubPremium"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")
    
    -- Main Window - Mesmo tamanho de antes (500x400)
    mainWindow = Instance.new("Frame")
    mainWindow.Size = UDim2.new(0, 500, 0, 400)
    mainWindow.Position = UDim2.new(0.5, -250, 0.5, -200)
    mainWindow.BackgroundColor3 = CONFIG.colors.bg
    mainWindow.BorderSizePixel = 0
    mainWindow.ClipsDescendants = true
    mainWindow.Parent = gui
    
    createCorner(mainWindow, 16)
    createShadow(mainWindow)
    
    -- Make draggable
    local dragging = false
    local dragInput, dragStart, startPos
    
    local function updateDrag(input)
        local delta = input.Position - dragStart
        mainWindow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    mainWindow.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainWindow.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    mainWindow.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updateDrag(input)
        end
    end)
    
    -- Title Bar Moderna
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 60)
    titleBar.BackgroundColor3 = CONFIG.colors.tabBg
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainWindow
    
    -- Gradient no topo
    local topGradient = Instance.new("Frame")
    topGradient.Size = UDim2.new(1, 0, 0, 3)
    topGradient.BackgroundColor3 = CONFIG.colors.accent
    topGradient.BorderSizePixel = 0
    topGradient.Parent = titleBar
    createGradient(topGradient, CONFIG.colors.accent, CONFIG.colors.accent2)
    
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(0, 200, 0, 30)
    titleText.Position = UDim2.new(0, 20, 0, 15)
    titleText.BackgroundTransparency = 1
    titleText.Text = "CADU HUB"
    titleText.TextColor3 = CONFIG.colors.text
    titleText.Font = Enum.Font.GothamBlack
    titleText.TextSize = 22
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    -- Subtitle com gradient
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(0, 200, 0, 20)
    subtitle.Position = UDim2.new(0, 20, 0, 38)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "PREMIUM EDITION"
    subtitle.TextColor3 = CONFIG.colors.accent2
    subtitle.Font = Enum.Font.GothamBold
    subtitle.TextSize = 11
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Parent = titleBar
    
    -- Status indicator
    local statusDot = Instance.new("Frame")
    statusDot.Size = UDim2.new(0, 8, 0, 8)
    statusDot.Position = UDim2.new(0, 130, 0, 22)
    statusDot.BackgroundColor3 = CONFIG.colors.success
    statusDot.Parent = titleBar
    createCorner(statusDot, 4)
    
    -- Animação pulsing
    task.spawn(function()
        while titleBar and titleBar.Parent do
            TweenService:Create(statusDot, TweenInfo.new(1), {BackgroundTransparency = 0.5}):Play()
            task.wait(1)
            TweenService:Create(statusDot, TweenInfo.new(1), {BackgroundTransparency = 0}):Play()
            task.wait(1)
        end
    end)
    
    -- Window Controls
    local controlsFrame = Instance.new("Frame")
    controlsFrame.Size = UDim2.new(0, 80, 0, 35)
    controlsFrame.Position = UDim2.new(1, -90, 0, 15)
    controlsFrame.BackgroundTransparency = 1
    controlsFrame.Parent = titleBar
    
    -- Minimize Button
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 32, 0, 32)
    minBtn.Position = UDim2.new(0, 0, 0, 0)
    minBtn.BackgroundColor3 = CONFIG.colors.warning
    minBtn.Text = "−"
    minBtn.TextColor3 = Color3.new(0, 0, 0)
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = 18
    minBtn.Parent = controlsFrame
    createCorner(minBtn, 8)
    
    minBtn.MouseButton1Click:Connect(function()
        isUIOpen = not isUIOpen
        contentArea.Visible = isUIOpen
        tabBar.Visible = isUIOpen
        minBtn.Text = isUIOpen and "−" or "+"
        mainWindow.Size = isUIOpen and UDim2.new(0, 500, 0, 400) or UDim2.new(0, 500, 0, 60)
    end)
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 32, 0, 32)
    closeBtn.Position = UDim2.new(1, -32, 0, 0)
    closeBtn.BackgroundColor3 = CONFIG.colors.danger
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18
    closeBtn.Parent = controlsFrame
    createCorner(closeBtn, 8)
    
    closeBtn.MouseButton1Click:Connect(function()
        mainWindow.Visible = false
    end)
    
    -- TAB BAR
    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(0, 130, 1, -60)
    tabBar.Position = UDim2.new(0, 0, 0, 60)
    tabBar.BackgroundColor3 = CONFIG.colors.tabBg
    tabBar.BorderSizePixel = 0
    tabBar.Parent = mainWindow
    
    -- Tab Content Area
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -130, 1, -60)
    contentArea.Position = UDim2.new(0, 130, 0, 60)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = mainWindow
    
    -- User Card na Sidebar
    local userCard = Instance.new("Frame")
    userCard.Size = UDim2.new(1, -20, 0, 70)
    userCard.Position = UDim2.new(0, 10, 1, -80)
    userCard.BackgroundColor3 = CONFIG.colors.cardBg
    userCard.Parent = tabBar
    createCorner(userCard, 10)
    
    local avatar = Instance.new("Frame")
    avatar.Size = UDim2.new(0, 40, 0, 40)
    avatar.Position = UDim2.new(0, 15, 0.5, -20)
    avatar.BackgroundColor3 = CONFIG.colors.accent
    avatar.Parent = userCard
    createCorner(avatar, 20)
    
    local avatarText = Instance.new("TextLabel")
    avatarText.Size = UDim2.new(1, 0, 1, 0)
    avatarText.BackgroundTransparency = 1
    avatarText.Text = "C"
    avatarText.TextColor3 = Color3.new(1, 1, 1)
    avatarText.Font = Enum.Font.GothamBlack
    avatarText.TextSize = 18
    avatarText.Parent = avatar
    
    local userName = Instance.new("TextLabel")
    userName.Size = UDim2.new(1, -70, 0, 20)
    userName.Position = UDim2.new(0, 65, 0, 15)
    userName.BackgroundTransparency = 1
    userName.Text = player.Name
    userName.TextColor3 = CONFIG.colors.text
    userName.Font = Enum.Font.GothamBold
    userName.TextSize = 13
    userName.TextXAlignment = Enum.TextXAlignment.Left
    userName.Parent = userCard
    
    local userStatus = Instance.new("TextLabel")
    userStatus.Size = UDim2.new(1, -70, 0, 15)
    userStatus.Position = UDim2.new(0, 65, 0, 38)
    userStatus.BackgroundTransparency = 1
    userStatus.Text = "Premium User"
    userStatus.TextColor3 = CONFIG.colors.accent2
    userStatus.Font = Enum.Font.Gotham
    userStatus.TextSize = 10
    userStatus.TextXAlignment = Enum.TextXAlignment.Left
    userStatus.Parent = userCard
    
    -- TAB SYSTEM
    local tabs = {}
    local tabButtons = {}
    
    local function createTab(name, icon, position)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 45)
        btn.Position = UDim2.new(0, 10, 0, 15 + (position * 55))
        btn.BackgroundColor3 = currentTab == name and CONFIG.colors.cardBg or Color3.fromRGB(45, 45, 60)
        btn.BackgroundTransparency = currentTab == name and 0 or 1
        btn.Text = ""
        btn.Parent = tabBar
        createCorner(btn, 10)
        
        -- Icon
        local iconLabel = Instance.new("TextLabel")
        iconLabel.Size = UDim2.new(0, 30, 0, 30)
        iconLabel.Position = UDim2.new(0, 12, 0.5, -15)
        iconLabel.BackgroundTransparency = 1
        iconLabel.Text = icon
        iconLabel.TextSize = 18
        iconLabel.Parent = btn
        
        -- Text
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, -50, 1, 0)
        textLabel.Position = UDim2.new(0, 45, 0, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = name
        textLabel.TextColor3 = currentTab == name and CONFIG.colors.text or CONFIG.colors.textDim
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextSize = 14
        textLabel.TextXAlignment = Enum.TextXAlignment.Left
        textLabel.Parent = btn
        
        -- Indicator
        local indicator = Instance.new("Frame")
        indicator.Size = UDim2.new(0, 3, 0, 20)
        indicator.Position = UDim2.new(0, 0, 0.5, -10)
        indicator.BackgroundColor3 = currentTab == name and CONFIG.colors.accent or Color3.fromRGB(45, 45, 60)
        indicator.BorderSizePixel = 0
        indicator.Parent = btn
        createCorner(indicator, 2)
        
        tabButtons[name] = {btn = btn, text = textLabel, indicator = indicator}
        
        -- Tab Content
        local content = Instance.new("ScrollingFrame")
        content.Name = name .. "Content"
        content.Size = UDim2.new(1, -20, 1, -20)
        content.Position = UDim2.new(0, 10, 0, 10)
        content.BackgroundTransparency = 1
        content.ScrollBarThickness = 4
        content.ScrollBarImageColor3 = CONFIG.colors.accent
        content.Visible = currentTab == name
        content.CanvasSize = UDim2.new(0, 0, 0, 0)
        content.Parent = contentArea
        
        tabs[name] = content
        
        btn.MouseButton1Click:Connect(function()
            currentTab = name
            for n, c in pairs(tabs) do
                c.Visible = (n == name)
            end
            for n, b in pairs(tabButtons) do
                local isActive = (n == name)
                b.btn.BackgroundColor3 = isActive and CONFIG.colors.cardBg or Color3.fromRGB(45, 45, 60)
                b.btn.BackgroundTransparency = isActive and 0 or 1
                b.text.TextColor3 = isActive and CONFIG.colors.text or CONFIG.colors.textDim
                b.indicator.BackgroundColor3 = isActive and CONFIG.colors.accent or Color3.fromRGB(45, 45, 60)
            end
        end)
        
        return content
    end
    
    -- REACH TAB
    local reachTab = createTab("Reach", "⚡", 0)
    
    -- Header
    local reachHeader = Instance.new("TextLabel")
    reachHeader.Size = UDim2.new(1, 0, 0, 30)
    reachHeader.BackgroundTransparency = 1
    reachHeader.Text = "REACH CONFIGURATION"
    reachHeader.TextColor3 = CONFIG.colors.textDim
    reachHeader.Font = Enum.Font.GothamBold
    reachHeader.TextSize = 12
    reachHeader.Parent = reachTab
    
    -- Player Reach
    createSlider(reachTab, "👤 PLAYER REACH", CONFIG.playerReach, 1, 150, CONFIG.colors.accent, function(val)
        CONFIG.playerReach = val
        updatePlayerSphere()
    end, 40)
    
    -- Ball Reach - CORREÇÃO: Agora funciona para TPS também
    createSlider(reachTab, "⚽ BALL REACH (TPS)", CONFIG.ballReach, 1, 150, CONFIG.colors.accent2, function(val)
        CONFIG.ballReach = val
        -- CORREÇÃO: Atualiza auras imediatamente
        for ball, data in pairs(ballAuras) do
            if data.aura then
                data.aura.Size = Vector3.new(val * 2, val * 2, val * 2)
            end
        end
    end, 190)
    
    -- Quantum Reach
    createSlider(reachTab, "🔮 QUANTUM REACH", CONFIG.quantumReach, 1, 150, CONFIG.colors.accent3, function(val)
        CONFIG.quantumReach = val
        updateQuantumCircle()
    end, 340)
    
    -- Toggles
    createToggle(reachTab, "⚡ FLASH MODE", CONFIG.flashEnabled, function(val)
        CONFIG.flashEnabled = val
    end, 490)
    
    createToggle(reachTab, "🔮 QUANTUM TOUCH", CONFIG.quantumReachEnabled, function(val)
        CONFIG.quantumReachEnabled = val
        updateQuantumCircle()
    end, 570)
    
    -- SETTINGS TAB
    local settingsTab = createTab("Settings", "⚙️", 1)
    
    local settingsHeader = Instance.new("TextLabel")
    settingsHeader.Size = UDim2.new(1, 0, 0, 30)
    settingsHeader.BackgroundTransparency = 1
    settingsHeader.Text = "SYSTEM SETTINGS"
    settingsHeader.TextColor3 = CONFIG.colors.textDim
    settingsHeader.Font = Enum.Font.GothamBold
    settingsHeader.TextSize = 12
    settingsHeader.Parent = settingsTab
    
    createToggle(settingsTab, "🤖 AUTO TOUCH", CONFIG.autoTouch, function(val)
        CONFIG.autoTouch = val
    end, 40)
    
    createToggle(settingsTab, "👁️ SHOW VISUALS", CONFIG.showVisuals, function(val)
        CONFIG.showVisuals = val
        if not val then
            clearAllAuras()
        else
            updateBallAuras()
            updateQuantumCircle()
        end
    end, 120)
    
    createToggle(settingsTab, "😴 ANTI-AFK", CONFIG.antiAFK, function(val)
        CONFIG.antiAFK = val
    end, 200)
    
    -- INFO TAB
    local infoTab = createTab("Info", "ℹ️", 2)
    
    local infoCard = Instance.new("Frame")
    infoCard.Size = UDim2.new(1, 0, 0, 200)
    infoCard.BackgroundColor3 = CONFIG.colors.cardBg
    infoCard.Parent = infoTab
    createCorner(infoCard, 12)
    
    local infoTitle = Instance.new("TextLabel")
    infoTitle.Size = UDim2.new(1, -20, 0, 30)
    infoTitle.Position = UDim2.new(0, 10, 0, 15)
    infoTitle.BackgroundTransparency = 1
    infoTitle.Text = "CADU HUB PREMIUM"
    infoTitle.TextColor3 = CONFIG.colors.accent
    infoTitle.Font = Enum.Font.GothamBlack
    infoTitle.TextSize = 18
    infoTitle.Parent = infoCard
    
    local infoText = Instance.new("TextLabel")
    infoText.Size = UDim2.new(1, -20, 0, 120)
    infoText.Position = UDim2.new(0, 10, 0, 50)
    infoText.BackgroundTransparency = 1
    infoText.Text = "Enhanced reach system for Roblox sports games.\n\nFeatures:\n• Player & Ball Reach\n• Quantum Touch System\n• TPS Ball Detection\n• Flash Mode\n• Anti-AFK Protection"
    infoText.TextColor3 = CONFIG.colors.textDim
    infoText.Font = Enum.Font.Gotham
    infoText.TextSize = 12
    infoText.TextWrapped = true
    infoText.TextXAlignment = Enum.TextXAlignment.Left
    infoText.TextYAlignment = Enum.TextYAlignment.Top
    infoText.Parent = infoCard
    
    -- Update canvas sizes
    for _, tab in pairs(tabs) do
        local contentHeight = 0
        for _, child in pairs(tab:GetChildren()) do
            if child:IsA("GuiObject") then
                contentHeight = math.max(contentHeight, child.Position.Y.Offset + child.Size.Y.Offset)
            end
        end
        tab.CanvasSize = UDim2.new(0, 0, 0, contentHeight + 20)
    end
    
    -- Keybind
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
            mainWindow.Visible = not mainWindow.Visible
        end
    end)
    
    -- Mobile Button
    if isMobile then
        local mobileBtn = Instance.new("TextButton")
        mobileBtn.Size = UDim2.new(0, 55, 0, 55)
        mobileBtn.Position = UDim2.new(0, 20, 0.5, -27)
        mobileBtn.BackgroundColor3 = CONFIG.colors.accent
        mobileBtn.Text = "⚡"
        mobileBtn.TextColor3 = Color3.new(1, 1, 1)
        mobileBtn.Font = Enum.Font.GothamBold
        mobileBtn.TextSize = 24
        mobileBtn.Parent = gui
        createCorner(mobileBtn, 28)
        createStroke(mobileBtn, CONFIG.colors.accent2, 2)
        
        mobileBtn.MouseButton1Click:Connect(function()
            mainWindow.Visible = not mainWindow.Visible
        end)
    end
end

-- MAIN LOOP OTIMIZADO
createConnection(RunService.RenderStepped, function()
    if isUIOpen then
        updatePlayerSphere()
        updateBallAuras()
        if quantumCircle and HRP then
            quantumCircle.Position = HRP.Position
            quantumCircle.Transparency = (CONFIG.quantumReachEnabled and CONFIG.showVisuals) and 0.8 or 1
        end
    end
    doReach()
    doQuantumReach()
end)

-- Initialize
buildMainGUI()

-- Notification moderna
local function notify(text, color)
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 320, 0, 70)
    notif.Position = UDim2.new(1, 20, 1, -90)
    notif.BackgroundColor3 = CONFIG.colors.cardBg
    notif.BorderSizePixel = 0
    notif.Parent = player:WaitForChild("PlayerGui")
    createCorner(notif, 12)
    createStroke(notif, color or CONFIG.colors.accent, 2)
    
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 40, 0, 40)
    icon.Position = UDim2.new(0, 15, 0.5, -20)
    icon.BackgroundColor3 = color or CONFIG.colors.accent
    icon.Text = "✓"
    icon.TextColor3 = Color3.new(1, 1, 1)
    icon.Font = Enum.Font.GothamBlack
    icon.TextSize = 20
    icon.Parent = notif
    createCorner(icon, 8)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -70, 0, 40)
    label.Position = UDim2.new(0, 65, 0.5, -20)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = CONFIG.colors.text
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = notif
    
    TweenService:Create(notif, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
        Position = UDim2.new(1, -340, 1, -90)
    }):Play()
    
    task.delay(3, function()
        TweenService:Create(notif, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
            Position = UDim2.new(1, 20, 1, -90)
        }):Play()
        task.wait(0.5)
        notif:Destroy()
    end)
end

notify("CaduHub Premium Loaded!\nPress Right Shift to toggle", CONFIG.colors.success)
