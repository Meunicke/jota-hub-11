--[[
    ╔══════════════════════════════════════════════════════════════════╗
    ║                    CADUHUB REBORN v2.0                           ║
    ║              Original: CaduHub | Remake: Reborn Team             ║
    ║                                                                  ║
    ║  "O CaduHub foi abandonado, mas sua essência permanece."         ║
    ║                                                                  ║
    ║  Features:                                                       ║
    ║  • Ball Reach System (Alcance de bola inteligente)              ║
    ║  • Auto-Touch (Toque automático otimizado)                      ║
    ║  • Mobile & PC Interface (Adaptativo)                           ║
    ║  • Visualização de Alcance (Reach Sphere)                         ║
    ║  • Auto-Skills (Habilidades automáticas)                          ║
    ║  • Keybind System (Sistema de teclas)                           ║
    ║                                                                  ║
    ║  Compatible: Delta, Xeno, KRNL, Arceus X, Codex, Hydrogen      ║
    ╚══════════════════════════════════════════════════════════════════╝
]]

local CaduHub = {}
CaduHub.__index = CaduHub

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Configurações Globais
CaduHub.Config = {
    Theme = {
        Primary = Color3.fromRGB(30, 30, 30),
        Secondary = Color3.fromRGB(35, 35, 35),
        Accent = Color3.fromRGB(0, 255, 140), -- Verde neon característico
        Text = Color3.fromRGB(255, 255, 255),
        Dark = Color3.fromRGB(25, 25, 25),
        Border = Color3.fromRGB(60, 60, 60)
    },
    Mobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled,
    Version = "2.0.0",
    Credits = "Original: CaduHub | Remake: Reborn Team"
}

-- Sistema de Football
CaduHub.Football = {
    Enabled = false,
    Reach = 10,
    AutoTouch = false,
    VisualizeReach = true,
    AutoSkills = false,
    BallLock = false,
    CurrentBall = nil,
    ReachPart = nil,
    Connection = nil
}

-- Utilidades
function CaduHub:Create(instanceType, properties)
    local instance = Instance.new(instanceType)
    for prop, value in pairs(properties) do
        if prop ~= "Parent" then
            if typeof(value) == "Instance" then
                value.Parent = instance
            else
                instance[prop] = value
            end
        end
    end
    instance.Parent = properties.Parent
    return instance
end

function CaduHub:MakeDraggable(frame)
    local dragInput, dragStart, startPos
    local dragging = false
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function CaduHub:RoundNumber(num, decimals)
    decimals = decimals or 0
    local mult = 10 ^ decimals
    return math.floor(num * mult + 0.5) / mult
end

-- Interface Principal
function CaduHub:InitUI()
    -- ScreenGui principal
    local ScreenGui = self:Create("ScreenGui", {
        Name = "CaduHubReborn",
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })
    
    -- Container principal (adaptativo para mobile)
    local MainFrame = self:Create("Frame", {
        Name = "MainFrame",
        Size = self.Config.Mobile and UDim2.new(0, 280, 0, 400) or UDim2.new(0, 220, 0, 350),
        Position = UDim2.new(0, 20, 0, 20),
        BackgroundColor3 = self.Config.Theme.Primary,
        BorderSizePixel = 0,
        Parent = ScreenGui,
        Active = true,
        Draggable = false -- Usarei sistema customizado
    })
    
    -- Cantos arredondados
    local Corner = self:Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = MainFrame
    })
    
    -- Sombra
    local Shadow = self:Create("ImageLabel", {
        Name = "Shadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 20, 1, 20),
        Image = "rbxassetid://1316045217",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.6,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10, 10, 118, 118),
        Parent = MainFrame,
        ZIndex = -1
    })
    
    -- Header
    local Header = self:Create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = self.Config.Theme.Primary,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    
    -- Underline colorida (Rainbow opcional)
    local Underline = self:Create("Frame", {
        Name = "Underline",
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = self.Config.Theme.Accent,
        BorderSizePixel = 0,
        Parent = Header,
        ZIndex = 2
    })
    
    -- Título
    local Title = self:Create("TextLabel", {
        Name = "Title",
        Text = "⚡ CaduHub Reborn",
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = self.Config.Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Header
    })
    
    -- Botão Minimizar
    local MinimizeBtn = self:Create("TextButton", {
        Name = "Minimize",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -35, 0, 0),
        BackgroundTransparency = 1,
        Text = "-",
        TextColor3 = self.Config.Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        Parent = Header
    })
    
    -- Container de conteúdo
    local Container = self:Create("ScrollingFrame", {
        Name = "Container",
        Size = UDim2.new(1, -10, 1, -40),
        Position = UDim2.new(0, 5, 0, 35),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = self.Config.Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = MainFrame
    })
    
    -- Layout
    local ListLayout = self:Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        Parent = Container
    })
    
    -- Padding
    local Padding = self:Create("UIPadding", {
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 5),
        Parent = Container
    })
    
    -- Créditos no rodapé
    local Credits = self:Create("TextLabel", {
        Name = "Credits",
        Text = self.Config.Credits,
        Size = UDim2.new(1, 0, 0, 15),
        Position = UDim2.new(0, 0, 1, -15),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(150, 150, 150),
        Font = Enum.Font.Gotham,
        TextSize = 10,
        Parent = MainFrame
    })
    
    -- Tornar arrastável
    self:MakeDraggable(MainFrame)
    
    -- Sistema de minimizar
    local minimized = false
    MinimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        MinimizeBtn.Text = minimized and "+" or "-"
        Container.Visible = not minimized
        Credits.Visible = not minimized
        
        local targetSize = minimized and UDim2.new(0, MainFrame.Size.X.Offset, 0, 30) or (self.Config.Mobile and UDim2.new(0, 280, 0, 400) or UDim2.new(0, 220, 0, 350))
        
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Size = targetSize
        }):Play()
    end)
    
    return {
        ScreenGui = ScreenGui,
        MainFrame = MainFrame,
        Container = Container,
        Underline = Underline
    }
