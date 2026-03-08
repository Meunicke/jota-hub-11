--[[
    CAFUXZ1 Hub v14.1 - CADUXX137 Ultimate Edition
    ================================================
    
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
    - Atalhos de teclado (F1, F2, F3, F4)
    - NOVO: Sistema Anti Lag completo
    - NOVO: Morph Avatar (Char) integrado
    
    VERSÃO: v14.2 Ultimate
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
-- CONFIGURAÇÕES CAFUXZ1 v14.2 ULTIMATE
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

local function toggleAntiLag()
    if antiLagActive then
        disableAntiLag()
    else
        applyAntiLag()
    end
    return antiLagActive
end

-- ============================================
-- SISTEMA DE MORPH AVATAR (INTEGRADO - CHAR)
-- ============================================
local function createMorphGui()
    if morphGui then morphGui:Destroy() end
    
    -- Theme Colors
    local BLACK = Color3.fromRGB(15, 15, 15)
    local DARK_GRAY = Color3.fromRGB(35, 35, 35)
    local WHITE = Color3.fromRGB(255, 255, 255)
    local RED = Color3.fromRGB(200, 50, 50)
    local MENU_ALPHA = 0.95

    -- Cleanup Existing GUI
    if CoreGui:FindFirstChild("CAFUXZ1_MorphChar") then 
        CoreGui["CAFUXZ1_MorphChar"]:Destroy() 
    end

    -- Main GUI
    morphGui = Instance.new("ScreenGui")
    morphGui.Name = "CAFUXZ1_MorphChar"
    morphGui.ResetOnSpawn = false
    morphGui.DisplayOrder = 999998
    morphGui.Parent = CoreGui
    morphGui.Enabled = true

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 90)
    frame.Position = UDim2.new(0.5, -100, 0.5, -50)
    frame.BackgroundColor3 = BLACK
    frame.BackgroundTransparency = 1 - MENU_ALPHA
    frame.BorderSizePixel = 0
    frame.Active = false
    frame.Parent = morphGui
    frame.Visible = true
    frame.ClipsDescendants = true

    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 8)
    frameCorner.Parent = frame

    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundTransparency = 1
    titleBar.Parent = frame
    titleBar.Active = true

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -60, 0, 30)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.Text = "Char Morph"
    title.TextColor3 = WHITE
    title.BackgroundTransparency = 1
    title.BorderSizePixel = 0
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar

    -- Username Input
    local usernameInput = Instance.new("TextBox")
    usernameInput.Size = UDim2.new(1, -20, 0, 30)
    usernameInput.Position = UDim2.new(0, 10, 0, 40)
    usernameInput.PlaceholderText = "Enter Username"
    usernameInput.Font = Enum.Font.Gotham
    usernameInput.TextSize = 14
    usernameInput.Text = ""
    usernameInput.TextColor3 = WHITE
    usernameInput.BackgroundColor3 = DARK_GRAY
    usernameInput.ClearTextOnFocus = false
    usernameInput.TextWrapped = true
    usernameInput.Parent = frame
    usernameInput.Visible = true

    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 4)
    inputCorner.Parent = usernameInput

    -- Buttons
    local miniBtn = Instance.new("TextButton")
    miniBtn.Name = "MinimizeButton"
    miniBtn.Size = UDim2.new(0, 30, 0, 30)
    miniBtn.Position = UDim2.new(1, -60, 0, 0)
    miniBtn.Text = "-"
    miniBtn.Font = Enum.Font.GothamBold
    miniBtn.TextSize = 16
    miniBtn.TextColor3 = WHITE
    miniBtn.BackgroundTransparency = 1
    miniBtn.Parent = titleBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "Close"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -30, 0, 0)
    closeBtn.Text = "X"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.TextColor3 = RED
    closeBtn.BackgroundTransparency = 1
    closeBtn.Parent = titleBar
    closeBtn.ZIndex = 2

    -- Morph Functions
    local function applyMorphEffect(character)
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end

        local particleEmitter = Instance.new("ParticleEmitter")
        particleEmitter.Texture = "rbxassetid://243098098"
        particleEmitter.Rate = 50
        particleEmitter.Speed = NumberRange.new(5, 10)
        particleEmitter.Lifetime = NumberRange.new(0.5, 1)
        particleEmitter.SpreadAngle = Vector2.new(360, 360)
        particleEmitter.Color = ColorSequence.new(RED)
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

    local function findPlayerByName(partialName)
        if not partialName or partialName == "" then return nil end
        local searchName = partialName:lower()
        
        local localPlayer = nil
        for _, v in ipairs(Players:GetPlayers()) do
            local nameLower = v.Name:lower()
            local dNameLower = v.DisplayName:lower()
            
            if nameLower == searchName or dNameLower == searchName then
                return v
            end
            
            if nameLower:sub(1, #searchName) == searchName or dNameLower:sub(1, #searchName) == searchName then
                localPlayer = v
            end
        end
        
        if not localPlayer then
            local success, userId = pcall(function()
                return Players:GetUserIdFromNameAsync(searchName)
            end)
            if success and userId then
                return {UserId = userId, Name = searchName}
            end
        end
        
        return localPlayer
    end

    local function morphToPlayer(target)
        if not target then 
            notify("Char Morph", "No target found!", 3)
            return 
        end
        
        local userId = target.UserId or (type(target) == "number" and target or target.UserId)
        local targetName = target.Name or "Unknown"
        
        if userId == LocalPlayer.UserId then
            notify("Char Morph", "Cannot morph to yourself!", 3)
            return
        end
        
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid", 10)
        if not humanoid then 
            notify("Char Morph", "Failed to find humanoid!", 3)
            return 
        end

        local success, desc = pcall(function()
            return Players:GetHumanoidDescriptionFromUserId(userId)
        end)
        if not success or not desc then
            notify("Char Morph", "Failed to load avatar data!", 3)
            return
        end

        -- Fetch target thumbnail
        local targetThumbnail = ""
        local thumbSuccess, thumbResult = pcall(function()
            return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        end)
        if thumbSuccess then
            targetThumbnail = thumbResult
        end

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
            notify("Char Morph", "Successfully morphed to " .. targetName .. "!", 3)
            addLog("Morph realizado: " .. targetName, "success")
        else
            notify("Char Morph", "Failed to apply morph!", 3)
        end
    end

    -- Events
    local draggingTitleBar = false
    local dragStart, startPos

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingTitleBar = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingTitleBar = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if draggingTitleBar and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    miniBtn.MouseButton1Click:Connect(function()
        CONFIG.morph.minimized = not CONFIG.morph.minimized
        if CONFIG.morph.minimized then
            frame.Size = UDim2.new(0, 200, 0, 30)
            miniBtn.Text = "+"
            usernameInput.Visible = false
        else
            frame.Size = UDim2.new(0, 200, 0, 90)
            miniBtn.Text = "-"
            usernameInput.Visible = true
        end
    end)

    closeBtn.MouseButton1Click:Connect(function()
        morphGui:Destroy()
        morphGui = nil
    end)

    usernameInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local inputText = usernameInput.Text
            if inputText == "" then 
                notify("Char Morph", "Please enter a username!", 3)
                return 
            end
            
            local target = findPlayerByName(inputText)
            if target then
                usernameInput.Text = target.Name or inputText
                morphToPlayer(target)
            else
                notify("Char Morph", "Player not found!", 3)
            end
        end
    end)
    
    return morphGui
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
        
        -- SelectionBox para destacar o cubo
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
        
        -- Atualizar cor se mudou
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
            -- Verificar se é uma bola
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
-- ÍCONE FLUTUANTE PREMIUM COM NOVA IMAGEM
-- ============================================
local function createIconButton()
    if iconGui then iconGui:Destroy() end
    
    iconGui = Instance.new("ScreenGui")
    iconGui.Name = "CAFUXZ1_Icon_v14"
    iconGui.ResetOnSpawn = false
    iconGui.DisplayOrder = 999999
    iconGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local iconSize = 75 * CONFIG.scale
    
    -- Frame principal com fundo circular
    local mainBtn = Instance.new("ImageButton")
    mainBtn.Name = "IconButton"
    mainBtn.Size = UDim2.new(0, iconSize, 0, iconSize)
    mainBtn.Position = UDim2.new(0.5, -iconSize/2, 0.88, 0)
    mainBtn.BackgroundTransparency = 1
    mainBtn.Image = CONFIG.iconImage
    mainBtn.ImageColor3 = Color3.new(1, 1, 1)
    mainBtn.ScaleType = Enum.ScaleType.Crop
    mainBtn.Parent = iconGui
    
    -- Corner radius para deixar circular
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = mainBtn
    
    -- Borda glow
    local stroke = Instance.new("UIStroke")
    stroke.Color = CONFIG.accentColor
    stroke.Thickness = 2
    stroke.Transparency = 0.3
    stroke.Parent = mainBtn
    
    -- Efeito de glow animado externo
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.Size = UDim2.new(1.4, 0, 1.4, 0)
    glow.Position = UDim2.new(-0.2, 0, -0.2, 0)
    glow.BackgroundTransparency = 1
    glow.Image = CONFIG.iconImage
    glow.ImageColor3 = CONFIG.accentColor
    glow.ImageTransparency = 0.85
    glow.ZIndex = -1
    glow.Parent = mainBtn
    Instance.new("UICorner", glow).CornerRadius = UDim.new(1, 0)
    
    -- Animação de pulso do glow
    task.spawn(function()
        while glow and glow.Parent do
            tween(glow, {Size = UDim2.new(1.6, 0, 1.6, 0), ImageTransparency = 0.9}, 1)
            task.wait(1)
            tween(glow, {Size = UDim2.new(1.4, 0, 1.4, 0), ImageTransparency = 0.85}, 1)
            task.wait(1)
        end
    end)
    
    -- Hover effects
    mainBtn.MouseEnter:Connect(function()
        tween(mainBtn, {Size = UDim2.new(0, iconSize * 1.15, 0, iconSize * 1.15)}, 0.3, Enum.EasingStyle.Back)
        tween(stroke, {Thickness = 4, Transparency = 0}, 0.3)
    end)
    
    mainBtn.MouseLeave:Connect(function()
        tween(mainBtn, {Size = UDim2.new(0, iconSize, 0, iconSize)}, 0.3, Enum.EasingStyle.Back)
        tween(stroke, {Thickness = 2, Transparency = 0.3}, 0.3)
    end)
    
    -- Clique para abrir
    mainBtn.MouseButton1Click:Connect(function()
        tween(mainBtn, {Size = UDim2.new(0, 0, 0, 0), Rotation = 360}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.4)
        iconGui:Destroy()
        iconGui = nil
        isMinimized = false
        notify("CAFUXZ1 Hub", "Use o botão minimizado ou reinicie o script", 3)
    end)
    
    -- Draggable
    local dragging = false
    local dragStart, startPos
    
    mainBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainBtn.Position
        end
    end)
    
    mainBtn.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            mainBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    -- Entrada elástica
    mainBtn.Size = UDim2.new(0, 0, 0, 0)
    tween(mainBtn, {Size = UDim2.new(0, iconSize, 0, iconSize)}, 0.6, Enum.EasingStyle.Back)
    
    notify("CAFUXZ1 Hub v14", "Clique no ícone para abrir", 3)
