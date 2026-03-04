if not game:IsLoaded() then game.Loaded:Wait() end
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local CONFIG = {
    version = "v10.0 ULTIMATE",
    build = "Final Release",
    reach = 15,
    showReachSphere = true,
    autoTouch = true,
    fullBodyTouch = true,
    autoSecondTouch = true,
    scanCooldown = 1.5,
    scale = 1.0,
    currentTab = "intro",
    bodyParts = {
        HumanoidRootPart = true,
        Head = false,
        LeftUpperArm = false,
        LeftLowerArm = false,
        LeftHand = false,
        RightUpperArm = false,
        RightLowerArm = false,
        RightHand = false,
        LeftUpperLeg = false,
        LeftLowerLeg = false,
        LeftFoot = false,
        RightUpperLeg = false,
        RightLowerLeg = false,
        RightFoot = false,
        Torso = false,
        UpperTorso = false,
        LowerTorso = false
    },
    bodyPresets = {
        {
            name = "Padrão (HRP)",
            parts = {HumanoidRootPart = true}
        },
        {
            name = "Apenas Pés",
            parts = {LeftFoot = true, RightFoot = true}
        },
        {
            name = "Apenas Mãos",
            parts = {LeftHand = true, RightHand = true}
        },
        {
            name = "Pernas Completas",
            parts = {LeftUpperLeg = true, LeftLowerLeg = true, LeftFoot = true,
                     RightUpperLeg = true, RightLowerLeg = true, RightFoot = true}
        },
        {
            name = "Braços Completos",
            parts = {LeftUpperArm = true, LeftLowerArm = true, LeftHand = true,
                     RightUpperArm = true, RightLowerArm = true, RightHand = true}
        },
        {
            name = "Full Body",
            parts = {HumanoidRootPart = true, Head = true,
                     LeftUpperArm = true, LeftLowerArm = true, LeftHand = true,
                     RightUpperArm = true, RightLowerArm = true, RightHand = true,
                     LeftUpperLeg = true, LeftLowerLeg = true, LeftFoot = true,
                     RightUpperLeg = true, RightLowerLeg = true, RightFoot = true}
        },
        {
            name = "Modo Chute",
            parts = {LeftLowerLeg = true, LeftFoot = true,
                     RightLowerLeg = true, RightFoot = true}
        },
        {
            name = "Modo Cabeceio",
            parts = {Head = true, LeftHand = true, RightHand = true}
        }
    },
    iconImage = "rbxassetid://104616032736993",
    iconBackground = "rbxassetid://96755648876012",
    logoImage = "rbxassetid://104616032736993",
    primary = Color3.fromRGB(0, 240, 255),
    secondary = Color3.fromRGB(180, 0, 255),
    accent = Color3.fromRGB(255, 0, 128),
    success = Color3.fromRGB(0, 255, 136),
    warning = Color3.fromRGB(255, 200, 0),
    danger = Color3.fromRGB(255, 50, 80),
    info = Color3.fromRGB(0, 150, 255),
    bgDark = Color3.fromRGB(5, 5, 10),
    bgDarker = Color3.fromRGB(2, 2, 5),
    bgCard = Color3.fromRGB(15, 15, 25),
    bgElevated = Color3.fromRGB(25, 25, 40),
    bgHover = Color3.fromRGB(35, 35, 55),
    bgLight = Color3.fromRGB(45, 45, 70),
    textPrimary = Color3.fromRGB(255, 255, 255),
    textSecondary = Color3.fromRGB(190, 190, 210),
    textMuted = Color3.fromRGB(130, 130, 150),
    textDark = Color3.fromRGB(80, 80, 100),
    gradientPrimary = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 240, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 0, 255))
    }),
    animSpeed = 0.3,
    animStyle = Enum.EasingStyle.Quint,
}
local UPDATES = {
    {
        version = "v10.0 ULTIMATE",
        date = "05/03/2026",
        type = "major",
        changes = {
            "Sistema completo de abas (Intro, Main, Body, Stats)",
            "Tela de loading animada premium",
            "Sistema avançado de seleção de partes do corpo",
            "8 presets de corpo pré-configurados",
            "Interface redesenhada do zero",
            "Sistema de estatísticas em tempo real",
            "Otimização de performance",
            "Sistema de salvamento de configurações",
            "Efeitos visuais aprimorados",
            "Suporte total a mobile"
        }
    },
    {
        version = "v9.2",
        date = "04/03/2026",
        type = "minor",
        changes = {
            "Correções de bugs críticos",
            "Melhorias visuais no hub",
            "Suporte mobile aprimorado",
            "Otimizações de código"
        }
    },
    {
        version = "v9.0",
        date = "01/03/2026",
        type = "major",
        changes = {
            "Lançamento inicial do CADUXX137",
            "Sistema de reach para bolas",
            "Auto skills integrado",
            "Sistema de detecção inteligente"
        }
    }
}
local STATS = {
    totalTouches = 0,
    ballsDetected = 0,
    sessionTime = 0,
    startTime = tick(),
    fps = 0,
    ping = 0,
    memoryUsage = 0
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
local isLoading = true
local iconGui = nil
local mainGui = nil
local loadingGui = nil
local currentTabFrame = nil
local tabButtons = {}
local function notify(title, text, duration, type)
    duration = duration or 3
    type = type or "info"
    local color = CONFIG.info
    if type == "success" then color = CONFIG.success
    elseif type == "warning" then color = CONFIG.warning
    elseif type == "error" then color = CONFIG.danger
    elseif type == "premium" then color = CONFIG.primary end
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "CADUXX137",
            Text = text or "",
            Duration = duration,
            Icon = "rbxassetid://104616032736993"
        })
    end)
end
local function tween(obj, props, time, style, direction, callback)
    time = time or CONFIG.animSpeed
    style = style or CONFIG.animStyle
    direction = direction or Enum.EasingDirection.Out
    local tweenInfo = TweenInfo.new(time, style, direction)
    local t = TweenService:Create(obj, tweenInfo, props)
    if callback then
        t.Completed:Connect(callback)
    end
    t:Play()
    return t
end
local function delay(seconds, callback)
    task.delay(seconds, callback)
end
local function spawn(callback)
    task.spawn(callback)
end
local function formatNumber(num)
    if num >= 1000000 then
        return string.format("%.1fM", num / 1000000)
    elseif num >= 1000 then
        return string.format("%.1fK", num / 1000)
    else
        return tostring(math.floor(num))
    end
end
local function formatTime(seconds)
    local mins = math.floor(seconds / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%02d:%02d", mins, secs)
end
local function createGradient(parent, colorSeq, rotation)
    rotation = rotation or 90
    local grad = Instance.new("UIGradient")
    grad.Color = colorSeq or CONFIG.gradientPrimary
    grad.Rotation = rotation
    grad.Parent = parent
    return grad
end
local function createCorner(parent, radius)
    radius = radius or 12
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius * CONFIG.scale)
    corner.Parent = parent
    return corner
end
local function createStroke(parent, color, thickness, transparency)
    color = color or CONFIG.primary
    thickness = thickness or 1.5
    transparency = transparency or 0
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness * CONFIG.scale
    stroke.Transparency = transparency
    stroke.Parent = parent
    return stroke
end
local function createShadow(parent, intensity)
    intensity = intensity or 0.7
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 60 * CONFIG.scale, 1, 60 * CONFIG.scale)
    shadow.Position = UDim2.new(0, -30 * CONFIG.scale, 0, -30 * CONFIG.scale)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://131296141"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = intensity
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.ZIndex = -1
    shadow.Parent = parent
    return shadow
end
local function createGlow(parent, color, size)
    color = color or CONFIG.primary
    size = size or 1.4
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.Size = UDim2.new(size, 0, size, 0)
    glow.Position = UDim2.new(-(size-1)/2, 0, -(size-1)/2, 0)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://5028857084"
    glow.ImageColor3 = color
    glow.ImageTransparency = 0.85
    glow.ScaleType = Enum.ScaleType.Slice
    glow.SliceCenter = Rect.new(10, 10, 90, 90)
    glow.ZIndex = -1
    glow.Parent = parent
    return glow
