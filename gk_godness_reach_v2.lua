

corrected_code = '''--// Services
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

--// Espera o jogador estar pronto
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    Players.PlayerAdded:Wait()
    LocalPlayer = Players.LocalPlayer
end

--// Espera o PlayerGui carregar
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
if not PlayerGui then
    warn("PlayerGui não encontrado!")
    return
end

--// Variables
local reachSize = 4
local isActive = true
local hubOpen = true
local showCube = true -- Nova variável para controlar visibilidade do cubo

--// HUB PRINCIPAL 180x180
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SRG_Hub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Frame Principal do Hub (180x180)
local HubFrame = Instance.new("Frame")
HubFrame.Name = "MainHub"
HubFrame.Size = UDim2.new(0, 180, 0, 180)
HubFrame.Position = UDim2.new(0.5, -90, 0.5, -90)
HubFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
HubFrame.BorderSizePixel = 0
HubFrame.ClipsDescendants = true
HubFrame.Parent = ScreenGui

-- Cantos arredondados
local HubCorner = Instance.new("UICorner", HubFrame)
HubCorner.CornerRadius = UDim.new(0, 12)

-- Gradiente de fundo
local Gradient = Instance.new("UIGradient", HubFrame)
Gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 20))
})
Gradient.Rotation = 45

-- Sombra/Stroke
local Stroke = Instance.new("UIStroke", HubFrame)
Stroke.Color = Color3.fromRGB(255, 215, 0)
Stroke.Thickness = 2

--// BOTÃO DE FECHAR/ABRIR (ÍCONE)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleHub"
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0.5, -25, 0.5, -115)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
ToggleButton.Text = "⚡"
ToggleButton.TextColor3 = Color3.fromRGB(0, 0, 0)
ToggleButton.TextSize = 28
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner", ToggleButton)
ToggleCorner.CornerRadius = UDim.new(1, 0)

local ToggleStroke = Instance.new("UIStroke", ToggleButton)
ToggleStroke.Color = Color3.fromRGB(255, 255, 255)
ToggleStroke.Thickness = 2

--// CONTEÚDO DO HUB
-- Título
local Title = Instance.new("TextLabel", HubFrame)
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "SRG HUB"
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold

-- Container dos controles
local ControlsFrame = Instance.new("Frame", HubFrame)
ControlsFrame.Name = "Controls"
ControlsFrame.Size = UDim2.new(1, -20, 1, -45)
ControlsFrame.Position = UDim2.new(0, 10, 0, 40)
ControlsFrame.BackgroundTransparency = 1

-- Display do valor
local ValueFrame = Instance.new("Frame", ControlsFrame)
ValueFrame.Size = UDim2.new(1, 0, 0, 50)
ValueFrame.Position = UDim2.new(0, 0, 0, 0)
ValueFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)

local ValueCorner = Instance.new("UICorner", ValueFrame)
ValueCorner.CornerRadius = UDim.new(0, 8)

local ValueLabel = Instance.new("TextLabel", ValueFrame)
ValueLabel.Size = UDim2.new(1, 0, 1, 0)
ValueLabel.BackgroundTransparency = 1
ValueLabel.Text = tostring(reachSize)
ValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
ValueLabel.TextSize = 32
ValueLabel.Font = Enum.Font.GothamBlack

-- Botões + e -
local function CreateControlBtn(text, pos, color)
    local btn = Instance.new("TextButton", ControlsFrame)
    btn.Size = UDim2.new(0.45, 0, 0, 45)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 28
    btn.Font = Enum.Font.GothamBold
    
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 8)
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = color:Lerp(Color3.new(1,1,1), 0.2)}):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
    end)
    
    return btn
end

local MinusBtn = CreateControlBtn("-", UDim2.new(0, 0, 0.6, 0), Color3.fromRGB(200, 50, 50))
local PlusBtn = CreateControlBtn("+", UDim2.new(0.55, 0, 0.6, 0), Color3.fromRGB(50, 150, 50))

-- NOVO: Botão para esconder/mostrar cubo
local CubeToggleBtn = Instance.new("TextButton", ControlsFrame)
CubeToggleBtn.Size = UDim2.new(1, 0, 0, 25)
CubeToggleBtn.Position = UDim2.new(0, 0, 0.42, 0)
CubeToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
CubeToggleBtn.Text = "👁 CUBO: ON"
CubeToggleBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
CubeToggleBtn.TextSize = 14
CubeToggleBtn.Font = Enum.Font.GothamBold

local CubeToggleCorner = Instance.new("UICorner", CubeToggleBtn)
CubeToggleCorner.CornerRadius = UDim.new(0, 6)

-- Status indicator
local StatusLabel = Instance.new("TextLabel", HubFrame)
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Position = UDim2.new(0, 0, 1, -25)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "● ACTIVE"
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.GothamSemibold

--// SISTEMA DE ARRASTAR (Drag)
local function makeDraggable(frame, button)
    local dragging = false
    local dragInput, dragStart, startPos
    
    button.InputBegan:Connect(function(input)
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
    
    button.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Torna o Hub arrastável
local DragHandle = Instance.new("Frame", HubFrame)
DragHandle.Size = UDim2.new(1, 0, 0, 35)
DragHandle.BackgroundTransparency = 1
DragHandle.Active = true

makeDraggable(HubFrame, DragHandle)
makeDraggable(ToggleButton, ToggleButton)

--// ANIMAÇÃO DE ABRIR/FECHAR
local function toggleHub()
    hubOpen = not hubOpen
    
    if hubOpen then
        TweenService:Create(HubFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = UDim2.new(0, 180, 0, 180)}):Play()
        ToggleButton.Text = "⚡"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    else
        TweenService:Create(HubFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 0, 0, 0)}):Play()
        ToggleButton.Text = "🔒"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    end
end

ToggleButton.MouseButton1Click:Connect(toggleHub)

--// FUNÇÃO PARA TOGGLE DO CUBO
CubeToggleBtn.MouseButton1Click:Connect(function()
    showCube = not showCube
    if showCube then
        CubeToggleBtn.Text = "👁 CUBO: ON"
        CubeToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    else
        CubeToggleBtn.Text = "🙈 CUBO: OFF"
        CubeToggleBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    end
end)

--// Cubo Visual
local VisualPart = Instance.new("Part")
VisualPart.Name = "SRG_VisualCube"
VisualPart.Transparency = 1
VisualPart.CanCollide = false
VisualPart.Anchored = true
VisualPart.Parent = workspace

local SelectionBox = Instance.new("SelectionBox", VisualPart)
SelectionBox.Adornee = VisualPart
SelectionBox.Color3 = Color3.fromRGB(255, 215, 0)
SelectionBox.LineThickness = 0.08

--// LÓGICA DE DETECÇÃO
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local torso = char and char:FindFirstChild("Torso")
    
    if root and torso and isActive and hubOpen then
        VisualPart.Size = Vector3.new(reachSize, reachSize, reachSize)
        
        -- Controla visibilidade do cubo
        if showCube then
            VisualPart.CFrame = root.CFrame
            SelectionBox.Visible = true
        else
            VisualPart.CFrame = CFrame.new(0, -1000, 0)
            SelectionBox.Visible = false
        end
        
        local overlap = OverlapParams.new()
        overlap.FilterDescendantsInstances = {char, VisualPart}
        overlap.FilterType = Enum.RaycastFilterType.Exclude
        
        local objectsInCube = workspace:GetPartBoundsInBox(VisualPart.CFrame, Visual3.new(reachSize, reachSize, reachSize), overlap)
        
        for _, obj in pairs(objectsInCube) do
            if obj:IsA("BasePart") and not obj.Anchored then
                firetouchinterest(obj, torso, 0)
                firetouchinterest(obj, torso, 1)
            end
        end
    else
        VisualPart.CFrame = CFrame.new(0, -1000, 0)
    end
end)

-- Botões de controle
PlusBtn.MouseButton1Click:Connect(function()
    reachSize = reachSize + 1
    ValueLabel.Text = tostring(reachSize)
    
    TweenService:Create(ValueLabel, TweenInfo.new(0.1), {TextSize = 38}):Play()
    task.wait(0.1)
    TweenService:Create(ValueLabel, TweenInfo.new(0.1), {TextSize = 32}):Play()
end)

MinusBtn.MouseButton1Click:Connect(function()
    if reachSize > 1 then
        reachSize = reachSize - 1
        ValueLabel.Text = tostring(reachSize)
        
        TweenService:Create(ValueLabel, TweenInfo.new(0.1), {TextSize = 38}):Play()
        task.wait(0.1)
        TweenService:Create(ValueLabel, TweenInfo.new(0.1), {TextSize = 32}):Play()
    end
end)

-- Animação inicial
HubFrame.Size = UDim2.new(0, 0, 0, 0)
task.wait(0.5)
TweenService:Create(HubFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Size = UDim2.new(0, 180, 0, 180)}):Play()
'''

print(corrected_code)
