local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Создание ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ControlGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Создание кнопки
local button = Instance.new("TextButton")
button.Name = "MoveForwardButton"
button.Size = UDim2.new(0, 120, 0, 50)
button.Position = UDim2.new(0, 20, 1, -70) -- снизу слева
button.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
button.TextColor3 = Color3.new(1, 1, 1)
button.TextScaled = true
button.Font = Enum.Font.SourceSansBold
button.Text = "Вперёд"
button.Parent = screenGui

-- Переменная для движения
local isMoving = false

-- Функция движения вперёд
local function moveForward()
	local character = player.Character
	if character and character:FindFirstChild("Humanoid") and character:FindFirstChild("HumanoidRootPart") then
		local humanoid = character:FindFirstChild("Humanoid")
		humanoid:Move(Vector3.new(0, 0, -1), true)
	end
end

-- Обновление каждый кадр
game:GetService("RunService").RenderStepped:Connect(function()
	if isMoving then
		moveForward()
	end
end)

-- События кнопки
button.MouseButton1Down:Connect(function()
	isMoving = true
end)

button.MouseButton1Up:Connect(function()
	isMoving = false
end)
