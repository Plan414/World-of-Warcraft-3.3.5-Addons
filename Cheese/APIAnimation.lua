local function InitAlphaAnimation(self)
	local target = self.target;
	if ( not target ) then
		target = self:GetRegionParent();
		self.target = target;
	end
	local change = self.change;
	if ( not change ) then
		change = 0;
		self.change = change;
	end
	local frameAlpha = target:GetAlpha();
	self.frameAlpha = frameAlpha;
	self.alphaFactor = frameAlpha + change - frameAlpha;
end

local function TidyAlphaAnimation(self)
	self.alphaFactor = nil;
	self.frameAlpha = nil;
end

function CheeseAlphaTemplate_OnUpdate(self, elapsed)
	local progress = self:GetSmoothProgress();
	if ( progress ~= 0 ) then
		if ( not self.played ) then
			InitAlphaAnimation(self);
			self.played = 1;
		end
		local frameAlpha = self.frameAlpha;
		if ( frameAlpha ) then
			self.target:SetAlpha(frameAlpha + self.alphaFactor * progress);
			if ( progress == 1 ) then
				TidyAlphaAnimation(self);
			end
		end
	end
end

function CheeseAlphaTemplate_OnStop(self)
	if ( self.frameAlpha ) then
		TidyAlphaAnimation(self);
	end
	self.played = nil;
end

CheeseAlphaTemplate_OnFinished = CheeseAlphaTemplate_OnStop;

local function InitScaleAnimation(self)
	local target = self.target;
	if ( not target ) then
		target = self:GetRegionParent();
		self.target = target;
	end
	local scaleX = self.scaleX;
	if ( not scaleX ) then
		scaleX = 0;
		self.scaleX = scaleX;
	end
	local scaleY = self.scaleY;
	if ( not scaleY ) then
		scaleY = 0;
		self.scaleY = scaleY;
	end
	local left, bottom, width, height = target:GetRect();
	if ( not width ) then
		return nil;
	end
	self.frameWidth, self.frameHeight = width, height;
	self.widthFactor, self.heightFactor = width * scaleX - width, height * scaleY - height;
	local parent = target:GetParent();
	local setCenter;
	local numPoints = target:GetNumPoints();
	if ( 1 <= numPoints ) then
		local point, relativeTo, relativePoint, xOffset, yOffset = target:GetPoint(1);
		if ( numPoints == 1 and point == "CENTER" ) then
			setCenter = false;
		else
			local i = 1;
			while true do
				if ( relativeTo ~= parent and yOffset ~= nil ) then
					local k = #self + 1;
					self[k], self[k + 1], self[k + 2], self[k + 3], self[k + 4] = point, relativeTo, relativePoint, xOffset, yOffset;
				end
				i = i + 1;
				if ( i <= numPoints ) then
					point, relativeTo, relativePoint, xOffset, yOffset = target:GetPoint(i);
				else
					break;
				end
			end
			target:ClearAllPoints();
			setCenter = true;
		end
	else
		setCenter = true;
	end
	if ( setCenter ) then
		local x, y = target:GetCenter();
		local parentX, parentY = parent:GetCenter();
		target:SetPoint("CENTER", x - parentX, y - parentY);
	end
	return 1;
end

local function TidyScaleAnimation(self)
	local target = self.target;
	if ( #self ~= 0 ) then
		target:ClearAllPoints();
		for i=1, #self, 5 do
			target:SetPoint(self[i], self[i + 1], self[i + 2], self[i + 3], self[i + 4]);
			self[i], self[i + 1], self[i + 2], self[i + 3], self[i + 4] = nil;
		end
	end
	self.widthFactor, self.heightFactor = nil;
	self.frameWidth, self.frameHeight = nil;
end

function CheeseScaleTemplate_OnUpdate(self, elapsed)
	local progress = self:GetSmoothProgress();
	if ( progress ~= 0 ) then
		if ( not self.played ) then
			if ( InitScaleAnimation(self) ) then
				self.played = 1;
			end
		end
		local frameWidth = self.frameWidth;
		if ( frameWidth ) then
			self.target:SetSize(frameWidth + self.widthFactor * progress, self.frameHeight + self.heightFactor * progress);
			if ( progress == 1 ) then
				TidyScaleAnimation(self);
			end
		end
	end
end

function CheeseScaleTemplate_OnStop(self)
	if ( self.frameWidth ) then
		TidyScaleAnimation(self);
	end
	self.played = nil;
end

CheeseScaleTemplate_OnFinished = CheeseScaleTemplate_OnStop;
