-- SERVICES
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer

-- CONFIG
local CONFIG = {
    playerReach = 10,
    ballReach = 15,
    autoTouch = true,
    showVisuals = true,
    flashEnabled = false,
    antiAFK = true,
    -- NOVA CONFIGURAÇÃO: Quantum Reach Touch
    quantumReachEnabled = false,
    quantumReach = 10,
    ballNames = { "MPS", "TRS", "TCS", "TPS", "PRS", "ESA", "MRS", "SSS", "AIFA", "RBZ", "SoccerBall", "Football", "Ball" },
    
    colors = {
        bg = Color3.fromRGB(25, 25, 35),
        tabBg = Color3.fromRGB(35, 35, 50),
        accent = Color3.fromRGB(88, 101, 242),
        accent2 = Color3.fromRGB(235, 69, 158),
        accent3 = Color3.fromRGB(0, 255, 255), -- Cyan para Quantum Reach
        success = Color3.fromRGB(87, 242, 135),
        warning = Color3.fromRGB(254, 231, 92),
        danger = Color3.fromRGB(240, 70, 70),
        text = Color3.fromRGB(255, 255, 255),
        textDim = Color3.fromRGB(180, 180, 200),
        flash = Color3.fromRGB(255, 255, 100),
        toggleOn = Color3.fromRGB(87, 242, 135),
        toggleOff = Color3.fromRGB(60, 60, 80)
    }
}

-- VARIABLES
local balls = {}
local ballAuras = {}
local playerSphere = nil
local quantumCircle = nil -- NOVO: Círculo do Quantum Reach
local HRP = nil
local gui, mainWindow, currentTab = nil, nil, "Reach"
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local connections = {}
local isUIOpen = true

-- BALL SET
local BALL_NAME_SET = {}
for _, n in ipairs(CONFIG.ballNames) do
    BALL_NAME_SET[n] = true
end

-- UTILITY FUNCTIONS
local function disconnectAll()
    for _, conn in pairs(connections) do
        if conn then conn:Disconnect() end
    end
    connections = {}
end

local function createConnection(signal, callback)
    local conn = signal:Connect(callback)
    table.insert(connections, conn)
    return conn
end

-- UPDATE HRP
task.spawn(function()
    while true do
        task.wait(0.5)
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            HRP = player.Character.HumanoidRootPart
        end
    end
end)

-- ANTI-AFK
if CONFIG.antiAFK then
    local VirtualUser = game:GetService("VirtualUser")
    player.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

-- GET BALLS (Optimized)
local lastBallUpdate = 0
local function getBalls()
    local now = tick()
    if now - lastBallUpdate < 0.1 then return balls end
    lastBallUpdate = now
    
    table.clear(balls)
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and BALL_NAME_SET[v.Name] then
            table.insert(balls, v)
        end
    end
    return balls
end

-- CREATE BALL AURA
local function createBallAura(ball)
    if ballAuras[ball] or not CONFIG.showVisuals then return end
    
    local aura = Instance.new("Part")
    aura.Name = "BallAura"
    aura.Shape = Enum.PartType.Ball
    aura.Size = Vector3.new(CONFIG.ballReach * 2, CONFIG.ballReach * 2, CONFIG.ballReach * 2)
    aura.Transparency = 0.9
    aura.Anchored = true
    aura.CanCollide = false
    aura.Material = Enum.Material.ForceField
    aura.Color = CONFIG.colors.accent2
    aura.Parent = Workspace
    
    local highlight = Instance.new("Highlight")
    highlight.Adornee = ball
    highlight.FillColor = CONFIG.colors.accent2
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.8
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = ball
    
    local conn = RunService.RenderStepped:Connect(function()
        if ball and ball.Parent and aura and aura.Parent then
            aura.CFrame = ball.CFrame
        else
            if aura then aura:Destroy() end
        end
    end)
    
    ballAuras[ball] = {aura = aura, highlight = highlight, conn = conn}
