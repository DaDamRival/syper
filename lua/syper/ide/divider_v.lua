local settings = Syper.Settings.settings

----------------------------------------

local Divider = {}

function Divider:Init()
	self.div_size = 6
	self.div_pos = 0
	self.bottom = nil
	self.top = nil
	
	self.holding = false
	self.hold_offset = 0
	
	self.stick = 1
	
	self:SetCursor("sizens")
end

function Divider:Paint(w, h)
	surface.SetDrawColor(settings.style_data.ide_background)
	surface.DrawRect(0, self.div_pos, w, self.div_size)
end

function Divider:PerformLayout(w, h)
	if not self.bottom then return end
	if not self.top then return end
	
	if self.last_h then
		local div = self.last_h - h
		
		if self.stick == 0 then
			-- nothing, dont move
		elseif self.stick == 1 then
			self.div_pos = self.div_pos - div * (self.top:GetTall() / self.last_h)
		elseif self.stick == 2 then
			self.div_pos = self.div_pos - div
		end
	end
	self.last_h = h
	
	self.top:SetPos(0, 0)
	self.top:SetSize(w, self.div_pos)
	self.top:InvalidateLayout()
	
	self.bottom:SetPos(0, self.div_pos + self.div_size)
	self.bottom:SetSize(w, h - self.div_pos - self.div_size)
	self.bottom:InvalidateLayout()
end

function Divider:FocusPreviousChild(cur_focus)
	if cur_focus == nil then
		return self.bottom
	elseif cur_focus == self.bottom then
		return self.top
	end
end

function Divider:FocusNextChild(cur_focus)
	if cur_focus == nil then
		return self.top
	elseif cur_focus == self.top then
		return self.bottom
	end
end

function Divider:OnCursorMoved(x, y)
	if not self.holding then return end
	
	self.div_pos = y - self.hold_offset
	self:InvalidateLayout()
end

function Divider:OnMousePressed(key)
	if key ~= MOUSE_LEFT then return end
	
	local y = select(2, self:LocalCursorPos())
	if y >= self.div_pos and y <= self.div_pos + self.div_size then
		self.holding = true
		self.hold_offset = y - self.div_pos
		self:MouseCapture(true)
	end
end

function Divider:OnMouseReleased(key)
	if key ~= MOUSE_LEFT then return end
	
	self.holding = false
	self:MouseCapture(false)
end

function Divider:SetColor(clr)
	self.clr = clr
end

function Divider:SetBottom(panel)
	self.bottom = panel
	panel:SetParent(self)
end

function Divider:SetTop(panel)
	self.top = panel
	panel:SetParent(self)
end

function Divider:CenterDiv()
	self:GetParent():InvalidateLayout(true)
	self.div_pos = self:GetTall() / 2 - self.div_size / 2
end

function Divider:SetDivSize(size)
	local dif = size - self.div_size
	self.div_size = size
	self.div_pos = self.div_pos - dif / 2
end

function Divider:StickBottom()
	self.stick = 0
end

function Divider:StickCenter()
	self.stick = 1
end

function Divider:StickTop()
	self.stick = 2
end

vgui.Register("SyperVDivider", Divider, "SyperBase")