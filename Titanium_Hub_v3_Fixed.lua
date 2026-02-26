--[[
 ╔═══════════════════════════════════════════════════════════════╗
 ║                                                               ║
 ║ ████████╗██╗████████╗ █████╗ ███╗   ██╗██╗██╗   ██╗███████╗ ║
 ║ ╚══██╔══╝██║╚══██╔══╝██╔══██╗████╗  ██║██║██║   ██║██╔════╝ ║
 ║    ██║   ██║   ██║   ███████║██╔██╗ ██║██║██║   ██║█████╗   ║
 ║    ██║   ██║   ██║   ██╔══██║██║╚██╗██║██║╚██╗ ██╔╝██╔══╝   ║
 ║    ██║   ██║   ██║   ██║  ██║██║ ╚████║██║ ╚████╔╝ ███████╗ ║
 ║    ╚═╝   ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═══╝  ╚══════╝ ║
 ║                                                               ║
 ║         TITANIUM HUB v3.0 - REFORMULADO & OTIMIZADO          ║
 ║              Correções: Nil Value, UI, Performance           ║
 ║                                                               ║
 ╚═══════════════════════════════════════════════════════════════╝
]]

-- ============================================
-- SERVIÇOS E INICIALIZAÇÃO SEGURA
-- ============================================

local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    Workspace = game:GetService("Workspace"),
    TweenService = game:GetService("TweenService"),
    StarterGui = game:GetService("StarterGui"),
    CoreGui = game:GetService("CoreGui"),
    Debris = game:GetService("Debris")
}

-- CORREÇÃO CRÍTICA: Aguarda LocalPlayer de forma segura
local LocalPlayer
local function GetLocalPlayer()
    if Services.Players.LocalPlayer then
        return Services.Players.LocalPlayer
    end
    
    -- Aguarda até 10 segundos pelo LocalPlayer
    local startTime = tick()
    while not Services.Players.LocalPlayer and (tick() - startTime) < 10 do
        task.wait(0.1)
    end
    
    return Services.Players.LocalPlayer
end

LocalPlayer = GetLocalPlayer()
if not LocalPlayer then
    warn("[TITANIUM HUB v3.0] Falha crítica: LocalPlayer não encontrado após 10s")
    return
end

local Mouse = LocalPlayer:GetMouse()

-- ============================================
-- CONFIGURAÇÕES OTIMIZADAS
-- ============================================

local CADU_CONFIG = {
    -- IDs das imagens
    iconImage = "rbxassetid://104616032736993",
    iconBackground = "rbxassetid://96755648876012",

    -- Configurações de Reach
    reach = 15,
    showReachSphere = true,
    autoTouch = true,
    fullBodyTouch = true,
    autoSecondTouch = true,
    scanCooldown = 1.5,

    -- Lista expandida de bolas
    ballNames = {
        "TPS", "TCS", "ESA", "MRS", "PRS", "MPS", "SSS", "AIFA", "RBZ",
        "Ball", "Soccer", "Football", "Basketball", "Baseball",
        "BallTemplate", "GameBall", "Hitbox", "TouchPart", "GoalBall",
        "Bola", "Pelota", "Balloon", "Sphere", "Part"
    },

    -- Auto Skills
    autoSkills = true,
    skillCooldown = 0.5,
    skillButtonNames = {
        "Shoot", "Pass", "Long", "Tackle", "Dribble", "GK", "Throw",
        "Control", "Left", "Right", "High", "Low", "Rainbow",
        "Chip", "Heel", "Volley", "Back Right", "Back Left",
        "Carry", "Fake Shot", "Drag Back", "Header", "Bicycle",
        "Shot", "Slide", "Goalkeeper", "Catch", "Punch",
        "Short Pass", "Through Ball", "Cross", "Curve",
        "Power Shot", "Precision", "First Touch", "Kick", "Dash"
    }
}

-- Variáveis globais otimizadas
local State = {
    balls = {},
    ballConnections = {},
    reachSphere = nil,
    HRP = nil,
    character = nil,
    touchDebounce = {},
    lastBallUpdate = 0,
    lastTouch = 0,
    lastSkillActivation = 0,
    activatedSkills = {},
    isRunning = true
}

-- ============================================
-- SISTEMA DE NOTIFICAÇÃO APRIMORADO
-- ============================================

local function notify(title, text, duration, type)
    duration = duration or 3
    type = type or "info"
    
    local colors = {
        info = Color3.fromRGB(0, 180, 255),
        success = Color3.fromRGB(0, 255, 128),
        warning = Color3.fromRGB(255, 200, 0),
        error = Color3.fromRGB(255, 50, 100)
    }
    
    pcall(function()
        Services.StarterGui:SetCore("SendNotification", {
            Title = title or "⚡ TITANIUM HUB v3.0",
            Text = text or "",
            Duration = duration,
            Icon = type == "success" and "rbxassetid://7733715400" or nil
        })
    end)
