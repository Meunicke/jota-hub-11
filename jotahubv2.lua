--[[
    CAFUXZ1 Hub v15.2 - Mobile Tote System
    Chute de lado (Tote) adaptado para mobile
]]

-- Esperar ambiente
task.wait(0.5)

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local ContextActionService = game:GetService("ContextActionService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

-- Limpar GUIs antigas
for _, obj in ipairs(CoreGui:GetChildren()) do
    if obj.Name == "CAFUXZ1_Hub" or obj.Name == "CAFUXZ1_Icon" or obj.Name == "CAFUXZ1_Mobile" then
        obj:Destroy()
    end
end

-- Configurações
local CONFIG = {
    reach = 10,
    arthurReach = 10,
    showSpheres = true,
    autoTouch = true,
    detectBalls = true,
    doubleTouch = true,
    toteEnabled = true, -- Sistema de tote ativo
    toteKey = "R", -- Tecla padrão do tote
    color1 = Color3.fromRGB(99, 102, 241),
    color2 = Color3.fromRGB(0, 255, 255),
}

-- Esferas
local sphere1, sphere2 = nil, nil

-- Criar esferas
local function createSpheres()
    if sphere1 then sphere1:Destroy() end
    if sphere2 then sphere2:Destroy() end
    
    sphere1 = Instance.new("Part")
    sphere1.Name = "CAFUXZ1_Sphere1"
    sphere1.Shape = Enum.PartType.Ball
    sphere1.Anchored = true
    sphere1.CanCollide = false
    sphere1.Material = Enum.Material.ForceField
    sphere1.Transparency = 0.88
    sphere1.Color = CONFIG.color1
    sphere1.Parent = Workspace
    
    sphere2 = Instance.new("Part")
    sphere2.Name = "CAFUXZ1_Sphere2"
    sphere2.Shape = Enum.PartType.Ball
    sphere2.Anchored = true
    sphere2.CanCollide = false
    sphere2.Material = Enum.Material.ForceField
    sphere2.Transparency = CONFIG.doubleTouch and 0.75 or 1
    sphere2.Color = CONFIG.color2
    sphere2.Parent = Workspace
end

-- Atualizar esferas
local function updateSpheres()
    if not sphere1 or not sphere2 then createSpheres() end
    if not CONFIG.showSpheres then
        sphere1.Transparency = 1
        sphere2.Transparency = 1
        return
    end
    if hrp and hrp.Parent then
        sphere1.Position = hrp.Position
        sphere1.Size = Vector3.new(CONFIG.reach * 2, CONFIG.reach * 2, CONFIG.reach * 2)
        sphere2.Position = hrp.Position
        sphere2.Size = Vector3.new(CONFIG.arthurReach * 2, CONFIG.arthurReach * 2, CONFIG.arthurReach * 2)
        sphere2.Transparency = CONFIG.doubleTouch and 0.75 or 1
    end
end

-- Sistema de Reach
local BallNames = { "TPS", "TCS", "ESA", "MRS", "PRS", "MPS", "SSS", "Ball", "Soccer", "Bola" }
local balls = {}
local lastTouch = 0
local touchDebounce = {}

local function getBalls()
    if not CONFIG.detectBalls then return {} end
    local list = {}
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            for _, b in ipairs(BallNames) do
                if v.Name == b or v.Name:find(b, 1, true) then
                    table.insert(list, v)
                    break
                end
            end
        end
    end
    return list
end

local function doTouch(ball, part)
    if not ball or not ball.Parent or not part or not part.Parent then return end
    local key = ball.Name .. "_" .. part.Name .. "_" .. tostring(ball)
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
-- SISTEMA DE TOTE (CHUTE DE LADO)
-- ============================================

local isCharging = false
local toteDirection = "R" -- "R" = direita, "F" = esquerda

-- Função para executar o tote
local function executeTote(direction)
    if not CONFIG.toteEnabled then return end
    
    -- Procurar bola próxima
    local nearestBall = nil
    local nearestDist = math.huge
    
    for _, ball in ipairs(getBalls()) do
        if ball and ball.Parent then
            local dist = (ball.Position - hrp.Position).Magnitude
            if dist < nearestDist and dist <= CONFIG.reach + 5 then
                nearestDist = dist
                nearestBall = ball
            end
        end
    end
    
    if not nearestBall then return end
    
    -- Calcular direção do tote
    local characterCFrame = hrp.CFrame
    local ballPosition = nearestBall.Position
    
    -- Direção lateral baseada em R ou F
    local sideDirection = nil
    if direction == "R" then
        -- Tote para direita (90 graus)
        sideDirection = (characterCFrame.RightVector * 10) + (characterCFrame.LookVector * 5)
    else
        -- Tote para esquerda (-90 graus)
        sideDirection = (characterCFrame.RightVector * -10) + (characterCFrame.LookVector * 5)
    end
    
    -- Executar o chute de lado
    pcall(function()
        -- Primeiro touch normal
        firetouchinterest(nearestBall, hrp, 0)
        
        -- Aplicar impulso lateral na bola
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        bodyVelocity.Velocity = sideDirection * 50
        bodyVelocity.Parent = nearestBall
        
        task.wait(0.1)
        firetouchinterest(nearestBall, hrp, 1)
        
        -- Remover body velocity após o chute
        task.delay(0.3, function()
            if bodyVelocity and bodyVelocity.Parent then
                bodyVelocity:Destroy()
            end
        end)
    end)
    
    print("Tote executado: " .. direction)
end

-- ============================================
-- GUI MOBILE COM BOTÕES DE TOTE
-- ============================================

local gui = Instance.new("ScreenGui")
gui.Name = "CAFUXZ1_Mobile"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

-- Frame principal
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 350, 0, 500)
main.Position = UDim2.new(0.5, -175, 0.5, -250)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
main.BorderSizePixel = 0
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -80, 0, 40)
title.Position = UDim2.new(0, 15, 0, 5)
title.BackgroundTransparency = 1
title.Text = "⚡ CAFUXZ1 Hub"
title.TextColor3 = CONFIG.color1
title.TextSize = 22
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

