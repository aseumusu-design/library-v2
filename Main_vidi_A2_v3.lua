-- Captured at: 22:55:19
local args = {
    [1] = game:GetService("Players").LocalPlayer.Character:FindFirstChild("Twist of Fate"):FindFirstChild("Right Arm").EmperorGun,
    [2] = Vector3.new(-0.20536945760250092, -0.18702244758605957, -0.9606487154960632)
}

game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Items"):WaitForChild("Twist of Fate"):WaitForChild("Fire"):FireServer(unpack(args))

local v1 = game:GetService("ReplicatedStorage")
local v_u_2 = game:GetService("UserInputService")
local v_u_3 = game:GetService("RunService")
local v_u_4 = game:GetService("Players")
local v_u_5 = game:GetService("CollectionService")
local v6 = {}
local v_u_7 = v1:WaitForChild("Remotes"):WaitForChild("Mechanics"):WaitForChild("cancelaction")
local v_u_8 = v1:WaitForChild("Remotes"):WaitForChild("Items"):WaitForChild("Twist of Fate"):WaitForChild("Fire")

-- Pengaturan Auto Aim & God Mode
local AutoAimEnabled = true
local TargetMode = "Killer" -- Pilihan: "Killer" atau "Survivor"
local MaxRadius = 150 -- Radius maksimal dalam stud
local GodModeEnabled = false -- Status God Mode (Default OFF)

local function getAutoAimDirection(originPos)
	local closestTarget = nil
	local shortestDist = MaxRadius
	
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") then
			local isValidTarget = false
			if TargetMode == "Killer" then
				if v_u_5:HasTag(obj, "Lookscriptkiller") then
					isValidTarget = true
				end
			elseif TargetMode == "Survivor" then
				local player = v_u_4:GetPlayerFromCharacter(obj)
				if player and player ~= v_u_4.LocalPlayer then
					isValidTarget = true
				end
			end
			
			if isValidTarget then
				local hrp = obj.HumanoidRootPart
				local hum = obj:FindFirstChildOfClass("Humanoid")
				if hum and hum.Health > 0 then
					local dist = (hrp.Position - originPos).Magnitude
					if dist < shortestDist then
						shortestDist = dist
						closestTarget = hrp
					end
				end
			end
		end
	end
	
	if closestTarget then
		return (closestTarget.Position - originPos).Unit
	end
	return nil
end