end

-- ============================================
-- INTERFACE WINDUI (CAFUXZ1 Hub)
-- ============================================
local Libary = loadstring(game:HttpGet("https://raw.githubusercontent.com/BRENOPOOF/slapola/refs/heads/main/Main.txt"))()
Workspace.FallenPartsDestroyHeight = -math.huge

local Window = Libary:MakeWindow({
    Title = "CAFUXZ1 Hub",
    SubTitle = "v14.2 Ultimate | by Bazuka & Cafuxz1",
    LoadText = "Carregando CADUXX137 Ultimate...",
    Flags = "CAFUXZ1Hub_v14_Ultimate"
})

-- Botão minimizar com novo ícone
Window:AddMinimizeButton({
    Button = {
        Image = CONFIG.iconImage,
        BackgroundTransparency = 0,
        BackgroundColor3 = Color3.fromRGB(30, 30, 40),
        Size = UDim2.new(0, 50, 0, 50),
    },
    Corner = {
        CornerRadius = UDim.new(0, 100),
    },
})

-- ============================================
-- ABA INFO (CRÉDITOS OFICIAIS)
-- ============================================
local InfoTab = Window:MakeTab({ Title = "Info", Icon = "rbxassetid://15309138473" })

InfoTab:AddSection({ "Créditos Oficiais" })
InfoTab:AddParagraph({ "Criadores:", "Bazuka & Cafuxz1" })
InfoTab:AddParagraph({ "Sistema Ball Reach:", "CADUXX137 v14.0 Ultimate" })
InfoTab:AddParagraph({ "Sistema Reach GK:", "Cafuxz1 v1.0" })
InfoTab:AddParagraph({ "Sistema Anti Lag:", "CAFUXZ1 v14.1" })
InfoTab:AddParagraph({ "Sistema Char Morph:", "Integrado v1.0" })
InfoTab:AddParagraph({ "Interface:", "CAFUXZ1 Hub (WindUI)" })

