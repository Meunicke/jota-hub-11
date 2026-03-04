-- CADUXX137 v9.1 - Wide Edition (Otimizado)
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ============================================
-- CONFIGURAÇÕES (Dimensões Ajustadas)
-- ============================================
local CONFIG = {
    reach = 15,
    showReachSphere = true,
    autoTouch = true,
    fullBodyTouch = true,
    autoSecondTouch = true,
    scanCooldown = 1.5,
    menuOpen = true,
    scale = 1.0,

    -- IDs DAS SUAS IMAGENS
    iconImage = "rbxassetid://104616032736993",      -- Ícone principal
    iconBackground = "rbxassetid://96755648876012",  -- Fundo do ícone
    minimizeIcon = "rbxassetid://104616032736993",   -- Ícone do botão minimizar

    ballNames = {
        "TPS", "TCS", "ESA", "MRS", "PRS", "MPS", "SSS", "AIFA", "RBZ",
        "Ball", "Soccer", "Football", "Basketball", "Baseball",
        "BallTemplate", "GameBall", "Hitbox", "TouchPart", "GoalBall"
    },

    accentColor = Color3.fromRGB(0, 180, 255),
    accentSecondary = Color3.fromRGB(138, 43, 226),
    successColor = Color3.fromRGB(0, 255, 128),
    dangerColor = Color3.fromRGB(255, 50, 100),
    warningColor = Color3.fromRGB(255, 200, 0),
    bgColor = Color3.fromRGB(10, 10, 15),
    bgLight = Color3.fromRGB(25, 25, 35),
    bgCard = Color3.fromRGB(35, 35, 50),
    textColor = Color3.fromRGB(255, 255, 255),
    textDark = Color3.fromRGB(150, 160, 180)
}

local balls = {}
local ballConnections = {}
local reachSphere = nil
local HRP = nil
local char = nil
local touchDebounce = {}
local lastBallUpdate = 0
local lastTouch = 0
local isMinimized = false
local iconGui = nil

local function notify(title, text, duration)
    duration = duration or 3
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "⚡ CADUXX137",
            Text = text or "",
            Duration = duration
        })
    end)
end

local function tween(obj, props, time, style, direction)
    time = time or 0.3
    style = style or Enum.EasingStyle.Quint
    direction = direction or Enum.EasingDirection.Out
    local t = TweenService:Create(obj, TweenInfo.new(time, style, direction), props)
    t:Play()
    return t
end

local function makeDraggable(frame, handle)
    local dragging = false
    local dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            tween(handle, {Size = handle.Size * 0.95}, 0.1)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    local function endDrag()
        if dragging then
            dragging = false
            tween(handle, {Size = handle.Size / 0.95}, 0.1)
        end
    end

    handle.InputEnded:Connect(endDrag)
    UserInputService.InputEnded:Connect(endDrag)
end

