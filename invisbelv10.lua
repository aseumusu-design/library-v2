local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer

-- Konfigurasi True Character Swap (Clone Aktif, Badan Asli Ngikut dari Bawah Tanah)
local isInvisible = false
local realCharacter = nil
local fakeCharacter = nil
local renderConnection = nil
local invisibilityOffset = -50 -- Jarak badan asli di bawah tanah

local function toggleInvisibility()
    if not isInvisible then
        -- 1. Persiapan Clone
        realCharacter = localPlayer.Character
        if not realCharacter or not realCharacter:FindFirstChild("HumanoidRootPart") then return end

        realCharacter.Archivable = true
        fakeCharacter = realCharacter:Clone()
        fakeCharacter.Name = "MovableClone"
        fakeCharacter.Parent = workspace
        
        -- Samakan posisi awal klon
        fakeCharacter.HumanoidRootPart.CFrame = realCharacter.HumanoidRootPart.CFrame

        -- Bikin klon transparan 0.5 agar kamu tau lagi mode invisible
        for _, v in pairs(fakeCharacter:GetDescendants()) do
            if v:IsA("BasePart") or v:IsA("Decal") then
                v.Transparency = 0.5
            elseif v:IsA("Accessory") then
                local h = v:FindFirstChild("Handle")
                if h then h.Transparency = 0.5 end
            end
        end

        -- 2. Pindah Kontrol Penuh ke Klon
        localPlayer.Character = fakeCharacter
        workspace.CurrentCamera.CameraSubject = fakeCharacter:WaitForChild("Humanoid")

        -- Matikan LocalScript di badan asli agar tidak error/bentrok
        for _, script in pairs(realCharacter:GetChildren()) do
            if script:IsA("LocalScript") then 
                script.Disabled = true 
            end
        end
        
        -- 3. Sinkronisasi: Badan asli dipaksa ngikutin pergerakan klon dari bawah tanah
        renderConnection = RunService.Heartbeat:Connect(function()
            if realCharacter and fakeCharacter and realCharacter:FindFirstChild("HumanoidRootPart") and fakeCharacter:FindFirstChild("HumanoidRootPart") then
                local targetCFrame = fakeCharacter.HumanoidRootPart.CFrame * CFrame.new(0, invisibilityOffset, 0)
                realCharacter.HumanoidRootPart.CFrame = targetCFrame
                realCharacter.HumanoidRootPart.Velocity = fakeCharacter.HumanoidRootPart.Velocity
            end
        end)

        isInvisible = true
    else
        -- 1. Matikan Sinkronisasi
        if renderConnection then
            renderConnection:Disconnect()
            renderConnection = nil
        end

        -- 2. Kembalikan Posisi Badan Asli Naik ke Posisi Terakhir Klon
        if realCharacter and fakeCharacter and realCharacter:FindFirstChild("HumanoidRootPart") and fakeCharacter:FindFirstChild("HumanoidRootPart") then
            realCharacter.HumanoidRootPart.CFrame = fakeCharacter.HumanoidRootPart.CFrame
            
            -- Kembalikan Kontrol ke Badan Asli
            localPlayer.Character = realCharacter
            workspace.CurrentCamera.CameraSubject = realCharacter:WaitForChild("Humanoid")
            
            -- Hidupkan lagi LocalScript di badan asli
            for _, script in pairs(realCharacter:GetChildren()) do
                if script:IsA("LocalScript") then 
                    script.Disabled = false 
                end
            end
        end

        -- 3. Hapus Klon
        if fakeCharacter then
            fakeCharacter:Destroy()
            fakeCharacter = nil
        end

        isInvisible = false
    end
end

-- Pembuatan UI Menu Troller
local troller = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local nameofgui = Instance.new("TextLabel")
local border = Instance.new("Frame")
local invis = Instance.new("TextButton")
local toggleUIBtn = Instance.new("TextButton")
local memedog = Instance.new("TextLabel")
local die = Instance.new("TextLabel")
local axy = Instance.new("TextLabel")

troller.Name = "troller"
troller.Parent = localPlayer:WaitForChild("PlayerGui")
troller.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
troller.ResetOnSpawn = false

Main.Name = "Main"
Main.Parent = troller
Main.BackgroundColor3 = Color3.new(0.129412, 0.129412, 0.129412)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Position = UDim2.new(0.045, 0, 0.087, 0)
Main.Size = UDim2.new(0, 248, 0, 220)

