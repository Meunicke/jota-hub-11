--[[
    CAFUXZ1 Intro v2.0 - Loading Screen Única
    ==========================================
    - Design futurista e personalizado
    - Correção do bug do 0% (sistema de progresso real)
    - Executa Titanium Hub após carregar
    - Otimizado, sem loops pesados
]]

if not game:IsLoaded() then game.Loaded:Wait() end

-- ============================================
-- SERVIÇOS
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ============================================
-- CONFIGURAÇÕES
-- ============================================
local CONFIG = {
    scriptUrl = "https://raw.githubusercontent.com/Meunicke/jota-hub-11/refs/heads/main/TitaniumHub_CADU_Standalone.lua",
    loadingTime = 4, -- segundos totais de loading
    colors = {
        primary = Color3.fromRGB(99, 102, 241),
        secondary = Color3.fromRGB(139, 92, 246),
        accent = Color3.fromRGB(14, 165, 233),
        dark = Color3.fromRGB(8, 8, 15),
        darker = Color3.fromRGB(5, 5, 10),
        success = Color3.fromRGB(34, 197, 94),
        text = Color3.fromRGB(252, 252, 255),
        glow = Color3.fromRGB(99, 102, 241)
    }
}

-- ============================================
-- FUNÇÕES UTILITÁRIAS
-- ============================================
local function tween(obj, props, time, style, dir)
    local info = TweenInfo.new(time or 0.5, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out)
    return TweenService:Create(obj, info, props)
end

local function createCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius or UDim.new(0, 8)
    c.Parent = parent
    return c
end

local function createStroke(parent, color, thick)
    local s = Instance.new("UIStroke")
    s.Color = color or CONFIG.colors.primary
    s.Thickness = thick or 1
    s.Parent = parent
    return s
end

-- ============================================
-- SISTEMA DE PROGRESSO REAL (CORREÇÃO DO BUG 0%)
-- ============================================
local ProgressSystem = {
    current = 0,
    target = 0,
    speed = 0,
    callbacks = {}
}

function ProgressSystem:init()
    -- Atualização suave do progresso usando Heartbeat (não while true)
    RunService.Heartbeat:Connect(function(dt)
        if self.current < self.target then
            -- Lerp suave entre current e target
            self.current = self.current + (self.target - self.current) * 5 * dt
            if math.abs(self.target - self.current) < 0.1 then
                self.current = self.target
            end
            
            -- Chamar callbacks
            for _, cb in ipairs(self.callbacks) do
                cb(self.current)
            end
        end
    end)
end

function ProgressSystem:setTarget(t)
    self.target = math.clamp(t, 0, 100)
end

function ProgressSystem:onUpdate(callback)
    table.insert(self.callbacks, callback)
end

-- ============================================
-- INTRO PERSONALIZADA
-- ============================================
local Intro = {}

