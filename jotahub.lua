-- SERVICES
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

-- CONFIG
local CONFIG = {
    reach = 10,
    magnetStrength = 0,
    showReachSphere = true,
    showCenterSphere = true,
    autoSecondTouch = true,
    scanCooldown = 1.5,
    ballNames = { "TPS", "ESA", "MRS", "PRS", "MPS", "SSS", "AIFA", "RBZ" },
}

-- VARIÁVEIS
local balls = {}
local lastRefresh = 0
local reachSphere
local gui, reachLabel, mainFrame, sphereToggleBtn
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

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

-- TOGGLE ESFERA CENTRAL
local function toggleCenterSphere()
    CONFIG.showCenterSphere = not CONFIG.showCenterSphere
    
    if reachSphere then
        if CONFIG.showCenterSphere then
            reachSphere.Transparency = 0.8
        else
            reachSphere.Transparency = 1
        end
    end
    
    if sphereToggleBtn then
        sphereToggleBtn.Text = CONFIG.showCenterSphere and "ESFERA ON" or "ESFERA OFF"
        sphereToggleBtn.BackgroundColor3 = CONFIG.showCenterSphere and Color3.fromRGB(0, 255, 136) or Color3.fromRGB(255, 50, 50)
    end
    
    notify(CONFIG.showCenterSphere and "Esfera visível" or "Esfera escondida", 1.5)
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
        reachSphere.Transparency = CONFIG.showCenterSphere and 0.8 or 1
        reachSphere.Material = Enum.Material.ForceField
        reachSphere.Color = Color3.fromRGB(0, 255, 136)
        reachSphere.Parent = Workspace

        RunService.RenderStepped:Connect(function()
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if hrp and reachSphere then
                reachSphere.Position = hrp.Position
            end
        end)
    end

    reachSphere.Size = Vector3.new(CONFIG.reach*2, CONFIG.reach*2, CONFIG.reach*2)
end

-- GUI PRINCIPAL - ESTILO NOVO
local function buildMainGUI()
    if gui then return end

    gui = Instance.new("ScreenGui")
    gui.Name = "CaduHubGUI"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")

    -- Frame principal com fundo escuro estilo cyber
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.fromScale(0.22, 0.22) -- Mesmo tamanho
    mainFrame.Position = UDim2.fromScale(0.02, 0.05)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35) -- Fundo escuro azulado
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = gui

    -- Borda neon
    local stroke = Instance.new("UIStroke", mainFrame)
    stroke.Color = Color3.fromRGB(0, 255, 136) -- Verde neon
    stroke.Thickness = 2

    -- Canto arredondado
    local corner = Instance.new("UICorner", mainFrame)
    corner.CornerRadius = UDim.new(0, 12) -- Cantos mais suaves

    -- Gradiente sutil no fundo
    local gradient = Instance.new("UIGradient", mainFrame)
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 45)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 30))
    })
    gradient.Rotation = 45

    -- Título estilizado
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -10, 0.14, 0)
    title.Position = UDim2.new(0, 5, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = "CADU HUB"
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold -- Fonte mais moderna
    title.TextColor3 = Color3.fromRGB(0, 255, 136) -- Verde neon
    title.Parent = mainFrame

    -- Linha divisória abaixo do título
    local line = Instance.new("Frame")
    line.Size = UDim2.new(0.8, 0, 0, 2)
    line.Position = UDim2.new(0.1, 0, 0.16, 0)
    line.BackgroundColor3 = Color3.fromRGB(0, 255, 136)
    line.BorderSizePixel = 0
    line.Parent = mainFrame

    -- Label do reach
    reachLabel = Instance.new("TextLabel")
    reachLabel.Size = UDim2.new(1, 0, 0.12, 0)
    reachLabel.Position = UDim2.new(0, 0, 0.20, 0)
    reachLabel.BackgroundTransparency = 1
    reachLabel.Text = "REACH: "..CONFIG.reach
    reachLabel.TextScaled = true
    reachLabel.Font = Enum.Font.GothamSemibold
    reachLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    reachLabel.Parent = mainFrame

    -- Container para botões + e -
    local btnContainer = Instance.new("Frame")
    btnContainer.Size = UDim2.new(0.9, 0, 0.18, 0)
    btnContainer.Position = UDim2.new(0.05, 0, 0.36, 0)
    btnContainer.BackgroundTransparency = 1
    btnContainer.Parent = mainFrame

    -- Botão MINUS estilizado
    local minus = Instance.new("TextButton")
    minus.Size = UDim2.new(0.45, 0, 1, 0)
    minus.Position = UDim2.new(0, 0, 0, 0)
    minus.Text = "−" -- Símbolo de menos mais bonito
    minus.TextSize = 24
    minus.Font = Enum.Font.GothamBold
    minus.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    minus.TextColor3 = Color3.fromRGB(255, 80, 80) -- Vermelho suave
    minus.Parent = btnContainer
    minus.AutoButtonColor = false
    
    local minusCorner = Instance.new("UICorner", minus)
    minusCorner.CornerRadius = UDim.new(0, 8)
    
    -- Efeito hover minus
    minus.MouseEnter:Connect(function()
        minus.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    end)
    minus.MouseLeave:Connect(function()
        minus.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    end)

    -- Botão PLUS estilizado
    local plus = Instance.new("TextButton")
    plus.Size = UDim2.new(0.45, 0, 1, 0)
    plus.Position = UDim2.new(0.55, 0, 0, 0)
    plus.Text = "+"
    plus.TextSize = 24
    plus.Font = Enum.Font.GothamBold
    plus.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    plus.TextColor3 = Color3.fromRGB(0, 255, 136) -- Verde neon
    plus.Parent = btnContainer
    plus.AutoButtonColor = false
    
    local plusCorner = Instance.new("UICorner", plus)
    plusCorner.CornerRadius = UDim.new(0, 8)
    
    -- Efeito hover plus
    plus.MouseEnter:Connect(function()
        plus.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    end)
    plus.MouseLeave:Connect(function()
        plus.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    end)

    -- Botão TOGGLE ESFERA estilizado
    sphereToggleBtn = Instance.new("TextButton")
    sphereToggleBtn.Size = UDim2.new(0.9, 0, 0.16, 0)
    sphereToggleBtn.Position = UDim2.new(0.05, 0, 0.58, 0)
    sphereToggleBtn.Text = "ESFERA ON"
    sphereToggleBtn.TextSize = 14
    sphereToggleBtn.Font = Enum.Font.GothamBold
    sphereToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 136)
    sphereToggleBtn.TextColor3 = Color3.fromRGB(25, 25, 35)
    sphereToggleBtn.Parent = mainFrame
    sphereToggleBtn.AutoButtonColor = false
    
    local sphereCorner = Instance.new("UICorner", sphereToggleBtn)
    sphereCorner.CornerRadius = UDim.new(0, 8)
    
    -- Efeito hover esfera
    sphereToggleBtn.MouseEnter:Connect(function()
        if CONFIG.showCenterSphere then
            sphereToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 255, 150)
        else
            sphereToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        end
    end)
    sphereToggleBtn.MouseLeave:Connect(function()
        if CONFIG.showCenterSphere then
            sphereToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 136)
        else
            sphereToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        end
    end)

    -- Botão ESCONDER estilizado
    local hideBtn = Instance.new("TextButton")
    hideBtn.Size = UDim2.new(0.9, 0, 0.16, 0)
    hideBtn.Position = UDim2.new(0.05, 0, 0.78, 0)
    hideBtn.Text = isMobile and "FECHAR" or "ESCONDER [INSERT]"
    hideBtn.TextSize = 12
    hideBtn.Font = Enum.Font.GothamSemibold
    hideBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    hideBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
    hideBtn.Parent = mainFrame
    hideBtn.AutoButtonColor = false
    
    local hideCorner = Instance.new("UICorner", hideBtn)
    hideCorner.CornerRadius = UDim.new(0, 8)
    
    -- Efeito hover hide
    hideBtn.MouseEnter:Connect(function()
        hideBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 95)
    end)
    hideBtn.MouseLeave:Connect(function()
        hideBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    end)

    -- FUNÇÕES DOS BOTÕES (inalteradas)
    minus.MouseButton1Click:Connect(function()
        CONFIG.reach = math.max(1, CONFIG.reach - 1)
        reachLabel.Text = "REACH: "..CONFIG.reach
        updateReachSphere()
        notify("Reach: "..CONFIG.reach, 1)
    end)

    plus.MouseButton1Click:Connect(function()
        CONFIG.reach += 1
        reachLabel.Text = "REACH: "..CONFIG.reach
        updateReachSphere()
        notify("Reach: "..CONFIG.reach, 1)
    end)

    sphereToggleBtn.MouseButton1Click:Connect(toggleCenterSphere)
    
    hideBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        if isMobile then
            notify("Use o botão flutuante", 2)
        else
            notify("Pressione INSERT", 2)
        end
    end)