InfoTab:AddSection({ "Sobre" })
InfoTab:AddParagraph({ "Versão:", "v14.2 Ultimate Edition" })
InfoTab:AddParagraph({ "Descrição:", "Sistema avançado de detecção e interação automática com bolas em jogos de futebol/soccer + Morph Avatar" })
InfoTab:AddParagraph({ "Status:", "Sistema Ativo | GK: " .. (CONFIG.reachGKEnabled and "ON" or "OFF") .. " | Anti Lag: " .. (antiLagActive and "ON" or "OFF") })

InfoTab:AddSection({ "Atalhos de Teclado" })
InfoTab:AddParagraph({ "F1:", "Minimizar/Maximizar Hub" })
InfoTab:AddParagraph({ "F2:", "Toggle Auto Touch" })
InfoTab:AddParagraph({ "F3:", "Toggle Esfera Visual" })
InfoTab:AddParagraph({ "F4:", "Toggle Reach GK" })
InfoTab:AddParagraph({ "F5:", "Toggle Anti Lag" })
InfoTab:AddParagraph({ "F6:", "Abrir Char Morph" })

-- ============================================
-- ABA CHAR (MORPH AVATAR - NOVO)
-- ============================================
local CharTab = Window:MakeTab({ Title = "Char", Icon = "rbxassetid://15309138473" })

CharTab:AddSection({ "👤 Morph Avatar" })

CharTab:AddParagraph({ "Como usar:", "Digite o username e pressione Enter para aplicar o morph" })

CharTab:AddButton({
    Name = "Abrir Interface Char Morph",
    Callback = function()
        createMorphGui()
        notify("Char Morph", "Interface aberta! Digite o username.", 3)
        addLog("Interface Char Morph aberta", "info")
    end
})

CharTab:AddButton({
    Name = "Fechar Interface Char Morph",
    Callback = function()
        if morphGui then
            morphGui:Destroy()
            morphGui = nil
            notify("Char Morph", "Interface fechada", 2)
        else
            notify("Char Morph", "Interface não está aberta", 2)
        end
    end
})

CharTab:AddSection({ "📊 Estatísticas de Morph" })

local morphsDoneLabel = CharTab:AddParagraph({ "Morphs Realizados:", "0" })

-- ============================================
-- ABA BALL REACH (CADUXX137 CORE)
-- ============================================
local BallTab = Window:MakeTab({ Title = "Ball Reach", Icon = "rbxassetid://104616032736993" })

BallTab:AddSection({ "⚡ Configurações de Alcance" })

-- Slider de Reach
BallTab:AddSlider({
    Name = "Alcance (Reach)",
    Min = 1,
    Max = 50,
    Default = 15,
    Color = CONFIG.primary,
    Increment = 1,
    ValueName = "studs",
    Callback = function(Value)
        CONFIG.reach = Value
        addLog("Alcance ajustado para " .. Value .. " studs", "info")
        notify("Ball Reach", "Alcance: " .. Value .. " studs", 1)
    end
})

