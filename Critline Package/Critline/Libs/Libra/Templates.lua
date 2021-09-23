local Libra = LibStub("Libra")
local Type, Version = "Frame", 1
if Libra:GetModuleVersion(Type) >= Version then return end

local attributes = {
	size = function(self, value) self:SetSize(value.x, value.y) end,
	anchors = function(self, anchors)
		for i, v in ipairs(anchors) do
			local relativeTo = (v.relativeKey and self:GetParent()[v.relativeKey]) or v.relativeTo or self:GetParent()
			self:SetPoint(v.point, relativeTo, v.relativePoint or v.point, v.x or 0, v.y or 0)
		end
	end,
	keyValues = function(self, value) for k, v in pairs(value) do self[k] = v end end,
	-- animations
	-- name
	parentKey = function(self, value) self:GetParent()[value] = self end,
	parentArray = function(self, value) tinsert(self:GetParent()[value], self) end,
	-- inherits
	mixin = function(self, value) Mixin(self, unpack(value)) end,
	-- secureMixin = function(self, value) Mixin(self, unpack(value)) end,
	-- virtual
	setAllPoints = "SetAllPoints",
	hidden = function(self, value) self:SetShown(not value) end,
	
	scale = "SetScale",
	
	-- Frame
	titleRegion = function(self, value)
		local titleRegion = self:CreateTitleRegion() -- FIX
	end,
	resizeBounds = function(self, value)
		self:SetMinResize(value.minResize.x, value.minResize.y)
		self:SetMaxResize(value.maxResize.x, value.maxResize.y)
	end,
	backdrop = function(self, value)
		self:SetBackdrop({
			bgFile = value.bgFile,
			edgeFile = value.edgeFile,
			edgeSize = value.edgeSize,
			tile = value.tile,
			tileSize = value.tileSize,
			insets = value.insets,
		})
		local color = value.color
		if color then
			self:SetBackdropColor(color.r, color.g, color.b, color.a)
		end
		local borderColor = value.borderColor
		if borderColor then
			self:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
		end
	end,
	hitRectInsets = function(self, value) self:SetHitRectInsets(value.left, value.right, value.top, value.bottom) end,
	-- layers
	-- attributes
	-- frames
	-- scripts
	
	alpha = "SetAlpha",
	parent = "SetParent",
	toplevel = "SetToplevel",
	-- useParentLevel
	movable = "SetMovable",
	resizable = "SetResizable",
	frameStrata = "SetFrameStrata",
	frameLevel = "SetFrameLevel",
	id = "SetID",
	enableMouse = "EnableMouse",
	enableKeyboard = "EnableKeyboard",
	clampedToScreen = "SetClampedToScreen",
	-- protected
	depth = "SetDepth",
	dontSavePosition = "SetDontSavePosition",
	propagateKeyboardInput = "SetPropagateKeyboardInput",
	ignoreParentAlpha = "SetIgnoreParentAlpha",
	ignoreParentScale = "SetIgnoreParentScale",
	clipChildren = "SetClipsChildren",
	-- propagateHyperlinksToParent
	hyperlinksEnabled = "SetHyperlinksEnabled",
	
	-- Button
	normalTexture = "SetNormalTexture",
	pushedTexture = "SetPushedTexture",
	disabledTexture = "SetDisabledTexture",
	highlightTexture = "SetHighlightTexture",
	-- ButtonText = "SetFontString",
	buttonText = function(self, value) self:SetFontString(value) end, -- FIX
	normalFont = "SetNormalFontObject",
	highlightFont = "SetHighlightFontObject",
	disabledFont = "SetDisabledFontObject",
	normalColor = function(self, value)
		local texture = self:GetNormalTexture()
		texture:SetColorTexture(value.r, value.g, value.b, value.a)
	end,
	highlightColor = function(self, value)
		local texture = self:GetHighlightTexture()
		texture:SetColorTexture(value.r, value.g, value.b, value.a)
	end,
	disabledColor = function(self, value)
		local texture = self:GetDisabledTexture()
		texture:SetColorTexture(value.r, value.g, value.b, value.a)
	end,
	pushedTextOffset = function(self, value) self:SetPushedTextOffset(value.x, value.y) end,
	text = "SetText",
	registerForClicks = "RegisterForClicks",
	motionScriptsWhileDisabled = "SetMotionScriptsWhileDisabled",
	
	enabled = "SetEnabled",
	
	-- CheckButton
	checkedTexture = "SetCheckedTexture",
	disabledCheckedTexture = "SetDisabledCheckedTexture",
	checked = "SetChecked",
	
	-- StatusBar
	BarTexture = "SetStatusBarTexture",
	BarColor = "SetStatusBarColor",
	-- drawLayer = function(self, value) self:GetStatusBarTexture():SetDrawLayer(value) end,
	minValue = function(self, value)
		local minValue, maxValue = self:GetMinMaxValues()
		self:SetMinMaxValues(value, maxValue)
	end,
	maxValue = function(self, value)
		local minValue, maxValue = self:GetMinMaxValues()
		self:SetMinMaxValues(minValue, value)
	end,
	-- defaultValue
	orientation = "SetOrientation",
	rotatesTexture = "SetRotatesTexture",
	reverseFill = "SetReverseFill",
	
	-- Slider
	-- ThumbTexture
	-- drawLayer
	-- minValue
	-- maxValue
	-- defaultValue
	valueStep = "SetValueStep",
	obeyStepOnDrag = "SetObeyStepOnDrag",
	-- orientation
	
--[=[
	-- EditBox
	FontString
	HighlightColor
	TextInsets
	font
	letters
	blinkSpeed
	numeric
	password
	multiLine
	historyLines
	autoFocus
	ignoreArrows
	countInvisibleLetters
	
	-- ColorSelect
	ColorWheelTexture
	ColorWheelThumbTexture
	ColorValueTexture
	ColorValueThumbTexture
	
	-- Model
	FogColor
	file
	scale
	fogNear
	fogFar
	glow
	drawLayer
	
	-- SimpleHTML
	FontString
	FontStringHeader1
	FontStringHeader2
	FontStringHeader3
	font
	file
	hyperlinkFormat
	
	-- MessageFrame
	FontString
	TextInsets
	font
	fade
	fadeDuration
	fadePower
	displayDuration
	insertMode
	
	-- ScrollingMessageFrame
	FontString
	TextInsets
	font
	fade
	fadeDuration
	displayDuration
	insertMode
	maxLines
	
	-- ScrollFrame
	ScrollChild
	
	-- MovieFrame
	-- WorldFrame
	-- GameTooltip
	
	-- Cooldown
	reverse
	hideCountdownNumbers
	drawEdge
	drawBling
	drawSwipe
	
	-- QuestPOIFrame
	filltexture
	bordertexture
	
	-- ArcheologyDigSiteFrame
	filltexture
	bordertexture
	
	-- ScenarioPOIFrame
	filltexture
	bordertexture
	
	-- Minimap
	questBlobInsideTexture
	questBlobOutsideTexture
	questBlobOutsideSelectedTexture
	questBlobRingTexture
	taskBlobInsideTexture
	taskBlobOutsideTexture
	taskBlobOutsideSelectedTexture
	taskBlobRingTexture
	archBlobInsideTexture
	archBlobOutsideTexture
	archBlobRingTexture
	
	-- PlayerModel
	-- DressUpModel
	-- TabardModel
	
	-- CinematicModel
	facing
	
	-- UiCamera
	-- UnitButton
	-- TaxiRouteFrame
	
	-- Browser
	imefont
	
	-- Animation
	Scripts
	name
	inherits
	virtual
	target
	targetKey
	parentKey
	childKey
	startDelay
	endDelay
	duration
	order
	smoothing
	
	-- Translation
	offsetX
	offsetY
	
	-- LineTranslation
	
	-- Rotation
	Origin
	degrees
	radians
	
	-- Scale
	Origin
	scaleX
	scaleY
	fromScaleX
	fromScaleY
	toScaleX
	toScaleY
	
	-- LineScale
	
	-- Alpha
	fromAlpha
	toAlpha
	
	-- ControlPoints
	ControlPoint
		name
		offsetX
		offsetY
	
	-- Path
	ControlPoints
	curve
	
	-- AnimationGroup
	Animation
	Scripts
	name
	inherits
	virtual
	parentKey
	looping
	setToFinalAlpha
]=]
	
	-- Texture
	texCoords = function(self, value)
		if value.left and value.right and value.top and value.bottom then
			self:SetTexCoord(value.left, value.right, value.top, value.bottom)
		else
			self:SetTexCoord(value.ULx, value.ULy, value.LLx, value.LLy, value.URx, value.URy, value.LRx, value.LRy)
		end
	end,
	color = function(self, value) texture:SetColorTexture(value.r, value.g, value.b, value.a) end,
	-- Gradient
	file = "SetTexture",
	mask = "SetMask",
	alphaMode = "SetBlendMode",
	-- alpha = "SetAlpha",
	ignoreParentAlpha = "SetIgnoreParentAlpha",
	ignoreParentScale = "SetIgnoreParentScale",
	nonBlocking = "SetNonBlocking",
	horizTile = "SetHorizTile",
	vertTile = "SetVertTile",
	atlas = "SetAtlas",
	-- useAtlasSize
	desaturated = "SetDesaturated",
	
	-- FontString
	-- FontHeight
	color = function(self, value) texture:SetTextColor(value.r, value.g, value.b, value.a) end,
	shadow = function(self, value)
		if value.offset then
			self:SetShadowOffset(value.offset.x, value.offset.y)
		end
		if value.color then
			self:SetShadowColor(value.color.r, value.color.g, value.color.b, value.color.a)
		end
	end,
	-- font = "SetFont",
	-- bytes
	text = "SetText",
	spacing = "SetSpacing",
	-- outline
	-- monochrome
	nonspacewrap = "SetNonSpaceWrap",
	wordwrap = "SetWordWrap",
	justifyV = "SetJustifyV",
	justifyH = "SetJustifyH",
	maxLines = "SetMaxLines",
	indented = "SetIndentedWordWrap",
	-- alpha = "SetAlpha",
	ignoreParentAlpha = "SetIgnoreParentAlpha",
	ignoreParentScale = "SetIgnoreParentScale",
	
--[=[
	-- Line
	StartAnchor
		Offset
		relativeTo
		relativePoint
		relativeKey
		x
		y
	EndAnchor
		Offset
		relativeTo
		relativePoint
		relativeKey
		x
		y
	thickness
]=]
}

