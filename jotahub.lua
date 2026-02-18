-- SERVICES
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- CONFIG
local CONFIG = {
    reach = 10,
    ballReach = 15,
    magnetStrength = 0,
    showReachSpheres = true,
    showBallAura = true,
    autoSecondTouch = true,
    scanCooldown = 1.5,
    ballNames = { "TPS", "ESA", "MRS", "PRS", "MPS", "SSS", "AIFA", "RBZ" },
    
    -- MODO CB (NOVO)
    cbMode = {
        enabled = false,           -- Começa desligado
        reach = 20,               -- Reach maior para interceptar
        reactionTime = 0.1,       -- Tempo de reação mais rápido
        autoBlock = true,         -- Bloqueio automático de chutes
        prediction = true,        -- Prever trajetória da bola
        tackleRange = 25,         -- Alcance do carrinho melhorado
        color = Color3.fromRGB(255, 50, 50) -- Vermelho para CB
    },
    
    mode = "central", -- "central" ou "bodyparts"
    
    centralSphere = {
        enabled = true,
        color = Color3.fromRGB(0, 255, 136),
        reach = 10
    },
    
    bodyParts = {
        head = { name = "Head", reach = 8, color = Color3.fromRGB(255, 50, 50), enabled = true },
        torso = { name = "Torso", reach = 10, color = Color3.fromRGB(0, 255, 136), enabled = true },
        arm = { name = "Arm", reach = 12, color = Color3.fromRGB(0, 150, 255), enabled = true },
        leg = { name = "Leg", reach = 9, color = Color3.fromRGB(255, 200, 0), enabled = true }
    }
}

-- VARIÁVEIS
local balls = {}
local ballAuras = {}
local lastRefresh = 0
local reachSpheres = {}
local centralSphere = nil
local gui, mainFrame, modeLabel, cbLabel
local spheresVisible = true
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local cbActive = false

-- BALL SET
local BALL_NAME_SET = {}
for _, n in ipairs(CONFIG.ballNames) do
    BALL_NAME_SET[n] = true
end

-- NOTIFY
local function notify(txt, t)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Cadu Hub",
            Text = txt,
            Duration = t or 2
        })
    end)
end