end

-- REMOVE BALL AURA
local function removeBallAura(ball)
    if ballAuras[ball] then
        if ballAuras[ball].conn then ballAuras[ball].conn:Disconnect() end
        if ballAuras[ball].aura then ballAuras[ball].aura:Destroy() end
        if ballAuras[ball].highlight then ballAuras[ball].highlight:Destroy() end
        ballAuras[ball] = nil
    end
end

-- UPDATE AURAS
local function updateBallAuras()
    for ball, _ in pairs(ballAuras) do
        if not ball or not ball.Parent then removeBallAura(ball) end
    end
    
    if not CONFIG.showVisuals then return end
    
    for _, ball in ipairs(balls) do
        if ball and ball.Parent then
            createBallAura(ball)
        end
    end
end

-- CLEAR ALL AURAS
local function clearAllAuras()
    for ball, data in pairs(ballAuras) do
        if data.conn then data.conn:Disconnect() end
        if data.aura then data.aura:Destroy() end
        if data.highlight then data.highlight:Destroy() end
    end
    ballAuras = {}
    if playerSphere then
        playerSphere:Destroy()
        playerSphere = nil
    end
    -- NOVO: Limpar círculo do Quantum Reach
    if quantumCircle then
        quantumCircle:Destroy()
        quantumCircle = nil
    end
end

-- UPDATE PLAYER SPHERE
local function updatePlayerSphere()
    if not CONFIG.showVisuals then
        if playerSphere then playerSphere:Destroy() playerSphere = nil end
        return
    end
    if not HRP then return end
    
    if not playerSphere then
        playerSphere = Instance.new("Part")
        playerSphere.Name = "PlayerSphere"
        playerSphere.Shape = Enum.PartType.Ball
        playerSphere.Anchored = true
        playerSphere.CanCollide = false
        playerSphere.Material = Enum.Material.ForceField
        playerSphere.Color = CONFIG.colors.accent
        playerSphere.Parent = Workspace
    end
    
    playerSphere.Size = Vector3.new(CONFIG.playerReach * 2, CONFIG.playerReach * 2, CONFIG.playerReach * 2)
    playerSphere.Position = HRP.Position
    playerSphere.Transparency = 0.75
end

-- NOVA FUNÇÃO: UPDATE QUANTUM CIRCLE (do Arthur Hub)
local function updateQuantumCircle()
    if not quantumCircle then
        quantumCircle = Instance.new("Part")
        quantumCircle.Name = "QuantumCircle"
        quantumCircle.Shape = Enum.PartType.Ball
        quantumCircle.Anchored = true
        quantumCircle.CanCollide = false
        quantumCircle.Material = Enum.Material.ForceField
        quantumCircle.Color = CONFIG.colors.accent3 -- Cyan
        quantumCircle.Parent = Workspace
    end
    quantumCircle.Size = Vector3.new(CONFIG.quantumReach * 2, CONFIG.quantumReach * 2, CONFIG.quantumReach * 2)
    quantumCircle.Transparency = CONFIG.quantumReachEnabled and 0.75 or 1
end

-- NOVA FUNÇÃO: DO QUANTUM REACH TOUCH (do Arthur Hub)
local function doQuantumReach()
    if not CONFIG.quantumReachEnabled or not player.Character or not HRP then return end
    
    local rightLeg = player.Character:FindFirstChild("Right Leg") or 
                     player.Character:FindFirstChild("RightLowerLeg") or
                     player.Character:FindFirstChild("RightFoot")
    if not rightLeg then return end

    local ballsList = getBalls()
    for _, ball in ipairs(ballsList) do
        if ball and ball.Parent and (ball.Position - HRP.Position).Magnitude < CONFIG.quantumReach then
            -- Procura TouchInterest na perna
            local touched = false
            for _, d in ipairs(rightLeg:GetDescendants()) do
                if d.Name == "TouchInterest" then
                    pcall(function()
                        firetouchinterest(ball, d.Parent, 0)
                        firetouchinterest(ball, d.Parent, 1)
                    end)
                    touched = true
                    break
                end
            end
            
            -- Se não achou TouchInterest, usa a perna diretamente
            if not touched then
                pcall(function()
                    firetouchinterest(ball, rightLeg, 0)
                    firetouchinterest(ball, rightLeg, 1)
                end)
            end
        end
    end