function Intro:create()
    -- Limpar GUIs antigas
    for _, g in ipairs(PlayerGui:GetChildren()) do
        if g:IsA("ScreenGui") and (g.Name:find("CAFUXZ1") or g.Name:find("Intro") or g.Name:find("Loading")) then
            g:Destroy()
        end
    end
    
    local screen = Instance.new("ScreenGui")
    screen.Name = "CAFUXZ1_Intro"
    screen.ResetOnSpawn = false
    screen.ZIndexBehavior = Enum.ZIndexBehavior.Global
    screen.Parent = PlayerGui
    
    -- Background principal
    local bg = Instance.new("Frame")
    bg.Name = "Background"
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = CONFIG.colors.darker
    bg.BorderSizePixel = 0
    bg.Parent = screen
    
    -- Gradiente animado de fundo
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, CONFIG.colors.darker),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(15, 15, 25)),
        ColorSequenceKeypoint.new(1, CONFIG.colors.darker)
    })
    gradient.Rotation = 0
    gradient.Parent = bg
    
    -- Animar gradiente suavemente
    spawn(function()
        while bg and bg.Parent do
            tween(gradient, {Rotation = gradient.Rotation + 360}, 20, Enum.EasingStyle.Linear):Play()
            wait(20)
        end
    end)
    
    -- Grid de linhas futuristas
    local grid = Instance.new("Frame")
    grid.Name = "Grid"
    grid.Size = UDim2.new(1, 0, 1, 0)
    grid.BackgroundTransparency = 1
    grid.Parent = bg
    
    -- Criar linhas horizontais
    for i = 1, 10 do
        local line = Instance.new("Frame")
        line.Size = UDim2.new(1, 0, 0, 1)
        line.Position = UDim2.new(0, 0, i/10, 0)
        line.BackgroundColor3 = CONFIG.colors.primary
        line.BackgroundTransparency = 0.95
        line.BorderSizePixel = 0
        line.Parent = grid
    end
    
    -- Container central
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(0, 500, 0, 350)
    container.Position = UDim2.new(0.5, -250, 0.5, -175)
    container.BackgroundColor3 = CONFIG.colors.dark
    container.BackgroundTransparency = 0.3
    container.BorderSizePixel = 0
    createCorner(container, UDim.new(0, 20))
    createStroke(container, CONFIG.colors.primary, 2)
    container.Parent = bg
    
    -- Glow effect atrás do container
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.Size = UDim2.new(1.5, 0, 1.5, 0)
    glow.Position = UDim2.new(-0.25, 0, -0.25, 0)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://10873939892"
    glow.ImageColor3 = CONFIG.colors.glow
    glow.ImageTransparency = 0.7
    glow.Parent = container
    
    -- Logo principal
    local logoContainer = Instance.new("Frame")
    logoContainer.Name = "LogoContainer"
    logoContainer.Size = UDim2.new(0, 120, 0, 120)
    logoContainer.Position = UDim2.new(0.5, -60, 0, 30)
    logoContainer.BackgroundColor3 = CONFIG.colors.primary
    logoContainer.BorderSizePixel = 0
    createCorner(logoContainer, UDim.new(1, 0))
    logoContainer.Parent = container
    
    -- Ícone do logo
    local logoIcon = Instance.new("TextLabel")
    logoIcon.Name = "LogoIcon"
    logoIcon.Size = UDim2.new(1, 0, 1, 0)
    logoIcon.BackgroundTransparency = 1
    logoIcon.Text = "⚡"
    logoIcon.TextColor3 = CONFIG.colors.text
    logoIcon.TextSize = 60
    logoIcon.Font = Enum.Font.GothamBlack
    logoIcon.Parent = logoContainer
    
    -- Glow do logo
    local logoGlow = Instance.new("ImageLabel")
    logoGlow.Size = UDim2.new(1.8, 0, 1.8, 0)
    logoGlow.Position = UDim2.new(-0.4, 0, -0.4, 0)
    logoGlow.BackgroundTransparency = 1
    logoGlow.Image = "rbxassetid://10873939892"
    logoGlow.ImageColor3 = CONFIG.colors.primary
    logoGlow.ImageTransparency = 0.6
    logoGlow.Parent = logoContainer
    
    -- Animação de pulso do glow
    spawn(function()
        while logoGlow and logoGlow.Parent do
            tween(logoGlow, {ImageTransparency = 0.3, Size = UDim2.new(2, 0, 2, 0)}, 1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut):Play()
            wait(1)
            tween(logoGlow, {ImageTransparency = 0.6, Size = UDim2.new(1.8, 0, 1.8, 0)}, 1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut):Play()
            wait(1)
        end
    end)
    
    -- Título
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 160)
    title.BackgroundTransparency = 1
    title.Text = "CAFUXZ1"
    title.TextColor3 = CONFIG.colors.text
    title.TextSize = 36
    title.Font = Enum.Font.GothamBlack
    title.Parent = container
    
    -- Subtítulo
    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.Size = UDim2.new(1, 0, 0, 20)
    subtitle.Position = UDim2.new(0, 0, 0, 200)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "TITANIUM HUB EDITION"
    subtitle.TextColor3 = CONFIG.colors.primary
    subtitle.TextSize = 12
    subtitle.Font = Enum.Font.GothamBold
    subtitle.Parent = container
    
    -- Barra de progresso container
    local barBg = Instance.new("Frame")
    barBg.Name = "BarBg"
    barBg.Size = UDim2.new(0, 400, 0, 8)
    barBg.Position = UDim2.new(0.5, -200, 0, 260)
    barBg.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    barBg.BorderSizePixel = 0
    createCorner(barBg, UDim.new(0, 4))
    barBg.Parent = container
    
    -- Fill da barra
    local barFill = Instance.new("Frame")
    barFill.Name = "BarFill"
    barFill.Size = UDim2.new(0, 0, 1, 0)
    barFill.BackgroundColor3 = CONFIG.colors.primary
    barFill.BorderSizePixel = 0
    createCorner(barFill, UDim.new(0, 4))
    barFill.Parent = barBg
    
    -- Brilho na barra
    local barShine = Instance.new("Frame")
    barShine.Name = "BarShine"
    barShine.Size = UDim2.new(0, 80, 1, 0)
    barShine.Position = UDim2.new(0, -80, 0, 0)
    barShine.BackgroundColor3 = Color3.new(1, 1, 1)
    barShine.BackgroundTransparency = 0.8
    barShine.BorderSizePixel = 0
    createCorner(barShine, UDim.new(0, 4))
    barShine.Parent = barFill
    
    -- Texto de porcentagem
    local percentText = Instance.new("TextLabel")
    percentText.Name = "Percent"
    percentText.Size = UDim2.new(0, 100, 0, 30)
    percentText.Position = UDim2.new(0.5, -50, 0, 275)
    percentText.BackgroundTransparency = 1
    percentText.Text = "0%"
    percentText.TextColor3 = CONFIG.colors.text
    percentText.TextSize = 18
    percentText.Font = Enum.Font.GothamBold
    percentText.Parent = container
    
    -- Status text
    local statusText = Instance.new("TextLabel")
    statusText.Name = "Status"
    statusText.Size = UDim2.new(1, 0, 0, 20)
    statusText.Position = UDim2.new(0, 0, 0, 305)
    statusText.BackgroundTransparency = 1
    statusText.Text = "Inicializando..."
    statusText.TextColor3 = CONFIG.colors.text
    statusText.TextTransparency = 0.5
    statusText.TextSize = 12
    statusText.Font = Enum.Font.GothamMedium
    statusText.Parent = container
    
    -- Partículas decorativas (poucas, otimizadas)
    local particles = Instance.new("Frame")
    particles.Name = "Particles"
    particles.Size = UDim2.new(1, 0, 1, 0)
    particles.BackgroundTransparency = 1
    particles.Parent = bg
    
    for i = 1, 6 do
        local p = Instance.new("Frame")
        p.Size = UDim2.new(0, 3, 0, 3)
        p.Position = UDim2.new(math.random(), 0, math.random(), 0)
        p.BackgroundColor3 = CONFIG.colors.primary
        p.BackgroundTransparency = 0.7
        p.BorderSizePixel = 0
        createCorner(p, UDim.new(1, 0))
        p.Parent = particles
        
        -- Movimento suave
        spawn(function()
            while p and p.Parent do
                tween(p, {
                    Position = UDim2.new(math.random(), 0, math.random(), 0),
                    BackgroundTransparency = math.random() * 0.6 + 0.2
                }, math.random(4, 8)):Play()
                wait(math.random(4, 8))
            end
        end)
    end
    
    -- Animações de entrada
    container.Position = UDim2.new(0.5, -250, 0.5, -100)
    container.BackgroundTransparency = 1
    
    tween(container, {
        Position = UDim2.new(0.5, -250, 0.5, -175),
        BackgroundTransparency = 0.3
    }, 0.8, Enum.EasingStyle.Back):Play()
    
    logoContainer.Size = UDim2.new(0, 0, 0, 0)
    tween(logoContainer, {Size = UDim2.new(0, 120, 0, 120)}, 0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out):Play()
    
    title.TextTransparency = 1
    tween(title, {TextTransparency = 0}, 0.5):Play()
    
    return {
        screen = screen,
        barFill = barFill,
        barShine = barShine,
        percentText = percentText,
        statusText = statusText,
        container = container,
        bg = bg
    }
