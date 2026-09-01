--// ============================================
--//  VD FE INVISIBLE V2 - DESYNC + FULL WIPE
--//  Game: Violence District
--//  Toggle: INSERT | Drag GUI buat geser
--// ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--// Settings
local isInvisible = false
local invisConnection = nil
local savedAccessories = {}
local savedClothing = {}

--// GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VD_FE_InvisV2"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 140)
mainFrame.Position = UDim2.new(0, 15, 0.5, -70)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 32)
title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
title.Text = "👻 VD FE Invisible V2"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = mainFrame

Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 22)
statusLabel.Position = UDim2.new(0.05, 0, 0.28, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: VISIBLE"
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 80)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 16
statusLabel.Parent = mainFrame

local descLabel = Instance.new("TextLabel")
descLabel.Size = UDim2.new(0.9, 0, 0, 18)
descLabel.Position = UDim2.new(0.05, 0, 0.48, 0)
descLabel.BackgroundTransparency = 1
descLabel.Text = "Desync + Full Visual Wipe"
descLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
descLabel.Font = Enum.Font.Gotham
descLabel.TextSize = 11
descLabel.Parent = mainFrame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0, 32)
toggleBtn.Position = UDim2.new(0.05, 0, 0.68, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
toggleBtn.Text = "Toggle Invisible [INSERT]"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 13
toggleBtn.Parent = mainFrame

Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

--// ============================================
--//  CORE FUNCTION: FULL VISUAL WIPE
--// ============================================

local function fullVisualWipe(character, enable)
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    
    for _, obj in pairs(character:GetDescendants()) do
        -- BaseParts (Body, Head, Limbs, HRP, MeshParts)
        if obj:IsA("BasePart") then
            if enable then
                obj.LocalTransparencyModifier = 1
                obj.Transparency = 1
                obj.CastShadow = false
                obj.Material = Enum.Material.ForceField
            else
                obj.LocalTransparencyModifier = 0
                obj.Transparency = 0
                obj.CastShadow = true
                obj.Material = Enum.Material.Plastic
            end
            
        -- Decals & Textures (Face, etc)
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            if enable then
                obj.Transparency = 1
            else
                obj.Transparency = 0
            end
            
        -- GUI elements (Name tag, health bar, dll)
        elseif obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
            obj.Enabled = not enable
            
        -- Effects
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
            obj.Enabled = not enable
            
        -- Sounds (Footstep, breathing, dll)
        elseif obj:IsA("Sound") then
            if enable then
                obj.Volume = 0
            else
                obj.Volume = 0.5 -- default approximation
            end
        end
    end
    
    --// HUMANOID SETTINGS
    if humanoid then
        if enable then
            humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            humanoid.NameDisplayDistance = 0
            humanoid.HealthDisplayDistance = 0
            humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
        else
            humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
            humanoid.NameDisplayDistance = 100
            humanoid.HealthDisplayDistance = 100
            humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.DisplayWhenDamaged
        end
    end
end

--// ============================================
--//  FE DESYNC METHOD
--// ============================================

local function applyDesync(character, enable)
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end
    
    if enable then
        -- Desync trick: Manipulate CFrame dengan velocity tinggi
        -- Ini bikin server "ketinggalan" sync visual
        -- HATI-HATI: Bisa ke-detect anti-cheat di beberapa game!
        
        -- Method 1: Anti-replicate dengan high velocity + anchor trick
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(0, 0, 0) -- Nggak gerak, tapi ada object
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Name = "InvisDesync_BV"
        bv.Parent = hrp
        
        -- Method 2: Network ownership trick (kalau executor support)
        if sethiddenproperty then
            pcall(function()
                sethiddenproperty(hrp, "NetworkIsSleeping", true)
            end)
        end
        
        -- Method 3: CFrame micro-jitter setiap frame (nggak replicate smooth)
        invisConnection = RunService.Heartbeat:Connect(function()
            if not isInvisible then return end
            if not hrp or not hrp.Parent then return end
            
            -- Micro CFrame adjustment (nggak kelihatan tapi nge-break replication smoothness)
            -- Hati-hati: Di VD anti-cheatnya agresif, jangan terlalu ekstrem
            local currentCF = hrp.CFrame
            hrp.CFrame = currentCF * CFrame.new(0, 0.001, 0)
            
            -- Maintain transparency
            fullVisualWipe(character, true)
        end)
        
    else
        if invisConnection then
            invisConnection:Disconnect()
            invisConnection = nil
        end
        
        -- Hapus BodyVelocity desync
        local bv = hrp:FindFirstChild("InvisDesync_BV")
        if bv then bv:Destroy() end
        
        -- Restore network
        if sethiddenproperty then
            pcall(function()
                sethiddenproperty(hrp, "NetworkIsSleeping", false)
            end)
        end
    end
end

--// ============================================
--//  ACCESSORIES & CLOTHING DESTROYER
--// ============================================

local function destroyVisualExtras(character, enable)
    if not character then return end
    
    if enable then
        -- Hancurkan Accessories (rambut, topi, wajah, dll) — nggak bisa di-transparanin
        for _, acc in pairs(character:GetChildren()) do
            if acc:IsA("Accessory") then
                table.insert(savedAccessories, acc:Clone())
                acc:Destroy()
            end
        end
        
        -- Hancurkan Clothing — Shirt/Pants nggak respond ke transparency
        for _, cloth in pairs(character:GetChildren()) do
            if cloth:IsA("Clothing") or cloth:IsA("ShirtGraphic") then
                table.insert(savedClothing, cloth:Clone())
                cloth:Destroy()
            end
        end
        
        -- Hancurkan Tool yang dipegang (kelihatan)
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:UnequipTools()
        end
        for _, tool in pairs(character:GetChildren()) do
            if tool:IsA("Tool") then
                tool.Parent = LocalPlayer.Backpack
            end
        end
        
    else
        -- Restore accessories & clothing (kalau respawn, ini nggak perlu)
        -- Karena VD biasanya respawn character, kita nggak restore
        -- Biar aja character baru spawn dengan baju normal
        savedAccessories = {}
        savedClothing = {}
    end
end

--// ============================================
--//  TOGGLE FUNCTION
--// ============================================

local function toggleInvisible()
    local character = LocalPlayer.Character
    if not character then
        warn("❌ Character belum spawn!")
        return
    end
    
    isInvisible = not isInvisible
    
    if isInvisible then
        -- AKTIFKAN
        destroyVisualExtras(character, true)
        fullVisualWipe(character, true)
        applyDesync(character, true)
        
        statusLabel.Text = "Status: INVISIBLE 👻"
        statusLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
        toggleBtn.Text = "MATIKAN INVISIBLE"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        print("✅ VD FE Invisible V2: AKTIF")
        print("⚠️  Desync aktif — jangan lari terlalu kencang!")
        
    else
        -- MATIKAN
        applyDesync(character, false)
        fullVisualWipe(character, false)
        -- Accessories & clothing nggak bisa di-restore, tunggu respawn
        
        statusLabel.Text = "Status: VISIBLE"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 80)
        toggleBtn.Text = "Toggle Invisible [INSERT]"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
        print("✅ VD FE Invisible V2: NONAKTIF")
    end
end

--// ============================================
--//  EVENTS
--// ============================================

toggleBtn.MouseButton1Click:Connect(toggleInvisible)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.Insert and not gameProcessed then
        toggleInvisible()
    end
end)

--// Auto re-apply kalau respawn
LocalPlayer.CharacterAdded:Connect(function(newChar)
    if isInvisible then
        wait(0.8) -- Tunggu character FULLY load
        destroyVisualExtras(newChar, true)
        fullVisualWipe(newChar, true)
        applyDesync(newChar, true)
        print("🔄 Auto-invisible applied after respawn")
    end
end)

--// Drag GUI
local dragging, dragInput, dragStart, startPos = false, nil, nil, nil

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

print("👻 VD FE Invisible V2 loaded!")
print("Tekan INSERT untuk toggle")
print("⚠️  WARNING: Desync bisa ke-detect anti-cheat. Pakai dengan bijak!")
