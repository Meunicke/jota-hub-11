-- SERVICES
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- CONFIG (baseado no Arthur V2)
local CONFIG = {
    playerReach = 10,
    ballReach = 15,
    showPlayerSphere = true,
    showBallAura = true,
    autoTouch = true,
    scanCooldown = 0.1,
    -- Nomes das bolas do Arthur V2 + extras
    ballNames = { "MPS", "TRS", "TCS", "TPS", "PRS", "ESA", "MRS", "SSS", "AIFA", "RBZ", "SoccerBall", "Football", "Ball" },
    
    colors = {
        primary = Color3.fromRGB(0, 255, 255),
        secondary = Color3.fromRGB(255, 0, 255),
        accent = Color3.fromRGB(255, 200, 0),
        dark = Color3.fromRGB(10, 10, 15),
        darker = Color3.fromRGB(5, 5, 8)
    }
}

-- VARIÁVEIS
local balls = {}
local ballAuras = {}
local lastRefresh = 0
local playerSphere = nil
local gui, mainFrame
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local HRP = nil

-- BALL SET
local BALL_NAME_SET = {}
for _, n in ipairs(CONFIG.ballNames) do
    BALL_NAME_SET[n] = true
end

-- NOTIFY
local function notify(txt, t)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "✨ Cadu Hub V3",
            Text = txt,
            Duration = t or 3
        })
    end)
end

-- UPDATE HRP (igual Arthur V2)
task.spawn(function()
    while true do
        task.wait(0.5)
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            HRP = player.Character.HumanoidRootPart
        end
    end
end)

-- REFRESH BALLS (igual Arthur V2)
local function refreshBalls()
    table.clear(balls)
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and BALL_NAME_SET[v.Name] then
            table.insert(balls, v)
        end
    end
end

-- CRIAR AURA NA BOLA
local function createBallAura(ball)
    if ballAuras[ball] then return end
    
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
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "BallHighlight"
    highlight.Adornee = ball
    highlight.FillColor = CONFIG.colors.secondary
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.8
    highlight.OutlineTransparency = 0.2
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = ball
    
    local connection = RunService.RenderStepped:Connect(function()
        if ball and ball.Parent and reachSphere and reachSphere.Parent then
            reachSphere.CFrame = ball.CFrame
        else
            if reachSphere then reachSphere:Destroy() end
        end
    end)
    
    ballAuras[ball] = {
        reachSphere = reachSphere,
        highlight = highlight,
        connection = connection
    }
end

-- REMOVER AURA
local function removeBallAura(ball)
    if ballAuras[ball] then
        if ballAuras[ball].connection then
            ballAuras[ball].connection:Disconnect()
        end
        if ballAuras[ball].reachSphere then
            ballAuras[ball].reachSphere:Destroy()
        end
        if ballAuras[ball].highlight then
            ballAuras[ball].highlight:Destroy()
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

-- ATUALIZAR ESFERA DO JOGADOR
local function updatePlayerSphere()
    if not CONFIG.showPlayerSphere then
        if playerSphere then
            playerSphere:Destroy()
            playerSphere = nil
        end
        return
    end
    
    if not HRP then return end
    
    if not playerSphere then
        playerSphere = Instance.new("Part")
        playerSphere.Name = "PlayerReachSphere"
        playerSphere.Shape = Enum.PartType.Ball
        playerSphere.Transparency = 0.75
        playerSphere.Anchored = true
        playerSphere.CanCollide = false
        playerSphere.CastShadow = false
        playerSphere.Material = Enum.Material.ForceField
        playerSphere.Color = CONFIG.colors.primary
        playerSphere.Parent = Workspace
    end
    
    playerSphere.Size = Vector3.new(CONFIG.playerReach * 2, CONFIG.playerReach * 2, CONFIG.playerReach * 2)
    playerSphere.Position = HRP.Position
    playerSphere.Transparency = CONFIG.showPlayerSphere and 0.75 or 1
end

