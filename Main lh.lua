--[[
  NO MERCY — "VIOLENCE DISTRICT" (Stable Orion UI & Predictive Auto Aim)
]]

local ICON = {
    Info     = "rbxassetid://7733964719",
    Crosshair= "rbxassetid://7733765307",
    Swords   = "rbxassetid://7734056608",
    Globe    = "rbxassetid://7733954760",
    Axe      = "rbxassetid://7733674079",
    User     = "rbxassetid://7743875962",
    Eye      = "rbxassetid://7733774602",
    Zap      = "rbxassetid://7733771628",
    Settings = "rbxassetid://7734053495",
    Logo     = "rbxassetid://113381647185328",
    Banner   = "rbxassetid://117118608066997",
}

getgenv().VD = getgenv().VD or {
    AutoSkillcheck        = false,
    AUTO_ToFAim           = true,
    AUTO_ToFTargetMode    = "Killer",
    AUTO_ToFRadius        = 150,
    AUTO_ToFPredict       = true,
    AUTO_ToFBulletSpeed   = 200,
    GodModeEnabled        = false,
    AUTO_Attack           = false,
    AUTO_AttackRange      = 12,
}

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local Lighting          = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")

local LocalPlayer       = Players.LocalPlayer
local VD                = getgenv().VD

-- Cek dan muat Orion Library dengan aman
local success, OrionLib = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Marpiii/UiLib/refs/heads/main/source.lua"))()
end)

if not success or not OrionLib then
    warn("[NO MERCY] Gagal memuat Orion Library!")
    return
end

-- ============================================================
--  LOGIKA PREDIKSI KORDINAT & AUTO AIM
-- ============================================================
local function getAutoAimDirection(originPos)
    local closestTarget = nil
    local shortestDist = VD.AUTO_ToFRadius
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") then
            local isValidTarget = false
            if VD.AUTO_ToFTargetMode == "Killer" then
                if CollectionService:HasTag(obj, "Lookscriptkiller") then
                    isValidTarget = true
                end
            elseif VD.AUTO_ToFTargetMode == "Survivor" then
                local player = Players:GetPlayerFromCharacter(obj)
                if player and player ~= LocalPlayer then
                    isValidTarget = true
                end
            end
            
            if isValidTarget then
                local hrp = obj.HumanoidRootPart
                local hum = obj:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local dist = (hrp.Position - originPos).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        closestTarget = hrp
                    end
                end
            end
        end
    end
    
    if closestTarget then
        local targetPos = closestTarget.Position
        if VD.AUTO_ToFPredict and closestTarget.AssemblyLinearVelocity then
            local distance = (targetPos - originPos).Magnitude
            local travelTime = distance / VD.AUTO_ToFBulletSpeed
            targetPos = targetPos + (closestTarget.AssemblyLinearVelocity * travelTime)
        end
        return (targetPos - originPos).Unit
    end
    return nil
end

task.spawn(function()
    pcall(function()
        local fireRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Items"):WaitForChild("Twist of Fate"):WaitForChild("Fire", 5)
        if fireRemote then
            local oldFireServer
            oldFireServer = hookmetamethod(game, "__namecall", function(self, ...)
                local args = {...}
                local method = getnamecallmethod()
                if self == fireRemote and method == "FireServer" and VD.AUTO_ToFAim then
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local autoDir = getAutoAimDirection(char.HumanoidRootPart.Position)
                        if autoDir then
                            args[2] = autoDir
                        end
                    end
                end
                return oldFireServer(self, unpack(args))
            end)
        end
    end)
end)

RunService.RenderStepped:Connect(function()
    if VD.GodModeEnabled then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.Health = hum.MaxHealth
            end
            if LocalPlayer:GetAttribute("IsDead") then
                LocalPlayer:SetAttribute("IsDead", false)
            end
            if char:GetAttribute("IsCarried") then
                char:SetAttribute("IsCarried", false)
            end
            if char:GetAttribute("IsHooked") then
                char:SetAttribute("IsHooked", false)
            end
        end
    end
end)

