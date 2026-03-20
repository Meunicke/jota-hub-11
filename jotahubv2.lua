--[[
    CAFUXZ1 Hub v17.0 - MOBILE TOTE SYSTEM v4.0 PRO
    Interface Touch Completa | Joystick de Mira | Save System
]]

task.wait(0.5)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Camera = Workspace.CurrentCamera

local player = Players.LocalPlayer
if not player then return end

local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

-- Limpar GUIs antigas
pcall(function()
    for _, obj in ipairs(CoreGui:GetChildren()) do
        if obj.Name:match("CAFUXZ1") then obj:Destroy() end
    end
end)

-- ============================================
-- CONFIGURAÇÕES MOBILE TOTE v4.0
-- ============================================
local TOTE = {
    -- Mira
    aimDirection = Vector2.new(0, 0), -- X = lado, Y = altura
    aimAngleX = 0, -- -1 a 1 (esquerda/direita)
    aimAngleY = 0, -- -1 a 1 (baixo/cima)
    maxAimDistance = 50,
    
    -- Força
    power = 50,
    isCharging = false,
    chargeValue = 0,
    maxPower = 100,
    minPower = 15,
    
    -- Curva
    curve = 50, -- 0 a 100
    lift = 30,
    
    -- Save System
    savedConfigs = {},
    selectedSlot = 1,
    
    -- Preview
    previewEnabled = true,
    previewParts = {},
    
    -- Estado
    direction = "R",
    isAiming = false,
    
    -- Cores
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
-- GUI MOBILE PRINCIPAL
-- ============================================
local mobileGui = Instance.new("ScreenGui")
mobileGui.Name = "CAFUXZ1_MobileTote"
mobileGui.ResetOnSpawn = false
mobileGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
mobileGui.Parent = CoreGui

-- Frame principal (ocupa tela toda)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "Main"
mainFrame.Size = UDim2.new(1, 0, 1, 0)
mainFrame.BackgroundTransparency = 1
mainFrame.Parent = mobileGui

-- ============================================
-- ÁREA DE PREVIEW (Topo)
-- ============================================
local previewFrame = Instance.new("Frame")
previewFrame.Name = "PreviewArea"
previewFrame.Size = UDim2.new(0.9, 0, 0.35, 0)
previewFrame.Position = UDim2.new(0.05, 0, 0.05, 0)
previewFrame.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
previewFrame.BorderSizePixel = 0
previewFrame.Parent = mainFrame

Instance.new("UICorner", previewFrame).CornerRadius = UDim.new(0, 16)

local previewStroke = Instance.new("UIStroke")
previewStroke.Color = TOTE.colors.preview
previewStroke.Thickness = 2
previewStroke.Parent = previewFrame

local previewLabel = Instance.new("TextLabel")
previewLabel.Size = UDim2.new(1, 0, 0, 30)
previewLabel.Position = UDim2.new(0, 0, 0, 5)
previewLabel.BackgroundTransparency = 1
previewLabel.Text = "👁️ PREVIEW DO CHUTE"
previewLabel.TextColor3 = TOTE.colors.preview
previewLabel.TextSize = 16
previewLabel.Font = Enum.Font.GothamBold
previewLabel.Parent = previewFrame

-- Info do chute atual
local shotInfo = Instance.new("TextLabel")
shotInfo.Name = "ShotInfo"
shotInfo.Size = UDim2.new(1, 0, 0, 25)
shotInfo.Position = UDim2.new(0, 0, 1, -30)
shotInfo.BackgroundTransparency = 1
shotInfo.Text = "Força: 50% | Curva: 50% | Ângulo: 0°"
shotInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
shotInfo.TextSize = 12
shotInfo.Font = Enum.Font.Gotham
shotInfo.Parent = previewFrame

-- ============================================
-- JOYSTICK DE MIRA (Esquerda)
-- ============================================
local joystickFrame = Instance.new("Frame")
joystickFrame.Name = "Joystick"
joystickFrame.Size = UDim2.new(0, 140, 0, 140)
joystickFrame.Position = UDim2.new(0, 20, 0.45, 0)
joystickFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
joystickFrame.BorderSizePixel = 0
joystickFrame.Parent = mainFrame

Instance.new("UICorner", joystickFrame).CornerRadius = UDim.new(1, 0)

local joystickStroke = Instance.new("UIStroke")
joystickStroke.Color = TOTE.colors.primary
joystickStroke.Thickness = 3
joystickStroke.Parent = joystickFrame

-- Área de toque do joystick (invisível, maior)
local joystickTouch = Instance.new("TextButton")
joystickTouch.Name = "TouchArea"
joystickTouch.Size = UDim2.new(1, 40, 1, 40)
joystickTouch.Position = UDim2.new(0, -20, 0, -20)
joystickTouch.BackgroundTransparency = 1
joystickTouch.Text = ""
joystickTouch.Parent = joystickFrame

-- Knob do joystick
local joystickKnob = Instance.new("Frame")
joystickKnob.Name = "Knob"
joystickKnob.Size = UDim2.new(0, 50, 0, 50)
joystickKnob.Position = UDim2.new(0.5, -25, 0.5, -25)
joystickKnob.BackgroundColor3 = TOTE.colors.primary
joystickKnob.BorderSizePixel = 0
joystickKnob.Parent = joystickFrame

Instance.new("UICorner", joystickKnob).CornerRadius = UDim.new(1, 0)

local knobStroke = Instance.new("UIStroke")
knobStroke.Color = Color3.new(1, 1, 1)
knobStroke.Thickness = 2
knobStroke.Parent = joystickKnob

-- Label
local joystickLabel = Instance.new("TextLabel")
joystickLabel.Size = UDim2.new(1, 0, 0, 20)
joystickLabel.Position = UDim2.new(0, 0, 1, 10)
joystickLabel.BackgroundTransparency = 1
joystickLabel.Text = "MIRA"
joystickLabel.TextColor3 = TOTE.colors.primary
joystickLabel.TextSize = 14
joystickLabel.Font = Enum.Font.GothamBold
joystickLabel.Parent = joystickFrame

-- ============================================
-- BOTÃO DE FORÇA CIRCULAR (Direita)
-- ============================================
local powerFrame = Instance.new("Frame")
powerFrame.Name = "PowerButton"
powerFrame.Size = UDim2.new(0, 130, 0, 130)
powerFrame.Position = UDim2.new(1, -150, 0.45, 0)
powerFrame.BackgroundTransparency = 1
powerFrame.Parent = mainFrame

-- Círculo de fundo
local powerBg = Instance.new("Frame")
powerBg.Size = UDim2.new(1, 0, 1, 0)
powerBg.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
powerBg.BorderSizePixel = 0
powerBg.Parent = powerFrame
Instance.new("UICorner", powerBg).CornerRadius = UDim.new(1, 0)

local powerStroke = Instance.new("UIStroke")
powerStroke.Color = TOTE.colors.power
powerStroke.Thickness = 3
powerStroke.Parent = powerBg

-- Fill circular (usando Frame com CornerRadius)
local powerFill = Instance.new("Frame")
powerFill.Name = "Fill"
powerFill.Size = UDim2.new(0.85, 0, 0.85, 0)
powerFill.Position = UDim2.new(0.075, 0, 0.075, 0)
powerFill.BackgroundColor3 = TOTE.colors.power
powerFill.BorderSizePixel = 0
powerFill.Parent = powerFrame
Instance.new("UICorner", powerFill).CornerRadius = UDim.new(1, 0)

-- Botão de toque
local powerButton = Instance.new("TextButton")
powerButton.Name = "Touch"
powerButton.Size = UDim2.new(1, 0, 1, 0)
powerButton.BackgroundTransparency = 1
powerButton.Text = "50%"
powerButton.TextColor3 = Color3.new(1, 1, 1)
powerButton.TextSize = 24
powerButton.Font = Enum.Font.GothamBold
powerButton.Parent = powerFrame

-- Label
local powerLabel = Instance.new("TextLabel")
powerLabel.Size = UDim2.new(1, 0, 0, 20)
powerLabel.Position = UDim2.new(0, 0, 1, 10)
powerLabel.BackgroundTransparency = 1
powerLabel.Text = "SEGURE"
powerLabel.TextColor3 = TOTE.colors.power
powerLabel.TextSize = 14
powerLabel.Font = Enum.Font.GothamBold
powerLabel.Parent = powerFrame

-- ============================================
-- SLIDER DE CURVA (Centro)
-- ============================================
local curveFrame = Instance.new("Frame")
curveFrame.Name = "CurveSlider"
curveFrame.Size = UDim2.new(0.5, 0, 0, 60)
curveFrame.Position = UDim2.new(0.25, 0, 0.42, 0)
curveFrame.BackgroundTransparency = 1
curveFrame.Parent = mainFrame

local curveLabel = Instance.new("TextLabel")
curveLabel.Size = UDim2.new(1, 0, 0, 20)
curveLabel.Text = "CURVA"
curveLabel.TextColor3 = TOTE.colors.curve
curveLabel.TextSize = 12
curveLabel.Font = Enum.Font.GothamBold
curveLabel.BackgroundTransparency = 1
curveLabel.Parent = curveFrame

local curveBg = Instance.new("Frame")
curveBg.Size = UDim2.new(1, 0, 0, 25)
curveBg.Position = UDim2.new(0, 0, 0, 22)
curveBg.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
curveBg.BorderSizePixel = 0
curveBg.Parent = curveFrame
Instance.new("UICorner", curveBg).CornerRadius = UDim.new(0, 12)

local curveFill = Instance.new("Frame")
curveFill.Name = "Fill"
curveFill.Size = UDim2.new(0.5, 0, 1, 0)
curveFill.BackgroundColor3 = TOTE.colors.curve
curveFill.BorderSizePixel = 0
curveFill.Parent = curveBg
Instance.new("UICorner", curveFill).CornerRadius = UDim.new(0, 12)

local curveValue = Instance.new("TextLabel")
curveValue.Size = UDim2.new(0, 40, 0, 25)
curveValue.Position = UDim2.new(0.5, -20, 0, 22)
curveValue.Text = "50"
curveValue.TextColor3 = Color3.new(1, 1, 1)
curveValue.TextSize = 14
curveValue.Font = Enum.Font.GothamBold
curveValue.BackgroundTransparency = 1
curveValue.Parent = curveFrame

-- Botões de ajuste de curva
local curveMinus = Instance.new("TextButton")
curveMinus.Size = UDim2.new(0, 30, 0, 30)
curveMinus.Position = UDim2.new(0, -35, 0, 20)
curveMinus.Text = "-"
curveMinus.TextColor3 = Color3.new(1, 1, 1)
curveMinus.TextSize = 20
curveMinus.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
curveMinus.Parent = curveFrame
Instance.new("UICorner", curveMinus).CornerRadius = UDim.new(0, 8)

local curvePlus = Instance.new("TextButton")
curvePlus.Size = UDim2.new(0, 30, 0, 30)
curvePlus.Position = UDim2.new(1, 5, 0, 20)
curvePlus.Text = "+"
curvePlus.TextColor3 = Color3.new(1, 1, 1)
curvePlus.TextSize = 20
curvePlus.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
curvePlus.Parent = curveFrame
Instance.new("UICorner", curvePlus).CornerRadius = UDim.new(0, 8)

-- ============================================
-- SAVE SLOTS (Topo direito)
-- ============================================
local slotsFrame = Instance.new("Frame")
slotsFrame.Name = "SaveSlots"
slotsFrame.Size = UDim2.new(0, 180, 0, 50)
slotsFrame.Position = UDim2.new(1, -190, 0.05, 0)
slotsFrame.BackgroundTransparency = 1
slotsFrame.Parent = mainFrame

local slots = {}
for i = 1, 3 do
    local slot = Instance.new("TextButton")
    slot.Name = "Slot" .. i
    slot.Size = UDim2.new(0, 55, 0, 45)
    slot.Position = UDim2.new(0, (i-1) * 60, 0, 0)
    slot.Text = tostring(i)
    slot.TextColor3 = Color3.new(1, 1, 1)
    slot.TextSize = 20
    slot.Font = Enum.Font.GothamBold
    slot.BackgroundColor3 = (i == 1) and TOTE.colors.slots[i] or Color3.fromRGB(60, 60, 80)
    slot.Parent = slotsFrame
    Instance.new("UICorner", slot).CornerRadius = UDim.new(0, 10)
    
    -- Indicador de salvo
    local savedIndicator = Instance.new("Frame")
    savedIndicator.Name = "Saved"
    savedIndicator.Size = UDim2.new(0, 8, 0, 8)
    savedIndicator.Position = UDim2.new(1, -12, 0, 4)
    savedIndicator.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    savedIndicator.BorderSizePixel = 0
    savedIndicator.Visible = false
    savedIndicator.Parent = slot
    Instance.new("UICorner", savedIndicator).CornerRadius = UDim.new(1, 0)
    
    slots[i] = {
        button = slot,
        indicator = savedIndicator,
        data = nil
    }
end

-- ============================================
-- BOTÕES DE CHUTE (Base - Grandes)
-- ============================================
local kickContainer = Instance.new("Frame")
kickContainer.Name = "KickButtons"
kickContainer.Size = UDim2.new(0.9, 0, 0, 120)
kickContainer.Position = UDim2.new(0.05, 0, 0.68, 0)
kickContainer.BackgroundTransparency = 1
kickContainer.Parent = mainFrame

-- Chute Esquerda [F]
local kickLeft = Instance.new("TextButton")
kickLeft.Name = "KickF"
kickLeft.Size = UDim2.new(0.48, 0, 1, 0)
kickLeft.BackgroundColor3 = TOTE.colors.left
kickLeft.Text = "⬅️\nCHUTE [F]"
kickLeft.TextColor3 = Color3.new(1, 1, 1)
kickLeft.TextSize = 18
kickLeft.Font = Enum.Font.GothamBold
kickLeft.Parent = kickContainer
Instance.new("UICorner", kickLeft).CornerRadius = UDim.new(0, 16)

local leftStroke = Instance.new("UIStroke")
leftStroke.Color = Color3.new(1, 1, 1)
leftStroke.Thickness = 2
leftStroke.Parent = kickLeft

-- Chute Direita [R]
local kickRight = Instance.new("TextButton")
kickRight.Name = "KickR"
kickRight.Size = UDim2.new(0.48, 0, 1, 0)
kickRight.Position = UDim2.new(0.52, 0, 0, 0)
kickRight.BackgroundColor3 = TOTE.colors.right
kickRight.Text = "➡️\nCHUTE [R]"
kickRight.TextColor3 = Color3.new(1, 1, 1)
kickRight.TextSize = 18
kickRight.Font = Enum.Font.GothamBold
kickRight.Parent = kickContainer
Instance.new("UICorner", kickRight).CornerRadius = UDim.new(0, 16)

local rightStroke = Instance.new("UIStroke")
rightStroke.Color = Color3.new(1, 1, 1)
rightStroke.Thickness = 2
rightStroke.Parent = kickRight

-- ============================================
// TOGGLE PREVIEW (Pequeno, canto)
-- ============================================
local previewToggle = Instance.new("TextButton")
previewToggle.Size = UDim2.new(0, 100, 0, 35)
previewToggle.Position = UDim2.new(0.05, 0, 0.42, 0)
previewToggle.BackgroundColor3 = TOTE.colors.preview
previewToggle.Text = "👁️ ON"
previewToggle.TextColor3 = Color3.new(1, 1, 1)
previewToggle.TextSize = 12
previewToggle.Font = Enum.Font.GothamBold
previewToggle.Parent = mainFrame
Instance.new("UICorner", previewToggle).CornerRadius = UDim.new(0, 8)

-- ============================================
// INSTRUÇÕES (Rodapé)
-- ============================================
local instructions = Instance.new("TextLabel")
instructions.Size = UDim2.new(0.9, 0, 0, 40)
instructions.Position = UDim2.new(0.05, 0, 0.92, 0)
instructions.BackgroundTransparency = 1
instructions.Text = "Arraste o joystick para mirar • Segure o botão vermelho para carregar força • Toque nos slots para salvar/carregar"
instructions.TextColor3 = Color3.fromRGB(150, 150, 150)
instructions.TextSize = 11
instructions.Font = Enum.Font.Gotham
instructions.TextWrapped = true
instructions.Parent = mainFrame

-- ============================================
// FUNÇÕES DO SISTEMA
// ============================================

-- Atualizar info na tela
local function updateShotInfo()
    local angleText = math.floor(TOTE.aimAngleX * 45)
    shotInfo.Text = string.format("Força: %d%% | Curva: %d%% | Ângulo: %d°", 
        TOTE.power, TOTE.curve, angleText)
end

-- Calcular trajetória com base na mira
local function calculateTrajectory()
    if not hrp or not hrp.Parent then return {} end
    
    -- Encontrar bola
    local ball = nil
    local nearestDist = math.huge
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:match("Ball") or obj.Name:match("Bola") or obj.Name:match("Soccer")) then
            if obj.Position then
                local dist = (obj.Position - hrp.Position).Magnitude
                if dist < nearestDist and dist < 20 then
                    nearestDist = dist
                    ball = obj
                end
            end
        end
    end
    
    if not ball then return {} end
    
    local startPos = ball.Position
    local charCF = hrp.CFrame
    
    -- Calcular direção baseada no joystick
    local sideDir = (TOTE.direction == "R") and 1 or -1
    local forward = charCF.LookVector
    local right = charCF.RightVector * sideDir
    local up = charCF.UpVector
    
    -- Aplicar ângulos do joystick
    local angleX = TOTE.aimAngleX * 0.5 -- Esquerda/direita
    local angleY = TOTE.aimAngleY * 0.3 -- Cima/baixo
    
    local aimVector = (forward * (1 - math.abs(angleX))) + 
                      (right * angleX) + 
                      (up * angleY)
    aimVector = aimVector.Unit
    
    -- Pontos de controle da curva de Bézier
    local distance = TOTE.power * 0.4
    local curveAmount = TOTE.curve * 0.02
    
    local p0 = startPos
    local p1 = startPos + (aimVector * distance * 0.3) + (up * TOTE.lift * 0.3)
    local p2 = startPos + (aimVector * distance * 0.7) + (right * curveAmount * 5) + (up * TOTE.lift)
    local p3 = startPos + (aimVector * distance) + (right * curveAmount * 8)
    
    -- Calcular pontos
    local points = {}
    for t = 0, 1, 0.08 do
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

