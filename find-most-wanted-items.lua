local Player = game.Players.LocalPlayer
local PlayerScripts = Player.PlayerScripts
local ReplicatedStorage = game.ReplicatedStorage

local UpdateNPCCard = getsenv(PlayerScripts.NPCRender).UpdateNPCCard
local Functions = require(ReplicatedStorage.Functions)
local Remotes = ReplicatedStorage.Remotes

local function getPlayerPlot(playerNameOrChar)
  local player
  if typeof(playerNameOrChar) == "Instance" then
    player = playerNameOrChar
  else
    player = game.Players:FindFirstChild(playerNameOrChar).Character
  end
  if not player then
    return
  end
  local plot = Functions.CharPlot(player)
  return plot
end

-- remove text censoring by preventing to invoke the function that sensor text
local old_FilterTextInvokeServer
old_FilterTextInvokeServer = hookfunction(Remotes.FilterText.InvokeServer, function (self, ...)
  local args = {...}
  local text = args[1]

  -- wait an random amount of time to simulate an remote firing delay
  wait(math.random() * 0.5)
  return text
end)

-- allow text to be however long as you want. this hack work by checking if the param are the one used by the function when it censor text in the game source code
-- self is the text to be subscrtacted, and the other params are the ones used by the function when it censor text
-- 1 used as second param is called when censoring is done
-- 100 used as third param is called when censoring is done
-- here is how the game remove extra text:
-- local v11 = l__Frame__10.MainPanel.Frame.TextBox.Text:sub(1, 100);
local old_rbx_string_sub
old_rbx_string_sub = hookfunction(getrenv().string.sub, function (self, start, finish)
  if start == 1 and finish == 100 then
    return self
  end
  return old_rbx_string_sub(self, start, finish)
end)

-- continue the unlimited string lenght hack by hooking string.len.
-- this hack work by checking if the param are the one used by the function
-- the game check like this according to the decompilation of the game:
-- if p26 == "Text" and string.len(l__Frame__10.MainPanel.Frame.TextBox.Text) > 100 then
local old_rbx_string_len
old_rbx_string_len = hookfunction(getrenv().string.len, function (self)
  if string.len(self) > 100 then
    return 100
  else
    return old_rbx_string_len(self)
  end
end)