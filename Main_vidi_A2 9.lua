-- Weliton Style Invisible Script (Clean & Fixed)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer

local isInvisible = false
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local backpack = localPlayer:WaitForChild("Backpack")

-- Fungsi utama Invisible (Metode Tool / Desync Server)
local function toggleInvisibility()
    character = localPlayer.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end

    isInvisible = not isInvisible

    if isInvisible then
        -- Simpan posisi terakhir sebelum invis
        local savedCFrame = humanoidRootPart.CFrame

        -- Cari tool di backpack untuk trik desync, atau gunakan metode drop/equip jika ada
        local tool = character:FindFirstChildOfClass("Tool") or backpack:FindFirstChildOfClass("Tool")
        if tool then
            tool.Parent = character
            task.wait()
            tool.Parent = backpack
        end

        -- Ubah transparansi bagian tubuh agar tak terlihat player lain & diri sendiri
        for _, v in pairs(character:GetDescendants()) do
            if v:IsA("BasePart") then
                if v.Name ~= "HumanoidRootPart" then
                    v.Transparency = 1
                    v.CanCollide = false
                end
            elseif v:IsA("Decal") then
                v.Transparency = 1
            elseif v:IsA("Accessory") then
                local handle = v:FindFirstChild("Handle")
                if handle then
                    handle.Transparency = 1
                    handle.CanCollide = false
                end
            end
        end
        
        print("Invis: ON")
    else
        -- Matikan Invis / Kembali Normal
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            -- Reset karakter dengan mati/respawn atau mengembalikan properti
            local currentPos = humanoidRootPart.CFrame
            localPlayer.Character:BreakJoints() -- Opsi paling bersih untuk reset posisi dan badan normal kembali
        end
        print("Invis: OFF")
    end
end

-- Pembuatan UI Menu Troller
local troller = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local nameofgui = Instance.new("TextLabel")
local border = Instance.new("Frame")
local invisBtn = Instance.new("TextButton")
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
invisBtn.Name = "invis"
invisBtn.Parent = Main
invisBtn.BackgroundColor3 = Color3.new(1, 0.541176, 0.164706)
invisBtn.Position = UDim2.new(0, 0, 0.15, 0)
invisBtn.Size = UDim2.new(0, 248, 0, 32)
invisBtn.Font = Enum.Font.SourceSansItalic
invisBtn.Text = "Invis: OFF"
invisBtn.TextColor3 = Color3.new(1, 1, 1)
invisBtn.TextSize = 16

invisBtn.MouseButton1Click:Connect(function()
    toggleInvisibility()
    if isInvisible then
        invisBtn.Text = "Invis: ON"
        invisBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- Hijau
    else
        invisBtn.Text = "Invis: OFF"
        invisBtn.BackgroundColor3 = Color3.new(1, 0.541176, 0.164706) -- Oranye
    end
end)

-- Tombol UI ON / OFF
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
memedog.Text = "Weliton Style Fix"
memedog.TextColor3 = Color3.new(0, 1, 0)
memedog.TextSize = 14

die.Name = "die"
die.Parent = Main
die.BackgroundTransparency = 1
die.Position = UDim2.new(0.01, 0, 0.72, 0)
die.Size = UDim2.new(0, 246, 0, 23)
die.Font = Enum.Font.SourceSansLight
die.Text = "Tool Desync Method"
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

-- Fitur Drag & Drop & Hide Menu
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