-- Atualizar preview visual
local function updatePreview()
    -- Limpar preview antigo
    for _, part in ipairs(TOTE.previewParts) do
        if part then part:Destroy() end
    end
    TOTE.previewParts = {}
    
    if not TOTE.previewEnabled then return end
    
    local points = calculateTrajectory()
    if #points == 0 then return end
    
    -- Criar partes de preview
    for i, point in ipairs(points) do
        local part = Instance.new("Part")
        part.Shape = Enum.PartType.Ball
        part.Size = Vector3.new(1.2 - (i * 0.08), 1.2 - (i * 0.08), 1.2 - (i * 0.08))
        part.Position = point
        part.Anchored = true
        part.CanCollide = false
        part.Material = Enum.Material.Neon
        part.Color = TOTE.colors.preview
        part.Transparency = 0.2 + (i * 0.06)
        part.Parent = Workspace
        
        table.insert(TOTE.previewParts, part)
    end
    
    -- Linhas de conexão
    for i = 1, #points - 1 do
        local dist = (points[i] - points[i+1]).Magnitude
        if dist > 0.1 then
            local mid = (points[i] + points[i+1]) / 2
            local cf = CFrame.lookAt(points[i], points[i+1])
            
            local line = Instance.new("Part")
            line.Size = Vector3.new(0.3, 0.3, dist)
            line.CFrame = cf * CFrame.new(0, 0, -dist/2)
            line.Anchored = true
            line.CanCollide = false
            line.Material = Enum.Material.Neon
            line.Color = TOTE.colors.preview
            line.Transparency = 0.5
            line.Parent = Workspace
            
            table.insert(TOTE.previewParts, line)
        end
    end
