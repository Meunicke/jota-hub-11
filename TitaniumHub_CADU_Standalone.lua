--[[
    CAFUXZ1 Hub v14.6 - Ultimate Edition + Bug Fixes
    ================================================
    
    CORREÇÕES:
    - X agora minimiza em vez de fechar (destruir)
    - Reach sphere agora segue o player corretamente
    - Referências do Character atualizadas em tempo real
    - Sistema de reconexão após respawn
    
    VERSÃO: v14.6 Ultimate
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
local TestService = game:GetService("TestService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ============================================
-- VERIFICAÇÃO ANTI-DUPLICAÇÃO
-- ============================================
if CoreGui:FindFirstChild("CAFUXZ1_Hub_v14") then
    CoreGui:FindFirstChild("CAFUXZ1_Hub_v14"):Destroy()
end
if CoreGui:FindFirstChild("CAFUXZ1_Icon_v14") then
    CoreGui:FindFirstChild("CAFUXZ1_Icon_v14"):Destroy()
end

-- Limpar spheres antigos
for _, obj in ipairs(Workspace:GetChildren()) do
    if obj.Name == "CAFUXZ1_ReachSphere_v14" or obj.Name == "CAFUXZ1_ReachGK_v14" then
        obj:Destroy()
    end
end

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
    
    reachGK = 25,
    reachGKEnabled = false,
    reachGKColor = Color3.fromRGB(255, 255, 0),
    reachGKTransparency = 0.8,
    reachGKShow = true,
    
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
    
    iconImage = "rbxassetid://88380080222477",
    
    ballNames = { 
        "TPS", "TCS", "ESA", "MRS", "PRS", "MPS", "SSS", "AIFA", "RBZ",
        "Ball", "Soccer", "Football", "Basketball", "Baseball", 
        "BallTemplate", "GameBall", "Hitbox", "TouchPart", "GoalBall",
        "Physics", "Interaction", "Trigger", "Touch", "Hit", "Box",
        " bola", "Bola", "BALL", "SOCCER", "FOOTBALL", "SoccerBall"
    }
}

-- Atualizar cores
local function updateThemeColors()
    CONFIG.primary = CONFIG.customColors.primary
    CONFIG.secondary = CONFIG.customColors.secondary
    CONFIG.accent = CONFIG.customColors.accent
    CONFIG.success = CONFIG.customColors.success
    CONFIG.danger = CONFIG.customColors.danger
    CONFIG.warning = CONFIG.customColors.warning
    CONFIG.info = CONFIG.customColors.info
    CONFIG.bgDark = CONFIG.customColors.bgDark
    CONFIG.bgCard = CONFIG.customColors.bgCard
    CONFIG.bgElevated = CONFIG.customColors.bgElevated
    CONFIG.bgGlass = CONFIG.customColors.bgGlass
    CONFIG.textPrimary = CONFIG.customColors.textPrimary
    CONFIG.textSecondary = CONFIG.customColors.textSecondary
    CONFIG.textMuted = CONFIG.customColors.textMuted
end

updateThemeColors()

-- ============================================
-- ESTATÍSTICAS E LOGS
-- ============================================
local STATS = {
    totalTouches = 0,
    ballsTouched = 0,
    sessionStart = tick(),
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
    if #LOGS > MAX_LOGS then table.remove(LOGS) end
end

-- ============================================
-- VARIÁVEIS GLOBAIS
-- ============================================
local balls = {}
local reachSphere = nil
local reachGKCube = nil
local lastBallUpdate = 0
local lastTouch = 0
local isMinimized = false
local isClosed = false
local mainGui = nil
local mainFrame = nil
local iconGui = nil
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
local skyItemsFrame = nil
local loopRunning = false

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
-- GET CHARACTER (COM VERIFICAÇÃO)
-- ============================================
local function getCharacter()
    local char = LocalPlayer.Character
    if not char then return nil, nil, nil end
    
    local humanoid = char:FindFirstChild("Humanoid")
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    
    return char, humanoid, rootPart
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
    local Stuff = {}
    
    for _, v in next, game:GetDescendants() do
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
    
    if CONFIG.antiLag.fullBright then
        saveOriginalState(Lighting, "FogColor", Lighting.FogColor)
        saveOriginalState(Lighting, "FogEnd", Lighting.FogEnd)
        saveOriginalState(Lighting, "Ambient", Lighting.Ambient)
        saveOriginalState(Lighting, "Brightness", Lighting.Brightness)
        
        Lighting.FogColor = Color3.fromRGB(255, 255, 255)
        Lighting.FogEnd = math.huge
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 5
    end
    
    STATS.antiLagItems = #Stuff
    addLog("Anti Lag ATIVADO - " .. #Stuff .. " itens", "success")
    
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
    
    for obj, properties in pairs(originalStates) do
        if obj and obj.Parent then
            for prop, value in pairs(properties) do
                pcall(function()
                    if prop == "Parent" then obj.Parent = value
                    else obj[prop] = value end
                end)
            end
        end
    end
    
    originalStates = {}
    STATS.antiLagItems = 0
    addLog("Anti Lag DESATIVADO", "warning")
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
    local humanoid = character:WaitForChild("Humanoid", 10)
    if not humanoid then notify("Morph", "Humanoid não encontrado!", 3) return end

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
        humanoid:ApplyDescriptionClientServer(desc)
    end)
    
    STATS.morphsDone = STATS.morphsDone + 1
    notify("Morph", "Morph aplicado: " .. targetName .. "!", 3)
    addLog("Morph: " .. targetName, "success")
end

-- ============================================
-- SISTEMA REACH GK
-- ============================================
local function updateReachGK()
    if not CONFIG.reachGKShow then
        if reachGKCube then reachGKCube:Destroy() reachGKCube = nil end
        return
    end
    
    local Character, Humanoid, RootPart = getCharacter()
    if not RootPart then return end
    
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
    
    reachGKCube.Size = Vector3.new(CONFIG.reachGK, CONFIG.reachGK, CONFIG.reachGK)
    reachGKCube.CFrame = RootPart.CFrame
    reachGKCube.Color = CONFIG.reachGKColor
    reachGKCube.Transparency = CONFIG.reachGKTransparency
    
    local selectionBox = reachGKCube:FindFirstChild("GKSelectionBox")
    if selectionBox then selectionBox.Color3 = CONFIG.reachGKColor end
end

local function processReachGK()
    if not CONFIG.reachGKEnabled then return end
    
    local Character, Humanoid, RootPart = getCharacter()
    if not RootPart or not reachGKCube then return end
    
    local torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
    if not torso then return end
    
    local overlap = OverlapParams.new()
    overlap.FilterDescendantsInstances = {Character, reachGKCube}
    overlap.FilterType = Enum.RaycastFilterType.Exclude
    
    local objectsInCube = Workspace:GetPartBoundsInBox(reachGKCube.CFrame, reachGKCube.Size, overlap)
    
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
                sky.Name = "CAFUXZ1_Sky_" .. assetId
                sky.Parent = Lighting
                return true
            end
            if source:IsA("Model") or source:IsA("Folder") then
                for _, child in pairs(source:GetDescendants()) do
                    if child:IsA("Sky") then
                        local sky = child:Clone()
                        sky.Name = "CAFUXZ1_Sky_" .. assetId
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
                    sky.Name = "CAFUXZ1_Sky_" .. assetId
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
        sky.Name = "CAFUXZ1_Sky_Generic_" .. assetId
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
-- SISTEMA DE BOLAS
-- ============================================
local function isBall(obj)
    if not obj or not obj:IsA("BasePart") then return false end
    for _, name in ipairs(CONFIG.ballNames) do
        if obj.Name == name or obj.Name:find(name) then return true end
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
            end
            newBalls[obj] = balls[obj]
        end
    end
    
    for obj, data in pairs(balls) do
        if not newBalls[obj] then
            if data.attachment then data.attachment:Destroy() end
            balls[obj] = nil
        end
    end
end

-- ============================================
-- SISTEMA REACH PRINCIPAL (CORRIGIDO)
-- ============================================
local function updateReachSphere()
    if not CONFIG.showReachSphere then
        if reachSphere then reachSphere:Destroy() reachSphere = nil end
        return
    end
    
    local Character, Humanoid, RootPart = getCharacter()
    if not RootPart then return end
    
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
    end
    
    -- SEMPRE atualizar posição e tamanho
    reachSphere.Size = Vector3.new(CONFIG.reach * 2, CONFIG.reach * 2, CONFIG.reach * 2)
    reachSphere.CFrame = RootPart.CFrame
    reachSphere.Color = CONFIG.primary
end

local function processAutoTouch()
    if not CONFIG.autoTouch then return end
    
    local Character, Humanoid, RootPart = getCharacter()
    if not RootPart then return end
    
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
-- AUTO SKILLS
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
                        pcall(function() gui.MouseButton1Click:Fire() end)
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
-- INTERFACE
-- ============================================
local function createWindUI()
    if CoreGui:FindFirstChild("CAFUXZ1_Hub_v14") then
        CoreGui:FindFirstChild("CAFUXZ1_Hub_v14"):Destroy()
    end
    
    isClosed = false
    
    mainGui = Instance.new("ScreenGui")
    mainGui.Name = "CAFUXZ1_Hub_v14"
    mainGui.ResetOnSpawn = false
    mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    mainGui.Parent = CoreGui
    
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, CONFIG.width, 0, CONFIG.height)
    mainFrame.Position = UDim2.new(0.5, -CONFIG.width/2, 0.5, -CONFIG.height/2)
    mainFrame.BackgroundColor3 = CONFIG.bgGlass
    mainFrame.BackgroundTransparency = 0.2
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = mainGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = CONFIG.primary
    stroke.Thickness = 2
    stroke.Transparency = 0.5
    stroke.Parent = mainFrame
    
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
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 50)
    titleLabel.Position = UDim2.new(0, 0, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "⚡"
    titleLabel.TextColor3 = CONFIG.primary
    titleLabel.TextSize = 32
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = sidebar
    
    local versionLabel = Instance.new("TextLabel")
    versionLabel.Size = UDim2.new(1, 0, 0, 20)
    versionLabel.Position = UDim2.new(0, 0, 0, 55)
    versionLabel.BackgroundTransparency = 1
    versionLabel.Text = "v14.6"
    versionLabel.TextColor3 = CONFIG.textMuted
    versionLabel.TextSize = 12
    versionLabel.Font = Enum.Font.Gotham
    versionLabel.Parent = sidebar
    
    -- Tabs
    local tabs = {
        {name = "reach", icon = "⚽", label = "Reach"},
        {name = "gk", icon = "🥅", label = "GK"},
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
    headerTitle.Text = "CAFUXZ1 Hub v14.6 Ultimate"
    headerTitle.TextColor3 = CONFIG.textPrimary
    headerTitle.TextSize = 18
    headerTitle.Font = Enum.Font.GothamBold
    headerTitle.TextXAlignment = Enum.TextXAlignment.Left
    headerTitle.Parent = header
    
    -- Botões de controle
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "MinimizeBtn"
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
    
    -- BOTÃO X AGORA MINIMIZA (NÃO FECHA)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
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
    
    -- Funções auxiliares
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
        
        return toggleFrame
    end
    
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
        
        local sliderBg = Instance.new("Frame")
        sliderBg.Size = UDim2.new(1, 0, 0, 8)
        sliderBg.Position = UDim2.new(0, 0, 0, 30)
        sliderBg.BackgroundColor3 = CONFIG.bgElevated
        sliderBg.BorderSizePixel = 0
        sliderBg.Parent = sliderFrame
        
        local sliderBgCorner = Instance.new("UICorner")
        sliderBgCorner.CornerRadius = UDim.new(0, 4)
        sliderBgCorner.Parent = sliderBg
        
        local sliderFill = Instance.new("Frame")
        sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        sliderFill.BackgroundColor3 = CONFIG.primary
        sliderFill.BorderSizePixel = 0
        sliderFill.Parent = sliderBg
        
        local sliderFillCorner = Instance.new("UICorner")
        sliderFillCorner.CornerRadius = UDim.new(0, 4)
        sliderFillCorner.Parent = sliderFill
        
        local sliderKnob = Instance.new("TextButton")
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
            label.Text = text .. ": " .. value
            
            if callback then callback(value) end
        end
        
        sliderKnob.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(input)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        return sliderFrame
    end
    
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
    
    local function createColorPicker(parent, labelText, defaultColor, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 40)
        frame.BackgroundTransparency = 1
        frame.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.6, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = labelText
        label.TextColor3 = CONFIG.textSecondary
        label.TextSize = 13
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local colorBtn = Instance.new("TextButton")
        colorBtn.Size = UDim2.new(0, 60, 0, 30)
        colorBtn.Position = UDim2.new(1, -60, 0.5, -15)
        colorBtn.BackgroundColor3 = defaultColor
        colorBtn.Text = "🎨"
        colorBtn.TextSize = 18
        colorBtn.Parent = frame
        
        local colorCorner = Instance.new("UICorner")
        colorCorner.CornerRadius = UDim.new(0, 6)
        colorCorner.Parent = colorBtn
        
        local rgbFrame = Instance.new("Frame")
        rgbFrame.Size = UDim2.new(1, 0, 0, 30)
        rgbFrame.Position = UDim2.new(0, 0, 0, 40)
        rgbFrame.BackgroundTransparency = 1
        rgbFrame.Visible = false
        rgbFrame.Parent = frame
        
        local rInput = Instance.new("TextBox")
        rInput.Size = UDim2.new(0.3, -4, 1, 0)
        rInput.BackgroundColor3 = CONFIG.bgElevated
        rInput.Text = tostring(math.floor(defaultColor.R * 255))
        rInput.TextColor3 = Color3.new(1, 0, 0)
        rInput.Parent = rgbFrame
        
        local gInput = Instance.new("TextBox")
        gInput.Size = UDim2.new(0.3, -4, 1, 0)
        gInput.Position = UDim2.new(0.35, 0, 0, 0)
        gInput.BackgroundColor3 = CONFIG.bgElevated
        gInput.Text = tostring(math.floor(defaultColor.G * 255))
        gInput.TextColor3 = Color3.fromRGB(0, 255, 0)
        gInput.Parent = rgbFrame
        
        local bInput = Instance.new("TextBox")
        bInput.Size = UDim2.new(0.3, -4, 1, 0)
        bInput.Position = UDim2.new(0.7, 0, 0, 0)
        bInput.BackgroundColor3 = CONFIG.bgElevated
        bInput.Text = tostring(math.floor(defaultColor.B * 255))
        bInput.TextColor3 = Color3.fromRGB(0, 100, 255)
        bInput.Parent = rgbFrame
        
        for _, inp in ipairs({rInput, gInput, bInput}) do
            local inpCorner = Instance.new("UICorner")
            inpCorner.CornerRadius = UDim.new(0, 4)
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
            frame.Size = rgbFrame.Visible and UDim2.new(1, 0, 0, 75) or UDim2.new(1, 0, 0, 40)
        end)
        
        return frame
    end
    
    -- POPULAR ABAS
    local reachSection, reachContent = createSection(contentFrames.reach, "Configurações de Reach")
    
    createToggle(reachContent, "Auto Touch", CONFIG.autoTouch, function(val)
        CONFIG.autoTouch = val
    end)
    
    createToggle(reachContent, "Full Body Touch", CONFIG.fullBodyTouch, function(val)
        CONFIG.fullBodyTouch = val
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
    end)
    
    -- ABA GK
    local gkSection, gkContent = createSection(contentFrames.gk, "Sistema GK")
    
    createToggle(gkContent, "Ativar Reach GK", CONFIG.reachGKEnabled, function(val)
        CONFIG.reachGKEnabled = val
    end)
    
    createSlider(gkContent, "Alcance GK", 10, 60, CONFIG.reachGK, function(val)
        CONFIG.reachGK = val
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
    usernameInput.Size = UDim2.new(1, 0, 0, 30)
    usernameInput.BackgroundColor3 = CONFIG.bgElevated
    usernameInput.Text = ""
    usernameInput.PlaceholderText = "Username..."
    usernameInput.TextColor3 = CONFIG.textPrimary
    usernameInput.Parent = charContent
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = usernameInput
    
    createButton(charContent, "Aplicar Morph", CONFIG.primary, function()
        local username = usernameInput.Text
        if username ~= "" then
            task.spawn(function()
                local success, userId = pcall(function()
                    return Players:GetUserIdFromNameAsync(username)
                end)
                if success then morphToUser(userId, username) end
            end)
        end
    end)
    
    for _, preset in ipairs(PRESET_MORPHS) do
        createButton(charContent, preset.displayName, CONFIG.bgElevated, function()
            if preset.userId then morphToUser(preset.userId, preset.displayName) end
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
    createButton(skyContent, "↩️ Resetar", CONFIG.danger, restoreOriginalSkybox)
    
    -- ABA CONFIG
    local configSection, configContent = createSection(contentFrames.config, "Cores")
    
    createColorPicker(configContent, "Primária", CONFIG.customColors.primary, function(c) CONFIG.customColors.primary = c end)
    createColorPicker(configContent, "Secundária", CONFIG.customColors.secondary, function(c) CONFIG.customColors.secondary = c end)
    
    -- ABA STATS
    local statsSection, statsContent = createSection(contentFrames.stats, "Estatísticas")
    
    local statsLabels = {}
    for _, item in ipairs({{k="totalTouches",l="Toques"},{k="gkSaves",l="Defesas"}}) do
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, 0, 0, 30)
        f.BackgroundTransparency = 1
        f.Parent = statsContent
        
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.6, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = item.l .. ":"
        lbl.TextColor3 = CONFIG.textSecondary
        lbl.TextSize = 13
        lbl.Font = Enum.Font.Gotham
        lbl.Parent = f
        
        local val = Instance.new("TextLabel")
        val.Size = UDim2.new(0.4, 0, 1, 0)
        val.Position = UDim2.new(0.6, 0, 0, 0)
        val.BackgroundTransparency = 1
        val.Text = "0"
        val.TextColor3 = CONFIG.primary
        val.TextSize = 14
        val.Font = Enum.Font.GothamBold
        val.Parent = f
        
        statsLabels[item.k] = val
    end
    
    task.spawn(function()
        while mainGui and mainGui.Parent do
            for k, lbl in pairs(statsLabels) do
                lbl.Text = tostring(STATS[k] or 0)
            end
            task.wait(1)
        end
    end)
    
    -- ABA LOGS
    local logsSection, logsContent = createSection(contentFrames.logs, "Logs")
    
    local logsList = Instance.new("ScrollingFrame")
    logsList.Size = UDim2.new(1, 0, 0, 250)
    logsList.BackgroundColor3 = CONFIG.bgDark
    logsList.BackgroundTransparency = 0.5
    logsList.BorderSizePixel = 0
    logsList.ScrollBarThickness = 4
    logsList.Parent = logsContent
    
    local logsCorner = Instance.new("UICorner")
    logsCorner.CornerRadius = UDim.new(0, 6)
    logsCorner.Parent = logsList
    
    task.spawn(function()
        while mainGui and mainGui.Parent do
            for _, c in ipairs(logsList:GetChildren()) do
                if c:IsA("TextLabel") then c:Destroy() end
            end
            
            for _, log in ipairs(LOGS) do
                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1, -10, 0, 20)
                lbl.BackgroundTransparency = 1
                lbl.Text = string.format("[%s] %s", log.time, log.message)
                lbl.TextColor3 = log.type == "success" and CONFIG.success or (log.type == "warning" and CONFIG.warning or CONFIG.textSecondary)
                lbl.TextSize = 11
                lbl.Font = Enum.Font.Code
                lbl.Parent = logsList
            end
            
            logsList.CanvasSize = UDim2.new(0, 0, 0, #LOGS * 22)
            task.wait(0.5)
        end
    end)
    
    -- NAVEGAÇÃO
    local function switchTab(tabName)
        currentTab = tabName
        for name, btn in pairs(tabButtons) do
            if name == tabName then
                tween(btn, {BackgroundColor3 = CONFIG.primary}, 0.2)
            else
                tween(btn, {BackgroundColor3 = CONFIG.bgElevated}, 0.2)
            end
        end
        for name, frame in pairs(contentFrames) do
            frame.Visible = (name == tabName)
        end
    end
    
    for name, btn in pairs(tabButtons) do
        btn.MouseButton1Click:Connect(function() switchTab(name) end)
    end
    
    switchTab("reach")
    
    -- MINIMIZAR/RESTAURAR (AMBOS OS BOTÕES AGORA MINIMIZAM)
    local function minimizeUI()
        isMinimized = true
        mainFrame.Visible = false
        if not iconGui or not iconGui.Parent then
            createIconGui()
        else
            iconGui.Enabled = true
        end
    end
    
    local function restoreUI()
        isMinimized = false
        mainFrame.Visible = true
        if iconGui then iconGui.Enabled = false end
    end
    
    minimizeBtn.MouseButton1Click:Connect(minimizeUI)
    closeBtn.MouseButton1Click:Connect(minimizeUI) -- X AGORA MINIMIZA!
    
    -- Drag
    local dragging = false
    local dragStart, startPos
    
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- ÍCONE FLUTUANTE
    function createIconGui()
        if CoreGui:FindFirstChild("CAFUXZ1_Icon_v14") then
            CoreGui:FindFirstChild("CAFUXZ1_Icon_v14"):Destroy()
        end
        
        iconGui = Instance.new("ScreenGui")
        iconGui.Name = "CAFUXZ1_Icon_v14"
        iconGui.ResetOnSpawn = false
        iconGui.Parent = CoreGui
        
        local iconBtn = Instance.new("TextButton")
        iconBtn.Name = "IconButton"
        iconBtn.Size = UDim2.new(0, 50, 0, 50)
        iconBtn.Position = UDim2.new(0, 20, 0.5, -25)
        iconBtn.BackgroundColor3 = CONFIG.primary
        iconBtn.Text = "⚡"
        iconBtn.TextColor3 = Color3.new(1, 1, 1)
        iconBtn.TextSize = 24
        iconBtn.Font = Enum.Font.GothamBold
        iconBtn.Parent = iconGui
        
        local iconCorner = Instance.new("UICorner")
        iconCorner.CornerRadius = UDim.new(1, 0)
        iconCorner.Parent = iconBtn
        
        iconBtn.MouseButton1Click:Connect(restoreUI)
        
        local iconDragging = false
        local iconDragStart, iconStartPos
        
        iconBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                iconDragging = true
                iconDragStart = input.Position
                iconStartPos = iconBtn.Position
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if iconDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - iconDragStart
                iconBtn.Position = UDim2.new(iconStartPos.X.Scale, iconStartPos.X.Offset + delta.X, iconStartPos.Y.Scale, iconStartPos.Y.Offset + delta.Y)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                iconDragging = false
            end
        end)
    end
    
    addLog("Hub v14.6 iniciado!", "success")
    notify("CAFUXZ1 Hub", "v14.6 carregado! X minimiza, não fecha.", 5)
end

-- ============================================
-- LOOP PRINCIPAL (CORRIGIDO)
-- ============================================
local function mainLoop()
    if loopRunning then return end
    loopRunning = true
    
    while true do
        if isClosed then break end
        
        -- SEMPRE pegar character atualizado a cada frame!
        local Character, Humanoid, RootPart = getCharacter()
        
        if Character and Humanoid and RootPart then
            -- Atualizar spheres independente de estado
            updateReachSphere()
            updateReachGK()
            
            -- Processar funcionalidades
            scanForBalls()
            processAutoTouch()
            processReachGK()
            activateSkillButton()
        else
            -- Se não tiver character, destruir spheres
            if reachSphere then reachSphere:Destroy() reachSphere = nil end
            if reachGKCube then reachGKCube:Destroy() reachGKCube = nil end
        end
        
        task.wait(0.03) -- ~30 FPS
    end
    
    loopRunning = false
end

-- ============================================
-- ATALHOS
-- ============================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F1 then
        CONFIG.autoTouch = not CONFIG.autoTouch
        notify("Auto Touch", CONFIG.autoTouch and "ON" or "OFF", 2)
    elseif input.KeyCode == Enum.KeyCode.F2 then
        CONFIG.showReachSphere = not CONFIG.showReachSphere
        if not CONFIG.showReachSphere and reachSphere then
            reachSphere:Destroy()
            reachSphere = nil
        end
    elseif input.KeyCode == Enum.KeyCode.F3 then
        CONFIG.reachGKEnabled = not CONFIG.reachGKEnabled
    elseif input.KeyCode == Enum.KeyCode.F4 then
        CONFIG.antiLag.enabled = not CONFIG.antiLag.enabled
        if CONFIG.antiLag.enabled then applyAntiLag() else disableAntiLag() end
    elseif input.KeyCode == Enum.KeyCode.Insert then
        if mainGui and mainGui.Parent then
            mainGui.Enabled = not mainGui.Enabled
        else
            createWindUI()
        end
    end
end)

-- ============================================
-- INICIALIZAÇÃO
-- ============================================
LocalPlayer.CharacterAdded:Connect(function(char)
    addLog("Character respawned", "info")
    if CONFIG.antiLag.enabled then
        task.delay(2, applyAntiLag)
    end
end)

createWindUI()
task.spawn(mainLoop)

print("CAFUXZ1 Hub v14.6 - Loaded")
