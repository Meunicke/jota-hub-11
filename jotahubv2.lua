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
    autoSecondTouch = true,
    scanCooldown = 1.5,
    scale = 1.0,
    currentTab = "intro",
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
            "Sistema completo de abas (Intro, Main, Stats)",
            "Tela de loading animada premium",
            "Reach otimizado no centro do personagem",
            "Interface redesenhada do zero",
            "Sistema de estatísticas em tempo real",
            "Otimização de performance",
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
                container.Size = UDim2.new(0, 50 * CONFIG.scale, 0, 26 * CONFIG.scale)
        container.Position = UDim2.new(0, x * CONFIG.scale, 0, y * CONFIG.scale)
        container.BackgroundColor3 = state and CONFIG.success or CONFIG.bgLight
        container.BorderSizePixel = 0
        container.Parent = parent
        createCorner(container, 13)
        
        local circle = Instance.new("Frame")
        circle.Size = UDim2.new(0, 22 * CONFIG.scale, 0, 22 * CONFIG.scale)
        circle.Position = state and UDim2.new(1, -24 * CONFIG.scale, 0, 2 * CONFIG.scale) or UDim2.new(0, 2 * CONFIG.scale, 0, 2 * CONFIG.scale)
        circle.BackgroundColor3 = CONFIG.textPrimary
        circle.BorderSizePixel = 0
        circle.Parent = container
        createCorner(circle, 11)
        
        local labelText = Instance.new("TextLabel")
        labelText.Size = UDim2.new(0, 200 * CONFIG.scale, 0, 26 * CONFIG.scale)
        labelText.Position = UDim2.new(0, (x + 55) * CONFIG.scale, 0, y * CONFIG.scale)
        labelText.BackgroundTransparency = 1
        labelText.Text = label or ""
        labelText.TextColor3 = CONFIG.textPrimary
        labelText.Font = Enum.Font.GothamBold
        labelText.TextSize = 14 * CONFIG.scale
        labelText.TextXAlignment = Enum.TextXAlignment.Left
        labelText.Parent = parent
        
        local clickArea = Instance.new("TextButton")
        clickArea.Size = UDim2.new(0, 255 * CONFIG.scale, 0, 26 * CONFIG.scale)
        clickArea.Position = UDim2.new(0, x * CONFIG.scale, 0, y * CONFIG.scale)
        clickArea.BackgroundTransparency = 1
        clickArea.Text = ""
        clickArea.Parent = parent
        
        local currentState = state
        clickArea.MouseButton1Click:Connect(function()
            currentState = not currentState
            tween(container, {BackgroundColor3 = currentState and CONFIG.success or CONFIG.bgLight}, 0.2)
            tween(circle, {Position = currentState and UDim2.new(1, -24 * CONFIG.scale, 0, 2 * CONFIG.scale) or UDim2.new(0, 2 * CONFIG.scale, 0, 2 * CONFIG.scale)}, 0.2)
            return currentState
        end)
        
        return {
            container = container,
            circle = circle,
            getState = function() return currentState end,
            setState = function(newState)
                currentState = newState
                tween(container, {BackgroundColor3 = currentState and CONFIG.success or CONFIG.bgLight}, 0.2)
                tween(circle, {Position = currentState and UDim2.new(1, -24 * CONFIG.scale, 0, 2 * CONFIG.scale) or UDim2.new(0, 2 * CONFIG.scale, 0, 2 * CONFIG.scale)}, 0.2)
            end
        }
    end
    
    function createSlider(parent, x, y, min, max, current, label)
        local width = 200 * CONFIG.scale
        local container = Instance.new("Frame")
        container.Size = UDim2.new(0, width, 0, 40 * CONFIG.scale)
        container.Position = UDim2.new(0, x * CONFIG.scale, 0, y * CONFIG.scale)
        container.BackgroundTransparency = 1
        container.Parent = parent
        
        local labelText = Instance.new("TextLabel")
        labelText.Size = UDim2.new(1, 0, 0, 20 * CONFIG.scale)
        labelText.BackgroundTransparency = 1
        labelText.Text = label or ""
        labelText.TextColor3 = CONFIG.textSecondary
        labelText.Font = Enum.Font.GothamBold
        labelText.TextSize = 12 * CONFIG.scale
        labelText.TextXAlignment = Enum.TextXAlignment.Left
        labelText.Parent = container
        
        local track = Instance.new("Frame")
        track.Size = UDim2.new(1, 0, 0, 6 * CONFIG.scale)
        track.Position = UDim2.new(0, 0, 0, 25 * CONFIG.scale)
        track.BackgroundColor3 = CONFIG.bgLight
        track.BorderSizePixel = 0
        track.Parent = container
        createCorner(track, 3)
        
        local fill = Instance.new("Frame")
        local percent = (current - min) / (max - min)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        fill.BackgroundColor3 = CONFIG.primary
        fill.BorderSizePixel = 0
        fill.Parent = track
        createCorner(fill, 3)
        createGradient(fill, CONFIG.gradientPrimary, 0)
        
        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 16 * CONFIG.scale, 0, 16 * CONFIG.scale)
        knob.Position = UDim2.new(percent, -8 * CONFIG.scale, 0.5, -8 * CONFIG.scale)
        knob.BackgroundColor3 = CONFIG.textPrimary
        knob.BorderSizePixel = 0
        knob.ZIndex = 2
        knob.Parent = track
        createCorner(knob, 8)
        createStroke(knob, CONFIG.primary, 2, 0)
        
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0, 50 * CONFIG.scale, 0, 20 * CONFIG.scale)
        valueLabel.Position = UDim2.new(1, 10 * CONFIG.scale, 0, 20 * CONFIG.scale)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = tostring(math.floor(current))
        valueLabel.TextColor3 = CONFIG.primary
        valueLabel.Font = Enum.Font.GothamBlack
        valueLabel.TextSize = 14 * CONFIG.scale
        valueLabel.TextXAlignment = Enum.TextXAlignment.Left
        valueLabel.Parent = container
        
        local dragging = false
        local function updateSlider(input)
            local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local value = min + (max - min) * pos
            tween(fill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.1)
            tween(knob, {Position = UDim2.new(pos, -8 * CONFIG.scale, 0.5, -8 * CONFIG.scale)}, 0.1)
            valueLabel.Text = tostring(math.floor(value))
            return value
        end
        
        knob.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
            end
        end)
        
        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                updateSlider(input)
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
        
        return {
            container = container,
            getValue = function() return tonumber(valueLabel.Text) end,
            setValue = function(val)
                local clamped = math.clamp(val, min, max)
                local pos = (clamped - min) / (max - min)
                tween(fill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.2)
                tween(knob, {Position = UDim2.new(pos, -8 * CONFIG.scale, 0.5, -8 * CONFIG.scale)}, 0.2)
                valueLabel.Text = tostring(math.floor(clamped))
            end
        }
    end
    
    function createIntroTab(parent)
        local tab = Instance.new("ScrollingFrame")
        tab.Name = "IntroTab"
        tab.Size = UDim2.new(1, 0, 1, 0)
        tab.BackgroundTransparency = 1
        tab.BorderSizePixel = 0
        tab.ScrollBarThickness = 4
        tab.ScrollBarImageColor3 = CONFIG.primary
        tab.CanvasSize = UDim2.new(0, 0, 0, 600 * CONFIG.scale)
        tab.Parent = parent
        currentTabFrame = tab
        
        local welcomeCard = createCard(tab, 0, 120, "Bem-vindo ao CADUXX137", CONFIG.bgCard)
        local welcomeText = Instance.new("TextLabel")
        welcomeText.Size = UDim2.new(1, -40 * CONFIG.scale, 0, 60 * CONFIG.scale)
        welcomeText.Position = UDim2.new(0, 20 * CONFIG.scale, 0, 50 * CONFIG.scale)
        welcomeText.BackgroundTransparency = 1
        welcomeText.Text = "O sistema mais avançado de automação para jogos de bola do Roblox. Desenvolvido para máxima performance e precisão."
        welcomeText.TextColor3 = CONFIG.textSecondary
        welcomeText.Font = Enum.Font.Gotham
        welcomeText.TextSize = 14 * CONFIG.scale
        welcomeText.TextWrapped = true
        welcomeText.TextXAlignment = Enum.TextXAlignment.Left
        welcomeText.Parent = welcomeCard
        
        local updatesCard = createCard(tab, 130, 280, "Últimas Atualizações", CONFIG.bgCard)
        local yOffset = 50 * CONFIG.scale
        for i, update in ipairs(UPDATES) do
            if i > 3 then break end
            local updateFrame = Instance.new("Frame")
            updateFrame.Size = UDim2.new(1, -30 * CONFIG.scale, 0, 70 * CONFIG.scale)
            updateFrame.Position = UDim2.new(0, 15 * CONFIG.scale, 0, yOffset)
            updateFrame.BackgroundColor3 = CONFIG.bgElevated
            updateFrame.BackgroundTransparency = 0.5
            updateFrame.BorderSizePixel = 0
            updateFrame.Parent = updatesCard
            createCorner(updateFrame, 12)
            
            local versionLabel = Instance.new("TextLabel")
            versionLabel.Size = UDim2.new(0, 120 * CONFIG.scale, 0, 25 * CONFIG.scale)
            versionLabel.Position = UDim2.new(0, 15 * CONFIG.scale, 0, 10 * CONFIG.scale)
            versionLabel.BackgroundTransparency = 1
            versionLabel.Text = update.version
            versionLabel.TextColor3 = update.type == "major" and CONFIG.accent or CONFIG.primary
            versionLabel.Font = Enum.Font.GothamBlack
            versionLabel.TextSize = 16 * CONFIG.scale
            versionLabel.TextXAlignment = Enum.TextXAlignment.Left
            versionLabel.Parent = updateFrame
            
            local dateLabel = Instance.new("TextLabel")
            dateLabel.Size = UDim2.new(0, 100 * CONFIG.scale, 0, 20 * CONFIG.scale)
            dateLabel.Position = UDim2.new(1, -115 * CONFIG.scale, 0, 12 * CONFIG.scale)
            dateLabel.BackgroundTransparency = 1
            dateLabel.Text = update.date
            dateLabel.TextColor3 = CONFIG.textMuted
            dateLabel.Font = Enum.Font.Gotham
            dateLabel.TextSize = 12 * CONFIG.scale
            dateLabel.TextXAlignment = Enum.TextXAlignment.Right
            dateLabel.Parent = updateFrame
            
            local changeText = Instance.new("TextLabel")
            changeText.Size = UDim2.new(1, -30 * CONFIG.scale, 0, 30 * CONFIG.scale)
            changeText.Position = UDim2.new(0, 15 * CONFIG.scale, 0, 35 * CONFIG.scale)
            changeText.BackgroundTransparency = 1
            changeText.Text = update.changes[1]
            changeText.TextColor3 = CONFIG.textSecondary
            changeText.Font = Enum.Font.Gotham
            changeText.TextSize = 12 * CONFIG.scale
            changeText.TextWrapped = true
            changeText.TextXAlignment = Enum.TextXAlignment.Left
            changeText.Parent = updateFrame
            
            yOffset = yOffset + 80 * CONFIG.scale
        end
        
        local infoCard = createCard(tab, 420, 150, "Informações", CONFIG.bgCard)
        local infoItems = {
            "• Desenvolvido por: CADUXX137 Team",
            "• Versão: " .. CONFIG.version,
            "• Build: " .. CONFIG.build,
            "• Sistema: WindUI + CADUXX137 Core"
        }
        local infoY = 50 * CONFIG.scale
        for _, item in ipairs(infoItems) do
            local infoLabel = Instance.new("TextLabel")
            infoLabel.Size = UDim2.new(1, -30 * CONFIG.scale, 0, 25 * CONFIG.scale)
            infoLabel.Position = UDim2.new(0, 15 * CONFIG.scale, 0, infoY)
            infoLabel.BackgroundTransparency = 1
            infoLabel.Text = item
            infoLabel.TextColor3 = CONFIG.textSecondary
            infoLabel.Font = Enum.Font.Gotham
            infoLabel.TextSize = 13 * CONFIG.scale
            infoLabel.TextXAlignment = Enum.TextXAlignment.Left
            infoLabel.Parent = infoCard
            infoY = infoY + 25 * CONFIG.scale
        end
        
        tween(tab, {Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0}, 0.3)
    end
    
    function createMainTab(parent)
        local tab = Instance.new("ScrollingFrame")
        tab.Name = "MainTab"
        tab.Size = UDim2.new(1, 0, 1, 0)
        tab.BackgroundTransparency = 1
        tab.BorderSizePixel = 0
        tab.ScrollBarThickness = 4
        tab.ScrollBarImageColor3 = CONFIG.primary
        tab.CanvasSize = UDim2.new(0, 0, 0, 700 * CONFIG.scale)
        tab.Parent = parent
        currentTabFrame = tab
        
        local reachCard = createCard(tab, 0, 180, "Configurações de Reach", CONFIG.bgCard)
        local reachToggle = createToggle(reachCard, 20, 55, CONFIG.autoTouch, "Auto Touch")
        local sphereToggle = createToggle(reachCard, 20, 95, CONFIG.showReachSphere, "Mostrar Esfera")
        local secondTouchToggle = createToggle(reachCard, 20, 135, CONFIG.autoSecondTouch, "Toque Duplo")
        
        local reachSlider = createSlider(reachCard, 20, 180, 5, 50, CONFIG.reach, "Distância do Reach")
        
        local applyBtn = Instance.new("TextButton")
        applyBtn.Size = UDim2.new(0, 120 * CONFIG.scale, 0, 35 * CONFIG.scale)
        applyBtn.Position = UDim2.new(1, -140 * CONFIG.scale, 0, 140 * CONFIG.scale)
        applyBtn.BackgroundColor3 = CONFIG.success
        applyBtn.Text = "APLICAR"
        applyBtn.TextColor3 = CONFIG.bgDark
        applyBtn.Font = Enum.Font.GothamBlack
        applyBtn.TextSize = 14 * CONFIG.scale
        applyBtn.AutoButtonColor = false
        applyBtn.Parent = reachCard
        createCorner(applyBtn, 10)
        addHoverEffect(applyBtn, CONFIG.success, Color3.fromRGB(0, 230, 120), Color3.fromRGB(0, 200, 100))
        addRippleEffect(applyBtn, Color3.new(0, 0, 0))
        
        applyBtn.MouseButton1Click:Connect(function()
            CONFIG.autoTouch = reachToggle.getState()
            CONFIG.showReachSphere = sphereToggle.getState()
            CONFIG.autoSecondTouch = secondTouchToggle.getState()
            CONFIG.reach = reachSlider.getValue()
            
            notify("CADUXX137", "Configurações aplicadas!", 2, "success")
            
            if CONFIG.showReachSphere then
                updateSphere()
            else
                if reachSphere then
                    reachSphere:Destroy()
                    reachSphere = nil
                end
            end
        end)
        
        local detectionCard = createCard(tab, 190, 150, "Detecção de Bolas", CONFIG.bgCard)
        local scanBtn = Instance.new("TextButton")
        scanBtn.Size = UDim2.new(0, 150 * CONFIG.scale, 0, 40 * CONFIG.scale)
        scanBtn.Position = UDim2.new(0.5, -75 * CONFIG.scale, 0, 60 * CONFIG.scale)
        scanBtn.BackgroundColor3 = CONFIG.primary
        scanBtn.Text = "SCANEAR BOLAS"
        scanBtn.TextColor3 = CONFIG.bgDark
        scanBtn.Font = Enum.Font.GothamBlack
        scanBtn.TextSize = 14 * CONFIG.scale
        scanBtn.AutoButtonColor = false
        scanBtn.Parent = detectionCard
        createCorner(scanBtn, 12)
        addHoverEffect(scanBtn, CONFIG.primary, Color3.fromRGB(0, 220, 240), Color3.fromRGB(0, 200, 220))
        addRippleEffect(scanBtn, Color3.new(0, 0, 0))
        
        local ballCountLabel = Instance.new("TextLabel")
        ballCountLabel.Size = UDim2.new(1, 0, 0, 30 * CONFIG.scale)
        ballCountLabel.Position = UDim2.new(0, 0, 0, 110 * CONFIG.scale)
        ballCountLabel.BackgroundTransparency = 1
        ballCountLabel.Text = "Bolas detectadas: 0"
        ballCountLabel.TextColor3 = CONFIG.textSecondary
        ballCountLabel.Font = Enum.Font.GothamBold
        ballCountLabel.TextSize = 14 * CONFIG.scale
        ballCountLabel.Parent = detectionCard
        
        scanBtn.MouseButton1Click:Connect(function()
            local count = findBalls()
            ballCountLabel.Text = "Bolas detectadas: " .. count
            ballCountLabel.TextColor3 = count > 0 and CONFIG.success or CONFIG.warning
            notify("CADUXX137", count .. " bolas encontradas!", 2, count > 0 and "success" or "warning")
        end)
        
        local miscCard = createCard(tab, 350, 200, "Miscelânea", CONFIG.bgCard)
        local scaleSlider = createSlider(miscCard, 20, 50, 0.5, 2.0, CONFIG.scale, "Escala da Interface")
        
        local resetBtn = Instance.new("TextButton")
        resetBtn.Size = UDim2.new(0, 140 * CONFIG.scale, 0, 35 * CONFIG.scale)
        resetBtn.Position = UDim2.new(0.5, -70 * CONFIG.scale, 0, 130 * CONFIG.scale)
        resetBtn.BackgroundColor3 = CONFIG.danger
        resetBtn.Text = "RESETAR CONFIGS"
        resetBtn.TextColor3 = CONFIG.textPrimary
        resetBtn.Font = Enum.Font.GothamBlack
        resetBtn.TextSize = 13 * CONFIG.scale
        resetBtn.AutoButtonColor = false
        resetBtn.Parent = miscCard
        createCorner(resetBtn, 10)
        addHoverEffect(resetBtn, CONFIG.danger, Color3.fromRGB(255, 80, 100), Color3.fromRGB(255, 100, 120))
        
        resetBtn.MouseButton1Click:Connect(function()
            CONFIG.reach = 15
            CONFIG.showReachSphere = true
            CONFIG.autoTouch = true
            CONFIG.autoSecondTouch = true
            CONFIG.scale = 1.0
            
            notify("CADUXX137", "Configurações resetadas!", 2, "warning")
            createMainGUI()
        end)
        
        tween(tab, {Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0}, 0.3)
    end
    
    function createStatsTab(parent)
        local tab = Instance.new("Frame")
        tab.Name = "StatsTab"
        tab.Size = UDim2.new(1, 0, 1, 0)
        tab.BackgroundTransparency = 1
        tab.BorderSizePixel = 0
        tab.Parent = parent
        currentTabFrame = tab
        
        local stats = {
            {label = "Toques Totais", value = function() return formatNumber(STATS.totalTouches) end, color = CONFIG.success, icon = "rbxassetid://104616032736993"},
            {label = "Bolas Detectadas", value = function() return tostring(STATS.ballsDetected) end, color = CONFIG.primary, icon = "rbxassetid://104616032736993"},
            {label = "Tempo de Sessão", value = function() return formatTime(tick() - STATS.startTime) end, color = CONFIG.warning, icon = "rbxassetid://104616032736993"},
            {label = "FPS", value = function() return tostring(math.floor(STATS.fps)) end, color = CONFIG.info, icon = "rbxassetid://104616032736993"}
        }
        
        local yPos = 0
        for i, stat in ipairs(stats) do
            local statCard = Instance.new("Frame")
            statCard.Size = UDim2.new(1, 0, 0, 90 * CONFIG.scale)
            statCard.Position = UDim2.new(0, 0, 0, yPos)
            statCard.BackgroundColor3 = CONFIG.bgCard
            statCard.BackgroundTransparency = 0.3
            statCard.BorderSizePixel = 0
            statCard.Parent = tab
            createCorner(statCard, 16)
            
            local iconBg = Instance.new("Frame")
            iconBg.Size = UDim2.new(0, 50 * CONFIG.scale, 0, 50 * CONFIG.scale)
            iconBg.Position = UDim2.new(0, 20 * CONFIG.scale, 0, 20 * CONFIG.scale)
            iconBg.BackgroundColor3 = stat.color
            iconBg.BackgroundTransparency = 0.8
            iconBg.BorderSizePixel = 0
            iconBg.Parent = statCard
            createCorner(iconBg, 12)
            
            local iconImg = Instance.new("ImageLabel")
            iconImg.Size = UDim2.new(0.6, 0, 0.6, 0)
            iconImg.Position = UDim2.new(0.2, 0, 0.2, 0)
            iconImg.BackgroundTransparency = 1
            iconImg.Image = stat.icon
            iconImg.ImageColor3 = stat.color
            iconImg.Parent = iconBg
            
            local labelText = Instance.new("TextLabel")
            labelText.Size = UDim2.new(0, 200 * CONFIG.scale, 0, 25 * CONFIG.scale)
            labelText.Position = UDim2.new(0, 85 * CONFIG.scale, 0, 20 * CONFIG.scale)
            labelText.BackgroundTransparency = 1
            labelText.Text = stat.label
            labelText.TextColor3 = CONFIG.textMuted
            labelText.Font = Enum.Font.GothamBold
            labelText.TextSize = 14 * CONFIG.scale
            labelText.TextXAlignment = Enum.TextXAlignment.Left
            labelText.Parent = statCard
            
            local valueText = Instance.new("TextLabel")
            valueText.Size = UDim2.new(0, 200 * CONFIG.scale, 0, 35 * CONFIG.scale)
            valueText.Position = UDim2.new(0, 85 * CONFIG.scale, 0, 42 * CONFIG.scale)
            valueText.BackgroundTransparency = 1
            valueText.Text = stat.value()
            valueText.TextColor3 = stat.color
            valueText.Font = Enum.Font.GothamBlack
            valueText.TextSize = 24 * CONFIG.scale
            valueText.TextXAlignment = Enum.TextXAlignment.Left
            valueText.Parent = statCard
            
            spawn(function()
                while valueText and valueText.Parent do
                    valueText.Text = stat.value()
                    wait(0.5)
                end
            end)
            
            yPos = yPos + 100 * CONFIG.scale
        end
        
        local systemCard = createCard(tab, 420, 150, "Status do Sistema", CONFIG.bgCard)
        local statusLabels = {
            {name = "Reach Ativo", check = function() return CONFIG.autoTouch end},
            {name = "Esfera Visível", check = function() return CONFIG.showReachSphere end},
            {name = "Toque Duplo", check = function() return CONFIG.autoSecondTouch end},
            {name = "Personagem", check = function() return HRP ~= nil end}
        }
        
        local statusY = 50 * CONFIG.scale
        for _, status in ipairs(statusLabels) do
            local statusFrame = Instance.new("Frame")
            statusFrame.Size = UDim2.new(1, -30 * CONFIG.scale, 0, 30 * CONFIG.scale)
            statusFrame.Position = UDim2.new(0, 15 * CONFIG.scale, 0, statusY)
            statusFrame.BackgroundTransparency = 1
            statusFrame.Parent = systemCard
            
            local dot = Instance.new("Frame")
            dot.Size = UDim2.new(0, 10 * CONFIG.scale, 0, 10 * CONFIG.scale)
            dot.Position = UDim2.new(0, 0, 0.5, -5 * CONFIG.scale)
            dot.BackgroundColor3 = status.check() and CONFIG.success or CONFIG.danger
            dot.BorderSizePixel = 0
            dot.Parent = statusFrame
            createCorner(dot, 5)
            
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, -20 * CONFIG.scale, 1, 0)
            nameLabel.Position = UDim2.new(0, 20 * CONFIG.scale, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = status.name
            nameLabel.TextColor3 = CONFIG.textSecondary
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextSize = 13 * CONFIG.scale
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Parent = statusFrame
            
            spawn(function()
                while dot and dot.Parent do
                    local isActive = status.check()
                    dot.BackgroundColor3 = isActive and CONFIG.success or CONFIG.danger
                    wait(1)
                end
            end)
            
            statusY = statusY + 30 * CONFIG.scale
        end
        
        tween(tab, {Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0}, 0.3)
    end
    
    makeDraggable(main, header)
    
    minimizeBtn.MouseButton1Click:Connect(function()
        tween(main, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        wait(0.4)
        mainGui:Destroy()
        mainGui = nil
        isMinimized = true
        createIconButton()
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        tween(main, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        wait(0.4)
        mainGui:Destroy()
        mainGui = nil
        notify("CADUXX137", "Hub fechado. Use o comando para reabrir.", 3, "info")
    end)
    
    main.Size = UDim2.new(0, 0, 0, 0)
    tween(main, {Size = UDim2.new(0, W, 0, H)}, 0.5, Enum.EasingStyle.Back)
    
    switchTab(CONFIG.currentTab)
    
    spawn(function()
        while mainGui and mainGui.Parent do
            local fps = math.floor(1 / RunService.Heartbeat:Wait())
            STATS.fps = fps
            wait(0.5)
        end
    end)
end

local function autoTouchLoop()
    while true do
        if CONFIG.autoTouch and HRP and #balls > 0 then
            local hrpPos = HRP.Position
            for _, ball in ipairs(balls) do
                if ball and ball.Parent then
                    local distance = (ball.Position - hrpPos).Magnitude
                    if distance <= CONFIG.reach then
                        doTouch(ball, HRP)
                    end
                end
            end
        end
        RunService.Heartbeat:Wait()
    end
end

local function updateLoop()
    while true do
        updateCharacter()
        if not isLoading then
            updateSphere()
        end
        wait(0.1)
    end
end

player.CharacterAdded:Connect(function()
    wait(1)
    updateCharacter()
end)

spawn(createLoadingScreen)
spawn(updateLoop)
spawn(autoTouchLoop)

notify("CADUXX137", "Sistema inicializado com sucesso!", 5, "success")
