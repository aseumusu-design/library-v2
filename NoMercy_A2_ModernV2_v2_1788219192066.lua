local localPlayer = game.Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()

-- Konfigurasi Invisibility
local invisibilityOffset = -20
local fakeCharacterTransparency = 0.7

local InvisibilityModule = {}
InvisibilityModule.__index = InvisibilityModule

function InvisibilityModule.new(player, offset)
    local self = setmetatable({}, InvisibilityModule)
    self.player = player
    self.offset = offset
    self.realCharacter = player.Character or player.CharacterAdded:Wait()
    self.fakeCharacter = nil
    self.isInvisible = false
    self.canBeInvisible = true
    self:Setup()
    return self
end

function InvisibilityModule:Setup()
    if not self.canBeInvisible then return end
    self.realCharacter.Archivable = true
    self.fakeCharacter = self.realCharacter:Clone()
    self.fakeCharacter.Name = "FakeCharacter"
    self.fakeCharacter.Parent = workspace
    if self.fakeCharacter:FindFirstChild("HumanoidRootPart") and self.realCharacter:FindFirstChild("HumanoidRootPart") then
        self.fakeCharacter.HumanoidRootPart.CFrame = self.realCharacter.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
    end

    self:DisableLocalScripts(self.fakeCharacter)

    for _, part in pairs(self.fakeCharacter:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = fakeCharacterTransparency
            part.CanCollide = false
        end
    end
    if self.fakeCharacter:FindFirstChild("HumanoidRootPart") then
        self.fakeCharacter.HumanoidRootPart.CanCollide = false
    end
end

function InvisibilityModule:DisableLocalScripts(char)
    for _, script in pairs(char:GetChildren()) do
        if script:IsA("LocalScript") then
            script.Disabled = true
        end
    end
end

function InvisibilityModule:EnableLocalScripts(char)
    for _, script in pairs(char:GetChildren()) do
        if script:IsA("LocalScript") then
            script.Disabled = false
        end
    end
end

function InvisibilityModule:Toggle()
    if self.isInvisible then
        if self.fakeCharacter and self.fakeCharacter:FindFirstChild("HumanoidRootPart") and self.realCharacter:FindFirstChild("HumanoidRootPart") then
            self.realCharacter.HumanoidRootPart.CFrame = self.fakeCharacter.HumanoidRootPart.CFrame
        end
        self.player.Character = self.realCharacter
        if self.realCharacter:FindFirstChild("Humanoid") then
            workspace.CurrentCamera.CameraSubject = self.realCharacter.Humanoid
        end
        self:EnableLocalScripts(self.realCharacter)
        self:DisableLocalScripts(self.fakeCharacter)
        self.isInvisible = false
    else
        if self.fakeCharacter and self.fakeCharacter:FindFirstChild("HumanoidRootPart") and self.realCharacter:FindFirstChild("HumanoidRootPart") then
            self.fakeCharacter.HumanoidRootPart.CFrame = self.realCharacter.HumanoidRootPart.CFrame
        end
        self.player.Character = self.fakeCharacter
        if self.fakeCharacter:FindFirstChild("Humanoid") then
            workspace.CurrentCamera.CameraSubject = self.fakeCharacter.Humanoid
        end
        self:DisableLocalScripts(self.realCharacter)
        self:EnableLocalScripts(self.fakeCharacter)
        self.isInvisible = true
    end
end

function InvisibilityModule:UpdatePosition()
    if self.isInvisible and self.realCharacter and self.fakeCharacter and self.realCharacter:FindFirstChild("HumanoidRootPart") and self.fakeCharacter:FindFirstChild("HumanoidRootPart") then
        local targetCFrame = self.fakeCharacter.HumanoidRootPart.CFrame * CFrame.new(0, self.offset, 0)
        self.realCharacter.HumanoidRootPart.CFrame = targetCFrame
        pcall(function()
            self.realCharacter.HumanoidRootPart:SetNetworkOwner(self.player)
        end)
    end
end

function InvisibilityModule:HandleCharacterAdded()
    self.canBeInvisible = false
    if self.fakeCharacter then self.fakeCharacter:Destroy() end
    self.realCharacter = self.player.Character or self.player.CharacterAdded:Wait()
    self:Setup()
    self.canBeInvisible = true
    if self.realCharacter:FindFirstChild("Humanoid") then
        self.realCharacter.Humanoid.Died:Connect(function() self:HandleCharacterAdded() end)
    end
end

local invisibility = InvisibilityModule.new(localPlayer, invisibilityOffset)

if invisibility.realCharacter:FindFirstChild("Humanoid") then
    invisibility.realCharacter.Humanoid.Died:Connect(function() invisibility:HandleCharacterAdded() end)
end
localPlayer.CharacterAppearanceLoaded:Connect(function() invisibility:HandleCharacterAdded() end)

game:GetService("RunService").Heartbeat:Connect(function()
    invisibility:UpdatePosition()
end)

-- Pembuatan UI "Troller" Utama
local troller = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local nameofgui = Instance.new("TextLabel")
local border = Instance.new("Frame")
local invis = Instance.new("TextButton")
local toggleUIBtn = Instance.new("TextButton")
local memedog = Instance.new("TextLabel")
local die = Instance.new("TextLabel")
local axy = Instance.new("TextLabel")
local diemie = Instance.new("TextLabel")

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
    invisibility:Toggle()
    if invisibility.isInvisible then
        invis.Text = "Invis: ON"
        invis.BackgroundColor3 = Color3.new(0, 0.7, 0) -- Hijau saat aktif
    else
        invis.Text = "Invis: OFF"
        invis.BackgroundColor3 = Color3.new(1, 0.541176, 0.164706) -- Oranye saat mati
    end
end)

-- Tombol UI Hide/Show On-Screen
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
die.Text = "Fixed Invisibility Script"
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

-- Sistem Drag & Drop serta Hide/Show dengan tombol ';'
local isHidden = false
local mouse = localPlayer:GetMouse()
local inputService = game:GetService('UserInputService')
local heartbeat = game:GetService("RunService").Heartbeat

function Draggable(frame)
    frame.Active = true
    frame.InputBegan:Connect(function(key)
        if key.UserInputType == Enum.UserInputType.MouseButton1 then
            local objectPosition = Vector2.new(mouse.X - frame.AbsolutePosition.X, mouse.Y - frame.AbsolutePosition.Y)
            while heartbeat:Wait() and inputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                frame:TweenPosition(UDim2.new(0, mouse.X - objectPosition.X + (frame.Size.X.Offset * frame.AnchorPoint.X), 0, mouse.Y - objectPosition.Y + (frame.Size.Y.Offset * frame.AnchorPoint.Y)), 'Out', 'Quad', 0.1, true)
            end
        end
    end)
end

Draggable(Main)

mouse.KeyDown:Connect(function(key)
    if key == ";" then
        if isHidden == false then
            Main:TweenPosition(Main.Position - UDim2.new(0, 0, 1, 0), "Out", "Quad", 0.4, false)
            isHidden = true
        else
            Main:TweenPosition(Main.Position + UDim2.new(0, 0, 1, 0), "Out", "Quad", 0.4, false)
            isHidden = false
        end
    end
end)

toggleUIBtn.MouseButton1Click:Connect(function()
    if isHidden == false then
        Main:TweenPosition(Main.Position - UDim2.new(0, 0, 1, 0), "Out", "Quad", 0.4, false)
        isHidden = true
    else
        Main:TweenPosition(Main.Position + UDim2.new(0, 0, 1, 0), "Out", "Quad", 0.4, false)
        isHidden = false
    end
end)
