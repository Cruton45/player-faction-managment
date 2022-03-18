-- Put this file in your addons\ulx\lua\ulx\modules\sh folder
-- Also for this addon to work, you need to change the function playerSend from a local function to global.
-- The function is located in addons\ulx\lua\ulx\modules\sh\teleport.lua and is on line 34

fTPOption = 0
local CATEGORY_NAME = "Battalion TP"
local calling_ply = ply

function Initialize()
	tables_exist()
end
 
function ulx.fgotooff(calling_ply)
    if not calling_ply:IsValid() then
        Msg( "You can not call this command in console.\n" )
        return
    end
	calling_ply:ChatPrint( calling_ply:Nick() .. " has set fgoto to off." ) 
	fTPOption = 1
	print( fTPOption )
end

local fgotooff = ulx.command( CATEGORY_NAME, "ulx fgotooff", ulx.fgotooff, "!fgotooff", false)

fgotooff:defaultAccess( ULib.ACCESS_ADMIN )
fgotooff:help( "Disables battalion teleporting" )

------------------------------------------------------------------------------------------------- FGOTOON Command

function ulx.fgotoon(calling_ply)

    if not calling_ply:IsValid() then
        return
    end
	calling_ply:ChatPrint( calling_ply:Nick() .. " has set fgoto to on." ) 
	fTPOption = 0
	print( fTPOption )
end
local fgotoon = ulx.command( CATEGORY_NAME, "ulx fgotoon", ulx.fgotoon, "!fgotoon", false )
fgotoon:defaultAccess( ULib.ACCESS_ADMIN )
fgotoon:help( "Enables battalion teleporting" )

--------------------------------------------------------------------------------------------------------------------- FGOTO  COMMAND

function ulx.fgoto( calling_ply, target_ply )
	ply_timer_name = tostring(calling_ply:SteamID())
	banval2 = sql.QueryValue("SELECT banval FROM playerGotoBanDB WHERE unique_id = '".. calling_ply:SteamID() .."'")
	if not calling_ply:IsValid() then
		Msg( "You may not step down into the mortal world from console.\n" )
		return
	end
	
	if target_ply:GetNWInt("pval") == 1 then
		ULib.tsayError( calling_ply, "Can't fgoto. " .. target_ply:Nick().. " has disabled fgoto for themselves.", true )
		return
	end
	
	if target_ply:Team() != calling_ply:Team() then
		ULib.tsayError( calling_ply, "Can't fgoto. You are not in the same team.", true )
		return
	end
	if tonumber(banval2) == 1 then
		ULib.tsayError( calling_ply, "Can't fgoto. You are banned from fgoto", true )
		return
	end

	if fTPOption == 1 then 
		ULib.tsayError( calling_ply, "Can't fgoto. fgoto has been disabled", true )
		return	
	end
	if calling_ply:GetNWInt("cooldown") == 1 then 
		ULib.tsayError( calling_ply, "fgoto on cool down for another " .. math.Round(timer.TimeLeft(ply_timer_name)) .. " seconds" , true )
		return	
	end
	if ulx.getExclusive( calling_ply, calling_ply ) then
		ULib.tsayError( calling_ply, ulx.getExclusive( calling_ply, calling_ply ), true )
		return
	end

	if not target_ply:Alive() then
		ULib.tsayError( calling_ply, target_ply:Nick() .. " is dead!", true )
		return
	end

	if not calling_ply:Alive() then
		ULib.tsayError( calling_ply, "You are dead!", true )
		return
	end

	if target_ply:InVehicle() and calling_ply:GetMoveType() ~= MOVETYPE_NOCLIP then
		ULib.tsayError( calling_ply, "Target is in a vehicle! Noclip and use this command to force a goto.", true )
		return
	end

	local newpos = playerSend( calling_ply, target_ply, calling_ply:GetMoveType() == MOVETYPE_NOCLIP )
	if not newpos then
		ULib.tsayError( calling_ply, "Can't find a place to put you! Noclip and use this command to force a goto.", true )
		return
	end

	if calling_ply:InVehicle() then
		calling_ply:ExitVehicle()
	end
	local newang = (target_ply:GetPos() - newpos):Angle()

	calling_ply:SetPos( newpos )
	calling_ply:SetEyeAngles( newang )
	calling_ply:SetLocalVelocity( Vector( 0, 0, 0 ) )
	ulx.fancyLogAdmin( calling_ply, "#A teleported to #T", target_ply, true )
	calling_ply:SetNWInt("cooldown", 1)
	timer.Create( ply_timer_name, 60, 1, function() calling_ply:SetNWInt("cooldown", 0) end )
