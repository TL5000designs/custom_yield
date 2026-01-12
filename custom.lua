local hitGuardRegistry = {}

local function cleanupHitGuard(target)
	local guard = hitGuardRegistry[target]
	if guard then
		if guard.conn then
			guard.conn:Disconnect()
		end
		if guard.died then
			guard.died:Disconnect()
		end
		hitGuardRegistry[target] = nil
		return true
	end
	return false
end

local function enableHitGuard(target)
	if not target then
		return false
	end
	local char = target.Character
	if not char then
		return false
	end
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return false
	end

	cleanupHitGuard(target)

	local guard = {lastHealth = humanoid.Health}
	guard.conn = humanoid.HealthChanged:Connect(function(newHealth)
		if newHealth < guard.lastHealth then
			humanoid.Health = guard.lastHealth
		else
			guard.lastHealth = newHealth
		end
	end)

	guard.died = humanoid.Died:Connect(function()
		cleanupHitGuard(target)
	end)

	hitGuardRegistry[target] = guard
	return true
end

addcmd('hitguard',{'nohit','hitblock'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for _, name in ipairs(players) do
		local player = Players[name]
		if player then
			if hitGuardRegistry[player] then
				cleanupHitGuard(player)
				notify('Hit Guard', player.Name .. ' registers hits normally again')
			else
				if enableHitGuard(player) then
					notify('Hit Guard', player.Name .. ' no  longer registers hits from opponents')
				else
					notify('Hit Guard', 'Could not protect ' .. player.Name)
				end
			end
		end
	end
end)
 
