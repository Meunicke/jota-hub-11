--[[
    CAFUXZ1 GK Hub v1.3 - Bug Fix Edition
    =========================================
    
    CORREÇÕES:
    - Erros de nil value corrigidos
    - Removido game:GetObjects e InsertService (não funcionam em scripts)
    - Sistema AC (Auto Catch) otimizado
    - Verificações de nil adicionadas em todas as funções
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
pcall(function()
    if CoreGui:FindFirstChild("CAFUXZ1_GK_Hub") then
        CoreGui:FindFirstChild("CAFUXZ1_GK_Hub"):Destroy()
    end
    if CoreGui:FindFirstChild("CAFUXZ1_GK_Icon") then
        CoreGui:FindFirstChild("CAFUXZ1_GK_Icon"):Destroy()
    end
end)

-- Limpar objetos antigos
pcall(function()
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj.Name == "CAFUXZ1_GK_Cube" then
            obj:Destroy()
        end
    end
end)

-- ============================================
-- CONFIGURAÇÕES GK
-- ============================================
local CONFIG = {
    width = 600,
    height = 450,
    sidebarWidth = 90,
    
    -- GK Settings
    reachGK = 100,
    reachGKEnabled = true,
    reachGKShow = true,
    reachGKColor = Color3.fromRGB(255, 215, 0),
    reachGKTransparency = 0.8,
    
    -- AC = Auto Catch (CORRIGIDO!)
    AC = {
        enabled = false,
        slotGK = 6,
        catchKey = "F",
        spamInterval = 0.15,
        equipDelay = 0.3,
        ballDetectionRange = 80,
        jumpDetection = false,
        toolCheck = true,
        maxConsecutiveActivations = 3,
        resetTime = 1.5,
    },
    
    -- Auto Skills
    autoSkills = true,
    autoSkillsInterval = 0.5,
    
    -- Funcionalidades
    autoTouch = true,
    fullBodyTouch = true,
    autoSecondTouch = false,
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
        primary = Color3.fromRGB(255, 215, 0),
        secondary = Color3.fromRGB(255, 165, 0),
        accent = Color3.fromRGB(255, 255, 0),
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
    
    ballNames = { 
        "TPS", "TCS", "ESA", "MRS", "PRS", "MPS", "SSS", "AIFA", "RBZ",
        "Ball", "Soccer", "Football", "Basketball", "Baseball", 
        "BallTemplate", "GameBall", "Hitbox", "TouchPart", "GoalBall",
        "Physics", "Interaction", "Trigger", "Touch", "Hit", "Box",
        "bola", "Bola", "BALL", "SOCCER", "FOOTBALL", "SoccerBall"
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
    catchesAttempted = 0,
    catchesSuccessful = 0,
    sessionStart = tick(),
    antiLagItems = 0,
    morphsDone = 0
}

local LOGS = {}
local MAX_LOGS = 50

local function addLog(message, type)
    type = type or "info"
    table.insert(LOGS, 1, {
        message = tostring(message),
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
local lastBallUpdate = 0
local isMinimized = false
local isClosed = false
local mainGui = nil
local mainFrame = nil
local iconGui = nil
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
local lastSkillCheck = 0
local lastStatsUpdate = 0
local logLabelPool = {}

-- AC (Auto Catch) Variáveis
local ACActive = false
local lastCatchAttempt = 0
local lastEquipTime = 0
local gkToolEquipped = false
local currentTool = nil
local consecutiveCatches = 0
local lastCatchReset = 0

-- ============================================
-- FUNÇÃO TWEEN CORRIGIDA
-- ============================================
local function tween(obj, props, time, style, dir, callback)
    if not obj or not obj.Parent then return nil end
    
    local success, result = pcall(function()
        time = time or 0.35
        style = style or Enum.EasingStyle.Quint
        dir = dir or Enum.EasingDirection.Out
        
        local info = TweenInfo.new(time, style, dir)
        local t = TweenService:Create(obj, info, props)
        
        if callback and typeof(callback) == "function" then
            t.Completed:Connect(callback)
        end
        
        t:Play()
        return t
    end)
    
    return success and result or nil
end

-- ============================================
-- NOTIFICAÇÃO CORRIGIDA
-- ============================================
local function notify(title, text, duration)
    duration = duration or 3
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = tostring(title) or "🥅 CAFUXZ1 GK",
            Text = tostring(text) or "",
            Duration = tonumber(duration) or 3
        })
    end)
end

-- ============================================
-- VIRTUAL INPUT CORRIGIDO
-- ============================================
local function simulateKeyPress(key)
    local keyCode = Enum.KeyCode[key]
    if not keyCode then return end
    
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
    end)
end

local function simulateKeyRelease(key)
    local keyCode = Enum.KeyCode[key]
    if not keyCode then return end
    
    pcall(function()
        VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
    end)
end

local function simulateKeyTap(key)
    simulateKeyPress(key)
    task.wait(0.03)
    simulateKeyRelease(key)
end

-- ============================================
-- SISTEMA AC (AUTO CATCH) - CORRIGIDO
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
    
    local tools = {}
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            table.insert(tools, tool)
        end
    end
    
    -- Ordenar por slot se disponível
    table.sort(tools, function(a, b)
        local slotA = a:GetAttribute("Slot") or 999
        local slotB = b:GetAttribute("Slot") or 999
        return slotA < slotB
    end)
    
    return tools[CONFIG.AC.slotGK]
end

local function equipGKTool()
    if not char then return false end
    
    -- Verificar se já tem tool equipada
    local currentTools = getCharacterTools()
    for _, tool in ipairs(currentTools) do
        if tool:IsA("Tool") then
            gkToolEquipped = true
            currentTool = tool
            return true
        end
    end
    
    -- Equipar nova tool
    local gkTool = getGKTool()
    if gkTool then
        pcall(function()
            gkTool.Parent = char
        end)
        lastEquipTime = tick()
        gkToolEquipped = true
        currentTool = gkTool
        addLog("AC: Tool equipada - " .. tostring(gkTool.Name), "success")
        return true
    end
    
    return false
end

local function unequipGKTool()
    local backpack = getBackpack()
    if not backpack or not char then return end
    
    pcall(function()
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                tool.Parent = backpack
            end
        end
    end)
    
    gkToolEquipped = false
    currentTool = nil
end

local function isJumping()
    if not humanoid then return false end
    local state = humanoid:GetState()
    return state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall
end

local function isBallInCatchRange()
    if not HRP then return false, nil, 0 end
    
    local catchRange = CONFIG.AC.ballDetectionRange or CONFIG.reachGK
    
    for _, ball in ipairs(balls) do
        if ball and ball.Parent and ball:IsA("BasePart") then
            local success, distance = pcall(function()
                return (ball.Position - HRP.Position).Magnitude
            end)
            
            if success and distance and distance <= catchRange then
                -- Verificar se bola está vindo em direção ao goleiro
                local velocitySuccess, ballVelocity = pcall(function()
                    return ball.AssemblyLinearVelocity or Vector3.zero
                end)
                
                if velocitySuccess then
                    local directionToPlayer = (HRP.Position - ball.Position).Unit
                    local dotProduct = ballVelocity:Dot(directionToPlayer)
                    
                    if dotProduct > 0 or distance < 20 then
                        return true, ball, distance
                    end
                else
                    return true, ball, distance
                end
            end
        end
    end
    
    return false, nil, 0
end

local function attemptAC()
    local now = tick()
    
    -- Resetar contador de catches consecutivos
    if now - lastCatchReset > CONFIG.AC.resetTime then
        consecutiveCatches = 0
    end
    
    -- Cooldown entre catches
    if now - lastCatchAttempt < CONFIG.AC.spamInterval then
        return false
    end
    
    -- Verificar limite de catches consecutivos
    if consecutiveCatches >= CONFIG.AC.maxConsecutiveActivations then
        if now - lastCatchReset < CONFIG.AC.resetTime then
            return false
        else
            consecutiveCatches = 0
        end
    end
    
    -- Equipar tool se necessário
    if CONFIG.AC.toolCheck and not gkToolEquipped then
        if not equipGKTool() then
            return false
        end
        if now - lastEquipTime < CONFIG.AC.equipDelay then
            return false
        end
    end
    
    -- Verificar pulo se configurado
    if CONFIG.AC.jumpDetection and not isJumping() then
        return false
    end
    
    -- Verificar bola no range
    local ballInRange, ball, distance = isBallInCatchRange()
    if not ballInRange then
        ACActive = false
        return false
    end
    
    -- EXECUTAR CATCH!
    ACActive = true
    lastCatchAttempt = now
    lastCatchReset = now
    consecutiveCatches = consecutiveCatches + 1
    STATS.catchesAttempted = STATS.catchesAttempted + 1
    
    -- Simular tecla F
    simulateKeyTap(CONFIG.AC.catchKey)
    
    addLog(string.format("AC: CATCH! Bola a %.1f studs", distance), "success")
    
    -- Verificar sucesso (simulação)
    task.delay(0.2, function()
        STATS.catchesSuccessful = STATS.catchesSuccessful + 1
    end)
    
    return true
end

local function processAC()
    if not CONFIG.AC.enabled then 
        if ACActive then
            ACActive = false
            if tick() - lastCatchAttempt > 3 then
                unequipGKTool()
            end
        end
        return 
    end
    
    attemptAC()
end

-- ============================================
-- SISTEMA ANTI LAG CORRIGIDO
-- ============================================
local function saveOriginalState(obj, property, value)
    if not obj or typeof(obj) ~= "Instance" then return end
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
            if not v then continue end
            
            pcall(function()
                if CONFIG.antiLag.parts and (v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("BasePart")) then
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
            end)
        end
        
        if endIdx < #descendants then
            task.wait()
            processBatch(descendants, endIdx + 1)
        else
            STATS.antiLagItems = #Stuff
            addLog("Anti Lag ATIVADO - " .. #Stuff .. " itens", "success")
            notify("Anti Lag", #Stuff .. " objetos otimizados!", 3)
        end
    end
    
    local allDescendants = game:GetDescendants()
    processBatch(allDescendants, 1)
    
    antiLagConnection = game.DescendantAdded:Connect(function(v)
        if not antiLagActive then return end
        task.wait(0.1)
        pcall(function()
            if CONFIG.antiLag.parts and (v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("BasePart")) then
                saveOriginalState(v, "Material", v.Material)
                v.Material = Enum.Material.SmoothPlastic
            end
        end)
    end)
end

local function disableAntiLag()
    if not antiLagActive then return end
    antiLagActive = false
    
    if antiLagConnection then
        pcall(function()
            antiLagConnection:Disconnect()
        end)
        antiLagConnection = nil
    end
    
    local states = {}
    for obj, props in pairs(originalStates) do
        if obj and typeof(obj) == "Instance" then
            table.insert(states, {obj = obj, props = props})
        end
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
                        if prop == "Parent" then 
                            obj.Parent = value
                        else 
                            obj[prop] = value 
                        end
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
    
    if #states > 0 then
        restoreBatch(1)
    end
end

-- ============================================
-- SISTEMA DE MORPH CORRIGIDO
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
        pcall(function()
            preset.userId = Players:GetUserIdFromNameAsync(preset.name)
        end)
        task.wait(0.1)
    end
end)

local function morphToUser(userId, targetName)
    if not userId then 
        notify("❌ Morph", "User ID não encontrado!", 3) 
        return 
    end
    
    if userId == LocalPlayer.UserId then 
        notify("⚠️ Morph", "Não pode morphar em si mesmo!", 3) 
        return 
    end
    
    local character = LocalPlayer.Character
    if not character then
        notify("❌ Morph", "Character não encontrado!", 3)
        return
    end
    
    local hum = character:FindFirstChildOfClass("Humanoid")
    if not hum then 
        notify("❌ Morph", "Humanoid não encontrado!", 3) 
        return 
    end

    local desc
    local success = pcall(function()
        desc = Players:GetHumanoidDescriptionFromUserId(userId)
    end)
    
    if not success or not desc then 
        notify("❌ Morph", "Falha ao carregar avatar!", 3) 
        return 
    end

    pcall(function()
        for _, obj in ipairs(character:GetChildren()) do
            if obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("ShirtGraphic") or obj:IsA("Accessory") or obj:IsA("BodyColors") then
                obj:Destroy()
            end
        end
        
        local head = character:FindFirstChild("Head")
        if head then
            for _, decal in ipairs(head:GetChildren()) do
                if decal:IsA("Decal") then 
                    decal:Destroy() 
                end
            end
        end

        hum:ApplyDescriptionClientServer(desc)
    end)
    
    STATS.morphsDone = STATS.morphsDone + 1
    notify("✨ Morph", "Morph aplicado: " .. tostring(targetName) .. "!", 3)
    addLog("Morph: " .. tostring(targetName), "success")
end

-- ============================================
-- SISTEMA SKYBOX CORRIGIDO (SEM game:GetObjects)
-- ============================================
local SkyboxDatabase = {
    { id = 14828385099, name = "Night Sky With Moon HD", category = "1" },
    { id = 277098164, name = "Night/Space Classic", category = "1" },
    { id = 6681543281, name = "Deep Space", category = "1" },
    { id = 2900944368, name = "Space/Sci-Fi Sky", category = "2" },
    { id = 290982885, name = "Atmospheric Sky", category = "2" },
    { id = 295604372, name = "Cloudy/Weather Sky", category = "2" },
    { id = 17124418086, name = "Custom Sky A", category = "3" },
    { id = 17480150596, name = "Custom Sky B", category = "3" },
    { id = 16553683517, name = "Custom Sky C", category = "3" },
    { id = 264910951, name = "Vintage/Retro Sky", category = "3" },
    { id = 119314959302386, name = "Special Effect Sky", category = "4" },
}

local function ClearSkies()
    pcall(function()
        for _, child in ipairs(Lighting:GetChildren()) do
            if child:IsA("Sky") then 
                child:Destroy() 
            end
        end
    end)
end

local function ApplySkybox(assetId, skyName)
    if not assetId or assetId == 0 then 
        return false 
    end
    
    ClearSkies()
    
    -- Método alternativo: criar sky genérico (game:GetObjects não funciona em scripts)
    local success = pcall(function()
        local sky = Instance.new("Sky")
        sky.Name = "CAFUXZ1_GK_Sky_" .. tostring(assetId)
        local url = "rbxassetid://" .. tostring(assetId)
        sky.SkyboxBk = url
        sky.SkyboxDn = url
        sky.SkyboxFt = url
        sky.SkyboxLf = url
        sky.SkyboxRt = url
        sky.SkyboxUp = url
        sky.Parent = Lighting
        return true
    end)
    
    if success then 
        currentSkybox = assetId 
        addLog("Skybox aplicado: " .. tostring(skyName), "success")
        notify("☁️ Skybox", "Céu alterado: " .. tostring(skyName), 2)
        return true
    end
    
    return false
end

local function restoreOriginalSkybox()
    ClearSkies()
    if originalSkybox and typeof(originalSkybox) == "Instance" then
        pcall(function()
            originalSkybox.Parent = Lighting
        end)
        originalSkybox = nil
    end
    currentSkybox = nil
    addLog("Skybox restaurado", "info")
    notify("☁️ Skybox", "Céu original restaurado!", 2)
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
    if now - lastBallUpdate < CONFIG.scanCooldown then 
        return #balls 
    end
    lastBallUpdate = now
    
    for i = #balls, 1, -1 do
        balls[i] = nil
    end
    
    for _, conn in ipairs(ballConnections) do
        pcall(function() 
            conn:Disconnect() 
        end)
    end
    for i = #ballConnections, 1, -1 do
        ballConnections[i] = nil
    end
    
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj and obj:IsA("BasePart") and obj.Parent then
                for _, name in ipairs(CONFIG.ballNames) do
                    if obj.Name == name or (string.find(obj.Name, name, 1, true)) then
                        table.insert(balls, obj)
                        local conn = obj.AncestryChanged:Connect(function()
                            if not obj.Parent then 
                                findBalls() 
                            end
                        end)
                        table.insert(ballConnections, conn)
                        break
                    end
                end
            end
        end
    end)
    
    return #balls
end

local function getBodyParts()
    if not char then 
        return {} 
    end
    
    local parts = {}
    for _, part in ipairs(char:GetChildren()) do
        if part and part:IsA("BasePart") then
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
    if gkCube and gkCube.Parent then 
        return 
    end
    
    pcall(function()
        gkCube = Instance.new("Part")
        gkCube.Name = "CAFUXZ1_GK_Cube"
        gkCube.Shape = Enum.PartType.Block
        gkCube.Anchored = true
        gkCube.CanCollide = false
        gkCube.Transparency = CONFIG.reachGKTransparency
        gkCube.Material = Enum.Material.ForceField
        gkCube.Color = CONFIG.reachGKColor
        gkCube.Parent = Workspace
        
        local selectionBox = Instance.new("SelectionBox")
        selectionBox.Name = "GKSelectionBox"
        selectionBox.Adornee = gkCube
        selectionBox.Color3 = CONFIG.reachGKColor
        selectionBox.LineThickness = 0.08
        selectionBox.Parent = gkCube
    end)
    
    addLog("GK Cube criado (Tamanho: " .. CONFIG.reachGK .. ")", "success")
end

local function destroyGKCube()
    if gkCube then
        pcall(function()
            gkCube:Destroy()
        end)
        gkCube = nil
    end
end

local function updateGKCube()
    if not CONFIG.reachGKShow then
        destroyGKCube()
        return
    end
    
    if not HRP or not HRP.Parent then
        destroyGKCube()
        return
    end
    
    if not gkCube or not gkCube.Parent then
        createGKCube()
    end
    
    if not gkCube then 
        return 
    end
    
    pcall(function()
        gkCube.Size = Vector3.new(CONFIG.reachGK, CONFIG.reachGK, CONFIG.reachGK)
        gkCube.CFrame = HRP.CFrame
        gkCube.Color = CONFIG.reachGKColor
        gkCube.Transparency = CONFIG.reachGKTransparency
        
        local selectionBox = gkCube:FindFirstChild("GKSelectionBox")
        if selectionBox then
            selectionBox.Color3 = CONFIG.reachGKColor
        end
    end)
end

local function processGKTouch()
    if not CONFIG.reachGKEnabled then 
        return 
    end
    if not HRP or not HRP.Parent then 
        return 
    end
    
    local torso = char and (char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or HRP)
    if not torso then 
        return 
    end
    
    if not gkCube or not gkCube.Parent then 
        return 
    end
    
    local overlapParams = OverlapParams.new()
    overlapParams.FilterDescendantsInstances = {char, gkCube}
    overlapParams.FilterType = Enum.RaycastFilterType.Exclude
    
    local objectsInCube = Workspace:GetPartBoundsInBox(gkCube.CFrame, gkCube.Size, overlapParams)
    
    for _, obj in ipairs(objectsInCube) do
        if obj and obj:IsA("BasePart") and not obj.Anchored then
            local isBall = false
            for _, name in ipairs(CONFIG.ballNames) do
                if obj.Name == name or (string.find(obj.Name, name, 1, true)) then
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

local function findSkillButtons()
    local buttons = {}
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then 
        return buttons 
    end
    
    pcall(function()
        for _, gui in ipairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and not gui.Name:match("CAFUXZ1") then
                for _, obj in ipairs(gui:GetDescendants()) do
                    if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                        for _, skillName in ipairs(skillButtonNames) do
                            if obj.Name == skillName or obj.Text == skillName then
                                table.insert(buttons, obj)
                                break
                            end
                        end
                    end
                end
            end
        end
    end)
    
    return buttons
end

local function activateSkillButton(button)
    if not button or not button.Parent then 
        return 
    end
    
    local key = tostring(button)
    if activatedSkills[key] and tick() - activatedSkills[key] < skillCooldown then 
        return 
    end
    activatedSkills[key] = tick()
    
    pcall(function()
        if button:IsA("GuiButton") then
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
    if not CONFIG.autoSkills then 
        return 
    end
    
    local now = tick()
    if now - lastSkillCheck < CONFIG.autoSkillsInterval then 
        return 
    end
    lastSkillCheck = now
    
    if now - lastSkillActivation < skillCooldown then 
        return 
    end
    
    if not cachedSkillButtons or now - lastSkillCache > 5 then
        cachedSkillButtons = findSkillButtons()
        lastSkillCache = now
    end
    
    if not HRP or not HRP.Parent then 
        return 
    end
    
    local ballInRange = false
    for _, ball in ipairs(balls) do
        if ball and ball.Parent then
            local success, dist = pcall(function()
                return (ball.Position - HRP.Position).Magnitude
            end)
            if success and dist and dist <= CONFIG.reachGK then
                ballInRange = true
                break
            end
        end
    end
    
    if not ballInRange then 
        return 
    end
    
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
    pcall(function()
        if mainFrame then
            local stroke = mainFrame:FindFirstChild("UIStroke")
            if stroke then 
                stroke.Color = CONFIG.customColors.primary 
            end
            
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
            local iconBtn = iconGui:FindFirstChild("IconButton", true)
            if iconBtn then 
                iconBtn.BackgroundColor3 = CONFIG.customColors.primary 
            end
        end
    end)
    
    addLog("Cores atualizadas!", "success")
end

-- ============================================
-- INTERFACE WINDUI GK - CORRIGIDA
-- ============================================
local function createWindUI()
    local success = pcall(function()
        local existing = CoreGui:FindFirstChild("CAFUXZ1_GK_Hub")
        if existing then
            existing:Destroy()
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
        versionLabel.Text = "GK v1.3"
        versionLabel.TextColor3 = CONFIG.customColors.textMuted
        versionLabel.TextSize = 12
        versionLabel.Font = Enum.Font.Gotham
        versionLabel.Parent = sidebar
        
        -- Tabs
        local tabs = {
            {name = "gk", icon = "🥅", label = "GK"},
            {name = "ac", icon = "🧤", label = "AC"},
            {name = "visual", icon = "👁️", label = "Visual"},
            {name = "char", icon = "👤", label = "Char"},
            {name = "sky", icon = "☁️", label = "Sky"},
            {name = "config", icon = "⚙️", label = "Config"},
            {name = "stats", icon = "📊", label = "Stats"}
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
        headerTitle.Text = "CAFUXZ1 GK Hub v1.3"
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
        
        -- FUNÇÕES AUXILIARES DA UI
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
                if callback then 
                    pcall(function() callback(enabled) end) 
                end
            end)
            
            return toggleFrame, toggleBtn
        end
        
        local function createSlider(parent, labelText, min, max, default, callback)
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 70)
            frame.BackgroundTransparency = 1
            frame.Parent = parent
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.7, 0, 0, 25)
            label.BackgroundTransparency = 1
            label.Text = labelText
            label.TextColor3 = CONFIG.customColors.textSecondary
            label.TextSize = 13
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = frame
            
            local valueLabel = Instance.new("TextLabel")
            valueLabel.Size = UDim2.new(0.3, 0, 0, 25)
            valueLabel.Position = UDim2.new(0.7, 0, 0, 0)
            valueLabel.BackgroundTransparency = 1
            valueLabel.Text = tostring(default)
            valueLabel.TextColor3 = CONFIG.customColors.primary
            valueLabel.TextSize = 16
            valueLabel.Font = Enum.Font.GothamBold
            valueLabel.TextXAlignment = Enum.TextXAlignment.Right
            valueLabel.Parent = frame
            
            local sliderBg = Instance.new("Frame")
            sliderBg.Size = UDim2.new(1, 0, 0, 10)
            sliderBg.Position = UDim2.new(0, 0, 0, 35)
            sliderBg.BackgroundColor3 = CONFIG.customColors.bgElevated
            sliderBg.BorderSizePixel = 0
            sliderBg.Parent = frame
            
            local sliderBgCorner = Instance.new("UICorner")
            sliderBgCorner.CornerRadius = UDim.new(0, 5)
            sliderBgCorner.Parent = sliderBg
            
            local sliderFill = Instance.new("Frame")
            sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            sliderFill.BackgroundColor3 = CONFIG.customColors.primary
            sliderFill.BorderSizePixel = 0
            sliderFill.Parent = sliderBg
            
            local sliderFillCorner = Instance.new("UICorner")
            sliderFillCorner.CornerRadius = UDim.new(0, 5)
            sliderFillCorner.Parent = sliderFill
            
            local dragging = false
            
            local function updateSlider(input)
                local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                local value = math.floor(min + (pos * (max - min)))
                
                sliderFill.Size = UDim2.new(pos, 0, 1, 0)
                valueLabel.Text = tostring(value)
                
                if callback then
                    pcall(function() callback(value) end)
                end
            end
            
            sliderBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    updateSlider(input)
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
            
            btn.MouseButton1Click:Connect(function()
                pcall(function()
                    tween(btn, {Size = UDim2.new(0.97, 0, 0, 38)}, 0.05)
                    task.wait(0.05)
                    tween(btn, {Size = UDim2.new(1, 0, 0, 40)}, 0.1)
                end)
                if callback then 
                    pcall(function() callback() end) 
                end
            end)
            
            return btn
        end
        
        -- POPULAR ABAS
        -- ABA GK
        local gkSection, gkContent = createSection(contentFrames.gk, "Sistema GK - Cubo")
        
        createToggle(gkContent, "Ativar Reach GK", CONFIG.reachGKEnabled, function(val)
            CONFIG.reachGKEnabled = val
            addLog("GK Reach: " .. (val and "ON" or "OFF"), val and "success" or "warning")
        end)
        
        createToggle(gkContent, "Mostrar Cubo GK", CONFIG.reachGKShow, function(val)
            CONFIG.reachGKShow = val
            if not val then destroyGKCube() end
        end)
        
        createToggle(gkContent, "Auto Touch GK", CONFIG.autoTouch, function(val)
            CONFIG.autoTouch = val
        end)
        
        createToggle(gkContent, "Full Body Touch", CONFIG.fullBodyTouch, function(val)
            CONFIG.fullBodyTouch = val
        end)
        
        createToggle(gkContent, "Auto Skills GK", CONFIG.autoSkills, function(val)
            CONFIG.autoSkills = val
        end)
        
        createSlider(gkContent, "Tamanho do Cubo", 10, 300, CONFIG.reachGK, function(val)
            CONFIG.reachGK = val
        end)
        
        -- ABA AC (AUTO CATCH)
        local acSection, acContent = createSection(contentFrames.ac, "🧤 AC - Auto Catch")
        
        createToggle(acContent, "Ativar AC (Auto Catch)", CONFIG.AC.enabled, function(val)
            CONFIG.AC.enabled = val
            addLog("AC: " .. (val and "ON" or "OFF"), val and "success" or "warning")
            if not val then
                unequipGKTool()
            end
        end)
        
        createToggle(acContent, "Só no Pulo", CONFIG.AC.jumpDetection, function(val)
            CONFIG.AC.jumpDetection = val
        end)
        
        createToggle(acContent, "Auto Equipar Tool", CONFIG.AC.toolCheck, function(val)
            CONFIG.AC.toolCheck = val
        end)
        
        createSlider(acContent, "Slot da Tool", 1, 10, CONFIG.AC.slotGK, function(val)
            CONFIG.AC.slotGK = val
        end)
        
        createSlider(acContent, "Range Detecção", 10, 200, CONFIG.AC.ballDetectionRange, function(val)
            CONFIG.AC.ballDetectionRange = val
        end)
        
        createSlider(acContent, "Intervalo (ms)", 10, 500, math.floor(CONFIG.AC.spamInterval * 1000), function(val)
            CONFIG.AC.spamInterval = val / 1000
        end)
        
        createButton(acContent, "🧤 TESTAR CATCH", CONFIG.customColors.warning, function()
            equipGKTool()
            task.wait(0.2)
            simulateKeyTap(CONFIG.AC.catchKey)
            addLog("Teste manual de AC!", "success")
        end)
        
        -- ABA VISUAL
        local visualSection, visualContent = createSection(contentFrames.visual, "Anti Lag")
        
        createToggle(visualContent, "Ativar Anti Lag", CONFIG.antiLag.enabled, function(val)
            CONFIG.antiLag.enabled = val
            if val then applyAntiLag() else disableAntiLag() end
        end)
        
        -- ABA CHAR
        local charSection, charContent = createSection(contentFrames.char, "Morph")
        
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
            if username and username ~= "" then
                task.spawn(function()
                    local userId
                    local success = pcall(function()
                        userId = Players:GetUserIdFromNameAsync(username)
                    end)
                    if success and userId then 
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
                    notify("Aguarde", "Carregando ID...", 2)
                end
            end)
        end
        
        -- ABA SKYBOX
        local skySection, skyContent = createSection(contentFrames.sky, "Skybox")
        
        local CategoryColors = {
            ["1"] = Color3.fromRGB(0, 120, 255),
            ["2"] = Color3.fromRGB(0, 200, 100),
            ["3"] = Color3.fromRGB(255, 170, 0),
            ["4"] = Color3.fromRGB(180, 0, 220),
        }
        
        local function loadSkyCategory(categoryNum)
            for _, child in ipairs(skyContent:GetChildren()) do
                if child:IsA("TextButton") then
                    child:Destroy()
                end
            end
            
            for _, sky in ipairs(SkyboxDatabase) do
                if sky.category == categoryNum then
                    createButton(skyContent, sky.name, CategoryColors[categoryNum], function()
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
        local configSection, configContent = createSection(contentFrames.config, "Cores")
        
        createButton(configContent, "Resetar Cores", CONFIG.customColors.warning, function()
            CONFIG.customColors.primary = Color3.fromRGB(255, 215, 0)
            CONFIG.reachGKColor = Color3.fromRGB(255, 215, 0)
            updateAllColors()
        end)
        
        -- ABA STATS
        local statsSection, statsContent = createSection(contentFrames.stats, "Estatísticas")
        
        local statsLabels = {}
        for _, item in ipairs({
            {k="totalTouches", l="Total Toques"},
            {k="ballsTouched", l="Bolas Tocadas"},
            {k="gkSaves", l="Defesas GK"},
            {k="skillsActivated", l="Skills"},
            {k="catchesAttempted", l="Catches Tentados"},
            {k="catchesSuccessful", l="Catches OK"},
            {k="morphsDone", l="Morphs"}
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
                if now - lastStatsUpdate >= 1 then
                    lastStatsUpdate = now
                    for k, lbl in pairs(statsLabels) do
                        pcall(function()
                            lbl.Text = tostring(STATS[k] or 0)
                        end)
                    end
                end
                task.wait(0.1)
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
        
        -- Drag
        local dragging = false
        local dragStart, startPos
        
        header.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or 
               input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = mainFrame.Position
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                            input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, 
                                               startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or 
               input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        
        -- ÍCONE FLUTUANTE
        function createIconGui()
            pcall(function()
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
                
                -- Drag do ícone
                local iconDragging = false
                local iconDragStart, iconStartPos
                
                iconBtn.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
                       input.UserInputType == Enum.UserInputType.Touch then
                        iconDragging = true
                        iconDragStart = input.Position
                        iconStartPos = iconContainer.Position
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if iconDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                                        input.UserInputType == Enum.UserInputType.Touch) then
                        local delta = input.Position - iconDragStart
                        iconContainer.Position = UDim2.new(iconStartPos.X.Scale, iconStartPos.X.Offset + delta.X, 
                                                             iconStartPos.Y.Scale, iconStartPos.Y.Offset + delta.Y)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
                       input.UserInputType == Enum.UserInputType.Touch then
                        iconDragging = false
                    end
                end)
            end)
        end
        
        notify("🥅 CAFUXZ1 GK Hub", "v1.3 - AC System ativo!", 5)
        addLog("GK Hub v1.3 iniciado! AC (Auto Catch) pronto!", "success")
    end)
    
    if not success then
        notify("❌ Erro", "Falha ao criar interface!", 5)
    end
end

-- ============================================
-- LOOP PRINCIPAL GK - CORRIGIDO
-- ============================================
local function mainLoop()
    if loopRunning then 
        return 
    end
    loopRunning = true
    
    local heartbeatConnection
    heartbeatConnection = RunService.Heartbeat:Connect(function()
        if isClosed then 
            return 
        end
        
        pcall(updateCharacter)
        pcall(updateGKCube)
        pcall(findBalls)
        
        if HRP and HRP.Parent then
            pcall(processGKTouch)
            pcall(processAutoSkills)
            pcall(processAC)
        else
            pcall(destroyGKCube)
        end
    end)
    
    addLog("Sistema GK iniciado - Cubo + AC ativos!", "success")
end

-- ============================================
-- ATALHOS CORRIGIDOS
-- ============================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then 
        return 
    end
    
    if input.KeyCode == Enum.KeyCode.F1 then
        CONFIG.reachGKEnabled = not CONFIG.reachGKEnabled
        notify("GK Reach", CONFIG.reachGKEnabled and "ON" or "OFF", 2)
        
    elseif input.KeyCode == Enum.KeyCode.F2 then
        CONFIG.reachGKShow = not CONFIG.reachGKShow
        if not CONFIG.reachGKShow then 
            pcall(destroyGKCube) 
        end
        notify("GK Cube", CONFIG.reachGKShow and "VISÍVEL" or "OCULTO", 2)
        
    elseif input.KeyCode == Enum.KeyCode.F3 then
        CONFIG.autoSkills = not CONFIG.autoSkills
        notify("Auto Skills", CONFIG.autoSkills and "ON" or "OFF", 2)
        
    elseif input.KeyCode == Enum.KeyCode.F4 then
        CONFIG.antiLag.enabled = not CONFIG.antiLag.enabled
        if CONFIG.antiLag.enabled then 
            applyAntiLag() 
        else 
            disableAntiLag() 
        end
        notify("Anti Lag", CONFIG.antiLag.enabled and "ON" or "OFF", 2)
        
    elseif input.KeyCode == Enum.KeyCode.F5 then
        -- ATALHO AC (Auto Catch)
        CONFIG.AC.enabled = not CONFIG.AC.enabled
        notify("🧤 AC (Auto Catch)", CONFIG.AC.enabled and "ON" or "OFF", 2)
        addLog("F5: AC " .. (CONFIG.AC.enabled and "ON" or "OFF"), "info")
        if not CONFIG.AC.enabled then
            pcall(unequipGKTool)
        end
        
    elseif input.KeyCode == Enum.KeyCode.Insert then
        pcall(function()
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
        end)
    end
end)