end

-- Salvar configuração
local function saveConfig(slotIndex)
    TOTE.savedConfigs[slotIndex] = {
        aimAngleX = TOTE.aimAngleX,
        aimAngleY = TOTE.aimAngleY,
        power = TOTE.power,
        curve = TOTE.curve,
        lift = TOTE.lift,
        timestamp = tick()
    }
    
    slots[slotIndex].data = TOTE.savedConfigs[slotIndex]
    slots[slotIndex].indicator.Visible = true
    
    -- Animação de feedback
    local originalColor = slots[slotIndex].button.BackgroundColor3
    slots[slotIndex].button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    task.delay(0.2, function()
        slots[slotIndex].button.BackgroundColor3 = TOTE.colors.slots[slotIndex]
    end)
    
    print(string.format("💾 Config [%d] salva!", slotIndex))
end

-- Carregar configuração
local function loadConfig(slotIndex)
    local config = TOTE.savedConfigs[slotIndex]
    if not config then
        print(string.format("⚠️ Slot [%d] vazio", slotIndex))
        return
    end
    
    TOTE.aimAngleX = config.aimAngleX
    TOTE.aimAngleY = config.aimAngleY
    TOTE.power = config.power
    TOTE.curve = config.curve
    TOTE.lift = config.lift
    
    -- Atualizar UI
    curveFill.Size = UDim2.new(TOTE.curve / 100, 0, 1, 0)
    curveValue.Text = tostring(TOTE.curve)
    powerButton.Text = tostring(TOTE.power) .. "%"
    
    -- Atualizar joystick visual
    local knobX = 0.5 + (TOTE.aimAngleX * 0.3)
    local knobY = 0.5 + (TOTE.aimAngleY * 0.3)
    joystickKnob.Position = UDim2.new(knobX, -25, knobY, -25)
    
    -- Destacar slot ativo
    for i, s in ipairs(slots) do
        s.button.BackgroundColor3 = (i == slotIndex) and TOTE.colors.slots[i] or Color3.fromRGB(60, 60, 80)
    end
    TOTE.selectedSlot = slotIndex
    
    updateShotInfo()
    updatePreview()
    
    print(string.format("📂 Config [%d] carregada!", slotIndex))
