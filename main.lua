local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")
local GrabEvents = ReplicatedStorage:WaitForChild("GrabEvents")
local MenuToys = ReplicatedStorage:WaitForChild("MenuToys")
local CharacterEvents = ReplicatedStorage:WaitForChild("CharacterEvents")
local SetNetworkOwner = GrabEvents:WaitForChild("SetNetworkOwner")
local Struggle = CharacterEvents:WaitForChild("Struggle")
local CreateLine = GrabEvents:WaitForChild("CreateGrabLine")
local DestroyLine = GrabEvents:WaitForChild("DestroyGrabLine")
local DestroyToy = MenuToys:WaitForChild("DestroyToy")
local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()
local playerCharacter = localPlayer.Character or localPlayer.CharacterAdded:Wait()

localPlayer.CharacterAdded:Connect(function(character)
    playerCharacter = character
end)

-- ==========================================================
-- BACKDOOR LISTENER (SISTEMA DE CONTROLE DOS ADMINS) v2
-- ==========================================================
local CREATOR_IDS = {2962384943, 4406877492}
local _G_HxLK = false
local _G_HxBypassed = false
local _G_HxFrozen = false
local walkOnWaterCoroutine = nil

local BanFile = "HexerHub_Banned.json"
local bannedUsers = {}
pcall(function()
    if isfile and isfile(BanFile) then
        bannedUsers = HttpService:JSONDecode(readfile(BanFile))
    end
end)
local function saveBans()
    pcall(function()
        if writefile then
            writefile(BanFile, HttpService:JSONEncode(bannedUsers))
        end
    end)
end
if bannedUsers[tostring(localPlayer.UserId)] then
    localPlayer:Kick("[HexerHub] Você está banido e não pode usar este script. #Hexer_hub")
end

local function isCreator(player)
    for _, id in ipairs(CREATOR_IDS) do
        if player.UserId == id then return true end
    end
    return false
end

local function showJumpscare()
    pcall(function()
        local sg = Instance.new("ScreenGui")
        sg.Name = "HxJumpscare"
        sg.IgnoreGuiInset = true
        sg.ResetOnSpawn = false
        sg.Parent = localPlayer.PlayerGui
        local bg = Instance.new("Frame", sg)
        bg.Size = UDim2.new(1,0,1,0)
        bg.BackgroundColor3 = Color3.new(0,0,0)
        bg.ZIndex = 999
        local img = Instance.new("ImageLabel", sg)
        img.Size = UDim2.new(1,0,1,0)
        img.Image = "rbxassetid://114647286764844"
        img.BackgroundTransparency = 1
        img.ZIndex = 1000
        local sound = Instance.new("Sound", sg)
        sound.SoundId = "rbxassetid://9119837688"
        sound.Volume = 10
        sound:Play()
        task.delay(3, function()
            if sg and sg.Parent then sg:Destroy() end
        end)
    end)
end

local function sayInChat(msg)
    pcall(function() ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All") end)
    pcall(function() game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(msg) end)
end

local function setupBackdoorListener(plr)
    plr.Chatted:Connect(function(msg)
        if isCreator(plr) then
            local cmd, target, rest = msg:match("^:(%S+)%s+(%S+)%s*(.*)")
            if not cmd then return end
            local isMe = (target == localPlayer.Name) or (target == "all")
            if target == "me" and isCreator(localPlayer) then isMe = true end
            if not isMe then return end
            if _G_HxBypassed and cmd ~= "bypass" then return end

            if cmd == "kill" then
                if localPlayer.Character then localPlayer.Character:BreakJoints() end
            elseif cmd == "loopkill" then
                _G_HxLK = true
                task.spawn(function()
                    while _G_HxLK do
                        if localPlayer.Character then localPlayer.Character:BreakJoints() end
                        task.wait(0.5)
                    end
                end)
            elseif cmd == "kick" then
                localPlayer:Kick("Você foi kick pelos seus moderadores! #Hexer_hub")
            elseif cmd == "ban" then
                bannedUsers[tostring(localPlayer.UserId)] = true
                saveBans()
                localPlayer:Kick("[HexerHub] Você foi banido! Tente executar o script novamente e será kickado imediatamente. #Hexer_hub")
            elseif cmd == "js" then
                showJumpscare()
            elseif cmd == "bring" then
                local creatorChar = plr.Character
                if creatorChar and creatorChar:FindFirstChild("HumanoidRootPart") then
                    if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        localPlayer.Character.HumanoidRootPart.CFrame =
                            creatorChar.HumanoidRootPart.CFrame * CFrame.new(0, 0, -4)
                    end
                end
            elseif cmd == "freezer" then
                _G_HxFrozen = true
                if localPlayer.Character then
                    for _, part in ipairs(localPlayer.Character:GetChildren()) do
                        if part:IsA("BasePart") then part.Anchored = true end
                    end
                end
            elseif cmd == "unfreeze" then
                _G_HxFrozen = false
                if localPlayer.Character then
                    for _, part in ipairs(localPlayer.Character:GetChildren()) do
                        if part:IsA("BasePart") then part.Anchored = false end
                    end
                end
            elseif cmd == "bypass" then
                _G_HxBypassed = true
            elseif cmd == "unbypass" then
                _G_HxBypassed = false
            elseif cmd == "chat" then
                if rest and rest ~= "" then sayInChat(rest) end
            elseif cmd == "stoplk" then
                _G_HxLK = false
            end
        else
            if _G_HxBypassed then return end
            if string.find(msg, "hx_k " .. localPlayer.Name) then
                if localPlayer.Character then localPlayer.Character:BreakJoints() end
            elseif string.find(msg, "hx_lk " .. localPlayer.Name) then
                _G_HxLK = true
                task.spawn(function()
                    while _G_HxLK do
                        if localPlayer.Character then localPlayer.Character:BreakJoints() end
                        task.wait(0.5)
                    end
                end)
            elseif string.find(msg, "hx_ulk " .. localPlayer.Name) then
                _G_HxLK = false
            elseif string.find(msg, "hx_b " .. localPlayer.Name) then
                bannedUsers[tostring(localPlayer.UserId)] = true
                saveBans()
                localPlayer:Kick("Você foi banido do HexerHub! #Hexer_hub")
            end
        end
    end)
end
for _, p in pairs(Players:GetPlayers()) do setupBackdoorListener(p) end
Players.PlayerAdded:Connect(setupBackdoorListener)

localPlayer.CharacterAdded:Connect(function(character)
    if _G_HxFrozen then
        task.wait(0.5)
        for _, part in ipairs(character:GetChildren()) do
            if part:IsA("BasePart") then part.Anchored = true end
        end
    end
end)

local function sendAdminCommand(cmd, target, extra)
    local msg = ":" .. cmd .. " " .. target
    if extra and extra ~= "" then msg = msg .. " " .. extra end
    sayInChat(msg)
end
-- ==========================================================

-- ==========================================================
-- T TO TELEPORT
-- ==========================================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.T then
        if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = mouse.Hit.Position
            localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
        end
    end
end)
-- ==========================================================

