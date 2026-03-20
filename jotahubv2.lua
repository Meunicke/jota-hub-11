--[[
    CAFUXZ1 Hub v18.0 - TOTE ROUBADO + REACH
    Simples, direto e funcional
]]

if not game or not game:IsLoaded() then 
    game.Loaded:Wait() 
end

task.wait(0.5)

local Players = game:FindFirstChildOfClass("Players")
local RunService = game:FindFirstChildOfClass("RunService")
local UserInputService = game:FindFirstChildOfClass("UserInputService")
local Workspace = game:FindFirstChildOfClass("Workspace")
local CoreGui = game:FindFirstChild("CoreGui")

if not (Players and RunService and UserInputService and Workspace and CoreGui) then
    warn("Serviços não encontrados")
    return
end

local player = Players.LocalPlayer
if not player then return end

local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

-- Limpar GUI antiga
pcall(function()
    for _, obj in ipairs(CoreGui:GetChildren()) do
        if obj.Name == "CAFUXZ1_Tote" then obj:Destroy() end
    end
end)

-- ============================================
-- CONFIGURAÇÕES
-- ============================================
local CONFIG = {
    -- Reach
    reach = 12,
    autoTouch = true,
    doubleTouch = true,
    
    -- Tote
    savedPosition = nil,        -- Posição salva
    curvePower = 80,            -- Força da curva (0-100)
    kickPower = 70,             -- Força do chute
    lift = 40,                  -- Elevação
    
    -- Cores
    color1 = Color3.fromRGB(99, 102, 241),
    color2 = Color3.fromRGB(0, 255, 255)
}

-- ============================================
-- GUI SIMPLES
-- ============================================
local gui = Instance.new("ScreenGui")
gui.Name = "CAFUXZ1_Tote"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 300, 0, 400)
main.Position = UDim2.new(0, 10, 0.5, -200)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundTransparency = 1
title.Text = "⚡ TOTE ROUBADO"
title.TextColor3 = CONFIG.color1
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.Parent = main

-- Info
local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, 0, 0, 25)
info.Position = UDim2.new(0, 0, 0, 35)
info.BackgroundTransparency = 1
info.Text = "Reach: " .. CONFIG.reach
info.TextColor3 = Color3.fromRGB(200, 200, 200)
info.TextSize = 12
info.Parent = main

-- Container
local container = Instance.new("Frame")
container.Size = UDim2.new(1, -20, 1, -70)
container.Position = UDim2.new(0, 10, 0, 65)
container.BackgroundTransparency = 1
container.Parent = main

-- ============================================
-- SAVE POSITION SYSTEM
-- ============================================

-- Botão Salvar Posição
local saveBtn = Instance.new("TextButton")
saveBtn.Size = UDim2.new(1, 0, 0, 50)
saveBtn.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
saveBtn.Text = "💾 SALVAR POSIÇÃO ATUAL"
saveBtn.TextColor3 = Color3.new(1, 1, 1)
saveBtn.TextSize = 14
saveBtn.Font = Enum.Font.GothamBold
saveBtn.Parent = container
Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 10)

-- Label da posição salva
local savedLabel = Instance.new("TextLabel")
savedLabel.Size = UDim2.new(1, 0, 0, 30)
savedLabel.Position = UDim2.new(0, 0, 0, 55)
savedLabel.BackgroundTransparency = 1
savedLabel.Text = "Nenhuma posição salva"
savedLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
savedLabel.TextSize = 11
savedLabel.Font = Enum.Font.Gotham
savedLabel.Parent = container

-- ============================================
-- CONTROLES DE CURVA
-- ============================================

local curveLabel = Instance.new("TextLabel")
curveLabel.Size = UDim2.new(1, 0, 0, 20)
curveLabel.Position = UDim2.new(0, 0, 0, 90)
curveLabel.BackgroundTransparency = 1
curveLabel.Text = "PODER DA CURVA: " .. CONFIG.curvePower .. "%"
curveLabel.TextColor3 = Color3.fromRGB(251, 191, 36)
curveLabel.TextSize = 12
curveLabel.Font = Enum.Font.GothamBold
curveLabel.Parent = container

