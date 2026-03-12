--[[
    CAFUXZ1 Hub v14.3 - Ultimate Edition + Skybox System
    ====================================================
    
    CRIADORES OFICIAIS:
    - Bazuka: Reconstrução total, integração WindUI + CADUXX137
    - Cafuxz1: Contribuições, sistema GK e melhorias no sistema
    - CADUXX137: Sistema de Ball Reach original (lógica de detecção de bolas)
    
    INTERFACE:
    - CAFUXZ1 Hub: WindUI Library (emprestada para este projeto)
    
    DESCRIÇÃO:
    Script focado exclusivamente em jogos de futebol/soccer do Roblox.
    Combina a interface moderna do CAFUXZ1 Hub com o sistema avançado
    de Ball Reach do CADUXX137 v14.0 Ultimate.
    
    FEATURES:
    - Detecção automática de 200+ tipos de bolas
    - Reach sphere/cubo visual com partículas
    - Reach GK (Goleiro) com cubo ampliado
    - Auto-touch com full body support
    - Double touch e triple touch
    - Auto-skills para botões de futebol
    - Estatísticas em tempo real
    - Temas dark/light/auto
    - Atalhos de teclado (F1, F2, F3, F4, F5, F6, F7)
    - NOVO: Sistema Anti Lag completo
    - NOVO: Morph Avatar (Char) integrado com 4 pré-definidos
    - NOVO: Sistema Skybox v1.0 com 16 céus
    
    VERSÃO: v14.3 Ultimate
    STATUS: Produção
]]

if not game:IsLoaded() then game.Loaded:Wait() end

-- ============================================
-- SERVIÇOS
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local TestService = game:GetService("TestService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Character = nil
local Humanoid = nil
local RootPart = nil
local Camera = Workspace.CurrentCamera

-- ============================================
-- CONFIGURAÇÕES CAFUXZ1 v14.3 ULTIMATE
-- ============================================
local CONFIG = {
    -- Dimensões
    width = 580,
    height = 420,
    sidebarWidth = 85,
    
    -- Core Ball Reach
    reach = 15,
    showReachSphere = true,
    autoTouch = true,
    fullBodyTouch = true,
    autoSecondTouch = true,
    scanCooldown = 1.5,
    scale = 1.0,
    
    -- Reach GK (NOVO)
    reachGK = 25,
    reachGKEnabled = false,
    reachGKColor = Color3.fromRGB(255, 255, 0), -- Amarelo padrão
    reachGKTransparency = 0.8,
    reachGKShow = true,
    
    -- Anti Lag Settings (NOVO)
    antiLag = {
        enabled = false,
        textures = true,
        visualEffects = true,
        parts = true,
        particles = true,
        sky = true,
        fullBright = false
    },
    
    -- Morph Settings (NOVO)
    morph = {
        minimized = false,
        draggingTitleBar = false,
        dragStart = nil,
        startPos = nil
    },
    
    -- Sistema de temas
    theme = "dark",
    accentColor = Color3.fromRGB(99, 102, 241),
    particleEffects = true,
    soundEffects = true,
    showStats = true,
    autoUpdate = true,
    
    -- IDs das imagens atualizadas (Bazuka)
    iconImage = "rbxassetid://88380080222477",      -- Ícone do botão
    
    -- Lista expandida de bolas (CADUXX137)
    ballNames = { 
        "TPS", "TCS", "ESA", "MRS", "PRS", "MPS", "SSS", "AIFA", "RBZ",
        "Ball", "Soccer", "Football", "Basketball", "Baseball", 
        "BallTemplate", "GameBall", "Hitbox", "TouchPart", "GoalBall",
        "Physics", "Interaction", "Trigger", "Touch", "Hit", "Box",
        " bola", "Bola", "BALL", "SOCCER", "FOOTBALL", "SoccerBall"
    },
    
    -- Cores tema Dark
    primary = Color3.fromRGB(99, 102, 241),
    secondary = Color3.fromRGB(139, 92, 246),
    accent = Color3.fromRGB(14, 165, 233),
    success = Color3.fromRGB(34, 197, 94),
    danger = Color3.fromRGB(239, 68, 68),
    warning = Color3.fromRGB(245, 158, 11),
    info = Color3.fromRGB(59, 130, 246),
    
    bgDark = Color3.fromRGB(12, 12, 20),
    bgCard = Color3.fromRGB(28, 28, 42),
    bgElevated = Color3.fromRGB(42, 42, 62),
    bgGlass = Color3.fromRGB(22, 22, 36),
    
    textPrimary = Color3.fromRGB(252, 252, 255),
    textSecondary = Color3.fromRGB(170, 180, 210),
    textMuted = Color3.fromRGB(130, 140, 170),
    
    -- Cores tema Light
    lightBg = Color3.fromRGB(245, 245, 250),
    lightCard = Color3.fromRGB(255, 255, 255),
    lightText = Color3.fromRGB(30, 30, 40),
    lightMuted = Color3.fromRGB(100, 110, 130)
}

-- ============================================
-- ESTATÍSTICAS E LOGS (CAFUXZ1)
-- ============================================
local STATS = {
    totalTouches = 0,
    ballsTouched = 0,
    sessionStart = tick(),
    fps = 0,
    ping = 0,
    lastUpdate = tick(),
    touchesPerMinute = 0,
    peakReach = 0,
    skillsActivated = 0,
    gkSaves = 0,
    antiLagItems = 0,
    morphsDone = 0
}

local LOGS = {}
local MAX_LOGS = 50

local function addLog(message, type)
    type = type or "info"
    table.insert(LOGS, 1, {
        message = message,
        type = type,
        time = os.date("%H:%M:%S"),
        timestamp = tick()
    })
    
    if #LOGS > MAX_LOGS then
        table.remove(LOGS)
    end
end

-- ============================================
-- VARIÁVEIS DE ESTADO
-- ============================================
local balls = {}
local ballConnections = {}
local reachSphere = nil
local reachGKCube = nil
local touchDebounce = {}
local lastBallUpdate = 0
local lastTouch = 0
local isMinimized = false
local iconGui = nil
local mainGui = nil
local currentTab = "reach"
local autoSkills = true
local lastSkillActivation = 0
local skillCooldown = 0.5
local activatedSkills = {}
local antiLagActive = false
local originalStates = {}
local antiLagConnection = nil
local morphGui = nil

local skillButtonNames = {
    "Shoot", "Pass", "Long", "Tackle", "Dribble", "GK", "Throw",
    "Control", "Left", "Right", "High", "Low", "Rainbow",
    "Chip", "Heel", "Volley", "Back Right", "Back Left",
    "Carry", "Fake Shot", "Drag Back", "Header", "Bicycle",
    "Shot", "Slide", "Goalkeeper", "Catch", "Punch",
    "Short Pass", "Through Ball", "Cross", "Curve",
    "Power Shot", "Precision", "First Touch", "Sprint", "Jump",
    "Chute", "Passe", "Drible", "Controle", "Defender", "Save"
}

-- ============================================
-- FUNÇÕES UTILITÁRIAS
-- ============================================
local function notify(title, text, duration)
    duration = duration or 3
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "⚡ CAFUXZ1 Hub",
            Text = text or "",
            Duration = duration
        })
    end)
end

local function tween(obj, props, time, style, dir, callback)
    time = time or 0.35
    style = style or Enum.EasingStyle.Quint
    dir = dir or Enum.EasingDirection.Out
    
    local info = TweenInfo.new(time, style, dir)
    local t = TweenService:Create(obj, info, props)
    if callback then t.Completed:Connect(callback) end
    t:Play()
    return t
end

-- ============================================
-- SISTEMA ANTI LAG (NOVO v14.1)
-- ============================================
local function saveOriginalState(obj, property, value)
    if not originalStates[obj] then
        originalStates[obj] = {}
    end
    if originalStates[obj][property] == nil then
        originalStates[obj][property] = value
    end
