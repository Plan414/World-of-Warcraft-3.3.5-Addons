local BestInSlot = unpack(select(2, ...))
BestInSlot:SetDefaultModulePrototype(setmetatable({
  OnEnable = function(self) self:Print("Enabled") end,
  OnDisable = function(self) self:Print("Disabled") end,
  OnInitialize = function(self) self:Print("Initialized") end,
  InitializeZoneDetect = function(self) self:Print("ZoneDetection is not initialized!") end,
}, {__index = BestInSlot}))
BestInSlot = nil