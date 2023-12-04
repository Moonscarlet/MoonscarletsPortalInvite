local enabled = true
local messageCheckDuplicate
local autoinvite = false

local frame = CreateFrame("FRAME")
frame:RegisterEvent("ADDON_LOADED"); -- Fired when saved variables are loaded
frame:RegisterEvent("PLAYER_LOGOUT"); -- Fired when user is logging out

function frame:OnEvent(event)
    if event == "ADDON_LOADED" then
        --print("Addon loaded")
		elseif event == "PLAYER_LOGOUT" then
		print("Player is logging out")
	end
end

frame:SetScript("OnEvent", frame.OnEvent);

commands =
{
    ["help"] = function()
        print("Commands : ")
        print(" ")
        print("/PI add [String]")
        print('Description : Adds a string to whitelist (underscore for spaces - | for must match all - "-"to exclude a word)')
        print(" ")
        print("/PI del [key number]")
        print("Description : Removes string by number in the list")
        print(" ")
        print("/PI clear")
        print("Description : Clears the list")
        print(" ")
        print("/PI list")
        print("Description : Prints the watchlist")
        print(" ")
		print("/PI addplayer")
        print("Description : add a player to ignore list")
        print(" ")
		print("/PI delplayer")
        print("Description : remove player from the ignore list (by key number, see /pi players)")
        print(" ")
		print("/PI players")
        print("Description : Prints the ignored players list")
        print(" ")		
		print("/PI enable")
        print("Description : Enables scanning")
        print(" ")
		print("/PI disable")
        print("Description : Disables scanning")
        print(" ")
		print("/PI auto")
        print("Description : autoinvite")
        print(" ")
        print("/PI help")
        print("Description : Prints help")
	end,
	
    ["add"] = function(textstr)
        if whitelistedStringTablePortals == nil then
            print("--")
            print("No string table detected, creating a new, empty one")
            whitelistedStringTablePortals = {nil}
		end
		textstr= textstr:gsub("_", " ")
        table.insert(whitelistedStringTablePortals, textstr)
	end,
	
    ["del"] = function(key)
		print("--")
		print("Removed "..key)    
		table.remove(whitelistedStringTablePortals, key)
	end,
	
    ["clear"] = function()
        wipe(whitelistedStringTablePortals)
        print("--")
        print("Wiped")
	end,
	
	["enable"] = function()
		enabled= true
        print("--")
        print("Enabled")
	end,
	
	["disable"] = function()
		enabled= false
        print("--")
        print("Disabled")
	end,

    ["auto"] = function()
		autoinvite= not autoinvite
        print("--")
        print("auto invite: " .. tostring(autoinvite))
    end,
	
    ["list"] = function()
		print("--")
		print("Enabled: " .. tostring(enabled))
		print("auto invite: " .. tostring(autoinvite))
        print("Watchlist:")
        if (whitelistedStringTablePortals == nil) then
			print("Watchlist is empty")
			return
		end
		
        for i,v in ipairs(whitelistedStringTablePortals) do
            print(i,v)
		end
	end,
	
    ["addplayer"] = function(textstr)
        if whitelistedStringTablePlayers == nil then
            print("--")
            print("No string table detected, creating a new, empty one")
            whitelistedStringTablePlayers = {}
			table.insert(whitelistedStringTablePlayers, "")
		end
        table.insert(whitelistedStringTablePlayers, textstr)
	end,
	
    ["delplayer"] = function(key)
		print("--")
		print("Removed "..key)    
		table.remove(whitelistedStringTablePlayers, key)
	end,
	
	["players"] = function()
        print("Ignored players:")
        if (whitelistedStringTablePlayers == nil) then
			print("Ignore list is empty")
			return
		end
		
        for i,v in ipairs(whitelistedStringTablePlayers) do
            print(i,v)
		end
	end
}