end

-- Executar chute
local function executeKick(direction)
    TOTE.direction = direction
    
    -- Encontrar bola
    local ball = nil
    local nearestDist = math.huge
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:match("Ball") or obj.Name:match("Bola") or obj.Name:match("Soccer")) then
            if obj.Position then
                local dist = (obj.Position - hrp.Position).Magnitude
                if dist < nearestDist and dist < 20 then
                    nearestDist = dist
                    ball = obj
                end
            end
        end
    end
    
    if not ball then return end
    
    -- Calcular vetor de chute
    local charCF = hrp.CFrame
    local sideDir = (direction == "R") and 1 or -1
    
    local forward = charCF.LookVector
    local right = charCF.RightVector * sideDir
    local up = charCF.UpVector
    
    -- Aplicar mira do joystick
    local aimX = TOTE.aimAngleX * 0.6
    local aimY = TOTE.aimAngleY * 0.4
    
    local kickVector = (forward * (1 - math.abs(aimX)) * (TOTE.power / 100)) + 
                       (right * aimX) + 
                       (up * (0.2 + aimY) * (TOTE.power / 100))
    
    -- Limitar força máxima
    local finalPower = math.min(TOTE.power, 80)
    
    -- Animação do botão
    local btn = (direction == "R") and kickRight or kickLeft
    local originalSize = btn.Size
    btn:TweenSize(UDim2.new(originalSize.X.Scale * 0.95, 0, originalSize.Y.Scale * 0.95, 0), 
                  Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.1, true)
    task.delay(0.1, function()
        btn:TweenSize(originalSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.1, true)
    end)
    
    -- Executar física
    pcall(function()
        -- Touch inicial
        firetouchinterest(ball, hrp, 0)
        task.wait(0.03)
        firetouchinterest(ball, hrp, 1)
        
        -- Aplicar movimento suave
        local startTime = tick()
        local duration = 0.4
        
        while tick() - startTime < duration do
            if not ball or not ball.Parent then break end
            
            local elapsed = tick() - startTime
            local progress = elapsed / duration
            local ease = math.sin(progress * math.pi * 0.5)
            
            -- Movimento base
            local move = kickVector * finalPower * ease * 0.08
            
            -- Curva (efeito Magnus)
            local curveForce = right * TOTE.curve * 0.01 * math.sin(progress * math.pi)
            
            ball.CFrame = ball.CFrame + move + curveForce
            
            -- Rotação
            ball.CFrame = ball.CFrame * CFrame.Angles(
                math.random() * 0.15,
                math.random() * 0.15,
                math.random() * 0.15
            )
            
            task.wait(0.03)
        end
        
        -- Touch final
        task.wait(0.05)
        firetouchinterest(ball, hrp, 0)
        firetouchinterest(ball, hrp, 1)
    end)
    
    -- Efeito visual
    pcall(function()
        local effect = Instance.new("Part")
        effect.Shape = Enum.PartType.Ball
        effect.Size = Vector3.new(3, 3, 3)
        effect.Position = ball.Position
        effect.Anchored = true
        effect.CanCollide = false
        effect.Material = Enum.Material.Neon
        effect.Color = (direction == "R") and TOTE.colors.right or TOTE.colors.left
        effect.Transparency = 0.4
        effect.Parent = Workspace
        
        TweenService:Create(effect, TweenInfo.new(0.5), {
            Size = Vector3.new(0.1, 0.1, 0.1),
            Transparency = 1
        }):Play()
        
        task.delay(0.5, function() effect:Destroy() end)
    end)
    
    print(string.format("⚽ Chute %s | Força: %d%% | Curva: %d%%", direction, TOTE.power, TOTE.curve))
