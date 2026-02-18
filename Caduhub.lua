-- SERVICES
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer

-- CONFIG
local CONFIG = {
    playerReach = 10,
    ballReach = 15,
    autoTouch = true,
    showVisuals = true,
    flashEnabled = false,
    antiAFK = true,
    quantumReachEnabled = false,
    quantumReach = 10,
    expandBallHitbox = true,
    ballNames = { "TPS", "MPS", "TRS", "TCS", "PRS", "ESA", "MRS", "SSS", "AIFA", "RBZ", "SoccerBall", "Football", "Ball" },
    
    colors = {
        bg = Color3.fromRGB(18, 18, 23),
        tabBg = Color3.fromRGB(30, 30, 38),
        cardBg = Color3.fromRGB(35, 35, 47),
        accent = Color3.fromRGB(88, 101, 242),
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
        gradient1 = Color3.fromRGB(88, 101, 242),
        gradient2 = Color3.fromRGB(235, 69, 158)
    }
}

-- STEALTH CONFIG
local STEALTH_CONFIG = {
    bigFootSize = 8,
    touchRate = 0,
    useSpoof = true,
    randomOffset = true,
    bypassAC = true
}

-- VARIABLES
local balls = {}
local ballAuras = {}
local ballHitboxes = {}
local playerSphere = nil
local quantumCircle = nil
local HRP = nil
local character = nil
local humanoid = nil
local gui = nil
local mainWindow = nil
local currentTab = "Reach"
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local connections = {}
local isUIOpen = true
local isScriptActive = false

-- BIGFOOT VARIABLES
local bigFoot = nil
local spoofPart = nil
local lastTouch = 0
local bigFootConnection = nil

-- BALL SET
local BALL_NAME_SET = {}
for _, n in ipairs(CONFIG.ballNames) do
    BALL_NAME_SET[n] = true
end

-- SAFE GETTERS (Previne nil values)
local function getCharacter()
    return player and player.Character
end

local function getHRP()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChild("Humanoid")
end

-- UTILITY FUNCTIONS
local function disconnectAll()
    for _, conn in pairs(connections) do
        if conn then 
            pcall(function() conn:Disconnect() end)
        end
    end
    connections = {}
end

local function createConnection(signal, callback)
    if not signal or not callback then return nil end
    local conn = signal:Connect(callback)
    if conn then
        table.insert(connections, conn)
    end
    return conn
end

local function safeDestroy(obj)
    if obj and obj.Parent then
        pcall(function() obj:Destroy() end)
    end
end

