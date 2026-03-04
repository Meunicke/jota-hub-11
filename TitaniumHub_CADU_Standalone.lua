--[[
    Zyronis Hub v10.0 - Ball Reach Edition
    ============================================
    
    CRIADORES:
    - Bazuka: Reconstrução total, integração CADUXX137
    - Cafuxz1: Contribuições e melhorias
    - CADUXX137: Sistema de Ball Reach original (lógica de detecção de bolas)
    
    AGRADECIMENTOS:
    - Zyronis: Interface WindUI (emprestada para este projeto)
    
    DESCRIÇÃO:
    Script híbrido combinando a interface moderna do Zyronis Hub
    com o sistema avançado de Ball Reach do CADUXX137.
    Remove todas as ferramentas do Brookhaven, mantendo apenas
    a funcionalidade de detecção e interação com bolas.
    
    FEATURES:
    - Detecção automática de bolas (TPS, TCS, Soccer, etc.)
    - Reach sphere visual configurável
    - Auto-touch com suporte a full body
    - Auto-skills para botões de futebol
    - Interface premium com ícone flutuante
]]

if not game:IsLoaded() then game.Loaded:Wait() end

-- ============================================
-- SERVIÇOS
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Character = nil
local Humanoid = nil
local RootPart = nil
local Camera = Workspace.CurrentCamera

-- ============================================
-- CONFIGURAÇÕES CADUXX137 (SISTEMA BALL REACH)
-- ============================================
local CONFIG = {
    reach = 15,
    showReachSphere = true,
    autoTouch = true,
    fullBodyTouch = true,
    autoSecondTouch = true,
    scanCooldown = 1.5,
    scale = 1.0,
    
    -- IDs das imagens (Bazuka)
    iconImage = "rbxassetid://104616032736993",
    iconBackground = "rbxassetid://96755648876012",
    
    -- Lista de nomes de bolas (CADUXX137)
    ballNames = { 
        "TPS", "TCS", "ESA", "MRS", "PRS", "MPS", "SSS", "AIFA", "RBZ",
        "Ball", "Soccer", "Football", "Basketball", "Baseball", 
        "BallTemplate", "GameBall", "Hitbox", "TouchPart", "GoalBall",
        "SoccerBall", "BallReach", "TouchBall", "GameBallTemplate",
        " bola", "Bola", "BALL", "SOCCER", "FOOTBALL"
    },
    
    -- Cores (paleta CADUXX137)
    accentColor = Color3.fromRGB(0, 180, 255),
    accentSecondary = Color3.fromRGB(138, 43, 226),
    successColor = Color3.fromRGB(0, 255, 128),
    dangerColor = Color3.fromRGB(255, 50, 100),
    warningColor = Color3.fromRGB(255, 200, 0),
    bgColor = Color3.fromRGB(10, 10, 15),
    bgLight = Color3.fromRGB(25, 25, 35),
    bgCard = Color3.fromRGB(35, 35, 50),
    textColor = Color3.fromRGB(255, 255, 255),
    textDark = Color3.fromRGB(150, 160, 180)
}

-- ============================================
-- VARIÁVEIS DE ESTADO
-- ============================================
local balls = {}
local ballConnections = {}
local reachSphere = nil
local touchDebounce = {}
local lastBallUpdate = 0
local lastTouch = 0
local autoSkills = true
local lastSkillActivation = 0
local skillCooldown = 0.5
local activatedSkills = {}

-- ============================================
-- FUNÇÕES UTILITÁRIAS (Bazuka + CADUXX137)
-- ============================================
local function notify(title, text, duration)
    duration = duration or 3
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "⚡ Zyronis Hub",
            Text = text or "",
            Duration = duration
        })
    end)
end

local function tween(obj, props, time, style, dir)
    time = time or 0.3
    style = style or Enum.EasingStyle.Quint
    dir = dir or Enum.EasingDirection.Out
    local t = TweenService:Create(obj, TweenInfo.new(time, style, dir), props)
    t:Play()
    return t
end

