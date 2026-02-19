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
  