-- Botões de controle da janela
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 35, 0, 35)
minimizeBtn.Position = UDim2.new(1, -75, 0, 5)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(245, 158, 11)
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
minimizeBtn.TextSize = 24
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.Parent = main
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 8)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -40, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.TextSize = 20
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = main
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

-- Container de controles
local container = Instance.new("Frame")
container.Size = UDim2.new(1, -20, 1, -130)
container.Position = UDim2.new(0, 10, 0, 50)
container.BackgroundTransparency = 1
container.Parent = main

local layout = Instance.new("UIListLayout", container)
layout.Padding = UDim.new(0, 8)

-- Info
local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, 0, 0, 25)
info.BackgroundTransparency = 1
info.Text = "🟣 Principal: " .. CONFIG.reach .. " | 🔵 Arthur: " .. CONFIG.arthurReach
info.TextColor3 = Color3.fromRGB(170, 170, 170)
info.TextSize = 11
info.Font = Enum.Font.Gotham
info.Parent = container

-- Função criar toggle
local function createToggle(text, default, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 42)
    btn.BackgroundColor3 = default and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(60, 60, 80)
    btn.Text = text .. ": " .. (default and "ON" or "OFF")
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.Parent = container
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    local enabled = default
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        btn.BackgroundColor3 = enabled and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(60, 60, 80)
        btn.Text = text .. ": " .. (enabled and "ON" or "OFF")
        callback(enabled)
    end)
    return btn
end

-- Função criar slider
local function createSlider(text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 65)
    frame.BackgroundTransparency = 1
    frame.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 18)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. default
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.Parent = frame
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, 0, 0, 38)
    input.Position = UDim2.new(0, 0, 0, 22)
    input.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    input.Text = tostring(default)
    input.TextColor3 = Color3.new(1, 1, 1)
    input.TextSize = 16
    input.Font = Enum.Font.GothamBold
    input.Parent = frame
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 8)
    
    input.FocusLost:Connect(function()
        local num = tonumber(input.Text)
        if num then
            num = math.clamp(math.floor(num), min, max)
            input.Text = tostring(num)
            label.Text = text .. ": " .. num
            callback(num)
            info.Text = "🟣 Principal: " .. CONFIG.reach .. " | 🔵 Arthur: " .. CONFIG.arthurReach
        else
            input.Text = tostring(default)
        end
    end)
end

-- Controles normais
createToggle("Auto Touch", CONFIG.autoTouch, function(v) CONFIG.autoTouch = v end)
createToggle("🔍 Detectar Bolas", CONFIG.detectBalls, function(v) CONFIG.detectBalls = v end)
createToggle("Mostrar Esferas", CONFIG.showSpheres, function(v) CONFIG.showSpheres = v end)
createToggle("Double Touch", CONFIG.doubleTouch, function(v) CONFIG.doubleTouch = v end)

