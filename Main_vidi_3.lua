--[[
  NO MERCY — "VIOLENCE DISTRICT" (Orion Library + Twist of Fate Native Integration)
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

-- ===================== GLOBAL CONFIG & STATE =====================
getgenv().VD = getgenv().VD or {
    AutoSkillcheck        = false,
    AUTO_ToFAim           = true,
    AUTO_ToFTargetMode    = "Killer",
    AUTO_ToFRadius        = 150,
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

local function VD_Notify(title, content, duration)
    pcall(function()
        if OrionLib and OrionLib.MakeNotification then
            OrionLib:MakeNotification({ Name = title, Content = content, Image = ICON.Logo, Time = duration or 3 })
        else
            print("[NO MERCY] " + title + " - " + content)
        end
    end)
end

-- ============================================================
--  LOGIKA TARGET AUTO AIM (NATIVE INTEGRATION)
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
        return (closestTarget.Position - originPos).Unit
    end
    return nil
end

-- Loop Pengaman God Mode
RunService.RenderStepped:Connect(function()
    if VD.GodModeEnabled then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.Health = hum.MaxHealth
            end
            if LocalPlayer:GetAttribute("IsDead") then
                LocalPlayer:GetAttribute("IsDead", false)
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
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Marpiii/UiLib/refs/heads/main/source.lua"))()

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
InfoSec:AddLabel("Twist of Fate Native Controller")

-- Aimbot Tab (Menu Pengaturan Auto Aim & God Mode)
local AimSec = AimbotTab:AddSection({ Name = "Twist of Fate Controller" })

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

-- Background Loop untuk Auto Attack
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
                        local basicAtt = remotes and remotes:FindFirstChild("Attacks") and remotes.Attacks:FindFirstChild("BasicAttack")
                        if basicAtt then basicAtt:FireServer(false) end
                        break
                    end
                end
            end
        end)
    end
end)

VD_Notify("NO MERCY", "Violence District & Native Aim Ready!", 4)