end

local CATEGORY_NAME = "Battalion TP"

local fgoto = ulx.command( CATEGORY_NAME, "ulx fgoto", ulx.fgoto, "!fgoto", false )
fgoto:addParam{ type=ULib.cmds.PlayerArg, target="!^", ULib.cmds.ignoreCanTarget }
fgoto:defaultAccess( ULib.ACCESS_ADMIN )
fgoto:help( "Goto a player that is in the same battalion as yourself." )
-----------------------------------------------------------------------------------------------------------------FGOTOBAN COMMAND
function ulx.fgotoban(calling_ply, target_ply)
	banval2 = sql.QueryValue("SELECT banval FROM playerGotoBanDB WHERE unique_id = '".. target_ply:SteamID() .."'")
    if not calling_ply:IsValid() then
        return
    end
	if tonumber(banval2) == 1 then
		ULib.tsayError( calling_ply, " Can't ban " .. target_ply:Nick() .. "! User is already banned.")
		return
	end
	
	target_ply:SetNWString("unique_id", target_ply:SteamID())
	target_ply:SetNWInt( "banval", 1 )
	calling_ply:ChatPrint( calling_ply:Nick() .. " has banned " .. target_ply:Nick() .. " from using ulx fgoto!" )
	target_ply:ChatPrint( calling_ply:Nick() .. " has banned you from using ulx fgoto")
	sql.Query("UPDATE playerGotoBanDB SET banval = "..target_ply:GetNWInt("banval").." WHERE unique_id = '"..target_ply:GetNWString("unique_id").."'")
	
end
local fgotoban = ulx.command( CATEGORY_NAME, "ulx fgotoban", ulx.fgotoban, "!fgotoban", false )
fgotoban:addParam{ type=ULib.cmds.PlayerArg, target="!^", ULib.cmds.ignoreCanTarget }
fgotoban:defaultAccess( ULib.ACCESS_ADMIN )
fgotoban:help( "Bans players from using fgoto" )
--------------------------------------------------------------------------------------------------------------FGOTOUNBAN COMMAND
function ulx.fgotounban(calling_ply, target_ply)
	banval2 = sql.QueryValue("SELECT banval FROM playerGotoBanDB WHERE unique_id = '".. target_ply:SteamID() .."'")
    if not calling_ply:IsValid() then
        return
    end
	if tonumber(banval2) == 0 then
		ULib.tsayError( calling_ply, " Can't ban " .. target_ply:Nick() .. "! User is not banned.")
		return
	end
	
	calling_ply:ChatPrint( calling_ply:Nick() .. " has unbanned " .. target_ply:Nick() .. " from using ulx fgoto!" )
	target_ply:ChatPrint( calling_ply:Nick() .. " has unbanned you from using ulx fgoto")
	target_ply:SetNWString("unique_id", target_ply:SteamID())
	target_ply:SetNWInt( "banval", 0 )
	sql.Query("UPDATE playerGotoBanDB SET banval = "..target_ply:GetNWInt("banval").." WHERE unique_id = '"..target_ply:GetNWString("unique_id").."'")
	
