local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Настройки скорости
local defaultSpeed = humanoid.WalkSpeed
local boostedSpeed = 100000 -- например, в 2 раза быстрее обычной (можно изменить)

-- Создаём GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WalkToggleGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 150, 0, 50)
button.Position = UDim2.new(0.5, -75, 0.9, 0)
button.Text = "Ходить вперёд"
button.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
button.TextScaled = true
button.Parent = screenGui

-- Переменная для состояния
local walkingForward = false
local moveConnection

-- Функция движения
local function moveForward()
	if not walkingForward then return end
	if not character or not character:FindFirstChild("HumanoidRootPart") then return end
	local hrp = character.HumanoidRootPart
	local direction = hrp.CFrame.LookVector
	humanoid:Move(direction, false)
end

-- Обновление персонажа после респауна
player.CharacterAdded:Connect(function(char)
	character = char
	humanoid = character:WaitForChild("Humanoid")
	defaultSpeed = humanoid.WalkSpeed
end)

-- Обработка нажатия кнопки
button.MouseButton1Click:Connect(function()
	walkingForward = not walkingForward
	button.Text = walkingForward and "Стоп" or "Ходить вперёд"
	button.BackgroundColor3 = walkingForward and Color3.new(0.8, 0.2, 0.2) or Color3.new(0.2, 0.6, 0.2)

	if walkingForward then
		humanoid.WalkSpeed = boostedSpeed
		moveConnection = RunService.RenderStepped:Connect(moveForward)
	else
		if moveConnection then
			moveConnection:Disconnect()
			moveConnection = nil
		end
		humanoid:Move(Vector3.zero, false)
		humanoid.WalkSpeed = defaultSpeed
	end
end)