end

-- ============================================
-- TEMA E UI SYSTEM REFATORADO
-- ============================================

local TitanHub = {
    Version = "3.0.0 - Reformulado",
    Name = "TITANIUM HUB",
    
    Theme = {
        Background = Color3.fromRGB(10, 10, 15),
        Surface = Color3.fromRGB(20, 20, 30),
        SurfaceLight = Color3.fromRGB(30, 30, 45),
        Primary = Color3.fromRGB(0, 180, 255),
        Secondary = Color3.fromRGB(138, 43, 226),
        Accent = Color3.fromRGB(255, 215, 0),
        Success = Color3.fromRGB(0, 255, 128),
        Danger = Color3.fromRGB(255, 50, 100),
        Warning = Color3.fromRGB(255, 200, 0),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(150, 160, 180),
        
        Gradients = {
            Neon = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 180, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 100, 255))
            }),
            Dark = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 45)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25))
            })
        }
    },

    Config = {
        UIScale = 1,
        Animations = true,
        ToggleKey = Enum.KeyCode.RightShift,
        Draggable = true,
        MobileMode = false
    },

    UI = {
        ScreenGui = nil,
        MainFrame = nil,
        ContentArea = nil,
        StatusLabel = nil,
        BallsCountLabel = nil,
        CharStatusLabel = nil,
        ReachDisplay = nil
    }
}

-- ============================================
-- FUNÇÕES UTILITÁRIAS OTIMIZADAS
-- ============================================

local function Create(className, properties, children)
    local instance = Instance.new(className)
    
    if properties then
        for prop, value in pairs(properties) do
            pcall(function()
                instance[prop] = value
            end)
        end
    end
    
    if children then
        for _, child in ipairs(children) do
            if typeof(child) == "Instance" then
                child.Parent = instance
            end
        end
    end
    
    return instance
end

local function Tween(instance, duration, properties, style, direction)
    if not instance or not instance.Parent then return nil end
    
    style = style or Enum.EasingStyle.Quint
    direction = direction or Enum.EasingDirection.Out
    
    local success, tween = pcall(function()
        return Services.TweenService:Create(
            instance, 
            TweenInfo.new(duration, style, direction), 
            properties
        )
    end)
    
    if success and tween then
        tween:Play()
        return tween
    end
    
    return nil
end

-- ============================================
-- SISTEMA CADUXX137 OTIMIZADO
-- ============================================

local function updateCharacter()
    local newChar = LocalPlayer.Character
    
    if newChar ~= State.character then
        State.character = newChar
        
        if newChar then
            -- Aguarda HRP com timeout
            local startTime = tick()
            repeat
                State.HRP = newChar:FindFirstChild("HumanoidRootPart")
                task.wait(0.1)
            until State.HRP or (tick() - startTime) > 5
            
            if State.HRP then
                notify("TITANIUM HUB", "Personagem conectado! Sistema ativo.", 2, "success")
            else
                warn("[TITANIUM HUB] HumanoidRootPart não encontrado")
            end
        else
            State.HRP = nil
        end
    end
end