-- Slider curva
local curveBg = Instance.new("Frame")
curveBg.Size = UDim2.new(1, 0, 0, 25)
curveBg.Position = UDim2.new(0, 0, 0, 115)
curveBg.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
curveBg.BorderSizePixel = 0
curveBg.Parent = container
Instance.new("UICorner", curveBg).CornerRadius = UDim.new(0, 8)

local curveFill = Instance.new("Frame")
curveFill.Size = UDim2.new(CONFIG.curvePower/100, 0, 1, 0)
curveFill.BackgroundColor3 = Color3.fromRGB(251, 191, 36)
curveFill.BorderSizePixel = 0
curveFill.Parent = curveBg
Instance.new("UICorner", curveFill).CornerRadius = UDim.new(0, 8)

-- Botões +/- curva
local curveMinus = Instance.new("TextButton")
curveMinus.Size = UDim2.new(0, 40, 0, 30)
curveMinus.Position = UDim2.new(0, 0, 0, 145)
curveMinus.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
curveMinus.Text = "-"
curveMinus.TextColor3 = Color3.new(1, 1, 1)
curveMinus.TextSize = 20
curveMinus.Parent = container
Instance.new("UICorner", curveMinus).CornerRadius = UDim.new(0, 6)

local curvePlus = Instance.new("TextButton")
curvePlus.Size = UDim2.new(0, 40, 0, 30)
curvePlus.Position = UDim2.new(1, -40, 0, 145)
curvePlus.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
curvePlus.Text = "+"
curvePlus.TextColor3 = Color3.new(1, 1, 1)
curvePlus.TextSize = 20
curvePlus.Parent = container
Instance.new("UICorner", curvePlus).CornerRadius = UDim.new(0, 6)

-- ============================================
-- BOTÕES DE CHUTE
-- ============================================

local kickFrame = Instance.new("Frame")
kickFrame.Size = UDim2.new(1, 0, 0, 60)
kickFrame.Position = UDim2.new(0, 0, 0, 185)
kickFrame.BackgroundTransparency = 1
kickFrame.Parent = container

-- Chute Esquerda (F) - Vai pra posição salva com curva
local kickF = Instance.new("TextButton")
kickF.Size = UDim2.new(0.48, 0, 1, 0)
kickF.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
kickF.Text = "⬅️ CHUTE [F]\n(Curva Esquerda)"
kickF.TextColor3 = Color3.new(1, 1, 1)
kickF.TextSize = 12
kickF.Font = Enum.Font.GothamBold
kickF.Parent = kickFrame
Instance.new("UICorner", kickF).CornerRadius = UDim.new(0, 10)

-- Chute Direita (R) - Vai pra posição salva com curva
local kickR = Instance.new("TextButton")
kickR.Size = UDim2.new(0.48, 0, 1, 0)
kickR.Position = UDim2.new(0.52, 0, 0, 0)
kickR.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
kickR.Text = "CHUTE [R] ➡️\n(Curva Direita)"
kickR.TextColor3 = Color3.new(1, 1, 1)
kickR.TextSize = 12
kickR.Font = Enum.Font.GothamBold
kickR.Parent = kickFrame
Instance.new("UICorner", kickR).CornerRadius = UDim.new(0, 10)

-- ============================================
-- REACH CONTROLS
-- ============================================

local reachLabel = Instance.new("TextLabel")
reachLabel.Size = UDim2.new(1, 0, 0, 20)
reachLabel.Position = UDim2.new(0, 0, 0, 255)
reachLabel.BackgroundTransparency = 1
reachLabel.Text = "ALCANCE: " .. CONFIG.reach
reachLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
reachLabel.TextSize = 12
reachLabel.Font = Enum.Font.GothamBold
reachLabel.Parent = container

