--[[
    CAFUXZ1 Loader v1.1 - Sistema Completo
    ======================================
    1. Loading Screen (com avatar do jogador)
    2. Key System (Key: CADUCOSXZ)
    3. Loading Final
    4. Hub CAFUXZ1
    
    Otimizações:
    - Imagens carregadas uma única vez
    - TweenService em vez de while true
    - Código modular e limpo
]]

if not game:IsLoaded() then game.Loaded:Wait() end

-- ============================================
-- SERVIÇOS
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ============================================
-- CONFIGURAÇÕES
-- ============================================
local CONFIG = {
    key = "CADUCOSXZ", -- KEY CORRETA
    scriptUrl = "https://raw.githubusercontent.com/Meunicke/jota-hub-11/refs/heads/main/TitaniumHub_CADU_Standalone.lua",
    colors = {
        primary = Color3.fromRGB(99, 102, 241),
        secondary = Color3.fromRGB(139, 92, 246),
        accent = Color3.fromRGB(14, 165, 233),
        dark = Color3.fromRGB(12, 12, 20),
        darker = Color3.fromRGB(8, 8, 15),
        success = Color3.fromRGB(34, 197, 94),
        danger = Color3.fromRGB(239, 68, 68),
        text = Color3.fromRGB(252, 252, 255)
    },
    avatarSize = 150,
    loadingDuration = 3
}

-- ============================================
-- FUNÇÕES UTILITÁRIAS
-- ============================================
local function tween(obj, props, time, easing, direction)
    time = time or 0.5
    easing = easing or Enum.EasingStyle.Quint
    direction = direction or Enum.EasingDirection.Out
    local info = TweenInfo.new(time, easing, direction)
    return TweenService:Create(obj, info, props)
end

local function createUICorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or UDim.new(0, 12)
    corner.Parent = parent
    return corner
end

local function createUIStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or CONFIG.colors.primary
    stroke.Thickness = thickness or 2
    stroke.Parent = parent
    return stroke
end

-- ============================================
-- SISTEMA DE LOADING SCREEN
-- ============================================
local LoadingSystem = {}

function LoadingSystem:createScreen()
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui.Name:find("CAFUXZ1") or gui.Name:find("Loading") then
            gui:Destroy()
        end
    end
    
    local screen = Instance.new("ScreenGui")
    screen.Name = "CAFUXZ1_Loading"
    screen.ResetOnSpawn = false
    screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screen.Parent = PlayerGui
    
    return screen
end

function LoadingSystem:createBackground(parent)
    local bg = Instance.new("Frame")
    bg.Name = "Background"
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = CONFIG.colors.darker
    bg.BorderSizePixel = 0
    bg.Parent = parent
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, CONFIG.colors.darker),
        ColorSequenceKeypoint.new(0.5, CONFIG.colors.dark),
        ColorSequenceKeypoint.new(1, CONFIG.colors.darker)
    })
    gradient.Rotation = 45
    gradient.Parent = bg
    
    spawn(function()
        while bg and bg.Parent do
            tween(gradient, {Rotation = gradient.Rotation + 180}, 10):Play()
            wait(10)
        end
    end)
    
    local particles = Instance.new("Frame")
    particles.Name = "Particles"
    particles.Size = UDim2.new(1, 0, 1, 0)
    particles.BackgroundTransparency = 1
    particles.Parent = bg
    
    for i = 1, 5 do
        local dot = Instance.new("Frame")
        dot.Name = "Dot"..i
        dot.Size = UDim2.new(0, 4, 0, 4)
        dot.Position = UDim2.new(math.random(), 0, math.random(), 0)
        dot.BackgroundColor3 = CONFIG.colors.primary
        dot.BackgroundTransparency = 0.6
        dot.BorderSizePixel = 0
        createUICorner(dot, UDim.new(1, 0))
        dot.Parent = particles
        
        local function animateDot()
            if not dot or not dot.Parent then return end
            tween(dot, {
                Position = UDim2.new(math.random(), 0, math.random(), 0),
                BackgroundTransparency = math.random() * 0.5 + 0.3
            }, math.random(3, 6)):Play()
        end
        
        spawn(function()
            while dot and dot.Parent do
                animateDot()
                wait(math.random(3, 6))
            end
        end)
    end
    
    return bg
