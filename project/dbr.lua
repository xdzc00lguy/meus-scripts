local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local PathfindingService = game:GetService("PathfindingService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local rootPart = char:WaitForChild("HumanoidRootPart")

local clip
local colisoes = {}
local function noclip(ativo)
    if ativo then
        for _,v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then
                colisoes[v] = v.CanCollide
            end
        end
        clip = RunService.Heartbeat:Connect(function()
            for _,v in ipairs(char:GetDescendants()) do
                if v:IsA("BasePart") and v.CanCollide then
                    v.CanCollide = false
                end
            end
        end)
    else
        if clip then
            clip:Disconnect()
            clip = nil
        end
        for part,colisao in pairs(colisoes) do
            if part and part.Parent then
                part.CanCollide = colisao
            end
        end
    end
end

local function marcador(destino)
    local marker = Instance.new("Part")
    marker.Parent = workspace
    marker.Name = "Marker"
    marker.Size = Vector3.new(2, 2, 2)
    marker.Shape = Enum.PartType.Ball
    marker.Material = Enum.Material.Neon
    marker.Anchored = true
    marker.Color = Color3.fromRGB(0, 255, 0)
    marker.CanCollide = false
    marker.Position = destino
    return marker
end

local function velocidade(n)
    return (n * (n + 1) / 2) * 100
end

local function voarTS(destino, vel)
    local dest = destino + Vector3.new(0, 25, 0)
    local marker = marcador(destino)
    local vm = vel
    local dist = (dest - rootPart.Position).Magnitude
    local tempo = dist / vm
    local infSubPos = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local ti = TweenInfo.new(tempo, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    local to = {CFrame = CFrame.new(dest)}
    local old = workspace.Gravity
    workspace.Gravity = 0
    rootPart.Velocity = Vector3.new(0, 0, 0)
    noclip(true)
    local subir = TweenService:Create(rootPart, infSubPos, {CFrame = CFrame.new(rootPart.Position + Vector3.new(0, 25, 0))})
    subir:Play()
    subir.Completed:Wait()
    local voar = TweenService:Create(rootPart, ti, to)
    voar:Play()
    voar.Completed:Wait()
    local descer = TweenService:Create(rootPart, infSubPos, {CFrame = CFrame.new(rootPart.Position + Vector3.new(0, -20, 0))})
    descer:Play()
    descer.Completed:Wait()
    noclip(false)
    rootPart.Velocity = Vector3.new(0, 0, 0)
    workspace.Gravity = old
    marker:Destroy()
end

local function voarCF(destino, vel)
    local dest = destino + Vector3.new(0, 25, 0)
    local vm = vel
    local marker = marcador(dest)
    rootPart.CFrame *= CFrame.new(0, 25, 0)
    rootPart.Anchored = true
    local event = Instance.new("BindableEvent")
    local conn; conn = RunService.Heartbeat:Connect(function(tempo)
        if not hum or not hum.Parent then
            conn:Disconnect()
            conn = nil
            rootPart.Anchored = false
            event:Fire()
            marker:Destroy()
            return
        end
        local vetorDistancia = dest - rootPart.Position
        local distancia = vetorDistancia.Magnitude
        if distancia <= 3 then
            conn:Disconnect()
            conn = nil
            rootPart.Anchored = false
            rootPart.CFrame = CFrame.new(dest)
            rootPart.Velocity = Vector3.new(0, 0, 0)
            event:Fire()
            marker:Destroy()
            return
        end
        rootPart.Velocity = Vector3.new(0, 0, 0)
        rootPart.Anchored = true
        local direcao = vetorDistancia.Unit
        local novaPos = rootPart.Position + (direcao * vm * tempo)
        rootPart.CFrame = CFrame.new(novaPos, dest)
        rootPart.Anchored = false
    end)
    return { Completed = event.Event }
end

local function esp(part, texto, cor)
    local BillboardGui = Instance.new("BillboardGui")
    local TextLabel = Instance.new("TextLabel")
    BillboardGui.Parent = part
    BillboardGui.Size = UDim2.new(0, 50, 0, 50)
    BillboardGui.Name = "ESP"
    BillboardGui.AlwaysOnTop = true
    BillboardGui.StudsOffset = Vector3.new(0, 2, 0)
    TextLabel.Parent = BillboardGui
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.Text = texto
    TextLabel.TextColor3 = cor
    TextLabel.BackgroundTransparency = 1
    return BillboardGui
end

local function criarPath(destino)
    local path = PathfindingService:CreatePath({
        AgentRadius = 4,
        AgentHeight = 5,
        AgentCanJump = true,
        AgentCanClimb = true,
        WaypointSpacing = 10,
        Costs = {
            Normal = 1,
            Perigo = 100
        }
    })
    path:ComputeAsync(rootPart.Position, destino)
    return path
end

local function andar(destino)
    local path = criarPath(destino)
    local ultimaPos = rootPart.Position
    local tempo = 0
    local waypoints = path:GetWaypoints()
    local waypoint = 1
    while waypoint <= #waypoints do
        local wp = waypoints[waypoint]
        if wp.Action == Enum.PathWaypointAction.Jump then
            hum.Jump = true
        end
        hum:MoveTo(wp.Position)
        local chegou = hum.MoveToFinished:Wait()
        if chegou then
            waypoint += 1
        end
        local posAtual = rootPart.Position
        local distancia = (ultimaPos - posAtual).Magnitude
        if distancia <= 5 then
            tempo += 1
        end
        if tempo >= 3 then
            tempo = 0
            path:ComputeAsync(rootPart.Position, destino)
            waypoints = path:GetWaypoints()
            waypoint = 1
        end
        ultimaPos = rootPart.Position
    end
end

local function detectPlayers()
    for _,v in ipairs(Players:GetPlayers()) do
        if v.UserId ~= lp.UserId then
            if v.Character or v.CharacterAdded:Wait() then
                local head = v.Character.Head
                local espD = head:FindFirstChild("ESP")
                if head and not espD then
                    esp(head, v.DisplayName, Color3.fromRGB(255,0,255))
                end
            end
        end
    end
end

local Window = Rayfield:CreateWindow({
   Name = "Dragon Ball Rage HUB",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Dragon Ball Rage HUB",
   LoadingSubtitle = "by aikoDev",
   ShowText = "HUB", -- for mobile users to unhide Rayfield, change if you'd like
   Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   ToggleUIKeybind = "K", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from emitting warnings when the script has a version mismatch with the interface.

   -- ScriptID = "sid_xxxxxxxxxxxx", -- Your Script ID from developer.sirius.menu — enables analytics, managed keys, and script hosting
})

local MainTab = Window:CreateTab("Config", 4483362458) -- Title, Image

local VisualSection = MainTab:CreateSection("Visual")

local EspButton = MainTab:CreateButton({
   Name = "Ativar ESP",
   Callback = function()
    detectPlayers()
   end,
})

local PlayerSection = MainTab:CreateSection("Player")

local NoclipToggle = MainTab:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Flag = "noclip", -- A flag is the identifier for the configuration file; make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
    noclip(Value)
    local info = string.format("A função noclip está abilitado como: %s", tostring(Value))
    Rayfield:Notify({
        Title = "Noclip",
        Content = info,
        Duration = 6.5,
        Image = 4483362458,
    })
   end,
})