local reachMinus = Instance.new("TextButton")
reachMinus.Size = UDim2.new(0, 50, 0, 35)
reachMinus.Position = UDim2.new(0, 0, 0, 280)
reachMinus.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
reachMinus.Text = "-"
reachMinus.TextColor3 = Color3.new(1, 1, 1)
reachMinus.TextSize = 20
reachMinus.Parent = container
Instance.new("UICorner", reachMinus).CornerRadius = UDim.new(0, 8)

local reachPlus = Instance.new("TextButton")
reachPlus.Size = UDim2.new(0, 50, 0, 35)
reachPlus.Position = UDim2.new(1, -50, 0, 280)
reachPlus.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
reachPlus.Text = "+"
reachPlus.TextColor3 = Color3.new(1, 1, 1)
reachPlus.TextSize = 20
reachPlus.Parent = container
Instance.new("UICorner", reachPlus).CornerRadius = UDim.new(0, 8)

-- Toggle Reach
local reachToggle = Instance.new("TextButton")
reachToggle.Size = UDim2.new(1, 0, 0, 40)
reachToggle.Position = UDim2.new(0, 0, 0, 320)
reachToggle.BackgroundColor3 = CONFIG.autoTouch and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(60, 60, 80)
reachToggle.Text = "AUTO TOUCH: " .. (CONFIG.autoTouch and "ON" or "OFF")
reachToggle.TextColor3 = Color3.new(1, 1, 1)
reachToggle.TextSize = 14
reachToggle.Font = Enum.Font.GothamBold
reachToggle.Parent = container
Instance.new("UICorner", reachToggle).CornerRadius = UDim.new(0, 10)

-- ============================================
-- FUNÇÕES DO SISTEMA
-- ============================================

-- Salvar posição atual
local function savePosition()
    if not hrp or not hrp.Parent then return end
    
    CONFIG.savedPosition = hrp.Position
    savedLabel.Text = "✅ POSIÇÃO SALVA!\nX: " .. math.floor(CONFIG.savedPosition.X) .. 
                     " Z: " .. math.floor(CONFIG.savedPosition.Z)
    savedLabel.TextColor3 = Color3.fromRGB(34, 197, 94)
    
    -- Efeito visual
    pcall(function()
        local beam = Instance.new("Part")
        beam.Shape = Enum.PartType.Ball
        beam.Size = Vector3.new(5, 5, 5)
        beam.Position = CONFIG.savedPosition + Vector3.new(0, 3, 0)
        beam.Anchored = true
        beam.CanCollide = false
        beam.Material = Enum.Material.Neon
        beam.Color = Color3.fromRGB(34, 197, 94)
        beam.Transparency = 0.3
        beam.Parent = Workspace
        
        for i = 1, 10 do
            beam.Size = beam.Size + Vector3.new(1, 1, 1)
            beam.Transparency = beam.Transparency + 0.07
            task.wait(0.05)
        end
        beam:Destroy()
    end)
    
    print("💾 Posição salva:", CONFIG.savedPosition)
end