-- REFRESH BALLS
local function refreshBalls(force)
    if not force and tick() - lastRefresh < CONFIG.scanCooldown then return end
    lastRefresh = tick()
    table.clear(balls)

    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and BALL_NAME_SET[v.Name] then
            balls[#balls+1] = v
        end
    end
end

-- CRIAR AURA NA BOLA
local function createBallAura(ball)
    if ballAuras[ball] then return end
    
    local auraAttachment = Instance.new("Attachment")
    auraAttachment.Name = "CaduAuraAttachment"
    auraAttachment.Position = Vector3.new(0, 0, 0)
    auraAttachment.Parent = ball
    
    local particle1 = Instance.new("ParticleEmitter")
    particle1.Name = "AuraParticles"
    particle1.Texture = "rbxassetid://258128463"
    particle1.Color = ColorSequence.new(Color3.fromRGB(255, 0, 255), Color3.fromRGB(150, 0, 255))
    particle1.Size = NumberSequence.new(2, 4)
    particle1.Transparency = NumberSequence.new(0.3, 1)
    particle1.Lifetime = NumberRange.new(0.5, 1)
    particle1.Rate = 20
    particle1.Speed = NumberRange.new(2, 5)
    particle1.SpreadAngle = Vector2.new(180, 180)
    particle1.Rotation = NumberRange.new(0, 360)
    particle1.RotSpeed = NumberRange.new(-50, 50)
    particle1.Parent = auraAttachment
    
    local particle2 = Instance.new("ParticleEmitter")
    particle2.Name = "TrailParticles"
    particle2.Texture = "rbxassetid://243660364"
    particle2.Color = ColorSequence.new(Color3.fromRGB(200, 0, 255))
    particle2.Size = NumberSequence.new(1, 0)
    particle2.Transparency = NumberSequence.new(0.5, 1)
    particle2.Lifetime = NumberRange.new(0.3, 0.6)
    particle2.Rate = 10
    particle2.Speed = NumberRange.new(1, 3)
    particle2.Parent = auraAttachment
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "CaduAuraHighlight"
    highlight.Adornee = ball
    highlight.FillColor = Color3.fromRGB(255, 0, 255)
    highlight.OutlineColor = Color3.fromRGB(200, 0, 255)
    highlight.FillTransparency = 0.8
    highlight.OutlineTransparency = 0.3
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = ball
    
    local reachSphere = Instance.new("Part")
    reachSphere.Name = "BallReachSphere"
    reachSphere.Shape = Enum.PartType.Ball
    reachSphere.Anchored = true
    reachSphere.CanCollide = false
    reachSphere.Transparency = 0.95
    reachSphere.Material = Enum.Material.ForceField
    reachSphere.Color = Color3.fromRGB(255, 100, 255)
    reachSphere.Size = Vector3.new(CONFIG.ballReach * 2, CONFIG.ballReach * 2, CONFIG.ballReach * 2)
    reachSphere.Parent = Workspace
    
    local connection = RunService.RenderStepped:Connect(function()
        if ball and ball.Parent and reachSphere and reachSphere.Parent then
            reachSphere.Position = ball.Position
        else
            if reachSphere then reachSphere:Destroy() end
        end
    end)
    
    ballAuras[ball] = {
        attachment = auraAttachment,
        particles = {particle1, particle2},
        highlight = highlight,
        reachSphere = reachSphere,
        connection = connection
    }
end

-- REMOVER AURA DA BOLA
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
        if ballAuras[ball].attachment then
            ballAuras[ball].attachment:Destroy()
        end
        ballAuras[ball] = nil
    end
end

-- ATUALIZAR AURAS DAS BOLAS
local function updateBallAuras()
    for ball, data in pairs(ballAuras) do
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

-- LIMPAR TODAS AS ESFERAS
local function clearAllSpheres()
    if centralSphere then
        centralSphere:Destroy()
        centralSphere = nil
    end
    for _, sphere in pairs(reachSpheres) do
        if sphere then sphere:Destroy() end
    end
    table.clear(reachSpheres)
end

-- TOGGLE VISIBILIDADE DAS ESFERAS
local function toggleSpheresVisibility()
    spheresVisible = not spheresVisible
    CONFIG.showReachSpheres = spheresVisible
    
    if spheresVisible then
        updateReachSpheres()
        notify("🔵 Esferas VISÍVEIS", 1.5)
    else
        clearAllSpheres()
        notify("⚫ Esferas ESCONDIDAS", 1.5)
    end
    
    return spheresVisible
end

-- TOGGLE AURA BOLAS
local function toggleBallAura()
    CONFIG.showBallAura = not CONFIG.showBallAura
    
    if not CONFIG.showBallAura then
        for ball, _ in pairs(ballAuras) do
            removeBallAura(ball)
        end
        notify("✨ Aura das Bolas DESLIGADA", 1.5)
    else
        updateBallAuras()
        notify("✨ Aura das Bolas LIGADA", 1.5)
    end
    
    return CONFIG.showBallAura
end

-- NOVO: TOGGLE MODO CB
local function toggleCBMode()
    CONFIG.cbMode.enabled = not CONFIG.cbMode.enabled
    cbActive = CONFIG.cbMode.enabled
    
    if cbActive then
        notify("🛡️ MODO CB ATIVADO!", 3)
        notify("Reach: " .. CONFIG.cbMode.reach .. " | AutoBlock: ON", 2)
        
        -- Efeito visual no personagem
        local char = player.Character
        if char then
            for _, part in ipairs(char:GetChildren()) do
                if part:IsA("BasePart") then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "CBModeHighlight"
                    highlight.Adornee = part
                    highlight.FillColor = CONFIG.cbMode.color
                    highlight.OutlineColor = Color3.new(1, 1, 1)
                    highlight.FillTransparency = 0.9
                    highlight.OutlineTransparency = 0.1
                    highlight.Parent = part
                    
                    -- Remove após 2 segundos
                    task.delay(2, function()
                        if highlight then highlight:Destroy() end
                    end)
                end
            end
        end
    else
        notify("🛡️ MODO CB DESATIVADO", 2)
        notify("Voltando ao normal...", 1)
    end
    
    return cbActive
end

-- MAPA DE PARTES R6
local function getBodyPartType(partName)
    if partName == "Head" then
        return "head"
    elseif partName == "Torso" then
        return "torso"
    elseif partName:match("Arm") or partName:match("Hand") then
        return "arm"
    elseif partName:match("Leg") or partName:match("Foot") then
        return "leg"
    end
    return nil
end

-- OBTER PARTES VÁLIDAS BASEADO NO MODO
local function getValidParts(char)
    local parts = {}
    
    -- NOVO: Se modo CB ativo, usa configurações de CB
    local currentReach = cbActive and CONFIG.cbMode.reach or CONFIG.reach
    
    if CONFIG.mode == "central" then
        for _, v in ipairs(char:GetChildren()) do
            if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                table.insert(parts, {
                    part = v,
                    reach = currentReach,
                    isCentral = true
                })
            end
        end
    else
        for _, v in ipairs(char:GetChildren()) do
            if v:IsA("BasePart") then
                local partType = getBodyPartType(v.Name)
                if partType and CONFIG.bodyParts[partType].enabled then
                    -- NOVO: No modo CB, todas as partes têm reach aumentado
                    local partReach = cbActive and CONFIG.cbMode.reach or CONFIG.bodyParts[partType].reach
                    table.insert(parts, {
                        part = v,
                        type = partType,
                        reach = partReach,
                        isCentral = false
                    })
                end
            end
        end
    end
    
    return parts
end

-- ATUALIZAR ESFERAS VISUAIS
function updateReachSpheres()
    if not spheresVisible then return end
    clearAllSpheres()
    
    local char = player.Character
    if not char then return end

    -- NOVO: Cor diferente no modo CB
    local sphereColor = cbActive and CONFIG.cbMode.color or CONFIG.centralSphere.color
    local sphereReach = cbActive and CONFIG.cbMode.reach or CONFIG.centralSphere.reach

    if CONFIG.mode == "central" then
        centralSphere = Instance.new("Part")
        centralSphere.Name = "CaduCentralSphere"
        centralSphere.Shape = Enum.PartType.Ball
        centralSphere.Anchored = true
        centralSphere.CanCollide = false
        centralSphere.Transparency = 0.8
        centralSphere.Material = Enum.Material.ForceField
        centralSphere.Color = sphereColor
        centralSphere.Size = Vector3.new(sphereReach * 2, sphereReach * 2, sphereReach * 2)
        centralSphere.Parent = Workspace
        
    else
        for partType, config in pairs(CONFIG.bodyParts) do
            if not config.enabled then continue end
            
            -- NOVO: Cores e tamanhos no modo CB
            local color = cbActive and CONFIG.cbMode.color or config.color
            local reach = cbActive and CONFIG.cbMode.reach or config.reach
            
            local sphere = Instance.new("Part")
            sphere.Name = "CaduReach_" .. partType
            sphere.Shape = Enum.PartType.Ball
            sphere.Anchored = true
            sphere.CanCollide = false
            sphere.Transparency = 0.85
            sphere.Material = Enum.Material.ForceField
            sphere.Color = color
            sphere.Size = Vector3.new(reach * 2, reach * 2, reach * 2)
            sphere.Parent = Workspace
            
            reachSpheres[partType] = sphere
        end
    end
end

-- ATUALIZAR POSIÇÕES DAS ESFERAS
function updateSpheresPosition()
    if not spheresVisible then return end
    
    local char = player.Character
    if not char then return end

    if CONFIG.mode == "central" and centralSphere then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            centralSphere.Position = hrp.Position
        end
        
    elseif CONFIG.mode == "bodyparts" then
        for partType, config in pairs(CONFIG.bodyParts) do
            local sphere = reachSpheres[partType]
            if not sphere or not config.enabled then continue end

            if partType == "head" then
                local head = char:FindFirstChild("Head")
                if head then sphere.Position = head.Position end
                
            elseif partType == "torso" then
                local torso = char:FindFirstChild("Torso")
                if torso then sphere.Position = torso.Position end
                
            elseif partType == "arm" then
                local leftArm = char:FindFirstChild("Left Arm")
                local rightArm = char:FindFirstChild("Right Arm")
                if leftArm and rightArm then
                    sphere.Position = (leftArm.Position + rightArm.Position) / 2
                elseif leftArm then
                    sphere.Position = leftArm.Position
                elseif rightArm then
                    sphere.Position = rightArm.Position
                end
                
            elseif partType == "leg" then
                local leftLeg = char:FindFirstChild("Left Leg")
                local rightLeg = char:FindFirstChild("Right Leg")
                if leftLeg and rightLeg then
                    sphere.Position = (leftLeg.Position + rightLeg.Position) / 2
                elseif leftLeg then
                    sphere.Position = leftLeg.Position
                elseif rightLeg then
                    sphere.Position = rightLeg.Position
                end
            end
        end
    end
end

-- TOGGLE MODO (CENTRAL <-> 4 PARTES)
function toggleMode()
    CONFIG.mode = (CONFIG.mode == "central") and "bodyparts" or "central"
    updateReachSpheres()
    
    local modeName = CONFIG.mode == "central" and "ESFERA CENTRAL" or "4 PARTES DO CORPO"
    notify("Modo: " .. modeName, 2)
    updateGUIForMode()
    
    return CONFIG.mode
end

-- TOGGLE PARTE ESPECÍFICA
function toggleBodyPart(partType)
    if CONFIG.mode ~= "bodyparts" then return end
    
    CONFIG.bodyParts[partType].enabled = not CONFIG.bodyParts[partType].enabled
    updateReachSpheres()
    
    local status = CONFIG.bodyParts[partType].enabled and "ON" or "OFF"
    notify(partType:upper() .. ": " .. status, 1)
    return CONFIG.bodyParts[partType].enabled
end

-- GUI PRINCIPAL
local bodyPartButtons = {}
local spheresBtnRef = nil
local auraBtnRef = nil
local cbBtnRef = nil

function buildMainGUI()
    if gui then return end

    gui = Instance.new("ScreenGui")
    gui.Name = "CaduHubGUI"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")

    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.fromScale(0.24, 0.50) -- Aumentado para caber botão CB
    mainFrame.Position = UDim2.fromScale(0.02, 0.05)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = gui

    local stroke = Instance.new("UIStroke", mainFrame)
    stroke.Color = Color3.fromRGB(0, 255, 136)
    stroke.Thickness = 2

    local corner = Instance.new("UICorner", mainFrame)
    corner.CornerRadius = UDim.new(0, 12)

    local gradient = Instance.new("UIGradient", mainFrame)
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 45)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 30))
    })
    gradient.Rotation = 45

    -- Título
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -10, 0.05, 0)
    title.Position = UDim2.new(0, 5, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = "CADU HUB"
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.TextColor3 = Color3.fromRGB(0, 255, 136)
    title.Parent = mainFrame

    -- Linha
    local line = Instance.new("Frame")
    line.Size = UDim2.new(0.8, 0, 0, 2)
    line.Position = UDim2.new(0.1, 0, 0.07, 0)
    line.BackgroundColor3 = Color3.fromRGB(0, 255, 136)
    line.BorderSizePixel = 0
    line.Parent = mainFrame

    -- BOTÃO TOGGLE ESFERAS
    local spheresBtn = Instance.new("TextButton")
    spheresBtn.Name = "SpheresButton"
    spheresBtn.Size = UDim2.new(0.9, 0, 0.05, 0)
    spheresBtn.Position = UDim2.new(0.05, 0, 0.10, 0)
    spheresBtn.Text = "🔵 ESFERAS: ON"
    spheresBtn.TextSize = 10
    spheresBtn.Font = Enum.Font.GothamBold
    spheresBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    spheresBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    spheresBtn.Parent = mainFrame
    spheresBtn.AutoButtonColor = false
    
    Instance.new("UICorner", spheresBtn).CornerRadius = UDim.new(0, 8)
    
    spheresBtn.MouseButton1Click:Connect(function()
        local visible = toggleSpheresVisibility()
        spheresBtn.Text = visible and "🔵 ESFERAS: ON" or "⚫ ESFERAS: OFF"
        spheresBtn.BackgroundColor3 = visible and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(80, 80, 80)
    end)
    
    spheresBtnRef = spheresBtn

    -- BOTÃO TOGGLE AURA BOLAS
    local auraBtn = Instance.new("TextButton")
    auraBtn.Name = "AuraButton"
    auraBtn.Size = UDim2.new(0.9, 0, 0.05, 0)
    auraBtn.Position = UDim2.new(0.05, 0, 0.17, 0)
    auraBtn.Text = "✨ AURA BOLAS: ON"
    auraBtn.TextSize = 10
    auraBtn.Font = Enum.Font.GothamBold
    auraBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
    auraBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    auraBtn.Parent = mainFrame
    auraBtn.AutoButtonColor = false
    
    Instance.new("UICorner", auraBtn).CornerRadius = UDim.new(0, 8)
    
    auraBtn.MouseButton1Click:Connect(function()
        local enabled = toggleBallAura()
        auraBtn.Text = enabled and "✨ AURA BOLAS: ON" or "✨ AURA BOLAS: OFF"
        auraBtn.BackgroundColor3 = enabled and Color3.fromRGB(255, 0, 255) or Color3.fromRGB(80, 80, 80)
    end)
    
    auraBtnRef = auraBtn

    -- NOVO: BOTÃO MODO CB (ZAGUEIRO)
    local cbBtn = Instance.new("TextButton")
    cbBtn.Name = "CBButton"
    cbBtn.Size = UDim2.new(0.9, 0, 0.06, 0)
    cbBtn.Position = UDim2.new(0.05, 0, 0.24, 0)
    cbBtn.Text = "🛡️ MODO CB: OFF"
    cbBtn.TextSize = 11
    cbBtn.Font = Enum.Font.GothamBold
    cbBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100) -- Cinza quando desligado
    cbBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    cbBtn.Parent = mainFrame
    cbBtn.AutoButtonColor = false
    
    Instance.new("UICorner", cbBtn).CornerRadius = UDim.new(0, 8)
    
    cbBtn.MouseButton1Click:Connect(function()
        local enabled = toggleCBMode()
        cbBtn.Text = enabled and "🛡️ MODO CB: ON 🔥" or "🛡️ MODO CB: OFF"
        cbBtn.BackgroundColor3 = enabled and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(100, 100, 100)
        
        -- Atualizar label de status
        if enabled then
            cbLabel.Text = "🔥 CB ATIVO! Reach: " .. CONFIG.cbMode.reach
            cbLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        else
            cbLabel.Text = "Modo Normal"
            cbLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
        end
        
                -- Atualizar esferas com nova cor/tamanho
        updateReachSpheres()
    end)
    
    cbBtnRef = cbBtn

    -- NOVO: Label status CB
    cbLabel = Instance.new("TextLabel")
    cbLabel.Size = UDim2.new(1, 0, 0.04, 0)
    cbLabel.Position = UDim2.new(0, 0, 0.31, 0)
    cbLabel.BackgroundTransparency = 1
    cbLabel.Text = "Modo Normal"
    cbLabel.TextScaled = true
    cbLabel.Font = Enum.Font.GothamSemibold
    cbLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    cbLabel.Parent = mainFrame

    -- BOTÃO MODO (Central/4 Partes)
    local modeBtn = Instance.new("TextButton")
    modeBtn.Name = "ModeButton"
    modeBtn.Size = UDim2.new(0.9, 0, 0.05, 0)
    modeBtn.Position = UDim2.new(0.05, 0, 0.37, 0)
    modeBtn.Text = "MODO: ESFERA CENTRAL"
    modeBtn.TextSize = 10
    modeBtn.Font = Enum.Font.GothamBold
    modeBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    modeBtn.TextColor3 = Color3.fromRGB(25, 25, 35)
    modeBtn.Parent = mainFrame
    modeBtn.AutoButtonColor = false
    
    Instance.new("UICorner", modeBtn).CornerRadius = UDim.new(0, 8)
    
    modeBtn.MouseButton1Click:Connect(function()
        local newMode = toggleMode()
        modeBtn.Text = "MODO: " .. (newMode == "central" and "ESFERA CENTRAL" or "4 PARTES")
        modeBtn.BackgroundColor3 = newMode == "central" and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(255, 150, 0)
    end)

    -- Label modo
    modeLabel = Instance.new("TextLabel")
    modeLabel.Size = UDim2.new(1, 0, 0.04, 0)
    modeLabel.Position = UDim2.new(0, 0, 0.43, 0)
    modeLabel.BackgroundTransparency = 1
    modeLabel.Text = "Esfera única no centro"
    modeLabel.TextScaled = true
    modeLabel.Font = Enum.Font.GothamSemibold
    modeLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    modeLabel.Parent = mainFrame

    -- Container partes
    local partsContainer = Instance.new("Frame")
    partsContainer.Name = "PartsContainer"
    partsContainer.Size = UDim2.new(0.9, 0, 0.26, 0)
    partsContainer.Position = UDim2.new(0.05, 0, 0.48, 0)
    partsContainer.BackgroundTransparency = 1
    partsContainer.Visible = false
    partsContainer.Parent = mainFrame

    local partOrder = {"head", "torso", "arm", "leg"}
    local partNames = {head = "CABEÇA", torso = "TRONCO", arm = "BRAÇOS", leg = "PERNAS"}

    for i, partType in ipairs(partOrder) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0.22, 0)
        btn.Position = UDim2.new(0, 0, (i-1) * 0.25, 0)
        btn.Text = partNames[partType] .. ": ON"
        btn.TextSize = 10
        btn.Font = Enum.Font.GothamBold
        btn.BackgroundColor3 = CONFIG.bodyParts[partType].color
        btn.TextColor3 = Color3.fromRGB(25, 25, 35)
        btn.Parent = partsContainer
        btn.AutoButtonColor = false
        
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        btn.MouseEnter:Connect(function()
            if CONFIG.bodyParts[partType].enabled then
                btn.BackgroundColor3 = Color3.new(
                    math.min(CONFIG.bodyParts[partType].color.R + 0.2, 1),
                    math.min(CONFIG.bodyParts[partType].color.G + 0.2, 1),
                    math.min(CONFIG.bodyParts[partType].color.B + 0.2, 1)
                )
            else
                btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            end
        end)

        btn.MouseLeave:Connect(function()
            if CONFIG.bodyParts[partType].enabled then
                btn.BackgroundColor3 = CONFIG.bodyParts[partType].color
            else
                btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            end
        end)

        btn.MouseButton1Click:Connect(function()
            local enabled = toggleBodyPart(partType)
            btn.Text = partNames[partType] .. ": " .. (enabled and "ON" or "OFF")
            btn.BackgroundColor3 = enabled and CONFIG.bodyParts[partType].color or Color3.fromRGB(60, 60, 60)
            btn.TextColor3 = enabled and Color3.fromRGB(25, 25, 35) or Color3.fromRGB(150, 150, 150)
        end)

        bodyPartButtons[partType] = btn
    end

    -- Label reach
    local reachLabel = Instance.new("TextLabel")
    reachLabel.Size = UDim2.new(1, 0, 0.04, 0)
    reachLabel.Position = UDim2.new(0, 0, 0.76, 0)
    reachLabel.BackgroundTransparency = 1
    reachLabel.Text = "REACH: " .. CONFIG.reach
    reachLabel.TextScaled = true
    reachLabel.Font = Enum.Font.GothamSemibold
    reachLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    reachLabel.Parent = mainFrame

    -- Container + e -
    local adjustContainer = Instance.new("Frame")
    adjustContainer.Size = UDim2.new(0.9, 0, 0.05, 0)
    adjustContainer.Position = UDim2.new(0.05, 0, 0.81, 0)
    adjustContainer.BackgroundTransparency = 1
    adjustContainer.Parent = mainFrame

    local minus = Instance.new("TextButton")
    minus.Size = UDim2.new(0.45, 0, 1, 0)
    minus.Text = "−"
    minus.TextSize = 14
    minus.Font = Enum.Font.GothamBold
    minus.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    minus.TextColor3 = Color3.fromRGB(255, 100, 100)
    minus.Parent = adjustContainer
    minus.AutoButtonColor = false
    Instance.new("UICorner", minus).CornerRadius = UDim.new(0, 6)

    local plus = Instance.new("TextButton")
    plus.Size = UDim2.new(0.45, 0, 1, 0)
    plus.Position = UDim2.new(0.55, 0, 0, 0)
    plus.Text = "+"
    plus.TextSize = 14
    plus.Font = Enum.Font.GothamBold
    plus.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    plus.TextColor3 = Color3.fromRGB(0, 255, 136)
    plus.Parent = adjustContainer
    plus.AutoButtonColor = false
    Instance.new("UICorner", plus).CornerRadius = UDim.new(0, 6)

    -- Botão esconder
    local hideBtn = Instance.new("TextButton")
    hideBtn.Size = UDim2.new(0.9, 0, 0.05, 0)
    hideBtn.Position = UDim2.new(0.05, 0, 0.90, 0)
    hideBtn.Text = isMobile and "FECHAR" or "ESCONDER [INSERT]"
    hideBtn.TextSize = 10
    hideBtn.Font = Enum.Font.GothamSemibold
    hideBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    hideBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
    hideBtn.Parent = mainFrame
    Instance.new("UICorner", hideBtn).CornerRadius = UDim.new(0, 6)

    -- FUNÇÕES
    minus.MouseButton1Click:Connect(function()
        CONFIG.reach = math.max(1, CONFIG.reach - 1)
        CONFIG.centralSphere.reach = CONFIG.reach
        CONFIG.ballReach = math.max(1, CONFIG.ballReach - 1)
        CONFIG.cbMode.reach = math.max(1, CONFIG.cbMode.reach - 1)
        reachLabel.Text = "REACH: " .. CONFIG.reach
        for _, config in pairs(CONFIG.bodyParts) do
            config.reach = math.max(1, config.reach - 1)
        end
        updateReachSpheres()
        notify("Reach: " .. CONFIG.reach, 1)
    end)

    plus.MouseButton1Click:Connect(function()
        CONFIG.reach += 1
        CONFIG.centralSphere.reach = CONFIG.reach
        CONFIG.ballReach += 1
        CONFIG.cbMode.reach += 1
        reachLabel.Text = "REACH: " .. CONFIG.reach
        for _, config in pairs(CONFIG.bodyParts) do
            config.reach += 1
        end
        updateReachSpheres()
        notify("Reach: " .. CONFIG.reach, 1)
    end)

    hideBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        if isMobile then
            notify("Use o botão flutuante", 2)
        else
            notify("Pressione INSERT", 2)
        end
    end)
