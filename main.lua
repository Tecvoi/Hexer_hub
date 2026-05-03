--[[
FTAP Consolidated Script (Blitz Hub Style)
Autor: User (Baseado em lógicas públicas de Velocity, Clone e Teleport)
Data: 03/05/2026
Uso: Copie para VSCode, edite as CONFIG e suba ao GitHub.
Execução: loadstring(game:HttpGet("SEU_LINK_RAW_AQUI"))()
]]

-- ==============================================================================
-- ⚙️ CONFIGURAÇÕES GERAIS (EDITE AQUI)
-- ==============================================================================
local CONFIG = {
Mode = "All", -- Opções: "Velocity", "Clone", "Teleport", "All"
FlingStrength = 3000, -- Força do lançamento (500 a 10000)
AntiGrabEnabled = true, -- Ativa proteção contra agarres
AutoClean = true, -- Remove objetos criados após 2 segundos

-- Keybinds (Teclas de Atalho)
Keys = {
Fling = Enum.KeyCode.F, -- Lança alvo mais próximo (Velocity)
CloneFling = Enum.KeyCode.G, -- Lança todos via Clone/Torque
TeleFling = Enum.KeyCode.T, -- Teleporta e lança todos
ToggleAntiGrab = Enum.KeyCode.Z -- Liga/Desliga Anti-Grab
}
}

-- ==============================================================================
-- 🔧 SERVIÇOS E VARIÁVEIS LOCAIS
-- ==============================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local ActiveConnections = {} -- Para limpar conexões se necessário

-- ==============================================================================
-- 🛡️ SISTEMA ANTI-GRAB (Proteção Passiva)
-- ==============================================================================
local AntiGrabConnection = nil

local function StartAntiGrab()
if not CONFIG.AntiGrabEnabled then return end

AntiGrabConnection = RunService.Heartbeat:Connect(function()
if Character and HumanoidRootPart then
-- Empurra levemente para cima para evitar travamento em grabs
HumanoidRootPart.CFrame = HumanoidRootPart.CFrame * CFrame.new(0, 0.5, 0)
end
end)
print(" Anti-Grab ativado.")
end

local function StopAntiGrab()
if AntiGrabConnection then
AntiGrabConnection:Disconnect()
AntiGrabConnection = nil
print(" Anti-Grab desativado.")
end
end

-- ==============================================================================
-- 🚀 MÉTODO 1: BODY VELOCITY (Físico Direto)
-- ==============================================================================
local function GetClosestTarget()
local closestDist = math.huge
local closestTarget = nil

for _, player in ipairs(Players:GetPlayers()) do
if player ~= LocalPlayer and player.Character then
local head = player.Character:FindFirstChild("Head")
if head then
local dist = (head.Position - HumanoidRootPart.Position).Magnitude
if dist < closestDist then
closestDist = dist
closestTarget = head
end
end
end
end
return closestTarget
end

local function FlingVelocity(targetPart)
if not targetPart or not targetPart:IsA("BasePart") then return end

local direction = (targetPart.Position - HumanoidRootPart.Position).Unit
local velocity = direction * CONFIG.FlingStrength

local bodyVel = Instance.new("BodyVelocity")
bodyVel.Velocity = velocity
bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
bodyVel.Parent = targetPart

if CONFIG.AutoClean then
Debris:AddItem(bodyVel, 0.5)
end
end

-- ==============================================================================
-- 🧬 MÉTODO 2: CLONE + TORQUE (Simulação de Física)
-- ==============================================================================
local function FlingClone(targetPlayer)
local targetChar = targetPlayer.Character
if not targetChar or not Character then return end

local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
if not targetHRP then return end

-- Clona o personagem local para usar como âncora de força
local clone = Character:Clone()
clone.Name = "FlingClone_".. targetPlayer.Name
clone.Parent = workspace

-- Posiciona o clone atrás do alvo
clone:PivotTo(targetHRP.CFrame * CFrame.new(0, 0, -10))

-- Cria a restrição física
local ballSocket = Instance.new("BallSocketConstraint")
ballSocket.Part0 = targetHRP
ballSocket.Part1 = clone:FindFirstChild("HumanoidRootPart")
ballSocket.Parent = workspace

-- Aplica torque giratório violento
local bodyGyro = Instance.new("BodyGyro")
bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
bodyGyro.P = 5000
bodyGyro.D = 0
bodyGyro.Parent = targetHRP

local connection
connection = RunService.Heartbeat:Connect(function()
if not targetHRP or not targetHRP.Parent then
connection:Disconnect()
return
end
bodyGyro.CFrame = targetHRP.CFrame * CFrame.Angles(0, math.rad(180), 0)
end)

-- Limpeza automática
if CONFIG.AutoClean then
delay(2, function()
if ballSocket then ballSocket:Destroy() end
if clone then clone:Destroy() end
if bodyGyro then bodyGyro:Destroy() end
connection:Disconnect()
end)
end
end

-- ==============================================================================
-- 📍 MÉTODO 3: TELEPORT + IMPULSO (Instantâneo)
-- ==============================================================================
local function FlingTeleport(targetPlayer)
local targetChar = targetPlayer.Character
if not targetChar then return end

local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
if not targetHRP then return end

-- Teleporta o alvo para 5 unidades na frente do jogador
local newPos = HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
targetHRP.CFrame = newPos

-- Aplica impulso vertical imediato
local bodyVel = Instance.new("BodyVelocity")
bodyVel.Velocity = Vector3.new(0, CONFIG.FlingStrength / 10, 0)
bodyVel.MaxForce = Vector3.new(0, math.huge, 0)
bodyVel.Parent = targetHRP

if CONFIG.AutoClean then
Debris:AddItem(bodyVel, 0.3)
end
end

-- ==============================================================================
-- ⌨️ SISTEMA DE INPUT (Teclado)
-- ==============================================================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
if gameProcessed then return end -- Ignora se estiver digitando no chat

-- Toggle Anti-Grab
if input.KeyCode == CONFIG.Keys.ToggleAntiGrab then
if AntiGrabConnection then
StopAntiGrab()
else
StartAntiGrab()
end
end

-- Fling Velocity (Alvo Único)
if input.KeyCode == CONFIG.Keys.Fling and (CONFIG.Mode == "Velocity" or CONFIG.Mode == "All") then
local target = GetClosestTarget()
if target then
FlingVelocity(target)
print(" Velocity Fling executado em: ".. target.Parent.Name)
end
end

-- Fling Clone (Todos os Jogadores)
if input.KeyCode == CONFIG.Keys.CloneFling and (CONFIG.Mode == "Clone" or CONFIG.Mode == "All") then
for _, player in ipairs(Players:GetPlayers()) do
if player ~= LocalPlayer then
FlingClone(player)
end
end
print(" Clone Fling executado em todos.")
end

-- Fling Teleport (Todos os Jogadores)
if input.KeyCode == CONFIG.Keys.TeleFling and (CONFIG.Mode == "Teleport" or CONFIG.Mode == "All") then
for _, player in ipairs(Players:GetPlayers()) do
if player ~= LocalPlayer then
FlingTeleport(player)
end
end
print(" Teleport Fling executado em todos.")
end
end)

-- ==============================================================================
-- 🚀 INICIALIZAÇÃO
-- ==============================================================================
print(" Script carregado com sucesso!")
print(" Modo atual: ".. CONFIG.Mode)
print(" Controles: F (Velocity), G (Clone), T (Teleport), Z (Anti-Grab)")
StartAntiGrab()