createSlider("🟣 Alcance Principal", 1, 50, CONFIG.reach, function(v) CONFIG.reach = v end)
createSlider("🔵 Alcance Arthur", 1, 50, CONFIG.arthurReach, function(v) CONFIG.arthurReach = v end)

-- ============================================
-- BOTÕES DE TOTE (CHUTE DE LADO) - MOBILE
-- ============================================

local toteFrame = Instance.new("Frame")
toteFrame.Size = UDim2.new(1, 0, 0, 80)
toteFrame.BackgroundTransparency = 1
toteFrame.Parent = container

local toteTitle = Instance.new("TextLabel")
toteTitle.Size = UDim2.new(1, 0, 0, 20)
toteTitle.BackgroundTransparency = 1
toteTitle.Text = "⚽ TOTE (Chute de Lado)"
toteTitle.TextColor3 = Color3.fromRGB(255, 200, 100)
toteTitle.TextSize = 14
toteTitle.Font = Enum.Font.GothamBold
toteTitle.Parent = toteFrame

-- Botão Tote Esquerda (F)
local toteLeft = Instance.new("TextButton")
toteLeft.Size = UDim2.new(0.48, 0, 0, 50)
toteLeft.Position = UDim2.new(0, 0, 0, 25)
toteLeft.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
toteLeft.Text = "⬅️ TOTE (F)"
toteLeft.TextColor3 = Color3.new(1, 1, 1)
toteLeft.TextSize = 14
toteLeft.Font = Enum.Font.GothamBold
toteLeft.Parent = toteFrame
Instance.new("UICorner", toteLeft).CornerRadius = UDim.new(0, 10)

-- Botão Tote Direita (R)
local toteRight = Instance.new("TextButton")
toteRight.Size = UDim2.new(0.48, 0, 0, 50)
toteRight.Position = UDim2.new(0.52, 0, 0, 25)
toteRight.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
toteRight.Text = "TOTE (R) ➡️"
toteRight.TextColor3 = Color3.new(1, 1, 1)
toteRight.TextSize = 14)
toteRight.Font = Enum.Font.GothamBold
toteRight.Parent = toteFrame
Instance.new("UICorner", toteRight).CornerRadius = UDim.new(0, 10)

-- Funções dos botões de tote
toteLeft.MouseButton1Down:Connect(function()
    if not CONFIG.toteEnabled then return end
    -- Efeito visual
    toteLeft.BackgroundColor3 = Color3.fromRGB(150, 150, 255)
    executeTote("F")
    task.wait(0.1)
    toteLeft.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
end)

toteRight.MouseButton1Down:Connect(function()
    if not CONFIG.toteEnabled then return end
    -- Efeito visual
    toteRight.BackgroundColor3 = Color3.fromRGB(255, 150, 150)
    executeTote("R")
    task.wait(0.1)
    toteRight.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
end)

-- Toggle para ativar/desativar tote
createToggle("🎯 Sistema Tote", CONFIG.toteEnabled, function(v)
    CONFIG.toteEnabled = v
end)

-- ============================================
-- ÍCONE FLUTUANTE (MINIMIZADO)
-- ============================================
local iconGui = Instance.new("ScreenGui")
iconGui.Name = "CAFUXZ1_Icon"
iconGui.ResetOnSpawn = false
iconGui.Enabled = false
iconGui.Parent = CoreGui

local iconBtn = Instance.new("TextButton")
iconBtn.Size = UDim2.new(0, 70, 0, 70)
iconBtn.Position = UDim2.new(0, 20, 0.8, -35)
iconBtn.BackgroundColor3 = CONFIG.color1
iconBtn.Text = "⚡"
iconBtn.TextColor3 = Color3.new(1, 1, 1)
iconBtn.TextSize = 35
iconBtn.Font = Enum.Font.GothamBold
iconBtn.Parent = iconGui
Instance.new("UICorner", iconBtn).CornerRadius = UDim.new(1, 0)

-- Botões de tote flutuantes (quando minimizado)
local toteContainer = Instance.new("Frame")
toteContainer.Size = UDim2.new(0, 200, 0, 80)
toteContainer.Position = UDim2.new(1, -220, 0.8, -40)
toteContainer.BackgroundTransparency = 1
toteContainer.Parent = iconGui

