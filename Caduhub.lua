-- Cadu Hub | The Classic Soccer
-- Script premium com arrasto livre para fora da tela

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- CONFIGURAÇÕES PREMIUM
local CONFIG = {
    reach = 10,
    showReachSphere = true,
    autoSecondTouch = true,
    scanCooldown = 1.5,
    ballNames = { "TPS", "ESA", "MRS", "PRS", "MPS", "SSS", "AIFA", "RBZ" },
    menuOpen = false,
    
    -- Cores tema
    accentColor = Color3.fromRGB(0, 180, 255),
    accentSecondary = Color3.fromRGB(0, 255, 180),
    bgColor = Color3.fromRGB(15, 15, 20),
    bgLight = Color3.fromRGB(35, 35, 45),
    textColor = Color3.fromRGB(255, 255, 255),
    textDark = Color3.fromRGB(180, 180, 190),
    
    -- Animações
    animSpeed = 0.35
}

-- VARIÁVEIS GLOBAIS
local balls = {}
local lastRefresh = 0
local reachSphere
local gui, mainFrame, menuButton, reachLabel, sphereToggle, contentFrame, iconContainer

-- BALL SET
local BALL_NAME_SET = {}
for _, n in ipairs(CONFIG.ballNames) do
    BALL_NAME_SET[n] = true
end

-- NOTIFICAÇÃO ELEGANTE
local function notify(txt, t)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "⚽ Cadu Hub",
            Text = txt,
            Duration = t or 3,
            Icon = "rbxassetid://3926305904"
        })
    end)
end

