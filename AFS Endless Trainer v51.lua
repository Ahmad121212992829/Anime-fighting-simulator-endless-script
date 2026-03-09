--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║       AFS ENDLESS - AUTO TRAINER v5.1                       ║
    ║       Actually Works | Rayfield UI | Delta Compatible        ║
    ║       Auto clicks training zones super fast                 ║
    ╚══════════════════════════════════════════════════════════════╝
]]

-- Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Services
local Players         = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService      = game:GetService("RunService")
local TweenService    = game:GetService("TweenService")

local Player    = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid  = Character:WaitForChild("Humanoid")
local HRP       = Character:WaitForChild("HumanoidRootPart")

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- CONFIG
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local Config = {
    AutoChikara   = false,
    AutoStrength  = false,
    AutoSword     = false,
    AutoKi        = false,
    AutoSpeed     = false,
    AutoJump      = false,
    AutoFight     = false,
    AutoQuest     = false,
    InfiniteJump  = false,
    WalkSpeed     = 16,
    TrainDelay    = 0.01, -- lower = faster training
}

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- FIND TRAINING ZONES
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local function FindTrainingZone(keyword)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name:lower():find(keyword:lower()) then
            if obj:IsA("BasePart") or obj:IsA("Model") then
                return obj
            end
        end
    end
    return nil
end

local function GetZonePosition(zone)
    if zone:IsA("Model") then
        return zone:GetModelCFrame().Position
    elseif zone:IsA("BasePart") then
        return zone.Position
    end
    return nil
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- TELEPORT TO ZONE & CLICK IT
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local function TeleportToAndTrain(zoneName, configKey)
    task.spawn(function()
        while Config[configKey] do
            -- Find the zone each loop in case map reloads
            local zone = FindTrainingZone(zoneName)
            if zone then
                local pos = GetZonePosition(zone)
                if pos and HRP then
                    -- Teleport on top of the zone
                    HRP.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                end
            end

            -- Simulate clicking / touching the training zone
            -- by firing the ProximityPrompt or TouchInterest
            if zone then
                -- Try firing touch
                pcall(function()
                    for _, part in ipairs(zone:GetDescendants()) do
                        if part:IsA("BasePart") then
                            local fire = Instance.new("Part")
                            fire.Size = Vector3.new(1,1,1)
                            fire.CFrame = part.CFrame
                            fire.Parent = workspace
                            fire.Touched:Fire(HRP)
                            game:GetService("Debris"):AddItem(fire, 0.1)
                        end
                    end
                end)

                -- Try ProximityPrompt trigger
                pcall(function()
                    for _, pp in ipairs(zone:GetDescendants()) do
                        if pp:IsA("ProximityPrompt") then
                            fireproximityprompt(pp)
                        end
                    end
                end)

                -- Try ClickDetector trigger
                pcall(function()
                    for _, cd in ipairs(zone:GetDescendants()) do
                        if cd:IsA("ClickDetector") then
                            fireclickdetector(cd)
                        end
                    end
                end)
            end

            task.wait(Config.TrainDelay)
        end
    end)
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- AUTO FIGHT LOOP
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local function AutoFightLoop()
    task.spawn(function()
        while Config.AutoFight do
            local hrp = Character:FindFirstChild("HumanoidRootPart")
            if not hrp then task.wait(1) continue end

            local nearest, nearDist = nil, math.huge

            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Model") and obj ~= Character then
                    local nHRP = obj:FindFirstChild("HumanoidRootPart")
                    local nHum = obj:FindFirstChildOfClass("Humanoid")
                    if nHRP and nHum and nHum.Health > 0 then
                        local d = (hrp.Position - nHRP.Position).Magnitude
                        if d < nearDist then
                            nearDist = d
                            nearest  = obj
                        end
                    end
                end
            end

            if nearest then
                local nHRP = nearest:FindFirstChild("HumanoidRootPart")
                if nHRP then
                    -- Teleport next to NPC
                    hrp.CFrame = CFrame.new(nHRP.Position + Vector3.new(3, 0, 0))
                end

                -- Fire all click detectors & proximity prompts on NPC
                pcall(function()
                    for _, cd in ipairs(nearest:GetDescendants()) do
                        if cd:IsA("ClickDetector") then
                            fireclickdetector(cd)
                        end
                        if cd:IsA("ProximityPrompt") then
                            fireproximityprompt(cd)
                        end
                    end
                end)
            end

            task.wait(0.1)
        end
    end)
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- AUTO QUEST LOOP
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local function AutoQuestLoop()
    task.spawn(function()
        while Config.AutoQuest do
            -- Find and click quest NPCs/boards
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.Name:lower():find("quest") then
                    pcall(function()
                        for _, cd in ipairs(obj:GetDescendants()) do
                            if cd:IsA("ClickDetector") then fireclickdetector(cd) end
                            if cd:IsA("ProximityPrompt") then fireproximityprompt(cd) end
                        end
                    end)
                end
            end
            task.wait(2)
        end
    end)
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- RESPAWN HANDLER
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Player.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid  = char:WaitForChild("Humanoid")
    HRP       = char:WaitForChild("HumanoidRootPart")
    Humanoid.WalkSpeed = Config.WalkSpeed