end

-- Componentes da UI
function CaduHub:CreateToggle(parent, text, default, callback)
    local ToggleFrame = self:Create("Frame", {
        Name = text .. "_Toggle",
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = self.Config.Theme.Secondary,
        BorderSizePixel = 0,
        Parent = parent
    })
    
    local Corner = self:Create("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = ToggleFrame
    })
    
    local Label = self:Create("TextLabel", {
        Text = text,
        Size = UDim2.new(1, -50, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = self.Config.Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = ToggleFrame
    })
    
    local ToggleBtn = self:Create("TextButton", {
        Name = "ToggleBtn",
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -45, 0.5, -10),
        BackgroundColor3 = default and self.Config.Theme.Accent or self.Config.Theme.Dark,
        Text = default and "ON" or "OFF",
        TextColor3 = self.Config.Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        Parent = ToggleFrame
    })
    
    local BtnCorner = self:Create("UICorner", {
        CornerRadius = UDim.new(0, 10),
        Parent = ToggleBtn
    })
    
    local enabled = default
    
    ToggleBtn.MouseButton1Click:Connect(function()
        enabled = not enabled
        ToggleBtn.Text = enabled and "ON" or "OFF"
        
        TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = enabled and self.Config.Theme.Accent or self.Config.Theme.Dark
        }):Play()
        
        callback(enabled)
    end)
    
    return {
        Set = function(self, value)
            enabled = value
            ToggleBtn.Text = enabled and "ON" or "OFF"
            ToggleBtn.BackgroundColor3 = enabled and self.Config.Theme.Accent or self.Config.Theme.Dark
            callback(enabled)
        end,
        Get = function() return enabled end
    }
end

function CaduHub:CreateSlider(parent, text, min, max, default, precise, callback)
    local SliderFrame = self:Create("Frame", {
        Name = text .. "_Slider",
        Size = UDim2.new(1, 0, 0, 45),
        BackgroundColor3 = self.Config.Theme.Secondary,
        BorderSizePixel = 0,
        Parent = parent
    })
    
    local Corner = self:Create("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = SliderFrame
    })
    
    local Label = self:Create("TextLabel", {
        Text = text,
        Size = UDim2.new(1, -10, 0, 20),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = self.Config.Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = SliderFrame
    })
    
    local ValueLabel = self:Create("TextLabel", {
        Text = tostring(default),
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -45, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = self.Config.Theme.Accent,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        Parent = SliderFrame
    })
    
    -- Background da barra
    local SliderBg = self:Create("Frame", {
        Name = "SliderBg",
        Size = UDim2.new(1, -20, 0, 6),
        Position = UDim2.new(0, 10, 0, 30),
        BackgroundColor3 = self.Config.Theme.Dark,
        BorderSizePixel = 0,
        Parent = SliderFrame
    })
    
    local BgCorner = self:Create("UICorner", {
        CornerRadius = UDim.new(0, 3),
        Parent = SliderBg
    })
    
    -- Fill da barra
    local SliderFill = self:Create("Frame", {
        Name = "SliderFill",
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = self.Config.Theme.Accent,
        BorderSizePixel = 0,
        Parent = SliderBg
    })
    
    local FillCorner = self:Create("UICorner", {
        CornerRadius = UDim.new(0, 3),
        Parent = SliderFill
    })
    
    -- Botão do slider
    local SliderBtn = self:Create("TextButton", {
        Name = "SliderBtn",
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Text = "",
        Parent = SliderBg
    })
    
    local BtnCorner = self:Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = SliderBtn
    })
    
    -- Lógica do slider
    local dragging = false
    local value = default
    
    local function update(input)
        local pos = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
        value = min + (max - min) * pos
        
        if not precise then
            value = math.floor(value)
        else
            value = self:RoundNumber(value, 2)
        end
        
        SliderFill.Size = UDim2.new(pos, 0, 1, 0)
        SliderBtn.Position = UDim2.new(pos, -6, 0.5, -6)
        ValueLabel.Text = tostring(value)
        callback(value)
    end
    
    SliderBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    
    SliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    return {
        Set = function(self, newValue)
            value = math.clamp(newValue, min, max)
            local pos = (value - min) / (max - min)
            SliderFill.Size = UDim2.new(pos, 0, 1, 0)
            SliderBtn.Position = UDim2.new(pos, -6, 0.5, -6)
            ValueLabel.Text = tostring(value)
            callback(value)
        end,
        Get = function() return value end
    }
