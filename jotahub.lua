-- SERVICES
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer

-- CONFIG
local CONFIG = {
    playerReach = 10,
    ballReach = 15,
    magnetStrength = 0,
    showPlayerSphere = true,
    showBallAura = true,
    autoTouch = true,
    scanCooldown = 0.1,
    ballNames = { "Ball", "TPS", "ESA", "MRS", "PRS", "MPS", "SSS", "AIFA", "RBZ", "SoccerBall", "Football" },
    
    -- CORES NEON
    colors = {
        primary = Color3.fromRGB(0, 255, 255),      -- Ciano neon
        secondary = Color3.fromRGB(255, 0, 255),    -- Magenta neon
        accent = Color3.fromRGB(255, 200, 0),       -- Amarelo ouro
        dark = Color3.fromRGB(10, 10, 15),          -- Fundo escuro
        darker = Color3.fromRGB(5, 5, 8),           -- Mais escuro
        glow = Color3.fromRGB(0, 200, 255)          -- Brilho
    }
}

-- VARIÁVEIS
local balls = {}
local ballAuras = {}
local lastRefresh = 0
local playerSphere = nil
local gui, mainFrame
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local activeTweens = {}

-- BALL SET
local BALL_NAME_SET = {}
for _, n in ipairs(CONFIG.ballNames) do
    BALL_NAME_SET[n] = true
end

-- NOTIFY ESTILIZADO
local function notify(txt, t)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "✨ Cadu Hub V3",
            Text = txt,
            Duration = t or 3
        })
    end)
end

-- CRIAR PARTÍCULAS DE FUNDO
local function createBackgroundParticles()
    local particleGui = Instance.new("ScreenGui")
    particleGui.Name = "BackgroundFX"
    particleGui.ResetOnSpawn = false
    particleGui.Parent = player:WaitForChild("PlayerGui")
    particleGui.DisplayOrder = -1
    
    for i = 1, 20 do
        local particle = Instance.new("Frame")
        particle.Size = UDim2.new(0, math.random(2, 6), 0, math.random(2, 6))
        particle.Position = UDim2.new(math.random(), 0, math.random(), 0)
        particle.BackgroundColor3 = CONFIG.colors.primary
        particle.BackgroundTransparency = 0.8
        particle.BorderSizePixel = 0
        particle.Parent = particleGui
        
        -- Animação flutuante
        local tween = TweenService:Create(particle, TweenInfo.new(
            math.random(3, 8),
            Enum.EasingStyle.Sine,
            Enum.EasingDirection.InOut,
            -1,
            true
        ), {
            Position = UDim2.new(math.random(), 0, math.random(), 0),
            BackgroundTransparency = math.random() * 0.5 + 0.3
        })
        tween:Play()
    end
end

-- REFRESH BALLS
local function refreshBalls()
    table.clear(balls)
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("BasePart") and BALL_NAME_SET[obj.Name] then
            table.insert(balls, obj)
        end
    end
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and BALL_NAME_SET[obj.Name] and not table.find(balls, obj) then
            table.insert(balls, obj)
        end
    end
end

