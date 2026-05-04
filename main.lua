-- ============================================
-- HEXER_HUB - Fling Things and People
-- Credits: Nydev and LeoLeoVip
-- Biblioteca: Fluent UI (COMPLETO)
-- ============================================

-- CARREGAR FLUENT UI
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- DETECÇÃO DE RESOLUÇÃO
local camera = workspace.CurrentCamera
local screenSize = camera.ViewportSize
local screenWidth = screenSize.X
local screenHeight = screenSize.Y

local windowWidth = 600
local windowHeight = 500

if screenWidth >= 2500 or screenHeight >= 1400 then
    windowWidth = 1100
    windowHeight = 900
elseif screenWidth >= 1900 then
    windowWidth = 850
    windowHeight = 700
elseif screenWidth <= 800 then
    windowWidth = 480
    windowHeight = 400
end

print("[Hexer_hub] Resolução: " .. screenWidth .. "x" .. screenHeight)
print("[Hexer_hub] Creditos: Nydev and LeoLeoVip")

-- CRIAR JANELA
local Window = Fluent:CreateWindow({
    Title = "Hexer_hub",
    SubTitle = "by Nydev and LeoLeoVip | Super Strength & Object Grab",
    TabWidth = 160,
    Size = UDim2.new(0, windowWidth, 0, windowHeight),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

-- CORREÇÃO DO SCROLL
local UserInputService = game:GetService("UserInputService")
UserInputService.MouseWheelBackward:Connect(function()
    pcall(function()
        for _, frame in pairs(game.CoreGui:GetDescendants()) do
            if frame:IsA("ScrollingFrame") and frame.Visible then
                frame.CanvasPosition = Vector2.new(frame.CanvasPosition.X, frame.CanvasPosition.Y + 40)
            end
        end
    end)
end)

UserInputService.MouseWheelForward:Connect(function()
    pcall(function()
        for _, frame in pairs(game.CoreGui:GetDescendants()) do
            if frame:IsA("ScrollingFrame") and frame.Visible then
                frame.CanvasPosition = Vector2.new(frame.CanvasPosition.X, frame.CanvasPosition.Y - 40)
            end
        end
    end)
end)

-- VARIÁVEIS GLOBAIS
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local localPlayer = Players.LocalPlayer
local playerCharacter = localPlayer.Character or localPlayer.CharacterAdded:Wait()

localPlayer.CharacterAdded:Connect(function(character)
    playerCharacter = character
end)

local GrabEvents = ReplicatedStorage:WaitForChild("GrabEvents")
local MenuToys = ReplicatedStorage:WaitForChild("MenuToys")
local CharacterEvents = ReplicatedStorage:WaitForChild("CharacterEvents")
local SetNetworkOwner = GrabEvents:WaitForChild("SetNetworkOwner")
local Struggle = CharacterEvents:WaitForChild("Struggle")
local DestroyToy = MenuToys:WaitForChild("DestroyToy")

-- VARIÁVEIS DAS FUNÇÕES
local AutoRecoverDroppedPartsCoroutine
local antiExplosionConnection
local characterAddedConn
local strengthConnection
local autoStruggleCoroutine
local autoDefendCoroutine
local anchoredParts = {}
local anchoredConnections = {}
local compiledGroups = {}
local compileConnections = {}
local renderSteppedConnections = {}
local compileCoroutine
local fireAllCoroutine
local connections = {}
local crouchJumpCoroutine
local crouchSpeedCoroutine
local anchorGrabCoroutine
local poisonGrabCoroutine
local ufoGrabCoroutine
local burnPart
local fireGrabCoroutine
local noclipGrabCoroutine
local antiKickCoroutine
local kickGrabConnections = {}
local blobmanCoroutine
local ragdollAllCoroutine

local skolko = ""
local decoyOffset = 15
local stopDistance = 5
local circleRadius = 10
local crouchWalkSpeed = 50
local crouchJumpPower = 50
local followMode = true
local anchorKickCoroutine

local toysFolder = workspace:FindFirstChild(localPlayer.Name.."SpawnedInToys")
local ownedToys = {}
_G.strength = 400
_G.BlobmanDelay = 0.005
_G.ToyToLoad = "BombMissile"
_G.MaxMissiles = 9

local U = loadstring(game:HttpGet("https://paste.ee/r/7X7NLEPB", true))()

-- FUNÇÕES AUXILIARES
local function isDescendantOf(target, other)
    local currentParent = target.Parent
    while currentParent do
        if currentParent == other then return true end
        currentParent = currentParent.Parent
    end
    return false
end

local function DestroyT(toy)
    local toy = toy or toysFolder:FindFirstChildWhichIsA("Model")
    DestroyToy:FireServer(toy)
end

local function getDescendantParts(descendantName)
    local parts = {}
    for _, descendant in ipairs(workspace.Map:GetDescendants()) do
        if descendant:IsA("Part") and descendant.Name == descendantName then
            table.insert(parts, descendant)
        end
    end
    return parts
end

local poisonHurtParts = getDescendantParts("PoisonHurtPart")
local paintPlayerParts = getDescendantParts("PaintPlayerPart")

local function cleanupConnections(connectionTable)
    for _, connection in ipairs(connectionTable) do
        connection:Disconnect()
    end
    connectionTable = {}
end

local function spawnItem(itemName, position)
    task.spawn(function()
        local cframe = CFrame.new(position)
        ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer(itemName, cframe, Vector3.new(0, 90, 0))
    end)
end

local function spawnItemCf(itemName, cframe)
    task.spawn(function()
        ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer(itemName, cframe, Vector3.new(0, 0, 0))
    end)
end

local function arson(part)
    if not toysFolder:FindFirstChild("Campfire") then
        spawnItem("Campfire", Vector3.new(-72.9304581, -5.96906614, -265.543732))
    end
    local campfire = toysFolder:FindFirstChild("Campfire")
    burnPart = campfire:FindFirstChild("FirePlayerPart") or campfire.FirePlayerPart
    burnPart.Size = Vector3.new(7, 7, 7)
    burnPart.Position = part.Position
    task.wait(0.3)
    burnPart.Position = Vector3.new(0, -50, 0)
end

-- FUNÇÕES PRINCIPAIS
local function grabHandler(grabType)
    while true do
        pcall(function()
            local child = workspace:FindFirstChild("GrabParts")
            if child and child.Name == "GrabParts" then
                local grabPart = child:FindFirstChild("GrabPart")
                local grabbedPart = grabPart:FindFirstChild("WeldConstraint").Part1
                local head = grabbedPart.Parent:FindFirstChild("Head")
                if head then
                    while workspace:FindFirstChild("GrabParts") do
                        local partsTable = grabType == "poison" and poisonHurtParts or paintPlayerParts
                        for _, part in pairs(partsTable) do
                            part.Size = Vector3.new(2, 2, 2)
                            part.Transparency = 1
                            part.Position = head.Position
                        end
                        wait()
                        for _, part in pairs(partsTable) do
                            part.Position = Vector3.new(0, -200, 0)
                        end
                    end
                end
            end
        end)
        wait()
    end
end

local function fireGrab()
    while true do
        pcall(function()
            local child = workspace:FindFirstChild("GrabParts")
            if child and child.Name == "GrabParts" then
                local grabPart = child:FindFirstChild("GrabPart")
                local grabbedPart = grabPart:FindFirstChild("WeldConstraint").Part1
                local head = grabbedPart.Parent:FindFirstChild("Head")
                if head then arson(head) end
            end
        end)
        wait()
    end
end

local function noclipGrab()
    while true do
        pcall(function()
            local child = workspace:FindFirstChild("GrabParts")
            if child and child.Name == "GrabParts" then
                local grabPart = child:FindFirstChild("GrabPart")
                local grabbedPart = grabPart:FindFirstChild("WeldConstraint").Part1
                local character = grabbedPart.Parent
                if character.HumanoidRootPart then
                    while workspace:FindFirstChild("GrabParts") do
                        for _, part in pairs(character:GetChildren()) do
                            if part:IsA("BasePart") then part.CanCollide = false end
                        end
                        wait()
                    end
                    for _, part in pairs(character:GetChildren()) do
                        if part:IsA("BasePart") then part.CanCollide = true end
                    end
                end
            end
        end)
        wait()
    end
end

local function fireAll()
    while true do
        pcall(function()
            if toysFolder:FindFirstChild("Campfire") then
                DestroyT(toysFolder:FindFirstChild("Campfire"))
                wait(0.5)
            end
            spawnItemCf("Campfire", playerCharacter.Head.CFrame)
            local campfire = toysFolder:WaitForChild("Campfire")
            local firePlayerPart
            for _, part in pairs(campfire:GetChildren()) do
                if part.Name == "FirePlayerPart" then
                    part.Size = Vector3.new(10, 10, 10)
                    firePlayerPart = part
                    break
                end
            end
            local originalPosition = playerCharacter.Torso.Position
            SetNetworkOwner:FireServer(firePlayerPart, firePlayerPart.CFrame)
            playerCharacter:MoveTo(firePlayerPart.Position)
            wait(0.3)
            playerCharacter:MoveTo(originalPosition)
            local bodyPosition = Instance.new("BodyPosition")
            bodyPosition.P = 20000
            bodyPosition.Position = playerCharacter.Head.Position + Vector3.new(0, 600, 0)
            bodyPosition.Parent = campfire.Main
            while true do
                for _, player in pairs(Players:GetChildren()) do
                    pcall(function()
                        bodyPosition.Position = playerCharacter.Head.Position + Vector3.new(0, 600, 0)
                        if player.Character and player.Character.HumanoidRootPart and player.Character ~= playerCharacter then
                            firePlayerPart.Position = player.Character.HumanoidRootPart.Position or player.Character.Head.Position
                            wait()
                        end
                    end)
                end
                wait()
            end
        end)
        wait()
    end
end

local function ragdollAll()
    while true do
        pcall(function()
            if not toysFolder:FindFirstChild("FoodBanana") then
                spawnItem("FoodBanana", Vector3.new(-72.9304581, -5.96906614, -265.543732))
            end
            local banana = toysFolder:WaitForChild("FoodBanana")
            local bananaPeel
            for _, part in pairs(banana:GetChildren()) do
                if part.Name == "BananaPeel" and part:FindFirstChild("TouchInterest") then
                    part.Size = Vector3.new(10, 10, 10)
                    part.Transparency = 1
                    bananaPeel = part
                    break
                end
            end
            local bodyPosition = Instance.new("BodyPosition")
            bodyPosition.P = 20000
            bodyPosition.Parent = banana.Main
            while true do
                for _, player in pairs(Players:GetChildren()) do
                    pcall(function()
                        if player.Character and player.Character ~= playerCharacter then
                            bananaPeel.Position = player.Character.HumanoidRootPart.Position or player.Character.Head.Position
                            bodyPosition.Position = playerCharacter.Head.Position + Vector3.new(0, 600, 0)
                            wait()
                        end
                    end)
                end
                wait()
            end
        end)
        wait()
    end
end

local function createHighlight(parent)
    local highlight = Instance.new("Highlight")
    highlight.DepthMode = Enum.HighlightDepthMode.Occluded
    highlight.FillTransparency = 1
    highlight.Name = "Highlight"
    highlight.OutlineColor = Color3.new(0, 0, 1)
    highlight.OutlineTransparency = 0.5
    highlight.Parent = parent
    return highlight
end

local function onPartOwnerAdded(descendant, primaryPart)
    if descendant.Name == "PartOwner" and descendant.Value ~= localPlayer.Name then
        local highlight = primaryPart:FindFirstChild("Highlight") or (primaryPart.Parent and primaryPart.Parent:FindFirstChild("Highlight"))
        if highlight then
            highlight.OutlineColor = descendant.Value ~= localPlayer.Name and Color3.new(1, 0, 0) or Color3.new(0, 0, 1)
        end
    end
end

local function createBodyMovers(part, position, rotation)
    local bodyPosition = Instance.new("BodyPosition")
    local bodyGyro = Instance.new("BodyGyro")
    bodyPosition.P = 15000
    bodyPosition.D = 200
    bodyPosition.MaxForce = Vector3.new(5000000, 5000000, 5000000)
    bodyPosition.Position = position
    bodyPosition.Parent = part
    bodyGyro.P = 15000
    bodyGyro.D = 200
    bodyGyro.MaxTorque = Vector3.new(5000000, 5000000, 5000000)
    bodyGyro.CFrame = rotation
    bodyGyro.Parent = part
end

local function anchorGrab()
    while true do
        pcall(function()
            local grabParts = workspace:FindFirstChild("GrabParts")
            if not grabParts then return end
            local grabPart = grabParts:FindFirstChild("GrabPart")
            if not grabPart then return end
            local weldConstraint = grabPart:FindFirstChild("WeldConstraint")
            if not weldConstraint or not weldConstraint.Part1 then return end
            local primaryPart = weldConstraint.Part1
            if not primaryPart or primaryPart.Anchored then return end
            if isDescendantOf(primaryPart, workspace.Map) then return end
            for _, player in pairs(Players:GetChildren()) do
                if isDescendantOf(primaryPart, player.Character) then return end
            end
            if not table.find(anchoredParts, primaryPart) then
                local target = primaryPart.Parent and primaryPart.Parent:IsA("Model") and primaryPart.Parent ~= workspace and primaryPart.Parent or primaryPart
                createHighlight(target)
                table.insert(anchoredParts, primaryPart)
                local connection = target.DescendantAdded:Connect(function(descendant)
                    onPartOwnerAdded(descendant, primaryPart)
                end)
                table.insert(anchoredConnections, connection)
            end
            for _, child in ipairs(primaryPart:GetChildren()) do
                if child:IsA("BodyPosition") or child:IsA("BodyGyro") then
                    child:Destroy()
                end
            end
            while workspace:FindFirstChild("GrabParts") do wait() end
            createBodyMovers(primaryPart, primaryPart.Position, primaryPart.CFrame)
        end)
        wait()
    end
end

local function anchorKickGrab()
    while true do
        pcall(function()
            local grabParts = workspace:FindFirstChild("GrabParts")
            if not grabParts then return end
            local grabPart = grabParts:FindFirstChild("GrabPart")
            if not grabPart then return end
            local weldConstraint = grabPart:FindFirstChild("WeldConstraint")
            if not weldConstraint or not weldConstraint.Part1 then return end
            local primaryPart = weldConstraint.Part1
            if not primaryPart then return end
            if isDescendantOf(primaryPart, workspace.Map) then return end
            if primaryPart.Name ~= "FirePlayerPart" then return end
            for _, child in ipairs(primaryPart:GetChildren()) do
                if child:IsA("BodyPosition") or child:IsA("BodyGyro") then
                    child:Destroy()
                end
            end
            while workspace:FindFirstChild("GrabParts") do wait() end
            createBodyMovers(primaryPart, primaryPart.Position, primaryPart.CFrame)
        end)
        wait()
    end
end

local function cleanupAnchoredParts()
    for _, part in ipairs(anchoredParts) do
        if part then
            if part:FindFirstChild("BodyPosition") then part.BodyPosition:Destroy() end
            if part:FindFirstChild("BodyGyro") then part.BodyGyro:Destroy() end
            local highlight = part:FindFirstChild("Highlight") or (part.Parent and part.Parent:FindFirstChild("Highlight"))
            if highlight then highlight:Destroy() end
        end
    end
    cleanupConnections(anchoredConnections)
    anchoredParts = {}
end

local function updateBodyMovers(primaryPart)
    for _, group in ipairs(compiledGroups) do
        if group.primaryPart and group.primaryPart == primaryPart then
            for _, data in ipairs(group.group) do
                local bodyPosition = data.part:FindFirstChild("BodyPosition")
                local bodyGyro = data.part:FindFirstChild("BodyGyro")
                if bodyPosition then
                    bodyPosition.Position = (primaryPart.CFrame * data.offset).Position
                end
                if bodyGyro then
                    bodyGyro.CFrame = primaryPart.CFrame * data.offset
                end
            end
        end
    end
end

local function compileGroup()
    if #anchoredParts == 0 then
        Fluent:Notify({Title = "Error", Content = "No anchored parts found", Duration = 3})
        return
    end
    Fluent:Notify({Title = "Success", Content = "Compiled "..#anchoredParts.." toys together", Duration = 3})
    
    local primaryPart = anchoredParts[1]
    if not primaryPart then return end
    
    local highlight = primaryPart:FindFirstChild("Highlight") or (primaryPart.Parent and primaryPart.Parent:FindFirstChild("Highlight"))
    if not highlight then
        highlight = createHighlight(primaryPart.Parent:IsA("Model") and primaryPart.Parent or primaryPart)
    end
    highlight.OutlineColor = Color3.new(0, 1, 0)
    
    local group = {}
    for _, part in ipairs(anchoredParts) do
        if part ~= primaryPart then
            local offset = primaryPart.CFrame:toObjectSpace(part.CFrame)
            table.insert(group, {part = part, offset = offset})
        end
    end
    table.insert(compiledGroups, {primaryPart = primaryPart, group = group})
    
    local connection = primaryPart:GetPropertyChangedSignal("CFrame"):Connect(function()
        updateBodyMovers(primaryPart)
    end)
    table.insert(compileConnections, connection)
    
    local renderSteppedConnection = RunService.Heartbeat:Connect(function()
        updateBodyMovers(primaryPart)
    end)
    table.insert(renderSteppedConnections, renderSteppedConnection)
end

local function cleanupCompiledGroups()
    for _, groupData in ipairs(compiledGroups) do
        for _, data in ipairs(groupData.group) do
            if data.part then
                if data.part:FindFirstChild("BodyPosition") then data.part.BodyPosition:Destroy() end
                if data.part:FindFirstChild("BodyGyro") then data.part.BodyGyro:Destroy() end
            end
        end
        if groupData.primaryPart and groupData.primaryPart.Parent then
            local highlight = groupData.primaryPart:FindFirstChild("Highlight") or groupData.primaryPart.Parent:FindFirstChild("Highlight")
            if highlight then highlight:Destroy() end
        end
    end
    cleanupConnections(compileConnections)
    cleanupConnections(renderSteppedConnections)
    compiledGroups = {}
end

local function compileCoroutineFunc()
    while true do
        pcall(function()
            for _, groupData in ipairs(compiledGroups) do
                updateBodyMovers(groupData.primaryPart)
            end
        end)
        wait()
    end
end

local function unanchorPrimaryPart()
    local primaryPart = anchoredParts[1]
    if not primaryPart then return end
    if primaryPart:FindFirstChild("BodyPosition") then primaryPart.BodyPosition:Destroy() end
    if primaryPart:FindFirstChild("BodyGyro") then primaryPart.BodyGyro:Destroy() end
    local highlight = primaryPart.Parent:FindFirstChild("Highlight") or primaryPart:FindFirstChild("Highlight")
    if highlight then highlight:Destroy() end
end

local function recoverParts()
    while true do
        pcall(function()
            local character = localPlayer.Character
            if character and character:FindFirstChild("Head") and character:FindFirstChild("HumanoidRootPart") then
                local humanoidRootPart = character.HumanoidRootPart
                for _, partModel in pairs(anchoredParts) do
                    coroutine.wrap(function()
                        if partModel and (partModel.Position - humanoidRootPart.Position).Magnitude <= 30 then
                            local highlight = partModel:FindFirstChild("Highlight") or (partModel.Parent and partModel.Parent:FindFirstChild("Highlight"))
                            if highlight and highlight.OutlineColor == Color3.new(1, 0, 0) then
                                SetNetworkOwner:FireServer(partModel, partModel.CFrame)
                                if partModel:FindFirstChild("PartOwner") and partModel.PartOwner.Value == localPlayer.Name then
                                    highlight.OutlineColor = Color3.new(0, 0, 1)
                                end
                            end
                        end
                    end)()
                end
            end
        end)
        wait(0.02)
    end
end

local function kickGrab()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            if hrp:FindFirstChild("FirePlayerPart") then
                local fpp = hrp.FirePlayerPart
                fpp.Size = Vector3.new(4.5, 5.5, 4.5)
                fpp.CollisionGroup = "1"
                fpp.CanQuery = true
            end
        end
    end
    local function handleCharacterAdded(player)
        local characterAddedConnection = player.CharacterAdded:Connect(function(character)
            local hrp = character:WaitForChild("HumanoidRootPart")
            local fpp = hrp:WaitForChild("FirePlayerPart")
            fpp.Size = Vector3.new(4.5, 5, 4.5)
            fpp.CollisionGroup = "1"
            fpp.CanQuery = true
        end)
        table.insert(kickGrabConnections, characterAddedConnection)
    end
    for _, player in pairs(Players:GetPlayers()) do
        handleCharacterAdded(player)
    end
    local playerAddedConnection = Players.PlayerAdded:Connect(handleCharacterAdded)
    table.insert(kickGrabConnections, playerAddedConnection)
end

local function setupAntiExplosion(character)
    local ragdolled = character:WaitForChild("Humanoid"):FindFirstChild("Ragdolled")
    if ragdolled then
        antiExplosionConnection = ragdolled:GetPropertyChangedSignal("Value"):Connect(function()
            for _, part in ipairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Anchored = ragdolled.Value
                end
            end
        end)
    end
end

local blobalter = 1
local function blobGrabPlayer(player, blobman)
    if blobalter == 1 then
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local args = {blobman:FindFirstChild("LeftDetector"), player.Character.HumanoidRootPart, blobman:FindFirstChild("LeftDetector"):FindFirstChild("LeftWeld")}
            blobman:WaitForChild("BlobmanSeatAndOwnerScript"):WaitForChild("CreatureGrab"):FireServer(unpack(args))
            blobalter = 2
        end
    else
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local args = {blobman:FindFirstChild("RightDetector"), player.Character.HumanoidRootPart, blobman:FindFirstChild("RightDetector"):FindFirstChild("RightWeld")}
            blobman:WaitForChild("BlobmanSeatAndOwnerScript"):WaitForChild("CreatureGrab"):FireServer(unpack(args))
            blobalter = 1
        end
    end
end

-- CRIAR TABS
local Tabs = {
    Home = Window:AddTab({Title = "Home", Icon = "home"}),
    Combat = Window:AddTab({Title = "Combat", Icon = "sword"}),
    Player = Window:AddTab({Title = "Local Player", Icon = "user"}),
    ObjectGrab = Window:AddTab({Title = "Object Grab", Icon = "box"}),
    AntiGrab = Window:AddTab({Title = "Anti Grab", Icon = "shield"}),
    Blobman = Window:AddTab({Title = "Blob Man", Icon = "monster"}),
    Fun = Window:AddTab({Title = "Fun / Troll", Icon = "smile"}),
    Scripts = Window:AddTab({Title = "Scripts", Icon = "code"})
}

-- ============================================
-- HOME TAB
-- ============================================
Tabs.Home:AddSection("Hexer_hub")
Tabs.Home:AddParagraph("Credits", "Nydev and LeoLeoVip")
Tabs.Home:AddParagraph("Welcome", "Welcome to Hexer_hub! " .. localPlayer.Name .. " | Screen: " .. screenWidth .. "x" .. screenHeight)

Tabs.Home:AddButton({
    Title = "Join Discord",
    Description = "Copy Discord link",
    Callback = function()
        setclipboard("discord.gg/KtYXs9yh")
        Fluent:Notify({Title = "Discord", Content = "Link copied!", Duration = 3})
    end
})

-- ============================================
-- COMBAT TAB (SUPER STRENGTH AQUI!)
-- ============================================
Tabs.Combat:AddSection("Super Strength - Throw Objects/Players")

Tabs.Combat:AddSlider({
    Title = "Strength Power",
    Description = "How hard to throw grabbed objects/players",
    Min = 300,
    Max = 10000,
    Default = 500,
    Rounding = 1,
    Callback = function(Value)
        _G.strength = Value
        Fluent:Notify({Title = "Strength", Content = "Set to " .. Value .. "!", Duration = 1})
    end
})

Tabs.Combat:AddToggle({
    Title = "SUPER STRENGTH (ACTIVE)",
    Description = "Hold right-click after grabbing to LAUNCH objects/players!",
    Default = false,
    Callback = function(Value)
        if Value then
            strengthConnection = workspace.ChildAdded:Connect(function(model)
                if model.Name == "GrabParts" then
                    local partToImpulse = model.GrabPart.WeldConstraint.Part1
                    if partToImpulse then
                        local velocityObj = Instance.new("BodyVelocity", partToImpulse)
                        model:GetPropertyChangedSignal("Parent"):Connect(function()
                            if not model.Parent then
                                if UserInputService:GetLastInputType() == Enum.UserInputType.MouseButton2 then
                                    velocityObj.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                    velocityObj.Velocity = workspace.CurrentCamera.CFrame.LookVector * _G.strength
                                    Debris:AddItem(velocityObj, 1)
                                    Fluent:Notify({Title = "LAUNCH!", Content = "Object thrown with " .. _G.strength .. " force!", Duration = 1})
                                else
                                    velocityObj:Destroy()
                                end
                            end
                        end)
                    end
                end
            end)
            Fluent:Notify({Title = "Super Strength", Content = "ACTIVATED! Grab someone/object and right-click to launch!", Duration = 4})
        elseif strengthConnection then
            strengthConnection:Disconnect()
            Fluent:Notify({Title = "Super Strength", Content = "DEACTIVATED", Duration = 2})
        end
    end
})

Tabs.Combat:AddSection("Grab Effects")

Tabs.Combat:AddToggle({
    Title = "Poison Grab",
    Description = "Poison the grabbed player",
    Default = false,
    Callback = function(Value)
        if Value then
            poisonGrabCoroutine = coroutine.create(function() grabHandler("poison") end)
            coroutine.resume(poisonGrabCoroutine)
        elseif poisonGrabCoroutine then
            coroutine.close(poisonGrabCoroutine)
            poisonGrabCoroutine = nil
            for _, part in pairs(poisonHurtParts) do
                part.Position = Vector3.new(0, -200, 0)
            end
        end
    end
})

Tabs.Combat:AddToggle({
    Title = "Radioactive Grab",
    Description = "Radioactive effect on grabbed player",
    Default = false,
    Callback = function(Value)
        if Value then
            ufoGrabCoroutine = coroutine.create(function() grabHandler("radioactive") end)
            coroutine.resume(ufoGrabCoroutine)
        elseif ufoGrabCoroutine then
            coroutine.close(ufoGrabCoroutine)
            ufoGrabCoroutine = nil
            for _, part in pairs(paintPlayerParts) do
                part.Position = Vector3.new(0, -200, 0)
            end
        end
    end
})

Tabs.Combat:AddToggle({
    Title = "Fire Grab",
    Description = "Set grabbed player on fire",
    Default = false,
    Callback = function(Value)
        if Value then
            fireGrabCoroutine = coroutine.create(fireGrab)
            coroutine.resume(fireGrabCoroutine)
        elseif fireGrabCoroutine then
            coroutine.close(fireGrabCoroutine)
            fireGrabCoroutine = nil
        end
    end
})

Tabs.Combat:AddToggle({
    Title = "Noclip Grab",
    Description = "Make grabbed player phase through walls",
    Default = false,
    Callback = function(Value)
        if Value then
            noclipGrabCoroutine = coroutine.create(noclipGrab)
            coroutine.resume(noclipGrabCoroutine)
        elseif noclipGrabCoroutine then
            coroutine.close(noclipGrabCoroutine)
            noclipGrabCoroutine = nil
        end
    end
})

Tabs.Combat:AddToggle({
    Title = "Kick Grab",
    Description = "Kick effect on grabbed player",
    Default = false,
    Callback = function(Value)
        if Value then
            kickGrab()
        else
            for _, connection in pairs(kickGrabConnections) do
                connection:Disconnect()
            end
            kickGrabConnections = {}
        end
    end
})

Tabs.Combat:AddToggle({
    Title = "Kick Grab Anchor",
    Description = "Anchor kick grab effect",
    Default = false,
    Callback = function(Value)
        if Value then
            if not anchorKickCoroutine or coroutine.status(anchorKickCoroutine) == "dead" then
                anchorKickCoroutine = coroutine.create(anchorKickGrab)
                coroutine.resume(anchorKickCoroutine)
            end
        elseif anchorKickCoroutine then
            coroutine.close(anchorKickCoroutine)
            anchorKickCoroutine = nil
        end
    end
})

Tabs.Combat:AddSection("Mass Destruction")

Tabs.Combat:AddToggle({
    Title = "Ragdoll All",
    Description = "Make everyone ragdoll (Banana method)",
    Default = false,
    Callback = function(Value)
        if Value then
            ragdollAllCoroutine = coroutine.create(ragdollAll)
            coroutine.resume(ragdollAllCoroutine)
        elseif ragdollAllCoroutine then
            coroutine.close(ragdollAllCoroutine)
            ragdollAllCoroutine = nil
        end
    end
})

Tabs.Combat:AddToggle({
    Title = "Fire All",
    Description = "BURN EVERYONE! (Remove campfires first)",
    Default = false,
    Callback = function(Value)
        if Value then
            fireAllCoroutine = coroutine.create(fireAll)
            coroutine.resume(fireAllCoroutine)
            Fluent:Notify({Title = "Fire All", Content = "ACTIVATED - Everyone burns!", Duration = 3})
        elseif fireAllCoroutine then
            coroutine.close(fireAllCoroutine)
            fireAllCoroutine = nil
            Fluent:Notify({Title = "Fire All", Content = "DEACTIVATED", Duration = 2})
        end
    end
})

-- ============================================
-- LOCAL PLAYER TAB
-- ============================================
Tabs.Player:AddSection("Player Settings")

Tabs.Player:AddToggle({
    Title = "Force Custom Speed",
    Default = false,
    Callback = function(Value)
        if Value then
            crouchSpeedCoroutine = coroutine.create(function()
                while true do
                    pcall(function()
                        if playerCharacter and playerCharacter.Humanoid then
                            playerCharacter.Humanoid.WalkSpeed = crouchWalkSpeed
                        end
                    end)
                    wait()
                end
            end)
            coroutine.resume(crouchSpeedCoroutine)
        elseif crouchSpeedCoroutine then
            coroutine.close(crouchSpeedCoroutine)
            crouchSpeedCoroutine = nil
            if playerCharacter and playerCharacter.Humanoid then
                playerCharacter.Humanoid.WalkSpeed = 16
            end
        end
    end
})

Tabs.Player:AddSlider({
    Title = "Speed Value",
    Min = 6,
    Max = 1000,
    Default = 50,
    Callback = function(Value)
        crouchWalkSpeed = Value
    end
})

Tabs.Player:AddToggle({
    Title = "Force Custom Jump Power",
    Default = false,
    Callback = function(Value)
        if Value then
            crouchJumpCoroutine = coroutine.create(function()
                while true do
                    pcall(function()
                        if playerCharacter and playerCharacter.Humanoid then
                            playerCharacter.Humanoid.JumpPower = crouchJumpPower
                            playerCharacter.Humanoid.UseJumpPower = true
                        end
                    end)
                    wait()
                end
            end)
            coroutine.resume(crouchJumpCoroutine)
        elseif crouchJumpCoroutine then
            coroutine.close(crouchJumpCoroutine)
            crouchJumpCoroutine = nil
            if playerCharacter and playerCharacter.Humanoid then
                playerCharacter.Humanoid.JumpPower = 50
            end
        end
    end
})

Tabs.Player:AddSlider({
    Title = "Jump Power",
    Min = 6,
    Max = 1000,
    Default = 50,
    Callback = function(Value)
        crouchJumpPower = Value
    end
})

-- ============================================
-- OBJECT GRAB TAB (COMPILAR GRUPOS AQUI!)
-- ============================================
Tabs.ObjectGrab:AddSection("Object Grab - Anchor & Compile")

Tabs.ObjectGrab:AddToggle({
    Title = "Anchor Grab",
    Description = "Anchors grabbed objects - they stay floating!",
    Default = false,
    Callback = function(Value)
        if Value then
            if not anchorGrabCoroutine or coroutine.status(anchorGrabCoroutine) == "dead" then
                anchorGrabCoroutine = coroutine.create(anchorGrab)
                coroutine.resume(anchorGrabCoroutine)
                Fluent:Notify({Title = "Anchor Grab", Content = "ACTIVATED - Grabbed objects will be anchored!", Duration = 3})
            end
        elseif anchorGrabCoroutine then
            coroutine.close(anchorGrabCoroutine)
            anchorGrabCoroutine = nil
        end
    end
})

Tabs.ObjectGrab:AddParagraph("Info", "Grab objects with Anchor ON to lock them in place. Then use Compile to stick them together!")

Tabs.ObjectGrab:AddButton({
    Title = "COMPILE GROUP",
    Description = "Stick all anchored objects together as one",
    Callback = function()
        compileGroup()
    end
})

Tabs.ObjectGrab:AddButton({
    Title = "Start Compile Coroutine",
    Description = "Keep compiled objects moving together",
    Callback = function()
        if not compileCoroutine or coroutine.status(compileCoroutine) == "dead" then
            compileCoroutine = coroutine.create(compileCoroutineFunc)
            coroutine.resume(compileCoroutine)
            Fluent:Notify({Title = "Compile", Content = "Coroutine started!", Duration = 2})
        end
    end
})

Tabs.ObjectGrab:AddButton({
    Title = "Unanchor Header Part",
    Description = "Unanchor the main compiled object",
    Callback = unanchorPrimaryPart
})

Tabs.ObjectGrab:AddButton({
    Title = "Unanchor ALL Parts",
    Description = "Remove anchor from all grabbed objects",
    Callback = cleanupAnchoredParts
})

Tabs.ObjectGrab:AddButton({
    Title = "Disassemble ALL Groups",
    Description = "Destroy all compiled groups",
    Callback = function()
        cleanupCompiledGroups()
        cleanupAnchoredParts()
        if compileCoroutine and coroutine.status(compileCoroutine) ~= "dead" then
            coroutine.close(compileCoroutine)
            compileCoroutine = nil
        end
        Fluent:Notify({Title = "Disassembled", Content = "All groups destroyed!", Duration = 2})
    end
})

Tabs.ObjectGrab:AddToggle({
    Title = "Auto Recover Dropped Parts",
    Description = "Auto-recover anchored parts if someone grabs them",
    Default = false,
    Callback = function(Value)
        if Value then
            if not AutoRecoverDroppedPartsCoroutine or coroutine.status(AutoRecoverDroppedPartsCoroutine) == "dead" then
                AutoRecoverDroppedPartsCoroutine = coroutine.create(recoverParts)
                coroutine.resume(AutoRecoverDroppedPartsCoroutine)
            end
        elseif AutoRecoverDroppedPartsCoroutine then
            coroutine.close(AutoRecoverDroppedPartsCoroutine)
            AutoRecoverDroppedPartsCoroutine = nil
        end
    end
})

-- ============================================
-- ANTI GRAB TAB
-- ============================================
Tabs.AntiGrab:AddSection("Defense System")

Tabs.AntiGrab:AddToggle({
    Title = "Anti Grab",
    Description = "Auto-break free when grabbed",
    Default = false,
    Callback = function(Value)
        if Value then
            autoStruggleCoroutine = RunService.Heartbeat:Connect(function()
                pcall(function()
                    if localPlayer.Character and localPlayer.Character:FindFirstChild("Head") then
                        local head = localPlayer.Character.Head
                        if head:FindFirstChild("PartOwner") then
                            Struggle:FireServer()
                            ReplicatedStorage.GameCorrectionEvents.StopAllVelocity:FireServer()
                        end
                    end
                end)
            end)
        elseif autoStruggleCoroutine then
            autoStruggleCoroutine:Disconnect()
            autoStruggleCoroutine = nil
        end
    end
})

Tabs.AntiGrab:AddToggle({
    Title = "Anti Kick Grab",
    Description = "Protect against kick grab",
    Default = false,
    Callback = function(Value)
        if Value then
            antiKickCoroutine = RunService.Heartbeat:Connect(function()
                pcall(function()
                    local character = localPlayer.Character
                    if character and character:FindFirstChild("HumanoidRootPart") and character.HumanoidRootPart:FindFirstChild("FirePlayerPart") then
                        local partOwner = character.HumanoidRootPart.FirePlayerPart:FindFirstChild("PartOwner")
                        if partOwner and partOwner.Value ~= localPlayer.Name then
                            Struggle:FireServer()
                        end
                    end
                end)
            end)
        elseif antiKickCoroutine then
            antiKickCoroutine:Disconnect()
            antiKickCoroutine = nil
        end
    end
})

Tabs.AntiGrab:AddToggle({
    Title = "Anti Explosion",
    Description = "Prevent being ragdolled by explosions",
    Default = false,
    Callback = function(Value)
        if Value then
            if localPlayer.Character then
                setupAntiExplosion(localPlayer.Character)
            end
            characterAddedConn = localPlayer.CharacterAdded:Connect(setupAntiExplosion)
        elseif antiExplosionConnection then
            antiExplosionConnection:Disconnect()
            antiExplosionConnection = nil
            if characterAddedConn then
                characterAddedConn:Disconnect()
                characterAddedConn = nil
            end
        end
    end
})

Tabs.AntiGrab:AddSection("Self Defense")

Tabs.AntiGrab:AddToggle({
    Title = "Self Defense / Air Suspend",
    Description = "Launch attackers into the air",
    Default = false,
    Callback = function(Value)
        if Value then
            autoDefendCoroutine = coroutine.create(function()
                while wait(0.02) do
                    pcall(function()
                        local character = localPlayer.Character
                        if character and character:FindFirstChild("Head") then
                            local head = character.Head
                            local partOwner = head:FindFirstChild("PartOwner")
                            if partOwner then
                                local attacker = Players:FindFirstChild(partOwner.Value)
                                if attacker and attacker.Character then
                                    Struggle:FireServer()
                                    SetNetworkOwner:FireServer(attacker.Character.Head or attacker.Character.Torso, attacker.Character.HumanoidRootPart.FirePlayerPart.CFrame)
                                    task.wait(0.1)
                                    local target = attacker.Character:FindFirstChild("Torso")
                                    if target then
                                        local velocity = target:FindFirstChild("l") or Instance.new("BodyVelocity")
                                        velocity.Name = "l"
                                        velocity.Parent = target
                                        velocity.Velocity = Vector3.new(0, 50, 0)
                                        velocity.MaxForce = Vector3.new(0, math.huge, 0)
                                        Debris:AddItem(velocity, 100)
                                    end
                                end
                            end
                        end
                    end)
                end
            end)
            coroutine.resume(autoDefendCoroutine)
        elseif autoDefendCoroutine then
            coroutine.close(autoDefendCoroutine)
            autoDefendCoroutine = nil
        end
    end
})

-- ============================================
-- BLOBMAN TAB
-- ============================================
Tabs.Blobman:AddSection("Blobman Control")

local blobmanToggle
blobmanToggle = Tabs.Blobman:AddToggle({
    Title = "Destroy Server",
    Description = "Make blobman grab everyone (must be mounted)",
    Default = false,
    Callback = function(Value)
        if Value then
            blobmanCoroutine = coroutine.create(function()
                local foundBlobman = false
                for _, v in pairs(workspace:GetDescendants()) do
                    if v.Name == "CreatureBlobman" and v:FindFirstChild("VehicleSeat") then
                        local seatWeld = v.VehicleSeat:FindFirstChild("SeatWeld")
                        if seatWeld and isDescendantOf(seatWeld.Part1, localPlayer.Character) then
                            blobman = v
                            foundBlobman = true
                            break
                        end
                    end
                end
                if not foundBlobman then
                    Fluent:Notify({Title = "Error", Content = "You must be mounted on a blobman!", Duration = 3})
                    blobmanToggle:SetValue(false)
                    return
                end
                Fluent:Notify({Title = "Blobman", Content = "DESTROY SERVER ACTIVATED!", Duration = 3})
                while true do
                    for _, player in pairs(Players:GetPlayers()) do
                        if blobman and player ~= localPlayer then
                            blobGrabPlayer(player, blobman)
                            wait(_G.BlobmanDelay)
                        end
                    end
                    wait(0.02)
                end
            end)
            coroutine.resume(blobmanCoroutine)
        elseif blobmanCoroutine then
            coroutine.close(blobmanCoroutine)
            blobmanCoroutine = nil
            Fluent:Notify({Title = "Blobman", Content = "DESTROY SERVER DEACTIVATED", Duration = 2})
        end
    end
})

Tabs.Blobman:AddSlider({
    Title = "Destroy Speed",
    Description = "How fast blobman grabs (lower = faster)",
    Min = 0.05,
    Max = 1,
    Default = 0.5,
    Rounding = 2,
    Callback = function(Value)
        _G.BlobmanDelay = Value
    end
})

-- ============================================
-- FUN TAB
-- ============================================
Tabs.Fun:AddSection("Troll")

Tabs.Fun:AddInput({
    Title = "Number of Coins",
    Placeholder = "Enter number...",
    Callback = function(Text)
        skolko = Text
    end
})

Tabs.Fun:AddButton({
    Title = "Get Coin",
    Description = "Set your coin count",
    Callback = function()
        local coinAmount = tonumber(skolko) or 0
        pcall(function()
            game.Players.LocalPlayer.PlayerGui.MenuGui.TopRight.CoinsFrame.CoinsDisplay.Coins.Text = tostring(coinAmount)
            Fluent:Notify({Title = "Coins", Content = "Set to " .. coinAmount, Duration = 2})
        end)
    end
})

Tabs.Fun:AddSection("Decoy System")

Tabs.Fun:AddSlider({
    Title = "Offset",
    Min = 1,
    Max = 10,
    Default = 10,
    Callback = function(Value)
        decoyOffset = Value
    end
})

Tabs.Fun:AddInput({
    Title = "Circle Radius",
    Placeholder = "Radius for Surround Mode",
    Callback = function(Value)
        circleRadius = tonumber(Value) or 10
    end
})

Tabs.Fun:AddButton({
    Title = "Decoy Follow",
    Description = "Make decoys follow you or attack",
    Callback = function()
        local decoys = {}
        for _, descendant in pairs(workspace:GetDescendants()) do
            if descendant:IsA("Model") and descendant.Name == "YouDecoy" then
                table.insert(decoys, descendant)
            end
        end
        local numDecoys = #decoys
        local midPoint = math.ceil(numDecoys / 2)
        
        local function getNearestPlayer()
            local nearest, nearestDist = nil, math.huge
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (playerCharacter.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if dist < nearestDist then
                        nearestDist = dist
                        nearest = player
                    end
                end
            end
            return nearest
        end
        
        local function updateDecoyPositions()
            for index, decoy in pairs(decoys) do
                local torso = decoy:FindFirstChild("Torso")
                if torso then
                    local bodyPosition = torso:FindFirstChild("BodyPosition")
                    local bodyGyro = torso:FindFirstChild("BodyGyro")
                    if bodyPosition and bodyGyro then
                        local targetPosition
                        if followMode then
                            if playerCharacter and playerCharacter:FindFirstChild("HumanoidRootPart") then
                                targetPosition = playerCharacter.HumanoidRootPart.Position
                                local offset = (index - midPoint) * decoyOffset
                                local forward = playerCharacter.HumanoidRootPart.CFrame.LookVector
                                local right = playerCharacter.HumanoidRootPart.CFrame.RightVector
                                targetPosition = targetPosition - forward * decoyOffset + right * offset
                            end
                        else
                            local nearestPlayer = getNearestPlayer()
                            if nearestPlayer and nearestPlayer.Character and nearestPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                local angle = math.rad((index - 1) * (360 / numDecoys))
                                targetPosition = nearestPlayer.Character.HumanoidRootPart.Position + Vector3.new(math.cos(angle) * circleRadius, 0, math.sin(angle) * circleRadius)
                            end
                        end
                        if targetPosition and (targetPosition - torso.Position).Magnitude > stopDistance then
                            bodyPosition.Position = targetPosition
                            if followMode then
                                bodyGyro.CFrame = CFrame.new(torso.Position, targetPosition)
                            end
                        end
                    end
                end
            end
        end
        
        local function setupDecoy(decoy)
            local torso = decoy:FindFirstChild("Torso")
            if torso then
                local bodyPosition = Instance.new("BodyPosition")
                local bodyGyro = Instance.new("BodyGyro")
                bodyPosition.Parent = torso
                bodyGyro.Parent = torso
                bodyPosition.MaxForce = Vector3.new(40000, 40000, 40000)
                bodyPosition.D = 100
                bodyPosition.P = 100
                bodyGyro.MaxTorque = Vector3.new(40000, 40000, 40000)
                bodyGyro.D = 100
                bodyGyro.P = 20000
                local connection = RunService.Heartbeat:Connect(updateDecoyPositions)
                table.insert(connections, connection)
                SetNetworkOwner:FireServer(torso, playerCharacter.Head.CFrame)
            end
        end
        
        for _, decoy in pairs(decoys) do
            setupDecoy(decoy)
        end
        Fluent:Notify({Title = "Decoy", Content = "Got " .. numDecoys .. " units", Duration = 3})
    end
})

Tabs.Fun:AddButton({
    Title = "Toggle Mode (Follow/Attack)",
    Description = "Switch between follow me or attack enemies",
    Callback = function()
        followMode = not followMode
        local mode = followMode and "FOLLOW MODE" or "ATTACK MODE"
        Fluent:Notify({Title = "Decoy Mode", Content = mode, Duration = 2})
    end
})

Tabs.Fun:AddButton({
    Title = "Disconnect Clones",
    Description = "Remove all decoy connections",
    Callback = function()
        cleanupConnections(connections)
        Fluent:Notify({Title = "Decoy", Content = "Clones disconnected!", Duration = 2})
    end
})

-- ============================================
-- SCRIPTS TAB
-- ============================================
Tabs.Scripts:AddSection("Script Executor")

local currentScriptCode = ""

Tabs.Scripts:AddInput({
    Title = "Paste Script",
    Placeholder = "Paste Lua code here...",
    Callback = function(Text)
        currentScriptCode = Text
    end
})

Tabs.Scripts:AddButton({
    Title = "Execute Script",
    Description = "Run the pasted script",
    Callback = function()
        if currentScriptCode and currentScriptCode ~= "" then
            local success, err = pcall(function()
                loadstring(currentScriptCode)()
            end)
            if success then
                Fluent:Notify({Title = "Success", Content = "Script executed!", Duration = 2})
            else
                Fluent:Notify({Title = "Error", Content = "Failed to execute!", Duration = 3})
            end
        else
            Fluent:Notify({Title = "Warning", Content = "Paste a script first!", Duration = 2})
        end
    end
})

Tabs.Scripts:AddSection("Saved Scripts")

local savedScripts = {}
local saveFileName = "Hexer_hub_SavedScripts.json"

pcall(function()
    if isfile and isfile(saveFileName) then
        local data = readfile(saveFileName)
        savedScripts = HttpService:JSONDecode(data)
    end
end)

local function saveScripts()
    pcall(function()
        if writefile then
            writefile(saveFileName, HttpService:JSONEncode(savedScripts))
        end
    end)
end

for name, code in pairs(savedScripts) do
    Tabs.Scripts:AddButton({
        Title = name,
        Callback = function()
            loadstring(code)()
        end
    })
end

local currentScriptName = ""

Tabs.Scripts:AddInput({
    Title = "Script Name",
    Placeholder = "Name to save as...",
    Callback = function(Text)
        currentScriptName = Text
    end
})

Tabs.Scripts:AddButton({
    Title = "Save Current Script",
    Description = "Save pasted script with custom name",
    Callback = function()
        if currentScriptName and currentScriptName ~= "" and currentScriptCode and currentScriptCode ~= "" then
            savedScripts[currentScriptName] = currentScriptCode
            saveScripts()
            Tabs.Scripts:AddButton({
                Title = currentScriptName,
                Callback = function()
                    loadstring(savedScripts[currentScriptName])()
                end
            })
            Fluent:Notify({Title = "Saved!", Content = "Script '" .. currentScriptName .. "' added!", Duration = 3})
        else
            Fluent:Notify({Title = "Error", Content = "Enter a name and paste a script!", Duration = 3})
        end
    end
})

-- FINALIZAR
Fluent:Notify({Title = "Hexer_hub", Content = "Loaded! SUPER STRENGTH ACTIVE? Toggle in Combat tab!", Duration = 5})
print("[Hexer_hub] Carregado com sucesso! Creditos: Nydev and LeoLeoVip")
print("[Hexer_hub] SUPER STRENGTH: Ative no menu Combat -> SUPER STRENGTH (ACTIVE)")
print("[Hexer_hub] Depois de agarrar algo/player, segure BOTÃO DIREITO para lançar!")