-- Executar tote roubado
local function executeTote(direction)
    if not CONFIG.savedPosition then
        savedLabel.Text = "❌ SALVE UMA POSIÇÃO PRIMEIRO!"
        savedLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end
    
    -- Encontrar bola
    local ball = nil
    local nearestDist = math.huge
    
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                if obj.Name:find("Ball") or obj.Name:find("Bola") or obj.Name:find("Soccer") or obj.Name:find("TPS") then
                    if obj.Position then
                        local dist = (obj.Position - hrp.Position).Magnitude
                        if dist < nearestDist and dist < 20 then
                            nearestDist = dist
                            ball = obj
                        end
                    end
                end
            end
        end
    end)
    
    if not ball then
        print("⚠️ Bola não encontrada!")
        return
    end
    
    -- Calcular direção para posição salva
    local startPos = ball.Position
    local targetPos = CONFIG.savedPosition
    local directionVector = (targetPos - startPos).Unit
    
    -- Aplicar curva gigante
    local sideDir = (direction == "R") and 1 or -1
    local curveVector = hrp.CFrame.RightVector * sideDir * CONFIG.curvePower * 0.1
    
    print(string.format("⚽ Chute %s | Curva: %d%% | Target: %.1f, %.1f", 
        direction, CONFIG.curvePower, targetPos.X, targetPos.Z))
    
    -- Executar chute roubado
    pcall(function()
        -- Touch inicial
        firetouchinterest(ball, hrp, 0)
        task.wait(0.03)
        firetouchinterest(ball, hrp, 1)
        
        -- Mover bola com curva gigante para o alvo
        local startTime = tick()
        local duration = 1.5 -- Tempo maior para curva visível
        
        while tick() - startTime < duration do
            if not ball or not ball.Parent then break end
            
            local elapsed = tick() - startTime
            local progress = elapsed / duration
            
            -- Interpolação linear para o alvo
            local straightPos = startPos:Lerp(targetPos, progress)
            
            -- Adicionar curva (arco)
            local curveOffset = curveVector * math.sin(progress * math.pi) * (CONFIG.curvePower * 0.05)
            
            -- Elevação (parábola)
            local heightOffset = Vector3.new(0, math.sin(progress * math.pi) * CONFIG.lift, 0)
            
            -- Posição final
            local finalPos = straightPos + curveOffset + heightOffset
            
            -- Teleporte suave (roubado mas suave)
            ball.CFrame = CFrame.new(finalPos)
            
            task.wait(0.03)
        end
        
        -- Garantir que chegou no destino
        ball.CFrame = CFrame.new(targetPos + Vector3.new(0, 2, 0))
        
        -- Touch final
        firetouchinterest(ball, hrp, 0)
        firetouchinterest(ball, hrp, 1)
    end)
    
    -- Efeito visual
    pcall(function()
        local trail = Instance.new("Part")
        trail.Shape = Enum.PartType.Ball
        trail.Size = Vector3.new(2, 2, 2)
        trail.Position = targetPos
        trail.Anchored = true
        trail.CanCollide = false
        trail.Material = Enum.Material.Neon
        trail.Color = (direction == "R") and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(100, 100, 255)
        trail.Transparency = 0.2
        trail.Parent = Workspace
        
        task.delay(0.5, function()
            trail:Destroy()
        end)
    end)
end

-- ============================================
-- SISTEMA DE REACH
-- ============================================

local lastTouch = 0
local touchDebounce = {}

local function getBalls()
    local list = {}
    pcall(function()
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.Parent then
                if v.Name:find("Ball") or v.Name:find("Bola") or v.Name:find("Soccer") or 
                   v.Name:find("TPS") or v.Name:find("TCS") or v.Name:find("ESA") then
                    table.insert(list, v)
                end
            end
        end
    end)
    return list
end

local function doTouch(ball, part)
    if not ball or not ball.Parent or not part or not part.Parent then return end
    local key = tostring(ball) .. "_" .. tostring(part)
    if touchDebounce[key] and tick() - touchDebounce[key] < 0.1 then return end
    touchDebounce[key] = tick()
    
    pcall(function()
        firetouchinterest(ball, part, 0)
        task.wait(0.01)
        firetouchinterest(ball, part, 1)
        if CONFIG.doubleTouch then
            task.wait(0.05)
            firetouchinterest(ball, part, 0)
            firetouchinterest(ball, part, 1)
        end
    end)
end

-- ============================================
-- CONEXÕES
-- ============================================

-- Save
saveBtn.MouseButton1Click:Connect(savePosition)

-- Curva
curveMinus.MouseButton1Click:Connect(function()
    CONFIG.curvePower = math.clamp(CONFIG.curvePower - 5, 0, 100)
    curveLabel.Text = "PODER DA CURVA: " .. CONFIG.curvePower .. "%"
    curveFill.Size = UDim2.new(CONFIG.curvePower/100, 0, 1, 0)
end)

