--[[
    CAFUXZ1 Hub v15.2 - Simple Edition
    WindUI + Double Sphere
]]

-- Esperar ambiente
task.wait(0.5)

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

-- Limpar GUIs antigas
for _, obj in ipairs(CoreGui:GetChildren()) do
    if obj.Name == "CAFUXZ1_Hub" then
        obj:Destroy()
    end
end

for _, obj in ipairs(Workspace:GetChildren()) do
    if obj.Name == "CAFUXZ1_Sphere1" or obj.Name == "CAFUXZ1_Sphere2" then
        obj:Destroy()
    end
end

-- Configurações
local CONFIG = {
    reach = 15,
    arthurReach = 10,
    showSpheres = true,
    autoTouch = true,
    doubleTouch = true,
    color1 = Color3.fromRGB(99, 102, 241), -- Principal
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

-- Atualizar esferas
local function updateSpheres()
    if not CONFIG.showSpheres then
        if sphere1 then sphere1.Transparency = 1 end
        if sphere2 then sphere2.Transparency = 1 end
        return
    end
    
    if not sphere1 or not sphere2 then
        createSpheres()
    end
    
    if hrp and hrp.Parent then
        sphere1.Position = hrp.Position
        sphere1.Size = Vector3.new(CONFIG.reach * 2, CONFIG.reach * 2, CONFIG.reach * 2)
        sphere1.Color = CONFIG.color1
        sphere1.Transparency = 0.88
        
        sphere2.Position = hrp.Position
        sphere2.Size = Vector3.new(CONFIG.arthurReach * 2, CONFIG.arthurReach * 2, CONFIG.arthurReach * 2)
        sphere2.Color = CONFIG.color2
        sphere2.Transparency = CONFIG.doubleTouch and 0.75 or 1
    end
end

-- Auto Touch
local balls = {}
local lastTouch = 0

local function findBalls()
    balls = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = obj.Name
            if name == "TPS" or name == "TCS" or name == "MPS" or name == "PRS" or 
               name == "Ball" or name == "Soccer" or name:find("Ball") then
                table.insert(balls, obj)
            end
        end
    end
end

local function doTouch(ball)
    if not CONFIG.autoTouch then return end
    local now = tick()
    if now - lastTouch < 0.05 then return end
    
    local dist = (ball.Position - hrp.Position).Magnitude
    if dist <= CONFIG.reach then
        lastTouch = now
        pcall(function()
            firetouchinterest(ball, hrp, 0)
            task.wait(0.01)
            firetouchinterest(ball, hrp, 1)
            
            if CONFIG.doubleTouch then
                task.wait(0.05)
                firetouchinterest(ball, hrp, 0)
                firetouchinterest(ball, hrp, 1)
            end
        end)
    end
end

-- WindUI Simples
local gui = Instance.new("ScreenGui")
gui.Name = "CAFUXZ1_Hub"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 300, 0, 400)
main.Position = UDim2.new(0.5, -150, 0.5, -200)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
main.BorderSizePixel = 0
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "⚡ CAFUXZ1 Hub v15.2"
title.TextColor3 = CONFIG.color1
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.Parent = main

-- Container de botões
local container = Instance.new("Frame")
container.Size = UDim2.new(1, -20, 1, -50)
container.Position = UDim2.new(0, 10, 0, 45)
container.BackgroundTransparency = 1
container.Parent = main

local layout = Instance.new("UIListLayout", container)
layout.Padding = UDim.new(0, 10)

-- Função criar toggle
local function createToggle(text, default, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
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

-- Função criar slider (simplificado)
local function createSlider(text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 60)
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
    input.Size = UDim2.new(1, 0, 0, 35)
    input.Position = UDim2.new(0, 0, 0, 25)
    input.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    input.Text = tostring(default)
    input.TextColor3 = Color3.new(1, 1, 1)
    input.TextSize = 16
    input.Font = Enum.Font.GothamBold
    input.Parent = frame
    
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 6)
    
    input.FocusLost:Connect(function()
        local num = tonumber(input.Text)
        if num then
            num = math.clamp(math.floor(num), min, max)
            input.Text = tostring(num)
            label.Text = text .. ": " .. num
            callback(num)
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

createSlider("Alcance Principal", 5, 100, CONFIG.reach, function(v)
    CONFIG.reach = v
end)

createSlider("Alcance Arthur", 1, 150, CONFIG.arthurReach, function(v)
    CONFIG.arthurReach = v
end)

-- Botão fechar
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = main

Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

closeBtn.MouseButton1Click:Connect(function()
    gui.Enabled = false
end)

-- Drag
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

-- Loop principal
RunService.Heartbeat:Connect(function()
    -- Atualizar character se mudou
    if player.Character and player.Character ~= char then
        char = player.Character
        hrp = char:WaitForChild("HumanoidRootPart")
    end
    
    -- Atualizar esferas
    updateSpheres()
    
    -- Procurar e tocar bolas
    findBalls()
    for _, ball in ipairs(balls) do
        if ball and ball.Parent then
            doTouch(ball)
        end
    end
end)

-- Insert para mostrar/esconder
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        gui.Enabled = not gui.Enabled
    end
end)

print("CAFUXZ1 Hub v15.2 - Simple WindUI Loaded!")
print("F1: Auto Touch | F2: Esferas | F3: Double Touch | Insert: Menu")
