local module = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage.Remotes
local Bindables = ReplicatedStorage.Bindables

-- Show a popup notification using the 
function module.popupNotification(message, confirmButtonText)
  return Bindables.PopupNotification:Fire(message, confirmButtonText)
end

function module.popupNotificationYield(message, confirmButtonText)
  return Bindables.PopupNotificationYield:Invoke(message, confirmButtonText)
end

function module.popupTextInput(message, submitText, cancelText)
  return Bindables.PopupTextInput:Invoke(message, submitText, cancelText)
end

function module.popupTextFilteredInput(message, submitText, cancelText, cancelText, filter)
  return Bindables.PopupTextFilteredInput:Invoke(message, submitText, cancelText, filter)
end

return module