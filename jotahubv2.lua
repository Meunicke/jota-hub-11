--[[
    CAFUXZ1 Hub v18.3 - TOTE ROUBADO (COM ALTURA)
    Bola sobe e desce no gol, não rasteira
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
    reach = 12,
    autoTouch = true,
    doubleTouch = true,
    
    -- Tote - ALTURA AUMENTADA
    savedPosition = nil,
    curvePower = 80,            -- Curva lateral
    speed = 100,                -- Velocidade horizontal
    lift = 35,                  -- AUMENTADO: Altura do arco (era 15)
    gravityControl = true,        -- NOVO: Controla queda da bola
    
    -- Cores
    color1 = Color3.fromRGB(99, 102, 241),
    color2 = Color3.fromRGB(0, 255, 255)
}

-- ============================================
-- GUI
-- ============================================
local gui = Instance.new("ScreenGui")
gui.Name = "CAFUXZ1_Tote"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 300, 0, 440)
main.Position = UDim2.new(0, 10, 0.5, -220)
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
info.Text = "Reach: " .. CONFIG.reach .. " | Speed: " .. CONFIG.speed .. " | Lift: " .. CONFIG.lift
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
-- SAVE POSITION
-- ============================================

local saveBtn = Instance.new("TextButton")
saveBtn.Size = UDim2.new(1, 0, 0, 50)
saveBtn.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
saveBtn.Text = "💾 SALVAR POSIÇÃO DO GOL"
saveBtn.TextColor3 = Color3.new(1, 1, 1)
saveBtn.TextSize = 14
saveBtn.Font = Enum.Font.GothamBold
saveBtn.Parent = container
Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 10)

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
-- CONTROLES DE ALTURA (NOVO)
-- ============================================

local liftLabel = Instance.new("TextLabel")
liftLabel.Size = UDim2.new(1, 0, 0, 20)
liftLabel.Position = UDim2.new(0, 0, 0, 90)
liftLabel.BackgroundTransparency = 1
liftLabel.Text = "ALTURA DO ARCO: " .. CONFIG.lift
liftLabel.TextColor3 = Color3.fromRGB(255, 150, 50)
liftLabel.TextSize = 12
liftLabel.Font = Enum.Font.GothamBold
liftLabel.Parent = container

local liftMinus = Instance.new("TextButton")
liftMinus.Size = UDim2.new(0, 40, 0, 30)
liftMinus.Position = UDim2.new(0, 0, 0, 115)
liftMinus.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
liftMinus.Text = "-"
liftMinus.TextColor3 = Color3.new(1, 1, 1)
liftMinus.TextSize = 20
liftMinus.Parent = container
Instance.new("UICorner", liftMinus).CornerRadius = UDim.new(0, 6)

local liftPlus = Instance.new("TextButton")
liftPlus.Size = UDim2.new(0, 40, 0, 30)
liftPlus.Position = UDim2.new(1, -40, 0, 115)
liftPlus.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
liftPlus.Text = "+"
liftPlus.TextColor3 = Color3.new(1, 1, 1)
liftPlus.TextSize = 20
liftPlus.Parent = container
Instance.new("UICorner", liftPlus).CornerRadius = UDim.new(0, 6)

-- ============================================
-- CONTROLES DE VELOCIDADE
-- ============================================

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, 0, 0, 20)
speedLabel.Position = UDim2.new(0, 0, 0, 150)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "VELOCIDADE: " .. CONFIG.speed
speedLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
speedLabel.TextSize = 12
speedLabel.Font = Enum.Font.GothamBold
speedLabel.Parent = container

local speedMinus = Instance.new("TextButton")
speedMinus.Size = UDim2.new(0, 40, 0, 30)
speedMinus.Position = UDim2.new(0, 0, 0, 175)
speedMinus.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
speedMinus.Text = "-"
speedMinus.TextColor3 = Color3.new(1, 1, 1)
speedMinus.TextSize = 20
speedMinus.Parent = container
Instance.new("UICorner", speedMinus).CornerRadius = UDim.new(0, 6)

local speedPlus = Instance.new("TextButton")
speedPlus.Size = UDim2.new(0, 40, 0, 30)
speedPlus.Position = UDim2.new(1, -40, 0, 175)
speedPlus.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
speedPlus.Text = "+"
speedPlus.TextColor3 = Color3.new(1, 1, 1)
speedPlus.TextSize = 20
speedPlus.Parent = container
Instance.new("UICorner", speedPlus).CornerRadius = UDim.new(0, 6)

-- ============================================
-- CONTROLES DE CURVA
-- ============================================