local function findBalls()
    local now = tick()
    if now - State.lastBallUpdate < CADU_CONFIG.scanCooldown then 
        return #State.balls 
    end
    
    State.lastBallUpdate = now

    -- Limpa lista anterior de forma segura
    table.clear(State.balls)
    
    -- Desconecta conexões antigas
    for _, conn in ipairs(State.ballConnections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(State.ballConnections)

    -- Busca otimizada
    local descendants = Services.Workspace:GetDescendants()
    
    for _, obj in ipairs(descendants) do
        if obj:IsA("BasePart") and obj.Parent then
            local objName = obj.Name
            
            for _, name in ipairs(CADU_CONFIG.ballNames) do
                if objName == name or objName:find(name, 1, true) then
                    table.insert(State.balls, obj)
                    
                    -- Conexão de cleanup
                    local conn = obj.AncestryChanged:Connect(function(_, parent)
                        if not parent then 
                            task.delay(0.1, findBalls)
                        end
                    end)
                    
                    table.insert(State.ballConnections, conn)
                    break
                end
            end
        end
    end

    return #State.balls
end

local function getBodyParts()
    if not State.character then return {} end
    
    local parts = {}
    
    for _, part in ipairs(State.character:GetChildren()) do
        if part:IsA("BasePart") then
            if CADU_CONFIG.fullBodyTouch then
                table.insert(parts, part)
            elseif part.Name == "HumanoidRootPart" then
                table.insert(parts, part)
                break
            end
        end
    end
    
    return parts
end

local function updateSphere()
    if not CADU_CONFIG.showReachSphere then
        if State.reachSphere then
            State.reachSphere:Destroy()
            State.reachSphere = nil
        end
        return
    end

    -- Cria esfera se não existir
    if not State.reachSphere or not State.reachSphere.Parent then
        State.reachSphere = Create("Part", {
            Name = "Titanium_ReachSphere",
            Shape = Enum.PartType.Ball,
            Anchored = true,
            CanCollide = false,
            Transparency = 0.88,
            Material = Enum.Material.ForceField,
            Color = TitanHub.Theme.Primary,
            Parent = Services.Workspace
        })
    end

    -- Atualiza posição e tamanho
    if State.HRP and State.HRP.Parent then
        local reach = CADU_CONFIG.reach
        State.reachSphere.Position = State.HRP.Position
        State.reachSphere.Size = Vector3.new(reach * 2, reach * 2, reach * 2)
    end
end

local function doTouch(ball, part)
    if not ball or not ball.Parent or not part or not part.Parent then 
        return 
    end

    local key = ball.Name .. "_" .. part.Name .. "_" .. tostring(ball:GetFullName())
    
    if State.touchDebounce[key] and (tick() - State.touchDebounce[key]) < 0.1 then 
        return 
    end
    
    State.touchDebounce[key] = tick()

    pcall(function()
        firetouchinterest(ball, part, 0)
        task.wait(0.01)
        firetouchinterest(ball, part, 1)

        if CADU_CONFIG.autoSecondTouch then
            task.wait(0.05)
            firetouchinterest(ball, part, 0)
            firetouchinterest(ball, part, 1)
        end
    end)
end

-- ============================================
-- SISTEMA DE SKILLS APRIMORADO
-- ============================================

local function findSkillButtons()
    local buttons = {}
    local playerGui = LocalPlayer:WaitForChild("PlayerGui", 5)
    
    if not playerGui then return buttons end

    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and not gui.Name:find("Titanium") then
            for _, obj in ipairs(gui:GetDescendants()) do
                if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                    local objName = obj.Name
                    local objText = obj:IsA("TextButton") and obj.Text or ""
                    
                    for _, skillName in ipairs(CADU_CONFIG.skillButtonNames) do
                        local skillLower = skillName:lower()
                        
                        if objName == skillName or objText == skillName or
                           objName:lower():find(skillLower) or 
                           objText:lower():find(skillLower) then
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
    local now = tick()
    
    if State.activatedSkills[key] and (now - State.activatedSkills[key]) < CADU_CONFIG.skillCooldown then
        return
    end
    
    State.activatedSkills[key] = now

    pcall(function()
        if button:IsA("GuiButton") then
            -- Método 1: Fire connections
            local success1, connections1 = pcall(function()
                return getconnections(button.MouseButton1Click)
            end)
            
            if success1 then
                for _, conn in ipairs(connections1) do
                    pcall(function() conn:Fire() end)
                end
            end
            
            local success2, connections2 = pcall(function()
                return getconnections(button.Activated)
            end)
            
            if success2 then
                for _, conn in ipairs(connections2) do
                    pcall(function() conn:Fire() end)
                end
            end

            -- Método 2: Fire eventos diretos
            pcall(function() button.MouseButton1Click:Fire() end)
            pcall(function() button.Activated:Fire() end)
        end
    end)
end

-- ============================================
-- COMPONENTES UI CORRIGIDOS
-- ============================================

function TitanHub:CreateGlassFrame(parent, size, pos, cornerRadius)
    cornerRadius = cornerRadius or 16

    local glass = Create("ImageLabel", {
        Name = "GlassFrame",
        BackgroundTransparency = 1,
        Image = "rbxassetid://8992230677",
        ImageColor3 = self.Theme.Surface,
        ImageTransparency = 0.4,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(99, 99, 99, 99),
        Size = size or UDim2.new(1, 0, 1, 0),
        Position = pos or UDim2.new(0, 0, 0, 0),
        ClipsDescendants = true
    })

    Create("UICorner", {
        CornerRadius = UDim.new(0, cornerRadius),
        Parent = glass
    })

    Create("UIStroke", {
        Color = self.Theme.Primary,
        Thickness = 1.5,
        Transparency = 0.7,
        Parent = glass
    })

    Create("UIGradient", {
        Color = self.Theme.Gradients.Dark,
        Rotation = 45,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.3),
            NumberSequenceKeypoint.new(1, 0.6)
        }),
        Parent = glass
    })

    glass.Parent = parent
    return glass
end

