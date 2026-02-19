-- ⚽ CADUXX137 HUB | The Classic Soccer | Supreme Edition
-- Base: pedrinjr hub + CADU Hub UI + Intro Animada

-- SERVICES
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

-- CONFIG
local CONFIG = {
    -- Reach
    reach = 12,
    ballReach = 15,
    quantumReach = 25,
    
    -- Features
    autoTouch = true,
    showReachSphere = true,
    showVisuals = true,
    flashEnabled = true,
    antiAFK = true,
    quantumReachEnabled = false,
    expandBallHitbox = true,
    ballMagnet = false,
    magnetStrength = 50,
    autoSecondTouch = true,
    fullBodyTouch = true, -- pedrinjr style: toca com todas as partes do corpo
    
    -- Performance
    scanCooldown = 1,
    
    -- Visual
    sphereColor = Color3.fromRGB(0, 85, 255), -- Azul pedrinjr
    auraColor = Color3.fromRGB(0, 255, 255), -- Ciano
    
    -- Lista completa de bolas
    ballNames = { "TPS", "ESA", "MRS", "PRS", "MPS", "SSS", "AIFA", "RBZ", "SoccerBall", "Football", "Ball" },
    
    -- Cores CADU
    colors = {
        bg = Color3.fromRGB(18, 18, 23),
        tabBg = Color3.fromRGB(30, 30, 38),
        cardBg = Color3.fromRGB(35, 35, 47),
        accent = Color3.fromRGB(0, 85, 255), -- Azul pedrinjr
        accent2 = Color3.fromRGB(235, 69, 158),
        accent3 = Color3.fromRGB(0, 255, 255),
        success = Color3.fromRGB(59, 165, 93),
        warning = Color3.fromRGB(250, 168, 26),
        danger = Color3.fromRGB(237, 66, 69),
        text = Color3.fromRGB(255, 255, 255),
        textDim = Color3.fromRGB(148, 155, 164),
        textDark = Color3.fromRGB(78, 86, 96),
        flash = Color3.fromRGB(255, 255, 100),
        toggleOn = Color3.fromRGB(59, 165, 93),
        toggleOff = Color3.fromRGB(78, 86, 96),
        gradient1 = Color3.fromRGB(0, 85, 255), -- Azul pedrinjr
        gradient2 = Color3.fromRGB(235, 69, 158)
    }
}

-- VARIÁVEIS
local balls = {}
local ballAuras = {}
local ballHitboxes = {}
local playerSphere = nil
local quantumCircle = nil
local HRP = nil
local mainGui, introGui, mainWindow, currentTab = nil, nil, nil, "Reach"
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local connections = {}
local isUIOpen = true
local introCompleted = false

-- BALL SET
local BALL_NAME_SET = {}
for _, n in ipairs(CONFIG.ballNames) do
    BALL_NAME_SET[n] = true
end

-- NOTIFICAÇÃO
local function notify(text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "⚽ CADUXX137 HUB",
            Text = text,
            Duration = duration or 3
        })
    end)
end