local function createAutoAimUI()
	local lp = v_u_4.LocalPlayer
	local pg = lp:WaitForChild("PlayerGui", 5)
	if not pg then return end
	
	local oldGui = pg:FindFirstChild("AutoAimAdvancedGui")
	if oldGui then oldGui:Destroy() end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "AutoAimAdvancedGui"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = pg

	-- Frame Utama (Bisa di-drag di HP / PC)
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 170, 0, 165)
	mainFrame.Position = UDim2.new(0.5, -85, 0.35, -82)
	mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	mainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
	mainFrame.Active = true
	mainFrame.Parent = screenGui

	-- Tombol On/Off Auto Aim
	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Name = "ToggleBtn"
	toggleBtn.Size = UDim2.new(0, 150, 0, 26)
	toggleBtn.Position = UDim2.new(0.5, -75, 0, 8)
	toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	toggleBtn.BorderColor3 = Color3.fromRGB(200, 200, 200)
	toggleBtn.Text = "AUTO AIM : ON"
	toggleBtn.TextColor3 = Color3.fromRGB(0, 255, 0)
	toggleBtn.TextSize = 12
	toggleBtn.Font = Enum.Font.SourceSansBold
	toggleBtn.Parent = mainFrame

	-- Tombol Ganti Target (Killer / Survivor)
	local targetBtn = Instance.new("TextButton")
	targetBtn.Name = "TargetBtn"
	targetBtn.Size = UDim2.new(0, 150, 0, 26)
	targetBtn.Position = UDim2.new(0.5, -75, 0, 39)
	targetBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	targetBtn.BorderColor3 = Color3.fromRGB(200, 200, 200)
	targetBtn.Text = "TARGET : KILLER"
	targetBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
	targetBtn.TextSize = 12
	targetBtn.Font = Enum.Font.SourceSansBold
	targetBtn.Parent = mainFrame

	-- Tombol God Mode
	local godModeBtn = Instance.new("TextButton")
	godModeBtn.Name = "GodModeBtn"
	godModeBtn.Size = UDim2.new(0, 150, 0, 26)
	godModeBtn.Position = UDim2.new(0.5, -75, 0, 70)
	godModeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	godModeBtn.BorderColor3 = Color3.fromRGB(200, 200, 200)
	godModeBtn.Text = "GOD MODE : OFF"
	godModeBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
	godModeBtn.TextSize = 12
	godModeBtn.Font = Enum.Font.SourceSansBold
	godModeBtn.Parent = mainFrame

	-- Label & Tombol Pengatur Radius
	local radiusLabel = Instance.new("TextLabel")
	radiusLabel.Name = "RadiusLabel"
	radiusLabel.Size = UDim2.new(0, 150, 0, 18)
	radiusLabel.Position = UDim2.new(0.5, -75, 0, 101)
	radiusLabel.BackgroundTransparency = 1
	radiusLabel.Text = "RADIUS : " .. MaxRadius .. " Studs"
	radiusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	radiusLabel.TextSize = 11
	radiusLabel.Font = Enum.Font.SourceSansBold
	radiusLabel.Parent = mainFrame

	local minusBtn = Instance.new("TextButton")
	minusBtn.Size = UDim2.new(0, 35, 0, 20)
	minusBtn.Position = UDim2.new(0.5, -75, 0, 122)
	minusBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	minusBtn.Text = "-"
	minusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	minusBtn.TextSize = 14
	minusBtn.Font = Enum.Font.SourceSansBold
	minusBtn.Parent = mainFrame

	local plusBtn = Instance.new("TextButton")
	plusBtn.Size = UDim2.new(0, 35, 0, 20)
	plusBtn.Position = UDim2.new(0.5, 40, 0, 122)
	plusBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	plusBtn.Text = "+"
	plusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	plusBtn.TextSize = 14
	plusBtn.Font = Enum.Font.SourceSansBold
	plusBtn.Parent = mainFrame

	-- Logika Dragging (Support Touch HP & Mouse PC)
	local dragging, dragInput, dragStart, startPos

	mainFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = mainFrame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	mainFrame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	v_u_2.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	-- Fungsi Aksi Tombol
	toggleBtn.MouseButton1Click:Connect(function()
		AutoAimEnabled = not AutoAimEnabled
		if AutoAimEnabled then
			toggleBtn.Text = "AUTO AIM : ON"
			toggleBtn.TextColor3 = Color3.fromRGB(0, 255, 0)
		else
			toggleBtn.Text = "AUTO AIM : OFF"
			toggleBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
		end
	end)

	targetBtn.MouseButton1Click:Connect(function()
		if TargetMode == "Killer" then
			TargetMode = "Survivor"
			targetBtn.Text = "TARGET : SURVIVOR"
			targetBtn.TextColor3 = Color3.fromRGB(100, 200, 255)
		else
			TargetMode = "Killer"
			targetBtn.Text = "TARGET : KILLER"
			targetBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
		end
	end)

	godModeBtn.MouseButton1Click:Connect(function()
		GodModeEnabled = not GodModeEnabled
		if GodModeEnabled then
			godModeBtn.Text = "GOD MODE : ON"
			godModeBtn.TextColor3 = Color3.fromRGB(0, 255, 0)
		else
			godModeBtn.Text = "GOD MODE : OFF"
			godModeBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
		end
	end)

	plusBtn.MouseButton1Click:Connect(function()
		MaxRadius = math.min(MaxRadius + 25, 500)
		radiusLabel.Text = "RADIUS : " .. MaxRadius .. " Studs"
	end)

	minusBtn.MouseButton1Click:Connect(function()
		MaxRadius = math.max(MaxRadius - 25, 25)
		radiusLabel.Text = "RADIUS : " .. MaxRadius .. " Studs"
	end)
