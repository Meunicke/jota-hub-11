-- SERVICES
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local GuiService = game:GetService("GuiService")

local player = Players.LocalPlayer

-- CONFIG
local CONFIG = {
    reach = 10,
    magnetStrength = 0,
    showReachSphere = true,      -- Controla visibilidade da esfera
    showCenterSphere = true,     -- NOVO: Controla a esfera central da hitbox
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
            Title = "JOTA HUB V10",
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
            reachSphere.CanCollide = false
        else
            reachSphere.Transparency = 1
        end
    end
    
    -- Atualiza texto do botão
    if sphereToggleBtn then
        sphereToggleBtn.Text = CONFIG.showCenterSphere and "🔵 ESFERA: ON" or "⚫ ESFERA: OFF"
        sphereToggleBtn.BackgroundColor3 = CONFIG.showCenterSphere and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(80, 80, 80)
    end
    
    notify(CONFIG.showCenterSphere and "🔵 Esfera central VISÍVEL" or "⚫ Esfera central ESCONDIDA", 1.5)
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
        reachSphere.Name = "JOTAReachSphere"
        reachSphere.Shape = Enum.PartType.Ball
        reachSphere.Anchored = true
        reachSphere.CanCollide = false
        reachSphere.Transparency = CONFIG.showCenterSphere and 0.8 or 1
        reachSphere.Material = Enum.Material.ForceField
        reachSphere.Color = Color3.fromRGB(0,85,255)
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

-- GUI PRINCIPAL (PC)
local function buildMainGUI()
    if gui then return end

    gui = Instance.new("ScreenGui")
    gui.Name = "JOTAHUBGUI"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")

    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.fromScale(0.22, 0.22)
    mainFrame.Position = UDim2.fromScale(0.02, 0.05)
    mainFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
    mainFrame.BackgroundTransparency = 0.35
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = gui

    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0.1,0)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,0,0.12,0)
    title.BackgroundTransparency = 1
    title.Text = "JOTA HUB V10"
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.TextColor3 = Color3.new(1,1,1)
    title.Parent = mainFrame

    reachLabel = Instance.new("TextLabel")
    reachLabel.Size = UDim2.new(1,0,0.12,0)
    reachLabel.Position = UDim2.new(0,0,0.12,0)
    reachLabel.BackgroundTransparency = 1
    reachLabel.Text = "Reach: "..CONFIG.reach
    reachLabel.TextScaled = true
    reachLabel.Font = Enum.Font.SourceSans
    reachLabel.TextColor3 = Color3.new(1,1,1)
    reachLabel.Parent = mainFrame

    local minus = Instance.new("TextButton")
    minus.Size = UDim2.new(0.4,0,0.2,0)
    minus.Position = UDim2.new(0.05,0,0.28,0)
    minus.Text = "-"
    minus.TextScaled = true
    minus.Font = Enum.Font.SourceSansBold
    minus.BackgroundColor3 = Color3.fromRGB(60,60,60)
    minus.TextColor3 = Color3.new(1,1,1)
    minus.Parent = mainFrame

    local plus = Instance.new("TextButton")
    plus.Size = UDim2.new(0.4,0,0.2,0)
    plus.Position = UDim2.new(0.55,0,0.28,0)
    plus.Text = "+"
    plus.TextScaled = true
    plus.Font = Enum.Font.SourceSansBold
    plus.BackgroundColor3 = Color3.fromRGB(60,60,60)
    plus.TextColor3 = Color3.new(1,1,1)
    plus.Parent = mainFrame

    -- Botão toggle esfera
    sphereToggleBtn = Instance.new("TextButton")
    sphereToggleBtn.Size = UDim2.new(0.9,0,0.18,0)
    sphereToggleBtn.Position = UDim2.new(0.05,0,0.52,0)
    sphereToggleBtn.Text = "🔵 ESFERA: ON"
    sphereToggleBtn.TextScaled = true
    sphereToggleBtn.Font = Enum.Font.SourceSansBold
    sphereToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    sphereToggleBtn.TextColor3 = Color3.new(1,1,1)
    sphereToggleBtn.Parent = mainFrame
    Instance.new("UICorner", sphereToggleBtn).CornerRadius = UDim.new(0.2,0)

    -- Botão esconder GUI
    local hideBtn = Instance.new("TextButton")
    hideBtn.Size = UDim2.new(0.9,0,0.18,0)
    hideBtn.Position = UDim2.new(0.05,0,0.74,0)
    hideBtn.Text = isMobile and "❌ FECHAR" or "❌ ESCONDER [INSERT]"
    hideBtn.TextScaled = true
    hideBtn.Font = Enum.Font.SourceSansBold
    hideBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
    hideBtn.TextColor3 = Color3.new(1,1,1)
    hideBtn.Parent = mainFrame
    Instance.new("UICorner", hideBtn).CornerRadius = UDim.new(0.2,0)

    minus.MouseButton1Click:Connect(function()
        CONFIG.reach = math.max(1, CONFIG.reach - 1)
        reachLabel.Text = "Reach: "..CONFIG.reach
        updateReachSphere()
        notify("Reach: "..CONFIG.reach,1)
    end)

    plus.MouseButton1Click:Connect(function()
        CONFIG.reach += 1
        reachLabel.Text = "Reach: "..CONFIG.reach
        updateReachSphere()
        notify("Reach: "..CONFIG.reach,1)
    end)

    sphereToggleBtn.MouseButton1Click:Connect(toggleCenterSphere)
    
    hideBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        if isMobile then
            notify("Use o botão flutuante para reabrir", 2)
        else
            notify("Pressione INSERT para reabrir", 2)
        end
    end)
end

-- BOTÃO FLUTUANTE MOBILE
local function buildMobileButton()
    local mobileGui = Instance.new("ScreenGui")
    mobileGui.Name = "JOTAMobileBtn"
    mobileGui.ResetOnSpawn = false
    mobileGui.Parent = player:WaitForChild("PlayerGui")

    local floatBtn = Instance.new("TextButton")
    floatBtn.Name = "FloatButton"
    floatBtn.Size = UDim2.new(0, 70, 0, 70)
    floatBtn.Position = UDim2.new(1, -80, 1, -150)
    floatBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    floatBtn.Text = "JOTA\nHUB"
    floatBtn.TextScaled = true
    floatBtn.Font = Enum.Font.SourceSansBold
    floatBtn.TextColor3 = Color3.new(1,1,1)
    floatBtn.Parent = mobileGui
    floatBtn.Active = true
    floatBtn.Draggable = true  -- Permite arrastar o botão

    local corner = Instance.new("UICorner", floatBtn)
    corner.CornerRadius = UDim.new(1, 0)  -- Círculo perfeito

    local stroke = Instance.new("UIStroke", floatBtn)
    stroke.Color = Color3.new(1,1,1)
    stroke.Thickness = 2

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
    notify("📱 MODO MOBILE ATIVADO", 3)
    notify("Arraste o botão azul, toque para abrir", 3)
else
    notify("💻 MODO PC ATIVADO", 3)
    notify("Pressione INSERT para esconder/mostrar", 3)
end
updateReachSphere()
refreshBalls(true)
notify("✅ JOTA HUB V10 ONLINE", 3)
print("JOTA HUB V10 OK | Mobile:", isMobile)
