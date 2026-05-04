-- Hexer Hub - Ultimate Exploit Script for Fling Things and People
-- Created by GitHub Copilot
-- Owners: Replace with actual UserIds or Names
local Owners = {123456789, 987654321} -- Example UserIds
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

-- Orion Library Load
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "Hexer Hub - Ultimate Exploit", HidePremium = false, SaveConfig = true, ConfigFolder = "HexerHub"})

-- Tabs
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local CombatTab = Window:MakeTab({
    Name = "Combat",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local MovementTab = Window:MakeTab({
    Name = "Movement",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local GrabTab = Window:MakeTab({
    Name = "Grab",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local AdminTab = Window:MakeTab({
    Name = "Admin",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local MiscTab = Window:MakeTab({
    Name = "Misc",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

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
    OrionLib:MakeNotification({
        Name = "Banned",
        Content = "You are banned from using Hexer Hub.",
        Image = "rbxassetid://4483345998",
        Time = 5
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
MainTab:AddButton({
    Name = "God Mode",
    Callback = function()
        Humanoid.Health = math.huge
        Humanoid.MaxHealth = math.huge
        OrionLib:MakeNotification({
            Name = "Activated",
            Content = "God Mode enabled!",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})

MainTab:AddButton({
    Name = "Infinite Jump",
    Callback = function()
        local infJump = true
        UserInputService.JumpRequest:Connect(function()
            if infJump then
                Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
        OrionLib:MakeNotification({
            Name = "Activated",
            Content = "Infinite Jump enabled!",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})

-- Combat Tab
CombatTab:AddButton({
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
MovementTab:AddSlider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 500,
    Default = 16,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "Speed",
    Callback = function(value)
        Humanoid.WalkSpeed = value
    end
})

MovementTab:AddSlider({
    Name = "JumpPower",
    Min = 50,
    Max = 500,
    Default = 50,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "Power",
    Callback = function(value)
        Humanoid.JumpPower = value
    end
})

-- Grab Tab (Enhanced Grabbing)
local GrabEnabled = false
GrabTab:AddToggle({
    Name = "Infinite Grab Distance",
    Default = false,
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

GrabTab:AddButton({
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
AdminTab:AddTextbox({
    Name = "Command Input",
    Default = "",
    TextDisappear = true,
    Callback = function(value)
        LocalPlayer:Chat(value) -- Simulate chat for commands
    end
})

-- Misc Tab
MiscTab:AddButton({
    Name = "Disable Core GUI",
    Callback = function()
        local StarterGui = game:GetService("StarterGui")
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
    end
})

MiscTab:AddButton({
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
MiscTab:AddToggle({
    Name = "Ragdoll Mode",
    Default = false,
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
MiscTab:AddToggle({
    Name = "Crouch",
    Default = false,
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
MiscTab:AddToggle({
    Name = "Bobbing Effect",
    Default = false,
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
MiscTab:AddButton({
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
MiscTab:AddButton({
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

-- UI Finalize
OrionLib:Init()