end

-- ============================================
// SISTEMA DE JOYSTICK TOUCH
// ============================================
local joystickActive = false
local joystickCenter = nil
local maxJoystickDist = 35

joystickTouch.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        joystickActive = true
        joystickCenter = Vector2.new(joystickFrame.AbsolutePosition.X + joystickFrame.AbsoluteSize.X/2,
                                     joystickFrame.AbsolutePosition.Y + joystickFrame.AbsoluteSize.Y/2)
    end
end)

joystickTouch.InputChanged:Connect(function(input)
    if joystickActive and input.UserInputType == Enum.UserInputType.Touch then
        local pos = input.Position
        local delta = pos - joystickCenter
        local dist = math.min(delta.Magnitude, maxJoystickDist)
        local angle = math.atan2(delta.Y, delta.X)
        
        -- Limitar distância
        local limitedDelta = Vector2.new(math.cos(angle) * dist, math.sin(angle) * dist)
        
        -- Mover knob
        joystickKnob.Position = UDim2.new(0.5, limitedDelta.X - 25, 0.5, limitedDelta.Y - 25)
        
        -- Calcular valores normalizados (-1 a 1)
        TOTE.aimAngleX = limitedDelta.X / maxJoystickDist
        TOTE.aimAngleY = limitedDelta.Y / maxJoystickDist
        
        updateShotInfo()
        updatePreview()
    end
end)