end

function CaduHub:CreateButton(parent, text, callback)
    local Button = self:Create("TextButton", {
        Name = text .. "_Btn",
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = self.Config.Theme.Accent,
        Text = text,
        TextColor3 = self.Config.Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        Parent = parent
    })
    
    local Corner = self:Create("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = Button
    })
    
    -- Efeito hover
    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(0, 230, 126)
        }):Play()
    end)
    
    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {
            BackgroundColor3 = self.Config.Theme.Accent
        }):Play()
    end)
    
    Button.MouseButton1Click:Connect(callback)
    
    return Button
end

function CaduHub:CreateSection(parent, text)
    local Section = self:Create("Frame", {
        Name = text .. "_Section",
        Size = UDim2.new(1, 0, 0, 25),
        BackgroundColor3 = self.Config.Theme.Dark,
        BorderSizePixel = 0,
        Parent = parent
    })
    
    local Label = self:Create("TextLabel", {
        Text = "  " .. text,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        TextColor3 = self.Config.Theme.Accent,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Section
    })
    
    return Section
end

-- Sistema de Football/Bola
function CaduHub:InitFootballSystem()
    local Football = self.Football
    
    -- Criar partícula de alcance visual
    function Football:CreateReachVisual()
        if self.ReachPart then self.ReachPart:Destroy() end
        
        self.ReachPart = Instance.new("Part")
        self.ReachPart.Name = "CaduHub_Reach"
        self.ReachPart.Anchored = true
        self.ReachPart.CanCollide = false
        self.ReachPart.Transparency = 0.9
        self.ReachPart.BrickColor = BrickColor.new("Lime green")
        self.ReachPart.Material = Enum.Material.ForceField
        self.ReachPart.Shape = Enum.PartType.Ball
        self.ReachPart.Size = Vector3.new(self.Reach * 2, self.Reach * 2, self.Reach * 2)
        self.ReachPart.Parent = Workspace
        
        -- Billboard para mostrar distância
        local Billboard = Instance.new("BillboardGui")
        Billboard.Name = "ReachInfo"
        Billboard.Size = UDim2.new(0, 100, 0, 50)
        Billboard.StudsOffset = Vector3.new(0, self.Reach + 2, 0)
        Billboard.AlwaysOnTop = true
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, 0, 1, 0)
        Label.BackgroundTransparency = 1
        Label.Text = "REACH: " .. self.Reach
        Label.TextColor3 = Color3.fromRGB(0, 255, 140)
        Label.Font = Enum.Font.GothamBold
        Label.TextSize = 14
        Label.Parent = Billboard
        
        Billboard.Parent = self.ReachPart
        
        return self.ReachPart
    end
    
    -- Atualizar visualização
    function Football:UpdateReachVisual(position)
        if self.ReachPart and self.VisualizeReach then
            self.ReachPart.Size = Vector3.new(self.Reach * 2, self.Reach * 2, self.Reach * 2)
            self.ReachPart.Position = position
            
            local Billboard = self.ReachPart:FindFirstChild("ReachInfo")
            if Billboard then
                Billboard.StudsOffset = Vector3.new(0, self.Reach + 2, 0)
                local Label = Billboard:FindFirstChildOfClass("TextLabel")
                if Label then
                    Label.Text = "REACH: " .. self.Reach
                end
            end
            self.ReachPart.Transparency = 0.85
        elseif self.ReachPart then
            self.ReachPart.Transparency = 1
        end
    end
    
    -- Encontrar bola mais próxima
    function Football:FindNearestBall()
        local nearestBall = nil
        local shortestDistance = math.huge
        local character = LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        
        if not rootPart then return nil end
        
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name:lowe
