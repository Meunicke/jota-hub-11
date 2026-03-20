--[[
    CAFUXZ1 Hub v17.1 - MOBILE TOTE SYSTEM v4.1 (FIXED)
    Corrigido para executores mobile - Sem criação de arquivos
]]

-- Verificações de segurança iniciais
if not game then return end
if not game:IsLoaded() then game.Loaded:Wait() end

task.wait(0.5)

-- Serviços com verificação
local Players = game:FindFirstChildOfClass("Players")
local RunService = game:FindFirstChildOfClass("RunService")
local UserInputService = game:FindFirstChildOfClass("UserInputService")
local Workspace = game:FindFirstChildOfClass("Workspace")
local CoreGui = game:FindFirstChild("CoreGui")
local TweenService = game:FindFirstChildOfClass("TweenService")

if not (Players and RunService and UserInputService and Workspace and CoreGui) then
    warn("CAFUXZ1: Serviços não encontrados")
    return
end

local player = Players.LocalPlayer
if not player then
    warn("CAFUXZ1: LocalPlayer não encontrado")
    return
end

-- Aguardar character com timeout
local char = player.Character
if not char then
    local success = pcall(function()
        char = player.CharacterAdded:Wait()
    end)
    if not success or not char then
        warn("CAFUXZ1: Character não carregou")
        return
    end
end

local hrp = char:FindFirstChild("HumanoidRootPart")
if not hrp then
    warn("CAFUXZ1: HumanoidRootPart não encontrado")
    return
end

-- Limpar GUIs antigas (com proteção)
pcall(function()
    for _, obj in ipairs(CoreGui:GetChildren()) do
        if obj:IsA("ScreenGui") and obj.Name:match("CAFUXZ1") then
            obj:Destroy()
        end
    end
end)

-- ============================================
-- CONFIGURAÇÕES MOBILE TOTE v4.1
-- ============================================
local TOTE = {
    aimAngleX = 0,
    aimAngleY = 0,
    power = 50,
    isCharging = false,
    chargeValue = 0,
    maxPower = 100,
    minPower = 15,
    curve = 50,
    lift = 30,
    savedConfigs = {},
    selectedSlot = 1,
    previewEnabled = true,
    previewParts = {},
    direction = "R",
    colors = {
        primary = Color3.fromRGB(99, 102, 241),
        left = Color3.fromRGB(59, 130, 246),
        right = Color3.fromRGB(239, 68, 68),
        power = Color3.fromRGB(239, 68, 68),
        curve = Color3.fromRGB(251, 191, 36),
        preview = Color3.fromRGB(0, 255, 136),
        slots = {
            Color3.fromRGB(34, 197, 94),
            Color3.fromRGB(234, 179, 8),
            Color3.fromRGB(239, 68, 68)
        }
    }
}

-- ============================================
-- GUI MOBILE (Criada em pcall)
-- ============================================
local mobileGui, mainFrame

local success, err = pcall(function()
    mobileGui = Instance.new("ScreenGui")
    mobileGui.Name = "CAFUXZ1_MobileTote"
    mobileGui.ResetOnSpawn = false
    mobileGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    mobileGui.Parent = CoreGui
    
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "Main"
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.BackgroundTransparency = 1
    mainFrame.Parent = mobileGui
end)

if not success then
    warn("CAFUXZ1: Falha ao criar GUI - " .. tostring(err))
    return
end

-- ============================================
-- FUNÇÃO HELPER: Criar elementos com segurança
-- ============================================
local function safeCreate(className, parent, properties)
    local success, obj = pcall(function()
        local obj = Instance.new(className)
        if parent then obj.Parent = parent end
        if properties then
            for prop, value in pairs(properties) do
                pcall(function()
                    obj[prop] = value
                end)
            end
        end
        return obj
    end)
    return success and obj or nil
end

-- ============================================
-- CONSTRUÇÃO DA INTERFACE (Tudo em pcall)
-- ============================================

-- Preview Frame
local previewFrame = safeCreate("Frame", mainFrame, {
    Name = "PreviewArea",
    Size = UDim2.new(0.9, 0, 0.35, 0),
    Position = UDim2.new(0.05, 0, 0.05, 0),
    BackgroundColor3 = Color3.fromRGB(15, 23, 42),
    BorderSizePixel = 0
})

