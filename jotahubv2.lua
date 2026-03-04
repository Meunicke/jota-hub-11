-- CADUXX137 v10.0 - Premium Tabbed Edition
-- Sistema completo com Intro, Main e Body

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
-- CONFIGURAÇÕES PREMIUM
-- ============================================
local CONFIG = {
    reach = 15,
    showReachSphere = true,
    autoTouch = true,
    fullBodyTouch = true,
    autoSecondTouch = true,
    scanCooldown = 1.5,
    scale = 1.0,
    currentTab = "intro",
    
    -- Partes do corpo para reach
    bodyParts = {
        HumanoidRootPart = true,
        LeftFoot = false,
        RightFoot = false,
        LeftHand = false,
        RightHand = false,
        LeftLowerLeg = false,
        RightLowerLeg = false,
        LeftUpperLeg = false,
        RightUpperLeg = false,
        LeftLowerArm = false,
        RightLowerArm = false,
        LeftUpperArm = false,
        RightUpperArm = false,
        Head = false
    },
    
    -- IDs das imagens
    iconImage = "rbxassetid://104616032736993",
    iconBackground = "rbxassetid://96755648876012",
    
    -- Cores Premium (Dark Neon)
    primary = Color3.fromRGB(0, 212, 255),
    secondary = Color3.fromRGB(157, 0, 255),
    accent = Color3.fromRGB(255, 0, 128),
    success = Color3.fromRGB(0, 255, 136),
    warning = Color3.fromRGB(255, 200, 0),
    danger = Color3.fromRGB(255, 50, 50),
    
    bgDark = Color3.fromRGB(8, 8, 16),
    bgCard = Color3.fromRGB(18, 18, 30),
    bgElevated = Color3.fromRGB(28, 28, 45),
    bgHover = Color3.fromRGB(38, 38, 60),
    
    textPrimary = Color3.fromRGB(255, 255, 255),
    textSecondary = Color3.fromRGB(180, 180, 200),
    textMuted = Color3.fromRGB(120, 120, 140),
}

-- Changelog/Updates
local UPDATES = {
    {
        version = "v10.0",
        date = "05/03/2026",
        changes = {
            "✨ Novo sistema de abas (Intro, Main, Body)",
            "🦵 Seleção de partes do corpo para reach",
            "🎨 Interface completamente redesenhada",
            "⚡ Performance otimizada",
            "🎯 Sistema de presets salvos"
        }
    },
    {
        version = "v9.2",
        date = "04/03/2026",
        changes = {
            "🔧 Correções de bugs",
            "🎨 Melhorias visuais",
            "📱 Suporte mobile aprimorado"
        }
    },
    {
        version = "v9.0",
        date = "01/03/2026",
        changes = {
            "🚀 Lançamento inicial",
            "⚽ Sistema de reach para bolas",
            "🤖 Auto skills integrado"
        }
    }
}

-- Variáveis globais
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
local mainGui = nil
local currentTabFrame = nil
local tabButtons = {}

-- ============================================
-- FUNÇÕES UTILITÁRIAS
-- ============================================
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
        dragging = false
    end
    
    handle.InputEnded:Connect(endDrag)
    UserInputService.InputEnded:Connect(endDrag)
end