end

local function applyAntiLag()
    if antiLagActive then return end
    antiLagActive = true
    local Stuff = {}
    
    for _, v in next, game:GetDescendants() do
        -- Parts Material
        if CONFIG.antiLag.parts then
            if v:IsA("Part") or v:IsA("Union") or v:IsA("BasePart") then
                saveOriginalState(v, "Material", v.Material)
                v.Material = Enum.Material.SmoothPlastic
                table.insert(Stuff, v)
            end
        end
        
        -- Particles
        if CONFIG.antiLag.particles then
            if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Explosion") or v:IsA("Sparkles") or v:IsA("Fire") then
                saveOriginalState(v, "Enabled", v.Enabled)
                v.Enabled = false
                table.insert(Stuff, v)
            end
        end
        
        -- Visual Effects
        if CONFIG.antiLag.visualEffects then
            if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("SunRaysEffect") then
                saveOriginalState(v, "Enabled", v.Enabled)
                v.Enabled = false
                table.insert(Stuff, v)
            end
        end
        
        -- Textures
        if CONFIG.antiLag.textures then
            if v:IsA("Decal") or v:IsA("Texture") then
                saveOriginalState(v, "Texture", v.Texture)
                v.Texture = ""
                table.insert(Stuff, v)
            end
        end
        
        -- Sky
        if CONFIG.antiLag.sky then
            if v:IsA("Sky") then
                saveOriginalState(v, "Parent", v.Parent)
                v.Parent = nil
                table.insert(Stuff, v)
            end
        end
    end
    
    -- Full Bright
    if CONFIG.antiLag.fullBright then
        saveOriginalState(Lighting, "FogColor", Lighting.FogColor)
        saveOriginalState(Lighting, "FogEnd", Lighting.FogEnd)
        saveOriginalState(Lighting, "FogStart", Lighting.FogStart)
        saveOriginalState(Lighting, "Ambient", Lighting.Ambient)
        saveOriginalState(Lighting, "Brightness", Lighting.Brightness)
        saveOriginalState(Lighting, "ColorShift_Bottom", Lighting.ColorShift_Bottom)
        saveOriginalState(Lighting, "ColorShift_Top", Lighting.ColorShift_Top)
        saveOriginalState(Lighting, "OutdoorAmbient", Lighting.OutdoorAmbient)
        saveOriginalState(Lighting, "Outlines", Lighting.Outlines)
        
        Lighting.FogColor = Color3.fromRGB(255, 255, 255)
        Lighting.FogEnd = math.huge
        Lighting.FogStart = math.huge
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 5
        Lighting.ColorShift_Bottom = Color3.fromRGB(255, 255, 255)
        Lighting.ColorShift_Top = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Outlines = true
    end
    
    STATS.antiLagItems = #Stuff
    TestService:Message("CAFUXZ1 Anti Lag: Desativados " .. #Stuff .. " efeitos/assets")
    addLog("Anti Lag ATIVADO - " .. #Stuff .. " itens otimizados", "success")
    
    -- Monitorar novos objetos
    antiLagConnection = game.DescendantAdded:Connect(function(v)
        if not antiLagActive then return end
        
        task.wait(0.1)
        
        if CONFIG.antiLag.parts and (v:IsA("Part") or v:IsA("Union") or v:IsA("BasePart")) then
            saveOriginalState(v, "Material", v.Material)
            v.Material = Enum.Material.SmoothPlastic
        end
        
        if CONFIG.antiLag.particles and (v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Explosion") or v:IsA("Sparkles") or v:IsA("Fire")) then
            saveOriginalState(v, "Enabled", v.Enabled)
            v.Enabled = false
        end
        
        if CONFIG.antiLag.textures and (v:IsA("Decal") or v:IsA("Texture")) then
            saveOriginalState(v, "Texture", v.Texture)
            v.Texture = ""
        end
        
        if CONFIG.antiLag.sky and v:IsA("Sky") then
            saveOriginalState(v, "Parent", v.Parent)
            v.Parent = nil
        end
    end)
end

local function disableAntiLag()
    if not antiLagActive then return end
    antiLagActive = false
    
    if antiLagConnection then
        antiLagConnection:Disconnect()
        antiLagConnection = nil
    end
    
    -- Restaurar estados originais
    for obj, properties in pairs(originalStates) do
        if obj and obj.Parent then
            for prop, value in pairs(properties) do
                pcall(function()
                    if prop == "Parent" then
                        obj.Parent = value
                    else
                        obj[prop] = value
                    end
                end)
            end
        end
    end
    
    originalStates = {}
    STATS.antiLagItems = 0
    addLog("Anti Lag DESATIVADO - Efeitos restaurados", "warning")
end

-- ============================================
-- SISTEMA DE MORPH AVATAR (4 PRÉ-DEFINIDOS)
-- ============================================
local PRESET_MORPHS = {
    { name = "Miguelcalebegamer202", userId = nil, displayName = "Miguelcalebegamer202" },
    { name = "Tottxii", userId = nil, displayName = "Tottxii" },
    { name = "Feliou23", userId = nil, displayName = "Feliou23 (cb)" },
    { name = "venxcore", userId = nil, displayName = "venxcore (cb)" },
    { name = "AlissonGkBe", userId = nil, displayName = "AlissonGkBe (extra,gk)" }
}

-- Resolver UserIds dos presets
task.spawn(function()
    for _, preset in ipairs(PRESET_MORPHS) do
        task.spawn(function()
            local success, userId = pcall(function()
                return Players:GetUserIdFromNameAsync(preset.name)
            end)
            if success then
                preset.userId = userId
            end
        end)
        task.wait(0.1)
    end
end)

local function applyMorphEffect(character)
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    local particleEmitter = Instance.new("ParticleEmitter")
    particleEmitter.Texture = "rbxassetid://243098098"
    particleEmitter.Rate = 50
    particleEmitter.Speed = NumberRange.new(5, 10)
    particleEmitter.Lifetime = NumberRange.new(0.5, 1)
    particleEmitter.SpreadAngle = Vector2.new(360, 360)
    particleEmitter.Color = ColorSequence.new(Color3.fromRGB(200, 50, 50))
    particleEmitter.Parent = rootPart

    local explosion = Instance.new("Explosion")
    explosion.BlastRadius = 5
    explosion.BlastPressure = 0
    explosion.Position = rootPart.Position
    explosion.Visible = true
    explosion.Parent = workspace
    explosion.ExplosionType = Enum.ExplosionType.NoCraters

    task.spawn(function()
        task.wait(2)
        particleEmitter.Enabled = false
        task.wait(1)
        particleEmitter:Destroy()
        explosion:Destroy()
    end)
end

local function morphToUser(userId, targetName)
    if not userId then 
        notify("Char Morph", "User ID não encontrado!", 3)
        return 
    end
    
    if userId == LocalPlayer.UserId then
        notify("Char Morph", "Não pode morphar em si mesmo!", 3)
        return
    end
    
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid", 10)
    if not humanoid then 
        notify("Char Morph", "Humanoid não encontrado!", 3)
        return 
    end

    local success, desc = pcall(function()
        return Players:GetHumanoidDescriptionFromUserId(userId)
    end)
    
    if not success or not desc then
        notify("Char Morph", "Falha ao carregar avatar!", 3)
        return
    end

    -- Remove roupas atuais
    for _, obj in ipairs(character:GetChildren()) do
        if obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("ShirtGraphic") or
           obj:IsA("Accessory") or obj:IsA("BodyColors") then
            obj:Destroy()
        end
    end
    
    local head = character:FindFirstChild("Head")
    if head then
        for _, decal in ipairs(head:GetChildren()) do
            if decal:IsA("Decal") then decal:Destroy() end
        end
    end

    local applySuccess = pcall(function()
        humanoid:ApplyDescriptionClientServer(desc)
    end)

    if applySuccess then
        applyMorphEffect(character)
        STATS.morphsDone = STATS.morphsDone + 1
        notify("Char Morph", "Morph aplicado: " .. targetName .. "!", 3)
        addLog("Morph realizado: " .. targetName, "success")
    else
        notify("Char Morph", "Falha ao aplicar morph!", 3)
    end
end

-- ============================================
-- SISTEMA DE REACH GK (NOVO - CAFUXZ1)
-- ============================================
local function updateReachGK()
    if not CONFIG.reachGKShow then
        if reachGKCube then
            reachGKCube:Destroy()
            reachGKCube = nil
        end
        return
    end
    
    if not reachGKCube or not reachGKCube.Parent then
        reachGKCube = Instance.new("Part")
        reachGKCube.Name = "CAFUXZ1_ReachGK_v14"
        reachGKCube.Shape = Enum.PartType.Block
        reachGKCube.Anchored = true
        reachGKCube.CanCollide = false
        reachGKCube.Transparency = CONFIG.reachGKTransparency
        reachGKCube.Material = Enum.Material.ForceField
        reachGKCube.Color = CONFIG.reachGKColor
        reachGKCube.Parent = Workspace
        
        local selectionBox = Instance.new("SelectionBox")
        selectionBox.Name = "GKSelectionBox"
        selectionBox.Adornee = reachGKCube
        selectionBox.Color3 = CONFIG.reachGKColor
        selectionBox.LineThickness = 0.08
        selectionBox.Parent = reachGKCube
    end
    
    if RootPart and RootPart.Parent then
        reachGKCube.Size = Vector3.new(CONFIG.reachGK, CONFIG.reachGK, CONFIG.reachGK)
        reachGKCube.CFrame = RootPart.CFrame
        
        reachGKCube.Color = CONFIG.reachGKColor
        reachGKCube.Transparency = CONFIG.reachGKTransparency
        
        local selectionBox = reachGKCube:FindFirstChild("GKSelectionBox")
        if selectionBox then
            selectionBox.Color3 = CONFIG.reachGKColor
        end
    end
end

local function processReachGK()
    if not CONFIG.reachGKEnabled or not RootPart then return end
    
    local overlap = OverlapParams.new()
    overlap.FilterDescendantsInstances = {Character, reachGKCube}
    overlap.FilterType = Enum.RaycastFilterType.Exclude
    
    local objectsInCube = Workspace:GetPartBoundsInBox(
        reachGKCube.CFrame, 
        reachGKCube.Size, 
        overlap
    )
    
    local torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
    if not torso then return end
    
    for _, obj in pairs(objectsInCube) do
        if obj:IsA("BasePart") and not obj.Anchored then
            local isBall = false
            for _, name in ipairs(CONFIG.ballNames) do
                if obj.Name == name or obj.Name:find(name) then
                    isBall = true
                    break
                end
            end
            
            if isBall then
                firetouchinterest(obj, torso, 0)
                firetouchinterest(obj, torso, 1)
                STATS.gkSaves = STATS.gkSaves + 1
            end
        end
    end
end

-- ============================================
-- SISTEMA SKYBOX v1.0 (NOVO v14.3)
-- ============================================
local SkyboxDatabase = {
    -- Categoria 1: Cosmos/Noturnos (6 itens)
    { id = 14828385099, name = "Night Sky With Moon HD", category = "1" },
    { id = 109488540432307, name = "Cosmic Sky A", category = "1" },
    { id = 109844440994380, name = "Cosmic Sky B", category = "1" },
    { id = 277098164, name = "Night/Space Classic", category = "1" },
    { id = 6681543281, name = "Deep Space", category = "1" },
    { id = 77407612452946, name = "Galaxy Nebula", category = "1" },
    
    -- Categoria 2: Atmosféricos/Natureza (3 itens)
    { id = 2900944368, name = "Space/Sci-Fi Sky", category = "2" },
    { id = 290982885, name = "Atmospheric Sky", category = "2" },
    { id = 295604372, name = "Cloudy/Weather Sky", category = "2" },
    
    -- Categoria 3: Custom/Variados (4 itens)
    { id = 17124418086, name = "Custom Sky A", category = "3" },
    { id = 17480150596, name = "Custom Sky B", category = "3" },
    { id = 16553683517, name = "Custom Sky C", category = "3" },
        { id = 16553683517, name = "Custom Sky C", category = "3" },
    { id = 16887161729, name = "Custom Sky D", category = "3" }
}

local currentSkybox = nil
local originalSkybox = nil

local function saveOriginalSkybox()
    if not originalSkybox then
        for _, child in ipairs(Lighting:GetChildren()) do
            if child:IsA("Sky") then
                originalSkybox = child:Clone()
                break
            end
        end
    end
end

local function applySkybox(skyboxId)
    saveOriginalSkybox()
    
    -- Remove skybox atual
    for _, child in ipairs(Lighting:GetChildren()) do
        if child:IsA("Sky") then
            child:Destroy()
        end
    end
    
    -- Cria novo skybox
    local sky = Instance.new("Sky")
    sky.Name = "CAFUXZ1_Skybox_v14"
    sky.SkyboxBk = "rbxassetid://" .. skyboxId
    sky.SkyboxDn = "rbxassetid://" .. skyboxId
    sky.SkyboxFt = "rbxassetid://" .. skyboxId
    sky.SkyboxLf = "rbxassetid://" .. skyboxId
    sky.SkyboxRt = "rbxassetid://" .. skyboxId
    sky.SkyboxUp = "rbxassetid://" .. skyboxId
    sky.Parent = Lighting
    
    currentSkybox = skyboxId
    addLog("Skybox aplicado: ID " .. skyboxId, "success")
    notify("Skybox System", "Céu alterado com sucesso!", 2)
end

local function restoreOriginalSkybox()
    for _, child in ipairs(Lighting:GetChildren()) do
        if child:IsA("Sky") and child.Name == "CAFUXZ1_Skybox_v14" then
            child:Destroy()
        end
    end
    
    if originalSkybox then
        originalSkybox.Parent = Lighting
        originalSkybox = nil
    end
    
    currentSkybox = nil
    addLog("Skybox restaurado ao original", "info")
end

-- ============================================
-- SISTEMA DE DETECÇÃO DE BOLAS (CADUXX137)
-- ============================================
local function isBall(obj)
    if not obj or not obj:IsA("BasePart") then return false end
    
    for _, name in ipairs(CONFIG.ballNames) do
        if obj.Name == name or obj.Name:find(name) then
            return true
        end
    end
    
    return false
end

local function scanForBalls()
    local currentTime = tick()
    if currentTime - lastBallUpdate < CONFIG.scanCooldown then return end
    lastBallUpdate = currentTime
    
    local newBalls = {}
    local ballCount = 0
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if isBall(obj) then
            ballCount = ballCount + 1
            if not balls[obj] then
                balls[obj] = {
                    obj = obj,
                    lastTouch = 0,
                    touchCount = 0
                }
                
                if CONFIG.particleEffects then
                    local attachment = Instance.new("Attachment")
                    attachment.Name = "CAFUXZ1_BallTrack"
                    attachment.Parent = obj
                    
                    local particle = Instance.new("ParticleEmitter")
                    particle.Texture = "rbxassetid://243660364"
                    particle.Rate = 20
                    particle.Lifetime = NumberRange.new(0.5, 1)
                    particle.Speed = NumberRange.new(2, 5)
                    particle.SpreadAngle = Vector2.new(180, 180)
                    particle.Color = ColorSequence.new(CONFIG.accentColor)
                    particle.Size = NumberSequence.new(0.5, 0)
                    particle.Parent = attachment
                end
            end
            newBalls[obj] = balls[obj]
        end
    end
    
    -- Limpa bolas que não existem mais
    for obj, data in pairs(balls) do
        if not newBalls[obj] then
            if data.attachment then
                data.attachment:Destroy()
            end
            balls[obj] = nil
        end
    end
    
    if ballCount > 0 then
        addLog("Scan: " .. ballCount .. " bolas detectadas", "info")
    end
end

-- ============================================
-- SISTEMA DE REACH PRINCIPAL
-- ============================================
local function updateReachSphere()
    if not CONFIG.showReachSphere then
        if reachSphere then
            reachSphere:Destroy()
            reachSphere = nil
        end
        return
    end
    
    if not reachSphere or not reachSphere.Parent then
        reachSphere = Instance.new("Part")
        reachSphere.Name = "CAFUXZ1_ReachSphere_v14"
        reachSphere.Shape = Enum.PartType.Ball
        reachSphere.Anchored = true
        reachSphere.CanCollide = false
        reachSphere.Transparency = 0.9
        reachSphere.Material = Enum.Material.ForceField
        reachSphere.Color = CONFIG.primary
        reachSphere.Parent = Workspace
        
        local selectionBox = Instance.new("SelectionBox")
        selectionBox.Name = "ReachSelectionBox"
        selectionBox.Adornee = reachSphere
        selectionBox.Color3 = CONFIG.primary
        selectionBox.LineThickness = 0.05
        selectionBox.Parent = reachSphere
        
        if CONFIG.particleEffects then
            local attachment = Instance.new("Attachment")
            attachment.Parent = reachSphere
            
            local particle = Instance.new("ParticleEmitter")
            particle.Texture = "rbxassetid://243660364"
            particle.Rate = 50
            particle.Lifetime = NumberRange.new(1, 2)
            particle.Speed = NumberRange.new(0.5, 2)
            particle.SpreadAngle = Vector2.new(180, 180)
            particle.Color = ColorSequence.new(CONFIG.primary)
            particle.Size = NumberSequence.new(0.3, 0)
            particle.Parent = attachment
        end
    end
    
    if RootPart and RootPart.Parent then
        reachSphere.Size = Vector3.new(CONFIG.reach * 2, CONFIG.reach * 2, CONFIG.reach * 2)
        reachSphere.CFrame = RootPart.CFrame
    end
end

local function processAutoTouch()
    if not CONFIG.autoTouch or not RootPart then return end
    
    local now = tick()
    if now - lastTouch < 0.1 then return end
    
    local touchParts = {}
    
    if CONFIG.fullBodyTouch then
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanTouch then
                table.insert(touchParts, part)
            end
        end
    else
        table.insert(touchParts, RootPart)
    end
    
    for ballObj, ballData in pairs(balls) do
        if ballObj and ballObj.Parent then
            local distance = (ballObj.Position - RootPart.Position).Magnitude
            
            if distance <= CONFIG.reach then
                if now - ballData.lastTouch > 0.5 then
                    for _, touchPart in ipairs(touchParts) do
                        firetouchinterest(ballObj, touchPart, 0)
                        firetouchinterest(ballObj, touchPart, 1)
                    end
                    
                    ballData.lastTouch = now
                    ballData.touchCount = ballData.touchCount + 1
                    lastTouch = now
                    STATS.totalTouches = STATS.totalTouches + 1
                    STATS.ballsTouched = STATS.ballsTouched + 1
                    
                    -- Double/Triple touch
                    if CONFIG.autoSecondTouch then
                        task.delay(0.15, function()
                            for _, touchPart in ipairs(touchParts) do
                                firetouchinterest(ballObj, touchPart, 0)
                                firetouchinterest(ballObj, touchPart, 1)
                            end
                        end)
                    end
                end
            end
        end
    end
end

-- ============================================
-- SISTEMA DE AUTO-SKILLS
-- ============================================
local function activateSkillButton()
    if not autoSkills then return end
    
    local now = tick()
    if now - lastSkillActivation < skillCooldown then return end
    
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return end
    
    for _, gui in ipairs(playerGui:GetDescendants()) do
        if gui:IsA("TextButton") or gui:IsA("ImageButton") then
            local buttonText = gui.Text or gui.Name
            
            for _, skillName in ipairs(skillButtonNames) do
                if buttonText:find(skillName) or gui.Name:find(skillName) then
                    if not activatedSkills[gui] or (now - activatedSkills[gui] > 1) then
                        pcall(function()
                            gui.MouseButton1Click:Fire()
                        end)
                        activatedSkills[gui] = now
                        lastSkillActivation = now
                        STATS.skillsActivated = STATS.skillsActivated + 1
                        return
                    end
                end
            end
        end
    end
end

-- ============================================
-- INTERFACE WINDUI - CAFUXZ1 HUB
-- ============================================
local function createWindUI()
    -- ScreenGui principal
    mainGui = Instance.new("ScreenGui")
    mainGui.Name = "CAFUXZ1_Hub_v14"
    mainGui.ResetOnSpawn = false
    mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    mainGui.Parent = CoreGui
    
    -- Frame principal com glassmorphism
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, CONFIG.width, 0, CONFIG.height)
    mainFrame.Position = UDim2.new(0.5, -CONFIG.width/2, 0.5, -CONFIG.height/2)
    mainFrame.BackgroundColor3 = CONFIG.bgGlass
    mainFrame.BackgroundTransparency = 0.2
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = mainGui
    
    -- Cantos arredondados
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    -- Stroke/Borda
    local stroke = Instance.new("UIStroke")
    stroke.Color = CONFIG.primary
    stroke.Thickness = 2
    stroke.Transparency = 0.5
    stroke.Parent = mainFrame
    
    -- Gradiente de fundo
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, CONFIG.bgDark),
        ColorSequenceKeypoint.new(1, CONFIG.bgCard)
    })
    gradient.Rotation = 45
    gradient.Parent = mainFrame
    
    -- Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, CONFIG.sidebarWidth, 1, 0)
    sidebar.BackgroundColor3 = CONFIG.bgCard
    sidebar.BackgroundTransparency = 0.3
    sidebar.BorderSizePixel = 0
    sidebar.Parent = mainFrame
    
    local sidebarCorner = Instance.new("UICorner")
    sidebarCorner.CornerRadius = UDim.new(0, 12)
    sidebarCorner.Parent = sidebar
    
    -- Logo/Título na sidebar
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, 0, 0, 50)
    titleLabel.Position = UDim2.new(0, 0, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "⚡"
    titleLabel.TextColor3 = CONFIG.primary
    titleLabel.TextSize = 32
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = sidebar
    
    local versionLabel = Instance.new("TextLabel")
    versionLabel.Name = "Version"
    versionLabel.Size = UDim2.new(1, 0, 0, 20)
    versionLabel.Position = UDim2.new(0, 0, 0, 55)
    versionLabel.BackgroundTransparency = 1
    versionLabel.Text = "v14.3"
    versionLabel.TextColor3 = CONFIG.textMuted
    versionLabel.TextSize = 12
    versionLabel.Font = Enum.Font.Gotham
    versionLabel.Parent = sidebar
    
    -- Botões de navegação
    local tabs = {
        {name = "reach", icon = "⚽", label = "Reach"},
        {name = "gk", icon = "🥅", label = "GK"},
        {name = "visual", icon = "👁️", label = "Visual"},
        {name = "char", icon = "👤", label = "Char"},
        {name = "sky", icon = "☁️", label = "Sky"},
        {name = "stats", icon = "📊", label = "Stats"},
        {name = "logs", icon = "📝", label = "Logs"}
    }
    
    local tabButtons = {}
    local contentFrames = {}
    
    for i, tab in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Name = tab.name .. "Btn"
        btn.Size = UDim2.new(0.9, 0, 0, 40)
        btn.Position = UDim2.new(0.05, 0, 0, 90 + (i-1) * 45)
        btn.BackgroundColor3 = CONFIG.bgElevated
        btn.BackgroundTransparency = 0.5
        btn.Text = tab.icon .. " " .. tab.label
        btn.TextColor3 = CONFIG.textSecondary
        btn.TextSize = 11
        btn.Font = Enum.Font.GothamBold
        btn.Parent = sidebar
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn
        
        tabButtons[tab.name] = btn
        
        -- Frame de conteúdo
        local content = Instance.new("ScrollingFrame")
        content.Name = tab.name .. "Content"
        content.Size = UDim2.new(1, -CONFIG.sidebarWidth - 10, 1, -60)
        content.Position = UDim2.new(0, CONFIG.sidebarWidth + 5, 0, 50)
        content.BackgroundTransparency = 1
        content.BorderSizePixel = 0
        content.ScrollBarThickness = 4
        content.ScrollBarImageColor3 = CONFIG.primary
        content.Visible = false
        content.Parent = mainFrame
        
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 10)
        layout.Parent = content
        
        contentFrames[tab.name] = content
    end
    
    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, -CONFIG.sidebarWidth, 0, 40)
    header.Position = UDim2.new(0, CONFIG.sidebarWidth, 0, 5)
    header.BackgroundTransparency = 1
    header.Parent = mainFrame
    
    local headerTitle = Instance.new("TextLabel")
    headerTitle.Name = "HeaderTitle"
    headerTitle.Size = UDim2.new(0.6, 0, 1, 0)
    headerTitle.Position = UDim2.new(0, 15, 0, 0)
    headerTitle.BackgroundTransparency = 1
    headerTitle.Text = "CAFUXZ1 Hub v14.3 Ultimate"
    headerTitle.TextColor3 = CONFIG.textPrimary
    headerTitle.TextSize = 18
    headerTitle.Font = Enum.Font.GothamBold
    headerTitle.TextXAlignment = Enum.TextXAlignment.Left
    headerTitle.Parent = header
    
    -- Botões de controle (minimizar, fechar)
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "Minimize"
    minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    minimizeBtn.Position = UDim2.new(1, -70, 0, 5)
    minimizeBtn.BackgroundColor3 = CONFIG.warning
    minimizeBtn.Text = "−"
    minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
    minimizeBtn.TextSize = 20
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.Parent = header
    
    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 6)
    minCorner.Parent = minimizeBtn
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "Close"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = CONFIG.danger
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextSize = 20
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = header
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeBtn
    
    -- Função para criar seções
    local function createSection(parent, title)
        local section = Instance.new("Frame")
        section.Size = UDim2.new(0.95, 0, 0, 0)
        section.AutomaticSize = Enum.AutomaticSize.Y
        section.BackgroundColor3 = CONFIG.bgCard
        section.BackgroundTransparency = 0.4
        section.BorderSizePixel = 0
        section.Parent = parent
        
        local sectionCorner = Instance.new("UICorner")
        sectionCorner.CornerRadius = UDim.new(0, 8)
        sectionCorner.Parent = section
        
        local sectionTitle = Instance.new("TextLabel")
        sectionTitle.Size = UDim2.new(1, -20, 0, 25)
        sectionTitle.Position = UDim2.new(0, 10, 0, 5)
        sectionTitle.BackgroundTransparency = 1
        sectionTitle.Text = "◆ " .. title
        sectionTitle.TextColor3 = CONFIG.primary
        sectionTitle.TextSize = 14
        sectionTitle.Font = Enum.Font.GothamBold
        sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
        sectionTitle.Parent = section
        
        local sectionContent = Instance.new("Frame")
        sectionContent.Name = "Content"
        sectionContent.Size = UDim2.new(1, -20, 0, 0)
        sectionContent.Position = UDim2.new(0, 10, 0, 30)
        sectionContent.AutomaticSize = Enum.AutomaticSize.Y
        sectionContent.BackgroundTransparency = 1
        sectionContent.Parent = section
        
        local sectionLayout = Instance.new("UIListLayout")
        sectionLayout.Padding = UDim.new(0, 8)
        sectionLayout.Parent = sectionContent
        
        return section, sectionContent
    end
    
    -- Função para criar toggle
    local function createToggle(parent, text, default, callback)
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Size = UDim2.new(1, 0, 0, 35)
        toggleFrame.BackgroundTransparency = 1
        toggleFrame.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = CONFIG.textSecondary
        label.TextSize = 13
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = toggleFrame
        
        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Size = UDim2.new(0, 50, 0, 25)
        toggleBtn.Position = UDim2.new(1, -50, 0.5, -12.5)
        toggleBtn.BackgroundColor3 = default and CONFIG.success or CONFIG.bgElevated
        toggleBtn.Text = default and "ON" or "OFF"
        toggleBtn.TextColor3 = Color3.new(1, 1, 1)
        toggleBtn.TextSize = 12
        toggleBtn.Font = Enum.Font.GothamBold
        toggleBtn.Parent = toggleFrame
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 12)
        toggleCorner.Parent = toggleBtn
        
        local enabled = default
        
        toggleBtn.MouseButton1Click:Connect(function()
            enabled = not enabled
            toggleBtn.BackgroundColor3 = enabled and CONFIG.success or CONFIG.bgElevated
            toggleBtn.Text = enabled and "ON" or "OFF"
            if callback then callback(enabled) end
        end)
        
        return toggleFrame, toggleBtn
    end
    
    -- Função para criar slider
    local function createSlider(parent, text, min, max, default, callback)
        local sliderFrame = Instance.new("Frame")
        sliderFrame.Size = UDim2.new(1, 0, 0, 50)
        sliderFrame.BackgroundTransparency = 1
        sliderFrame.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.6, 0, 0, 20)
        label.BackgroundTransparency = 1
        label.Text = text .. ": " .. default
        label.TextColor3 = CONFIG.textSecondary
        label.TextSize = 13
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = sliderFrame
        
        local valueLabel = label
        
        local sliderBg = Instance.new("Frame")
        sliderBg.Name = "SliderBg"
        sliderBg.Size = UDim2.new(1, 0, 0, 8)
        sliderBg.Position = UDim2.new(0, 0, 0, 30)
        sliderBg.BackgroundColor3 = CONFIG.bgElevated
        sliderBg.BorderSizePixel = 0
        sliderBg.Parent = sliderFrame
        
        local sliderBgCorner = Instance.new("UICorner")
        sliderBgCorner.CornerRadius = UDim.new(0, 4)
        sliderBgCorner.Parent = sliderBg
        
        local sliderFill = Instance.new("Frame")
        sliderFill.Name = "SliderFill"
        sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        sliderFill.BackgroundColor3 = CONFIG.primary
        sliderFill.BorderSizePixel = 0
        sliderFill.Parent = sliderBg
        
        local sliderFillCorner = Instance.new("UICorner")
        sliderFillCorner.CornerRadius = UDim.new(0, 4)
        sliderFillCorner.Parent = sliderFill
        
        local sliderKnob = Instance.new("TextButton")
        sliderKnob.Name = "Knob"
        sliderKnob.Size = UDim2.new(0, 16, 0, 16)
        sliderKnob.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
        sliderKnob.BackgroundColor3 = Color3.new(1, 1, 1)
        sliderKnob.Text = ""
        sliderKnob.Parent = sliderBg
        
        local knobCorner = Instance.new("UICorner")
        knobCorner.CornerRadius = UDim.new(1, 0)
        knobCorner.Parent = sliderKnob
        
        local dragging = false
        
        local function updateSlider(input)
            local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (pos * (max - min)))
            
            sliderFill.Size = UDim2.new(pos, 0, 1, 0)
            sliderKnob.Position = UDim2.new(pos, -8, 0.5, -8)
            valueLabel.Text = text .. ": " .. value
            
            if callback then callback(value) end
        end
        
        sliderKnob.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                updateSlider(input)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        
        sliderBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                updateSlider(input)
            end
        end)
        
        return sliderFrame
    end
    
    -- Função para criar botão
    local function createButton(parent, text, color, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 35)
        btn.BackgroundColor3 = color or CONFIG.primary
        btn.Text = text
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.TextSize = 13
        btn.Font = Enum.Font.GothamBold
        btn.Parent = parent
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            tween(btn, {Size = UDim2.new(0.95, 0, 0, 33)}, 0.1)
            task.wait(0.1)
            tween(btn, {Size = UDim2.new(1, 0, 0, 35)}, 0.1)
            if callback then callback() end
        end)
        
        return btn
    end
    
    -- POPULAR ABAS
    
    -- ABA REACH
    local reachSection, reachContent = createSection(contentFrames.reach, "Configurações de Reach")
    
    createToggle(reachContent, "Auto Touch", CONFIG.autoTouch, function(val)
        CONFIG.autoTouch = val
        addLog("Auto Touch " .. (val and "ativado" or "desativado"), "info")
    end)
    
    createToggle(reachContent, "Full Body Touch", CONFIG.fullBodyTouch, function(val)
        CONFIG.fullBodyTouch = val
        addLog("Full Body Touch " .. (val and "ativado" or "desativado"), "info")
    end)
    
    createToggle(reachContent, "Double/Triple Touch", CONFIG.autoSecondTouch, function(val)
        CONFIG.autoSecondTouch = val
    end)
    
    createToggle(reachContent, "Mostrar Esfera", CONFIG.showReachSphere, function(val)
        CONFIG.showReachSphere = val
        if not val and reachSphere then
            reachSphere:Destroy()
            reachSphere = nil
        end
    end)
    
    createSlider(reachContent, "Alcance Reach", 5, 50, CONFIG.reach, function(val)
        CONFIG.reach = val
        if val > STATS.peakReach then STATS.peakReach = val end
    end)
    
    createSlider(reachContent, "Cooldown Scan", 0.5, 5, CONFIG.scanCooldown, function(val)
        CONFIG.scanCooldown = val
    end)
    
    -- ABA GK (Goleiro)
    local gkSection, gkContent = createSection(contentFrames.gk, "Sistema GK v14")
    
    createToggle(gkContent, "Ativar Reach GK", CONFIG.reachGKEnabled, function(val)
        CONFIG.reachGKEnabled = val
        if not val and reachGKCube then
            reachGKCube:Destroy()
            reachGKCube = nil
        end
        addLog("Reach GK " .. (val and "ativado" or "desativado"), "warning")
    end)
    
    createToggle(gkContent, "Mostrar Cubo GK", CONFIG.reachGKShow, function(val)
        CONFIG.reachGKShow = val
    end)
    
    createSlider(gkContent, "Alcance GK", 10, 60, CONFIG.reachGK, function(val)
        CONFIG.reachGK = val
    end)
    
    createSlider(gkContent, "Transparência", 0, 0.9, CONFIG.reachGKTransparency, function(val)
        CONFIG.reachGKTransparency = val
    end)
    
    -- ABA VISUAL
    local visualSection, visualContent = createSection(contentFrames.visual, "Anti Lag System v14")
    
    createToggle(visualContent, "Ativar Anti Lag", CONFIG.antiLag.enabled, function(val)
        CONFIG.antiLag.enabled = val
        if val then applyAntiLag() else disableAntiLag() end
    end)
    
    createToggle(visualContent, "Otimizar Texturas", CONFIG.antiLag.textures, function(val)
        CONFIG.antiLag.textures = val
    end)
    
    createToggle(visualContent, "Remover Partículas", CONFIG.antiLag.particles, function(val)
        CONFIG.antiLag.particles = val
    end)
    
    createToggle(visualContent, "Remover Efeitos Visuais", CONFIG.antiLag.visualEffects, function(val)
        CONFIG.antiLag.visualEffects = val
    end)
    
    createToggle(visualContent, "Full Bright", CONFIG.antiLag.fullBright, function(val)
        CONFIG.antiLag.fullBright = val
    end)
    
    -- ABA CHAR (MORPH)
    local charSection, charContent = createSection(contentFrames.char, "Morph Avatar v14")
    
    -- Input para username customizado
    local usernameFrame = Instance.new("Frame")
    usernameFrame.Size = UDim2.new(1, 0, 0, 60)
    usernameFrame.BackgroundTransparency = 1
    usernameFrame.Parent = charContent
    
    local usernameLabel = Instance.new("TextLabel")
    usernameLabel.Size = UDim2.new(1, 0, 0, 20)
    usernameLabel.BackgroundTransparency = 1
    usernameLabel.Text = "Username para Morph:"
    usernameLabel.TextColor3 = CONFIG.textSecondary
    usernameLabel.TextSize = 12
    usernameLabel.Font = Enum.Font.Gotham
    usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    usernameLabel.Parent = usernameFrame
    
    local usernameInput = Instance.new("TextBox")
    usernameInput.Size = UDim2.new(1, 0, 0, 30)
    usernameInput.Position = UDim2.new(0, 0, 0, 25)
    usernameInput.BackgroundColor3 = CONFIG.bgElevated
    usernameInput.Text = ""
    usernameInput.PlaceholderText = "Digite o username..."
    usernameInput.TextColor3 = CONFIG.textPrimary
    usernameInput.PlaceholderColor3 = CONFIG.textMuted
    usernameInput.TextSize = 13
    usernameInput.Font = Enum.Font.Gotham
    usernameInput.Parent = usernameFrame
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = usernameInput
    
    createButton(charContent, "🎭 Aplicar Morph", CONFIG.primary, function()
        local username = usernameInput.Text
        if username and username ~= "" then
            task.spawn(function()
                local success, userId = pcall(function()
                    return Players:GetUserIdFromNameAsync(username)
                end)
                if success then
                    morphToUser(userId, username)
                else
                    notify("Morph", "Username não encontrado!", 3)
                end
            end)
        end
    end)
    
    createButton(charContent, "🎲 Morph Aleatório", CONFIG.secondary, function()
        local validPresets = {}
        for _, preset in ipairs(PRESET_MORPHS) do
            if preset.userId then table.insert(validPresets, preset) end
        end
        
        if #validPresets > 0 then
            local randomPreset = validPresets[math.random(1, #validPresets)]
            morphToUser(randomPreset.userId, randomPreset.displayName)
        else
            notify("Morph", "Nenhum preset disponível ainda!", 3)
        end
    end)
    
    -- Presets
    local presetsLabel = Instance.new("TextLabel")
    presetsLabel.Size = UDim2.new(1, 0, 0, 25)
    presetsLabel.BackgroundTransparency = 1
    presetsLabel.Text = "◆ Presets Rápidos"
    presetsLabel.TextColor3 = CONFIG.accent
    presetsLabel.TextSize = 13
    presetsLabel.Font = Enum.Font.GothamBold
    presetsLabel.TextXAlignment = Enum.TextXAlignment.Left
    presetsLabel.Parent = charContent
    
    for _, preset in ipairs(PRESET_MORPHS) do
        createButton(charContent, "👤 " .. preset.displayName, CONFIG.bgElevated, function()
            if preset.userId then
                morphToUser(preset.userId, preset.displayName)
            else
                notify("Morph", "Carregando ID... Tente novamente em instantes.", 2)
            end
        end)
    end
    
    createButton(charContent, "↩️ Resetar Avatar", CONFIG.danger, function()
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid:Destroy()
                LocalPlayer.Character = nil
                LocalPlayer.Character = character
            end
        end
        addLog("Avatar resetado", "warning")
    end)
    
    -- ABA SKYBOX
    local skySection, skyContent = createSection(contentFrames.sky, "Skybox System v1.0")
    
    local skyLabel = Instance.new("TextLabel")
    skyLabel.Size = UDim2.new(1, 0, 0, 30)
    skyLabel.BackgroundTransparency = 1
    skyLabel.Text = "Selecione uma categoria:"
    skyLabel.TextColor3 = CONFIG.textSecondary
    skyLabel.TextSize = 13
    skyLabel.Font = Enum.Font.Gotham
    skyLabel.Parent = skyContent
    
    -- Categorias
    local categories = {
        {name = "🌌 Cosmos/Noturnos", cat = "1"},
        {name = "🌅 Atmosféricos", cat = "2"},
        {name = "🎨 Custom/Variados", cat = "3"}
    }
    
    for _, category in ipairs(categories) do
        local catBtn = createButton(skyContent, category.name, CONFIG.bgElevated, function()
            -- Mostrar skyboxes da categoria
            for _, child in ipairs(skyContent:GetChildren()) do
                if child.Name:find("Skybox_") then child:Destroy() end
            end
            
            for _, skybox in ipairs(SkyboxDatabase) do
                if skybox.category == category.cat then
                    createButton(skyContent, "☁️ " .. skybox.name, CONFIG.info, function()
                        applySkybox(skybox.id)
                    end).Name = "Skybox_" .. skybox.id
                end
            end
        end)
        catBtn.Name = "Category_" .. category.cat
    end
    
    createButton(skyContent, "↩️ Restaurar Céu Original", CONFIG.danger, function()
        restoreOriginalSkybox()
    end)
    
    -- ABA STATS
    local statsSection, statsContent = createSection(contentFrames.stats, "Estatísticas da Sessão")
    
    local statsLabels = {}
    local statItems = {
        {key = "totalTouches", label = "Toques Totais"},
        {key = "ballsTouched", label = "Bolas Tocadas"},
        {key = "gkSaves", label = "Defesas GK"},
        {key = "skillsActivated", label = "Skills Ativadas"},
        {key = "morphsDone", label = "Morphs Realizados"},
        {key = "antiLagItems", label = "Itens Otimizados"},
        {key = "peakReach", label = "Alcance Máximo"}
    }
    
    for _, item in ipairs(statItems) do
        local statFrame = Instance.new("Frame")
        statFrame.Size = UDim2.new(1, 0, 0, 30)
        statFrame.BackgroundTransparency = 1
        statFrame.Parent = statsContent
        
        local statLabel = Instance.new("TextLabel")
        statLabel.Size = UDim2.new(0.6, 0, 1, 0)
        statLabel.BackgroundTransparency = 1
        statLabel.Text = item.label .. ":"
        statLabel.TextColor3 = CONFIG.textSecondary
        statLabel.TextSize = 13
        statLabel.Font = Enum.Font.Gotham
        statLabel.TextXAlignment = Enum.TextXAlignment.Left
        statLabel.Parent = statFrame
        
        local statValue = Instance.new("TextLabel")
        statValue.Name = "Value"
        statValue.Size = UDim2.new(0.4, 0, 1, 0)
        statValue.Position = UDim2.new(0.6, 0, 0, 0)
        statValue.BackgroundTransparency = 1
        statValue.Text = "0"
        statValue.TextColor3 = CONFIG.primary
        statValue.TextSize = 14
        statValue.Font = Enum.Font.GothamBold
        statValue.TextXAlignment = Enum.TextXAlignment.Right
        statValue.Parent = statFrame
        
        statsLabels[item.key] = statValue
    end
    
    -- Atualizar stats
    task.spawn(function()
        while mainGui and mainGui.Parent do
            for key, label in pairs(statsLabels) do
                label.Text = tostring(STATS[key] or 0)
            end
            task.wait(1)
        end
    end)
    
    -- ABA LOGS
    local logsSection, logsContent = createSection(contentFrames.logs, "System Logs")
    
    local logsScrolling = Instance.new("ScrollingFrame")
    logsScrolling.Name = "LogsList"
    logsScrolling.Size = UDim2.new(1, 0, 0, 250)
    logsScrolling.BackgroundColor3 = CONFIG.bgDark
    logsScrolling.BackgroundTransparency = 0.5
    logsScrolling.BorderSizePixel = 0
    logsScrolling.ScrollBarThickness = 4
    logsScrolling.Parent = logsContent
    
    local logsCorner = Instance.new("UICorner")
    logsCorner.CornerRadius = UDim.new(0, 6)
    logsCorner.Parent = logsScrolling
    
    local logsLayout = Instance.new("UIListLayout")
    logsLayout.Padding = UDim.new(0, 2)
    logsLayout.Parent = logsScrolling
    
    -- Função para atualizar logs
    local function updateLogs()
        for _, child in ipairs(logsScrolling:GetChildren()) do
            if child:IsA("TextLabel") then child:Destroy() end
        end
        
        for _, log in ipairs(LOGS) do
            local logLabel = Instance.new("TextLabel")
            logLabel.Size = UDim2.new(1, -10, 0, 20)
            logLabel.Position = UDim2.new(0, 5, 0, 0)
            logLabel.BackgroundTransparency = 1
            
            local color = CONFIG.textSecondary
            if log.type == "success" then color = CONFIG.success
            elseif log.type == "warning" then color = CONFIG.warning
            elseif log.type == "error" then color = CONFIG.danger end
            
            logLabel.Text = string.format("[%s] %s", log.time, log.message)
            logLabel.TextColor3 = color
            logLabel.TextSize = 11
            logLabel.Font = Enum.Font.Code
            logLabel.TextXAlignment = Enum.TextXAlignment.Left
            logLabel.Parent = logsScrolling
        end
        
        logsScrolling.CanvasSize = UDim2.new(0, 0, 0, #LOGS * 22)
    end
    
    -- Atualizar logs periodicamente
    task.spawn(function()
        while mainGui and mainGui.Parent do
            updateLogs()
            task.wait(0.5)
        end
    end)
    
    -- SISTEMA DE NAVEGAÇÃO
    local function switchTab(tabName)
        currentTab = tabName
        
        for name, btn in pairs(tabButtons) do
            if name == tabName then
                tween(btn, {BackgroundColor3 = CONFIG.primary, TextColor3 = CONFIG.textPrimary}, 0.2)
            else
                tween(btn, {BackgroundColor3 = CONFIG.bgElevated, TextColor3 = CONFIG.textSecondary}, 0.2)
            end
        end
        
        for name, frame in pairs(contentFrames) do
            frame.Visible = (name == tabName)
        end
        
        addLog("Switched to tab: " .. tabName, "info")
    end
    
    -- Conectar botões
    for name, btn in pairs(tabButtons) do
        btn.MouseButton1Click:Connect(function()
            switchTab(name)
        end)
    end
    
    -- Iniciar na primeira aba
    switchTab("reach")
    
    -- Minimizar/Restaurar
    local function minimize()
        isMinimized = true
        tween(mainFrame, {Size = UDim2.new(0, CONFIG.width, 0, 50)}, 0.3)
        contentFrames[currentTab].Visible = false
        sidebar.Visible = false
        headerTitle.Visible = false
    end
    
    local function restore()
        isMinimized = false
        tween(mainFrame, {Size = UDim2.new(0, CONFIG.width, 0, CONFIG.height)}, 0.3)
        task.delay(0.3, function()
            sidebar.Visible = true
            headerTitle.Visible = true
            contentFrames[currentTab].Visible = true
        end)
    end
    
    minimizeBtn.MouseButton1Click:Connect(function()
        if isMinimized then restore() else minimize() end
    end)
    
    -- Fechar
    closeBtn.MouseButton1Click:Connect(function()
        tween(mainFrame, {Position = UDim2.new(0.5, -CONFIG.width/2, 1, 0)}, 0.3, nil, nil, function()
            mainGui:Destroy()
            if reachSphere then reachSphere:Destroy() end
            if reachGKCube then reachGKCube:Destroy() end
            disableAntiLag()
        end)
    end)
    
    -- Drag functionality
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil
    
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    header.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    -- Criar ícone flutuante quando minimizado
    local function createIconGui()
        iconGui = Instance.new("ScreenGui")
        iconGui.Name = "CAFUXZ1_Icon_v14"
        iconGui.ResetOnSpawn = false
        iconGui.Parent = CoreGui
        
        local iconBtn = Instance.new("ImageButton")
        iconBtn.Name = "IconButton"
        iconBtn.Size = UDim2.new(0, 50, 0, 50)
        iconBtn.Position = UDim2.new(0, 20, 0.5, -25)
        iconBtn.BackgroundColor3 = CONFIG.primary
        iconBtn.Image = CONFIG.iconImage
        iconBtn.Parent = iconGui
        
        local iconCorner = Instance.new("UICorner")
        iconCorner.CornerRadius = UDim.new(1, 0)
        iconCorner.Parent = iconBtn
        
        local iconStroke = Instance.new("UIStroke")
        iconStroke.Color = Color3.new(1, 1, 1)
        iconStroke.Thickness = 2
        iconStroke.Parent = iconBtn
        
        -- Glow effect
        local glow = Instance.new("ImageLabel")
        glow.Name = "Glow"
        glow.Size = UDim2.new(1.5, 0, 1.5, 0)
        glow.Position = UDim2.new(-0.25, 0, -0.25, 0)
        glow.BackgroundTransparency = 1
        glow.Image = "rbxassetid://243660364"
        glow.ImageColor3 = CONFIG.primary
        glow.ImageTransparency = 0.8
        glow.Parent = iconBtn
        
        iconBtn.MouseButton1Click:Connect(function()
            if mainGui and mainGui.Parent then
                restore()
                mainFrame.Visible = true
            else
                createWindUI()
            end
        end)
        
        -- Drag para o ícone também
        local iconDragging = false
        local iconDragStart = nil
        local iconStartPos = nil
        
        iconBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                iconDragging = true
                iconDragStart = input.Position
                iconStartPos = iconBtn.Position
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if iconDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - iconDragStart
                iconBtn.Position = UDim2.new(iconStartPos.X.Scale, iconStartPos.X.Offset + delta.X, iconStartPos.Y.Scale, iconStartPos.Y.Offset + delta.Y)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                iconDragging = false
            end
        end)
    end
    
    createIconGui()
    
    addLog("CAFUXZ1 Hub v14.3 iniciado com sucesso!", "success")
    notify("CAFUXZ1 Hub v14.3", "Sistema carregado! Pressione F1-F7 para atalhos.", 5)
end

-- ============================================
-- LOOP PRINCIPAL
-- ============================================
local function mainLoop()
    while true do
        if Character and Humanoid and RootPart then
            -- Atualizar referências
            Character = LocalPlayer.Character
            Humanoid = Character:FindFirstChild("Humanoid")
            RootPart = Character:FindFirstChild("HumanoidRootPart")
            
            -- Scan de bolas
            scanForBalls()
            
            -- Atualizar reach sphere
            updateReachSphere()
            
            -- Processar auto touch
            processAutoTouch()
            
            -- Processar GK
            if CONFIG.reachGKEnabled then
                updateReachGK()
                processReachGK()
            end
            
            -- Auto skills
            activateSkillButton()
            
            -- Atualizar stats
            local now = tick()
            if now - STATS.lastUpdate >= 60 then
                STATS.touchesPerMinute = math.floor(STATS.totalTouches / ((now - STATS.sessionStart) / 60))
                STATS.lastUpdate = now
            end
        end
        
        task.wait(0.03) -- ~30 FPS
    end
end

-- ============================================
-- ATALHOS DE TECLADO
-- ============================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F1 then
        CONFIG.autoTouch = not CONFIG.autoTouch
        notify("Auto Touch", CONFIG.autoTouch and "ATIVADO" or "DESATIVADO", 2)
    elseif input.KeyCode == Enum.KeyCode.F2 then
        CONFIG.showReachSphere = not CONFIG.showReachSphere
        if not CONFIG.showReachSphere and reachSphere then
            reachSphere:Destroy()
            reachSphere = nil
        end
        notify("Reach Sphere", CONFIG.showReachSphere and "VISÍVEL" or "OCULTA", 2)
    elseif input.KeyCode == Enum.KeyCode.F3 then
        CONFIG.reachGKEnabled = not CONFIG.reachGKEnabled
        if not CONFIG.reachGKEnabled and reachGKCube then
            reachGKCube:Destroy()
            reachGKCube = nil
        end
        notify("Reach GK", CONFIG.reachGKEnabled and "ATIVADO" or "DESATIVADO", 2)
    elseif input.KeyCode == Enum.KeyCode.F4 then
        CONFIG.antiLag.enabled = not CONFIG.antiLag.enabled
        if CONFIG.antiLag.enabled then applyAntiLag() else disableAntiLag() end
        notify("Anti Lag", CONFIG.antiLag.enabled and "ATIVADO" or "DESATIVADO", 2)
    elseif input.KeyCode == Enum.KeyCode.F5 then
        autoSkills = not autoSkills
        notify("Auto Skills", autoSkills and "ATIVADO" or "DESATIVADO", 2)
    elseif input.KeyCode == Enum.KeyCode.F6 then
        -- Random morph
        local validPresets = {}
        for _, preset in ipairs(PRESET_MORPHS) do
            if preset.userId then table.insert(validPresets, preset) end
        end
        if #validPresets > 0 then
            local randomPreset = validPresets[math.random(1, #validPresets)]
            morphToUser(randomPreset.userId, randomPreset.displayName)
        end
    elseif input.KeyCode == Enum.KeyCode.F7 then
        -- Toggle UI
        if mainGui and mainGui.Parent then
            mainGui.Enabled = not mainGui.Enabled
        else
            createWindUI()
        end
    elseif input.KeyCode == Enum.KeyCode.Insert then
        if mainGui and mainGui.Parent then
            mainGui:Destroy()
            if reachSphere then reachSphere:Destroy() end
            if reachGKCube then reachGKCube:Destroy() end
            disableAntiLag()
        else
            createWindUI()
        end
    end
end)

-- ============================================
-- INICIALIZAÇÃO
-- ============================================
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    RootPart = char:WaitForChild("HumanoidRootPart")
    
    addLog("Character respawned - sistemas reiniciados", "info")
    
    -- Reaplicar morph se necessário
    if CONFIG.antiLag.enabled then
        task.delay(2, applyAntiLag)
    end
end)

-- Iniciar se já tiver character
if LocalPlayer.Character then
    Character = LocalPlayer.Character
    Humanoid = Character:FindFirstChild("Humanoid")
    RootPart = Character:FindFirstChild("HumanoidRootPart")
end

-- Criar UI
createWindUI()

-- Iniciar loop principal
task.spawn(mainLoop)

-- Mensagem final
print([[ 
    ╔══════════════════════════════════════════════════════════════╗
    ║           CAFUXZ1 Hub v14.3 Ultimate - Loaded                  ║
    ║           Created by: Bazuka | Cafuxz1 | CADUXX137           ║
    ║                                                                ║
    ║  Features: Ball Reach GK | Anti Lag | Morph | Skybox          ║
    ║  Hotkeys: F1-F7 | Insert to toggle UI                         ║
    ╚══════════════════════════════════════════════════════════════╝
]])

addLog("Sistema inicializado - Bem-vindo ao CAFUXZ1 Hub v14.3!", "success")
    
    
    
    
    
    
                                                    
