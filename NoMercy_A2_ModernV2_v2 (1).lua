local player = game:GetService("Players").LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local runService = game:GetService("RunService")

local isInvisible = false
local hiddenParts = {}

-- Function to set transparency for all character parts
local function setCharacterTransparency(transparency)
    if not character then return end
    
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("Decal") then
            -- Store original transparency if we are turning invisible
            if transparency == 1 then
                if not hiddenParts[part] then
                    hiddenParts[part] = part.Transparency
                end
                part.Transparency = 1
            else
                -- Restore original transparency
                part.Transparency = hiddenParts[part] or 0
            end
        end
    end
end

-- Create UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "InvisGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 150, 0, 50)
toggleButton.Position = UDim2.new(0.5, -75, 0.8, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Text = "Invisibility: OFF"
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 20
toggleButton.Parent = screenGui

-- UI Styling (Rounded Corners)
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = toggleButton

-- Toggle Logic
toggleButton.MouseButton1Click:Connect(function()
    isInvisible = not isInvisible
    
    if isInvisible then
        toggleButton.Text = "Invisibility: ON"
        toggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        setCharacterTransparency(1)
    else
        toggleButton.Text = "Invisibility: OFF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
        setCharacterTransparency(0)
    end
end)

-- Keep character invisible if new parts are added or character respawns
runService.RenderStepped:Connect(function()
    if isInvisible then
        if not character or not character.Parent then
            character = player.Character
        end
        setCharacterTransparency(1)
    end
end)

player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    if isInvisible then
        task.wait(0.1)
        setCharacterTransparency(1)
    end
end)

print("Invisibility Script Loaded for CURE: Distrik Kekerasan")