-- ============================================
-- SISTEMA DE DETECÇÃO DE BOLAS (CADUXX137)
-- ============================================
local function findBalls()
    local now = tick()
    if now - lastBallUpdate < CONFIG.scanCooldown then return #balls end
    lastBallUpdate = now
    
    table.clear(balls)
    for _, conn in ipairs(ballConnections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(ballConnections)
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Parent then
            for _, name in ipairs(CONFIG.ballNames) do
                if obj.Name == name or obj.Name:find(name) then
                    table.insert(balls, obj)
                    local conn = obj.AncestryChanged:Connect(function()
                        if not obj.Parent then findBalls() end
                    end)
                    table.insert(ballConnections, conn)
                    break
                end
            end
        end
    end
    
    return #balls
end

local function updateCharacter()
    local newChar = LocalPlayer.Character
    if newChar ~= Character then
        Character = newChar
        if Character then
            Humanoid = Character:WaitForChild("Humanoid", 2)
            RootPart = Character:WaitForChild("HumanoidRootPart", 2)
            if RootPart then
                notify("Sistema Ativo", "Ball Reach inicializado!", 2)
            end
        else
            Humanoid = nil
            RootPart = nil
        end
    end
end

local function getBodyParts()
    if not Character then return {} end
    local parts = {}
    for _, part in ipairs(Character:GetChildren()) do
        if part:IsA("BasePart") then
            if CONFIG.fullBodyTouch then
                table.insert(parts, part)
            elseif part.Name == "HumanoidRootPart" then
                table.insert(parts, part)
            end
        end
    end
    return parts
end

local function updateSphere()
    if not CONFIG.showReachSphere then
        if reachSphere then 
            reachSphere:Destroy() 
            reachSphere = nil 
        end
        return
    end
    
    if not reachSphere or not reachSphere.Parent then
        reachSphere = Instance.new("Part")
        reachSphere.Name = "CADU_ReachSphere"
        reachSphere.Shape = Enum.PartType.Ball
        reachSphere.Anchored = true
        reachSphere.CanCollide = false
        reachSphere.Transparency = 0.88
        reachSphere.Material = Enum.Material.ForceField
        reachSphere.Color = CONFIG.accentColor
        reachSphere.Parent = Workspace
    end
    
    if RootPart and RootPart.Parent then
        reachSphere.Position = RootPart.Position
        reachSphere.Size = Vector3.new(CONFIG.reach * 2, CONFIG.reach * 2, CONFIG.reach * 2)
    end
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
        
        if CONFIG.autoSecondTouch then
            task.wait(0.05)
            firetouchinterest(ball, part, 0)
            firetouchinterest(ball, part, 1)
        end
    end)
end

-- ============================================
-- SISTEMA DE AUTO-SKILLS (CADUXX137)
-- ============================================
local skillButtonNames = {
    "Shoot", "Pass", "Long", "Tackle", "Dribble", "GK", "Throw",
    "Control", "Left", "Right", "High", "Low", "Rainbow",
    "Chip", "Heel", "Volley", "Back Right", "Back Left",
    "Carry", "Fake Shot", "Drag Back", "Header", "Bicycle",
    "Shot", "Slide", "Goalkeeper", "Catch", "Punch",
    "Short Pass", "Through Ball", "Cross", "Curve",
    "Power Shot", "Precision", "First Touch", "Chute", "Passe"
}

