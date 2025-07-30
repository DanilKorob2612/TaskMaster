
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local runService = game:GetService("RunService")

-- Дождаться загрузки персонажа
local function onCharacterAdded(character)
	local humanoid = character:WaitForChild("Humanoid")
	local rootPart = character:WaitForChild("HumanoidRootPart")

	runService.RenderStepped:Connect(function()
		-- Перемещение вперёд по направлению взгляда
		local moveDirection = humanoid.MoveDirection
		if moveDirection.Magnitude == 0 then
			humanoid:Move(Vector3.new(0, 0, -1), true)
		end
	end)
end

if player.Character then
	onCharacterAdded(player.Character)
end

player.CharacterAdded:Connect(onCharacterAdded)