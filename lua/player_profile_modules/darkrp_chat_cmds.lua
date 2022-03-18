include ("autorun/common.lua")

local function COMM(ply, args)
    local DoSay = function(text)
        if ( text == "" ) then
            DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
            return ""
        end

        local col = team.GetColor(ply:Team())
        local col2 = Color(255, 51, 0, 255)
        local ply_faction_id = ply:get_faction_id()
        local faction_str = string.upper(get_faction_str(ply_faction_id))

        if ( not ply:Alive() ) then
            col2 = Color(255, 200, 200, 255)
            col = col2
        end
			
        for k, v in pairs(player.GetAll()) do
        	if (ply_faction_id == v:get_faction_id()) then 
            	DarkRP.talkToPerson(v, col, "[" .. faction_str .. "COMMS" .. "] " .. ply:Name(), col2, text, ply)
            end
        end
    end

    return args, DoSay
end

hook.Add("loadCustomDarkRPItems", "player_profile_load_comms", function() 
    ServerLog("[INFO] Loading custom DarkRP chat command /c (comms)")
    
    DarkRP.declareChatCommand {
        command = "c",
        description = "Communicate with everyone in your faction on the server.",
        delay = 1.5
     }

    DarkRP.defineChatCommand("c", COMM, true, 1.5)
end)
