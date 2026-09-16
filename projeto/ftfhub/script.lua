local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PathfindingService = game:GetService("PathfindingService")

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
        for part, colisao in pairs(colisoes) do
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
    local oldG = workspace.Gravity
    workspace.Gravity = 0
    local subida = TweenService:Create(rootPart, infSubPos, {CFrame = CFrame.new(rootPart.Position + Vector3.new(0, 25, 0))})
    subida:Play()
    subida.Completed:Wait()
    local voar = TweenService:Create(rootPart, ti, {CFrame = CFrame.new(dest)})
    voar:Play()
    voar.Completed:Wait()
    local descida = TweenService:Create(rootPart, infSubPos, {CFrame = CFrame.new(rootPart.Position + Vector3.new(0, -20, 0))})
    descida:Play()
    descida.Completed:Wait()
    workspace.Gravity = oldG
end

local function esp(part, texto, cor)
    local BillboardGui = Instance.new("BillboardGui")
    local TextLabel = Instance.new("TextLabel")
    BillboardGui.Parent = part
    BillboardGui.AlwaysOnTop = true
    BillboardGui.Size = UDim2.new(0, 50, 0, 50)
    BillboardGui.StudsOffset = Vector3.new(0, 2, 0)
    BillboardGui.Name = "ESP"
    TextLabel.Parent = BillboardGui
    TextLabel.Text = texto
    TextLabel.TextColor3 = cor
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.BackgroundTransparency = 1
    return BillboardGui
end

local function espHighlight(part, cor)
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESPHighlight"
    highlight.OutlineColor = cor
    highlight.FillTransparency = 1
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = part
    return highlight
end

--[[
Configuracoes simples do menu
]]

local FlySpeed = velocidade(1)
local TeleportType = "TeleportInstant"
local ColorEsp = Color3.fromRGB(255, 255, 255)

local espAtivo
local function marcarPlayersEsp(ativo)
    if ativo then
        espAtivo = RunService.Heartbeat:Connect(function()
            for _,v in ipairs(Players:GetChildren()) do
                if v.UserId ~= lp.UserId then
                    if v.Character or v.CharacterAdded:Wait() then
                        local head = v.Character.Head
                        local espDH = v.Character:FindFirstChild("ESPHighlight")
                        local espD = head and head:FindFirstChild("ESP")
                        if head and not espD and not espDH then
                            esp(head, v.DisplayName, ColorEsp)
                            espHighlight(v.Character, ColorEsp)
                        end
                    end
                end
            end
        end)
    else
        if espAtivo then
            espAtivo:Disconnect()
            espAtivo = nil
        end
        for _,v in ipairs(Players:GetChildren()) do
            if v.UserId ~= lp.UserId then
                if v.Character or v.CharacterAdded:Wait() then
                    local head = v.Character.Head
                    local espDH = v.Character:FindFirstChild("ESPHighlight")
                    local espD = head and head:FindFirstChild("ESP")
                    if espD then
                        espD:Destroy()
                        espDH:Destroy()
                    end
                end
            end
        end
    end
end

local detectPcAtivo
local ultimoUpdate = 0
local function detectPc(ativo)
    if ativo then
        detectPcAtivo = RunService.Heartbeat:Connect(function()
            local agora = os.clock()
            if ultimoUpdate and agora - ultimoUpdate < 1 then
                return
            end
            ultimoUpdate = agora
            for _,v in ipairs(workspace:GetDescendants()) do
                if v:IsA("Model") and v.Name == "ComputerTable" then
                    local tela = v:FindFirstChild("Screen")
                    local espD = tela and tela:FindFirstChild("ESP")
                    local espDH = v:FindFirstChild("ESPHighlight")
                    if espD and espDH then
                        local corPc = tela.Color
                        local textL = espD:FindFirstChildOfClass("TextLabel")
                        textL.TextColor3 = corPc
                        espDH.OutlineColor = corPc
                    else
                        local corPc = tela.Color
                        esp(tela, "Computador", corPc)
                        espHighlight(v, corPc)
                    end
                end
            end
        end)
    else
        if detectPcAtivo then
            detectPcAtivo:Disconnect()
            detectPcAtivo = nil
        end
        for _,v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v.Name == "ComputerTable" then
                local tela = v:FindFirstChild("Screen")
                local espD = tela and tela:FindFirstChild("ESP")
                local espDH = v:FindFirstChild("ESPHighlight")
                if espD and espDH then
                    espD:Destroy()
                    espDH:Destroy()
                end
            end
        end
    end
end

local teleportUsuarios = {}
local function detectPlayers()
    table.clear(teleportUsuarios)
    for _,v in ipairs(Players:GetPlayers()) do
        if v.UserId ~= lp.UserId then
            table.insert(teleportUsuarios, tostring(v.DisplayName))
        end
    end
