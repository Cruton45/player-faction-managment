function db_init()
	local ret = sql.Query("CREATE TABLE IF NOT EXISTS player_profile_info( \
			  		 	   PLAYER_STEAM_ID INTEGER(64) PRIMARY KEY NOT NULL, \
			  		       MAX_PLAYER_PROFILES INTEGER(1) NOT NULL);")

	if (ret != false) then
		ret = sql.Query("CREATE TABLE IF NOT EXISTS player_profiles( \
						 PROFILE_ID INTEGER PRIMARY KEY, \
						 CHAR_FACTION INTEGER(1) NOT NULL, \
						 PLAYER_PROFILE_NAME TEXT(256) NOT NULL, \
			  		     PLAYER_PROFILE_DESC TEXT(256) NOT NULL, \
						 PLAYER_STEAM_ID INTEGER(64), \
						 FOREIGN KEY(PLAYER_STEAM_ID) REFERENCES player_profile_info(PLAYER_STEAM_ID) \
						     ON DELETE CASCADE ON UPDATE CASCADE);")
	end

	return ret
end

hook.Add("Initialize", "init_player_profile_module_db", db_init)

function db_close()
end

function db_select_ply_info_by_steamid(ply_steam_id)
	if (!ply_steam_id) then return nil end

	local query = "SELECT * FROM player_profile_info WHERE \
		PLAYER_STEAM_ID = " .. ply_steam_id .. ";"

	return sql.Query(query)

end

function db_select_profiles_by_ply_steamid(ply_steam_id)
	if (!ply_steam_id) then return nil end

	local query = "SELECT PROFILE_ID, CHAR_FACTION, PLAYER_PROFILE_NAME, PLAYER_PROFILE_DESC FROM player_profiles WHERE \
		PLAYER_STEAM_ID = " .. ply_steam_id .. ";"

	return sql.Query(query)
end

function db_select_profile_by_idx_ply_steam_idx(ply_steam_id, idx)
	if (!ply_steam_id) then return nil end

	local query = "SELECT CHAR_FACTION, PLAYER_PROFILE_NAME, PLAYER_PROFILE_DESC FROM player_profiles WHERE \
		PLAYER_STEAM_ID = " .. ply_steam_id .. " AND PROFILE_ID = " .. idx .. ";"

	return sql.Query(query)
end

function db_update_profile_name_by_idx_steam_idx(ply_steam_id, idx, name)
	if (!ply_steam_id || !idx || !name) then return nil end

	local query = "UPDATE player_profiles SET PLAYER_PROFILE_NAME = '" .. name .. "' WHERE \
		PLAYER_STEAM_ID = " .. ply_steam_id .. " AND PROFILE_ID = " .. idx .. ";"

	return sql.Query(query)
end

-- Returns (int): Postive value that represents how many more profiles this user can have or
-- 					-1 if user not found
function db_can_ply_has_new_profile(ply_steam_id)
	local ret = -1

	if (!ply_steam_id) then return ret end

	local query_profile_cnt = "SELECT COUNT(*) AS CURRENT_NUM_OF_PROFILES FROM player_profiles WHERE PLAYER_STEAM_ID = "
		.. ply_steam_id .. ";"
	local query_max_profiles = "SELECT MAX_PLAYER_PROFILES FROM player_profile_info WHERE PLAYER_STEAM_ID = "
		.. ply_steam_id .. ";"
	
	local res = sql.Query(query_profile_cnt)

	if (res) then
		ret = tonumber(res[1]["CURRENT_NUM_OF_PROFILES"])
	end 

	if (ret >= 0) then 
		res = sql.Query(query_max_profiles)

		if (res) then 
			ret = res[1]["MAX_PLAYER_PROFILES"] - ret
		else
			ret = -1
		end
	end

	return ret
end

function db_insert_or_update_player(ply_steam_id, max_allowed_profiles)
	if (!ply_steam_id || !max_allowed_profiles) then
		return false
	end

	local query = "INSERT OR REPLACE INTO player_profile_info VALUES('" .. ply_steam_id .. "', " .. max_allowed_profiles .. ");"
	query = string.format(query, ply_steam_id, max_allowed_profiles)

	return sql.Query(query)
end

-- Returns (int): ID of new/edited profile or -1 on failure
function db_insert_or_replace_profile(profile_id, ply_steam_id, char_faction, profile_name, profile_desc)
	if ((!ply_steam_id) ||
		(!profile_name || string.len(profile_name) <= 0) ||
		(!profile_desc || string.len(profile_desc) <= 0)) then
		return -1 
	end

	local ret = -1
	local query_insert_new_profile = "INSERT OR REPLACE INTO player_profiles VALUES(%s, %d, '%s', '%s', '%s');"
	local query_last_rid_insert = "SELECT last_insert_rowid() AS NEW_PROFILE_ID;"

	query_insert_new_profile = string.format(query_insert_new_profile, profile_id or "NULL", char_faction, profile_name, 
		profile_desc, ply_steam_id)

	ret = sql.Query(query_insert_new_profile)
	if (ret != false && !profile_id) then
		ret = sql.Query(query_last_rid_insert)

		if (ret) then 
			ret = tonumber(ret[1]["NEW_PROFILE_ID"])
		else 
			ret = -1
		end

	elseif (!profile_id) then
		ret = -1
	else
		ret = profile_id
	end

	return ret
end

function db_delete_profile(profile_id)
	if (!profile_id) then return end 

	local query = "DELETE FROM player_profiles where PROFILE_ID = " .. profile_id .. ";"

	sql.Query(query)
end
