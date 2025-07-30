-- LocalScript (StarterPlayerScripts)

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local runService = game:GetService("RunService")

-- Создаем GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WalkToggleGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 150, 0, 50)
button.Position = UDim2.new(0.5, -75, 0.9, 0)
button.Text = "Ходить вперед"
button.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
button.TextScaled = true
button.Parent = screenGui

-- Переменная для отслеживания состояния
local walkingForward = false
local connection

-- Функция для передвижения
local function moveForward()
	if not walkingForward then return end
	if not character or not character:FindFirstChild("HumanoidRootPart") then return end
	local hrp = character.HumanoidRootPart
	local direction = hrp.CFrame.LookVector
	humanoid:Move(direction, false)
end

-- Обновляем персонажа при респауне
player.CharacterAdded:Connect(function(char)
	character = char
	humanoid = character:WaitForChild("Humanoid")
end)

-- Нажатие на кнопку
button.MouseButton1Click:Connect(function()
	walkingForward = not walkingForward
	button.Text = walkingForward and "Стоп" or "Ходить вперед"
	button.BackgroundColor3 = walkingForward and Color3.new(0.8, 0.2, 0.2) or Color3.new(0.2, 0.6, 0.2)

	if walkingForward then
		connection = runService.RenderStepped:Connect(moveForward)
	else
		if connection then
			connection:Disconnect()
			connection = nil
		end
		humanoid:Move(Vector3.zero, false)
	end
end)
