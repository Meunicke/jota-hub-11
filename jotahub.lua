-- SERVICES
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

-- CONFIG
local player = Players.LocalPlayer
local CONFIG = {
    playerReach = 10,
    ballReach = 15,
    autoTouch = true,
    showPlayerSphere = true,
    showBallAura = true,
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
local mainFrame
local playerSphere = nil
local isMobile = UserInputService.TouchEnabled
local HRP = nil

-- UPDATE HRP (Método Arthur V2)
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

-- DO REACH (Método Arthur V2 Corrigido)
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
                    -- Procura TouchInterest nos descendentes da perna
                    for _, descendant in ipairs(rightLeg:GetDescendants()) do
                        if descendant:IsA("TouchTransmitter") or descendant.Name == "TouchInterest" then
                            firetouchinterest(ball, descendant.Parent, 0)
                            firetouchinterest(ball, descendant.Parent, 1)
                        end
                    end
                    -- Touch na perna especificamente
                    firetouchinterest(ball, rightLeg, 0)
                    firetouchinterest(ball, rightLeg, 1)
                end)
            end
        end
    end
end

-- ANIMATE BUTTON
local function animateButton(btn)
    local original = btn.BackgroundColor3
    TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.new(1, 1, 1)}):Play()
    task.wait(0.1)
    TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = original}):Play()
end

-- BUILD GUI
function buildMainGUI()
    local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    gui.Name = "CaduHubV3"
    gui.ResetOnSpawn = false

    mainFrame = Instance.new("Frame", gui)
    mainFrame.Size = UDim2.new(0, 320, 0, 450)
    mainFrame.Position = UDim2.new(0, 20, 0.5, -225)
    mainFrame.BackgroundColor3 = CONFIG.colors.dark
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = true
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 16)
    
    local stroke = Instance.new("UIStroke", mainFrame)
    stroke.Color = CONFIG.colors.primary
    stroke.Thickness = 2

    -- PLAYER REACH CONTROLS
    local pValue = Instance.new("TextLabel", mainFrame)
    pValue.Size = UDim2.new(1, 0, 0, 30)
    pValue.Position = UDim2.new(0, 0, 0, 80)
    pValue.Text = CONFIG.playerReach .. " studs"
    pValue.TextColor3 = Color3.new(1, 1, 1)
    pValue.BackgroundTransparency = 1
    pValue.Font = Enum.Font.GothamBold

    local plusP = Instance.new("TextButton", mainFrame)
    plusP.Size = UDim2.new(0, 40, 0, 40)
    plusP.Position = UDim2.new(0.7, 0, 0, 110)
    plusP.Text = "+"
    plusP.BackgroundColor3 = CONFIG.colors.primary
    plusP.MouseButton1Click:Connect(function()
        animateButton(plusP)
        CONFIG.playerReach = math.min(150, CONFIG.playerReach + 1)
        pValue.Text = CONFIG.playerReach .. " studs"
    end)

    local minusP = Instance.new("TextButton", mainFrame)
    minusP.Size = UDim2.new(0, 40, 0, 40)
    minusP.Position = UDim2.new(0.2, 0, 0, 110)
    minusP.Text = "-"
    minusP.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    minusP.MouseButton1Click:Connect(function()
        animateButton(minusP)
        CONFIG.playerReach = math.max(1, CONFIG.playerReach - 1)
        pValue.Text = CONFIG.playerReach .. " studs"
    end)

    -- AUTO TOUCH BUTTON
    local autoTouchBtn = Instance.new("TextButton", mainFrame)
    autoTouchBtn.Size = UDim2.new(0, 200, 0, 40)
    autoTouchBtn.Position = UDim2.new(0.5, -100, 0, 250)
    autoTouchBtn.Text = "AUTO TOUCH: ON"
    autoTouchBtn.BackgroundColor3 = CONFIG.colors.primary
    autoTouchBtn.MouseButton1Click:Connect(function()
        CONFIG.autoTouch = not CONFIG.autoTouch
        autoTouchBtn.Text = CONFIG.autoTouch and "AUTO TOUCH: ON" or "AUTO TOUCH: OFF"
        autoTouchBtn.BackgroundColor3 = CONFIG.autoTouch and CONFIG.colors.primary or Color3.fromRGB(100, 100, 100)
        animateButton(autoTouchBtn)
    end)

    -- HIDE BUTTON
    local hideBtn = Instance.new("TextButton", mainFrame)
    hideBtn.Size = UDim2.new(0, 200, 0, 40)
    hideBtn.Position = UDim2.new(0.5, -100, 0, 310)
    hideBtn.Text = "ESCONDER"
    hideBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    hideBtn.MouseButton1Click:Connect(function()
        animateButton(hideBtn)
        mainFrame.Visible = false
    end)
end

-- BOTÃO MOBILE FLASH
local function buildMobileButton()
    local mobileGui = Instance.new("ScreenGui", player.PlayerGui)
    mobileGui.Name = "CaduMobileV3"
    
    local floatBtn = Instance.new("TextButton", mobileGui)
    floatBtn.Size = UDim2.new(0, 75, 0, 75)
    floatBtn.Position = UDim2.new(1, -95, 1, -130)
    floatBtn.BackgroundColor3 = CONFIG.colors.dark
    floatBtn.Text = "⚡"
    floatBtn.TextSize = 40
    floatBtn.Font = Enum.Font.GothamBlack
    floatBtn.TextColor3 = CONFIG.colors.primary
    Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(1, 0)
    
    local stroke = Instance.new("UIStroke", floatBtn)
    stroke.Color = CONFIG.colors.primary
    stroke.Thickness = 3

    floatBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
        if mainFrame.Visible then
            TweenService:Create(mainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back), {
                Position = UDim2.new(0, 20, 0.5, -225)
            }):Play()
        end
    end)
end

-- CORREÇÃO DO ERRO DO CONSOLE: RenderStepped
RunService.RenderStepped:Connect(function()
    doReach()
end)

-- INIT
buildMainGUI()
if isMobile then buildMobileButton() end
