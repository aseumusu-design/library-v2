local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer

local isInvisible = false
local fakeCharacter = nil
local realRoot = nil
local cloneRoot = nil
local renderConnection = nil

local function toggleInvisibility()
    local character = localPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then return end

    isInvisible = not isInvisible

    if isInvisible then
        realRoot = rootPart
        local savedCFrame = realRoot.CFrame

        -- 1. Buat klon karakter di atas
        character.Archivable = true
        fakeCharacter = character:Clone()
        fakeCharacter.Name = "VisualClone"
        fakeCharacter.Parent = workspace
        cloneRoot = fakeCharacter:FindFirstChild("HumanoidRootPart")

        for _, v in pairs(fakeCharacter:GetChildren()) do
            if v:IsA("LocalScript") then v.Disabled = true end
        end

        -- Atur transparansi klon (0.3 agar kamu masih bisa lihat sedikit bayangan karaktermu sendiri)
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
        workspace.CurrentCamera.CameraSubject = fakeCharacter:FindFirstChildOfClass("Humanoid")

        -- 2. Pindahkan badan asli ke bawah tanah (Void)
        realRoot.CFrame = CFrame.new(savedCFrame.Position - Vector3.new(0, 500, 0))
        
        -- Sembunyikan bagian tubuh asli sepenuhnya
        for _, v in pairs(character:GetDescendants()) do
            if v:IsA("BasePart") or v:IsA("Decal") then
                v.Transparency = 1
            elseif v:IsA("Accessory") then
                local h = v:FindFirstChild("Handle")
                if h then h.Transparency = 1 end
            end
        end

        -- 3. PERBAIKAN UTAMA: Sinkronisasi posisi yang lebih stabil
        renderConnection = RunService.RenderStepped:Connect(function()
            if fakeCharacter and cloneRoot and cloneRoot.Parent and realRoot and realRoot.Parent then
                -- Paksa badan asli di bawah mengikuti persis pergerakan klon di atas
                realRoot.CFrame = cloneRoot.CFrame - Vector3.new(0, 500, 0)
                realRoot.AssemblyLinearVelocity = cloneRoot.AssemblyLinearVelocity
            end
        end)

    else
        -- Matikan Invisibility
        if renderConnection then
            renderConnection:Disconnect()
            renderConnection = nil
        end

        if fakeCharacter then
            if cloneRoot and realRoot then
                -- Munculkan kembali badan asli tepat di posisi terakhir klon berada
                realRoot.CFrame = cloneRoot.CFrame + Vector3.new(0, 3, 0)
            end
            fakeCharacter:Destroy()
            fakeCharacter = nil
        end

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

-- UI Menu Troller (Tetap Sama)
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
die.Text = "Underground Clone + Gun Fix"
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