-- CORREÇÃO PRINCIPAL: DO REACH (igual Arthur V2 mas melhorado)
local function doReach()
    if not CONFIG.autoTouch or not player.Character then return end
    
    -- Pega a perna direita (igual Arthur V2)
    local rightLeg = player.Character:FindFirstChild("Right Leg") or 
                     player.Character:FindFirstChild("RightLowerLeg") or
                     player.Character:FindFirstChild("RightFoot")
    
    if not rightLeg then return end
    
    -- Atualiza lista de bolas
    refreshBalls()
    
    for _, ball in ipairs(balls) do
        if not ball or not ball.Parent then continue end
        
        -- Distância da bola até o jogador
        local distance = (ball.Position - HRP.Position).Magnitude
        
        -- Reach efetivo: playerReach + ballReach
        local effectiveReach = CONFIG.playerReach + CONFIG.ballReach
        
        if distance < effectiveReach then
            -- MÉTODO ARTHUR V2: Pega TouchInterest dos descendentes da perna
            local touched = false
            
            for _, descendant in ipairs(rightLeg:GetDescendants()) do
                if descendant.Name == "TouchInterest" then
                    pcall(function()
                        firetouchinterest(ball, descendant.Parent, 0)
                        firetouchinterest(ball, descendant.Parent, 1)
                    end)
                    touched = true
                end
            end
            
            -- Se não achou TouchInterest, tenta na própria perna
            if not touched then
                pcall(function()
                    firetouchinterest(ball, rightLeg, 0)
                    firetouchinterest(ball, rightLeg, 1)
                end)
            end
            
            -- Efeito visual ao tocar
            if distance < 5 then
                local effect = Instance.new("Part")
                effect.Size = Vector3.new(0.5, 0.5, 0.5)
                effect.Position = ball.Position
                effect.Anchored = true
                effect.CanCollide = false
                effect.Material = Enum.Material.Neon
                effect.Color = CONFIG.colors.accent
                effect.Parent = Workspace
                
                TweenService:Create(effect, TweenInfo.new(0.2), {
                    Size = Vector3.new(2, 2, 2),
                    Transparency = 1
                }):Play()
                
                game:GetService("Debris"):AddItem(effect, 0.2)
            end
        end
    end
end