-- CRIAR AURA NA BOLA COM EFEITOS
local function createBallAura(ball)
    if ballAuras[ball] then return end
    
    -- Esfera de reach com glow
    local reachSphere = Instance.new("Part")
    reachSphere.Name = "BallAuraSphere"
    reachSphere.Shape = Enum.PartType.Ball
    reachSphere.Size = Vector3.new(CONFIG.ballReach * 2, CONFIG.ballReach * 2, CONFIG.ballReach * 2)
    reachSphere.Transparency = 0.85
    reachSphere.Anchored = true
    reachSphere.CanCollide = false
    reachSphere.CastShadow = false
    reachSphere.Material = Enum.Material.ForceField
    reachSphere.Color = CONFIG.colors.secondary
    reachSphere.Parent = Workspace
    
    -- Inner glow
    local innerSphere = Instance.new("Part")
    innerSphere.Name = "BallInnerGlow"
    innerSphere.Shape = Enum.PartType.Ball
    innerSphere.Size = Vector3.new(CONFIG.ballReach * 1.5, CONFIG.ballReach * 1.5, CONFIG.ballReach * 1.5)
    innerSphere.Transparency = 0.9
    innerSphere.Anchored = true
    innerSphere.CanCollide = false
    innerSphere.CastShadow = false
    innerSphere.Material = Enum.Material.Neon
    innerSphere.Color = CONFIG.colors.secondary
    innerSphere.Parent = Workspace
    
    -- Highlight premium
    local highlight = Instance.new("Highlight")
    highlight.Name = "BallPremiumHighlight"
    highlight.Adornee = ball
    highlight.FillColor = CONFIG.colors.secondary
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = ball
    
    -- Partículas na bola
    local attachment = Instance.new("Attachment")
    attachment.Position = Vector3.new(0, 0, 0)
    attachment.Parent = ball
    
    local particle = Instance.new("ParticleEmitter")
    particle.Texture = "rbxassetid://258128463"
    particle.Color = ColorSequence.new(CONFIG.colors.secondary)
    particle.Size = NumberSequence.new(1, 3)
    particle.Transparency = NumberSequence.new(0.5, 1)
    particle.Lifetime = NumberRange.new(0.5, 1.5)
    particle.Rate = 15
    particle.Speed = NumberRange.new(2, 6)
    particle.SpreadAngle = Vector2.new(180, 180)
    particle.Parent = attachment
    
    -- Conexão suave
    local connection = RunService.RenderStepped:Connect(function()
        if ball and ball.Parent then
            if reachSphere and reachSphere.Parent then
                reachSphere.CFrame = ball.CFrame
            end
            if innerSphere and innerSphere.Parent then
                innerSphere.CFrame = ball.CFrame
            end
        else
            if reachSphere then reachSphere:Destroy() end
            if innerSphere then innerSphere:Destroy() end
            if attachment then attachment:Destroy() end
        end
    end)
    
    ballAuras[ball] = {
        reachSphere = reachSphere,
        innerSphere = innerSphere,
        highlight = highlight,
        attachment = attachment,
        connection = connection
    }
end

-- REMOVER AURA
local function removeBallAura(ball)
    if ballAuras[ball] then
        if ballAuras[ball].connection then
            ballAuras[ball].connection:Disconnect()
        end
        for _, obj in pairs({"reachSphere", "innerSphere", "highlight", "attachment"}) do
            if ballAuras[ball][obj] then
                ballAuras[ball][obj]:Destroy()
            end
        end
        ballAuras[ball] = nil
    end
end

-- ATUALIZAR AURAS
local function updateBallAuras()
    for ball, _ in pairs(ballAuras) do
        if not ball or not ball.Parent then
            removeBallAura(ball)
        end
    end
    
    for _, ball in ipairs(balls) do
        if ball and ball.Parent and CONFIG.showBallAura then
            createBallAura(ball)
        else
            removeBallAura(ball)
        end
    end
end

