-- 1. SERVICES
local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- Nettoyage
if playerGui:FindFirstChild("PumpAutoFarmGui") then
    playerGui.PumpAutoFarmGui:Destroy()
end

-- 2. VARIABLES
local autoFarmActive = false
local antiAfkActive = false
local walkSpeedValue = 16
local farmWaitTime = 0.5 -- Vitesse par défaut plus rapide

-- FONCTION DE RECHERCHE GLOBALE ET MODIFICATION
local function interactWithHitbox()
    -- On cherche dans TOUT le Workspace de manière récursive
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name == "HitBox" and obj:IsA("BasePart") then
            local prompt = obj:FindFirstChildOfClass("ProximityPrompt")
            if prompt then
                -- MODIFICATION : Met la durée à 0 pour un clic instantané
                if prompt.HoldDuration ~= 0 then
                    prompt.HoldDuration = 0
                end
                
                -- ACTION : Simule le clic
                prompt:InputHoldBegin()
                prompt:InputHoldEnd()
                -- On peut s'arrêter après en avoir trouvé un pour optimiser, 
                -- ou continuer si plusieurs pompes existent.
            end
        end
    end
end

-- 3. INTERFACE (RECONSTRUITE POUR ÊTRE FONCTIONNELLE)
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "PumpAutoFarmGui"
screenGui.ResetOnSpawn = false

local logo = Instance.new("TextButton", screenGui)
logo.Size = UDim2.new(0, 60, 0, 60)
logo.Position = UDim2.new(0, 20, 0, 150)
logo.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
logo.Text = "⚡"
logo.TextColor3 = Color3.new(1, 1, 1)
logo.TextSize = 35
Instance.new("UICorner", logo).CornerRadius = UDim.new(0, 12)

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 300, 0, 250)
frame.Position = UDim2.new(0.5, -150, 0.5, -125)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Visible = false
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

-- Header & Close
local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0, 30, 0, 30)
close.Position = UDim2.new(1, -35, 0, 5)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
close.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", close)

-- Titre
local t = Instance.new("TextLabel", frame)
t.Size = UDim2.new(1, 0, 0, 40)
t.Text = "Auto Clicker Universal"
t.TextColor3 = Color3.new(1, 1, 1)
t.BackgroundTransparency = 1
t.Font = Enum.Font.GothamBold

-- Bouton ON/OFF
local btnAF = Instance.new("TextButton", frame)
btnAF.Size = UDim2.new(0, 200, 0, 50)
btnAF.Position = UDim2.new(0.5, -100, 0, 60)
btnAF.Text = "AUTO CLICK : OFF"
btnAF.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
btnAF.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", btnAF)

-- Slider Speed Label
local labelFS = Instance.new("TextLabel", frame)
labelFS.Size = UDim2.new(0, 200, 0, 20)
labelFS.Position = UDim2.new(0.5, -100, 0, 130)
labelFS.Text = "Vitesse: 0.50s"
labelFS.TextColor3 = Color3.new(1, 1, 1)
labelFS.BackgroundTransparency = 1

-- Bouton WalkSpeed (Simple Toggle pour test)
local btnWS = Instance.new("TextButton", frame)
btnWS.Size = UDim2.new(0, 200, 0, 40)
btnWS.Position = UDim2.new(0.5, -100, 0, 170)
btnWS.Text = "Vitesse Perso: OFF"
btnWS.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
btnWS.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", btnWS)

-- 4. LOGIQUE D'OUVERTURE
logo.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

close.MouseButton1Click:Connect(function()
    frame.Visible = false
end)

-- 5. LOGIQUE DES FONCTIONS
btnAF.MouseButton1Click:Connect(function()
    autoFarmActive = not autoFarmActive
    btnAF.Text = autoFarmActive and "AUTO CLICK : ON" or "AUTO CLICK : OFF"
    btnAF.BackgroundColor3 = autoFarmActive and Color3.fromRGB(40, 160, 40) or Color3.fromRGB(60, 60, 60)
end)

local wsActive = false
btnWS.MouseButton1Click:Connect(function()
    wsActive = not wsActive
    walkSpeedValue = wsActive and 100 or 16
    btnWS.Text = wsActive and "Vitesse Perso: ON" or "Vitesse Perso: OFF"
end)

-- 6. DRAG SYSTEM
local dragging, dragStart, startPos
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true dragStart = input.Position startPos = frame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function() dragging = false end)

-- 7. BOUCLES DE FONCTIONNEMENT
RunService.Stepped:Connect(function()
    pcall(function()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = walkSpeedValue
        end
    end)
end)

task.spawn(function()
    while true do
        if autoFarmActive then
            pcall(interactWithHitbox)
            task.wait(farmWaitTime)
        else
            task.wait(0.5)
        end
    end
end)

print("Script chargé ! Cliquez sur l'éclair pour ouvrir.")