end

-- ATUALIZAR GUI BASEADO NO MODO
function updateGUIForMode()
    if not mainFrame then return end
    
    local partsContainer = mainFrame:FindFirstChild("PartsContainer")
    
    if CONFIG.mode == "central" then
        partsContainer.Visible = false
        modeLabel.Text = "Esfera única no centro (HRP)"
        modeLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
    else
        partsContainer.Visible = true
        modeLabel.Text = "4 esferas: Cabeça, Tronco, Braços, Pernas"
        modeLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
    end
end

-- BOTÃO FLUTUANTE MOBILE
local function buildMobileButton()
    local mobileGui = Instance.new("ScreenGui")
    mobileGui.Name = "CaduMobileBtn"
    mobileGui.ResetOnSpawn = false
    mobileGui.Parent = player:WaitForChild("PlayerGui")

    local floatBtn = Instance.new("TextButton")
    floatBtn.Name = "FloatButton"
    floatBtn.Size = UDim2.new(0, 65, 0, 65)
    floatBtn.Position = UDim2.new(1, -85, 1, -140)
    floatBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    floatBtn.Text = "CADU\nHUB"
    floatBtn.TextSize = 11
    floatBtn.Font = Enum.Font.GothamBold
    floatBtn.TextColor3 = Color3.fromRGB(0, 255, 136)
    floatBtn.Parent = mobileGui
    floatBtn.Active = true
    floatBtn.Draggable = true
    floatBtn.AutoButtonColor = false

    local btnStroke = Instance.new("UIStroke", floatBtn)
    btnStroke.Color = Color3.fromRGB(0, 255, 136)
    btnStroke.Thickness = 2

    local btnCorner = Instance.new("UICorner", floatBtn)
    btnCorner.CornerRadius = UDim.new(1, 0)

    local btnGradient = Instance.new("UIGradient", floatBtn)
    btnGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 30))
    })

    floatBtn.MouseButton1Down:Connect(function()
        floatBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 136)
        floatBtn.TextColor3 = Color3.fromRGB(25, 25, 35)
    end)
    
    floatBtn.MouseButton1Up:Connect(function()
        floatBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        floatBtn.TextColor3 = Color3.fromRGB(0, 255, 136)
    end)

    floatBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
    end)
