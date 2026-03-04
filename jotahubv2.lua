-- ============================================
-- CADUXX137 v12.0 - WindUI Edition
-- Lógica Original + Interface Moderna
-- ============================================

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
-- CONFIGURAÇÕES (Suas originais preservadas)
-- ============================================
local CONFIG = {
    reach = 15,
    showReachSphere = true,
    autoTouch = true,
    fullBodyTouch = true,
    autoSecondTouch = true,
    scanCooldown = 1.5,
    scale = 1.0,
    
    -- Suas imagens
    iconImage = "rbxassetid://104616032736993",
    iconBackground = "rbxassetid://96755648876012",
    
    -- Suas bolas
    ballNames = { 
        "TPS", "TCS", "ESA", "MRS", "PRS", "MPS", "SSS", "AIFA", "RBZ",
        "Ball", "Soccer", "Football", "Basketball", "Baseball", 
        "BallTemplate", "GameBall", "Hitbox", "TouchPart", "GoalBall"
    },
    
    -- Cores WindUI Inspired
    primary = Color3.fromRGB(99, 102, 241),
    secondary = Color3.fromRGB(139, 92, 246),
    accent = Color3.fromRGB(14, 165, 233),
    success = Color3.fromRGB(34, 197, 94),
    danger = Color3.fromRGB(239, 68, 68),
    warning = Color3.fromRGB(245, 158, 11),
    
    bgDark = Color3.fromRGB(15, 15, 25),
    bgCard = Color3.fromRGB(30, 30, 45),
    bgElevated = Color3.fromRGB(45, 45, 65),
    bgGlass = Color3.fromRGB(25, 25, 40),
    
    textPrimary = Color3.fromRGB(250, 250, 255),
    textSecondary = Color3.fromRGB(160, 170, 200),
    textMuted = Color3.fromRGB(120, 130, 160)
}

-- Variáveis globais (suas originais)
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
local currentTab = "reach"
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

-- ============================================
-- UTILITÁRIOS (Melhorados visualmente)
-- ============================================

local function notify(title, text, duration, type)
    duration = duration or 3
    type = type or "info"
    
    local color = CONFIG.accent
    if type == "success" then color = CONFIG.success
    elseif type == "warning" then color = CONFIG.warning
    elseif type == "error" then color = CONFIG.danger end
    
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "CADUXX137",
            Text = text or "",
            Duration = duration,
            Icon = CONFIG.iconImage
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
-- SISTEMA DE ÍCONE (WindUI Style)
-- ============================================

