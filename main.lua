--[[
    HEXER HUB - FIX EDITION
    Developer: gabezinho278 (ID: 2962384943)
    Game: Fling Things and People
    UI: Orion Library
]]

-- 1. Carregamento Seguro da Orion Library
local success, OrionLib = pcall(function()
    return loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
end)

if not success or not OrionLib then
    warn("Hexer Hub: Erro ao carregar a Orion Library! Verifique sua conexão.")
    return
end

-- 2. Criação da Janela (Blitz Hub Style)
local Window = OrionLib:MakeWindow({
    Name = "Hexer Hub - Fling Things", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "HexerHubV3",
    IntroEnabled = true, -- Ativa a intro para você ver se carregou
    IntroText = "Hexer Hub by gabezinho278"[cite: 1]
})

-- 3. Variáveis de Controle
local ReachValue = 50
local AutoGrab = false

-- 4. Abas Principais
local MainTab = Window:MakeTab({Name = "Main", Icon = "rbxassetid://4483345998", PremiumOnly = false})

MainTab:AddSlider({
    Name = "Reach Distance",
    Min = 5,
    Max = 300,
    Default = 50,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "Studs",
    Callback = function(Value)
        ReachValue = Value
    end    
})

MainTab:AddToggle({
    Name = "Auto Grab (Blitz Mode)",
    Default = false,
    Callback = function(Value)
        AutoGrab = Value
        task.spawn(function()
            while AutoGrab do
                -- Lógica de Grab baseada nas informações do jogo que você extraiu
                task.wait(0.1)
            end
        end)
    end    
})

-- 5. Player Tab (Anti-Fling & Speed)
local PlayerTab = Window:MakeTab({Name = "Player", Icon = "rbxassetid://4483345998", PremiumOnly = false})

PlayerTab:AddButton({
    Name = "Fix Character (Anti-Ragdoll)",
    Callback = function()
        local hum = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            OrionLib:MakeNotification({Name = "Hexer Hub", Content = "Estados de Física Bloqueados!", Time = 2})
        end
    end
})

-- 6. Inicialização Obrigatória
OrionLib:Init()[cite: 1]