-- ATUALIZAR BOLAS
local function refreshBalls(force)
    if not force and tick() - lastRefresh < CONFIG.scanCooldown then return end
    lastRefresh = tick()
    table.clear(balls)

    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and BALL_NAME_SET[v.Name] then
            balls[#balls+1] = v
        end
    end
end

-- PARTES DO CORPO
local function getValidParts(char)
    local parts = {}
    for _, v in ipairs(char:GetChildren()) do
        if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
            parts[#parts+1] = v
        end
    end
    return parts
end

-- ESFERA DE ALCANCE
local function updateReachSphere()
    if not CONFIG.showReachSphere then
        if reachSphere then 
            TweenService:Create(reachSphere, TweenInfo.new(0.5), {Transparency = 1}):Play()
            task.delay(0.5, function()
                if reachSphere then reachSphere:Destroy() end
                reachSphere = nil
            end)
        end
        return
    end

    if not reachSphere then
        reachSphere = Instance.new("Part")
        reachSphere.Name = "CaduReachSphere"
        reachSphere.Shape = Enum.PartType.Ball
        reachSphere.Anchored = true
        reachSphere.CanCollide = false
        reachSphere.Transparency = 0.92
        reachSphere.Material = Enum.Material.ForceField
        reachSphere.Color = CONFIG.accentColor
        reachSphere.Parent = Workspace
    end

    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        reachSphere.Position = hrp.Position
    end

    reachSphere.Size = Vector3.new(CONFIG.reach*2, CONFIG.reach*2, CONFIG.reach*2)
end

-- SISTEMA DE ANIMAÇÕES
local function smoothTween(obj, properties, duration, style, direction)
    return TweenService:Create(obj, TweenInfo.new(
        duration or CONFIG.animSpeed,
        style or Enum.EasingStyle.Quint,
        direction or Enum.EasingDirection.Out
    ), properties)
end

local function elasticTween(obj, properties, duration)
    return TweenService:Create(obj, TweenInfo.new(
        duration or 0.6,
        Enum.EasingStyle.Back,
        Enum.EasingDirection.Out
    ), properties)
end

-- ARRASTO ULTRA FLUIDO - LIVRE PARA FORA DA TELA
local function makeFreeDraggable(frame, handle)
    local dragging = false
    local dragStart, startPos
    local dragConnection
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            -- Feedback visual
            smoothTween(handle, {BackgroundColor3 = handle.BackgroundColor3:Lerp(Color3.new(0,0,0), 0.2)}, 0.1):Play()
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    smoothTween(handle, {BackgroundColor3 = handle:GetAttribute("OriginalColor")}, 0.2):Play()
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            -- Movimento direto sem restrições - pode ir para qualquer lugar
            frame.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X,
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Hover effects
    if handle:IsA("TextButton") or handle:IsA("ImageButton") then
        handle.MouseEnter:Connect(function()
            if not dragging then
                smoothTween(handle, {BackgroundColor3 = handle:GetAttribute("HoverColor") or handle.BackgroundColor3:Lerp(Color3.new(1,1,1), 0.2)}, 0.2):Play()
                smoothTween(handle, {Size = handle.Size + UDim2.new(0, 6, 0, 6)}, 0.2):Play()
            end
        end)
        
        handle.MouseLeave:Connect(function()
            if not dragging then
                smoothTween(handle, {BackgroundColor3 = handle:GetAttribute("OriginalColor")}, 0.2):Play()
                smoothTween(handle, {Size = handle:GetAttribute("OriginalSize")}, 0.2):Play()
            end
        end)
    end
end

-- CRIAR SOMBRA SUAVE
local function createShadow(parent, offset, transparency)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, offset * 2, 1, offset * 2)
    shadow.Position = UDim2.new(0, -offset, 0, -offset)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://131296141"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = transparency or 0.7
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Parent = parent
    return shadow
end

-- INTERFACE PREMIUM
local function buildGUI()
    if gui then return end

    gui = Instance.new("ScreenGui")
    gui.Name = "CaduHubPremium"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    gui.Parent = player:WaitForChild("PlayerGui")

    -- CONTAINER DO ÍCONE - PODE SAIR FORA DA TELA
    iconContainer = Instance.new("Frame")
    iconContainer.Name = "IconContainer"
    iconContainer.Size = UDim2.new(0, 60, 0, 60)
    iconContainer.Position = UDim2.new(1, -80, 0.15, 0)
    iconContainer.BackgroundTransparency = 1
    iconContainer.Parent = gui

    menuButton = Instance.new("TextButton")
    menuButton.Name = "MenuButton"
    menuButton.Size = UDim2.new(0, 50, 0, 50)
    menuButton.Position = UDim2.new(0.5, -25, 0.5, -25)
    menuButton.BackgroundColor3 = CONFIG.accentColor
    menuButton.Text = "⚽"
    menuButton.TextSize = 26
    menuButton.Font = Enum.Font.GothamBlack
    menuButton.TextColor3 = CONFIG.textColor
    menuButton.BorderSizePixel = 0
    menuButton.AutoButtonColor = false
    menuButton.Parent = iconContainer
    
    menuButton:SetAttribute("OriginalColor", CONFIG.accentColor)
    menuButton:SetAttribute("HoverColor", Color3.fromRGB(0, 210, 255))
    menuButton:SetAttribute("OriginalSize", UDim2.new(0, 50, 0, 50))
    
    -- Sombra premium
    createShadow(menuButton, 12, 0.6)
    
    -- Glow sutil pulsante
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.Size = UDim2.new(1.4, 0, 1.4, 0)
    glow.Position = UDim2.new(-0.2, 0, -0.2, 0)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://10873939892"
    glow.ImageColor3 = CONFIG.accentColor
    glow.ImageTransparency = 0.9
    glow.ScaleType = Enum.ScaleType.Stretch
    glow.ZIndex = menuButton.ZIndex - 2
    glow.Parent = menuButton
    
    -- Animação de pulso
    task.spawn(function()
        while menuButton and menuButton.Parent do
            smoothTween(glow, {ImageTransparency = 0.75}, 1.2):Play()
            task.wait(1.2)
            smoothTween(glow, {ImageTransparency = 0.9}, 1.2):Play()
            task.wait(1.2)
        end
    end)
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0.5, 0)
    btnCorner.Parent = menuButton

    -- MENU PRINCIPAL ELEGANTE
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 300, 0, 220)
    mainFrame.Position = UDim2.new(0.5, -150, 0.5, -110)
    mainFrame.BackgroundColor3 = CONFIG.bgColor
    mainFrame.BackgroundTransparency = 0.02
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = gui
    
    createShadow(mainFrame, 25, 0.5)

    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 20)
    frameCorner.Parent = mainFrame

    -- CABEÇALHO COM GRADIENTE
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = CONFIG.accentColor
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    header:SetAttribute("OriginalColor", CONFIG.accentColor)
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, CONFIG.accentColor),
        ColorSequenceKeypoint.new(1, CONFIG.accentSecondary)
    })
    gradient.Rotation = 45
    gradient.Parent = header

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 20)
    headerCorner.Parent = header
    
    local headerFix = Instance.new("Frame")
    headerFix.Size = UDim2.new(1, 0, 0.5, 0)
    headerFix.Position = UDim2.new(0, 0, 0.5, 0)
    headerFix.BackgroundColor3 = CONFIG.accentColor
    headerFix.BorderSizePixel = 0
    headerFix.Parent = header
    
    local gradientFix = Instance.new("UIGradient")
    gradientFix.Color = gradient.Color
    gradientFix.Rotation = 45
    gradientFix.Parent = headerFix

    -- Título
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -60, 1, 0)
    title.Position = UDim2.new(0, 20, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "⚽ Cadu Hub"
    title.TextSize = 22
    title.Font = Enum.Font.GothamBold
    title.TextColor3 = CONFIG.textColor
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    -- Botão fechar
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -45, 0.5, -17.5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    closeBtn.Text = "×"
    closeBtn.TextSize = 24
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextColor3 = CONFIG.textColor
    closeBtn.BorderSizePixel = 0
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = header
    
    closeBtn:SetAttribute("OriginalColor", Color3.fromRGB(255, 80, 80))
    closeBtn:SetAttribute("HoverColor", Color3.fromRGB(255, 120, 120))
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0.3, 0)
    closeCorner.Parent = closeBtn

    -- CONTEÚDO
    contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, 0, 1, -50)
    contentFrame.Position = UDim2.new(0, 0, 0, 50)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame

    -- SEÇÃO DE REACH
    local reachSection = Instance.new("Frame")
    reachSection.Size = UDim2.new(1, -40, 0, 60)
    reachSection.Position = UDim2.new(0, 20, 0, 20)
    reachSection.BackgroundColor3 = CONFIG.bgLight
    reachSection.BorderSizePixel = 0
    reachSection.Parent = contentFrame
    
    local reachSectionCorner = Instance.new("UICorner")
    reachSectionCorner.CornerRadius = UDim.new(0, 12)
    reachSectionCorner.Parent = reachSection

    local reachText = Instance.new("TextLabel")
    reachText.Size = UDim2.new(0.4, 0, 1, 0)
    reachText.Position = UDim2.new(0, 15, 0, 0)
    reachText.BackgroundTransparency = 1
    reachText.Text = "Alcance"
    reachText.TextSize = 14
    reachText.Font = Enum.Font.Gotham
    reachText.TextColor3 = CONFIG.textDark
    reachText.TextXAlignment = Enum.TextXAlignment.Left
    reachText.Parent = reachSection

    reachLabel = Instance.new("TextLabel")
    reachLabel.Size = UDim2.new(0.6, -15, 1, 0)
    reachLabel.Position = UDim2.new(0.4, 0, 0, 0)
    reachLabel.BackgroundTransparency = 1
    reachLabel.Text = tostring(CONFIG.reach)
    reachLabel.TextSize = 32
    reachLabel.Font = Enum.Font.GothamBlack
    reachLabel.TextColor3 = CONFIG.accentColor
    reachLabel.TextXAlignment = Enum.TextXAlignment.Right
    reachLabel.Parent = reachSection

    -- BOTÕES DE CONTROLE
    local controlsFrame = Instance.new("Frame")
    controlsFrame.Size = UDim2.new(1, -40, 0, 55)
    controlsFrame.Position = UDim2.new(0, 20, 0, 90)
    controlsFrame.BackgroundTransparency = 1
    controlsFrame.Parent = contentFrame

    local minus = Instance.new("TextButton")
    minus.Name = "Minus"
    minus.Size = UDim2.new(0.48, 0, 1, 0)
    minus.BackgroundColor3 = CONFIG.bgLight
    minus.Text = "−"
    minus.TextSize = 24
    minus.Font = Enum.Font.GothamBold
    minus.TextColor3 = CONFIG.textColor
    minus.BorderSizePixel = 0
    minus.AutoButtonColor = false
    minus.Parent = controlsFrame
    
    minus:SetAttribute("OriginalColor", CONFIG.bgLight)
    minus:SetAttribute("HoverColor", Color3.fromRGB(255, 100, 100))
    
    local minusCorner = Instance.new("UICorner")
    minusCorner.CornerRadius = UDim.new(0, 12)
    minusCorner.Parent = minus

    local plus = Instance.new("TextButton")
    plus.Name = "Plus"
    plus.Size = UDim2.new(0.48, 0, 1, 0)
    plus.Position = UDim2.new(0.52, 0, 0, 0)
    plus.BackgroundColor3 = CONFIG.bgLight
    plus.Text = "+"
    plus.TextSize = 24
    plus.Font = Enum.Font.GothamBold
    plus.TextColor3 = CONFIG.textColor
    plus.BorderSizePixel = 0
    plus.AutoButtonColor = false
    plus.Parent = controlsFrame
    
    plus:SetAttribute("OriginalColor", CONFIG.bgLight)
    plus:SetAttribute("HoverColor", Color3.fromRGB(100, 255, 150))
    
    local plusCorner = Instance.new("UICorner")
    plusCorner.CornerRadius = UDim.new(0, 12)
    plusCorner.Parent = plus

    -- TOGGLE DE ESFERA
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, -40, 0, 45)
    toggleFrame.Position = UDim2.new(0, 20, 0, 155)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = contentFrame

    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Size = UDim2.new(0.6, 0, 1, 0)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Text = "Mostrar Esfera"
    toggleLabel.TextSize = 15
    toggleLabel.Font = Enum.Font.Gotham
    toggleLabel.TextColor3 = CONFIG.textDark
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.Parent = toggleFrame

    local switchContainer = Instance.new("TextButton")
    switchContainer.Size = UDim2.new(0, 55, 0, 30)
    switchContainer.Position = UDim2.new(1, -55, 0.5, -15)
    switchContainer.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    switchContainer.Text = ""
    switchContainer.BorderSizePixel = 0
    switchContainer.AutoButtonColor = false
    switchContainer.Parent = toggleFrame
    
    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(0.5, 0)
    switchCorner.Parent = switchContainer
    
    local switchCircle = Instance.new("Frame")
    switchCircle.Size = UDim2.new(0, 24, 0, 24)
    switchCircle.Position = UDim2.new(0, 3, 0.5, -12)
    switchCircle.BackgroundColor3 = Color3.new(1, 1, 1)
    switchCircle.BorderSizePixel = 0
    switchCircle.Parent = switchContainer
    
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(0.5, 0)
    circleCorner.Parent = switchCircle
    
    sphereToggle = switchContainer

    -- EVENTOS
    
    -- Abrir/Fechar menu
    menuButton.MouseButton1Click:Connect(function()
        CONFIG.menuOpen = not CONFIG.menuOpen
        
        if CONFIG.menuOpen then
            mainFrame.Visible = true
            mainFrame.Size = UDim2.new(0, 0, 0, 0)
            mainFrame.BackgroundTransparency = 1
            
            elasticTween(mainFrame, {
                Size = UDim2.new(0, 300, 0, 220),
                BackgroundTransparency = 0.02
            }, 0.6):Play()
            
            smoothTween(menuButton, {BackgroundColor3 = CONFIG.accentSecondary}, 0.3):Play()
            
            -- Animar elementos internos
            for _, child in ipairs(contentFrame:GetDescendants()) do
                if child:IsA("GuiObject") and child ~= contentFrame then
                    child.Visible = false
                end
            end
            
            local delay = 0
            for _, child in ipairs(contentFrame:GetChildren()) do
                task.delay(delay, function()
                    for _, subChild in ipairs(child:GetDescendants()) do
                        if subChild:IsA("GuiObject") then
                            subChild.Visible = true
                            if subChild:IsA("TextLabel") or subChild:IsA("TextButton") then
                                subChild.TextTransparency = 1
                                smoothTween(subChild, {TextTransparency = 0}, 0.4):Play()
                            elseif subChild:IsA("Frame") and subChild.Name ~= "Shadow" then
                                subChild.BackgroundTransparency = 1
                                smoothTween(subChild, {BackgroundTransparency = 0}, 0.4):Play()
                            end
                        end
                    end
                end)
                delay += 0.05
            end
            
        else
            smoothTween(mainFrame, {
                Size = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1
            }, 0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In).Completed:Connect(function()
                mainFrame.Visible = false
            end)
            
            smoothTween(menuButton, {BackgroundColor3 = CONFIG.accentColor}, 0.3):Play()
        end
    end)

    closeBtn.MouseButton1Click:Connect(function()
        CONFIG.menuOpen = false
        smoothTween(mainFrame, {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        }, 0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In).Completed:Connect(function()
            mainFrame.Visible = false
        end)
        smoothTween(menuButton, {BackgroundColor3 = CONFIG.accentColor}, 0.3):Play()
    end)

        -- Controles de Reach
    local function updateReachDisplay()
        reachLabel.Text = tostring(CONFIG.reach)
        elasticTween(reachLabel, {TextSize = 38}, 0.15).Completed:Connect(function()
            smoothTween(reachLabel, {TextSize = 32}, 0.3):Play()
        end)
        reachLabel.TextColor3 = CONFIG.accentSecondary
        smoothTween(reachLabel, {TextColor3 = CONFIG.accentColor}, 0.5):Play()
    end

    minus.MouseButton1Click:Connect(function()
        if CONFIG.reach > 1 then
            CONFIG.reach -= 1
            updateReachDisplay()
            updateReachSphere()
            smoothTween(minus, {BackgroundColor3 = Color3.fromRGB(255, 100, 100)}, 0.1).Completed:Connect(function()
                smoothTween(minus, {BackgroundColor3 = CONFIG.bgLight}, 0.2):Play()
            end)
        end
    end)

    plus.MouseButton1Click:Connect(function()
        CONFIG.reach += 1
        updateReachDisplay()
        updateReachSphere()
        smoothTween(plus, {BackgroundColor3 = Color3.fromRGB(100, 255, 150)}, 0.1).Completed:Connect(function()
            smoothTween(plus, {BackgroundColor3 = CONFIG.bgLight}, 0.2):Play()
        end)
    end)

    -- Toggle Sphere
    switchContainer.MouseButton1Click:Connect(function()
        CONFIG.showReachSphere = not CONFIG.showReachSphere
        
        if CONFIG.showReachSphere then
            smoothTween(switchContainer, {BackgroundColor3 = Color3.fromRGB(0, 200, 100)}, 0.3):Play()
            smoothTween(switchCircle, {Position = UDim2.new(0, 3, 0.5, -12)}, 0.3, Enum.EasingStyle.Quint):Play()
        else
            smoothTween(switchContainer, {BackgroundColor3 = Color3.fromRGB(200, 50, 50)}, 0.3):Play()
            smoothTween(switchCircle, {Position = UDim2.new(1, -27, 0.5, -12)}, 0.3, Enum.EasingStyle.Quint):Play()
        end
        
        updateReachSphere()
    end)

    -- ARRASTAR LIVREMENTE - SEM RESTRIÇÕES
    makeFreeDraggable(iconContainer, iconContainer)
    makeFreeDraggable(mainFrame, header)
end

-- AUTO TOUCH
local function processTouch()
    local char = player.Character
    if not char then return end

    for _, part in ipairs(getValidParts(char)) do
        for _, ball in ipairs(balls) do
            if ball and ball.Parent then
                if (ball.Position - part.Position).Magnitude <= CONFIG.reach then
                    pcall(function()
                        firetouchinterest(ball, part, 0)
                        firetouchinterest(ball, part, 1)
                    end)
                end
            end
        end
    end
end

-- LOOPS
RunService.RenderStepped:Connect(function()
    updateReachSphere()
    if CONFIG.autoSecondTouch then
        processTouch()
    end
end)

task.spawn(function()
    while true do
        refreshBalls(false)
        task.wait(CONFIG.scanCooldown)
    end
end)

-- INICIALIZAÇÃO
buildGUI()
updateReachSphere()
refreshBalls(true)
notify("⚽ Cadu Hub Premium Ativo!", 4)
print("✅ Cadu Hub Premium carregado com sucesso!")