-- Quick buttons
BallTab:AddButton({
    Name = "Alcance Mínimo (1)",
    Callback = function()
        CONFIG.reach = 1
        notify("Reach", "Mínimo: 1 stud", 1)
    end
})

BallTab:AddButton({
    Name = "Alcance Médio (15)",
    Callback = function()
        CONFIG.reach = 15
        notify("Reach", "Médio: 15 studs", 1)
    end
})

BallTab:AddButton({
    Name = "Alcance Máximo (50)",
    Callback = function()
        CONFIG.reach = 50
        notify("Reach", "Máximo: 50 studs", 1)
    end
})

BallTab:AddSection({ "🎮 Sistema de Toque" })

BallTab:AddToggle({
    Name = "Auto Touch Automático",
    Default = true,
    Callback = function(value)
        CONFIG.autoTouch = value
        addLog("Auto Touch: " .. (value and "ON" or "OFF"), value and "success" or "warning")
    end
})

BallTab:AddToggle({
    Name = "Full Body Touch",
    Default = true,
    Callback = function(value)
        CONFIG.fullBodyTouch = value
        addLog("Full Body: " .. (value and "ON" or "OFF"), value and "success" or "warning")
    end
})

BallTab:AddToggle({
    Name = "Double Touch (2x rápido)",
    Default = true,
    Callback = function(value)
        CONFIG.autoSecondTouch = value
        addLog("Double Touch: " .. (value and "ON" or "OFF"), value and "success" or "warning")
    end
})

BallTab:AddSection({ "👁️ Visualização" })

BallTab:AddToggle({
    Name = "Mostrar Esfera de Alcance",
    Default = true,
    Callback = function(value)
        CONFIG.showReachSphere = value
        addLog("Esfera: " .. (value and "ON" or "OFF"), "info")
    end
})

BallTab:AddToggle({
    Name = "Partículas de Fundo",
    Default = true,
    Callback = function(value)
        CONFIG.particleEffects = value
        addLog("Partículas: " .. (value and "ON" or "OFF"), "info")
    end
})

BallTab:AddSection({ "🤖 Auto Skills" })

BallTab:AddToggle({
    Name = "Auto Skills (Botões de Futebol)",
    Default = true,
    Callback = function(value)
        autoSkills = value
        addLog("Auto Skills: " .. (value and "ON" or "OFF"), value and "success" or "warning")
    end
})

BallTab:AddParagraph({ "Skills Detectadas:", "Shoot, Pass, Dribble, Control, Tackle, etc." })

BallTab:AddSection({ "📊 Status em Tempo Real" })

local statusLabel = BallTab:AddParagraph({ "Bolas Detectadas:", "0" })
local reachLabel = BallTab:AddParagraph({ "Alcance Atual:", "15 studs" })
local touchesLabel = BallTab:AddParagraph({ "Toques Totais:", "0" })

-- ============================================
-- ABA REACH GK (NOVO - CAFUXZ1)
-- ============================================
local GKTab = Window:MakeTab({ Title = "Reach GK", Icon = "rbxassetid://11322093465" })

GKTab:AddSection({ "🥅 Sistema de Goleiro (GK)" })

GKTab:AddToggle({
    Name = "Ativar Reach GK",
    Default = false,
    Callback = function(value)
        CONFIG.reachGKEnabled = value
        addLog("Reach GK: " .. (value and "ON" or "OFF"), value and "success" or "warning")
        notify("Reach GK", value and "ATIVADO - Modo Goleiro" or "DESATIVADO", 2)
    end
})

GKTab:AddSlider({
    Name = "Tamanho do Cubo GK",
    Min = 5,
    Max = 60,
    Default = 25,
    Color = CONFIG.warning,
    Increment = 1,
    ValueName = "studs",
    Callback = function(Value)
        CONFIG.reachGK = Value
        addLog("Reach GK tamanho: " .. Value .. " studs", "info")
    end
})

GKTab:AddSection({ "🎨 Personalização do Cubo" })

GKTab:AddToggle({
    Name = "Mostrar Cubo GK",
    Default = true,
    Callback = function(value)
        CONFIG.reachGKShow = value
        addLog("Visual GK: " .. (value and "ON" or "OFF"), "info")
    end
})

GKTab:AddSlider({
    Name = "Transparência do Cubo",
    Min = 0,
    Max = 1,
    Default = 0.8,
    Increment = 0.1,
    ValueName = "",
    Callback = function(Value)
        CONFIG.reachGKTransparency = Value
    end
})

GKTab:AddSection({ "🌈 Cores do Cubo GK" })

GKTab:AddButton({
    Name = "Cor: Amarelo (Padrão)",
    Callback = function()
        CONFIG.reachGKColor = Color3.fromRGB(255, 255, 0)
        notify("Cor GK", "Amarelo selecionado", 1)
    end
})

GKTab:AddButton({
    Name = "Cor: Vermelho",
    Callback = function()
        CONFIG.reachGKColor = Color3.fromRGB(255, 0, 0)
        notify("Cor GK", "Vermelho selecionado", 1)
    end
})

GKTab:AddButton({
    Name = "Cor: Azul",
    Callback = function()
        CONFIG.reachGKColor = Color3.fromRGB(0, 100, 255)
        notify("Cor GK", "Azul selecionado", 1)
    end
})

