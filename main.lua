--[[
    HEXER HUB - Oficial
    Repositório: Tecvoi/Hexer_hub
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "hexer_hub | a!sob",
   LoadingTitle = "Iniciando Hexer Hub...",
   LoadingSubtitle = "by Tecvoi",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "HexerHubData"
   },
   Theme = "Default" -- Podemos ajustar as cores manualmente depois
})

-- ABAS (Baseadas nas suas prints)
local MainTab = Window:CreateTab("Main", 4483362458) -- Ícone de casa
local PlayerTab = Window:CreateTab("LocalPlayer", 4483362458) -- Ícone de usuário
local VisualTab = Window:CreateTab("Visual", 4483362458)
local AlvoTab = Window:CreateTab("Alvo", 4483362458)

-- SEÇÃO DE COMBATE (image_95683c.png)
MainTab:CreateSection("Combat")

MainTab:CreateToggle({
   Name = "Super Strength",
   CurrentValue = false,
   Callback = function(Value)
      _G.SuperStrength = Value
      task.spawn(function()
         while _G.SuperStrength do
            -- Lógica para aumentar a força de arremesso
            -- No jogo "Arremessa Coisas", isso geralmente envolve mudar atributos do corpo
            task.wait(0.5)
         end
      end)
   end,
})

MainTab:CreateSlider({
   Name = "Strength",
   Range = {0, 40000},
   Increment = 100,
   Suffix = " Power",
   CurrentValue = 742,
   Callback = function(Value)
      -- Ajusta o valor da força global
      _G.StrengthValue = Value
   end,
})

-- SEÇÃO LOCAL PLAYER (image_956c3c.png)
PlayerTab:CreateSection("Defence")

PlayerTab:CreateToggle({
   Name = "Anti-Grab",
   CurrentValue = true,
   Callback = function(Value)
      _G.AntiGrab = Value
      game:GetService("RunService").Stepped:Connect(function()
         if _G.AntiGrab and game.Players.LocalPlayer.Character then
            for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
               if v:IsA("Weld") or v:IsA("ManualWeld") then
                  v:Destroy()
               end
            end
         end
      end)
   end,
})