-- ATUALIZAR ESFERA DO JOGADOR COM EFEITOS
local function updatePlayerSphere()
    if not CONFIG.showPlayerSphere then
        if playerSphere then
            playerSphere:Destroy()
            playerSphere = nil
        end
        return
    end
    
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    if not playerSphere then
        -- Esfera externa
        playerSphere = Instance.new("Part")
        playerSphere.Name = "PlayerAuraSphere"
        playerSphere.Shape = Enum.PartType.Ball
        playerSphere.Transparency = 0.7
        playerSphere.Anchored = true
        playerSphere.CanCollide = false
        playerSphere.CastShadow = false
        playerSphere.Material = Enum.Material.ForceField
        playerSphere.Color = CONFIG.colors.primary
        playerSphere.Parent = Workspace
        
        -- Anel rotativo
        local ring = Instance.new("Part")
        ring.Name = "PlayerRing"
        ring.Shape = Enum.PartType.Cylinder
        ring.Size = Vector3.new(0.5, CONFIG.playerReach * 2, CONFIG.playerReach * 2)
        ring.Transparency = 0.5
        ring.Anchored = true
        ring.CanCollide = false
        ring.CastShadow = false
        ring.Material = Enum.Material.Neon
        ring.Color = CONFIG.colors.accent
        ring.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(90), 0)
        ring.Parent = playerSphere
        
        -- Animação do anel
        spawn(function()
            while ring and ring.Parent do
                local rotation = tick() * 2
                ring.CFrame = hrp.CFrame * CFrame.Angles(0, rotation, math.rad(90))
                RunService.RenderStepped:Wait()
            end
        end)
        
        -- Partículas no jogador
        local attachment = Instance.new("Attachment")
        attachment.Parent = hrp
        
        local particle = Instance.new("ParticleEmitter")
        particle.Texture = "rbxassetid://243660364"
        particle.Color = ColorSequence.new(CONFIG.colors.primary)
        particle.Size = NumberSequence.new(0.5, 2)
        particle.Transparency = NumberSequence.new(0.3, 1)
        particle.Lifetime = NumberRange.new(0.5, 1)
        particle.Rate = 20
        particle.Speed = NumberRange.new(1, 3)
        particle.Parent = attachment
        
        playerSphere:SetAttribute("Ring", ring)
        playerSphere:SetAttribute("Attachment", attachment)
    end
    
    playerSphere.Size = Vector3.new(CONFIG.playerReach * 2, CONFIG.playerReach * 2, CONFIG.playerReach * 2)
    playerSphere.CFrame = hrp.CFrame
end

-- AUTO TOUCH OTIMIZADO
local function processTouch()
    if not CONFIG.autoTouch then return end
    
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local myPos = hrp.Position
    
    for _, ball in ipairs(balls) do
        if not ball or not ball.Parent then continue end
        
        local dist = (ball.Position - myPos).Magnitude
        local effectiveReach = CONFIG.playerReach + CONFIG.ballReach
        
        if dist <= effectiveReach then
            -- Efeito visual ao tocar
            if dist < 5 then
                local touchEffect = Instance.new("Part")
                touchEffect.Size = Vector3.new(1, 1, 1)
                touchEffect.Position = ball.Position
                touchEffect.Anchored = true
                touchEffect.CanCollide = false
                touchEffect.Material = Enum.Material.Neon
                touchEffect.Color = CONFIG.colors.accent
                touchEffect.Parent = Workspace
                
                TweenService:Create(touchEffect, TweenInfo.new(0.3), {
                    Size = Vector3.new(4, 4, 4),
                    Transparency = 1
                }):Play()
                
                Debris:AddItem(touchEffect, 0.3)
            end
            
            -- Touch em todas as partes
            for _, part in ipairs(char:GetChildren()) do
                if part:IsA("BasePart") then
                    pcall(function()
                        firetouchinterest(ball, part, 0)
                        firetouchinterest(ball, part, 1)
                    end)
                end
            end
        end
    end
end