local function createIconButton()
    if iconGui then iconGui:Destroy() end
    
    iconGui = Instance.new("ScreenGui")
    iconGui.Name = "CADU_Icon_v12"
    iconGui.ResetOnSpawn = false
    iconGui.DisplayOrder = 999999
    iconGui.Parent = playerGui
    
    local iconSize = 65 * CONFIG.scale
    
    local mainBtn = Instance.new("ImageButton")
    mainBtn.Name = "IconButton"
    mainBtn.Size = UDim2.new(0, iconSize, 0, iconSize)
    mainBtn.Position = UDim2.new(0.5, -iconSize/2, 0.85, 0)
    mainBtn.BackgroundTransparency = 1
    mainBtn.Image = CONFIG.iconBackground
    mainBtn.ImageColor3 = Color3.new(1, 1, 1)
    mainBtn.ScaleType = Enum.ScaleType.Stretch
    mainBtn.Parent = iconGui
    
    Instance.new("UICorner", mainBtn).CornerRadius = UDim.new(1, 0)
    
    -- Glow suave
    local glow = Instance.new("ImageLabel")
    glow.Size = UDim2.new(1.4, 0, 1.4, 0)
    glow.Position = UDim2.new(-0.2, 0, -0.2, 0)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://96755648876012"
    glow.ImageColor3 = CONFIG.primary
    glow.ImageTransparency = 0.7
    glow.ZIndex = -1
    glow.Parent = mainBtn
    
    -- Ícone interno
    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0.5, 0, 0.5, 0)
    icon.Position = UDim2.new(0.25, 0, 0.25, 0)
    icon.BackgroundTransparency = 1
    icon.Image = CONFIG.iconImage
    icon.ImageColor3 = CONFIG.textPrimary
    icon.Parent = mainBtn
    
    -- Animação de rotação do glow
    task.spawn(function()
        while glow and glow.Parent do
            tween(glow, {Rotation = glow.Rotation + 360}, 10, Enum.EasingStyle.Linear)
            task.wait(10)
        end
    end)
    
    -- Hover
    mainBtn.MouseEnter:Connect(function()
        tween(mainBtn, {Size = UDim2.new(0, iconSize * 1.1, 0, iconSize * 1.1)}, 0.3, Enum.EasingStyle.Back)
        tween(glow, {ImageTransparency = 0.4}, 0.3)
        tween(icon, {Rotation = 15}, 0.3, Enum.EasingStyle.Back)
    end)
    
    mainBtn.MouseLeave:Connect(function()
        tween(mainBtn, {Size = UDim2.new(0, iconSize, 0, iconSize)}, 0.3, Enum.EasingStyle.Back)
        tween(glow, {ImageTransparency = 0.7}, 0.3)
        tween(icon, {Rotation = 0}, 0.3, Enum.EasingStyle.Back)
    end)
    
    -- Clique
    mainBtn.MouseButton1Click:Connect(function()
        tween(mainBtn, {Size = UDim2.new(0, 0, 0, 0), Rotation = 360}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.4)
        iconGui:Destroy()
        iconGui = nil
        isMinimized = false
        createMainGUI()
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
    
    -- Entrada
    mainBtn.Size = UDim2.new(0, 0, 0, 0)
    tween(mainBtn, {Size = UDim2.new(0, iconSize, 0, iconSize)}, 0.5, Enum.EasingStyle.Back)
    
    notify("CADUXX137 v12", "Clique no ícone para abrir", 3)
end

-- ============================================
-- INTERFACE PRINCIPAL (WindUI Design)
-- ============================================

function createMainGUI()
    pcall(function()
        for _, v in pairs(playerGui:GetChildren()) do
            if v.Name:find("CADU") then v:Destroy() end
        end
    end)
    
    mainGui = Instance.new("ScreenGui")
    mainGui.Name = "CADU_Main_v12"
    mainGui.ResetOnSpawn = false
    mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    mainGui.Parent = playerGui
    
    local W, H = 480 * CONFIG.scale, 420 * CONFIG.scale
    
    -- Frame principal com Glass effect
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, W, 0, H)
    main.Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
    main.BackgroundColor3 = CONFIG.bgDark
    main.BackgroundTransparency = 0.1
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = mainGui
    
    -- Bordas arredondadas grandes (WindUI style)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 24 * CONFIG.scale)
    corner.Parent = main
    
    -- Stroke sutil
    local stroke = Instance.new("UIStroke")
    stroke.Color = CONFIG.primary
    stroke.Transparency = 0.6
    stroke.Thickness = 1.5 * CONFIG.scale
    stroke.Parent = main
    
    -- Sombra soft
    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, 60 * CONFIG.scale, 1, 60 * CONFIG.scale)
    shadow.Position = UDim2.new(0, -30 * CONFIG.scale, 0, -30 * CONFIG.scale)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://131296141"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.ZIndex = -1
    shadow.Parent = main
    
    -- Sidebar (estilo WindUI)
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 70 * CONFIG.scale, 1, 0)
    sidebar.BackgroundColor3 = CONFIG.bgCard
    sidebar.BackgroundTransparency = 0.2
    sidebar.BorderSizePixel = 0
    sidebar.Parent = main
    
    local sidebarCorner = Instance.new("UICorner")
    sidebarCorner.CornerRadius = UDim.new(0, 24 * CONFIG.scale)
    sidebarCorner.Parent = sidebar
    
    -- Logo na sidebar
    local logoContainer = Instance.new("Frame")
    logoContainer.Size = UDim2.new(0, 45 * CONFIG.scale, 0, 45 * CONFIG.scale)
    logoContainer.Position = UDim2.new(0.5, -22.5 * CONFIG.scale, 0, 20 * CONFIG.scale)
    logoContainer.BackgroundColor3 = CONFIG.bgElevated
    logoContainer.BackgroundTransparency = 0.3
    logoContainer.BorderSizePixel = 0
    logoContainer.Parent = sidebar
    
    Instance.new("UICorner", logoContainer).CornerRadius = UDim.new(1, 0)
    
    local logo = Instance.new("ImageLabel")
    logo.Size = UDim2.new(0.6, 0, 0.6, 0)
    logo.Position = UDim2.new(0.2, 0, 0.2, 0)
    logo.BackgroundTransparency = 1
    logo.Image = CONFIG.iconImage
    logo.ImageColor3 = CONFIG.textPrimary
    logo.Parent = logoContainer
    
    -- Botões de navegação (ícones)
    local tabs = {
        {id = "reach", icon = "⚡", y = 90},
        {id = "balls", icon = "🔮", y = 150},
        {id = "controls", icon = "🎮", y = 210},
        {id = "settings", icon = "⚙️", y = 270}
    }
    
    local tabButtons = {}
    
    for _, tab in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Name = tab.id .. "Btn"
        btn.Size = UDim2.new(0, 50 * CONFIG.scale, 0, 50 * CONFIG.scale)
        btn.Position = UDim2.new(0.5, -25 * CONFIG.scale, 0, tab.y * CONFIG.scale)
        btn.BackgroundColor3 = (tab.id == currentTab) and CONFIG.primary or CONFIG.bgElevated
        btn.BackgroundTransparency = (tab.id == currentTab) and 0.2 or 0.5
        btn.Text = tab.icon
        btn.TextColor3 = (tab.id == currentTab) and CONFIG.textPrimary or CONFIG.textMuted
        btn.Font = Enum.Font.GothamBlack
        btn.TextSize = 24 * CONFIG.scale
        btn.AutoButtonColor = false
        btn.Parent = sidebar
        
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 14 * CONFIG.scale)
        
        tabButtons[tab.id] = btn
        
        -- Seleção
        btn.MouseButton1Click:Connect(function()
            if currentTab == tab.id then return end
            
            -- Desativar anterior
            local prev = tabButtons[currentTab]
            tween(prev, {BackgroundColor3 = CONFIG.bgElevated}, 0.3)
            tween(prev, {BackgroundTransparency = 0.5}, 0.3)
            tween(prev, {TextColor3 = CONFIG.textMuted}, 0.3)
            
            -- Ativar novo
            currentTab = tab.id
            tween(btn, {BackgroundColor3 = CONFIG.primary}, 0.3)
            tween(btn, {BackgroundTransparency = 0.2}, 0.3)
            tween(btn, {TextColor3 = CONFIG.textPrimary}, 0.3)
            
            updateContent()
        end)
        
        -- Hover
        if tab.id ~= currentTab then
            btn.MouseEnter:Connect(function()
                tween(btn, {BackgroundTransparency = 0.3}, 0.2)
            end)
            btn.MouseLeave:Connect(function()
                tween(btn, {BackgroundTransparency = 0.5}, 0.2)
            end)
        end
    end
    
    -- Botão fechar/minimizar na sidebar
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 40 * CONFIG.scale, 0, 40 * CONFIG.scale)
    closeBtn.Position = UDim2.new(0.5, -20 * CONFIG.scale, 1, -60 * CONFIG.scale)
    closeBtn.BackgroundColor3 = CONFIG.danger
    closeBtn.BackgroundTransparency = 0.3
    closeBtn.Text = "×"
    closeBtn.TextColor3 = CONFIG.textPrimary
    closeBtn.Font = Enum.Font.GothamBlack
    closeBtn.TextSize = 20 * CONFIG.scale
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = sidebar
    
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)
    
    closeBtn.MouseButton1Click:Connect(function()
        tween(main, {Size = UDim2.new(0, 0, 0, 0)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.4)
        mainGui:Destroy()
        mainGui = nil
        isMinimized = true
        createIconButton()
    end)
    
    -- Área de conteúdo
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -90 * CONFIG.scale, 1, -40 * CONFIG.scale)
    content.Position = UDim2.new(0, 80 * CONFIG.scale, 0, 20 * CONFIG.scale)
    content.BackgroundTransparency = 1
    content.ClipsDescendants = true
    content.Parent = main
    
    -- Título da seção
    local sectionTitle = Instance.new("TextLabel")
    sectionTitle.Name = "Title"
    sectionTitle.Size = UDim2.new(1, 0, 0, 40 * CONFIG.scale)
    sectionTitle.BackgroundTransparency = 1
    sectionTitle.Text = "Alcance"
    sectionTitle.TextColor3 = CONFIG.textPrimary
    sectionTitle.Font = Enum.Font.GothamBlack
    sectionTitle.TextSize = 28 * CONFIG.scale
    sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    sectionTitle.Parent = content
    
    -- Container de conteúdo dinâmico
    local dynamicContent = Instance.new("Frame")
    dynamicContent.Name = "Dynamic"
    dynamicContent.Size = UDim2.new(1, 0, 1, -50 * CONFIG.scale)
    dynamicContent.Position = UDim2.new(0, 0, 0, 50 * CONFIG.scale)
    dynamicContent.BackgroundTransparency = 1
    dynamicContent.Parent = content
    
    -- Função para criar cards glass
    local function createCard(parent, y, h, title)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, 0, 0, h * CONFIG.scale)
        card.Position = UDim2.new(0, 0, 0, y * CONFIG.scale)
        card.BackgroundColor3 = CONFIG.bgCard
        card.BackgroundTransparency = 0.15
        card.BorderSizePixel = 0
        card.Parent = parent
        
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 16 * CONFIG.scale)
        
        if title then
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -20, 0, 30)
            lbl.Position = UDim2.new(0, 15, 0, 12)
            lbl.BackgroundTransparency = 1
            lbl.Text = title
            lbl.TextColor3 = CONFIG.textSecondary
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 13 * CONFIG.scale
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = card
        end
        
        return card
    end
    
    -- Toggle moderno
    local function createToggle(parent, x, y, state, label)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(0, 50 * CONFIG.scale, 0, 28 * CONFIG.scale)
        container.Position = UDim2.new(0, x * CONFIG.scale, 0, y * CONFIG.scale)
        container.BackgroundColor3 = state and CONFIG.success or CONFIG.bgElevated
        container.BackgroundTransparency = 0.2
        container.BorderSizePixel = 0
        container.Parent = parent
        
        Instance.new("UICorner", container).CornerRadius = UDim.new(0, 14 * CONFIG.scale)
        
        local circle = Instance.new("Frame")
        circle.Size = UDim2.new(0, 22 * CONFIG.scale, 0, 22 * CONFIG.scale)
        circle.Position = state and UDim2.new(1, -25 * CONFIG.scale, 0, 3 * CONFIG.scale) or UDim2.new(0, 3 * CONFIG.scale, 0, 3 * CONFIG.scale)
        circle.BackgroundColor3 = CONFIG.textPrimary
        circle.BorderSizePixel = 0
        circle.Parent = container
        
        Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
        
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0, 200, 0, 28)
        lbl.Position = UDim2.new(0, (x + 60) * CONFIG.scale, 0, y * CONFIG.scale)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.TextColor3 = CONFIG.textSecondary
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 13 * CONFIG.scale
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = parent
        
        local click = Instance.new("TextButton")
        click.Size = UDim2.new(0, 260 * CONFIG.scale, 0, 28 * CONFIG.scale)
        click.Position = UDim2.new(0, x * CONFIG.scale, 0, y * CONFIG.scale)
        click.BackgroundTransparency = 1
        click.Text = ""
        click.Parent = parent
        
        local current = state
        
        local function update()
            local pos = current and UDim2.new(1, -25 * CONFIG.scale, 0, 3 * CONFIG.scale) or UDim2.new(0, 3 * CONFIG.scale, 0, 3 * CONFIG.scale)
            local col = current and CONFIG.success or CONFIG.bgElevated
            tween(circle, {Position = pos}, 0.3, Enum.EasingStyle.Back)
            tween(container, {BackgroundColor3 = col}, 0.3)
        end
        
        click.MouseButton1Click:Connect(function()
            current = not current
            update()
            return current
        end)
        
        return {
            get = function() return current end,
            set = function(v) current = v update() end,
            container = container
        }
    end
    
    -- Slider premium
    local function createSlider(parent, x, y, min, max, val, label)
        local track = Instance.new("Frame")
        track.Size = UDim2.new(0, 200 * CONFIG.scale, 0, 6 * CONFIG.scale)
        track.Position = UDim2.new(0, x * CONFIG.scale, 0, (y + 25) * CONFIG.scale)
        track.BackgroundColor3 = CONFIG.bgElevated
        track.BackgroundTransparency = 0.3
        track.BorderSizePixel = 0
        track.Parent = parent
        
        Instance.new("UICorner", track).CornerRadius = UDim.new(0, 3 * CONFIG.scale)
        
        local fill = Instance.new("Frame")
        local pct = (val - min) / (max - min)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        fill.BackgroundColor3 = CONFIG.primary
        fill.BorderSizePixel = 0
        fill.Parent = track
        
        Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3 * CONFIG.scale)
        
        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 16 * CONFIG.scale, 0, 16 * CONFIG.scale)
        knob.Position = UDim2.new(pct, -8 * CONFIG.scale, 0.5, -8 * CONFIG.scale)
        knob.BackgroundColor3 = CONFIG.textPrimary
        knob.BorderSizePixel = 0
        knob.ZIndex = 2
        knob.Parent = track
        
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
        
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 20)
        lbl.Position = UDim2.new(0, x * CONFIG.scale, 0, y * CONFIG.scale)
        lbl.BackgroundTransparency = 1
        lbl.Text = label .. ": " .. val
        lbl.TextColor3 = CONFIG.textSecondary
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 12 * CONFIG.scale
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = parent
        
        local dragging = false
        
        local function update(input)
            local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local v = math.floor(min + (max - min) * rel)
            tween(fill, {Size = UDim2.new(rel, 0, 1, 0)}, 0.1)
            tween(knob, {Position = UDim2.new(rel, -8 * CONFIG.scale, 0.5, -8 * CONFIG.scale)}, 0.1)
            lbl.Text = label .. ": " .. v
            return v
        end
        
        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                return update(input)
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                return update(input)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        
        return {
            get = function() return tonumber(lbl.Text:match("%d+")) end,
            set = function(v)
                local rel = (v - min) / (max - min)
                tween(fill, {Size = UDim2.new(rel, 0, 1, 0)}, 0.2)
                tween(knob, {Position = UDim2.new(rel, -8 * CONFIG.scale, 0.5, -8 * CONFIG.scale)}, 0.2)
                lbl.Text = label .. ": " .. v
            end
        }
    end
    
    -- Atualização de conteúdo
    function updateContent()
        -- Limpar
        for _, c in ipairs(dynamicContent:GetChildren()) do
            c:Destroy()
        end
        
        if currentTab == "reach" then
            sectionTitle.Text = "Alcance"
            
            -- Card principal
            local card = createCard(dynamicContent, 0, 140, "DISTÂNCIA")
            
            -- Display grande
            local disp = Instance.new("TextLabel")
            disp.Size = UDim2.new(0.5, 0, 0, 60 * CONFIG.scale)
            disp.Position = UDim2.new(0.5, 0, 0, 40 * CONFIG.scale)
            disp.BackgroundTransparency = 1
            disp.Text = tostring(CONFIG.reach)
            disp.TextColor3 = CONFIG.primary
            disp.Font = Enum.Font.GothamBlack
            disp.TextSize = 48 * CONFIG.scale
            disp.Parent = card
            
            local unit = Instance.new("TextLabel")
            unit.Size = UDim2.new(0.2, 0, 0, 20)
            unit.Position = UDim2.new(0.8, 0, 0, 65 * CONFIG.scale)
            unit.BackgroundTransparency = 1
            unit.Text = "studs"
            unit.TextColor3 = CONFIG.textMuted
            unit.Font = Enum.Font.Gotham
            unit.TextSize = 12 * CONFIG.scale
            unit.Parent = card
            
            -- Slider
            local slider = createSlider(card, 20, 90, 1, 50, CONFIG.reach, "Alcance")
            
            -- Botões rápidos
            local btns = {{"−", -1}, {"+", 1}, {"MAX", 50}}
            for i, b in ipairs(btns) do
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(0, 45 * CONFIG.scale, 0, 35 * CONFIG.scale)
                btn.Position = UDim2.new(0, 20 + (i-1)*55 * CONFIG.scale, 0, 45 * CONFIG.scale)
                btn.BackgroundColor3 = CONFIG.bgElevated
                btn.BackgroundTransparency = 0.3
                btn.Text = b[1]
                btn.TextColor3 = CONFIG.textPrimary
                btn.Font = Enum.Font.GothamBlack
                btn.TextSize = 18 * CONFIG.scale
                btn.AutoButtonColor = false
                btn.Parent = card
                
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10 * CONFIG.scale)
                
                btn.MouseButton1Click:Connect(function()
                    if b[1] == "MAX" then
                        CONFIG.reach = 50
                    else
                        CONFIG.reach = math.clamp(CONFIG.reach + b[2], 1, 50)
                    end
                    slider.set(CONFIG.reach)
                    disp.Text = tostring(CONFIG.reach)
                end)
            end
            
            -- Toggle esfera
            local sphereCard = createCard(dynamicContent, 150, 80, "VISUALIZAÇÃO")
            local sphereToggle = createToggle(sphereCard, 20, 40, CONFIG.showReachSphere, "Mostrar Esfera")
            
        elseif currentTab == "balls" then
            sectionTitle.Text = "Bolas"
            
            local card = createCard(dynamicContent, 0, 280, "DETECTADAS")
            
            local count = Instance.new("TextLabel")
            count.Size = UDim2.new(1, 0, 0, 40)
            count.Position = UDim2.new(0, 0, 0, 40 * CONFIG.scale)
            count.BackgroundTransparency = 1
            count.Text = tostring(#balls) .. " bolas ativas"
            count.TextColor3 = #balls > 0 and CONFIG.success or CONFIG.warning
            count.Font = Enum.Font.GothamBlack
            count.TextSize = 24 * CONFIG.scale
            count.Parent = card
            
            -- Lista scrollável
            local list = Instance.new("ScrollingFrame")
            list.Size = UDim2.new(1, -30 * CONFIG.scale, 0, 180 * CONFIG.scale)
            list.Position = UDim2.new(0, 15 * CONFIG.scale, 0, 80 * CONFIG.scale)
            list.BackgroundColor3 = CONFIG.bgDark
            list.BackgroundTransparency = 0.5
            list.BorderSizePixel = 0
            list.ScrollBarThickness = 4
            list.CanvasSize = UDim2.new(0, 0, 0, 0)
            list.Parent = card
            
            Instance.new("UICorner", list).CornerRadius = UDim.new(0, 12 * CONFIG.scale)
            
            local y = 10
            local unique = {}
            for _, b in ipairs(balls) do
                if b and b.Parent then
                    unique[b.Name] = (unique[b.Name] or 0) + 1
                end
            end
            
            for name, c in pairs(unique) do
                local item = Instance.new("Frame")
                item.Size = UDim2.new(1, -20, 0, 35 * CONFIG.scale)
                item.Position = UDim2.new(0, 10, 0, y)
                item.BackgroundColor3 = CONFIG.bgCard
                item.BackgroundTransparency = 0.3
                item.Parent = list
                
                Instance.new("UICorner", item).CornerRadius = UDim.new(0, 8 * CONFIG.scale)
                
                local nl = Instance.new("TextLabel")
                nl.Size = UDim2.new(0.7, 0, 1, 0)
                nl.Position = UDim2.new(0, 10, 0, 0)
                nl.BackgroundTransparency = 1
                nl.Text = name
                nl.TextColor3 = CONFIG.accent
                nl.Font = Enum.Font.GothamBold
                nl.TextSize = 12 * CONFIG.scale
                nl.Parent = item
                
                local cl = Instance.new("TextLabel")
                cl.Size = UDim2.new(0.3, -10, 1, 0)
                cl.Position = UDim2.new(0.7, 0, 0, 0)
                cl.BackgroundTransparency = 1
                cl.Text = "x" .. c
                cl.TextColor3 = CONFIG.textMuted
                cl.Font = Enum.Font.GothamBold
                cl.TextSize = 12 * CONFIG.scale
                cl.TextXAlignment = Enum.TextXAlignment.Right
                cl.Parent = item
                
                y = y + 40
            end
            
            list.CanvasSize = UDim2.new(0, 0, 0, math.max(y, 180))
            
        elseif currentTab == "controls" then
            sectionTitle.Text = "Controles"
            
            local card = createCard(dynamicContent, 0, 200, "AUTOMAÇÃO")
            local autoToggle = createToggle(card, 20, 45, CONFIG.autoTouch, "Auto Touch")
            local bodyToggle = createToggle(card, 20, 85, CONFIG.fullBodyTouch, "Full Body")
            local secondToggle = createToggle(card, 20, 125, CONFIG.autoSecondTouch, "Double Touch")
            
            local skillsCard = createCard(dynamicContent, 210, 80, "SKILLS")
            local skillsToggle = createToggle(skillsCard, 20, 40, autoSkills, "Auto Skills")
            
        elseif currentTab == "settings" then
            sectionTitle.Text = "Ajustes"
            
            local card = createCard(dynamicContent, 0, 120, "INTERFACE")
            local scaleSlider = createSlider(card, 20, 50, 0.5, 1.5, CONFIG.scale, "Escala")
            
            local resetCard = createCard(dynamicContent, 130, 80, "SISTEMA")
            local resetBtn = Instance.new("TextButton")
            resetBtn.Size = UDim2.new(0, 140 * CONFIG.scale, 0, 40 * CONFIG.scale)
            resetBtn.Position = UDim2.new(0.5, -70 * CONFIG.scale, 0, 40 * CONFIG.scale)
            resetBtn.BackgroundColor3 = CONFIG.danger
            resetBtn.BackgroundTransparency = 0.2
            resetBtn.Text = "RESETAR"
            resetBtn.TextColor3 = CONFIG.textPrimary
            resetBtn.Font = Enum.Font.GothamBlack
            resetBtn.TextSize = 14 * CONFIG.scale
            resetBtn.AutoButtonColor = false
            resetBtn.Parent = resetCard
            
            Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0, 12 * CONFIG.scale)
            
            resetBtn.MouseButton1Click:Connect(function()
                CONFIG.reach = 15
                CONFIG.showReachSphere = true
                CONFIG.autoTouch = true
                CONFIG.fullBodyTouch = true
                CONFIG.autoSecondTouch = true
                CONFIG.scale = 1.0
                notify("CADUXX137", "Resetado!", 2)
                createMainGUI()
            end)
        end
    end
    
    -- Draggable
    local dragging = false
    local dragStart, startPos
    
    main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)
    
    main.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    -- Animação de entrada
    main.Size = UDim2.new(0, 0, 0, 0)
    tween(main, {Size = UDim2.new(0, W, 0, H)}, 0.6, Enum.EasingStyle.Back)
    
    updateContent()
    notify("CADUXX137 v12", "WindUI Edition ativada!", 3)
end

-- ============================================
-- LÓGICA ORIGINAL PRESERVADA (100% sua)
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
            if HRP then
                notify("Personagem", "Sistema ativo!", 2, "success")
            end
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
        if button:IsA("GuiButton") then
            for _, conn in ipairs(getconnections(button.MouseButton1Click)) do
                conn:Fire()
            end
            for _, conn in ipairs(getconnections(button.Activated)) do
                conn:Fire()
            end
        end
    end)
end

-- ============================================
-- LOOP PRINCIPAL (Seu código original)
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
            if button.Name == "Shoot" or button.Name == "Pass" or button.Name == "Dribble" then
                activateSkillButton(button)
            end
        end
    end
end)

-- ============================================
-- INICIALIZAÇÃO
-- ============================================

createMainGUI()
