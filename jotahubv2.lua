-- CADUXX137 v9.2 - Modern Glass Edition
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ============================================
-- CONFIGURAÇÕES MODERNAS
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

    -- IDs das imagens
    iconImage = "rbxassetid://104616032736993",
    iconBackground = "rbxassetid://96755648876012",

    -- Cores Modernas (Glassmorphism)
    primary = Color3.fromRGB(0, 170, 255),
    secondary = Color3.fromRGB(138, 43, 226),
    success = Color3.fromRGB(0, 230, 118),
    danger = Color3.fromRGB(255, 71, 87),
    warning = Color3.fromRGB(255, 193, 7),
    
    -- Cores de fundo escuro moderno
    bgDark = Color3.fromRGB(15, 15, 25),
    bgCard = Color3.fromRGB(25, 25, 40),
    bgHover = Color3.fromRGB(35, 35, 55),
    bgLight = Color3.fromRGB(45, 45, 70),
    
    textPrimary = Color3.fromRGB(255, 255, 255),
    textSecondary = Color3.fromRGB(170, 180, 200),
    textMuted = Color3.fromRGB(120, 130, 150),
    
    -- Cores do glass effect
    glassBg = Color3.fromRGB(20, 20, 35),
    glassTransparency = 0.15,
    strokeColor = Color3.fromRGB(60, 60, 90)
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

-- ============================================
-- SISTEMA DE ARRASTAR
-- ============================================
local function makeDraggable(frame, handle)
    local dragging = false
    local dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            tween(handle, {BackgroundTransparency = 0.1}, 0.1)
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
            tween(handle, {BackgroundTransparency = handle:GetAttribute("OriginalTransparency") or 0}, 0.1)
        end
    end

    handle.InputEnded:Connect(endDrag)
    UserInputService.InputEnded:Connect(endDrag)
end