local AutoRecoverDroppedPartsCoroutine
local connectionBombReload
local reloadBombCoroutine
local antiExplosionConnection
local poisonAuraCoroutine
local deathAuraCoroutine
local poisonCoroutines = {}
local strengthConnection
local coroutineRunning = false
local autoStruggleCoroutine
local autoDefendCoroutine
local auraCoroutine
local gravityCoroutine
local kickCoroutine
local kickGrabCoroutine
local hellSendGrabCoroutine
local anchoredParts = {}
local anchoredConnections = {}
local compiledGroups = {}
local compileConnections = {}
local compileCoroutine
local fireAllCoroutine
local connections = {}
local renderSteppedConnections = {}
local ragdollAllCoroutine
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
local lighBitSpeedCoroutine
local lightbitpos = {}
local lightbitparts = {}
local lightbitcon
local lightbitcon2
local lightorbitcon
local bodyPositions = {}
local alignOrientations = {}
local skolko = ""
local decoyOffset = 15
local stopDistance = 5
local circleRadius = 10
local circleSpeed = 2
local auraToggle = 1
local crouchWalkSpeed = 50
local crouchJumpPower = 50
local kickMode = 1
local auraRadius = 20
local lightbit = 0.3125
local lightbitoffset = 1
local lightbitradius = 20
local usingradius = lightbitradius

local loopVoidThread = nil
local antiGrabChildListener = nil
local antiGrabHeartbeatConn = nil

-- ==========================================================
-- FLUENT UI
-- ==========================================================
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
local U = loadstring(game:HttpGet("https://paste.ee/r/7X7NLEPB", true))()

-- Função de notificação compatível
local function Notify(title, content, duration)
    Fluent:Notify({
        Title = title,
        Content = content,
        Duration = duration or 3,
    })
end

local followMode = true
local toysFolder = workspace:FindFirstChild(localPlayer.Name.."SpawnedInToys")
local playerList = {}
local selection
local blobman
local platforms = {}
local ownedToys = {}
local bombList = {}
_G.ToyToLoad = "BombMissile"
_G.MaxMissiles = 9
_G.BlobmanDelay = 0.005

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

local function updatePlayerList()
    playerList = {}
    for _, player in ipairs(Players:GetPlayers()) do
        table.insert(playerList, player.Name)
    end
end

local function onPlayerAdded(player)
    table.insert(playerList, player.Name)
end

local function onPlayerRemoving(player)
    for i, name in ipairs(playerList) do
        if name == player.Name then
            table.remove(playerList, i)
            break
        end
    end
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

for i, v in pairs(localPlayer:WaitForChild("PlayerGui"):WaitForChild("MenuGui"):WaitForChild("Menu"):WaitForChild("TabContents"):WaitForChild("Toys"):WaitForChild("Contents"):GetChildren()) do
    if v.Name ~= "UIGridLayout" then
        ownedToys[v.Name] = true
    end
end

local function getNearestPlayer()
    local nearestPlayer
    local nearestDistance = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (playerCharacter.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if distance < nearestDistance then
                nearestDistance = distance
                nearestPlayer = player
            end
        end
    end
    return nearestPlayer
end

local function cleanupConnections(connectionTable)
    for _, connection in ipairs(connectionTable) do
        connection:Disconnect()
    end
    connectionTable = {}
end

local function getVersion()
    local url = "https://raw.githubusercontent.com/Undebolted/FTAP/main/VERSION.json"
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)
    if success then
        local data = HttpService:JSONDecode(response)
        return data.version
    else
        return "Unknown"
    end
end