local function endJoystick(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        joystickActive = false
        -- Resetar knob com animação
        TweenService:Create(joystickKnob, TweenInfo.new(0.2), {
            Position = UDim2.new(0.5, -25, 0.5, -25)
        }):Play()
        
        -- Suavizar retorno dos valores
        TweenService:Create(TOTE, TweenInfo.new(0.2), {
            aimAngleX = 0,
            aimAngleY = 0
        }):Play()
        
        task.delay(0.2, function()
            updateShotInfo()
            updatePreview()
        end)
    end
end

joystickTouch.InputEnded:Connect(endJoystick)
joystickTouch.InputCancelled:Connect(endJoystick)

-- ============================================
// SISTEMA DE FORÇA (HOLD)
// ============================================
local powerActive = false
local chargeConnection = nil

powerButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        powerActive = true
        TOTE.isCharging = true
        
        -- Animação de pressão
        TweenService:Create(powerFill, TweenInfo.new(0.1), {
            Size = UDim2.new(0.75, 0, 0.75, 0),
            Position = UDim2.new(0.125, 0, 0.125, 0)
        }):Play()
        
        -- Loop de carregamento
        chargeConnection = RunService.Heartbeat:Connect(function()
            if not powerActive then return end
            
            TOTE.chargeValue = math.min(TOTE.chargeValue + 1.5, 100)
            TOTE.power = TOTE.minPower + math.floor((TOTE.chargeValue / 100) * (TOTE.maxPower - TOTE.minPower))
            
            -- Atualizar visual
            powerButton.Text = tostring(TOTE.power) .. "%"
            local fillScale = 0.2 + (TOTE.chargeValue / 100) * 0.65
            powerFill.Size = UDim2.new(fillScale, 0, fillScale, 0)
            powerFill.Position = UDim2.new((1 - fillScale) / 2, 0, (1 - fillScale) / 2, 0)
            
            -- Mudar cor baseado na força
            if TOTE.power > 80 then
                powerFill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            elseif TOTE.power > 50 then
                powerFill.BackgroundColor3 = Color3.fromRGB(255, 150, 50)
            else
                powerFill.BackgroundColor3 = TOTE.colors.power
            end
            
            updateShotInfo()
        end)
    end
end)

