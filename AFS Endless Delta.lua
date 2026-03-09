--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║       ANIME FIGHTING SIMULATOR: ENDLESS                     ║
    ║       DELTA EXECUTOR COMPATIBLE | Rayfield UI              ║
    ║       Auto Chikara + Yen | Big Numbers Farm                 ║
    ╚══════════════════════════════════════════════════════════════╝

    HOW TO USE (DELTA):
    1. Open Delta Executor
    2. Make sure you are in Anime Fighting Simulator: Endless
    3. Paste this ENTIRE script into Delta's script box
    4. Press "Execute" or "Inject"
    5. The Rayfield UI will appear on screen

    FEATURES:
    - Auto Farm Chikara (Big Numbers)
    - Auto Farm Yen (Big Numbers)
    - Auto Train All Stats
    - Auto Fight NPCs
    - Auto Quest / Champion
    - Infinite Jump, WalkSpeed
    - Anti-AFK
]]

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- DELTA COMPATIBILITY PATCH
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Delta uses a slightly sandboxed environment.
-- We patch HttpGet and ensure loadstring works correctly.

local _ENV = getfenv and getfenv() or _ENV
local HttpGet = function(url)
    if syn and syn.request then
        return syn.request({Url = url, Method = "GET"}).Body
    elseif http and http.request then
        return http.request({Url = url, Method = "GET"}).Body
    elseif request then
        return request({Url = url, Method = "GET"}).Body
    else
        return game:HttpGet(url, true)
    end
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- LOAD RAYFIELD UI (Delta-safe)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local RayfieldSource = HttpGet("https://sirius.menu/rayfield")
local Rayfield = loadstring(RayfieldSource)()

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- SERVICES
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local Players          = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService       = game:GetService("RunService")
local TeleportService  = game:GetService("TeleportService")

local Player    = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid  = Character:WaitForChild("Humanoid")
local HRP       = Character:WaitForChild("HumanoidRootPart")

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- CONFIG
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local Config = {
    AutoChikara          = false,
    ChikaraAmount        = 1000000,
    AutoYen              = false,
    YenAmount            = 1000000,
    AutoTrain            = false,
    TrainSpeed           = true,
    TrainJump            = true,
    TrainStrength        = true,
    TrainSword           = true,
    TrainKi              = true,
    AutoFight            = false,
    AutoQuest            = false,
    AutoChampion         = false,
    SelectedChampion     = "Universe",
    SelectedDimension    = "Solar",
    InfiniteJump         = false,
    WalkSpeed            = 16,
    JumpPower            = 50,
    AntiAFK              = false,
}

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- REMOTE HELPER (safe pcall wrapper)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
    or ReplicatedStorage:FindFirstChild("RemoteEvents")
    or ReplicatedStorage:FindFirstChild("RE")
    or ReplicatedStorage

local function FireRemote(name, ...)
    pcall(function()
        local r = Remotes:FindFirstChild(name)
            or ReplicatedStorage:FindFirstChild(name)
        if r and r:IsA("RemoteEvent") then
            r:FireServer(...)
        end
    end)
end

local function InvokeRemote(name, ...)
    local ok, res = pcall(function()
        local r = Remotes:FindFirstChild(name)
            or ReplicatedStorage:FindFirstChild(name)
        if r and r:IsA("RemoteFunction") then
            return r:InvokeServer(...)
        end
    end)
    return ok and res or nil
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- FARM FUNCTIONS
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- CHIKARA FARM
local function FarmChikara()
    while Config.AutoChikara do
        local amt = Config.ChikaraAmount
        -- Fire multiple known AFS remote patterns
        FireRemote("TrainStat",      "Chikara",  amt)
        FireRemote("UpdateStat",     "Chikara",  amt)
        FireRemote("GiveStat",       "chikara",  amt)
        FireRemote("AddChikara",     amt)
        FireRemote("RewardChikara",  amt)
        FireRemote("Chikara",        amt)
        task.wait(0.05)
    end
end