-- INTRO ANIMADA CADUXX137
local function playIntro()
    if introGui then introGui:Destroy() end
    
    introGui = Instance.new("ScreenGui")
    introGui.Name = "CADUXX137Intro"
    introGui.ResetOnSpawn = false
    introGui.DisplayOrder = 999999
    introGui.Parent = player:WaitForChild("PlayerGui")
    
    -- Background escuro
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bg.BorderSizePixel = 0
    bg.Parent = introGui
    
    -- Logo/Nome CADUXX137
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 80)
    nameLabel.Position = UDim2.new(0, 0, 0.3, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "CADUXX137"
    nameLabel.TextColor3 = CONFIG.colors.accent
    nameLabel.Font = Enum.Font.GothamBlack
    nameLabel.TextSize = 60
    nameLabel.TextTransparency = 1
    nameLabel.Parent = introGui
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, 0, 0, 40)
    subtitle.Position = UDim2.new(0, 0, 0.42, 0)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "HUB SUPREME"
    subtitle.TextColor3 = CONFIG.colors.accent2
    subtitle.Font = Enum.Font.GothamBold
    subtitle.TextSize = 30
    subtitle.TextTransparency = 1
    subtitle.Parent = introGui
    
    -- Avatar do jogador
    local avatarFrame = Instance.new("Frame")
    avatarFrame.Size = UDim2.new(0, 120, 0, 120)
    avatarFrame.Position = UDim2.new(0.5, -60, 0.55, -60)
    avatarFrame.BackgroundColor3 = CONFIG.colors.accent
    avatarFrame.BorderSizePixel = 0
    avatarFrame.BackgroundTransparency = 1
    avatarFrame.Parent = introGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = avatarFrame
    
    local avatarStroke = Instance.new("UIStroke")
    avatarStroke.Color = CONFIG.colors.accent3
    avatarStroke.Thickness = 4
    avatarStroke.Parent = avatarFrame
    
    -- Tenta pegar imagem do avatar
    local avatarImage = Instance.new("ImageLabel")
    avatarImage.Size = UDim2.new(1, 0, 1, 0)
    avatarImage.BackgroundTransparency = 1
    avatarImage.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=420&height=420&format=png"
    avatarImage.Parent = avatarFrame
    
    local avatarText = Instance.new("TextLabel")
    avatarText.Size = UDim2.new(1, 0, 1, 0)
    avatarText.BackgroundTransparency = 1
    avatarText.Text = string.sub(player.Name, 1, 1)
    avatarText.TextColor3 = Color3.new(1, 1, 1)
    avatarText.Font = Enum.Font.GothamBlack
    avatarText.TextSize = 50
    avatarText.Visible = false
    avatarText.Parent = avatarFrame
    
    -- Texto "Olá Player"
    local helloText = Instance.new("TextLabel")
    helloText.Size = UDim2.new(1, 0, 0, 50)
    helloText.Position = UDim2.new(0, 0, 0.7, 0)
    helloText.BackgroundTransparency = 1
    helloText.Text = "Olá, " .. player.Name .. "!"
    helloText.TextColor3 = CONFIG.colors.text
    helloText.Font = Enum.Font.GothamBold
    helloText.TextSize = 28
    helloText.TextTransparency = 1
    helloText.Parent = introGui
    
    -- Loading bar
    local loadingBg = Instance.new("Frame")
    loadingBg.Size = UDim2.new(0, 400, 0, 6)
    loadingBg.Position = UDim2.new(0.5, -200, 0.8, 0)
    loadingBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    loadingBg.BorderSizePixel = 0
    loadingBg.BackgroundTransparency = 1
    loadingBg.Parent = introGui
    
    local loadingCorner = Instance.new("UICorner")
    loadingCorner.CornerRadius = UDim.new(0, 3)
    loadingCorner.Parent = loadingBg
    
    local loadingFill = Instance.new("Frame")
    loadingFill.Size = UDim2.new(0, 0, 1, 0)
    loadingFill.BackgroundColor3 = CONFIG.colors.accent
    loadingFill.BorderSizePixel = 0
    loadingFill.Parent = loadingBg
    
    local loadingFillCorner = Instance.new("UICorner")
    loadingFillCorner.CornerRadius = UDim.new(0, 3)
    loadingFillCorner.Parent = loadingFill
    
    -- ANIMAÇÃO DA INTRO
    local introSequence = {
        -- [tempo] = {objeto, propriedade, valor final, duração}
        {0, bg, "BackgroundTransparency", 0.3, 0.5},
        {0.3, nameLabel, "TextTransparency", 0, 0.6},
        {0.5, subtitle, "TextTransparency", 0, 0.5},
        {0.8, avatarFrame, "BackgroundTransparency", 0, 0.5},
        {1.0, loadingBg, "BackgroundTransparency", 0, 0.3},
        {1.2, loadingFill, "Size", UDim2.new(0.3, 0, 1, 0), 0.4},
        {1.6, loadingFill, "Size", UDim2.new(0.7, 0, 1, 0), 0.4},
        {2.0, loadingFill, "Size", UDim2.new(1, 0, 1, 0), 0.4},
        {2.4, helloText, "TextTransparency", 0, 0.5},
        {3.0, helloText, "TextTransparency", 1, 0.3},
        {3.2, avatarFrame, "BackgroundTransparency", 1, 0.3},
        {3.3, subtitle, "TextTransparency", 1, 0.3},
        {3.4, nameLabel, "TextTransparency", 1, 0.3},
        {3.5, bg, "BackgroundTransparency", 1, 0.5},
    }
    
    -- Executa animações
    for _, anim in ipairs(introSequence) do
        task.delay(anim[1], function()
            TweenService:Create(anim[2], TweenInfo.new(anim[5], Enum.EasingStyle.Quart), {
                [anim[3]] = anim[4]
            }):Play()
        end)
    end
    
    -- Remove intro e mostra main GUI
    task.delay(4.2, function()
        introCompleted = true
        if introGui then
            TweenService:Create(introGui, TweenInfo.new(0.5), {Enabled = false}):Play()
            task.wait(0.5)
            introGui:Destroy()
        end
        -- Mostra a UI principal
        if mainWindow then
            mainWindow.Visible = true
            -- Animação de entrada da main window
            mainWindow.Size = UDim2.new(0, 400, 0, 300)
            mainWindow.Position = UDim2.new(0.5, -200, 0.5, -150)
            TweenService:Create(mainWindow, TweenInfo.new(0.6, Enum.EasingStyle.Back), {
                Size = UDim2.new(0, 500, 0, 400),
                Position = UDim2.new(0.5, -250, 0.5, -200)
            }):Play()
        end
        notify("Bem-vindo, " .. player.Name .. "! CADUXX137 HUB carregado.", 4)
    end)
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