end

-- DO REACH (Arthur V2 Method - Optimized)
local lastReach = 0
local function doReach()
    if not CONFIG.autoTouch or not player.Character or not HRP then return end
    
    local now = tick()
    if now - lastReach < 0.03 then return end -- 30ms cooldown
    lastReach = now
    
    local rightLeg = player.Character:FindFirstChild("Right Leg") or 
                     player.Character:FindFirstChild("RightLowerLeg") or
                     player.Character:FindFirstChild("RightFoot") or
                     player.Character:FindFirstChild("HumanoidRootPart")
    if not rightLeg then return end
    
    getBalls()
    
    for _, ball in ipairs(balls) do
        if not ball or not ball.Parent then continue end
        
        local dist = (ball.Position - HRP.Position).Magnitude
        local effectiveReach = CONFIG.playerReach + CONFIG.ballReach
        
        -- FLASH MODE: Instant touch at any distance within reach
        if CONFIG.flashEnabled and dist < effectiveReach * 2 then
            pcall(function()
                firetouchinterest(ball, rightLeg, 0)
                firetouchinterest(ball, rightLeg, 1)
            end)
            
            -- Visual flash effect
            if CONFIG.showVisuals then
                local flash = Instance.new("Part")
                flash.Size = Vector3.new(1, 1, 1)
                flash.Position = ball.Position
                flash.Anchored = true
                flash.CanCollide = false
                flash.Material = Enum.Material.Neon
                flash.Color = CONFIG.colors.flash
                flash.Parent = Workspace
                
                TweenService:Create(flash, TweenInfo.new(0.1), {
                    Size = Vector3.new(5, 5, 5),
                    Transparency = 1
                }):Play()
                
                Debris:AddItem(flash, 0.1)
            end
            
        elseif dist < effectiveReach then
            -- Normal mode: Check for TouchInterest
            local touched = false
            for _, desc in ipairs(rightLeg:GetDescendants()) do
                if desc.Name == "TouchInterest" then
                    pcall(function()
                        firetouchinterest(ball, desc.Parent, 0)
                        firetouchinterest(ball, desc.Parent, 1)
                    end)
                    touched = true
                    break
                end
            end
            
            if not touched then
                pcall(function()
                    firetouchinterest(ball, rightLeg, 0)
                    firetouchinterest(ball, rightLeg, 1)
                end)
            end
        end
    end
end

-- CREATE UI ELEMENTS
local function createCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

local function createStroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or CONFIG.colors.accent
    s.Thickness = thickness or 1
    s.Parent = parent
    return s
end

local function createShadow(parent)
    local s = Instance.new("ImageLabel")
    s.Name = "Shadow"
    s.Size = UDim2.new(1, 20, 1, 20)
    s.Position = UDim2.new(0, -10, 0, -10)
    s.BackgroundTransparency = 1
    s.Image = "rbxassetid://5554236805"
    s.ImageColor3 = Color3.new(0, 0, 0)
    s.ImageTransparency = 0.6
    s.ScaleType = Enum.ScaleType.Slice
    s.SliceCenter = Rect.new(23, 23, 277, 277)
    s.Parent = parent
    return s
end

