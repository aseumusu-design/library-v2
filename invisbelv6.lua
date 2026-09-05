local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer

-- Konfigurasi Invisibility Gaze R6 Void (Bisa Jalan, Nembak, Emote, 100% Invisible)
local isInvisible = false
local fakePart = nil
local renderConnection = nil

local function toggleInvisibility()
    local character = localPlayer.Character
    if not character then return end
    local hrp0 = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    
    if not hrp0 or not humanoid then return end

    isInvisible = not isInvisible

    if isInvisible then
        -- Pastikan rig R6 (kalau R15 sebagian game tidak mendukung metode void penuh)
        if humanoid.RigType ~= Enum.HumanoidRigType.R6 then
            warn("Metode ini khusus untuk R6 agar berjalan sempurna!")
        end

        local hrp1 = hrp0:Clone()

        -- Buat part indikator kecil di atas (opsional/bisa transparan)
        fakePart = Instance.new("Part")
        fakePart.Size = Vector3.new(0.5, 0.5, 0.5)
        fakePart.Anchored = true
        fakePart.CanCollide = false
        fakePart.Transparency = 1
        fakePart.Parent = workspace

        -- Trik Gaze Void R6
        character.Parent = nil
        hrp0.Parent = hrp1
        if hrp0:FindFirstChild("RootJoint") then
            hrp0.RootJoint.Part0 = nil
        end
        hrp1.Parent = character
        character.Parent = workspace

        local animId = "rbxassetid://215384594"
        local anim = Instance.new("Animation")
        anim.AnimationId = animId
        local animTrack = humanoid:LoadAnimation(anim)

        -- Sinkronisasi pergerakan dan posisi void ke bawah tanah
        renderConnection = RunService.Heartbeat:Connect(function()
            if character and character.Parent and hrp0 and hrp1 then
                humanoid.HipHeight = 3
                humanoid.JumpPower = 20
                if not animTrack.IsPlaying then
                    animTrack:Play()
                    animTrack:AdjustSpeed(0)
                    animTrack.TimePosition = 0.4
                end
                hrp0.CFrame = hrp1.CFrame 
                hrp0.Orientation = Vector3.new(90, 0, 0)
                hrp0.Position = hrp1.Position - Vector3.new(0, hrp0.Size.Y / 2, 0) 
                hrp0.Velocity = hrp1.Velocity

                fakePart.Position = hrp0.Position + Vector3.new(-0.05, 0, 2.45)
            end
        end)

    else
        -- Matikan Invisibility / Kembali Normal
        if renderConnection then
            renderConnection:Disconnect()
            renderConnection = nil
        end

        if fakePart then
            fakePart:Destroy()
            fakePart = nil
        end

        -- Paksa respawn/reload karakter agar kembali normal
        localPlayer.Character:BreakJoints()
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

-- Tombol On/Off Invisibility
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
        invis.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- Hijau
    else
        invis.Text = "Invis: OFF"
        invis.BackgroundColor3 = Color3.new(1, 0.541176, 0.164706) -- Oranye
    end
end)

-- Tombol UI ON / OFF (Menu Utama Sembunyi/Muncul) - AMAN TIDAK HILANG
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
die.Text = "Gaze R6 Void Perfect"
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

-- Fitur Drag & Drop, Tombol Keyboard ';', dan Tombol UI On/Off
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

toggleUIBtn.MouseButton1Click:Connect(function()
    toggleMenu()
end)