local function endPower(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        powerActive = false
        TOTE.isCharging = false
        TOTE.chargeValue = 0
        
        if chargeConnection then
            chargeConnection:Disconnect()
            chargeConnection = nil
        end
        
        -- Resetar visual
        TweenService:Create(powerFill, TweenInfo.new(0.3), {
            Size = UDim2.new(0.85, 0, 0.85, 0),
            Position = UDim2.new(0.075, 0, 0.075, 0),
            BackgroundColor3 = TOTE.colors.power
        }):Play()
        
        powerButton.Text = tostring(TOTE.power) .. "%"
    end
end

powerButton.InputEnded:Connect(endPower)
powerButton.InputCancelled:Connect(endPower)

-- ============================================
// CONTROLES DE CURVA
// ============================================
curveMinus.MouseButton1Click:Connect(function()
    TOTE.curve = math.clamp(TOTE.curve - 5, 0, 100)
    curveFill.Size = UDim2.new(TOTE.curve / 100, 0, 1, 0)
    curveValue.Text = tostring(TOTE.curve)
    updateShotInfo()
    updatePreview()
end)

curvePlus.MouseButton1Click:Connect(function()
    TOTE.curve = math.clamp(TOTE.curve + 5, 0, 100)
    curveFill.Size = UDim2.new(TOTE.curve / 100, 0, 1, 0)
    curveValue.Text = tostring(TOTE.curve)
    updateShotInfo()
    updatePreview()
end)

-- Slider de curva touch
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
        updatePreview()
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
        updatePreview()
    end
end)