-- ============================================
-- ÍCONE FLUTUANTE
-- ============================================
local function createIconButton()
    if iconGui then iconGui:Destroy() end
    
    iconGui = Instance.new("ScreenGui")
    iconGui.Name = "CADU_Icon_v10"
    iconGui.ResetOnSpawn = false
    iconGui.DisplayOrder = 999999
    iconGui.Parent = playerGui
    
    local iconSize = 70 * CONFIG.scale
    
    local iconFrame = Instance.new("Frame")
    iconFrame.Name = "IconFrame"
    iconFrame.Size = UDim2.new(0, iconSize, 0, iconSize)
    iconFrame.Position = UDim2.new(0.5, -iconSize/2, 0.85, 0)
    iconFrame.BackgroundColor3 = CONFIG.bgCard
    iconFrame.BorderSizePixel = 0
    iconFrame.Parent = iconGui
    
    Instance.new("UICorner", iconFrame).CornerRadius = UDim.new(0, 20 * CONFIG.scale)
    
    local glow = Instance.new("ImageLabel")
    glow.Size = UDim2.new(1.4, 0, 1.4, 0)
    glow.Position = UDim2.new(-0.2, 0, -0.2, 0)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://5028857084"
    glow.ImageColor3 = CONFIG.primary
    glow.ImageTransparency = 0.85
    glow.ScaleType = Enum.ScaleType.Slice
    glow.SliceCenter = Rect.new(10, 10, 90, 90)
    glow.ZIndex = -1
    glow.Parent = iconFrame
    
    local stroke = Instance.new("UIStroke", iconFrame)
    stroke.Color = CONFIG.primary
    stroke.Thickness = 2 * CONFIG.scale
    
    local iconImage = Instance.new("ImageLabel")
    iconImage.Size = UDim2.new(0.6, 0, 0.6, 0)
    iconImage.Position = UDim2.new(0.2, 0, 0.2, 0)
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
        tween(iconFrame, {Size = UDim2.new(0, iconSize * 1.1, 0, iconSize * 1.1)}, 0.2)
        tween(stroke, {Color = CONFIG.secondary}, 0.2)
        tween(glow, {ImageTransparency = 0.6}, 0.2)
    end)
    
    clickBtn.MouseLeave:Connect(function()
        tween(iconFrame, {Size = UDim2.new(0, iconSize, 0, iconSize)}, 0.2)
        tween(stroke, {Color = CONFIG.primary}, 0.2)
        tween(glow, {ImageTransparency = 0.85}, 0.2)
    end)
    
    clickBtn.MouseButton1Click:Connect(function()
        tween(iconFrame, {Size = UDim2.new(0, 0, 0, 0), Rotation = 360}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.3)
        iconGui:Destroy()
        iconGui = nil
        isMinimized = false
        createMainGUI()
    end)
    
    makeDraggable(iconFrame, clickBtn)
    
    iconFrame.Size = UDim2.new(0, 0, 0, 0)
    tween(iconFrame, {Size = UDim2.new(0, iconSize, 0, iconSize)}, 0.4, Enum.EasingStyle.Back)
end

-- ============================================
-- SISTEMA DE BOLAS E REACH
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
            notify("CADUXX137", "Personagem detectado!", 2)
        else
            HRP = nil
        end
    end
end