if previewFrame then
    safeCreate("UICorner", previewFrame, {CornerRadius = UDim.new(0, 16)})
    
    local previewLabel = safeCreate("TextLabel", previewFrame, {
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 5),
        BackgroundTransparency = 1,
        Text = "PREVIEW DO CHUTE",
        TextColor3 = TOTE.colors.preview,
        TextSize = 16,
        Font = Enum.Font.GothamBold
    })
    
    TOTE.shotInfo = safeCreate("TextLabel", previewFrame, {
        Name = "ShotInfo",
        Size = UDim2.new(1, 0, 0, 25),
        Position = UDim2.new(0, 0, 1, -30),
        BackgroundTransparency = 1,
        Text = "Força: 50% | Curva: 50% | Ângulo: 0°",
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextSize = 12,
        Font = Enum.Font.Gotham
    })
end

-- Joystick Frame
local joystickFrame = safeCreate("Frame", mainFrame, {
    Name = "Joystick",
    Size = UDim2.new(0, 140, 0, 140),
    Position = UDim2.new(0, 20, 0.45, 0),
    BackgroundColor3 = Color3.fromRGB(30, 30, 50),
    BorderSizePixel = 0
})

local joystickKnob, joystickTouch
if joystickFrame then
    safeCreate("UICorner", joystickFrame, {CornerRadius = UDim.new(1, 0)})
    
    joystickKnob = safeCreate("Frame", joystickFrame, {
        Name = "Knob",
        Size = UDim2.new(0, 50, 0, 50),
        Position = UDim2.new(0.5, -25, 0.5, -25),
        BackgroundColor3 = TOTE.colors.primary,
        BorderSizePixel = 0
    })
    
    if joystickKnob then
        safeCreate("UICorner", joystickKnob, {CornerRadius = UDim.new(1, 0)})
    end
    
    -- Touch area invisível (maior)
    joystickTouch = safeCreate("TextButton", joystickFrame, {
        Name = "TouchArea",
        Size = UDim2.new(1, 40, 1, 40),
        Position = UDim2.new(0, -20, 0, -20),
        BackgroundTransparency = 1,
        Text = ""
    })
    
    safeCreate("TextLabel", joystickFrame, {
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 1, 10),
        BackgroundTransparency = 1,
        Text = "MIRA",
        TextColor3 = TOTE.colors.primary,
        TextSize = 14,
        Font = Enum.Font.GothamBold
    })
end

-- Power Button
local powerFrame = safeCreate("Frame", mainFrame, {
    Name = "PowerButton",
    Size = UDim2.new(0, 130, 0, 130),
    Position = UDim2.new(1, -150, 0.45, 0),
    BackgroundTransparency = 1
})

local powerFill, powerButton
if powerFrame then
    local powerBg = safeCreate("Frame", powerFrame, {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(30, 30, 50),
        BorderSizePixel = 0
    })
    if powerBg then safeCreate("UICorner", powerBg, {CornerRadius = UDim.new(1, 0)}) end
    
    powerFill = safeCreate("Frame", powerFrame, {
        Name = "Fill",
        Size = UDim2.new(0.85, 0, 0.85, 0),
        Position = UDim2.new(0.075, 0, 0.075, 0),
        BackgroundColor3 = TOTE.colors.power,
        BorderSizePixel = 0
    })
    if powerFill then safeCreate("UICorner", powerFill, {CornerRadius = UDim.new(1, 0)}) end
    
    powerButton = safeCreate("TextButton", powerFrame, {
        Name = "Touch",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "50%",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 24,
        Font = Enum.Font.GothamBold
    })
    
    safeCreate("TextLabel", powerFrame, {
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 1, 10),
        BackgroundTransparency = 1,
        Text = "SEGURE",
        TextColor3 = TOTE.colors.power,
        TextSize = 14,
        Font = Enum.Font.GothamBold
    })
end

-- Curve Slider
local curveFrame = safeCreate("Frame", mainFrame, {
    Name = "CurveSlider",
    Size = UDim2.new(0.5, 0, 0, 60),
    Position = UDim2.new(0.25, 0, 0.42, 0),
    BackgroundTransparency = 1
})