-- GUI ULTRA ESTILIZADA
function buildMainGUI()
    if gui then return end

    gui = Instance.new("ScreenGui")
    gui.Name = "CaduHubPremium"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")

    -- Frame principal com glassmorphism
    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 300, 0, 400)
    mainFrame.Position = UDim2.new(0, 20, 0.5, -200)
    mainFrame.BackgroundColor3 = CONFIG.colors.dark
    mainFrame.BackgroundTransparency = 0.15
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = gui

    -- Cantos arredondados
    local corner = Instance.new("UICorner", mainFrame)
    corner.CornerRadius = UDim.new(0, 20)

    -- Stroke neon
    local stroke = Instance.new("UIStroke", mainFrame)
    stroke.Color = CONFIG.colors.primary
    stroke.Thickness = 3
    stroke.Transparency = 0.3

    -- Gradiente de fundo
    local gradient = Instance.new("UIGradient", mainFrame)
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, CONFIG.colors.dark),
        ColorSequenceKeypoint.new(1, CONFIG.colors.darker)
    })
    gradient.Rotation = 45

    -- Glow effect
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.Size = UDim2.new(1.5, 0, 1.5, 0)
    glow.Position = UDim2.new(-0.25, 0, -0.25, 0)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://243660364"
    glow.ImageColor3 = CONFIG.colors.primary
    glow.ImageTransparency = 0.9
    glow.Parent = mainFrame

    -- Título com animação
    local titleContainer = Instance.new("Frame")
    titleContainer.Size = UDim2.new(1, -20, 0, 50)
    titleContainer.Position = UDim2.new(0, 10, 0, 10)
    titleContainer.BackgroundTransparency = 1
    titleContainer.Parent = mainFrame

    local titleBg = Instance.new("Frame")
    titleBg.Size = UDim2.new(1, 0, 1, 0)
    titleBg.BackgroundColor3 = CONFIG.colors.primary
    titleBg.BackgroundTransparency = 0.9
    titleBg.Parent = titleContainer
    Instance.new("UICorner", titleBg).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = "⚡ CADU HUB V3 ⚡"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 24
    title.Parent = titleContainer

    -- Subtítulo
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, -20, 0, 20)
    subtitle.Position = UDim2.new(0, 10, 0, 65)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "PREMIUM EDITION"
    subtitle.TextColor3 = CONFIG.colors.accent
    subtitle.Font = Enum.Font.GothamBold
    subtitle.TextSize = 12
    subtitle.Parent = mainFrame

    -- Container de controles
    local controlsContainer = Instance.new("Frame")
    controlsContainer.Size = UDim2.new(1, -20, 0, 280)
    controlsContainer.Position = UDim2.new(0, 10, 0, 95)
    controlsContainer.BackgroundTransparency = 1
    controlsContainer.Parent = mainFrame

    -- FUNÇÃO PARA CRIAR SEÇÃO
    local function createSection(name, yPos, color, icon)
        local section = Instance.new("Frame")
        section.Size = UDim2.new(1, 0, 0, 80)
        section.Position = UDim2.new(0, 0, 0, yPos)
        section.BackgroundColor3 = CONFIG.colors.darker
        section.BackgroundTransparency = 0.5
        section.Parent = controlsContainer
        Instance.new("UICorner", section).CornerRadius = UDim.new(0, 12)

        local sectionStroke = Instance.new("UIStroke", section)
        sectionStroke.Color = color
        sectionStroke.Thickness = 1
        sectionStroke.Transparency = 0.5

        local iconLabel = Instance.new("TextLabel")
        iconLabel.Size = UDim2.new(0, 30, 0, 30)
        iconLabel.Position = UDim2.new(0, 10, 0, 5)
        iconLabel.BackgroundTransparency = 1
        iconLabel.Text = icon
        iconLabel.TextSize = 20
        iconLabel.Parent = section

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, -50, 0, 25)
        nameLabel.Position = UDim2.new(0, 45, 0, 5)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = name
        nameLabel.TextColor3 = color
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 14
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = section

        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(1, -20, 0, 20)
        valueLabel.Position = UDim2.new(0, 10, 0, 30)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = "0 studs"
        valueLabel.TextColor3 = Color3.new(1, 1, 1)
        valueLabel.Font = Enum.Font.Gotham
        valueLabel.TextSize = 16
        valueLabel.Parent = section

        return section, valueLabel
    end

    -- SEÇÃO PLAYER REACH
    local playerSection, playerValue = createSection("PLAYER REACH", 0, CONFIG.colors.primary, "👤")
    
    local minusPlayer = Instance.new("TextButton")
    minusPlayer.Size = UDim2.new(0, 60, 0, 25)
    minusPlayer.Position = UDim2.new(0, 10, 0, 52)
    minusPlayer.Text = "−"
    minusPlayer.Font = Enum.Font.GothamBlack
    minusPlayer.TextSize = 18
    minusPlayer.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    minusPlayer.TextColor3 = Color3.new(1, 1, 1)
    minusPlayer.Parent = playerSection
    Instance.new("UICorner", minusPlayer).CornerRadius = UDim.new(0, 8)

    local plusPlayer = Instance.new("TextButton")
    plusPlayer.Size = UDim2.new(0, 60, 0, 25)
    plusPlayer.Position = UDim2.new(0, 80, 0, 52)
    plusPlayer.Text = "+"
    plusPlayer.Font = Enum.Font.GothamBlack
    plusPlayer.TextSize = 18
    plusPlayer.BackgroundColor3 = CONFIG.colors.primary
    plusPlayer.TextColor3 = Color3.new(0, 0, 0)
    plusPlayer.Parent = playerSection
    Instance.new("UICorner", plusPlayer).CornerRadius = UDim.new(0, 8)

    local resetPlayer = Instance.new("TextButton")
    resetPlayer.Size = UDim2.new(0, 70, 0, 25)
    resetPlayer.Position = UDim2.new(0, 150, 0, 52)
    resetPlayer.Text = "RESET"
    resetPlayer.Font = Enum.Font.GothamBold
    resetPlayer.TextSize = 12
    resetPlayer.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    resetPlayer.TextColor3 = Color3.new(1, 1, 1)
    resetPlayer.Parent = playerSection
    Instance.new("UICorner", resetPlayer).CornerRadius = UDim.new(0, 8)

    -- SEÇÃO BALL REACH
    local ballSection, ballValue = createSection("BALL REACH", 90, CONFIG.colors.secondary, "⚽")

    local minusBall = Instance.new("TextButton")
    minusBall.Size = UDim2.new(0, 60, 0, 25)
    minusBall.Position = UDim2.new(0, 10, 0, 52)
    minusBall.Text = "−"
    minusBall.Font = Enum.Font.GothamBlack
    minusBall.TextSize = 18
    minusBall.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    minusBall.TextColor3 = Color3.new(1, 1, 1)
    minusBall.Parent = ballSection
    Instance.new("UICorner", minusBall).CornerRadius = UDim.new(0, 8)

    local plusBall = Instance.new("TextButton")
    plusBall.Size = UDim2.new(0, 60, 0, 25)
    plusBall.Position = UDim2.new(0, 80, 0, 52)
    plusBall.Text = "+"
    plusBall.Font = Enum.Font.GothamBlack
    plusBall.TextSize = 18
    plusBall.BackgroundColor3 = CONFIG.colors.secondary
    plusBall.TextColor3 = Color3.new(0, 0, 0)
    plusBall.Parent = ballSection
    Instance.new("UICorner", plusBall).CornerRadius = UDim.new(0, 8)

    local resetBall = Instance.new("TextButton")
    resetBall.Size = UDim2.new(0, 70, 0, 25)
    resetBall.Position = UDim2.new(0, 150, 0, 52)
    resetBall.Text = "RESET"
    resetBall.Font = Enum.Font.GothamBold
    resetBall.TextSize = 12
    resetBall.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    resetBall.TextColor3 = Color3.new(1, 1, 1)
    resetBall.Parent = ballSection
    Instance.new("UICorner", resetBall).CornerRadius = UDim.new(0, 8)

        -- SESSÃO TOGGLES
    local toggleSection = Instance.new("Frame")
    toggleSection.Size = UDim2.new(1, 0, 0, 90)
    toggleSection.Position = UDim2.new(0, 0, 0, 180)
    toggleSection.BackgroundColor3 = CONFIG.colors.darker
    toggleSection.BackgroundTransparency = 0.5
    toggleSection.Parent = controlsContainer
    Instance.new("UICorner", toggleSection).CornerRadius = UDim.new(0, 12)

    local toggleStroke = Instance.new("UIStroke", toggleSection)
    toggleStroke.Color = CONFIG.colors.accent
    toggleStroke.Thickness = 1
    toggleStroke.Transparency = 0.5

    local toggleTitle = Instance.new("TextLabel")
    toggleTitle.Size = UDim2.new(1, -20, 0, 25)
    toggleTitle.Position = UDim2.new(0, 10, 0, 5)
    toggleTitle.BackgroundTransparency = 1
    toggleTitle.Text = "🔧 CONTROLES"
    toggleTitle.TextColor3 = CONFIG.colors.accent
    toggleTitle.Font = Enum.Font.GothamBold
    toggleTitle.TextSize = 14
    toggleTitle.TextXAlignment = Enum.TextXAlignment.Left
    toggleTitle.Parent = toggleSection

    -- Auto Touch Toggle
    local autoTouchBtn = Instance.new("TextButton")
    autoTouchBtn.Size = UDim2.new(0, 130, 0, 25)
    autoTouchBtn.Position = UDim2.new(0, 10, 0, 35)
    autoTouchBtn.Text = "AUTO TOUCH: ON"
    autoTouchBtn.Font = Enum.Font.GothamBold
    autoTouchBtn.TextSize = 11
    autoTouchBtn.BackgroundColor3 = CONFIG.colors.primary
    autoTouchBtn.TextColor3 = Color3.new(0, 0, 0)
    autoTouchBtn.Parent = toggleSection
    Instance.new("UICorner", autoTouchBtn).CornerRadius = UDim.new(0, 8)

    -- Visuals Toggle
    local visualsBtn = Instance.new("TextButton")
    visualsBtn.Size = UDim2.new(0, 130, 0, 25)
    visualsBtn.Position = UDim2.new(0, 10, 0, 65)
    visualsBtn.Text = "VISUALS: ON"
    visualsBtn.Font = Enum.Font.GothamBold
    visualsBtn.TextSize = 11
    visualsBtn.BackgroundColor3 = CONFIG.colors.secondary
    visualsBtn.TextColor3 = Color3.new(0, 0, 0)
    visualsBtn.Parent = toggleSection
    Instance.new("UICorner", visualsBtn).CornerRadius = UDim.new(0, 8)

    -- Hide Button
    local hideBtn = Instance.new("TextButton")
    hideBtn.Size = UDim2.new(0, 120, 0, 50)
    hideBtn.Position = UDim2.new(1, -130, 0, 35)
    hideBtn.Text = isMobile and "❌ FECHAR" or "❌ ESCONDER\n[INSERT]"
    hideBtn.Font = Enum.Font.GothamBold
    hideBtn.TextSize = 11
    hideBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    hideBtn.TextColor3 = Color3.new(1, 1, 1)
    hideBtn.Parent = toggleSection
    Instance.new("UICorner", hideBtn).CornerRadius = UDim.new(0, 10)

    -- ANIMAÇÃO DE ENTRADA
    mainFrame.Position = UDim2.new(0, -320, 0.5, -200)
    TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
        Position = UDim2.new(0, 20, 0.5, -200)
    }):Play()

    -- FUNÇÕES COM ANIMAÇÕES
    local function animateButton(btn)
        local original = btn.BackgroundColor3
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.new(1, 1, 1)}):Play()
        task.wait(0.1)
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = original}):Play()
    end

    local function updatePlayerDisplay()
        playerValue.Text = CONFIG.playerReach .. " studs"
        TweenService:Create(playerValue, TweenInfo.new(0.2), {TextColor3 = CONFIG.colors.accent}):Play()
        task.delay(0.2, function()
            TweenService:Create(playerValue, TweenInfo.new(0.2), {TextColor3 = Color3.new(1, 1, 1)}):Play()
        end)
    end

    local function updateBallDisplay()
        ballValue.Text = CONFIG.ballReach .. " studs"
        TweenService:Create(ballValue, TweenInfo.new(0.2), {TextColor3 = CONFIG.colors.accent}):Play()
        task.delay(0.2, function()
            TweenService:Create(ballValue, TweenInfo.new(0.2), {TextColor3 = Color3.new(1, 1, 1)}):Play()
        end)
    end

    minusPlayer.MouseButton1Click:Connect(function()
        animateButton(minusPlayer)
        CONFIG.playerReach = math.max(1, CONFIG.playerReach - 1)
        updatePlayerDisplay()
        updatePlayerSphere()
    end)

    plusPlayer.MouseButton1Click:Connect(function()
        animateButton(plusPlayer)
        CONFIG.playerReach = math.min(50, CONFIG.playerReach + 1)
        updatePlayerDisplay()
        updatePlayerSphere()
    end)

    resetPlayer.MouseButton1Click:Connect(function()
        animateButton(resetPlayer)
        CONFIG.playerReach = 10
        updatePlayerDisplay()
        updatePlayerSphere()
    end)

    minusBall.MouseButton1Click:Connect(function()
        animateButton(minusBall)
        CONFIG.ballReach = math.max(1, CONFIG.ballReach - 1)
        updateBallDisplay()
        updateBallAuras()
    end)

    plusBall.MouseButton1Click:Connect(function()
        animateButton(plusBall)
        CONFIG.ballReach = math.min(50, CONFIG.ballReach + 1)
        updateBallDisplay()
        updateBallAuras()
    end)

    resetBall.MouseButton1Click:Connect(function()
        animateButton(resetBall)
        CONFIG.ballReach = 15
        updateBallDisplay()
        updateBallAuras()
    end)

    autoTouchBtn.MouseButton1Click:Connect(function()
        CONFIG.autoTouch = not CONFIG.autoTouch
        autoTouchBtn.Text = CONFIG.autoTouch and "AUTO TOUCH: ON" or "AUTO TOUCH: OFF"
        autoTouchBtn.BackgroundColor3 = CONFIG.autoTouch and CONFIG.colors.primary or Color3.fromRGB(100, 100, 100)
        animateButton(autoTouchBtn)
    end)

    visualsBtn.MouseButton1Click:Connect(function()
        CONFIG.showPlayerSphere = not CONFIG.showPlayerSphere
        CONFIG.showBallAura = not CONFIG.showBallAura
        visualsBtn.Text = (CONFIG.showPlayerSphere and CONFIG.showBallAura) and "VISUALS: ON" or "VISUALS: OFF"
        visualsBtn.BackgroundColor3 = (CONFIG.showPlayerSphere and CONFIG.showBallAura) and CONFIG.colors.secondary or Color3.fromRGB(100, 100, 100)
        animateButton(visualsBtn)
        updatePlayerSphere()
        updateBallAuras()
    end)

    hideBtn.MouseButton1Click:Connect(function()
        animateButton(hideBtn)
        TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
            Position = UDim2.new(0, -320, 0.5, -200)
        }):Play()
        task.delay(0.3, function()
            mainFrame.Visible = false
            mainFrame.Position = UDim2.new(0, 20, 0.5, -200)
        end)
        notify("Pressione INSERT ou use o botão mobile para reabrir", 2)
    end)

    -- Atualizar displays iniciais
    updatePlayerDisplay()
    updateBallDisplay()