-- ============================================================
--  ORION UI SETUP
-- ============================================================
local Window = OrionLib:MakeWindow({
    Name = "NO MERCY — VIOLENCE DISTRICT",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "NoMercyViolenceFullZiaan",
    IntroEnabled = false,
    Icon = ICON.Logo,
})

local InfoTab   = Window:MakeTab({ Name = "Info", Icon = ICON.Info, PremiumOnly = false })
local AimbotTab = Window:MakeTab({ Name = "Aimbot", Icon = ICON.Crosshair, PremiumOnly = false })
local KillerTab = Window:MakeTab({ Name = "Killer", Icon = ICON.Axe, PremiumOnly = false })
local VisualTab = Window:MakeTab({ Name = "Visual", Icon = ICON.Eye, PremiumOnly = false })

-- Info Tab
local InfoSec = InfoTab:AddSection({ Name = "Tentang" })
InfoSec:AddLabel("NO MERCY — Violence District")
InfoSec:AddLabel("Predictive Auto Aim Integrated")

-- Aimbot Tab
local AimSec = AimbotTab:AddSection({ Name = "Predictive Auto Aim" })

AimSec:AddToggle({ 
    Name = "Auto Aim : ON/OFF", 
    Default = VD.AUTO_ToFAim, 
    Callback = function(v) VD.AUTO_ToFAim = v end 
})

AimSec:AddDropdown({ 
    Name = "Target Mode", 
    Default = VD.AUTO_ToFTargetMode, 
    Options = { "Killer", "Survivor" }, 
    Callback = function(v) VD.AUTO_ToFTargetMode = type(v) == "table" and v[1] or v end 
})

AimSec:AddToggle({ 
    Name = "Prediction (Anti-Miss/Belokan)", 
    Default = VD.AUTO_ToFPredict, 
    Callback = function(v) VD.AUTO_ToFPredict = v end 
})

AimSec:AddSlider({ 
    Name = "Radius (Studs)", 
    Min = 25, 
    Max = 500, 
    Default = VD.AUTO_ToFRadius, 
    Increment = 25, 
    Callback = function(v) VD.AUTO_ToFRadius = v end 
})

AimSec:AddToggle({ 
    Name = "God Mode", 
    Default = VD.GodModeEnabled, 
    Callback = function(v) VD.GodModeEnabled = v end 
})

-- Killer Tab
local KillSec = KillerTab:AddSection({ Name = "General Killer" })
KillSec:AddToggle({ 
    Name = "Auto Attack", 
    Default = VD.AUTO_Attack, 
    Callback = function(v) VD.AUTO_Attack = v end 
})

-- Visual Tab
local VisSec = VisualTab:AddSection({ Name = "Visual Settings" })
VisSec:AddToggle({ 
    Name = "Fullbright", 
    Default = false, 
    Callback = function(v) Lighting.Brightness = v and 1 or 2 end 
})

RunService.Heartbeat:Connect(function()
    if VD.AUTO_Attack and LocalPlayer.Team and LocalPlayer.Team.Name == "Killer" then
        pcall(function()
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not root then return end
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Team and player.Team.Name == "Survivors" and player.Character then
                    local tRoot = player.Character:FindFirstChild("HumanoidRootPart")
                    if tRoot and (tRoot.Position - root.Position).Magnitude <= VD.AUTO_AttackRange then
                        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                        local basicAtt = remotes and remotes:FindFirstChild("Remotes") and remotes.Remotes:FindFirstChild("Attacks") -- aman
                        if basicAtt then basicAtt:FireServer(false) end
                        break
                    end
                end
            end
        end)
    end
end)

OrionLib:MakeNotification({
    Name = "NO MERCY",
    Content = "Violence District UI Loaded Successfully!",
    Image = ICON.Logo,
    Time = 4
})