-- GET BALLS (pedrinjr style otimizado)
local lastBallUpdate = 0
local function getBalls()
    local now = tick()
    if now - lastBallUpdate < 0.05 then return balls end
    lastBallUpdate = now
    
    table.clear(balls)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and BALL_NAME_SET[obj.Name] then
            table.insert(balls, obj)
        end
    end
    return balls
end

-- GET CHARACTER PARTS (pedrinjr style - full body)
local function getCharacterParts(char)
    local parts = {}
    for _, v in ipairs(char:GetChildren()) do
        if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
            table.insert(parts, v)
        end
    end
    return parts
end

-- HITBOX EXPANDIDA (CADU style)
local function createBallHitbox(ball)
    if ballHitboxes[ball] or not CONFIG.expandBallHitbox then return end
    
    local hitbox = Instance.new("Part")
    hitbox.Name = "CADUHitbox_" .. ball.Name
    hitbox.Shape = Enum.PartType.Ball
    hitbox.Size = Vector3.new(CONFIG.ballReach * 2, CONFIG.ballReach * 2, CONFIG.ballReach * 2)
    hitbox.Transparency = 1
    hitbox.Anchored = true
    hitbox.CanCollide = false
    hitbox.Material = Enum.Material.SmoothPlastic
    hitbox.Parent = Workspace
    
    local conn = RunService.Heartbeat:Connect(function()
        if ball and ball.Parent and hitbox and hitbox.Parent then
            hitbox.CFrame = ball.CFrame
        else
            if hitbox then hitbox:Destroy() end
        end
    end)
    
    ballHitboxes[ball] = {hitbox = hitbox, conn = conn}
end

local function removeBallHitbox(ball)
    if ballHitboxes[ball] then
        if ballHitboxes[ball].conn then ballHitboxes[ball].conn:Disconnect() end
        if ballHitboxes[ball].hitbox then ballHitboxes[ball].hitbox:Destroy() end
        ballHitboxes[ball] = nil
    end
end

local function updateBallHitboxes()
    for ball, _ in pairs(ballHitboxes) do
        if not ball or not ball.Parent then removeBallHitbox(ball) end
    end
    
    if not CONFIG.expandBallHitbox then return end
    
    for _, ball in ipairs(balls) do
        if ball and ball.Parent then
            if ballHitboxes[ball] then
                local targetSize = Vector3.new(CONFIG.ballReach * 2, CONFIG.ballReach * 2, CONFIG.ballReach * 2)
                if ballHitboxes[ball].hitbox.Size ~= targetSize then
                    ballHitboxes[ball].hitbox.Size = targetSize
                end
            else
                createBallHitbox(ball)
            end
        end
    end
end

