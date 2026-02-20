-- Cadu Hub | The Classic Soccer
-- Script completo e funcional

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- CONFIGURAÇÕES
local CONFIG = {
    reach = 10,
    showReachSphere = true,
    autoSecondTouch = true,
    scanCooldown = 1.5,
    ballNames = { "TPS", "ESA", "MRS", "PRS", "MPS", "SSS", "AIFA", "RBZ" },
    menuOpen = false,
    accentColor = Color3.fromRGB(0, 180, 255),
    accentSecondary = Color3.fromRGB(0, 255, 180),
    bgColor = Color3.fromRGB(15, 15, 20),
    bgLight = Color3.fromRGB(35, 35, 45),
    textColor = Color3.fromRGB(255, 255, 255),
    textDark = Color3.fromRGB(180, 180, 190)
}

-- VARIÁVEIS
local balls = {}
local lastRefresh = 0
local reachSphere
local gui, mainFrame, menuButton, reachLabel, iconContainer

-- BALL SET
local BALL_NAME_SET = {}
for _, n in ipairs(CONFIG.ballNames) do
    BALL_NAME_SET[n] = true
end

-- NOTIFICAÇÃO
local function notify(txt, t)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "⚽ Cadu Hub",
            Text = txt,
            Duration = t or 3
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
            table.insert(balls, v)
        end
    end
end

-- PARTES DO CORPO
local function getValidParts(char)
    local parts = {}
    for _, v in ipairs(char:GetChildren()) do
        if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
            table.insert(parts, v)
        end
    end
    return parts
end

-- ESFERA DE ALCANCE
local function updateReachSphere()
    if not CONFIG.showReachSphere then
        if reachSphere then 
            reachSphere:Destroy()
            reachSphere = nil
        end
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

    reachSphere.Size = Vector3.new(CONFIG.reach * 2, CONFIG.reach * 2, CONFIG.reach * 2)
end