local curveFill, curveValue, curveBg
if curveFrame then
    safeCreate("TextLabel", curveFrame, {
        Size = UDim2.new(1, 0, 0, 20),
        Text = "CURVA",
        TextColor3 = TOTE.colors.curve,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        BackgroundTransparency = 1
    })
    
    curveBg = safeCreate("Frame", curveFrame, {
        Size = UDim2.new(1, 0, 0, 25),
        Position = UDim2.new(0, 0, 0, 22),
        BackgroundColor3 = Color3.fromRGB(40, 40, 60),
        BorderSizePixel = 0
    })
    if curveBg then safeCreate("UICorner", curveBg, {CornerRadius = UDim.new(0, 12)}) end
    
    curveFill = safeCreate("Frame", curveFrame, {
        Name = "Fill",
        Size = UDim2.new(0.5, 0, 1, 0),
        BackgroundColor3 = TOTE.colors.curve,
        BorderSizePixel = 0
    })
    if curveFill then safeCreate("UICorner", curveFill, {CornerRadius = UDim.new(0, 12)}) end
    
    curveValue = safeCreate("TextLabel", curveFrame, {
        Size = UDim2.new(0, 40, 0, 25),
        Position = UDim2.new(0.5, -20, 0, 22),
        Text = "50",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        BackgroundTransparency = 1
    })
    
    -- Botões +/- (simplificados)
    safeCreate("TextButton", curveFrame, {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0, -35, 0, 20),
        Text = "-",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 20,
        BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    })
    
    safeCreate("TextButton", curveFrame, {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, 5, 0, 20),
        Text = "+",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 20,
        BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    })
end

-- Save Slots
local slotsFrame = safeCreate("Frame", mainFrame, {
    Name = "SaveSlots",
    Size = UDim2.new(0, 180, 0, 50),
    Position = UDim2.new(1, -190, 0.05, 0),
    BackgroundTransparency = 1
})

local slots = {}
if slotsFrame then
    for i = 1, 3 do
        local slot = safeCreate("TextButton", slotsFrame, {
            Name = "Slot" .. i,
            Size = UDim2.new(0, 55, 0, 45),
            Position = UDim2.new(0, (i-1) * 60, 0, 0),
            Text = tostring(i),
            TextColor3 = Color3.new(1, 1, 1),
            TextSize = 20,
            Font = Enum.Font.GothamBold,
            BackgroundColor3 = (i == 1) and TOTE.colors.slots[i] or Color3.fromRGB(60, 60, 80)
        })
        if slot then
            safeCreate("UICorner", slot, {CornerRadius = UDim.new(0, 10)})
            
            local indicator = safeCreate("Frame", slot, {
                Name = "Saved",
                Size = UDim2.new(0, 8, 0, 8),
                Position = UDim2.new(1, -12, 0, 4),
                BackgroundColor3 = Color3.fromRGB(0, 255, 0),
                BorderSizePixel = 0,
                Visible = false
            })
            if indicator then safeCreate("UICorner", indicator, {CornerRadius = UDim.new(1, 0)}) end
            
            slots[i] = {button = slot, indicator = indicator, data = nil}
        end
    end
end

-- Kick Buttons (Grandes)
local kickContainer = safeCreate("Frame", mainFrame, {
    Name = "KickButtons",
    Size = UDim2.new(0.9, 0, 0, 120),
    Position = UDim2.new(0.05, 0, 0.68, 0),
    BackgroundTransparency = 1
})

local kickLeft, kickRight
if kickContainer then
    kickLeft = safeCreate("TextButton", kickContainer, {
        Name = "KickF",
        Size = UDim2.new(0.48, 0, 1, 0),
        BackgroundColor3 = TOTE.colors.left,
        Text = "<- CHUTE [F]",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 18,
        Font = Enum.Font.GothamBold
    })
    if kickLeft then safeCreate("UICorner", kickLeft, {CornerRadius = UDim.new(0, 16)}) end
    
    kickRight = safeCreate("TextButton", kickContainer, {
        Name = "KickR",
        Size = UDim2.new(0.48, 0, 1, 0),
        Position = UDim2.new(0.52, 0, 0, 0),
        BackgroundColor3 = TOTE.colors.right,
        Text = "CHUTE [R] ->",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 18,
        Font = Enum.Font.GothamBold
    })
    if kickRight then safeCreate("UICorner", kickRight, {CornerRadius = UDim.new(0, 16)}) end
end

-- Preview Toggle
local previewToggle = safeCreate("TextButton", mainFrame, {
    Size = UDim2.new(0, 100, 0, 35),
    Position = UDim2.new(0.05, 0, 0.42, 0),
    BackgroundColor3 = TOTE.colors.preview,
    Text = "PREVIEW: ON",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 12,
    Font = Enum.Font.GothamBold
})
if previewToggle then safeCreate("UICorner", previewToggle, {CornerRadius = UDim.new(0, 8)}) end

