local files, dirs = file.Find("player_profile_modules/*.lua", "LUA")
for k, v in pairs( files ) do
	ServerLog("Player profile system: Loading module (" .. v .. ")\n")
	include( "player_profile_modules/" .. v )
end

local files, dirs = file.Find("client/*.lua", "LUA")
for k, v in pairs( files ) do
	ServerLog("Player profile system: Sending module (" .. v .. ")\n")
	AddCSLuaFile( "client/" .. v )
end

include("autorun/common.lua")

util.AddNetworkString("reload_player_profiles")
util.AddNetworkString("player_add_or_update_profile")
util.AddNetworkString("player_load_profile")
util.AddNetworkString("to_cl_loaded_player_profile")
util.AddNetworkString("player_delete_new_profile")
util.AddNetworkString("player_edit_profile")
util.AddNetworkString("notify_server_reload_all_profiles")


--[[ 
	Structure of the table current_loaded_profile:
		loaded_profile.id = INTEGER VALUE
		loaded_profile.faction_id = INTEGER VALUE (0 - 3)
		loaded_profile.desc = STRING VALUE
		loaded_profile.name = STRING VALUE
--]]
local pmeta = FindMetaTable("Player")
if (!pmeta) then return end

function pmeta:get_player_profile()
	if (!self.my_profile || !self.my_profile.name) then return nil end

	return self.my_profile
end

function pmeta:get_faction_id()
	if (!self.my_profile || !self.my_profile.faction_id) then return INVALID_FACTION_ID end

	return self.my_profile.faction_id
end

function pmeta:get_profile_id()
	if (!self.my_profile || !self.my_profile.id) then return INVALID_PROFILE_ID end

	return self.my_profile.id
end

function pmeta:set_player_char_name(name)
	if (!name || !self.my_profile || !self.my_profile.name) then return end 
	
	self.my_profile.name = name
end

function pmeta:set_player_profile(ctx)
	if (!ctx) then 
		self.my_profile = {}
		return
	end

	self.my_profile = {}
	self.my_profile.id = ctx.id -- Keep as a string b/c 64 bit ints aren't a safe thing in LUA
	self.my_profile.name = ctx.name
	self.my_profile.desc = ctx.desc
	self.my_profile.faction_id = tonumber(ctx.faction_id)
end

local function get_all_ply_profiles(ply)
	if (!IsValid(ply)) then return end

	local ply_id = ply:SteamID64()
	local ret = {["can_create_new_profile"] = 1}
	local ply_profiles = {}
	local ply_profile_limit = db_select_ply_info_by_steamid(ply_id)

	if (ply_profile_limit) then
		ret["max_player_profiles"] = ply_profile_limit[1]["MAX_PLAYER_PROFILES"]

		ply_profiles = db_select_profiles_by_ply_steamid(ply_id)
		if (ply_profiles) then
			ret["profiles"] = ply_profiles
		else 
			ply_profiles = {}
		end

		ret["can_create_new_profile"] = ret["max_player_profiles"] - #ply_profiles
	end

	return ret
end

local function send_ply_profiles(ply, ...)
	if (!IsValid(ply)) then return end

	local args = {...}
	local update_type = args[1]

	if (!update_type) then 
		update_type = 0
		ply:set_player_profile(nil) 
		ServerLog("[INFO] Initalized loaded player profile to NULL for : " .. ply:SteamID() .. "\n")
	else 
		ServerLog(string.format("[INFO] Player %s has a profile checked out...\n", ply:SteamID()))
	end
	
	net.Start("reload_player_profiles")
		net.WriteInt(update_type, 32)
		net.WriteTable(get_all_ply_profiles(ply))
	net.Send(ply)
end

hook.Add("PlayerInitialSpawn", "reload_player_profiles", send_ply_profiles)

net.Receive("notify_server_reload_all_profiles", function(len, ply)
	send_ply_profiles(ply, 1)
end)

net.Receive("player_load_profile", function(len, ply) 
	local ply_steamid = ply:SteamID64() -- 76561198092541763
	local profile_id = net.ReadString()
	local loaded_profile = {}
	local max_str_len = 64

	if (validate_text_field(profile_id, max_str_len)) then return end

	loaded_profile.id = profile_id
	loaded_profile.faction_id = -1
	loaded_profile.desc = nil
	loaded_profile.name = nil

	result_table = db_select_profile_by_idx_ply_steam_idx(ply_steamid, loaded_profile.id)
	if (result_table) then
		loaded_profile.faction_id = result_table[1]["CHAR_FACTION"]
		loaded_profile.name = result_table[1]["PLAYER_PROFILE_NAME"]
		loaded_profile.desc = result_table[1]["PLAYER_PROFILE_DESC"]

		ply:set_player_profile(loaded_profile)

		if (ply:Nick() != loaded_profile.name) then 
			ply:setRPName(loaded_profile.name)
		end

		ServerLog(string.format("[INFO] Loaded profile %s for player %s\n", loaded_profile.id, ply:SteamID()))
		DarkRP.notify(ply, NOTIFY_GENERIC, 3, "Your profile was loaded successfully!")

		net.Start("to_cl_loaded_player_profile")
			net.WriteTable(loaded_profile)
		net.Send(ply)
	end
end)

local function get_ply_profile_limit(ply) 
	if (!IsValid(ply)) then return 1 end

	local ret = 1
	local user_group = ply:GetUserGroup()

	for k, v in pairs(g_max_profiles_by_ulx_group) do
		if (user_group == k) then
			ret = v
			break
		end
	end

	if (ret <= 0) then ret = 1 end

	return ret
