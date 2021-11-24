-- require modules from the internet. useful for workng with retail-tycoon-lib.lua and UI libs
local function httpRequire(url)
  local scr = game:HttpGet(url, true)
  return loadstring(scr)()
end

local Player = game.Players.LocalPlayer
local PlayerScripts = Player.PlayerScripts
local ReplicatedStorage = game.ReplicatedStorage

local UpdateNPCCard = getsenv(PlayerScripts.NPCRender).UpdateNPCCard
local Functions = require(ReplicatedStorage.Functions)
local Remotes = ReplicatedStorage.Remotes
local gameHelper = httpRequire("https://raw.githubusercontent.com/ViniDalvino/retail-tycoon-2-scripts/master/retail-tycoon-lib.lua")

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
  local fenvScript = debug.getfenv(2).script
  local infoScript = debug.getinfo(2, "S").source
  if infoScript == PlayerScripts.PopupScript or infoScript == PlayerScripts.PopupScript then
    return 100
  end
end)


local activeFilteredTextInputFunc, activeTextInputFunc
for k, v in ipairs(getgc()) do
  if type(v) ~= "function" then continue end
  if islclosure(v) then
    local constants = debug.getconstants(v)
    -- find "ActiveFilteredTextInput" to look out for the censorTextInputFunc
    for k2, v2 in pairs(constants) do
      if v2 == "ActiveFilteredTextInput" then
        activeFilteredTextInputFunc = v
      end
    end
    -- find the "ActiveTextInput" to look out for the activeTextInputFunc
    for k2, v2 in pairs(constants) do
      if v2 == "ActiveTextInput" then
        activeTextInputFunc = v
      end
    end
  end
end

-- hook the function that censor text
hookfunction(activeFilteredTextInputFunc, function (...)
  local args = {...}
  return gameHelper.popupTextInput(table.unpack(args))
end)
print("hooked activeFilteredTextInputFunc 😎")