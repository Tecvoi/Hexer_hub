-- Hexer Hub - Ultimate Exploit Script for Fling Things and People
-- Created by GitHub Copilot
-- Owners: Replace with actual UserIds or Names
local Owners = {4406877492, 2962384943} -- Example UserIds
-- Admins: Replace with actual UserIds or Names
local Admins = {111111111, 222222222, 333333333, 444444444, 555555555} -- Example UserIds

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ContextActionService = game:GetService("ContextActionService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Rayfield Library Load
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Hexer Hub - Ultimate Exploit",
    LoadingTitle = "Loading Hexer Hub...",
    LoadingSubtitle = "by GitHub Copilot",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "HexerHub",
        FileName = "Config"
    },
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = true
    },
    KeySystem = false,
    KeySettings = {
        Title = "Hexer Hub",
        Subtitle = "Key System",
        Note = "No key required",
        FileName = "Key",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {"Hello"}
    }
})

-- Tabs
local MainTab = Window:CreateTab("Main", 4483345998)
local MainSection = MainTab:CreateSection("Main Features")

local CombatTab = Window:CreateTab("Combat", 4483345998)
local CombatSection = CombatTab:CreateSection("Combat Features")

local MovementTab = Window:CreateTab("Movement", 4483345998)
local MovementSection = MovementTab:CreateSection("Movement Settings")

local GrabTab = Window:CreateTab("Grab", 4483345998)
local GrabSection = GrabTab:CreateSection("Grab Enhancements")

local AdminTab = Window:CreateTab("Admin", 4483345998)
local AdminSection = AdminTab:CreateSection("Admin Commands")

local MiscTab = Window:CreateTab("Misc", 4483345998)
local MiscSection = MiscTab:CreateSection("Miscellaneous")

-- Functions
local function IsOwner(player)
    return table.find(Owners, player.UserId) or table.find(Owners, player.Name)
end

local function IsAdmin(player)
    return table.find(Admins, player.UserId) or table.find(Admins, player.Name) or IsOwner(player)
end

local function BypassCheck(target)
    if IsAdmin(target) then
        return true -- Immune
    end
    return false
end

local BannedUsers = {} -- List of banned users

local function IsBanned(player)
    return table.find(BannedUsers, player.UserId) or table.find(BannedUsers, player.Name)
end

if IsBanned(LocalPlayer) then
    Rayfield:Notify({
        Title = "Banned",
        Content = "You are banned from using Hexer Hub.",
        Duration = 5,
        Image = 4483345998,
    })
    return
end

-- Commands Handler
LocalPlayer.Chatted:Connect(function(message)
    local args = string.split(message, " ")
    local cmd = args[1]:lower()
    local targetName = args[2]
    local target = targetName and Players:FindFirstChild(targetName)

    if cmd == ":kill" and target and IsAdmin(LocalPlayer) then
        if not BypassCheck(target) then
            -- Kill logic
            local humanoid = target.Character and target.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.Health = 0
            end
        end
    elseif cmd == ":loopkill" and target and IsAdmin(LocalPlayer) then
        if not BypassCheck(target) then
            -- Loop kill
            spawn(function()
                while target and target.Character do
                    local humanoid = target.Character:FindFirstChild("Humanoid")
                    if humanoid then
                        humanoid.Health = 0
                    end
                    wait(1)
                end
            end)
        end
    elseif cmd == ":bring" and target and IsAdmin(LocalPlayer) then
        if not BypassCheck(target) then
            -- Bring
            local targetHRP = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP then
                targetHRP.CFrame = HumanoidRootPart.CFrame
            end
        end
    elseif cmd == ":kick" and target and IsOwner(LocalPlayer) then
        -- Kick from script (simulate)
        target:Kick("Kicked by Hexer Hub Owner")
    elseif cmd == ":ban" and target and IsOwner(LocalPlayer) then
        table.insert(BannedUsers, target.UserId)
        target:Kick("Banned by Hexer Hub Owner")
    elseif cmd == ":js" and target and IsAdmin(LocalPlayer) then
        if not BypassCheck(target) then
            -- Jumpscare
            local jumpscareGui = Instance.new("ScreenGui")
            jumpscareGui.Parent = target.PlayerGui
            local image = Instance.new("ImageLabel")
            image.Image = "rbxassetid://123456789" -- Replace with jumpscare image ID
            image.Size = UDim2.new(1,0,1,0)
            image.Parent = jumpscareGui
            wait(2)
            jumpscareGui:Destroy()
        end
    end
end)

-- Bypass for Admins/Owners
local function MakeImmune()
    if IsAdmin(LocalPlayer) then
        -- Make character ungrabable, unkillable
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Anchored = true -- Temporary anchor to prevent grabs
                part.CanCollide = false
            end
        end
        Humanoid.Health = math.huge
        Humanoid.MaxHealth = math.huge
    end
end

MakeImmune()

-- Main Features
MainSection:CreateButton({
    Name = "God Mode",
    Callback = function()
        Humanoid.Health = math.huge
        Humanoid.MaxHealth = math.huge
        Rayfield:Notify({
            Title = "Activated",
            Content = "God Mode enabled!",
            Duration = 3,
            Image = 4483345998,
        })
    end
})

