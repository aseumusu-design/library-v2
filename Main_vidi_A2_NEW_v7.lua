local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Fungsi untuk membuat seluruh bagian tubuh dan aksesori transparan
local function makeInvisible()
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
            -- Menyembunyikan bayangan agar tidak ketahuan player lain (opsional)
            part.CastShadow = false
        elseif part:IsA("Decal") then
            -- Menghilangkan wajah/decals pada kepala
            part.Transparency = 1
        end
    end
end

-- Jalankan fungsi saat skrip pertama kali dieksekusi
makeInvisible()

-- Menjaga karakter tetap invisible jika character reset atau respawn
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    newChar:WaitForChild("HumanoidRootPart")
    task.wait(0.5) -- Jeda singkat agar semua bagian tubuh termuat sempurna
    makeInvisible()
end)