GKTab:AddButton({
    Name = "Cor: Verde",
    Callback = function()
        CONFIG.reachGKColor = Color3.fromRGB(0, 255, 0)
        notify("Cor GK", "Verde selecionado", 1)
    end
})

GKTab:AddButton({
    Name = "Cor: Roxo",
    Callback = function()
        CONFIG.reachGKColor = Color3.fromRGB(139, 0, 255)
        notify("Cor GK", "Roxo selecionado", 1)
    end
})

GKTab:AddButton({
    Name = "Cor: Laranja",
    Callback = function()
        CONFIG.reachGKColor = Color3.fromRGB(255, 165, 0)
        notify("Cor GK", "Laranja selecionado", 1)
    end
})

GKTab:AddSection({ "📊 Estatísticas GK" })

local gkStatusLabel = GKTab:AddParagraph({ "Status GK:", "Desativado" })
local gkSizeLabel = GKTab:AddParagraph({ "Tamanho do Cubo:", "25 studs" })
local gkSavesLabel = GKTab:AddParagraph({ "Defesas (Saves):", "0" })

-- ============================================
-- ABA ANTI LAG (NOVO v14.1)
-- ============================================
local AntiLagTab = Window:MakeTab({ Title = "Anti Lag", Icon = "rbxassetid://11322093465" })

AntiLagTab:AddSection({ "🚀 Otimização de Performance" })

AntiLagTab:AddToggle({
    Name = "🔥 Ativar Anti Lag",
    Default = false,
    Callback = function(value)
        CONFIG.antiLag.enabled = value
        if value then
            applyAntiLag()
            notify("Anti Lag", "OTIMIZAÇÃO ATIVADA - FPS Boost!", 3)
        else
            disableAntiLag()
            notify("Anti Lag", "Efeitos restaurados", 2)
        end
    end
})

AntiLagTab:AddSection({ "⚙️ Configurações de Otimização" })

AntiLagTab:AddToggle({
    Name = "Texturas (Decals/Textures)",
    Default = true,
    Callback = function(value)
        CONFIG.antiLag.textures = value
        addLog("Anti Lag Textures: " .. (value and "ON" or "OFF"), "info")
    end
})

AntiLagTab:AddToggle({
    Name = "Efeitos Visuais (Bloom/Blur/SunRays)",
    Default = true,
    Callback = function(value)
        CONFIG.antiLag.visualEffects = value
        addLog("Anti Lag Visual Effects: " .. (value and "ON" or "OFF"), "info")
    end
})

AntiLagTab:AddToggle({
    Name = "Materiais das Partes (Smooth Plastic)",
    Default = true,
    Callback = function(value)
        CONFIG.antiLag.parts = value
        addLog("Anti Lag Parts: " .. (value and "ON" or "OFF"), "info")
    end
})

AntiLagTab:AddToggle({
    Name = "Partículas (Fogo/Fumaça/Explosões)",
    Default = true,
    Callback = function(value)
        CONFIG.antiLag.particles = value
        addLog("Anti Lag Particles: " .. (value and "ON" or "OFF"), "info")
    end
})

AntiLagTab:AddToggle({
    Name = "Céu (Remover Skybox)",
    Default = true,
    Callback = function(value)
        CONFIG.antiLag.sky = value
        addLog("Anti Lag Sky: " .. (value and "ON" or "OFF"), "info")
    end
})

AntiLagTab:AddToggle({
    Name = "Full Bright (Iluminação Máxima)",
    Default = false,
    Callback = function(value)
        CONFIG.antiLag.fullBright = value
        addLog("Anti Lag FullBright: " .. (value and "ON" or "OFF"), "info")
    end
})

AntiLagTab:AddSection({ "📊 Status da Otimização" })

local antiLagStatusLabel = AntiLagTab:AddParagraph({ "Status:", "Desativado" })
local antiLagItemsLabel = AntiLagTab:AddParagraph({ "Itens Otimizados:", "0" })

AntiLagTab:AddSection({ "⚡ Ações Rápidas" })

AntiLagTab:AddButton({
    Name = "Ativar Tudo (MAX FPS)",
    Callback = function()
        CONFIG.antiLag.textures = true
        CONFIG.antiLag.visualEffects = true
        CONFIG.antiLag.parts = true
        CONFIG.antiLag.particles = true
        CONFIG.antiLag.sky = true
        CONFIG.antiLag.fullBright = true
        CONFIG.antiLag.enabled = true
        
        applyAntiLag()
        notify("Anti Lag", "MODO MÁXIMO DESEMPENHO ATIVADO!", 3)
        addLog("Anti Lag MAX ativado", "success")
    end
})

AntiLagTab:AddButton({
    Name = "Desativar Tudo (Restaurar)",
    Callback = function()
        CONFIG.antiLag.enabled = false
        disableAntiLag()
        notify("Anti Lag", "Todos os efeitos restaurados", 2)
    end
})

-- ============================================
-- ABA ESTATÍSTICAS (CAFUXZ1)
-- ============================================
local StatsTab = Window:MakeTab({ Title = "Estatísticas", Icon = "rbxassetid://11322093465" })

StatsTab:AddSection({ "📈 Performance da Sessão" })

local sessionTimeLabel = StatsTab:AddParagraph({ "Tempo de Uso:", "00:00" })
local fpsLabel = StatsTab:AddParagraph({ "FPS Médio:", "60" })
local tpmLabel = StatsTab:AddParagraph({ "Toques por Minuto:", "0" })