-- BIGFOOT STEALTH SYSTEM (CORRIGIDO)
local function createStealthBigFoot()
    local char = getCharacter()
    if not char then 
        warn("[BigFoot] Character não encontrado")
        return nil 
    end
    
    -- Limpa anterior com segurança
    safeDestroy(bigFoot)
    safeDestroy(spoofPart)
    if bigFootConnection then
        pcall(function() bigFootConnection:Disconnect() end)
        bigFootConnection = nil
    end
    
    -- Procura a perna com múltiplas alternativas
    local rightLeg = char:FindFirstChild("Right Leg") or 
                     char:FindFirstChild("RightLowerLeg") or
                     char:FindFirstChild("RightFoot") or
                     char:FindFirstChild("RightUpperLeg")
    
    if not rightLeg then
        -- Tenta encontrar qualquer perna
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and (part.Name:lower():match("leg") or part.Name:lower():match("foot")) then
                rightLeg = part
                break
            end
        end
    end
    
    if not rightLeg then
        warn("[BigFoot] RightLeg não encontrado, usando Torso como fallback")
        rightLeg = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart")
    end
    
    if not rightLeg then
        warn("[BigFoot] Nenhuma parte válida encontrada para BigFoot")
        return nil
    end
    
    -- Cria BigFoot com proteção
    local success, result = pcall(function()
        bigFoot = Instance.new("Part")
        bigFoot.Name = "HumanoidRootPart_BigFoot"
        bigFoot.Shape = Enum.PartType.Ball
        bigFoot.Size = Vector3.new(STEALTH_CONFIG.bigFootSize, STEALTH_CONFIG.bigFootSize, STEALTH_CONFIG.bigFootSize)
        bigFoot.Transparency = 1
        bigFoot.CanCollide = false
        bigFoot.CanQuery = false
        bigFoot.CanTouch = true
        bigFoot.Parent = char
        
        -- Spoof part
        if STEALTH_CONFIG.useSpoof then
            spoofPart = Instance.new("Part")
            spoofPart.Name = "LegSpoof"
            spoofPart.Size = rightLeg.Size
            spoofPart.Transparency = 1
            spoofPart.CanCollide = false
            spoofPart.Parent = Workspace
        end
        
        -- Conexão de posição com verificações de nil
        bigFootConnection = RunService.Heartbeat:Connect(function()
            if not bigFoot or not bigFoot.Parent then return end
            if not rightLeg or not rightLeg.Parent then 
                -- Tenta recriar se a perna sumiu
                createStealthBigFoot()
                return 
            end
            
            local baseOffset = CFrame.new(0, -rightLeg.Size.Y/2 - 0.5, 0)
            
            if STEALTH_CONFIG.randomOffset then
                local jitter = Vector3.new(
                    math.random(-10, 10)/100,
                    math.random(-10, 10)/100,
                    math.random(-10, 10)/100
                )
                baseOffset = baseOffset + CFrame.new(jitter)
            end
            
            pcall(function()
                bigFoot.CFrame = rightLeg.CFrame * baseOffset
            end)
            
            if spoofPart then
                pcall(function()
                    spoofPart.CFrame = rightLeg.CFrame
                    spoofPart.Velocity = rightLeg.Velocity or Vector3.new()
                    spoofPart.RotVelocity = rightLeg.RotVelocity or Vector3.new()
                end)
            end
        end)
        
        return bigFoot
    end)
    
    if not success then
        warn("[BigFoot] Erro ao criar: " .. tostring(result))
        return nil
    end
    
    print("[BigFoot] Criado com sucesso em: " .. rightLeg.Name)
    return bigFoot
end

local function stealthTouch(ball)
    if not ball or not bigFoot or not bigFoot.Parent then 
        return 
    end
    
    local now = tick()
    if now - lastTouch < STEALTH_CONFIG.touchRate then return end
    lastTouch = now
    
    -- Método 1: Touch direto com pcall
    pcall(function()
        if firetouchinterest then
            firetouchinterest(ball, bigFoot, 0)
            task.wait()
            firetouchinterest(ball, bigFoot, 1)
        end
    end)
    
    -- Método 2: Descendentes
    pcall(function()
        for _, child in ipairs(bigFoot:GetDescendants()) do
            if child:IsA("TouchTransmitter") or child.Name == "TouchInterest" then
                if child.Parent then
                    firetouchinterest(ball, child.Parent, 0)
                    task.wait()
                    firetouchinterest(ball, child.Parent, 1)
                end
            end
        end
    end)
    
    -- Método 3: CFrame teleport (com backup)
    if STEALTH_CONFIG.bypassAC then
        local originalCF
        pcall(function()
            originalCF = bigFoot.CFrame
            bigFoot.CFrame = ball.CFrame
            task.wait()
            firetouchinterest(ball, bigFoot, 0)
            firetouchinterest(ball, bigFoot, 1)
        end)
        if originalCF then
            pcall(function()
                bigFoot.CFrame = originalCF
            end)
        end
    end
    
    -- Método 4: Network ownership
    pcall(function()
        if ball.SetNetworkOwner then
            ball:SetNetworkOwner(player)
        end
    end)
end

-- INICIALIZAÇÃO SEGURA DO CHARACTER
local function onCharacterAdded(char)
    character = char
    HRP = nil
    humanoid = nil
    
    -- Aguarda HumanoidRootPart com timeout
    local startTime = tick()
    repeat
        HRP = char:FindFirstChild("HumanoidRootPart")
        if HRP then break end
        task.wait(0.1)
    until tick() - startTime > 5
    
    if not HRP then
        warn("[Init] HumanoidRootPart não encontrado após 5s")
        return
    end
    
    humanoid = char:FindFirstChild("Humanoid")
    
    -- Cria BigFoot após delay para garantir que tudo carregou
    task.delay(1, function()
        createStealthBigFoot()
    end)
    
    print("[Init] Character inicializado com sucesso")
