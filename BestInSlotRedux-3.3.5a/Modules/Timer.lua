local unpack, select, time
=     unpack, select, time
local BestInSlot, L = unpack(select(2, ...))
local Timer = BestInSlot:NewModule("Timer")

function Timer:OnInitialize()
  BestInSlot.Timer = self
end

function Timer:NewTimer(interval, func, verifyvalidfunc, timeout, ...)
  local startTime = time()
  local args = {...}
  local timerfunc
  timerfunc = function()
    if not verifyvalidfunc or verifyvalidfunc() then
      func(true, unpack(args))
    elseif timeout and time() > (startTime + timeout) then
      func(false, unpack(args))
    else
      C_Timer.After(interval, timerfunc)
    end
  end
  C_Timer.After(interval, timerfunc)
end