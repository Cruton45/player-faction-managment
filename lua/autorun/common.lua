PROFILE_FACTION_CIS = 1
PROFILE_FACTION_REPUBLIC = 2

INVALID_PROFILE_ID = "0"
INVALID_FACTION_ID = "0"
INVALID_FACTION_STR = ""

g_selected_faction_auto_whitelist_team_names = {}

-- Number of player profiles allowed per user group
g_max_profiles_by_ulx_group = {
	["VIP+"] = 3, 
	["VIP"] = 2, 
	["user"] = 1
}

-- Had to put this into a hook otherwise the team IDs didn't show up properly...
hook.Add("loadCustomDarkRPItems", "player_profile_load_create_profile_auto_whitelist", function() 
	if (SERVER) then 
		ServerLog(string.format("[INFO] Loading auto white list table for newly created profiles...\n"))
	end 
	
	-- When a player selects a faction, this config will auto whitelist players for jobs added here
    g_selected_faction_auto_whitelist_team_names = {
		[PROFILE_FACTION_CIS] = {TEAM_B1_BDROID},
		[PROFILE_FACTION_REPUBLIC] = {TEAM_CT_Trooper},
	}

end)

function is_valid_faction_id(id) 
	return (id == PROFILE_FACTION_CIS or 
			id == PROFILE_FACTION_REPUBLIC)
end

function get_faction_str(id)
    local faction_id_to_str = {
        -- Extra space added so its printed to each player as: [FactionName Comms]
        [PROFILE_FACTION_CIS] = "Sith ",
        [PROFILE_FACTION_REPUBLIC] = "Jedi ",
    }

    if (!id) then return "" end

    id = tonumber(id)

    if (!faction_id_to_str[id]) then 
        return ""
    else 
        return faction_id_to_str[id]
    end
end

function validate_text_field(text, max_len)
	local invalid_chars = "[%%%^%$%(%)%.%[%]%*%+%-%?;'\"'<>,/\\]"
	local min_len = 2
	local error_msg = nil 

	if ((!text) ||
		(#text < min_len) ||
		(#text > max_len)) then
			return string.format("Length must be between %d - %d", min_len, max_len)
	end

	error_msg = string.match(text, invalid_chars)
	if (error_msg) then 
		error_msg = string.format("One or more invalid values entered: ' %s '", error_msg)
	end 

	return error_msg
end