end

local speedAtivo
local oldSpeed = hum.WalkSpeed
local speed = 16
local speedCounter = 0
local function speedHack(ativo)
    if ativo then
        local agora = os.clock()
        speedAtivo = RunService.Heartbeat:Connect(function()
            if speedCounter and agora - speedCounter < 2 then
                return
            end
            speedCounter = agora
            hum.WalkSpeed = speed
        end)
    else
        if speedAtivo then
            speedAtivo:Disconnect()
            speedAtivo = nil
        end
        hum.WalkSpeed = oldSpeed
    end
end

local hackpc
local function hackingpc(ativo)
    if ativo then
        hackpc = RunService.Heartbeat:Connect(function()
            ReplicatedStorage:WaitForChild("RemoteEvent"):FireServer("SetPlayerMinigameResult", true)
        end)
    else
        if hackpc then
            hackpc:Disconnect()
            hackpc = nil
        end
    end
end

local function playerProximo()
    for _,v in ipairs(Players:GetPlayers()) do
        if v.UserId ~= lp.UserId and v.Character then
            local root = v.Character:FindFirstChild("HumanoidRootPart")
            local distancia = (root.Position - rootPart.Position).Magnitude
            if distancia <= 10 then
                return v
            end
        end
    end
end

local auraBeastAtivo
local auraUpdate = 0
local function aurabeast(ativo)
    if ativo then
        auraBeastAtivo = RunService.Heartbeat:Connect(function()
            local agora = os.clock()
            if auraUpdate and agora - auraUpdate < 1 then return end
            auraUpdate = agora
            local plr = playerProximo()
            if plr and plr.Character then
                local torso = plr.Character.Torso
                if torso then
                    char:WaitForChild("Hammer"):WaitForChild("HammerEvent"):FireServer("HammerHit", torso)
                    task.wait(0.5)
                    char:WaitForChild("Hammer"):WaitForChild("HammerEvent"):FireServer("HammerTieUp", torso, torso.Position)
                end
            end
        end)
    else
        if auraBeastAtivo then
            auraBeastAtivo:Disconnect()
            auraBeastAtivo = nil
        end
    end
end

local function criarPath(destino)
    local path = PathfindingService:CriarPath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanClimb = true,
        AgentCanJump = true,
        WaypointSpacing = 10,
        Costs = {
            Porta = 5,
            Janela = 3,
            Ventilacao = 3
        }
        path:ComputeAsync(rootPart.Position, destino)
        return path
    })
end

local function andar(destino)
    local path = criarPath(destino)
    local waypoints = path:GetWaypoints()
    local waypoint = 1
    while waypoint <= #waypoints do
        local wp = waypoints[waypoint]
        if wp.Action == Enum.PathWaypointAction.Jump then
            hum.Jump = true
        end
        if wp.Label == "Porta" then
            hum:MoveTo(wp.Position)
            ReplicatedStorage:WaitForChild("RemoteEvent"):FireServer("Input","Action",true)
            task.wait(5)
        elseif wp.Label == "Ventilacao" then
            hum:MoveTo(wp.Position)
            ReplicatedStorage:WaitForChild("RemoteEvent"):FireServer("Input","Crawl",true)
            task.wait(1)
        else
            hum:MoveTo(wp.Position)
            ReplicatedStorage:WaitForChild("RemoteEvent"):FireServer("Input","Crawl",false)
        end
        local inicio = os.clock()
        local ultimaDistancia = math.huge
        while true do
            task.wait(0.1)
            local distancia = (rootPart.Position - wp.Position).Magnitude
            if distancia < 3 then
                break
            end
            if os.clock() - inicio >= 2 then
                if distancia >= ultimaDistancia - 0.5 then
                    path = criarPath(destino)
                    waypoints = path:GetWaypoints()
                    waypoint = 1
                    break
                end
                inicio = os.clock()
            end
            ultimaDistancia = distancia
        end
        waypoint += 1
    end
end

local Window = Rayfield:CreateWindow({
   Name = "Flee The Facility HUB",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Carregando script HUB",
   LoadingSubtitle = "by aikoDev",
   ShowText = "HUB", -- for mobile users to unhide Rayfield, change if you'd like
   Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   ToggleUIKeybind = "K", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from emitting warnings when the script has a version mismatch with the interface.

   -- ScriptID = "sid_xxxxxxxxxxxx", -- Your Script ID from developer.sirius.menu — enables analytics, managed keys, and script hosting

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "Big Hub"
   }
})

local MainTab = Window:CreateTab("Menu Principal", 4483362458) -- Title, Image

local MainSection = MainTab:CreateSection("Principal")

