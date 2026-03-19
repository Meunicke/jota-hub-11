

local suc, err = pcall(function()
    return game:GetService("Players")
end)

if not suc then
    -- Se falhou, aguardar e tentar novamente
    repeat
        task.wait(0.1)
        suc, err = pcall(function()
            return game:GetService("Players")
        end)
    until suc
end

-- Agora sim, obter todos os serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart", 5)
-- Aguardar personagem
while not LocalPlayer.Character do
    task.wait(0.1)
end




-- ============================================
-- LIMPEZA ANTI-DUPLICAÇÃO
-- ============================================
pcall(function()
    for _, obj in ipairs(CoreGui:GetChildren()) do
        if obj.Name == "CAFUXZ1_Hub_v15" or obj.Name == "CAFUXZ1_Icon_v15" or obj.Name == "CAFUXZ1_Intro" then
            obj:Destroy()
        end
    end
end)

pcall(function()
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj.Name == "CAFUXZ1_ReachSphere_v15" or obj.Name == "CAFUXZ1_ArthurSphere_v15" then
            obj:Destroy()
        end
    end
end)

-- ============================================
-- CONFIGURAÇÕES
-- ============================================
local CONFIG = {
    width = 600,
    height = 450,
    sidebarWidth = 90,
    
    reach = 15,
    showReachSphere = true,
    autoTouch = true,
    fullBodyTouch = true,
    autoSecondTouch = true,
    scanCooldown = 1.5,
    
    arthurSphere = {
        reach = 10,
        color = Color3.fromRGB(0, 255, 255),
        transparency = 0.75,
        material = Enum.Material.ForceField
    },
    
    antiLag = {
        enabled = false,
        textures = true,
        visualEffects = true,
        parts = true,
        particles = true,
        sky = true,
        fullBright = false
    },
    
    customColors = {
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
    },
    
    ballNames = { 
        "TPS", "TCS", "ESA", "MRS", "PRS", "MPS", "SSS", "AIFA", "RBZ",
        "Ball", "Soccer", "Football", "Basketball", "Baseball", 
        "BallTemplate", "GameBall", "Hitbox", "TouchPart", "GoalBall",
        "Physics", "Interaction", "Trigger", "Touch", "Hit", "Box",
        " bola", "Bola", "BALL", "SOCCER", "FOOTBALL", "SoccerBall"
    }
}

-- ============================================
-- ESTATÍSTICAS E LOGS
-- ============================================
local STATS = {
    totalTouches = 0,
    ballsTouched = 0,
    sessionStart = tick(),
    skillsActivated = 0,
    antiLagItems = 0,
    morphsDone = 0
}

local LOGS = {}
local MAX_LOGS = 50

local function addLog(message, type)
    type = type or "info"
    table.insert(LOGS, 1, {
        message = tostring(message),
        type = tostring(type),
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
local reachSphere = nil
local arthurSphere = nil
local touchDebounce = {}
local lastBallUpdate = 0
local lastTouch = 0
local isMinimized = false
local isClosed = false
local mainGui = nil
local mainFrame = nil
local iconGui = nil
local introGui = nil
local currentTab = "reach"
local autoSkills = true
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
            Title = tostring(title) or "⚡ CAFUXZ1 Hub",
            Text = tostring(text) or "",
            Duration = tonumber(duration) or 3
        })
    end)
end