-- AURA VISUAL (CADU style)
local function createBallAura(ball)
    if ballAuras[ball] or not CONFIG.showVisuals then return end
    
    local aura = Instance.new("Part")
    aura.Name = "CADUAura_" .. ball.Name
    aura.Shape = Enum.PartType.Ball
    aura.Size = Vector3.new(CONFIG.ballReach * 2, CONFIG.ballReach * 2, CONFIG.ballReach * 2)
    aura.Transparency = 0.85
    aura.Anchored = true
    aura.CanCollide = false
    aura.Material = Enum.Material.ForceField
    aura.Color = ball.Name == "TPS" and CONFIG.auraColor or CONFIG.colors.accent2
    aura.Parent = Workspace
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "CADUHighlight_" .. ball.Name
    highlight.Adornee = ball
    highlight.FillColor = ball.Name == "TPS" and CONFIG.auraColor or CONFIG.colors.accent2
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = ball
    
    local conn = RunService.RenderStepped:Connect(function()
        if ball and ball.Parent and aura and aura.Parent then
            aura.CFrame = ball.CFrame
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

local function removeBallAura(ball)
    if ballAuras[ball] then
        if ballAuras[ball].conn then ballAuras[ball].conn:Disconnect() end
        if ballAuras[ball].aura then ballAuras[ball].aura:Destroy() end
        if ballAuras[ball].highlight then ballAuras[ball].highlight:Destroy() end
        ballAuras[ball] = nil
    end
end

local function updateBallAuras()
    for ball, _ in pairs(ballAuras) do
        if not ball or not ball.Parent then removeBallAura(ball) end
    end
    
    if not CONFIG.showVisuals then return end
    
    for _, ball in ipairs(balls) do
        if ball and ball.Parent then
            if ballAuras[ball] then
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

-- CLEAR ALL
local function clearAllAuras()
    for ball, data in pairs(ballAuras) do
        if data.conn then data.conn:Disconnect() end
        if data.aura then data.aura:Destroy() end
        if data.highlight then data.highlight:Destroy() end
    end
    ballAuras = {}
    
    for ball, data in pairs(ballHitboxes) do
        if data.conn then data.conn:Disconnect() end
        if data.hitbox then data.hitbox:Destroy() end
    end
    ballHitboxes = {}
    
    if playerSphere then
        playerSphere:Destroy()
        playerSphere = nil
    end
    if quantumCircle then
        quantumCircle:Destroy()
        quantumCircle = nil
    end
end

-- REACH SPHERE (pedrinjr style azul)
local function updateReachSphere()
    if not CONFIG.showReachSphere then
        if playerSphere then playerSphere:Destroy() playerSphere = nil end
        return
    end
    if not HRP then return end
    
    if not playerSphere then
        playerSphere = Instance.new("Part")
        playerSphere.Name = "CADUReachSphere"
        playerSphere.Shape = Enum.PartType.Ball
        playerSphere.Anchored = true
        playerSphere.CanCollide = false
        playerSphere.Transparency = 0.75
        playerSphere.Material = Enum.Material.ForceField
        playerSphere.Color = CONFIG.sphereColor -- Azul pedrinjr
        playerSphere.Parent = Workspace
    end
    
    playerSphere.Size = Vector3.new(CONFIG.reach * 2, CONFIG.reach * 2, CONFIG.reach * 2)
    playerSphere.Position = HRP.Position
end

-- QUANTUM CIRCLE
local function updateQuantumCircle()
    if not quantumCircle then
        quantumCircle = Instance.new("Part")
        quantumCircle.Name = "CADUQuantum"
        quantumCircle.Shape = Enum.PartType.Ball
        quantumCircle.Anchored = true
        quantumCircle.CanCollide = false
        quantumCircle.Material = Enum.Material.ForceField
        quantumCircle.Color = CONFIG.auraColor
        quantumCircle.Parent = Workspace
    end
    quantumCircle.Size = Vector3.new(CONFIG.quantumReach * 2, CONFIG.quantumReach * 2, CONFIG.quantumReach * 2)
    quantumCircle.Transparency = (CONFIG.quantumReachEnabled and CONFIG.showVisuals) and 0.75 or 1
end

-- ULTRA TOUCH (pedrinjr + CADU fusion)
local function ultraTouch(ball, part)
    if not ball or not part then return end
    
    -- Método 1: Toque direto (pedrinjr style)
    pcall(function()
        firetouchinterest(ball, part, 0)
        firetouchinterest(ball, part, 1)
    end)
    
    -- Método 2: Hitbox expandida (CADU)
    if ballHitboxes[ball] and ballHitboxes[ball].hitbox then
        pcall(function()
            firetouchinterest(ballHitboxes[ball].hitbox, part, 0)
            firetouchinterest(ballHitboxes[ball].hitbox, part, 1)
        end)
    end
    
    -- Método 3: Múltiplos pontos (CADU enhanced)
    local offsets = {
        Vector3.new(0, 0, 0),
        Vector3.new(0, 1, 0),
        Vector3.new(0, -1, 0),
        Vector3.new(1, 0, 0),
        Vector3.new(-1, 0, 0),
    }
    
    for _, offset in ipairs(offsets) do
        local touchPoint = ball.CFrame:PointToWorldSpace(offset)
        local tempPart = Instance.new("Part")
        tempPart.Size = Vector3.new(0.5, 0.5, 0.5)
        tempPart.CFrame = CFrame.new(touchPoint)
        tempPart.Anchored = true
        tempPart.CanCollide = false
        tempPart.Transparency = 1
        tempPart.Parent = Workspace
        
        pcall(function()
            firetouchinterest(tempPart, part, 0)
            firetouchinterest(tempPart, part, 1)
        end)
        
        Debris:AddItem(tempPart, 0.05)
    end
end

-- DO REACH PRINCIPAL (pedrinjr style full body + CADU hitbox)
local function doReach()
    if not CONFIG.autoTouch or not player.Character or not HRP then return end
    
    local char = player.Character
    local parts = CONFIG.fullBodyTouch and getCharacterParts(char) or {HRP}
    
    if #parts == 0 then return end

    local ballsList = getBalls()
    local effectiveReach = CONFIG.reach + CONFIG.ballReach
    
    for _, ball in ipairs(ballsList) do
        if not ball or not ball.Parent then continue end
        
        for _, part in ipairs(parts) do
            local dist = (ball.Position - part.Position).Magnitude
            
            if dist < effectiveReach then
                ultraTouch(ball, part)
                
                -- Flash effect
                if CONFIG.flashEnabled and CONFIG.showVisuals then
                    local flash = Instance.new("Part")
                    flash.Size = Vector3.new(0.5, 0.5, 0.5)
                    flash.Position = ball.Position
                    flash.Anchored = true
                    flash.CanCollide = false
                    flash.Material = Enum.Material.Neon
                    flash.Color = CONFIG.colors.flash
                    flash.Parent = Workspace
                    
                    TweenService:Create(flash, TweenInfo.new(0.1), {
                        Size = Vector3.new(3, 3, 3),
                        Transparency = 1
                    }):Play()
                    
                    Debris:AddItem(flash, 0.1)
                end
            end
        end
    end
end

-- DO QUANTUM REACH
local function doQuantumReach()
    if not CONFIG.quantumReachEnabled or not HRP then return end
    
    local char = player.Character
    local parts = getCharacterParts(char)
    if #parts == 0 then return end

    local ballsList = getBalls()
    for _, ball in ipairs(ballsList) do
        if ball and ball.Parent then
            for _, part in ipairs(parts) do
                if (ball.Position - part.Position).Magnitude < CONFIG.quantumReach then
                    ultraTouch(ball, part)
                end
            end
        end
    end
end

-- BALL MAGNET
local function doBallMagnet()
    if not CONFIG.ballMagnet or not HRP or CONFIG.magnetStrength == 0 then return end
    
    for _, ball in ipairs(balls) do
        if ball and ball.Parent then
            local dist = (ball.Position - HRP.Position).Magnitude
            if dist <= CONFIG.reach and dist > 3 then
                local dir = (HRP.Position - ball.Position).Unit
                ball.Velocity = ball.Velocity + dir * CONFIG.magnetStrength
            end
        end
    end
end

-- UI FUNCTIONS (CADU style)
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

-- TOGGLE MODERNO
local function createToggle(parent, text, defaultValue, callback, yPos)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 70)
    toggleFrame.Position = UDim2.new(0, 0, 0, yPos or 0)
    toggleFrame.BackgroundColor3 = CONFIG.colors.cardBg
    toggleFrame.Parent = parent
    createCorner(toggleFrame, 12)
    
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