local function findSkillButtons()
    local buttons = {}
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            for _, obj in ipairs(gui:GetDescendants()) do
                if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                    for _, skillName in ipairs(skillButtonNames) do
                        if obj.Name == skillName or obj.Text == skillName or 
                           (obj.Name:lower():find(skillName:lower()) and #obj.Name < 30) then
                            table.insert(buttons, obj)
                            break
                        end
                    end
                end
            end
        end
    end
    
    return buttons
end

local function activateSkillButton(button)
    if not button or not button.Parent then return end
    
    local key = tostring(button)
    if activatedSkills[key] and tick() - activatedSkills[key] < skillCooldown then 
        return 
    end
    activatedSkills[key] = tick()
    
    pcall(function()
        if button:IsA("GuiButton") then
            for _, conn in ipairs(getconnections(button.MouseButton1Click)) do
                conn:Fire()
            end
            for _, conn in ipairs(getconnections(button.Activated)) do
                conn:Fire()
            end
            
            local originalSize = button.Size
            tween(button, {Size = UDim2.new(originalSize.X.Scale * 0.95, originalSize.X.Offset * 0.95, 
                                           originalSize.Y.Scale * 0.95, originalSize.Y.Offset * 0.95)}, 0.05)
            task.delay(0.05, function()
                if button and button.Parent then
                    tween(button, {Size = originalSize}, 0.05)
                end
            end)
        end
    end)
end

-- ============================================
-- INTERFACE WINDUI (Zyronis Hub - Emprestada)
-- ============================================
local Libary = loadstring(game:HttpGet("https://raw.githubusercontent.com/BRENOPOOF/slapola/refs/heads/main/Main.txt"))()
Workspace.FallenPartsDestroyHeight = -math.huge

local Window = Libary:MakeWindow({
    Title = "Zyronis Hub",
    SubTitle = "v10.0 Ball Reach | by Bazuka & Cafuxz1",
    LoadText = "Carregando Sistema CADUXX137...",
    Flags = "ZyronisHub_BallReach"
})

Window:AddMinimizeButton({
    Button = {
        Image = CONFIG.iconImage,
        BackgroundTransparency = 0,
        Size = UDim2.new(0, 45, 0, 45),
    },
    Corner = {
        CornerRadius = UDim.new(0, 100),
    },
})

-- ============================================
-- ABA INFO (Créditos Oficiais)
-- ============================================
local InfoTab = Window:MakeTab({ Title = "Info", Icon = "rbxassetid://15309138473" })

InfoTab:AddSection({ "Créditos Oficiais" })
InfoTab:AddParagraph({ "Criadores:", "Bazuka & Cafuxz1" })
InfoTab:AddParagraph({ "Sistema Ball Reach:", "CADUXX137 v9.0" })
InfoTab:AddParagraph({ "Interface:", "Zyronis Hub (WindUI)" })
InfoTab:AddParagraph({ "Agradecimentos:", "Zyronis pela UI" })

InfoTab:AddSection({ "Sobre" })
InfoTab:AddParagraph({ "Versão:", "v10.0 Ball Reach Edition" })
InfoTab:AddParagraph({ "Descrição:", "Script focado em detecção e interação automática com bolas em jogos de futebol/soccer do Roblox" })
InfoTab:AddParagraph({ "Status:", "Sistema Ativo" })

-- ============================================
-- ABA BALL REACH (CORE DO CADUXX137)
-- ============================================
local BallTab = Window:MakeTab({ Title = "Ball Reach", Icon = "rbxassetid://104616032736993" })

BallTab:AddSection({ "⚡ Configurações de Alcance" })

BallTab:AddSlider({
    Name = "Alcance (Reach)",
    Min = 1,
    Max = 50,
    Default = 15,
    Color = Color3.fromRGB(0, 180, 255),
    Increment = 1,
    ValueName = "studs",
    Callback = function(Value)
        CONFIG.reach = Value
        notify("Ball Reach", "Alcance: " .. Value .. " studs", 1)
    end
})

BallTab:AddToggle({
    Name = "Mostrar Esfera Visual",
    Default = true,
    Callback = function(value)
        CONFIG.showReachSphere = value
        notify("Visual", value and "Esfera ativada" or "Esfera desativada", 2)
    end
})

BallTab:AddToggle({
    Name = "Auto Touch (Interação Automática)",
    Default = true,
    Callback = function(value)
        CONFIG.autoTouch = value
        notify("Auto Touch", value and "Ativado" or "Desativado", 2)
    end
})

BallTab:AddToggle({
    Name = "Full Body Touch",
    Default = true,
    Callback = function(value)
        CONFIG.fullBodyTouch = value
        notify("Full Body", value and "Ativado" or "Desativado", 2)
    end
})

BallTab:AddToggle({
    Name = "Double Touch (Toque Duplo)",
    Default = true,
    Callback = function(value)
        CONFIG.autoSecondTouch = value
        notify("Double Touch", value and "Ativado" or "Desativado", 2)
    end
})

BallTab:AddSection({ "🎮 Sistema de Skills" })

BallTab:AddToggle({
    Name = "Auto Skills (Botões de Futebol)",
    Default = true,
    Callback = function(value)
        autoSkills = value
        notify("Auto Skills", value and "Ativado" or "Desativado", 2)
    end
})

BallTab:AddParagraph({ "Skills Detectadas:", "Shoot, Pass, Dribble, Control, Tackle, etc." })

BallTab:AddSection({ "📊 Status do Sistema" })

local statusLabel = BallTab:AddParagraph({ "Bolas Detectadas:", "0" })
local reachLabel = BallTab:AddParagraph({ "Alcance Atual:", tostring(CONFIG.reach) .. " studs" })

-- Atualizador automático
task.spawn(function()
    while true do
        task.wait(1)
        local count = findBalls()
        pcall(function()
            statusLabel:Set("Bolas Detectadas: " .. count)
            reachLabel:Set("Alcance Atual: " .. CONFIG.reach .. " studs")
        end)
    end
end)

-- ============================================
-- ABA CONFIGURAÇÕES (Bazuka & Cafuxz1)
-- ============================================
local ConfigTab = Window:MakeTab({ Title = "Config", Icon = "rbxassetid://11322093465" })

ConfigTab:AddSection({ "⚙️ Ajustes Gerais" })

ConfigTab:AddSlider({
    Name = "Escala da Interface",
    Min = 0.5,
    Max = 2.0,
    Default = 1.0,
    Increment = 0.1,
    ValueName = "x",
    Callback = function(Value)
        CONFIG.scale = Value
        notify("Config", "Escala: " .. Value .. "x (reinicie para aplicar)", 3)
    end
})

ConfigTab:AddSlider({
    Name = "Cooldown de Scan",
    Min = 0.5,
    Max = 5.0,
    Default = 1.5,
    Increment = 0.1,
    ValueName = "s",
    Callback = function(Value)
        CONFIG.scanCooldown = Value
    end
})

ConfigTab:AddSection({ "🎨 Personalização" })

ConfigTab:AddColorPicker({
    Name = "Cor Principal",
    Default = CONFIG.accentColor,
    Callback = function(Value)
        CONFIG.accentColor = Value
        if reachSphere then reachSphere.Color = Value end
    end
})

ConfigTab:AddSection({ "🔧 Debug" })

ConfigTab:AddButton({
    Name = "Forçar Atualização de Bolas",
    Callback = function()
        local count = findBalls()
        notify("Debug", "Bolas encontradas: " .. count, 2)
    end
})

ConfigTab:AddButton({
    Name = "Limpar Cache de Touch",
    Callback = function()
        table.clear(touchDebounce)
        notify("Debug", "Cache limpo!", 1)
    end
})

-- ============================================
-- LOOP PRINCIPAL (CADUXX137 - Mantido Puro)
-- ============================================
RunService.Heartbeat:Connect(function()
    updateCharacter()
    updateSphere()
    findBalls()
    
    if not RootPart then return end
    if not CONFIG.autoTouch then return end
    
    local now = tick()
    if now - lastTouch < 0.05 then return end
    
    local hrpPos = RootPart.Position
    local characterParts = getBodyParts()
    if #characterParts == 0 then return end
    
    local closestBall = nil
    local closestDistance = CONFIG.reach
    
    for _, ball in ipairs(balls) do
        if ball and ball.Parent then
            local distance = (ball.Position - hrpPos).Magnitude
            if distance <= CONFIG.reach and distance < closestDistance then
                closestDistance = distance
                closestBall = ball
            end
        end
    end
    
    if closestBall then
        lastTouch = now
        for _, part in ipairs(characterParts) do
            doTouch(closestBall, part)
        end
    end
    
    -- Auto Skills
    if autoSkills and closestBall and (now - lastSkillActivation > skillCooldown) then
        lastSkillActivation = now
        local skillButtons = findSkillButtons()
        local mainSkills = {"Shoot", "Pass", "Dribble", "Control", "Chute", "Passe"}
        
        for _, button in ipairs(skillButtons) do
            for _, mainSkill in ipairs(mainSkills) do
                if button.Name == mainSkill or button.Text == mainSkill then
                    activateSkillButton(button)
                    break
                end
            end
        end
    end
end)

-- ============================================
-- INICIALIZAÇÃO (Bazuka & Cafuxz1)
-- ============================================
notify("⚡ Zyronis Hub v10.0", "Ball Reach by Bazuka & Cafuxz1", 4)
notify("Sistema CADUXX137", "Detecção de bolas ativa!", 3)

print("========================================")
print("  ZYRIONIS HUB v10.0 - BALL REACH")
print("========================================")
print("Criadores: Bazuka & Cafuxz1")
print("Sistema Ball Reach: CADUXX137")
print("Interface: Zyronis Hub (WindUI)")
print("----------------------------------------")
print("Reach: " .. CONFIG.reach .. " studs")
print("Auto Touch: " .. tostring(CONFIG.autoTouch))
print("Auto Skills: " .. tostring(autoSkills))
print("Full Body: " .. tostring(CONFIG.fullBodyTouch))
print("========================================")