-- CREATE TOGGLE BUTTON
local function createToggle(parent, text, defaultValue, callback, yPos)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 60)
    toggleFrame.Position = UDim2.new(0, 0, 0, yPos or 0)
    toggleFrame.BackgroundColor3 = CONFIG.colors.tabBg
    toggleFrame.Parent = parent
    createCorner(toggleFrame, 10)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 200, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = CONFIG.colors.text
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 50, 0, 30)
    btn.Position = UDim2.new(1, -65, 0, 15)
    btn.BackgroundColor3 = defaultValue and CONFIG.colors.toggleOn or CONFIG.colors.toggleOff
    btn.Text = defaultValue and "ON" or "OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = toggleFrame
    createCorner(btn, 15)
    
    local isOn = defaultValue
    
    btn.MouseButton1Click:Connect(function()
        isOn = not isOn
        btn.BackgroundColor3 = isOn and CONFIG.colors.toggleOn or CONFIG.colors.toggleOff
        btn.Text = isOn and "ON" or "OFF"
        callback(isOn)
    end)
    
    return toggleFrame
end

-- CREATE SLIDER
local function createSlider(parent, text, value, min, max, color, callback, yPos)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, 0, 0, 120)
    section.Position = UDim2.new(0, 0, 0, yPos or 0)
    section.BackgroundColor3 = CONFIG.colors.tabBg
    section.Parent = parent
    createCorner(section, 10)
    createStroke(section, color, 2)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 30)
    label.Position = UDim2.new(0, 10, 0, 10)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.Parent = section
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(1, -20, 0, 40)
    valueLabel.Position = UDim2.new(0, 10, 0, 40)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(value)
    valueLabel.TextColor3 = CONFIG.colors.text
    valueLabel.Font = Enum.Font.GothamBlack
    valueLabel.TextSize = 36
    valueLabel.Parent = section
    
    local studsLabel = Instance.new("TextLabel")
    studsLabel.Size = UDim2.new(0, 60, 0, 20)
    studsLabel.Position = UDim2.new(0, 80, 0, 55)
    studsLabel.BackgroundTransparency = 1
    studsLabel.Text = "studs"
    studsLabel.TextColor3 = CONFIG.colors.textDim
    studsLabel.Font = Enum.Font.Gotham
    studsLabel.TextSize = 14
    studsLabel.Parent = section
    
    -- Slider Background
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -20, 0, 8)
    sliderBg.Position = UDim2.new(0, 10, 0, 90)
    sliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = section
    createCorner(sliderBg, 4)
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = color
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBg
    createCorner(sliderFill, 4)
    
    local function updateValue(newVal)
        newVal = math.clamp(math.floor(newVal + 0.5), min, max)
        valueLabel.Text = tostring(newVal)
        TweenService:Create(sliderFill, TweenInfo.new(0.2), {
            Size = UDim2.new((newVal - min) / (max - min), 0, 1, 0)
        }):Play()
        callback(newVal)
        return newVal
    end
    
    -- Click and drag functionality
    local dragging = false
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            updateValue(min + (pos * (max - min)))
        end
    end)
    
    sliderBg.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            updateValue(min + (pos * (max - min)))
        end
    end)
    
    -- Minus/Plus Buttons
    local minusBtn = Instance.new("TextButton")
    minusBtn.Size = UDim2.new(0, 40, 0, 40)
    minusBtn.Position = UDim2.new(1, -100, 0, 40)
    minusBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    minusBtn.Text = "−"
    minusBtn.TextColor3 = CONFIG.colors.text
    minusBtn.Font = Enum.Font.GothamBold
    minusBtn.TextSize = 24
    minusBtn.Parent = section
    createCorner(minusBtn, 8)
    
    local plusBtn = Instance.new("TextButton")
    plusBtn.Size = UDim2.new(0, 40, 0, 40)
    plusBtn.Position = UDim2.new(1, -50, 0, 40)
    plusBtn.BackgroundColor3 = color
    plusBtn.Text = "+"
    plusBtn.TextColor3 = Color3.new(0, 0, 0)
    plusBtn.Font = Enum.Font.GothamBold
    plusBtn.TextSize = 24
    plusBtn.Parent = section
    createCorner(plusBtn, 8)
    
    local currentValue = value
    
    minusBtn.MouseButton1Click:Connect(function()
        currentValue = updateValue(currentValue - 1)
    end)
    
    plusBtn.MouseButton1Click:Connect(function()
        currentValue = updateValue(currentValue + 1)
    end)
    
    return section