end

-- BOTÃO FLUTUANTE MOBILE PREMIUM
local function buildMobileButton()
    local mobileGui = Instance.new("ScreenGui")
    mobileGui.Name = "CaduMobilePremium"
    mobileGui.ResetOnSpawn = false
    mobileGui.Parent = player:WaitForChild("PlayerGui")

    local floatBtn = Instance.new("TextButton")
    floatBtn.Size = UDim2.new(0, 70, 0, 70)
    floatBtn.Position = UDim2.new(1, -90, 1, -120)
    floatBtn.BackgroundColor3 = CONFIG.colors.dark
    floatBtn.Text = "⚡"
    floatBtn.TextSize = 35
    floatBtn.Font = Enum.Font.GothamBlack
    floatBtn.TextColor3 = CONFIG.colors.primary
    floatBtn.Parent = mobileGui
    floatBtn.Active = true
    floatBtn.Draggable = true
    floatBtn.AutoButtonColor = false
    
    local corner = Instance.new("UICorner", floatBtn)
    corner.CornerRadius = UDim.new(1, 0)
    
    local stroke = Instance.new("UIStroke", floatBtn)
    stroke.Color = CONFIG.colors.primary
    stroke.Thickness = 3
    
    -- Glow animado
    local glow = Instance.new("ImageLabel")
    glow.Size = UDim2.new(1.5, 0, 1.5, 0)
    glow.Position = UDim2.new(-0.25, 0, -0.25, 0)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://243660364"
    glow.ImageColor3 = CONFIG.colors.primary
    glow.ImageTransparency = 0.8
    glow.Parent = floatBtn
    
    -- Animação de pulso
    spawn(function()
        while floatBtn and floatBtn.Parent do
            TweenService:Create(glow, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                ImageTransparency = 0.5,
                Size = UDim2.new(1.8, 0, 1.8, 0)
            }):Play()
            task.wait(1)
            TweenService:Create(glow, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                ImageTransparency = 0.8,
                Size = UDim2.new(1.5, 0, 1.5, 0)
            }):Play()
            task.wait(1)
        end
    end)
    
    -- Efeito hover
    floatBtn.MouseEnter:Connect(function()
        TweenService:Create(floatBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = CONFIG.colors.primary,
            TextColor3 = CONFIG.colors.dark
        }):Play()
    end)
    
    floatBtn.MouseLeave:Connect(function()
        TweenService:Create(floatBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = CONFIG.colors.dark,
            TextColor3 = CONFIG.colors.primary
        }):Play()
    end)

    floatBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = true
        TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
            Position = UDim2.new(0, 20, 0.5, -200)
        }):Play()
    end)