MainSection:CreateButton({
    Name = "Infinite Jump",
    Callback = function()
        local infJump = true
        UserInputService.JumpRequest:Connect(function()
            if infJump then
                Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
        Rayfield:Notify({
            Title = "Activated",
            Content = "Infinite Jump enabled!",
            Duration = 3,
            Image = 4483345998,
        })
    end
})

-- Combat Tab
CombatSection:CreateButton({
    Name = "Kill All",
    Callback = function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and not BypassCheck(player) then
                local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.Health = 0
                end
            end
        end
    end
})

-- Movement Tab
MovementSection:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 500},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(value)
        Humanoid.WalkSpeed = value
    end
})

MovementSection:CreateSlider({
    Name = "JumpPower",
    Range = {50, 500},
    Increment = 1,
    Suffix = "Power",
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(value)
        Humanoid.JumpPower = value
    end
})

-- Grab Tab (Enhanced Grabbing)
local GrabEnabled = false
GrabSection:CreateToggle({
    Name = "Infinite Grab Distance",
    CurrentValue = false,
    Flag = "InfiniteGrab",
    Callback = function(value)
        GrabEnabled = value
        if value then
            -- Modify grab distance to infinite
            local GrabEvents = ReplicatedStorage:WaitForChild("GrabEvents")
            local ExtendGrabLine = GrabEvents:WaitForChild("ExtendGrabLine")
            ExtendGrabLine:FireServer(999999) -- Infinite distance
        end
    end
})

GrabSection:CreateButton({
    Name = "Throw All",
    Callback = function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and not BypassCheck(player) then
                -- Throw logic from GrabbingScript
                local GrabEvents = ReplicatedStorage:WaitForChild("GrabEvents")
                local CreateGrabLine = GrabEvents:WaitForChild("CreateGrabLine")
                CreateGrabLine:FireServer(player.Character, player.Character.HumanoidRootPart)
                wait(0.1)
                local Throw = GrabEvents:WaitForChild("DestroyGrabLine")
                Throw:FireServer(player.Character)
            end
        end
    end
})

-- Admin Tab
AdminSection:CreateInput({
    Name = "Command Input",
    PlaceholderText = "Enter command (e.g., :kill username)",
    RemoveTextAfterFocusLost = true,
    Callback = function(value)
        LocalPlayer:Chat(value) -- Simulate chat for commands
    end
})

-- Misc Tab
MiscSection:CreateButton({
    Name = "Disable Core GUI",
    Callback = function()
        local StarterGui = game:GetService("StarterGui")
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
    end
})

MiscSection:CreateButton({
    Name = "Spawn Poison Balls",
    Callback = function()
        -- From PoisonBallSpawner
        local FactoryIsland = workspace:WaitForChild("Map"):WaitForChild("FactoryIsland")
        for i = 1, 10 do
            local clone = FactoryIsland:WaitForChild("PoisonBallDripper1"):Clone()
            clone.Transparency = 0
            clone.Name = "Drip"
            clone.Parent = FactoryIsland
            clone.Anchored = false
            game:GetService("Debris"):AddItem(clone, 3)
        end
    end
})

-- Ragdoll Toggle
MiscSection:CreateToggle({
    Name = "Ragdoll Mode",
    CurrentValue = false,
    Flag = "Ragdoll",
    Callback = function(value)
        if value then
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
            Humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
        else
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        end
    end
})

-- Crouch Toggle
MiscSection:CreateToggle({
    Name = "Crouch",
    CurrentValue = false,
    Flag = "Crouch",
    Callback = function(value)
        if value then
            Humanoid.HipHeight = -1.5 -- Crouch
        else
            Humanoid.HipHeight = 0
        end
    end
})

-- Bobbing Effect
local BobbingEnabled = false
MiscSection:CreateToggle({
    Name = "Bobbing Effect",
    CurrentValue = false,
    Flag = "Bobbing",
    Callback = function(value)
        BobbingEnabled = value
        if value then
            RunService.RenderStepped:Connect(function()
                if BobbingEnabled and Humanoid.MoveDirection.Magnitude > 0 then
                    Humanoid.CameraOffset = Humanoid.CameraOffset:Lerp(Vector3.new(0, math.abs(math.sin(tick() * 12)) / 5, 0), 0.25)
                end
            end)
        end
    end
})

-- Explosion Maker
MiscSection:CreateButton({
    Name = "Explode All",
    Callback = function()
        local ExplosionMaker = require(ReplicatedStorage.ExplosionMaker)
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and not BypassCheck(player) then
                ExplosionMaker.Explode(player.Character.HumanoidRootPart.Position, 50)
            end
        end
    end
})

-- Food Module
MiscSection:CreateButton({
    Name = "Cook All Food",
    Callback = function()
        local Food = require(ReplicatedStorage.Food)
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name == "Food" then
                Food.new(obj, true):Cook()
            end
        end
    end
})

-- Anti-Grab/Kill for Admins
RunService.Heartbeat:Connect(function()
    if IsAdmin(LocalPlayer) then
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Anchored = true
            end
        end
    end
end)