local curveLabel = Instance.new("TextLabel")
curveLabel.Size = UDim2.new(1, 0, 0, 20)
curveLabel.Position = UDim2.new(0, 0, 0, 210)
curveLabel.BackgroundTransparency = 1
curveLabel.Text = "CURVA LATERAL: " .. CONFIG.curvePower .. "%"
curveLabel.TextColor3 = Color3.fromRGB(251, 191, 36)
curveLabel.TextSize = 12
curveLabel.Font = Enum.Font.GothamBold
curveLabel.Parent = container

local curveMinus = Instance.new("TextButton")
curveMinus.Size = UDim2.new(0, 40, 0, 30)
curveMinus.Position = UDim2.new(0, 0, 0, 235)
curveMinus.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
curveMinus.Text = "-"
curveMinus.TextColor3 = Color3.new(1, 1, 1)
curveMinus.TextSize = 20
curveMinus.Parent = container
Instance.new("UICorner", curveMinus).CornerRadius = UDim.new(0, 6)

local curvePlus = Instance.new("TextButton")
curvePlus.Size = UDim2.new(0, 40, 0, 30)
curvePlus.Position = UDim2.new(1, -40, 0, 235)
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
kickFrame.Position = UDim2.new(0, 0, 0, 275)
kickFrame.BackgroundTransparency = 1
kickFrame.Parent = container

local kickF = Instance.new("TextButton")
kickF.Size = UDim2.new(0.48, 0, 1, 0)
kickF.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
kickF.Text = "⬅️ CHUTE [F]\n(Curva Esquerda)"
kickF.TextColor3 = Color3.new(1, 1, 1)
kickF.TextSize = 12
kickF.Font = Enum.Font.GothamBold
kickF.Parent = kickFrame
Instance.new("UICorner", kickF).CornerRadius = UDim.new(0, 10)

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
reachLabel.Position = UDim2.new(0, 0, 0, 345)
reachLabel.BackgroundTransparency = 1
reachLabel.Text = "ALCANCE: " .. CONFIG.reach
reachLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
reachLabel.TextSize = 12
reachLabel.Font = Enum.Font.GothamBold
reachLabel.Parent = container

local reachMinus = Instance.new("TextButton")
reachMinus.Size = UDim2.new(0, 50, 0, 35)
reachMinus.Position = UDim2.new(0, 0, 0, 370)
reachMinus.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
reachMinus.Text = "-"
reachMinus.TextColor3 = Color3.new(1, 1, 1)
reachMinus.TextSize = 20
reachMinus.Parent = container
Instance.new("UICorner", reachMinus).CornerRadius = UDim.new(0, 8)

local reachPlus = Instance.new("TextButton")
reachPlus.Size = UDim2.new(0, 50, 0, 35)
reachPlus.Position = UDim2.new(1, -50, 0, 370)
reachPlus.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
reachPlus.Text = "+"
reachPlus.TextColor3 = Color3.new(1, 1, 1)
reachPlus.TextSize = 20
reachPlus.Parent = container
Instance.new("UICorner", reachPlus).CornerRadius = UDim.new(0, 8)

local reachToggle = Instance.new("TextButton")
reachToggle.Size = UDim2.new(1, 0, 0, 40)
reachToggle.Position = UDim2.new(0, 0, 0, 410)
reachToggle.BackgroundColor3 = CONFIG.autoTouch and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(60, 60, 80)
reachToggle.Text = "AUTO TOUCH: " .. (CONFIG.autoTouch and "ON" or "OFF")
reachToggle.TextColor3 = Color3.new(1, 1, 1)
reachToggle.TextSize = 14
reachToggle.Font = Enum.Font.GothamBold
reachToggle.Parent = container
Instance.new("UICorner", reachToggle).CornerRadius = UDim.new(0, 10)

-- ============================================
-- FUNÇÕES
-- ============================================

local function savePosition()
    if not hrp or not hrp.Parent then return end
    
    CONFIG.savedPosition = hrp.Position
    savedLabel.Text = "✅ POSIÇÃO SALVA!\nX: " .. math.floor(CONFIG.savedPosition.X) .. 
                     " Z: " .. math.floor(CONFIG.savedPosition.Z)
    savedLabel.TextColor3 = Color3.fromRGB(34, 197, 94)
    
    pcall(function()
        local beam = Instance.new("Part")
        beam.Shape = Enum.PartType.Ball
        beam.Size = Vector3.new(3, 3, 3)
        beam.Position = CONFIG.savedPosition + Vector3.new(0, 2, 0)
        beam.Anchored = true
        beam.CanCollide = false
        beam.Material = Enum.Material.Neon
        beam.Color = Color3.fromRGB(34, 197, 94)
        beam.Transparency = 0.3
        beam.Parent = Workspace
        
        for i = 1, 8 do
            beam.Size = beam.Size + Vector3.new(0.5, 0.5, 0.5)
            beam.Transparency = beam.Transparency + 0.1
            task.wait(0.05)
        end
        beam:Destroy()
    end)
    
    print("💾 Posição salva:", CONFIG.savedPosition)
