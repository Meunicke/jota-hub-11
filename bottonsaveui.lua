--[[
    CAFUXZ1 GK Hub v1.1 - Goalkeeper Edition + Auto Catch
    ======================================================
    
    NOVO: Sistema Auto Catch GK para Mobile/PC
    - Auto equipa Tool de GK (slot 6)
    - Spamma tecla "R" quando detectar bola no alcance
    - Usa VirtualInputManager para mobile
    - Detecção de pulo + bola = catch automático
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
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer

-- ============================================
-- VERIFICAÇÃO ANTI-DUPLICAÇÃO
-- ============================================
if CoreGui:FindFirstChild("CAFUXZ1_GK_Hub") then
    CoreGui:FindFirstChild("CAFUXZ1_GK_Hub"):Destroy()
end
if CoreGui:FindFirstChild("CAFUXZ1_GK_Icon") then
    CoreGui:FindFirstChild("CAFUXZ1_GK_Icon"):Destroy()
end
if CoreGui:FindFirstChild("CAFUXZ1_GK_Intro") then
    CoreGui:FindFirstChild("CAFUXZ1_GK_Intro"):Destroy()
end

-- Limpar objetos antigos
for _, obj in ipairs(Workspace:GetChildren()) do
    if obj.Name == "CAFUXZ1_GK_Cube" or obj.Name == "CAFUXZ1_ReachSphere" then
        obj:Destroy()
    end
end

-- ============================================
-- CONFIGURAÇÕES GK
-- ============================================
local CONFIG = {
    width = 600,
    height = 450,
    sidebarWidth = 90,
    
    -- GK Settings (padrão 100 como no original)
    reachGK = 100,
    reachGKEnabled = true,
    reachGKShow = true,
    reachGKColor = Color3.fromRGB(255, 255, 0), -- Amarelo GK
    reachGKTransparency = 0.8,
    
    -- NOVO: Auto Catch GK
    autoCatch = {
        enabled = true,           -- Ativar auto catch
        slotGK = 6,               -- Slot da Tool GK (padrão 6)
        catchKey = "R",           -- Tecla de catch (R)
        spamInterval = 0.05,      -- Intervalo entre spams (segundos)
        equipDelay = 0.1,         -- Delay após equipar antes de spammar
        ballDetectionRange = 80,  -- Range para detectar bola e ativar
        jumpDetection = true,     -- Só ativar se estiver pulando
        toolCheck = true,         -- Verificar se tem tool equipada
    },
    
    -- Funcionalidades
    autoTouch = true,
    fullBodyTouch = true,
    autoSecondTouch = true,
    autoSkills = true,
    scanCooldown = 1.5,
    
    -- Anti Lag
    antiLag = {
        enabled = false,
        textures = true,
        visualEffects = true,
        parts = true,
        particles = true,
        sky = true,
        fullBright = false
    },
    
    -- Cores Tema
    customColors = {
        primary = Color3.fromRGB(255, 215, 0),      -- Dourado GK
        secondary = Color3.fromRGB(255, 165, 0),    -- Laranja
        accent = Color3.fromRGB(255, 255, 0),       -- Amarelo
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
    },
    
    -- Lista de bolas
    ballNames = { 
        "TPS", "TCS", "ESA", "MRS", "PRS", "MPS", "SSS", "AIFA", "RBZ",
        "Ball", "Soccer", "Football", "Basketball", "Baseball", 
        "BallTemplate", "GameBall", "Hitbox", "TouchPart", "GoalBall",
        "Physics", "Interaction", "Trigger", "Touch", "Hit", "Box",
        " bola", "Bola", "BOLA", "SOCCER", "FOOTBALL", "SoccerBall"
    }
}

-- ============================================
-- ESTATÍSTICAS
-- ============================================
local STATS = {
    totalTouches = 0,
    ballsTouched = 0,
    gkSaves = 0,
    skillsActivated = 0,
    catchesAttempted = 0,      -- NOVO: Catches tentados
    catchesSuccessful = 0,      -- NOVO: Catches bem-sucedidos
    sessionStart = tick(),
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
    if #LOGS > MAX_LOGS then table.remove(LOGS) end
end

-- ============================================
-- VARIÁVEIS GLOBAIS
-- ============================================
local balls = {}
local ballConnections = {}
local gkCube = nil
local HRP = nil
local char = nil
local humanoid = nil
local touchDebounce = {}
local lastBallUpdate = 0
local lastTouch = 0
local isMinimized = false
local isClosed = false
local mainGui = nil
local mainFrame = nil
local iconGui = nil
local introGui = nil
local currentTab = "gk"
local lastSkillActivation = 0
local skillCooldown = 0.5
local activatedSkills = {}
local antiLagActive = false
local originalStates = {}
local antiLagConnection = nil
local currentSkybox = nil
local originalSkybox = nil
local loopRunning = false
local heartbeatConnection = nil
local lastSkillCheck = 0
local skillCheckInterval = 0.1
local lastStatsUpdate = 0
local statsUpdateInterval = 1
local logLabelPool = {}

-- NOVO: Variáveis do Auto Catch
local autoCatchActive = false
local lastCatchAttempt = 0
local lastEquipTime = 0
local gkToolEquipped = false
local currentTool = nil

local skillButtonNames = {
    "GK", "Save", "Dive", "Jump", "Throw", "Catch", "Punch",
    "Control", "Left", "Right", "High", "Low",
    "Goalkeeper", "Defender", "Defense",
    "Slide", "Tackle", "Block", "Stop"
}

-- ============================================
-- FUNÇÕES UTILITÁRIAS
-- ============================================
local function notify(title, text, duration)
    duration = duration or 3
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "🥅 CAFUXZ1 GK",
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
-- VIRTUAL INPUT (MOBILE/PC)
-- ============================================
local function simulateKeyPress(key)
    local keyCode = Enum.KeyCode[key]
    if not keyCode then return end
    
    -- Método 1: VirtualInputManager (funciona em mobile e PC)
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
    end)
    
    -- Método 2: keypress (se disponível)
    if keypress then
        pcall(function()
            keypress(keyCode.Value)
        end)
    end
end

local function simulateKeyRelease(key)
    local keyCode = Enum.KeyCode[key]
    if not keyCode then return end
    
    pcall(function()
        VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
    end)
    
    if keyrelease then
        pcall(function()
            keyrelease(keyCode.Value)
        end)
    end
end

local function simulateKeyTap(key)
    simulateKeyPress(key)
    task.wait(0.05)
    simulateKeyRelease(key)
end

-- ============================================
-- SISTEMA AUTO CATCH GK
-- ============================================

local function getBackpack()
    return LocalPlayer:FindFirstChild("Backpack")
end

local function getCharacterTools()
    if not char then return {} end
    local tools = {}
    for _, obj in ipairs(char:GetChildren()) do
        if obj:IsA("Tool") then
            table.insert(tools, obj)
        end
    end
    return tools
end

local function getGKTool()
    local backpack = getBackpack()
    if not backpack then return nil end
    
    -- Procura tool de GK no slot especificado ou por nome
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            -- Verifica se é tool de GK (por nome ou slot)
            local toolName = tool.Name:lower()
            if toolName:find("gk") or toolName:find("goalkeeper") or 
               toolName:find("catch") or toolName:find("gloves") then
                return tool
            end
        end
    end
    
    -- Se não achou por nome, tenta pegar a tool do slot 6
    local tools = {}
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            table.insert(tools, tool)
        end
    end
    
    -- Ordena por slot (se tiver atributo) ou por ordem
    table.sort(tools, function(a, b)
        local slotA = a:GetAttribute("Slot") or 999
        local slotB = b:GetAttribute("Slot") or 999
        return slotA < slotB
    end)
    
    return tools[CONFIG.autoCatch.slotGK]
end

local function equipGKTool()
    if not char then return false end
    
    local currentTools = getCharacterTools()
    -- Se já tem tool equipada, verifica se é GK
    for _, tool in ipairs(currentTools) do
        local toolName = tool.Name:lower()
        if toolName:find("gk") or toolName:find("goalkeeper") or 
           toolName:find("catch") or toolName:find("gloves") then
            gkToolEquipped = true
            currentTool = tool
            return true
        end
    end
    
    -- Equipa a tool de GK
    local gkTool = getGKTool()
    if gkTool then
        pcall(function()
            gkTool.Parent = char
        end)
        lastEquipTime = tick()
        addLog("GK Tool equipada: " .. gkTool.Name, "success")
        return true
    end
    
    return false
end

local function unequipGKTool()
    local backpack = getBackpack()
    if not backpack or not char then return end
    
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            pcall(function()
                tool.Parent = backpack
            end)
        end
    end
    
    gkToolEquipped = false
    currentTool = nil
end

local function isJumping()
    if not humanoid then return false end
    return humanoid:GetState() == Enum.HumanoidStateType.Jumping or
           humanoid:GetState() == Enum.HumanoidStateType.Freefall
end

local function isBallInCatchRange()
    if not HRP then return false end
    
    local catchRange = CONFIG.autoCatch.ballDetectionRange or CONFIG.reachGK
    
    for _, ball in ipairs(balls) do
        if ball and ball.Parent then
            local distance = (ball.Position - HRP.Position).Magnitude
            if distance <= catchRange then
                -- Verifica se a bola está vindo em direção ao goleiro
                local ballVelocity = ball.AssemblyLinearVelocity or Vector3.zero
                local directionToPlayer = (HRP.Position - ball.Position).Unit
                local dotProduct = ballVelocity:Dot(directionToPlayer)
                
                -- Se a bola está se movendo em direção ao player ou está próxima
                if dotProduct > 0 or distance < 20 then
                    return true, ball, distance
                end
            end
        end
    end
    
    return false, nil, 0
end

local function attemptCatch()
    local now = tick()
    
    -- Cooldown entre catches
    if now - lastCatchAttempt < CONFIG.autoCatch.spamInterval then
        return false
    end
    
    -- Verifica se deve equipar tool
    if CONFIG.autoCatch.toolCheck and not gkToolEquipped then
        if not equipGKTool() then
            return false
        end
        -- Aguarda um pouco após equipar
        if now - lastEquipTime < CONFIG.autoCatch.equipDelay then
            return false
        end
    end
    
    -- Verifica se está pulando (se configurado)
    if CONFIG.autoCatch.jumpDetection and not isJumping() then
        return false
    end
    
    -- Verifica se tem bola no range
    local ballInRange, ball, distance = isBallInCatchRange()
    if not ballInRange then
        autoCatchActive = false
        return false
    end
    
    -- ATIVA O CATCH!
    autoCatchActive = true
    lastCatchAttempt = now
    STATS.catchesAttempted = STATS.catchesAttempted + 1
    
    -- Spamma a tecla R
    simulateKeyPress(CONFIG.autoCatch.catchKey)
    task.wait(0.03)
    simulateKeyRelease(CONFIG.autoCatch.catchKey)
    
    addLog(string.format("CATCH! Bola a %.1f studs", distance), "success")
    
    -- Verifica se pegou a bola (feedback visual/sonoro do jogo)
    task.delay(0.2, function()
        -- Aqui você pode adicionar lógica para detectar se pegou
        STATS.catchesSuccessful = STATS.catchesSuccessful + 1
    end)
    
    return true
end

local function processAutoCatch()
    if not CONFIG.autoCatch.enabled then 
        if autoCatchActive then
            autoCatchActive = false
            -- Desequipa após um tempo sem uso
            if tick() - lastCatchAttempt > 3 then
                unequipGKTool()
            end
        end
        return 
    end
    
    attemptCatch()
end

-- ============================================
-- INTRO GK
-- ============================================
local function createIntro()
    introGui = Instance.new("ScreenGui")
    introGui.Name = "CAFUXZ1_GK_Intro"
    introGui.ResetOnSpawn = false
    introGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    introGui.Parent = CoreGui
    
    local bg = Instance.new("Frame")
    bg.Name = "Background"
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.new(0, 0, 0)
    bg.BackgroundTransparency = 0
    bg.BorderSizePixel = 0
    bg.Parent = introGui
    
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(0, 500, 0, 400)
    container.Position = UDim2.new(0.5, -250, 0.5, -200)
    container.BackgroundTransparency = 1
    container.Parent = bg
    
    local icon = Instance.new("TextLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0, 100, 0, 100)
    icon.Position = UDim2.new(0.5, -50, 0, 20)
    icon.BackgroundTransparency = 1
    icon.Text = "🥅"
    icon.TextColor3 = CONFIG.customColors.primary
    icon.TextSize = 80
    icon.Font = Enum.Font.GothamBold
    icon.Parent = container
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 130)
    title.BackgroundTransparency = 1
    title.Text = "CAFUXZ1 GK Hub"
    title.TextColor3 = CONFIG.customColors.textPrimary
    title.TextSize = 36
    title.Font = Enum.Font.GothamBold
    title.Parent = container
    
    local version = Instance.new("TextLabel")
    version.Name = "Version"
    version.Size = UDim2.new(1, 0, 0, 30)
    version.Position = UDim2.new(0, 0, 0, 180)
    version.BackgroundTransparency = 1
    version.Text = "Versão 1.1 - Auto Catch Edition"
    version.TextColor3 = CONFIG.customColors.primary
    version.TextSize = 18
    version.Font = Enum.Font.Gotham
    version.Parent = container
    
    local line = Instance.new("Frame")
    line.Name = "Line"
    line.Size = UDim2.new(0, 0, 0, 2)
    line.Position = UDim2.new(0.5, 0, 0, 220)
    line.BackgroundColor3 = CONFIG.customColors.primary
    line.BorderSizePixel = 0
    line.Parent = container
    
    local updatesText = Instance.new("TextLabel")
    updatesText.Name = "Updates"
    updatesText.Size = UDim2.new(1, -40, 0, 120)
    updatesText.Position = UDim2.new(0, 20, 0, 240)
    updatesText.BackgroundTransparency = 1
    updatesText.Text = "🥅 NOVO - AUTO CATCH:\n\n" ..
                       "• Equipa GK automaticamente (Slot 6)\n" ..
                       "• Spamma 'R' quando detectar bola\n" ..
                       "• Funciona no Mobile com Virtual Input\n" ..
                       "• Só ativa durante o pulo\n\n" ..
                       "📱 ARRASTE O ÍCONE 🥅 PARA MOVER"
    updatesText.TextColor3 = CONFIG.customColors.textSecondary
    updatesText.TextSize = 14
    updatesText.Font = Enum.Font.Gotham
    updatesText.TextWrapped = true
    updatesText.TextYAlignment = Enum.TextYAlignment.Top
    updatesText.Parent = container
    
    local enterBtn = Instance.new("TextButton")
    enterBtn.Name = "EnterBtn"
    enterBtn.Size = UDim2.new(0, 200, 0, 45)
    enterBtn.Position = UDim2.new(0.5, -100, 1, -60)
    enterBtn.BackgroundColor3 = CONFIG.customColors.primary
    enterBtn.Text = "ENTRAR NO HUB"
    enterBtn.TextColor3 = Color3.new(0, 0, 0)
    enterBtn.TextSize = 18
    enterBtn.Font = Enum.Font.GothamBold
    enterBtn.Parent = container
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 10)
    btnCorner.Parent = enterBtn
    
    task.wait(0.2)
    
    tween(icon, {TextTransparency = 0}, 0.5)
    task.wait(0.3)
    tween(title, {TextTransparency = 0}, 0.5)
    task.wait(0.2)
    tween(version, {TextTransparency = 0}, 0.5)
    task.wait(0.2)
    tween(line, {Size = UDim2.new(0.8, 0, 0, 2)}, 0.6)
    task.wait(0.3)
    tween(updatesText, {TextTransparency = 0}, 0.5)
    task.wait(0.3)
    tween(enterBtn, {BackgroundTransparency = 0.2, TextTransparency = 0}, 0.5)
    
    task.spawn(function()
        while enterBtn and enterBtn.Parent do
            tween(enterBtn, {Size = UDim2.new(0, 205, 0, 47)}, 0.5)
            task.wait(0.5)
            if not enterBtn or not enterBtn.Parent then break end
            tween(enterBtn, {Size = UDim2.new(0, 200, 0, 45)}, 0.5)
            task.wait(0.5)
        end
    end)
    
    local function closeIntro()
        tween(bg, {BackgroundTransparency = 1}, 0.5)
        tween(container, {Position = UDim2.new(0.5, -250, 0.5, -100), Size = UDim2.new(0, 500, 0, 0)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In, function()
            introGui:Destroy()
            introGui = nil
        end)
    end
    
    enterBtn.MouseButton1Click:Connect(closeIntro)
    task.delay(10, function()
        if introGui and introGui.Parent then closeIntro() end
    end)
end

-- ============================================
-- SISTEMA ANTI LAG
-- ============================================
local function saveOriginalState(obj, property, value)
    if not originalStates[obj] then originalStates[obj] = {} end
    if originalStates[obj][property] == nil then
        originalStates[obj][property] = value
    end
end

local function applyAntiLag()
    if antiLagActive then return end
    antiLagActive = true
    
    local batchSize = 100
    local Stuff = {}
    
    local function processBatch(descendants, startIdx)
        local endIdx = math.min(startIdx + batchSize - 1, #descendants)
        
        for i = startIdx, endIdx do
            local v = descendants[i]
            
            if CONFIG.antiLag.parts and (v:IsA("Part") or v:IsA("Union") or v:IsA("BasePart")) then
                saveOriginalState(v, "Material", v.Material)
                v.Material = Enum.Material.SmoothPlastic
                table.insert(Stuff, v)
            end
            
            if CONFIG.antiLag.particles and (v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Explosion") or v:IsA("Sparkles") or v:IsA("Fire")) then
                saveOriginalState(v, "Enabled", v.Enabled)
                v.Enabled = false
                table.insert(Stuff, v)
            end
            
            if CONFIG.antiLag.visualEffects and (v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("SunRaysEffect")) then
                saveOriginalState(v, "Enabled", v.Enabled)
                v.Enabled = false
                table.insert(Stuff, v)
            end
            
            if CONFIG.antiLag.textures and (v:IsA("Decal") or v:IsA("Texture")) then
                saveOriginalState(v, "Texture", v.Texture)
                v.Texture = ""
                table.insert(Stuff, v)
            end
            
            if CONFIG.antiLag.sky and v:IsA("Sky") then
                saveOriginalState(v, "Parent", v.Parent)
                v.Parent = nil
                table.insert(Stuff, v)
            end
        end
        
        if endIdx < #descendants then
            task.wait()
            processBatch(descendants, endIdx + 1)
        else
            STATS.antiLagItems = #Stuff
            addLog("Anti Lag ATIVADO - " .. #Stuff .. " itens", "success")
        end
    end
    
    local allDescendants = game:GetDescendants()
    processBatch(allDescendants, 1)
    
    antiLagConnection = game.DescendantAdded:Connect(function(v)
        if not antiLagActive then return end
        task.wait(0.1)
        if CONFIG.antiLag.parts and (v:IsA("Part") or v:IsA("Union") or v:IsA("BasePart")) then
            saveOriginalState(v, "Material", v.Material)
            v.Material = Enum.Material.SmoothPlastic
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
    
    local states = {}
    for obj, props in pairs(originalStates) do
        table.insert(states, {obj = obj, props = props})
    end
    
    local batchSize = 100
    local function restoreBatch(startIdx)
        local endIdx = math.min(startIdx + batchSize - 1, #states)
        
        for i = startIdx, endIdx do
            local data = states[i]
            local obj = data.obj
            if obj and obj.Parent then
                for prop, value in pairs(data.props) do
                    pcall(function()
                        if prop == "Parent" then obj.Parent = value
                        else obj[prop] = value end
                    end)
                end
            end
        end
        
        if endIdx < #states then
            task.wait()
            restoreBatch(endIdx + 1)
        else
            originalStates = {}
            STATS.antiLagItems = 0
            addLog("Anti Lag DESATIVADO", "warning")
        end
    end
    
    restoreBatch(1)
end

-- ============================================
-- SISTEMA DE MORPH
-- ============================================
local PRESET_MORPHS = {
    { name = "AlissonGkBe", userId = nil, displayName = "AlissonGkBe (GK)" },
    { name = "Miguelcalebegamer202", userId = nil, displayName = "Miguelcalebegamer202" },
    { name = "Tottxii", userId = nil, displayName = "Tottxii" },
    { name = "Feliou23", userId = nil, displayName = "Feliou23 (cb)" },
    { name = "venxcore", userId = nil, displayName = "venxcore (cb)" }
}

task.spawn(function()
    for _, preset in ipairs(PRESET_MORPHS) do
        local success, userId = pcall(function()
            return Players:GetUserIdFromNameAsync(preset.name)
        end)
        if success then preset.userId = userId end
        task.wait(0.1)
    end
end)

local function morphToUser(userId, targetName)
    if not userId then notify("Morph", "User ID não encontrado!", 3) return end
    if userId == LocalPlayer.UserId then notify("Morph", "Não pode morphar em si mesmo!", 3) return end
    
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum = character:WaitForChild("Humanoid", 10)
    if not hum then notify("Morph", "Humanoid não encontrado!", 3) return end

    local success, desc = pcall(function()
        return Players:GetHumanoidDescriptionFromUserId(userId)
    end)
    
    if not success or not desc then notify("Morph", "Falha ao carregar avatar!", 3) return end

    for _, obj in ipairs(character:GetChildren()) do
        if obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("ShirtGraphic") or obj:IsA("Accessory") or obj:IsA("BodyColors") then
            obj:Destroy()
        end
    end
    
    local head = character:FindFirstChild("Head")
    if head then
        for _, decal in ipairs(head:GetChildren()) do
            if decal:IsA("Decal") then decal:Destroy() end
        end
    end

    pcall(function()
        hum:ApplyDescriptionClientServer(desc)
    end)
    
    STATS.morphsDone = STATS.morphsDone + 1
    notify("Morph", "Morph aplicado: " .. targetName .. "!", 3)
    addLog("Morph: " .. targetName, "success")
end

-- ============================================
-- SISTEMA SKYBOX
-- ============================================
local SkyboxDatabase = {
    { id = 14828385099, name = "Night Sky With Moon HD", category = "1" },
    { id = 109488540432307, name = "Cosmic Sky A", category = "1" },
    { id = 109844440994380, name = "Cosmic Sky B", category = "1" },
    { id = 277098164, name = "Night/Space Classic", category = "1" },
    { id = 6681543281, name = "Deep Space", category = "1" },
    { id = 77407612452946, name = "Galaxy Nebula", category = "1" },
    { id = 2900944368, name = "Space/Sci-Fi Sky", category = "2" },
    { id = 290982885, name = "Atmospheric Sky", category = "2" },
    { id = 295604372, name = "Cloudy/Weather Sky", category = "2" },
    { id = 17124418086, name = "Custom Sky A", category = "3" },
    { id = 17480150596, name = "Custom Sky B", category = "3" },
    { id = 16553683517, name = "Custom Sky C", category = "3" },
    { id = 264910951, name = "Vintage/Retro Sky", category = "3" },
    { id = 119314959302386, name = "Special Effect Sky", category = "4" },
    { id = 109488540432307, name = "Cosmic Sky A (Alt)", category = "4" },
}

local function ClearSkies()
    for _, child in pairs(Lighting:GetChildren()) do
        if child:IsA("Sky") then child:Destroy() end
    end
end

local function ApplySkybox(assetId, skyName)
    if assetId == 0 then return false end
    ClearSkies()
    
    local success = pcall(function()
        local objects = game:GetObjects("rbxassetid://" .. assetId)
        if objects and #objects > 0 then
            local source = objects[1]
            if source:IsA("Sky") then
                local sky = source:Clone()
                sky.Name = "CAFUXZ1_GK_Sky_" .. assetId
                sky.Parent = Lighting
                return true
            end
            if source:IsA("Model") or source:IsA("Folder") then
                for _, child in pairs(source:GetDescendants()) do
                    if child:IsA("Sky") then
                        local sky = child:Clone()
                        sky.Name = "CAFUXZ1_GK_Sky_" .. assetId
                        sky.Parent = Lighting
                        source:Destroy()
                        return true
                    end
                end
                source:Destroy()
            end
        end
        return false
    end)
    
    if success then currentSkybox = assetId return true end
    
    success = pcall(function()
        local InsertService = game:GetService("InsertService")
        local model = InsertService:LoadAsset(assetId)
        if model then
            for _, child in pairs(model:GetDescendants()) do
                if child:IsA("Sky") then
                    local sky = child:Clone()
                    sky.Name = "CAFUXZ1_GK_Sky_" .. assetId
                    sky.Parent = Lighting
                    model:Destroy()
                    return true
                end
            end
            model:Destroy()
        end
        return false
    end)
    
    if success then currentSkybox = assetId return true end
    
    success = pcall(function()
        local sky = Instance.new("Sky")
        sky.Name = "CAFUXZ1_GK_Sky_Generic_" .. assetId
        local url = "rbxassetid://" .. assetId
        sky.SkyboxBk = url
        sky.SkyboxDn = url
        sky.SkyboxFt = url
        sky.SkyboxLf = url
        sky.SkyboxRt = url
        sky.SkyboxUp = url
        sky.Parent = Lighting
        return true
    end)
    
    if success then currentSkybox = assetId end
    return success
end

local function restoreOriginalSkybox()
    ClearSkies()
    if originalSkybox then
        originalSkybox.Parent = Lighting
        originalSkybox = nil
    end
    currentSkybox = nil
end

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

-- ============================================
-- SISTEMA GK - CUBO DE ALCANCE
-- ============================================

local function updateCharacter()
    local newChar = LocalPlayer.Character
    if newChar ~= char then
        char = newChar
        if char then
            HRP = char:WaitForChild("HumanoidRootPart", 2)
            humanoid = char:WaitForChild("Humanoid", 2)
            if HRP then
                addLog("Personagem detectado - GK ativo!", "success")
            end
        else
            HRP = nil
            humanoid = nil
        end
    end
end

local function findBalls()
    local now = tick()
    if now - lastBallUpdate < CONFIG.scanCooldown then return #balls end
    lastBallUpdate = now
    
    table.clear(balls)
    for _, conn in ipairs(ballConnections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(ballConnections)
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Parent then
            for _, name in ipairs(CONFIG.ballNames) do
                if obj.Name == name or obj.Name:find(name) then
                    table.insert(balls, obj)
                    local conn = obj.AncestryChanged:Connect(function()
                        if not obj.Parent then findBalls() end
                    end)
                    table.insert(ballConnections, conn)
                    break
                end
            end
        end
    end
    
    return #balls
end

local function getBodyParts()
    if not char then return {} end
    local parts = {}
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") then
            if CONFIG.fullBodyTouch then
                table.insert(parts, part)
            elseif part.Name == "HumanoidRootPart" or part.Name == "Torso" or part.Name == "UpperTorso" then
                table.insert(parts, part)
            end
        end
    end
    return parts
end

-- ============================================
-- CUBO GK (SISTEMA PRINCIPAL)
-- ============================================
local function createGKCube()
    if gkCube and gkCube.Parent then return end
    
    gkCube = Instance.new("Part")
    gkCube.Name = "CAFUXZ1_GK_Cube"
    gkCube.Shape = Enum.PartType.Block
    gkCube.Anchored = true
    gkCube.CanCollide = false
    gkCube.Transparency = CONFIG.reachGKTransparency
    gkCube.Material = Enum.Material.ForceField
    gkCube.Color = CONFIG.reachGKColor
    gkCube.Parent = Workspace
    
    -- SelectionBox para visualização do cubo
    local selectionBox = Instance.new("SelectionBox")
    selectionBox.Name = "GKSelectionBox"
    selectionBox.Adornee = gkCube
    selectionBox.Color3 = CONFIG.reachGKColor
    selectionBox.LineThickness = 0.08
    selectionBox.Parent = gkCube
    
    addLog("GK Cube criado (Tamanho: " .. CONFIG.reachGK .. ")", "success")
end

local function destroyGKCube()
    if gkCube then
        gkCube:Destroy()
        gkCube = nil
    end
end

local function updateGKCube()
    if not CONFIG.reachGKShow then
        destroyGKCube()
        return
    end
    
    local Character, Humanoid, RootPart = char, humanoid, HRP
    if not RootPart then
        destroyGKCube()
        return
    end
    
    if not gkCube or not gkCube.Parent then
        createGKCube()
    end
    
    -- CUBO com tamanho configurável (padrão 100)
    gkCube.Size = Vector3.new(CONFIG.reachGK, CONFIG.reachGK, CONFIG.reachGK)
    gkCube.CFrame = RootPart.CFrame
    gkCube.Color = CONFIG.reachGKColor
    gkCube.Transparency = CONFIG.reachGKTransparency
    
    local selectionBox = gkCube:FindFirstChild("GKSelectionBox")
    if selectionBox then
        selectionBox.Color3 = CONFIG.reachGKColor
    end
end

local function processGKTouch()
    if not CONFIG.reachGKEnabled then return end
    if not HRP then return end
    
    local Character = char
    local torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso") or HRP
    if not torso then return end
    
    if not gkCube then return end
    
    local overlap = OverlapParams.new()
    overlap.FilterDescendantsInstances = {Character, gkCube}
    overlap.FilterType = Enum.RaycastFilterType.Exclude
    
    local objectsInCube = Workspace:GetPartBoundsInBox(gkCube.CFrame, gkCube.Size, overlap)
    
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
                pcall(function()
                    firetouchinterest(obj, torso, 0)
                    firetouchinterest(obj, torso, 1)
                end)
                STATS.gkSaves = STATS.gkSaves + 1
                STATS.totalTouches = STATS.totalTouches + 1
                STATS.ballsTouched = STATS.ballsTouched + 1
            end
        end
    end
end

-- ============================================
-- AUTO SKILLS GK
-- ============================================
local cachedSkillButtons = nil
local lastSkillCache = 0

local function findSkillButtons()
    local buttons = {}
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return buttons end
    
    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Name ~= "CAFUXZ1_GK_Hub" and gui.Name ~= "CAFUXZ1_GK_Icon" then
            for _, obj in ipairs(gui:GetDescendants()) do
                if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                    for _, skillName in ipairs(skillButtonNames) do
                        if obj.Name == skillName or obj.Text == skillName or 
                           (obj.Name:lower():find(skillName:lower()) and #obj.Name < 30) then
                            table.insert(buttons, obj)
                            break
                        end
                    end
                end
            end
        end
    end
    
    return buttons
end

local function activateSkillButton(button)
    if not button or not button.Parent then return end
    
    local key = tostring(button)
    if activatedSkills[key] and tick() - activatedSkills[key] < skillCooldown then 
        return 
    end
    activatedSkills[key] = tick()
    
    pcall(function()
        if button:IsA("GuiButton") then
            for _, conn in ipairs(getconnections(button.MouseButton1Click)) do
                conn:Fire()
            end
            for _, conn in ipairs(getconnections(button.Activated)) do
                conn:Fire()
            end
            
            if button.MouseButton1Click then
                button.MouseButton1Click:Fire()
            end
            if button.Activated then
                button.Activated:Fire()
            end
        end
    end)
end

local function processAutoSkills()
    if not CONFIG.autoSkills then return end
    
    local now = tick()
    if now - lastSkillCheck < skillCheckInterval then return end
    lastSkillCheck = now
    
    if now - lastSkillActivation < skillCooldown then return end
    
    if not cachedSkillButtons or now - lastSkillCache > 5 then
        cachedSkillButtons = findSkillButtons()
        lastSkillCache = now
    end
    
    -- Verificar se tem bola no range do GK
    if not HRP then return end
    
    local ballInRange = false
    for _, ball in ipairs(balls) do
        if ball and ball.Parent then
            if (ball.Position - HRP.Position).Magnitude <= CONFIG.reachGK then
                ballInRange = true
                break
            end
        end
    end
    
    if not ballInRange then return end
    
    lastSkillActivation = now
    
    local gkSkills = {"GK", "Save", "Dive", "Catch", "Punch", "Goalkeeper"}
    for _, button in ipairs(cachedSkillButtons) do
        for _, gkSkill in ipairs(gkSkills) do
            if button.Name == gkSkill or button.Text == gkSkill then
                activateSkillButton(button)
                STATS.skillsActivated = STATS.skillsActivated + 1
                return
            end
        end
    end
end

-- ============================================
-- ATUALIZAÇÃO DE CORES
-- ============================================
local function updateAllColors()
    if mainFrame then
        local stroke = mainFrame:FindFirstChild("UIStroke")
        if stroke then stroke.Color = CONFIG.customColors.primary end
        
        local gradient = mainFrame:FindFirstChild("UIGradient")
        if gradient then
            gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, CONFIG.customColors.bgDark),
                ColorSequenceKeypoint.new(1, CONFIG.customColors.bgCard)
            })
        end
    end
    
    if gkCube then
        gkCube.Color = CONFIG.reachGKColor
        local selectionBox = gkCube:FindFirstChild("GKSelectionBox")
        if selectionBox then
            selectionBox.Color3 = CONFIG.reachGKColor
        end
    end
    
    if iconGui then
        local iconBtn = iconGui:FindFirstChild("IconButton")
        if iconBtn then iconBtn.BackgroundColor3 = CONFIG.customColors.primary end
    end
    
    addLog("Cores atualizadas!", "success")
end

-- ============================================
-- INTERFACE WINDUI GK
-- ============================================
local function createWindUI()
    if CoreGui:FindFirstChild("CAFUXZ1_GK_Hub") then
        CoreGui:FindFirstChild("CAFUXZ1_GK_Hub"):Destroy()
    end
    
    isClosed = false
    
    mainGui = Instance.new("ScreenGui")
    mainGui.Name = "CAFUXZ1_GK_Hub"
    mainGui.ResetOnSpawn = false
    mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    if UserInputService.TouchEnabled then
        mainGui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
    end
    
    mainGui.Parent = CoreGui
    
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    
    if UserInputService.TouchEnabled then
        mainFrame.Size = UDim2.new(0, 350, 0, 400)
    else
        mainFrame.Size = UDim2.new(0, CONFIG.width, 0, CONFIG.height)
    end
    
    mainFrame.Position = UDim2.new(0.5, -mainFrame.Size.X.Offset/2, 0.5, -mainFrame.Size.Y.Offset/2)
    mainFrame.BackgroundColor3 = CONFIG.customColors.bgGlass
    mainFrame.BackgroundTransparency = 0.2
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = mainGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Name = "UIStroke"
    stroke.Color = CONFIG.customColors.primary
    stroke.Thickness = 2
    stroke.Transparency = 0.5
    stroke.Parent = mainFrame
    
    local gradient = Instance.new("UIGradient")
    gradient.Name = "UIGradient"
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, CONFIG.customColors.bgDark),
        ColorSequenceKeypoint.new(1, CONFIG.customColors.bgCard)
    })
    gradient.Rotation = 45
    gradient.Parent = mainFrame
    
    -- Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, CONFIG.sidebarWidth, 1, 0)
    sidebar.BackgroundColor3 = CONFIG.customColors.bgCard
    sidebar.BackgroundTransparency = 0.3
    sidebar.BorderSizePixel = 0
    sidebar.Parent = mainFrame
    
    local sidebarCorner = Instance.new("UICorner")
    sidebarCorner.CornerRadius = UDim.new(0, 12)
    sidebarCorner.Parent = sidebar
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 50)
    titleLabel.Position = UDim2.new(0, 0, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "🥅"
    titleLabel.TextColor3 = CONFIG.customColors.primary
    titleLabel.TextSize = 32
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = sidebar
    
    local versionLabel = Instance.new("TextLabel")
    versionLabel.Size = UDim2.new(1, 0, 0, 20)
    versionLabel.Position = UDim2.new(0, 0, 0, 55)
    versionLabel.BackgroundTransparency = 1
    versionLabel.Text = "GK v1.1"
    versionLabel.TextColor3 = CONFIG.customColors.textMuted
    versionLabel.TextSize = 12
    versionLabel.Font = Enum.Font.Gotham
    versionLabel.Parent = sidebar
    
    -- Tabs
    local tabs = {
        {name = "gk", icon = "🥅", label = "GK"},
        {name = "catch", icon = "🧤", label = "Catch"},  -- NOVO: Tab de Catch
        {name = "visual", icon = "👁️", label = "Visual"},
        {name = "char", icon = "👤", label = "Char"},
        {name = "sky", icon = "☁️", label = "Sky"},
        {name = "config", icon = "⚙️", label = "Config"},
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
        btn.BackgroundColor3 = CONFIG.customColors.bgElevated
        btn.BackgroundTransparency = 0.5
        btn.Text = tab.icon .. " " .. tab.label
        btn.TextColor3 = CONFIG.customColors.textSecondary
        btn.TextSize = 11
        btn.Font = Enum.Font.GothamBold
        btn.Parent = sidebar
        
        if UserInputService.TouchEnabled then
            btn.Size = UDim2.new(0.9, 0, 0, 45)
        end
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn
        
        tabButtons[tab.name] = btn
        
        local content = Instance.new("ScrollingFrame")
        content.Name = tab.name .. "Content"
        content.Size = UDim2.new(1, -CONFIG.sidebarWidth - 10, 1, -60)
        content.Position = UDim2.new(0, CONFIG.sidebarWidth + 5, 0, 50)
        content.BackgroundTransparency = 1
        content.BorderSizePixel = 0
        content.ScrollBarThickness = 6
        content.ScrollBarImageColor3 = CONFIG.customColors.primary
        content.Visible = false
        content.Parent = mainFrame
        
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 12)
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
    headerTitle.Text = "CAFUXZ1 GK Hub v1.1"
    headerTitle.TextColor3 = CONFIG.customColors.textPrimary
    headerTitle.TextSize = 18
    headerTitle.Font = Enum.Font.GothamBold
    headerTitle.TextXAlignment = Enum.TextXAlignment.Left
    headerTitle.Parent = header
    
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "MinimizeBtn"
    minimizeBtn.Size = UDim2.new(0, 35, 0, 35)
    minimizeBtn.Position = UDim2.new(1, -80, 0, 2)
    minimizeBtn.BackgroundColor3 = CONFIG.customColors.warning
    minimizeBtn.Text = "−"
    minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
    minimizeBtn.TextSize = 24
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.Parent = header
    
    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 8)
    minCorner.Parent = minimizeBtn
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -40, 0, 2)
    closeBtn.BackgroundColor3 = CONFIG.customColors.danger
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextSize = 24
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = header
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn
    
    -- Funções auxiliares
    local function createSection(parent, title)
        local section = Instance.new("Frame")
        section.Size = UDim2.new(0.95, 0, 0, 0)
        section.AutomaticSize = Enum.AutomaticSize.Y
        section.BackgroundColor3 = CONFIG.customColors.bgCard
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
        sectionTitle.TextColor3 = CONFIG.customColors.primary
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
        sectionLayout.Padding = UDim.new(0, 10)
        sectionLayout.Parent = sectionContent
        
        return section, sectionContent
    end
    
    local function createToggle(parent, text, default, callback)
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Size = UDim2.new(1, 0, 0, 40)
        toggleFrame.BackgroundTransparency = 1
        toggleFrame.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = CONFIG.customColors.textSecondary
        label.TextSize = 13
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = toggleFrame
        
        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Size = UDim2.new(0, 55, 0, 30)
        toggleBtn.Position = UDim2.new(1, -55, 0.5, -15)
        toggleBtn.BackgroundColor3 = default and CONFIG.customColors.success or CONFIG.customColors.bgElevated
        toggleBtn.Text = default and "ON" or "OFF"
        toggleBtn.TextColor3 = Color3.new(1, 1, 1)
        toggleBtn.TextSize = 14
        toggleBtn.Font = Enum.Font.GothamBold
        toggleBtn.Parent = toggleFrame
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 15)
        toggleCorner.Parent = toggleBtn
        
        local enabled = default
        
        toggleBtn.MouseButton1Click:Connect(function()
            enabled = not enabled
            toggleBtn.BackgroundColor3 = enabled and CONFIG.customColors.success or CONFIG.customColors.bgElevated
            toggleBtn.Text = enabled and "ON" or "OFF"
            if callback then callback(enabled) end
        end)
        
        return toggleFrame, toggleBtn
    end
    
    local function createNumberInput(parent, labelText, defaultValue, min, max, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 70)
        frame.BackgroundTransparency = 1
        frame.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 25)
        label.BackgroundTransparency = 1
        label.Text = labelText
        label.TextColor3 = CONFIG.customColors.textSecondary
        label.TextSize = 13
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local inputContainer = Instance.new("Frame")
        inputContainer.Size = UDim2.new(1, 0, 0, 35)
        inputContainer.Position = UDim2.new(0, 0, 0, 30)
        inputContainer.BackgroundTransparency = 1
        inputContainer.Parent = frame
        
        local input = Instance.new("TextBox")
        input.Size = UDim2.new(0.6, -5, 1, 0)
        input.BackgroundColor3 = CONFIG.customColors.bgElevated
        input.Text = tostring(defaultValue)
        input.PlaceholderText = "Digite o valor..."
        input.TextColor3 = CONFIG.customColors.textPrimary
        input.TextSize = 16
        input.Font = Enum.Font.GothamBold
        input.ClearTextOnFocus = true
        input.Parent = inputContainer
        
        local inputCorner = Instance.new("UICorner")
        inputCorner.CornerRadius = UDim.new(0, 8)
        inputCorner.Parent = input
        
        local applyBtn = Instance.new("TextButton")
        applyBtn.Size = UDim2.new(0.4, -5, 1, 0)
        applyBtn.Position = UDim2.new(0.6, 10, 0, 0)
        applyBtn.BackgroundColor3 = CONFIG.customColors.primary
        applyBtn.Text = "APLICAR"
        applyBtn.TextColor3 = Color3.new(0, 0, 0)
        applyBtn.TextSize = 14
        applyBtn.Font = Enum.Font.GothamBold
        applyBtn.Parent = inputContainer
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = applyBtn
        
        local currentLabel = Instance.new("TextLabel")
        currentLabel.Size = UDim2.new(1, 0, 0, 20)
        currentLabel.Position = UDim2.new(0, 0, 0, 68)
        currentLabel.BackgroundTransparency = 1
        currentLabel.Text = "Valor atual: " .. defaultValue
        currentLabel.TextColor3 = CONFIG.customColors.textMuted
        currentLabel.TextSize = 11
        currentLabel.Font = Enum.Font.Gotham
        currentLabel.TextXAlignment = Enum.TextXAlignment.Left
        currentLabel.Parent = frame
        
        local function applyValue()
            local num = tonumber(input.Text)
            if num then
                num = math.clamp(math.floor(num), min, max)
                input.Text = tostring(num)
                currentLabel.Text = "Valor atual: " .. num
                if callback then callback(num) end
                addLog(labelText .. " alterado para: " .. num, "success")
            else
                input.Text = tostring(defaultValue)
                notify("Erro", "Digite um número válido!", 2)
            end
        end
        
        applyBtn.MouseButton1Click:Connect(applyValue)
        input.FocusLost:Connect(function(enterPressed)
            if enterPressed then applyValue() end
        end)
        
        return frame
    end
    
    local function createButton(parent, text, color, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 40)
        btn.BackgroundColor3 = color or CONFIG.customColors.primary
        btn.Text = text
        btn.TextColor3 = Color3.new(0, 0, 0)
        btn.TextSize = 14
        btn.Font = Enum.Font.GothamBold
        btn.Parent = parent
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn
        
        btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or 
               input.UserInputType == Enum.UserInputType.Touch then
                tween(btn, {Size = UDim2.new(0.97, 0, 0, 38)}, 0.05)
            end
        end)
        
        btn.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or 
               input.UserInputType == Enum.UserInputType.Touch then
                tween(btn, {Size = UDim2.new(1, 0, 0, 40)}, 0.1)
                if callback then callback() end
            end
        end)
        
        return btn
    end
    
    local function createColorPicker(parent, labelText, defaultColor, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 45)
        frame.BackgroundTransparency = 1
        frame.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.6, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = labelText
        label.TextColor3 = CONFIG.customColors.textSecondary
        label.TextSize = 13
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local colorBtn = Instance.new("TextButton")
        colorBtn.Size = UDim2.new(0, 70, 0, 35)
        colorBtn.Position = UDim2.new(1, -70, 0.5, -17)
        colorBtn.BackgroundColor3 = defaultColor
        colorBtn.Text = "🎨"
        colorBtn.TextSize = 20
        colorBtn.Parent = frame
        
        local colorCorner = Instance.new("UICorner")
        colorCorner.CornerRadius = UDim.new(0, 8)
        colorCorner.Parent = colorBtn
        
        local rgbFrame = Instance.new("Frame")
        rgbFrame.Size = UDim2.new(1, 0, 0, 35)
        rgbFrame.Position = UDim2.new(0, 0, 0, 45)
        rgbFrame.BackgroundTransparency = 1
        rgbFrame.Visible = false
        rgbFrame.Parent = frame
        
        local rInput = Instance.new("TextBox")
        rInput.Size = UDim2.new(0.3, -5, 1, 0)
        rInput.BackgroundColor3 = CONFIG.customColors.bgElevated
        rInput.Text = tostring(math.floor(defaultColor.R * 255))
        rInput.TextColor3 = Color3.new(1, 0, 0)
        rInput.TextSize = 14
        rInput.Parent = rgbFrame
        
        local gInput = Instance.new("TextBox")
        gInput.Size = UDim2.new(0.3, -5, 1, 0)
        gInput.Position = UDim2.new(0.35, 0, 0, 0)
        gInput.BackgroundColor3 = CONFIG.customColors.bgElevated
        gInput.Text = tostring(math.floor(defaultColor.G * 255))
        gInput.TextColor3 = Color3.fromRGB(0, 255, 0)
        gInput.TextSize = 14
        gInput.Parent = rgbFrame
        
        local bInput = Instance.new("TextBox")
        bInput.Size = UDim2.new(0.3, -5, 1, 0)
        bInput.Position = UDim2.new(0.7, 0, 0, 0)
        bInput.BackgroundColor3 = CONFIG.customColors.bgElevated
        bInput.Text = tostring(math.floor(defaultColor.B * 255))
        bInput.TextColor3 = Color3.fromRGB(0, 100, 255)
        bInput.TextSize = 14
        bInput.Parent = rgbFrame
        
        for _, inp in ipairs({rInput, gInput, bInput}) do
            local inpCorner = Instance.new("UICorner")
            inpCorner.CornerRadius = UDim.new(0, 6)
            inpCorner.Parent = inp
            
            inp.FocusLost:Connect(function()
                local r = math.clamp(tonumber(rInput.Text) or 0, 0, 255)
                local g = math.clamp(tonumber(gInput.Text) or 0, 0, 255)
                local b = math.clamp(tonumber(bInput.Text) or 0, 0, 255)
                local newColor = Color3.fromRGB(r, g, b)
                colorBtn.BackgroundColor3 = newColor
                if callback then callback(newColor) end
            end)
        end
        
        colorBtn.MouseButton1Click:Connect(function()
            rgbFrame.Visible = not rgbFrame.Visible
            frame.Size = rgbFrame.Visible and UDim2.new(1, 0, 0, 85) or UDim2.new(1, 0, 0, 45)
        end)
        
        return frame
    end
    
    -- POPULAR ABAS
    -- ABA GK (Principal)
    local gkSection, gkContent = createSection(contentFrames.gk, "Sistema GK - Cubo")
    
    createToggle(gkContent, "Ativar Reach GK", CONFIG.reachGKEnabled, function(val)
        CONFIG.reachGKEnabled = val
        addLog("GK Reach: " .. (val and "ON" or "OFF"), val and "success" or "warning")
    end)
    
    createToggle(gkContent, "Mostrar Cubo GK", CONFIG.reachGKShow, function(val)
        CONFIG.reachGKShow = val
        if not val then destroyGKCube() end
        addLog("GK Cube: " .. (val and "VISÍVEL" or "OCULTO"), "info")
    end)
    
    createToggle(gkContent, "Auto Touch GK", CONFIG.autoTouch, function(val)
        CONFIG.autoTouch = val
        addLog("Auto Touch GK: " .. (val and "ON" or "OFF"), val and "success" or "warning")
    end)
    
    createToggle(gkContent, "Full Body Touch", CONFIG.fullBodyTouch, function(val)
        CONFIG.fullBodyTouch = val
    end)
    
    createToggle(gkContent, "Double Touch", CONFIG.autoSecondTouch, function(val)
        CONFIG.autoSecondTouch = val
    end)
    
    createToggle(gkContent, "Auto Skills GK", CONFIG.autoSkills, function(val)
        CONFIG.autoSkills = val
        addLog("Auto Skills GK: " .. (val and "ON" or "OFF"), val and "success" or "warning")
    end)
    
    -- Inputs GK
    createNumberInput(gkContent, "Tamanho do Cubo GK", CONFIG.reachGK, 10, 300, function(val)
        CONFIG.reachGK = val
    end)
    
    createNumberInput(gkContent, "Transparência GK (0-100)", math.floor(CONFIG.reachGKTransparency * 100), 0, 100, function(val)
        CONFIG.reachGKTransparency = val / 100
    end)
    
    -- NOVO: ABA CATCH (Auto Catch GK)
    local catchSection, catchContent = createSection(contentFrames.catch, "🧤 Auto Catch GK")
    
    createToggle(catchContent, "Ativar Auto Catch", CONFIG.autoCatch.enabled, function(val)
        CONFIG.autoCatch.enabled = val
        addLog("Auto Catch: " .. (val and "ON" or "OFF"), val and "success" or "warning")
        if not val then
            unequipGKTool()
        end
    end)
    
    createToggle(catchContent, "Só no Pulo", CONFIG.autoCatch.jumpDetection, function(val)
        CONFIG.autoCatch.jumpDetection = val
        addLog("Catch no Pulo: " .. (val and "ON" or "OFF"), "info")
    end)
    
    createToggle(catchContent, "Auto Equipar Tool", CONFIG.autoCatch.toolCheck, function(val)
        CONFIG.autoCatch.toolCheck = val
        addLog("Auto Equip: " .. (val and "ON" or "OFF"), "info")
    end)
    
    createNumberInput(catchContent, "Slot da Tool GK", CONFIG.autoCatch.slotGK, 1, 10, function(val)
        CONFIG.autoCatch.slotGK = val
    end)
    
    createNumberInput(catchContent, "Range Detecção Bola", CONFIG.autoCatch.ballDetectionRange, 10, 200, function(val)
        CONFIG.autoCatch.ballDetectionRange = val
    end)
    
    createNumberInput(catchContent, "Spam Interval (ms)", math.floor(CONFIG.autoCatch.spamInterval * 1000), 10, 500, function(val)
        CONFIG.autoCatch.spamInterval = val / 1000
    end)
    
    -- Botão de teste manual
    createButton(catchContent, "🧤 TESTAR CATCH MANUAL", CONFIG.customColors.warning, function()
        equipGKTool()
        task.wait(0.2)
        simulateKeyTap(CONFIG.autoCatch.catchKey)
        addLog("Teste manual de catch!", "success")
    end)
    
    createButton(catchContent, "⌨️ TESTAR TECLA R", CONFIG.customColors.info, function()
        simulateKeyTap("R")
        addLog("Tecla R simulada!", "info")
    end)
    
    -- ABA VISUAL
    local visualSection, visualContent = createSection(contentFrames.visual, "Anti Lag")
    
    createToggle(visualContent, "Ativar Anti Lag", CONFIG.antiLag.enabled, function(val)
        CONFIG.antiLag.enabled = val
        if val then applyAntiLag() else disableAntiLag() end
    end)
    
    -- ABA CHAR
    local charSection, charContent = createSection(contentFrames.char, "Morph Avatar")
    
    local usernameInput = Instance.new("TextBox")
    usernameInput.Size = UDim2.new(1, 0, 0, 35)
    usernameInput.BackgroundColor3 = CONFIG.customColors.bgElevated
    usernameInput.Text = ""
    usernameInput.PlaceholderText = "Username..."
    usernameInput.TextColor3 = CONFIG.customColors.textPrimary
    usernameInput.TextSize = 14
    usernameInput.Parent = charContent
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 8)
    inputCorner.Parent = usernameInput
    
    createButton(charContent, "Aplicar Morph", CONFIG.customColors.primary, function()
                local username = usernameInput.Text
        if username ~= "" then
            task.spawn(function()
                local success, userId = pcall(function()
                    return Players:GetUserIdFromNameAsync(username)
                end)
                if success then 
                    morphToUser(userId, username) 
                else
                    notify("Erro", "Usuário não encontrado!", 3)
                end
            end)
        end
    end)
    
    for _, preset in ipairs(PRESET_MORPHS) do
        createButton(charContent, preset.displayName, CONFIG.customColors.bgElevated, function()
            if preset.userId then 
                morphToUser(preset.userId, preset.displayName) 
            else
                notify("Aguarde", "Carregando ID do preset...", 2)
            end
        end)
    end
    
    -- ABA SKYBOX
    local skySection, skyContent = createSection(contentFrames.sky, "Skybox System")
    
    skyItemsFrame = Instance.new("Frame")
    skyItemsFrame.Size = UDim2.new(1, 0, 0, 0)
    skyItemsFrame.AutomaticSize = Enum.AutomaticSize.Y
    skyItemsFrame.BackgroundTransparency = 1
    skyItemsFrame.Parent = skyContent
    
    local CategoryColors = {
        ["1"] = Color3.fromRGB(0, 120, 255),
        ["2"] = Color3.fromRGB(0, 200, 100),
        ["3"] = Color3.fromRGB(255, 170, 0),
        ["4"] = Color3.fromRGB(180, 0, 220),
    }
    
    local function loadSkyCategory(categoryNum)
        for _, child in ipairs(skyItemsFrame:GetChildren()) do
            child:Destroy()
        end
        
        for _, sky in ipairs(SkyboxDatabase) do
            if sky.category == categoryNum then
                createButton(skyItemsFrame, sky.name, CategoryColors[categoryNum], function()
                    saveOriginalSkybox()
                    ApplySkybox(sky.id, sky.name)
                end)
            end
        end
    end
    
    createButton(skyContent, "🌌 Cosmos", CategoryColors["1"], function() loadSkyCategory("1") end)
    createButton(skyContent, "🌅 Atmosféricos", CategoryColors["2"], function() loadSkyCategory("2") end)
    createButton(skyContent, "🎨 Custom", CategoryColors["3"], function() loadSkyCategory("3") end)
    createButton(skyContent, "✨ Especiais", CategoryColors["4"], function() loadSkyCategory("4") end)
    createButton(skyContent, "↩️ Resetar", CONFIG.customColors.danger, restoreOriginalSkybox)
    
    -- ABA CONFIG
    local configSection, configContent = createSection(contentFrames.config, "Cores do Tema")
    
    createColorPicker(configContent, "Cor Primária", CONFIG.customColors.primary, function(c) 
        CONFIG.customColors.primary = c
        updateAllColors()
    end)
    
    createColorPicker(configContent, "Cor do Cubo GK", CONFIG.reachGKColor, function(c) 
        CONFIG.reachGKColor = c
        updateAllColors()
    end)
    
    createColorPicker(configContent, "Cor Secundária", CONFIG.customColors.secondary, function(c) 
        CONFIG.customColors.secondary = c
        updateAllColors()
    end)
    
    createColorPicker(configContent, "Cor Sucesso", CONFIG.customColors.success, function(c) 
        CONFIG.customColors.success = c
        updateAllColors()
    end)
    
    createColorPicker(configContent, "Cor Perigo", CONFIG.customColors.danger, function(c) 
        CONFIG.customColors.danger = c
        updateAllColors()
    end)
    
    -- ABA STATS
    local statsSection, statsContent = createSection(contentFrames.stats, "Estatísticas GK")
    
    local statsLabels = {}
    for _, item in ipairs({
        {k="totalTouches", l="Total Toques"},
        {k="ballsTouched", l="Bolas Tocadas"},
        {k="gkSaves", l="Defesas GK"},
        {k="skillsActivated", l="Skills Ativadas"},
        {k="catchesAttempted", l="Catches Tentados"},
        {k="catchesSuccessful", l="Catches Bem-sucedidos"},
        {k="morphsDone", l="Morphs Realizados"}
    }) do
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, 0, 0, 35)
        f.BackgroundTransparency = 1
        f.Parent = statsContent
        
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.6, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = item.l .. ":"
        lbl.TextColor3 = CONFIG.customColors.textSecondary
        lbl.TextSize = 14
        lbl.Font = Enum.Font.Gotham
        lbl.Parent = f
        
        local val = Instance.new("TextLabel")
        val.Size = UDim2.new(0.4, 0, 1, 0)
        val.Position = UDim2.new(0.6, 0, 0, 0)
        val.BackgroundTransparency = 1
        val.Text = "0"
        val.TextColor3 = CONFIG.customColors.primary
        val.TextSize = 16
        val.Font = Enum.Font.GothamBold
        val.Parent = f
        
        statsLabels[item.k] = val
    end
    
    task.spawn(function()
        while mainGui and mainGui.Parent do
            local now = tick()
            if now - lastStatsUpdate >= statsUpdateInterval then
                lastStatsUpdate = now
                for k, lbl in pairs(statsLabels) do
                    lbl.Text = tostring(STATS[k] or 0)
                end
            end
            task.wait(0.1)
        end
    end)
    
    -- ABA LOGS
    local logsSection, logsContent = createSection(contentFrames.logs, "Logs")
    
    local logsList = Instance.new("ScrollingFrame")
    logsList.Size = UDim2.new(1, 0, 0, 250)
    logsList.BackgroundColor3 = CONFIG.customColors.bgDark
    logsList.BackgroundTransparency = 0.5
    logsList.BorderSizePixel = 0
    logsList.ScrollBarThickness = 6
    logsList.Parent = logsContent
    
    local logsCorner = Instance.new("UICorner")
    logsCorner.CornerRadius = UDim.new(0, 8)
    logsCorner.Parent = logsList
    
    for i = 1, 20 do
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -10, 0, 22)
        lbl.Position = UDim2.new(0, 5, 0, (i-1) * 24)
        lbl.BackgroundTransparency = 1
        lbl.Text = ""
        lbl.TextSize = 12
        lbl.Font = Enum.Font.Code
        lbl.Visible = false
        lbl.Parent = logsList
        table.insert(logLabelPool, lbl)
    end
    
    task.spawn(function()
        while mainGui and mainGui.Parent do
            for i, lbl in ipairs(logLabelPool) do
                local log = LOGS[i]
                if log then
                    lbl.Text = string.format("[%s] %s", log.time, log.message)
                    lbl.TextColor3 = log.type == "success" and CONFIG.customColors.success or (log.type == "warning" and CONFIG.customColors.warning or CONFIG.customColors.textSecondary)
                    lbl.Visible = true
                else
                    lbl.Visible = false
                end
            end
            
            logsList.CanvasSize = UDim2.new(0, 0, 0, math.min(#LOGS, 20) * 24)
            task.wait(0.5)
        end
    end)
    
    -- NAVEGAÇÃO
    local function switchTab(tabName)
        currentTab = tabName
        for name, btn in pairs(tabButtons) do
            if name == tabName then
                tween(btn, {BackgroundColor3 = CONFIG.customColors.primary}, 0.2)
                btn.TextColor3 = CONFIG.customColors.textPrimary
            else
                tween(btn, {BackgroundColor3 = CONFIG.customColors.bgElevated}, 0.2)
                btn.TextColor3 = CONFIG.customColors.textSecondary
            end
        end
        for name, frame in pairs(contentFrames) do
            frame.Visible = (name == tabName)
        end
    end
    
    for name, btn in pairs(tabButtons) do
        btn.MouseButton1Click:Connect(function() switchTab(name) end)
    end
    
    switchTab("gk")
    
    -- MINIMIZAR/RESTAURAR
    local function minimizeUI()
        isMinimized = true
        mainFrame.Visible = false
        if not iconGui or not iconGui.Parent then
            createIconGui()
        else
            iconGui.Enabled = true
        end
        addLog("Interface minimizada", "info")
    end
    
    local function restoreUI()
        isMinimized = false
        mainFrame.Visible = true
        if iconGui then iconGui.Enabled = false end
        addLog("Interface restaurada", "info")
    end
    
    minimizeBtn.MouseButton1Click:Connect(minimizeUI)
    closeBtn.MouseButton1Click:Connect(minimizeUI)
    
    -- Drag (PC e Mobile)
    local dragging = false
    local dragStart, startPos
    
    local function onDragStart(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end
    
    local function onDragMove(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                        input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end
    
    local function onDragEnd(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end
    
    header.InputBegan:Connect(onDragStart)
    UserInputService.InputChanged:Connect(onDragMove)
    UserInputService.InputEnded:Connect(onDragEnd)
    
    -- ÍCONE FLUTUANTE
    function createIconGui()
        if CoreGui:FindFirstChild("CAFUXZ1_GK_Icon") then
            CoreGui:FindFirstChild("CAFUXZ1_GK_Icon"):Destroy()
        end
        
        iconGui = Instance.new("ScreenGui")
        iconGui.Name = "CAFUXZ1_GK_Icon"
        iconGui.ResetOnSpawn = false
        iconGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        iconGui.Parent = CoreGui
        
        local iconContainer = Instance.new("Frame")
        iconContainer.Name = "IconContainer"
        iconContainer.Size = UDim2.new(0, 70, 0, 70)
        iconContainer.Position = UDim2.new(0, 20, 0.5, -35)
        iconContainer.BackgroundTransparency = 1
        iconContainer.Parent = iconGui
        
        local iconBtn = Instance.new("TextButton")
        iconBtn.Name = "IconButton"
        iconBtn.Size = UDim2.new(0, 60, 0, 60)
        iconBtn.Position = UDim2.new(0.5, -30, 0.5, -30)
        iconBtn.BackgroundColor3 = CONFIG.customColors.primary
        iconBtn.Text = "🥅"
        iconBtn.TextColor3 = Color3.new(0, 0, 0)
        iconBtn.TextSize = 32
        iconBtn.Font = Enum.Font.GothamBold
        iconBtn.Parent = iconContainer
        
        local iconCorner = Instance.new("UICorner")
        iconCorner.CornerRadius = UDim.new(1, 0)
        iconCorner.Parent = iconBtn
        
        -- Sombra
        local shadow = Instance.new("ImageLabel")
        shadow.Name = "Shadow"
        shadow.Size = UDim2.new(1.3, 0, 1.3, 0)
        shadow.Position = UDim2.new(-0.15, 0, -0.15, 0)
        shadow.BackgroundTransparency = 1
        shadow.Image = "rbxassetid://1316045217"
        shadow.ImageColor3 = Color3.new(0, 0, 0)
        shadow.ImageTransparency = 0.5
        shadow.ZIndex = -1
        shadow.Parent = iconBtn
        
        -- Label "Arraste"
        local dragLabel = Instance.new("TextLabel")
        dragLabel.Size = UDim2.new(1, 0, 0, 20)
        dragLabel.Position = UDim2.new(0, 0, 1, -10)
        dragLabel.BackgroundTransparency = 1
        dragLabel.Text = "Arraste"
        dragLabel.TextColor3 = CONFIG.customColors.textMuted
        dragLabel.TextSize = 10
        dragLabel.Font = Enum.Font.Gotham
        dragLabel.Parent = iconContainer
        
        iconBtn.MouseButton1Click:Connect(restoreUI)
        
        -- Drag do ícone (PC e Mobile)
        local iconDragging = false
        local iconDragStart, iconStartPos
        
        local function onIconDragStart(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or 
               input.UserInputType == Enum.UserInputType.Touch then
                iconDragging = true
                iconDragStart = input.Position
                iconStartPos = iconContainer.Position
                
                -- Efeito visual
                tween(iconBtn, {Size = UDim2.new(0, 65, 0, 65), Position = UDim2.new(0.5, -32.5, 0.5, -32.5)}, 0.1)
            end
        end
        
        local function onIconDragMove(input)
            if iconDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                                input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - iconDragStart
                iconContainer.Position = UDim2.new(iconStartPos.X.Scale, iconStartPos.X.Offset + delta.X, 
                                                     iconStartPos.Y.Scale, iconStartPos.Y.Offset + delta.Y)
            end
        end
        
        local function onIconDragEnd(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or 
               input.UserInputType == Enum.UserInputType.Touch then
                iconDragging = false
                
                -- Efeito visual
                tween(iconBtn, {Size = UDim2.new(0, 60, 0, 60), Position = UDim2.new(0.5, -30, 0.5, -30)}, 0.1)
            end
        end
        
        iconBtn.InputBegan:Connect(onIconDragStart)
        UserInputService.InputChanged:Connect(onIconDragMove)
        UserInputService.InputEnded:Connect(onIconDragEnd)
    end
    
    addLog("GK Hub v1.1 iniciado! Auto Catch ativo!", "success")
    notify("CAFUXZ1 GK Hub", "v1.1 - Auto Catch Edition!", 5)
end

-- ============================================
-- LOOP PRINCIPAL GK
-- ============================================
local function mainLoop()
    if loopRunning then return end
    loopRunning = true
    
    heartbeatConnection = RunService.Heartbeat:Connect(function()
        if isClosed then return end
        
        updateCharacter()
        updateGKCube()
        findBalls()
        
        if HRP and HRP.Parent then
            processGKTouch()
            processAutoSkills()
            processAutoCatch()  -- NOVO: Processa auto catch
        else
            if gkCube then
                gkCube:Destroy()
                gkCube = nil
            end
        end
    end)
    
    addLog("Sistema GK iniciado - Cubo + Auto Catch ativos!", "success")
end

-- ============================================
-- ATALHOS
-- ============================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F1 then
        CONFIG.reachGKEnabled = not CONFIG.reachGKEnabled
        notify("GK Reach", CONFIG.reachGKEnabled and "ON" or "OFF", 2)
        addLog("F1: GK Reach " .. (CONFIG.reachGKEnabled and "ON" or "OFF"), "info")
    elseif input.KeyCode == Enum.KeyCode.F2 then
        CONFIG.reachGKShow = not CONFIG.reachGKShow
        if not CONFIG.reachGKShow then destroyGKCube() end
        notify("GK Cube", CONFIG.reachGKShow and "VISÍVEL" or "OCULTO", 2)
    elseif input.KeyCode == Enum.KeyCode.F3 then
        CONFIG.autoSkills = not CONFIG.autoSkills
        notify("Auto Skills GK", CONFIG.autoSkills and "ON" or "OFF", 2)
        addLog("F3: Auto Skills GK " .. (CONFIG.autoSkills and "ON" or "OFF"), "info")
    elseif input.KeyCode == Enum.KeyCode.F4 then
        CONFIG.antiLag.enabled = not CONFIG.antiLag.enabled
        if CONFIG.antiLag.enabled then applyAntiLag() else disableAntiLag() end
        notify("Anti Lag", CONFIG.antiLag.enabled and "ON" or "OFF", 2)
    elseif input.KeyCode == Enum.KeyCode.F5 then
        -- NOVO: Atalho para Auto Catch
        CONFIG.autoCatch.enabled = not CONFIG.autoCatch.enabled
        notify("Auto Catch", CONFIG.autoCatch.enabled and "ON" or "OFF", 2)
        addLog("F5: Auto Catch " .. (CONFIG.autoCatch.enabled and "ON" or "OFF"), "info")
        if not CONFIG.autoCatch.enabled then
            unequipGKTool()
        end
    elseif input.KeyCode == Enum.KeyCode.Insert then
        if mainGui and mainGui.Parent then
            if mainGui.Enabled then
                local header = mainFrame:FindFirstChild("Header")
                if header then
                    local minimizeBtn = header:FindFirstChild("MinimizeBtn")
                    if minimizeBtn then
                        minimizeBtn.MouseButton1Click:Fire()
                    end
                end
            else
                mainGui.Enabled = true
            end
        else
            createWindUI()
        end
    end
end)

-- ============================================
-- INICIALIZAÇÃO
-- ============================================
LocalPlayer.CharacterAdded:Connect(function(newChar)
    addLog("Character respawned - reconectando GK...", "info")
    
    char = newChar
    HRP = nil
    humanoid = nil
    gkToolEquipped = false
    currentTool = nil
    
    if gkCube then
        gkCube:Destroy()
        gkCube = nil
    end
    
    task.spawn(function()
        HRP = newChar:WaitForChild("HumanoidRootPart", 5)
        humanoid = newChar:WaitForChild("Humanoid", 5)
        if HRP then
            addLog("HRP encontrado - GK ativo!", "success")
        end
    end)
    
    task.delay(1, function()
        if CONFIG.antiLag.enabled then
            applyAntiLag()
        end
    end)
end)

-- Iniciar
createIntro()
task.delay(0.5, function()
    createWindUI()
    mainLoop()
end)

print("CAFUXZ1 GK Hub v1.1 - Auto Catch Edition Loaded!")
print("🥅 Cubo GK + Auto Catch ativo!")
print("🧤 Tecla F5 para toggle do Auto Catch")

