include ("autorun/common.lua")

local g_my_ply_profile_panel = g_my_ply_profile_panel or nil
local g_ply_profiles_list_view = g_ply_profiles_list_view or nil
local g_ply_current_profile = g_ply_current_profile or nil

--ScreenScale scales font sizes to the screen, change the value in brackets to change its size.
surface.CreateFont( "intro_font", {
	font = "Arial", 
	extended = false,
	size = ( ScreenScale ( 10 ) ),
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
} )

surface.CreateFont( "button_font_txt", {
	font = "Arial", 
	extended = false,
	size = ( ScreenScale ( 9 ) ),
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
} )

surface.CreateFont( "label_fnt_txt", {
	font = "Arial", 
	extended = false,
	size = ( ScreenScale ( 8 ) ),
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
} )


local cis_http_img = [[http://media.moddb.com/cache/images/mods/1/13/12172/thumb_620x2000/droid_symbol.png]]
local neutral_http_img = [[http://a.dilcdn.com/bl/wp-content/uploads/sites/6/2013/12/Krybes.png]]
local republic_http_img = [[https://upload.wikimedia.org/wikipedia/commons/thumb/e/e0/Galactic_Republic.svg/1024px-Galactic_Republic.svg.png]]
local COLOR_AZURE = Color(240, 255, 255, 255)

function add_new_html_img_btn(html, callback, x, y, w, h, parent_obj)
	local htmlimg = vgui.Create("HTML", parent_obj)
	-- "<img src=\"".. cis_http_img .. "\" width=\"%s\" height=\"%s\" alt=\" Click here to join CIS! \" /></a>"
	htmlimg:SetPos(x, y)
	htmlimg:SetSize(w, h)
	htmlimg.img_w = w - (w * .22)
	htmlimg.img_h = h - (h * .22)

	print (string.format("FULL CORDS x = %d y = %d w = %d h = %d\n", x, y, w, h))
	print (string.format("IMG CORDS x = %d y = %d w = %d h = %d\n", x, y, htmlimg.img_w, htmlimg.img_h))

	htmlimg:SetHTML(string.format(html, htmlimg.img_w, htmlimg.img_h))

	htmlimg.Think = function()
		if (htmlimg:IsLoading() || htmlimg.has_loaded_img) then return end

		htmlimg.has_loaded_img = 1
		htmlimg.button = vgui.Create("DImageButton", parent_obj)
		htmlimg.button:SetPos(x, y)
		htmlimg.button:SetSize(w, h)
		htmlimg.button.DoClick = callback
	end

	return htmlimg
end

-- Creates new table that belongs to a form (table). 
function mk_new_form_field(obj, obj_name, val, field_validator, max_len)
	if (obj == nil) then obj = {} end 

	obj.max_len = max_len
	obj.name = obj_name
	obj.validate_submit = field_validator
	obj.val = val
	obj.invalid_label = nil

	if (obj.GetText == nil) then -- don't want to override the obj version of GetText() if obj is not NULL
		function obj:GetText() return tostring(obj.val) end
	end

	return obj
end

-- local ply_name_text_entry = add_str_request_to_panel(PCreatemain_parent_panel, nil, nil, 
														 -- MAX_TEXT_LEN, true, "name", 
														 -- ScrW() * .26, ScrH() * .51, ScrW() / 3, ScrH() / 25)

function add_str_request_to_panel(parent_obj, title, font, max_len, editable, new_obj_name, x, y, l, h)
	if (title) then
		surface.SetFont(font)
		local text_width, text_height = surface.GetTextSize(title)
		local label = vgui.Create("DLabel", parent_obj)

		label:SetPos(x, y - text_height - 5)
		label:SetSize(text_width * text_width, text_height + 2)
		label:SetFont("label_fnt_txt")
		label:SetText(title)
		label:SetTextColor(COLOR_AZURE)
	end

	local text_entry = vgui.Create("DTextEntry", parent_obj)
	text_entry:SetEditable(editable)
	text_entry:SetPos(x, y)
	text_entry:SetSize(l, h) 

	mk_new_form_field(text_entry, new_obj_name, nil, validate_text_field, max_len)

	return text_entry
end

-- return nil on failure
function send_new_profile_request(req)
		if (!req || type(req) != "table" || !req.faction_name || !req.name || !req.description) then return end
		local profile_id = "" -- We do not have an edit feature yet, but it is supported on the back end ;)
		local faction_name = req.faction_name
		local faction_id = -1

		-- NOTE: The values for faction_name (e.g CIS) are specific to what they 
		-- 	are set to in the button_ctx callback functions
		if (faction_name == "Sith") then 
			faction_id = PROFILE_FACTION_CIS 
		elseif (faction_name == "Jedi") then 
			faction_id = PROFILE_FACTION_REPUBLIC
		else
			return nil
		end

		net.Start("player_add_or_update_profile")
			net.WriteString(profile_id)
			net.WriteInt(faction_id, 32)
			net.WriteString(req.name)
			net.WriteString(req.description)
		net.SendToServer()

		return 1
end

-- return nil on failure
function try_profile_form_submit(fields, parent_obj)
	-- if (ply_name_text_entry && try_form_submit({ply_name_text_entry, PCreatemain_parent_panel.faction_name}, PCreatemain_parent_panel)) then 
	local ret = nil
	local form = {}
	local send_form_to_server = true
	local error_msg = nil

	for _, form_field in pairs(fields) do
		if (!form_field) then return ret end

		if (form_field.validate_submit) then -- this should be removed in the future, only here b/c description isn't supported yet
			error_msg = form_field.validate_submit(form_field:GetText(), form_field.max_len)
		end 

		if (error_msg) then 
			send_form_to_server = false

			if (form_field.GetBounds) then
				local x, y, w, h = form_field:GetBounds()
				form_field:SetText("")

				if (form_field.invalid_label) then form_field.invalid_label:Remove() end 

				local label = vgui.Create("DLabel", parent_obj)
				label:SetPos(x + w + 10, y)
				label:SetSize(w, h)
				label:SetFont("label_fnt_txt")
				label:SetDrawBackground(false)
				label:SetTextColor(Color(255, 0, 0))
				label:SetText(error_msg)

				form_field.invalid_label = label
			else 
				print("--------------------------------- [ERROR] Invalid field " .. form_field.name .. " : " .. error_msg .. " ---------------------------------")
			end
		else 
			form[form_field.name] = form_field:GetText() 
			if (form_field.invalid_label) then form_field.invalid_label:Remove() form_field.invalid_label = nil end 
		end
	end

	if (send_form_to_server) then 
		-- send data to server if validated ...
		ret = send_new_profile_request(form)
		if (ret) then 
			g_my_ply_profile_panel = nil
			parent_obj:Remove()
		end
	end

	return ret
end

function rec_ply_profiles(len, _)
	local update_type = net.ReadInt(32)
	local ctx = net.ReadTable()
	local ply = LocalPlayer()
	local remaining_profile_cnt = 1
	local current_profile_cnt = 0

	if (!update_type || update_type == 0) then g_ply_current_profile = nil end 

	if (ctx) then
		if (ctx["can_create_new_profile"]) then
			remaining_profile_cnt = ctx["can_create_new_profile"]
		end

		if (ctx["profiles"]) then
			current_profile_cnt = #ctx["profiles"]
		end
	end
	
	timer.Simple(0, function() 
						g_my_ply_profile_panel = vgui.Create("profile_welcome_menu") 
						g_my_ply_profile_panel:set_data(remaining_profile_cnt, current_profile_cnt, g_ply_current_profile)
					end)
end

net.Receive("reload_player_profiles", rec_ply_profiles)

net.Receive("to_cl_loaded_player_profile", function(len, _) 
	g_ply_current_profile = net.ReadTable()

	print ("Loaded character: ")

	if (g_ply_current_profile) then PrintTable(g_ply_current_profile) end 

	/* Removes main menu that lets you create a new profile...
	if (g_my_ply_profile_panel) then 
		g_my_ply_profile_panel:Remove()
		g_my_ply_profile_panel = nil
	end 
	*/
end)

/*---------------------------------------------------------------------------
Display notifications

Got this from here: https://facepunch.com/showthread.php?t=1511691
---------------------------------------------------------------------------*/
local function DisplayNotify(msg)
    local txt = msg:ReadString()
    GAMEMODE:AddNotify(txt, msg:ReadShort(), msg:ReadLong())
    surface.PlaySound("buttons/lightswitch2.wav")

    -- Log to client console
    MsgC(Color(255, 20, 20, 255), "[DarkRP] ", Color(200, 200, 200, 255), txt, "\n")
end
usermessage.Hook("_Notify", DisplayNotify)




/* 

	Debug console commands

*/

concommand.Add("pedit", function() 
	if (g_my_ply_profile_panel) then 
		g_my_ply_profile_panel:Remove()
		g_my_ply_profile_panel = nil 
	end

	g_my_ply_profile_panel = vgui.Create("PlayerFactionCreateNewScrn") 
end)

concommand.Add("pclose", function() 
	if (g_my_ply_profile_panel) then 
		g_my_ply_profile_panel:Remove()
		g_my_ply_profile_panel = nil 
	end
end)

concommand.Add("tpload", function(ply, cmd, args, argStr) 
	local unique_profile_id_number = args[1]

	if (!unique_profile_id_number) then return end

	net.Start("player_load_profile")
		net.WriteString(unique_profile_id_number)
	net.SendToServer()
end)

concommand.Add("cchar", function(ply, cmd, args, argStr)

	net.Start("notify_server_reload_all_profiles")
	net.SendToServer()
end)

concommand.Add("ppload", function()
	local profile = g_ply_current_profile
	
	if (profile) then
		PrintTable(profile)
	else 
		print ("---------- NO PROFILE LOADED -----------")
	end
end)
