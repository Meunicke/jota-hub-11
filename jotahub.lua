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
    showReachSpheres = true,      -- Toggle visual das esferas
    autoSecondTouch = true,
    scanCooldown = 1.5,
    tackleReach = 15,             -- NOVO: Reach especial para tackle
    tackleEnabled = true,         -- NOVO: Ativar reach no tackle
    ballNames = { "TPS", "ESA", "MRS", "PRS", "MPS", "SSS", "AIFA", "RBZ" },
    
    mode = "central", -- "central" ou "bodyparts"
    
    centralSphere = {
        enabled = true,
        color = Color3.fromRGB(0, 255, 136),
        reach = 10
    },
    
    bodyParts = {
        head = { name = "Head", reach = 8, color = Color3.fromRGB(255, 50, 50), enabled = true },
        torso = { name = "Torso", reach = 10, color = Color3.fromRGB(0, 255, 136), enabled = true },
        arm = { name = "Arm", reach = 12, color = Color3.fromRGB(0, 150, 255), enabled = true },
        leg = { name = "Leg", reach = 9, color = Color3.fromRGB(255, 200, 0), enabled = true }
    }
}

-- VARIÁVEIS
local balls = {}
local lastRefresh = 0
local reachSpheres = {}
local centralSphere = nil
local gui, mainFrame, modeLabel, spheresVisible = true
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local currentTool = nil

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

-- LIMPAR TODAS AS ESFERAS
local function clearAllSpheres()
    if centralSphere then
        centralSphere:Destroy()
        centralSphere = nil
    end
    for _, sphere in pairs(reachSpheres) do
        if sphere then sphere:Destroy() end
    end
    table.clear(reachSpheres)
end

-- TOGGLE VISIBILIDADE DAS ESFERAS (NOVO)
local function toggleSpheresVisibility()
    spheresVisible = not spheresVisible
    CONFIG.showReachSpheres = spheresVisible
    
    if spheresVisible then
        updateReachSpheres()
        notify("🔵 Esferas VISÍVEIS", 1.5)
    else
        clearAllSpheres()
        notify("⚫ Esferas ESCONDIDAS", 1.5)
    end
    
    return spheresVisible
end

-- MAPA DE PARTES R6
local function getBodyPartType(partName)
    if partName == "Head" then
        return "head"
    elseif partName == "Torso" then
        return "torso"
    elseif partName:match("Arm") or partName:match("Hand") then
        return "arm"
    elseif partName:match("Leg") or partName:match("Foot") then
        return "leg"
    end
    return nil
end

-- OBTER PARTES VÁLIDAS BASEADO NO MODO
local function getValidParts(char)
    local parts = {}
    
    if CONFIG.mode == "central" then
        for _, v in ipairs(char:GetChildren()) do
            if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                table.insert(parts, {
                    part = v,
                    reach = CONFIG.centralSphere.reach,
                    isCentral = true
                })
            end
        end
    else
        for _, v in ipairs(char:GetChildren()) do
            if v:IsA("BasePart") then
                local partType = getBodyPartType(v.Name)
                if partType and CONFIG.bodyParts[partType].enabled then
                    table.insert(parts, {
                        part = v,
                        type = partType,
                        reach = CONFIG.bodyParts[partType].reach,
                        isCentral = false
                    })
                end
            end
        end
    end
    
    return parts
end

-- ATUALIZAR ESFERAS VISUAIS
local function updateReachSpheres()
    if not spheresVisible then return end
    clearAllSpheres()
    
    local char = player.Character
    if not char then return end

    if CONFIG.mode == "central" then
        centralSphere = Instance.new("Part")
        centralSphere.Name = "CaduCentralSphere"
        centralSphere.Shape = Enum.PartType.Ball
        centralSphere.Anchored = true
        centralSphere.CanCollide = false
        centralSphere.Transparency = 0.8
        centralSphere.Material = Enum.Material.ForceField
        centralSphere.Color = CONFIG.centralSphere.color
        centralSphere.Size = Vector3.new(CONFIG.centralSphere.reach * 2, CONFIG.centralSphere.reach * 2, CONFIG.centralSphere.reach * 2)
        centralSphere.Parent = Workspace
        
    else
        for partType, config in pairs(CONFIG.bodyParts) do
            if not config.enabled then continue end
            
            local sphere = Instance.new("Part")
            sphere.Name = "CaduReach_" .. partType
            sphere.Shape = Enum.PartType.Ball
            sphere.Anchored = true
            sphere.CanCollide = false
            sphere.Transparency = 0.85
            sphere.Material = Enum.Material.ForceField
            sphere.Color = config.color
            sphere.Size = Vector3.new(config.reach * 2, config.reach * 2, config.reach * 2)
            sphere.Parent = Workspace
            
            reachSpheres[partType] = sphere
        end
    end