end

-- CONEXÕES DO PLAYER
if player then
    createConnection(player.CharacterAdded, onCharacterAdded)
    
    if player.Character then
        onCharacterAdded(player.Character)
    end
else
    warn("[Init] Player não encontrado!")
    return
end

-- UPDATE HRP E BIGFOOT (LOOP SEGURO)
task.spawn(function()
    while true do
        task.wait(0.5)
        
        -- Atualiza referências se necessário
        if not character or not character.Parent then
            character = getCharacter()
        end
        
        if not HRP or not HRP.Parent then
            HRP = getHRP()
        end
        
        if not humanoid or not humanoid.Parent then
            humanoid = getHumanoid()
        end
        
        -- Recria BigFoot se necessário
        if character and (not bigFoot or not bigFoot.Parent) then
            createStealthBigFoot()
        end
    end
end)

-- ANTI-AFK
if CONFIG.antiAFK then
    pcall(function()
        player.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end)
end

-- GET BALLS (OTIMIZADO)
local lastBallUpdate = 0
local function getBalls()
    local now = tick()
    if now - lastBallUpdate < 0.05 then return balls end
    lastBallUpdate = now
    
    table.clear(balls)
    
    -- Verifica se Workspace existe
    if not Workspace then return balls end
    
    local descendants = Workspace:GetDescendants()
    for _, v in ipairs(descendants) do
        if v and v:IsA("BasePart") and BALL_NAME_SET[v.Name] then
            table.insert(balls, v)
        end
    end
    
    return balls
end

-- CREATE BALL HITBOX (SEGURANÇA MÁXIMA)
local function createBallHitbox(ball)
    if not ball or not ball.Parent then return end
    if ballHitboxes[ball] or not CONFIG.expandBallHitbox then return end
    
    local success, hitbox = pcall(function()
        local hb = Instance.new("Part")
        hb.Name = "ExpandedHitbox_" .. ball.Name
        hb.Shape = Enum.PartType.Ball
        hb.Size = Vector3.new(CONFIG.ballReach * 2, CONFIG.ballReach * 2, CONFIG.ballReach * 2)
        hb.Transparency = 1
        hb.Anchored = true
        hb.CanCollide = false
        hb.Material = Enum.Material.SmoothPlastic
        hb.Parent = Workspace
        
        local conn
        conn = RunService.Heartbeat:Connect(function()
            if not conn then return end
            if ball and ball.Parent and hb and hb.Parent then
                hb.CFrame = ball.CFrame
            else
                pcall(function() conn:Disconnect() end)
                safeDestroy(hb)
            end
        end)
        
        return {hitbox = hb, conn = conn}
    end)
    
    if success and hitbox then
        ballHitboxes[ball] = hitbox
    end
end

-- REMOVE BALL HITBOX
local function removeBallHitbox(ball)
    local data = ballHitboxes[ball]
    if data then
        if data.conn then pcall(function() data.conn:Disconnect() end) end
        safeDestroy(data.hitbox)
        ballHitboxes[ball] = nil
    end
end

-- UPDATE BALL HITBOXES
local function updateBallHitboxes()
    -- Limpa inválidos
    for ball, _ in pairs(ballHitboxes) do
        if not ball or not ball.Parent then 
            removeBallHitbox(ball) 
        end
    end
    
    if not CONFIG.expandBallHitbox then return end
    
    local currentBalls = getBalls()
    for _, ball in ipairs(currentBalls) do
        if ball and ball.Parent then
            if ballHitboxes[ball] then
                local targetSize = Vector3.new(CONFIG.ballReach * 2, CONFIG.ballReach * 2, CONFIG.ballReach * 2)
                local hb = ballHitboxes[ball].hitbox
                if hb and hb.Size ~= targetSize then
                    pcall(function() hb.Size = targetSize end)
                end
            else
                createBallHitbox(ball)
            end
        end
    end