end

-- ============================================
-- CHUTE COM ALTURA (NÃO RASTEIRO)
-- ============================================

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
            if obj:IsA("BasePart") and not obj.Anchored then
                local nameLower = obj.Name:lower()
                if nameLower:find("ball") or nameLower:find("bola") or nameLower:find("soccer") or 
                   nameLower:find("tps") or nameLower:find("tcs") then
                    local dist = (obj.Position - hrp.Position).Magnitude
                    if dist < nearestDist and dist < 30 then
                        nearestDist = dist
                        ball = obj
                    end
                end
            end
        end
    end)
    
    if not ball then
        savedLabel.Text = "❌ BOLA NÃO ENCONTRADA!"
        savedLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end
    
    local originalCanCollide = ball.CanCollide
    ball.CanCollide = true
    
    local ballPos = ball.Position
    local targetPos = CONFIG.savedPosition
    
    -- Distância horizontal
    local flatDistance = Vector3.new(targetPos.X - ballPos.X, 0, targetPos.Z - ballPos.Z)
    local distance = flatDistance.Magnitude
    
    -- Altura do gol vs bola
    local heightDiff = targetPos.Y - ballPos.Y
    
    print(string.format("⚽ Chute %s | Dist: %.1f | Altura alvo: %.1f", direction, distance, heightDiff))
    
    pcall(function()
        -- Touch inicial
        firetouchinterest(ball, hrp, 0)
        task.wait(0.02)
        firetouchinterest(ball, hrp, 1)
        
        -- ==========================================
        -- CÁLCULO DE PROJÉTIL (PARÁBOLA)
        -- ==========================================
        
        -- Tempo estimado de voo baseado na distância
        local flightTime = math.clamp(distance / 25, 0.6, 2.0)
        
        -- Velocidade horizontal necessária
        local horizontalVel = flatDistance.Unit * (distance / flightTime)
        
        -- Velocidade VERTICAL calculada pra fazer arco e cair no gol
        -- Fórmula: v0 = (Δy + 0.5*g*t²) / t
        local gravity = workspace.Gravity
        local verticalVel = (heightDiff + (0.5 * gravity * flightTime * flightTime)) / flightTime
        
        -- Adicionar extra de altura pro arco bonito (não rasteiro)
        verticalVel = verticalVel + CONFIG.lift
        
        -- Curva lateral
        local sideDir = (direction == "R") and 1 or -1
        local curveDir = flatDistance.Unit:Cross(Vector3.new(0, 1, 0)) * sideDir
        local curveVel = curveDir * (CONFIG.curvePower * 0.4)
        
        -- VELOCIDADE FINAL
        local finalVelocity = horizontalVel + Vector3.new(0, verticalVel, 0) + curveVel
        
        -- Aplicar impulso
        ball.Velocity = finalVelocity
        ball.RotVelocity = Vector3.new(math.random(-20, 20), math.random(-20, 20), math.random(-20, 20))
        
        print(string.format("   Vel: H=%.1f, V=%.1f, C=%.1f", horizontalVel.Magnitude, verticalVel, curveVel.Magnitude))
        
        -- CONTROLE DE VOO - Mantém trajetória e corrige queda
        local startTime = tick()
        local connection
        
        connection = RunService.Heartbeat:Connect(function()
            if not ball or not ball.Parent then 
                connection:Disconnect()
                return
            end
            
            local elapsed = tick() - startTime
            
            -- Se passou do tempo de voo, deixa cair naturalmente
            if elapsed > flightTime * 1.2 then
                connection:Disconnect()
                ball.CanCollide = originalCanCollide
                return
            end
            
            local currentPos = ball.Position
            local toGoal = (targetPos - currentPos)
            local distRemaining = toGoal.Magnitude
            
            -- Chegou perto do gol
            if distRemaining < 5 then
                connection:Disconnect()
                ball.CanCollide = originalCanCollide
                -- Atrair pro centro
                ball.Velocity = toGoal.Unit * 15
                return
            end
            
            -- CORREÇÃO: se a bola tá caindo muito rápido, dá um up
            if ball.Velocity.Y < -10 and currentPos.Y < targetPos.Y + 5 then
                ball.Velocity = Vector3.new(ball.Velocity.X, ball.Velocity.Y * 0.5, ball.Velocity.Z)
            end
            
            -- CORREÇÃO: mantém direção horizontal pro gol
            local currentHorizontal = Vector3.new(ball.Velocity.X, 0, ball.Velocity.Z)
            local toGoalHorizontal = Vector3.new(toGoal.X, 0, toGoal.Z).Unit
            
            -- Interpola direção atual pra direção do gol (suave)
            local newHorizontal = (currentHorizontal.Unit * 0.7 + toGoalHorizontal * 0.3) * math.max(currentHorizontal.Magnitude, 20)
            
            ball.Velocity = Vector3.new(newHorizontal.X, ball.Velocity.Y, newHorizontal.Z)
        end)
        
        -- Timeout
        task.delay(4, function()
            if connection then
                connection:Disconnect()
                if ball and ball.Parent then
                    ball.CanCollide = originalCanCollide
                end
            end
        end)
    end)
    
    -- Efeito visual
    pcall(function()
        local attachment = Instance.new("Attachment", ball)
        local trail = Instance.new("Trail")
        trail.Color = ColorSequence.new(
            (direction == "R") and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(100, 100, 255),
            Color3.fromRGB(255, 255, 255)
        )
        trail.Lifetime = 0.4
        trail.WidthScale = NumberSequence.new(0.6, 0)
        trail.Parent = attachment
        
        task.delay(2, function()
            if attachment then attachment:Destroy() end
        end)
    end)