end

-- ATUALIZAR POSIÇÕES DAS ESFERAS
local function updateSpheresPosition()
    if not spheresVisible then return end
    
    local char = player.Character
    if not char then return end

    if CONFIG.mode == "central" and centralSphere then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            centralSphere.Position = hrp.Position
        end
        
    elseif CONFIG.mode == "bodyparts" then
        for partType, config in pairs(CONFIG.bodyParts) do
            local sphere = reachSpheres[partType]
            if not sphere or not config.enabled then continue end

            if partType == "head" then
                local head = char:FindFirstChild("Head")
                if head then sphere.Position = head.Position end
                
            elseif partType == "torso" then
                local torso = char:FindFirstChild("Torso")
                if torso then sphere.Position = torso.Position end
                
            elseif partType == "arm" then
                local leftArm = char:FindFirstChild("Left Arm")
                local rightArm = char:FindFirstChild("Right Arm")
                if leftArm and rightArm then
                    sphere.Position = (leftArm.Position + rightArm.Position) / 2
                elseif leftArm then
                    sphere.Position = leftArm.Position
                elseif rightArm then
                    sphere.Position = rightArm.Position
                end
                
            elseif partType == "leg" then
                local leftLeg = char:FindFirstChild("Left Leg")
                local rightLeg = char:FindFirstChild("Right Leg")
                if leftLeg and rightLeg then
                    sphere.Position = (leftLeg.Position + rightLeg.Position) / 2
                elseif leftLeg then
                    sphere.Position = leftLeg.Position
                elseif rightLeg then
                    sphere.Position = rightLeg.Position
                end
            end
        end
    end
end

-- TOGGLE MODO (CENTRAL <-> 4 PARTES)
local function toggleMode()
    CONFIG.mode = (CONFIG.mode == "central") and "bodyparts" or "central"
    updateReachSpheres()
    
    local modeName = CONFIG.mode == "central" and "ESFERA CENTRAL" or "4 PARTES DO CORPO"
    notify("Modo: " .. modeName, 2)
    updateGUIForMode()
    
    return CONFIG.mode
end

-- TOGGLE PARTE ESPECÍFICA
local function toggleBodyPart(partType)
    if CONFIG.mode ~= "bodyparts" then return end
    
    CONFIG.bodyParts[partType].enabled = not CONFIG.bodyParts[partType].enabled
    updateReachSpheres()
    
    local status = CONFIG.bodyParts[partType].enabled and "ON" or "OFF"
    notify(partType:upper() .. ": " .. status, 1)
    return CONFIG.bodyParts[partType].enabled
end

-- VERIFICAR SE TEM TACKLE EQUIPADO (NOVO)
local function hasTackleEquipped()
    local char = player.Character
    if not char then return false end
    
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") and tool.Name:lower():match("tackle") then
            return true, tool
        end
    end
    return false, nil
end

-- GUI PRINCIPAL
local bodyPartButtons = {}