-- GUI ULTRA ESTILIZADA
function buildMainGUI()
    if gui then return end

    gui = Instance.new("ScreenGui")
    gui.Name = "CaduHubV3"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")

    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 320, 0, 450)
    mainFrame.Position = UDim2.new(0, 20, 0.5, -225)
    mainFrame.BackgroundColor3 = CONFIG.colors.dark
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = gui

    local corner = Instance.new("UICorner", mainFrame)
    corner.CornerRadius = UDim.new(0, 16)

    local stroke = Instance.new("UIStroke", mainFrame)
    stroke.Color = CONFIG.colors.primary
    stroke.Thickness = 2
    stroke.Transparency = 0.3

    -- Gradiente
    local gradient = Instance.new("UIGradient", mainFrame)
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, CONFIG.colors.dark),
        ColorSequenceKeypoint.new(1, CONFIG.colors.darker)
    })
    gradient.Rotation = 45

    -- Título Premium
    local titleBg = Instance.new("Frame")
    titleBg.Size = UDim2.new(1, -20, 0, 50)
    titleBg.Position = UDim2.new(0, 10, 0, 10)
    titleBg.BackgroundColor3 = CONFIG.colors.primary
    titleBg.BackgroundTransparency = 0.9
    titleBg.Parent = mainFrame
    Instance.new("UICorner", titleBg).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = "⚡ CADU HUB V3 ⚡"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 22
    title.Parent = titleBg

    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, -20, 0, 20)
    subtitle.Position = UDim2.new(0, 10, 0, 65)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "ARTHUR V2 EDITION"
    subtitle.TextColor3 = CONFIG.colors.accent
    subtitle.Font = Enum.Font.GothamBold
    subtitle.TextSize = 12
    subtitle.Parent = mainFrame

    -- Container de controles
    local controls = Instance.new("Frame")
    controls.Size = UDim2.new(1, -20, 0, 320)
    controls.Position = UDim2.new(0, 10, 0, 95)
    controls.BackgroundTransparency = 1
    controls.Parent = mainFrame

    -- SEÇÃO PLAYER REACH
    local playerSection = Instance.new("Frame")
    playerSection.Size = UDim2.new(1, 0, 0, 90)
    playerSection.Position = UDim2.new(0, 0, 0, 0)
    playerSection.BackgroundColor3 = CONFIG.colors.darker
    playerSection.BackgroundTransparency = 0.5
    playerSection.Parent = controls
    Instance.new("UICorner", playerSection).CornerRadius = UDim.new(0, 12)

    local playerStroke = Instance.new("UIStroke", playerSection)
    playerStroke.Color = CONFIG.colors.primary
    playerStroke.Thickness = 1

    local playerIcon = Instance.new("TextLabel")
    playerIcon.Size = UDim2.new(0, 30, 0, 30)
    playerIcon.Position = UDim2.new(0, 10, 0, 5)
    playerIcon.BackgroundTransparency = 1
    playerIcon.Text = "👤"
    playerIcon.TextSize = 20
    playerIcon.Parent = playerSection

    local playerTitle = Instance.new("TextLabel")
    playerTitle.Size = UDim2.new(1, -50, 0, 25)
    playerTitle.Position = UDim2.new(0, 45, 0, 5)
    playerTitle.BackgroundTransparency = 1
    playerTitle.Text = "PLAYER REACH"
    playerTitle.TextColor3 = CONFIG.colors.primary
    playerTitle.Font = Enum.Font.GothamBold
    playerTitle.TextSize = 14
    playerTitle.TextXAlignment = Enum.TextXAlignment.Left
    playerTitle.Parent = playerSection

    local playerValue = Instance.new("TextLabel")
    playerValue.Size = UDim2.new(1, -20, 0, 20)
    playerValue.Position = UDim2.new(0, 10, 0, 30)
    playerValue.BackgroundTransparency = 1
    playerValue.Text = CONFIG.playerReach .. " studs"
    playerValue.TextColor3 = Color3.new(1, 1, 1)
    playerValue.Font = Enum.Font.GothamBold
    playerValue.TextSize = 18
    playerValue.Parent = playerSection

    -- Botões Player
    local minusPlayer = Instance.new("TextButton")
    minusPlayer.Size = UDim2.new(0, 70, 0, 30)
    minusPlayer.Position = UDim2.new(0, 10, 0, 55)
    minusPlayer.Text = "−"
    minusPlayer.Font = Enum.Font.GothamBlack
    minusPlayer.TextSize = 20
    minusPlayer.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    minusPlayer.TextColor3 = Color3.new(1, 1, 1)
    minusPlayer.Parent = playerSection
    Instance.new("UICorner", minusPlayer).CornerRadius = UDim.new(0, 8)

    local plusPlayer = Instance.new("TextButton")
    plusPlayer.Size = UDim2.new(0, 70, 0, 30)
    plusPlayer.Position = UDim2.new(0, 90, 0, 55)
    plusPlayer.Text = "+"
    plusPlayer.Font = Enum.Font.GothamBlack
    plusPlayer.TextSize = 20
    plusPlayer.BackgroundColor3 = CONFIG.colors.primary
    plusPlayer.TextColor3 = Color3.new(0, 0, 0)
    plusPlayer.Parent = playerSection
    Instance.new("UICorner", plusPlayer).CornerRadius = UDim.new(0, 8)

    local resetPlayer = Instance.new("TextButton")
    resetPlayer.Size = UDim2.new(0, 80, 0, 30)
    resetPlayer.Position = UDim2.new(0, 170, 0, 55)
    resetPlayer.Text = "RESET"
    resetPlayer.Font = Enum.Font.GothamBold
    resetPlayer.TextSize = 12
    resetPlayer.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    resetPlayer.TextColor3 = Color3.new(1, 1, 1)
    resetPlayer.Parent = playerSection
    Instance.new("UICorner", resetPlayer).CornerRadius = UDim.new(0, 8)

    -- SEÇÃO BALL REACH
    local ballSection = Instance.new("Frame")
    ballSection.Size = UDim2.new(1, 0, 0, 90)
    ballSection.Position = UDim2.new(0, 0, 0, 100)
    ballSection.BackgroundColor3 = CONFIG.colors.darker
    ballSection.BackgroundTransparency = 0.5
    ballSection.Parent = controls
    Instance.new("UICorner", ballSection).CornerRadius = UDim.new(0, 12)

    local ballStroke = Instance.new("UIStroke", ballSection)
    ballStroke.Color = CONFIG.colors.secondary
    ballStroke.Thickness = 1

    local ballIcon = Instance.new("TextLabel")
    ballIcon.Size = UDim2.new(0, 30, 0, 30)
    ballIcon.Position = UDim2.new(0, 10, 0, 5)
    ballIcon.BackgroundTransparency = 1
    ballIcon.Text = "⚽"
    ballIcon.TextSize = 20
    ballIcon.Parent = ballSection

    local ballTitle = Instance.new("TextLabel")
    ballTitle.Size = UDim2.new(1, -50, 0, 25)
    ballTitle.Position = UDim2.new(0, 45, 0, 5)
    ballTitle.BackgroundTransparency = 1
    ballTitle.Text = "BALL REACH"
    ballTitle.TextColor3 = CONFIG.colors.secondary
    ballTitle.Font = Enum.Font.GothamBold
    ballTitle.TextSize = 14
    ballTitle.TextXAlignment = Enum.TextXAlignment.Left
    ballTitle.Parent = ballSection

    local ballValue = Instance.new("TextLabel")
    ballValue.Size = UDim2.new(1, -20, 0, 20)
    ballValue.Position = UDim2.new(0, 10, 0, 30)
    ballValue.BackgroundTransparency = 1
    ballValue.Text = CONFIG.ballReach .. " studs"
    ballValue.TextColor3 = Color3.new(1, 1, 1)
    ballValue.Font = Enum.Font.GothamBold
    ballValue.TextSize = 18
    ballValue.Parent = ballSection

    local minusBall = Instance.new("TextButton")
    minusBall.Size = UDim2.new(0, 70, 0, 30)
    minusBall.Position = UDim2.new(0, 10, 0, 55)
    minusBall.Text = "−"
    minusBall.Font = Enum.Font.GothamBlack
    minusBall.TextSize = 20
    minusBall.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    minusBall.TextColor3 = Color3.new(1, 1, 1)
    minusBall.Parent = ballSection
    Instance.new("UICorner", minusBall).CornerRadius = UDim.new(0, 8)

    local plusBall = Instance.new("TextButton")
    plusBall.Size = UDim2.new(0, 70, 0, 30)
    plusBall.Position = UDim2.new(0, 90, 0, 55)
    plusBall.Text = "+"
    plusBall.Font = Enum.Font.GothamBlack
    plusBall.TextSize = 20
    plusBall.BackgroundColor3 = CONFIG.colors.secondary
    plusBall.TextColor3 = Color3.new(0, 0, 0)
    plusBall.Parent = ballSection
    Instance.new("UICorner", plusBall).CornerRadius = UDim.new(0, 8)

    local resetBall = Instance.new("TextButton")
    resetBall.Size = UDim2.new(0, 80, 0, 30)
    resetBall.Position = UDim2.new(0, 170, 0, 55)
    resetBall.Text = "RESET"
    resetBall.Font = Enum.Font.GothamBold
    resetBall.TextSize = 12
    resetBall.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    resetBall.TextColor3 = Color3.new(1, 1, 1)
    resetBall.Parent = ballSection
    Instance.new("UICorner", resetBall).CornerRadius = UDim.new(0, 8)

    -- SEÇÃO TOGGLES
    local toggleSection = Instance.new("Frame")
    toggleSection.Size = UDim2.new(1, 0, 0, 110)
    toggleSection.Position = UDim2.new(0, 0, 0, 200)
    toggleSection.BackgroundColor3 = CONFIG.colors.darker
    toggleSection.BackgroundTransparency = 0.5
    toggleSection.Parent = controls
    Instance.new("UICorner", toggleSection).CornerRadius = UDim.new(0, 12)

    local toggleStroke = Instance.new("UIStroke", toggleSection)
    toggleStroke.Color = CONFIG.colors.accent
    toggleStroke.Thickness = 1

    local toggleIcon = Instance.new("TextLabel")
    toggleIcon.Size = UDim2.new(0, 30, 0, 30)
    toggleIcon.Position = UDim2.new(0, 10, 0, 5)
    toggleIcon.BackgroundTransparency = 1
    toggleIcon.Text = "🔧"
    toggleIcon.TextSize = 20
    toggleIcon.Parent = toggleSection

    local toggleTitle = Instance.new("TextLabel")
    toggleTitle.Size = UDim2.new(1, -50, 0, 25)
    toggleTitle.Position = UDim2.new(0, 45, 0, 5)
    toggleTitle.BackgroundTransparency = 1
    toggleTitle.Text = "CONTROLES"
    toggleTitle.TextColor3 = CONFIG.colors.accent
    toggleTitle.Font = Enum.Font.GothamBold
    toggleTitle.TextSize = 14
    toggleTitle.TextXAlignment = Enum.TextXAlignment.Left
    toggleTitle.Parent = toggleSection

    local autoTouchBtn = Instance.new("TextButton")
    autoTouchBtn.Size = UDim2.new(0, 140, 0, 30)
    autoTouchBtn.Position = UDim2.new(0, 10, 0, 40)
    autoTouchBtn.Text = "AUTO TOUCH: ON"
    autoTouchBtn.Font = Enum.Font.GothamBold
    autoTouchBtn.TextSize = 12
    autoTouchBtn.BackgroundColor3 = CONFIG.colors.primary
    autoTouchBtn.TextColor3 = Color3.new(0, 0, 0)
    autoTouchBtn.Parent = toggleSection
    Instance.new("UICorner", autoTouchBtn).CornerRadius = UDim.new(0, 8)

    local visualsBtn = Instance.new("TextButton")
    visualsBtn.Size = UDim2.new(0, 140, 0, 30)
    visualsBtn.Position = UDim2.new(0, 10, 0, 75)
    visualsBtn.Text = "VISUALS: ON"
    visualsBtn.Font = Enum.Font.GothamBold
    visualsBtn.TextSize = 12
    visualsBtn.BackgroundColor3 = CONFIG.colors.secondary
    visualsBtn.TextColor3 = Color3.new(0, 0, 0)
    visualsBtn.Parent = toggleSection
    Instance.new("UICorner", visualsBtn).CornerRadius = UDim.new(0, 8)

    local hideBtn = Instance.new("TextButton")
    hideBtn.Size = UDim2.new(0, 130, 0, 65)
    hideBtn.Position = UDim2.new(1, -140, 0, 40)
    hideBtn.Text = isMobile and "❌ FECHAR" or "❌ ESCONDER\n[INSERT]"
    hideBtn.Font = Enum.Font.GothamBold
    hideBtn.TextSize = 11
    hideBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    hideBtn.TextColor3 = Color3.new(1, 1, 1)
    hideBtn.Parent = toggleSection
    Instance.new("UICorner", hideBtn).CornerRadius = UDim.new(0, 10)

    -- ANIMAÇÃO DE ENTRADA
    mainFrame.Position = UDim2.new(0, -340, 0.5, -225)
    TweenService:Create(mainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back), {
        Position = UDim2.new(0, 20, 0.5, -225)
    }):Play()

    -- FUNÇÕES
