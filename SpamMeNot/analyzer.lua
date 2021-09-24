--[[    
    SpamMeNot: Detects and blocks commercial spam
    Copyright (C) 2008 Robert Stiles (robs@codexsoftware.co.uk)

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]

local L = LibStub("AceLocale-3.0"):GetLocale("SpamMeNot")

local Analyzer = {}

function Analyzer:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	self.weights = SpamMeNot.words[GetLocale()]
	self.tradeWeights = SpamMeNot.tradeWords[GetLocale()]
	self.cachedRatings = {}
	
	-- Default to enUS if we didn't find words for this locale
	if not self.weights then
		self.weights = SpamMeNot.words["enUS"]
		SpamMeNot:Print(L["No localized word list available.  Defaulting to enUS word list."])	
	end
	
	if not self.tradeWords then
		self.tradeWeights = SpamMeNot.tradeWords["enUS"]		
	end
	
	return o
end

function Analyzer:RemoveHyperLinks(text)
	text = string.gsub(text, "|H.-|h(.-)|h", "%1")	
	text = string.gsub(text, "|c%w%w%w%w%w%w%w%w(.-)|r", "%1")	
	return text
end

-- Tests individual words and returns a summed spam rating.  Words
-- listed in wordsChecked are not checked again
function Analyzer:TestWords(weights, wordsChecked, s)	
	local w = ""
	local weight = 0
	-- Check individual words
	for w in string.gmatch(s, "%w+") do
		if (not wordsChecked[w]) then
			if (weights[w]) then				
				weight = weight + weights[w]
			end
			wordsChecked[w] = 1;
		end
	end	
	return weight;
end

function Analyzer:NumbersToLetters(s)
	s = string.gsub(s, "0" , "o")
	s = string.gsub(s, "{circle}" , "o")
	s = string.gsub(s, "1" , "l")		
	s = string.gsub(s, "3" , "e")		
	s = string.gsub(s, "4" , "a")
	s = string.gsub(s, "5" , "s")
	return s
end

function Analyzer:LettersToNumbers(s)
	s = string.gsub(s, "o" , "0")
	s = string.gsub(s, "{circle}" , "0")
	s = string.gsub(s, "l" , "1")		
	s = string.gsub(s, "e" , "3")		
	s = string.gsub(s, "a" , "4")
	s = string.gsub(s, "s" , "5")
	return s
end

-- Searches for substring matches for words in the word list
-- Will not check for words listed in wordsFound
function Analyzer:TestSubstringWords(weights, wordsFound, s)
	local word = ""
	local value = 0
	local weight = 0
	
	for word, value in pairs(weights) do				
		if not wordsFound[word] then
			if (string.match(s, word)) then
				weight = weight + value
				wordsFound[word] = 1				
			end
		end
	end
	return weight
end

-- Regular spaced word check.
function Analyzer:SpacedWordCheck(weights, s)
	local weight = 0
	local wordsChecked = {}
	
	-- Check individual words
	weight = weight + self:TestWords(weights, wordsChecked, s)

	-- Remove double spacing and replace odd characters used for spaces with real ones
	-- and check again
	local spacestrip = "[^1234567890abcdefghijklmnopqrstuvwxyzr&Ä£$!.,%<>=-?‡·‚‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ˘˙˚¸]+"	
	s = string.gsub(s, spacestrip, " ")
	s = string.gsub(s, "{star}", " ")
	s = string.gsub(s, "{triangle}", " ")
	s = string.gsub(s, "{circle}", " ")
	s = string.gsub(s, "{square}", " ")	
	s = string.gsub(s, "{diamond}", " ")	
	weight = weight + self:TestWords(weights, wordsChecked, s)	
	
	-- Change numbers commonly used as letters to their letter and check again
	s = self:NumbersToLetters(s)
	weight = weight + self:TestWords(weights, wordsChecked, s)	
	
	-- and vice-versa
	s = self:LettersToNumbers(s)
	weight = weight + self:TestWords(weights, wordsChecked, s)	

	--SpamMeNot:DebugMsg("SpaceWordCheck: " .. weight);
			
	return weight
end

-- Simply search for word matches anywhere in the text
function Analyzer:SubstringCheck(weights, s)
	local word = ""
	local value = 0
	local weight = 0
	
	local wordsFound = {}

	weight = self:TestSubstringWords(weights, wordsFound, s)

	-- Revert numerics
	s = self:NumbersToLetters(s)
	weight = weight + self:TestSubstringWords(weights, wordsFound, s)

	-- and backwards
	s = self:LettersToNumbers(s)
	weight = weight + self:TestSubstringWords(weights, wordsFound, s)
	
	--SpamMeNot:DebugMsg("SubstringCheck: " .. weight)
	return weight
end

-- The main spam rating formula.  Takes a string and returns a rating.  >= 100 is considered
-- to be spam.
function Analyzer:RateMessage(weights, s)
	if type(weights) == "string" then		
		s = weights
		weights = self.weights
	end

	--SpamMeNot:DebugMsg("RateMessage: " .. s)
		
	-- Strip out wow hyperlinks and colors	
	s = self:RemoveHyperLinks(s)
	s = string.lower(s)	

	if self.cachedRatings[s] then
		if self.cachedRatings[s][weights] then
			--SpamMeNot:DebugMsg("Returning cached value: " .. self.cachedRatings[s][weights])
			return self.cachedRatings[s][weights]
		end
	end

	local spacestrip = "[^1234567890abcdefghijklmnopqrstuvwxyzr&Ä£$!.,%<>=-?‡·‚‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ˘˙˚¸]+"	
	local sCompact = string.gsub(s, spacestrip, "")

	local weight1 = self:SpacedWordCheck(weights, s)
	local weight2 = self:SubstringCheck(weights, s)
	local weight3 = self:SubstringCheck(weights, sCompact)
			
	local weight = weight1
	if weight2 > weight then
		weight = weight2
	end
	
	if weight3 > weight then
		weight = weight3
	end
	
	if not self.cachedRatings[s] then
		self.cachedRatings[s] = {}		
	end
	
	self.cachedRatings[s][weights] = weight
	return weight
end

function Analyzer:ContainsSkillLink(s)
	 --[[		
		|Hspell:3127|h[Parry]|h
	]]

	local res = false	
	if string.find(s, "|Hspell.-|h(.-)|h") then	
		res = true
	end
	return res
end

function Analyzer:RateTradeMessage(s)	
	local tradeSkillLinkWeight = 10
	local weight = self:RateMessage(self.tradeWeights, s) 
	
	if self:ContainsSkillLink(s) then
		SpamMeNot:DebugMsg(s .. " contains skill link.")
		weight = weight + tradeSkillLinkWeight
	end
	SpamMeNot:DebugMsg("RateTradeMessage(" .. s .. ") returning " .. weight)
	return weight	
end

SpamMeNot.Analyzer = Analyzer