end

-- BOTÃO FLUTUANTE MOBILE - ESTILO NOVO
local function buildMobileButton()
    local mobileGui = Instance.new("ScreenGui")
    mobileGui.Name = "CaduMobileBtn"
    mobileGui.ResetOnSpawn = false
    mobileGui.Parent = player:WaitForChild("PlayerGui")

    local floatBtn = Instance.new("TextButton")
    floatBtn.Name = "FloatButton"
    floatBtn.Size = UDim2.new(0, 65, 0, 65)
    floatBtn.Position = UDim2.new(1, -85, 1, -140)
    floatBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    floatBtn.Text = "CADU\nHUB"
    floatBtn.TextSize = 11
    floatBtn.Font = Enum.Font.GothamBold
    floatBtn.TextColor3 = Color3.fromRGB(0, 255, 136)
    floatBtn.Parent = mobileGui
    floatBtn.Active = true
    floatBtn.Draggable = true
    floatBtn.AutoButtonColor = false

    -- Borda neon no botão mobile
    local btnStroke = Instance.new("UIStroke", floatBtn)
    btnStroke.Color = Color3.fromRGB(0, 255, 136)
    btnStroke.Thickness = 2

    -- Círculo perfeito
    local btnCorner = Instance.new("UICorner", floatBtn)
    btnCorner.CornerRadius = UDim.new(1, 0)

    -- Efeito de brilho interno
    local btnGradient = Instance.new("UIGradient", floatBtn)
    btnGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 30))
    })

    -- Efeito pressionado
    floatBtn.MouseButton1Down:Connect(function()
        floatBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 136)
        floatBtn.TextColor3 = Color3.fromRGB(25, 25, 35)
    end)
    
    floatBtn.MouseButton1Up:Connect(function()
        floatBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        floatBtn.TextColor3 = Color3.fromRGB(0, 255, 136)
    end)

    floatBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
    end)
end

-- TECLA INSERT (PC apenas)
if not isMobile then
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
            if mainFrame then
                mainFrame.Visible = not mainFrame.Visible
            end
        end
    end)
end

-- AUTO TOUCH (inalterado)
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

-- LOOPS (inalterados)
RunService.RenderStepped:Connect(function()
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
buildMainGUI()
if isMobile then
    buildMobileButton()
    notify("📱 Modo Mobile Ativo", 3)
else
    notify("💻 Modo PC Ativo", 3)
end
updateReachSphere()
refreshBalls(true)
notify("✅ Cadu Hub Online", 3)
print("Cadu Hub OK | Mobile:", isMobile)


