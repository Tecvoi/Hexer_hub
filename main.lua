-- [[ CONFIGURAÇÕES PRINCIPAIS ]]
local AdminID = 2962384943 -- Seu ID (gabezinho278)
local Prefix = ":"
local Player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- [[ VERIFICAÇÃO DE ADMIN ]]
local IsAdmin = (Player.UserId == AdminID)

local function Notificar(titulo, texto)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = titulo;
        Text = texto;
        Duration = 5;
    })
end

if not IsAdmin then
    Notificar("Aviso", "Executado com sucesso, mas você não é admin!")
    -- O script para aqui para usuários comuns
    return 
end

-- [[ CRIAÇÃO DA INTERFACE ]]
local ScreenGui = Instance.new("ScreenGui", Player.PlayerGui)
ScreenGui.Name = "GabezinhoPanel"
ScreenGui.Enabled = false -- Começa fechado

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 450, 0, 320)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local Corner = Instance.new("UICorner", MainFrame)
Corner.CornerRadius = UDim.new(0, 12)

-- Título
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "GABEZINHO278 - ADMIN PANEL (K TO TOGGLE)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.BackgroundTransparency = 1

-- [[ LÓGICA DE ABRIR/FECHAR E MOUSE ]]
local function ToggleUI()
    ScreenGui.Enabled = not ScreenGui.Enabled
    
    if ScreenGui.Enabled then
        -- AO ABRIR: Libera o mouse
        UserInputService.MouseIconEnabled = true
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    else
        -- AO FECHAR: Trava o mouse (estilo Shift Lock)
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    end
end

-- Detectar Tecla K
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.K then
        ToggleUI()
    end
end)

-- [[ CATEGORIAS DA INTERFACE ]]
local TabContainer = Instance.new("Frame", MainFrame)
TabContainer.Size = UDim2.new(0, 110, 1, -50)
TabContainer.Position = UDim2.new(0, 10, 0, 40)
TabContainer.BackgroundTransparency = 1

local Layout = Instance.new("UIListLayout", TabContainer)
Layout.Padding = UDim.new(0, 5)

local function NewTab(name)
    local btn = Instance.new("TextButton", TabContainer)
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.Gotham
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local bAdmin = NewTab("Admin")
local bImortal = NewTab("Imortal")
local bCreditos = NewTab("Créditos")
local bDiscord = NewTab("Discord")

-- [[ COMANDOS DE CHAT ]]
Player.Chatted:Connect(function(msg)
    local args = msg:split(" ")
    local cmd = args[1]:lower()

    if cmd == Prefix.."kill" then
        local targetName = args[2]
        for _, v in pairs(game.Players:GetPlayers()) do
            if v.Name:lower():sub(1, #targetName) == targetName:lower() then
                v.Character:BreakJoints()
            end
        end
    elseif cmd == Prefix.."chat" then
        local targetName = args[2]
        local text = msg:match('"(.-)"')
        if targetName == "all" then
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(text, "All")
        end
    end
end)

Notificar("Gabezinho Admin", "Script pronto! Aperte K para abrir.")