function TitanHub:CreateToggle(parent, config)
    config = config or {}
    local text = config.Text or "Toggle"
    local default = config.Default or false
    local callback = config.Callback or function() end

    local container = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 40),
        Parent = parent
    })

    local label = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = self.Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 15,
        Size = UDim2.new(1, -60, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })

    local switchBg = Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(50, 50, 60),
        BorderSizePixel = 0,
        Size = UDim2.new(0, 50, 0, 26),
        Position = UDim2.new(1, -50, 0.5, -13),
        Parent = container
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = switchBg
    })

    local stroke = Create("UIStroke", {
        Color = default and self.Theme.Success or Color3.fromRGB(80, 80, 90),
        Thickness = 2,
        Transparency = 0.5,
        Parent = switchBg
    })

    local circle = Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Size = UDim2.new(0, 20, 0, 20),
        Position = default and UDim2.new(1, -24, 0.5, -10) or UDim2.new(0, 4, 0.5, -10),
        Parent = switchBg
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = circle
    })

    local state = default

    local clickDetector = Create("TextButton", {
        BackgroundTransparency = 1,
        Text = "",
        Size = UDim2.new(1, 0, 1, 0),
        Parent = container
    })

    clickDetector.MouseButton1Click:Connect(function()
        state = not state

        Tween(circle, 0.3, {
            Position = state and UDim2.new(1, -24, 0.5, -10) or UDim2.new(0, 4, 0.5, -10)
        })
        
        Tween(switchBg, 0.3, {
            BackgroundColor3 = state and Color3.fromRGB(0, 100, 80) or Color3.fromRGB(50, 50, 60)
        })
        
        Tween(stroke, 0.3, {
            Color = state and self.Theme.Success or Color3.fromRGB(80, 80, 90)
        })

        callback(state)
    end)

    return {
        Instance = container,
        Set = function(_, value)
            state = value
            Tween(circle, 0.3, {
                Position = state and UDim2.new(1, -24, 0.5, -10) or UDim2.new(0, 4, 0.5, -10)
            })
            Tween(switchBg, 0.3, {
                BackgroundColor3 = state and Color3.fromRGB(0, 100, 80) or Color3.fromRGB(50, 50, 60)
            })
            Tween(stroke, 0.3, {
                Color = state and self.Theme.Success or Color3.fromRGB(80, 80, 90)
            })
        end,
        Get = function() return state end
    }
end

function TitanHub:CreateSlider(parent, config)
    config = config or {}
    local text = config.Text or "Slider"
    local min = config.Min or 0
    local max = config.Max or 100
    local default = config.Default or min
    local callback = config.Callback or function() end

    local container = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 60),
        Parent = parent
    })

    local label = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = self.Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 15,
        Size = UDim2.new(0.7, 0, 0, 25),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })

    local valueLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = tostring(default),
        TextColor3 = self.Theme.Primary,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        Size = UDim2.new(0.3, 0, 0, 25),
        Position = UDim2.new(0.7, 0, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = container
    })

    local track = Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(40, 40, 50),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 8),
        Position = UDim2.new(0, 0, 0, 35),
        Parent = container
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = track
    })

    Create("UIStroke", {
        Color = self.Theme.Primary,
        Thickness = 1,
        Transparency = 0.6,
        Parent = track
    })

    local fill = Create("Frame", {
        BackgroundColor3 = self.Theme.Primary,
                BorderSizePixel = 0,
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        Parent = track
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = fill
    })

    local thumb = Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new((default - min) / (max - min), -9, 0.5, -9),
        Parent = track
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = thumb
    })

    local dragging = false

    local function update(input)
        local trackAbsPos = track.AbsolutePosition.X
        local trackAbsSize = track.AbsoluteSize.X
        
        if trackAbsSize <= 0 then return end
        
        local pos = math.clamp((input.Position.X - trackAbsPos) / trackAbsSize, 0, 1)
        local value = math.floor(min + (pos * (max - min)))

        fill.Size = UDim2.new(pos, 0, 1, 0)
        thumb.Position = UDim2.new(pos, -9, 0.5, -9)
        valueLabel.Text = tostring(value)

        callback(value)
    end

    thumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            Tween(thumb, 0.2, {Size = UDim2.new(0, 22, 0, 22)})
        end
    end)

    Services.UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            Tween(thumb, 0.2, {Size = UDim2.new(0, 18, 0, 18)})
        end
    end)

    Services.UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                        input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            update(input)
        end
    end)

    return {
        Instance = container,
        Set = function(_, value)
            local pos = (value - min) / (max - min)
            Tween(fill, 0.3, {Size = UDim2.new(pos, 0, 1, 0)})
            Tween(thumb, 0.3, {Position = UDim2.new(pos, -9, 0.5, -9)})
            valueLabel.Text = tostring(value)
        end
    }
