-- Client-only cosmetic invisibility (local)
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function setLocalInvisible(character, state)
    if not character then return end
    for _, obj in ipairs(character:GetDescendants()) do
        if obj:IsA("BasePart") then
            -- LocalTransparencyModifier = 1 makes it invisible only for this client
            obj.LocalTransparencyModifier = state and 1 or 0
            -- optionally disable local collision feedback (visuals) - doesn't change server physics
            -- obj.LocalTransparencyModifier doesn't change collisions; keep collisions as-is
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = state and 1 or 0
        end
    end

    -- Hide name tag (older games might use BillboardGui under the head)
    local head = character:FindFirstChild("Head")
    if head then
        for _, gui in ipairs(head:GetDescendants()) do
            if gui:IsA("BillboardGui") then
                gui.Enabled = not state
            end
        end
    end
end

local function onCharacterAdded(character)
    -- reapply current state if needed (store state on player)
    local invisible = player:GetAttribute("LocalInvisible")
    if invisible then
        -- wait for parts
        character:WaitForChild("HumanoidRootPart", 5)
        setLocalInvisible(character, true)
    end
end

player.CharacterAdded:Connect(onCharacterAdded)

-- toggle function you can call from your GUI
local function toggleLocalInvis()
    local newState = not player:GetAttribute("LocalInvisible")
    player:SetAttribute("LocalInvisible", newState)
    local char = player.Character
    if char then
        setLocalInvisible(char, newState)
    end
end

-- Example: expose toggleLocalInvis so your GUI (another LocalScript) can call it.
return {
    Toggle = toggleLocalInvis
}
