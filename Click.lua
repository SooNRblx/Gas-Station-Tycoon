local player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local autoFarmActive = false
local remote = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SelfPump")

-- Fonction pour localiser la pompe précisément
local function getPump()
    for _, tycoon in ipairs({"Tycoon1", "Tycoon2", "Tycoon3", "Tycoon4"}) do
        local root = Workspace:FindFirstChild(tycoon)
        if root then
            local p = root:FindFirstChild("Phantom_Forcefrench'sTycoon")
                and root["Phantom_Forcefrench'sTycoon"]:FindFirstChild("Purchased")
                and root["Phantom_Forcefrench'sTycoon"].Purchased:FindFirstChild("Pump")
                and root["Phantom_Forcefrench'sTycoon"].Purchased.Pump:FindFirstChild("FuelPumpSelf")
            if p then return p end
        end
    end
    return nil
end

-- Interface
local sg = Instance.new("ScreenGui", player.PlayerGui)
local btn = Instance.new("TextButton", sg)
btn.Size = UDim2.new(0, 200, 0, 50)
btn.Position = UDim2.new(0.5, -100, 0.2, 0)
btn.Text = "TEST ALL REMOTES: OFF"
btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
btn.TextColor3 = Color3.new(1,1,1)

btn.MouseButton1Click:Connect(function()
    autoFarmActive = not autoFarmActive
    btn.Text = autoFarmActive and "FARMING..." or "OFF"
    btn.BackgroundColor3 = autoFarmActive and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
end)

-- Boucle de test intensif
task.spawn(function()
    while true do
        if autoFarmActive then
            local pump = getPump()
            pcall(function()
                -- On essaie toutes les combinaisons possibles
                remote:FireServer() 
                remote:FireServer(true)
                remote:FireServer(1)
                if pump then
                    remote:FireServer(pump)
                    remote:FireServer(pump.Name)
                    -- Si la HitBox est l'élément déclencheur :
                    if pump:FindFirstChild("HitBox") then
                        remote:FireServer(pump.HitBox)
                    end
                end
            end)
        end
        task.wait(0.1) -- 10 fois par seconde
    end
end)