end

function TitanHub:CreateButton(parent, config)
    config = config or {}
    local text = config.Text or "Button"
    local callback = config.Callback or function() end
    local color = config.Color or self.Theme.Primary

    local btn = self:CreateGlassFrame(parent, UDim2.new(1, -20, 0, 45), nil, 10)
    btn.Name = "Button"
    
    local stroke = btn:FindFirstChildOfClass("UIStroke")
    if stroke then
        stroke.Color = color
        stroke.Transparency = 0.8
    end

    local btnText = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = self.Theme.Text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 15,
        Size = UDim2.new(1, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = btn
    })

    local clickDetector = Create("TextButton", {
        BackgroundTransparency = 1,
        Text = "",
        Size = UDim2.new(1, 0, 1, 0),
        Parent = btn
    })

    clickDetector.MouseEnter:Connect(function()
        Tween(btn, 0.2, {ImageTransparency = 0.2})
        if stroke then
            Tween(stroke, 0.2, {Transparency = 0.4})
        end
    end)

    clickDetector.MouseLeave:Connect(function()
        Tween(btn, 0.2, {ImageTransparency = 0.4})
        if stroke then
            Tween(stroke, 0.2, {Transparency = 0.7})
        end
    end)

    clickDetector.MouseButton1Click:Connect(function()
        local ripple = Create("Frame", {
            BackgroundColor3 = color,
            BackgroundTransparency = 0.5,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Parent = btn
        })
        
        Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = ripple
        })

        Tween(ripple, 0.5, {
            Size = UDim2.new(1.5, 0, 1.5, 0), 
            BackgroundTransparency = 1
        })
        
        Services.Debris:AddItem(ripple, 0.5)

        local success, err = pcall(callback)
        if not success then
            notify("Erro", tostring(err), 3, "error")
        end
    end)

    return btn
end

-- ============================================
-- CONSTRUÇÃO DA INTERFACE CORRIGIDA
-- ============================================

function TitanHub:BuildReachSection()
    local section = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 180),
        LayoutOrder = 1,
        Parent = self.UI.ContentArea
    })

    local header = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = "⚡ ALCANCE (REACH)",
        TextColor3 = self.Theme.Primary,
        Font = Enum.Font.GothamBlack,
        TextSize = 16,
        Size = UDim2.new(1, 0, 0, 25),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = section
    })

    -- Display do valor
    local reachDisplay = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = tostring(CADU_CONFIG.reach),
        TextColor3 = self.Theme.Primary,
        Font = Enum.Font.GothamBlack,
        TextSize = 48,
        Size = UDim2.new(0.5, 0, 0, 60),
        Position = UDim2.new(0.5, 0, 0, 30),
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = section
    })
    
    self.UI.ReachDisplay = reachDisplay

    Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = "studs",
        TextColor3 = self.Theme.TextDim,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        Size = UDim2.new(0.5, 0, 0, 20),
        Position = UDim2.new(0.5, 0, 0, 75),
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = section
    })

    -- Slider corrigido
    local reachSlider = self:CreateSlider(section, {
        Text = "Distância do Reach",
        Min = 1,
        Max = 50,
        Default = CADU_CONFIG.reach,
        Callback = function(value)
            CADU_CONFIG.reach = value
            if self.UI.ReachDisplay then
                self.UI.ReachDisplay.Text = tostring(value)
            end
        end
    })
    
    -- CORREÇÃO: Usar Instance em vez de propriedade inexistente
    if reachSlider and reachSlider.Instance then
        reachSlider.Instance.Position = UDim2.new(0, 0, 0, 100)
    end

    -- Toggle corrigido
    local sphereToggle = self:CreateToggle(section, {
        Text = "Mostrar Esfera Visual",
        Default = CADU_CONFIG.showReachSphere,
        Callback = function(state)
            CADU_CONFIG.showReachSphere = state
            notify("Reach", "Esfera " .. (state and "ativada" or "desativada"), 2, state and "success" or "info")
        end
    })
    
    -- CORREÇÃO: Usar Instance
    if sphereToggle and sphereToggle.Instance then
        sphereToggle.Instance.Position = UDim2.new(0, 0, 0, 140)
    end
end