end

-- Eksekusi pembuatan UI dengan aman
task.defer(createAutoAimUI)
v_u_4.LocalPlayer.CharacterAdded:Connect(function()
	task.wait(1.5)
	createAutoAimUI()
end)

-- Loop Pengaman God Mode
v_u_3.RenderStepped:Connect(function()
	if GodModeEnabled then
		local char = v_u_4.LocalPlayer.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then
				hum.Health = hum.MaxHealth
			end
			if v_u_4.LocalPlayer:GetAttribute("IsDead") then
				v_u_4.LocalPlayer:SetAttribute("IsDead", false)
			end
			if char:GetAttribute("IsCarried") then
				char:SetAttribute("IsCarried", false)
			end
			if char:GetAttribute("IsHooked") then
				char:SetAttribute("IsHooked", false)
			end
		end
	end
end)

function v6.start(p9)
	local v10 = p9.item
	local v_u_11 = assert(v10, "TwistOfFateClient.start: config.item is required")
	local v12 = p9.equip
	local v_u_13 = assert(v12, "TwistOfFateClient.start: config.equip is required")
	local v_u_14 = p9.aimAnimationIds or {}
	local v_u_15 = p9.shootSuccessId
	local v_u_16 = p9.shootFailId
	local v_u_17 = p9.fireCooldown or 1
	local v_u_18 = p9.cameraDelayDuration or 0.5
	local v_u_19 = p9.targetOffset or Vector3.new(2, 0, -5)
	local v_u_20 = p9.smoothSpeed or 8
	local v_u_21 = v_u_4.LocalPlayer
	local v_u_22 = v_u_21.Character or v_u_21.CharacterAdded:Wait()
	local v_u_23 = v_u_22:WaitForChild("HumanoidRootPart")
	local v_u_24 = workspace.CurrentCamera
	local v_u_25 = v_u_22:WaitForChild("Humanoid")
	local v_u_26 = {}
	local v_u_27 = nil
	local v_u_28 = nil
	local function v_u_35()
		v_u_26 = {}
		for _, v29 in ipairs(v_u_14) do
			local v30 = Instance.new("Animation")
			v30.AnimationId = v29
			local v31 = v_u_26
			local v32 = v_u_25
			table.insert(v31, v32:LoadAnimation(v30))
		end
		if v_u_15 then
			local v33 = Instance.new("Animation")
			v33.AnimationId = v_u_15
			v_u_27 = v_u_25:LoadAnimation(v33)
		end
		if v_u_16 then
			local v34 = Instance.new("Animation")
			v34.AnimationId = v_u_16
			v_u_28 = v_u_25:LoadAnimation(v34)
		end
	end
	v_u_35()
	local function v_u_37()
		for _, v36 in ipairs(v_u_26) do
			if not v36.IsPlaying then
				v36:Play()
			end
		end
	end
	local v_u_38 = 0
	local v_u_39 = false
	local v_u_40 = 0
	local v_u_41 = Vector3.new(0, 0, 0)
	local v_u_42 = false
	local v_u_43 = false
	local v_u_44 = false
	local v_u_45 = 0
	local v_u_46 = nil
	local v_u_47 = Color3.fromRGB(77, 77, 77)
	local v_u_48 = Color3.fromRGB(255, 255, 255)
	local v_u_49 = false
	local v_u_50 = {
		["pc"] = {},
		["mob"] = {}
	}
	local v_u_51 = nil
	local function v_u_55(p52, p53)
		if p52 then
			if p52:IsA("ImageLabel") or p52:IsA("ImageButton") then
				p52.ImageColor3 = p53
			end
			local v54 = p52:FindFirstChild("icon")
			if v54 and (v54:IsA("ImageLabel") or v54:IsA("ImageButton")) then
				v54.ImageColor3 = p53
			end
		end
	end
	local function v_u_59()
		local v56 = v_u_49 and v_u_47 or v_u_48
		for _, v57 in ipairs(v_u_50.pc) do
			v_u_55(v57, v56)
		end
		for _, v58 in ipairs(v_u_50.mob) do
			v_u_55(v58, v56)
		end
	end
	local function v_u_62()
		if GodModeEnabled then
			return false
		end
		if v_u_21:GetAttribute("IsDead") then
			return true
		end
		if v_u_22:GetAttribute("IsCarried") then
			return true
		end
		if v_u_22:GetAttribute("IsHooked") then
			return true
		end
		if v_u_23:HasTag("doing action") then
			return true
		end
		local v60 = v_u_22:FindFirstChild("CheckInterractable")
		if v60 then
			for _, v61 in ipairs({
				"isVaulting",
				"isSliding",
				"isDroppingPallet",
				"isRepairing",
				"isHealing",
				"isUnhooking",
				"isExiting"
			}) do
				if v60:GetAttribute(v61) then
					return true
				end
			end
		end
		return false
	end
	local function v_u_80(p63)
		if v_u_44 then
			if v_u_18 > tick() - v_u_45 then
				local v64 = v_u_24.CFrame.LookVector
				local v65 = v_u_23.Position
				local v66 = v_u_23
				local v67 = CFrame.new
				local v68 = v64.X
				local v69 = v64.Z
				v66.CFrame = v67(v65, v65 + Vector3.new(v68, 0, v69).Unit * 900)
				local v70 = -v_u_20 * p63
				v_u_41 = v_u_41:Lerp(v_u_19, 1 - math.exp(v70))
				v_u_24.CFrame = v_u_24.CFrame * CFrame.new(v_u_41)
				return
			end
			v_u_44 = false
			v_u_42 = true
		end
		if v_u_43 then
			local v71 = v_u_24.CFrame.LookVector
			local v72 = v_u_23.Position
			local v73 = v_u_23
			local v74 = CFrame.new
			local v75 = v71.X
			local v76 = v71.Z
			v73.CFrame = v74(v72, v72 + Vector3.new(v75, 0, v76).Unit * 900)
			local v77 = -v_u_20 * p63
			v_u_41 = v_u_41:Lerp(v_u_19, 1 - math.exp(v77))
		elseif v_u_42 then
			local v78 = -v_u_20 * p63
			local v79 = 1 - math.exp(v78)
			v_u_41 = v_u_41:Lerp(Vector3.new(), v79)
			if v_u_41.Magnitude < 0.01 then
				v_u_3:UnbindFromRenderStep("CameraTransition")
				v_u_3:UnbindFromRenderStep("CameraDelay")
				v_u_42 = false
				v_u_41 = Vector3.new()
			end
		end
		v_u_24.CFrame = v_u_24.CFrame * CFrame.new(v_u_41)
	end
	local v_u_81 = nil
	local function v_u_86(p82)
		local v83 = p82 or 1
		v_u_39 = true
		local v84 = v_u_38
		local v85 = tick() + v83
		v_u_38 = math.max(v84, v85)
		v_u_46 = nil
		if v_u_43 or v_u_44 then
			v_u_81(false)
		end
		task.delay(v83, function()
			v_u_39 = false
		end)
	end
	v_u_81 = function(p87, p88)
		if p87 == v_u_43 and not (v_u_42 or v_u_44) then
			return
		elseif p87 or not p88 then
			v_u_43 = p87
			v_u_3:UnbindFromRenderStep("ShiftLock")
			v_u_3:UnbindFromRenderStep("CameraTransition")
			v_u_3:UnbindFromRenderStep("CameraDelay")
			if p87 then
				if not v_u_13.Playing then
					v_u_13:Play()
				end
				v_u_21.Character:SetAttribute("Aiming", true)
				v_u_41 = Vector3.new()
				v_u_42 = false
				v_u_44 = false
				v_u_5:AddTag(v_u_23, "doing action")
				v_u_3:BindToRenderStep("ShiftLock", Enum.RenderPriority.Character.Value, v_u_80)
				v_u_37()
			else
				if v_u_51 then
					v_u_51.Visible = false
				end
				v_u_21.Character:SetAttribute("Aiming", false)
				if v_u_5:HasTag(v_u_23, "doing action") then
					v_u_5:RemoveTag(v_u_23, "doing action")
				end
				v_u_42 = true
				v_u_44 = false
				v_u_3:BindToRenderStep("CameraTransition", Enum.RenderPriority.Character.Value, v_u_80)
				for _, v89 in ipairs(v_u_26) do
					if v89.IsPlaying then
						v89:Stop()
					end
				end
			end
			v_u_25.AutoRotate = not p87
		else
			v_u_43 = false
			if v_u_51 then
				v_u_51.Visible = false
			end
			v_u_21.Character:SetAttribute("Aiming", false)
			if v_u_5:HasTag(v_u_23, "doing action") then
				v_u_5:RemoveTag(v_u_23, "doing action")
			end
			for _, v90 in ipairs(v_u_26) do
				if v90.IsPlaying then
					v90:Stop()
				end
			end
			v_u_25.AutoRotate = true
			v_u_44 = true
			v_u_45 = tick()
		end
	end
	local function v_u_122(p_u_91)
		if p_u_91:IsA("ImageButton") and p_u_91.Name == "Gui-mob" then
			local v92 = v_u_50.mob
			table.insert(v92, p_u_91)
			v_u_59()
			local v93 = p_u_91:FindFirstChild("cancelaim")
			if v93 then
				v_u_51 = v93
				v_u_51.Visible = false
			else
				p_u_91.ChildAdded:Connect(function(p94)
					if p94.Name == "cancelaim" and p94:IsA("ImageButton") then
						v_u_51 = p94
						v_u_51.Visible = false
					end
				end)
			end
			v_u_2.InputBegan:Connect(function(p_u_95)
				if p_u_95.UserInputType == Enum.UserInputType.Touch then
					local v96 = p_u_91.AbsolutePosition
					local v97 = p_u_91.AbsoluteSize
					local v98 = v96.X + v97.X / 2
					local v99 = v96.Y + v97.Y / 2
					local v100 = v97.X
					local v101 = v97.Y
					local v102 = math.min(v100, v101) / 2 * 0.8
					local v103 = p_u_95.Position.X - v98
					local v104 = p_u_95.Position.Y - v99
					if v103 * v103 + v104 * v104 > v102 * v102 then
						return
					elseif not GodModeEnabled and (v_u_62() or v_u_25.Health < v_u_25.MaxHealth * 0.5) then
						return
					elseif tick() - v_u_40 >= v_u_17 then
						local v_u_105 = false
						v_u_46 = v_u_11
						v_u_43 = true
						v_u_3:UnbindFromRenderStep("ShiftLock")
						v_u_3:UnbindFromRenderStep("CameraTransition")
						v_u_3:UnbindFromRenderStep("CameraDelay")
						if not v_u_13.Playing then
							v_u_13:Play()
						end
						v_u_21.Character:SetAttribute("Aiming", true)
						v_u_41 = Vector3.new()
						v_u_42 = false
						v_u_44 = false
						v_u_5:AddTag(v_u_23, "doing action")
						v_u_3:BindToRenderStep("ShiftLock", Enum.RenderPriority.Character.Value, v_u_80)
						v_u_25.AutoRotate = false
						v_u_37()
						if v_u_51 then
							v_u_51.Visible = true
						end
						local v_u_111 = v_u_2.InputChanged:Connect(function(p106)
							if p106 == p_u_95 then
								local v107 = p106.Position
								local v108
								if v_u_51 and v_u_51.Visible then
									local v109 = v_u_51.AbsolutePosition
									local v110 = v_u_51.AbsoluteSize
									if v107.X >= v109.X and (v107.X <= v109.X + v110.X and v107.Y >= v109.Y) then
										v108 = v107.Y <= v109.Y + v110.Y
									else
										v108 = false
									end
								else
									v108 = false
								end
								v_u_105 = v108
							end
						end)
						local v_u_112 = nil
						v_u_112 = v_u_2.InputEnded:Connect(function(p113)
							if p113 == p_u_95 then
								v_u_112:Disconnect()
								v_u_111:Disconnect()
								if v_u_51 then
									v_u_51.Visible = false
								end
								if not v_u_105 then
									local v114 = p113.Position
									local v115
									if v_u_51 and v_u_51.Visible then
										local v116 = v_u_51.AbsolutePosition
										local v117 = v_u_51.AbsoluteSize
										if v114.X >= v116.X and (v114.X <= v116.X + v117.X and v114.Y >= v116.Y) then
											v115 = v114.Y <= v116.Y + v117.Y
										else
											v115 = false
										end
									else
										v115 = false
									end
									if not v115 then
										local v118 = tick()
										if v_u_49 or (v_u_39 or v118 < v_u_38) then
											v_u_21.Character:SetAttribute("Aiming", false)
											if v_u_5:HasTag(v_u_23, "doing action") then
												v_u_5:RemoveTag(v_u_23, "doing action")
											end
											for _, v119 in ipairs(v_u_26) do
												if v119.IsPlaying then
													v119:Stop()
												end
											end
											v_u_43 = false
											v_u_42 = true
											v_u_44 = false
											v_u_3:BindToRenderStep("CameraTransition", Enum.RenderPriority.Character.Value, v_u_80)
											return
										elseif v_u_17 <= v118 - v_u_40 then
											v_u_40 = v118
											local fireDir = v_u_24.CFrame.LookVector
											if AutoAimEnabled then
												local autoDir = getAutoAimDirection(v_u_23.Position)
												if autoDir then
													fireDir = autoDir
												end
											end
											v_u_8:FireServer(v_u_46, fireDir)
											if v_u_27 then
												v_u_27:Play()
											end
											v_u_43 = false
											v_u_21.Character:SetAttribute("Aiming", false)
											if v_u_5:HasTag(v_u_23, "doing action") then
												v_u_5:RemoveTag(v_u_23, "doing action")
											end
											for _, v120 in ipairs(v_u_26) do
												if v120.IsPlaying then
													v120:Stop()
												end
											end
											v_u_25.AutoRotate = true
											v_u_44 = true
											v_u_45 = tick()
										else
											v_u_21.Character:SetAttribute("Aiming", false)
											if v_u_5:HasTag(v_u_23, "doing action") then
												v_u_5:RemoveTag(v_u_23, "doing action")
											end
											for _, v121 in ipairs(v_u_26) do
												if v121.IsPlaying then
													v121:Stop()
												end
											end
											v_u_43 = false
											v_u_42 = true
											v_u_44 = false
											v_u_3:BindToRenderStep("CameraTransition", Enum.RenderPriority.Character.Value, v_u_80)
										end
									end
								end
								v_u_86(0.3)
							end
						end)
					end
				end
			end)
		end
	end
	local function v_u_127(p123)
		local v124 = p123:FindFirstChild("Controls")
		if v124 then
			for _, v125 in ipairs(v124:GetChildren()) do
				v_u_122(v125)
			end
			v124.ChildAdded:Connect(v_u_122)
		else
			p123.ChildAdded:Connect(function(p126)
				if p126.Name == "Controls" then
					v_u_127(p126)
				end
			end)
		end
	end
	v_u_21:WaitForChild("PlayerGui");
	(function()
		local v128 = v_u_21:FindFirstChildOfClass("PlayerGui")
		if v128 then
			local v129 = v128:FindFirstChild("Survivor") or v128:FindFirstChild("Survivor-con")
			if v129 then
				local v130 = v129:FindFirstChild("Gen")
				if v130 then
					local v131 = v130:FindFirstChild("ItemFrame")
					if v131 then
						local v132 = v131:FindFirstChild("Gui")
						if v132 then
							local v133 = v_u_50.pc
							table.insert(v133, v132)
						end
					end
				else
					return
				end
			else
				return
			end
		else
			return
		end
	end)()
	local v134 = v_u_21:FindFirstChildOfClass("PlayerGui")
	if v134 then
		local v135 = v134:FindFirstChild("Survivor-mob")
		if v135 then
			v_u_127(v135)
		else
			v134.ChildAdded:Connect(function(p136)
				if p136.Name == "Survivor-mob" then
					v_u_127(p136)
				end
			end)
		end
	end
	v_u_2.InputBegan:Connect(function(p137, p138)
		if not p138 then
			if p137.UserInputType == Enum.UserInputType.MouseButton2 then
				if v_u_49 then
					return
				end
				if tick() < v_u_38 or v_u_39 then
					return
				end
				if not GodModeEnabled and (v_u_62() or v_u_25.Health < v_u_25.MaxHealth * 0.5) then
					return
				end
				if tick() - v_u_40 < v_u_17 then
					return
				end
				v_u_46 = v_u_11
				v_u_81(true)
			end
			if p137.UserInputType == Enum.UserInputType.Gamepad1 and p137.KeyCode == Enum.KeyCode.ButtonL2 then
				if v_u_49 then
					return
				end
				if tick() < v_u_38 or v_u_39 then
					return
				end
				if not GodModeEnabled and (v_u_62() or v_u_25.Health < v_u_25.MaxHealth * 0.5) then
					return
				end
				if tick() - v_u_40 < v_u_17 then
					return
				end
				v_u_46 = v_u_11
				v_u_81(true)
			end
		end
	end)
	v_u_2.InputBegan:Connect(function(p139, p140)
		if not p140 then
			if p139.UserInputType == Enum.UserInputType.MouseButton1 and (v_u_43 or v_u_44) and v_u_46 then
				if v_u_49 then
					return
				end
				local v141 = tick()
				if v141 < v_u_38 or v_u_39 then
					return
				end
				if v141 - v_u_40 < v_u_17 then
					return
				end
				v_u_40 = v141
				local fireDir = v_u_24.CFrame.LookVector
				if AutoAimEnabled then
					local autoDir = getAutoAimDirection(v_u_23.Position)
					if autoDir then
						fireDir = autoDir
					end
				end
				v_u_8:FireServer(v_u_46, fireDir)
				v_u_81(false, true)
			end
			if p139.UserInputType == Enum.UserInputType.Gamepad1 and (p139.KeyCode == Enum.KeyCode.ButtonR2 and (v_u_43 or v_u_44)) and v_u_46 then
				if v_u_49 then
					return
				end
				local v142 = tick()
				if v142 < v_u_38 or v_u_39 then
					return
				end
				if v142 - v_u_40 < v_u_17 then
					return
				end
				v_u_40 = v142
				local fireDir = v_u_24.CFrame.LookVector
				if AutoAimEnabled then
					local autoDir = getAutoAimDirection(v_u_23.Position)
					if autoDir then
						fireDir = autoDir
					end
				end
				v_u_8:FireServer(v_u_46, fireDir)
				v_u_81(false, true)
			end
		end
	end)
	v_u_2.InputEnded:Connect(function(p143, p144)
		if not p144 then
			if p143.UserInputType == Enum.UserInputType.MouseButton2 and not v_u_44 then
				v_u_81(false)
			end
			if p143.UserInputType == Enum.UserInputType.Gamepad1 and (p143.KeyCode == Enum.KeyCode.ButtonL2 and not v_u_44) then
				v_u_81(false)
			end
		end
	end)
	v_u_25:GetPropertyChangedSignal("Health"):Connect(function()
		if not GodModeEnabled and (v_u_43 or v_u_44) then
			v_u_81(false)
		end
	end)
	v_u_8.OnClientEvent:Connect(function(p145)
		if p145 == "SelfDamage" then
		if v_u_28 then
				v_u_28:Play()
				return
			end
		elseif p145 == "Shoot" and v_u_27 then
			v_u_27:Play()
		end
	end)
	v_u_7.OnClientEvent:Connect(function()
		v_u_86(4)
	end)
	v_u_5:GetInstanceAddedSignal("Silenced"):Connect(function(p146)
		if p146 == v_u_22 then
			v_u_49 = true
			v_u_59()
			if not GodModeEnabled and (v_u_43 or v_u_44) then
				v_u_81(false)
			end
		end
	end)
end
return v6
