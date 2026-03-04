--[[
    Zyronis Hub v10.0 - Enhanced Edition
    Combinando: Interface WindUI (Zyronis) + Sistema CADUXX137 (Ball Reach)
    
    Créditos:
    - Interface: Zyronis Hub (WindUI Library)
    - Lógica Ball Reach: CADUXX137 v9.0
    - Reconstruído por: Bazuka (com melhorias)
    
    Features:
    - Sistema de detecção de bolas avançado
    - Auto-touch com reach sphere
    - Auto-skills para botões de futebol
    - Interface moderna com ícone flutuante
    - Proteções anti-fling
    - Troll features (Couch Kill, Bus Kill, etc.)
]]

if not game:IsLoaded() then game.Loaded:Wait() end

-- ============================================
-- SERVIÇOS E VARIÁVEIS GLOBAIS
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local Character = nil
local Humanoid = nil
local RootPart = nil
local Camera = Workspace.CurrentCamera

-- Variáveis CADUXX137
local CONFIG = {
    reach = 15,
    showReachSphere = true,
    autoTouch = true,
    fullBodyTouch = true,
    autoSecondTouch = true,
    scanCooldown = 1.5,
    scale = 1.0,
    
    -- IDs das imagens (sua)
    iconImage = "rbxassetid://104616032736993",
    iconBackground = "rbxassetid://96755648876012",
    
    -- Lista de nomes de bolas (expandida)
    ballNames = { 
        "TPS", "TCS", "ESA", "MRS", "PRS", "MPS", "SSS", "AIFA", "RBZ",
        "Ball", "Soccer", "Football", "Basketball", "Baseball", 
        "BallTemplate", "GameBall", "Hitbox", "TouchPart", "GoalBall",
        "SoccerBall", "BallReach", "TouchBall", "GameBallTemplate"
    },
    
    -- Cores
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

-- Estado global
local balls = {}
local ballConnections = {}
local reachSphere = nil
local touchDebounce = {}
local lastBallUpdate = 0
local lastTouch = 0
local isMinimized = false
local iconGui = nil
local autoSkills = true
local lastSkillActivation = 0
local skillCooldown = 0.5
local activatedSkills = {}

-- Variáveis Zyronis Hub
local selectedPlayerName = nil
local methodKill = nil
getgenv().Target = nil

-- ============================================
-- FUNÇÕES UTILITÁRIAS
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
    
    -- Limpar lista anterior
    table.clear(balls)
    for _, conn in ipairs(ballConnections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(ballConnections)
    
    -- Buscar novas bolas
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Parent then
            for _, name in ipairs(CONFIG.ballNames) do
                if obj.Name == name or obj.Name:find(name) then
                    table.insert(balls, obj)
                    -- Conectar evento para atualizar quando destruída
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
                notify("Personagem Detectado", "Sistema de reach ativo!", 2)
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
    "Power Shot", "Precision", "First Touch"
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
            -- Simular clique
            for _, conn in ipairs(getconnections(button.MouseButton1Click)) do
                conn:Fire()
            end
            for _, conn in ipairs(getconnections(button.Activated)) do
                conn:Fire()
            end
            
            -- Efeito visual
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
-- INTERFACE WINDUI (Zyronis Hub)
-- ============================================
local Libary = loadstring(game:HttpGet("https://raw.githubusercontent.com/BRENOPOOF/slapola/refs/heads/main/Main.txt"))()
Workspace.FallenPartsDestroyHeight = -math.huge

local Window = Libary:MakeWindow({
    Title = "Zyronis Hub",
    SubTitle = "v10.0 | CADUXX137 Integration",
    LoadText = "Carregando Sistema Híbrido...",
    Flags = "ZyronisHub_v10"
})

Window:AddMinimizeButton({
    Button = {
        Image = CONFIG.iconImage,
        BackgroundTransparency = 0,
        Size = UDim2.new(0, 40, 0, 40),
    },
    Corner = {
        CornerRadius = UDim.new(0, 100),
    },
})

-- ============================================
-- ABA INFO
-- ============================================
local InfoTab = Window:MakeTab({ Title = "Info", Icon = "rbxassetid://15309138473" })

InfoTab:AddSection({ "Informações do Script" })
InfoTab:AddParagraph({ "Owner / Developer:", "Zyronis" })
InfoTab:AddParagraph({ "Ball System:", "CADUXX137 v9.0" })
InfoTab:AddParagraph({ "UI Library:", "WindUI + Slapola" })
InfoTab:AddParagraph({ "Status:", "Sistema Híbrido Ativo" })

InfoTab:AddSection({ "Rejoin" })
InfoTab:AddButton({
    Name = "Rejoin Server",
    Callback = function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end
})

-- ============================================
-- ABA BALL REACH (NOVA - CADUXX137)
-- ============================================
local BallTab = Window:MakeTab({ Title = "Ball Reach", Icon = "rbxassetid://104616032736993" })

BallTab:AddSection({ "⚡ Configurações de Alcance" })

-- Slider de Reach
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

-- Toggles
BallTab:AddToggle({
    Name = "Mostrar Esfera",
    Default = true,
    Callback = function(value)
        CONFIG.showReachSphere = value
    end
})

BallTab:AddToggle({
    Name = "Auto Touch",
    Default = true,
    Callback = function(value)
        CONFIG.autoTouch = value
    end
})

BallTab:AddToggle({
    Name = "Full Body Touch",
    Default = true,
    Callback = function(value)
        CONFIG.fullBodyTouch = value
    end
})

BallTab:AddToggle({
    Name = "Double Touch",
    Default = true,
    Callback = function(value)
        CONFIG.autoSecondTouch = value
    end
})

BallTab:AddToggle({
    Name = "Auto Skills (Futebol)",
    Default = true,
    Callback = function(value)
        autoSkills = value
    end
})

BallTab:AddSection({ "📊 Status" })

local statusLabel = BallTab:AddParagraph({ "Bolas Detectadas:", "0" })

-- Atualizar contador
task.spawn(function()
    while true do
        task.wait(1)
        local count = findBalls()
        pcall(function()
            statusLabel:Set("Bolas Detectadas: " .. count)
        end)
    end
end)

-- ============================================
-- ABA TROLL PLAYERS (Zyronis Original)
-- ============================================
local Troll = Window:MakeTab({ Title = "Troll Players", Icon = "skull" })

-- Funções de cleanup
local function cleanupCouch()
    local char = LocalPlayer.Character
    if char then
        local couch = char:FindFirstChild("Zyronis.Couch") or LocalPlayer.Backpack:FindFirstChild("Zyronis.Couch")
        if couch then couch:Destroy() end
    end
    ReplicatedStorage:WaitForChild("RE"):WaitForChild("1Clea1rTool1s"):FireServer("ClearAllTools")
end

-- Evento CharacterAdded
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = newCharacter:WaitForChild("Humanoid")
    RootPart = newCharacter:WaitForChild("HumanoidRootPart")
    cleanupCouch()
    
    Humanoid.Died:Connect(function()
        cleanupCouch()
    end)
end)

-- Kill Player Couch (Original Zyronis)
local function KillPlayerCouch()
    if not selectedPlayerName then
        warn("Erro: Nenhum jogador selecionado")
        return
    end
    local target = Players:FindFirstChild(selectedPlayerName)
    if not target or not target.Character then return end

    local char = LocalPlayer.Character
    if not char then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    local tRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if not hum or not root or not tRoot then return end

    local originalPos = root.Position 
    local sitPos = Vector3.new(145.51, -350.09, 21.58)

    ReplicatedStorage:WaitForChild("RE"):WaitForChild("1Clea1rTool1s"):FireServer("ClearAllTools")
    task.wait(0.2)

    ReplicatedStorage.RE:FindFirstChild("1Too1l"):InvokeServer("PickingTools", "Couch")
    task.wait(0.3)

    local tool = LocalPlayer.Backpack:FindFirstChild("Couch")
    if tool then tool.Parent = char end
    task.wait(0.1)

    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
    task.wait(0.1)

    hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
    hum.PlatformStand = false
    Camera.CameraSubject = target.Character:FindFirstChild("Head") or tRoot or hum

    local align = Instance.new("BodyPosition")
    align.Name = "BringPosition"
    align.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    align.D = 10
    align.P = 30000
    align.Position = root.Position
    align.Parent = tRoot

    task.spawn(function()
        local angle = 0
        local startTime = tick()
        while tick() - startTime < 5 and target and target.Character and target.Character:FindFirstChildOfClass("Humanoid") do
            local tHum = target.Character:FindFirstChildOfClass("Humanoid")
            if not tHum or tHum.Sit then break end

            local hrp = target.Character.HumanoidRootPart
            local adjustedPos = hrp.Position + (hrp.Velocity / 1.5)

            angle += 50
            root.CFrame = CFrame.new(adjustedPos + Vector3.new(0, 2, 0)) * CFrame.Angles(math.rad(angle), 0, 0)
            align.Position = root.Position + Vector3.new(2, 0, 0)

            task.wait()
        end

        align:Destroy()
        hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        hum.PlatformStand = false
        Camera.CameraSubject = hum

        for _, p in pairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                p.Velocity = Vector3.zero
                p.RotVelocity = Vector3.zero
            end
        end

        task.wait(0.1)
        root.CFrame = CFrame.new(sitPos)
        task.wait(0.3)

        local tool = char:FindFirstChild("Couch")
        if tool then tool.Parent = LocalPlayer.Backpack end

        task.wait(0.01)
        ReplicatedStorage.RE:FindFirstChild("1Too1l"):InvokeServer("PickingTools", "Couch")
        task.wait(0.2)
        root.CFrame = CFrame.new(originalPos)
    end)
end

-- Bring Player LLL
local function BringPlayerLLL()
    if not selectedPlayerName then return end
    local target = Players:FindFirstChild(selectedPlayerName)
    if not target or not target.Character then return end

    local char = LocalPlayer.Character
    if not char then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    local tRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if not hum or not root or not tRoot then return end

    local originalPos = root.Position 
    ReplicatedStorage:WaitForChild("RE"):WaitForChild("1Clea1rTool1s"):FireServer("ClearAllTools")
    task.wait(0.2)

    ReplicatedStorage.RE:FindFirstChild("1Too1l"):InvokeServer("PickingTools", "Couch")
    task.wait(0.3)

    local tool = LocalPlayer.Backpack:FindFirstChild("Couch")
    if tool then tool.Parent = char end
    task.wait(0.1)

    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
    task.wait(0.1)

    hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
    hum.PlatformStand = false
    Camera.CameraSubject = target.Character:FindFirstChild("Head") or tRoot or hum

    local align = Instance.new("BodyPosition")
    align.Name = "BringPosition"
    align.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    align.D = 10
    align.P = 30000
    align.Position = root.Position
    align.Parent = tRoot

    task.spawn(function()
        local angle = 0
        local startTime = tick()
        while tick() - startTime < 5 and target and target.Character do
            local tHum = target.Character:FindFirstChildOfClass("Humanoid")
            if not tHum or tHum.Sit then break end

            local hrp = target.Character.HumanoidRootPart
            local adjustedPos = hrp.Position + (hrp.Velocity / 1.5)

            angle += 50
            root.CFrame = CFrame.new(adjustedPos + Vector3.new(0, 2, 0)) * CFrame.Angles(math.rad(angle), 0, 0)
            align.Position = root.Position + Vector3.new(2, 0, 0)

            task.wait()
        end

        align:Destroy()
        hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        hum.PlatformStand = false
        Camera.CameraSubject = hum

        for _, p in pairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                p.Velocity = Vector3.zero
                p.RotVelocity = Vector3.zero
            end
        end

        task.wait(0.1)
        root.Anchored = true
        root.CFrame = CFrame.new(originalPos)
        task.wait(0.001)
        root.Anchored = false

        task.wait(0.7)
        local tool = char:FindFirstChild("Couch")
        if tool then tool.Parent = LocalPlayer.Backpack end

        task.wait(0.001)
        ReplicatedStorage.RE:FindFirstChild("1Too1l"):InvokeServer("PickingTools", "Couch")
    end)
end

-- Interface Troll
local PlayerSection = Troll:AddSection({ Name = "Troll Player" })

local function getPlayerList()
    local playerNames = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(playerNames, player.Name)
        end
    end
    return playerNames
end

local killDropdown = Troll:AddDropdown({
    Name = "Selecionar Jogador",
    Options = getPlayerList(),
    Default = "",
    Callback = function(value)
        selectedPlayerName = value
        getgenv().Target = value
    end
})

Troll:AddButton({
    Name = "Atualizar Player List",
    Callback = function()
        local newPlayers = {}
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Name ~= LocalPlayer.Name then
                table.insert(newPlayers, player.Name)
            end
        end
        killDropdown:Set(newPlayers)
    end
})

Troll:AddButton({
    Name = "Teleportar até o Player",
    Callback = function()
        if not selectedPlayerName then return end
        local target = Players:FindFirstChild(selectedPlayerName)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            if RootPart then
                RootPart.CFrame = target.Character.HumanoidRootPart.CFrame
            end
        end
    end
})

Troll:AddToggle({
    Name = "Spectar Player",
    Default = false,
    Callback = function(value)
        if value then
            local target = Players:FindFirstChild(selectedPlayerName)
            if target and target.Character then
                local humanoid = target.Character:FindFirstChild("Humanoid")
                if humanoid then
                    Camera.CameraSubject = humanoid
                end
            end
        else
            if Character then
                local humanoid = Character:FindFirstChild("Humanoid")
                if humanoid then
                    Camera.CameraSubject = humanoid
                end
            end
        end
    end
})

local MethodSection = Troll:AddSection({ Name = "Métodos" })

Troll:AddDropdown({
    Name = "Selecionar Método",
    Options = {"Bus", "Couch", "Couch Sem ir até o alvo [BETA]"},
    Default = "",
    Callback = function(value)
        methodKill = value
    end
})

Troll:AddButton({
    Name = "Matar Player",
    Callback = function()
        if not selectedPlayerName then return end
        
        if methodKill == "Couch" then
            KillPlayerCouch()
        elseif methodKill == "Couch Sem ir até o alvo [BETA]" then
            -- KillWithCouch() - implementação similar
            notify("Info", "Método BETA em desenvolvimento", 2)
        else
            -- Método Bus (original)
            local originalPosition = RootPart.CFrame
            
            local function GetBus()
                local vehicles = Workspace:FindFirstChild("Vehicles")
                if vehicles then
                    return vehicles:FindFirstChild(LocalPlayer.Name .. "Car")
                end
                return nil
            end

            local bus = GetBus()
            if not bus then
                RootPart.CFrame = CFrame.new(1118.81, 75.998, -1138.61)
                task.wait(0.5)
                local remoteEvent = ReplicatedStorage:FindFirstChild("RE")
                if remoteEvent and remoteEvent:FindFirstChild("1Ca1r") then
                    remoteEvent["1Ca1r"]:FireServer("PickingCar", "SchoolBus")
                end
                task.wait(1)
                bus = GetBus()
            end

            if bus then
                local seat = bus:FindFirstChild("Body") and bus.Body:FindFirstChild("VehicleSeat")
                if seat and Character:FindFirstChildOfClass("Humanoid") and not Character.Humanoid.Sit then
                    repeat
                        RootPart.CFrame = seat.CFrame * CFrame.new(0, 2, 0)
                        task.wait()
                    until Character.Humanoid.Sit or not bus.Parent
                end
            end

            local function TrackPlayer()
                while true do
                    if selectedPlayerName then
                        local targetPlayer = Players:FindFirstChild(selectedPlayerName)
                        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            local targetHumanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
                            if targetHumanoid and targetHumanoid.Sit then
                                if Character.Humanoid then
                                    bus:SetPrimaryPartCFrame(CFrame.new(Vector3.new(9999, -450, 9999)))
                                    task.wait(0.2)
                                    Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                                    task.wait(0.5)
                                    RootPart.CFrame = originalPosition
                                end
                                break
                            else
                                local targetRoot = targetPlayer.Character.HumanoidRootPart
                                local time = tick() * 35
                                local lateralOffset = math.sin(time) * 4
                                local frontBackOffset = math.cos(time) * 20
                                bus:SetPrimaryPartCFrame(targetRoot.CFrame * CFrame.new(lateralOffset, 0, frontBackOffset))
                            end
                        end
                    end
                    RunService.RenderStepped:Wait()
                end
            end
            spawn(TrackPlayer)
        end
    end
})

Troll:AddButton({
    Name = "Puxar Player",
    Callback = function()
        if not selectedPlayerName then return end
        if methodKill == "Couch" then
            BringPlayerLLL()
        else
            notify("Info", "Use método Couch para puxar", 2)
        end
    end
})

-- Auto Fling
Troll:AddToggle({
    Name = "Auto Fling",
    Default = false,
    Callback = function(state)
        if state and selectedPlayerName then
            local target = Players:FindFirstChild(selectedPlayerName)
            if not target or not target.Character then return end
            
            local flingActive = true
            local root = RootPart
            local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
            if not root or not tRoot then return end
            
            local hum = Character:FindFirstChildOfClass("Humanoid")
            local original = root.CFrame

            ReplicatedStorage:WaitForChild("RE"):WaitForChild("1Clea1rTool1s"):FireServer("ClearAllTools")
            task.wait(0.2)
            
            ReplicatedStorage.RE:FindFirstChild("1Too1l"):InvokeServer("PickingTools", "Couch")
            task.wait(0.3)
            
            local tool = LocalPlayer.Backpack:FindFirstChild("Couch")
            if tool then tool.Parent = Character end
            task.wait(0.2)
            
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
            task.wait(0.25)

            Workspace.FallenPartsDestroyHeight = 0/0
            local bv = Instance.new("BodyVelocity")
            bv.Name = "FlingForce"
            bv.Velocity = Vector3.new(9e8, 9e8, 9e8)
            bv.MaxForce = Vector3.new(1/0, 1/0, 1/0)
            bv.Parent = root
            
            hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
            hum.PlatformStand = false
            Camera.CameraSubject = target.Character:FindFirstChild("Head") or tRoot or hum

            task.spawn(function()
                local angle = 0
                while flingActive and target and target.Character do
                    local tHum = target.Character:FindFirstChildOfClass("Humanoid")
                    if tHum.Sit then break end
                    angle += 50
                    
                    local hrp = target.Character.HumanoidRootPart
                    local pos = hrp.Position + hrp.Velocity / 1.5
                    root.CFrame = CFrame.new(pos) * CFrame.Angles(math.rad(angle), 0, 0)
                    root.Velocity = Vector3.new(9e8, 9e8, 9e8)
                    root.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
                    task.wait()
                end
                
                bv:Destroy()
                hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
                hum.PlatformStand = false
                root.CFrame = original
                Camera.CameraSubject = hum
                
                for _, p in pairs(Character:GetDescendants()) do
                    if p:IsA("BasePart") then
                        p.Velocity = Vector3.zero
                        p.RotVelocity = Vector3.zero
                    end
                end
            end)
        end
    end
})

-- ============================================
-- ABA CAR (Zyronis Original)
-- ============================================
local CarTab = Window:MakeTab({"Car", "car"})

CarTab:AddButton({
    Name = "Remove All Cars",
    Callback = function()
        local args = {[1] = "DeleteAllVehicles"}
        ReplicatedStorage.RE:FindFirstChild("1Ca1r"):FireServer(unpack(args))
        notify("Car System", "Todos os veículos removidos!", 2)
    end
})

CarTab:AddButton({
    Name = "Bring All Cars",
    Callback = function()
        for _, v in next, Workspace.Vehicles:GetChildren() do
            v:SetPrimaryPartCFrame(LocalPlayer.Character:GetPrimaryPartCFrame())
        end
    end
})

CarTab:AddSlider({
    Name = "Speed",
    Min = 0,
    Max = 500,
    Default = 50,
    Color = Color3.fromRGB(0, 255, 128),
    Increment = 10,
    ValueName = "km/h",
    Callback = function(Value)
        local car = Workspace.Vehicles:FindFirstChild(LocalPlayer.Name .. "Car")
        if car then
            local body = car:FindFirstChild("Body") and car.Body:FindFirstChild("VehicleSeat")
            if body then
                body.TopSpeed.Value = Value
            end
        end
    end
})

-- ============================================
-- ABA PROTECTIONS (Zyronis Original)
-- ============================================
local Tab13 = Window:MakeTab({"Protections", "rbxassetid://11322093465"})

Tab13:AddToggle({
    Name = "Anti Sit",
    Default = false,
    Callback = function(state)
        task.spawn(function()
            while state and LocalPlayer.Character do
                local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
                    if humanoid:GetState() == Enum.HumanoidStateType.Seated then
                        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                    end
                end
                task.wait(0.05)
            end
            if not state then
                local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
                end
            end
        end)
    end
})

Tab13:AddToggle({
    Name = "Anti-Lag (Tool Dupe)",
    Default = false,
    Callback = function(state)
        if not state then return end
        
        local dedupLock = {}
        local IGNORED_PLAYER = LocalPlayer

        local function isTargetTool(inst)
            return inst:IsA("Tool")
        end

        local function gatherTools(player)
            local found = {}
            local containers = {}
            if player.Character then table.insert(containers, player.Character) end
            local backpack = player:FindFirstChildOfClass("Backpack")
            if backpack then table.insert(containers, backpack) end
            
            for _, container in ipairs(containers) do
                for _, child in ipairs(container:GetChildren()) do
                    if isTargetTool(child) then table.insert(found, child) end
                end
            end
            return found
        end

        local function dedupePlayer(player)
            if player == IGNORED_PLAYER then return end
            if dedupLock[player] then return end
            dedupLock[player] = true
            local tools = gatherTools(player)
            if #tools > 1 then
                for i = 2, #tools do pcall(function() tools[i]:Destroy() end) end
            end
            dedupLock[player] = false
        end

        while state do
            for _, plr in ipairs(Players:GetPlayers()) do dedupePlayer(plr) end
            task.wait(2)
        end
    end
})

-- ============================================
-- LOOP PRINCIPAL (CADUXX137)
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
        local mainSkills = {"Shoot", "Pass", "Dribble", "Control"}
        
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
-- INICIALIZAÇÃO
-- ============================================
notify("⚡ Zyronis Hub v10.0", "Sistema Híbrido Carregado!", 4)
print("[Zyronis Hub] CADUXX137 Integration Active")
print("[Zyronis Hub] Ball Reach: " .. CONFIG.reach .. " studs")
print("[Zyronis Hub] Auto Touch: " .. tostring(CONFIG.autoTouch))
print("[Zyronis Hub] Auto Skills: " .. tostring(autoSkills))