local FlySection = MainTab:CreateSection("Fly Config")

local FlySpeed = velocidade(1)
local FlyType = "Tween"

local FlySlider = MainTab:CreateSlider({
   Name = "Velocidade",
   Range = {0, 8},
   Increment = 1,
   Suffix = "Fly Config",
   CurrentValue = 1,
   Flag = "FlyConfig", -- A flag is the identifier for the configuration file; make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
    FlySpeed = velocidade(Value)
   end,
})

local FlyDropdown = MainTab:CreateDropdown({
   Name = "Tipo de voo",
   Options = {"Tween", "CFrame"},
   CurrentOption = nil,
   MultipleOptions = false,
   Flag = "FlyConfig", -- A flag is the identifier for the configuration file; make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Options)
    FlyType = tostring(Options)
   end,
})

local AutoTab = Window:CreateTab("Auto", 4483362458) -- Title, Image

local AutoSection = AutoTab:CreateSection("Auto Farm")

local farm
local detect = false
local EsferaToggle = AutoTab:CreateToggle({
   Name = "Auto Farm Esferas",
   CurrentValue = false,
   Flag = "Farm", -- A flag is the identifier for the configuration file; make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
    if Value == true then
        farm = RunService.Heartbeat:Connect(function()
            for _,v in ipairs(workspace.Map:GetChildren()) do
                if v:IsA("Model") and v.Name ~= "Pedestal" then
                    local prompt = v:FindFirstChild("ProximityPrompt", true)
                    local esfera = v:GetAttribute("BallNum")
                    local espD = v:FindFirstChild("ESP", true)
                    local numero = string.format("Esfera %s", tostring(esfera))
                    if prompt and esfera and not espD then
                        if detect then return end
                        detect = true
                        esp(v, numero, Color3.fromRGB(0,255,0))
                        if FlyType == "Tween" then
                            voarTS(v:GetPivot().Position, FlySpeed)
                        else
                            noclip(true)
                            voarCF(v:GetPivot().Position, FlySpeed).Completed:Wait()
                            noclip(false)
                        end
                        task.wait(1)
                        fireproximityprompt(prompt)
                        if farm then farm:Disconnect() end
                        farm = nil
                        detect = false
                    end
                end
            end
        end)
    end
   end,
})