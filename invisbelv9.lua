local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer

-- Konfigurasi Invisibility Sinkronisasi Sempurna (Clone Atas & Badan Bawah Ikut Bergerak)
local isInvisible = false
local fakeCharacter = nil
local realRoot = nil
local cloneRoot = nil
local renderConnection = nil
local savedCFrame = nil

local function toggleInvisibility()
    local character = localPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then return end

    isInvisible = not isInvisible

    if isInvisible then
        realRoot = rootPart
        savedCEdit = realRoot.CFrame
        savedCFrame = realRoot.CFrame

        -- 1. Buat klon karakter di atas sebagai visual & kontrol utama (bisa jalan, nembak, emote)
        character.Archivable = true
        fakeCharacter = character:Clone()
        fakeCharacter.Name = "MovableInvisibleClone"
        fakeCharacter.Parent = workspace
        cloneRoot = fakeCharacter:FindFirstChild("HumanoidRootPart")

        -- Hidupkan script animasi klon
        local animateScript = fakeCharacter:FindFirstChild("Animate")
        if animateScript then animateScript.Disabled = false end

        -- Atur transparansi klon (0.3 agar terlihat samar di layar kamu, atau 1 jika ingin benar-benar tak terlihat)
        for _, v in pairs(fakeCharacter:GetDescendants()) do
            if v:IsA("BasePart") or v:IsA("Decal") then
                v.Transparency = 0.3
            elseif v:IsA("Accessory") then
                local h = v:FindFirstChild("Handle")
                if h then h.Transparency = 0.3 end
            end
        end

        if cloneRoot then
            cloneRoot.CFrame = savedCFrame
        end

        -- Alihkan kamera ke klon
        workspace.CurrentCamera.CameraSubject = fakeCharacter:FindFirstChildOfClass("Humanoid")

        -- 2. Teleport badan asli ke bawah tanah (Void) dan set Network Owner agar bisa digerakkan dari jarak jauh
        pcall(function()
            realRoot:SetNetworkOwner(localPlayer)
        end)
        
        realRoot.CFrame = savedCFrame * CFrame.new(0, -500, 0)

        -- Sembunyikan badan asli sepenuhnya
        for _, v in pairs(character:GetDescendants()) do
            if v:IsA("BasePart") or v:IsA("Decal") then
                v.Transparency = 1
            elseif v:IsA("Accessory") then
                local h = v:FindFirstChild("Handle")
                if h then h.Transparency = 1 end
            end
        end

        -- 3. Sinkronisasi mutlak: Badan asli di bawah mengikuti persis kemana klon berjalan di atas
        renderConnection = RunService.Heartbeat:Connect(function()
            if fakeCharacter and cloneRoot and realRoot and realRoot.Parent then
                -- Menjaga posisi badan asli persis 500 stud di bawah posisi klon secara real-time
                realRoot.CFrame = cloneRoot.CFrame * CFrame.new(0, -500, 0)
                realRoot.Velocity = cloneRoot.Velocity
                realRoot.RotVelocity = cloneRoot.RotVelocity
            end
        end)

    else
        -- Saat Invis OFF: Matikan sinkronisasi
        if renderConnection then
            renderConnection:Disconnect()
            renderConnection = nil
        end

        -- Kembalikan posisi badan asli naik ke posisi terakhir klon di atas sebelum dimatikan
        if fakeCharacter and cloneRoot and realRoot then
            realRoot.CFrame = cloneRoot.CFrame
        elseif savedCFrame and realRoot then
            realRoot.CFrame = savedCFrame
        end

        -- Hapus klon
        if fakeCharacter then
            fakeCharacter:Destroy()
            fakeCharacter = nil
        end

        -- Kembalikan kamera dan kembalikan visibilitas badan asli
        if character then
            workspace.CurrentCamera.CameraSubject = character:FindFirstChildOfClass("Humanoid")
            for _, v in pairs(character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Transparency = 0
                elseif v:IsA("Decal") then
                    v.Transparency = 0
                elseif v:IsA("Accessory") then
                    local h = v:FindFirstChild("Handle")
                    if h then h.Transparency = 0 end
                end
            end
        end
    end
end

-- Pembuatan UI Menu Troller Lengkap
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
die.Text = "Perfect Sync Underground"
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
