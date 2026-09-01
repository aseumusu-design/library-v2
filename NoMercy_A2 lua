local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

--// GUI
local gui = Instance.new("ScreenGui")
gui.Name = "InvisibleToggle"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Name = "Toggle"
button.Size = UDim2.new(0, 180, 0, 50)
button.Position = UDim2.new(0.5, -90, 0.8, 0)
button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextSize = 18
button.Font = Enum.Font.GothamBold
button.Text = "INVISIBLE : OFF"
button.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = button

local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(80, 80, 80)
stroke.Parent = button

--// State
local invisible = false
local savedCFrame = nil

local function getCharacter()
	return player.Character or player.CharacterAdded:Wait()
end

local function setInvisible(character, state)
	for _, obj in ipairs(character:GetDescendants()) do
		if obj:IsA("BasePart") then
			if state then
				obj.LocalTransparencyModifier = 1
			else
				obj.LocalTransparencyModifier = 0
			end
		elseif obj:IsA("Decal") or obj:IsA("Texture") then
			obj.Transparency = state and 1 or 0
		end
	end
end

local function turnOn()
	local character = getCharacter()
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")

	if not humanoid or not root then
		return
	end

	-- Simpan posisi awal
	savedCFrame = root.CFrame
	invisible = true

	-- Langsung invisible
	setInvisible(character, true)

	-- Efek jatuh ke bawah
	root.CFrame = root.CFrame + Vector3.new(0, -20, 0)

	task.wait(0.25)

	-- Naik lagi tanpa membunuh Humanoid
	if character.Parent and humanoid.Health > 0 then
		root.CFrame = savedCFrame + Vector3.new(0, 5, 0)
	end

	button.Text = "INVISIBLE : ON"

	TweenService:Create(
		button,
		TweenInfo.new(0.2),
		{BackgroundColor3 = Color3.fromRGB(30, 120, 70)}
	):Play()
end

local function turnOff()
	local character = getCharacter()
	local root = character:FindFirstChild("HumanoidRootPart")

	invisible = false

	-- Kembalikan visual karakter
	setInvisible(character, false)

	-- Kembalikan ke posisi sebelum ON
	if root and savedCFrame then
		root.CFrame = savedCFrame
	end

	button.Text = "INVISIBLE : OFF"

	TweenService:Create(
		button,
		TweenInfo.new(0.2),
		{BackgroundColor3 = Color3.fromRGB(35, 35, 35)}
	):Play()
end

button.MouseButton1Click:Connect(function()
	if invisible then
		turnOff()
	else
		turnOn()
	end
end)

-- Kalau karakter respawn, reset status
player.CharacterAdded:Connect(function()
	invisible = false
	savedCFrame = nil

	task.wait(0.5)

	button.Text = "INVISIBLE : OFF"
	button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
end)