local function animateButton(btn)
    local original = btn.BackgroundColor3
    TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.new(1, 1, 1)}):Play()
    task.wait(0.1)
    TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = original}):Play()
end

minusPlayer.MouseButton1Click:Connect(function()
    animateButton(minusPlayer)
    CONFIG.playerReach = math.max(1, CONFIG.playerReach - 1)
    playerValue.Text = CONFIG.playerReach .. " studs"
end)

plusPlayer.MouseButton1Click:Connect(function()
    animateButton(plusPlayer)
    CONFIG.playerReach = math.min(150, CONFIG.playerReach + 1)
    playerValue.Text = CONFIG.playerReach .. " studs"
end)

resetPlayer.MouseButton1Click:Connect(function()
    animateButton(resetPlayer)
    CONFIG.playerReach = 10
    playerValue.Text = CONFIG.playerReach .. " studs"
end)

minusBall.MouseButton1Click:Connect(function()
    animateButton(minusBall)
    CONFIG.ballReach = math.max(1, CONFIG.ballReach - 1)
    ballValue.Text = CONFIG.ballReach .. " studs"
    updateBallAuras()
end)

plusBall.MouseButton1Click:Connect(function()
    animateButton(plusBall)
    CONFIG.ballReach = math.min(150, CONFIG.ballReach + 1)
    ballValue.Text = CONFIG.ballReach .. " studs"
    updateBallAuras()
end)

