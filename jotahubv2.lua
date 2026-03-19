--[[
    CAFUXZ1 Hub v16.0 - TOTE SYSTEM v3.0 PRO
    Preview Visual | Angle Bar | Power Bar | Save Positions
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
-- CONFIGURAÇÕES DO SISTEMA DE TOTE v3.0
-- ============================================
local TOTE = {
    -- Controles
    angle = 0,              -- Ângulo atual (-45 a +45)
    power = 50,             -- Força atual (0-100)
    maxPower = 100,
    minPower = 10,
    chargeSpeed = 80,       -- Velocidade de carregamento (%/segundo)
    isCharging = false,
    chargeStartTime = 0,
    
    -- Curva
    curveIntensity = 30,    -- Quanto curva (0-100)
    lift = 25,              -- Elevação
    
    -- Preview
    previewEnabled = true,
    previewParts = {},
    previewUpdateRate = 0.05,
    lastPreviewUpdate = 0,
    
    -- Save System
    savedPositions = {},    -- [1], [2], [3]
    maxSavedPositions = 3,
    currentSlot = 1,
    
    -- Estado
    isAiming = false,
    direction = "R",        -- "R" ou "F"
    
    -- Visual
    colors = {
        primary = Color3.fromRGB(99, 102, 241),
        secondary = Color3.fromRGB(0, 255, 255),
        angle = Color3.fromRGB(251, 191, 36),
        power = Color3.fromRGB(239, 68, 68),
        charge = Color3.fromRGB(139, 92, 246),
        preview = Color3.fromRGB(0, 255, 136),
        saved = {
            Color3.fromRGB(34, 197, 94),
            Color3.fromRGB(234, 179, 8),
            Color3.fromRGB(239, 68, 68)
        }
    }
}

-- ============================================
-- GUI DO SISTEMA DE TOTE
-- ============================================
local toteGui = Instance.new("ScreenGui")
toteGui.Name = "CAFUXZ1_ToteSystem"
toteGui.ResetOnSpawn = false
toteGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
toteGui.Parent = CoreGui

-- Frame Principal (canto inferior esquerdo)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "ToteMain"
mainFrame.Size = UDim2.new(0, 400, 0, 300)
mainFrame.Position = UDim2.new(0, 20, 1, -320)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = toteGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.Position = UDim2.new(0, 0, 0, 5)
title.BackgroundTransparency = 1
title.Text = "⚽ TOTE SYSTEM v3.0"
title.TextColor3 = TOTE.colors.primary
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

-- Container de controles
local controlsContainer = Instance.new("Frame")
controlsContainer.Size = UDim2.new(1, -20, 1, -50)
controlsContainer.Position = UDim2.new(0, 10, 0, 45)
controlsContainer.BackgroundTransparency = 1
controlsContainer.Parent = mainFrame

-- ============================================
-- ANGLE BAR (Arco)
-- ============================================
local angleFrame = Instance.new("Frame")
angleFrame.Name = "AngleBar"
angleFrame.Size = UDim2.new(0, 200, 0, 80)
angleFrame.Position = UDim2.new(0, 0, 0, 0)
angleFrame.BackgroundTransparency = 1
angleFrame.Parent = controlsContainer

local angleLabel = Instance.new("TextLabel")
angleLabel.Size = UDim2.new(1, 0, 0, 20)
angleLabel.Text = "ÂNGULO: 0°"
angleLabel.TextColor3 = TOTE.colors.angle
angleLabel.TextSize = 14
angleLabel.Font = Enum.Font.GothamBold
angleLabel.BackgroundTransparency = 1
angleLabel.Parent = angleFrame

-- Barra de ângulo visual (semicírculo)
local angleBg = Instance.new("Frame")
angleBg.Size = UDim2.new(0, 180, 0, 10)
angleBg.Position = UDim2.new(0.5, -90, 0, 35)
angleBg.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
angleBg.BorderSizePixel = 0
angleBg.Parent = angleFrame
Instance.new("UICorner", angleBg).CornerRadius = UDim.new(0, 5)

local angleFill = Instance.new("Frame")
angleFill.Name = "Fill"
angleFill.Size = UDim2.new(0.5, 0, 1, 0)
angleFill.Position = UDim2.new(0.5, 0, 0, 0)
angleFill.BackgroundColor3 = TOTE.colors.angle
angleFill.BorderSizePixel = 0
angleFill.Parent = angleBg
Instance.new("UICorner", angleFill).CornerRadius = UDim.new(0, 5)

-- Indicador central
local angleCenter = Instance.new("Frame")
angleCenter.Size = UDim2.new(0, 4, 0, 16)
angleCenter.Position = UDim2.new(0.5, -2, 0.5, -8)
angleCenter.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
angleCenter.BorderSizePixel = 0
angleCenter.ZIndex = 2
angleCenter.Parent = angleBg

-- Botões de ajuste de ângulo
local angleLeft = Instance.new("TextButton")
angleLeft.Size = UDim2.new(0, 30, 0, 30)
angleLeft.Position = UDim2.new(0, 0, 0, 25)
angleLeft.Text = "◀"
angleLeft.TextColor3 = Color3.new(1, 1, 1)
angleLeft.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
angleLeft.Parent = angleFrame
Instance.new("UICorner", angleLeft).CornerRadius = UDim.new(0, 6)

local angleRight = Instance.new("TextButton")
angleRight.Size = UDim2.new(0, 30, 0, 30)
angleRight.Position = UDim2.new(1, -30, 0, 25)
angleRight.Text = "▶"
angleRight.TextColor3 = Color3.new(1, 1, 1)
angleRight.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
angleRight.Parent = angleFrame
Instance.new("UICorner", angleRight).CornerRadius = UDim.new(0, 6)

-- ============================================
-- POWER BAR (Vertical)
-- ============================================
local powerFrame = Instance.new("Frame")
powerFrame.Name = "PowerBar"
powerFrame.Size = UDim2.new(0, 60, 0, 150)
powerFrame.Position = UDim2.new(0, 210, 0, 0)
powerFrame.BackgroundTransparency = 1
powerFrame.Parent = controlsContainer

local powerLabel = Instance.new("TextLabel")
powerLabel.Size = UDim2.new(1, 0, 0, 20)
powerLabel.Text = "FORÇA"
powerLabel.TextColor3 = TOTE.colors.power
powerLabel.TextSize = 12
powerLabel.Font = Enum.Font.GothamBold
powerLabel.BackgroundTransparency = 1
powerLabel.Parent = powerFrame

-- Barra vertical
local powerBg = Instance.new("Frame")
powerBg.Size = UDim2.new(0, 20, 0, 100)
powerBg.Position = UDim2.new(0.5, -10, 0, 25)
powerBg.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
powerBg.BorderSizePixel = 0
powerBg.Parent = powerFrame
Instance.new("UICorner", powerBg).CornerRadius = UDim.new(0, 10)

local powerFill = Instance.new("Frame")
powerFill.Name = "Fill"
powerFill.Size = UDim2.new(1, 0, 0.5, 0)
powerFill.Position = UDim2.new(0, 0, 0.5, 0)
powerFill.BackgroundColor3 = TOTE.colors.power
powerFill.BorderSizePixel = 0
powerFill.Parent = powerBg
Instance.new("UICorner", powerFill).CornerRadius = UDim.new(0, 10)

local powerValue = Instance.new("TextLabel")
powerValue.Size = UDim2.new(1, 0, 0, 20)
powerValue.Position = UDim2.new(0, 0, 0, 130)
powerValue.Text = "50%"
powerValue.TextColor3 = TOTE.colors.power
powerValue.TextSize = 14
powerValue.Font = Enum.Font.GothamBold
powerValue.BackgroundTransparency = 1
powerValue.Parent = powerFrame

-- Botões de ajuste
local powerUp = Instance.new("TextButton")
powerUp.Size = UDim2.new(0, 25, 0, 25)
powerUp.Position = UDim2.new(1, -25, 0, 30)
powerUp.Text = "+"
powerUp.TextColor3 = Color3.new(1, 1, 1)
powerUp.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
powerUp.Parent = powerFrame
Instance.new("UICorner", powerUp).CornerRadius = UDim.new(0, 6)

local powerDown = Instance.new("TextButton")
powerDown.Size = UDim2.new(0, 25, 0, 25)
powerDown.Position = UDim2.new(1, -25, 0, 95)
powerDown.Text = "-"
powerDown.TextColor3 = Color3.new(1, 1, 1)
powerDown.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
powerDown.Parent = powerFrame
Instance.new("UICorner", powerDown).CornerRadius = UDim.new(0, 6)

-- ============================================
-- CHARGE BAR (Carregamento)
-- ============================================
local chargeFrame = Instance.new("Frame")
chargeFrame.Name = "ChargeBar"
chargeFrame.Size = UDim2.new(0, 280, 0, 40)
chargeFrame.Position = UDim2.new(0, 0, 0, 90)
chargeFrame.BackgroundTransparency = 1
chargeFrame.Parent = controlsContainer

local chargeLabel = Instance.new("TextLabel")
chargeLabel.Size = UDim2.new(1, 0, 0, 18)
chargeLabel.Text = "CARREGAR: [HOLD SPACE]"
chargeLabel.TextColor3 = TOTE.colors.charge
chargeLabel.TextSize = 12
chargeLabel.Font = Enum.Font.GothamBold
chargeLabel.BackgroundTransparency = 1
chargeLabel.Parent = chargeFrame

local chargeBg = Instance.new("Frame")
chargeBg.Size = UDim2.new(1, 0, 0, 12)
chargeBg.Position = UDim2.new(0, 0, 0, 22)
chargeBg.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
chargeBg.BorderSizePixel = 0
chargeBg.Parent = chargeFrame
Instance.new("UICorner", chargeBg).CornerRadius = UDim.new(0, 6)

local chargeFill = Instance.new("Frame")
chargeFill.Name = "Fill"
chargeFill.Size = UDim2.new(0, 0, 1, 0)
chargeFill.BackgroundColor3 = TOTE.colors.charge
chargeFill.BorderSizePixel = 0
chargeFill.Parent = chargeBg
Instance.new("UICorner", chargeFill).CornerRadius = UDim.new(0, 6)

local chargePercent = Instance.new("TextLabel")
chargePercent.Size = UDim2.new(0, 50, 0, 20)
chargePercent.Position = UDim2.new(0.5, -25, 0, 0)
chargePercent.Text = "0%"
chargePercent.TextColor3 = TOTE.colors.charge
chargePercent.TextSize = 11
chargePercent.Font = Enum.Font.GothamBold
chargePercent.BackgroundTransparency = 1
chargePercent.Parent = chargeFrame

-- ============================================
-- SAVE SYSTEM (Slots)
-- ============================================
local saveFrame = Instance.new("Frame")
saveFrame.Name = "SaveSystem"
saveFrame.Size = UDim2.new(0, 280, 0, 60)
saveFrame.Position = UDim2.new(0, 0, 0, 140)
saveFrame.BackgroundTransparency = 1
saveFrame.Parent = controlsContainer

local saveLabel = Instance.new("TextLabel")
saveLabel.Size = UDim2.new(1, 0, 0, 18)
saveLabel.Text = "POSIÇÕES SALVAS [E/Q]"
saveLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
saveLabel.TextSize = 11
saveLabel.Font = Enum.Font.GothamBold
saveLabel.BackgroundTransparency = 1
saveLabel.Parent = saveFrame

local slotContainer = Instance.new("Frame")
slotContainer.Size = UDim2.new(1, 0, 0, 35)
slotContainer.Position = UDim2.new(0, 0, 0, 22)
slotContainer.BackgroundTransparency = 1
slotContainer.Parent = saveFrame

local slots = {}
for i = 1, 3 do
    local slot = Instance.new("TextButton")
    slot.Name = "Slot" .. i
    slot.Size = UDim2.new(0, 80, 1, 0)
    slot.Position = UDim2.new(0, (i-1) * 95, 0, 0)
    slot.Text = "[" .. i .. "] VAZIO"
    slot.TextColor3 = Color3.new(1, 1, 1)
    slot.TextSize = 11
    slot.Font = Enum.Font.GothamBold
    slot.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    slot.Parent = slotContainer
    Instance.new("UICorner", slot).CornerRadius = UDim.new(0, 8)
    
    -- Indicador de slot ativo
    local indicator = Instance.new("Frame")
    indicator.Name = "Indicator"
    indicator.Size = UDim2.new(1, 0, 0, 3)
    indicator.Position = UDim2.new(0, 0, 1, -3)
    indicator.BackgroundColor3 = TOTE.colors.saved[i]
    indicator.BorderSizePixel = 0
    indicator.Visible = (i == 1)
    indicator.Parent = slot
    
    slots[i] = {button = slot, indicator = indicator, data = nil}
end

-- ============================================
-- BOTÕES DE CHUTE
-- ============================================
local kickFrame = Instance.new("Frame")
kickFrame.Name = "KickButtons"
kickFrame.Size = UDim2.new(0, 280, 0, 45)
kickFrame.Position = UDim2.new(0, 0, 0, 205)
kickFrame.BackgroundTransparency = 1
kickFrame.Parent = controlsContainer

local kickLeft = Instance.new("TextButton")
kickLeft.Size = UDim2.new(0.48, 0, 1, 0)
kickLeft.Text = "⬅️ CHUTE [F]"
kickLeft.TextColor3 = Color3.new(1, 1, 1)
kickLeft.TextSize = 13
kickLeft.Font = Enum.Font.GothamBold
kickLeft.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
kickLeft.Parent = kickFrame
Instance.new("UICorner", kickLeft).CornerRadius = UDim.new(0, 10)

local kickRight = Instance.new("TextButton")
kickRight.Size = UDim2.new(0.48, 0, 1, 0)
kickRight.Position = UDim2.new(0.52, 0, 0, 0)
kickRight.Text = "CHUTE [R] ➡️"
kickRight.TextColor3 = Color3.new(1, 1, 1)
kickRight.TextSize = 13
kickRight.Font = Enum.Font.GothamBold
kickRight.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
kickRight.Parent = kickFrame
Instance.new("UICorner", kickRight).CornerRadius = UDim.new(0, 10)

-- Toggle Preview
local previewToggle = Instance.new("TextButton")
previewToggle.Size = UDim2.new(0, 120, 0, 30)
previewToggle.Position = UDim2.new(1, -130, 0, 0)
previewToggle.Text = "👁️ PREVIEW: ON"
previewToggle.TextColor3 = Color3.new(1, 1, 1)
previewToggle.TextSize = 11
previewToggle.Font = Enum.Font.GothamBold
previewToggle.BackgroundColor3 = TOTE.colors.preview
previewToggle.Parent = controlsContainer
Instance.new("UICorner", previewToggle).CornerRadius = UDim.new(0, 8)

-- ============================================
-- FUNÇÕES DO SISTEMA
-- ============================================

-- Atualizar UI de ângulo
local function updateAngleUI()
    angleLabel.Text = string.format("ÂNGULO: %d°", TOTE.angle)
    
    -- Atualizar barra (0.5 é o centro, varia para esquerda/direita)
    local normalized = (TOTE.angle + 45) / 90  -- -45~45 -> 0~1
    if TOTE.angle < 0 then
        angleFill.Position = UDim2.new(normalized, 0, 0, 0)
        angleFill.Size = UDim2.new(0.5 - normalized, 0, 1, 0)
    else
        angleFill.Position = UDim2.new(0.5, 0, 0, 0)
        angleFill.Size = UDim2.new(normalized - 0.5, 0, 1, 0)
    end
end

-- Atualizar UI de força
local function updatePowerUI()
    powerValue.Text = string.format("%d%%", TOTE.power)
    powerFill.Size = UDim2.new(1, 0, TOTE.power / 100, 0)
    powerFill.Position = UDim2.new(0, 0, 1 - (TOTE.power / 100), 0)
end

-- Atualizar UI de carregamento
local function updateChargeUI()
    if not TOTE.isCharging then
        chargeFill.Size = UDim2.new(0, 0, 1, 0)
        chargePercent.Text = "0%"
        return
    end
    
    local elapsed = tick() - TOTE.chargeStartTime
    local chargePercent = math.min((elapsed * TOTE.chargeSpeed) / 100, 1)
    TOTE.power = math.floor(TOTE.minPower + (chargePercent * (TOTE.maxPower - TOTE.minPower)))
    
    chargeFill.Size = UDim2.new(chargePercent, 0, 1, 0)
    chargePercent.Text = string.format("%d%%", math.floor(chargePercent * 100))
    updatePowerUI()
end

-- Calcular trajetória de preview (Curva de Bézier)
local function calculateTrajectory(startPos, direction)
    if not hrp or not hrp.Parent then return {} end
    
    local charCF = hrp.CFrame
    local angleRad = math.rad(TOTE.angle)
    local sideDir = (direction == "R") and 1 or -1
    
    -- Vetores base
    local forward = charCF.LookVector
    local right = charCF.RightVector * sideDir
    local up = charCF.UpVector
    
    -- Aplicar rotação do ângulo
    local rotatedForward = (forward * math.cos(angleRad)) + (right * math.sin(angleRad))
    
    -- Pontos de controle da curva de Bézier
    local p0 = startPos
    local p1 = startPos + (rotatedForward * TOTE.power * 0.3) + (up * TOTE.lift * 0.5)
    local p2 = startPos + (rotatedForward * TOTE.power * 0.7) + (right * TOTE.curveIntensity * 0.3) + (up * TOTE.lift)
    local p3 = startPos + (rotatedForward * TOTE.power) + (right * TOTE.curveIntensity * 0.8)
    
    -- Calcular pontos da curva
    local points = {}
    for t = 0, 1, 0.05 do
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

-- Criar/Atualizar preview visual
local function updatePreview()
    if not TOTE.previewEnabled or not TOTE.isAiming then
        -- Limpar preview
        for _, part in ipairs(TOTE.previewParts) do
            if part then part:Destroy() end
        end
        TOTE.previewParts = {}
        return
    end
    
    -- Limitar taxa de atualização
    if tick() - TOTE.lastPreviewUpdate < TOTE.previewUpdateRate then return end
    TOTE.lastPreviewUpdate = tick()
    
    -- Limpar preview antigo
    for _, part in ipairs(TOTE.previewParts) do
        if part then part:Destroy() end
    end
    TOTE.previewParts = {}
    
    -- Encontrar bola
    local ball = nil
    local nearestDist = math.huge
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:match("Ball") or obj.Name:match("Bola") or obj.Name:match("Soccer") then
            if obj.Position then
                local dist = (obj.Position - hrp.Position).Magnitude
                if dist < nearestDist and dist < 15 then
                    nearestDist = dist
                    ball = obj
                end
            end
        end
    end
    
    if not ball then return end
    
    -- Calcular trajetória
    local points = calculateTrajectory(ball.Position, TOTE.direction)
    
    -- Criar partes de preview
    for i, point in ipairs(points) do
        local part = Instance.new("Part")
        part.Shape = Enum.PartType.Ball
        part.Size = Vector3.new(0.8 - (i * 0.05), 0.8 - (i * 0.05), 0.8 - (i * 0.05))
        part.Position = point
        part.Anchored = true
        part.CanCollide = false
        part.Material = Enum.Material.Neon
        part.Color = TOTE.colors.preview
        part.Transparency = 0.3 + (i * 0.05)
        part.Parent = Workspace
        
        -- Adicionar luz ao primeiro ponto
        if i == 1 then
            local light = Instance.new("PointLight")
            light.Color = TOTE.colors.preview
            light.Brightness = 2
            light.Range = 10
            light.Parent = part
        end
        
        table.insert(TOTE.previewParts, part)
    end
    
    -- Linha de conexão (usando partes cilíndricas)
    for i = 1, #points - 1 do
        local dist = (points[i] - points[i+1]).Magnitude
        local mid = (points[i] + points[i+1]) / 2
        local cf = CFrame.lookAt(points[i], points[i+1])
        
        local line = Instance.new("Part")
        line.Size = Vector3.new(0.2, 0.2, dist)
        line.CFrame = cf * CFrame.new(0, 0, -dist/2)
        line.Anchored = true
        line.CanCollide = false
        line.Material = Enum.Material.Neon
        line.Color = TOTE.colors.preview
        line.Transparency = 0.6
        line.Parent = Workspace
        
        table.insert(TOTE.previewParts, line)
    end
end

-- Salvar posição atual
local function savePosition(slot)
    if not hrp or not hrp.Parent then return end
    
    local targetPos = nil
    
    -- Se estiver mirando em uma bola, salvar posição relativa à bola
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:match("Ball") or obj.Name:match("Goal") or obj.Name:match("Gol")) then
            if obj.Position then
                local dist = (obj.Position - hrp.Position).Magnitude
                if dist < 50 then
                    targetPos = {
                        type = "relative",
                        ballPos = obj.Position,
                        hrpPos = hrp.Position,
                        angle = TOTE.angle,
                        power = TOTE.power,
                        curve = TOTE.curveIntensity,
                        direction = TOTE.direction,
                        timestamp = tick()
                    }
                    break
                end
            end
        end
    end
    
    -- Se não encontrou bola, salvar posição absoluta do HR
    if not targetPos then
        targetPos = {
            type = "absolute",
            hrpPos = hrp.Position,
            hrpRot = hrp.CFrame,
            angle = TOTE.angle,
            power = TOTE.power,
            curve = TOTE.curveIntensity,
            direction = TOTE.direction,
            timestamp = tick()
        }
    end
    
    TOTE.savedPositions[slot] = targetPos
    slots[slot].data = targetPos
    
    -- Atualizar UI
    slots[slot].button.Text = "[" .. slot .. "] SALVO"
    slots[slot].button.BackgroundColor3 = TOTE.colors.saved[slot]
    
    -- Notificação
    print(string.format("💾 Posição salva no slot [%d]", slot))
end

-- Carregar posição salva
local function loadPosition(slot)
    local data = TOTE.savedPositions[slot]
    if not data then 
        print(string.format("⚠️ Slot [%d] está vazio!", slot))
        return 
    end
    
    -- Aplicar configurações
    TOTE.angle = data.angle
    TOTE.power = data.power
    TOTE.curveIntensity = data.curve
    TOTE.direction = data.direction
    
    updateAngleUI()
    updatePowerUI()
    
    -- Destacar slot ativo
    for i, s in ipairs(slots) do
        s.indicator.Visible = (i == slot)
    end
    TOTE.currentSlot = slot
    
    -- Se for posição relativa e a bola ainda existir, calcular direção automática
    if data.type == "relative" then
        -- Procurar bola próxima da posição salva
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name:match("Ball") then
                if obj.Position and (obj.Position - data.ballPos).Magnitude < 10 then
                    -- Calcular ângulo automático para a bola
                    local toBall = (obj.Position - hrp.Position).Unit
                    local look = hrp.CFrame.LookVector
                    local angle = math.deg(math.atan2(toBall.X - look.X, toBall.Z - look.Z))
                    TOTE.angle = math.clamp(angle, -45, 45)
                    updateAngleUI()
                    break
                end
            end
        end
    end
    
    print(string.format("📂 Posição [%d] carregada!", slot))
end

-- Executar chute com física suave
local function executeTote(direction)
    if not hrp or not hrp.Parent then return end
    
    TOTE.direction = direction
    TOTE.isAiming = false
    updatePreview() -- Limpar preview
    
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
    
    -- Calcular direção final
    local charCF = hrp.CFrame
    local angleRad = math.rad(TOTE.angle)
    local sideDir = (direction == "R") and 1 or -1
    
    local forward = charCF.LookVector
    local right = charCF.RightVector * sideDir
    local up = charCF.UpVector
    
    -- Vetor de chute com ângulo
    local kickDir = (forward * math.cos(angleRad) * (TOTE.power / 100)) + 
                    (right * math.sin(angleRad) * 0.5) + 
                    (up * 0.3 * (TOTE.power / 100))
    
    -- Limitar força máxima para não atravessar
    local maxForce = math.min(TOTE.power, 85) -- Cap em 85% para não bugar
    
    -- Executar com interpolação suave
    pcall(function()
        local startTime = tick()
        local duration = 0.5 + (maxForce / 200) -- Mais força = mais tempo de aplicação
        
        -- Primeiro touch
        firetouchinterest(ball, hrp, 0)
        task.wait(0.05)
        firetouchinterest(ball, hrp, 1)
        
        -- Aplicar movimento suave frame a frame
        local connection
        connection = RunService.Heartbeat:Connect(function()
            local elapsed = tick() - startTime
            if elapsed > duration or not ball or not ball.Parent then
                if connection then connection:Disconnect() end
                return
            end
            
            local progress = elapsed / duration
            local ease = math.sin(progress * math.pi * 0.5) -- Ease out sine
            
            -- Movimento base
            local move = kickDir * maxForce * ease * 0.15
            
            -- Adicionar curva (efeito Magnus)
            local curve = right * TOTE.curveIntensity * math.sin(progress * math.pi) * 0.1
            
            -- Aplicar
            ball.CFrame = ball.CFrame + move + curve
            
            -- Rotação para visual
            ball.CFrame = ball.CFrame * CFrame.Angles(
                math.random() * 0.1,
                math.random() * 0.1,
                math.random() * 0.1
            )
        end)
        
        -- Double touch no meio
        task.delay(duration * 0.4, function()
            pcall(function()
                firetouchinterest(ball, hrp, 0)
                task.wait(0.02)
                firetouchinterest(ball, hrp, 1)
            end)
        end)
    end)
    
    -- Efeito visual
    pcall(function()
        local effect = Instance.new("Part")
        effect.Shape = Enum.PartType.Ball
        effect.Size = Vector3.new(2, 2, 2)
        effect.Position = ball.Position
        effect.Anchored = true
        effect.CanCollide = false
        effect.Material = Enum.Material.Neon
        effect.Color = (direction == "R") and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(100, 100, 255)
        effect.Transparency = 0.5
        effect.Parent = Workspace
        
        TweenService:Create(effect, TweenInfo.new(0.4), {
            Size = Vector3.new(0.1, 0.1, 0.1),
            Transparency = 1
        }):Play()
        
        task.delay(0.4, function() effect:Destroy() end)
    end)
    
    print(string.format("⚽ Tote %s | Ângulo: %d° | Força: %d%%", direction, TOTE.angle, TOTE.power))
end

-- ============================================
-- CONEXÕES DE INPUT
-- ============================================

-- Ajuste de ângulo
angleLeft.MouseButton1Click:Connect(function()
    TOTE.angle = math.clamp(TOTE.angle - 5, -45, 45)
    updateAngleUI()
end)

angleRight.MouseButton1Click:Connect(function()
    TOTE.angle = math.clamp(TOTE.angle + 5, -45, 45)
    updateAngleUI()
end)

-- Ajuste de força
powerUp.MouseButton1Click:Connect(function()
    TOTE.power = math.clamp(TOTE.power + 5, TOTE.minPower, TOTE.maxPower)
    updatePowerUI()
end)

powerDown.MouseButton1Click:Connect(function()
    TOTE.power = math.clamp(TOTE.power - 5, TOTE.minPower, TOTE.maxPower)
    updatePowerUI()
end)

-- Slots de save
for i, slot in ipairs(slots) do
    slot.button.MouseButton1Click:Connect(function()
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            loadPosition(i)
        else
            savePosition(i)
        end
    end)
end

-- Botões de chute
kickLeft.MouseButton1Click:Connect(function() executeTote("F") end)
kickRight.MouseButton1Click:Connect(function() executeTote("R") end)

-- Toggle preview
previewToggle.MouseButton1Click:Connect(function()
    TOTE.previewEnabled = not TOTE.previewEnabled
    previewToggle.Text = TOTE.previewEnabled and "👁️ PREVIEW: ON" or "👁️ PREVIEW: OFF"
    previewToggle.BackgroundColor3 = TOTE.previewEnabled and TOTE.colors.preview or Color3.fromRGB(100, 100, 100)
    if not TOTE.previewEnabled then
        updatePreview()
    end
end)

-- Teclado
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Carregar (Segurar Espaço)
    if input.KeyCode == Enum.KeyCode.Space then
        TOTE.isCharging = true
        TOTE.chargeStartTime = tick()
    end
    
    -- Ajuste fino de ângulo (Setas)
    if input.KeyCode == Enum.KeyCode.Left then
        TOTE.angle = math.clamp(TOTE.angle - 2, -45, 45)
        updateAngleUI()
    elseif input.KeyCode == Enum.KeyCode.Right then
        TOTE.angle = math.clamp(TOTE.angle + 2, -45, 45)
        updateAngleUI()
    elseif input.KeyCode == Enum.KeyCode.Up then
        TOTE.power = math.clamp(TOTE.power + 2, TOTE.minPower, TOTE.maxPower)
        updatePowerUI()
    elseif input.KeyCode == Enum.KeyCode.Down then
        TOTE.power = math.clamp(TOTE.power - 2, TOTE.minPower, TOTE.maxPower)
        updatePowerUI()
    end
    
    -- Save/Load (E/Q)
    if input.KeyCode == Enum.KeyCode.E then
        savePosition(TOTE.currentSlot)
    elseif input.KeyCode == Enum.KeyCode.Q then
        loadPosition(TOTE.currentSlot)
    end
    
    -- Trocar slot (1, 2, 3)
    if input.KeyCode == Enum.KeyCode.One then
        TOTE.currentSlot = 1
        for i, s in ipairs(slots) do s.indicator.Visible = (i == 1) end
    elseif input.KeyCode == Enum.KeyCode.Two then
        TOTE.currentSlot = 2
        for i, s in ipairs(slots) do s.indicator.Visible = (i == 2) end
    elseif input.KeyCode == Enum.KeyCode.Three then
        TOTE.currentSlot = 3
        for i, s in ipairs(slots) do s.indicator.Visible = (i == 3) end
    end
    
    -- Chutar (R/F)
    if input.KeyCode == Enum.KeyCode.R then
        executeTote("R")
    elseif input.KeyCode == Enum.KeyCode.F then
        executeTote("F")
    end
    
    -- Toggle aim mode (Tab)
    if input.KeyCode == Enum.KeyCode.Tab then
        TOTE.isAiming = not TOTE.isAiming
        if not TOTE.isAiming then
            updatePreview()
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space and TOTE.isCharging then
        TOTE.isCharging = false
        -- O power já foi setado durante o carregamento
    end
end)

-- ============================================
-- LOOP PRINCIPAL
-- ============================================
RunService.RenderStepped:Connect(function()
    -- Atualizar carregamento
    if TOTE.isCharging then
        updateChargeUI()
    end
    
    -- Atualizar preview
    if TOTE.previewEnabled and TOTE.isAiming then
        updatePreview()
    end
    
    -- Limpar preview se não estiver mirando
    if not TOTE.isAiming and #TOTE.previewParts > 0 then
        updatePreview()
    end
end)

-- Inicializar
updateAngleUI()
updatePowerUI()

print("========================================")
print("⚽ CAFUXZ1 TOTE SYSTEM v3.0 PRO")
print("========================================")
print("🎮 CONTROLES:")
print("   [TAB] - Modo mira (preview)")
print("   [HOLD SPACE] - Carregar força")
print("   [⬅️➡️] - Ajustar ângulo")
print("   [⬆️⬇️] - Ajustar força manual")
print("   [R/F] - Chutar direita/esquerda")
print("   [E] - Salvar posição no slot atual")
print("   [Q] - Carregar posição do slot atual")
print("   [1/2/3] - Trocar slot ativo")
print("========================================")
