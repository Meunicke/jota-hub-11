
script_content = '''
--========================================
--  Football UI Saver & Restorer
--  Salva e restaura posições dos botões de habilidades
--========================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Configurações
local CONFIG = {
    CONFIG_FILE = "FootballUI_Positions.json",
    BUTTON_NAMES = {
        -- Botões principais de habilidades (os grandes da direita)
        "Chute", "Passe", "Longo",
        "Dominar", "Esquerda", "Direita", "Alto",
        "Chute Baixo", "Lambreta", "Chapéu", "Calcanhar",
        "Voleio", "Direita Atrás", "Esquerda Atrás", "Conduzir",
        "Chute Falso", "Arraste Para Trás", "Cabeceio", "Bicicleta",
        -- Botões de controle
        "D", "R"
    },
    ANIMATION_SPEED = 0.3,
    DRAG_TRANSPARENCY = 0.5
}

-- Estado do script
local State = {
    isEditMode = false,
    savedPositions = {},
    originalPositions = {},
    uiElements = {},
    dragConnection = nil,
    selectedButton = nil,
    dragOffset = Vector2.new(0, 0)
}

--========================================
--  SISTEMA DE CONFIGURAÇÃO
--========================================

local ConfigSystem = {}

function ConfigSystem:Save()
    local data = {}
    for name, pos in pairs(State.savedPositions) do
        data[name] = {
            X = pos.X.Scale,
            Y = pos.Y.Scale,
            OffsetX = pos.X.Offset,
            OffsetY = pos.Y.Offset
        }
    end
    
    local success, encoded = pcall(function()
        return HttpService:JSONEncode(data)
    end)
    
    if success then
        writefile(CONFIG.CONFIG_FILE, encoded)
        return true
    end
    return false
end

function ConfigSystem:Load()
    if not isfile(CONFIG.CONFIG_FILE) then
        return false
    end
    
    local success, data = pcall(function()
        return HttpService:JSONDecode(readfile(CONFIG.CONFIG_FILE))
    end)
    
    if success and data then
        State.savedPositions = {}
        for name, posData in pairs(data) do
            State.savedPositions[name] = UDim2.new(
                posData.X or 0, 
                posData.OffsetX or 0,
                posData.Y or 0, 
                posData.OffsetY or 0
            )
        end
        return true
    end
    return false
end

--========================================
--  DETECÇÃO DE BOTÕES
--========================================

local ButtonDetector = {}

function ButtonDetector:FindFootballButtons()
    local found = {}
    
    -- Procura em todas as ScreenGuis
    for _, gui in pairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            self:ScanGui(gui, found)
        end
    end
    
    -- Procura em PlayerGui diretamente
    self:ScanGui(playerGui, found)
    
    return found
end

function ButtonDetector:ScanGui(parent, found)
    for _, obj in pairs(parent:GetDescendants()) do
        if obj:IsA("TextButton") or obj:IsA("ImageButton") then
            local name = obj.Name or ""
            local text = ""
            
            if obj:IsA("TextButton") then
                text = obj.Text or ""
            end
            
            -- Verifica se é um botão de habilidade conhecido
            for _, skillName in ipairs(CONFIG.BUTTON_NAMES) do
                if name:lower():find(skillName:lower()) or 
                   text:lower():find(skillName:lower()) then
                    found[skillName] = obj
                    break
                end
            end
            
            -- Também detecta por tamanho (botões grandes típicos de mobile)
            if obj:IsA("GuiObject") then
                local size = obj.AbsoluteSize
                -- Botões grandes de habilidade geralmente são > 80x80
                if size.X > 80 and size.Y > 80 and size.X < 300 and size.Y < 150 then
                    if not obj:GetAttribute("IsSkillButton") then
                        obj:SetAttribute("IsSkillButton", true)
                        obj:SetAttribute("SkillName", name ~= "" and name or text)
                    end
                end
            end
        end
    end
end

function ButtonDetector:GetAllSkillButtons()
    local buttons = {}
    
    for _, gui in pairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            for _, obj in pairs(gui:GetDescendants()) do
                if obj:GetAttribute("IsSkillButton") or 
                   (obj:IsA("TextButton") and obj.Text and #obj.Text > 2) then
                    local key = obj:GetAttribute("SkillName") or obj.Name or obj.Text
                    if key and key ~= "" then
                        buttons[key] = obj
                    end
                end
            end
        end
    end
    
    return buttons
end

--========================================
--  SISTEMA DE ARRASTAR
--========================================

local DragSystem = {}

function DragSystem:Enable()
    State.isEditMode = true
    
    -- Cria overlay para facilitar o drag
    self:CreateEditOverlay()
    
    State.dragConnection = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or 
           input.UserInputType == Enum.UserInputType.Touch then
            self:UpdateDrag(input)
        end
    end)
    
    -- Conecta eventos de toque/click nos botões
    for name, button in pairs(State.uiElements) do
        self:MakeDraggable(button, name)
    end
end

function DragSystem:Disable()
    State.isEditMode = false
    
    if State.dragConnection then
        State.dragConnection:Disconnect()
        State.dragConnection = nil
    end
    
    if State.editOverlay then
        State.editOverlay:Destroy()
        State.editOverlay = nil
    end
    
    -- Remove conexões de drag dos botões
    for name, button in pairs(State.uiElements) do
        if button:GetAttribute("DragConnections") then
            for _, conn in ipairs(button:GetAttribute("DragConnections")) do
                conn:Disconnect()
            end
            button:SetAttribute("DragConnections", nil)
        end
        button.Active = true -- Reativa cliques normais
    end
end

function DragSystem:MakeDraggable(button, name)
    if not button:IsA("GuiObject") then return end
    
    local connections = {}
    
    -- Evento de início do drag
    table.insert(connections, button.InputBegan:Connect(function(input)
        if not State.isEditMode then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            
            State.selectedButton = button
            local pos = input.Position
            local buttonPos = button.AbsolutePosition
            State.dragOffset = Vector2.new(
                pos.X - buttonPos.X,
                pos.Y - buttonPos.Y
            )
            
            -- Efeito visual
            button.BackgroundTransparency = CONFIG.DRAG_TRANSPARENCY
            self:CreateDragEffect(button)
        end
    end))
    
    -- Evento de fim do drag
    table.insert(connections, button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            
            if State.selectedButton == button then
                -- Salva a nova posição
                State.savedPositions[name] = button.Position
                State.selectedButton = nil
                button.BackgroundTransparency = 0
                self:RemoveDragEffect(button)
                
                -- Feedback visual
                self:ShowSaveFeedback(button)
            end
        end
    end))
    
    button:SetAttribute("DragConnections", connections)
end

function DragSystem:UpdateDrag(input)
    if not State.selectedButton then return end
    
    local button = State.selectedButton
    local screenGui = button:FindFirstAncestorOfClass("ScreenGui")
    if not screenGui then return end
    
    local screenSize = screenGui.AbsoluteSize
    local mousePos = Vector2.new(input.Position.X, input.Position.Y)
    local newPos = mousePos - State.dragOffset
    
    -- Converte para UDim2
    local scaleX = newPos.X / screenSize.X
    local scaleY = newPos.Y / screenSize.Y
    
    -- Limita aos limites da tela
    scaleX = math.clamp(scaleX, 0, 0.9)
    scaleY = math.clamp(scaleY, 0, 0.9)
    
    button.Position = UDim2.new(scaleX, 0, scaleY, 0)
end

function DragSystem:CreateDragEffect(button)
    if button:FindFirstChild("DragHighlight") then return end
    
    local highlight = Instance.new("UIStroke")
    highlight.Name = "DragHighlight"
    highlight.Color = Color3.fromRGB(0, 255, 255)
    highlight.Thickness = 3
    highlight.Transparency = 0.3
    highlight.Parent = button
end

function DragSystem:RemoveDragEffect(button)
    local highlight = button:FindFirstChild("DragHighlight")
    if highlight then
        highlight:Destroy()
    end
end

function DragSystem:ShowSaveFeedback(button)
    local feedback = Instance.new("TextLabel")
    feedback.Name = "SaveFeedback"
    feedback.Size = UDim2.new(0, 100, 0, 30)
    feedback.Position = UDim2.new(0.5, -50, 0, -40)
    feedback.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    feedback.Text = "Posição Salva!"
    feedback.TextColor3 = Color3.new(1, 1, 1)
    feedback.TextSize = 14
    feedback.Font = Enum.Font.GothamBold
    feedback.Parent = button
    
    -- Animação de fade out
    TweenService:Create(feedback, TweenInfo.new(1), {
        TextTransparency = 1,
        BackgroundTransparency = 1
    }):Play()
    
    game:GetService("Debris"):AddItem(feedback, 1)
end

function DragSystem:CreateEditOverlay()
    if State.editOverlay then return end
    
    local overlay = Instance.new("ScreenGui")
    overlay.Name = "FootballUI_Editor"
    overlay.DisplayOrder = 9999
    overlay.ResetOnSpawn = false
    
    local frame = Instance.new("Frame")
    frame.Name = "EditFrame"
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 0.8
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.Parent = overlay
    
    local label = Instance.new("TextLabel")
    label.Name = "EditLabel"
    label.Size = UDim2.new(0, 400, 0, 50)
    label.Position = UDim2.new(0.5, -200, 0, 20)
    label.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    label.Text = "🎮 MODO EDIÇÃO: Arraste os botões para reposicionar"
    label.TextColor3 = Color3.fromRGB(255, 255, 0)
    label.TextSize = 18
    label.Font = Enum.Font.GothamBold
    label.Parent = frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = label
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 0)
    stroke.Thickness = 2
    stroke.Parent = label
    
    overlay.Parent = playerGui
    State.editOverlay = overlay
end

--========================================
--  INTERFACE DO SCRIPT
--========================================

local ScriptUI = {}

function ScriptUI:Create()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FootballUI_Saver"
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 10000
    
    -- Frame principal
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 300, 0, 400)
    mainFrame.Position = UDim2.new(0, 20, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 150, 255)
    stroke.Thickness = 2
    stroke.Parent = mainFrame
    
    -- Título
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    title.Text = "⚽ Football UI Saver"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = title
    
    -- Botão de Editar
    local editBtn = self:CreateButton(
        mainFrame, 
        "✏️ Editar Posições", 
        Color3.fromRGB(0, 120, 255),
        UDim2.new(0.5, -130, 0, 70)
    )
    
    -- Botão de Salvar
    local saveBtn = self:CreateButton(
        mainFrame, 
        "💾 Salvar Config", 
        Color3.fromRGB(0, 200, 100),
        UDim2.new(0.5, 10, 0, 70)
    )
    
    -- Botão de Restaurar
    local restoreBtn = self:CreateButton(
        mainFrame, 
        "🔄 Restaurar Posições", 
        Color3.fromRGB(255, 150, 0),
        UDim2.new(0.5, -130, 0, 130)
    )
    
    -- Botão de Reset
    local resetBtn = self:CreateButton(
        mainFrame, 
        "↩️ Reset Padrão", 
        Color3.fromRGB(255, 80, 80),
        UDim2.new(0.5, 10, 0, 130)
    )
    
    -- Botão de Esconder/Mostrar
    local toggleBtn = self:CreateButton(
        mainFrame, 
        "👁️ Esconder/Mostrar UI", 
        Color3.fromRGB(150, 80, 255),
        UDim2.new(0.5, -130, 0, 190)
    )
    
    -- Botão de Minimizar
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "MinimizeBtn"
    minimizeBtn.Size = UDim2.new(0, 40, 0, 40)
    minimizeBtn.Position = UDim2.new(1, -50, 0, 5)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    minimizeBtn.Text = "−"
    minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
    minimizeBtn.TextSize = 24
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.Parent = mainFrame
    
    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 8)
    minCorner.Parent = minimizeBtn
    
    -- Status Label
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "Status"
    statusLabel.Size = UDim2.new(1, -20, 0, 80)
    statusLabel.Position = UDim2.new(0, 10, 0, 260)
    statusLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    statusLabel.Text = "Status: Aguardando...\\nBotões detectados: 0"
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    statusLabel.TextSize = 14
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextWrapped = true
    statusLabel.Parent = mainFrame
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 8)
    statusCorner.Parent = statusLabel
    
    -- Botão flutuante (quando minimizado)
    local floatBtn = Instance.new("TextButton")
    floatBtn.Name = "FloatButton"
    floatBtn.Size = UDim2.new(0, 60, 0, 60)
    floatBtn.Position = UDim2.new(0, 20, 0.5, -30)
    floatBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    floatBtn.Text = "⚽"
    floatBtn.TextSize = 30
    floatBtn.Visible = false
    floatBtn.Parent = screenGui
    
    local floatCorner = Instance.new("UICorner")
    floatCorner.CornerRadius = UDim.new(1, 0)
    floatCorner.Parent = floatBtn
    
    local floatStroke = Instance.new("UIStroke")
    floatStroke.Color = Color3.new(1, 1, 1)
    floatStroke.Thickness = 3
    floatStroke.Parent = floatBtn
    
    -- Eventos
    local minimized = false
    
    minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        mainFrame.Visible = not minimized
        floatBtn.Visible = minimized
    end)
    
    floatBtn.MouseButton1Click:Connect(function()
        minimized = false
        mainFrame.Visible = true
        floatBtn.Visible = false
    end)
    
    editBtn.MouseButton1Click:Connect(function()
        if not State.isEditMode then
            DragSystem:Enable()
            statusLabel.Text = "Status: ✅ MODO EDIÇÃO ATIVO\\nArraste os botões livremente!"
            statusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
            editBtn.Text = "✅ Finalizar Edição"
            editBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        else
            DragSystem:Disable()
            statusLabel.Text = "Status: Edição finalizada\\nPosições prontas para salvar"
            statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            editBtn.Text = "✏️ Editar Posições"
            editBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        end
    end)
    
    saveBtn.MouseButton1Click:Connect(function()
        if ConfigSystem:Save() then
            statusLabel.Text = "Status: 💾 Configuração salva!\\nArquivo: " .. CONFIG.CONFIG_FILE
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        else
            statusLabel.Text = "Status: ❌ Erro ao salvar!"
            statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        end
    end)
    
    restoreBtn.MouseButton1Click:Connect(function()
        if ConfigSystem:Load() then
            self:ApplySavedPositions()
            statusLabel.Text = "Status: 🔄 Posições restauradas!"
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        else
            statusLabel.Text = "Status: ❌ Nenhum arquivo de config encontrado!"
            statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        end
    end)
    
    resetBtn.MouseButton1Click:Connect(function()
        for name, pos in pairs(State.originalPositions) do
            if State.uiElements[name] then
                State.uiElements[name].Position = pos
            end
        end
        State.savedPositions = {}
        statusLabel.Text = "Status: ↩️ Posições resetadas para o padrão!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
    end)
    
    toggleBtn.MouseButton1Click:Connect(function()
        local footballUI = self:FindFootballUI()
        if footballUI then
            footballUI.Enabled = not footballUI.Enabled
            statusLabel.Text = footballUI.Enabled and 
                "Status: 👁️ UI do futebol visível" or 
                "Status: 🚫 UI do futebol escondida"
        end
    end)
    
    screenGui.Parent = playerGui
    
    -- Atualiza contador de botões
    spawn(function()
        while screenGui.Parent do
            wait(2)
            local count = 0
            for _ in pairs(State.uiElements) do count = count + 1 end
            if not minimized then
                statusLabel.Text = statusLabel.Text:gsub("Botões detectados: %d+", "Botões detectados: " .. count)
            end
        end
    end)
    
    return screenGui
end

function ScriptUI:CreateButton(parent, text, color, position)
    local btn = Instance.new("TextButton")
    btn.Name = text:gsub("[^%w]", "") .. "Btn"
    btn.Size = UDim2.new(0, 120, 0, 45)
    btn.Position = position
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamBold
    btn.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.new(1, 1, 1)
    stroke.Transparency = 0.5
    stroke.Thickness = 1
    stroke.Parent = btn
    
    -- Efeito hover
            btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
        end)
        
        return btn
    end

    function ScriptUI:FindFootballUI()
        for _, gui in pairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name:lower():find("football") or 
               gui.Name:lower():find("soccer") or
               gui.Name:lower():find("skill") then
                return gui
            end
        end
        return nil
    end

    function ScriptUI:ApplySavedPositions()
        for name, pos in pairs(State.savedPositions) do
            if State.uiElements[name] then
                TweenService:Create(State.uiElements[name], TweenInfo.new(CONFIG.ANIMATION_SPEED), {
                    Position = pos
                }):Play()
            end
        end
    end

    --========================================
    --  INICIALIZAÇÃO
    --========================================

    local function Initialize()
        -- Aguarda o jogo carregar completamente
        repeat wait() until playerGui
        
        -- Detecta botões iniciais
        wait(2) -- Aguarda a UI do jogo carregar
        
        State.uiElements = ButtonDetector:GetAllSkillButtons()
        
        -- Salva posições originais
        for name, button in pairs(State.uiElements) do
            State.originalPositions[name] = button.Position
        end
        
        -- Carrega configuração salva
        if ConfigSystem:Load() then
            ScriptUI:ApplySavedPositions()
        end
        
        -- Cria interface
        ScriptUI:Create()
        
        -- Monitora novos botões
        playerGui.DescendantAdded:Connect(function(descendant)
            if descendant:IsA("TextButton") or descendant:IsA("ImageButton") then
                wait(0.5)
                local newButtons = ButtonDetector:GetAllSkillButtons()
                for name, button in pairs(newButtons) do
                    if not State.uiElements[name] then
                        State.uiElements[name] = button
                        State.originalPositions[name] = button.Position
                        
                        -- Aplica posição salva se existir
                        if State.savedPositions[name] then
                            button.Position = State.savedPositions[name]
                        end
                    end
                end
            end
        end)
        
        print("⚽ Football UI Saver carregado!")
        print("Botões detectados:", #State.uiElements)
    end

    -- Inicia
    Initialize()

    -- Retorna funções úteis para uso externo
    getgenv().FootballUI = {
        Save = function() return ConfigSystem:Save() end,
        Load = function() 
            local success = ConfigSystem:Load()
            if success then ScriptUI:ApplySavedPositions() end
            return success
        end,
        EditMode = function(enable)
            if enable then DragSystem:Enable() else DragSystem:Disable() end
        end,
        GetButtons = function() return State.uiElements end,
        Reset = function()
            for name, pos in pairs(State.originalPositions) do
                if State.uiElements[name] then
                    State.uiElements[name].Position = pos
                end
            end
            State.savedPositions = {}
        end
}
