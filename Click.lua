-- 1. SERVICES
local player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- 2. VARIABLES
local autoFarmActive = false
local remote = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SelfPump")

-- Fonction pour trouver l'objet de la pompe (le modèle)
local function getPumpObject()
    for _, name in ipairs({"Tycoon1", "Tycoon2", "Tycoon3", "Tycoon4"}) do
        local t = Workspace:FindFirstChild(name)
        if t then
            local pump = t:FindFirstChild("Phantom_Forcefrench'sTycoon") 
                and t["Phantom_Forcefrench'sTycoon"]:FindFirstChild("Purchased")
                and t["Phantom_Forcefrench'sTycoon"].Purchased:FindFirstChild("Pump")
                and t["Phantom_Forcefrench'sTycoon"].Purchased.Pump:FindFirstChild("FuelPumpSelf")
            if pump then return pump end
        end
    end
    return nil
end

-- 3. INTERFACE
local sg = Instance.new("ScreenGui", player.PlayerGui)
sg.Name = "UltraFarm"

local btn = Instance.new("TextButton", sg)
btn.Size = UDim2.new(0, 200, 0, 50)
btn.Position = UDim2.new(0.5, -100, 0.2, 0)
btn.Text = "FORCE REMOTE: OFF"
btn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
btn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", btn)

btn.MouseButton1Click:Connect(function()
    autoFarmActive = not autoFarmActive
    btn.Text = autoFarmActive and "FORCE REMOTE: ON" or "FORCE REMOTE: OFF"
    btn.BackgroundColor3 = autoFarmActive and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(80, 0, 0)
end)

-- 4. BOUCLE DE FARM
task.spawn(function()
    while true do
        if autoFarmActive then
            local pumpObj = getPumpObject()
            
            pcall(function()
                -- On teste les 3 façons courantes dont les remotes reçoivent des ordres :
                remote:FireServer() -- Vide
                if pumpObj then
                    remote:FireServer(pumpObj) -- Avec l'objet modèle
                    remote:FireServer(pumpObj.Name) -- Avec le nom "FuelPumpSelf"
                end
            end)
        end
        task.wait(0.1)
    end
end)