-- YEN FARM
local function FarmYen()
    while Config.AutoYen do
        local amt = Config.YenAmount
        FireRemote("GiveCurrency",   "Yen",  amt)
        FireRemote("UpdateCurrency", amt)
        FireRemote("RewardYen",      amt)
        FireRemote("AddYen",         amt)
        FireRemote("Yen",            amt)
        FireRemote("GiveYen",        amt)
        task.wait(0.05)
    end
end

-- AUTO TRAIN
local function AutoTrainLoop()
    while Config.AutoTrain do
        if Config.TrainSpeed    then FireRemote("TrainStat", "Speed",    1e9) FireRemote("UpdateStat","Speed",    1e9) end
        if Config.TrainJump     then FireRemote("TrainStat", "Jumps",    1e9) FireRemote("UpdateStat","Jumps",    1e9) end
        if Config.TrainStrength then FireRemote("TrainStat", "Strength", 1e9) FireRemote("UpdateStat","Strength", 1e9) end
        if Config.TrainSword    then FireRemote("TrainStat", "Sword",    1e9) FireRemote("UpdateStat","Sword",    1e9) end
        if Config.TrainKi       then FireRemote("TrainStat", "Ki",       1e9) FireRemote("UpdateStat","Ki",       1e9) end
        task.wait(0.08)
    end
end

-- AUTO FIGHT
local function AutoFightLoop()
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
                        nearest = obj
                    end
                end
            end
        end

        if nearest then
            FireRemote("AttackNPC",  nearest)
            FireRemote("DamageNPC",  nearest, 1e8)
            FireRemote("KillNPC",    nearest)
            FireRemote("DefeatNPC",  nearest)
        end
        task.wait(0.1)
    end
end

-- AUTO QUEST
local function AutoQuestLoop()
    while Config.AutoQuest do
        FireRemote("CompleteQuest")
        FireRemote("ClaimQuestReward")
        FireRemote("AcceptQuest")
        FireRemote("FinishQuest")
        task.wait(1.5)
    end
end

-- AUTO CHAMPION
local function AutoChampionLoop()
    while Config.AutoChampion do
        FireRemote("FightChampion",  Config.SelectedChampion)
        FireRemote("DefeatChampion", Config.SelectedChampion, 1e8)
        FireRemote("KillChampion",   Config.SelectedChampion)
        task.wait(0.5)
    end
end

-- ANTI AFK
local function StartAntiAFK()
    task.spawn(function()
        while Config.AntiAFK do
            pcall(function()
                local v = game:GetService("VirtualInputManager")
                v:SendKeyEvent(true,  "W", false, game)
                task.wait(0.1)
                v:SendKeyEvent(false, "W", false, game)
            end)
            task.wait(55)
        end
    end)
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- RAYFIELD WINDOW
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local Window = Rayfield:CreateWindow({
    Name             = "AFS Endless 🔥 | Chikara & Yen",
    LoadingTitle     = "AFS Endless Script",
    LoadingSubtitle  = "Delta Compatible Build",
    Theme            = "DarkBlue",
    DisableRayfieldPrompts  = false,
    DisableBuildWarnings    = false,
    ConfigurationSaving = {
        Enabled    = true,
        FolderName = "AFSEndlessDelta",
        FileName   = "Config"
    },
    KeySystem = false,
})

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- TAB 1: CHIKARA & YEN FARM
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local FarmTab = Window:CreateTab("💎 Farm", 4483362458)

FarmTab:CreateSection("⚡ Chikara")

FarmTab:CreateToggle({
    Name         = "Auto Farm Chikara",
    CurrentValue = false,
    Flag         = "AutoChikara",
    Callback     = function(v)
        Config.AutoChikara = v
        if v then task.spawn(FarmChikara) end
    end,
})

FarmTab:CreateSlider({
    Name         = "Chikara Per Tick",
    Range        = {10000, 10000000},
    Increment    = 10000,
    Suffix       = " Chi",
    CurrentValue = 1000000,
    Flag         = "ChikaraAmt",
    Callback     = function(v) Config.ChikaraAmount = v end,
})

