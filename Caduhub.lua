-- Cadu Hub | The Classic Soccer
-- Design minimalista com animações fluidas

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- CONFIG
local CONFIG = {
    reach = 10,
    showReachSphere = true,
    autoSecondTouch = true,
    scanCooldown = 1.5,
    ballNames = { "TPS", "ESA", "MRS", "PRS", "MPS", "SSS", "AIFA", "RBZ" },
    menuOpen = false,
    accentColor = Color3.fromRGB(0, 170, 255),
    bgColor = Color3.fromRGB(20, 20, 25),
    textColor = Color3.fromRGB(255, 255, 255)
}

-- VARIÁVEIS
local balls = {}
local lastRefresh = 0
local reachSphere
local gui, mainFrame, menuButton, reachLabel, sphereToggle, contentFrame

-- BALL SET
local BALL_NAME_SET = {}
for _, n in ipairs(CONFIG.ballNames) do
    BALL_NAME_SET[n] = true
end

-- NOTIFY
local function notify(txt, t)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Cadu Hub",
            Text = txt,
            Duration = t or 2
        })
    end)
end

-- REFRESH BALLS
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

-- REACH SPHERE
local function updateReachSphere()
    if not CONFIG.showReachSphere then
        if reachSphere then reachSphere:Destroy() end
        reachSphere = nil
        return
    end

    if not reachSphere then
        reachSphere = Instance.new("Part")
        reachSphere.Name = "CaduReachSphere"
        reachSphere.Shape = Enum.PartType.Ball
        reachSphere.Anchored = true
        reachSphere.CanCollide = false
        reachSphere.Transparency = 0.9
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

-- ANIMAÇÕES SUAVES
local function smoothTween(obj, properties, duration, easingStyle, easingDirection)
    local tween = TweenService:Create(obj, TweenInfo.new(
        duration or 0.4,
        easingStyle or Enum.EasingStyle.Quint,
        easingDirection or Enum.EasingDirection.Out
    ), properties)
    tween:Play()
    return tween
end