end

-- TECLA INSERT
if not isMobile then
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
            if mainFrame then
                if mainFrame.Visible then
                    TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
                        Position = UDim2.new(0, -320, 0.5, -200)
                    }):Play()
                    task.delay(0.3, function()
                        mainFrame.Visible = false
                        mainFrame.Position = UDim2.new(0, 20, 0.5, -200)
                    end)
                else
                    mainFrame.Visible = true
                    TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
                        Position = UDim2.new(0, 20, 0.5, -200)
                    }):Play()
                end
            end
        end
    end)
end

-- LOOPS
RunService.RenderStepped:Connect(function()
    updatePlayerSphere()
    updateBallAuras()
    
    if CONFIG.autoTouch then
        processTouch()
    end
end)

task.spawn(function()
    while true do
        refreshBalls()
        task.wait(CONFIG.scanCooldown)
    end
end)

-- LIMPEZA
player.CharacterRemoving:Connect(function()
    if playerSphere then
        playerSphere:Destroy()
        playerSphere = nil
    end
    for ball, _ in pairs(ballAuras) do
        removeBallAura(ball)
    end
end)

player.CharacterAdded:Connect(function(newChar)
    task.wait(0.5)
    updatePlayerSphere()
end)

-- INIT
createBackgroundParticles()
buildMainGUI()
if isMobile then
    buildMobileButton()
end

if not player.Character then
    player.CharacterAdded:Wait()
end
task.wait(0.5)

updatePlayerSphere()
refreshBalls()
notify("✨ CADU HUB V3 PREMIUM ✨", 3)
notify("🎨 Estilo 200% ativado!", 2)
print("Cadu Hub V3 Premium | Player:", CONFIG.playerReach, "| Ball:", CONFIG.ballReach)