end)

-- Infinite jump heartbeat
RunService.Heartbeat:Connect(function()
    if Config.InfiniteJump and Humanoid then
        if Humanoid:GetState() == Enum.HumanoidStateType.Freefall then
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- RAYFIELD UI
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local Window = Rayfield:CreateWindow({
    Name            = "AFS Endless v5.1 🔥 Auto Trainer",
    LoadingTitle    = "AFS Endless Trainer",
    LoadingSubtitle = "Actually Works Build",
    Theme           = "DarkBlue",
    ConfigurationSaving = {
        Enabled    = true,
        FolderName = "AFSEndlessTrainer",
        FileName   = "Config"
    },
    KeySystem = false,
})

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- TAB: CHIKARA
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local ChikaraTab = Window:CreateTab("⚡ Chikara", 4483362458)

ChikaraTab:CreateSection("Auto Chikara Training")
ChikaraTab:CreateLabel("Teleports you to Chikara zone & auto clicks it!")

ChikaraTab:CreateToggle({
    Name         = "Auto Train Chikara",
    CurrentValue = false,
    Flag         = "AutoChikara",
    Callback     = function(v)
        Config.AutoChikara = v
        if v then TeleportToAndTrain("chikara", "AutoChikara") end
    end,
})

ChikaraTab:CreateToggle({
    Name         = "Auto Train Strength",
    CurrentValue = false,
    Flag         = "AutoStrength",
    Callback     = function(v)
        Config.AutoStrength = v
        if v then TeleportToAndTrain("strength", "AutoStrength") end
    end,
})

ChikaraTab:CreateToggle({
    Name         = "Auto Train Sword",
    CurrentValue = false,
    Flag         = "AutoSword",
    Callback     = function(v)
        Config.AutoSword = v
        if v then TeleportToAndTrain("sword", "AutoSword") end
    end,
})

ChikaraTab:CreateToggle({
    Name         = "Auto Train Ki",
    CurrentValue = false,
    Flag         = "AutoKi",
    Callback     = function(v)
        Config.AutoKi = v
        if v then TeleportToAndTrain("ki", "AutoKi") end
    end,
})

ChikaraTab:CreateSlider({
    Name         = "Train Speed (lower = faster)",
    Range        = {0, 1},
    Increment    = 0.01,
    Suffix       = "s delay",
    CurrentValue = 0.01,
    Flag         = "TrainDelay",
    Callback     = function(v) Config.TrainDelay = v end,
})

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- TAB: MOVEMENT
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local MoveTab = Window:CreateTab("🏃 Movement", 4483362458)

MoveTab:CreateSection("Speed & Jump")

MoveTab:CreateToggle({
    Name         = "Auto Train Speed",
    CurrentValue = false,
    Flag         = "AutoSpeed",
    Callback     = function(v)
        Config.AutoSpeed = v
        if v then TeleportToAndTrain("speed", "AutoSpeed") end
    end,
})

MoveTab:CreateToggle({
    Name         = "Auto Train Jump",
    CurrentValue = false,
    Flag         = "AutoJump",
    Callback     = function(v)
        Config.AutoJump = v
        if v then TeleportToAndTrain("jump", "AutoJump") end
    end,
})

MoveTab:CreateToggle({
    Name         = "Infinite Jump",
    CurrentValue = false,
    Flag         = "InfJump",
    Callback     = function(v) Config.InfiniteJump = v end,
})

MoveTab:CreateSlider({
    Name         = "Walk Speed",
    Range        = {16, 300},
    Increment    = 1,
    Suffix       = " ws",
    CurrentValue = 16,
    Flag         = "WSpeed",
    Callback     = function(v)
        Config.WalkSpeed = v
        if Humanoid then Humanoid.WalkSpeed = v end
    end,
})

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- TAB: FIGHT & QUEST
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local FightTab = Window:CreateTab("⚔️ Fight", 4483362458)

FightTab:CreateSection("Auto Combat")

FightTab:CreateToggle({
    Name         = "Auto Fight NPCs",
    CurrentValue = false,
    Flag         = "AutoFight",
    Callback     = function(v)
        Config.AutoFight = v
        if v then AutoFightLoop() end
    end,
})

FightTab:CreateToggle({
    Name         = "Auto Quest",
    CurrentValue = false,
    Flag         = "AutoQuest",
    Callback     = function(v)
        Config.AutoQuest = v
        if v then AutoQuestLoop() end
    end,
})

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- BOOT NOTIFY
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Rayfield:LoadConfiguration()

task.wait(2)
Rayfield:Notify({
    Title   = "AFS Endless Trainer Loaded! ⚡",
    Content = "Enable Auto Chikara in the Chikara tab to start farming!",
    Duration = 6,
    Image   = 4483362458,
})

print("[AFS Endless Trainer v5.1] Loaded!")