local toteLeftFloat = Instance.new("TextButton")
toteLeftFloat.Size = UDim2.new(0, 90, 0, 70)
toteLeftFloat.Position = UDim2.new(0, 0, 0, 0)
toteLeftFloat.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
toteLeftFloat.BackgroundTransparency = 0.2
toteLeftFloat.Text = "⬅️"
toteLeftFloat.TextColor3 = Color3.new(1, 1, 1)
toteLeftFloat.TextSize = 40
toteLeftFloat.Font = Enum.Font.GothamBold
toteLeftFloat.Parent = toteContainer
Instance.new("UICorner", toteLeftFloat).CornerRadius = UDim.new(0, 15)

local toteRightFloat = Instance.new("TextButton")
toteRightFloat.Size = UDim2.new(0, 90, 0, 70)
toteRightFloat.Position = UDim2.new(1, -90, 0, 0)
toteRightFloat.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
toteRightFloat.BackgroundTransparency = 0.2
toteRightFloat.Text = "➡️"
toteRightFloat.TextColor3 = Color3.new(1, 1, 1)
toteRightFloat.TextSize = 40
toteRightFloat.Font = Enum.Font.GothamBold
toteRightFloat.Parent = toteContainer
Instance.new("UICorner", toteRightFloat).CornerRadius = UDim.new(0, 15)

-- Funções dos botões flutuantes
toteLeftFloat.MouseButton1Down:Connect(function()
    if not CONFIG.toteEnabled then return end
    executeTote("F")
    toteLeftFloat.BackgroundTransparency = 0
    task.wait(0.1)
    toteLeftFloat.BackgroundTransparency = 0.2
end)

toteRightFloat.MouseButton1Down:Connect(function()
    if not CONFIG.toteEnabled then return end
    executeTote("R")
    toteRightFloat.BackgroundTransparency = 0
    task.wait(0.1)
    toteRightFloat.BackgroundTransparency = 0.2
end)

-- Funções de minimizar/restaurar
local function minimize()
    gui.Enabled = false
    iconGui.Enabled = true
end

local function restore()
    gui.Enabled = true
    iconGui.Enabled = false
end

minimizeBtn.MouseButton1Click:Connect(minimize)
closeBtn.MouseButton1Click:Connect(minimize)
iconBtn.MouseButton1Click:Connect(restore)

-- Drag do ícone
local iconDragging = false
local iconDragStart, iconStartPos

iconBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        iconDragging = true
        iconDragStart = input.Position
        iconStartPos = iconBtn.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if iconDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                        input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - iconDragStart
        local newPos = UDim2.new(iconStartPos.X.Scale, iconStartPos.X.Offset + delta.X,
                                 iconStartPos.Y.Scale, iconStartPos.Y.Offset + delta.Y)
        iconBtn.Position = newPos
        toteContainer.Position = UDim2.new(newPos.X.Scale, newPos.X.Offset + 80, 
                                           newPos.Y.Scale, newPos.Y.Offset - 5)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        iconDragging = false
    end
end)

-- Drag da janela principal
local dragging = false
local dragStart, startPos

main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                    input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                  startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ============================================
-- LOOP PRINCIPAL
-- ============================================
RunService.RenderStepped:Connect(function()
    if player.Character and player.Character ~= char then
        char = player.Character
        hrp = char:WaitForChild("HumanoidRootPart")
    end
    
    updateSpheres()
    
    -- Processar reach normal
    if CONFIG.autoTouch and CONFIG.detectBalls then
        balls = getBalls()
        local now = tick()
        if now - lastTouch >= 0.05 then
            local hrpPos = hrp.Position
            for _, ball in ipairs(balls) do
                if ball and ball.Parent then
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

-- Tecla Insert para PC
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        if gui.Enabled then minimize() else restore() end
    elseif input.KeyCode == Enum.KeyCode.R and CONFIG.toteEnabled then
        executeTote("R")
    elseif input.KeyCode == Enum.KeyCode.F and CONFIG.toteEnabled then
        executeTote("F")
    end
end)

print("========================================")
print("CAFUXZ1 Hub v15.2 - Mobile Tote System")
print("========================================")
print("🎯 SISTEMA DE TOTE (Chute de Lado)")
print("⬅️ F = Tote Esquerda")
print("➡️ R = Tote Direita")
print("========================================")
print("Mobile: Botões na tela")
print("PC: Teclas R e F")
print("========================================")