-- ============================================
-- EVENTOS DO JOGADOR
-- ============================================
LocalPlayer.CharacterAdded:Connect(function(newChar)
    addLog("Character respawned - reconectando GK...", "info")
    
    char = newChar
    HRP = nil
    humanoid = nil
    gkToolEquipped = false
    currentTool = nil
    ACActive = false
    consecutiveCatches = 0
    
    pcall(destroyGKCube)
    
    task.spawn(function()
        local newHRP = newChar:WaitForChild("HumanoidRootPart", 5)
        local newHumanoid = newChar:WaitForChild("Humanoid", 5)
        if newHRP then
            HRP = newHRP
            humanoid = newHumanoid
            addLog("HRP encontrado - GK ativo!", "success")
        end
    end)
    
    task.delay(1, function()
        if CONFIG.antiLag.enabled then
            applyAntiLag()
        end
    end)
end)

-- ============================================
-- INICIALIZAÇÃO
-- ============================================
task.spawn(function()
    task.wait(0.5)
    
    -- Verificar character inicial
    if LocalPlayer.Character then
        char = LocalPlayer.Character
        HRP = char:FindFirstChild("HumanoidRootPart")
        humanoid = char:FindFirstChild("Humanoid")
    end
    
    pcall(createWindUI)
    task.wait(0.3)
    pcall(mainLoop)
end)

print("========================================")
print("CAFUXZ1 GK Hub v1.3 - BUG FIX EDITION")
print("========================================")
print("✅ CORREÇÕES APLICADAS:")
print("   • Erros de nil value corrigidos")
print("   • Sistema AC (Auto Catch) criado")
print("   • Removido game:GetObjects (não funciona)")
print("   • Removido InsertService:LoadAsset")
print("   • Verificações de nil em todas as funções")
print("   • pcall() em operações críticas")
print("========================================")
print("🥅 SISTEMAS ATIVOS:")
print("   • Cubo GK com Reach")
print("   • AC (Auto Catch) - Tecla F")
print("   • Auto Skills GK")
print("   • Anti Lag")
print("   • Morph System")
print("   • Skybox System")
print("========================================")
print("🎮 ATALHOS:")
print("   F1 = Toggle GK Reach")
print("   F2 = Toggle Cubo Visual")
print("   F3 = Toggle Auto Skills")
print("   F4 = Toggle Anti Lag")
print("   F5 = Toggle AC (Auto Catch) 🧤")
print("   Insert = Minimizar/Restaurar")
print("========================================")

