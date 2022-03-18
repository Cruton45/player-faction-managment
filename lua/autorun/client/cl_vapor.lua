local JEDI_MDL = "models/jazzmcfly/jka/younglings/jka_young_male.mdl"
local SITH_MDL = "models/grealms/characters/sithtrainee/sithtrainee_03.mdl"
local NULL_MDL = "models/player/Group01/male_01.mdl"

local MAX_TEXT_LEN = 64

local profile_welcome_menu = {}

function profile_welcome_menu:set_data(remaining_profile_cnt, current_profile_cnt, g_ply_current_profile)
	self.remaining_profile_cnt = remaining_profile_cnt
	self.current_profile_cnt = current_profile_cnt
	self.g_ply_current_profile = g_ply_current_profile
end

function profile_welcome_menu:Init()
	local Frame = vgui.Create( "DFrame" )
	Frame:SetTitle("")
	Frame:SetSize( ScrW(), ScrH() )
	Frame:Center()
	Frame:MakePopup()
	Frame:ShowCloseButton( false )
	Frame.Paint = function( self, w, h ) 
		draw.RoundedBox( 20, 0, 0, w, h, Color( 0, 0, 0, 250 ) )
	end
	-------------------------------------------------------------------------- Mainmenu Background
	local img_bg_m_p = vgui.Create( "DImage", Frame )
	img_bg_m_p:SetSize( Frame:GetSize() )
	img_bg_m_p:SetImage( "entities/Main_Menu_None_slct.png" )

	-------------------------------------------Profile Create Button
	local Btn_Player_Create = vgui.Create ( "DButton", Frame )
	Btn_Player_Create:SetText( "" )
	Btn_Player_Create:SetTextColor( Color( 255, 255, 255 ) )
	Btn_Player_Create:SetPos( ScrW() * .09, ScrH() * .35 )-- 175 , 378 
	Btn_Player_Create:SetSize( ScrW() / 7, ScrH() / 18)
	Btn_Player_Create.Paint = function( self, w, h )
		draw.RoundedBox( 17, 0, 0, w, h, Color( 41, 128, 185, 0 ) ) 
	end
	Btn_Player_Create.DoClick = function()
		Frame:Close()
	--------------------------------------------------- player  create frame
		vgui.Create("PCreateFrame")
	end
	
	--------------------------------------------------------------------------------------------- Choose Button  
	local Btn_Player_Choose = vgui.Create ( "DButton", Frame )
	Btn_Player_Choose:SetText( "" )
	Btn_Player_Choose:SetTextColor( Color( 255, 255, 255 ) )
	Btn_Player_Choose:SetPos( ScrW() * .09, ScrH() * .47)
	Btn_Player_Choose:SetSize( ScrW() / 6.5, ScrH() / 18)
	Btn_Player_Choose.Paint = function( self, w, h )
		draw.RoundedBox( 17, 0, 0, w, h, Color( 41, 128, 185, 0 ) ) 
	end
	Btn_Player_Choose.DoClick = function()
		Frame:Close()
		----------------------------------------------------------------------- Profile Choose Frame
		local PChooseFrame = vgui.Create( "DFrame")
		PChooseFrame:SetTitle("")
		PChooseFrame:SetSize( ScrW(), ScrH() )
		PChooseFrame:Center()
		PChooseFrame:MakePopup()
		PChooseFrame:ShowCloseButton( false )
		PChooseFrame.Paint = function( self, w, h ) 
			draw.RoundedBox( 20, 0, 0, w, h, Color( 0, 0, 0, 250 ) )
		end
		
		------------------------------------------------------------------------------------------------------------ Back Button From Choose Frame
		local Btn_Bck_f_ChooseFrame = vgui.Create ( "DButton",  PChooseFrame )
		Btn_Bck_f_ChooseFrame:SetText( "Back" )
		Btn_Bck_f_ChooseFrame:SetTextColor( Color( 255, 255, 255 ) )
		Btn_Bck_f_ChooseFrame:SetPos( ScrW() * .05, ScrH() * .93)
		Btn_Bck_f_ChooseFrame:SetSize( ScrW() / 5, ScrH() / 25)
		Btn_Bck_f_ChooseFrame.Paint = function( self, w, h )
			draw.RoundedBox( 17, 0, 0, w, h, Color( 41, 128, 185, 250 ) ) 
		end
		Btn_Bck_f_ChooseFrame.DoClick = function()
			PChooseFrame:Close()
			vgui.Create("profile_welcome_menu")
		end
	end
	
	-------------------------------------------------------------------------------------------------- Discord Button
	local Btn_Discord = vgui.Create ( "DButton", Frame )
	Btn_Discord:SetText( "" )
	Btn_Discord:SetTextColor( Color( 255, 255, 255 ) )
	Btn_Discord:SetPos( ScrW() * .09, ScrH() * .59)
	Btn_Discord:SetSize( ScrW() / 6, ScrH() / 18)
	Btn_Discord.Paint = function( self, w, h )
		draw.RoundedBox( 17, 0, 0, w, h, Color( 41, 128, 185, 0 ) ) 
	end
	Btn_Discord.DoClick = function()
 		local discord_link_var = "https://discord.gg/c5GkZWY"
		SetClipboardText( discord_link_var )
		gui.OpenURL( discord_link_var )
	end
	
	------------------------------------------------------------------------------------------------------ Exit Button
	local Btn_Exit = vgui.Create ( "DButton", Frame )
	Btn_Exit:SetText( "" )
	Btn_Exit:SetTextColor( Color( 255, 255, 255 ) )
	Btn_Exit:SetPos( ScrW() * .09, ScrH() * .71 )
	Btn_Exit:SetSize( ScrW() / 12, ScrH() / 20)
	Btn_Exit.Paint = function( self, w, h )
		draw.RoundedBox( 17, 0, 0, w, h, Color( 0, 0, 185, 0 ) ) 
	end
	Btn_Exit.DoClick = function()
		Frame:Close()
		-------------------------------------------------------------------------------------------------------- Exit Frame	
		local Exit_CheckFrame = vgui.Create( "DFrame")
		Exit_CheckFrame:SetTitle("")
		Exit_CheckFrame:SetSize( ScrW() / 2, ScrH() / 2 )
		Exit_CheckFrame:Center()
		Exit_CheckFrame:MakePopup()
		Exit_CheckFrame:ShowCloseButton( false )
		
		-------------------------------------------------------------------------------------------------------- Exit Frame Background
		local img_bg_exit_frame = vgui.Create( "DImage", Exit_CheckFrame )
		img_bg_exit_frame:SetSize( Exit_CheckFrame:GetSize() )
		img_bg_exit_frame:SetImage( "entities/exitmenu_nonselect.png" )
		-------------------------------------------------------------------------------------------------------------------------------
		Exit_CheckFrame.Paint = function( self, w, h ) 
			draw.RoundedBox( 20, 0, 0, w, h, Color( 0, 0, 0, 250 ) )
		end
		------------------------------------------------------------------------------------------------------------------------- Exit Frame Yes Button
		local Btn_Y_Exit = vgui.Create ( "DButton", Exit_CheckFrame  )
		Btn_Y_Exit:SetText( "" )
		Btn_Y_Exit:SetTextColor( Color( 255, 255, 255 ) )
		Btn_Y_Exit:SetPos( ScrW() * .05, ScrH() * .39)
		Btn_Y_Exit:SetSize( ScrW() / 11, ScrH() / 18)
		Btn_Y_Exit.Paint = function( self, w, h )
			draw.RoundedBox( 17, 0, 0, w, h, Color( 41, 128, 185, 0 ) ) 
		end
		Btn_Y_Exit.DoClick = function()
			Exit_CheckFrame:Close()
			RunConsoleCommand( "Disconnect" ) 
		end