-- ============================================
-- ÍCONE FLUTUANTE (Melhorado)
-- ============================================
local function createIconButton()
    if iconGui then iconGui:Destroy() end

    iconGui = Instance.new("ScreenGui")
    iconGui.Name = "CADU_Icon_v9"
    iconGui.ResetOnSpawn = false
    iconGui.DisplayOrder = 999999
    iconGui.Parent = playerGui

    local iconSize = 70 * CONFIG.scale

    local iconFrame = Instance.new("Frame")
    iconFrame.Name = "IconFrame"
    iconFrame.Size = UDim2.new(0, iconSize, 0, iconSize)
    iconFrame.Position = UDim2.new(0.5, -iconSize/2, 0.85, 0)
    iconFrame.BackgroundTransparency = 1
    iconFrame.BorderSizePixel = 0
    iconFrame.Parent = iconGui

    -- Fundo
    local background = Instance.new("ImageLabel")
    background.Name = "Background"
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundTransparency = 1
    background.Image = CONFIG.iconBackground
    background.ImageColor3 = Color3.new(1, 1, 1)
    background.ScaleType = Enum.ScaleType.Stretch
    background.Parent = iconFrame

    Instance.new("UICorner", background).CornerRadius = UDim.new(1, 0)

    -- Ícone
    local iconImage = Instance.new("ImageLabel")
    iconImage.Name = "Icon"
    iconImage.Size = UDim2.new(0.65, 0, 0.65, 0)
    iconImage.Position = UDim2.new(0.175, 0, 0.175, 0)
    iconImage.BackgroundTransparency = 1
    iconImage.Image = CONFIG.iconImage
    iconImage.ImageColor3 = Color3.new(1, 1, 1)
    iconImage.ScaleType = Enum.ScaleType.Fit
    iconImage.Parent = iconFrame

    -- Botão de clique
    local clickButton = Instance.new("TextButton")
    clickButton.Name = "ClickArea"
    clickButton.Size = UDim2.new(1, 0, 1, 0)
    clickButton.BackgroundTransparency = 1
    clickButton.Text = ""
    clickButton.Parent = iconFrame

    -- Efeitos hover
    clickButton.MouseEnter:Connect(function()
        tween(background, {Size = UDim2.new(1.15, 0, 1.15, 0)}, 0.2)
        tween(iconImage, {Rotation = 15}, 0.3, Enum.EasingStyle.Back)
    end)

    clickButton.MouseLeave:Connect(function()
        tween(background, {Size = UDim2.new(1, 0, 1, 0)}, 0.2)
        tween(iconImage, {Rotation = 0}, 0.3, Enum.EasingStyle.Back)
    end)

    clickButton.MouseButton1Click:Connect(function()
        tween(iconFrame, {Size = UDim2.new(0, 0, 0, 0), Rotation = 360}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.3)
        iconGui:Destroy()
        iconGui = nil
        isMinimized = false
        createMainGUI()
    end)

    makeDraggable(iconFrame, clickButton)

    iconFrame.Size = UDim2.new(0, 0, 0, 0)
    tween(iconFrame, {Size = UDim2.new(0, iconSize, 0, iconSize)}, 0.4, Enum.EasingStyle.Back)
    
    notify("CADUXX137", "Clique no ícone para abrir", 2)
end

-- ============================================
-- SISTEMA DE BOLAS
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
    return #balls
end

local function updateCharacter()
    local newChar = player.Character
    if newChar ~= char then
        char = newChar
        if char then
            HRP = char:WaitForChild("HumanoidRootPart", 2)
            notify("Personagem Detectado", "Sistema ativo!", 2)
        else
            HRP = nil
        end
    end
end

local function getBodyParts()
    if not char then return {} end
    local parts = {}
    for _, part in ipairs(char:GetChildren()) do
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
        reachSphere.Name = "CADU_ReachSphere"
        reachSphere.Shape = Enum.PartType.Ball
        reachSphere.Anchored = true
        reachSphere.CanCollide = false
        reachSphere.Transparency = 0.88
        reachSphere.Material = Enum.Material.ForceField
        reachSphere.Color = CONFIG.accentColor
        reachSphere.Parent = Workspace
    end

    if HRP and HRP.Parent then
        reachSphere.Position = HRP.Position
        reachSphere.Size = Vector3.new(CONFIG.reach * 2, CONFIG.reach * 2, CONFIG.reach * 2)
    end
end

local function doTouch(ball, part)
    if not ball or not ball.Parent or not part or not part.Parent then return end
    local key = ball.Name .. "_" .. part.Name .. "_" .. tostring(ball)
    if touchDebounce[key] and tick() - touchDebounce[key] < 0.1 then return end
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

