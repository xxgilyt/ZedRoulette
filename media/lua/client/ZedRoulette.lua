local function generateRandomReward()
  local randomChance = ZombRand(100) + 1
  if randomChance >= SandboxVars.ZedRoulette.chanceToRoulette then
      return nil
  end

  local inputString = SandboxVars.ZedRoulette.rewardsList
  local rewardsList = {}
  -- Divide la entrada en partes usando el delimitador ";"
  for pair in inputString:gmatch("([^;]+)") do
      -- Divide cada par de nombre, probabilidad y cantidad usando el delimitador "|"
      local name, probability, amounts = pair:match("name=([^|]+)|probability=(%d+)|amounts=(%d+)")
      
      if name and probability and amounts then
          table.insert(rewardsList, {name = name, probability = tonumber(probability), amounts = tonumber(amounts)})
      end
  end

  local totalProbability = 0
  for _, reward in ipairs(rewardsList) do
    totalProbability = totalProbability + reward.probability
  end

  local randomProbability = ZombRand(totalProbability) + 1
  local reward = nil
  local amount = nil
  -- Recorre la lista de recompensas y resta la probabilidad de cada una hasta que sea menor o igual a 0
  for _, rewardItem in ipairs(rewardsList) do
      randomProbability = randomProbability - rewardItem.probability
      if randomProbability <= 0 then
          reward = rewardItem.name
          amount = rewardItem.amounts
          break
      end
  end
  return {rewardName = reward, rewardAmount = amount}
end

local function onZombieKill(zombie)
  local reward = generateRandomReward()
  if reward then
    local item = ScriptManager.instance:FindItem(reward.rewardName)
    local player = getPlayer()
    if item then
      player:Say("¡Waos un(a) " .. item:getDisplayName() .. " en el zombie!")
      player:getInventory():AddItems(reward.rewardName,reward.rewardAmount)
    else
      player:Say("¡Ocurrió un error al encontrar el item! Informa a un administrador.")
    end
  end
end

Events.OnZombieDead.Add(onZombieKill)