end

function Intro:simulateLoading(ui, onComplete)
    ProgressSystem:init()
    
    local steps = {
        {status = "Conectando ao servidor...", progress = 15, delay = 0.8},
        {status = "Autenticando usuário...", progress = 35, delay = 0.6},
        {status = "Carregando recursos...", progress = 55, delay = 0.8},
        {status = "Compilando scripts...", progress = 75, delay = 0.7},
        {status = "Finalizando...", progress = 90, delay = 0.5},
        {status = "Pronto!", progress = 100, delay = 0.4}
    }
    
    -- Conectar atualização da UI ao progresso
    ProgressSystem:onUpdate(function(progress)
        -- Atualizar barra
        ui.barFill.Size = UDim2.new(progress/100, 0, 1, 0)
        -- Atualizar shine
        ui.barShine.Position = UDim2.new(progress/100, -80, 0, 0)
        -- Atualizar texto (inteiro)
        ui.percentText.Text = math.floor(progress) .. "%"
    end)
    
    -- Executar etapas sequencialmente
    spawn(function()
        for i, step in ipairs(steps) do
            -- Atualizar status
            ui.statusText.Text = step.status
            
            -- Definir target do progresso
            ProgressSystem:setTarget(step.progress)
            
            -- Aguardar delay da etapa
            wait(step.delay)
        end
        
        -- Aguardar progresso chegar a 100%
        repeat wait() until ProgressSystem.current >= 99
        
        wait(0.3)
        
        -- Animação de saída
        ui.statusText.Text = "EXECUTANDO..."
        ui.statusText.TextColor3 = CONFIG.colors.success
        
        tween(ui.container, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Rotation = 360
        }, 0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In):Play()
        
        tween(ui.bg, {BackgroundTransparency = 1}, 0.6).Completed:Wait()
        
        ui.screen:Destroy()
        
        if onComplete then onComplete() end
    end)
end

-- ============================================
-- CARREGADOR DO SCRIPT
-- ============================================
local ScriptLoader = {}

function ScriptLoader:execute()
    -- Notificação
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "⚡ CAFUXZ1",
            Text = "Carregando Titanium Hub...",
            Duration = 3
        })
    end)
    
    -- Executar script em pcall para não travar se der erro
    local success, err = pcall(function()
        loadstring(game:HttpGet(CONFIG.scriptUrl))()
    end)
    
    if not success then
        warn("[CAFUXZ1] Erro ao carregar: " .. tostring(err))
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "⚠️ Erro",
                Text = "Falha ao carregar script",
                Duration = 5
            })
        end)
    end
end

-- ============================================
-- INICIAR SISTEMA
-- ============================================
local function main()
    local ui = Intro:create()
    
    Intro:simulateLoading(ui, function()
        ScriptLoader:execute()
    end)
end

main()

print("⚡ CAFUXZ1 Intro v2.0 iniciado para " .. LocalPlayer.Name)