function TitanHub:BuildControlsSection()
    local section = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 200),
        LayoutOrder = 2,
        Parent = self.UI.ContentArea
    })

    local header = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = "🎮 CONTROLES",
        TextColor3 = self.Theme.Primary,
        Font = Enum.Font.GothamBlack,
        TextSize = 16,
        Size = UDim2.new(1, 0, 0, 25),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = section
    })

    -- Toggles corrigidos com verificação de Instance
    local autoTouchToggle = self:CreateToggle(section, {
        Text = "Auto Touch (Pegar Bolas)",
        Default = CADU_CONFIG.autoTouch,
        Callback = function(state)
            CADU_CONFIG.autoTouch = state
            notify("Auto Touch", state and "Ativado" or "Desativado", 2, state and "success" or "warning")
        end
    })
    
    if autoTouchToggle and autoTouchToggle.Instance then
        autoTouchToggle.Instance.Position = UDim2.new(0, 0, 0, 35)
    end

    local fullBodyToggle = self:CreateToggle(section, {
        Text = "Full Body Touch",
        Default = CADU_CONFIG.fullBodyTouch,
        Callback = function(state)
            CADU_CONFIG.fullBodyTouch = state
            notify("Full Body", state and "Ativado" or "Desativado", 2, state and "success" or "warning")
        end
    })
    
    if fullBodyToggle and fullBodyToggle.Instance then
        fullBodyToggle.Instance.Position = UDim2.new(0, 0, 0, 80)
    end

    local doubleTouchToggle = self:CreateToggle(section, {
        Text = "Double Touch (2x toque)",
        Default = CADU_CONFIG.autoSecondTouch,
        Callback = function(state)
            CADU_CONFIG.autoSecondTouch = state
            notify("Double Touch", state and "Ativado" or "Desativado", 2, state and "success" or "warning")
        end
    })
    
    if doubleTouchToggle and doubleTouchToggle.Instance then
        doubleTouchToggle.Instance.Position = UDim2.new(0, 0, 0, 125)
    end
end

function TitanHub:BuildSkillsSection()
    local section = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 120),
        LayoutOrder = 3,
        Parent = self.UI.ContentArea
    })

    local header = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = "⚽ AUTO SKILLS",
        TextColor3 = self.Theme.Primary,
        Font = Enum.Font.GothamBlack,
        TextSize = 16,
        Size = UDim2.new(1, 0, 0, 25),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = section
    })

    local skillsToggle = self:CreateToggle(section, {
        Text = "Ativar Auto Skills",
        Default = CADU_CONFIG.autoSkills,
        Callback = function(state)
            CADU_CONFIG.autoSkills = state
            notify("Auto Skills", state and "Ativado" or "Desativado", 2, state and "success" or "warning")
        end
    })
    
    if skillsToggle and skillsToggle.Instance then
        skillsToggle.Instance.Position = UDim2.new(0, 0, 0, 35)
    end

    Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = "Detecta botões: Shoot, Pass, Dribble, etc.",
        TextColor3 = self.Theme.TextDim,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 80),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = section
    })
end

function TitanHub:BuildInfoSection()
    local section = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 150),
        LayoutOrder = 4,
        Parent = self.UI.ContentArea
    })

    local header = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = "📊 INFORMAÇÕES",
        TextColor3 = self.Theme.Primary,
        Font = Enum.Font.GothamBlack,
        TextSize = 16,
        Size = UDim2.new(1, 0, 0, 25),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = section
    })

    self.UI.BallsCountLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = "Bolas detectadas: 0",
        TextColor3 = self.Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        Size = UDim2.new(1, 0, 0, 25),
        Position = UDim2.new(0, 0, 0, 35),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = section
    })

    self.UI.CharStatusLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = "Personagem: Aguardando...",
        TextColor3 = self.Theme.Warning,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 65),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = section
    })

    Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = "Tecla para abrir/fechar: " .. self.Config.ToggleKey.Name,
        TextColor3 = self.Theme.TextDim,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 95),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = section
    })

    -- Botão corrigido - CreateButton retorna o frame diretamente
    local closeHubBtn = self:CreateButton(section, {
        Text = "Fechar Hub",
        Color = self.Theme.Danger,
        Callback = function()
            self:Close()
        end
    })
    
    -- CORREÇÃO: Ajustar posição do frame retornado
    if closeHubBtn then
        closeHubBtn.Position = UDim2.new(0, 10, 0, 120)
    end
end

-- ============================================
-- INICIALIZAÇÃO PRINCIPAL CORRIGIDA
-- ============================================