---------------------------------------------------------------------------------------------------------------------Exit Frame No Button
		local Btn_N_Exit = vgui.Create ( "DButton", Exit_CheckFrame  )
		Btn_N_Exit:SetText( "" )
		Btn_N_Exit:SetTextColor( Color( 255, 255, 255 ) )
		Btn_N_Exit:SetPos( ScrW() * .36 , ScrH() * .39)
		Btn_N_Exit:SetSize( ScrW() / 15, ScrH() / 18)
		Btn_N_Exit.Paint = function( self, w, h )
			draw.RoundedBox( 17, 0, 0, w, h, Color( 41, 128, 185, 0 ) ) 
		end
		Btn_N_Exit.DoClick = function()
			Exit_CheckFrame:Close()
			vgui.Create("profile_welcome_menu")
		end
	end
end

local PCreateFrame = {}

function PCreateFrame:Init()
	local PCreateFrame = vgui.Create( "DFrame")
	PCreateFrame:SetTitle("")
	PCreateFrame:SetSize( ScrW(), ScrH() )
	PCreateFrame:Center()
	PCreateFrame:MakePopup()
	PCreateFrame:ShowCloseButton( false )
	PCreateFrame.Paint = function( self, w, h ) 
		draw.RoundedBox( 20, 0, 0, w, h, Color( 0, 0, 0, 250 ) )
	end

	----------------------------------------------------------------------------------------- Player Create Background
	local img_bg_Pc = vgui.Create( "DImage", PCreateFrame )
	img_bg_Pc:SetSize( PCreateFrame:GetSize() )
	img_bg_Pc:SetImage( "entities/baseccmenu_n.png" )

	-----------------------------------------------------------------------------------------  Player Model Viewer
	local Ply_Model = vgui.Create( "DModelPanel", PCreateFrame )
	Ply_Model:SetSize( ScrW() / 3, ScrH() / 1.5 )
	Ply_Model:SetPos(ScrW() * .57, ScrH() * .28)
	Ply_Model:SetModel( NULL_MDL  )---------- Null Model is for when player has not clicked on faction buttons yet.
	function Ply_Model:LayoutEntity( Entity ) return end -- disables default rotation
	function Ply_Model.Entity:GetPlayerColor() return Vector ( 1, 0, 0 ) end --we need to set it to a Vector not a Color, so the values are normal RGB values divided by 255.
	--------------------------------------------------------------------------------------------------------------------- Jedi Button
	local Jedi_Button = vgui.Create ( "DButton",  PCreateFrame )
	Jedi_Button:SetText( "" )
	Jedi_Button:SetTextColor( Color( 255, 255, 255 ) )
	Jedi_Button:SetPos( ScrW() * .26, ScrH() * .63)
	Jedi_Button:SetSize( ScrW() / 8, ScrH() / 5)
	Jedi_Button.Paint = function( self, w, h )
		draw.RoundedBox( 17, 0, 0, w, h, Color( 41, 128, 185, 0 ) ) 
	end
	Jedi_Button.DoClick = function()
		local faction = "Jedi"									
		Ply_Model:SetModel( JEDI_MDL  )
		PCreateFrame.faction = faction
	end

	---------------------------------------------------------------------------------------------------------------- Sith Button
	local Sith_Button = vgui.Create ( "DButton",  PCreateFrame )
	Sith_Button:SetText( "" )
	Sith_Button:SetTextColor( Color( 255, 255, 255 ) )
	Sith_Button:SetPos( ScrW() * .46, ScrH() * .63)
	Sith_Button:SetSize( ScrW() / 8, ScrH() / 5)
	Sith_Button.Paint = function( self, w, h )
		draw.RoundedBox( 17, 0, 0, w, h, Color( 41, 128, 185, 0 ) )
	end
	Sith_Button.DoClick = function()
		local faction = "Sith"
		Ply_Model:SetModel( SITH_MDL )
		PCreateFrame.faction = faction
	end
	
	----------------------------------------------------------------------------------------- Player Name Text Entry
	local ply_name_text_entry = add_str_request_to_panel(PCreateFrame, nil, nil, 
														 MAX_TEXT_LEN, true, "name", 
														 ScrW() * .26, ScrH() * .51, ScrW() / 3, ScrH() / 25)


	------------------------------------------------------------------------------------------ Back Button For Player Create Frame
	local Btn_Bck_f_CreateFrame = vgui.Create ( "DButton",  PCreateFrame )
	Btn_Bck_f_CreateFrame:SetText( "" )
	Btn_Bck_f_CreateFrame:SetTextColor( Color( 255, 255, 255 ) )
	Btn_Bck_f_CreateFrame:SetPos( ScrW() * .02, ScrH() * .94)
	Btn_Bck_f_CreateFrame:SetSize( ScrW() / 10, ScrH() / 25)
	Btn_Bck_f_CreateFrame.Paint = function( self, w, h )
		draw.RoundedBox( 17, 0, 0, w, h, Color( 41, 128, 185, 0 ) ) 
	end
	Btn_Bck_f_CreateFrame.DoClick = function()
		PCreateFrame:Close()
		vgui.Create("profile_welcome_menu")
	end
	
	----------------------------------------------------------------------------------------------------- Submit Player Profile Button
	local submit_button = vgui.Create ( "DButton",  PCreateFrame )
	submit_button:SetText( "" )
	submit_button:SetTextColor( Color( 255, 255, 255 ) )
	submit_button:SetPos( ScrW() * .64, ScrH() * .94)
	submit_button:SetSize( ScrW() / 5, ScrH() / 25)
	submit_button.Paint = function( self, w, h )
		draw.RoundedBox( 17, 0, 0, w, h, Color( 41, 128, 185, 0 ) ) 
	end
	submit_button.DoClick = function()
		-- PCreateFrame:Close()
		local faction_selection = mk_new_form_field(nil, "faction_name", 
												  PCreateFrame.faction, 
												  validate_text_field, MAX_TEXT_LEN)

		-- Temporary until we get a real desc panel
		local default_desc = mk_new_form_field(nil, "description", "DEFAULT", nil, MAX_TEXT_LEN)

		local new_req_obj = {ply_name_text_entry, faction_selection, default_desc}

		if (ply_name_text_entry && try_profile_form_submit(new_req_obj, PCreateFrame)) then 
			PCreateFrame:Close()
		end 
	end
end

vgui.Register("profile_welcome_menu", profile_welcome_menu, "DFrame")
vgui.Register("PCreateFrame", PCreateFrame, "DFrame")
