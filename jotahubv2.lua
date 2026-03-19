--[[
    CAFUXZ1 Hub v15.2 - Reach Fix Edition
    Lógica de reach do script original
]]

-- Esperar ambiente
task.wait(0.5)

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

-- Limpar GUIs antigas
for _, obj in ipairs(CoreGui:GetChildren()) do
    if obj.Name == "CAFUXZ1_Hub" or obj.Name == "CAFUXZ1_Icon" then
        obj:Destroy()
    end
end

for _, obj in ipairs(Workspace:GetChildren()) do
    if obj.Name == "CAFUXZ1_Sphere1" or obj.Name == "CAFUXZ1_Sphere2" then
        obj:Destroy()
    end
end

-- Configurações (AMBAS em 10 por padrão)
local CONFIG = {
    reach = 10,        -- Principal
    arthurReach = 10,  -- Arthur (igual)
    showSpheres = true,
    autoTouch = true,
    doubleTouch = true,
    color1 = Color3.fromRGB(99, 102, 241), -- Principal (Roxo)
    color2 = Color3.fromRGB(0, 255, 255),   -- Arthur (Cyan)
}

-- Esferas
local sphere1 = nil
local sphere2 = nil

-- Criar esferas
local function createSpheres()
    if sphere1 then sphere1:Destroy() end
    if sphere2 then sphere2:Destroy() end
    
    -- Esfera Principal
    sphere1 = Instance.new("Part")
    sphere1.Name = "CAFUXZ1_Sphere1"
    sphere1.Shape = Enum.PartType.Ball
    sphere1.Anchored = true
    sphere1.CanCollide = false
    sphere1.Material = Enum.Material.ForceField
    sphere1.Transparency = 0.88
    sphere1.Color = CONFIG.color1
    sphere1.Parent = Workspace
    
    -- Esfera Arthur (Double Touch)
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

-- Atualizar esferas (SEGUIR JOGADOR)
local function updateSpheres()
    if not sphere1 or not sphere2 then
        createSpheres()
    end
    
    -- Verificar se deve mostrar
    if not CONFIG.showSpheres then
        sphere1.Transparency = 1
        sphere2.Transparency = 1
        return
    end
    
    -- Atualizar posição e tamanho em tempo real
    if hrp and hrp.Parent then
        -- Esfera Principal
        sphere1.Position = hrp.Position
        sphere1.Size = Vector3.new(CONFIG.reach * 2, CONFIG.reach * 2, CONFIG.reach * 2)
        sphere1.Color = CONFIG.color1
        sphere1.Transparency = 0.88
        
        -- Esfera Arthur (só aparece se Double Touch ON)
        sphere2.Position = hrp.Position
        sphere2.Size = Vector3.new(CONFIG.arthurReach * 2, CONFIG.arthurReach * 2, CONFIG.arthurReach * 2)
        sphere2.Color = CONFIG.color2
        sphere2.Transparency = CONFIG.doubleTouch and 0.75 or 1
    end
end

-- ============================================
-- SISTEMA DE REACH (LÓGICA DO SCRIPT ANTIGO)
-- ============================================

-- Lista de nomes de bolas
local BallNames = { 
    "TPS", "TCS", "ESA", "MRS", "PRS", "MPS", "SSS", "AIFA", "RBZ",
    "Ball", "Soccer", "Football", "Basketball", "Baseball", 
    "BallTemplate", "GameBall", "Hitbox", "TouchPart", "GoalBall",
    "Physics", "Interaction", "Trigger", "Touch", "Hit", "Box",
    "Bola", "BALL", "SOCCER", "FOOTBALL", "SoccerBall"
}

-- Variáveis de controle
local balls = {}
local lastTouch = 0
local touchDebounce = {}

-- Encontrar bolas no workspace
local function getBalls()
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

-- Função de touch com debounce
local function doTouch(ball, part)
    if not ball or not ball.Parent or not part or not part.Parent then 
        return 
    end
    
    local key = ball.Name .. "_" .. part.Name .. "_" .. tostring(ball)
    if touchDebounce[key] and tick() - touchDebounce[key] < 0.1 then 
        return 
    end
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

-- Processar auto touch (LÓGICA CORRETA)
local function processReach()
    if not CONFIG.autoTouch then 
        return 
    end
    
    if not hrp or not hrp.Parent then 
        return 
    end
    
    local now = tick()
    if now - lastTouch < 0.05 then 
        return 
    end
    
    local hrpPos = hrp.Position
    local characterParts = {}
    
    -- Pegar todas as partes do character para tocar
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") then
            table.insert(characterParts, part)
        end
    end
    
    if #characterParts == 0 then 
        return 
    end
    
    -- Procurar bolas dentro do alcance
    balls = getBalls()
    
    for _, ball in ipairs(balls) do
        if ball and ball.Parent then
            local dist = (ball.Position - hrpPos).Magnitude
            
            -- Se a bola estiver dentro do alcance da esfera principal
            if dist <= CONFIG.reach then
                lastTouch = now
                
                -- Fazer touch em todas as partes do character
                for _, part in ipairs(characterParts) do
                    doTouch(ball, part)
                end
                
                break -- Só toca a bola mais próxima
            end
        end
    end
