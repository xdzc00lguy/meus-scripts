local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
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
            for _,v in ipairs(Players:GetPlayers()) do
                if v.UserId ~= lp.UserId then
                    if v.Character or v.CharacterAdded:Wait() then
                        local head = v.Character.head
                        local espD = v:FindFirstChild("ESP")
                        if head and not espD then
                            esp(head, v.DisplayName, ColorEsp)
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
        for _,v in ipairs(Players:GetPlayers()) do
            if v.UserId ~= lp.UserId then
                if v.Character or v.CharacterAdded:Wait() then
                    local head = v.Character.head
                    local espD = v:FindFirstChild("ESP")
                    if espD then
                        espD:Destroy()
                    end
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

local Window = Rayfield:CreateWindow({
   Name = "Projeto Kali",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Projetinho Kali",
   LoadingSubtitle = "by aiko",
   ShowText = "Menu", -- for mobile users to unhide Rayfield, change if you'd like
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

local MainTab = Window:CreateTab("Aba Principal", 4483362458) -- Title, Image

local NoclipSection = MainTab:CreateSection("Principal")

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

local VisualSection = MainTab:CreateSection("Visual")

local EspToggle = MainTab:CreateToggle({
   Name = "ESP Players",
   CurrentValue = false,
   Flag = "EspPlayers", -- A flag is the identifier for the configuration file; make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
    marcarPlayersEsp(Value)
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