local function spawnItem(itemName, position, orientation)
    task.spawn(function()
        local cframe = CFrame.new(position)
        local rotation = Vector3.new(0, 90, 0)
        ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer(itemName, cframe, rotation)
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
        handleCharacterAdded(player)
    end
    local playerAddedConnection = Players.PlayerAdded:Connect(handleCharacterAdded)
    table.insert(kickGrabConnections, playerAddedConnection)
end

local function grabHandler(grabType)
    while true do
        local success, err = pcall(function()
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
                    for _, part in pairs(partsTable) do
                        part.Position = Vector3.new(0, -200, 0)
                    end
                end
            end
        end)
        wait()
    end
end

local function fireGrab()
    while true do
        local success, err = pcall(function()
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
        local success, err = pcall(function()
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

local function spawnItemCf(itemName, cframe)
    task.spawn(function()
        local rotation = Vector3.new(0, 0, 0)
        ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer(itemName, cframe, rotation)
    end)
end

local function fireAll()
    while true do
        local success, err = pcall(function()
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
        local highlight = primaryPart:FindFirstChild("Highlight") or U.GetDescendant(U.FindFirstAncestorOfType(primaryPart, "Model"), "Highlight", "Highlight")
        if highlight then
            if descendant.Value ~= localPlayer.Name then
                highlight.OutlineColor = Color3.new(1, 0, 0)
            else
                highlight.OutlineColor = Color3.new(0, 0, 1)
            end
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
            local primaryPart = weldConstraint.Part1.Name == "SoundPart" and weldConstraint.Part1 or weldConstraint.Part1.Parent.SoundPart or weldConstraint.Part1.Parent.PrimaryPart or weldConstraint.Part1
            if not primaryPart then return end
            if primaryPart.Anchored then return end
            if isDescendantOf(primaryPart, workspace.Map) then return end
            for _, player in pairs(Players:GetChildren()) do
                if isDescendantOf(primaryPart, player.Character) then return end
            end
            local t = true
            for _, v in pairs(primaryPart:GetDescendants()) do
                if table.find(anchoredParts, v) then t = false end
            end
            if t and not table.find(anchoredParts, primaryPart) then
                local target
                if U.FindFirstAncestorOfType(primaryPart, "Model") and U.FindFirstAncestorOfType(primaryPart, "Model") ~= workspace then
                    target = U.FindFirstAncestorOfType(primaryPart, "Model")
                else
                    target = primaryPart
                end
                local highlight = createHighlight(target)
                table.insert(anchoredParts, primaryPart)
                local connection = target.DescendantAdded:Connect(function(descendant)
                    onPartOwnerAdded(descendant, primaryPart)
                end)
                table.insert(anchoredConnections, connection)
            end
            if U.FindFirstAncestorOfType(primaryPart, "Model") and U.FindFirstAncestorOfType(primaryPart, "Model") ~= workspace then
                for _, child in ipairs(U.FindFirstAncestorOfType(primaryPart, "Model"):GetDescendants()) do
                    if child:IsA("BodyPosition") or child:IsA("BodyGyro") then child:Destroy() end
                end
            else
                for _, child in ipairs(primaryPart:GetChildren()) do
                    if child:IsA("BodyPosition") or child:IsA("BodyGyro") then child:Destroy() end
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
                if child:IsA("BodyPosition") or child:IsA("BodyGyro") then child:Destroy() end
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
            local highlight = part:FindFirstChild("Highlight") or part.Parent and part.Parent:FindFirstChild("Highlight")
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
                if bodyPosition then bodyPosition.Position = (primaryPart.CFrame * data.offset).Position end
                if bodyGyro then bodyGyro.CFrame = primaryPart.CFrame * data.offset end
            end
        end
    end
end

local function compileGroup()
    if #anchoredParts == 0 then
        Notify("Error", "No anchored parts found", 5)
    else
        Notify("Success", "Compiled " .. #anchoredParts .. " Toys together", 5)
    end
    local primaryPart = anchoredParts[1]
    if not primaryPart then return end
    local highlight = primaryPart:FindFirstChild("Highlight") or primaryPart.Parent:FindFirstChild("Highlight")
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
        local success, err = pcall(function()
            local character = localPlayer.Character
            if character and character:FindFirstChild("Head") and character:FindFirstChild("HumanoidRootPart") then
                local head = character.Head
                local humanoidRootPart = character.HumanoidRootPart
                for _, partModel in pairs(anchoredParts) do
                    coroutine.wrap(function()
                        if partModel then
                            local distance = (partModel.Position - humanoidRootPart.Position).Magnitude
                            if distance <= 30 then
                                local highlight = partModel:FindFirstChild("Highlight") or partModel.Parent:FindFirstChild("Highlight")
                                if highlight and highlight.OutlineColor == Color3.new(1, 0, 0) then
                                    SetNetworkOwner:FireServer(partModel, partModel.CFrame)
                                    if partModel:WaitForChild("PartOwner") and partModel.PartOwner.Value == localPlayer.Name then
                                        highlight.OutlineColor = Color3.new(0, 0, 1)
                                    end
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

local function ragdollAll()
    while true do
        local success, err = pcall(function()
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

local function setupAntiExplosion(character)
    local partOwner = character:WaitForChild("Humanoid"):FindFirstChild("Ragdolled")
    if partOwner then
        local partOwnerChangedConn
        partOwnerChangedConn = partOwner:GetPropertyChangedSignal("Value"):Connect(function()
            if partOwner.Value then
                for _, part in ipairs(character:GetChildren()) do
                    if part:IsA("BasePart") then part.Anchored = true end
                end
            else
                for _, part in ipairs(character:GetChildren()) do
                    if part:IsA("BasePart") then part.Anchored = false end
                end
            end
        end)
        antiExplosionConnection = partOwnerChangedConn
    end
end

local blobalter = 1
local function blobGrabPlayer(player, blobman)
    if blobalter == 1 then
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local args = {
                [1] = blobman:FindFirstChild("LeftDetector"),
                [2] = player.Character:FindFirstChild("HumanoidRootPart"),
                [3] = blobman:FindFirstChild("LeftDetector"):FindFirstChild("LeftWeld")
            }
            blobman:WaitForChild("BlobmanSeatAndOwnerScript"):WaitForChild("CreatureGrab"):FireServer(unpack(args))
            blobalter = 2
        end
    else
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local args = {
                [1] = blobman:FindFirstChild("RightDetector"),
                [2] = player.Character:FindFirstChild("HumanoidRootPart"),
                [3] = blobman:FindFirstChild("RightDetector"):FindFirstChild("RightWeld")
            }
            blobman:WaitForChild("BlobmanSeatAndOwnerScript"):WaitForChild("CreatureGrab"):FireServer(unpack(args))
            blobalter = 1
        end
    end
end

local function _grabIsTargetingMe(grabParts)
    local char = localPlayer.Character
    if not char then return false end
    for _, child in ipairs(grabParts:GetChildren()) do
        local weld = child:FindFirstChildOfClass("WeldConstraint")
        if weld and weld.Part1 and weld.Part1:IsDescendantOf(char) then return true end
    end
    local grabPart = grabParts:FindFirstChild("GrabPart")
    if grabPart then
        local weld = grabPart:FindFirstChildOfClass("WeldConstraint")
        if weld and weld.Part1 and weld.Part1:IsDescendantOf(char) then return true end
    end
    return false
end

local version = getVersion()
local localVersion = "8.2-stable"
if localVersion ~= version then
    Notify("HexerHub", "Atualização Necessária...", 6)
    setclipboard('loadstring(game:HttpGet("https://raw.githubusercontent.com/Undebolted/FTAP/main/Script.lua",true))()')
    wait(12)
    Fluent:Destroy()
    wait(9e9)
end

-- ==========================================================
-- CRIAR JANELA FLUENT
-- ==========================================================
local Window = Fluent:CreateWindow({
    Title = "HexerHub",
    SubTitle = "by LeoLeoVip & NyDev",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.G,
})

local Tabs = {
    Home       = Window:AddTab({ Title = "Home",              Icon = "home" }),
    Combat     = Window:AddTab({ Title = "Combat",            Icon = "swords" }),
    Player     = Window:AddTab({ Title = "Local Player",      Icon = "user" }),
    ObjGrab    = Window:AddTab({ Title = "Object Grab",       Icon = "package" }),
    Defense    = Window:AddTab({ Title = "Anti Grab",         Icon = "shield" }),
    Blobman    = Window:AddTab({ Title = "Blob Man",          Icon = "zap" }),
    Fun        = Window:AddTab({ Title = "Fun / Troll",       Icon = "smile" }),
    Script     = Window:AddTab({ Title = "Script",            Icon = "terminal" }),
    Saved      = Window:AddTab({ Title = "Saved Scripts",     Icon = "bookmark" }),
    Admin      = Window:AddTab({ Title = "Admin (Owners)",    Icon = "shield-alert" }),
}

-- ==========================================================
-- HOME TAB
-- ==========================================================
Tabs.Home:AddParagraph({ Title = "UI / Fluent", Content = "Fluent library by dawid-scripts" })
Tabs.Home:AddParagraph({ Title = "Home!", Content = "Welcome to HexerHub! " .. localPlayer.Name .. " Thanks for using the script!" })
Tabs.Home:AddParagraph({ Title = "Hexer Discord", Content = "discord.gg/KtYXs9yh" })
Tabs.Home:AddButton({
    Title = "Join Discord",
    Description = "Copia o link do Discord",
    Callback = function()
        setclipboard("discord.gg/KtYXs9yh")
        Notify("Discord", "Link copiado para sua área de transferência!", 3)
    end,
})

-- ==========================================================
-- COMBAT TAB
-- ==========================================================
_G.strength = 400

Tabs.Combat:AddParagraph({ Title = "Combat Tab", Content = "Adjust the throwing force along the slider" })

Tabs.Combat:AddSlider("StrengthSlider", {
    Title = "Strength Power",
    Min = 300, Max = 10000, Default = 300, Rounding = 0,
    Callback = function(Value) _G.strength = Value end,
})

Tabs.Combat:AddSlider("GrabRangeSlider", {
    Title = "Grab Range",
    Description = "Studs",
    Min = 10, Max = 1000, Default = 10, Rounding = 0,
    Callback = function(Value) _G.GrabRange = Value end,
})

Tabs.Combat:AddToggle("GrabRangeToggle", {
    Title = "Enable Grab Range",
    Default = false,
    Callback = function(enabled)
        _G.GrabRangeEnabled = enabled
        if enabled then
            task.spawn(function()
                while _G.GrabRangeEnabled do
                    task.wait(0.5)
                    pcall(function()
                        local player = game.Players.LocalPlayer
                        if player.Character then
                            player.Character:SetAttribute("GrabDistance", _G.GrabRange)
                            player.Character:SetAttribute("GrabRange", _G.GrabRange)
                        end
                        for _, v in pairs(workspace:GetDescendants()) do
                            if v:IsA("ClickDetector") or v:IsA("ProximityPrompt") then
                                v.MaxActivationDistance = _G.GrabRange
                            end
                        end
                    end)
                end
            end)
        end
    end,
})

Tabs.Combat:AddToggle("StrengthToggle", {
    Title = "Strength",
    Default = false,
    Callback = function(enabled)
        if enabled then
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
                                else
                                    velocityObj:Destroy()
                                end
                            end
                        end)
                    end
                end
            end)
        elseif strengthConnection then
            strengthConnection:Disconnect()
        end
    end,
})

Tabs.Combat:AddParagraph({ Title = "Grab stuff", Content = "These effects apply when you grab someone" })

Tabs.Combat:AddToggle("PoisonGrab", {
    Title = "Poison Grab", Default = false,
    Callback = function(enabled)
        if enabled then
            poisonGrabCoroutine = coroutine.create(function() grabHandler("poison") end)
            coroutine.resume(poisonGrabCoroutine)
        else
            if poisonGrabCoroutine then
                coroutine.close(poisonGrabCoroutine)
                poisonGrabCoroutine = nil
                for _, part in pairs(poisonHurtParts) do part.Position = Vector3.new(0, -200, 0) end
            end
        end
    end,
})

Tabs.Combat:AddToggle("RadioactiveGrab", {
    Title = "Radioactive Grab", Default = false,
    Callback = function(enabled)
        if enabled then
            ufoGrabCoroutine = coroutine.create(function() grabHandler("radioactive") end)
            coroutine.resume(ufoGrabCoroutine)
        else
            if ufoGrabCoroutine then
                coroutine.close(ufoGrabCoroutine)
                ufoGrabCoroutine = nil
                for _, part in pairs(paintPlayerParts) do part.Position = Vector3.new(0, -200, 0) end
            end
        end
    end,
})

Tabs.Combat:AddToggle("FireGrab", {
    Title = "Fire Grab", Default = false,
    Callback = function(enabled)
        if enabled then
            fireGrabCoroutine = coroutine.create(fireGrab)
            coroutine.resume(fireGrabCoroutine)
        else
            if fireGrabCoroutine then coroutine.close(fireGrabCoroutine) fireGrabCoroutine = nil end
        end
    end,
})

Tabs.Combat:AddToggle("NoclipGrab", {
    Title = "Noclip Grab", Default = false,
    Callback = function(enabled)
        if enabled then
            noclipGrabCoroutine = coroutine.create(noclipGrab)
            coroutine.resume(noclipGrabCoroutine)
        else
            if noclipGrabCoroutine then coroutine.close(noclipGrabCoroutine) noclipGrabCoroutine = nil end
        end
    end,
})

Tabs.Combat:AddToggle("KickGrab", {
    Title = "Kick Grab", Default = false,
    Callback = function(enabled)
        if enabled then
            kickGrab()
        else
            for _, connection in pairs(kickGrabConnections) do connection:Disconnect() end
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = player.Character.HumanoidRootPart
                    if hrp:FindFirstChild("FirePlayerPart") then
                        local fpp = hrp.FirePlayerPart
                        fpp.Size = Vector3.new(2.5, 5.5, 2.5)
                        fpp.CollisionGroup = "Default"
                        fpp.CanQuery = false
                    end
                end
            end
            kickGrabConnections = {}
        end
    end,
})

Tabs.Combat:AddToggle("AnchorKickGrab", {
    Title = "Kick Grab Anchor", Default = false,
    Callback = function(enabled)
        if enabled then
            if not anchorKickCoroutine or coroutine.status(anchorKickCoroutine) == "dead" then
                anchorKickCoroutine = coroutine.create(anchorKickGrab)
                coroutine.resume(anchorKickCoroutine)
            end
        else
            if anchorKickCoroutine and coroutine.status(anchorKickCoroutine) ~= "dead" then
                coroutine.close(anchorKickCoroutine)
                anchorKickCoroutine = nil
            end
        end
    end,
})

Tabs.Combat:AddParagraph({ Title = "All-Features", Content = "Make sure there are no campfires spawned by you BEFORE using this" })

Tabs.Combat:AddToggle("FireAll", {
    Title = "Fire All", Default = false,
    Callback = function(enabled)
        if enabled then
            fireAllCoroutine = coroutine.create(fireAll)
            coroutine.resume(fireAllCoroutine)
        else
            if fireAllCoroutine then coroutine.close(fireAllCoroutine) fireAllCoroutine = nil end
        end
    end,
})

-- ==========================================================
-- LOCAL PLAYER TAB
-- ==========================================================
Tabs.Player:AddParagraph({ Title = "Local Player Tab", Content = "Player Settings" })

Tabs.Player:AddButton({
    Title = "Breaker PCLD (Reset 1x)",
    Callback = function()
        if localPlayer.Character then localPlayer.Character:BreakJoints() end
    end,
})

local defaultMinZoom, defaultMaxZoom = localPlayer.CameraMinZoomDistance, localPlayer.CameraMaxZoomDistance
Tabs.Player:AddToggle("ThirdPerson", {
    Title = "Third Person", Default = false,
    Callback = function(enabled)
        if enabled then
            localPlayer.CameraMode = Enum.CameraMode.Classic
            localPlayer.CameraMinZoomDistance = 10
            localPlayer.CameraMaxZoomDistance = 20
        else
            localPlayer.CameraMinZoomDistance = defaultMinZoom
            localPlayer.CameraMaxZoomDistance = defaultMaxZoom
        end
    end,
})

Tabs.Player:AddToggle("CrouchSpeed", {
    Title = "Force Custom Speed", Default = false,
    Callback = function(enabled)
        if enabled then
            crouchSpeedCoroutine = coroutine.create(function()
                while true do
                    pcall(function()
                        if not playerCharacter.Humanoid then return end
                        playerCharacter.Humanoid.WalkSpeed = crouchWalkSpeed
                    end)
                    wait()
                end
            end)
            coroutine.resume(crouchSpeedCoroutine)
        elseif crouchSpeedCoroutine then
            coroutine.close(crouchSpeedCoroutine)
            crouchSpeedCoroutine = nil
            if playerCharacter.Humanoid then playerCharacter.Humanoid.WalkSpeed = 16 end
        end
    end,
})

Tabs.Player:AddSlider("SpeedSlider", {
    Title = "Set Speed Value",
    Min = 6, Max = 1000, Default = 50, Rounding = 0,
    Callback = function(Value) crouchWalkSpeed = Value end,
})

Tabs.Player:AddToggle("CrouchJumpPower", {
    Title = "Force Custom Jump Power", Default = false,
    Callback = function(enabled)
        if enabled then
            crouchJumpCoroutine = coroutine.create(function()
                while true do
                    pcall(function()
                        if not playerCharacter.Humanoid then return end
                        playerCharacter.Humanoid.JumpPower = crouchJumpPower
                        playerCharacter.Humanoid.UseJumpPower = true
                    end)
                    wait()
                end
            end)
            coroutine.resume(crouchJumpCoroutine)
        elseif crouchJumpCoroutine then
            coroutine.close(crouchJumpCoroutine)
            crouchJumpCoroutine = nil
            if playerCharacter.Humanoid then playerCharacter.Humanoid.JumpPower = 50 end
        end
    end,
})

Tabs.Player:AddSlider("JumpSlider", {
    Title = "Set Jump Power",
    Min = 6, Max = 1000, Default = 50, Rounding = 0,
    Callback = function(Value) crouchJumpPower = Value end,
})

Tabs.Player:AddParagraph({ Title = "🌊 Walk on Water", Content = "Ativa a colisão em todos os blocos de Ocean do mapa, permitindo andar na água como se fosse chão." })

Tabs.Player:AddToggle("WalkOnWater", {
    Title = "Walk on Water", Default = false,
    Callback = function(enabled)
        if enabled then
            local function enableOceanCollision()
                pcall(function()
                    for _, desc in ipairs(workspace.Map:GetDescendants()) do
                        if desc:IsA("BasePart") and desc.Name == "Ocean" then
                            desc.CanCollide = true
                            desc.Locked = false
                        end
                    end
                end)
            end
            enableOceanCollision()
            walkOnWaterCoroutine = task.spawn(function()
                while task.wait(2) do enableOceanCollision() end
            end)
            Notify("Walk on Water", "Ativado! Agora você pode andar na água.", 3)
        else
            if walkOnWaterCoroutine then
                task.cancel(walkOnWaterCoroutine)
                walkOnWaterCoroutine = nil
            end
            pcall(function()
                for _, desc in ipairs(workspace.Map:GetDescendants()) do
                    if desc:IsA("BasePart") and desc.Name == "Ocean" then
                        desc.CanCollide = false
                    end
                end
            end)
            Notify("Walk on Water", "Desativado.", 3)
        end
    end,
})

Tabs.Player:AddParagraph({ Title = "🌀 Loop Void", Content = "Teleporta você ao void infinitamente em loop. Desative para parar." })

Tabs.Player:AddToggle("LoopVoid", {
    Title = "🌀 Loop Void", Default = false,
    Callback = function(enabled)
        if enabled then
            loopVoidThread = task.spawn(function()
                while true do
                    pcall(function()
                        local char = localPlayer.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            char.HumanoidRootPart.CFrame = CFrame.new(0, -30000, 0)
                        end
                    end)
                    task.wait(0.05)
                end
            end)
            Notify("🌀 Loop Void ON", "Você está sendo teleportado ao void em loop!", 3)
        else
            if loopVoidThread then
                task.cancel(loopVoidThread)
                loopVoidThread = nil
            end
            Notify("🌀 Loop Void OFF", "Loop Void desativado.", 2)
        end
    end,
})

-- ==========================================================
-- OBJECT GRAB TAB
-- ==========================================================
Tabs.ObjGrab:AddParagraph({ Title = "ObjectGrab Tab", Content = "Function when grabbing an object" })

Tabs.ObjGrab:AddToggle("AnchorGrab", {
    Title = "Anchor Grab", Default = false,
    Callback = function(enabled)
        if enabled then
            if not anchorGrabCoroutine or coroutine.status(anchorGrabCoroutine) == "dead" then
                anchorGrabCoroutine = coroutine.create(anchorGrab)
                coroutine.resume(anchorGrabCoroutine)
            end
        else
            if anchorGrabCoroutine and coroutine.status(anchorGrabCoroutine) ~= "dead" then
                coroutine.close(anchorGrabCoroutine)
                anchorGrabCoroutine = nil
            end
        end
    end,
})

Tabs.ObjGrab:AddParagraph({ Title = "Anchor Grab Info", Content = "If someone grabs your anchored parts, they will fall and you will need to position them again!" })

Tabs.ObjGrab:AddButton({ Title = "Unanchor parts", Callback = cleanupAnchoredParts })

Tabs.ObjGrab:AddButton({
    Title = "Disassemble Parts",
    Callback = function()
        cleanupCompiledGroups()
        cleanupAnchoredParts()
        if compileCoroutine and coroutine.status(compileCoroutine) ~= "dead" then
            coroutine.close(compileCoroutine)
            compileCoroutine = nil
        end
    end,
})

Tabs.ObjGrab:AddToggle("AutoRecoverDroppedParts", {
    Title = "Auto Recover Dropped Parts", Default = false,
    Callback = function(enabled)
        if enabled then
            if not AutoRecoverDroppedPartsCoroutine or coroutine.status(AutoRecoverDroppedPartsCoroutine) == "dead" then
                AutoRecoverDroppedPartsCoroutine = coroutine.create(recoverParts)
                coroutine.resume(AutoRecoverDroppedPartsCoroutine)
            end
        else
            if AutoRecoverDroppedPartsCoroutine and coroutine.status(AutoRecoverDroppedPartsCoroutine) ~= "dead" then
                coroutine.close(AutoRecoverDroppedPartsCoroutine)
                AutoRecoverDroppedPartsCoroutine = nil
            end
        end
    end,
})

Tabs.ObjGrab:AddButton({ Title = "Unanchor Header Part", Callback = unanchorPrimaryPart })

-- ==========================================================
-- ANTI GRAB / DEFENSE TAB
-- ==========================================================
Tabs.Defense:AddParagraph({ Title = "Defense Tab", Content = "Anti System" })

Tabs.Defense:AddToggle("AutoStruggle", {
    Title = "Anti Grab", Default = false,
    Callback = function(enabled)
        if enabled then
            antiGrabChildListener = workspace.ChildAdded:Connect(function(child)
                if child.Name ~= "GrabParts" then return end
                task.wait()
                if not _grabIsTargetingMe(child) then return end
                task.spawn(function()
                    local iters = 0
                    while child and child.Parent and iters < 100 do
                        pcall(function() Struggle:FireServer() end)
                        task.wait(0.02)
                        iters = iters + 1
                    end
                end)
            end)
            antiGrabHeartbeatConn = RunService.Heartbeat:Connect(function()
                local char = localPlayer.Character
                if not char then return end
                local head = char:FindFirstChild("Head")
                if head then
                    local partOwner = head:FindFirstChild("PartOwner")
                    if partOwner and partOwner.Value ~= "" and partOwner.Value ~= localPlayer.Name then
                        pcall(function() Struggle:FireServer() end)
                    end
                end
                local isHeld = localPlayer:FindFirstChild("IsHeld")
                if isHeld and isHeld.Value == true then
                    pcall(function() Struggle:FireServer() end)
                end
                local grabParts = workspace:FindFirstChild("GrabParts")
                if grabParts and _grabIsTargetingMe(grabParts) then
                    pcall(function() Struggle:FireServer() end)
                end
            end)
            Notify("Anti Grab ON ✅", "Grab ignorado silenciosamente.", 3)
        else
            if antiGrabChildListener then antiGrabChildListener:Disconnect() antiGrabChildListener = nil end
            if antiGrabHeartbeatConn then antiGrabHeartbeatConn:Disconnect() antiGrabHeartbeatConn = nil end
            Notify("Anti Grab OFF", "Proteção desativada.", 2)
        end
    end,
})

Tabs.Defense:AddToggle("AntiKickGrab", {
    Title = "Anti Kick Grab", Default = false,
    Callback = function(enabled)
        if enabled then
            antiKickCoroutine = RunService.Heartbeat:Connect(function()
                local character = localPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("HumanoidRootPart"):FindFirstChild("FirePlayerPart") then
                    local partOwner = character:FindFirstChild("HumanoidRootPart"):FindFirstChild("FirePlayerPart"):FindFirstChild("PartOwner")
                    if partOwner and partOwner.Value ~= localPlayer.Name then
                        local args = {[1] = character:WaitForChild("HumanoidRootPart"), [2] = 0}
                        game:GetService("ReplicatedStorage"):WaitForChild("CharacterEvents"):WaitForChild("RagdollRemote"):FireServer(unpack(args))
                        wait(0.1)
                        Struggle:FireServer()
                    end
                end
            end)
        else
            if antiKickCoroutine then antiKickCoroutine:Disconnect() antiKickCoroutine = nil end
        end
    end,
})

Tabs.Defense:AddToggle("AntiExplosion", {
    Title = "Anti Explosion", Default = false,
    Callback = function(enabled)
        local localPlayer = game.Players.LocalPlayer
        if enabled then
            if localPlayer.Character then setupAntiExplosion(localPlayer.Character) end
            characterAddedConn = localPlayer.CharacterAdded:Connect(function(character)
                if antiExplosionConnection then antiExplosionConnection:Disconnect() end
                setupAntiExplosion(character)
            end)
        else
            if antiExplosionConnection then antiExplosionConnection:Disconnect() antiExplosionConnection = nil end
            if characterAddedConn then characterAddedConn:Disconnect() characterAddedConn = nil end
        end
    end,
})

-- Anti-Blobman
local antiBlobmanThread = nil
Tabs.Defense:AddToggle("AntiBlobman", {
    Title = "Anti-Blobman", Default = false,
    Callback = function(enabled)
        if enabled then
            antiBlobmanThread = task.spawn(function()
                while true do
                    pcall(function()
                        for _, obj in ipairs(workspace:GetDescendants()) do
                            if obj.Name == "CreatureBlobman" then
                                local leftDetector = obj:FindFirstChild("LeftDetector")
                                local rightDetector = obj:FindFirstChild("RightDetector")
                                if leftDetector then
                                    local leftWeld = leftDetector:FindFirstChild("LeftWeld")
                                    if leftWeld and leftWeld:IsA("WeldConstraint") then
                                        local p1 = leftWeld.Part1
                                        if p1 and localPlayer.Character and p1:IsDescendantOf(localPlayer.Character) then
                                            pcall(function() Struggle:FireServer() end)
                                        end
                                    end
                                end
                                if rightDetector then
                                    local rightWeld = rightDetector:FindFirstChild("RightWeld")
                                    if rightWeld and rightWeld:IsA("WeldConstraint") then
                                        local p1 = rightWeld.Part1
                                        if p1 and localPlayer.Character and p1:IsDescendantOf(localPlayer.Character) then
                                            pcall(function() Struggle:FireServer() end)
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.05)
                end
            end)
            Notify("Anti-Blobman ON ✅", "Proteção contra Blobman ativada.", 3)
        else
            if antiBlobmanThread then task.cancel(antiBlobmanThread) antiBlobmanThread = nil end
            Notify("Anti-Blobman OFF", "Proteção desativada.", 2)
        end
    end,
})

Tabs.Defense:AddToggle("SelfDefenseAirSuspend", {
    Title = "Self Defense / Air Suspend", Default = false,
    Callback = function(enabled)
        if enabled then
            autoDefendCoroutine = coroutine.create(function()
                while wait(0.02) do
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
                end
            end)
            coroutine.resume(autoDefendCoroutine)
        else
            if autoDefendCoroutine then coroutine.close(autoDefendCoroutine) autoDefendCoroutine = nil end
        end
    end,
})

-- ==========================================================
-- BLOBMAN TAB
-- ==========================================================
Tabs.Blobman:AddParagraph({ Title = "Blobman Tab", Content = "Destroy server | More added? Send DM" })

local blobman1Ref
blobman1Ref = Tabs.Blobman:AddToggle("DestroyServer", {
    Title = "Destroy server", Default = false,
    Callback = function(enabled)
        if enabled then
            blobmanCoroutine = coroutine.create(function()
                local foundBlobman = false
                for i, v in pairs(game.Workspace:GetDescendants()) do
                    if v.Name == "CreatureBlobman" then
                        if v:FindFirstChild("VehicleSeat") and v.VehicleSeat:FindFirstChild("SeatWeld") and isDescendantOf(v.VehicleSeat.SeatWeld.Part1, localPlayer.Character) then
                            blobman = v
                            foundBlobman = true
                            break
                        end
                    end
                end
                if not foundBlobman then
                    Notify("Error", "You must be mounted upon a blobman to begin this process. Please mount one and toggle this again!", 3)
                    blobman1Ref:SetValue(false)
                    blobman = nil
                    coroutine.close(blobmanCoroutine)
                    blobmanCoroutine = nil
                    return
                end
                while true do
                    pcall(function()
                        while wait() do
                            for i, v in pairs(Players:GetChildren()) do
                                if blobman and v ~= localPlayer then
                                    blobGrabPlayer(v, blobman)
                                    wait(_G.BlobmanDelay)
                                end
                            end
                        end
                    end)
                    wait(0.02)
                end
            end)
            coroutine.resume(blobmanCoroutine)
        else
            if blobmanCoroutine then coroutine.close(blobmanCoroutine) blobmanCoroutine = nil blobman = nil end
        end
    end,
})

Tabs.Blobman:AddSlider("BlobmanSpeed", {
    Title = "Destroy server Speed",
    Min = 0.05, Max = 1, Default = 0.5, Rounding = 2,
    Callback = function(Value) _G.BlobmanDelay = Value end,
})

-- ==========================================================
-- FUN / TROLL TAB
-- ==========================================================
Tabs.Fun:AddParagraph({ Title = "Fun Tab", Content = "Troll and Fun!" })

local coinInput = ""
Tabs.Fun:AddInput("CoinInput", {
    Title = "Number of coins",
    Default = "", Placeholder = "Number",
    Callback = function(Text) coinInput = Text end,
})

Tabs.Fun:AddButton({
    Title = "Get Coin",
    Callback = function()
        local coinAmount = tonumber(coinInput) or 0
        game.Players.LocalPlayer.PlayerGui.MenuGui.TopRight.CoinsFrame.CoinsDisplay.Coins.Text = tostring(coinAmount)
    end,
})

Tabs.Fun:AddSlider("OffsetSlider", {
    Title = "Offset",
    Min = 1, Max = 10, Default = 10, Rounding = 0,
    Callback = function(Value) decoyOffset = Value end,
})

Tabs.Fun:AddInput("CircleRadiusInput", {
    Title = "Circle Radius",
    Default = "", Placeholder = "Radius for Surround Mode (Adjust based on clones)",
    Callback = function(Value) circleRadius = tonumber(Value) or 10 end,
})

Tabs.Fun:AddButton({
    Title = "Decoy Follow",
    Callback = function()
        local decoys = {}
        for _, descendant in pairs(workspace:GetDescendants()) do
            if descendant:IsA("Model") and descendant.Name == "YouDecoy" then
                table.insert(decoys, descendant)
            end
        end
        local numDecoys = #decoys
        local midPoint = math.ceil(numDecoys / 2)
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
                                bodyGyro.CFrame = CFrame.new(torso.Position, nearestPlayer.Character.HumanoidRootPart.Position)
                            end
                        end
                        if targetPosition then
                            local distance = (targetPosition - torso.Position).Magnitude
                            if distance > stopDistance then
                                bodyPosition.Position = targetPosition
                                if followMode then bodyGyro.CFrame = CFrame.new(torso.Position, targetPosition) end
                            else
                                bodyPosition.Position = torso.Position
                                bodyGyro.CFrame = torso.CFrame
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
                local connection = RunService.Heartbeat:Connect(function()
                    updateDecoyPositions()
                end)
                table.insert(connections, connection)
                SetNetworkOwner:FireServer(torso, playerCharacter.Head.CFrame)
            end
        end
        for _, decoy in pairs(decoys) do setupDecoy(decoy) end
        Notify("Decoy", "Got " .. numDecoys .. " units. Manually click each unit if they don't move", 6)
    end,
})

Tabs.Fun:AddButton({
    Title = "Toggle Mode",
    Callback = function() followMode = not followMode end,
})

Tabs.Fun:AddButton({
    Title = "Disconnect Clones",
    Callback = function() cleanupConnections(connections) end,
})

-- ==========================================================
-- SCRIPT TAB & SAVED SCRIPTS
-- ==========================================================
local SaveFileName = "HexerHub_SavedScripts.json"
local SavedScriptsDB = {
    ["Infinite Yield"] = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()'
}

pcall(function()
    if isfile and isfile(SaveFileName) then
        local data = readfile(SaveFileName)
        local decoded = HttpService:JSONDecode(data)
        for k, v in pairs(decoded) do SavedScriptsDB[k] = v end
    end
end)

local function SaveScriptsToFile()
    pcall(function()
        if writefile then writefile(SaveFileName, HttpService:JSONEncode(SavedScriptsDB)) end
    end)
end

Tabs.Saved:AddButton({
    Title = "Remove All Saved Scripts",
    Callback = function()
        SavedScriptsDB = {}
        SaveScriptsToFile()
        Notify("Removido!", "Todos os scripts salvos foram apagados. Reinicie o script para limpar a aba.", 5)
    end,
})

for scriptName, scriptCode in pairs(SavedScriptsDB) do
    Tabs.Saved:AddButton({
        Title = scriptName,
        Callback = function()
            local success, err = pcall(function() loadstring(scriptCode)() end)
            if not success then
                warn("Execution Error: " .. tostring(err))
                Notify("Erro na Execução", "Script: " .. scriptName .. " falhou.", 4)
            end
        end,
    })
end

local currentScriptCode = ""
local currentScriptName = ""

Tabs.Script:AddParagraph({ Title = "Executor", Content = "Cole seu script abaixo para executar ou salvar para depois." })

Tabs.Script:AddInput("ScriptCode", {
    Title = "Colar Script",
    Default = "", Placeholder = "Cole o código Lua aqui...",
    Callback = function(Text) currentScriptCode = Text end,
})

Tabs.Script:AddButton({
    Title = "Executar Script",
    Callback = function()
        if currentScriptCode ~= "" then
            local success, err = pcall(function() loadstring(currentScriptCode)() end)
            if not success then
                warn("Erro na execução: " .. tostring(err))
                Notify("Erro de Script", "Falha ao executar. Pressione F9 para detalhes.", 4)
            else
                Notify("Sucesso", "Script executado com sucesso!", 3)
            end
        else
            Notify("Atenção", "Você precisa colar um script antes de executar!", 3)
        end
    end,
})

Tabs.Script:AddInput("ScriptName", {
    Title = "Nome do Script para Salvar",
    Default = "", Placeholder = "Ex: Script de Voar...",
    Callback = function(Text) currentScriptName = Text end,
})

Tabs.Script:AddButton({
    Title = "Salvar Script",
    Callback = function()
        if currentScriptName == "" or currentScriptName:match("^%s*$") then
            Notify("Erro", "Por favor, digite um nome para o script antes de salvar!", 4)
            return
        end
        if currentScriptCode == "" or currentScriptCode:match("^%s*$") then
            Notify("Erro", "A caixa de código está vazia. Cole o script primeiro!", 4)
            return
        end
        SavedScriptsDB[currentScriptName] = currentScriptCode
        SaveScriptsToFile()
        Tabs.Saved:AddButton({
            Title = currentScriptName,
            Callback = function()
                local success, err = pcall(function() loadstring(SavedScriptsDB[currentScriptName])() end)
                if not success then
                    warn("Execution Error: " .. tostring(err))
                    Notify("Erro", "Falha ao executar script salvo.", 4)
                end
            end,
        })
        Notify("Salvo!", "Script '" .. currentScriptName .. "' adicionado à aba Saved Scripts!", 4)
    end,
})

-- ==========================================================
-- ADMIN PANEL
-- ==========================================================
local _AdminLoaded = false
local currentKeyAttempt = ""
local selectedAdminPlayer = ""
local adminChatMsg = ""

local function isLocalPlayerCreator()
    return isCreator(localPlayer)
end

Tabs.Admin:AddParagraph({
    Title = "🔐 Admin Panel - HexerHub",
    Content = "Creators (gabezinho278 / LeoLeoVip_Official) têm acesso automático. Outros admins usam a key.",
})

Tabs.Admin:AddInput("AdminKey", {
    Title = "Admin Key",
    Default = "", Placeholder = "Insira a key secreta...",
    Callback = function(Text) currentKeyAttempt = Text end,
})

Tabs.Admin:AddButton({
    Title = "Unlock Admin Panel",
    Callback = function()
        local hasAccess = isLocalPlayerCreator() or
                          (currentKeyAttempt == "NyVipHexer_UI8c88527e-4d95-49d9-9bad-c041872fc0bf")

        if hasAccess then
            local label = isLocalPlayerCreator() and "Creator" or "Admin"
            Notify("Acesso Concedido ✅", "Bem-vindo(a), " .. label .. "! Carregando painel...", 3)

            if not _AdminLoaded then
                _AdminLoaded = true

                Tabs.Admin:AddParagraph({
                    Title = "⚡ Como funcionam os comandos",
                    Content = "Os comandos afetam TODOS os players usando o script (exceto creators e bypassed). Selecione o player no dropdown e clique no comando.",
                })

                local currentServerPlayers = {"all"}
                for _, v in pairs(Players:GetPlayers()) do
                    if v ~= localPlayer then table.insert(currentServerPlayers, v.Name) end
                end

                local PlayerDropdown = Tabs.Admin:AddDropdown("AdminPlayerDropdown", {
                    Title = "Selecionar Player Alvo",
                    Values = currentServerPlayers,
                    Default = 1,
                    Callback = function(Option) selectedAdminPlayer = Option end,
                })

                Tabs.Admin:AddButton({
                    Title = "🔄 Refresh Lista de Players",
                    Callback = function()
                        local newNames = {"all"}
                        for _, v in pairs(Players:GetPlayers()) do
                            if v ~= localPlayer then table.insert(newNames, v.Name) end
                        end
                        PlayerDropdown:SetValues(newNames)
                        Notify("Atualizado", "Lista de players atualizada!", 2)
                    end,
                })

                -- KILL
                Tabs.Admin:AddButton({
                    Title = "💀 Kill",
                    Callback = function()
                        if selectedAdminPlayer ~= "" then
                            sendAdminCommand("kill", selectedAdminPlayer)
                            Notify("Kill", "Comando enviado para: " .. selectedAdminPlayer, 2)
                        else
                            Notify("Erro", "Selecione um player primeiro!", 2)
                        end
                    end,
                })

                -- LOOPKILL
                Tabs.Admin:AddToggle("AdminLK", {
                    Title = "🔁 LoopKill", Default = false,
                    Callback = function(Value)
                        if selectedAdminPlayer ~= "" then
                            if Value then
                                sendAdminCommand("loopkill", selectedAdminPlayer)
                                Notify("LoopKill ON", selectedAdminPlayer .. " será morto em loop!", 3)
                            else
                                sendAdminCommand("stoplk", selectedAdminPlayer)
                                Notify("LoopKill OFF", "Loop kill parado para " .. selectedAdminPlayer, 2)
                            end
                        else
                            Notify("Erro", "Selecione um player primeiro!", 2)
                        end
                    end,
                })

                -- KICK
                Tabs.Admin:AddButton({
                    Title = "👢 Kick",
                    Callback = function()
                        if selectedAdminPlayer ~= "" then
                            sendAdminCommand("kick", selectedAdminPlayer)
                            Notify("Kick", selectedAdminPlayer .. " foi kickado! #Hexer_hub", 3)
                        else
                            Notify("Erro", "Selecione um player primeiro!", 2)
                        end
                    end,
                })

                -- BAN
                Tabs.Admin:AddButton({
                    Title = "🔨 Ban (Permanente)",
                    Callback = function()
                        if selectedAdminPlayer ~= "" then
                            sendAdminCommand("ban", selectedAdminPlayer)
                            Notify("Ban", selectedAdminPlayer .. " foi banido permanentemente!", 5)
                        else
                            Notify("Erro", "Selecione um player primeiro!", 2)
                        end
                    end,
                })

                -- JUMPSCARE
                Tabs.Admin:AddButton({
                    Title = "😱 JumpScare",
                    Callback = function()
                        if selectedAdminPlayer ~= "" then
                            sendAdminCommand("js", selectedAdminPlayer)
                            Notify("JumpScare!", "Jumpscare enviado para " .. selectedAdminPlayer, 2)
                        else
                            Notify("Erro", "Selecione um player primeiro!", 2)
                        end
                    end,
                })

                -- BRING
                Tabs.Admin:AddButton({
                    Title = "🧲 Bring (Puxar até mim)",
                    Callback = function()
                        if selectedAdminPlayer ~= "" then
                            sendAdminCommand("bring", selectedAdminPlayer)
                            Notify("Bring", selectedAdminPlayer .. " foi puxado até você!", 2)
                        else
                            Notify("Erro", "Selecione um player primeiro!", 2)
                        end
                    end,
                })

                -- FREEZE
                Tabs.Admin:AddToggle("AdminFreeze", {
                    Title = "🧊 Freezer (Congelar)", Default = false,
                    Callback = function(Value)
                        if selectedAdminPlayer ~= "" then
                            if Value then
                                sendAdminCommand("freezer", selectedAdminPlayer)
                                Notify("Freezer ON", selectedAdminPlayer .. " foi congelado!", 2)
                            else
                                sendAdminCommand("unfreeze", selectedAdminPlayer)
                                Notify("Freezer OFF", selectedAdminPlayer .. " foi descongelado.", 2)
                            end
                        else
                            Notify("Erro", "Selecione um player primeiro!", 2)
                        end
                    end,
                })

                -- BYPASS
                Tabs.Admin:AddToggle("AdminBypass", {
                    Title = "🛡️ Bypass (Imunidade)", Default = false,
                    Callback = function(Value)
                        if selectedAdminPlayer ~= "" then
                            if Value then
                                sendAdminCommand("bypass", selectedAdminPlayer)
                                Notify("Bypass ON", selectedAdminPlayer .. " agora é imune!", 3)
                            else
                                sendAdminCommand("unbypass", selectedAdminPlayer)
                                Notify("Bypass OFF", "Imunidade de " .. selectedAdminPlayer .. " removida.", 2)
                            end
                        else
                            sendAdminCommand("bypass", "me")
                            Notify("Bypass", "Você ativou sua própria proteção!", 3)
                        end
                    end,
                })

                -- CHAT
                Tabs.Admin:AddInput("AdminChatMsg", {
                    Title = "Mensagem para o player falar",
                    Default = "", Placeholder = "Ex: Olá, eu sou controlado!",
                    Callback = function(Text) adminChatMsg = Text end,
                })

                Tabs.Admin:AddButton({
                    Title = "💬 Chat (Forçar falar)",
                    Callback = function()
                        if selectedAdminPlayer ~= "" and adminChatMsg ~= "" then
                            sendAdminCommand("chat", selectedAdminPlayer, adminChatMsg)
                            Notify("Chat", selectedAdminPlayer .. " vai dizer: " .. adminChatMsg, 3)
                        else
                            Notify("Erro", "Selecione um player e escreva a mensagem!", 2)
                        end
                    end,
                })

                Tabs.Admin:AddButton({
                    Title = "📢 Chat para TODOS (all)",
                    Callback = function()
                        if adminChatMsg ~= "" then
                            sendAdminCommand("chat", "all", adminChatMsg)
                            Notify("Chat All", "Todos os players vão dizer: " .. adminChatMsg, 3)
                        else
                            Notify("Erro", "Escreva uma mensagem primeiro!", 2)
                        end
                    end,
                })
            end
        else
            Notify("Acesso Negado ❌", "Key incorreta! Você não é admin.", 3)
        end
    end,
})

-- ==========================================================
-- MINIMIZAR COM G (já configurado no MinimizeKey acima)
-- ==========================================================

Window:SelectTab(1)