-- ============================================
-- FUNÇÕES DO SISTEMA (Todas com pcall)
-- ============================================

local function updateShotInfo()
    pcall(function()
        if TOTE.shotInfo then
            local angleText = math.floor(TOTE.aimAngleX * 45)
            TOTE.shotInfo.Text = string.format("Força: %d%% | Curva: %d%% | Ângulo: %d°", 
                TOTE.power, TOTE.curve, angleText)
        end
    end)
end

local function clearPreview()
    pcall(function()
        for _, part in ipairs(TOTE.previewParts) do
            if part then part:Destroy() end
        end
        TOTE.previewParts = {}
    end)
end

local function calculateTrajectory()
    if not hrp or not hrp.Parent then return {} end
    
    local ball = nil
    local nearestDist = math.huge
    
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name:find("Ball") or obj.Name:find("Bola") or obj.Name:find("Soccer")) then
                if obj.Position then
                    local dist = (obj.Position - hrp.Position).Magnitude
                    if dist < nearestDist and dist < 20 then
                        nearestDist = dist
                        ball = obj
                    end
                end
            end
        end
    end)
    
    if not ball then return {} end
    
    local startPos = ball.Position
    local charCF = hrp.CFrame
    local sideDir = (TOTE.direction == "R") and 1 or -1
    
    local forward = charCF.LookVector
    local right = charCF.RightVector * sideDir
    local up = charCF.UpVector
    
    local aimX = TOTE.aimAngleX * 0.6
    local aimY = TOTE.aimAngleY * 0.4
    
    local aimVector = (forward * (1 - math.abs(aimX))) + (right * aimX) + (up * aimY)
    aimVector = aimVector.Unit
    
    local distance = TOTE.power * 0.4
    local curveAmount = TOTE.curve * 0.02
    
    local p0 = startPos
    local p1 = startPos + (aimVector * distance * 0.3) + (up * TOTE.lift * 0.3)
    local p2 = startPos + (aimVector * distance * 0.7) + (right * curveAmount * 5) + (up * TOTE.lift)
    local p3 = startPos + (aimVector * distance) + (right * curveAmount * 8)
    
    local points = {}
    for t = 0, 1, 0.1 do
        local t2 = t * t
        local t3 = t2 * t
        local mt = 1 - t
        local mt2 = mt * mt
        local mt3 = mt2 * mt
        
        local point = (p0 * mt3) + (p1 * 3 * mt2 * t) + (p2 * 3 * mt * t2) + (p3 * t3)
        table.insert(points, point)
    end
    
    return points
end

local function updatePreview()
    clearPreview()
    if not TOTE.previewEnabled then return end
    
    local points = calculateTrajectory()
    if #points == 0 then return end
    
    pcall(function()
        for i, point in ipairs(points) do
            local part = Instance.new("Part")
            part.Shape = Enum.PartType.Ball
            part.Size = Vector3.new(1.5 - (i * 0.1), 1.5 - (i * 0.1), 1.5 - (i * 0.1))
            part.Position = point
            part.Anchored = true
            part.CanCollide = false
            part.Material = Enum.Material.Neon
            part.Color = TOTE.colors.preview
            part.Transparency = 0.3
            part.Parent = Workspace
            table.insert(TOTE.previewParts, part)
        end
    end)
end

local function saveConfig(slotIndex)
    TOTE.savedConfigs[slotIndex] = {
        aimAngleX = TOTE.aimAngleX,
        aimAngleY = TOTE.aimAngleY,
        power = TOTE.power,
        curve = TOTE.curve,
        timestamp = tick()
    }
    
    if slots[slotIndex] then
        slots[slotIndex].data = TOTE.savedConfigs[slotIndex]
        pcall(function()
            slots[slotIndex].indicator.Visible = true
            slots[slotIndex].button.BackgroundColor3 = TOTE.colors.slots[slotIndex]
        end)
    end
    
    print("💾 Config [" .. slotIndex .. "] salva!")
end

