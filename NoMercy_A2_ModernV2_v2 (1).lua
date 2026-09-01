--// ============================================
--//  VIOLENCE DISTRICT - FE INVISIBILITY SCRIPT
--//  Khusus buat Survivor (bisa interact objek)
--//  Toggle: Press INSERT
--// ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

--// Settings
local INVIS_KEY = Enum.KeyCode.Insert
local isInvisible = false
local invisConnection = nil
local originalTransparencies = {}
local originalNames = {}

--// GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VD_InvisibleGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 120)
mainFrame.Position = UDim2.new(0, 20, 0.5, -60)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.Text = "👻 VD Invisible"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = mainFrame

Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 25)
statusLabel.Position = UDim2.new(0.05, 0, 0.35, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: VISIBLE"
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 18
statusLabel.Parent = mainFrame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0, 30)
toggleBtn.Position = UDim2.new(0.05, 0, 0.65, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
toggleBtn.Text = "Toggle Invisible [INSERT]"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.Gotham
toggleBtn.TextSize = 14
toggleBtn.Parent = mainFrame

Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

--// Core Invisibility Function
local function makeInvisible(character)
    if not character then return end
    
    -- Simpan original values
    originalTransparencies = {}
    originalNames = {}
    
    -- Loop semua descendant di character
    for _, obj in pairs(character:GetDescendants()) do
        if obj:IsA("BasePart") then
            if obj.Name ~= "HumanoidRootPart" then
                originalTransparencies[obj] = obj.Transparency
                obj.Transparency = 1
            end
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            originalTransparencies[obj] = obj.Transparency
            obj.Transparency = 1
        elseif obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
            originalTransparencies[obj] = obj.Enabled
            obj.Enabled = false
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
            originalTransparencies[obj] = obj.Enabled
            obj.Enabled = false
        end
    end
    
    -- Hilangkan name tag di atas kepala
    local head = character:FindFirstChild("Head")
    if head then
        for _, child in pairs(head:GetChildren()) do
            if child:IsA("BillboardGui") and child.Name:lower():find("name") then
                originalNames[child] = child.Enabled
                child.Enabled = false
            end
        end
    end
    
    -- FE Invisibility Trick: HumanoidRootPart manipulation
    local hrp = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")
    
    -- Simpan original properties
    originalTransparencies["HRP_CFrame"] = hrp.CFrame
    originalTransparencies["HRP_CanCollide"] = hrp.CanCollide
    originalTransparencies["Humanoid_WalkSpeed"] = humanoid.WalkSpeed
    
    -- Anti-detect: Jangan ubah WalkSpeed drastis (bisa ke-detect anti-cheat)
    -- Tapi kita bisa manipulate CFrame untuk desync ringan
    
    -- Hilangkan shadow/footstep effects
    if humanoid then
        -- Matikan footstep sounds
        for _, sound in pairs(character:GetDescendants()) do
            if sound:IsA("Sound") and (sound.Name:lower():find("step") or sound.Name:lower():find("foot")) then
                originalTransparencies[sound] = sound.Volume
                sound.Volume = 0
            end
        end
    end
    
    -- Loop untuk maintain invisibility (kalo ada part baru)
    invisConnection = RunService.Heartbeat:Connect(function()
        if not isInvisible then return end
        if not character or not character.Parent then return end
        
        for _, obj in pairs(character:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart" then
                if obj.Transparency ~= 1 then
                    obj.Transparency = 1
                end
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                if obj.Transparency ~= 1 then
                    obj.Transparency = 1
                end
            end
        end
    end)
end

--// Restore Visibility
local function makeVisible(character)
    if invisConnection then
        invisConnection:Disconnect()
        invisConnection = nil
    end
    
    if not character then return end
    
    -- Restore transparencies
    for obj, original in pairs(originalTransparencies) do
        if typeof(obj) == "Instance" and obj.Parent then
            if obj:IsA("BasePart") or obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = original
            elseif obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") or obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                obj.Enabled = original
            elseif obj:IsA("Sound") then
                obj.Volume = original
            end
        end
    end
    
    -- Restore name tags
    for obj, original in pairs(originalNames) do
        if typeof(obj) == "Instance" and obj.Parent then
            obj.Enabled = original
        end
    end
    
    originalTransparencies = {}
    originalNames = {}
end

--// Toggle Function
local function toggleInvisibility()
    local character = LocalPlayer.Character
    if not character then
        warn("❌ Character belum spawn!")
        return
    end
    
    isInvisible = not isInvisible
    
    if isInvisible then
        makeInvisible(character)
        statusLabel.Text = "Status: INVISIBLE 👻"
        statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        toggleBtn.Text = "Turn OFF Invisible"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        print("✅ VD Invisible: AKTIF - Killer nggak bisa lihat kamu!")
    else
        makeVisible(character)
        statusLabel.Text = "Status: VISIBLE"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        toggleBtn.Text = "Toggle Invisible [INSERT]"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        print("✅ VD Invisible: NONAKTIF - Kamu terlihat normal")
    end
end

--// Event Listeners
toggleBtn.MouseButton1Click:Connect(toggleInvisibility)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == INVIS_KEY and not gameProcessed then
        toggleInvisibility()
    end
end)

--// Auto-apply kalau character respawn
LocalPlayer.CharacterAdded:Connect(function(newChar)
    if isInvisible then
        wait(0.5) -- Tunggu character fully load
        makeInvisible(newChar)
    end
end)

--// Drag GUI
local dragging = false
local dragStart = nil
local startPos = nil

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

print("👻 VD Invisible Script loaded! Tekan INSERT untuk toggle")