end

-- BUILD MAIN GUI
function buildMainGUI()
    if gui then return end
    
    gui = Instance.new("ScreenGui")
    gui.Name = "CaduHubPremium"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")
    
    -- Main Window
    mainWindow = Instance.new("Frame")
    mainWindow.Size = UDim2.new(0, 500, 0, 400)
    mainWindow.Position = UDim2.new(0.5, -250, 0.5, -200)
    mainWindow.BackgroundColor3 = CONFIG.colors.bg
    mainWindow.BorderSizePixel = 0
    mainWindow.Parent = gui
    
    createCorner(mainWindow, 12)
    createShadow(mainWindow)
    
    -- Make draggable
    local dragging = false
    local dragInput, dragStart, startPos
    
    local function updateDrag(input)
        local delta = input.Position - dragStart
        mainWindow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    mainWindow.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainWindow.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    mainWindow.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updateDrag(input)
        end
    end)
    
        -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 50)
    titleBar.BackgroundColor3 = CONFIG.colors.tabBg
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainWindow
    createCorner(titleBar, 12)
    
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(0, 200, 1, 0)
    titleText.Position = UDim2.new(0, 20, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "CADU HUB"
    titleText.TextColor3 = CONFIG.colors.text
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 24
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(0, 200, 0, 20)
    subtitle.Position = UDim2.new(0, 20, 0, 30)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "PREMIUM EDITION v2.0"
    subtitle.TextColor3 = CONFIG.colors.accent
    subtitle.Font = Enum.Font.GothamBold
    subtitle.TextSize = 10
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Parent = titleBar
    
    -- Minimize Button
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 35, 0, 35)
    minBtn.Position = UDim2.new(1, -85, 0, 7)
    minBtn.BackgroundColor3 = CONFIG.colors.warning
    minBtn.Text = "−"
    minBtn.TextColor3 = Color3.new(0, 0, 0)
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = 20
    minBtn.Parent = titleBar
    createCorner(minBtn, 8)
    
    minBtn.MouseButton1Click:Connect(function()
        isUIOpen = not isUIOpen
        contentArea.Visible = isUIOpen
        tabBar.Visible = isUIOpen
        minBtn.Text = isUIOpen and "−" or "+"
        mainWindow.Size = isUIOpen and UDim2.new(0, 500, 0, 400) or UDim2.new(0, 500, 0, 50)
    end)
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -45, 0, 7)
    closeBtn.BackgroundColor3 = CONFIG.colors.danger
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 20
    closeBtn.Parent = titleBar
    createCorner(closeBtn, 8)
    
    closeBtn.MouseButton1Click:Connect(function()
        mainWindow.Visible = false
    end)
    
    -- TAB BAR
    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(0, 120, 1, -50)
    tabBar.Position = UDim2.new(0, 0, 0, 50)
    tabBar.BackgroundColor3 = CONFIG.colors.tabBg
    tabBar.BorderSizePixel = 0
    tabBar.Parent = mainWindow
    
    -- Tab Content Area
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -120, 1, -50)
    contentArea.Position = UDim2.new(0, 120, 0, 50)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = mainWindow
    
    -- TAB SYSTEM
    local tabs = {}
    local tabButtons = {}
    
    local function createTab(name, icon, position)
        -- Tab Button
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 45)
        btn.Position = UDim2.new(0, 5, 0, 10 + (position * 55))
        btn.BackgroundColor3 = currentTab == name and CONFIG.colors.accent or Color3.fromRGB(45, 45, 60)
        btn.Text = "  " .. icon .. "  " .. name
        btn.TextColor3 = currentTab == name and Color3.new(1, 1, 1) or CONFIG.colors.textDim
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = tabBar
        createCorner(btn, 8)
        
        tabButtons[name] = btn
        
        -- Tab Content
        local content = Instance.new("ScrollingFrame")
        content.Name = name .. "Content"
        content.Size = UDim2.new(1, -20, 1, -20)
        content.Position = UDim2.new(0, 10, 0, 10)
        content.BackgroundTransparency = 1
        content.ScrollBarThickness = 4
        content.ScrollBarImageColor3 = CONFIG.colors.accent
        content.Visible = currentTab == name
        content.CanvasSize = UDim2.new(0, 0, 0, 0)
        content.Parent = contentArea
        
        tabs[name] = content
        
        btn.MouseButton1Click:Connect(function()
            currentTab = name
            for n, c in pairs(tabs) do
                c.Visible = (n == name)
            end
            for n, b in pairs(tabButtons) do
                b.BackgroundColor3 = (n == name) and CONFIG.colors.accent or Color3.fromRGB(45, 45, 60)
                b.TextColor3 = (n == name) and Color3.new(1, 1, 1) or CONFIG.colors.textDim
            end
        end)
        
        return content
    end
    
    -- REACH TAB
    local reachTab = createTab("Reach", "⚡", 0)
    
    -- Player Reach Slider
    createSlider(reachTab, "👤 PLAYER REACH", CONFIG.playerReach, 1, 150, CONFIG.colors.accent, function(val)
        CONFIG.playerReach = val
        updatePlayerSphere()
    end, 0)
    
    -- Ball Reach Slider
    createSlider(reachTab, "⚽ BALL REACH", CONFIG.ballReach, 1, 150, CONFIG.colors.accent2, function(val)
        CONFIG.ballReach = val
        updateBallAuras()
    end, 130)
    
    -- NOVO: Quantum Reach Slider (do Arthur Hub)
    createSlider(reachTab, "🔮 QUANTUM REACH", CONFIG.quantumReach, 1, 150, CONFIG.colors.accent3, function(val)
        CONFIG.quantumReach = val
        updateQuantumCircle()
    end, 260)
    
    -- Flash Mode Toggle
    createToggle(reachTab, "⚡ FLASH MODE (Instant Touch)", CONFIG.flashEnabled, function(val)
        CONFIG.flashEnabled = val
    end, 390)
    
    -- NOVO: Quantum Reach Toggle (do Arthur Hub)
    createToggle(reachTab, "🔮 QUANTUM REACH TOUCH", CONFIG.quantumReachEnabled, function(val)
        CONFIG.quantumReachEnabled = val
        updateQuantumCircle()
    end, 460)
    
    -- SETTINGS TAB
    local settingsTab = createTab("Settings", "⚙️", 1)
    
    -- Auto Touch Toggle
    createToggle(settingsTab, "🤖 Auto Touch", CONFIG.autoTouch, function(val)
        CONFIG.autoTouch = val
    end, 0)
    
    -- Show Visuals Toggle
    createToggle(settingsTab, "👁️ Show Visuals", CONFIG.showVisuals, function(val)
        CONFIG.showVisuals = val
        if not val then
            clearAllAuras()
        else
            updateBallAuras()
            updateQuantumCircle()
        end
    end, 70)
    
    -- Anti-AFK Toggle
    createToggle(settingsTab, "😴 Anti-AFK", CONFIG.antiAFK, function(val)
        CONFIG.antiAFK = val
    end, 140)
    
    -- VISUALS TAB
    local visualsTab = createTab("Visuals", "👁️", 2)
    
    -- Info text
    local infoText = Instance.new("TextLabel")
    infoText.Size = UDim2.new(1, -20, 0, 60)
    infoText.Position = UDim2.new(0, 10, 0, 10)
    infoText.BackgroundTransparency = 1
    infoText.Text = "Visual features help you see the reach range. Disable if you experience lag."
    infoText.TextColor3 = CONFIG.colors.textDim
    infoText.Font = Enum.Font.Gotham
    infoText.TextSize = 14
    infoText.TextWrapped = true
    infoText.Parent = visualsTab
    
    -- Clear Visuals Button
    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(1, -20, 0, 50)
    clearBtn.Position = UDim2.new(0, 10, 0, 80)
    clearBtn.BackgroundColor3 = CONFIG.colors.danger
    clearBtn.Text = "CLEAR ALL VISUALS"
    clearBtn.TextColor3 = Color3.new(1, 1, 1)
    clearBtn.Font = Enum.Font.GothamBold
    clearBtn.TextSize = 16
    clearBtn.Parent = visualsTab
    createCorner(clearBtn, 10)
    
    clearBtn.MouseButton1Click:Connect(function()
        clearAllAuras()
        CONFIG.showVisuals = false
    end)
    
    -- Update canvas sizes
    for _, tab in pairs(tabs) do
        local contentHeight = 0
        for _, child in pairs(tab:GetChildren()) do
            if child:IsA("GuiObject") then
                contentHeight = math.max(contentHeight, child.Position.Y.Offset + child.Size.Y.Offset)
            end
        end
        tab.CanvasSize = UDim2.new(0, 0, 0, contentHeight + 20)
    end
    
    -- Open/Close Keybind (Right Shift)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
            mainWindow.Visible = not mainWindow.Visible
        end
    end)
    
    -- Mobile Toggle Button
    if isMobile then
        local mobileBtn = Instance.new("TextButton")
        mobileBtn.Size = UDim2.new(0, 60, 0, 60)
        mobileBtn.Position = UDim2.new(0, 20, 0.5, -30)
        mobileBtn.BackgroundColor3 = CONFIG.colors.accent
        mobileBtn.Text = "CADU"
        mobileBtn.TextColor3 = Color3.new(1, 1, 1)
        mobileBtn.Font = Enum.Font.GothamBold
        mobileBtn.TextSize = 14
        mobileBtn.Parent = gui
        createCorner(mobileBtn, 30)
        createStroke(mobileBtn, CONFIG.colors.accent2, 2)
        
        mobileBtn.MouseButton1Click:Connect(function()
            mainWindow.Visible = not mainWindow.Visible
        end)
    end