curveBg.InputEnded:Connect(function() curveDragging = false end)

-- ============================================
// SAVE SLOTS
// ============================================
for i, slot in ipairs(slots) do
    -- Tap simples: Carregar
    -- Hold: Salvar
    local holdStart = 0
    
    slot.button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            holdStart = tick()
        end
    end)
    
    slot.button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            local holdTime = tick() - holdStart
            if holdTime > 0.5 then
                -- Hold: Salvar
                saveConfig(i)
            else
                -- Tap: Carregar
                loadConfig(i)
            end
        end
    end)
end

-- ============================================
// BOTÕES DE CHUTE
// ============================================
kickLeft.MouseButton1Click:Connect(function()
    executeKick("F")
end)

kickRight.MouseButton1Click:Connect(function()
    executeKick("R")
end)

-- ============================================
// TOGGLE PREVIEW
// ============================================
previewToggle.MouseButton1Click:Connect(function()
    TOTE.previewEnabled = not TOTE.previewEnabled
    previewToggle.Text = TOTE.previewEnabled and "👁️ ON" or "👁️ OFF"
    previewToggle.BackgroundColor3 = TOTE.previewEnabled and TOTE.colors.preview or Color3.fromRGB(100, 100, 100)
    updatePreview()
end)

-- ============================================
// LOOP DE ATUALIZAÇÃO
// ============================================
RunService.RenderStepped:Connect(function()
    -- Atualizar preview periodicamente se estiver mirando
    if TOTE.previewEnabled and (math.abs(TOTE.aimAngleX) > 0.1 or math.abs(TOTE.aimAngleY) > 0.1) then
        -- Throttle updates
        if tick() % 0.1 < 0.05 then
            updatePreview()
        end
    end
end)

-- Cleanup ao respawnar
player.CharacterAdded:Connect(function(newChar)
    char = newChar
    hrp = newChar:WaitForChild("HumanoidRootPart")
    task.wait(0.5)
    updatePreview()
end)

-- Inicializar
updateShotInfo()
updatePreview()

print("========================================")
print("⚽ CAFUXZ1 MOBILE TOTE v4.0 PRO")
print("========================================")
print("🎮 CONTROLES TOUCH:")
print("   👆 ARRASTE joystick para mirar")
print("   👆 SEGURE botão vermelho para carregar força")
print("   👆 Toque botões azul/vermelho para chutar")
print("   👆 Segure slot para SALVAR, toque para CARREGAR")
print("   👆 Ajuste curva com slider ou +/-")
print("========================================")
