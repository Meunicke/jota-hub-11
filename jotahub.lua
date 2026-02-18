-- SERVICES
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer

-- CONFIG
local CONFIG = {
    playerReach = 10,
    ballReach = 15,
    showPlayerSphere = true,
    showBallAura = true,
    autoTouch = true,
    scanCooldown = 0.1,
    ballNames = { "MPS", "TRS", "TCS", "TPS", "PRS", "ESA", "MRS", "SSS", "AIFA", "RBZ", "SoccerBall", "Football", "Ball" },
    colors = {
        primary = Color3.fromRGB(0, 255, 255),
        secondary = Color3.fromRGB(255, 0, 255),
        accent = Color3.fromRGB(255, 200, 0),
        dark = Color3.fromRGB(10, 10, 15),
        darker = Color3.fromRGB(5, 5, 8)
    }
}

-- VARIÁVEIS GLOBAIS
local balls = {}
local ballAuras = {}
local playerSphere = nil
local gui, mainFrame
local isMobile = UserInputService.TouchEnabled
local HRP = nil

-- ATUALIZAR HRP
task.spawn(function()
    while true do
        task.wait(0.5)
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            HRP = player.Character.HumanoidRootPart
        end
    end
end)

-- REFRESH BALLS
local function refreshBalls()
    table.clear(balls)
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            for _, name in ipairs(CONFIG.ballNames) do
                if v.Name == name then
                    table.insert(balls, v)
                    break
                end
            end
        end
    end
end

-- LÓGICA DE REACH (MÉTODO ARTHUR V2)
local function doReach()
    if not CONFIG.autoTouch or not HRP then return end
    
    local character = player.Character
    local rightLeg = character and (character:FindFirstChild("Right Leg") or character:FindFirstChild("RightLowerLeg") or character:FindFirstChild("RightFoot"))
    if not rightLeg then return end
    
    refreshBalls()
    
    for _, ball in ipairs(balls) do
        if ball and ball.Parent then
            local distance = (ball.Position - HRP.Position).Magnitude
            if distance < (CONFIG.playerReach + CONFIG.ballReach) then
                pcall(function()
                    firetouchinterest(ball, rightLeg, 0)
                    firetouchinterest(ball, rightLeg, 1)
                end)
            end
        end
    end
end

-- ATUALIZAR ESFERA VISUAL
local function updatePlayerSphere()
    if not CONFIG.showPlayerSphere then
        if playerSphere then playerSphere:Destroy(); playerSphere = nil end
        return
    end
    if not HRP then return end
    if not playerSphere then
        playerSphere = Instance.new("Part", Workspace)
        playerSphere.Shape = Enum.PartType.Ball
        playerSphere.Anchored = true
        playerSphere.CanCollide = false
        playerSphere.Material = Enum.Material.ForceField
        playerSphere.Color = CONFIG.colors.primary
    end
    playerSphere.Size = Vector3.new(CONFIG.playerReach*2, CONFIG.playerReach*2, CONFIG.playerReach*2)
    playerSphere.Position = HRP.Position
end

-- INTERFACE PRINCIPAL
function buildMainGUI()
    gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    gui.Name = "CaduHubV3"
    gui.ResetOnSpawn = false

    mainFrame = Instance.new("Frame", gui)
    mainFrame.Size = UDim2.new(0, 320, 0, 450)
    mainFrame.Position = UDim2.new(0, 20, 0.5, -225)
    mainFrame.BackgroundColor3 = CONFIG.colors.dark
    mainFrame.BorderSizePixel = 0
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 16)
    
    local stroke = Instance.new("UIStroke", mainFrame)
    stroke.Color = CONFIG.colors.primary
    stroke.Thickness = 2

    -- (Aqui você continua com o design dos botões que você já tem...)
    -- Para economizar espaço e focar na funcionalidade:
    -- Supondo que você já tem os objetos minusPlayer, plusPlayer, etc. criados dentro do Frame.
    
    -- EXECUTANDO AS CONEXÕES QUE VOCÊ MANDOU:
    local function animateButton(btn)
        local original = btn.BackgroundColor3
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.new(1, 1, 1)}):Play()
        task.wait(0.1)
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = original}):Play()
    end

    -- [COLOCAR AQUI OS BOTÕES CRIADOS NO SEU SCRIPT] --
    -- Exemplo rápido para não dar erro:
    -- minusPlayer.MouseButton1Click:Connect(function() ... end)
end

-- BOTÃO MOBILE PREMIUM (ESTILO FLASH)
local function buildMobileButton()
    local mobileGui = Instance.new("ScreenGui", player.PlayerGui)
    mobileGui.Name = "CaduMobileV3"
    
    local floatBtn = Instance.new("TextButton", mobileGui)
    floatBtn.Size = UDim2.new(0, 70, 0, 70)
    floatBtn.Position = UDim2.new(1, -85, 0.5, 0)
    floatBtn.BackgroundColor3 = CONFIG.colors.dark
    floatBtn.Text = "⚡"
    floatBtn.TextSize = 35
    floatBtn.TextColor3 = CONFIG.colors.primary
    floatBtn.Draggable = true
    Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", floatBtn).Thickness = 2

    floatBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
        if mainFrame.Visible then
            mainFrame.Position = UDim2.new(0, -340, 0.5, -225)
            TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Position = UDim2.new(0, 20, 0.5, -225)}):Play()
        end
    end)
end

-- SISTEMA DE FECHAR/ABRIR (PC)
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.Insert then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

-- LOOP PRINCIPAL
RunService.RenderStep:Connect(function()
    doReach()
    updatePlayerSphere()
end)

-- INICIALIZAÇÃO
buildMainGUI()
if isMobile then
    buildMobileButton()
end

StarterGui:SetCore("SendNotification", {Title = "Cadu Hub", Text = "Carregado com Sucesso!"})