function TitanHub:Init()
    -- ScreenGui com proteção
    self.UI.ScreenGui = Create("ScreenGui", {
        Name = "TitaniumHub_CADU_v3",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    -- Proteção do GUI
    pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(self.UI.ScreenGui)
            self.UI.ScreenGui.Parent = Services.CoreGui
        elseif gethui then
            self.UI.ScreenGui.Parent = gethui()
        else
            self.UI.ScreenGui.Parent = Services.CoreGui
        end
    end)
    
    -- Fallback se proteção falhar
    if not self.UI.ScreenGui.Parent then
        self.UI.ScreenGui.Parent = Services.CoreGui
    end

    -- Frame principal
    self.UI.MainFrame = Create("Frame", {
        Name = "Main",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 400, 0, 550),
        Position = UDim2.new(0.5, -200, 0.5, -275),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Active = true,
        ClipsDescendants = true,
        Parent = self.UI.ScreenGui
    })

    -- Background
    local background = self:CreateGlassFrame(self.UI.MainFrame, UDim2.new(1, 0, 1, 0), nil, 20)
    background.Name = "Background"
    background.ImageColor3 = self.Theme.Background
    background.ImageTransparency = 0.1

    -- Top Bar
    local topBar = Create("Frame", {
        Name = "TopBar",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 60),
        Parent = self.UI.MainFrame
    })

    -- Título com gradiente
    local title = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = self.Name,
        TextColor3 = self.Theme.Text,
        Font = Enum.Font.GothamBlack,
        TextSize = 24,
        Size = UDim2.new(0.6, 0, 0, 35),
        Position = UDim2.new(0, 20, 0, 5),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topBar
    })

    Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, self.Theme.Primary),
            ColorSequenceKeypoint.new(0.5, self.Theme.Secondary),
            ColorSequenceKeypoint.new(1, self.Theme.Accent)
        }),
        Rotation = 45,
        Parent = title
    })

    Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = "CADUXX137 v3.0 Reformulado",
        TextColor3 = self.Theme.TextDim,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        Size = UDim2.new(0.6, 0, 0, 20),
        Position = UDim2.new(0, 20, 0, 38),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topBar
    })

    -- Botão fechar
    local closeBtn = Create("ImageButton", {
        BackgroundTransparency = 1,
        Image = "rbxassetid://7733954760",
        ImageColor3 = self.Theme.Danger,
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -40, 0, 18),
        Parent = topBar
    })

    closeBtn.MouseEnter:Connect(function()
        Tween(closeBtn, 0.2, {ImageColor3 = Color3.fromRGB(255, 100, 100)})
    end)
    
    closeBtn.MouseLeave:Connect(function()
        Tween(closeBtn, 0.2, {ImageColor3 = self.Theme.Danger})
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        self:Close()
    end)

    -- Área de conteúdo
    self.UI.ContentArea = Create("ScrollingFrame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -30, 1, -130),
        Position = UDim2.new(0, 15, 0, 70),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = self.Theme.Primary,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = self.UI.MainFrame
    })

    local listLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 12),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = self.UI.ContentArea
    })
    
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.UI.ContentArea.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 20)
    end)

    -- Status Bar
    local statusBar = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -30, 0, 40),
        Position = UDim2.new(0, 15, 1, -50),
        Parent = self.UI.MainFrame
    })

    self.UI.StatusLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = "🟡 Iniciando...",
        TextColor3 = self.Theme.Warning,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        Size = UDim2.new(1, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = statusBar
    })

    -- Sistema de drag
    local dragging = false
    local dragInput, dragStart, startPos

    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = self.UI.MainFrame.Position
        end
    end)

    Services.UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            self.UI.MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    Services.UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- Toggle key
    Services.UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == self.Config.ToggleKey then
            self:Toggle()
        end
    end)

    -- Construir seções
    self:BuildReachSection()
    self:BuildControlsSection()
    self:BuildSkillsSection()
    self:BuildInfoSection()

    -- Animação inicial
    self.UI.MainFrame.Size = UDim2.new(0, 0, 0, 0)
    Tween(self.UI.MainFrame, 0.5, {
        Size = UDim2.new(0, 400, 0, 550)
    }, Enum.EasingStyle.Back)


    notify("TITANIUM HUB v3.0", "Sistema reformulado carregado!", 3, "success")
    
    return self
end