end
local fgotounban = ulx.command( CATEGORY_NAME, "ulx fgotounban", ulx.fgotounban, "!fgotounban", false )
fgotounban:addParam{ type=ULib.cmds.PlayerArg, target="!^", ULib.cmds.ignoreCanTarget }
fgotounban:defaultAccess( ULib.ACCESS_ADMIN )
fgotounban:help( "Unbans players from using fgoto." )
-------------------------------------------------------------------------------------------------------------FGOTOPOFF COMMAND
function ulx.fgotopoff(calling_ply)
    if not calling_ply:IsValid() then
        return
    end
	calling_ply:ChatPrint( calling_ply:Nick() .. " has turned off ulx fgoto for himself." )
	calling_ply:SetNWInt( "pval", 1 )
end
local fgotopoff = ulx.command( CATEGORY_NAME, "ulx fgotopoff", ulx.fgotopoff, "!fgotopoff", false )
fgotopoff:defaultAccess( ULib.ACCESS_ADMIN )
fgotopoff:help( "Turns the ability of players to teleport to the calling player off." )
--------------------------------------------------------------------------------------------------------------FGOTOPON COMMAND
function ulx.fgotopon(calling_ply)
    if not calling_ply:IsValid() then
        return
    end
	calling_ply:ChatPrint( calling_ply:Nick() .. " has turned on ulx fgoto for himself." )
	calling_ply:SetNWInt( "pval", 0 )
end
local fgotopon = ulx.command( CATEGORY_NAME, "ulx fgotopon", ulx.fgotopon, "!fgotopon", false )
fgotopon:defaultAccess( ULib.ACCESS_ADMIN )
fgotopon:help( "Turns the ability of players to teleport to the calling player on." )

------------------------------------------------------------------------------------SQL Functionality
 
function sql_value_fgotobanval( ply )
	unique_id = sql.QueryValue("SELECT unique_id FROM playerGotoBanDB WHERE unique_id = '"..steamID.."'")
	banval = sql.QueryValue("SELECT banval FROM playerGotoBanDB WHERE unique_id = '"..steamID.."'")
	ply:SetNWString("unique_id", unique_id)
	ply:SetNWInt("banval", banval)
end


function tables_exist()
	if (sql.TableExists("playerGotoBanDB")) then
		Msg("ULX FGOTO: Mounting fgoto ban database!\n")
	else
		if (!sql.TableExists("playerGotoBanDB")) then
			query = "CREATE TABLE playerGotoBanDB( unique_id varchar(255), banval)"
			result = sql.Query(query)
			if (sql.TableExists("playerGotoBanDB")) then
				Msg("ULX FGOTO: The fgoto ban database has been created.\n")
				else
					Msg("ULX FGOTO: Somthing went wrong with the fgoto query ! \n")
					Msg( sql.LastError( result ) .. "\n" )
			end
		end
	end
end

function PlayerInitialSpawn( ply )
	timer.Create("Steam_id_delay", 1, 1, function()
		SteamID = ply:SteamID()
		ply:SetNWString("SteamID", SteamID)
		player_exists( ply ) 
	end)
 
 end
 
function player_exists( ply )
 
	steamID = ply:GetNWString("SteamID")
 
	result = sql.Query("SELECT unique_id, banval FROM playerGotoBanDB WHERE unique_id = '"..steamID.."'")
	if (result) then
		return
	else
		new_player( steamID, ply )
	end
end
function new_player( SteamID, ply )
	steamID = SteamID
	sql.Query( "INSERT INTO playerGotoBanDB (`unique_id`, `banval`)VALUES ('"..steamID.."', '0')" )
	result = sql.Query( "SELECT unique_id, banval FROM playerGotoBanDB WHERE unique_id = '"..steamID.."'" )
	if (result) then
		Msg("ULX FGOTO: Player account created !\n")
		sql_value_fgotobanval( ply )
	else
		Msg("ULX FGOTO: Something went wrong with creating a playerGotoBanDB entry !\n")
	end
end
hook.Add( "PlayerInitialSpawn", "PlayerInitialSpawn", PlayerInitialSpawn )
hook.Add( "Initialize", "Initialize", Initialize )