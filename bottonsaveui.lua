-- Script Local/Exploit - Troca textura apenas visual para você
-- Workspace.TPS.texture -> Cor visível só no client

local RunService = game:GetService("RunService")

-- CONFIGURAÇÕES
local COR_TESTE = Color3.fromRGB(255, 0, 100) -- Rosa/Vermelho neon
-- Outras opções:
-- Color3.fromRGB(255, 0, 0)     -- Vermelho puro
-- Color3.fromRGB(255, 105, 180) -- Rosa choque
-- Color3.fromRGB(255, 20, 147)  -- Rosa profundo

local function modificarTextura()
    local tps = workspace:FindFirstChild("TPS")
    if not tps then return end
    
    local textureObj = tps:FindFirstChild("texture")
    if not textureObj then return end
    
    -- Se for uma Part/MeshPart/Union (objeto 3D)
    if textureObj:IsA("BasePart") then
        -- Cria um Highlight ao redor (visível só local)
        local highlight = textureObj:FindFirstChild("LocalHighlight")
        if not highlight then
            highlight = Instance.new("Highlight")
            highlight.Name = "LocalHighlight"
            highlight.FillColor = COR_TESTE
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.FillTransparency = 0.3
            highlight.OutlineTransparency = 0
            highlight.Parent = textureObj
        end
        
        -- Muda a cor do objeto localmente
        textureObj.Color = COR_TESTE
        textureObj.Material = Enum.Material.Neon
        
        print("✅ Objeto pintado de ROSA/VERMELHO (só você vê)")
    end
    
    -- Se for um Decal/Texture, troca para cor sólida via SurfaceGui local
    if textureObj:IsA("Decal") or textureObj:IsA("Texture") then
        local parent = textureObj.Parent
        textureObj.Transparency = 1 -- Esconde original localmente
        
        -- Cria Frame colorido por cima (só no client)
        local surfaceGui = parent:FindFirstChild("LocalColorOverlay")
        if not surfaceGui then
            surfaceGui = Instance.new("SurfaceGui")
            surfaceGui.Name = "LocalColorOverlay"
            surfaceGui.Face = textureObj:IsA("Decal") and Enum.NormalId.Front or textureObj.Face
            surfaceGui.CanvasSize = Vector2.new(100, 100)
            surfaceGui.Parent = parent
            
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 1, 0)
            frame.BackgroundColor3 = COR_TESTE
            frame.BorderSizePixel = 0
            frame.Parent = surfaceGui
        end
        
        print("✅ Textura trocada por COR SÓLIDA ROSA (só você vê)")
    end
end

-- Aplica imediatamente
modificarTextura()

-- Loop para garantir que fique aplicado (caso o jogo resete)
RunService.Heartbeat:Connect(function()
    modificarTextura()
end)

-- Se o objeto for criado depois
workspace.DescendantAdded:Connect(function(desc)
    if desc.Name == "texture" and desc.Parent and desc.Parent.Name == "TPS" then
        wait(0.1)
        modificarTextura()
    end
end)

print("🎨 Script de textura local ativo - Cor: ROSA/VERMELHO")
 
