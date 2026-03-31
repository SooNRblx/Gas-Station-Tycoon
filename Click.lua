-- 1. SERVICES
local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- Nettoyage
if playerGui:FindFirstChild("AppleAutoFarmGui") then
    playerGui.AppleAutoFarmGui:Destroy()
end

-- 2. VARIABLES
local autoFarmActive = false
local antiAfkActive = false
local walkSpeedValue = 16
local jumpPowerValue = 50
local farmWaitTime = 1.0

-- Liste des Tycoons possibles pour la recherche
local tycoonNames = {"Tycoon1", "Tycoon2", "Tycoon3", "Tycoon4"}

-- Fonction pour trouver et activer le ProximityPrompt
local function interactWithPump()
    for _, name in ipairs(tycoonNames) do
        local tycoon = Workspace:FindFirstChild(name)
        if tycoon then
            -- On suit l'arborescence demandée
            local folder1 = tycoon:FindFirstChild("Phantom_Forcefrench'sTycoon")
            local purchased = folder1 and folder1:FindFirstChild("Purchased")
            local pumpFolder = purchased and purchased:FindFirstChild("Pump")
            local pumpModel = pumpFolder and pumpFolder:FindFirstChild("FuelPumpSelf")
            local hitBox = pumpModel and pumpModel:FindFirstChild("HitBox")
            
            if hitBox then
                local prompt = hitBox:FindFirstChildOfClass("ProximityPrompt")
                if prompt then
                    -- Simule l'interaction (Appui maintenu si nécessaire)
                    prompt:InputHoldBegin()
                    task.wait(prompt.HoldDuration)
                    prompt:InputHoldEnd()
                    return true
                end
            end
        end
    end
    return false
end

-- 3. INTERFACE (CONSERVÉE)
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "AppleAutoFarmGui"
screenGui.ResetOnSpawn = false

local logo = Instance.new("TextButton", screenGui)
logo.Size = UDim2.new(0, 60, 0, 60)
logo.Position = UDim2.new(0, 20, 0, 150)
logo.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
logo.Text = "🍎"
logo.TextSize = 35
Instance.new("UICorner", logo).CornerRadius = UDim.new(0, 12)

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 350, 0, 300)
frame.Position = UDim2.new(0.5, -175, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Visible = false
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

-- [Le reste du code de l'interface (Header, Scroll, Sliders) est conservé pour le design]
-- ... (Header, farmSection, moveSection, etc. créés ici) ...

-- (Note : J'ai raccourci visuellement ici pour la clarté, mais gardez votre bloc d'UI original)
-- [REPRISE DU CODE LOGIQUE DES SLIDERS ET BOUTONS]

-- 4. LOGIQUE DE DRAG ET SLIDERS (Simplifiée pour l'exemple, gardez la vôtre)
local function makeDraggable(obj, target)
    target = target or obj
    local dragging, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true dragStart = input.Position startPos = target.Position
        end
    end)
    obj.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    obj.InputEnded:Connect(function() dragging = false end)
end

makeDraggable(logo)
makeDraggable(frame)

-- 5. LOGIQUE DE FONCTIONNEMENT
btnAF.MouseButton1Click:Connect(function()
    autoFarmActive = not autoFarmActive
    btnAF.Text = autoFarmActive and "ON" or "OFF"
    btnAF.BackgroundColor3 = autoFarmActive and Color3.fromRGB(40, 160, 40) or Color3.fromRGB(80, 80, 80)
end)

-- BOUCLE DE FARM MODIFIÉE (SANS TP)
task.spawn(function()
    while true do
        if autoFarmActive then
            pcall(function()
                interactWithPump()
            end)
            task.wait(farmWaitTime)
        else 
            task.wait(0.5) 
        end
    end
end)

-- Anti-AFK et Movement (Gardé tel quel)
RunService.Stepped:Connect(function()
    pcall(function()
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = walkSpeedValue
            char.Humanoid.JumpPower = jumpPowerValue
        end
    end)
end)

local vu = game:GetService("VirtualUser")
player.Idled:Connect(function()
    if antiAfkActive then pcall(function() vu:CaptureController() vu:ClickButton2(Vector2.new()) end) end
end)
