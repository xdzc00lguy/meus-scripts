local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local rootPart = char:WaitForChild("HumanoidRootPart")

local clip
local colisoes = {}
local function noclip(ativo)
    if ativo then
        for _,v in ipairs(char:GetChildren()) do
            if v:IsA("BasePart") and v.CanCollide then
                colisoes[v] = v.CanCollide
            end
        end
        clip = RunService.Heartbeat:Connect(function()
            for _,v in ipairs(char:GetChildren()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end)
    else
        if clip then
            clip:Disconnect()
            clip = nil
        end
        for part, colisao in pairs(colisoes) then
            if part and part.Parent then
                part.CanCollide = colisao
            end
        end
        colisoes = {}
    end
end

local function velocidade(n)
    return (n * (n + 1) / 2) * 25
end

local function voarCF(destino, vel)
    local dest = destino + Vector3.new(0, 25, 0)
    local vm = vel
    rootPart.CFrame *= CFrame.new(0, 25, 0)
    rootPart.Anchored = true
    noclip(true)
    task.wait(1)
    local event = Instance.new("BindableEvent")
    local conexao; conexao = RunService.Heartbeat:Connect(function(tempo)
        if not hum or not hum.Parent then
            event:Fire()
            rootPart.Anchored = false
            conexao:Disconnect()
            conexao = nil
            noclip(false)
            return
        end
        local vetorDistancia = destino - rootPart.Position
        local distancia = vetorDistancia.Magnitude
        if distancia <= 3 then
            event:Fire()
            rootPart.Anchored = false
            rootPart.CFrame = CFrame.new(dest)
            rootPart.Velocity = Vector3.new(0, 0, 0)
            conexao:Disconnect()
            conexao = nil
            noclip(false)
            return
        end
        rootPart.Velocity = Vector3.new(0, 0, 0)
        rootPart.Anchored = true
        local direcao = vetorDistancia.Unit
        local novaPos = rootPart.Position + (direcao * vm * tempo)
        rootPart.CFrame = CFrame.new(novaPos)
        rootPart.Anchored = false
    end)
    return { Completed = event.Event }
end

local function voarTS(destino, vel)
    local dest = destino + Vector3.new(0, 25, 0)
    local vm = vel
    local dist = (destino - rootPart.Position).Magnitude
    local tempo = dist / vm
    local infSubPos = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local ti = TweenInfo.new(tempo, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    rootPart.Anchored = true
    local subida = TweenService:Create(rootPart, infSubPos, {CFrame = rootPart.CFrame * CFrame.new(0, 25, 0)})
    subida.Completed:Wait()
    local voar = TweenService:Create(rootPart, ti, {CFrame = CFrame.new(dest)})
    voar.Completed:Wait()
    local descida = TweenService:Create(rootPart, infSubPos, {CFrame = rootPart.CFrame * CFrame.new(0, -20, 0)})
    descida.Completed:Wait()
    rootPart.Anchored = false
end