end

function LoadingSystem:getAvatarImage()
    local userId = LocalPlayer.UserId
    local thumbType = Enum.ThumbnailType.AvatarBust
    local thumbSize = Enum.ThumbnailSize.Size420x420
    
    local success, content = pcall(function()
        return Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
    end)
    
    if success then
        return content
    else
        return "rbxasset://textures/ui/PlayerListDefaultAvatar.png"
    end
end

function LoadingSystem:createAvatar(parent)
    local container = Instance.new("Frame")
    container.Name = "AvatarContainer"
    container.Size = UDim2.new(0, CONFIG.avatarSize, 0, CONFIG.avatarSize)
    container.Position = UDim2.new(0.5, -CONFIG.avatarSize/2, 0.35, -CONFIG.avatarSize/2)
    container.BackgroundColor3 = CONFIG.colors.dark
    container.BorderSizePixel = 0
    createUICorner(container, UDim.new(1, 0))
    createUIStroke(container, CONFIG.colors.primary, 3)
    container.Parent = parent
    
    local image = Instance.new("ImageLabel")
    image.Name = "AvatarImage"
    image.Size = UDim2.new(1, -6, 1, -6)
    image.Position = UDim2.new(0, 3, 0, 3)
    image.BackgroundTransparency = 1
    image.Image = self:getAvatarImage()
    createUICorner(image, UDim.new(1, 0))
    image.Parent = container
    
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.Size = UDim2.new(1.5, 0, 1.5, 0)
    glow.Position = UDim2.new(-0.25, 0, -0.25, 0)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://10873939892"
    glow.ImageColor3 = CONFIG.colors.primary
    glow.ImageTransparency = 0.8
    glow.Parent = container
    
    tween(glow, {ImageTransparency = 0.5, Size = UDim2.new(1.8, 0, 1.8, 0), Position = UDim2.new(-0.4, 0, -0.4, 0)}, 2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut).Completed:Connect(function()
        tween(glow, {ImageTransparency = 0.8, Size = UDim2.new(1.5, 0, 1.5, 0), Position = UDim2.new(-0.25, 0, -0.25, 0)}, 2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    end)
    
    spawn(function()
        while container and container.Parent do
            tween(container, {Rotation = 360}, 20, Enum.EasingStyle.Linear).Completed:Wait()
            container.Rotation = 0
        end
    end)
    
    return container
end

function LoadingSystem:createLoadingBar(parent)
    local container = Instance.new("Frame")
    container.Name = "LoadingContainer"
    container.Size = UDim2.new(0, 400, 0, 6)
    container.Position = UDim2.new(0.5, -200, 0.6, 0)
    container.BackgroundColor3 = CONFIG.colors.dark
    container.BorderSizePixel = 0
    createUICorner(container, UDim.new(0, 3))
    container.Parent = parent
    
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = CONFIG.colors.primary
    fill.BorderSizePixel = 0
    createUICorner(fill, UDim.new(0, 3))
    fill.Parent = container
    
    local shine = Instance.new("Frame")
    shine.Name = "Shine"
    shine.Size = UDim2.new(0, 100, 1, 0)
    shine.Position = UDim2.new(0, -100, 0, 0)
    shine.BackgroundColor3 = Color3.new(1, 1, 1)
    shine.BackgroundTransparency = 0.9
    shine.BorderSizePixel = 0
    createUICorner(shine, UDim.new(0, 3))
    shine.Parent = fill
    
    local status = Instance.new("TextLabel")
    status.Name = "Status"
    status.Size = UDim2.new(0, 400, 0, 30)
    status.Position = UDim2.new(0.5, -200, 0.6, 20)
    status.BackgroundTransparency = 1
    status.Text = "Inicializando..."
    status.TextColor3 = CONFIG.colors.text
    status.TextSize = 14
    status.Font = Enum.Font.GothamMedium
    status.Parent = parent
    
    local percent = Instance.new("TextLabel")
    percent.Name = "Percent"
    percent.Size = UDim2.new(0, 100, 0, 30)
    percent.Position = UDim2.new(0.5, -50, 0.6, -35)
    percent.BackgroundTransparency = 1
    percent.Text = "0%"
    percent.TextColor3 = CONFIG.colors.primary
    percent.TextSize = 24
    percent.Font = Enum.Font.GothamBold
    percent.Parent = parent
    
    return {
        container = container,
        fill = fill,
        shine = shine,
        status = status,
        percent = percent
    }
end

function LoadingSystem:animateLoading(loadingBar, callback)
    local steps = {
        {text = "Carregando recursos...", percent = 0.2, delay = 0.5},
        {text = "Verificando sistema...", percent = 0.4, delay = 0.5},
        {text = "Preparando interface...", percent = 0.6, delay = 0.5},
        {text = "Quase pronto...", percent = 0.8, delay = 0.5},
        {text = "Concluído!", percent = 1, delay = 0.3}
    }
    
    spawn(function()
        for _, step in ipairs(steps) do
            loadingBar.status.Text = step.text
            tween(loadingBar.fill, {Size = UDim2.new(step.percent, 0, 1, 0)}, step.delay):Play()
            tween(loadingBar.shine, {Position = UDim2.new(step.percent, -100, 0, 0)}, step.delay):Play()
            
            local targetPercent = math.floor(step.percent * 100)
            for i = tonumber(loadingBar.percent.Text:gsub("%%", "")), targetPercent do
                loadingBar.percent.Text = i .. "%"
                wait(0.02)
            end
            
            wait(step.delay)
        end
        
        wait(0.5)
        if callback then callback() end
    end)
end

function LoadingSystem:show(callback)
    local screen = self:createScreen()
    local bg = self:createBackground(screen)
    local avatar = self:createAvatar(bg)
    local loadingBar = self:createLoadingBar(bg)
    
    local logo = Instance.new("TextLabel")
    logo.Name = "Logo"
    logo.Size = UDim2.new(0, 400, 0, 50)
    logo.Position = UDim2.new(0.5, -200, 0.15, 0)
    logo.BackgroundTransparency = 1
    logo.Text = "⚡ CAFUXZ1"
    logo.TextColor3 = CONFIG.colors.text
    logo.TextSize = 42
    logo.Font = Enum.Font.GothamBlack
    logo.Parent = bg
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.Size = UDim2.new(0, 400, 0, 20)
    subtitle.Position = UDim2.new(0.5, -200, 0.15, 45)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "SISTEMA DE LOADING"
    subtitle.TextColor3 = CONFIG.colors.primary
    subtitle.TextSize = 12
    subtitle.Font = Enum.Font.GothamBold
    subtitle.Parent = bg
    
    local welcome = Instance.new("TextLabel")
    welcome.Name = "Welcome"
    welcome.Size = UDim2.new(0, 400, 0, 25)
    welcome.Position = UDim2.new(0.5, -200, 0.35, CONFIG.avatarSize/2 + 10)
    welcome.BackgroundTransparency = 1
    welcome.Text = "Bem-vindo, " .. LocalPlayer.DisplayName
    welcome.TextColor3 = CONFIG.colors.text
    welcome.TextSize = 16
    welcome.Font = Enum.Font.GothamBold
    welcome.Parent = bg
    
    local username = Instance.new("TextLabel")
    username.Name = "Username"
    username.Size = UDim2.new(0, 400, 0, 20)
    username.Position = UDim2.new(0.5, -200, 0.35, CONFIG.avatarSize/2 + 35)
    username.BackgroundTransparency = 1
    username.Text = "@" .. LocalPlayer.Name
    username.TextColor3 = CONFIG.colors.text
    username.TextTransparency = 0.5
    username.TextSize = 12
    username.Font = Enum.Font.Gotham
    username.Parent = bg
    
    logo.Position = UDim2.new(0.5, -200, -0.2, 0)
    tween(logo, {Position = UDim2.new(0.5, -200, 0.15, 0)}, 0.8, Enum.EasingStyle.Back):Play()
    
    avatar.Container.Size = UDim2.new(0, 0, 0, 0)
    tween(avatar.Container, {Size = UDim2.new(0, CONFIG.avatarSize, 0, CONFIG.avatarSize)}, 0.8, Enum.EasingStyle.Back):Play()
    
    wait(1)
    self:animateLoading(loadingBar, function()
        if callback then callback(screen) end
    end)
    
    return screen
end

-- ============================================
-- SISTEMA DE KEY (KEY: CADUCOSXZ)
-- ============================================
local KeySystem = {}

function KeySystem:show(previousScreen, onSuccess)
    if previousScreen then
        tween(previousScreen:FindFirstChild("Background"), {BackgroundTransparency = 1}, 0.5).Completed:Wait()
        previousScreen:Destroy()
    end
    
    local screen = Instance.new("ScreenGui")
    screen.Name = "CAFUXZ1_KeySystem"
    screen.ResetOnSpawn = false
    screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screen.Parent = PlayerGui
    
    local bg = Instance.new("Frame")
    bg.Name = "Background"
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = CONFIG.colors.darker
    bg.BorderSizePixel = 0
    bg.BackgroundTransparency = 1
    bg.Parent = screen
    
    tween(bg, {BackgroundTransparency = 0}, 0.5):Play()
    
    local container = Instance.new("Frame")
    container.Name = "KeyContainer"
    container.Size = UDim2.new(0, 450, 0, 300)
    container.Position = UDim2.new(0.5, -225, 0.5, -150)
    container.BackgroundColor3 = CONFIG.colors.dark
    container.BorderSizePixel = 0
    createUICorner(container, UDim.new(0, 16))
    createUIStroke(container, CONFIG.colors.primary, 2)
    container.Parent = bg
    
    local icon = Instance.new("TextLabel")
    icon.Name = "LockIcon"
    icon.Size = UDim2.new(0, 60, 0, 60)
    icon.Position = UDim2.new(0.5, -30, 0, 30)
    icon.BackgroundTransparency = 1
    icon.Text = "🔒"
    icon.TextSize = 50
    icon.Parent = container
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 100)
    title.BackgroundTransparency = 1
    title.Text = "SISTEMA DE ACESSO"
    title.TextColor3 = CONFIG.colors.text
    title.TextSize = 20
    title.Font = Enum.Font.GothamBlack
    title.Parent = container
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.Size = UDim2.new(1, -40, 0, 40)
    subtitle.Position = UDim2.new(0, 20, 0, 135)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Digite a key de acesso para continuar"
    subtitle.TextColor3 = CONFIG.colors.text
    subtitle.TextTransparency = 0.4
    subtitle.TextSize = 14
    subtitle.Font = Enum.Font.Gotham
    subtitle.Parent = container
    
    local inputBg = Instance.new("Frame")
    inputBg.Name = "InputBg"
    inputBg.Size = UDim2.new(0, 350, 0, 45)
    inputBg.Position = UDim2.new(0.5, -175, 0, 190)
    inputBg.BackgroundColor3 = CONFIG.colors.darker
    inputBg.BorderSizePixel = 0
    createUICorner(inputBg, UDim.new(0, 8))
    createUIStroke(inputBg, CONFIG.colors.primary, 1)
    inputBg.Parent = container
    
    local input = Instance.new("TextBox")
    input.Name = "KeyInput"
    input.Size = UDim2.new(1, -20, 1, 0)
    input.Position = UDim2.new(0, 10, 0, 0)
    input.BackgroundTransparency = 1
    input.Text = ""
    input.PlaceholderText = "Digite a key aqui..."
    input.TextColor3 = CONFIG.colors.text
    input.PlaceholderColor3 = CONFIG.colors.text
    input.TextTransparency = 0.5
    input.TextSize = 14
    input.Font = Enum.Font.GothamMedium
    input.ClearTextOnFocus = false
    input.Parent = inputBg
    
    local btn = Instance.new("TextButton")
    btn.Name = "VerifyBtn"
    btn.Size = UDim2.new(0, 350, 0, 45)
    btn.Position = UDim2.new(0.5, -175, 0, 245)
    btn.BackgroundColor3 = CONFIG.colors.primary
    btn.Text = "VERIFICAR KEY"
    btn.TextColor3 = CONFIG.colors.text
    btn.TextSize = 16
    btn.Font = Enum.Font.GothamBold
    createUICorner(btn, UDim.new(0, 8))
    btn.Parent = container
    
    btn.MouseEnter:Connect(function()
        tween(btn, {BackgroundColor3 = CONFIG.colors.secondary}, 0.2):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        tween(btn, {BackgroundColor3 = CONFIG.colors.primary}, 0.2):Play()
    end)
    
    local errorMsg = Instance.new("TextLabel")
    errorMsg.Name = "ErrorMsg"
    errorMsg.Size = UDim2.new(1, 0, 0, 20)
    errorMsg.Position = UDim2.new(0, 0, 1, -25)
    errorMsg.BackgroundTransparency = 1
    errorMsg.Text = ""
    errorMsg.TextColor3 = CONFIG.colors.danger
    errorMsg.TextSize = 12
    errorMsg.Font = Enum.Font.GothamBold
    errorMsg.Parent = container
    
    container.Position = UDim2.new(0.5, -225, 0.5, -100)
    container.BackgroundTransparency = 1
    tween(container, {Position = UDim2.new(0.5, -225, 0.5, -150), BackgroundTransparency = 0}, 0.6, Enum.EasingStyle.Back):Play()
    
    local function verifyKey()
        local enteredKey = input.Text:gsub("%s+", "")
        
        if enteredKey == "" then
            errorMsg.Text = "⚠️ Digite uma key!"
            tween(errorMsg, {TextTransparency = 0}, 0.2):Play()
            wait(2)
            tween(errorMsg, {TextTransparency = 1}, 0.2):Play()
            return
        end
        
        if enteredKey == CONFIG.key then
            errorMsg.Text = "✓ Key válida! Carregando..."
            errorMsg.TextColor3 = CONFIG.colors.success
            tween(errorMsg, {TextTransparency = 0}, 0.2):Play()
            
            tween(btn, {BackgroundColor3 = CONFIG.colors.success}, 0.3):Play()
            btn.Text = "ACESSO CONCEDIDO!"
            
            wait(1)
            
            tween(container, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.5):Play()
            tween(bg, {BackgroundTransparency = 1}, 0.5).Completed:Wait()
            
            screen:Destroy()
            if onSuccess then onSuccess() end
        else
            errorMsg.Text = "✗ Key inválida! Tente novamente."
            tween(errorMsg, {TextTransparency = 0}, 0.2):Play()
            
            local originalPos = container.Position
            for i = 1, 5 do
                container.Position = originalPos + UDim2.new(0, math.random(-10, 10), 0, 0)
                wait(0.05)
            end
            container.Position = originalPos
            
            input.Text = ""
            input:CaptureFocus()
            
            wait(2)
            tween(errorMsg, {TextTransparency = 1}, 0.2):Play()
        end
    end
    
    btn.MouseButton1Click:Connect(verifyKey)
    
    input.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            verifyKey()
        end
    end)
    
    input:CaptureFocus()