end

net.Receive("player_edit_profile", function(ply, len) 
	if (!IsValid(ply)) then return end

	local ply_steamid = ply:SteamID64()
	local ply_steamid_std_str = ply:SteamID()
	local ply_profile_faction = net.ReadInt(32)
	local ply_name = net.ReadString()
	local ply_desc = net.ReadString()

	if ((validate_text_field(ply_name, max_text_str_len)) ||
		(validate_text_field(ply_desc, max_text_str_len)) || 
		(!is_valid_faction_id(ply_profile_faction))) then
		ServerLog("[ERROR] Failed to validate request to add new profile: " .. ply_steamid_std_str .. "\n")
	end
end)

net.Receive("player_add_or_update_profile", function(len, ply)
	if (!IsValid(ply)) then return end

	local ply_steamid = ply:SteamID64()
	local ply_steamid_std_str = ply:SteamID()
	local ply_profile_limit = 1
	local ply_profiles_remaining = 0
	local max_text_str_len = 128
	local max_profile_id_len = 64

	local ply_profile_id = net.ReadString()
	local ply_profile_faction = net.ReadInt(32)
	local ply_name = net.ReadString()
	local ply_desc = net.ReadString()
	

	if ((validate_text_field(ply_name, max_text_str_len)) ||
		(validate_text_field(ply_desc, max_text_str_len)) || 
		(!is_valid_faction_id(ply_profile_faction))) then
		ServerLog("[ERROR] Failed to validate request to add new profile: " .. ply_steamid_std_str .. "\n")
		return
	end

	if (ply_profile_id == "") then ply_profile_id = nil end 

	if (ply_profile_id && validate_text_field(ply_profile_id, max_profile_id_len)) then
		ServerLog("[ERROR] Failed to validate request to update profile: " .. ply_steamid_std_str .. "\n")
		return
	end

	ply_profile_limit = get_ply_profile_limit(ply)
	db_insert_or_update_player(ply_steamid, ply_profile_limit)

	ply_profiles_remaining = db_can_ply_has_new_profile(ply_steamid)
	if (ply_profiles_remaining <= 0) then
		DarkRP.notify(ply, NOTIFY_ERROR, 5, "Failed to create new profile contact an Admin!")
		ServerLog("[ERROR] Failed to create new profile because the user has no available profiles left: " .. ply_steamid_std_str .. "\n") 
		return
	end

	if (db_insert_or_replace_profile(ply_profile_id, ply_steamid, ply_profile_faction, ply_name, ply_desc) <= 0) then
		DarkRP.notify(ply, NOTIFY_ERROR, 5, "Failed to create new profile contact an Admin!")
		ServerLog("[ERROR] Failed to create new profile : db_insert_or_replace_profile\n")
		return
	end

	WHITE_LIST:whitelist(ply, ply_profile_faction)
	
	send_ply_profiles(ply, 1)
end)

hook.Add("OnPlayerChangedTeam", "is_valid_job_change", function(ply, prev_job, current_job)	
	local steam_id_str = ply:SteamID()
	local ply_faction = ply:get_faction_id()
	local ply_faction_str = string.Trim(get_faction_str(ply_faction))
	local current_job_table = RPExtraTeams[current_job]
	local fallback_job = GAMEMODE.DefaultTeam
	local force_job_change = nil

	if (current_job == fallback_job) then return end

	if (!ply_faction_str || INVALID_FACTION_STR == ply_faction_str) then force_job_change = fallback_job end 

	-- If faction is not set on new job do nothing...
	if (!force_job_change && (!current_job_table || !current_job_table.faction)) then return end 

	-- Faction is set for this job. Must verify the user's new job is in the faction based on players current checked out profile
	if (!force_job_change && current_job_table.faction != ply_faction_str) then 
		force_job_change = fallback_job
	end

	if (force_job_change != nil) then
		--ply:SetTeam(fallback_job)
		DarkRP.notify(ply, NOTIFY_ERROR, 3, "Select your character using !cchar")
		RunConsoleCommand("_FAdmin", "setteam", steam_id_str, fallback_job)
		send_ply_profiles(ply)
	end
end)

hook.Add("CanChangeRPName", "check_profile_loaded_on_name_change", function(ply, name)
	local reason = "Select your character using !cchar"
	if (ply:get_profile_id() != INVALID_PROFILE_ID) then 
		return true 
	else 
		return false, reason
	end
end)

hook.Add("onPlayerChangedName", "update_char_name", function(ply, old_name, name)
	local profile_id = ply:get_profile_id()

	if (profile_id == INVALID_PROFILE_ID || !name) then return end

	ply:set_player_char_name(name)
	db_update_profile_name_by_idx_steam_idx(ply:SteamID64(), profile_id, name)
end)

hook.Add(ULib.HOOK_USER_GROUP_CHANGE, "update_ply_profile_limit", function(id, allows, denies, group, prev_group) 
	local ply = ULib.getPlyByID(id)
	local ply_profile_limit = 1

	if (!ply || !IsValid(ply) || !group) then return end

	if (g_max_profiles_by_ulx_group[group] && type(g_max_profiles_by_ulx_group[group]) == "number") then 
		ply_profile_limit = g_max_profiles_by_ulx_group[group]
	end

	db_insert_or_update_player(ply:SteamID64(), ply_profile_limit)
end)
