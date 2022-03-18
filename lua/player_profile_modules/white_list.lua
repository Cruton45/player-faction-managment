if (WHITE_LIST) then return end -- Load this only once... 

include ("autorun/common.lua")

WHITE_LIST = WHITE_LIST or {}

function WHITE_LIST:whitelist(ply, ply_faction) return 1 end

local pmeta = FindMetaTable("Player")
if (!pmeta) then return end

local MAX_WHITELIST_RETRIES = 12
local WAIT_TIME = 10

function pmeta:inc_whitelist_attempts()
	if (!self.white_list_attempts) then 
		self.white_list_attempts = 1 
		return self.white_list_attempts 
	end

	self.white_list_attempts = self.white_list_attempts + 1

	return self.white_list_attempts
end 

function pmeta:should_retry_whitelist()
	if (!self.white_list_attempts) then return false end 

	return self.white_list_attempts <= MAX_WHITELIST_RETRIES
end

if (BWhitelist) then 
	local function is_bwhitelist_initalized()
		if (BWhitelist.IsWhitelisted) then return true else return false end 
	end

	local function exec_whitelist(ply, ply_steamid_std_str, bwhitelist_perm_check, is_usergroup, team_idx)
		--ServerLog("[INFO] CUR TIME: " .. tostring(CurTime()) .. "\n") 
		
		if (!is_bwhitelist_initalized()) then 

			if (ply:should_retry_whitelist()) then 
				ply:inc_whitelist_attempts()

				ServerLog("[INFO] BWhitelist has not initalized.. Retrying again...\n") 
				timer.Simple(WAIT_TIME, function() 
					exec_whitelist(ply, ply_steamid_std_str, bwhitelist_perm_check, is_usergroup, team_idx)
				end)
			else 
				DarkRP.notify(ply, NOTIFY_ERROR, 5, "Unable to white list you because bwhitelist has not yet initalized")
				ServerLog("[ERROR] BWhitelist has not initalized yet, number of retry attempts exceded limit for ply " .. ply_steamid_std_str .. "\n")
			end 

			return 
		end 

		BWhitelist:IsWhitelisted(ply, team_idx, function(whitelisted) 
			if (whitelisted == false) then 
				team_name = team.GetName(team_idx)
				if (#team_name < 1) then
					ServerLog("[ERROR] Team with the ID \'" .. tostring(team_idx) .. "\' does not exist!\n")
				else 
					ServerLog(string.format("[INFO] white listed player %s to job %s\n", ply_steamid_std_str, team_name)) 
					BWhitelist:AddToWhitelist(is_usergroup, team_name, ply_steamid_std_str, bwhitelist_perm_check)
				end 
			end
		end)
	end 

	local function bwhitelist(ply, ply_faction)
		-- bwhitelist_perm_check = nil because if we ran a perm check on the 
		-- user, than we would never be able to whitelist for standard/VIP users...
		-- This means we need to do all the validation for "valid" whitelist request here
		local bwhitelist_perm_check = nil 
		local is_usergroup = false
		local ply_steamid_std_str = ply:SteamID()
		local jobs = g_selected_faction_auto_whitelist_team_names[ply_faction]
		local ret = 0
		local has_notified_user_of_retry = nil

		if (jobs && #jobs > 0) then
			for _, team_idx in pairs(jobs) do
				if (!is_bwhitelist_initalized()) then 
					if (!has_notified_user_of_retry) then 
						DarkRP.notify(ply, NOTIFY_GENERIC, 5, "Waiting for bwhitelist to initalize before white listing you...")
						ServerLog("[INFO] BWhitelist has not initalized yet!!\n")
					else 
						has_notified_user_of_retry = 1
					end 

					ply:inc_whitelist_attempts()

					if (ply:should_retry_whitelist()) then 
						timer.Simple(WAIT_TIME, function()
							exec_whitelist(ply, ply_steamid_std_str, bwhitelist_perm_check, is_usergroup, team_idx)
						end)
					else 
						DarkRP.notify(ply, NOTIFY_ERROR, 5, "Unable to white list you because bwhitelist has not yet initalized")
						ServerLog("[ERROR] BWhitelist has not initalized number of retry attempts exceded limit for ply: " .. ply_steamid_std_str .. "\n") 
						break 
					end 
				else 
					ServerLog("[INFO] Attempting to whitelist player... BWhitelist is initalized...\n") 
					exec_whitelist(ply, ply_steamid_std_str, bwhitelist_perm_check, is_usergroup, team_idx)
					ret = ret + 1
				end 	
			end
		end

		return ret
	end

	function WHITE_LIST:whitelist(ply, ply_faction)
		if (!IsValid(ply)) then return end

		return bwhitelist(ply, ply_faction)
	end

	return 
end