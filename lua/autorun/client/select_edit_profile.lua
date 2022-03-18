local g_profiles_view = g_profiles_view or nil
local PANEL = {}

function PANEL:reload_data(data, current_prof, new_profile_limit)
	local show_close_button = false 

	if (current_prof) then show_close_button = true end

	self:ShowCloseButton(show_close_button)
	self.data:Clear()

	if (!data) then return end

	for k, v in pairs(data) do
		print ("------------------------------- v.PROFILE_ID " .. v.PROFILE_ID .. " -------------------------------")
		self.data:AddLine(v.PROFILE_ID, get_faction_str(v.CHAR_FACTION), v.PLAYER_PROFILE_NAME, v.PLAYER_PROFILE_DESC)
	end

	if (new_profile_limit > 0 && !self.new_prof_button) then
		local b3 = vgui.Create("DButton", self.button_panel)
		b3.Paint = function(b3, w, h) draw.RoundedBox(8, 0, 0, w, h, Color(0, 128, 255)) end
		b3:Dock(TOP)
		b3:SetDrawBackground(false)
		b3:DockMargin(1, 4, 1, 0)
		b3:SetColor(color_black)
		b3:SetText("Create new profile")
		b3.DoClick = function() 
			self:Remove()
			RunConsoleCommand("pedit")
		end

		self.new_prof_button = b3
	end

end

function PANEL:Init()
	if (g_profiles_view) then 
		g_profiles_view:Remove()
	end

	g_profiles_view = self
	self.new_prof_button = nil

	COLOR_TEAM_BLUE = Color( 153, 204, 255, 255 )

	self:SetSize(750, 350)
	self:SetTitle("Select/Edit your profile")
	self:Center()
	self:MakePopup(true)

	local AppList = vgui.Create("DListView", self)
	AppList:SetPos(3, 28)
	AppList:SetSize(600, 318)
	AppList:DockPadding(0, 0, 0, 0)
	--panel:SetDrawBackground(false)
	AppList:SetMultiSelect(false)
	AppList.Paint = function(AppList, w, h) 
		draw.RoundedBox(8, 0, 0, w, h, Color(255, 255, 255, 200))
	end

	self.data = AppList

	AppList:AddColumn("Profile ID")
	AppList:AddColumn("Faction")
	AppList:AddColumn("Name")
	AppList:AddColumn("Description")

	local right_panel = vgui.Create("DPanel", self)
	right_panel:SetText("RIGHT")
	right_panel:SetSize(140, 0)
	right_panel:Dock(RIGHT)
	right_panel.Paint = function(right_panel, w, h) 
		draw.RoundedBox(8, 0, 0, w, h, COLOR_TEAM_BLUE)
	end

	self.button_panel = right_panel

	/*
	local b = vgui.Create("DButton", self.button_panel)
	b.Paint = function(b, w, h) draw.RoundedBox(8, 0, 0, w, h, Color(0, 128, 255)) end
	b:Dock(TOP)
	b:SetDrawBackground(false)
	b:DockMargin(1, 4, 1, 0)
	b:SetColor(color_black)
	b:SetText("Update profile")
	b.DoClick = function() 
		local sr = self.data:GetSelected()[1]
		local faction = nil
		local name = nil
		local desc = nil

		if (!sr) then return end

		profile_id = tonumber(sr:GetColumnText(1))
		--faction = sr:GetColumnText(2)
		name = sr:GetColumnText(3)
		desc = sr:GetColumnText(4)

		if (!is_valid_text_entry(name, 128) || !is_valid_text_entry(desc, 128)) then return end


	end
	*/

	local b2 = vgui.Create("DButton", self.button_panel)
	b2.Paint = function(b2, w, h) draw.RoundedBox(8, 0, 0, w, h, Color(0, 128, 255)) end
	b2:Dock(TOP)
	b2:SetDrawBackground(false)
	b2:DockMargin(1, 4, 1, 0)
	b2:SetColor(color_black)
	b2:SetText("Select profile")
	b2.DoClick = function() 
		local sr = self.data:GetSelected()[1]
		local id = nil

		if (!sr) then return end

		id = sr:GetColumnText(1)
		if (id) then
			net.Start("player_load_profile")
				net.WriteString(id)
			net.SendToServer()
		end 
	end
end

function PANEL:OnRemove()
	g_profiles_view = nil
end

vgui.Register("PlayerFactionSelectScrn", PANEL, "DFrame")