nameofgui.Name = "nameofgui"
nameofgui.Parent = Main
nameofgui.BackgroundTransparency = 1
nameofgui.Size = UDim2.new(0, 248, 0, 19)
nameofgui.Font = Enum.Font.GothamBold
nameofgui.Text = "Troller"
nameofgui.TextColor3 = Color3.new(1, 1, 1)
nameofgui.TextSize = 16
nameofgui.TextXAlignment = Enum.TextXAlignment.Left

border.Name = "border"
border.Parent = Main
border.BackgroundColor3 = Color3.new(1, 1, 1)
border.Position = UDim2.new(0, 0, 0.09, 0)
border.Size = UDim2.new(0, 248, 0, 1)

invis.Name = "invis"
invis.Parent = Main
invis.BackgroundColor3 = Color3.new(1, 0.541176, 0.164706)
invis.Position = UDim2.new(0, 0, 0.15, 0)
invis.Size = UDim2.new(0, 248, 0, 32)
invis.Font = Enum.Font.SourceSansItalic
invis.Text = "Invis: OFF"
invis.TextColor3 = Color3.new(1, 1, 1)
invis.TextSize = 16

invis.MouseButton1Click:Connect(function()
    toggleInvisibility()
    if isInvisible then
        invis.Text = "Invis: ON"
        invis.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
    else
        invis.Text = "Invis: OFF"
        invis.BackgroundColor3 = Color3.new(1, 0.541176, 0.164706)
    end
end)

toggleUIBtn.Name = "toggleUIBtn"
toggleUIBtn.Parent = Main
toggleUIBtn.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
toggleUIBtn.Position = UDim2.new(0, 0, 0.33, 0)
toggleUIBtn.Size = UDim2.new(0, 248, 0, 32)
toggleUIBtn.Font = Enum.Font.SourceSansBold
toggleUIBtn.Text = "UI ON / OFF (Click)"
toggleUIBtn.TextColor3 = Color3.new(1, 1, 1)
toggleUIBtn.TextSize = 14

memedog.Name = "memedog"
memedog.Parent = Main
memedog.BackgroundTransparency = 1
memedog.Position = UDim2.new(0.04, 0, 0.58, 0)
memedog.Size = UDim2.new(0, 200, 0, 23)
memedog.Font = Enum.Font.SourceSansLight
memedog.Text = "Memedog#1256 for GUI"
memedog.TextColor3 = Color3.new(0, 1, 0)
memedog.TextSize = 14

die.Name = "die"
die.Parent = Main
die.BackgroundTransparency = 1
die.Position = UDim2.new(0.01, 0, 0.72, 0)
die.Size = UDim2.new(0, 246, 0, 23)
die.Font = Enum.Font.SourceSansLight
die.Text = "True Swap Active"
die.TextColor3 = Color3.new(0, 1, 1)
die.TextSize = 14

axy.Name = "axy"
axy.Parent = Main
axy.BackgroundTransparency = 1
axy.Position = UDim2.new(0.01, 0, 0.85, 0)
axy.Size = UDim2.new(0, 246, 0, 23)
axy.Font = Enum.Font.SourceSansLight
axy.Text = "Press ; to hide or show"
axy.TextColor3 = Color3.new(1, 1, 0)
axy.TextSize = 14

-- Fitur Drag & Drop & Hide
local isHidden = false
local mouse = localPlayer:GetMouse()

function Draggable(frame)
    frame.Active = true
    frame.InputBegan:Connect(function(key)
        if key.UserInputType == Enum.UserInputType.MouseButton1 then
            local objectPosition = Vector2.new(mouse.X - frame.AbsolutePosition.X, mouse.Y - frame.AbsolutePosition.Y)
            while RunService.Heartbeat:Wait() and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                frame:TweenPosition(UDim2.new(0, mouse.X - objectPosition.X + (frame.Size.X.Offset * frame.AnchorPoint.X), 0, mouse.Y - objectPosition.Y + (frame.Size.Y.Offset * frame.AnchorPoint.Y)), 'Out', 'Quad', 0.1, true)
            end
        end
    end)
end

Draggable(Main)

local function toggleMenu()
    if isHidden == false then
        Main:TweenPosition(Main.Position - UDim2.new(0, 0, 1, 0), "Out", "Quad", 0.4, false)
        isHidden = true
    else
        Main:TweenPosition(Main.Position + UDim2.new(0, 0, 1, 0), "Out", "Quad", 0.4, false)
        isHidden = false
    end
end

mouse.KeyDown:Connect(function(key)
    if key == ";" then
        toggleMenu()
    end
end)

toggleUIBtn.MouseButton1Click:Connect(toggleMenu)

-- Handle Character Respawn
localPlayer.CharacterAdded:Connect(function(newChar)
    if isInvisible then
        toggleInvisibility()
    end
end)