local function loadConfig(slotIndex)
    local config = TOTE.savedConfigs[slotIndex]
    if not config then
        print("⚠️ Slot [" .. slotIndex .. "] vazio")
        return
    end
    
    TOTE.aimAngleX = config.aimAngleX
    TOTE.aimAngleY = config.aimAngleY
    TOTE.power = config.power
    TOTE.curve = config.curve
    
    pcall(function()
        if curveFill then curveFill.Size = UDim2.new(TOTE.curve / 100, 0, 1, 0) end
        if curveValue then curveValue.Text = tostring(TOTE.curve) end
        if powerButton then powerButton.Text = tostring(TOTE.power) .. "%" end
        
        if joystickKnob then
            joystickKnob.Position = UDim2.new(0.5, -25, 0.5, -25)
        end
        
        for i, s in ipairs(slots) do
            if s and s.button then
                s.button.BackgroundColor3 = (i == slotIndex) and TOTE.colors.slots[i] or Color3.fromRGB(60, 60, 80)
            end
        end
    end)
    
    TOTE.selectedSlot = slotIndex
    updateShotInfo()
    updatePreview()
    print("📂 Config [" .. slotIndex .. "] carregada!")
end

local function executeKick(direction)
    TOTE.direction = direction
    
    local ball = nil
    local nearestDist = math.huge
    
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name:find("Ball") or obj.Name:find("Bola") or obj.Name:find("Soccer")) then
                if obj.Position then
                    local dist = (obj.Position - hrp.Position).Magnitude
                    if dist < nearestDist and dist < 20 then
                        nearestDist = dist
                        ball = obj
                    end
                end
            end
        end
    end)
    
    if not ball then return end
    
    local charCF = hrp.CFrame
    local sideDir = (direction == "R") and 1 or -1
    local forward = charCF.LookVector
    local right = charCF.RightVector * sideDir
    local up = charCF.UpVector
    
    local aimX = TOTE.aimAngleX * 0.6
    local aimY = TOTE.aimAngleY * 0.4
    
    local kickVector = (forward * (1 - math.abs(aimX)) * (TOTE.power / 100)) + 
                       (right * aimX) + 
                       (up * (0.2 + aimY) * (TOTE.power / 100))
    
    local finalPower = math.min(TOTE.power, 75)
    
    -- Animação do botão
    pcall(function()
        local btn = (direction == "R") and kickRight or kickLeft
        if btn then
            btn.BackgroundColor3 = Color3.new(1, 1, 1)
            task.delay(0.1, function()
                btn.BackgroundColor3 = (direction == "R") and TOTE.colors.right or TOTE.colors.left
            end)
        end
    end)
    
    -- Executar chute
    pcall(function()
        firetouchinterest(ball, hrp, 0)
        task.wait(0.03)
        firetouchinterest(ball, hrp, 1)
        
        local startTime = tick()
        local duration = 0.35
        
        while tick() - startTime < duration do
            if not ball or not ball.Parent then break end
            
            local elapsed = tick() - startTime
            local progress = elapsed / duration
            local ease = math.sin(progress * math.pi * 0.5)
            
            local move = kickVector * finalPower * ease * 0.06
            local curveForce = right * TOTE.curve * 0.008 * math.sin(progress * math.pi)
            
            ball.CFrame = ball.CFrame + move + curveForce
            
            task.wait(0.03)
        end
        
        task.wait(0.05)
        firetouchinterest(ball, hrp, 0)
        firetouchinterest(ball, hrp, 1)
    end)
    
    print("⚽ Chute " .. direction .. " executado!")
end

-- ============================================
-- CONEXÕES DE INPUT (Com verificações)
-- ============================================