local SpeedHackSlider = MainTab:CreateSlider({
   Name = "Speed Hack",
   Range = {0, 100},
   Increment = 1,
   Suffix = "Velocidade",
   CurrentValue = 16,
   Flag = "SpeedHackSlider", -- A flag is the identifier for the configuration file; make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
    speed = Value
   end,
})

local SpeedHackToggle = MainTab:CreateToggle({
   Name = "Ativar Speed Hack",
   CurrentValue = false,
   Flag = "SpeedHackToggle", -- A flag is the identifier for the configuration file; make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
    speedHack(Value)
   end,
})

local NoclipToggle = MainTab:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Flag = "Noclip", -- A flag is the identifier for the configuration file; make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
    noclip(Value)
    Rayfield:Notify({
        Title = "Noclip",
        Content = string.format("A função de noclip está habilitado como: %s", tostring(Value)),
        Duration = 6.5,
        Image = 4483362458,
    })
   end,
})

local TpSection = MainTab:CreateSection("Teleport")

local TeleportDropdown = MainTab:CreateDropdown({
   Name = "Teleportar",
   Options = teleportUsuarios,
   CurrentOption = nil,
   MultipleOptions = false,
   Flag = "Teleport", -- A flag is the identifier for the configuration file; make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Options)
    for _,v in ipairs(Players:GetPlayers()) do
        if v.DisplayName == Options[1] then
            if v.Character or v.CharacterAdded:Wait() then
                local root = v.Character:FindFirstChild("HumanoidRootPart")
                if TeleportType == "TeleportBypassTS" then
                    voarTS(root.Position, FlySpeed)
                elseif TeleportType == "TeleportBypassCF" then
                    voarCF(root.Position, FlySpeed)
                elseif TeleportType == "TeleportInstant" then
                    rootPart.CFrame = root.CFrame
                end
            end
        end
    end
   end,
})

local TeleportButton = MainTab:CreateButton({
   Name = "Atualizar lista de usuários",
   Callback = function()
    detectPlayers()
    TeleportDropdown:Refresh(teleportUsuarios)
    Rayfield:Notify({
        Title = "Teleport",
        Content = string.format("A lista de usuários foi atualizada com sucesso!"),
        Duration = 6.5,
        Image = 4483362458,
    })
   end,
})

local BeastSection = MainTab:CreateSection("Besta")

local AuraBeastToggle = MainTab:CreateToggle({
   Name = "Aura Beast",
   CurrentValue = false,
   Flag = "AuraBeastToggle", -- A flag is the identifier for the configuration file; make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
    aurabeast(Value)
   end,
})

local SurvivorSection = MainTab:CreateSection("Sobrevivente")

local HackPcToggle = MainTab:CreateToggle({
   Name = "Hack PC",
   CurrentValue = false,
   Flag = "HackPcToggle", -- A flag is the identifier for the configuration file; make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
    hackingpc(Value)
    Rayfield:Notify({
        Title = "Hack PC",
        Content = string.format("A função hack pc está habilitado como %s", totring(Value)),
        Duration = 6.5,
        Image = 4483362458,
    })
   end,
})

local VisualSection = MainTab:CreateSection("Visual")

local EspToggle = MainTab:CreateToggle({
   Name = "ESP Players",
   CurrentValue = false,
   Flag = "EspPlayers", -- A flag is the identifier for the configuration file; make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
    marcarPlayersEsp(Value)
   end,
})

local DetectPcEspToggle = MainTab:CreateToggle({
   Name = "ESP Pc",
   CurrentValue = false,
   Flag = "EspPc", -- A flag is the identifier for the configuration file; make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
    detectPc(Value)
   end,
})

local ConfigTab = Window:CreateTab("Config", 4483362458) -- Title, Image

local ConfigTpSection = ConfigTab:CreateSection("Configurações do Teleport")

local FlySlider = ConfigTab:CreateSlider({
   Name = "Velocidade de teleport",
   Range = {0, 10},
   Increment = 1,
   Suffix = "Velocidade",
   CurrentValue = 1,
   Flag = "ConfigTpSlider", -- A flag is the identifier for the configuration file; make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
    FlySpeed = velocidade(Value)
   end,
})

local TypeTpDropdown = ConfigTab:CreateDropdown({
   Name = "Tipo de teleport",
   Options = {"TeleportBypassTS", "TeleportBypassCF", "TeleportInstant"},
   CurrentOption = nil,
   MultipleOptions = false,
   Flag = "ConfigTpType", -- A flag is the identifier for the configuration file; make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Options)
    print(Options[1])
    TeleportType = tostring(Options[1])
   end,
})

local EspSection = ConfigTab:CreateSection("Configuração ESP")

local EspColorPicker = ConfigTab:CreateColorPicker({
    Name = "Cor de ESP",
    Color = Color3.fromRGB(255,255,255),
    Flag = "CorESP", -- A flag is the identifier for the configuration file; make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
        ColorEsp = Value
    end
})