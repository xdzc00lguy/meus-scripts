local Players = game:GetService("Players")

local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local rootPart = char:WaitForChild("HumanoidRootPart")