function TitanHub:Toggle()
    local isOpened = self.UI.MainFrame.Visible and self.UI.MainFrame.Size.Y.Offset > 0
    
    if isOpened then
        Tween(self.UI.MainFrame, 0.3, {
            Size = UDim2.new(0, 0, 0, 0)
        }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        
        task.delay(0.3, function()
            self.UI.MainFrame.Visible = false
        end)
    else
        self.UI.MainFrame.Visible = true
        Tween(self.UI.MainFrame, 0.4, {
            Size = UDim2.new(0, 400, 0, 550)
        }, Enum.EasingStyle.Back)
    end
end

function TitanHub:Close()
    State.isRunning = false
    
    Tween(self.UI.MainFrame, 0.3, {
        Size = UDim2.new(0, 0, 0, 0)
    })
    
    task.delay(0.3, function()
        if self.UI.ScreenGui then
            self.UI.ScreenGui:Destroy()
        end
        if State.reachSphere then
            State.reachSphere:Destroy()
        end
        for _, conn in ipairs(State.ballConnections) do
            pcall(function() conn:Disconnect() end)
        end
    end)
end

function TitanHub:UpdateStatus()
    if not self.UI.StatusLabel or not self.UI.StatusLabel.Parent then 
        return 
    end

    local ballCount = #State.balls
    local hasChar = State.HRP ~= nil

    self.UI.StatusLabel.Text = string.format("%s Sistema %s | Bolas: %d",
        hasChar and "🟢" or "🟡",
        hasChar and "Ativo" or "Aguardando",
        ballCount
    )
    self.UI.StatusLabel.TextColor3 = hasChar and self.Theme.Success or self.Theme.Warning

    if self.UI.BallsCountLabel then
        self.UI.BallsCountLabel.Text = "Bolas detectadas: " .. ballCount
    end

    if self.UI.CharStatusLabel then
        if hasChar then
            self.UI.CharStatusLabel.Text = "Personagem: Conectado ✓"
            self.UI.CharStatusLabel.TextColor3 = self.Theme.Success
        else
            self.UI.CharStatusLabel.Text = "Personagem: Aguardando..."
            self.UI.CharStatusLabel.TextColor3 = self.Theme.Warning
        end
    end
end

-- ============================================
-- LOOP PRINCIPAL CORRIGIDO E OTIMIZADO
-- ============================================

local Hub = TitanHub:Init()

-- Loop principal usando Heartbeat
Services.RunService.Heartbeat:Connect(function()
    if not State.isRunning then return end
    
    -- Atualizações básicas
    updateCharacter()
    updateSphere()
    findBalls()
    Hub:UpdateStatus()

    -- PROTEÇÃO: Verifica se o HumanoidRootPart existe e está no Workspace
    if not State.HRP or not State.HRP.Parent then 
        return 
    end

    local now = tick()
    
    -- Controle de taxa de atualização
    if now - State.lastTouch < 0.05 then 
        return 
    end

    local hrpPos = State.HRP.Position
    local characterParts = getBodyParts()
    
    if #characterParts == 0 then 
        return 
    end

    -- Busca a bola mais próxima com verificação de existência
    local closestBall = nil
    local closestDistance = CADU_CONFIG.reach

    for _, ball in ipairs(State.balls) do
        if ball and ball.Parent and ball:IsA("BasePart") then
            local success, distance = pcall(function()
                return (ball.Position - hrpPos).Magnitude
            end)
            
            if success and distance and distance <= CADU_CONFIG.reach and distance < closestDistance then
                closestDistance = distance
                closestBall = ball
            end
        end
    end

    -- Lógica de Auto Touch
    if CADU_CONFIG.autoTouch and closestBall then
        State.lastTouch = now
        
        for _, part in ipairs(characterParts) do
            if part and part.Parent then
                doTouch(closestBall, part)
            end
        end
    end

    -- Lógica de Auto Skills
    if CADU_CONFIG.autoSkills and closestBall and 
       (now - State.lastSkillActivation > CADU_CONFIG.skillCooldown) then
        
        local skillButtons = findSkillButtons()
        local mainSkills = {"Shoot", "Pass", "Dribble", "Control", "Kick"}

        for _, button in ipairs(skillButtons) do
            if button and button.Parent then
                for _, mainSkill in ipairs(mainSkills) do
                    local buttonName = button.Name or ""
                    local buttonText = button:IsA("TextButton") and button.Text or ""
                    
                    if buttonName == mainSkill or buttonText == mainSkill then
                        State.lastSkillActivation = now
                        activateSkillButton(button)
                        break
                    end
                end
            end
        end
    end
end)

-- Cleanup periódico
task.spawn(function()
    while State.isRunning do
        task.wait(5)
        local now = tick()
        
        -- Limpa skills antigas
        for key, time in pairs(State.activatedSkills) do
            if now - time > 10 then
                State.activatedSkills[key] = nil
            end
        end
        
        -- Limpa debounce antigo
        for key, time in pairs(State.touchDebounce) do
            if now - time > 5 then
                State.touchDebounce[key] = nil
            end
        end
    end
end)

-- Handler de respawn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    updateCharacter()
end)

print([[
 ╔═══════════════════════════════════════════════════════════════╗
 ║                                                               ║
 ║     TITANIUM HUB v3.0 - REFORMULADO CARREGADO               ║
 ║     Correções aplicadas:                                      ║
 ║     ✓ Nil Value LocalPlayer                                   ║
 ║     ✓ Span tags inválidas removidas                           ║
 ║     ✓ Propriedades Instance corrigidas                        ║
 ║     ✓ Sistema de aguardo seguro                               ║
 ║                                                               ║
 ╚═══════════════════════════════════════════════════════════════╝
]])







 
                    