-- ============================================
-- ÍCONE FLUTUANTE (Estilo Moderno)
-- ============================================
local function createIconButton()
    if iconGui then iconGui:Destroy() end

    iconGui = Instance.new("ScreenGui")
    iconGui.Name = "CADU_Icon_v9"
    iconGui.ResetOnSpawn = false
    iconGui.DisplayOrder = 999999
    iconGui.Parent = playerGui

    local iconSize = 65 * CONFIG.scale

    local iconFrame = Instance.new("Frame")
    iconFrame.Name = "IconFrame"
    iconFrame.Size = UDim2.new(0, iconSize, 0, iconSize)
    iconFrame.Position = UDim2.new(0.5, -iconSize/2, 0.85, 0)
    iconFrame.BackgroundColor3 = CONFIG.bgCard
    iconFrame.BackgroundTransparency = 0.2
    iconFrame.BorderSizePixel = 0
    iconFrame.Parent = iconGui

    -- Corner radius moderno
    Instance.new("UICorner", iconFrame).CornerRadius = UDim.new(0, 20 * CONFIG.scale)
    
    -- Stroke sutil
    local stroke = Instance.new("UIStroke", iconFrame)
    stroke.Color = CONFIG.primary
    stroke.Thickness = 2 * CONFIG.scale
    stroke.Transparency = 0.5

    -- Glow effect
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.Size = UDim2.new(1.5, 0, 1.5, 0)
    glow.Position = UDim2.new(-0.25, 0, -0.25, 0)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://5028857084"
    glow.ImageColor3 = CONFIG.primary
    glow.ImageTransparency = 0.9
    glow.ScaleType = Enum.ScaleType.Slice
    glow.SliceCenter = Rect.new(10, 10, 90, 90)
    glow.ZIndex = -1
    glow.Parent = iconFrame

    -- Ícone
    local iconImage = Instance.new("ImageLabel")
    iconImage.Name = "Icon"
    iconImage.Size = UDim2.new(0.6, 0, 0.6, 0)
    iconImage.Position = UDim2.new(0.2, 0, 0.2, 0)
    iconImage.BackgroundTransparency = 1
    iconImage.Image = CONFIG.iconImage
    iconImage.ImageColor3 = CONFIG.textPrimary
    iconImage.ScaleType = Enum.ScaleType.Fit
    iconImage.Parent = iconFrame

    -- Botão de clique
    local clickButton = Instance.new("TextButton")
    clickButton.Name = "ClickArea"
    clickButton.Size = UDim2.new(1, 0, 1, 0)
    clickButton.BackgroundTransparency = 1
    clickButton.Text = ""
    clickButton.Parent = iconFrame

    -- Animações hover
    clickButton.MouseEnter:Connect(function()
        tween(iconFrame, {Size = UDim2.new(0, iconSize * 1.1, 0, iconSize * 1.1)}, 0.2)
        tween(stroke, {Transparency = 0}, 0.2)
        tween(glow, {ImageTransparency = 0.7}, 0.2)
    end)

    clickButton.MouseLeave:Connect(function()
        tween(iconFrame, {Size = UDim2.new(0, iconSize, 0, iconSize)}, 0.2)
        tween(stroke, {Transparency = 0.5}, 0.2)
        tween(glow, {ImageTransparency = 0.9}, 0.2)
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

    -- Animação de entrada
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
            for _, name in ipairs({"TPS", "TCS", "ESA", "MRS", "PRS", "MPS", "SSS", "AIFA", "RBZ",
                "Ball", "Soccer", "Football", "Basketball", "Baseball",
                "BallTemplate", "GameBall", "Hitbox", "TouchPart", "GoalBall"}) do
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
        reachSphere.Transparency = 0.9
        reachSphere.Material = Enum.Material.ForceField
        reachSphere.Color = CONFIG.primary
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
-- INTERFACE PRINCIPAL - MODERN GLASS STYLE
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

    -- Dimensões: Wide e compacto
    local W, H = 440 * CONFIG.scale, 380 * CONFIG.scale

    -- Frame principal com glass effect
    local main = Instance.new("Frame")
    main.Name = "MainFrame"
    main.Size = UDim2.new(0, W, 0, H)
    main.Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
    main.BackgroundColor3 = CONFIG.glassBg
    main.BackgroundTransparency = CONFIG.glassTransparency
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = gui

    -- Corner radius moderno
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 24 * CONFIG.scale)

    -- Stroke elegante
    local mainStroke = Instance.new("UIStroke", main)
    mainStroke.Color = CONFIG.strokeColor
    mainStroke.Thickness = 1.5 * CONFIG.scale
    mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- Sombra suave
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 60 * CONFIG.scale, 1, 60 * CONFIG.scale)
    shadow.Position = UDim2.new(0, -30 * CONFIG.scale, 0, -30 * CONFIG.scale)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://131296141"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.75
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.ZIndex = -1
    shadow.Parent = main

    -- ============================================
    -- HEADER MODERNO
    -- ============================================
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 70 * CONFIG.scale)
    header.BackgroundColor3 = CONFIG.bgCard
    header.BackgroundTransparency = 0.5
    header.BorderSizePixel = 0
    header.ZIndex = 2
    header.Parent = main
    header:SetAttribute("OriginalTransparency", 0.5)

    -- Gradiente sutil no header
    local headerGradient = Instance.new("UIGradient", header)
    headerGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, CONFIG.bgCard),
        ColorSequenceKeypoint.new(1, CONFIG.bgDark)
    })
    headerGradient.Rotation = 90

    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 24 * CONFIG.scale)

    -- Fix para cantos arredondados
    local headerFix = Instance.new("Frame", header)
    headerFix.Size = UDim2.new(1, 0, 0.5, 0)
    headerFix.Position = UDim2.new(0, 0, 0.5, 0)
    headerFix.BackgroundColor3 = CONFIG.bgCard
    headerFix.BorderSizePixel = 0
    headerFix.ZIndex = 1

    -- Título com ícone
    local titleIcon = Instance.new("TextLabel")
    titleIcon.Size = UDim2.new(0, 40 * CONFIG.scale, 0, 40 * CONFIG.scale)
    titleIcon.Position = UDim2.new(0, 20 * CONFIG.scale, 0.5, -20 * CONFIG.scale)
    titleIcon.BackgroundTransparency = 1
    titleIcon.Text = "⚡"
    titleIcon.TextColor3 = CONFIG.primary
    titleIcon.Font = Enum.Font.GothamBlack
    titleIcon.TextSize = 28 * CONFIG.scale
    titleIcon.ZIndex = 3
    titleIcon.Parent = header

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.4, 0, 0.6, 0)
    title.Position = UDim2.new(0, 65 * CONFIG.scale, 0.2, 0)
    title.BackgroundTransparency = 1
    title.Text = "CADUXX137"
    title.TextColor3 = CONFIG.textPrimary
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 22 * CONFIG.scale
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 3
    title.Parent = header

    local version = Instance.new("TextLabel")
    version.Size = UDim2.new(0.3, 0, 0.35, 0)
    version.Position = UDim2.new(0, 67 * CONFIG.scale, 0.65, 0)
    version.BackgroundTransparency = 1
    version.Text = "v9.2 Modern"
    version.TextColor3 = CONFIG.primary
    version.Font = Enum.Font.GothamBold
    version.TextSize = 11 * CONFIG.scale
    version.TextXAlignment = Enum.TextXAlignment.Left
    version.ZIndex = 3
    version.Parent = header

    -- ============================================
    -- BOTÕES HEADER - MINIMIZAR COM EMOJI VISÍVEL
    -- ============================================
    local btnSize = UDim2.new(0, 42 * CONFIG.scale, 0, 42 * CONFIG.scale)
    local btnCorner = UDim.new(0, 12 * CONFIG.scale)

    -- BOTÃO MINIMIZAR - EMOJI 🎯 VISÍVEL
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "Minimize"
    minimizeBtn.Size = btnSize
    minimizeBtn.Position = UDim2.new(1, -95 * CONFIG.scale, 0.5, -21 * CONFIG.scale)
    minimizeBtn.BackgroundColor3 = CONFIG.bgHover
    minimizeBtn.Text = "🎯"
    minimizeBtn.TextColor3 = CONFIG.textPrimary
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.TextSize = 20 * CONFIG.scale
    minimizeBtn.AutoButtonColor = false
    minimizeBtn.ZIndex = 3
    minimizeBtn.Parent = header

    Instance.new("UICorner", minimizeBtn).CornerRadius = btnCorner
    
    -- Ícone de minimizar visível (adicionar imagem pequena ao lado do emoji)
    local minimizeIcon = Instance.new("ImageLabel")
    minimizeIcon.Size = UDim2.new(0.5, 0, 0.5, 0)
    minimizeIcon.Position = UDim2.new(0.25, 0, 0.25, 0)
    minimizeIcon.BackgroundTransparency = 1
    minimizeIcon.Image = CONFIG.iconImage
    minimizeIcon.ImageColor3 = CONFIG.textPrimary
    minimizeIcon.ScaleType = Enum.ScaleType.Fit
    minimizeIcon.ZIndex = 4
    minimizeIcon.Parent = minimizeBtn
    minimizeIcon.Visible = false  -- Começa invisível, mostra só o emoji

    -- BOTÃO FECHAR
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "Close"
    closeBtn.Size = btnSize
    closeBtn.Position = UDim2.new(1, -50 * CONFIG.scale, 0.5, -21 * CONFIG.scale)
    closeBtn.BackgroundColor3 = CONFIG.danger
    closeBtn.BackgroundTransparency = 0.2
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = CONFIG.textPrimary
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18 * CONFIG.scale
    closeBtn.AutoButtonColor = false
    closeBtn.ZIndex = 3
    closeBtn.Parent = header

    Instance.new("UICorner", closeBtn).CornerRadius = btnCorner

    -- ============================================
    -- CONTEÚDO COM LAYOUT MODERNO
    -- ============================================
    local content = Instance.new("ScrollingFrame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -30 * CONFIG.scale, 1, -90 * CONFIG.scale)
    content.Position = UDim2.new(0, 15 * CONFIG.scale, 0, 80 * CONFIG.scale)
    content.BackgroundTransparency = 1
    content.ScrollBarThickness = 4 * CONFIG.scale
    content.ScrollBarImageColor3 = CONFIG.primary
    content.CanvasSize = UDim2.new(0, 0, 0, 500 * CONFIG.scale)
    content.ZIndex = 1
    content.Parent = main

    -- Função para criar cards modernos
    local function createCard(titleText, yPos, height, icon)
        local card = Instance.new("Frame")
        card.Name = titleText .. "Card"
        card.Size = UDim2.new(1, 0, 0, height * CONFIG.scale)
        card.Position = UDim2.new(0, 0, 0, yPos * CONFIG.scale)
        card.BackgroundColor3 = CONFIG.bgCard
        card.BackgroundTransparency = 0.4
        card.BorderSizePixel = 0
        card.Parent = content

        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 16 * CONFIG.scale)

        -- Stroke sutil
        local cardStroke = Instance.new("UIStroke", card)
        cardStroke.Color = CONFIG.strokeColor
        cardStroke.Thickness = 1 * CONFIG.scale
        cardStroke.Transparency = 0.5

        -- Header do card
        local cardHeader = Instance.new("Frame")
        cardHeader.Size = UDim2.new(1, 0, 0, 35 * CONFIG.scale)
        cardHeader.BackgroundTransparency = 1
        cardHeader.Position = UDim2.new(0, 0, 0, 5 * CONFIG.scale)
        cardHeader.Parent = card

        local iconLabel = Instance.new("TextLabel")
        iconLabel.Size = UDim2.new(0, 30 * CONFIG.scale, 0, 30 * CONFIG.scale)
        iconLabel.Position = UDim2.new(0, 15 * CONFIG.scale, 0, 2 * CONFIG.scale)
        iconLabel.BackgroundTransparency = 1
        iconLabel.Text = icon or "🔹"
        iconLabel.Font = Enum.Font.GothamBold
        iconLabel.TextSize = 18 * CONFIG.scale
        iconLabel.Parent = cardHeader

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(0.7, 0, 1, 0)
        titleLabel.Position = UDim2.new(0, 50 * CONFIG.scale, 0, 0)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = titleText
        titleLabel.TextColor3 = CONFIG.textPrimary
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextSize = 14 * CONFIG.scale
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Parent = cardHeader

        -- Linha decorativa
        local line = Instance.new("Frame", card)
        line.Size = UDim2.new(0.9, 0, 0, 2 * CONFIG.scale)
        line.Position = UDim2.new(0.05, 0, 0, 35 * CONFIG.scale)
        line.BackgroundColor3 = CONFIG.primary
        line.BackgroundTransparency = 0.6
        line.BorderSizePixel = 0
        Instance.new("UICorner", line).CornerRadius = UDim.new(1, 0)

        return card
    end

    -- ============================================
    -- CARD DE ALCANCE (Reach)
    -- ============================================
    local reachCard = createCard("ALCANCE", 0, 130, "🎯")

    -- Display de valor grande
    local reachValueBg = Instance.new("Frame")
    reachValueBg.Size = UDim2.new(0, 80 * CONFIG.scale, 0, 50 * CONFIG.scale)
    reachValueBg.Position = UDim2.new(1, -95 * CONFIG.scale, 0, 45 * CONFIG.scale)
    reachValueBg.BackgroundColor3 = CONFIG.bgDark
    reachValueBg.BorderSizePixel = 0
    reachValueBg.Parent = reachCard
    Instance.new("UICorner", reachValueBg).CornerRadius = UDim.new(0, 12 * CONFIG.scale)

    local reachDisplay = Instance.new("TextLabel")
    reachDisplay.Name = "ReachValue"
    reachDisplay.Size = UDim2.new(1, 0, 1, 0)
    reachDisplay.BackgroundTransparency = 1
    reachDisplay.Text = tostring(CONFIG.reach)
    reachDisplay.TextColor3 = CONFIG.primary
    reachDisplay.Font = Enum.Font.GothamBlack
    reachDisplay.TextSize = 28 * CONFIG.scale
    reachDisplay.Parent = reachValueBg

    local reachUnit = Instance.new("TextLabel")
    reachUnit.Size = UDim2.new(1, 0, 0, 20 * CONFIG.scale)
    reachUnit.Position = UDim2.new(0, 0, 1, -5 * CONFIG.scale)
    reachUnit.BackgroundTransparency = 1
    reachUnit.Text = "studs"
    reachUnit.TextColor3 = CONFIG.textMuted
    reachUnit.Font = Enum.Font.Gotham
    reachUnit.TextSize = 10 * CONFIG.scale
    reachUnit.Parent = reachValueBg

    -- Botões + e - modernos
    local btnSizeSmall = UDim2.new(0, 50 * CONFIG.scale, 0, 40 * CONFIG.scale)
    
    local minusBtn = Instance.new("TextButton")
    minusBtn.Name = "Minus"
    minusBtn.Size = btnSizeSmall
    minusBtn.Position = UDim2.new(0, 15 * CONFIG.scale, 0, 50 * CONFIG.scale)
    minusBtn.BackgroundColor3 = CONFIG.bgHover
    minusBtn.Text = "−"
    minusBtn.TextColor3 = CONFIG.textPrimary
    minusBtn.Font = Enum.Font.GothamBlack
    minusBtn.TextSize = 24 * CONFIG.scale
    minusBtn.AutoButtonColor = false
    minusBtn.Parent = reachCard
    Instance.new("UICorner", minusBtn).CornerRadius = UDim.new(0, 10 * CONFIG.scale)

    local plusBtn = Instance.new("TextButton")
    plusBtn.Name = "Plus"
    plusBtn.Size = btnSizeSmall
    plusBtn.Position = UDim2.new(0, 75 * CONFIG.scale, 0, 50 * CONFIG.scale)
    plusBtn.BackgroundColor3 = CONFIG.primary
    plusBtn.BackgroundTransparency = 0.3
    plusBtn.Text = "+"
    plusBtn.TextColor3 = CONFIG.textPrimary
    plusBtn.Font = Enum.Font.GothamBlack
    plusBtn.TextSize = 24 * CONFIG.scale
    plusBtn.AutoButtonColor = false
    plusBtn.Parent = reachCard
    Instance.new("UICorner", plusBtn).CornerRadius = UDim.new(0, 10 * CONFIG.scale)

    -- Slider moderno
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(0.55, 0, 0, 10 * CONFIG.scale)
    sliderBg.Position = UDim2.new(0, 15 * CONFIG.scale, 0, 105 * CONFIG.scale)
    sliderBg.BackgroundColor3 = CONFIG.bgDark
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = reachCard
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)

    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "SliderFill"
    sliderFill.Size = UDim2.new(CONFIG.reach / 50, 0, 1, 0)
    sliderFill.BackgroundColor3 = CONFIG.primary
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBg
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)

    local sliderKnob = Instance.new("Frame")
    sliderKnob.Name = "Knob"
    sliderKnob.Size = UDim2.new(0, 20 * CONFIG.scale, 0, 20 * CONFIG.scale)
    sliderKnob.Position = UDim2.new(CONFIG.reach / 50, -10 * CONFIG.scale, 0.5, -10 * CONFIG.scale)
    sliderKnob.BackgroundColor3 = CONFIG.textPrimary
    sliderKnob.BorderSizePixel = 0
    sliderKnob.Parent = sliderBg
    Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)

    -- Toggle Esfera
    local sphereToggle = Instance.new("TextButton")
    sphereToggle.Size = UDim2.new(0, 60 * CONFIG.scale, 0, 30 * CONFIG.scale)
    sphereToggle.Position = UDim2.new(1, -75 * CONFIG.scale, 0, 100 * CONFIG.scale)
    sphereToggle.BackgroundColor3 = CONFIG.showReachSphere and CONFIG.success or CONFIG.bgHover
    sphereToggle.Text = CONFIG.showReachSphere and "ON" or "OFF"
    sphereToggle.TextColor3 = CONFIG.textPrimary
    sphereToggle.Font = Enum.Font.GothamBlack
    sphereToggle.TextSize = 12 * CONFIG.scale
    sphereToggle.AutoButtonColor = false
    sphereToggle.Parent = reachCard
    Instance.new("UICorner", sphereToggle).CornerRadius = UDim.new(0, 15 * CONFIG.scale)

    -- ============================================
    -- CARD DE CONTROLES (Grid 2x2)
    -- ============================================
    local controlCard = createCard("CONTROLES", 145, 160, "🎮")

    local function createModernToggle(y, x, configKey, label, defaultState)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(0.45, 0, 0, 50 * CONFIG.scale)
        container.Position = UDim2.new(x, 15 * CONFIG.scale, 0, y)
        container.BackgroundTransparency = 1
        container.Parent = controlCard

        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Size = UDim2.new(0, 55 * CONFIG.scale, 0, 28 * CONFIG.scale)
        toggleBtn.Position = UDim2.new(1, -60 * CONFIG.scale, 0.5, -14 * CONFIG.scale)
        toggleBtn.BackgroundColor3 = defaultState and CONFIG.success or CONFIG.bgHover
        toggleBtn.Text = defaultState and "ON" or "OFF"
        toggleBtn.TextColor3 = CONFIG.textPrimary
        toggleBtn.Font = Enum.Font.GothamBlack
        toggleBtn.TextSize = 11 * CONFIG.scale
        toggleBtn.AutoButtonColor = false
        toggleBtn.Parent = container
        Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 14 * CONFIG.scale)

        local labelText = Instance.new("TextLabel")
        labelText.Size = UDim2.new(1, -65 * CONFIG.scale, 1, 0)
        labelText.BackgroundTransparency = 1
        labelText.Text = label
        labelText.TextColor3 = CONFIG.textSecondary
        labelText.Font = Enum.Font.GothamBold
        labelText.TextSize = 12 * CONFIG.scale
        labelText.TextXAlignment = Enum.TextXAlignment.Left
        labelText.Parent = container

        return toggleBtn
    end

    local autoBtn = createModernToggle(45, 0, "autoTouch", "Auto Touch", CONFIG.autoTouch)
    local bodyBtn = createModernToggle(45, 0.5, "fullBodyTouch", "Full Body", CONFIG.fullBodyTouch)
    local secondBtn = createModernToggle(95, 0, "autoSecondTouch", "Double Touch", CONFIG.autoSecondTouch)
    local skillsBtn = createModernToggle(95, 0.5, "autoSkills", "Auto Skills", true)

    -- ============================================
    -- CARD DE STATUS
    -- ============================================
    local statusCard = createCard("STATUS", 315, 80, "📊")

    local statusText = Instance.new("TextLabel")
    statusText.Name = "StatusText"
    statusText.Size = UDim2.new(1, -30 * CONFIG.scale, 0, 40 * CONFIG.scale)
    statusText.Position = UDim2.new(0, 15 * CONFIG.scale, 0, 40 * CONFIG.scale)
    statusText.BackgroundTransparency = 1
    statusText.Text = "🟢 Sistema Ativo e Operacional"
    statusText.TextColor3 = CONFIG.success
    statusText.Font = Enum.Font.GothamBold
    statusText.TextSize = 13 * CONFIG.scale
    statusText.TextWrapped = true
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.Parent = statusCard

    -- ============================================
    -- FUNÇÕES DE ATUALIZAÇÃO
    -- ============================================
    local function updateReachDisplay()
        reachDisplay.Text = tostring(CONFIG.reach)
        local fillScale = math.clamp(CONFIG.reach / 50, 0, 1)
        tween(sliderFill, {Size = UDim2.new(fillScale, 0, 1, 0)}, 0.2)
        tween(sliderKnob, {Position = UDim2.new(fillScale, -10 * CONFIG.scale, 0.5, -10 * CONFIG.scale)}, 0.2)
    end

    local function updateStatus(text, isError)
        statusText.Text = text
        statusText.TextColor3 = isError and CONFIG.danger or CONFIG.success
    end

    -- ============================================
    -- EVENTOS E INTERAÇÕES
    -- ============================================
    
    -- Hover effects modernos
    local function addModernHover(btn, normalColor, hoverColor)
        btn.MouseEnter:Connect(function()
            tween(btn, {BackgroundColor3 = hoverColor}, 0.2)
        end)
        btn.MouseLeave:Connect(function()
            tween(btn, {BackgroundColor3 = normalColor}, 0.2)
        end)
    end

    addModernHover(minusBtn, CONFIG.bgHover, CONFIG.bgLight)
    addModernHover(plusBtn, CONFIG.primary, Color3.fromRGB(50, 190, 255))
    addModernHover(closeBtn, CONFIG.danger, Color3.fromRGB(255, 100, 120))

    -- Minimize hover especial
    minimizeBtn.MouseEnter:Connect(function()
        tween(minimizeBtn, {BackgroundColor3 = CONFIG.primary}, 0.2)
        tween(minimizeBtn, {Rotation = 180}, 0.3)
    end)
    minimizeBtn.MouseLeave:Connect(function()
        tween(minimizeBtn, {BackgroundColor3 = CONFIG.bgHover}, 0.2)
        tween(minimizeBtn, {Rotation = 0}, 0.3)
    end)

    -- Cliques
    minusBtn.MouseButton1Click:Connect(function()
        CONFIG.reach = math.max(1, CONFIG.reach - 1)
        updateReachDisplay()
    end)

    plusBtn.MouseButton1Click:Connect(function()
        CONFIG.reach = math.min(50, CONFIG.reach + 1)
        updateReachDisplay()
    end)

    -- Slider drag
    local draggingSlider = false
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = true
            local relativeX = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            CONFIG.reach = math.floor(relativeX * 50)
            updateReachDisplay()
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local relativeX = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            CONFIG.reach = math.floor(relativeX * 50)
            updateReachDisplay()
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = false
        end
    end)

    -- Toggles
    sphereToggle.MouseButton1Click:Connect(function()
        CONFIG.showReachSphere = not CONFIG.showReachSphere
        sphereToggle.Text = CONFIG.showReachSphere and "ON" or "OFF"
        tween(sphereToggle, {BackgroundColor3 = CONFIG.showReachSphere and CONFIG.success or CONFIG.bgHover}, 0.2)
        notify("CADUXX137", "Esfera " .. (CONFIG.showReachSphere and "ativada" or "desativada"), 2)
    end)

    autoBtn.MouseButton1Click:Connect(function()
        CONFIG.autoTouch = not CONFIG.autoTouch
        autoBtn.Text = CONFIG.autoTouch and "ON" or "OFF"
        tween(autoBtn, {BackgroundColor3 = CONFIG.autoTouch and CONFIG.success or CONFIG.bgHover}, 0.2)
    end)

    bodyBtn.MouseButton1Click:Connect(function()
        CONFIG.fullBodyTouch = not CONFIG.fullBodyTouch
        bodyBtn.Text = CONFIG.fullBodyTouch and "ON" or "OFF"
        tween(bodyBtn, {BackgroundColor3 = CONFIG.fullBodyTouch and CONFIG.success or CONFIG.bgHover}, 0.2)
    end)

    secondBtn.MouseButton1Click:Connect(function()
        CONFIG.autoSecondTouch = not CONFIG.autoSecondTouch
        secondBtn.Text = CONFIG.autoSecondTouch and "ON" or "OFF"
        tween(secondBtn, {BackgroundColor3 = CONFIG.autoSecondTouch and CONFIG.success or CONFIG.bgHover}, 0.2)
    end)

    local autoSkills = true
    skillsBtn.MouseButton1Click:Connect(function()
        autoSkills = not autoSkills
        skillsBtn.Text = autoSkills and "ON" or "OFF"
        tween(skillsBtn, {BackgroundColor3 = autoSkills and CONFIG.success or CONFIG.bgHover}, 0.2)
    end)

    -- Minimizar com animação suave
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

    -- Draggable
    makeDraggable(main, header)

    -- Animação de entrada suave
    main.Size = UDim2.new(0, 0, 0, 0)
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
    tween(main, {Size = UDim2.new(0, W, 0, H), Position = UDim2.new(0.5, -W/2, 0.5, -H/2)}, 0.5, Enum.EasingStyle.Back)

    notify("⚡ CADUXX137 v9.2", "Modern Edition carregada!", 3)
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
        if gui:IsA("ScreenGui") and not gui.Name:find("CADU") then
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
        for _, conn in ipairs(getconnections(button.MouseButton1Click)) do conn:Fire() end
        for _, conn in ipairs(getconnections(button.Activated)) do conn:Fire() end
        if button.MouseButton1Click then button.MouseButton1Click:Fire() end
        if button.Activated then button.Activated:Fire() end
    end)
end

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
        for _, button in ipairs(skillButtons) do
            if button.Name == "Shoot" or button.Name == "Pass" or button.Name == "Dribble" then
                activateSkillButton(button)
            end
        end
    end
end)

-- Inicialização
createMainGUI()
print("[CADUXX137] v9.2 Modern Edition - Botão minimizar visível com emoji 🎯")