end

-- ============================================
-- GUI SIMPLES
-- ============================================
local gui = Instance.new("ScreenGui")
gui.Name = "CAFUXZ1_Hub"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 320, 0, 420)
main.Position = UDim2.new(0.5, -160, 0.5, -210)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
main.BorderSizePixel = 0
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -70, 0, 40)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "⚡ CAFUXZ1 Hub"
title.TextColor3 = CONFIG.color1
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

-- Info das esferas
local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, -20, 0, 25)
info.Position = UDim2.new(0, 10, 0, 35)
info.BackgroundTransparency = 1
info.Text = "🟣 Principal: " .. CONFIG.reach .. " | 🔵 Arthur: " .. CONFIG.arthurReach
info.TextColor3 = Color3.fromRGB(170, 170, 170)
info.TextSize = 12
info.Font = Enum.Font.Gotham
info.Parent = main

-- Botão Minimizar (-)
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -65, 0, 5)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(245, 158, 11)
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
minimizeBtn.TextSize = 24
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.Parent = main

Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 6)

-- Botão Fechar (X)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.TextSize = 20
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = main

Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

-- Container de botões
local container = Instance.new("Frame")
container.Size = UDim2.new(1, -20, 1, -110)
container.Position = UDim2.new(0, 10, 0, 65)
container.BackgroundTransparency = 1
container.Parent = main

local layout = Instance.new("UIListLayout", container)
layout.Padding = UDim.new(0, 10)

-- Função criar toggle
local function createToggle(text, default, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 45)
    btn.BackgroundColor3 = default and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(60, 60, 80)
    btn.Text = text .. ": " .. (default and "ON" or "OFF")
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 14
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
    frame.Size = UDim2.new(1, 0, 0, 70)
    frame.BackgroundTransparency = 1
    frame.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. default
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.Parent = frame
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, 0, 0, 40)
    input.Position = UDim2.new(0, 0, 0, 25)
    input.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    input.Text = tostring(default)
    input.TextColor3 = Color3.new(1, 1, 1)
    input.TextSize = 18
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
            -- Atualizar info
            info.Text = "🟣 Principal: " .. CONFIG.reach .. " | 🔵 Arthur: " .. CONFIG.arthurReach
        else
            input.Text = tostring(default)
        end
    end)
end

-- Criar controles
createToggle("Auto Touch", CONFIG.autoTouch, function(v)
    CONFIG.autoTouch = v
end)

createToggle("Mostrar Esferas", CONFIG.showSpheres, function(v)
    CONFIG.showSpheres = v
    updateSpheres()
end)

createToggle("Double Touch (Arthur)", CONFIG.doubleTouch, function(v)
    CONFIG.doubleTouch = v
    updateSpheres()
end)

createSlider("🟣 Alcance Principal", 1, 50, CONFIG.reach, function(v)
    CONFIG.reach = v
end)

createSlider("🔵 Alcance Arthur", 1, 50, CONFIG.arthurReach, function(v)
    CONFIG.arthurReach = v
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
iconBtn.Size = UDim2.new(0, 60, 0, 60)
iconBtn.Position = UDim2.new(0, 20, 0.5, -30)
iconBtn.BackgroundColor3 = CONFIG.color1
iconBtn.Text = "⚡"
iconBtn.TextColor3 = Color3.new(1, 1, 1)
iconBtn.TextSize = 30
iconBtn.Font = Enum.Font.GothamBold
iconBtn.Parent = iconGui

Instance.new("UICorner", iconBtn).CornerRadius = UDim.new(1, 0)

-- Label arraste
local dragLabel = Instance.new("TextLabel")
dragLabel.Size = UDim2.new(1, 0, 0, 15)
dragLabel.Position = UDim2.new(0, 0, 1, -5)
dragLabel.BackgroundTransparency = 1
dragLabel.Text = "Arraste"
dragLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
dragLabel.TextSize = 10
dragLabel.Font = Enum.Font.Gotham
dragLabel.Parent = iconBtn

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
        iconBtn.Position = UDim2.new(iconStartPos.X.Scale, iconStartPos.X.Offset + delta.X,
                                     iconStartPos.Y.Scale, iconStartPos.Y.Offset + delta.Y)
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
-- LOOP PRINCIPAL (ATUALIZAÇÃO DAS ESFERAS E REACH)
-- ============================================
RunService.RenderStepped:Connect(function()
    -- Atualizar character se mudou
    if player.Character and player.Character ~= char then
        char = player.Character
        hrp = char:WaitForChild("HumanoidRootPart")
    end
    
    -- Atualizar esferas em tempo real (SEGUEM O JOGADOR)
    updateSpheres()
    
    -- Processar reach (LÓGICA DO SCRIPT ANTIGO)
    processReach()
end)

-- Teclas de atalho
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        if gui.Enabled then
            minimize()
        else
            restore()
        end
    end
end)

print("========================================")
print("CAFUXZ1 Hub v15.2 - Reach Fix")
print("========================================")
print("🟣 Esfera Principal: " .. CONFIG.reach)
print("🔵 Esfera Arthur: " .. CONFIG.arthurReach)
print("========================================")
print("Reach funcionando com lógica original!")
print("========================================")