-- ============================================
-- INTERFACE PRINCIPAL (WIDE EDITION)
-- ============================================
function createMainGUI()
    pcall(function()
        for _, v in pairs(playerGui:GetChildren()) do
            if v.Name:find("CADU") then v:Destroy() end
        end
    end)

    local gui = Instance.new("ScreenGui")
    gui.Name = "CADU_Main_v9"
    gui.ResetOnSpawn = false
    gui.Parent = playerGui

    -- DIMENSÕES: Mais largo (420), menos alto (450)
    local W, H = 420 * CONFIG.scale, 450 * CONFIG.scale

    local main = Instance.new("Frame")
    main.Name = "MainFrame"
    main.Size = UDim2.new(0, W, 0, H)
    main.Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
    main.BackgroundColor3 = CONFIG.bgColor
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = gui

    local overlay = Instance.new("Frame")
    overlay.Name = "Overlay"
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = CONFIG.bgColor
    overlay.BackgroundTransparency = 0.15
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 0
    overlay.Parent = main

    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 16 * CONFIG.scale)

    local stroke = Instance.new("UIStroke", main)
    stroke.Color = CONFIG.accentColor
    stroke.Thickness = 2.5 * CONFIG.scale

    -- Sombra
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 40 * CONFIG.scale, 1, 40 * CONFIG.scale)
    shadow.Position = UDim2.new(0, -20 * CONFIG.scale, 0, -20 * CONFIG.scale)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://131296141"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.6
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.ZIndex = -1
    shadow.Parent = main

    -- HEADER
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 55 * CONFIG.scale)
    header.BackgroundColor3 = CONFIG.accentColor
    header.BorderSizePixel = 0
    header.ZIndex = 2
    header.Parent = main

    local headerCorner = Instance.new("UICorner", header)
    headerCorner.CornerRadius = UDim.new(0, 16 * CONFIG.scale)

    local headerFix = Instance.new("Frame", header)
    headerFix.Size = UDim2.new(1, 0, 0.5, 0)
    headerFix.Position = UDim2.new(0, 0, 0.5, 0)
    headerFix.BackgroundColor3 = CONFIG.accentColor
    headerFix.BorderSizePixel = 0

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.5, 0, 1, 0)
    title.Position = UDim2.new(0, 15 * CONFIG.scale, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "CADUXX137"
    title.TextColor3 = CONFIG.textColor
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 22 * CONFIG.scale
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 3
    title.Parent = header

    local version = Instance.new("TextLabel")
    version.Size = UDim2.new(0.3, 0, 0.4, 0)
    version.Position = UDim2.new(0, 17 * CONFIG.scale, 0.6, 0)
    version.BackgroundTransparency = 1
    version.Text = "v9.1 Wide"
    version.TextColor3 = CONFIG.textDark
    version.Font = Enum.Font.GothamBold
    version.TextSize = 10 * CONFIG.scale
    version.TextXAlignment = Enum.TextXAlignment.Left
    version.ZIndex = 3
    version.Parent = header

    -- BOTÕES HEADER COM ÍCONE VISÍVEL
    local btnSize = UDim2.new(0, 36 * CONFIG.scale, 0, 36 * CONFIG.scale)

    -- BOTÃO MINIMIZAR COM IMAGEM
    local minimizeBtn = Instance.new("ImageButton")
    minimizeBtn.Name = "Minimize"
    minimizeBtn.Size = btnSize
    minimizeBtn.Position = UDim2.new(1, -82 * CONFIG.scale, 0.5, -18 * CONFIG.scale)
    minimizeBtn.BackgroundColor3 = CONFIG.bgLight
    minimizeBtn.Image = CONFIG.minimizeIcon
    minimizeBtn.ImageColor3 = CONFIG.textColor
    minimizeBtn.ScaleType = Enum.ScaleType.Fit
    minimizeBtn.AutoButtonColor = false
    minimizeBtn.ZIndex = 3
    minimizeBtn.Parent = header

    Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 10 * CONFIG.scale)

    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "Close"
    closeBtn.Size = btnSize
    closeBtn.Position = UDim2.new(1, -42 * CONFIG.scale, 0.5, -18 * CONFIG.scale)
    closeBtn.BackgroundColor3 = CONFIG.dangerColor
    closeBtn.Text = "×"
    closeBtn.TextColor3 = CONFIG.textColor
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 24 * CONFIG.scale
    closeBtn.AutoButtonColor = false
    closeBtn.ZIndex = 3
    closeBtn.Parent = header

    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 10 * CONFIG.scale)

    -- CONTEÚDO SCROLLÁVEL (Área maior horizontalmente)
    local content = Instance.new("ScrollingFrame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -20 * CONFIG.scale, 1, -120 * CONFIG.scale)
    content.Position = UDim2.new(0, 10 * CONFIG.scale, 0, 65 * CONFIG.scale)
    content.BackgroundTransparency = 1
    content.ScrollBarThickness = 4 * CONFIG.scale
    content.ScrollBarImageColor3 = CONFIG.accentColor
    content.CanvasSize = UDim2.new(0, 0, 0, 600 * CONFIG.scale)
    content.ZIndex = 1
    content.Parent = main

    -- FUNÇÃO CRIAR SEÇÃO
    local function createSection(titleText, yPos, height)
        local section = Instance.new("Frame")
        section.Size = UDim2.new(1, 0, 0, height * CONFIG.scale)
        section.Position = UDim2.new(0, 0, 0, yPos * CONFIG.scale)
        section.BackgroundColor3 = CONFIG.bgCard
        section.BorderSizePixel = 0
        section.Parent = content

        Instance.new("UICorner", section).CornerRadius = UDim.new(0, 12 * CONFIG.scale)

        local glow = Instance.new("ImageLabel", section)
        glow.Size = UDim2.new(1, 20, 1, 20)
        glow.Position = UDim2.new(0, -10, 0, -10)
        glow.BackgroundTransparency = 1
        glow.Image = "rbxassetid://5028857084"
        glow.ImageColor3 = CONFIG.accentColor
        glow.ImageTransparency = 0.95
        glow.ScaleType = Enum.ScaleType.Slice
        glow.SliceCenter = Rect.new(10, 10, 90, 90)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -20, 0, 28 * CONFIG.scale)
        lbl.Position = UDim2.new(0, 12 * CONFIG.scale, 0, 8 * CONFIG.scale)
        lbl.BackgroundTransparency = 1
        lbl.Text = titleText
        lbl.TextColor3 = CONFIG.accentColor
        lbl.Font = Enum.Font.GothamBlack
        lbl.TextSize = 14 * CONFIG.scale
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = section

        local line = Instance.new("Frame", section)
        line.Size = UDim2.new(0, 40 * CONFIG.scale, 0, 2 * CONFIG.scale)
        line.Position = UDim2.new(0, 12 * CONFIG.scale, 0, 30 * CONFIG.scale)
        line.BackgroundColor3 = CONFIG.accentSecondary
        line.BorderSizePixel = 0

        return section
    end

    -- SEÇÃO REACH (Layout horizontal otimizado)
    local reachSection = createSection("⚡ ALCANCE", 0, 110)

    local reachDisplay = Instance.new("TextLabel")
    reachDisplay.Name = "ReachValue"
    reachDisplay.Size = UDim2.new(0.25, 0, 0, 40 * CONFIG.scale)
    reachDisplay.Position = UDim2.new(0.7, 0, 0, 35 * CONFIG.scale)
    reachDisplay.BackgroundTransparency = 1
    reachDisplay.Text = tostring(CONFIG.reach)
    reachDisplay.TextColor3 = CONFIG.accentColor
    reachDisplay.Font = Enum.Font.GothamBlack
    reachDisplay.TextSize = 32 * CONFIG.scale
    reachDisplay.TextXAlignment = Enum.TextXAlignment.Right
    reachDisplay.Parent = reachSection

    local reachUnit = Instance.new("TextLabel")
    reachUnit.Size = UDim2.new(0.15, 0, 0, 18 * CONFIG.scale)
    reachUnit.Position = UDim2.new(0.83, 0, 0, 48 * CONFIG.scale)
    reachUnit.BackgroundTransparency = 1
    reachUnit.Text = "studs"
    reachUnit.TextColor3 = CONFIG.textDark
    reachUnit.Font = Enum.Font.Gotham
    reachUnit.TextSize = 11 * CONFIG.scale
    reachUnit.Parent = reachSection

    -- Controles lado a lado
    local minusBtn = Instance.new("TextButton")
    minusBtn.Name = "Minus"
    minusBtn.Size = UDim2.new(0, 45 * CONFIG.scale, 0, 38 * CONFIG.scale)
    minusBtn.Position = UDim2.new(0, 12 * CONFIG.scale, 0, 38 * CONFIG.scale)
    minusBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    minusBtn.Text = "−"
    minusBtn.TextColor3 = CONFIG.textColor
    minusBtn.Font = Enum.Font.GothamBlack
    minusBtn.TextSize = 22 * CONFIG.scale
    minusBtn.AutoButtonColor = false
    minusBtn.Parent = reachSection
    Instance.new("UICorner", minusBtn).CornerRadius = UDim.new(0, 10 * CONFIG.scale)

    local plusBtn = Instance.new("TextButton")
    plusBtn.Name = "Plus"
    plusBtn.Size = UDim2.new(0, 45 * CONFIG.scale, 0, 38 * CONFIG.scale)
    plusBtn.Position = UDim2.new(0, 62 * CONFIG.scale, 0, 38 * CONFIG.scale)
    plusBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    plusBtn.Text = "+"
    plusBtn.TextColor3 = CONFIG.textColor
    plusBtn.Font = Enum.Font.GothamBlack
    plusBtn.TextSize = 22 * CONFIG.scale
    plusBtn.AutoButtonColor = false
    plusBtn.Parent = reachSection
    Instance.new("UICorner", plusBtn).CornerRadius = UDim.new(0, 10 * CONFIG.scale)

    -- Slider mais largo
    local sliderTrack = Instance.new("Frame")
    sliderTrack.Size = UDim2.new(0.45, 0, 0, 8 * CONFIG.scale)
    sliderTrack.Position = UDim2.new(0, 12 * CONFIG.scale, 0, 85 * CONFIG.scale)
    sliderTrack.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    sliderTrack.BorderSizePixel = 0
    sliderTrack.Parent = reachSection
    Instance.new("UICorner", sliderTrack).CornerRadius = UDim.new(0, 4 * CONFIG.scale)

    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "SliderFill"
    sliderFill.Size = UDim2.new(CONFIG.reach / 50, 0, 1, 0)
    sliderFill.BackgroundColor3 = CONFIG.accentColor
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderTrack
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(0, 4 * CONFIG.scale)

    local sliderKnob = Instance.new("Frame")
    sliderKnob.Name = "Knob"
    sliderKnob.Size = UDim2.new(0, 16 * CONFIG.scale, 0, 16 * CONFIG.scale)
    sliderKnob.Position = UDim2.new(CONFIG.reach / 50, -8 * CONFIG.scale, 0.5, -8 * CONFIG.scale)
    sliderKnob.BackgroundColor3 = CONFIG.textColor
    sliderKnob.BorderSizePixel = 0
    sliderKnob.Parent = sliderTrack
    Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)

    -- Toggle Esfera
    local sphereToggle = Instance.new("TextButton")
    sphereToggle.Size = UDim2.new(0, 55 * CONFIG.scale, 0, 28 * CONFIG.scale)
    sphereToggle.Position = UDim2.new(1, -70 * CONFIG.scale, 0, 75 * CONFIG.scale)
    sphereToggle.BackgroundColor3 = CONFIG.showReachSphere and CONFIG.successColor or Color3.fromRGB(60, 60, 75)
    sphereToggle.Text = CONFIG.showReachSphere and "ON" or "OFF"
    sphereToggle.TextColor3 = CONFIG.textColor
    sphereToggle.Font = Enum.Font.GothamBlack
    sphereToggle.TextSize = 11 * CONFIG.scale
    sphereToggle.AutoButtonColor = false
    sphereToggle.Parent = reachSection
    Instance.new("UICorner", sphereToggle).CornerRadius = UDim.new(0, 14 * CONFIG.scale)

    local sphereLbl = Instance.new("TextLabel")
    sphereLbl.Size = UDim2.new(0.4, 0, 0, 28 * CONFIG.scale)
    sphereLbl.Position = UDim2.new(0.52, 0, 0, 75 * CONFIG.scale)
    sphereLbl.BackgroundTransparency = 1
    sphereLbl.Text = "Mostrar Esfera"
    sphereLbl.TextColor3 = CONFIG.textDark
    sphereLbl.Font = Enum.Font.GothamBold
    sphereLbl.TextSize = 11 * CONFIG.scale
    sphereLbl.TextXAlignment = Enum.TextXAlignment.Right
    sphereLbl.Parent = reachSection

    -- SEÇÃO BOLAS (Compacta)
    local ballsSection = createSection("🔮 BOLAS", 120, 80)

    local ballsCount = Instance.new("TextLabel")
    ballsCount.Name = "BallsCount"
    ballsCount.Size = UDim2.new(1, -24, 0, 22 * CONFIG.scale)
    ballsCount.Position = UDim2.new(0, 12 * CONFIG.scale, 0, 38 * CONFIG.scale)
    ballsCount.BackgroundTransparency = 1
    ballsCount.Text = "Buscando..."
    ballsCount.TextColor3 = CONFIG.textDark
    ballsCount.Font = Enum.Font.GothamBold
    ballsCount.TextSize = 12 * CONFIG.scale
    ballsCount.Parent = ballsSection

    -- SEÇÃO CONTROLES (Layout em grid horizontal)
    local controlSection = createSection("🎮 CONTROLES", 210, 140)

    -- Grid 2x2 para economizar espaço vertical
    local function createToggle(y, x, configKey, labelText)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 55 * CONFIG.scale, 0, 26 * CONFIG.scale)
        btn.Position = UDim2.new(x, 0, 0, y)
        btn.BackgroundColor3 = CONFIG[configKey] and CONFIG.successColor or Color3.fromRGB(60, 60, 75)
        btn.Text = CONFIG[configKey] and "ON" or "OFF"
        btn.TextColor3 = CONFIG.textColor
        btn.Font = Enum.Font.GothamBlack
        btn.TextSize = 10 * CONFIG.scale
        btn.AutoButtonColor = false
        btn.Parent = controlSection
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 13 * CONFIG.scale)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.35, 0, 0, 26 * CONFIG.scale)
        lbl.Position = UDim2.new(x - 0.38, 5 * CONFIG.scale, 0, y)
        lbl.BackgroundTransparency = 1
        lbl.Text = labelText
        lbl.TextColor3 = CONFIG.textDark
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 11 * CONFIG.scale
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = controlSection

        return btn, lbl
    end

    local autoBtn, autoLbl = createToggle(40, 0.55, "autoTouch", "Auto Touch")
    local bodyBtn, bodyLbl = createToggle(40, 1.05, "fullBodyTouch", "Full Body")
    local secondBtn, secondLbl = createToggle(85, 0.55, "autoSecondTouch", "Double Touch")
    
    -- Auto Skills (sempre ativo)
    local skillsBtn = Instance.new("TextButton")
    skillsBtn.Size = UDim2.new(0, 55 * CONFIG.scale, 0, 26 * CONFIG.scale)
    skillsBtn.Position = UDim2.new(1.05, 0, 0, 85)
    skillsBtn.BackgroundColor3 = CONFIG.successColor
    skillsBtn.Text = "ON"
    skillsBtn.TextColor3 = CONFIG.textColor
    skillsBtn.Font = Enum.Font.GothamBlack
    skillsBtn.TextSize = 10 * CONFIG.scale
    skillsBtn.AutoButtonColor = false
    skillsBtn.Parent = controlSection
    Instance.new("UICorner", skillsBtn).CornerRadius = UDim.new(0, 13 * CONFIG.scale)

    local skillsLbl = Instance.new("TextLabel")
    skillsLbl.Size = UDim2.new(0.35, 0, 0, 26 * CONFIG.scale)
    skillsLbl.Position = UDim2.new(0.67, 5 * CONFIG.scale, 0, 85)
    skillsLbl.BackgroundTransparency = 1
    skillsLbl.Text = "Auto Skills"
    skillsLbl.TextColor3 = CONFIG.textDark
    skillsLbl.Font = Enum.Font.GothamBold
    skillsLbl.TextSize = 11 * CONFIG.scale
    skillsLbl.TextXAlignment = Enum.TextXAlignment.Left
    skillsLbl.Parent = controlSection

    -- SEÇÃO STATUS
    local statusSection = createSection("📊 STATUS", 360, 70)

    local statusText = Instance.new("TextLabel")
    statusText.Name = "StatusText"
    statusText.Size = UDim2.new(1, -24, 0, 40 * CONFIG.scale)
    statusText.Position = UDim2.new(0, 12 * CONFIG.scale, 0, 32 * CONFIG.scale)
    statusText.BackgroundTransparency = 1
    statusText.Text = "🟢 Sistema Ativo\nAguardando..."
    statusText.TextColor3 = CONFIG.successColor
    statusText.Font = Enum.Font.GothamBold
    statusText.TextSize = 11 * CONFIG.scale
    statusText.TextWrapped = true
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.Parent = statusSection

    -- ============================================
    -- FUNÇÕES DE ATUALIZAÇÃO
    -- ============================================
    local function updateReachDisplay()
        reachDisplay.Text = tostring(CONFIG.reach)
        local fillScale = math.clamp(CONFIG.reach / 50, 0, 1)
        tween(sliderFill, {Size = UDim2.new(fillScale, 0, 1, 0)}, 0.2)
        tween(sliderKnob, {Position = UDim2.new(fillScale, -8 * CONFIG.scale, 0.5, -8 * CONFIG.scale)}, 0.2)
    end

    local function updateBallsList()
        ballsCount.Text = #balls .. " bolas detectadas no mapa"
    end

    local function updateStatus(text, isError)
        statusText.Text = text
        statusText.TextColor3 = isError and CONFIG.dangerColor or CONFIG.successColor
    end

    -- ============================================
    -- EVENTOS
    -- ============================================
    minusBtn.MouseButton1Click:Connect(function()
        CONFIG.reach = math.max(1, CONFIG.reach - 1)
        updateReachDisplay()
    end)

    plusBtn.MouseButton1Click:Connect(function()
        CONFIG.reach = math.min(50, CONFIG.reach + 1)
        updateReachDisplay()
    end)

    local draggingSlider = false
    sliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = true
            local relativeX = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
            CONFIG.reach = math.floor(relativeX * 50)
            updateReachDisplay()
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local relativeX = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
            CONFIG.reach = math.floor(relativeX * 50)
            updateReachDisplay()
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = false
        end
    end)

    sphereToggle.MouseButton1Click:Connect(function()
        CONFIG.showReachSphere = not CONFIG.showReachSphere
        sphereToggle.Text = CONFIG.showReachSphere and "ON" or "OFF"
        tween(sphereToggle, {BackgroundColor3 = CONFIG.showReachSphere and CONFIG.successColor or Color3.fromRGB(60, 60, 75)}, 0.2)
        notify("CADUXX137", "Esfera: " .. (CONFIG.showReachSphere and "ATIVADA" or "DESATIVADA"), 2)
    end)

    autoBtn.MouseButton1Click:Connect(function()
        CONFIG.autoTouch = not CONFIG.autoTouch
        autoBtn.Text = CONFIG.autoTouch and "ON" or "OFF"
        tween(autoBtn, {BackgroundColor3 = CONFIG.autoTouch and CONFIG.successColor or Color3.fromRGB(60, 60, 75)}, 0.2)
        notify("CADUXX137", "Auto Touch: " .. (CONFIG.autoTouch and "ATIVADO" or "DESATIVADO"), 2)
    end)

    bodyBtn.MouseButton1Click:Connect(function()
        CONFIG.fullBodyTouch = not CONFIG.fullBodyTouch
        bodyBtn.Text = CONFIG.fullBodyTouch and "ON" or "OFF"
        tween(bodyBtn, {BackgroundColor3 = CONFIG.fullBodyTouch and CONFIG.successColor or Color3.fromRGB(60, 60, 75)}, 0.2)
        notify("CADUXX137", "Full Body: " .. (CONFIG.fullBodyTouch and "ATIVADO" or "DESATIVADO"), 2)
    end)

    secondBtn.MouseButton1Click:Connect(function()
        CONFIG.autoSecondTouch = not CONFIG.autoSecondTouch
        secondBtn.Text = CONFIG.autoSecondTouch and "ON" or "OFF"
        tween(secondBtn, {BackgroundColor3 = CONFIG.autoSecondTouch and CONFIG.successColor or Color3.fromRGB(60, 60, 75)}, 0.2)
        notify("CADUXX137", "Double Touch: " .. (CONFIG.autoSecondTouch and "ATIVADO" or "DESATIVADO"), 2)
    end)

    skillsBtn.MouseButton1Click:Connect(function()
        autoSkills = not autoSkills
        skillsBtn.Text = autoSkills and "ON" or "OFF"
        tween(skillsBtn, {BackgroundColor3 = autoSkills and CONFIG.successColor or Color3.fromRGB(60, 60, 75)}, 0.2)
        notify("CADUXX137", "Auto Skills: " .. (autoSkills and "ATIVADO" or "DESATIVADO"), 2)
    end)

    -- Minimizar com animação
    minimizeBtn.MouseButton1Click:Connect(function()
        isMinimized = true
        tween(main, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.4)
        gui:Destroy()
        createIconButton()
    end)

    closeBtn.MouseButton1Click:Connect(function()
        tween(main, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
        task.wait(0.3)
        gui:Destroy()
        if reachSphere then reachSphere:Destroy() end
        for _, conn in ipairs(ballConnections) do
            pcall(function() conn:Disconnect() end)
        end
    end)

    -- Hover effects
    local function addHoverEffect(btn, normalColor, hoverColor)
        btn.MouseEnter:Connect(function()
            tween(btn, {BackgroundColor3 = hoverColor}, 0.2)
        end)
        btn.MouseLeave:Connect(function()
            tween(btn, {BackgroundColor3 = normalColor}, 0.2)
        end)
    end

    addHoverEffect(minusBtn, Color3.fromRGB(60, 60, 75), Color3.fromRGB(80, 80, 95))
    addHoverEffect(plusBtn, Color3.fromRGB(60, 60, 75), Color3.fromRGB(80, 80, 95))
    addHoverEffect(closeBtn, CONFIG.dangerColor, Color3.fromRGB(255, 80, 120))
    
    minimizeBtn.MouseEnter:Connect(function()
        tween(minimizeBtn, {BackgroundColor3 = Color3.fromRGB(50, 50, 60)}, 0.2)
        tween(minimizeBtn, {ImageColor3 = CONFIG.accentColor}, 0.2)
    end)
    minimizeBtn.MouseLeave:Connect(function()
        tween(minimizeBtn, {BackgroundColor3 = CONFIG.bgLight}, 0.2)
        tween(minimizeBtn, {ImageColor3 = CONFIG.textColor}, 0.2)
    end)

    makeDraggable(main, header)

    -- Animação de entrada
    main.Size = UDim2.new(0, 0, 0, 0)
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
    tween(main, {Size = UDim2.new(0, W, 0, H), Position = UDim2.new(0.5, -W/2, 0.5, -H/2)}, 0.5, Enum.EasingStyle.Back)

    notify("⚡ CADUXX137 v9.1", "Wide Edition carregada!", 3)
    updateStatus("🟢 Sistema Iniciado\nPronto para uso", false)
end

-- ============================================
-- SISTEMA DE SKILLS
-- ============================================
local autoSkills = true
local lastSkillActivation = 0
local skillCooldown = 0.5
local activatedSkills = {}

local skillButtonNames = {
    "Shoot", "Pass", "Long", "Tackle", "Dribble", "GK", "Throw",
    "Control", "Left", "Right", "High", "Low", "Rainbow",
    "Chip", "Heel", "Volley", "Back Right", "Back Left",
    "Carry", "Fake Shot", "Drag Back", "Header", "Bicycle",
    "Shot", "Slide", "Goalkeeper", "Catch", "Punch",
    "Short Pass", "Through Ball", "Cross", "Curve",
    "Power Shot", "Precision", "First Touch"
}

local function findSkillButtons()
    local buttons = {}
    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Name ~= "CADU_Main_v9" and gui.Name ~= "CADU_Icon_v9" then
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
    if activatedSkills[key] and tick() - activatedSkills[key] < skillCooldown then return end
    activatedSkills[key] = tick()

    pcall(function()
        if button:IsA("GuiButton") then
            for _, conn in ipairs(getconnections(button.MouseButton1Click)) do conn:Fire() end
            for _, conn in ipairs(getconnections(button.Activated)) do conn:Fire() end
            if button.MouseButton1Click then button.MouseButton1Click:Fire() end
            if button.Activated then button.Activated:Fire() end
            
            local originalSize = button.Size
            tween(button, {Size = UDim2.new(originalSize.X.Scale * 0.95, originalSize.X.Offset * 0.95,
                originalSize.Y.Scale * 0.95, originalSize.Y.Offset * 0.95)}, 0.05)
            task.delay(0.05, function()
                if button and button.Parent then tween(button, {Size = originalSize}, 0.05) end
            end)
        end
    end)
end

task.spawn(function()
    while true do
        task.wait(5)
        local now = tick()
        for key, time in pairs(activatedSkills) do
            if now - time > 10 then activatedSkills[key] = nil end
        end
    end
end)

-- ============================================
-- LOOP PRINCIPAL
-- ============================================
RunService.Heartbeat:Connect(function()
    updateCharacter()
    updateSphere()
    findBalls()

    if not HRP then return end
    local now = tick()
    if now - lastTouch < 0.05 then return end

    local hrpPos = HRP.Position
    local characterParts = getBodyParts()
    if #characterParts == 0 then return end

    local ballInRange = false
    local closestBall = nil
    local closestDistance = CONFIG.reach

    for _, ball in ipairs(balls) do
        if ball and ball.Parent then
            local distance = (ball.Position - hrpPos).Magnitude
            if distance <= CONFIG.reach and distance < closestDistance then
                ballInRange = true
                closestDistance = distance
                closestBall = ball
            end
        end
    end

    if CONFIG.autoTouch and ballInRange and closestBall then
        lastTouch = now
        for _, part in ipairs(characterParts) do
            doTouch(closestBall, part)
        end
    end

    if autoSkills and ballInRange and (now - lastSkillActivation > skillCooldown) then
        lastSkillActivation = now
        local skillButtons = findSkillButtons()
        local mainSkills = {"Shoot", "Pass", "Dribble", "Control"}
        for _, button in ipairs(skillButtons) do
            for _, mainSkill in ipairs(mainSkills) do
                if button.Name == mainSkill or button.Text == mainSkill then
                    activateSkillButton(button)
                    break
                end
            end
        end
    end
end)

-- Inicialização
createMainGUI()
print("[CADUXX137] v9.1 Wide Edition carregada - Icon visível no botão minimizar")