end

-- CLEAR ALL AURAS
local function clearAllAuras()
    for ball, data in pairs(ballAuras) do
        if data then
            if data.conn then pcall(function() data.conn:Disconnect() end) end
            safeDestroy(data.aura)
            safeDestroy(data.highlight)
        end
    end
    ballAuras = {}
    
    for ball, data in pairs(ballHitboxes) do
        if data then
            if data.conn then pcall(function() data.conn:Disconnect() end) end
            safeDestroy(data.hitbox)
        end
    end
    ballHitboxes = {}
    
    safeDestroy(playerSphere)
    playerSphere = nil
    safeDestroy(quantumCircle)
    quantumCircle = nil
end

-- CREATE BALL AURA
local function createBallAura(ball)
    if not ball or not ball.Parent then return end
    if ballAuras[ball] or not CONFIG.showVisuals then return end
    
    local success, result = pcall(function()
        local aura = Instance.new("Part")
        aura.Name = "BallAura_" .. ball.Name
        aura.Shape = Enum.PartType.Ball
        aura.Size = Vector3.new(CONFIG.ballReach * 2, CONFIG.ballReach * 2, CONFIG.ballReach * 2)
        aura.Transparency = 0.85
        aura.Anchored = true
        aura.CanCollide = false
        aura.Material = Enum.Material.ForceField
        aura.Color = ball.Name == "TPS" and CONFIG.colors.accent3 or CONFIG.colors.accent2
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
            if not ball or not ball.Parent or not aura or not aura.Parent then
                safeDestroy(aura)
                return
            end
            
            local targetSize = Vector3.new(CONFIG.ballReach * 2, CONFIG.ballReach * 2, CONFIG.ballReach * 2)
            if aura.Size ~= targetSize then
                pcall(function() aura.Size = targetSize end)
            end
            
            pcall(function()
                aura.CFrame = ball.CFrame
            end)
        end)
        
        return {aura = aura, highlight = highlight, conn = conn}
    end)
    
    if success and result then
        ballAuras[ball] = result
    end
end

-- REMOVE BALL AURA
local function removeBallAura(ball)
    local data = ballAuras[ball]
    if data then
        if data.conn then pcall(function() data.conn:Disconnect() end) end
        safeDestroy(data.aura)
        safeDestroy(data.highlight)
        ballAuras[ball] = nil
    end
end

-- UPDATE AURAS
local function updateBallAuras()
    for ball, _ in pairs(ballAuras) do
        if not ball or not ball.Parent then removeBallAura(ball) end
    end
    
    if not CONFIG.showVisuals then return end
    
    local currentBalls = getBalls()
    for _, ball in ipairs(currentBalls) do
        if ball and ball.Parent then
            if ballAuras[ball] then
                local targetSize = Vector3.new(CONFIG.ballReach * 2, CONFIG.ballReach * 2, CONFIG.ballReach * 2)
                local aura = ballAuras[ball].aura
                if aura and aura.Size ~= targetSize then
                    pcall(function() aura.Size = targetSize end)
                end
            else
                createBallAura(ball)
            end
        end
    end
end

-- UPDATE PLAYER SPHERE
local function updatePlayerSphere()
    if not CONFIG.showVisuals then
        safeDestroy(playerSphere)
        playerSphere = nil
        return
    end
    
    if not HRP or not HRP.Parent then
        HRP = getHRP()
        if not HRP then return end
    end
    
    if not playerSphere then
        local success, sphere = pcall(function()
            local s = Instance.new("Part")
            s.Name = "PlayerSphere"
            s.Shape = Enum.PartType.Ball
            s.Anchored = true
            s.CanCollide = false
            s.Material = Enum.Material.ForceField
            s.Color = CONFIG.colors.accent
            s.Parent = Workspace
            return s
        end)
        
        if success then
            playerSphere = sphere
        else
            return
        end
    end
    
    pcall(function()
        playerSphere.Size = Vector3.new(CONFIG.playerReach * 2, CONFIG.playerReach * 2, CONFIG.playerReach * 2)
        playerSphere.Position = HRP.Position
        playerSphere.Transparency = 0.8
    end)