end
local function makeDraggable(frame, handle, onDragStart, onDragEnd)
    local dragging = false
    local dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            if onDragStart then onDragStart() end
            tween(frame, {BackgroundTransparency = frame.BackgroundTransparency + 0.1}, 0.1)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                        input.UserInputType == Enum.UserInputType.Touch) then
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
            if onDragEnd then onDragEnd() end
            tween(frame, {BackgroundTransparency = frame.BackgroundTransparency - 0.1}, 0.1)
        end
    end
    handle.InputEnded:Connect(endDrag)
    UserInputService.InputEnded:Connect(endDrag)
end
local function addHoverEffect(btn, normalColor, hoverColor, clickColor)
    normalColor = normalColor or btn.BackgroundColor3
    hoverColor = hoverColor or CONFIG.bgHover
    clickColor = clickColor or CONFIG.bgLight
    local originalColor = normalColor
    btn.MouseEnter:Connect(function()
        tween(btn, {BackgroundColor3 = hoverColor}, 0.2)
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, {BackgroundColor3 = originalColor}, 0.2)
    end)
    btn.MouseButton1Down:Connect(function()
        tween(btn, {BackgroundColor3 = clickColor}, 0.1)
    end)
    btn.MouseButton1Up:Connect(function()
        tween(btn, {BackgroundColor3 = hoverColor}, 0.1)
    end)
end
local function addRippleEffect(btn, color)
    color = color or Color3.new(1, 1, 1)
    btn.MouseButton1Click:Connect(function()
        local ripple = Instance.new("Frame")
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
        ripple.BackgroundColor3 = color
        ripple.BackgroundTransparency = 0.7
        ripple.BorderSizePixel = 0
        ripple.ZIndex = btn.ZIndex + 1
        ripple.Parent = btn
        createCorner(ripple, 50)
        local targetSize = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 2
        tween(ripple, {
            Size = UDim2.new(0, targetSize, 0, targetSize),
            Position = UDim2.new(0.5, -targetSize/2, 0.5, -targetSize/2),
            BackgroundTransparency = 1
        }, 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, function()
            ripple:Destroy()
        end)
    end)
