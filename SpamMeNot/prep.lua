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

-- Create the Ace3 AddOn.
SpamMeNot = LibStub("AceAddon-3.0"):NewAddon("SpamMeNot", "AceEvent-3.0", "AceConsole-3.0", "AceTimer-3.0")
-- Create a place for the localized words to load
SpamMeNot.words = {}
SpamMeNot.tradeWords = {}