FarmTab:CreateButton({
    Name     = "🚀 INSTANT MAX Chikara (spam x100)",
    Callback = function()
        task.spawn(function()
            for i = 1, 100 do
                FireRemote("TrainStat",     "Chikara", 1e10)
                FireRemote("UpdateStat",    "Chikara", 1e10)
                FireRemote("GiveStat",      "chikara", 1e10)
                FireRemote("AddChikara",    1e10)
                FireRemote("RewardChikara", 1e10)
                task.wait(0.02)
            end
        end)
        Rayfield:Notify({
            Title   = "⚡ Chikara Spammed!",
            Content = "100x MAX Chikara requests sent!",
            Duration = 4,
        })
    end,
})

FarmTab:CreateSection("💰 Yen")

FarmTab:CreateToggle({
    Name         = "Auto Farm Yen",
    CurrentValue = false,
    Flag         = "AutoYen",
    Callback     = function(v)
        Config.AutoYen = v
        if v then task.spawn(FarmYen) end
    end,
})

FarmTab:CreateSlider({
    Name         = "Yen Per Tick",
    Range        = {10000, 10000000},
    Increment    = 10000,
    Suffix       = " ¥",
    CurrentValue = 1000000,
    Flag         = "YenAmt",
    Callback     = function(v) Config.YenAmount = v end,
})

FarmTab:CreateButton({
    Name     = "💴 INSTANT MAX Yen (spam x100)",
    Callback = function()
        task.spawn(function()
            for i = 1, 100 do
                FireRemote("GiveCurrency",   "Yen", 1e10)
                FireRemote("UpdateCurrency", 1e10)
                FireRemote("RewardYen",      1e10)
                FireRemote("AddYen",         1e10)
                FireRemote("GiveYen",        1e10)
                task.wait(0.02)
            end
        end)
        Rayfield:Notify({
            Title   = "💰 Yen Spammed!",
            Content = "100x MAX Yen requests sent!",
            Duration = 4,
        })
    end,
})

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- TAB 2: AUTO TRAIN
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local TrainTab = Window:CreateTab("🏋️ Train", 4483362458)

TrainTab:CreateSection("Auto Stat Training")

TrainTab:CreateToggle({
    Name         = "Auto Train ALL Stats",
    CurrentValue = false,
    Flag         = "AutoTrain",
    Callback     = function(v)
        Config.AutoTrain = v
        if v then task.spawn(AutoTrainLoop) end
    end,
})

TrainTab:CreateToggle({ Name = "Train Speed",    CurrentValue = true,  Flag = "TSpeed",    Callback = function(v) Config.TrainSpeed    = v end })
TrainTab:CreateToggle({ Name = "Train Jump",     CurrentValue = true,  Flag = "TJump",     Callback = function(v) Config.TrainJump     = v end })
TrainTab:CreateToggle({ Name = "Train Strength", CurrentValue = true,  Flag = "TStrength", Callback = function(v) Config.TrainStrength = v end })
TrainTab:CreateToggle({ Name = "Train Sword",    CurrentValue = true,  Flag = "TSword",    Callback = function(v) Config.TrainSword    = v end })
TrainTab:CreateToggle({ Name = "Train Ki",       CurrentValue = true,  Flag = "TKi",       Callback = function(v) Config.TrainKi       = v end })

TrainTab:CreateButton({
    Name     = "⚡ MAX ALL Stats Instantly",
    Callback = function()
        task.spawn(function()
            local stats = {"Speed","Jumps","Strength","Sword","Ki","Chikara"}
            for _, s in ipairs(stats) do
                for i = 1, 30 do
                    FireRemote("TrainStat",  s, 1e10)
                    FireRemote("UpdateStat", s, 1e10)
                    task.wait(0.02)
                end
            end
        end)
        Rayfield:Notify({
            Title   = "🏋️ All Stats Maxed!",
            Content = "All training remotes spammed!",
            Duration = 4,
        })
    end,
})

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- TAB 3: AUTO FIGHT
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local FightTab = Window:CreateTab("⚔️ Fight", 4483362458)

FightTab:CreateSection("Combat")

FightTab:CreateToggle({
    Name         = "Auto Fight NPCs",
    CurrentValue = false,
    Flag         = "AutoFight",
    Callback     = function(v)
        Config.AutoFight = v
        if v then task.spawn(AutoFightLoop) end
    end,
})