end

-- ============================================
-- REACH SYSTEM
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

saveBtn.MouseButton1Click:Connect(savePosition)

-- Altura
liftMinus.MouseButton1Click:Connect(function()
    CONFIG.lift = math.clamp(CONFIG.lift - 5, 10, 80)
    liftLabel.Text = "ALTURA DO ARCO: " .. CONFIG.lift
    info.Text = "Reach: " .. CONFIG.reach .. " | Speed: " .. CONFIG.speed .. " | Lift: " .. CONFIG.lift
end)

liftPlus.MouseButton1Click:Connect(function()
    CONFIG.lift = math.clamp(CONFIG.lift + 5, 10, 80)
    liftLabel.Text = "ALTURA DO ARCO: " .. CONFIG.lift
    info.Text = "Reach: " .. CONFIG.reach .. " | Speed: " .. CONFIG.speed .. " | Lift: " .. CONFIG.lift
end)

-- Velocidade
speedMinus.MouseButton1Click:Connect(function()
    CONFIG.speed = math.clamp(CONFIG.speed - 10, 50, 200)
    speedLabel.Text = "VELOCIDADE: " .. CONFIG.speed
    info.Text = "Reach: " .. CONFIG.reach .. " | Speed: " .. CONFIG.speed .. " | Lift: " .. CONFIG.lift
end)

speedPlus.MouseButton1Click:Connect(function()
    CONFIG.speed = math.clamp(CONFIG.speed + 10, 50, 200)
    speedLabel.Text = "VELOCIDADE: " .. CONFIG.speed
    info.Text = "Reach: " .. CONFIG.reach .. " | Speed: " .. CONFIG.speed .. " | Lift: " .. CONFIG.lift
end)

-- Curva
curveMinus.MouseButton1Click:Connect(function()
    CONFIG.curvePower = math.clamp(CONFIG.curvePower - 10, 0, 200)
    curveLabel.Text = "CURVA LATERAL: " .. CONFIG.curvePower .. "%"
end)

curvePlus.MouseButton1Click:Connect(function()
    CONFIG.curvePower = math.clamp(CONFIG.curvePower + 10, 0, 200)
    curveLabel.Text = "CURVA LATERAL: " .. CONFIG.curvePower .. "%"
end)

-- Chutes
kickF.MouseButton1Click:Connect(function() executeTote("F") end)
kickR.MouseButton1Click:Connect(function() executeTote("R") end)

-- Reach
reachMinus.MouseButton1Click:Connect(function()
    CONFIG.reach = math.clamp(CONFIG.reach - 1, 1, 50)
    reachLabel.Text = "ALCANCE: " .. CONFIG.reach
    info.Text = "Reach: " .. CONFIG.reach .. " | Speed: " .. CONFIG.speed .. " | Lift: " .. CONFIG.lift
end)

reachPlus.MouseButton1Click:Connect(function()
    CONFIG.reach = math.clamp(CONFIG.reach + 1, 1, 50)
    reachLabel.Text = "ALCANCE: " .. CONFIG.reach
    info.Text = "Reach: " .. CONFIG.reach .. " | Speed: " .. CONFIG.speed .. " | Lift: " .. CONFIG.lift
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
-- LOOP PRINCIPAL
-- ============================================
RunService.RenderStepped:Connect(function()
    pcall(function()
        if player.Character and player.Character ~= char then
            char = player.Character
            hrp = char:WaitForChild("HumanoidRootPart")
        end
        
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
print("⚡ CAFUXZ1 TOTE ROUBADO v18.3")
print("========================================")
print("✅ ALTURA CONSERTADA:")
print("   • Lift padrão: 35 (era 15)")
print("   • Controle de altura na GUI")
print("   • Fórmula de projétil calculada")
print("   • Bola sobe e desce no gol")
print("========================================")
