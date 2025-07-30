local button = script.Parent
local player = game:GetService("Players").LocalPlayer
local UserInputService = game:GetService("UserInputService")

local isMoving = false

-- Движение персонажа
local function moveForward()
	local character = player.Character
	if character and character:FindFirstChild("Humanoid") and character:FindFirstChild("HumanoidRootPart") then
		local humanoid = character:FindFirstChild("Humanoid")
		-- Двигаем вперёд
		humanoid:Move(Vector3.new(0, 0, -1), true)
	end
end

-- Обновление каждый кадр, пока зажата кнопка
game:GetService("RunService").RenderStepped:Connect(function()
	if isMoving then
		moveForward()
	end
end)

-- Когда нажали на кнопку
button.MouseButton1Down:Connect(function()
	isMoving = true
end)

-- Когда отпустили кнопку
button.MouseButton1Up:Connect(function()
	isMoving = false
end)
