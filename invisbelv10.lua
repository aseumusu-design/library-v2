local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer

local isInvisible = false

-- Fungsi resmi mengubah transparansi seluruh bagian karakter
local function setCharacterTransparency(character, transparencyValue)
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("Decal") then
            -- HumanoidRootPart bawaannya memang harus transparan (1)
            if part.Name ~= "HumanoidRootPart" then
                part.Transparency = transparencyValue
            end
        elseif part:IsA("Accessory") then
            local handle = part:FindFirstChild("Handle")
            if handle then
                handle.Transparency = transparencyValue
            end
        end
    end
end

local function toggleInvisibility()
    local character = localPlayer.Character
    if not character then return end
    
    isInvisible = not isInvisible
    
    if isInvisible then
        -- Set ke 1 agar tidak terlihat sama sekali
        setCharacterTransparency(character, 1)
    else
        -- Set ke 0 agar kembali normal
        setCharacterTransparency(character, 0)
    end
end

-- GUI Troller Tetap Menggunakan Struktur Kamu
local troller = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local invis = Instance.new("TextButton")

troller.Name = "troller"
troller.Parent = localPlayer:WaitForChild("PlayerGui")
troller.ResetOnSpawn = false

Main.Name = "Main"
Main.Parent = troller
Main.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
Main.Position = UDim2.new(0.05, 0, 0.1, 0)
Main.Size = UDim2.new(0, 200, 0, 100)
Main.Active = true
Main.Draggable = true

invis.Name = "invis"
invis.Parent = Main
invis.BackgroundColor3 = Color3.fromRGB(255, 138, 42)
invis.Position = UDim2.new(0.1, 0, 0.25, 0)
invis.Size = UDim2.new(0, 160, 0, 50)
invis.Font = Enum.Font.SourceSansBold
invis.Text = "Invis: OFF"
invis.TextColor3 = Color3.fromRGB(255, 255, 255)
invis.TextSize = 18

invis.MouseButton1Click:Connect(function()
    toggleInvisibility()
    if isInvisible then
        invis.Text = "Invis: ON"
        invis.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
    else
        invis.Text = "Invis: OFF"
        invis.BackgroundColor3 = Color3.fromRGB(255, 138, 42)
    end
end)