local function tween(obj, props, time, style, dir, callback)
    if not obj or not obj.Parent then return nil end
    
    time = tonumber(time) or 0.35
    style = style or Enum.EasingStyle.Quint
    dir = dir or Enum.EasingDirection.Out
    
    local success, result = pcall(function()
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
-- INTRO ANIMADA
-- ============================================
local function createIntro()
    local success, err = pcall(function()
        introGui = Instance.new("ScreenGui")
        introGui.Name = "CAFUXZ1_Intro"
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
        icon.Text = "⚡"
        icon.TextColor3 = CONFIG.customColors.primary
        icon.TextSize = 80
        icon.Font = Enum.Font.GothamBold
        icon.Parent = container
        
        local title = Instance.new("TextLabel")
        title.Name = "Title"
        title.Size = UDim2.new(1, 0, 0, 50)
        title.Position = UDim2.new(0, 0, 0, 130)
        title.BackgroundTransparency = 1
        title.Text = "CAFUXZ1 Hub"
        title.TextColor3 = CONFIG.customColors.textPrimary
        title.TextSize = 36
        title.Font = Enum.Font.GothamBold
        title.Parent = container
        
        local version = Instance.new("TextLabel")
        version.Name = "Version"
        version.Size = UDim2.new(1, 0, 0, 30)
        version.Position = UDim2.new(0, 0, 0, 180)
        version.BackgroundTransparency = 1
        version.Text = "Versão 15.2 - Double Sphere"
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
        updatesText.Text = "🆕 NOVIDADES v15.2:\n\n" ..
                           "• DUAS ESFERAS SINCRONIZADAS\n" ..
                           "• Esfera Pura (Principal)\n" ..
                           "• Esfera Arthur V2 (Double Touch)\n" ..
                           "• Double Touch = Esfera Arthur ativa\n" ..
                           "• Esferas sempre JUNTAS\n\n" ..
                           "📱 ARRASTE O ÍCONE ⚡ PARA MOVER"
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
        enterBtn.TextColor3 = Color3.new(1, 1, 1)
        enterBtn.TextSize = 18
        enterBtn.Font = Enum.Font.GothamBold
        enterBtn.Parent = container
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 10)
        btnCorner.Parent = enterBtn
        
        -- Animações
        task.spawn(function()
            task.wait(0.2)
            
            pcall(function() tween(icon, {TextTransparency = 0}, 0.5) end)
            task.wait(0.3)
            pcall(function() tween(title, {TextTransparency = 0}, 0.5) end)
            task.wait(0.2)
            pcall(function() tween(version, {TextTransparency = 0}, 0.5) end)
            task.wait(0.2)
            pcall(function() tween(line, {Size = UDim2.new(0.8, 0, 0, 2)}, 0.6) end)
            task.wait(0.3)
            pcall(function() tween(updatesText, {TextTransparency = 0}, 0.5) end)
            task.wait(0.3)
            pcall(function() tween(enterBtn, {BackgroundTransparency = 0.2, TextTransparency = 0}, 0.5) end)
        end)
        
        -- Animação pulso do botão
        task.spawn(function()
            while enterBtn and enterBtn.Parent do
                pcall(function()
                    tween(enterBtn, {Size = UDim2.new(0, 205, 0, 47)}, 0.5)
                end)
                task.wait(0.5)
                if not enterBtn or not enterBtn.Parent then break end
                pcall(function()
                    tween(enterBtn, {Size = UDim2.new(0, 200, 0, 45)}, 0.5)
                end)
                task.wait(0.5)
            end
        end)
        
        -- Fechar intro
        local function closeIntro()
            pcall(function()
                tween(bg, {BackgroundTransparency = 1}, 0.5)
                tween(container, {Position = UDim2.new(0.5, -250, 0.5, -100), Size = UDim2.new(0, 500, 0, 0)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In, function()
                    if introGui then
                        introGui:Destroy()
                        introGui = nil
                    end
                end)
            end)
        end
        
        enterBtn.MouseButton1Click:Connect(closeIntro)
        
        task.delay(10, function()
            if introGui and introGui.Parent then 
                closeIntro() 
            end
        end)
    end)
    
    if not success then
        warn("Erro na intro: " .. tostring(err))
        -- Continua sem intro se der erro
        introGui = nil
    end
end

-- ============================================
-- SISTEMA ANTI LAG
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
-- SISTEMA DE MORPH
-- ============================================
local PRESET_MORPHS = {
    { name = "Miguelcalebegamer202", userId = nil, displayName = "Miguelcalebegamer202" },
    { name = "Tottxii", userId = nil, displayName = "Tottxii" },
    { name = "Feliou23", userId = nil, displayName = "Feliou23 (cb)" },
    { name = "venxcore", userId = nil, displayName = "venxcore (cb)" },
    { name = "AlissonGkBe", userId = nil, displayName = "AlissonGkBe (extra,gk)" }
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
        notify("Morph", "User ID não encontrado!", 3) 
        return 
    end
    
    if userId == LocalPlayer.UserId then 
        notify("Morph", "Não pode morphar em si mesmo!", 3) 
        return 
    end
    
    local character = LocalPlayer.Character
    if not character then
        notify("Morph", "Character não encontrado!", 3)
        return
    end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then 
        notify("Morph", "Humanoid não encontrado!", 3) 
        return 
    end

    local desc
    local success = pcall(function()
        desc = Players:GetHumanoidDescriptionFromUserId(userId)
    end)
    
    if not success or not desc then 
        notify("Morph", "Falha ao carregar avatar!", 3) 
        return 
    end

    -- Limpar acessórios atuais
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

        humanoid:ApplyDescriptionClientServer(desc)
    end)
    
    STATS.morphsDone = STATS.morphsDone + 1
    notify("Morph", "Morph aplicado: " .. tostring(targetName) .. "!", 3)
    addLog("Morph: " .. tostring(targetName), "success")
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
    
    local success = pcall(function()
        local objects = game:GetObjects("rbxassetid://" .. tostring(assetId))
        if objects and #objects > 0 then
            local source = objects[1]
            if source:IsA("Sky") then
                local sky = source:Clone()
                sky.Name = "CAFUXZ1_Sky_" .. tostring(assetId)
                sky.Parent = Lighting
                return true
            end
            if source:IsA("Model") or source:IsA("Folder") then
                for _, child in ipairs(source:GetDescendants()) do
                    if child:IsA("Sky") then
                        local sky = child:Clone()
                        sky.Name = "CAFUXZ1_Sky_" .. tostring(assetId)
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
    
    if success then 
        currentSkybox = assetId 
        return true 
    end
    
    -- Fallback: criar sky genérico
    success = pcall(function()
        local sky = Instance.new("Sky")
        sky.Name = "CAFUXZ1_Sky_Generic_" .. tostring(assetId)
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
    end
    
    return success
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
-- SISTEMA DE BOLAS E REACH (DOUBLE SPHERE)
-- ============================================
local function updateCharacter()
    local newChar = LocalPlayer.Character
    if newChar then
        Character = newChar
        local newHRP = newChar:FindFirstChild("HumanoidRootPart")
        if newHRP then
            HRP = newHRP
        end
    end
end

local function findBalls()
    local now = tick()
    if now - lastBallUpdate < CONFIG.scanCooldown then 
        return #balls 
    end
    lastBallUpdate = now
    
    -- Limpar lista atual
    for i = #balls, 1, -1 do
        balls[i] = nil
    end
    
    -- Desconectar conexões antigas
    for _, conn in ipairs(ballConnections) do
        pcall(function() 
            conn:Disconnect() 
        end)
    end
    for i = #ballConnections, 1, -1 do
        ballConnections[i] = nil
    end
    
    -- Procurar bolas
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
    if not Character then 
        return {} 
    end
    
    local parts = {}
    for _, part in ipairs(Character:GetChildren()) do
        if part and part:IsA("BasePart") then
            if CONFIG.fullBodyTouch then
                table.insert(parts, part)
            elseif part.Name == "HumanoidRootPart" then
                table.insert(parts, part)
            end
        end
    end
    return parts
end

-- ============================================
-- ESFERA PURA (Principal)
-- ============================================
local function createReachSphere()
    if reachSphere and reachSphere.Parent then 
        return 
    end
    
    pcall(function()
        reachSphere = Instance.new("Part")
        reachSphere.Name = "CAFUXZ1_ReachSphere_v15"
        reachSphere.Shape = Enum.PartType.Ball
        reachSphere.Anchored = true
        reachSphere.CanCollide = false
        reachSphere.Transparency = 0.88
        reachSphere.Material = Enum.Material.ForceField
        reachSphere.Color = CONFIG.customColors.primary
        reachSphere.Parent = Workspace
    end)
end

local function destroyReachSphere()
    if reachSphere then
        pcall(function()
            reachSphere:Destroy()
        end)
        reachSphere = nil
    end
end

local function updateReachSphere()
    if not CONFIG.showReachSphere then
        destroyReachSphere()
        return
    end
    
    createReachSphere()
    
    if not reachSphere then 
        return 
    end
    
    if HRP and HRP.Parent then
        pcall(function()
            reachSphere.Position = HRP.Position
            reachSphere.Size = Vector3.new(CONFIG.reach * 2, CONFIG.reach * 2, CONFIG.reach * 2)
            reachSphere.Color = CONFIG.customColors.primary
            reachSphere.Transparency = 0.88
        end)
    end
end

-- ============================================
-- ESFERA ARTHUR V2 (Double Touch)
-- ============================================
local function createArthurSphere()
    if arthurSphere and arthurSphere.Parent then 
        return 
    end
    
    pcall(function()
        arthurSphere = Instance.new("Part")
        arthurSphere.Name = "CAFUXZ1_ArthurSphere_v15"
        arthurSphere.Shape = Enum.PartType.Ball
        arthurSphere.Anchored = true
        arthurSphere.CanCollide = false
        arthurSphere.Material = CONFIG.arthurSphere.material
        arthurSphere.Transparency = 1 -- Começa invisível
        arthurSphere.Color = CONFIG.arthurSphere.color
        arthurSphere.Parent = Workspace
    end)
end

local function destroyArthurSphere()
    if arthurSphere then
        pcall(function()
            arthurSphere:Destroy()
        end)
        arthurSphere = nil
    end
end

local function updateArthurSphere()
    createArthurSphere()
    
    if not arthurSphere then 
        return 
    end
    
    -- Só mostra se Double Touch estiver ON e esferas visíveis
    local shouldShow = CONFIG.showReachSphere and CONFIG.autoSecondTouch
    
    if HRP and HRP.Parent then
        pcall(function()
            arthurSphere.Position = HRP.Position
            arthurSphere.Size = Vector3.new(CONFIG.arthurSphere.reach * 2, CONFIG.arthurSphere.reach * 2, CONFIG.arthurSphere.reach * 2)
            arthurSphere.Color = CONFIG.arthurSphere.color
            arthurSphere.Transparency = shouldShow and CONFIG.arthurSphere.transparency or 1
        end)
    end
end

-- ============================================
-- CONTROLE DAS ESFERAS
-- ============================================
local function updateBothSpheres()
    updateReachSphere()
    updateArthurSphere()
end

local function destroyBothSpheres()
    destroyReachSphere()
    destroyArthurSphere()
end

local function setSpheresVisible(visible)
    CONFIG.showReachSphere = visible
    if not visible then
        destroyBothSpheres()
    else
        updateBothSpheres()
    end
    addLog("Esferas " .. (visible and "VISÍVEIS" or "OCULTAS"), "info")
end

-- ============================================
-- TOUCH SYSTEM
-- ============================================
local function doTouch(ball, part)
    if not ball or not ball.Parent or not part or not part.Parent then 
        return 
    end
    
    local key = tostring(ball.Name) .. "_" .. tostring(part.Name) .. "_" .. tostring(ball:GetFullName())
    if touchDebounce[key] and tick() - touchDebounce[key] < 0.1 then 
        return 
    end
    touchDebounce[key] = tick()
    
    pcall(function()
        firetouchinterest(ball, part, 0)
        task.wait(0.01)
        firetouchinterest(ball, part, 1)
        
        if CONFIG.autoSecondTouch then
            task.wait(0.05)
            firetouchinterest(ball, part, 0)
            firetouchinterest(ball, part, 1)
        end
    end)
end

local function processAutoTouch()
    if not CONFIG.autoTouch then 
        return 
    end
    
    if not HRP or not HRP.Parent then 
        return 
    end
    
    local now = tick()
    if now - lastTouch < 0.05 then 
        return 
    end
    
    local hrpPos = HRP.Position
    local characterParts = getBodyParts()
    if #characterParts == 0 then 
        return 
    end
    
    local ballInRange = false
    local closestBall = nil
    local closestDistance = CONFIG.reach
    
    for _, ball in ipairs(balls) do
        if ball and ball.Parent then
            local success, distance = pcall(function()
                return (ball.Position - hrpPos).Magnitude
            end)
            
            if success and distance and distance <= CONFIG.reach and distance < closestDistance then
                ballInRange = true
                closestDistance = distance
                closestBall = ball
            end
        end
    end
    
    if ballInRange and closestBall then
        lastTouch = now
        
        for _, part in ipairs(characterParts) do
            doTouch(closestBall, part)
        end
        
        STATS.totalTouches = STATS.totalTouches + 1
        STATS.ballsTouched = STATS.ballsTouched + 1
    end
end

-- ============================================
-- AUTO SKILLS
-- ============================================
local cachedSkillButtons = nil
local lastSkillCache = 0

local function findSkillButtons()
    local buttons = {}
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then 
        return buttons 
    end
    
    pcall(function()
        for _, gui in ipairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name ~= "CAFUXZ1_Hub_v15" and gui.Name ~= "CAFUXZ1_Icon_v15" then
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
            -- Tentar diferentes métodos de ativação
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
    if not autoSkills then 
        return 
    end
    
    local now = tick()
    if now - lastSkillCheck < skillCheckInterval then 
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
    
    local hrpPos = HRP.Position
    local ballInRange = false
    
    for _, ball in ipairs(balls) do
        if ball and ball.Parent then
            local success, dist = pcall(function()
                return (ball.Position - hrpPos).Magnitude
            end)
            if success and dist and dist <= CONFIG.reach then
                ballInRange = true
                break
            end
        end
    end
    
    if not ballInRange then 
        return 
    end
    
    lastSkillActivation = now
    
    local mainSkills = {"Shoot", "Pass", "Dribble", "Control"}
    for _, button in ipairs(cachedSkillButtons) do
        for _, mainSkill in ipairs(mainSkills) do
            if button.Name == mainSkill or button.Text == mainSkill then
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
        
        if reachSphere then
            reachSphere.Color = CONFIG.customColors.primary
        end
        
        if arthurSphere then
            arthurSphere.Color = CONFIG.arthurSphere.color
        end
        
        if iconGui then
            local iconBtn = iconGui:FindFirstChild("IconButton")
            if iconBtn then 
                iconBtn.BackgroundColor3 = CONFIG.customColors.primary 
            end
        end
    end)
    
    addLog("Cores atualizadas!", "success")
end

-- ============================================
-- INTERFACE WINDUI
-- ============================================
local function createWindUI()
    local success, err = pcall(function()
        -- Verificar se já existe e destruir
        local existing = CoreGui:FindFirstChild("CAFUXZ1_Hub_v15")
        if existing then
            existing:Destroy()
        end
        
        isClosed = false
        
        -- Criar GUI principal
        mainGui = Instance.new("ScreenGui")
        mainGui.Name = "CAFUXZ1_Hub_v15"
        mainGui.ResetOnSpawn = false
        mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        mainGui.Parent = CoreGui
        
        -- Frame principal
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
        
        -- Corner e Stroke
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
        
        -- Título sidebar
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, 0, 0, 50)
        titleLabel.Position = UDim2.new(0, 0, 0, 10)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = "⚡"
        titleLabel.TextColor3 = CONFIG.customColors.primary
        titleLabel.TextSize = 32
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.Parent = sidebar
        
        local versionLabel = Instance.new("TextLabel")
        versionLabel.Size = UDim2.new(1, 0, 0, 20)
        versionLabel.Position = UDim2.new(0, 0, 0, 55)
        versionLabel.BackgroundTransparency = 1
        versionLabel.Text = "v15.2"
        versionLabel.TextColor3 = CONFIG.customColors.textMuted
        versionLabel.TextSize = 12
        versionLabel.Font = Enum.Font.Gotham
        versionLabel.Parent = sidebar
        
        -- Tabs
        local tabs = {
            {name = "reach", icon = "⚽", label = "Reach"},
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
        headerTitle.Text = "CAFUXZ1 Hub v15.2"
        headerTitle.TextColor3 = CONFIG.customColors.textPrimary
        headerTitle.TextSize = 18
        headerTitle.Font = Enum.Font.GothamBold
        headerTitle.TextXAlignment = Enum.TextXAlignment.Left
        headerTitle.Parent = header
        
        -- Botões header
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
            sectionTitle.Text = "◆ " .. tostring(title)
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
            label.Text = tostring(text)
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
                    callback(enabled) 
                end
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
            label.Text = tostring(labelText)
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
            input.PlaceholderText = "Valor..."
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
            applyBtn.Text = "OK"
            applyBtn.TextColor3 = Color3.new(1, 1, 1)
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
            currentLabel.Text = "Atual: " .. tostring(defaultValue)
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
                    currentLabel.Text = "Atual: " .. num
                    if callback then 
                        callback(num) 
                    end
                    addLog(tostring(labelText) .. ": " .. num, "success")
                else
                    input.Text = tostring(defaultValue)
                    notify("Erro", "Digite um número!", 2)
                end
            end
            
            applyBtn.MouseButton1Click:Connect(applyValue)
            input.FocusLost:Connect(function(enterPressed)
                if enterPressed then 
                    applyValue() 
                end
            end)
            
            return frame
        end
        
        local function createButton(parent, text, color, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 40)
            btn.BackgroundColor3 = color or CONFIG.customColors.primary
            btn.Text = tostring(text)
            btn.TextColor3 = Color3.new(1, 1, 1)
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
                    callback() 
                end
            end)
            
            return btn
        end
        
        -- POPULAR ABA REACH
        local reachSection, reachContent = createSection(contentFrames.reach, "Configurações de Reach")
        
        createToggle(reachContent, "Auto Touch", CONFIG.autoTouch, function(val)
            CONFIG.autoTouch = val
            addLog("Auto Touch: " .. (val and "ON" or "OFF"), val and "success" or "warning")
        end)
        
        createToggle(reachContent, "Full Body Touch", CONFIG.fullBodyTouch, function(val)
            CONFIG.fullBodyTouch = val
        end)
        
        -- Double Touch = Esfera Arthur
        createToggle(reachContent, "Double Touch (Arthur)", CONFIG.autoSecondTouch, function(val)
            CONFIG.autoSecondTouch = val
            updateArthurSphere()
            addLog("Double Touch: " .. (val and "ON" or "OFF"), val and "success" or "warning")
        end)
        
        -- Toggle único para ambas as esferas
        createToggle(reachContent, "Mostrar Esferas", CONFIG.showReachSphere, function(val)
            setSpheresVisible(val)
        end)
        
        createToggle(reachContent, "Auto Skills", autoSkills, function(val)
            autoSkills = val
            addLog("Auto Skills: " .. (val and "ON" or "OFF"), val and "success" or "warning")
        end)
        
        createNumberInput(reachContent, "Alcance Principal", CONFIG.reach, 5, 100, function(val)
            CONFIG.reach = val
        end)
        
        createNumberInput(reachContent, "Alcance Arthur", CONFIG.arthurSphere.reach, 1, 150, function(val)
            CONFIG.arthurSphere.reach = val
        end)
        
        -- ABA VISUAL
        local visualSection, visualContent = createSection(contentFrames.visual, "Anti Lag")
        
        createToggle(visualContent, "Ativar Anti Lag", CONFIG.antiLag.enabled, function(val)
            CONFIG.antiLag.enabled = val
            if val then 
                applyAntiLag() 
            else 
                disableAntiLag() 
            end
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
            if username and username ~= "" then
                task.spawn(function()
                    local userId
                    local success = pcall(function()
                        userId = Players:GetUserIdFromNameAsync(username)
                    end)
                    if success and userId then 
                        morphToUser(userId, username) 
                    end
                end)
            end
        end)
        
        for _, preset in ipairs(PRESET_MORPHS) do
            createButton(charContent, preset.displayName, CONFIG.customColors.bgElevated, function()
                if preset.userId then 
                    morphToUser(preset.userId, preset.displayName) 
                end
            end)
        end
        
        -- ABA SKYBOX
        local skySection, skyContent = createSection(contentFrames.sky, "Skybox System")
        
        local CategoryColors = {
            ["1"] = Color3.fromRGB(0, 120, 255),
            ["2"] = Color3.fromRGB(0, 200, 100),
            ["3"] = Color3.fromRGB(255, 170, 0),
            ["4"] = Color3.fromRGB(180, 0, 220),
        }
        
        local function loadSkyCategory(categoryNum)
            -- Limpar frame de itens
            for _, child in ipairs(skyContent:GetChildren()) do
                if child.Name ~= "UIListLayout" and child:IsA("Frame") then
                    child:Destroy()
                end
            end
            
            -- Criar container para botões de skybox
            local skyItemsFrame = Instance.new("Frame")
            skyItemsFrame.Size = UDim2.new(1, 0, 0, 0)
            skyItemsFrame.AutomaticSize = Enum.AutomaticSize.Y
            skyItemsFrame.BackgroundTransparency = 1
            skyItemsFrame.Parent = skyContent
            
            local itemsLayout = Instance.new("UIListLayout")
            itemsLayout.Padding = UDim.new(0, 8)
            itemsLayout.Parent = skyItemsFrame
            
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
        
        -- Color pickers simplificados
        local function createSimpleColorPicker(parent, labelText, defaultColor, callback)
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 35)
            frame.BackgroundTransparency = 1
            frame.Parent = parent
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.6, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = tostring(labelText)
            label.TextColor3 = CONFIG.customColors.textSecondary
            label.TextSize = 13
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = frame
            
            local colorBtn = Instance.new("TextButton")
            colorBtn.Size = UDim2.new(0, 60, 0, 30)
            colorBtn.Position = UDim2.new(1, -60, 0.5, -15)
            colorBtn.BackgroundColor3 = defaultColor
            colorBtn.Text = ""
            colorBtn.Parent = frame
            
            local colorCorner = Instance.new("UICorner")
            colorCorner.CornerRadius = UDim.new(0, 6)
            colorCorner.Parent = colorBtn
            
            -- Cores predefinidas
            colorBtn.MouseButton1Click:Connect(function()
                local colors = {
                    Color3.fromRGB(99, 102, 241),
                    Color3.fromRGB(0, 255, 255),
                    Color3.fromRGB(255, 0, 0),
                    Color3.fromRGB(0, 255, 0),
                    Color3.fromRGB(255, 255, 0),
                    Color3.fromRGB(255, 0, 255),
                }
                local currentIndex = 1
                for i, c in ipairs(colors) do
                    if c == colorBtn.BackgroundColor3 then
                        currentIndex = i
                        break
                    end
                end
                local nextColor = colors[(currentIndex % #colors) + 1]
                colorBtn.BackgroundColor3 = nextColor
                if callback then
                    callback(nextColor)
                end
            end)
            
            return frame
        end
        
        createSimpleColorPicker(configContent, "Cor Principal", CONFIG.customColors.primary, function(c) 
            CONFIG.customColors.primary = c
            updateAllColors()
        end)
        
        createSimpleColorPicker(configContent, "Cor Arthur", CONFIG.arthurSphere.color, function(c) 
            CONFIG.arthurSphere.color = c
            if arthurSphere then
                arthurSphere.Color = c
            end
        end)
        
        -- ABA STATS
        local statsSection, statsContent = createSection(contentFrames.stats, "Estatísticas")
        
        local statsLabels = {}
        local statItems = {
            {k="totalTouches", l="Total Toques"},
            {k="ballsTouched", l="Bolas Tocadas"},
            {k="skillsActivated", l="Skills Ativadas"},
            {k="morphsDone", l="Morphs Realizados"}
        }
        
        for _, item in ipairs(statItems) do
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
                        pcall(function()
                            lbl.Text = tostring(STATS[k] or 0)
                        end)
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
                    pcall(function()
                        local log = LOGS[i]
                        if log then
                            lbl.Text = string.format("[%s] %s", log.time, log.message)
                            lbl.TextColor3 = (log.type == "success" and CONFIG.customColors.success) or 
                                            (log.type == "warning" and CONFIG.customColors.warning) or 
                                            CONFIG.customColors.textSecondary
                            lbl.Visible = true
                        else
                            lbl.Visible = false
                        end
                    end)
                end
                
                pcall(function()
                    logsList.CanvasSize = UDim2.new(0, 0, 0, math.min(#LOGS, 20) * 24)
                end)
                
                task.wait(0.5)
            end
        end)
        
        -- NAVEGAÇÃO
        local function switchTab(tabName)
            currentTab = tabName
            for name, btn in pairs(tabButtons) do
                if name == tabName then
                    pcall(function()
                        tween(btn, {BackgroundColor3 = CONFIG.customColors.primary}, 0.2)
                    end)
                    btn.TextColor3 = CONFIG.customColors.textPrimary
                else
                    pcall(function()
                        tween(btn, {BackgroundColor3 = CONFIG.customColors.bgElevated}, 0.2)
                    end)
                    btn.TextColor3 = CONFIG.customColors.textSecondary
                end
            end
            for name, frame in pairs(contentFrames) do
                frame.Visible = (name == tabName)
            end
        end
        
        for name, btn in pairs(tabButtons) do
            btn.MouseButton1Click:Connect(function() 
                switchTab(name) 
            end)
        end
        
        switchTab("reach")
        
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
            if iconGui then 
                iconGui.Enabled = false 
            end
            addLog("Interface restaurada", "info")
        end
        
        minimizeBtn.MouseButton1Click:Connect(minimizeUI)
        closeBtn.MouseButton1Click:Connect(minimizeUI)
        
        -- DRAG DO MAIN FRAME
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
        
        UserInputService.InputEnded:Connect
        function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or 
               input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        
        -- ÍCONE FLUTUANTE
        function createIconGui()
            pcall(function()
                local existing = CoreGui:FindFirstChild("CAFUXZ1_Icon_v15")
                if existing then
                    existing:Destroy()
                end
                
                iconGui = Instance.new("ScreenGui")
                iconGui.Name = "CAFUXZ1_Icon_v15"
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
                iconBtn.Text = "⚡"
                iconBtn.TextColor3 = Color3.new(1, 1, 1)
                iconBtn.TextSize = 32
                iconBtn.Font = Enum.Font.GothamBold
                iconBtn.Parent = iconContainer
                
                local iconCorner = Instance.new("UICorner")
                iconCorner.CornerRadius = UDim.new(1, 0)
                iconCorner.Parent = iconBtn
                
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
                
                -- Drag do ícone
                local iconDragging = false
                local iconDragStart, iconStartPos
                
                iconBtn.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
                       input.UserInputType == Enum.UserInputType.Touch then
                        iconDragging = true
                        iconDragStart = input.Position
                        iconStartPos = iconContainer.Position
                        
                        pcall(function()
                            tween(iconBtn, {Size = UDim2.new(0, 65, 0, 65), 
                                          Position = UDim2.new(0.5, -32.5, 0.5, -32.5)}, 0.1)
                        end)
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
                        
                        pcall(function()
                            tween(iconBtn, {Size = UDim2.new(0, 60, 0, 60), 
                                          Position = UDim2.new(0.5, -30, 0.5, -30)}, 0.1)
                        end)
                    end
                end)
            end)
        end
        
        addLog("Hub v15.2 iniciado! (Double Sphere)", "success")
        notify("CAFUXZ1 Hub", "v15.2 - Double Touch = Esfera Arthur!", 5)
    end)
    
    if not success then
        warn("Erro ao criar interface: " .. tostring(err))
        notify("Erro", "Falha ao criar interface!", 5)
    end
end

-- ============================================
-- LOOP PRINCIPAL (DOUBLE SPHERE)
-- ============================================
local function mainLoop()
    if loopRunning then 
        return 
    end
    loopRunning = true
    
    heartbeatConnection = RunService.Heartbeat:Connect(function()
        if isClosed then 
            return 
        end
        
        -- Atualizar character e HRP
        pcall(updateCharacter)
        
        -- Atualizar ambas as esferas
        pcall(updateBothSpheres)
        
        -- Procurar bolas
        pcall(findBalls)
        
        -- Processar touch e skills se HRP existir
        if HRP and HRP.Parent then
            pcall(processAutoTouch)
            pcall(processAutoSkills)
        else
            pcall(destroyBothSpheres)
        end
    end)
    
    addLog("Sistema Reach iniciado - Double Sphere!", "success")
end

-- ============================================
-- ATALHOS (DOUBLE SPHERE)
-- ============================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then 
        return 
    end
    
    if input.KeyCode == Enum.KeyCode.F1 then
        CONFIG.autoTouch = not CONFIG.autoTouch
        notify("Auto Touch", CONFIG.autoTouch and "ON" or "OFF", 2)
        addLog("F1: Auto Touch " .. (CONFIG.autoTouch and "ON" or "OFF"), "info")
        
    elseif input.KeyCode == Enum.KeyCode.F2 then
        -- F2 controla AMBAS as esferas juntas
        setSpheresVisible(not CONFIG.showReachSphere)
        notify("Esferas", CONFIG.showReachSphere and "VISÍVEIS" or "OCULTAS", 2)
        
    elseif input.KeyCode == Enum.KeyCode.F3 then
        -- F3 ativa/desativa Double Touch (Esfera Arthur visível)
        CONFIG.autoSecondTouch = not CONFIG.autoSecondTouch
        pcall(updateArthurSphere)
        notify("Double Touch (Arthur)", CONFIG.autoSecondTouch and "ON" or "OFF", 2)
        addLog("F3: Double Touch " .. (CONFIG.autoSecondTouch and "ON" or "OFF"), "info")
        
    elseif input.KeyCode == Enum.KeyCode.F4 then
        CONFIG.antiLag.enabled = not CONFIG.antiLag.enabled
        if CONFIG.antiLag.enabled then 
            applyAntiLag() 
        else 
            disableAntiLag() 
        end
        notify("Anti Lag", CONFIG.antiLag.enabled and "ON" or "OFF", 2)
        
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
    addLog("Character respawnado - reconectando...", "info")
    
    Character = newChar
    HRP = nil
    
    -- Destrói ambas as esferas ao respawnar
    pcall(destroyBothSpheres)
    
    -- Aguardar novo HRP
    task.spawn(function()
        local newHRP = newChar:WaitForChild("HumanoidRootPart", 5)
        if newHRP then
            HRP = newHRP
            addLog("HRP encontrado - Reach ativo!", "success")
        end
    end)
    
    -- Reaplicar anti lag se estava ativo
    task.delay(1, function()
        if CONFIG.antiLag.enabled then
            applyAntiLag()
        end
    end)
end)

-- ============================================
-- INICIALIZAÇÃO FINAL
-- ============================================
task.spawn(function()
    -- Aguardar um pouco antes de iniciar
    task.wait(0.5)
    
    -- Criar intro
    pcall(createIntro)
    
    -- Aguardar intro ou timeout
    task.delay(0.5, function()
        -- Criar interface principal
        pcall(createWindUI)
        
        -- Iniciar loop principal
        task.wait(0.2)
        pcall(mainLoop)
    end)
end)

print("========================================")
print("CAFUXZ1 Hub v15.2 - Double Sphere Edition")
print("========================================")
print("✅ Duas Esferas SINCRONIZADAS:")
print("   🟣 Esfera Principal (Pura)")
print("   🔵 Esfera Arthur V2 (Cyan - Double Touch)")
print("========================================")
print("🎮 Atalhos:")
print("   F1 = Auto Touch")
print("   F2 = Mostrar/Ocultar Esferas")
print("   F3 = Double Touch (Esfera Arthur)")
print("   F4 = Anti Lag")
print("   Insert = Minimizar/Restaurar")
print("========================================")