end

-- MAIN LOOP
createConnection(RunService.RenderStepped, function()
    if isUIOpen then
        updatePlayerSphere()
        updateBallAuras()
        -- NOVO: Atualizar círculo do Quantum Reach
        if quantumCircle and HRP then
            quantumCircle.Position = HRP.Position
            quantumCircle.Transparency = (CONFIG.quantumReachEnabled and CONFIG.showVisuals) and 0.75 or 1
        end
    end
    doReach()
    -- NOVO: Executar Quantum Reach Touch
    doQuantumReach()
end)

-- Initialize
buildMainGUI()

-- Notification
local function notify(text, color)
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 300, 0, 60)
    notif.Position = UDim2.new(1, 20, 1, -80)
    notif.BackgroundColor3 = color or CONFIG.colors.accent
    notif.BorderSizePixel = 0
    notif.Parent = player:WaitForChild("PlayerGui")
    createCorner(notif, 10)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.Parent = notif
    
    TweenService:Create(notif, TweenInfo.new(0.5), {
        Position = UDim2.new(1, -320, 1, -80)
    }):Play()
    
    task.delay(3, function()
        TweenService:Create(notif, TweenInfo.new(0.5), {
            Position = UDim2.new(1, 20, 1, -80)
        }):Play()
        task.wait(0.5)
        notif:Destroy()
    end)
end

notify("CaduHub Premium Loaded! Press Right Shift to toggle", CONFIG.colors.success)