end

-- UPDATE QUANTUM CIRCLE
local function updateQuantumCircle()
    if not quantumCircle then
        local success, circle = pcall(function()
            local c = Instance.new("Part")
            c.Name = "QuantumCircle"
            c.Shape = Enum.PartType.Ball
            c.Anchored = true
            c.CanCollide = false
            c.Material = Enum.Material.ForceField
            c.Color = CONFIG.colors.accent3
            c.Parent = Workspace
            return c
        end)
        
        if success then
            quantumCircle = circle
        else
            return
        end
    end
    
    pcall(function()
        quantumCircle.Size = Vector3.new(CONFIG.quantumReach * 2, CONFIG.quantumReach * 2, CONFIG.quantumReach * 2)
        quantumCircle.Transparency = (CONFIG.quantumReachEnabled and CONFIG.showVisuals) and 0.8 or 1
    end)
end

-- DO REACH (CORRIGIDO)
local function doReach()
    if not CONFIG.autoTouch then return end
    
    -- Atualiza HRP se necessário
    if not HRP or not HRP.Parent then
        HRP = getHRP()
        if not HRP then return end
    end
    
    -- Garante BigFoot
    if not bigFoot or not bigFoot.Parent then
        createStealthBigFoot()
        if not bigFoot then return end
    end
    
    local ballsList = getBalls()
    if #ballsList == 0 then return end
    
    for _, ball in ipairs(ballsList) do
        if not ball or not ball.Parent then continue end
        
        local success, dist = pcall(function()
            return (ball.Position - HRP.Position).Magnitude
        end)
        
        if not success then continue end
        
        local effectiveReach = CONFIG.playerReach + CONFIG.ballReach
        
        if dist < effectiveReach then
            stealthTouch(ball)
            
            if CONFIG.flashEnabled and CONFIG.showVisuals then
                pcall(function()
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
                end)
            end
        end
    end
end

-- DO QUANTUM REACH
local function doQuantumReach()
    if not CONFIG.quantumReachEnabled then return end
    
    if not HRP or not HRP.Parent then
        HRP = getHRP()
        if not HRP then return end
    end
    
    if not bigFoot or not bigFoot.Parent then
        createStealthBigFoot()
        if not bigFoot then return end
    end
    
    local ballsList = getBalls()
    for _, ball in ipairs(ballsList) do
        if not ball or not ball.Parent then continue end
        
        local success, dist = pcall(function()
            return (ball.Position - HRP.Position).Magnitude
        end)
        
        if success and dist < CONFIG.quantumReach then
            stealthTouch(ball)
        end
    end
end

-- TOGGLE FUNCTIONS (para usar na UI)
local function toggleAutoTouch()
    CONFIG.autoTouch = not CONFIG.autoTouch
    return CONFIG.autoTouch
end

local function toggleVisuals()
    CONFIG.showVisuals = not CONFIG.showVisuals
    if not CONFIG.showVisuals then
        clearAllAuras()
    end
    return CONFIG.showVisuals
end

local function toggleFlash()
    CONFIG.flashEnabled = not CONFIG.flashEnabled
    return CONFIG.flashEnabled
end

local function toggleQuantumReach()
    CONFIG.quantumReachEnabled = not CONFIG.quantumReachEnabled
    if not CONFIG.quantumReachEnabled and quantumCircle then
        pcall(function() quantumCircle.Transparency = 1 end)
    end
    return CONFIG.quantumReachEnabled
end

local function toggleHitboxExpand()
    CONFIG.expandBallHitbox = not CONFIG.expandBallHitbox
    if not CONFIG.expandBallHitbox then
        for ball, _ in pairs(ballHitboxes) do
            removeBallHitbox(ball)
        end
    end
    return CONFIG.expandBallHitbox
end

local function setPlayerReach(value)
    CONFIG.playerReach = math.clamp(value, 1, 50)
    return CONFIG.playerReach