end

-- ============================================
-- LOADING FINAL
-- ============================================
local FinalLoading = {}

function FinalLoading:show(callback)
    local screen = Instance.new("ScreenGui")
    screen.Name = "CAFUXZ1_FinalLoading"
    screen.ResetOnSpawn = false
    screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screen.Parent = PlayerGui
    
    local bg = Instance.new("Frame")
    bg.Name = "Background"
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = CONFIG.colors.darker
    bg.BorderSizePixel = 0
    bg.Parent = screen
    
    local logo = Instance.new("TextLabel")
    logo.Name = "Logo"
    logo.Size = UDim2.new(0, 400, 0, 80)
    logo.Position = UDim2.new(0.5, -200, 0.4, -40)
    logo.BackgroundTransparency = 1
    logo.Text = "⚡ CAFUXZ1"
    logo.TextColor3 = CONFIG.colors.text
    logo.TextSize = 56
    logo.Font = Enum.Font.GothamBlack
    logo.Parent = bg
    
    local spinner = Instance.new("Frame")
    spinner.Name = "Spinner"
    spinner.Size = UDim2.new(0, 60, 0, 60)
    spinner.Position = UDim2.new(0.5, -30, 0.6, 0)
    spinner.BackgroundTransparency = 1
    spinner.Parent = bg
    
    for i = 1, 8 do
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 8, 0, 8)
        dot.Position = UDim2.new(0.5 + 0.35 * math.cos(i * math.pi / 4) - 0.1, 0, 0.5 + 0.35 * math.sin(i * math.pi / 4) - 0.1, 0)
        dot.BackgroundColor3 = CONFIG.colors.primary
        dot.BackgroundTransparency = i / 10
        dot.BorderSizePixel = 0
        createUICorner(dot, UDim.new(1, 0))
        dot.Parent = spinner
    end
    
    spawn(function()
        while spinner and spinner.Parent do
            tween(spinner, {Rotation = spinner.Rotation + 45}, 0.1, Enum.EasingStyle.Linear):Play()
            wait(0.1)
        end
    end)
    
    local status = Instance.new("TextLabel")
    status.Name = "Status"
    status.Size = UDim2.new(0, 400, 0, 30)
    status.Position = UDim2.new(0.5, -200, 0.6, 70)
    status.BackgroundTransparency = 1
    status.Text = "Carregando CAFUXZ1 Hub..."
    status.TextColor3 = CONFIG.colors.primary
    status.TextSize = 14
    status.Font = Enum.Font.GothamMedium
    status.Parent = bg
    
    logo.Position = UDim2.new(0.5, -200, 0.3, -40)
    tween(logo, {Position = UDim2.new(0.5, -200, 0.4, -40)}, 0.8, Enum.EasingStyle.Back):Play()
    
    spawn(function()
        local messages = {
            "Conectando ao servidor...",
            "Baixando recursos...",
            "Compilando scripts...",
            "Inicializando módulos...",
            "Quase lá..."
        }
        
        for _, msg in ipairs(messages) do
            status.Text = msg
            wait(0.4)
        end
        
        status.Text = "CAFUXZ1 Hub carregado!"
        status.TextColor3 = CONFIG.colors.success
        
        wait(0.5)
        
        tween(logo, {Position = UDim2.new(0.5, -200, -0.2, -40)}, 0.5):Play()
        tween(spinner, {ImageTransparency = 1}, 0.5):Play()
        tween(bg, {BackgroundTransparency = 1}, 0.5).Completed:Wait()
        
        screen:Destroy()
        if callback then callback() end
    end)