StatsTab:AddSection({ "🏆 Conquistas" })

local totalTouchesLabel = StatsTab:AddParagraph({ "Toques Totais:", "0" })
local ballsTouchedLabel = StatsTab:AddParagraph({ "Bolas Tocadas:", "0" })
local skillsActivatedLabel = StatsTab:AddParagraph({ "Skills Ativadas:", "0" })
local peakReachLabel = StatsTab:AddParagraph({ "Pico de Alcance:", "0" })
local gkTotalSavesLabel = StatsTab:AddParagraph({ "Defesas GK:", "0" })
local antiLagTotalLabel = StatsTab:AddParagraph({ "Itens Anti Lag:", "0" })
local morphsTotalLabel = StatsTab:AddParagraph({ "Morphs Realizados:", "0" })

-- ============================================
-- ABA CONFIGURAÇÕES (CAFUXZ1)
-- ============================================
local ConfigTab = Window:MakeTab({ Title = "Configurações", Icon = "rbxassetid://11322093465" })

ConfigTab:AddSection({ "🎨 Aparência" })

ConfigTab:AddDropdown({
    Name = "Tema do Hub",
    Default = "dark",
    Options = {"dark", "light", "auto"},
    Callback = function(Value)
        notify("Tema", "Modo " .. Value:upper() .. " ativado!", 2)
    end
})

ConfigTab:AddSlider({
    Name = "Escala da Interface",
    Min = 0.5,
    Max = 1.5,
    Default = 1.0,
    Increment = 0.1,
    ValueName = "x",
    Callback = function(Value)
        CONFIG.scale = Value
        notify("Config", "Escala: " .. Value .. "x (reinicie para aplicar)", 3)
    end
})

ConfigTab:AddSection({ "🔧 Sistema" })

ConfigTab:AddSlider({
    Name = "Cooldown de Scan",
    Min = 0.5,
    Max = 5.0,
    Default = 1.5,
    Increment = 0.1,
    ValueName = "s",
    Callback = function(Value)
        CONFIG.scanCooldown = Value
    end
})

ConfigTab:AddToggle({
    Name = "Auto Update (Scan Automático)",
    Default = true,
    Callback = function(value)
        CONFIG.autoUpdate = value
    end
})

ConfigTab:AddSection({ "🚨 Debug" })

ConfigTab:AddButton({
    Name = "Forçar Scan de Bolas",
    Callback = function()
        local count = findBalls()
        notify("Debug", "Bolas encontradas: " .. count, 2)
        addLog("Scan manual: " .. count .. " bolas", count > 0 and "success" or "warning")
    end
})

ConfigTab:AddButton({
    Name = "Limpar Cache de Touch",
    Callback = function()
        table.clear(touchDebounce)
        notify("Debug", "Cache limpo!", 1)
    end
})

ConfigTab:AddButton({
    Name = "Resetar Estatísticas",
    Callback = function()
        STATS.totalTouches = 0
        STATS.ballsTouched = 0
        STATS.skillsActivated = 0
        STATS.peakReach = 0
        STATS.gkSaves = 0
        STATS.antiLagItems = 0
        STATS.morphsDone = 0
        STATS.sessionStart = tick()
        notify("Stats", "Estatísticas resetadas!", 2)
        addLog("Estatísticas resetadas", "warning")
    end
})

ConfigTab:AddSection({ "⚠️ Reset Total" })

ConfigTab:AddButton({
    Name = "RESETAR TUDO",
    Callback = function()
        CONFIG.reach = 15
        CONFIG.showReachSphere = true
        CONFIG.autoTouch = true
        CONFIG.fullBodyTouch = true
        CONFIG.autoSecondTouch = true
        CONFIG.scale = 1.0
        CONFIG.theme = "dark"
        CONFIG.particleEffects = true
        CONFIG.reachGK = 25
        CONFIG.reachGKEnabled = false
        CONFIG.reachGKColor = Color3.fromRGB(255, 255, 0)
        
        -- Reset Anti Lag
        CONFIG.antiLag.enabled = false
        disableAntiLag()
        
        STATS.totalTouches = 0
        STATS.ballsTouched = 0
        STATS.skillsActivated = 0
        STATS.peakReach = 0
        STATS.gkSaves = 0
        STATS.antiLagItems = 0
        STATS.morphsDone = 0
        
        notify("Reset", "Todas as configurações padrão restauradas!", 3)
        addLog("Reset total executado", "warning")
    end
})

-- ============================================
-- LÓGICA CADUXX137 v14.0 (PRESERVADA 100%)
-- ============================================

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
    
    if #balls > STATS.peakReach then
        STATS.peakReach = #balls
    end
    
    return #balls
end

local function updateCharacter()
    local newChar = LocalPlayer.Character
    if newChar ~= Character then
        Character = newChar
        if Character then
            Humanoid = Character:WaitForChild("Humanoid", 2)
            RootPart = Character:WaitForChild("HumanoidRootPart", 2)
            if RootPart then
                addLog("Personagem conectado", "success")
            end
        else
            Humanoid = nil
            RootPart = nil
            addLog("Personagem desconectado", "warning")
        end
    end
end

local function getBodyParts()
    if not Character then return {} end
    local parts = {}
    for _, part in ipairs(Character:GetChildren()) do
        if part:IsA("BasePart") then
            if CONFIG.fullBodyTouch then
                table.insert(parts, part)
            elseif part.Name == "HumanoidRootPart" then
                table.insert(parts, part)
            end
        end
    end
    return parts