-- SLIDER MODERNO
local function createSlider(parent, text, value, min, max, color, callback, yPos)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, 0, 0, 140)
    section.Position = UDim2.new(0, 0, 0, yPos or 0)
    section.BackgroundColor3 = CONFIG.colors.cardBg
    section.Parent = parent
    createCorner(section, 12)
    
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
    
    local function updateValue(newVal)
        newVal = math.clamp(math.floor(newVal + 0.5), min, max)
        valueLabel.Text = tostring(newVal)
        TweenService:Create(sliderFill, TweenInfo.new(0.15), {
            Size = UDim2.new((newVal - min) / (max - min), 0, 1, 0)
        }):Play()
        callback(newVal)
        return newVal
    end
    
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

-- BUILD MAIN GUI (CADU style)
function buildMainGUI()
    if mainGui then return end
    
    mainGui = Instance.new("ScreenGui")
    mainGui.Name = "CADUXX137Hub"
    mainGui.ResetOnSpawn = false
    mainGui.Enabled = false -- Desabilitado até a intro terminar
    mainGui.Parent = player:WaitForChild("PlayerGui")
    
    -- Main Window
    mainWindow = Instance.new("Frame")
    mainWindow.Size = UDim2.new(0, 500, 0, 400)
    mainWindow.Position = UDim2.new(0.5, -250, 0.5, -200)
    mainWindow.BackgroundColor3 = CONFIG.colors.bg
    mainWindow.BorderSizePixel = 0
    mainWindow.ClipsDescendants = true
    mainWindow.Visible = false -- Escondido até a intro terminar
    mainWindow.Parent = mainGui
    
    createCorner(mainWindow, 16)
    createShadow(mainWindow)
    
    -- Draggable
    local dragging = false
    local dragInput, dragStart, startPos
    
    local function updateDrag(input)
        local delta = input.Position - dragStart
        mainWindow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 60)
    titleBar.BackgroundColor3 = CONFIG.colors.tabBg
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainWindow
    
    titleBar.InputBegan:Connect(function(input)
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
    
    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updateDrag(input)
        end
    end)
    
    -- Title Bar Content
    local topGradient = Instance.new("Frame")
    topGradient.Size = UDim2.new(1, 0, 0, 3)
    topGradient.BackgroundColor3 = CONFIG.colors.accent
    topGradient.BorderSizePixel = 0
    topGradient.Parent = titleBar
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, CONFIG.colors.gradient1),
        ColorSequenceKeypoint.new(1, CONFIG.colors.gradient2)
    })
    gradient.Rotation = 45
    gradient.Parent = topGradient
    
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(0, 300, 0, 30)
    titleText.Position = UDim2.new(0, 20, 0, 15)
    titleText.BackgroundTransparency = 1
    titleText.Text = "⚽ CADUXX137 HUB"
    titleText.TextColor3 = CONFIG.colors.text
    titleText.Font = Enum.Font.GothamBlack
    titleText.TextSize = 22
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(0, 200, 0, 20)
    subtitle.Position = UDim2.new(0, 20, 0, 38)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "SUPREME EDITION"
    subtitle.TextColor3 = CONFIG.colors.accent2
    subtitle.Font = Enum.Font.GothamBold
    subtitle.TextSize = 11
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Parent = titleBar
    
    -- Status Pulsing Dot
    local statusDot = Instance.new("Frame")
    statusDot.Size = UDim2.new(0, 8, 0, 8)
    statusDot.Position = UDim2.new(0, 210, 0, 22)
    statusDot.BackgroundColor3 = CONFIG.colors.success
    statusDot.Parent = titleBar
    createCorner(statusDot, 4)
    
    task.spawn(function()
        while titleBar and titleBar.Parent do
            TweenService:Create(statusDot, TweenInfo.new(1), {BackgroundTransparency = 0.5}):Play()
            task.wait(1)
            TweenService:Create(statusDot, TweenInfo.new(1), {BackgroundTransparency = 0}):Play()
            task.wait(1)
        end
    end)
    
    -- Controls
    local controlsFrame = Instance.new("Frame")
    controlsFrame.Size = UDim2.new(0, 80, 0, 35)
    controlsFrame.Position = UDim2.new(1, -90, 0, 15)
    controlsFrame.BackgroundTransparency = 1
    controlsFrame.Parent = titleBar
    
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
        notify("UI escondida. Pressione RightShift para abrir")
    end)
    
    -- Tab Bar
    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(0, 130, 1, -60)
    tabBar.Position = UDim2.new(0, 0, 0, 60)
    tabBar.BackgroundColor3 = CONFIG.colors.tabBg
    tabBar.BorderSizePixel = 0
    tabBar.Parent = mainWindow
    
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -130, 1, -60)
    contentArea.Position = UDim2.new(0, 130, 0, 60)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = mainWindow
    
    -- User Card com Avatar
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
    
    local avatarImage = Instance.new("ImageLabel")
    avatarImage.Size = UDim2.new(1, 0, 1, 0)
    avatarImage.BackgroundTransparency = 1
    avatarImage.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=420&height=420&format=png"
    avatarImage.Parent = avatar
    
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
    userStatus.Text = "Supreme User"
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
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 30, 0, 30)
    iconLabel.Position = UDim2.new(0, 12, 0.5, -15)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon
    iconLabel.TextSize = 18
    iconLabel.Parent = btn
    
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
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 3, 0, 20)
    indicator.Position = UDim2.new(0, 0, 0.5, -10)
    indicator.BackgroundColor3 = currentTab == name and CONFIG.colors.accent or Color3.fromRGB(45, 45, 60)
    indicator.BorderSizePixel = 0
    indicator.Parent = btn
    createCorner(indicator, 2)
    
    tabButtons[name] = {btn = btn, text = textLabel, indicator = indicator}
    
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

