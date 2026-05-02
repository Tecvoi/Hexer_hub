-- [[ CONFIGURAÇÕES DE IDENTIDADE ]]
local AdminID = 2962384943 -- Seu ID (gabezinho278)
local Prefix = ":"
local Player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

-- [[ VERIFICAÇÃO DE ADMIN ]]
local IsAdmin = (Player.UserId == AdminID)

local function Notificar(titulo, texto)
    StarterGui:SetCore("SendNotification", {
        Title = titulo;
        Text = texto;
        Duration = 5;
    })
end

-- Mensagem inicial baseada no status
if not IsAdmin then
    Notificar("Status do Script", "Executado com sucesso, mas você não é admin!")
    -- O script para aqui para quem não for você, mantendo sua "regra de negócio"
    return 
else
    Notificar("Status do Script", "Executado com sucesso, administrador!")
end

-- [[ CRIAÇÃO DA INTERFACE DE ALTA PRIORIDADE ]]
local ScreenGui = Instance.new("ScreenGui", Player.PlayerGui)
ScreenGui.Name = "GabezinhoPanel_Ultra"
ScreenGui.Enabled = false 
ScreenGui.ResetOnSpawn = false 
ScreenGui.DisplayOrder = 2147483647 -- Prioridade máxima (frente de tudo)
ScreenGui.IgnoreGuiInset = true   -- Ignora a barra superior do Roblox
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 450, 0, 320)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ZIndex = 10000

local Corner = Instance.new("UICorner", MainFrame)
Corner.CornerRadius = UDim.new(0, 10)

-- Título da Interface
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 45)
Title.Text = "GABEZINHO278 | ADMIN PANEL"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.BackgroundTransparency = 1
Title.ZIndex = 10001

-- [[ LÓGICA DE ABRIR/FECHAR E MOUSE ]]
local function ToggleUI()
    ScreenGui.Enabled = not ScreenGui.Enabled
    
    if ScreenGui.Enabled then
        -- AO ABRIR: Libera o mouse para mexer na interface
        UserInputService.MouseIconEnabled = true
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    else
        -- AO FECHAR: Trava o mouse no centro (estilo shift lock)
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    end
end

-- Atalho Tecla K
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.K then
        ToggleUI()
    end
end)

-- [[ CATEGORIAS (MENU LATERAL) ]]
local TabContainer = Instance.new("Frame", MainFrame)
TabContainer.Size = UDim2.new(0, 120, 1, -60)
TabContainer.Position = UDim2.new(0, 10, 0, 50)
TabContainer.BackgroundTransparency = 1

local Layout = Instance.new("UIListLayout", TabContainer)
Layout.Padding = UDim.new(0, 8)

local function NewTab(name)
    local btn = Instance.new("TextButton", TabContainer)
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    btn.ZIndex = 10002
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local bAdmin = NewTab("Admin")
local bImortal = NewTab("Imortal")
local bCreditos = NewTab("Créditos")
local bDiscord = NewTab("Discord")

-- [[ LÓGICA DE COMANDOS DE CHAT ]]
Player.Chatted:Connect(function(msg)
    local args = msg:split(" ")
    local cmd = args[1]:lower()

    -- Comando :kill user
    if cmd == Prefix.."kill" then
        local targetName = args[2]
        for _, v in pairs(game.Players:GetPlayers()) do
            if v.Name:lower():sub(1, #targetName) == targetName:lower() then
                if v.Character then v.Character:BreakJoints() end
            end
        end

    -- Comando :bring user
    elseif cmd == Prefix.."bring" then
        local targetName = args[2]
        for _, v in pairs(game.Players:GetPlayers()) do
            if v.Name:lower():sub(1, #targetName) == targetName:lower() then
                if v.Character and Player.Character then
                    v.Character.HumanoidRootPart.CFrame = Player.Character.HumanoidRootPart.CFrame
                end
            end
        end

    -- Comando :chat user "mensagem"
    elseif cmd == Prefix.."chat" then
        local targetName = args[2]
        local text = msg:match('"(.-)"')
        if text then
            if targetName == "all" then
                game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(text, "All")
            else
                for _, v in pairs(game.Players:GetPlayers()) do
                    if v.Name:lower():sub(1, #targetName) == targetName:lower() then
                        -- Simulação de chat forçado (funciona se o script estiver rodando neles)
                        game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(text, "All")
                    end
                end
            end
        end

    -- Comando :kick user
    elseif cmd == Prefix.."kick" then
        local targetName = args[2]
        for _, v in pairs(game.Players:GetPlayers()) do
            if v.Name:lower():sub(1, #targetName) == targetName:lower() and v ~= Player then
                v:Kick("Removido pelo Administrador.")
            end
        end
    end
end)

-- [[ FUNÇÃO IMORTAL ]]
local IsImmortal = false
bImortal.MouseButton1Click:Connect(function()
    IsImmortal = not IsImmortal
    if IsImmortal then
        bImortal.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        Notificar("Imortal", "Modo Deus Ativado!")
    else
        bImortal.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        Notificar("Imortal", "Modo Deus Desativado.")
    end
end)

-- Mantém a vida no máximo se imortal estiver ativo
game:GetService("RunService").Heartbeat:Connect(function()
    if IsImmortal and Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.Health = Player.Character.Humanoid.MaxHealth
    end
end)

-- Créditos e Discord
bCreditos.MouseButton1Click:Connect(function()
    Notificar("Créditos", "Desenvolvido por gabezinho278")
end)

bDiscord.MouseButton1Click:Connect(function()
    print("Discord: gabezinho_comunidade")
    Notificar("Discord", "Informação enviada ao console (F9)")
end)