-- Joystick
if joystickTouch and joystickKnob then
    local joystickActive = false
    local joystickCenter = nil
    local maxDist = 35
    
    joystickTouch.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            joystickActive = true
            local absPos = joystickFrame.AbsolutePosition
            local absSize = joystickFrame.AbsoluteSize
            joystickCenter = Vector2.new(absPos.X + absSize.X/2, absPos.Y + absSize.Y/2)
        end
    end)
    
    joystickTouch.InputChanged:Connect(function(input)
        if joystickActive and input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - joystickCenter
            local dist = math.min(delta.Magnitude, maxDist)
            local angle = math.atan2(delta.Y, delta.X)
            
            local limited = Vector2.new(math.cos(angle) * dist, math.sin(angle) * dist)
            joystickKnob.Position = UDim2.new(0.5, limited.X - 25, 0.5, limited.Y - 25)
            
            TOTE.aimAngleX = limited.X / maxDist
            TOTE.aimAngleY = limited.Y / maxDist
            
            updateShotInfo()
        end
    end)
    
    local function endJoystick()
        joystickActive = false
        pcall(function()
            joystickKnob:TweenPosition(UDim2.new(0.5, -25, 0.5, -25), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
        end)
        TOTE.aimAngleX = 0
        TOTE.aimAngleY = 0
        updateShotInfo()
    end
    
    joystickTouch.InputEnded:Connect(endJoystick)
    joystickTouch.InputCancelled:Connect(endJoystick)
end

-- Power Button
if powerButton and powerFill then
    local powerActive = false
    local chargeConnection = nil
    
    powerButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            powerActive = true
            TOTE.isCharging = true
            TOTE.chargeValue = 0
            
            chargeConnection = RunService.Heartbeat:Connect(function()
                if not powerActive then return end
                TOTE.chargeValue = math.min(TOTE.chargeValue + 2, 100)
                TOTE.power = TOTE.minPower + math.floor((TOTE.chargeValue / 100) * (TOTE.maxPower - TOTE.minPower))
                
                pcall(function()
                    powerButton.Text = tostring(TOTE.power) .. "%"
                    local scale = 0.2 + (TOTE.chargeValue / 100) * 0.65
                    powerFill.Size = UDim2.new(scale, 0, scale, 0)
                    powerFill.Position = UDim2.new((1 - scale) / 2, 0, (1 - scale) / 2, 0)
                end)
                
                updateShotInfo()
            end)
        end
    end)
    
    local function endPower()
        powerActive = false
        TOTE.isCharging = false
        if chargeConnection then
            chargeConnection:Disconnect()
            chargeConnection = nil
        end
        TOTE.chargeValue = 0
    end
    
    powerButton.InputEnded:Connect(endPower)
    powerButton.InputCancelled:Connect(endPower)
end

-- Curve Slider (simplificado - só botões +/-)
if curveBg and curveFill and curveValue then
    -- Ajuste via touch no bg
    local curveDragging = false
    
    curveBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            curveDragging = true
            local pos = input.Position.X - curveBg.AbsolutePosition.X
            local percent = math.clamp(pos / curveBg.AbsoluteSize.X, 0, 1)
            TOTE.curve = math.floor(percent * 100)
            curveFill.Size = UDim2.new(percent, 0, 1, 0)
            curveValue.Text = tostring(TOTE.curve)
            updateShotInfo()
        end
    end)
    
    curveBg.InputChanged:Connect(function(input)
        if curveDragging and input.UserInputType == Enum.UserInputType.Touch then
            local pos = input.Position.X - curveBg.AbsolutePosition.X
            local percent = math.clamp(pos / curveBg.AbsoluteSize.X, 0, 1)
            TOTE.curve = math.floor(percent * 100)
            curveFill.Size = UDim2.new(percent, 0, 1, 0)
            curveValue.Text = tostring(TOTE.curve)
            updateShotInfo()
        end
    end)
    
    curveBg.InputEnded:Connect(function() curveDragging = false end)
end

-- Save Slots
for i, slot in ipairs(slots) do
    if slot and slot.button then
        local holdStart = 0
        
        slot.button.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                holdStart = tick()
            end
        end)
        
        slot.button.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                if tick() - holdStart > 0.4 then
                    saveConfig(i)
                else
                    loadConfig(i)
                end
            end
        end)
    end
end

-- Kick Buttons
if kickLeft then
    kickLeft.MouseButton1Click:Connect(function() executeKick("F") end)
end

if kickRight then
    kickRight.MouseButton1Click:Connect(function() executeKick("R") end)
end

-- Preview Toggle
if previewToggle then
    previewToggle.MouseButton1Click:Connect(function()
        TOTE.previewEnabled = not TOTE.previewEnabled
        previewToggle.Text = TOTE.previewEnabled and "PREVIEW: ON" or "PREVIEW: OFF"
        previewToggle.BackgroundColor3 = TOTE.previewEnabled and TOTE.colors.preview or Color3.fromRGB(100, 100, 100)
        updatePreview()
    end)
end

-- ============================================
-- LOOP E INIT
-- ============================================
RunService.RenderStepped:Connect(function()
    if TOTE.previewEnabled and (math.abs(TOTE.aimAngleX) > 0.05 or math.abs(TOTE.aimAngleY) > 0.05) then
        if tick() % 0.15 < 0.03 then
            updatePreview()
        end
    end
end)

-- Character respawn
player.CharacterAdded:Connect(function(newChar)
    char = newChar
    hrp = newChar:WaitForChild("HumanoidRootPart")
    task.wait(0.5)
    updatePreview()
end)

updateShotInfo()
updatePreview()

print("========================================")
print("⚽ CAFUXZ1 MOBILE TOTE v4.1")
print("✅ Loaded Successfully (Mobile Safe)")
print("========================================")