end

local function updateSphere()
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
        reachSphere.Transparency = 0.92
        reachSphere.Material = Enum.Material.ForceField
        reachSphere.Color = CONFIG.accentColor
        reachSphere.Parent = Workspace
    end
    
    if RootPart and RootPart.Parent then
        reachSphere.Position = RootPart.Position
        reachSphere.Size = Vector3.new(CONFIG.reach * 2, CONFIG.reach * 2, CONFIG.reach * 2)
    end
end

local function doTouch(ball, part)
    if not ball or not ball.Parent or not part or not part.Parent then return end
    
    local key = ball.Name .. "_" .. part.Name .. "_" .. tostring(ball)
    if touchDebounce[key] and tick() - touchDebounce[key] < 0.08 then return end
    touchDebounce[key] = tick()
    
    pcall(function()
        firetouchinterest(ball, part, 0)
        task.wait(0.01)
        firetouchinterest(ball, part, 1)
        
        if CONFIG.autoSecondTouch then
            task.wait(0.04)
            firetouchinterest(ball, part, 0)
            firetouchinterest(ball, part, 1)
        end
        
        STATS.totalTouches = STATS.totalTouches + 1
        STATS.ballsTouched = STATS.ballsTouched + 1
        
    end)
end

local function findSkillButtons()
    local buttons = {}
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and not gui.Name:find("CAFUXZ1") and not gui.Name:find("CADU") then
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
    return buttons
end

local function activateSkillButton(button)
    if not button or not button.Parent then return end
    
    local key = tostring(button)
    if activatedSkills[key] and tick() - activatedSkills[key] < skillCooldown then return end
    activatedSkills[key] = tick()
    
    pcall(function()
        if button:IsA("GuiButton") then
            for _, conn in ipairs(getconnections(button.MouseButton1Click)) do
                conn:Fire()
            end
            for _, conn in ipairs(getconnections(button.Activated)) do
                conn:Fire()
            end
            
            STATS.skillsActivated = STATS.skillsActivated + 1
        end
    end)
end

-- ============================================
-- LOOP PRINCIPAL (CAFUXZ1 v14.0)
-- ============================================

RunService.Heartbeat:Connect(function()
    STATS.fps = math.floor(1 / RunService.Heartbeat:Wait())
    
    updateCharacter()
    updateSphere()
    updateReachGK()
    
    if CONFIG.reachGKEnabled then
        processReachGK()
    end
    
    if CONFIG.autoUpdate then
        findBalls()
    end
    
    if not RootPart then return end
    
    -- Sistema Normal (apenas se GK não estiver ativo)
    if not CONFIG.reachGKEnabled then
        local now = tick()
        if now - lastTouch < 0.05 then return end
        
        local hrpPos = RootPart.Position
        local characterParts = getBodyParts()
        if #characterParts == 0 then return end
        
        local closestBall = nil
        local closestDistance = CONFIG.reach
        
        for _, ball in ipairs(balls) do
            if ball and ball.Parent then
                local distance = (ball.Position - hrpPos).Magnitude
                if distance <= CONFIG.reach and distance < closestDistance then
                    closestDistance = distance
                    closestBall = ball
                end
            end
        end
        
        if CONFIG.autoTouch and closestBall then
            lastTouch = now
            for _, part in ipairs(characterParts) do
                doTouch(closestBall, part)
            end
        end
        
        if autoSkills and closestBall and (now - lastSkillActivation > skillCooldown) then
            lastSkillActivation = now
            local skillButtons = findSkillButtons()
            for _, button in ipairs(skillButtons) do
                if button.Name == "Shoot" or button.Name == "Pass" or button.Name == "Dribble" or 
                   button.Name == "Control" or button.Name == "Chute" or button.Name == "Passe" then
                    activateSkillButton(button)
                end
            end
        end
    end
end)

-- ============================================
-- ATALHOS DE TECLADO (CAFUXZ1)
-- ============================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- F1: Minimizar/Maximizar
    if input.KeyCode == Enum.KeyCode.F1 then
        notify("Hub", "Use o botão minimizado na tela", 2)
    end
    
    -- F2: Toggle Auto Touch
    if input.KeyCode == Enum.KeyCode.F2 then
        CONFIG.autoTouch = not CONFIG.autoTouch
        notify("Auto Touch", CONFIG.autoTouch and "ATIVADO" or "DESATIVADO", 2)
        addLog("Auto Touch (F2): " .. (CONFIG.autoTouch and "ON" or "OFF"), CONFIG.autoTouch and "success" or "warning")
    end
    
    -- F3: Toggle Esfera
    if input.KeyCode == Enum.KeyCode.F3 then
        CONFIG.showReachSphere = not CONFIG.showReachSphere
        notify("Esfera", CONFIG.showReachSphere and "ATIVADA" or "DESATIVADA", 2)
        addLog("Esfera (F3): " .. (CONFIG.showReachSphere and "ON" or "OFF"), "info")
    end
    
    -- F4: Toggle Reach GK
    if input.KeyCode == Enum.KeyCode.F4 then
        CONFIG.reachGKEnabled = not CONFIG.reachGKEnabled
        notify("Reach GK", CONFIG.reachGKEnabled and "ATIVADO - Modo Goleiro" or "DESATIVADO", 2)
        addLog("Reach GK (F4): " .. (CONFIG.reachGKEnabled and "ON" or "OFF"), CONFIG.reachGKEnabled and "success" or "warning")
    end
    
    -- F5: Toggle Anti Lag
    if input.KeyCode == Enum.KeyCode.F5 then
        CONFIG.antiLag.enabled = not CONFIG.antiLag.enabled
        if CONFIG.antiLag.enabled then
            applyAntiLag()
            notify("Anti Lag", "OTIMIZAÇÃO ATIVADA (F5)", 2)
        else
            disableAntiLag()
            notify("Anti Lag", "DESATIVADO (F5)", 2)
        end
        addLog("Anti Lag (F5): " .. (CONFIG.antiLag.enabled and "ON" or "OFF"), CONFIG.antiLag.enabled and "success" or "warning")
    end
    
    -- F6: Abrir Char Morph
    if input.KeyCode == Enum.KeyCode.F6 then
        createMorphGui()
        notify("Char Morph", "Interface aberta (F6)! Digite o username.", 3)
        addLog("Char Morph aberto via F6", "info")
    end
