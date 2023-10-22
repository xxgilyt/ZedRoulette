local function generateRandomReward()
  local randomChance = ZombRand(100) + 1
  if randomChance >= SandboxVars.ZedRoulette.chanceToRoulette then
      return nil
  end


  local inputString = SandboxVars.ZedRoulette.rewardsList
  local rewardsList = {}
  -- Divide la entrada en partes usando el delimitador ";"
  for pair in inputString:gmatch("([^;]+)") do
      -- Divide cada par de nombre y probabilidad usando el delimitador "|"
      local name, probability = pair:match("name=([^|]+)|probability=(%d+)")
      
      if name and probability then
          table.insert(rewardsList, {name = name, probability = tonumber(probability)})
      end
  end

  local totalProbability = 0
  for _, reward in ipairs(rewardsList) do
    totalProbability = totalProbability + reward.probability
  end

  local randomProbability = ZombRand(totalProbability)+1
  local reward = nil
  -- Recorre la lista de recompensas y resta la probabilidad de cada una hasta que sea menor o igual a 0
  -- Ejemplo: Si el numero inicial es 20 y la probabilidad del primer item es 10, se resta 10 y queda 10 por lo tanto no es menor o igual a 0
  for _, rewardItem in ipairs(rewardsList) do
      randomProbability = randomProbability - rewardItem.probability
      if randomProbability <= 0 then
          reward = rewardItem.name
          break
      end
  end
  
  return reward
end

local function onZombieKill(zombie)
  local reward = generateRandomReward()
  if reward then
    local item = ScriptManager.instance:FindItem(reward)
    local player = getPlayer()
    if item then
      player:Say("¡Encontraste un(a) " .. item:getDisplayName() .. " en el zombie!")
      player:getInventory():AddItem(reward)
      -- player:getInventory():AddItems(item:Type(), 1) -> Si quieres agregar más de un item
    else
      player:Say("!Ocurrió un error al encontrar el item! Informa a un administrador.")
    end
  end
end

Events.OnZombieDead.Add(onZombieKill)