end

local function setBallReach(value)
    CONFIG.ballReach = math.clamp(value, 1, 50)
    return CONFIG.ballReach
end

local function setQuantumReach(value)
    CONFIG.quantumReach = math.clamp(value, 1, 100)
    return CONFIG.quantumReach
end

-- MAIN LOOP (INICIALIZAÇÃO SEGURA)
task.spawn(function()
    -- Aguarda inicialização completa
    local attempts = 0
    repeat
        task.wait(0.5)
        attempts = attempts + 1
        if attempts > 20 then -- Timeout de 10 segundos
            warn("[System] Timeout aguardando inicialização")
            break
        end
    until (HRP and bigFoot) or not isScriptActive
    
    if not isScriptActive then return end
    
    isScriptActive = true
    print("[System] Script ativo e operacional")
    
    while isScriptActive do
        local success, err = pcall(function()
            -- Atualizações visuais
            updateBallAuras()
            updatePlayerSphere()
            updateQuantumCircle()
            updateBallHitboxes()
            
            -- Lógica principal
            doReach()
            doQuantumReach()
        end)
        
        if not success then
            warn("[Loop Error] " .. tostring(err))
        end
        
        task.wait(0.03) -- ~30 FPS
    end
end)

-- LIMPEZA AO DESCONECTAR/FECHAR
local function cleanup()
    isScriptActive = false
    clearAllAuras()
    disconnectAll()
    
    safeDestroy(bigFoot)
    safeDestroy(spoofPart)
    safeDestroy(playerSphere)
    safeDestroy(quantumCircle)
    
    print("[Cleanup] Script finalizado e limpo")
end

-- Detecta quando o jogador respawna (limpa tudo)
createConnection(player.CharacterRemoving, function()
    clearAllAuras()
    bigFoot = nil
    spoofPart = nil
    HRP = nil
    humanoid = nil
    character = nil
end)

-- Detecta quando o jogador recebe novo personagem
createConnection(player.CharacterAdded, function(newChar)
    task.delay(1, function()
        onCharacterAdded(newChar)
    end)
end)

-- LIMPEZA AO FECHAR GUI (se você tiver uma GUI)
-- Substitua "YourGuiName" pelo nome real da sua interface
pcall(function()
    game:GetService("CoreGui").ChildRemoved:Connect(function(child)
        if child.Name == "YourGuiName" then
            cleanup()
        end
    end)
end)

-- Anti-detect simples (opcional)
pcall(function()
    -- Esconde partes do workspace se necessário
    game:GetService("RunService").Stepped:Connect(function()
        if bigFoot and bigFoot.Parent then
            bigFoot.LocalTransparencyModifier = 1
        end
        for _, data in pairs(ballHitboxes) do
            if data.hitbox then
                data.hitbox.LocalTransparencyModifier = 1
            end
        end
    end)
end)

print("[Loader] Script carregado com proteções anti-nil")
print("[Loader] Comandos disponíveis:")
print("  - toggleAutoTouch()")
print("  - toggleVisuals()")
print("  - toggleFlash()")
print("  - toggleQuantumReach()")
print("  - toggleHitboxExpand()")
print("  - setPlayerReach(numero)")
print("  - setBallReach(numero)")
print("  - setQuantumReach(numero)")
print("  - cleanup() -- para desligar tudo")

-- Retorna funções úteis para controle externo
return {
    toggleAutoTouch = toggleAutoTouch,
    toggleVisuals = toggleVisuals,
    toggleFlash = toggleFlash,
    toggleQuantumReach = toggleQuantumReach,
    toggleHitboxExpand = toggleHitboxExpand,
    setPlayerReach = setPlayerReach,
    setBallReach = setBallReach,
    setQuantumReach = setQuantumReach,
    cleanup = cleanup,
    getConfig = function() return CONFIG end,
    getStatus = function() 
        return {
            active = isScriptActive,
            hasHRP = HRP ~= nil,
            hasBigFoot = bigFoot ~= nil,
            ballsCount = #getBalls()
        }
    end
}