local function buildMainGUI()
    if gui then return end

    gui = Instance.new("ScreenGui")
    gui.Name = "CaduHubGUI"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")

    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.fromScale(0.24, 0.42) -- Aumentado para caber botão de esferas
    mainFrame.Position = UDim2.fromScale(0.02, 0.05)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = gui

    local stroke = Instance.new("UIStroke", mainFrame)
    stroke.Color = Color3.fromRGB(0, 255, 136)
    stroke.Thickness = 2

    local corner = Instance.new("UICorner", mainFrame)
    corner.CornerRadius = UDim.new(0, 12)

    local gradient = Instance.new("UIGradient", mainFrame)
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 45)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 30))
    })
    gradient.Rotation = 45

    -- Título
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -10, 0.07, 0)
    title.Position = UDim2.new(0, 5, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = "CADU HUB"
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.TextColor3 = Color3.fromRGB(0, 255, 136)
    title.Parent = mainFrame

    -- Linha
    local line = Instance.new("Frame")
    line.Size = UDim2.new(0.8, 0, 0, 2)
    line.Position = UDim2.new(0.1, 0, 0.09, 0)
    line.BackgroundColor3 = Color3.fromRGB(0, 255, 136)
    line.BorderSizePixel = 0
    line.Parent = mainFrame

    -- BOTÃO TOGGLE ESFERAS (NOVO)
    local spheresBtn = Instance.new("TextButton")
    spheresBtn.Name = "SpheresButton"
    spheresBtn.Size = UDim2.new(0.9, 0, 0.07, 0)
    spheresBtn.Position = UDim2.new(0.05, 0, 0.12, 0)
    spheresBtn.Text = "🔵 ESFERAS: ON"
    spheresBtn.TextSize = 12
    spheresBtn.Font = Enum.Font.GothamBold
    spheresBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    spheresBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    spheresBtn.Parent = mainFrame
    spheresBtn.AutoButtonColor = false
    
    Instance.new("UICorner", spheresBtn).CornerRadius = UDim.new(0, 8)
    
    spheresBtn.MouseButton1Click:Connect(function()
        local visible = toggleSpheresVisibility()
        spheresBtn.Text = visible and "🔵 ESFERAS: ON" or "⚫ ESFERAS: OFF"
        spheresBtn.BackgroundColor3 = visible and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(80, 80, 80)
    end)

    -- BOTÃO MODO
    local modeBtn = Instance.new("TextButton")
    modeBtn.Name = "ModeButton"
    modeBtn.Size = UDim2.new(0.9, 0, 0.07, 0)
    modeBtn.Position = UDim2.new(0.05, 0, 0.21, 0)
    modeBtn.Text = "MODO: ESFERA CENTRAL"
    modeBtn.TextSize = 12
    modeBtn.Font = Enum.Font.GothamBold
    modeBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    modeBtn.TextColor3 = Color3.fromRGB(25, 25, 35)
    modeBtn.Parent = mainFrame
    modeBtn.AutoButtonColor = false
    
    Instance.new("UICorner", modeBtn).CornerRadius = UDim.new(0, 8)
    
    modeBtn.MouseButton1Click:Connect(function()
        local newMode = toggleMode()
        modeBtn.Text = "MODO: " .. (newMode == "central" and "ESFERA CENTRAL" or "4 PARTES")
        modeBtn.BackgroundColor3 = newMode == "central" and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(255, 150, 0)
    end)

    -- Label modo
    modeLabel = Instance.new("TextLabel")
    modeLabel.Size = UDim2.new(1, 0, 0.05, 0)
    modeLabel.Position = UDim2.new(0, 0, 0.29, 0)
    modeLabel.BackgroundTransparency = 1
    modeLabel.Text = "Esfera única no centro"
    modeLabel.TextScaled = true
    modeLabel.Font = Enum.Font.GothamSemibold
    modeLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    modeLabel.Parent = mainFrame

    -- Container partes
    local partsContainer = Instance.new("Frame")
    partsContainer.Name = "PartsContainer"
    partsContainer.Size = UDim2.new(0.9, 0, 0.35, 0)
    partsContainer.Position = UDim2.new(0.05, 0, 0.34, 0)
    partsContainer.BackgroundTransparency = 1
    partsContainer.Visible = false
    partsContainer.Parent = mainFrame

    local partOrder = {"head", "torso", "arm", "leg"}
    local partNames = {head = "CABEÇA", torso = "TRONCO", arm = "BRAÇOS", leg = "PERNAS"}

    for i, partType in ipairs(partOrder) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0.22, 0)
        btn.Position = UDim2.new(0, 0, (i-1) * 0.25, 0)
        btn.Text = partNames[partType] .. ": ON"
        btn.TextSize = 12
        btn.Font = Enum.Font.GothamBold
        btn.BackgroundColor3 = CONFIG.bodyParts[partType].color
        btn.TextColor3 = Color3.fromRGB(25, 25, 35)
        btn.Parent = partsContainer
        btn.AutoButtonColor = false
        
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        btn.MouseEnter:Connect(function()
            if CONFIG.bodyParts[partType].enabled then
                btn.BackgroundColor3 = Color3.new(
                    math.min(CONFIG.bodyParts[partType].color.R + 0.2, 1),
                    math.min(CONFIG.bodyParts[partType].color.G + 0.2, 1),
                    math.min(CONFIG.bodyParts[partType].color.B + 0.2, 1)
                )
            else
                btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            end
        end)

        btn.MouseLeave:Connect(function()
            if CONFIG.bodyParts[partType].enabled then
                btn.BackgroundColor3 = CONFIG.bodyParts[partType].color
            else
                btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            end
        end)

        btn.MouseButton1Click:Connect(function()
            local enabled = toggleBodyPart(partType)
            btn.Text = partNames[partType] .. ": " .. (enabled and "ON" or "OFF")
            btn.BackgroundColor3 = enabled and CONFIG.bodyParts[partType].color or Color3.fromRGB(60, 60, 60)
            btn.TextColor3 = enabled and Color3.fromRGB(25, 25, 35) or Color3.fromRGB(150, 150, 150)
        end)

        bodyPartButtons[partType] = btn
    end

    -- Label reach
    local reachLabel = Instance.new("TextLabel")
    reachLabel.Size = UDim2.new(1, 0, 0.05, 0)
    reachLabel.Position = UDim2.new(0, 0, 0.71, 0)
    reachLabel.BackgroundTransparency = 1
    reachLabel.Text = "REACH: " .. CONFIG.reach
    reachLabel.TextScaled = true
    reachLabel.Font = Enum.Font.GothamSemibold
    reachLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    reachLabel.Parent = mainFrame

    -- Container + e -
    local adjustContainer = Instance.new("Frame")
    adjustContainer.Size = UDim2.new(0.9, 0, 0.07, 0)
    adjustContainer.Position = UDim2.new(0.05, 0, 0.77, 0)
    adjustContainer.BackgroundTransparency = 1
    adjustContainer.Parent = mainFrame

    local minus = Instance.new("TextButton")
    minus.Size = UDim2.new(0.45, 0, 1, 0)
    minus.Text = "−"
    minus.TextSize = 18
    minus.Font = Enum.Font.GothamBold
    minus.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    minus.TextColor3 = Color3.fromRGB(255, 100, 100)
    minus.Parent = adjustContainer
    minus.AutoButtonColor = false
    Instance.new("UICorner", minus).CornerRadius = UDim.new(0, 6)

    local plus = Instance.new("TextButton")
    plus.Size = UDim2.new(0.45, 0, 1, 0)
    plus.Position = UDim2.new(0.55, 0, 0, 0)
    plus.Text = "+"
    plus.TextSize = 18
    plus.Font = Enum.Font.GothamBold
    plus.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    plus.TextColor3 = Color3.fromRGB(0, 255, 136)
    plus.Parent = adjustContainer
    plus.AutoButtonColor = false
    Instance.new("UICorner", plus).CornerRadius = UDim.new(0, 6)

    -- Botão esconder
    local hideBtn = Instance.new("TextButton")
    hideBtn.Size = UDim2.new(0.9, 0, 0.07, 0)
    hideBtn.Position = UDim2.new(0.05, 0, 0.88, 0)
    hideBtn.Text = isMobile and "FECHAR" or "ESCONDER [INSERT]"
    hideBtn.TextSize = 11
    hideBtn.Font = Enum.Font.GothamSemibold
    hideBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    hideBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
    hideBtn.Parent = mainFrame
    Instance.new("UICorner", hideBtn).CornerRadius = UDim.new(0, 6)

    -- FUNÇÕES
    minus.MouseButton1Click:Connect(function()
        CONFIG.reach = math.max(1, CONFIG.reach - 1)
        CONFIG.centralSphere.reach = CONFIG.reach
        CONFIG.tackleReach = math.max(1, CONFIG.tackleReach - 1)
        reachLabel.Text = "REACH: " .. CONFIG.reach
        for _, config in pairs(CONFIG.bodyParts) do
            config.reach = math.max(1, config.reach - 1)
        end
        updateReachSpheres()
        notify("Reach: " .. CONFIG.reach, 1)
    end)

    plus.MouseButton1Click:Connect(function()
        CONFIG.reach += 1
        CONFIG.centralSphere.reach = CONFIG.reach
        CONFIG.tackleReach += 1
        reachLabel.Text = "REACH: " .. CONFIG.reach
        for _, config in pairs(CONFIG.bodyParts) do
            config.reach += 1
        end
        updateReachSpheres()
        notify("Reach: " .. CONFIG.reach, 1)
    end)

    hideBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        if isMobile then
            notify("Use o botão flutuante", 2)
        else
            notify("Pressione INSERT", 2)
        end
    end)