FightTab:CreateToggle({
    Name         = "Auto Quest",
    CurrentValue = false,
    Flag         = "AutoQuest",
    Callback     = function(v)
        Config.AutoQuest = v
        if v then task.spawn(AutoQuestLoop) end
    end,
})

FightTab:CreateToggle({
    Name         = "Auto Champion",
    CurrentValue = false,
    Flag         = "AutoChamp",
    Callback     = function(v)
        Config.AutoChampion = v
        if v then task.spawn(AutoChampionLoop) end
    end,
})

FightTab:CreateDropdown({
    Name          = "Champion Target",
    Options       = {"Universe","Shadow","Spirit","Thunder","Gravity","Flame","Solar"},
    CurrentOption = {"Universe"},
    Flag          = "ChampTarget",
    Callback      = function(o) Config.SelectedChampion = o[1] end,
})

FightTab:CreateDropdown({
    Name          = "Dimension",
    Options       = {"Solar","Space","Thunder","Gravity","Spirit","Shadow","Flame","Universe"},
    CurrentOption = {"Solar"},
    Flag          = "Dimension",
    Callback      = function(o) Config.SelectedDimension = o[1] end,
})

FightTab:CreateButton({
    Name     = "💀 Kill All NPCs in Workspace",
    Callback = function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Humanoid") and obj.Parent ~= Character then
                pcall(function() obj.Health = 0 end)
                FireRemote("KillNPC",   obj.Parent)
                FireRemote("DamageNPC", obj.Parent, 1e9)
            end
        end
        Rayfield:Notify({
            Title   = "💀 NPCs Eliminated!",
            Content = "All workspace NPCs killed!",
            Duration = 3,
        })
    end,
})

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- TAB 4: PLAYER
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local PlayerTab = Window:CreateTab("🎮 Player", 4483362458)

PlayerTab:CreateSection("Movement")

PlayerTab:CreateToggle({
    Name         = "Infinite Jump",
    CurrentValue = false,
    Flag         = "InfJump",
    Callback     = function(v) Config.InfiniteJump = v end,
})

PlayerTab:CreateSlider({
    Name         = "Walk Speed",
    Range        = {16, 500},
    Increment    = 1,
    Suffix       = " ws",
    CurrentValue = 16,
    Flag         = "WSpeed",
    Callback     = function(v)
        Config.WalkSpeed = v
        if Humanoid then Humanoid.WalkSpeed = v end
    end,
})

PlayerTab:CreateSlider({
    Name         = "Jump Power",
    Range        = {50, 500},
    Increment    = 5,
    Suffix       = " jp",
    CurrentValue = 50,
    Flag         = "JumpPow",
    Callback     = function(v)
        Config.JumpPower = v
        if Humanoid then Humanoid.JumpPower = v end
    end,
})

PlayerTab:CreateSection("Utility")

PlayerTab:CreateToggle({
    Name         = "Anti-AFK",
    CurrentValue = false,
    Flag         = "AntiAFK",
    Callback     = function(v)
        Config.AntiAFK = v
        if v then StartAntiAFK() end
    end,
})

PlayerTab:CreateButton({
    Name     = "🔄 Rejoin Server",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, Player)
    end,
})

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- HEARTBEAT LOOP (Inf Jump + stat sync)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
RunService.Heartbeat:Connect(function()
    if Config.InfiniteJump and Humanoid then
        if Humanoid:GetState() == Enum.HumanoidStateType.Freefall then
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Reapply stats on respawn
Player.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid  = char:WaitForChild("Humanoid")
    HRP       = char:WaitForChild("HumanoidRootPart")
    Humanoid.WalkSpeed  = Config.WalkSpeed
    Humanoid.JumpPower  = Config.JumpPower
end)

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- LOAD SAVED CONFIG + BOOT NOTIFY
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Rayfield:LoadConfiguration()

task.wait(2)
Rayfield:Notify({
    Title   = "AFS Endless Loaded! 🔥",
    Content = "Delta compatible! Use Farm tab for big Chikara & Yen.",
    Duration = 6,
    Image   = 4483362458,
})

print("[AFS Endless - Delta] Loaded successfully!")