local reachHeader = Instance.new("TextLabel")
reachHeader.Size = UDim2.new(1, 0, 0, 30)
reachHeader.BackgroundTransparency = 1
reachHeader.Text = "REACH CONFIGURATION"
reachHeader.TextColor3 = CONFIG.colors.textDim
reachHeader.Font = Enum.Font.GothamBold
reachHeader.TextSize = 12
reachHeader.Parent = reachTab

createSlider(reachTab, "⚽ MAIN REACH", CONFIG.reach, 1, 150, CONFIG.colors.accent, function(val)
    CONFIG.reach = val
    updateReachSphere()
    notify("Reach: " .. val)
end, 40)

createSlider(reachTab, "🎯 BALL EXPAND", CONFIG.ballReach, 1, 100, CONFIG.colors.accent2, function(val)
    CONFIG.ballReach = val
    for ball, data in pairs(ballAuras) do
        if data.aura then
            data.aura.Size = Vector3.new(val * 2, val * 2, val * 2)
        end
    end
end, 190)

createSlider(reachTab, "🔮 QUANTUM", CONFIG.quantumReach, 1, 200, CONFIG.colors.accent3, function(val)
    CONFIG.quantumReach = val
    updateQuantumCircle()
end, 340)

createToggle(reachTab, "🎯 EXPAND HITBOX", CONFIG.expandBallHitbox, function(val)
    CONFIG.expandBallHitbox = val
    if not val then
        for ball, data in pairs(ballHitboxes) do
            if data.conn then data.conn:Disconnect() end
            if data.hitbox then data.hitbox:Destroy() end
        end
        ballHitboxes = {}
    end
end, 490)

