-- 1. SERVICES
local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- Nettoyage des anciennes instances
if playerGui:FindFirstChild("FinalPumpGui") then
    playerGui.FinalPumpGui:Destroy()
end

-- 2. VARIABLES
local autoFarmActive = false
local walkSpeedValue = 16

-- FONCTION DE RECHERCHE ET CLIC FORCÉ
local function forceInteract()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        -- On cherche la HitBox
        if obj.Name == "HitBox" and obj:IsA("BasePart") then
            local prompt = obj:FindFirstChildOfClass("ProximityPrompt")
            if prompt then
                -- 1. On force les paramètres du prompt pour qu'il soit instantané et utilisable de loin
                prompt.HoldDuration = 0
                prompt.MaxActivationDistance = 50 -- Augmente la distance au cas où
                prompt.Enabled = true
                
                -- 2. Tentative de clic avec la fonction spéciale des executeurs
                if fireproximityprompt then
                    fireproximityprompt(prompt)
                else
                    -- Méthode de secours si fireproximityprompt n'est pas supporté
                    prompt:InputHoldBegin()
                    task.wait()
                    prompt:InputHoldEnd()
                end
            end
        end
    end
end

-- 3. INTERFACE ULTRA SIMPLE (POUR ÉVITER LES BUGS)
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "FinalPumpGui"
screenGui.ResetOnSpawn = false

local mainBtn = Instance.new("TextButton", screenGui)
mainBtn.Size = UDim2.new(0, 150, 0, 50)
mainBtn.Position = UDim2.new(0, 20, 0, 200)
mainBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
mainBtn.Text = "FARM: OFF"
mainBtn.TextColor3 = Color3.new(1, 1, 1)
mainBtn.Font = Enum.Font.GothamBold
mainBtn.TextSize = 18
Instance.new("UICorner", mainBtn)

-- 4. LOGIQUE DU BOUTON
mainBtn.MouseButton1Click:Connect(function()
    autoFarmActive = not autoFarmActive
    if autoFarmActive then
        mainBtn.Text = "FARM: ON"
        mainBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    else
        mainBtn.Text = "FARM: OFF"
        mainBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

-- Rendre le bouton déplaçable
local dragging, dragStart, startPos
mainBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true dragStart = input.Position startPos = mainBtn.Position
    end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
game:GetService("UserInputService").InputEnded:Connect(function() dragging = false end)

-- 5. BOUCLE DE FARM (PLUS RAPIDE)
task.spawn(function()
    while true do
        if autoFarmActive then
            pcall(forceInteract)
        end
        task.wait(0.1) -- Attend 0.1 seconde entre chaque tentative de clic
    end
end)

-- Walkspeed (Optionnel, toujours actif pour aider)
RunService.Stepped:Connect(function()
    pcall(function()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = walkSpeedValue
        end
    end)
end)