function HandleSlashCommands(str)  
    if (#str == 0) then
        print("Command not recognized, showing help")
        commands.help()
        return;    
	end
	
    local args = {};
    for _, arg in ipairs({ string.split(' ', str) }) do
        if (#arg > 0) then
            table.insert(args, arg);
		end
	end
	
    local path = commands;
	
    for id, arg in ipairs(args) do
        if (#arg > 0) then
            arg = arg:lower();         
            if (path[arg]) then
                if (type(path[arg]) == "function") then            
                    path[arg](select(id + 1, unpack(args)));
                    return;                
					elseif (type(path[arg]) == "table") then               
                    path = path[arg];
				end
				else
                print("--")
                print("Not a Portal Invite command")
                print("Arguement numcount : " , #arg)
                print("Arguement : " , arg)
                return;
			end
		end
	end
end

SLASH_PI1 = "/PI"
SlashCmdList.PI = HandleSlashCommands

local chatFrame = CreateFrame("FRAME")

-- chatFrame:RegisterEvent("CHAT_MSG_GUILD")
-- chatFrame:RegisterEvent("CHAT_MSG_OFFICER")
--chatFrame:RegisterEvent("CHAT_MSG_BATTLEGROUND")--NO
--chatFrame:RegisterEvent("CHAT_MSG_BATTLEGROUND_LEADER")--NO
-- chatFrame:RegisterEvent("CHAT_MSG_PARTY")
-- chatFrame:RegisterEvent("CHAT_MSG_RAID_LEADER")
-- chatFrame:RegisterEvent("CHAT_MSG_RAID")
chatFrame:RegisterEvent("CHAT_MSG_WHISPER")
-- chatFrame:RegisterEvent("CHAT_MSG_BN_WHISPER")
chatFrame:RegisterEvent("CHAT_MSG_CHANNEL")
chatFrame:RegisterEvent("CHAT_MSG_SAY")
chatFrame:RegisterEvent("CHAT_MSG_YELL")

chatFrame:SetScript("OnEvent", function(self,event,message,sender,chanString,chanNumber,chanName,x8,x9,x10,x11,x12,x13,guid)
	local class, _, _, _, _, _, _ = GetPlayerInfoByGUID(guid) --class of sender
	local player = sender:gsub("-.*", "")--REMOVE -server name from sender
	local myName,_ = UnitName("player") -- Get my name
	local chanNumberOnly = string.sub(chanNumber, 1, 1) -- get channel number
	local myClass, _, _ = UnitClass("player");
	local location = PlayerLocation:CreateFromGUID(guid)
	-- print(location)
	------------------CLASS COLORS
	local classColor
	if 	   class=="Druid" then classColor= "FF7D0A" 
		elseif class=="Hunter" then classColor= "ABD473"
		elseif class=="Mage" then classColor= "69CCF0"
		elseif class=="Paladin" then classColor= "F58CBA"
		elseif class=="Priest" then classColor= "FFFFFF"
		elseif class=="Rogue" then classColor= "FFF569"
		elseif class=="Shaman" then classColor= "0070DE"
		elseif class=="Warlock" then classColor= "9482C9"
		elseif class=="Warrior" then classColor= "C79C6E"
		elseif class=="Death Knight" then classColor= "C41E3A"
		elseif class=="Demon Hunter" then classColor= "A330C9"
	end
	-------------------------
	
	-- if enabled and player~= myName and myClass== "Mage" and class ~= "Mage" and ((chanNumberOnly== "1" and event == "CHAT_MSG_CHANNEL") or event ~= "CHAT_MSG_CHANNEL") then 
	-- if enabled and player~= myName and myClass== "Mage" then --all channels
	-- if enabled and myClass== "Mage" and (((chanNumberOnly== "1" or chanNumberOnly== "2") and event == "CHAT_MSG_CHANNEL") or event ~= "CHAT_MSG_CHANNEL") then --testing (including me)
	if enabled and myClass== "Mage" and ((chanNumberOnly== "1" and event == "CHAT_MSG_CHANNEL") or event ~= "CHAT_MSG_CHANNEL") then --no trade channel
		--not me & not a mage & general chat or others 
		-- if enabled then
		for _, z in ipairs(whitelistedStringTablePlayers) do --if player is found in blacklist > return
			if player:lower() == z:lower() then 
				return 
			end
		end
		
		for _, v in ipairs(whitelistedStringTablePortals) do
			local checkFound = true
			for w in string.gmatch(v:lower(), "([^\|]+)") do
				if (string.sub(w, 1, 1)~= "-" and not message:lower():find(w:lower())) or (string.sub(w, 1, 1)== "-" and message:lower():find(string.sub(w:lower(), 2))) then 
					-- if keyword doesn't start with - and keyword not found in msg		OR 		keyword starts with - and keyword found in msg THEN ignore this msg
					checkFound= false
				end
			end
			
			if checkFound then
				-- if messageCheckDuplicate == message then --if same as previous message return
					-- return
				-- else
					-- messageCheckDuplicate = message
				-- end
	
				playerLink= "|Hplayer:"..sender.."|h"..chanName.."|h" --GetPlayerLink(characterName,linkDisplayText)
				playerLink=  "|cff"..classColor.."["..playerLink.."]|r"-- Adding class color
				msg= "|cAAFF0000PORTAL(|r|cff92ff58"..v:upper().."|r|cffFF0000): |r|cff5892ff["..chanNumber.."]|r "..playerLink.."|cff5892ff: "..message.."|r"
				
				-- RaidNotice_AddMessage(RaidWarningFrame,msg, ChatTypeInfo["RAID_WARNING"])
				DEFAULT_CHAT_FRAME:AddMessage(msg);
				
				
				------------TEST-------------
				-- DEFAULT_CHAT_FRAME:AddMessage("self: "..self);
				-- DEFAULT_CHAT_FRAME:AddMessage("event: "..event);
				-- DEFAULT_CHAT_FRAME:AddMessage("message: "..message);
				-- DEFAULT_CHAT_FRAME:AddMessage("sender: "..sender);
				-- DEFAULT_CHAT_FRAME:AddMessage("chanString: "..chanString);
				-- DEFAULT_CHAT_FRAME:AddMessage("chanNumber: "..chanNumber);
				-- DEFAULT_CHAT_FRAME:AddMessage("chanName: "..chanName);
				-- DEFAULT_CHAT_FRAME:AddMessage("x8: "..x8);
				-- DEFAULT_CHAT_FRAME:AddMessage("x9: "..x9);
				-- DEFAULT_CHAT_FRAME:AddMessage("x10: "..x10);
				-- DEFAULT_CHAT_FRAME:AddMessage("x11: "..x11);
				-- DEFAULT_CHAT_FRAME:AddMessage("x12: "..x12);
				-- DEFAULT_CHAT_FRAME:AddMessage("x13: "..x13);
				-- DEFAULT_CHAT_FRAME:AddMessage("guid: "..guid);
				
				-----------------------------
				
				-- SELECTED_CHAT_FRAME:AddMessage(msg);
				-- ChatFrame8:AddMessage(msg);
				
				-- PlaySoundFile("Sound\\Interface\\RaidWarning.ogg")
				-- PlaySound(4041)--cat
				-- PlaySound(4041,"Master")--cat
				-- PlaySound(6555,"Master")--ShaysBell
				-- PlaySound(1044,"Master")--centaur
				-- PlaySound(1023,"Master")--CHICKEN
				-- PlaySound(3410,"Master")--ORCA
				-- PlaySound(1431,"Master")--LOH
				PlaySound(8474,"Master")--SCREECH
				
				if autoinvite then
					InviteUnit(sender);
				end
				
				StaticPopupDialogs["INVITEPLAYER"] = {
					-- text = "Invite "..player.."?\n\n"..message.."\n",
					text = "Invite ".."|cff"..classColor..player.."|r".."?\n\n["..chanNumber.."]\n\n"..message.."\n",
					-- text = "Invite ".."|cff"..classColor..player.."|r".."? ("..table.concat(location)..")\n\n"..message.."\n",
					button1 = "Yes",
					button2 = "No",
					OnAccept = function() --on Yes
						InviteUnit(sender);
					end,
					timeout = 20,
					whileDead = true,
					hideOnEscape = true,
					preferredIndex = 3,
				}
				StaticPopup_Show ("INVITEPLAYER")
				return--SHOW ONLY IF 1st is FOUND TO AVOID SPAM NOTIFICATIONS
			end
		end
	end
end)