end

-- ============================================
-- HUB CAFUXZ1
-- ============================================
local HubLoader = {}

function HubLoader:load()
    StarterGui:SetCore("SendNotification", {
        Title = "⚡ CAFUXZ1 Hub",
        Text = "v14.9 Carregando script...",
        Duration = 3
    })
    
    -- SÓ O LINK DO SCRIPT - sem loadstring do Titanium Hub
    local success, err = pcall(function()
        loadstring(game:HttpGet(CONFIG.scriptUrl))()
    end)
    
    if not success then
        warn("Erro ao carregar CAFUXZ1 Hub: " .. tostring(err))
        StarterGui:SetCore("SendNotification", {
            Title = "⚠️ Erro",
            Text = "Falha ao carregar: " .. tostring(err):sub(1, 50),
            Duration = 5
        })
    end
end

-- ============================================
-- EXECUÇÃO PRINCIPAL
-- ============================================
local function startSystem()
    -- 1. Loading com avatar
    LoadingSystem:show(function(screen)
        -- 2. Key System (Key: CADUCOSXZ)
        KeySystem:show(screen, function()
            -- 3. Loading final
            FinalLoading:show(function()
                -- 4. Carregar Hub
                HubLoader:load()
            end)
        end)
    end)
end

startSystem()

print("🚀 CAFUXZ1 Loader v1.1 - Key: CADUCOSXZ - Usuário: " .. LocalPlayer.Name)