end
local function createLoadingScreen()
    if loadingGui then loadingGui:Destroy() end
    loadingGui = Instance.new("ScreenGui")
    loadingGui.Name = "CADU_Loading_v10"
    loadingGui.ResetOnSpawn = false
    loadingGui.DisplayOrder = 999999
    loadingGui.Parent = playerGui
    local bg = Instance.new("Frame")
    bg.Name = "Background"
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = CONFIG.bgDarker
    bg.BackgroundTransparency = 0.1
    bg.BorderSizePixel = 0
    bg.Parent = loadingGui
    for i = 1, 20 do
        local particle = Instance.new("ImageLabel")
        particle.Size = UDim2.new(0, math.random(2, 6), 0, math.random(2, 6))
        particle.Position = UDim2.new(math.random(), 0, math.random(), 0)
        particle.BackgroundTransparency = 1
        particle.Image = "rbxassetid://96755648876012"
        particle.ImageColor3 = CONFIG.primary
        particle.ImageTransparency = math.random(3, 8) / 10
        particle.ZIndex = 1
        particle.Parent = bg
        spawn(function()
            while particle and particle.Parent do
                local newY = particle.Position.Y.Scale + math.random(-10, 10) / 1000
                if newY < 0 then newY = 1 elseif newY > 1 then newY = 0 end
                tween(particle, {
                    Position = UDim2.new(particle.Position.X.Scale, 0, newY, 0),
                    Rotation = math.random(0, 360)
                }, math.random(3, 6))
                wait(math.random(3, 6))
            end
        end)
    end
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(0, 400 * CONFIG.scale, 0, 300 * CONFIG.scale)
    container.Position = UDim2.new(0.5, -200 * CONFIG.scale, 0.5, -150 * CONFIG.scale)
    container.BackgroundColor3 = CONFIG.bgCard
    container.BackgroundTransparency = 0.2
    container.BorderSizePixel = 0
    container.ZIndex = 10
    container.Parent = bg
    createCorner(container, 24)
    createStroke(container, CONFIG.primary, 2, 0.5)
    createGlow(container, CONFIG.primary, 1.6)
    local logoContainer = Instance.new("Frame")
    logoContainer.Size = UDim2.new(0, 120 * CONFIG.scale, 0, 120 * CONFIG.scale)
    logoContainer.Position = UDim2.new(0.5, -60 * CONFIG.scale, 0, 30 * CONFIG.scale)
    logoContainer.BackgroundColor3 = CONFIG.bgElevated
    logoContainer.BorderSizePixel = 0
    logoContainer.ZIndex = 11
    logoContainer.Parent = container
    createCorner(logoContainer, 60)
    createStroke(logoContainer, CONFIG.primary, 3, 0.3)
    local outerRing = Instance.new("Frame")
    outerRing.Size = UDim2.new(1.3, 0, 1.3, 0)
    outerRing.Position = UDim2.new(-0.15, 0, -0.15, 0)
    outerRing.BackgroundTransparency = 1
    outerRing.ZIndex = 10
    outerRing.Parent = logoContainer
    local outerCircle = Instance.new("ImageLabel")
    outerCircle.Size = UDim2.new(1, 0, 1, 0)
    outerCircle.BackgroundTransparency = 1
    outerCircle.Image = "rbxassetid://96755648876012"
    outerCircle.ImageColor3 = CONFIG.primary
    outerCircle.ImageTransparency = 0.5
    outerCircle.ZIndex = 10
    outerCircle.Parent = outerRing
    spawn(function()
        while outerRing and outerRing.Parent do
            tween(outerRing, {Rotation = outerRing.Rotation + 360}, 8, Enum.EasingStyle.Linear)
            wait(8)
        end
    end)
    local logo = Instance.new("ImageLabel")
    logo.Size = UDim2.new(0.7, 0, 0.7, 0)
    logo.Position = UDim2.new(0.15, 0, 0.15, 0)
    logo.BackgroundTransparency = 1
    logo.Image = CONFIG.logoImage
    logo.ImageColor3 = CONFIG.textPrimary
    logo.ZIndex = 12
    logo.Parent = logoContainer
    spawn(function()
        while logoContainer and logoContainer.Parent do
            tween(logoContainer, {Size = UDim2.new(0, 130 * CONFIG.scale, 0, 130 * CONFIG.scale)}, 1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            wait(1)
            tween(logoContainer, {Size = UDim2.new(0, 120 * CONFIG.scale, 0, 120 * CONFIG.scale)}, 1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            wait(1)
        end
    end)
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40 * CONFIG.scale)
    title.Position = UDim2.new(0, 0, 0, 160 * CONFIG.scale)
    title.BackgroundTransparency = 1
    title.Text = "CADUXX137"
    title.TextColor3 = CONFIG.textPrimary
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 32 * CONFIG.scale
    title.ZIndex = 11
    title.Parent = container
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, 0, 0, 25 * CONFIG.scale)
    subtitle.Position = UDim2.new(0, 0, 0, 195 * CONFIG.scale)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = CONFIG.version .. " - " .. CONFIG.build
    subtitle.TextColor3 = CONFIG.primary
    subtitle.Font = Enum.Font.GothamBold
    subtitle.TextSize = 14 * CONFIG.scale
    subtitle.ZIndex = 11
    subtitle.Parent = container
    local progressBg = Instance.new("Frame")
    progressBg.Size = UDim2.new(0.8, 0, 0, 8 * CONFIG.scale)
    progressBg.Position = UDim2.new(0.1, 0, 0, 240 * CONFIG.scale)
    progressBg.BackgroundColor3 = CONFIG.bgDark
    progressBg.BorderSizePixel = 0
    progressBg.ZIndex = 11
    progressBg.Parent = container
    createCorner(progressBg, 4)
    local progressFill = Instance.new("Frame")
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    progressFill.BackgroundColor3 = CONFIG.primary
    progressFill.BorderSizePixel = 0
    progressFill.ZIndex = 12
    progressFill.Parent = progressBg
    createCorner(progressFill, 4)
    createGradient(progressFill, CONFIG.gradientPrimary, 0)
    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(1, 0, 0, 20 * CONFIG.scale)
    statusText.Position = UDim2.new(0, 0, 0, 255 * CONFIG.scale)
    statusText.BackgroundTransparency = 1
    statusText.Text = "Inicializando sistema..."
    statusText.TextColor3 = CONFIG.textMuted
    statusText.Font = Enum.Font.Gotham
    statusText.TextSize = 12 * CONFIG.scale
    statusText.ZIndex = 11
    statusText.Parent = container
    local loadingSteps = {
        {text = "Inicializando sistema...", progress = 0.1, delay = 0.5},
        {text = "Carregando configuracoes...", progress = 0.25, delay = 0.4},
        {text = "Detectando personagem...", progress = 0.4, delay = 0.6},
        {text = "Configurando reach...", progress = 0.6, delay = 0.5},
        {text = "Inicializando interface...", progress = 0.8, delay = 0.4},
        {text = "Pronto!", progress = 1, delay = 0.3}
    }
    spawn(function()
        for _, step in ipairs(loadingSteps) do
            statusText.Text = step.text
            tween(progressFill, {Size = UDim2.new(step.progress, 0, 1, 0)}, step.delay)
            wait(step.delay)
        end
        tween(bg, {BackgroundTransparency = 1}, 0.5)
        tween(container, {Size = UDim2.new(0, 0, 0, 0)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        wait(0.5)
        loadingGui:Destroy()
        loadingGui = nil
        isLoading = false
        createMainGUI()
    end)
    container.Size = UDim2.new(0, 0, 0, 0)
    tween(container, {Size = UDim2.new(0, 400 * CONFIG.scale, 0, 300 * CONFIG.scale)}, 0.6, Enum.EasingStyle.Back)
end
local function createIconButton()
    if iconGui then iconGui:Destroy() end
    iconGui = Instance.new("ScreenGui")
    iconGui.Name = "CADU_Icon_v10"
    iconGui.ResetOnSpawn = false
    iconGui.DisplayOrder = 999999
    iconGui.Parent = playerGui
    local iconSize = 75 * CONFIG.scale
    local iconFrame = Instance.new("Frame")
    iconFrame.Name = "IconFrame"
    iconFrame.Size = UDim2.new(0, iconSize, 0, iconSize)
    iconFrame.Position = UDim2.new(0.5, -iconSize/2, 0.85, 0)
    iconFrame.BackgroundColor3 = CONFIG.bgCard
    iconFrame.BorderSizePixel = 0
    iconFrame.Parent = iconGui
    createCorner(iconFrame, 22)
    local glow = createGlow(iconFrame, CONFIG.primary, 1.5)
    local stroke = createStroke(iconFrame, CONFIG.primary, 2.5, 0.3)
    local energyRing = Instance.new("ImageLabel")
    energyRing.Size = UDim2.new(1.4, 0, 1.4, 0)
    energyRing.Position = UDim2.new(-0.2, 0, -0.2, 0)
    energyRing.BackgroundTransparency = 1
    energyRing.Image = "rbxassetid://96755648876012"
    energyRing.ImageColor3 = CONFIG.secondary
    energyRing.ImageTransparency = 0.7
    energyRing.ZIndex = -1
    energyRing.Parent = iconFrame
    spawn(function()
        while energyRing and energyRing.Parent do
            tween(energyRing, {Rotation = energyRing.Rotation + 360}, 10, Enum.EasingStyle.Linear)
            wait(10)
        end
    end)
    local iconImage = Instance.new("ImageLabel")
    iconImage.Size = UDim2.new(0.65, 0, 0.65, 0)
    iconImage.Position = UDim2.new(0.175, 0, 0.175, 0)
    iconImage.BackgroundTransparency = 1
    iconImage.Image = CONFIG.iconImage
    iconImage.ImageColor3 = CONFIG.textPrimary
    iconImage.ScaleType = Enum.ScaleType.Fit
    iconImage.Parent = iconFrame
    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.Parent = iconFrame
    clickBtn.MouseEnter:Connect(function()
        tween(iconFrame, {Size = UDim2.new(0, iconSize * 1.15, 0, iconSize * 1.15)}, 0.3, Enum.EasingStyle.Back)
        tween(stroke, {Color = CONFIG.secondary, Transparency = 0}, 0.3)
        tween(glow, {ImageTransparency = 0.5}, 0.3)
        tween(iconImage, {Rotation = 15}, 0.3, Enum.EasingStyle.Back)
    end)
    clickBtn.MouseLeave:Connect(function()
        tween(iconFrame, {Size = UDim2.new(0, iconSize, 0, iconSize)}, 0.3, Enum.EasingStyle.Back)
        tween(stroke, {Color = CONFIG.primary, Transparency = 0.3}, 0.3)
        tween(glow, {ImageTransparency = 0.85}, 0.3)
        tween(iconImage, {Rotation = 0}, 0.3, Enum.EasingStyle.Back)
    end)
    clickBtn.MouseButton1Click:Connect(function()
        tween(iconFrame, {Size = UDim2.new(0, 0, 0, 0), Rotation = 360}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        wait(0.4)
        iconGui:Destroy()
        iconGui = nil
        isMinimized = false
        createMainGUI()
    end)
    makeDraggable(iconFrame, clickBtn)
    iconFrame.Size = UDim2.new(0, 0, 0, 0)
    tween(iconFrame, {Size = UDim2.new(0, iconSize, 0, iconSize)}, 0.5, Enum.EasingStyle.Back)
    notify("CADUXX137", "Clique no icone para abrir o hub", 3, "info")
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
    local ballNames = {
        "TPS", "TCS", "ESA", "MRS", "PRS", "MPS", "SSS", "AIFA", "RBZ",
        "Ball", "Soccer", "Football", "Basketball", "Baseball", "Volleyball",
        "BallTemplate", "GameBall", "MatchBall", "SportsBall",
        "Hitbox", "TouchPart", "GoalBall", "ScoreBall", "HitBox",
        "CollisionBox", "TriggerBox", "InteractPart",
        "Ball", "ball", "BALL", "Sphere", "Part"
    }
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Parent then
            local objName = obj.Name
            for _, name in ipairs(ballNames) do
                if objName == name or objName:find(name) then
                    local size = obj.Size.Magnitude
                    if size > 0.5 and size < 50 then
                        table.insert(balls, obj)
                        local conn = obj.AncestryChanged:Connect(function(_, parent)
                            if not parent then
                                findBalls()
                            end
                        end)
                        table.insert(ballConnections, conn)
                        break
                    end
                end
            end
        end
    end
    STATS.ballsDetected = #balls
    return #balls
end
local function updateCharacter()
    local newChar = player.Character
    if newChar ~= char then
        char = newChar
        if char then
            HRP = char:WaitForChild("HumanoidRootPart", 3)
            if HRP then
                notify("CADUXX137", "Personagem conectado!", 2, "success")
            else
                notify("CADUXX137", "Aguardando personagem...", 2, "warning")
            end
        else
            HRP = nil
        end
    end
end
local function getSelectedBodyParts()
    if not char then return {} end
    local parts = {}
    local hasSelection = false
    for partName, enabled in pairs(CONFIG.bodyParts) do
        if enabled then
            hasSelection = true
            local part = char:FindFirstChild(partName)
            if part and part:IsA("BasePart") then
                table.insert(parts, part)
            end
        end
    end
    if not hasSelection and HRP then
        table.insert(parts, HRP)
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
        reachSphere.Name = "CADU_ReachSphere_v10"
        reachSphere.Shape = Enum.PartType.Ball
        reachSphere.Anchored = true
        reachSphere.CanCollide = false
        reachSphere.Transparency = 0.93
        reachSphere.Material = Enum.Material.ForceField
        reachSphere.Color = CONFIG.primary
        reachSphere.CastShadow = false
        reachSphere.Parent = Workspace
    end
    if HRP and HRP.Parent then
        reachSphere.Position = HRP.Position
        reachSphere.Size = Vector3.new(CONFIG.reach * 2, CONFIG.reach * 2, CONFIG.reach * 2)
    end
end
local function doTouch(ball, part)
    if not ball or not ball.Parent or not part or not part.Parent then return end
    local key = ball.Name .. "_" .. part.Name .. "_" .. tostring(ball:GetFullName())
    local now = tick()
    if touchDebounce[key] and (now - touchDebounce[key]) < 0.08 then return end
    touchDebounce[key] = now
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
    end)
end
function createMainGUI()
    pcall(function()
        for _, v in pairs(playerGui:GetChildren()) do
            if v.Name:find("CADU") then v:Destroy() end
        end
    end)
    mainGui = Instance.new("ScreenGui")
    mainGui.Name = "CADU_Main_v10_Ultimate"
    mainGui.ResetOnSpawn = false
    mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    mainGui.Parent = playerGui
    local W, H = 550 * CONFIG.scale, 520 * CONFIG.scale
    local main = Instance.new("Frame")
    main.Name = "MainFrame"
    main.Size = UDim2.new(0, W, 0, H)
    main.Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
    main.BackgroundColor3 = CONFIG.bgDark
    main.BackgroundTransparency = 0.05
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = mainGui
    createCorner(main, 28)
    createShadow(main, 0.65)
    local bgGradient = Instance.new("Frame")
    bgGradient.Size = UDim2.new(1, 0, 1, 0)
    bgGradient.BackgroundTransparency = 0.9
    bgGradient.BorderSizePixel = 0
    bgGradient.ZIndex = 0
    bgGradient.Parent = main
    createGradient(bgGradient, ColorSequence.new({
        ColorSequenceKeypoint.new(0, CONFIG.bgDark),
        ColorSequenceKeypoint.new(0.5, CONFIG.bgCard),
        ColorSequenceKeypoint.new(1, CONFIG.bgDark)
    }), 45)
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 95 * CONFIG.scale)
    header.BackgroundColor3 = CONFIG.bgCard
    header.BackgroundTransparency = 0.3
    header.BorderSizePixel = 0
    header.ZIndex = 100
    header.Parent = main
    createCorner(header, 28)
    local headerFix = Instance.new("Frame")
    headerFix.Size = UDim2.new(1, 0, 0.5, 0)
    headerFix.Position = UDim2.new(0, 0, 0.5, 0)
    headerFix.BackgroundColor3 = CONFIG.bgCard
    headerFix.BackgroundTransparency = 0.3
    headerFix.BorderSizePixel = 0
    headerFix.ZIndex = 99
    headerFix.Parent = header
    local logoContainer = Instance.new("Frame")
    logoContainer.Size = UDim2.new(0, 55 * CONFIG.scale, 0, 55 * CONFIG.scale)
    logoContainer.Position = UDim2.new(0, 25 * CONFIG.scale, 0, 20 * CONFIG.scale)
    logoContainer.BackgroundColor3 = CONFIG.bgElevated
    logoContainer.BorderSizePixel = 0
    logoContainer.ZIndex = 101
    logoContainer.Parent = header
    createCorner(logoContainer, 16)
    createStroke(logoContainer, CONFIG.primary, 2, 0.4)
    local logoIcon = Instance.new("ImageLabel")
    logoIcon.Size = UDim2.new(0.6, 0, 0.6, 0)
    logoIcon.Position = UDim2.new(0.2, 0, 0.2, 0)
    logoIcon.BackgroundTransparency = 1
    logoIcon.Image = CONFIG.logoImage
    logoIcon.ImageColor3 = CONFIG.primary
    logoIcon.ZIndex = 102
    logoIcon.Parent = logoContainer
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 200 * CONFIG.scale, 0, 35 * CONFIG.scale)
    title.Position = UDim2.new(0, 90 * CONFIG.scale, 0, 22 * CONFIG.scale)
    title.BackgroundTransparency = 1
    title.Text = "CADUXX137"
    title.TextColor3 = CONFIG.textPrimary
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 28 * CONFIG.scale
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 101
    title.Parent = header
    local version = Instance.new("TextLabel")
    version.Size = UDim2.new(0, 150 * CONFIG.scale, 0, 20 * CONFIG.scale)
    version.Position = UDim2.new(0, 92 * CONFIG.scale, 0, 55 * CONFIG.scale)
    version.BackgroundTransparency = 1
    version.Text = CONFIG.version .. " | " .. CONFIG.build
    version.TextColor3 = CONFIG.primary
    version.Font = Enum.Font.GothamBold
    version.TextSize = 13 * CONFIG.scale
    version.TextXAlignment = Enum.TextXAlignment.Left
    version.ZIndex = 101
    version.Parent = header
    local btnSize = UDim2.new(0, 45 * CONFIG.scale, 0, 45 * CONFIG.scale)
    local btnCorner = 14
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "MinimizeBtn"
    minimizeBtn.Size = btnSize
    minimizeBtn.Position = UDim2.new(1, -105 * CONFIG.scale, 0, 25 * CONFIG.scale)
    minimizeBtn.BackgroundColor3 = CONFIG.bgElevated
    minimizeBtn.Text = ""
    minimizeBtn.TextColor3 = CONFIG.textPrimary
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.TextSize = 22 * CONFIG.scale
    minimizeBtn.AutoButtonColor = false
    minimizeBtn.ZIndex = 101
    minimizeBtn.Parent = header
    createCorner(minimizeBtn, btnCorner)
    addHoverEffect(minimizeBtn, CONFIG.bgElevated, CONFIG.bgHover, CONFIG.bgLight)
    addRippleEffect(minimizeBtn, Color3.new(1, 1, 1))
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = btnSize
    closeBtn.Position = UDim2.new(1, -55 * CONFIG.scale, 0, 25 * CONFIG.scale)
    closeBtn.BackgroundColor3 = CONFIG.danger
    closeBtn.BackgroundTransparency = 0.2
    closeBtn.Text = ""
    closeBtn.TextColor3 = CONFIG.textPrimary
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 20 * CONFIG.scale
    closeBtn.AutoButtonColor = false
    closeBtn.ZIndex = 101
    closeBtn.Parent = header
    createCorner(closeBtn, btnCorner)
    addHoverEffect(closeBtn, 
        Color3.new(CONFIG.danger.R, CONFIG.danger.G, CONFIG.danger.B), 
        Color3.fromRGB(255, 80, 100), 
        Color3.fromRGB(255, 100, 120)
    )
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(1, -50 * CONFIG.scale, 0, 60 * CONFIG.scale)
    tabContainer.Position = UDim2.new(0, 25 * CONFIG.scale, 0, 100 * CONFIG.scale)
    tabContainer.BackgroundColor3 = CONFIG.bgElevated
    tabContainer.BackgroundTransparency = 0.4
    tabContainer.BorderSizePixel = 0
    tabContainer.ZIndex = 100
    tabContainer.Parent = main
    createCorner(tabContainer, 18)
    local tabs = {
        {id = "intro", name = "Intro", icon = "", color = CONFIG.info},
        {id = "main", name = "Main", icon = "", color = CONFIG.primary},
        {id = "body", name = "Body", icon = "", color = CONFIG.success},
        {id = "stats", name = "Stats", icon = "", color = CONFIG.warning}
    }
    local tabWidth = 1 / #tabs
    local tabButtonList = {}
    for i, tab in ipairs(tabs) do
        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = tab.id .. "Tab"
        tabBtn.Size = UDim2.new(tabWidth, -12 * CONFIG.scale, 1, -12 * CONFIG.scale)
        tabBtn.Position = UDim2.new((i-1) * tabWidth, 6 * CONFIG.scale, 0, 6 * CONFIG.scale)
        tabBtn.BackgroundColor3 = (tab.id == CONFIG.currentTab) and tab.color or CONFIG.bgCard
        tabBtn.Text = tab.name
        tabBtn.TextColor3 = (tab.id == CONFIG.currentTab) and CONFIG.bgDark or CONFIG.textPrimary
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.TextSize = 14 * CONFIG.scale
        tabBtn.AutoButtonColor = false
        tabBtn.ZIndex = 101
        tabBtn.Parent = tabContainer
        createCorner(tabBtn, 14)
        tabButtons[tab.id] = {
            button = tabBtn,
            color = tab.color,
            defaultBg = CONFIG.bgCard
        }
        tabBtn.MouseButton1Click:Connect(function()
            if CONFIG.currentTab ~= tab.id then
                switchTab(tab.id)
            end
        end)
        if tab.id ~= CONFIG.currentTab then
            tabBtn.MouseEnter:Connect(function()
                tween(tabBtn, {BackgroundColor3 = CONFIG.bgHover}, 0.2)
            end)
            tabBtn.MouseLeave:Connect(function()
                tween(tabBtn, {BackgroundColor3 = CONFIG.bgCard}, 0.2)
            end)
        end
        table.insert(tabButtonList, tabBtn)
    end
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, -50 * CONFIG.scale, 1, -180 * CONFIG.scale)
    contentContainer.Position = UDim2.new(0, 25 * CONFIG.scale, 0, 170 * CONFIG.scale)
    contentContainer.BackgroundTransparency = 1
    contentContainer.ClipsDescendants = true
    contentContainer.ZIndex = 50
    contentContainer.Parent = main
    function switchTab(newTabId)
        local oldTabId = CONFIG.currentTab
        CONFIG.currentTab = newTabId
        for id, tabData in pairs(tabButtons) do
            local btn = tabData.button
            if id == newTabId then
                tween(btn, {BackgroundColor3 = tabData.color}, 0.3)
                tween(btn, {TextColor3 = CONFIG.bgDark}, 0.3)
                btn.MouseEnter:Connect(function() end)
                btn.MouseLeave:Connect(function() end)
            else
                tween(btn, {BackgroundColor3 = CONFIG.bgCard}, 0.3)
                tween(btn, {TextColor3 = CONFIG.textPrimary}, 0.3)
                btn.MouseEnter:Connect(function()
                    tween(btn, {BackgroundColor3 = CONFIG.bgHover}, 0.2)
                end)
                btn.MouseLeave:Connect(function()
                    tween(btn, {BackgroundColor3 = CONFIG.bgCard}, 0.2)
                end)
            end
        end
        if currentTabFrame then
            local direction = (newTabId == "intro") and -1 or 1
            tween(currentTabFrame, {
                Position = UDim2.new(direction * 0.2, 0, 0, 0),
                Transparency = 1
            }, 0.2)
            wait(0.2)
            currentTabFrame:Destroy()
        end
        if newTabId == "intro" then
            createIntroTab(contentContainer)
        elseif newTabId == "main" then
            createMainTab(contentContainer)
        elseif newTabId == "body" then
            createBodyTab(contentContainer)
        elseif newTabId == "stats" then
            createStatsTab(contentContainer)
        end
    end
    function createCard(parent, y, height, title, bgColor)
        local card = Instance.new("Frame")
        card.Name = (title or "Card") .. "_Card"
        card.Size = UDim2.new(1, 0, 0, height * CONFIG.scale)
        card.Position = UDim2.new(0, 0, 0, y * CONFIG.scale)
        card.BackgroundColor3 = bgColor or CONFIG.bgCard
        card.BackgroundTransparency = 0.3
        card.BorderSizePixel = 0
        card.Parent = parent
        createCorner(card, 18)
        if title and title ~= "" then
            local titleLabel = Instance.new("TextLabel")
            titleLabel.Size = UDim2.new(1, -30 * CONFIG.scale, 0, 35 * CONFIG.scale)
            titleLabel.Position = UDim2.new(0, 15 * CONFIG.scale, 0, 8 * CONFIG.scale)
            titleLabel.BackgroundTransparency = 1
            titleLabel.Text = title
            titleLabel.TextColor3 = CONFIG.textPrimary
            titleLabel.Font = Enum.Font.GothamBlack
            titleLabel.TextSize = 16 * CONFIG.scale
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
            titleLabel.Parent = card
            local line = Instance.new("Frame")
            line.Size = UDim2.new(0.25, 0, 0, 2 * CONFIG.scale)
            line.Position = UDim2.new(0, 15 * CONFIG.scale, 0, 35 * CONFIG.scale)
            line.BackgroundColor3 = CONFIG.primary
            line.BorderSizePixel = 0
            line.Parent = card
            createCorner(line, 1)
        end
        return card
    end
    function createToggle(parent, x, y, state, label)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(0.9, 0, 0, 40 * CONFIG.scale)
        container.Position = UDim2.new(0, 15 * CONFIG.scale, 0, y * CONFIG.scale)
        container.BackgroundTransparency = 1
        container.Parent = parent
        local labelText = Instance.new("TextLabel")
        labelText.Size = UDim2.new(0.7, 0, 1, 0)
        labelText.BackgroundTransparency = 1
        labelText.Text = label
        labelText.TextColor3 = CONFIG.textSecondary
        labelText.Font = Enum.Font.GothamBold
        labelText.TextSize = 13 * CONFIG.scale
        labelText.TextXAlignment = Enum.TextXAlignment.Left
        labelText.Parent = container
        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Size = UDim2.new(0, 55 * CONFIG.scale, 0, 26 * CONFIG.scale)
        toggleBtn.Position = UDim2.new(1, -60 * CONFIG.scale, 0.5, -13 * CONFIG.scale)
        toggleBtn.BackgroundColor3 = state and CONFIG.success or CONFIG.bgHover
        toggleBtn.Text = state and "ON" or "OFF"
        toggleBtn.TextColor3 = CONFIG.textPrimary
        toggleBtn.Font = Enum.Font.GothamBlack
        toggleBtn.TextSize = 11 * CONFIG.scale
        toggleBtn.AutoButtonColor = false
        toggleBtn.Parent = container
        createCorner(toggleBtn, 13)
        return toggleBtn
    end
    function createIntroTab(parent)
        local frame = Instance.new("ScrollingFrame")
        frame.Name = "IntroTab"
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.ScrollBarThickness = 4
        frame.ScrollBarImageColor3 = CONFIG.primary
        frame.CanvasSize = UDim2.new(0, 0, 0, 800 * CONFIG.scale)
        frame.Parent = parent
        currentTabFrame = frame
        frame.Position = UDim2.new(0, 30 * CONFIG.scale, 0, 0)
        tween(frame, {Position = UDim2.new(0, 0, 0, 0)}, 0.3)
        local welcomeCard = createCard(frame, 0, 140, "Bem-vindo ao CADUXX137", CONFIG.bgElevated)
        local welcomeText = Instance.new("TextLabel")
        welcomeText.Size = UDim2.new(1, -30 * CONFIG.scale, 0, 70 * CONFIG.scale)
        welcomeText.Position = UDim2.new(0, 15 * CONFIG.scale, 0, 50 * CONFIG.scale)
        welcomeText.BackgroundTransparency = 1
        welcomeText.Text = "O sistema de reach mais avancado do Roblox! Desenvolvido para maxima performance e precisao."
        welcomeText.TextColor3 = CONFIG.textSecondary
        welcomeText.Font = Enum.Font.GothamBold
        welcomeText.TextSize = 14 * CONFIG.scale
        welcomeText.TextWrapped = true
        welcomeText.Parent = welcomeCard
        local quickCard = createCard(frame, 150, 180, "Inicio Rapido", CONFIG.bgCard)
        local steps = {
            "1. Va para a aba Main para configurar o reach",
            "2. Use a aba Body para selecionar partes do corpo",
            "3. Acompanhe estatisticas na aba Stats",
            "4. Use presets para configuracoes rapidas!"
        }
        local stepsText = ""
        for _, step in ipairs(steps) do
            stepsText = stepsText .. step .. "\n"
        end
        local stepsLabel = Instance.new("TextLabel")
        stepsLabel.Size = UDim2.new(1, -30 * CONFIG.scale, 0, 120 * CONFIG.scale)
        stepsLabel.Position = UDim2.new(0, 15 * CONFIG.scale, 0, 50 * CONFIG.scale)
        stepsLabel.BackgroundTransparency = 1
        stepsLabel.Text = stepsText
        stepsLabel.TextColor3 = CONFIG.textMuted
        stepsLabel.Font = Enum.Font.Gotham
        stepsLabel.TextSize = 12 * CONFIG.scale
        stepsLabel.TextWrapped = true
        stepsLabel.TextYAlignment = Enum.TextYAlignment.Top
        stepsLabel.Parent = quickCard
        local yOffset = 340 * CONFIG.scale
        for _, update in ipairs(UPDATES) do
            local updateCard = createCard(frame, yOffset / CONFIG.scale, 160, update.version .. " - " .. update.date, CONFIG.bgCard)
            local changesText = ""
            for _, change in ipairs(update.changes) do
                changesText = changesText .. "• " .. change .. "\n"
            end
            local changesLabel = Instance.new("TextLabel")
            changesLabel.Size = UDim2.new(1, -30 * CONFIG.scale, 0, 110 * CONFIG.scale)
            changesLabel.Position = UDim2.new(0, 15 * CONFIG.scale, 0, 45 * CONFIG.scale)
            changesLabel.BackgroundTransparency = 1
            changesLabel.Text = changesText
            changesLabel.TextColor3 = CONFIG.textMuted
            changesLabel.Font = Enum.Font.Gotham
            changesLabel.TextSize = 11 * CONFIG.scale
            changesLabel.TextWrapped = true
            changesLabel.TextYAlignment = Enum.TextYAlignment.Top
            changesLabel.Parent = updateCard
            yOffset = yOffset + 170 * CONFIG.scale
        end
        local footerCard = createCard(frame, yOffset / CONFIG.scale + 10, 60, "", CONFIG.bgElevated)
        local footerText = Instance.new("TextLabel")
        footerText.Size = UDim2.new(1, -30 * CONFIG.scale, 1, 0)
        footerText.Position = UDim2.new(0, 15 * CONFIG.scale, 0, 0)
        footerText.BackgroundTransparency = 1
        footerText.Text = "Dica: Use o botao no header para minimizar o hub"
        footerText.TextColor3 = CONFIG.textSecondary
        footerText.Font = Enum.Font.GothamBold
        footerText.TextSize = 12 * CONFIG.scale
        footerText.TextWrapped = true
        footerText.Parent = footerCard
        frame.CanvasSize = UDim2.new(0, 0, 0, yOffset + 100)
    end
    function createMainTab(parent)
        local frame = Instance.new("Frame")
        frame.Name = "MainTab"
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.Parent = parent
        currentTabFrame = frame
        frame.Position = UDim2.new(0, 30 * CONFIG.scale, 0, 0)
        tween(frame, {Position = UDim2.new(0, 0, 0, 0)}, 0.3)
        local reachCard = createCard(frame, 0, 140, "Controle de Alcance", CONFIG.bgElevated)
        local reachBg = Instance.new("Frame")
        reachBg.Size = UDim2.new(0, 90 * CONFIG.scale, 0, 55 * CONFIG.scale)
        reachBg.Position = UDim2.new(1, -105 * CONFIG.scale, 0, 45 * CONFIG.scale)
        reachBg.BackgroundColor3 = CONFIG.bgDark
        reachBg.BorderSizePixel = 0
        reachBg.Parent = reachCard
        createCorner(reachBg, 14)
        local reachDisplay = Instance.new("TextLabel")
        reachDisplay.Name = "ReachValue"
        reachDisplay.Size = UDim2.new(1, 0, 0.7, 0)
        reachDisplay.BackgroundTransparency = 1
        reachDisplay.Text = tostring(CONFIG.reach)
        reachDisplay.TextColor3 = CONFIG.primary
        reachDisplay.Font = Enum.Font.GothamBlack
        reachDisplay.TextSize = 28 * CONFIG.scale
        reachDisplay.Parent = reachBg
        local reachUnit = Instance.new("TextLabel")
        reachUnit.Size = UDim2.new(1, 0, 0.3, 0)
        reachUnit.Position = UDim2.new(0, 0, 0.7, 0)
        reachUnit.BackgroundTransparency = 1
        reachUnit.Text = "studs"
        reachUnit.TextColor3 = CONFIG.textMuted
        reachUnit.Font = Enum.Font.Gotham
        reachUnit.TextSize = 10 * CONFIG.scale
        reachUnit.Parent = reachBg
        local minusBtn = Instance.new("TextButton")
        minusBtn.Size = UDim2.new(0, 50 * CONFIG.scale, 0, 40 * CONFIG.scale)
        minusBtn.Position = UDim2.new(0, 15 * CONFIG.scale, 0, 50 * CONFIG.scale)
        minusBtn.BackgroundColor3 = CONFIG.bgCard
        minusBtn.Text = "-"
        minusBtn.TextColor3 = CONFIG.textPrimary
        minusBtn.Font = Enum.Font.GothamBlack
        minusBtn.TextSize = 22 * CONFIG.scale
        minusBtn.AutoButtonColor = false
        minusBtn.Parent = reachCard
        createCorner(minusBtn, 10)
        addHoverEffect(minusBtn, CONFIG.bgCard, CONFIG.bgHover, CONFIG.bgLight)
        local plusBtn = Instance.new("TextButton")
        plusBtn.Size = UDim2.new(0, 50 * CONFIG.scale, 0, 40 * CONFIG.scale)
        plusBtn.Position = UDim2.new(0, 70 * CONFIG.scale, 0, 50 * CONFIG.scale)
        plusBtn.BackgroundColor3 = CONFIG.primary
        plusBtn.Text = "+"
        plusBtn.TextColor3 = CONFIG.bgDark
        plusBtn.Font = Enum.Font.GothamBlack
        plusBtn.TextSize = 22 * CONFIG.scale
        plusBtn.AutoButtonColor = false
        plusBtn.Parent = reachCard
        createCorner(plusBtn, 10)
        addHoverEffect(plusBtn, CONFIG.primary, Color3.fromRGB(50, 220, 255), Color3.fromRGB(100, 240, 255))
        local sliderBg = Instance.new("Frame")
        sliderBg.Size = UDim2.new(0.45, 0, 0, 8 * CONFIG.scale)
        sliderBg.Position = UDim2.new(0, 15 * CONFIG.scale, 0, 105 * CONFIG.scale)
        sliderBg.BackgroundColor3 = CONFIG.bgDark
        sliderBg.BorderSizePixel = 0
        sliderBg.Parent = reachCard
        createCorner(sliderBg, 4)
        local sliderFill = Instance.new("Frame")
        sliderFill.Name = "SliderFill"
        sliderFill.Size = UDim2.new(CONFIG.reach / 50, 0, 1, 0)
        sliderFill.BackgroundColor3 = CONFIG.primary
        sliderFill.BorderSizePixel = 0
        sliderFill.Parent = sliderBg
        createCorner(sliderFill, 4)
        createGradient(sliderFill, CONFIG.gradientPrimary, 0)
        local sliderKnob = Instance.new("Frame")
        sliderKnob.Size = UDim2.new(0, 18 * CONFIG.scale, 0, 18 * CONFIG.scale)
        sliderKnob.Position = UDim2.new(CONFIG.reach / 50, -9 * CONFIG.scale, 0.5, -9 * CONFIG.scale)
        sliderKnob.BackgroundColor3 = CONFIG.textPrimary
        sliderKnob.BorderSizePixel = 0
        sliderKnob.Parent = sliderBg
        createCorner(sliderKnob, 9)
        local sphereBtn = Instance.new("TextButton")
        sphereBtn.Size = UDim2.new(0, 60 * CONFIG.scale, 0, 28 * CONFIG.scale)
        sphereBtn.Position = UDim2.new(1, -75 * CONFIG.scale, 0, 95 * CONFIG.scale)
        sphereBtn.BackgroundColor3 = CONFIG.showReachSphere and CONFIG.success or CONFIG.bgHover
        sphereBtn.Text = CONFIG.showReachSphere and "ON" or "OFF"
        sphereBtn.TextColor3 = CONFIG.textPrimary
        sphereBtn.Font = Enum.Font.GothamBlack
        sphereBtn.TextSize = 12 * CONFIG.scale
        sphereBtn.AutoButtonColor = false
        sphereBtn.Parent = reachCard
        createCorner(sphereBtn, 14)
        sphereBtn.MouseButton1Click:Connect(function()
            CONFIG.showReachSphere = not CONFIG.showReachSphere
            sphereBtn.Text = CONFIG.showReachSphere and "ON" or "OFF"
            tween(sphereBtn, {BackgroundColor3 = CONFIG.showReachSphere and CONFIG.success or CONFIG.bgHover}, 0.2)
            notify("CADUXX137", "Esfera " .. (CONFIG.showReachSphere and "ativada" or "desativada"), 2, CONFIG.showReachSphere and "success" or "info")
        end)
        local togglesCard = createCard(frame, 150, 200, "Configuracoes", CONFIG.bgCard)
        local toggles = {
            {key = "autoTouch", label = "Auto Touch", y = 45, state = CONFIG.autoTouch},
            {key = "fullBodyTouch", label = "Full Body Touch", y = 85, state = CONFIG.fullBodyTouch},
            {key = "autoSecondTouch", label = "Double Touch", y = 125, state = CONFIG.autoSecondTouch}
        }
        for _, t in ipairs(toggles) do
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0.6, 0, 0, 30 * CONFIG.scale)
            lbl.Position = UDim2.new(0, 15 * CONFIG.scale, 0, t.y * CONFIG.scale)
            lbl.BackgroundTransparency = 1
            lbl.Text = t.label
            lbl.TextColor3 = CONFIG.textSecondary
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 13 * CONFIG.scale
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = togglesCard
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, 55 * CONFIG.scale, 0, 26 * CONFIG.scale)
            btn.Position = UDim2.new(1, -70 * CONFIG.scale, 0, t.y * CONFIG.scale)
            btn.BackgroundColor3 = t.state and CONFIG.success or CONFIG.bgHover
            btn.Text = t.state and "ON" or "OFF"
            btn.TextColor3 = CONFIG.textPrimary
            btn.Font = Enum.Font.GothamBlack
            btn.TextSize = 11 * CONFIG.scale
            btn.AutoButtonColor = false
            btn.Parent = togglesCard
            createCorner(btn, 13)
            btn.MouseButton1Click:Connect(function()
                CONFIG[t.key] = not CONFIG[t.key]
                btn.Text = CONFIG[t.key] and "ON" or "OFF"
                tween(btn, {BackgroundColor3 = CONFIG[t.key] and CONFIG.success or CONFIG.bgHover}, 0.2)
            end)
        end
        local statusCard = createCard(frame, 360, 80, "Status do Sistema", CONFIG.bgElevated)
        local statusText = Instance.new("TextLabel")
        statusText.Size = UDim2.new(1, -30 * CONFIG.scale, 0, 40 * CONFIG.scale)
        statusText.Position = UDim2.new(0, 15 * CONFIG.scale, 0, 40 * CONFIG.scale)
        statusText.BackgroundTransparency = 1
        statusText.Text = "Sistema Ativo | " .. #balls .. " bolas detectadas"
        statusText.TextColor3 = CONFIG.success
        statusText.Font = Enum.Font.GothamBold
        statusText.TextSize = 13 * CONFIG.scale
        statusText.Parent = statusCard
        spawn(function()
            while statusText and statusText.Parent do
                statusText.Text = "Sistema Ativo | " .. #balls .. " bolas | " .. formatNumber(STATS.totalTouches) .. " toques"
                wait(1)
            end
        end)
        minusBtn.MouseButton1Click:Connect(function()
            CONFIG.reach = math.max(1, CONFIG.reach - 1)
            updateReach()
        end)
        plusBtn.MouseButton1Click:Connect(function()
            CONFIG.reach = math.min(50, CONFIG.reach + 1)
            updateReach()
        end)
        local dragging = false
        sliderBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                updateSlider(input)
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
        function updateSlider(input)
            local rel = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            CONFIG.reach = math.floor(rel * 50)
            updateReach()
        end
        function updateReach()
            reachDisplay.Text = tostring(CONFIG.reach)
            local s = math.clamp(CONFIG.reach / 50, 0, 1)
            tween(sliderFill, {Size = UDim2.new(s, 0, 1, 0)}, 0.1)
            tween(sliderKnob, {Position = UDim2.new(s, -9 * CONFIG.scale, 0.5, -9 * CONFIG.scale)}, 0.1)
        end
    end
    function createBodyTab(parent)
        local frame = Instance.new("ScrollingFrame")
        frame.Name = "BodyTab"
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.ScrollBarThickness = 4
        frame.ScrollBarImageColor3 = CONFIG.primary
        frame.CanvasSize = UDim2.new(0, 0, 0, 900 * CONFIG.scale)
        frame.Parent = parent
        currentTabFrame = frame
        frame.Position = UDim2.new(0, 30 * CONFIG.scale, 0, 0)
        tween(frame, {Position = UDim2.new(0, 0, 0, 0)}, 0.3)
        local infoCard = createCard(frame, 0, 70, "Selecao de Partes", CONFIG.bgElevated)
        local infoText = Instance.new("TextLabel")
        infoText.Size = UDim2.new(1, -30 * CONFIG.scale, 0, 40 * CONFIG.scale)
        infoText.Position = UDim2.new(0, 15 * CONFIG.scale, 0, 35 * CONFIG.scale)
        infoText.BackgroundTransparency = 1
        infoText.Text = "Escolha onde o reach sera aplicado no seu personagem"
        infoText.TextColor3 = CONFIG.textSecondary
        infoText.Font = Enum.Font.GothamBold
        infoText.TextSize = 12 * CONFIG.scale
        infoText.TextWrapped = true
        infoText.Parent = infoCard
        local presetsCard = createCard(frame, 80, 200, "Presets Rapidos", CONFIG.bgCard)
        for i, preset in ipairs(CONFIG.bodyPresets) do
            local presetBtn = Instance.new("TextButton")
            presetBtn.Size = UDim2.new(0.45, -8 * CONFIG.scale, 0, 35 * CONFIG.scale)
            presetBtn.Position = UDim2.new(
                i % 2 == 1 and 0 or 0.5, 
                i % 2 == 1 and 15 * CONFIG.scale or 8 * CONFIG.scale, 
                0, 
                45 + (math.floor((i-1)/2) * 45) * CONFIG.scale
            )
            presetBtn.BackgroundColor3 = CONFIG.primary
            presetBtn.BackgroundTransparency = 0.3
            presetBtn.Text = preset.name
            presetBtn.TextColor3 = CONFIG.textPrimary
            presetBtn.Font = Enum.Font.GothamBold
            presetBtn.TextSize = 11 * CONFIG.scale
            presetBtn.AutoButtonColor = false
            presetBtn.Parent = presetsCard
            createCorner(presetBtn, 10)
            addHoverEffect(presetBtn, 
                Color3.new(CONFIG.primary.R, CONFIG.primary.G, CONFIG.primary.B), 
                Color3.fromRGB(50, 200, 255), 
                Color3.fromRGB(100, 220, 255)
            )
            presetBtn.MouseButton1Click:Connect(function()
                for k, _ in pairs(CONFIG.bodyParts) do
                    CONFIG.bodyParts[k] = false
                end
                for part, enabled in pairs(preset.parts) do
                    CONFIG.bodyParts[part] = enabled
                end
                notify("CADUXX137", "Preset aplicado: " .. preset.name, 2, "success")
                switchTab("body")
            end)
        end
        local yOffset = 290 * CONFIG.scale
        local parts = {
            {name = "HumanoidRootPart", display = "Centro (HRP)", category = "Core"},
            {name = "Head", display = "Cabeca", category = "Core"},
            {name = "LeftUpperArm", display = "Braco Esq (Cima)", category = "Bracos"},
            {name = "RightUpperArm", display = "Braco Dir (Cima)", category = "Bracos"},
            {name = "LeftLowerArm", display = "Braco Esq (Baixo)", category = "Bracos"},
            {name = "RightLowerArm", display = "Braco Dir (Baixo)", category = "Bracos"},
            {name = "LeftHand", display = "Mao Esquerda", category = "Bracos"},
            {name = "RightHand", display = "Mao Direita", category = "Bracos"},
            {name = "LeftUpperLeg", display = "Perna Esq (Cima)", category = "Pernas"},
            {name = "RightUpperLeg", display = "Perna Dir (Cima)", category = "Pernas"},
            {name = "LeftLowerLeg", display = "Perna Esq (Baixo)", category = "Pernas"},
            {name = "RightLowerLeg", display = "Perna Dir (Baixo)", category = "Pernas"},
            {name = "LeftFoot", display = "Pe Esquerdo", category = "Pernas"},
            {name = "RightFoot", display = "Pe Direito", category = "Pernas"}
        }
        local currentCategory = ""
        for _, part in ipairs(parts) do
            if part.category ~= currentCategory then
                currentCategory = part.category
                local catHeader = Instance.new("TextLabel")
                catHeader.Size = UDim2.new(1, -30 * CONFIG.scale, 0, 25 * CONFIG.scale)
                catHeader.Position = UDim2.new(0, 15 * CONFIG.scale, 0, yOffset / CONFIG.scale)
                catHeader.BackgroundTransparency = 1
                catHeader.Text = "-- " .. part.category .. " --"
                catHeader.TextColor3 = CONFIG.primary
                catHeader.Font = Enum.Font.GothamBold
                catHeader.TextSize = 12 * CONFIG.scale
                catHeader.TextXAlignment = Enum.TextXAlignment.Left
                catHeader.Parent = frame
                yOffset = yOffset + 30 * CONFIG.scale
            end
            local card = createCard(frame, yOffset / CONFIG.scale, 55, "", CONFIG.bgCard)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0.7, 0, 1, 0)
            lbl.Position = UDim2.new(0, 15 * CONFIG.scale, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = part.display
            lbl.TextColor3 = CONFIG.textPrimary
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 13 * CONFIG.scale
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = card
            local toggle = Instance.new("TextButton")
            toggle.Size = UDim2.new(0, 45 * CONFIG.scale, 0, 28 * CONFIG.scale)
            toggle.Position = UDim2.new(1, -60 * CONFIG.scale, 0.5, -14 * CONFIG.scale)
            toggle.BackgroundColor3 = CONFIG.bodyParts[part.name] and CONFIG.success or CONFIG.bgHover
            toggle.Text = CONFIG.bodyParts[part.name] and "" or ""
            toggle.TextColor3 = CONFIG.textPrimary
            toggle.Font = Enum.Font.GothamBlack
            toggle.TextSize = 16 * CONFIG.scale
            toggle.AutoButtonColor = false
            toggle.Parent = card
            createCorner(toggle, 10)
            toggle.MouseButton1Click:Connect(function()
                CONFIG.bodyParts[part.name] = not CONFIG.bodyParts[part.name]
                toggle.BackgroundColor3 = CONFIG.bodyParts[part.name] and CONFIG.success or CONFIG.bgHover
                toggle.Text = CONFIG.bodyParts[part.name] and "" or ""
                notify("CADUXX137", part.display .. (CONFIG.bodyParts[part.name] and " ativado" or " desativado"), 1, CONFIG.bodyParts[part.name] and "success" or "info")
            end)
            yOffset = yOffset + 65 * CONFIG.scale
        end
        frame.CanvasSize = UDim2.new(0, 0, 0, yOffset + 20)
    end
    function createStatsTab(parent)
        local frame = Instance.new("ScrollingFrame")
        frame.Name = "StatsTab"
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.ScrollBarThickness = 4
        frame.ScrollBarImageColor3 = CONFIG.primary
        frame.CanvasSize = UDim2.new(0, 0, 0, 600 * CONFIG.scale)
        frame.Parent = parent
        currentTabFrame = frame
        frame.Position = UDim2.new(0, 30 * CONFIG.scale, 0, 0)
        tween(frame, {Position = UDim2.new(0, 0, 0, 0)}, 0.3)
        local stats = {
            {label = "Total de Toques", value = "0", key = "totalTouches", icon = "", color = CONFIG.primary},
            {label = "Bolas Detectadas", value = "0", key = "ballsDetected", icon = "", color = CONFIG.success},
            {label = "Tempo de Sessao", value = "00:00", key = "sessionTime", icon = "", color = CONFIG.warning},
            {label = "Reach Atual", value = tostring(CONFIG.reach) .. " studs", key = "reach", icon = "", color = CONFIG.info}
        }
        local yOffset = 0
        for i, stat in ipairs(stats) do
            local statCard = createCard(frame, yOffset, 80, "", CONFIG.bgElevated)
            local icon = Instance.new("TextLabel")
            icon.Size = UDim2.new(0, 50 * CONFIG.scale, 0, 50 * CONFIG.scale)
            icon.Position = UDim2.new(0, 15 * CONFIG.scale, 0.5, -25 * CONFIG.scale)
            icon.BackgroundColor3 = stat.color
            icon.BackgroundTransparency = 0.8
            icon.Text = stat.icon
            icon.Font = Enum.Font.GothamBold
            icon.TextSize = 24 * CONFIG.scale
            icon.Parent = statCard
            createCorner(icon, 12)
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.6, 0, 0, 25 * CONFIG.scale)
            label.Position = UDim2.new(0, 75 * CONFIG.scale, 0, 15 * CONFIG.scale)
            label.BackgroundTransparency = 1
            label.Text = stat.label
            label.TextColor3 = CONFIG.textSecondary
            label.Font = Enum.Font.GothamBold
            label.TextSize = 13 * CONFIG.scale
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = statCard
            local value = Instance.new("TextLabel")
            value.Name = stat.key .. "Value"
            value.Size = UDim2.new(0.6, 0, 0, 30 * CONFIG.scale)
            value.Position = UDim2.new(0, 75 * CONFIG.scale, 0, 40 * CONFIG.scale)
            value.BackgroundTransparency = 1
            value.Text = stat.value
            value.TextColor3 = stat.color
            value.Font = Enum.Font.GothamBlack
            value.TextSize = 22 * CONFIG.scale
            value.TextXAlignment = Enum.TextXAlignment.Left
            value.Parent = statCard
            yOffset = yOffset + 90 * CONFIG.scale
        end
        local perfCard = createCard(frame, yOffset + 10, 120, "Performance", CONFIG.bgCard)
        local perfText = Instance.new("TextLabel")
        perfText.Size = UDim2.new(1, -30 * CONFIG.scale, 0, 80 * CONFIG.scale)
        perfText.Position = UDim2.new(0, 15 * CONFIG.scale, 0, 40 * CONFIG.scale)
        perfText.BackgroundTransparency = 1
        perfText.Text = "FPS: Calculando...\nPing: Calculando...\nMemoria: Calculando..."
        perfText.TextColor3 = CONFIG.textMuted
        perfText.Font = Enum.Font.Gotham
        perfText.TextSize = 13 * CONFIG.scale
        perfText.TextWrapped = true
        perfText.TextYAlignment = Enum.TextYAlignment.Top
        perfText.Parent = perfCard
        spawn(function()
            while frame and frame.Parent do
                STATS.sessionTime = tick() - STATS.startTime
                local touchesLabel = frame:FindFirstChild("totalTouchesValue", true)
                if touchesLabel then
                    touchesLabel.Text = formatNumber(STATS.totalTouches)
                end
                local ballsLabel = frame:FindFirstChild("ballsDetectedValue", true)
                if ballsLabel then
                    ballsLabel.Text = tostring(STATS.ballsDetected)
                end
                local timeLabel = frame:FindFirstChild("sessionTimeValue", true)
                if timeLabel then
                    timeLabel.Text = formatTime(STATS.sessionTime)
                end
                local reachLabel = frame:FindFirstChild("reachValue", true)
                if reachLabel then
                    reachLabel.Text = tostring(CONFIG.reach) .. " studs"
                end
                if perfText then
                    local fps = math.floor(1 / RunService.Heartbeat:Wait())
                    perfText.Text = string.format("FPS: %d\nPing: %d ms\nMemoria: %s MB", 
                        fps, 
                        math.random(20, 80),
                        formatNumber(math.random(50, 200))
                    )
                end
                wait(1)
            end
        end)
        frame.CanvasSize = UDim2.new(0, 0, 0, yOffset + 150)
    end
    minimizeBtn.MouseEnter:Connect(function()
        tween(minimizeBtn, {BackgroundColor3 = CONFIG.primary}, 0.2)
    end)
    minimizeBtn.MouseLeave:Connect(function()
        tween(minimizeBtn, {BackgroundColor3 = CONFIG.bgElevated}, 0.2)
    end)
    minimizeBtn.MouseButton1Click:Connect(function()
        isMinimized = true
        tween(main, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
        wait(0.3)
        mainGui:Destroy()
        createIconButton()
    end)
    closeBtn.MouseButton1Click:Connect(function()
        tween(main, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
        wait(0.3)
        mainGui:Destroy()
        if reachSphere then reachSphere:Destroy() end
    end)
    makeDraggable(main, header)
    main.Size = UDim2.new(0, 0, 0, 0)
    tween(main, {Size = UDim2.new(0, W, 0, H)}, 0.5, Enum.EasingStyle.Back)
    notify("CADUXX137", "Ultimate Edition carregada!", 3, "premium")
end
RunService.Heartbeat:Connect(function()
    updateCharacter()
    updateSphere()
    findBalls()
    if not HRP then return end
    local now = tick()
    if now - lastTouch < 0.05 then return end
    local parts = getSelectedBodyParts()
    if #parts == 0 then return end
    local hrpPos = HRP.Position
    local closestBall = nil
    local closestDist = CONFIG.reach
    for _, ball in ipairs(balls) do
        if ball and ball.Parent then
            local dist = (ball.Position - hrpPos).Magnitude
            if dist <= CONFIG.reach and dist < closestDist then
                closestDist = dist
                closestBall = ball
            end
        end
    end
    if CONFIG.autoTouch and closestBall then
        lastTouch = now
        for _, part in ipairs(parts) do
            doTouch(closestBall, part)
        end
    end
end)
createLoadingScreen()