resetBall.MouseButton1Click:Connect(function()
    animateButton(resetBall)
    CONFIG.ballReach = 15
    ballValue.Text = CONFIG.ballReach .. " studs"
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
end)

hideBtn.MouseButton1Click:Connect(function()
    animateButton(hideBtn)
    TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
        Position = UDim2.new(0, -340, 0.5, -225)
    }):Play()
    task.delay(0.4, function()
        mainFrame.Visible = false
        mainFrame.Position = UDim2.new(0, 20, 0.5, -225)
    end)
end)

-- BOTÃO MOBILE PREMIUM
local function buildMobileButton()
    local mobileGui = Instance.new("ScreenGui")
    mobileGui.Name = "CaduMobileV3"
    mobileGui.ResetOnSpawn = false
    mobileGui.Parent = player:WaitForChild("PlayerGui")

    local floatBtn = Instance.new("TextButton")
    floatBtn.Size = UDim2.new(0, 75, 0, 75)
    floatBtn.Position = UDim2.new(1, -95, 1, -130)
    floatBtn.BackgroundColor3 = CONFIG.colors.dark
    floatBtn.Text = "⚡"
    floatBtn.TextSize = 40
    floatBtn.Font = Enum.Font.GothamBlack
    floatBtn.TextColor3 = CONFIG.colors.primary
    floatBtn.Parent = mobileGui
    floatBtn.Active = true
    floatBtn.Draggable = true
    floatBtn.AutoButtonColor = false

    Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(1, 0)

    local stroke = Instance.new("UIStroke", floatBtn)
    stroke.Color = CONFIG.colors.primary
    stroke.Thickness = 3

    local glow = Instance.new("ImageLabel")
    glow.Size = UDim2.new(1.5, 0, 1.5, 0)
    glow.Position = UDim2.new(-0.25, 0, -0.25, 0)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://243660364"
    glow.ImageColor3 = CONFIG.colors.primary
    glow.ImageTransparency = 0.8
    glow.Parent = floatBtn

    spawn(function()
        while floatBtn and floatBtn.Parent do
            TweenService:Create(glow, TweenInfo.new(1), {
                ImageTransparency = 0.5,
                Size = UDim2.new(1.8, 0, 1.8, 0)
            }):Play()
            task.wait(1)
            TweenService:Create(glow, TweenInfo.new(1), {
                ImageTransparency = 0.8,
                Size = UDim2.new(1.5, 0, 1.5, 0)
            }):Play()
            task.wait(1)
        end
    end)

    floatBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = true
        TweenService:Create(mainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back), {
            Position = UDim2.new(0, 20, 0.5, -225)
        }):Play()
    end)
end

-- TECLA INSERT
if not isMobile then
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
            if mainFrame then
                if mainFrame.Visible then
                    TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
                        Position = UDim2.new(0, -340, 0.5, -225)
                    }):Play()
                    task.delay(0.4, function()
                        mainFrame.Visible = false
                        mainFrame.Position = UDim2.new(0, 20, 0.5, -225)
                    end)
                else
                    mainFrame.Visible = true
                    TweenService:Create(mainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back), {
                        Position = UDim2.new(0, 20, 0.5, -225)
                    }):Play()
                end
            end
        end
    end)
end

-- LOOPS (igual Arthur V2)
RunService.RenderStepped:Connect(function()
    updatePlayerSphere()
    updateBallAuras()
    doReach()
end)

-- INIT
buildMainGUI()
if isMobile then
    buildMobileButton()
end

print("Cadu Hub V3 | Arthur V2 Edition | Player:", CONFIG.playerReach, "| Ball:", CONFIG.ballReach)
