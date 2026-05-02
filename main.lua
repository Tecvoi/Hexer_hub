local UIS = game:GetService("UserInputService")
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()

local Window = Library:CreateWindow({
    Title = 'HEXER HUB | a!sob',
    Center = true,
    AutoShow = true,
    TabPadding = 8
})

local Tabs = {
    Main = Window:AddTab('Combat'),
    ['Settings'] = Window:AddTab('Settings'),
}

local LeftGroupBox = Tabs.Main:AddLeftGroupbox('Throwing Settings')

-- Toggle do Super Strength
LeftGroupBox:AddToggle('SuperStrength', {
    Text = 'Super Strength',
    Default = false,
    Tooltip = 'Arremessa forte com o Botão Direito',
})

-- Slider de Força
LeftGroupBox:AddSlider('StrengthPower', {
    Text = 'Throwing Power',
    Default = 742,
    Min = 0,
    Max = 40000,
    Rounding = 0,
})

-- LOGICA DE ARREMESSO (Botão Direito)
UIS.InputBegan:Connect(function(input, processed)
    if not processed and input.UserInputType == Enum.UserInputType.MouseButton2 then
        if Toggles.SuperStrength.Value then
            local char = game.Players.LocalPlayer.Character
            if char then
                -- Procura o que você está segurando
                for _, obj in pairs(char:GetDescendants()) do
                    if obj:IsA("Weld") or obj:IsA("ManualWeld") then
                        local victim = obj.Part1 or obj.Part0
                        if victim and victim.Parent:FindFirstChild("Humanoid") then
                            obj:Destroy() -- Solta a pessoa
                            
                            -- Aplica o "Tiro"
                            local bv = Instance.new("BodyVelocity")
                            bv.Velocity = char.HumanoidRootPart.CFrame.LookVector * (Options.StrengthPower.Value / 10)
                            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                            bv.Parent = victim
                            game.Debris:AddItem(bv, 0.2)
                        end
                    end
                end
            end
        end
    end
end)

Library:Notify("Hexer Hub Carregado! Use o Botão Direito para arremessar.")