curvePlus.MouseButton1Click:Connect(function()
    CONFIG.curvePower = math.clamp(CONFIG.curvePower + 5, 0, 100)
    curveLabel.Text = "PODER DA CURVA: " .. CONFIG.curvePower .. "%"
    curveFill.Size = UDim2.new(CONFIG.curvePower/100, 0, 1, 0)
end)

-- Slider curva touch
local curveDragging = false
curveBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        curveDragging = true
        local pos = input.Position.X - curveBg.AbsolutePosition.X
        CONFIG.curvePower = math.clamp(math.floor((pos / curveBg.AbsoluteSize.X) * 100), 0, 100)
        curveLabel.Text = "PODER DA CURVA: " .. CONFIG.curvePower .. "%"
        curveFill.Size = UDim2.new(CONFIG.curvePower/100, 0, 1, 0)
    end
end)

curveBg.InputChanged:Connect(function(input)
    if curveDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local pos = input.Position.X - curveBg.AbsolutePosition.X
        CONFIG.curvePower = math.clamp(math.floor((pos / curveBg.AbsoluteSize.X) * 100), 0, 100)
        curveLabel.Text = "PODER DA CURVA: " .. CONFIG.curvePower .. "%"
        curveFill.Size = UDim2.new(CONFIG.curvePower/100, 0, 1, 0)
    end
end)

curveBg.InputEnded:Connect(function() curveDragging = false end)

-- Chutes
kickF.MouseButton1Click:Connect(function() executeTote("F") end)
kickR.MouseButton1Click:Connect(function() executeTote("R") end)

-- Reach
reachMinus.MouseButton1Click:Connect(function()
    CONFIG.reach = math.clamp(CONFIG.reach - 1, 1, 50)
    reachLabel.Text = "ALCANCE: " .. CONFIG.reach
    info.Text = "Reach: " .. CONFIG.reach
end)

reachPlus.MouseButton1Click:Connect(function()
    CONFIG.reach = math.clamp(CONFIG.reach + 1, 1, 50)
    reachLabel.Text = "ALCANCE: " .. CONFIG.reach
    info.Text = "Reach: " .. CONFIG.reach
end)

reachToggle.MouseButton1Click:Connect(function()
    CONFIG.autoTouch = not CONFIG.autoTouch
    reachToggle.BackgroundColor3 = CONFIG.autoTouch and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(60, 60, 80)
    reachToggle.Text = "AUTO TOUCH: " .. (CONFIG.autoTouch and "ON" or "OFF")
end)

-- Teclado
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.E then
        savePosition()
    elseif input.KeyCode == Enum.KeyCode.F then
        executeTote("F")
    elseif input.KeyCode == Enum.KeyCode.R then
        executeTote("R")
    end
end)

-- ============================================
-- LOOP PRINCIPAL (REACH)
-- ============================================
RunService.RenderStepped:Connect(function()
    pcall(function()
        -- Atualizar character
        if player.Character and player.Character ~= char then
            char = player.Character
            hrp = char:WaitForChild("HumanoidRootPart")
        end
        
        -- Reach auto
        if CONFIG.autoTouch and hrp and hrp.Parent then
            local balls = getBalls()
            local now = tick()
            local hrpPos = hrp.Position
            
            if now - lastTouch >= 0.05 then
                for _, ball in ipairs(balls) do
                    if ball and ball.Position then
                        local dist = (ball.Position - hrpPos).Magnitude
                        if dist <= CONFIG.reach then
                            lastTouch = now
                            for _, part in ipairs(char:GetChildren()) do
                                if part:IsA("BasePart") then
                                    doTouch(ball, part)
                                end
                            end
                            break
                        end
                    end
                end
            end
        end
    end)
end)

-- Drag GUI
local dragging = false
local dragStart, startPos

main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                  startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

print("========================================")
print("⚡ CAFUXZ1 TOTE ROUBADO + REACH")
print("========================================")
print("🎮 CONTROLES:")
print("   [E] - Salvar posição atual")
print("   [F] - Chute curva esquerda")
print("   [R] - Chute curva direita")
print("========================================")