local function popIn(obj, delay)
    obj.Size = UDim2.new(0, 0, 0, 0)
    obj.Visible = true
    task.delay(delay or 0, function()
        smoothTween(obj, {Size = obj:GetAttribute("OriginalSize")}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end)
end

local function fadeOut(obj, duration)
    smoothTween(obj, {BackgroundTransparency = 1, TextTransparency = 1}, duration or 0.3)
    for _, v in ipairs(obj:GetDescendants()) do
        if v:IsA("GuiObject") then
            if v:IsA("TextLabel") or v:IsA("TextButton") then
                smoothTween(v, {TextTransparency = 1}, duration or 0.3)
            elseif v:IsA("Frame") then
                smoothTween(v, {BackgroundTransparency = 1}, duration or 0.3)
            end
        end
    end
end

-- DRAG FUNCTION APRIMORADO
local function makeDraggable(frame, handle)
    local dragging = false
    local dragStart, startPos
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            -- Efeito de pressionado
            smoothTween(handle, {BackgroundColor3 = handle.BackgroundColor3:Lerp(Color3.new(0,0,0), 0.2)}, 0.1)
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    smoothTween(handle, {BackgroundColor3 = handle:GetAttribute("OriginalColor") or handle.BackgroundColor3}, 0.2)
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X,
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- GUI MINIMALISTA E SUAVE
local function buildGUI()
    if gui then return end

    gui = Instance.new("ScreenGui")
    gui.Name = "CaduHubGUI"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    gui.Parent = player:WaitForChild("PlayerGui")

    -- BOTÃO FLUTUANTE (ÍCONE ARRASTÁVEL)
    menuButton = Instance.new("TextButton")
    menuButton.Name = "MenuButton"
    menuButton.Size = UDim2.new(0, 50, 0, 50)
    menuButton.Position = UDim2.new(0.9, -60, 0.1, 0)
    menuButton.BackgroundColor3 = CONFIG.accentColor
    menuButton.Text = "⚽"
    menuButton.TextSize = 24
    menuButton.Font = Enum.Font.GothamBold
    menuButton.TextColor3 = CONFIG.textColor
    menuButton.BorderSizePixel = 0
    menuButton.AutoButtonColor = false
    menuButton.Parent = gui
    menuButton:SetAttribute("OriginalColor", CONFIG.accentColor)
    
    -- Sombra suave do botão
    local btnShadow = Instance.new("ImageLabel")
    btnShadow.Name = "Shadow"
    btnShadow.Size = UDim2.new(1, 10, 1, 10)
    btnShadow.Position = UDim2.new(0, -5, 0, -5)
    btnShadow.BackgroundTransparency = 1
    btnShadow.Image = "rbxassetid://131296141"
    btnShadow.ImageColor3 = Color3.new(0, 0, 0)
    btnShadow.ImageTransparency = 0.7
    btnShadow.ScaleType = Enum.ScaleType.Slice
    btnShadow.SliceCenter = Rect.new(10, 10, 118, 118)
    btnShadow.ZIndex = menuButton.ZIndex - 1
    btnShadow.Parent = menuButton
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0.5, 0)
    btnCorner.Parent = menuButton
    
    -- Efeito hover no botão
    menuButton.MouseEnter:Connect(function()
        smoothTween(menuButton, {Size = UDim2.new(0, 55, 0, 55), BackgroundColor3 = Color3.fromRGB(0, 200, 255)}, 0.3)
    end)
    
    menuButton.MouseLeave:Connect(function()
        smoothTween(menuButton, {Size = UDim2.new(0, 50, 0, 50), BackgroundColor3 = CONFIG.accentColor}, 0.3)
    end)

    -- FRAME PRINCIPAL (MENU MINIMALISTA)
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 220, 0, 160)
    mainFrame.Position = UDim2.new(0.5, -110, 0.5, -80)
    mainFrame.BackgroundColor3 = CONFIG.bgColor
    mainFrame.BackgroundTransparency = 0.05
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = gui
    mainFrame:SetAttribute("OriginalSize", UDim2.new(0, 220, 0, 160))

    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 16)
    frameCorner.Parent = mainFrame

    -- Sombra do menu
    local frameShadow = Instance.new("ImageLabel")
    frameShadow.Name = "Shadow"
    frameShadow.Size = UDim2.new(1, 30, 1, 30)
    frameShadow.Position = UDim2.new(0, -15, 0, -15)
    frameShadow.BackgroundTransparency = 1
    frameShadow.Image = "rbxassetid://131296141"
    frameShadow.ImageColor3 = Color3.new(0, 0, 0)
    frameShadow.ImageTransparency = 0.6
    frameShadow.ScaleType = Enum.ScaleType.Slice
    frameShadow.SliceCenter = Rect.new(10, 10, 118, 118)
    frameShadow.ZIndex = mainFrame.ZIndex - 1
    frameShadow.Parent = mainFrame

    -- CABEÇALHO ARRASTÁVEL
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 35)
    header.BackgroundColor3 = CONFIG.accentColor
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    header:SetAttribute("OriginalColor", CONFIG.accentColor)

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 16)
    headerCorner.Parent = header
    
    -- Fixar cantos superiores apenas
    local headerFix = Instance.new("Frame")
    headerFix.Size = UDim2.new(1, 0, 0.5, 0)
    headerFix.Position = UDim2.new(0, 0, 0.5, 0)
    headerFix.BackgroundColor3 = CONFIG.accentColor
    headerFix.BorderSizePixel = 0
    headerFix.Parent = header

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -50, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Cadu Hub"
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.TextColor3 = CONFIG.textColor
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    -- BOTÃO FECHAR (X minimalista)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0.5, -15)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "×"
    closeBtn.TextSize = 24
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextColor3 = CONFIG.textColor
    closeBtn.Parent = header
    
    closeBtn.MouseEnter:Connect(function()
        smoothTween(closeBtn, {TextColor3 = Color3.fromRGB(255, 100, 100)}, 0.2)
    end)
    closeBtn.MouseLeave:Connect(function()
        smoothTween(closeBtn, {TextColor3 = CONFIG.textColor}, 0.2)
    end)

    -- CONTEÚDO COM LAYOUT SUAVE
    contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, 0, 1, -35)
    contentFrame.Position = UDim2.new(0, 0, 0, 35)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame

    -- DISPLAY DE REACH (Estilo moderno)
    local reachContainer = Instance.new("Frame")
    reachContainer.Size = UDim2.new(1, -30, 0, 40)
    reachContainer.Position = UDim2.new(0, 15, 0, 15)
    reachContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    reachContainer.BorderSizePixel = 0
    reachContainer.Parent = contentFrame
    
    local reachCorner = Instance.new("UICorner")
    reachCorner.CornerRadius = UDim.new(0, 10)
    reachCorner.Parent = reachContainer

    reachLabel = Instance.new("TextLabel")
    reachLabel.Size = UDim2.new(1, 0, 1, 0)
    reachLabel.BackgroundTransparency = 1
    reachLabel.Text = "Reach: " .. CONFIG.reach
    reachLabel.TextSize = 16
    reachLabel.Font = Enum.Font.GothamBold
    reachLabel.TextColor3 = CONFIG.accentColor
    reachLabel.Parent = reachContainer

    -- BOTÕES + E - (Design minimalista)
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Size = UDim2.new(1, -30, 0, 45)
    buttonContainer.Position = UDim2.new(0, 15, 0, 65)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = contentFrame

    local minus = Instance.new("TextButton")
    minus.Size = UDim2.new(0.48, 0, 1, 0)
    minus.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    minus.Text = "−"
    minus.TextSize = 20
    minus.Font = Enum.Font.GothamBold
    minus.TextColor3 = CONFIG.textColor
    minus.BorderSizePixel = 0
    minus.AutoButtonColor = false
    minus.Parent = buttonContainer
    
    local minusCorner = Instance.new("UICorner")
    minusCorner.CornerRadius = UDim.new(0, 10)
    minusCorner.Parent = minus

    local plus = Instance.new("TextButton")
    plus.Size = UDim2.new(0.48, 0, 1, 0)
    plus.Position = UDim2.new(0.52, 0, 0, 0)
    plus.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    plus.Text = "+"
    plus.TextSize = 20
    plus.Font = Enum.Font.GothamBold
    plus.TextColor3 = CONFIG.textColor
    plus.BorderSizePixel = 0
    plus.AutoButtonColor = false
    plus.Parent = buttonContainer
    
    local plusCorner = Instance.new("UICorner")
    plusCorner.CornerRadius = UDim.new(0, 10)
    plusCorner.Parent = plus

    -- Efeitos hover nos botões
    local function setupButtonHover(btn, originalColor)
        btn.MouseEnter:Connect(function()
            smoothTween(btn, {BackgroundColor3 = CONFIG.accentColor}, 0.2)
        end)
        btn.MouseLeave:Connect(function()
            smoothTween(btn, {BackgroundColor3 = originalColor}, 0.2)
        end)
        btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                smoothTween(btn, {Size = UDim2.new(btn.Size.X.Scale * 0.95, 0, 0.95, 0)}, 0.1)
            end
        end)
        btn.InputEnded:Connect(function()
            smoothTween(btn, {Size = UDim2.new(0.48, 0, 1, 0)}, 0.1)
        end)
    end

    setupButtonHover(minus, Color3.fromRGB(45, 45, 50))
    setupButtonHover(plus, Color3.fromRGB(45, 45, 50))

    -- TOGGLE SPHERE (Switch moderno)
    local toggleContainer = Instance.new("Frame")
    toggleContainer.Size = UDim2.new(1, -30, 0, 35)
    toggleContainer.Position = UDim2.new(0, 15, 0, 115)
    toggleContainer.BackgroundTransparency = 1
    toggleContainer.Parent = contentFrame

    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Size = UDim2.new(0.6, 0, 1, 0)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Text = "Show Sphere"
    toggleLabel.TextSize = 14
    toggleLabel.Font = Enum.Font.Gotham
    toggleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.Parent = toggleContainer

    -- Switch visual
    local switchBg = Instance.new("Frame")
    switchBg.Size = UDim2.new(0, 50, 0, 26)
    switchBg.Position = UDim2.new(1, -50, 0.5, -13)
    switchBg.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    switchBg.BorderSizePixel = 0
    switchBg.Parent = toggleContainer
    
    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(0.5, 0)
    switchCorner.Parent = switchBg

    local switchCircle = Instance.new("Frame")
    switchCircle.Size = UDim2.new(0, 22, 0, 22)
    switchCircle.Position = UDim2.new(0, 2, 0.5, -11)
    switchCircle.BackgroundColor3 = Color3.new(1, 1, 1)
    switchCircle.BorderSizePixel = 0
    switchCircle.Parent = switchBg
    
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(0.5, 0)
    circleCorner.Parent = switchCircle

    sphereToggle = switchBg

    -- EVENTOS COM ANIMAÇÕES SUAVES
    menuButton.MouseButton1Click:Connect(function()
        CONFIG.menuOpen = not CONFIG.menuOpen
        
        if CONFIG.menuOpen then
            -- Animação de abertura suave
            mainFrame.Visible = true
            mainFrame.Size = UDim2.new(0, 0, 0, 0)
            mainFrame.BackgroundTransparency = 1
            
            smoothTween(mainFrame, {
                Size = UDim2.new(0, 220, 0, 160),
                BackgroundTransparency = 0.05
            }, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            
            -- Animação do botão
            smoothTween(menuButton, {BackgroundColor3 = Color3.fromRGB(0, 255, 150)}, 0.3)
            
            -- Animação dos elementos internos
            for _, child in ipairs(contentFrame:GetDescendants()) do
                if child:IsA("GuiObject") and child ~= contentFrame then
                    child.Visible = false
                end
            end
            
            task.delay(0.2, function()
                for _, child in ipairs(contentFrame:GetDescendants()) do
                    if child:IsA("GuiObject") and child ~= contentFrame then
                        child.Visible = true
                        if child:IsA("TextLabel") or child:IsA("TextButton") then
                            child.TextTransparency = 1
                            smoothTween(child, {TextTransparency = 0}, 0.3)
                        elseif child:IsA("Frame") then
                            child.BackgroundTransparency = 1
                            smoothTween(child, {BackgroundTransparency = child.Name == "Shadow" and 0.6 or 0}, 0.3)
                        end
                    end
                end
            end)
        else
            -- Animação de fechamento suave
            smoothTween(mainFrame, {
                Size = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1
            }, 0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In).Completed:Connect(function()
                mainFrame.Visible = false
            end)
            
            smoothTween(menuButton, {BackgroundColor3 = CONFIG.accentColor}, 0.3)
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
        smoothTween(menuButton, {BackgroundColor3 = CONFIG.accentColor}, 0.3)
    end)

    -- Controles de Reach com animação de contador
    local function updateReachDisplay()
        reachLabel.Text = "Reach: " .. CONFIG.reach
        -- Animação de pulo no número
        smoothTween(reachLabel, {TextSize = 20}, 0.1).Completed:Connect(function()
            smoothTween(reachLabel, {TextSize = 16}, 0.2)
        end)
    end

    minus.MouseButton1Click:Connect(function()
        CONFIG.reach = math.max(1, CONFIG.reach - 1)
        updateReachDisplay()
        updateReachSphere()
        notify("Reach: " .. CONFIG.reach, 1)
    end)

    plus.MouseButton1Click:Connect(function()
        CONFIG.reach += 1
        updateReachDisplay()
        updateReachSphere()
        notify("Reach: " .. CONFIG.reach, 1)
    end)

    -- Toggle Sphere com animação de switch
    sphereToggle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            CONFIG.showReachSphere = not CONFIG.showReachSphere
            
            if CONFIG.showReachSphere then
                smoothTween(switchBg, {BackgroundColor3 = Color3.fromRGB(0, 170, 0)}, 0.3)
                smoothTween(switchCircle, {Position = UDim2.new(0, 2, 0.5, -11)}, 0.3, Enum.EasingStyle.Quint)
            else
                smoothTween(switchBg, {BackgroundColor3 = Color3.fromRGB(170, 0, 0)}, 0.3)
                smoothTween(switchCircle, {Position = UDim2.new(0, 26, 0.5, -11)}, 0.3, Enum.EasingStyle.Quint)
            end
            
            updateReachSphere()
        end
    end)

    -- TORNAR ARRASTÁVEL
    makeDraggable(mainFrame, header)
    makeDraggable(menuButton, menuButton)
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

-- INIT
buildGUI()
updateReachSphere()
refreshBalls(true)
notify("⚽ Cadu Hub Online!", 3)
print("Cadu Hub executado com sucesso!")