createToggle(reachTab, "⚡ FLASH EFFECT", CONFIG.flashEnabled, function(val)
    CONFIG.flashEnabled = val
end, 570)

createToggle(reachTab, "🔮 QUANTUM MODE", CONFIG.quantumReachEnabled, function(val)
    CONFIG.quantumReachEnabled = val
    updateQuantumCircle()
    notify("Quantum: " .. (val and "ON" or "OFF"))
end, 650)

-- FEATURES TAB
local featuresTab = createTab("Features", "🚀", 1)

local featuresHeader = Instance.new("TextLabel")
featuresHeader.Size = UDim2.new(1, 0, 0, 30)
featuresHeader.BackgroundTransparency = 1
featuresHeader.Text = "ADVANCED FEATURES"
featuresHeader.TextColor3 = CONFIG.colors.textDim
featuresHeader.Font = Enum.Font.GothamBold
featuresHeader.TextSize = 12
featuresHeader.Parent = featuresTab

createToggle(featuresTab, "🦵 FULL BODY TOUCH", CONFIG.fullBodyTouch, function(val)
    CONFIG.fullBodyTouch = val
    notify("Full Body: " .. (val and "ON" or "OFF"))
end, 40)

createToggle(featuresTab, "🧲 BALL MAGNET", CONFIG.ballMagnet, function(val)
    CONFIG.ballMagnet = val
    notify("Magnet: " .. (val and "ON" or "OFF"))
end, 120)

createSlider(featuresTab, "🧲 MAGNET POWER", CONFIG.magnetStrength, 0, 200, CONFIG.colors.warning, function(val)
    CONFIG.magnetStrength = val
end, 200)

createToggle(featuresTab, "🔄 AUTO SECOND", CONFIG.autoSecondTouch, function(val)
    CONFIG.autoSecondTouch = val
end, 350)

createToggle(featuresTab, "🤖 AUTO TOUCH", CONFIG.autoTouch, function(val)
    CONFIG.autoTouch = val
end, 430)

createToggle(featuresTab, "👁️ SHOW VISUALS", CONFIG.showVisuals, function(val)
    CONFIG.showVisuals = val
    if not val then
        clearAllAuras()
    else
        updateBallAuras()
        updateQuantumCircle()
    end
end, 510)