end

-- ATUALIZAR GUI BASEADO NO MODO
function updateGUIForMode()
    if not mainFrame then return end
    
    local partsContainer = mainFrame:FindFirstChild("PartsContainer")
    
    if CONFIG.mode == "central" then
        partsContainer.Visible = false
        modeLabel.Text = "Esfera única no centro (HRP)"
        modeLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
    else
        partsContainer.Visible = true
        modeLabel.Text = "4 esferas: Cabeça, Tronco, Braços, Pernas"
        modeLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
    end
end

-- BOTÃO FLUTUANTE MOBILE
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

    local btnStroke = Instance.new("UIStroke", floatBtn)
    btnStroke.Color = Color3.fromRGB(0, 255, 136)
    btnStroke.Thickness = 2

    local btnCorner = Instance.new("UICorner", floatBtn)
    btnCorner.CornerRadius = UDim.new(1, 0)

    local btnGradient = Instance.new("UIGradient", floatBtn)
    btnGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 30))
    })

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

-- AUTO TOUCH APRIMORADO COM TACKLE
local function processTouch()
    local char = player.Character
    if not char then return end

    local hasTackle, tackleTool = hasTackleEquipped()
    local isTackling = false
    
    if hasTackle and tackleTool then
        isTackling = true
    end

    local validParts = getValidParts(char)
    
    for _, data in ipairs(validParts) do
        local part = data.part
        local reach = (isTackling and CONFIG.tackleEnabled) and CONFIG.tackleReach or data.reach
        
        for _, ball in ipairs(balls) do
            if ball and ball.Parent then
                local distance = (ball.Position - part.Position).Magnitude
                
                if distance <= reach then
                    local velocity = ball.AssemblyLinearVelocity or Vector3.new(0,0,0)
                    
                    if isTackling then
                        pcall(function()
                            firetouchinterest(ball, part, 0)
                            firetouchinterest(ball, part, 1)
                        end)
                    else
                        if distance < reach * 0.5 or velocity.Magnitude < 50 then
                            pcall(function()
                                firetouchinterest(ball, part, 0)
                                firetouchinterest(ball, part, 1)
                            end)
                        end
                    end
                end
            end
        end
    end
end

-- MONITORAR TOOLS
player.CharacterAdded:Connect(function(char)
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") and child.Name:lower():match("tackle") then
            notify("🎯 Tackle detectado! Reach aumentado", 2)
        end
    end)
end)

-- LOOPS
RunService.RenderStepped:Connect(function()
    updateSpheresPosition()
    
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
updateReachSpheres()
updateGUIForMode()
refreshBalls(true)
notify("✅ Cadu Hub Online", 3)
notify("🔵 Botão 'ESFERAS' para esconder/mostrar", 3)
notify("🎯 Tackle = Reach aumentado automaticamente", 3)
print("Cadu Hub OK | Modo:", CONFIG.mode, "| Mobile:", isMobile)