local function applyAttributes(object, template)
	for k, v in pairs(template) do
		local attribute = attributes[k]
		if type(attribute) == "string" then
			attribute = object[attribute]
		end
		if attribute then
			attribute(object, v)
		end
	end
end

local function createTexture(parent, template)
	local texture = parent:CreateTexture(nil, nil, template.inherits)
	applyAttributes(texture, template)
	return texture
end

local function createFontString(parent, template)
	local fontString = parent:CreateFontString(nil, nil, template.inherits)
	applyAttributes(fontString, template)
	return fontString
end

local function constructor(self, objectType, parent, template)
	local inherits = template.inherits
	if type(inherits) == "table" then
		inherits = table.concat(",", inherits)
	end
	local frame = CreateFrame(objectType, template.name, parent, inherits)
	applyAttributes(frame, template)
	if template.textures then
		for i, v in ipairs(template.textures) do
			createTexture(frame, v)
		end
	end
	if template.fontStrings then
		for i, v in ipairs(template.fontStrings) do
			createFontString(frame, v)
		end
	end
	if template.scripts then
		for k, v in pairs(template.scripts) do
			if type(v) == "string" then
				v = frame[v]
			end
			frame:SetScript(k, v)
		end
		if template.scripts.OnLoad then
			template.scripts.OnLoad(frame)
		end
	end
	return frame
end

Libra:RegisterModule(Type, Version, constructor)