-- TWEEN HELPER
local function tween(obj, props, dur, style, dir)
    local info = TweenInfo.new(dur or 0.3, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

-- ARRASTO LIVRE SEM RESTRIÇÕES
local function makeDraggable(frame, handle)
    local dragging = false
    local dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            -- Feedback visual
            if handle:IsA("GuiObject") then
                tween(handle, {BackgroundColor3 = handle.BackgroundColor3:Lerp(Color3.new(0,0,0), 0.2)}, 0.1)
            end
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

    handle.InputEnded:Connect(function()
        if dragging then
            dragging = false
            if handle:IsA("GuiObject") then
                tween(handle, {BackgroundColor3 = handle:GetAttribute("OriginalColor") or CONFIG.accentColor}, 0.2)
            end
        end
    end)
end

-- CRIAR INTERFACE
local function buildGUI()
    if gui then return end

    gui = Instance.new("ScreenGui")
    gui.Name = "CaduHubGUI"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = player:WaitForChild("PlayerGui")

    -- CONTAINER DO ÍCONE (ÁREA DE TOQUE MAIOR)
    iconContainer = Instance.new("Frame")
    iconContainer.Name = "IconContainer"
    iconContainer.Size = UDim2.new(0, 70, 0, 70)
    iconContainer.Position = UDim2.new(1, -100, 0.1, 0)
    iconContainer.BackgroundTransparency = 1
    iconContainer.Parent = gui

    -- BOTÃO DO ÍCONE (VISUAL)
    menuButton = Instance.new("TextButton")
    menuButton.Name = "MenuButton"
    menuButton.Size = UDim2.new(0, 50, 0, 50)
    menuButton.Position = UDim2.new(0.5, -25, 0.5, -25)
    menuButton.BackgroundColor3 = CONFIG.accentColor
    menuButton.Text = "⚽"
    menuButton.TextSize = 24
    menuButton.Font = Enum.Font.GothamBold
    menuButton.TextColor3 = CONFIG.textColor
    menuButton.BorderSizePixel = 0
    menuButton.AutoButtonColor = false
    menuButton.Parent = iconContainer
    
    menuButton:SetAttribute("OriginalColor", CONFIG.accentColor)

    -- CANTOS ARREDONDADOS
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.5, 0)
    corner.Parent = menuButton

    -- SOMBRA
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://131296141"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.7
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.ZIndex = menuButton.ZIndex - 1
    shadow.Parent = menuButton

    -- MENU PRINCIPAL
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 280, 0, 200)
    mainFrame.Position = UDim2.new(0.5, -140, 0.5, -100)
    mainFrame.BackgroundColor3 = CONFIG.bgColor
    mainFrame.BackgroundTransparency = 0.05
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = gui

    -- CANTOS ARREDONDADOS DO MENU
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 16)
    frameCorner.Parent = mainFrame

    -- SOMBRA DO MENU
    local frameShadow = Instance.new("ImageLabel")
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

    -- CABEÇALHO
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = CONFIG.accentColor
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    header:SetAttribute("OriginalColor", CONFIG.accentColor)

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 16)
    headerCorner.Parent = header

    -- CORREÇÃO DOS CANTOS INFERIORES DO HEADER
    local headerFix = Instance.new("Frame")
    headerFix.Size = UDim2.new(1, 0, 0.5, 0)
    headerFix.Position = UDim2.new(0, 0, 0.5, 0)
    headerFix.BackgroundColor3 = CONFIG.accentColor
    headerFix.BorderSizePixel = 0
    headerFix.Parent = header

    -- TÍTULO
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -50, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "⚽ Cadu Hub"
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.TextColor3 = CONFIG.textColor
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    -- BOTÃO FECHAR
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0.5, -15)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
    closeBtn.Text = "×"
    closeBtn.TextSize = 20
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextColor3 = CONFIG.textColor
    closeBtn.BorderSizePixel = 0
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = header

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0.3, 0)
    closeCorner.Parent = closeBtn

    -- CONTEÚDO
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, -40)
    content.Position = UDim2.new(0, 0, 0, 40)
    content.BackgroundTransparency = 1
    content.Parent = mainFrame

    -- DISPLAY DO REACH
    local reachFrame = Instance.new("Frame")
    reachFrame.Size = UDim2.new(1, -30, 0, 50)
    reachFrame.Position = UDim2.new(0, 15, 0, 15)
    reachFrame.BackgroundColor3 = CONFIG.bgLight
    reachFrame.BorderSizePixel = 0
    reachFrame.Parent = content

    local reachCorner = Instance.new("UICorner")
    reachCorner.CornerRadius = UDim.new(0, 10)
    reachCorner.Parent = reachFrame

    local reachText = Instance.new("TextLabel")
    reachText.Size = UDim2.new(0.4, 0, 1, 0)
    reachText.Position = UDim2.new(0, 12, 0, 0)
    reachText.BackgroundTransparency = 1
    reachText.Text = "Alcance"
    reachText.TextSize = 14
    reachText.Font = Enum.Font.Gotham
    reachText.TextColor3 = CONFIG.textDark
    reachText.TextXAlignment = Enum.TextXAlignment.Left
    reachText.Parent = reachFrame

    reachLabel = Instance.new("TextLabel")
    reachLabel.Size = UDim2.new(0.6, -10, 1, 0)
    reachLabel.Position = UDim2.new(0.4, 0, 0, 0)
    reachLabel.BackgroundTransparency = 1
    reachLabel.Text = tostring(CONFIG.reach)
    reachLabel.TextSize = 28
    reachLabel.Font = Enum.Font.GothamBold
    reachLabel.TextColor3 = CONFIG.accentColor
    reachLabel.TextXAlignment = Enum.TextXAlignment.Right
    reachLabel.Parent = reachFrame

    -- BOTÕES DE CONTROLE
    local btnFrame = Instance.new("Frame")
    btnFrame.Size = UDim2.new(1, -30, 0, 45)
    btnFrame.Position = UDim2.new(0, 15, 0, 75)
    btnFrame.BackgroundTransparency = 1
    btnFrame.Parent = content

    -- BOTÃO MENOS
    local minus = Instance.new("TextButton")
    minus.Size = UDim2.new(0.48, 0, 1, 0)
    minus.BackgroundColor3 = CONFIG.bgLight
    minus.Text = "−"
    minus.TextSize = 22
    minus.Font = Enum.Font.GothamBold
    minus.TextColor3 = CONFIG.textColor
    minus.BorderSizePixel = 0
    minus.AutoButtonColor = false
    minus.Parent = btnFrame

    local minusCorner = Instance.new("UICorner")
    minusCorner.CornerRadius = UDim.new(0, 10)
    minusCorner.Parent = minus

    -- BOTÃO MAIS
    local plus = Instance.new("TextButton")
    plus.Size = UDim2.new(0.48, 0, 1, 0)
    plus.Position = UDim2.new(0.52, 0, 0, 0)
    plus.BackgroundColor3 = CONFIG.bgLight
    plus.Text = "+"
    plus.TextSize = 22
    plus.Font = Enum.Font.GothamBold
    plus.TextColor3 = CONFIG.textColor
    plus.BorderSizePixel = 0
    plus.AutoButtonColor = false
    plus.Parent = btnFrame

    local plusCorner = Instance.new("UICorner")
    plusCorner.CornerRadius = UDim.new(0, 10)
    plusCorner.Parent = plus

    -- TOGGLE ESFERA
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, -30, 0, 35)
    toggleFrame.Position = UDim2.new(0, 15, 0, 130)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = content

    local toggleText = Instance.new("TextLabel")
    toggleText.Size = UDim2.new(0.6, 0, 1, 0)
    toggleText.BackgroundTransparency = 1
    toggleText.Text = "Mostrar Esfera"
    toggleText.TextSize = 14
    toggleText.Font = Enum.Font.Gotham
    toggleText.TextColor3 = CONFIG.textDark
    toggleText.TextXAlignment = Enum.TextXAlignment.Left
    toggleText.Parent = toggleFrame

    -- SWITCH
    local switch = Instance.new("TextButton")
    switch.Size = UDim2.new(0, 50, 0, 26)
    switch.Position = UDim2.new(1, -50, 0.5, -13)
    switch.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
    switch.Text = ""
    switch.BorderSizePixel = 0
    switch.AutoButtonColor = false
    switch.Parent = toggleFrame

    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(0.5, 0)
    switchCorner.Parent = switch

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 22, 0, 22)
    circle.Position = UDim2.new(0, 2, 0.5, -11)
    circle.BackgroundColor3 = Color3.new(1, 1, 1)
    circle.BorderSizePixel = 0
    circle.Parent = switch

    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(0.5, 0)
    circleCorner.Parent = circle

    -- EVENTOS DO ÍCONE (ABRIR MENU)
    menuButton.MouseButton1Click:Connect(function()
        CONFIG.menuOpen = not CONFIG.menuOpen
        
        if CONFIG.menuOpen then
            -- ABRIR MENU
            mainFrame.Visible = true
            mainFrame.Size = UDim2.new(0, 0, 0, 0)
            mainFrame.BackgroundTransparency = 1
            
            -- Animação de abertura
            tween(mainFrame, {Size = UDim2.new(0, 280, 0, 200), BackgroundTransparency = 0.05}, 0.4, Enum.EasingStyle.Back)
            tween(menuButton, {BackgroundColor3 = CONFIG.accentSecondary}, 0.3)
            
            -- Mostrar conteúdo com delay
            for _, obj in ipairs(content:GetDescendants()) do
                if obj:IsA("GuiObject") then
                    obj.Visible = false
                end
            end
            
            task.delay(0.2, function()
                for _, obj in ipairs(content:GetDescendants()) do
                    if obj:IsA("GuiObject") then
                        obj.Visible = true
                        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                            obj.TextTransparency = 1
                            tween(obj, {TextTransparency = 0}, 0.3)
                        elseif obj:IsA("Frame") and obj.Name ~= "Shadow" then
                            obj.BackgroundTransparency = 1
                            tween(obj, {BackgroundTransparency = 0}, 0.3)
                        end
                    end
                end
            end)
        else
            -- FECHAR MENU
            tween(mainFrame, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In).Completed:Connect(function()
                mainFrame.Visible = false
            end)
            tween(menuButton, {BackgroundColor3 = CONFIG.accentColor}, 0.3)
        end
    end)

    -- FECHAR PELO X
    closeBtn.MouseButton1Click:Connect(function()
        CONFIG.menuOpen = false
        tween(mainFrame, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In).Completed:Connect(function()
            mainFrame.Visible = false
        end)
        tween(menuButton, {BackgroundColor3 = CONFIG.accentColor}, 0.3)
    end)

    -- FUNÇÃO ATUALIZAR DISPLAY
    local function updateReach()
        reachLabel.Text = tostring(CONFIG.reach)
        tween(reachLabel, {TextSize = 32}, 0.1).Completed:Connect(function()
            tween(reachLabel, {TextSize = 28}, 0.2)
        end)
    end

    -- BOTÃO MENOS
    minus.MouseButton1Click:Connect(function()
        if CONFIG.reach > 1 then
            CONFIG.reach = CONFIG.reach - 1
            updateReach()
            updateReachSphere()
            
            tween(minus, {BackgroundColor3 = Color3.fromRGB(255, 100, 100)}, 0.1).Completed:Connect(function()
                tween(minus, {BackgroundColor3 = CONFIG.bgLight}, 0.2)
            end)
        end
    end)

    -- BOTÃO MAIS
    plus.MouseButton1Click:Connect(function()
        CONFIG.reach = CONFIG.reach + 1
        updateReach()
        updateReachSphere()
        
        tween(plus, {BackgroundColor3 = Color3.fromRGB(100, 255, 150)}, 0.1).Completed:Connect(function()
            tween(plus, {BackgroundColor3 = CONFIG.bgLight}, 0.2)
        end)
    end)

    -- TOGGLE ESFERA
    switch.MouseButton1Click:Connect(function()
        CONFIG.showReachSphere = not CONFIG.showReachSphere
        
        if CONFIG.showReachSphere then
            tween(switch, {BackgroundColor3 = Color3.fromRGB(0, 180, 100)}, 0.3)
            tween(circle, {Position = UDim2.new(0, 2, 0.5, -11)}, 0.3)
        else
            tween(switch, {BackgroundColor3 = Color3.fromRGB(200, 50, 50)}, 0.3)
            tween(circle, {Position = UDim2.new(1, -24, 0.5, -11)}, 0.3)
        end
        
        updateReachSphere()
    end)

    -- ARRASTAR (ÍCONE E MENU)
    makeDraggable(iconContainer, iconContainer)
    makeDraggable(mainFrame, header)
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

-- INICIALIZAR
buildGUI()
updateReachSphere()
refreshBalls(true)
notify("⚽ Cadu Hub Ativo!", 3)
print("✅ Cadu Hub carregado!")