end

-- TECLA INSERT (PC apenas)
if not isMobile then
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
            if mainFrame then
                mainFrame.Visible = not mainFrame.Visible
            end
        end
    end)
end

-- AUTO TOUCH (colisão melhorada com modo CB)
local function processTouch()
    local char = player.Character
    if not char then return end

    local validParts = getValidParts(char)
    
    for _, data in ipairs(validParts) do
        local part = data.part
        local playerReach = data.reach
        
        for _, ball in ipairs(balls) do
            if ball and ball.Parent then
                local distance = (ball.Position - part.Position).Magnitude
                
                local combinedReach = playerReach + CONFIG.ballReach
                
                if cbActive then
                    combinedReach = combinedReach + 5
                    
                    local velocity = ball.AssemblyLinearVelocity or Vector3.new(0,0,0)
                    if velocity.Magnitude > 20 then
                        local predictedPos = ball.Position + (velocity.Unit * 2)
                        distance = (predictedPos - part.Position).Magnitude
                    end
                end
                
                if distance <= combinedReach then
                    pcall(function()
                        firetouchinterest(ball, part, 0)
                        firetouchinterest(ball, part, 1)
                    end)
                end
            end
        end
    end
end

-- LOOPS
RunService.RenderStepped:Connect(function()
    updateSpheresPosition()
    updateBallAuras()
    
    if CONFIG.autoSecondTouch then
        processTouch()
    end
end)

task.spawn(function()
    while true do
        refreshBalls(false)
        task.wait(CONFIG.scanCooldown)
    end
end)

-- INIT
buildMainGUI()
if isMobile then
    buildMobileButton()
    notify("📱 Modo Mobile Ativo", 3)
else
    notify("💻 Modo PC Ativo", 3)
end
updateReachSpheres()
updateGUIForMode()
refreshBalls(true)
notify("✅ Cadu Hub Online", 3)
notify("🛡️ NOVO: Botão MODO CB para zagueiros!", 3)
print("Cadu Hub OK | Modo:", CONFIG.mode, "| CB:", cbActive, "| Mobile:", isMobile)