local function getSelectedBodyParts()
    if not char then return {} end
    local parts = {}
    
    for partName, enabled in pairs(CONFIG.bodyParts) do
        if enabled then
            local part = char:FindFirstChild(partName)
            if part and part:IsA("BasePart") then
                table.insert(parts, part)
            end
        end
    end
    
    if #parts == 0 and HRP then
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
        reachSphere.Name = "CADU_ReachSphere"
        reachSphere.Shape = Enum.PartType.Ball
        reachSphere.Anchored = true
        reachSphere.CanCollide = false
        reachSphere.Transparency = 0.92
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
-- INTERFACE PRINCIPAL COM ABAS
-- ============================================
function createMainGUI()
    pcall(function()
        for _, v in pairs(playerGui:GetChildren()) do
            if v.Name:find("CADU") then v:Destroy() end
        end
    end)
    
    mainGui = Instance.new("ScreenGui")
    mainGui.Name = "CADU_Main_v10"
    mainGui.ResetOnSpawn = false
    mainGui.Parent = playerGui
    
    local W, H = 520 * CONFIG.scale, 480 * CONFIG.scale
    
    local main = Instance.new("Frame")
    main.Name = "MainFrame"
    main.Size = UDim2.new(0, W, 0, H)
    main.Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
    main.BackgroundColor3 = CONFIG.bgDark
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = mainGui
    
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 24 * CONFIG.scale)
    
    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, 80 * CONFIG.scale, 1, 80 * CONFIG.scale)
    shadow.Position = UDim2.new(0, -40 * CONFIG.scale, 0, -40 * CONFIG.scale)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://131296141"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.7
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.ZIndex = -1
    shadow.Parent = main
    
    -- HEADER
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 85 * CONFIG.scale)
    header.BackgroundColor3 = CONFIG.bgCard
    header.BorderSizePixel = 0
    header.ZIndex = 10
    header.Parent = main
    
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 24 * CONFIG.scale)
    
    local headerFix = Instance.new("Frame", header)
    headerFix.Size = UDim2.new(1, 0, 0.5, 0)
    headerFix.Position = UDim2.new(0, 0, 0.5, 0)
    headerFix.BackgroundColor3 = CONFIG.bgCard
    headerFix.BorderSizePixel = 0
    headerFix.ZIndex = 9
    
    -- Logo
    local logoIcon = Instance.new("TextLabel")
    logoIcon.Size = UDim2.new(0, 45 * CONFIG.scale, 0, 45 * CONFIG.scale)
    logoIcon.Position = UDim2.new(0, 20 * CONFIG.scale, 0, 20 * CONFIG.scale)
    logoIcon.BackgroundTransparency = 1
    logoIcon.Text = "⚡"
    logoIcon.TextColor3 = CONFIG.primary
    logoIcon.Font = Enum.Font.GothamBlack
    logoIcon.TextSize = 32 * CONFIG.scale
    logoIcon.ZIndex = 11
    logoIcon.Parent = header
    
    local logoText = Instance.new("TextLabel")
    logoText.Size = UDim2.new(0, 180 * CONFIG.scale, 0, 30 * CONFIG.scale)
    logoText.Position = UDim2.new(0, 70 * CONFIG.scale, 0, 22 * CONFIG.scale)
    logoText.BackgroundTransparency = 1
    logoText.Text = "CADUXX137"
    logoText.TextColor3 = CONFIG.textPrimary
    logoText.Font = Enum.Font.GothamBlack
    logoText.TextSize = 26 * CONFIG.scale
    logoText.TextXAlignment = Enum.TextXAlignment.Left
    logoText.ZIndex = 11
    logoText.Parent = header
    
    local versionText = Instance.new("TextLabel")
    versionText.Size = UDim2.new(0, 100 * CONFIG.scale, 0, 20 * CONFIG.scale)
    versionText.Position = UDim2.new(0, 72 * CONFIG.scale, 0, 52 * CONFIG.scale)
    versionText.BackgroundTransparency = 1
    versionText.Text = "v10.0 Premium"
    versionText.TextColor3 = CONFIG.primary
    versionText.Font = Enum.Font.GothamBold
    versionText.TextSize = 12 * CONFIG.scale
    versionText.TextXAlignment = Enum.TextXAlignment.Left
    versionText.ZIndex = 11
    versionText.Parent = header
    
    -- Botões controle
    local btnSize = UDim2.new(0, 42 * CONFIG.scale, 0, 42 * CONFIG.scale)
    
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "Minimize"
    minimizeBtn.Size = btnSize
    minimizeBtn.Position = UDim2.new(1, -95 * CONFIG.scale, 0, 22 * CONFIG.scale)
    minimizeBtn.BackgroundColor3 = CONFIG.bgElevated
    minimizeBtn.Text = "🎯"
    minimizeBtn.TextColor3 = CONFIG.textPrimary
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.TextSize = 20 * CONFIG.scale
    minimizeBtn.AutoButtonColor = false
    minimizeBtn.ZIndex = 11
    minimizeBtn.Parent = header
    Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 12 * CONFIG.scale)
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "Close"
    closeBtn.Size = btnSize
    closeBtn.Position = UDim2.new(1, -50 * CONFIG.scale, 0, 22 * CONFIG.scale)
    closeBtn.BackgroundColor3 = CONFIG.danger
    closeBtn.BackgroundTransparency = 0.2
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = CONFIG.textPrimary
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18 * CONFIG.scale
    closeBtn.AutoButtonColor = false
    closeBtn.ZIndex = 11
    closeBtn.Parent = header
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 12 * CONFIG.scale)
    
    -- TABS
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(1, -40 * CONFIG.scale, 0, 55 * CONFIG.scale)
    tabContainer.Position = UDim2.new(0, 20 * CONFIG.scale, 0, 90 * CONFIG.scale)
    tabContainer.BackgroundColor3 = CONFIG.bgElevated
    tabContainer.BorderSizePixel = 0
    tabContainer.ZIndex = 10
    tabContainer.Parent = main
    Instance.new("UICorner", tabContainer).CornerRadius = UDim.new(0, 16 * CONFIG.scale)
    
    local tabs = {
        {id = "intro", name = "📢 Intro"},
        {id = "main", name = "⚡ Main"},
        {id = "body", name = "🦵 Body"}
    }
    
    local tabWidth = 1 / #tabs
    
    for i, tab in ipairs(tabs) do
        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = tab.id .. "Tab"
        tabBtn.Size = UDim2.new(tabWidth, -10 * CONFIG.scale, 1, -10 * CONFIG.scale)
        tabBtn.Position = UDim2.new((i-1) * tabWidth, 5 * CONFIG.scale, 0, 5 * CONFIG.scale)
        tabBtn.BackgroundColor3 = tab.id == CONFIG.currentTab and CONFIG.primary or CONFIG.bgCard
        tabBtn.Text = tab.name
        tabBtn.TextColor3 = tab.id == CONFIG.currentTab and CONFIG.bgDark or CONFIG.textPrimary
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.TextSize = 14 * CONFIG.scale
        tabBtn.AutoButtonColor = false
        tabBtn.ZIndex = 11
        tabBtn.Parent = tabContainer
        Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 12 * CONFIG.scale)
        
        tabButtons[tab.id] = tabBtn
        
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
    end
    
    -- Container de conteúdo
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, -40 * CONFIG.scale, 1, -165 * CONFIG.scale)
    contentContainer.Position = UDim2.new(0, 20 * CONFIG.scale, 0, 155 * CONFIG.scale)
    contentContainer.BackgroundTransparency = 1
    contentContainer.ZIndex = 5
    contentContainer.Parent = main
    
    -- ============================================
    -- SISTEMA DE TABS
    -- ============================================
    
    function switchTab(tabId)
        for id, btn in pairs(tabButtons) do
            if id == tabId then
                tween(btn, {BackgroundColor3 = CONFIG.primary}, 0.3)
                btn.TextColor3 = CONFIG.bgDark
            else
                tween(btn, {BackgroundColor3 = CONFIG.bgCard}, 0.3)
                btn.TextColor3 = CONFIG.textPrimary
                
                btn.MouseEnter:Connect(function()
                    tween(btn, {BackgroundColor3 = CONFIG.bgHover}, 0.2)
                end)
                btn.MouseLeave:Connect(function()
                    tween(btn, {BackgroundColor3 = CONFIG.bgCard}, 0.2)
                end)
            end
        end
        
        CONFIG.currentTab = tabId
        
        if currentTabFrame then
            tween(currentTabFrame, {Position = UDim2.new(0, -30 * CONFIG.scale, 0, 0)}, 0.2)
            task.wait(0.2)
            currentTabFrame:Destroy()
        end
        
        if tabId == "intro" then
            createIntroTab(contentContainer)
        elseif tabId == "main" then
            createMainTab(contentContainer)
        elseif tabId == "body" then
            createBodyTab(contentContainer)
        end
    end
    
    function createCard(parent, y, height, title, bgColor)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, 0, 0, height * CONFIG.scale)
        card.Position = UDim2.new(0, 0, 0, y * CONFIG.scale)
        card.BackgroundColor3 = bgColor or CONFIG.bgCard
        card.BorderSizePixel = 0
        card.Parent = parent
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 16 * CONFIG.scale)
        
        if title ~= "" then
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
            Instance.new("UICorner", line).CornerRadius = UDim.new(1, 0)
        end
        
        return card
    end
    
    -- ============================================
    -- TAB INTRO (Atualizações)
    -- ============================================
    function createIntroTab(parent)
        local frame = Instance.new("ScrollingFrame")
        frame.Name = "IntroTab"
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.ScrollBarThickness = 4
        frame.ScrollBarImageColor3 = CONFIG.primary
        frame.CanvasSize = UDim2.new(0, 0, 0, 600 * CONFIG.scale)
        frame.Parent = parent
        currentTabFrame = frame
        
        frame.Position = UDim2.new(0, 30 * CONFIG.scale, 0, 0)
        tween(frame, {Position = UDim2.new(0, 0, 0, 0)}, 0.3)
        
        -- Welcome
        local welcomeCard = createCard(frame, 0, 100, "🎉 Bem-vindo", CONFIG.bgElevated)
        
        local welcomeText = Instance.new("TextLabel")
        welcomeText.Size = UDim2.new(1, -30 * CONFIG.scale, 0, 50 * CONFIG.scale)
        welcomeText.Position = UDim2.new(0, 15 * CONFIG.scale, 0, 45 * CONFIG.scale)
        welcomeText.BackgroundTransparency = 1
        welcomeText.Text = "CADUXX137 v10.0 - O mais avançado sistema de reach!"
        welcomeText.TextColor3 = CONFIG.textSecondary
        welcomeText.Font = Enum.Font.GothamBold
        welcomeText.TextSize = 14 * CONFIG.scale
        welcomeText.TextWrapped = true
        welcomeText.Parent = welcomeCard
        
        -- Updates
        local yOffset = 110 * CONFIG.scale
        
        for _, update in ipairs(UPDATES) do
            local updateCard = createCard(frame, yOffset, 140, "📦 " .. update.version .. " - " .. update.date, CONFIG.bgCard)
            
            local changesText = ""
            for _, change in ipairs(update.changes) do
                changesText = changesText .. change .. "\n"
            end
            
            local changesLabel = Instance.new("TextLabel")
            changesLabel.Size = UDim2.new(1, -30 * CONFIG.scale, 0, 90 * CONFIG.scale)
            changesLabel.Position = UDim2.new(0, 15 * CONFIG.scale, 0, 45 * CONFIG.scale)
            changesLabel.BackgroundTransparency = 1
            changesLabel.Text = changesText
            changesLabel.TextColor3 = CONFIG.textMuted
            changesLabel.Font = Enum.Font.Gotham
            changesLabel.TextSize = 12 * CONFIG.scale
            changesLabel.TextWrapped = true
            changesLabel.TextYAlignment = Enum.TextYAlignment.Top
            changesLabel.Parent = updateCard
            
            yOffset = yOffset + 150 * CONFIG.scale
        end
        
        frame.CanvasSize = UDim2.new(0, 0, 0, yOffset + 20)
    end
    
    -- ============================================
    -- TAB MAIN (Reach e Controles)
    -- ============================================
    function createMainTab(parent)
        local frame = Instance.new("Frame")
        frame.Name = "MainTab"
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.Parent = parent
        currentTabFrame = frame
        
        frame.Position = UDim2.new(0, 30 * CONFIG.scale, 0, 0)
        tween(frame, {Position = UDim2.new(0, 0, 0, 0)}, 0.3)
        
        -- Reach Card
        local reachCard = createCard(frame, 0, 130, "🎯 Controle de Alcance", CONFIG.bgElevated)
        
        -- Display
        local reachBg = Instance.new("Frame")
        reachBg.Size = UDim2.new(0, 90 * CONFIG.scale, 0, 55 * CONFIG.scale)
        reachBg.Position = UDim2.new(1, -105 * CONFIG.scale, 0, 45 * CONFIG.scale)
        reachBg.BackgroundColor3 = CONFIG.bgDark
        reachBg.BorderSizePixel = 0
        reachBg.Parent = reachCard
        Instance.new("UICorner", reachBg).CornerRadius = UDim.new(0, 14 * CONFIG.scale)
        
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
        
        -- Botões
        local minusBtn = Instance.new("TextButton")
        minusBtn.Size = UDim2.new(0, 50 * CONFIG.scale, 0, 40 * CONFIG.scale)
        minusBtn.Position = UDim2.new(0, 15 * CONFIG.scale, 0, 50 * CONFIG.scale)
        minusBtn.BackgroundColor3 = CONFIG.bgCard
        minusBtn.Text = "−"
        minusBtn.TextColor3 = CONFIG.textPrimary
        minusBtn.Font = Enum.Font.GothamBlack
        minusBtn.TextSize = 22 * CONFIG.scale
        minusBtn.AutoButtonColor = false
        minusBtn.Parent = reachCard
        Instance.new("UICorner", minusBtn).CornerRadius = UDim.new(0, 10 * CONFIG.scale)
        
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
        Instance.new("UICorner", plusBtn).CornerRadius = UDim.new(0, 10 * CONFIG.scale)
        
        -- Slider
        local sliderBg = Instance.new("Frame")
        sliderBg.Size = UDim2.new(0.45, 0, 0, 8 * CONFIG.scale)
        sliderBg.Position = UDim2.new(0, 15 * CONFIG.scale, 0, 100 * CONFIG.scale)
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
        sliderKnob.Size = UDim2.new(0, 18 * CONFIG.scale, 0, 18 * CONFIG.scale)
        sliderKnob.Position = UDim2.new(CONFIG.reach / 50, -9 * CONFIG.scale, 0.5, -9 * CONFIG.scale)
        sliderKnob.BackgroundColor3 = CONFIG.textPrimary
        sliderKnob.BorderSizePixel = 0
        sliderKnob.Parent = sliderBg
        Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)
        
        -- Toggle Esfera
        local sphereBtn = Instance.new("TextButton")
        sphereBtn.Size = UDim2.new(0, 60 * CONFIG.scale, 0, 28 * CONFIG.scale)
        sphereBtn.Position = UDim2.new(1, -75 * CONFIG.scale, 0, 95 * CONFIG.scale)
        sphereBtn.BackgroundColor3 = CONFIG.showReachSphere and CONFIG.success or CONFIG.bgHover
        sphereBtn.Text = CONFIG.showReachSphere and "ON" or "OFF"
        sphereBtn.TextColor3 = CONFIG.textPrimary
        sphereBtn.Font = Enum.Font.GothamBlack
        sphereBtn.TextSize = 11 * CONFIG.scale
        sphereBtn.AutoButtonColor = false
        sphereBtn.Parent = reachCard
        Instance.new("UICorner", sphereBtn).CornerRadius = UDim.new(0, 14 * CONFIG.scale)
        
        sphereBtn.MouseButton1Click:Connect(function()
            CONFIG.showReachSphere = not CONFIG.showReachSphere
            sphereBtn.Text = CONFIG.showReachSphere and "ON" or "OFF"
            tween(sphereBtn, {BackgroundColor3 = CONFIG.showReachSphere and CONFIG.success or CONFIG.bgHover}, 0.2)
        end)
        
        -- Toggles Card
        local togglesCard = createCard(frame, 140, 180, "⚙️ Configurações", CONFIG.bgCard)
        
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
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 13 * CONFIG.scale)
            
            btn.MouseButton1Click:Connect(function()
                CONFIG[t.key] = not CONFIG[t.key]
                btn.Text = CONFIG[t.key] and "ON" or "OFF"
                tween(btn, {BackgroundColor3 = CONFIG[t.key] and CONFIG.success or CONFIG.bgHover}, 0.2)
            end)
        end
        
        -- Status
        local statusCard = createCard(frame, 330, 70, "📊 Status", CONFIG.bgElevated)
        
        local statusText = Instance.new("TextLabel")
        statusText.Size = UDim2.new(1, -30 * CONFIG.scale, 0, 30 * CONFIG.scale)
        statusText.Position = UDim2.new(0, 15 * CONFIG.scale, 0, 40 * CONFIG.scale)
        statusText.BackgroundTransparency = 1
        statusText.Text = "🟢 Sistema Ativo | " .. #balls .. " bolas"
        statusText.TextColor3 = CONFIG.success
        statusText.Font = Enum.Font.GothamBold
        statusText.TextSize = 13 * CONFIG.scale
        statusText.Parent = statusCard
        
        -- Eventos Reach
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
    
    -- ============================================
    -- TAB BODY (Partes do Corpo)
    -- ============================================
    function createBodyTab(parent)
        local frame = Instance.new("ScrollingFrame")
        frame.Name = "BodyTab"
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.ScrollBarThickness = 4
        frame.ScrollBarImageColor3 = CONFIG.primary
        frame.CanvasSize = UDim2.new(0, 0, 0, 800 * CONFIG.scale)
        frame.Parent = parent
        currentTabFrame = frame
        
        frame.Position = UDim2.new(0, 30 * CONFIG.scale, 0, 0)
        tween(frame, {Position = UDim2.new(0, 0, 0, 0)}, 0.3)
        
        -- Info
        local infoCard = createCard(frame, 0, 70, "💡 Dica", CONFIG.bgElevated)
        
        local infoText = Instance.new("TextLabel")
        infoText.Size = UDim2.new(1, -30 * CONFIG.scale, 0, 40 * CONFIG.scale)
        infoText.Position = UDim2.new(0, 15 * CONFIG.scale, 0, 35 * CONFIG.scale)
        infoText.BackgroundTransparency = 1
        infoText.Text = "Selecione onde o reach será aplicado no seu personagem"
        infoText.TextColor3 = CONFIG.textSecondary
        infoText.Font = Enum.Font.GothamBold
        infoText.TextSize = 12 * CONFIG.scale
        infoText.TextWrapped = true
        infoText.Parent = infoCard
        
        -- Partes do corpo
        local yOffset = 80 * CONFIG.scale
        local parts = {
            {name = "HumanoidRootPart", display = "📍 Centro (HRP)"},
            {name = "Head", display = "🎲 Cabeça"},
            {name = "LeftUpperArm", display = "💪 Braço Esq (Cima)"},
            {name = "RightUpperArm", display = "💪 Braço Dir (Cima)"},
            {name = "LeftLowerArm", display = "🦾 Braço Esq (Baixo)"},
            {name = "RightLowerArm", display = "🦾 Braço Dir (Baixo)"},
            {name = "LeftHand", display = "✋ Mão Esquerda"},
            {name = "RightHand", display = "✋ Mão Direita"},
            {name = "LeftUpperLeg", display = "🦵 Perna Esq (Cima)"},
            {name = "RightUpperLeg", display = "🦵 Perna Dir (Cima)"},
            {name = "LeftLowerLeg", display = "🦿 Perna Esq (Baixo)"},
            {name = "RightLowerLeg", display = "🦿 Perna Dir (Baixo)"},
            {name = "LeftFoot", display = "🦶 Pé Esquerdo"},
            {name = "RightFoot", display = "🦶 Pé Direito"}
        }
        
        for _, part in ipairs(parts) do
            local card = createCard(frame, yOffset, 55, "", CONFIG.bgCard)
            
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
            toggle.Text = CONFIG.bodyParts[part.name] and "✓" or ""
            toggle.TextColor3 = CONFIG.textPrimary
            toggle.Font = Enum.Font.GothamBlack
            toggle.TextSize = 16 * CONFIG.scale
            toggle.AutoButtonColor = false
            toggle.Parent = card
            Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 10 * CONFIG.scale)
            
            toggle.MouseButton1Click:Connect(function()
                CONFIG.bodyParts[part.name] = not CONFIG.bodyParts[part.name]
                toggle.BackgroundColor3 = CONFIG.bodyParts[part.name] and CONFIG.success or CONFIG.bgHover
                toggle.Text = CONFIG.bodyParts[part.name] and "✓" or ""
                notify("CADUXX137", part.display .. (CONFIG.bodyParts[part.name] and " ✓" or " ✗"), 1)
            end)
            
            yOffset = yOffset + 65 * CONFIG.scale
        end
        
        -- Presets
        local presetCard = createCard(frame, yOffset + 10, 160, "⚡ Presets Rápidos", CONFIG.bgElevated)
        
        local presets = {
            {name = "🦶 Apenas Pés", fn = function()
                for k, _ in pairs(CONFIG.bodyParts) do CONFIG.bodyParts[k] = false end
                CONFIG.bodyParts.LeftFoot = true
                CONFIG.bodyParts.RightFoot = true
                switchTab("body")
            end},
            {name = "✋ Apenas Mãos", fn = function()
                for k, _ in pairs(CONFIG.bodyParts) do CONFIG.bodyParts[k] = false end
                CONFIG.bodyParts.LeftHand = true
                CONFIG.bodyParts.RightHand = true
                switchTab("body")
            end},
            {name = "🦵 Pernas Completas", fn = function()
                for k, _ in pairs(CONFIG.bodyParts) do CONFIG.bodyParts[k] = false end
                CONFIG.bodyParts.LeftUpperLeg = true
                CONFIG.bodyParts.LeftLowerLeg = true
                CONFIG.bodyParts.LeftFoot = true
                CONFIG.bodyParts.RightUpperLeg = true
                CONFIG.bodyParts.RightLowerLeg = true
                CONFIG.bodyParts.RightFoot = true
                switchTab("body")
            end},
            {name = "📍 Resetar (HRP)", fn = function()
                for k, _ in pairs(CONFIG.bodyParts) do CONFIG.bodyParts[k] = false end
                CONFIG.bodyParts.HumanoidRootPart = true
                switchTab("body")
            end}
        }
        
        for i, preset in ipairs(presets) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.45, -5 * CONFIG.scale, 0, 35 * CONFIG.scale)
            btn.Position = UDim2.new(i % 2 == 1 and 0 or 0.5, i % 2 == 1 and 15 * CONFIG.scale or 5 * CONFIG.scale, 
                0, 45 + (math.floor((i-1)/2) * 40) * CONFIG.scale)
            btn.BackgroundColor3 = CONFIG.primary
            btn.BackgroundTransparency = 0.3
            btn.Text = preset.name
            btn.TextColor3 = CONFIG.textPrimary
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 11 * CONFIG.scale
            btn.AutoButtonColor = false
            btn.Parent = presetCard
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10 * CONFIG.scale)
            
            btn.MouseButton1Click:Connect(function()
                preset.fn()
                notify("CADUXX137", "Preset aplicado!", 2)
            end)
        end
        
        frame.CanvasSize = UDim2.new(0, 0, 0, yOffset + 180)
    end
    
    -- Iniciar
    switchTab(CONFIG.currentTab)
    
    -- Eventos
    minimizeBtn.MouseEnter:Connect(function()
        tween(minimizeBtn, {BackgroundColor3 = CONFIG.primary}, 0.2)
    end)
    minimizeBtn.MouseLeave:Connect(function()
        tween(minimizeBtn, {BackgroundColor3 = CONFIG.bgElevated}, 0.2)
    end)
    
    minimizeBtn.MouseButton1Click:Connect(function()
        isMinimized = true
        tween(main, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
        task.wait(0.3)
        mainGui:Destroy()
        createIconButton()
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        tween(main, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
        task.wait(0.3)
        mainGui:Destroy()
        if reachSphere then reachSphere:Destroy() end
    end)
    
    makeDraggable(main, header)
    
    main.Size = UDim2.new(0, 0, 0, 0)
    tween(main, {Size = UDim2.new(0, W, 0, H)}, 0.5, Enum.EasingStyle.Back)
    
    notify("⚡ CADUXX137 v10.0", "Premium Edition carregada!", 3)
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

-- Iniciar
createMainGUI()