createToggle(featuresTab, "🔵 SHOW SPHERE", CONFIG.showReachSphere, function(val)
    CONFIG.showReachSphere = val
    updateReachSphere()
end, 590)

-- SETTINGS TAB
local settingsTab = createTab("Settings", "⚙️", 2)

local settingsHeader = Instance.new("TextLabel")
settingsHeader.Size = UDim2.new(1, 0, 0, 30)
settingsHeader.BackgroundTransparency = 1
settingsHeader.Text = "SYSTEM SETTINGS"
settingsHeader.TextColor3 = CONFIG.colors.textDim
settingsHeader.Font = Enum.Font.GothamBold
settingsHeader.TextSize = 12
settingsHeader.Parent = settingsTab

createToggle(settingsTab, "😴 ANTI-AFK", CONFIG.antiAFK, function(val)
    CONFIG.antiAFK = val
end, 40)

createSlider(settingsTab, "⏱️ SCAN RATE", CONFIG.scanCooldown, 0, 5, CONFIG.colors.success, function(val)
    CONFIG.scanCooldown = val
end, 120)

-- INFO TAB
local infoTab = createTab("Info", "ℹ️", 3)

local infoCard = Instance.new("Frame")
infoCard.Size = UDim2.new(1, 0, 0, 280)
infoCard.BackgroundColor3 = CONFIG.colors.cardBg
infoCard.Parent = infoTab
createCorner(infoCard, 12)

local infoTitle = Instance.new("TextLabel")
infoTitle.Size = UDim2.new(1, -20, 0, 30)
infoTitle.Position = UDim2.new(0, 10, 0, 15)
infoTitle.BackgroundTransparency = 1
infoTitle.Text = "⚽ CADUXX137 HUB"
infoTitle.TextColor3 = CONFIG.colors.accent
infoTitle.Font = Enum.Font.GothamBlack
infoTitle.TextSize = 18
infoTitle.Parent = infoCard

local infoText = Instance.new("TextLabel")
infoText.Size = UDim2.new(1, -20, 0, 200)
infoText.Position = UDim2.new(0, 10, 0, 50)
infoText.BackgroundTransparency = 1
infoText.Text = "Supreme Edition v2.0\n\nBase: pedrinjr hub + CADU Hub\n\nFeatures:\n• Full Body Touch (pedrinjr)\n• Expanded Hitbox (CADU)\n• Multi-Point Touch (7 pontos)\n• Ball Magnet com força\n• Quantum Reach separado\n• Sphere Visual Azul\n• Anti-AFK integrado\n• UI Premium com Abas\n\nCriador: CADUXX137\n\nHotkey: RightShift"
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
        if introCompleted then
            mainWindow.Visible = not mainWindow.Visible
        end
    end
end)

-- Mobile Button
if isMobile then
    local mobileBtn = Instance.new("TextButton")
    mobileBtn.Size = UDim2.new(0, 55, 0, 55)
    mobileBtn.Position = UDim2.new(0, 20, 0.5, -27)
    mobileBtn.BackgroundColor3 = CONFIG.colors.accent
    mobileBtn.Text = "⚽"
    mobileBtn.TextColor3 = Color3.new(1, 1, 1)
    mobileBtn.Font = Enum.Font.GothamBold
    mobileBtn.TextSize = 24
    mobileBtn.Parent = mainGui
    createCorner(mobileBtn, 28)
    createStroke(mobileBtn, CONFIG.colors.accent2, 2)
    
    mobileBtn.MouseButton1Click:Connect(function()
        if introCompleted then
            mainWindow.Visible = not mainWindow.Visible
        end
    end)
end

mainGui.Enabled = true
end

-- MAIN LOOPS
RunService.RenderStepped:Connect(function()
    if HRP then
        getBalls()
        if isUIOpen and introCompleted then
            updateBallAuras()
            updateBallHitboxes()
            updateReachSphere()
            updateQuantumCircle()
        end
        
        if playerSphere then playerSphere.Position = HRP.Position end
        if quantumCircle then 
            quantumCircle.Position = HRP.Position 
            quantumCircle.Transparency = (CONFIG.quantumReachEnabled and CONFIG.showVisuals) and 0.75 or 1
        end
    end
    
    if introCompleted then
        doReach()
        doQuantumReach()
        doBallMagnet()
    end
end)

-- START
buildMainGUI()
playIntro()

print("✅ CADUXX137 HUB SUPREME loaded!")
print("⚽ Base: pedrinjr hub + CADU Hub")
print("🎬 Intro animada ativa")
