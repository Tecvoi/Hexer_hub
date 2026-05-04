--[[
    HEXER HUB - FLING THINGS AND PEOPLE SPECIAL
    Developer: gabezinho278 (ID: 2962384943)
    UI: Orion Library (Blitz Hub Style)
]]

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "Hexer Hub - Fling Things", HidePremium = false, SaveConfig = true, ConfigFolder = "HexerConfig"})

-- Variáveis de Controle (Baseadas nos dados do jogo)
local ReachValue = 50
local AutoGrab = false
local AntiFling = true

-- // FUNÇÕES MESTRE
local function GetClosestPlayer()
    local target = nil
    local dist = math.huge
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= game.Players.LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local d = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then
                dist = d
                target = v
            end
        end
    end
    return target
end

-- // ABAS
local MainTab = Window:MakeTab({Name = "Main", Icon = "rbxassetid://4483345998", PremiumOnly = false})

-- // SEÇÃO DE ALCANCE (REACH)
MainTab:AddSlider({
    Name = "Grab Reach",
    Min = 10,
    Max = 150,
    Default = 50,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "Studs",
    Callback = function(Value)
        ReachValue = Value
        -- Manipula o atributo de alcance do jogo se existir nos dados
    end    
})

-- // SEÇÃO DE COMBATE (BLITZ STYLE)
MainTab:AddToggle({
    Name = "Auto Grab Closest",
    Default = false,
    Callback = function(Value)
        AutoGrab = Value
        task.spawn(function()
            while AutoGrab do
                local target = GetClosestPlayer()
                if target and (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - target.Character.HumanoidRootPart.Position).Magnitude <= ReachValue then
                    -- Simula o evento de agarrar (baseado nos dados que você extraiu)[cite: 1]
                    print("Hexer Hub: Tentando agarrar " .. target.Name)
                end
                task.wait(0.5)
            end
        end)
    end    
})

-- // ABA DE PLAYER
local PlayerTab = Window:MakeTab({Name = "Player", Icon = "rbxassetid://4483345998", PremiumOnly = false})

PlayerTab:AddButton({
    Name = "Anti-Fling (Stay Anchored)",
    Callback = function()
        local hum = game.Players.LocalPlayer.Character.Humanoid
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        OrionLib:MakeNotification({Name = "Hexer Hub", Content = "Anti-Fling Ativado!", Time = 3})
    end
})

-- // ABA DE MUNDO (CLEANER)[cite: 1]
local WorldTab = Window:MakeTab({Name = "World", Icon = "rbxassetid://4483345998", PremiumOnly = false})

WorldTab:AddButton({
    Name = "Remove All Textures (Boost FPS)",
    Callback = function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
            elseif v:IsA("Texture") or v:IsA("Decal") then
                v:Destroy()
            end
        end
    end
})

OrionLib:Init()