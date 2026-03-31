-- 1. SERVICES
local player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Nettoyage
if player.PlayerGui:FindFirstChild("RemoteFarmGui") then
    player.PlayerGui.RemoteFarmGui:Destroy()
end

-- 2. VARIABLES
local autoFarmActive = false
local walkSpeedValue = 16

-- Chemin vers le RemoteEvent que tu as trouvé
local remotePath = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SelfPump")

-- 3. INTERFACE SIMPLE
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
screenGui.Name = "RemoteFarmGui"
screenGui.ResetOnSpawn = false

local btn = Instance.new("TextButton", screenGui)
btn.Size = UDim2.new(0, 200, 0, 50)
btn.Position = UDim2.new(0.5, -100, 0.1, 0)
btn.Text = "REMOTE FARM: OFF"
btn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
btn.TextColor3 = Color3.new(1, 1, 1)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 16
Instance.new("UICorner", btn)

-- Rendre le bouton déplaçable
local dragging, dragStart, startPos
btn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true dragStart = input.Position startPos = btn.Position
    end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
game:GetService("UserInputService").InputEnded:Connect(function() dragging = false end)

-- 4. LOGIQUE DU BOUTON
btn.MouseButton1Click:Connect(function()
    autoFarmActive = not autoFarmActive
    btn.Text = autoFarmActive and "REMOTE FARM: ON" or "REMOTE FARM: OFF"
    btn.BackgroundColor3 = autoFarmActive and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
end)

-- 5. BOUCLE DE FARM (ENVOI DU SIGNAL)
task.spawn(function()
    while true do
        if autoFarmActive then
            -- On envoie le signal directement au serveur
            -- Parfois le serveur attend des arguments (ex: le nom de la pompe), 
            -- on commence par envoyer vide.
            pcall(function()
                remotePath:FireServer()
            end)
        end
        task.wait(0.1) -- Vitesse d'envoi (0.1s = très rapide)
    end
end)

-- Walkspeed toujours actif
RunService.Stepped:Connect(function()
    pcall(function()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = walkSpeedValue
        end
    end)
end)

print("Script à distance chargé ! Remote utilisé : Events.SelfPump")
