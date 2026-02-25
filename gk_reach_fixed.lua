--// Services
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

--// Variables
local reachSize = 4
local isActive = true

--// GUI SRG (Layout EstÃ¡vel)
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "SRG_Hitbox_Fixed"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 200, 0, 100)
MainFrame.Position = UDim2.new(0.5, -100, 0.8, -120)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderColor3 = Color3.fromRGB(255, 255, 0)
MainFrame.BorderSizePixel = 2
MainFrame.Active = true
MainFrame.Draggable = true

local ValueLabel = Instance.new("TextLabel", MainFrame)
ValueLabel.Size = UDim2.new(1, 0, 0, 40)
ValueLabel.Position = UDim2.new(0, 0, 0, 40)
ValueLabel.BackgroundTransparency = 1
ValueLabel.Text = tostring(reachSize)
ValueLabel.TextColor3 = Color3.new(1, 1, 1)
ValueLabel.TextSize = 30
ValueLabel.Font = Enum.Font.GothamBold

local function CreateBtn(text, pos)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0, 40, 0, 40)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 25
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    return btn
end

local MinusBtn = CreateBtn("-", UDim2.new(0.1, 0, 0.45, 0))
local PlusBtn = CreateBtn("+", UDim2.new(0.7, 0, 0.45, 0))

--// Cubo Visual (Sem colisÃ£o, apenas referÃªncia)
local VisualPart = Instance.new("Part")
VisualPart.Name = "SRG_VisualCube"
VisualPart.Transparency = 1
VisualPart.CanCollide = false
VisualPart.Anchored = true
VisualPart.Parent = workspace

local SelectionBox = Instance.new("SelectionBox", VisualPart)
SelectionBox.Adornee = VisualPart
SelectionBox.Color3 = Color3.fromRGB(255, 255, 0)
SelectionBox.LineThickness = 0.08

--// LÃ³gica de DetecÃ§Ã£o e Toque de Longo Alcance
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local torso = char and char:FindFirstChild("Torso") -- PeÃ§a principal do R6
    
    if root and torso and isActive then
        -- Atualiza o cubo para seguir o personagem
        VisualPart.Size = Vector3.new(reachSize, reachSize, reachSize)
        VisualPart.CFrame = root.CFrame
        
        -- Detecta TUDO o que estÃ¡ dentro do volume do cubo amarelo
        local overlap = OverlapParams.new()
        overlap.FilterDescendantsInstances = {char, VisualPart}
        overlap.FilterType = Enum.RaycastFilterType.Exclude
        
        local objectsInCube = workspace:GetPartBoundsInBox(VisualPart.CFrame, VisualPart.Size, overlap)
        
        for _, obj in pairs(objectsInCube) do
            if obj:IsA("BasePart") and not obj.Anchored then
                -- O TRUQUE: Disparamos o toque entre a BOLA e o seu TORSO
                -- Como a bola estÃ¡ dentro do cubo (GetPartBoundsInBox), o sinal Ã© enviado
                -- NÃ£o importa se a bola estÃ¡ em cima, embaixo ou na ponta do cubo.
                firetouchinterest(obj, torso, 0)
                firetouchinterest(obj, torso, 1)
            end
        end
    end
end)

-- BotÃµes de 1 em 1
PlusBtn.MouseButton1Click:Connect(function()
    reachSize = reachSize + 1
    ValueLabel.Text = tostring(reachSize)
end)

MinusBtn.MouseButton1Click:Connect(function()
    if reachSize > 1 then
        reachSize = reachSize - 1
        ValueLabel.Text = tostring(reachSize)
    end
end)