end)

-- ============================================
-- ATUALIZADORES DE UI
-- ============================================

task.spawn(function()
    while true do
        task.wait(1)
        local count = findBalls()
        pcall(function()
            statusLabel:Set("Bolas Detectadas: " .. count)
            reachLabel:Set("Alcance Atual: " .. CONFIG.reach .. " studs")
            touchesLabel:Set("Toques Totais: " .. STATS.totalTouches)
        end)
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        
        local sessionTime = tick() - STATS.sessionStart
        local mins = math.floor(sessionTime / 60)
        local secs = math.floor(sessionTime % 60)
        
        if sessionTime > 0 then
            STATS.touchesPerMinute = math.floor((STATS.totalTouches / sessionTime) * 60)
        end
        
        pcall(function()
            sessionTimeLabel:Set("Tempo de Uso: " .. string.format("%02d:%02d", mins, secs))
            totalTouchesLabel:Set("Toques Totais: " .. STATS.totalTouches)
            ballsTouchedLabel:Set("Bolas Tocadas: " .. STATS.ballsTouched)
            skillsActivatedLabel:Set("Skills Ativadas: " .. STATS.skillsActivated)
            peakReachLabel:Set("Pico de Alcance: " .. STATS.peakReach)
            tpmLabel:Set("Toques por Minuto: " .. STATS.touchesPerMinute)
            gkTotalSavesLabel:Set("Defesas GK: " .. STATS.gkSaves)
            antiLagTotalLabel:Set("Itens Anti Lag: " .. STATS.antiLagItems)
            morphsTotalLabel:Set("Morphs Realizados: " .. STATS.morphsDone)
            
            -- Atualizar labels da aba GK
            gkStatusLabel:Set("Status GK: " .. (CONFIG.reachGKEnabled and "ATIVADO" or "Desativado"))
            gkSizeLabel:Set("Tamanho do Cubo: " .. CONFIG.reachGK .. " studs")
            gkSavesLabel:Set("Defesas (Saves): " .. STATS.gkSaves)
            
            -- Atualizar labels da aba Anti Lag
            antiLagStatusLabel:Set("Status: " .. (antiLagActive and "ATIVADO ✅" or "Desativado"))
            antiLagItemsLabel:Set("Itens Otimizados: " .. STATS.antiLagItems)
            
            -- Atualizar labels da aba Char
            morphsDoneLabel:Set("Morphs Realizados: " .. STATS.morphsDone)
        end)
    end
end)

-- ============================================
-- INICIALIZAÇÃO (Bazuka & Cafuxz1)
-- ============================================

task.spawn(function()
    repeat task.wait(0.1) until game:IsLoaded() and LocalPlayer.Character
    task.wait(0.5)
    
    -- Mensagens de inicialização
    notify("⚡ CAFUXZ1 Hub v14.2", "Ultimate Edition by Bazuka & Cafuxz1", 4)
    notify("CADUXX137", "Sistema de Ball Reach ativo!", 3)
    notify("NOVO", "Reach GK disponível (F4 ou aba Reach GK)!", 4)
    notify("NOVO v14.1", "Anti Lag System disponível (F5 ou aba Anti Lag)!", 4)
    notify("NOVO v14.2", "Char Morph disponível (F6 ou aba Char)!", 4)
    
    print("========================================")
    print("  CAFUXZ1 HUB v14.2 - ULTIMATE EDITION")
    print("========================================")
    print("Criadores: Bazuka & Cafuxz1")
    print("Ball Reach: CADUXX137 v14.0 Ultimate")
    print("Reach GK: Cafuxz1 v1.0")
    print("Anti Lag: CAFUXZ1 v14.1")
    print("Char Morph: Integrado v1.0")
    print("Interface: CAFUXZ1 Hub (WindUI)")
    print("Ícone: 88380080222477")
    print("----------------------------------------")
    print("Reach Normal: " .. CONFIG.reach .. " studs")
    print("Reach GK: " .. CONFIG.reachGK .. " studs")
    print("Auto Touch: " .. tostring(CONFIG.autoTouch))
    print("Auto Skills: " .. tostring(autoSkills))
    print("Partículas: " .. tostring(CONFIG.particleEffects))
    print("Atalhos: F1 (Minimizar) | F2 (Auto Touch) | F3 (Esfera) | F4 (GK) | F5 (Anti Lag) | F6 (Char)")
    print("========================================")
end)
