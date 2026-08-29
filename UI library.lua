-- [[ AUTO COPY ALL REMOTE PATHS TO CLIPBOARD ]]
-- Scan seluruh RemoteEvent & RemoteFunction di game,
-- lalu copy semua path lengkap ke clipboard (dipisah newline).

local function getAllRemotePaths()
    local paths = {}
    local function scan(obj)
        for _, child in pairs(obj:GetChildren()) do
            if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                table.insert(paths, child:GetFullName())
            end
            scan(child)
        end
    end
    scan(game)
    return paths
end

local allPaths = getAllRemotePaths()
local combined = table.concat(allPaths, "\n")

-- Copy ke clipboard
pcall(function()
    if setclipboard then
        setclipboard(combined)
        print("✅ " .. #allPaths .. " remote path disalin ke clipboard!")
    elseif toclipboard then
        toclipboard(combined)
        print("✅ " .. #allPaths .. " remote path disalin ke clipboard!")
    else
        print("⚠️ Clipboard tidak support, tapi daftar ada di console.")
    end
end)

-- Tampilkan di console (untuk berjaga-jaga)
print("========== DAFTAR REMOTE PATHS ==========")
for i, p in ipairs(allPaths) do
    print(i .. ". " .. p)
end
print("========== TOTAL: " .. #allPaths .. " ==========")

-- Jika kamu juga mau GUI untuk browsing, aktifkan bagian ini (opsional)
-- Tapi karena kamu minta auto copy, script di atas sudah cukup.
