--[[
    HEXER HUB - FULL EXPLOIT CONSOLIDATION
    Dev: gabezinho278 (ID: 2962384943)
    Target: High Performance & Game Data Exploitation
]]

local LP = game:GetService("Players").LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- Configurações extraídas dos dados que você mandou
local HexerConfig = {
    Reach = 60, -- Alcance máximo detectado
    Speed = 25, -- Velocidade otimizada
    Jump = 70,
    NoClip = true
}

-- [ FUNÇÕES DE ELITE CONSOLIDADAS ]

-- 1. REACH & HITBOX (O melhor para combate e interação)
RS.Stepped:Connect(function()
    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
        if player ~= LP and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            hrp.Size = Vector3.new(12, 12, 12) -- Expansão massiva de hitbox
            hrp.Transparency = 0.7
            hrp.CanCollide = false
        end
    end
end)

-- 2. SUPREME GRABBING & INTERACT (Sem tempo de espera)
local function EnableInteractions()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            v.HoldDuration = 0
            v.MaxActivationDistance = HexerConfig.Reach
        end
    end
end
workspace.DescendantAdded:Connect(function(d)
    if d:IsA("ProximityPrompt") then d.HoldDuration = 0 end
end)

-- 3. PHYSICS & MOVEMENT (Bypass de Ragdoll e Queda)
local function PhysicsBypass(char)
    local hum = char:WaitForChild("Humanoid")
    hum.WalkSpeed = HexerConfig.Speed
    hum.JumpPower = HexerConfig.Jump
    
    -- Desativa estados que travam o personagem
    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
end

-- 4. BOBOING & CAMERA (Visual Profissional)[cite: 1]
RS.RenderStepped:Connect(function()
    local char = LP.Character
    if char and char:FindFirstChild("Humanoid") and char.Humanoid.MoveDirection.Magnitude > 0 then
        local t = tick()
        char.Humanoid.CameraOffset = Vector3.new(math.cos(t*12)*0.1, math.abs(math.sin(t*12))*0.1, 0)
    end
end)

-- [ INICIALIZAÇÃO DIRETA ]
LP.CharacterAdded:Connect(PhysicsBypass)
if LP.Character then PhysicsBypass(LP.Character) end
EnableInteractions()

-- Anti-Lag e Limpeza de Mapas (Dados de Performance)[cite: 1]
for _, v in pairs(workspace:GetDescendants()) do
    if v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = false end
end

print("🔥 HEXER HUB: TUDO ATIVADO. SEM LIMITES.")