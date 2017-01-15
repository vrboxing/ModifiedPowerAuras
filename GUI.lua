local stf = strfind
local _G = getglobal
local tinsert = table.insert
local tremove = table.remove
local UN = UnitName
local strform = string.format
local flr = floor
local strgfind = string.gfind
local strfind = string.find
local GT = GetTime
local tnbr = tonumber

local SELECTEDICON = "Interface\\Icons\\Ability_Warrior_BattleShout"

function MPOWA:TernaryReturn(id, var, real)
	if MPOWA_SAVE[id][var] == 0 then
		return true
	elseif MPOWA_SAVE[id][var] == true and real then
		return true
	elseif MPOWA_SAVE[id][var] == false and (not real) then
		return true
	end
end

function MPOWA:Pager(left)
	if left then
		if self.Page<=1 then
			self.Page = 1
		else
			self.Page = self.Page - 1
		end
	else
		if self.Page >= 10 then
			self.Page = 10
		else
			self.Page = self.Page + 1
		end
	end
	self:UpdatePage()
end

function MPOWA:UpdatePage()
	MPowa_MainFrame_Pages:SetText(self.Page.."/10")
	self:Show()
	self:Reposition()
end

function MPOWA:Show()
	local coeff = (self.Page - 1)*49
	local bool = false
	local p = self.NumBuffs-coeff
	if (p<=0) then
		p = self.NumBuffs
		bool = true
	end
	if (not self.Cloaded) then
		for i=1, 49 do
			if i<=self.NumBuffs then
				MPOWA:CreateButton(i)
			end
		end
		self.Cloaded = true
	end
	for i=1, 49 do
		if getglobal("ConfigButton"..i) then
			getglobal("ConfigButton"..i):Hide()
		end
	end
	local e = self.Page * 49
	if e>self.NumBuffs then
		e = self.NumBuffs
	end
	for i=(1+coeff), e do
		MPOWA:ApplyAttributesToButton(i, getglobal("ConfigButton"..(i-coeff)))
	end
	if self.NumBuffs > 0 and self.NumBuffs > coeff then
		getglobal("ConfigButton"..self.selected.."_Border"):Show()
	end
	MPowa_MainFrame:Show()
end

function MPOWA:CreateButton(i)
	local button = CreateFrame("Button", "ConfigButton"..i, MPowa_ButtonContainer, "MPowa_ContainerBuffButtonTemplate")
	MPOWA:ApplyAttributesToButton(i, button)
end

function MPOWA:CreateIcon(i)
	if not self.frames[i] then
		self.frames[i] = {}
	end
	CreateFrame("Frame", "TextureFrame"..i, UIParent, "MPowa_IconTemplate")
	self.frames[i][1] = _G("TextureFrame"..i)
	self.frames[i][2] = _G("TextureFrame"..i.."_Icon")
	self.frames[i][3] = _G("TextureFrame"..i.."_Timer")
	self.frames[i][4] = _G("TextureFrame"..i.."_Count")
	self.frames[i][1]:SetID(i)
	self.frames[i][1]:EnableMouse(0)
	self.frames[i][1]:Hide()
end

function MPOWA:ApplyConfig(i)
	local val = MPOWA_SAVE[i]
	self.frames[i][2]:SetTexture(val["texture"])
	self.frames[i][1]:SetAlpha(val["alpha"])
	self.frames[i][1]:ClearAllPoints()
	self.frames[i][1]:SetPoint("CENTER", UIParent, "CENTER", val["x"], val["y"])
	self.frames[i][1]:SetScale(val["size"])
	self.frames[i][3]:SetFont("Fonts\\FRIZQT__.ttf", val["fontsize"]*12, "OUTLINE")
	self.frames[i][3]:SetAlpha(val["fontalpha"])
	self.frames[i][3]:ClearAllPoints()
	self.frames[i][3]:SetPoint("CENTER", self.frames[i][1], "CENTER", val["fontoffsetx"], val["fontoffsety"])
	self.frames[i][2]:SetVertexColor(val.icon_r or 1, val.icon_g or 1, val.icon_b or 1)
	if val["usefontcolor"] then
		self.frames[i][3]:SetTextColor(val["fontcolor_r"],val["fontcolor_g"],val["fontcolor_b"],val["fontalpha"])
	end
end

function MPOWA:ApplyAttributesToButton(i, button)
	if not button then return end
	local coeff = (self.Page - 1)*49
	local p = (i-coeff)
	local bool = false
	if (p<=0) then
		p = i
		bool = true
	end
	button:ClearAllPoints()
	button:SetPoint("TOPLEFT",MPowa_ButtonContainer,"TOPLEFT",42*(p-1)+6 - floor((p-1)/7)*7*42,-11-floor((p-1)/7)*41)
	button:SetID(i)
	_G("ConfigButton"..p.."_Icon"):SetTexture(MPOWA_SAVE[i]["texture"])
	_G("ConfigButton"..p.."_Count"):SetText(i)
	_G("ConfigButton"..p.."_Border"):Hide()
	if not bool and i<=self.Page*49 then
		button:Show()
	else
		button:Hide()
	end
end

function MPOWA:AddAura()
	if self.NumBuffs < 490 then
		self.NumBuffs = self.NumBuffs + 1
		local coeff = (self.Page - 1)*49
		local bool = false
		local p = self.NumBuffs-coeff
		if (p<=0) then
			p = self.NumBuffs
			bool = true
		end
		if _G("ConfigButton"..(self.NumBuffs-coeff)) ~= nil then
			self:ApplyAttributesToButton(self.NumBuffs,_G("ConfigButton"..(self.NumBuffs-coeff)))
			if not self.frames[self.NumBuffs] then
				self:CreateIcon(self.NumBuffs)
			end
			self:ApplyConfig(self.NumBuffs)
		else
			self:CreateSave(self.NumBuffs)
			self:CreateIcon(self.NumBuffs)
			self:ApplyConfig(self.NumBuffs)
			self:CreateButton(p)
		end
		MPOWA_SAVE[self.NumBuffs]["used"] = true
		self:DeselectAll()
		if not bool then
			_G("ConfigButton"..p.."_Border"):Show()
		end
		self.selected = p
	end
end

function MPOWA:DeselectAll()
	for i=1, 49 do
		if not _G("ConfigButton"..i) then break end
		_G("ConfigButton"..i.."_Border"):Hide()
	end
end

function MPOWA:Remove()
	if ConfigButton1 then
		local coeff = (self.Page - 1)*49
		self.NumBuffs = self.NumBuffs - 1
		if (self.selected+coeff) == self.CurEdit then
			MPowa_ConfigFrame:Hide()
		end
		MPOWA_SAVE[self.selected+coeff]["used"] = false
		self.NeedUpdate[self.selected+coeff] = false
		if self.auras[MPOWA_SAVE[self.selected+coeff]["buffname"]] then
			if self:GetTableLength(self.auras[MPOWA_SAVE[self.selected+coeff]["buffname"]])>1 and self:GetTablePosition(self.auras[MPOWA_SAVE[self.selected+coeff]["buffname"]], self.selected+coeff) then
				tremove(self.auras[MPOWA_SAVE[self.selected+coeff]["buffname"]], self:GetTablePosition(self.auras[MPOWA_SAVE[self.selected+coeff]["buffname"]], self.selected+coeff))
				if self.active[self.selected+coeff] then
					self.active[self.selected+coeff] = false
				end
			else
				for cat, val in self.auras[MPOWA_SAVE[self.selected+coeff]["buffname"]] do
					if self.active[val] then
						self.active[val] = false;
					end
				end
			end
		end
		self:CreateSave(self.selected+coeff)
		self.auras[MPOWA_SAVE[self.selected+coeff]["buffname"]] = false
		self.frames[self.selected+coeff][1]:Hide()
		self.selected = self.NumBuffs-coeff
		if self.selected == 0 then
			self.selected = 1
		end
		self:Reposition()
		_G("ConfigButton"..self.selected.."_Border"):Show()
	end
end

function MPOWA:Reposition()
	local coeff = (self.Page - 1)*49
	for i=(1+coeff), self.NumBuffs +1 do
		if _G("ConfigButton"..(i-coeff)) then
			_G("ConfigButton"..(i-coeff)):Hide()
		end
	end
	local e = self.Page * 49
	if e>self.NumBuffs then
		e = self.NumBuffs
	end
	for i=(1+coeff), e do
		MPOWA:ApplyAttributesToButton(i,_G("ConfigButton"..(i-coeff)))
	end
end

function MPOWA:SelectAura(button)
	local coeff = (self.Page - 1)*49
	self.selected = button:GetID() - coeff
	self:DeselectAll()
	if _G("ConfigButton"..self.selected.."_Border") then
		_G("ConfigButton"..self.selected.."_Border"):Show()
	end
end

function MPOWA:Edit()
	if ConfigButton1 then
		local coeff = (self.Page - 1)*49
		self.CurEdit = self.selected+coeff
		for i=1, self.NumBuffs do
			if self.frames[i] then
				self.frames[i][1]:EnableMouse(false)
			end
		end
		if self.frames[self.CurEdit] then
			self.frames[self.CurEdit][1]:EnableMouse(1)
		end
		MPowa_ConfigFrame:Hide()
		MPowa_ConfigFrame_Container_1_Icon_Texture:SetTexture(MPOWA_SAVE[self.CurEdit].texture)
		MPowa_ConfigFrame_Container_1_Slider_Opacity:SetValue(MPOWA_SAVE[self.CurEdit].alpha)
		MPowa_ConfigFrame_Container_1_Slider_OpacityText:SetText(MPOWA_SLIDER_OPACITY.." "..MPOWA_SAVE[self.CurEdit].alpha)
		
		MPowa_ConfigFrame_Container_1_Slider_PosX:SetMinMaxValues(MPOWA:GetMinValues(MPOWA_SAVE[self.CurEdit].x),MPOWA:GetMaxValues(MPOWA_SAVE[self.CurEdit].x))
		MPowa_ConfigFrame_Container_1_Slider_PosX:SetValue(MPOWA_SAVE[self.CurEdit].x)
		MPowa_ConfigFrame_Container_1_Slider_PosXText:SetText(MPOWA_SLIDER_POSX.." "..MPOWA_SAVE[self.CurEdit].x)
		MPowa_ConfigFrame_Container_1_Slider_PosXLow:SetText(MPOWA:GetMinValues(MPOWA_SAVE[self.CurEdit].x))
		MPowa_ConfigFrame_Container_1_Slider_PosXHigh:SetText(MPOWA:GetMaxValues(MPOWA_SAVE[self.CurEdit].x))
		
		MPowa_ConfigFrame_Container_1_Slider_PosY:SetMinMaxValues(MPOWA:GetMinValues(MPOWA_SAVE[self.CurEdit].y),MPOWA:GetMaxValues(MPOWA_SAVE[self.CurEdit].y))
		MPowa_ConfigFrame_Container_1_Slider_PosY:SetValue(MPOWA_SAVE[self.CurEdit].y)
		MPowa_ConfigFrame_Container_1_Slider_PosYText:SetText(MPOWA_SLIDER_POSY.." "..MPOWA_SAVE[self.CurEdit].y)
		MPowa_ConfigFrame_Container_1_Slider_PosYLow:SetText(MPOWA:GetMinValues(MPOWA_SAVE[self.CurEdit].y))
		MPowa_ConfigFrame_Container_1_Slider_PosYHigh:SetText(MPOWA:GetMaxValues(MPOWA_SAVE[self.CurEdit].y))
		
		MPowa_ConfigFrame_Container_2_Slider_PosX:SetMinMaxValues(MPOWA:GetMinValues(MPOWA_SAVE[self.CurEdit].fontoffsetx),MPOWA:GetMaxValues(MPOWA_SAVE[self.CurEdit].fontoffsetx))
		MPowa_ConfigFrame_Container_2_Slider_PosX:SetValue(MPOWA_SAVE[self.CurEdit].fontoffsetx)
		MPowa_ConfigFrame_Container_2_Slider_PosXText:SetText(MPOWA_SLIDER_POSX.." "..MPOWA_SAVE[self.CurEdit].fontoffsetx)
		MPowa_ConfigFrame_Container_2_Slider_PosXLow:SetText(MPOWA:GetMinValues(MPOWA_SAVE[self.CurEdit].fontoffsetx))
		MPowa_ConfigFrame_Container_2_Slider_PosXHigh:SetText(MPOWA:GetMaxValues(MPOWA_SAVE[self.CurEdit].fontoffsetx))
		
		MPowa_ConfigFrame_Container_2_Slider_PosY:SetMinMaxValues(MPOWA:GetMinValues(MPOWA_SAVE[self.CurEdit].fontoffsety),MPOWA:GetMaxValues(MPOWA_SAVE[self.CurEdit].fontoffsety))
		MPowa_ConfigFrame_Container_2_Slider_PosY:SetValue(MPOWA_SAVE[self.CurEdit].fontoffsety)
		MPowa_ConfigFrame_Container_2_Slider_PosYText:SetText(MPOWA_SLIDER_POSY.." "..MPOWA_SAVE[self.CurEdit].fontoffsety)
		MPowa_ConfigFrame_Container_2_Slider_PosYLow:SetText(MPOWA:GetMinValues(MPOWA_SAVE[self.CurEdit].fontoffsety))
		MPowa_ConfigFrame_Container_2_Slider_PosYHigh:SetText(MPOWA:GetMaxValues(MPOWA_SAVE[self.CurEdit].fontoffsety))
		
		MPowa_ConfigFrame_Container_1_Slider_Size:SetValue(tonumber(MPOWA_SAVE[self.CurEdit].size))
		MPowa_ConfigFrame_Container_1_Slider_SizeText:SetText(MPOWA_SLIDER_SIZE.." "..MPOWA_SAVE[self.CurEdit].size)
		MPowa_ConfigFrame_Container_1_ColorpickerNormalTexture:SetVertexColor(MPOWA_SAVE[self.CurEdit].icon_r or 1, MPOWA_SAVE[self.CurEdit].icon_g or 1, MPOWA_SAVE[self.CurEdit].icon_b or 1)
		MPowa_ConfigFrame_Container_1_Colorpicker_SwatchBg.r = MPOWA_SAVE[self.CurEdit].icon_r or 1
		MPowa_ConfigFrame_Container_1_Colorpicker_SwatchBg.g = MPOWA_SAVE[self.CurEdit].icon_g or 1
		MPowa_ConfigFrame_Container_1_Colorpicker_SwatchBg.b = MPOWA_SAVE[self.CurEdit].icon_b or 1
		MPowa_ConfigFrame_Container_1_Icon_Texture:SetVertexColor(MPOWA_SAVE[self.CurEdit].icon_r or 1, MPOWA_SAVE[self.CurEdit].icon_g or 1, MPOWA_SAVE[self.CurEdit].icon_b or 1)
		MPowa_ConfigFrame_Container_2_Slider_Size:SetValue(tonumber(MPOWA_SAVE[self.CurEdit].fontsize))
		MPowa_ConfigFrame_Container_2_Slider_SizeText:SetText(MPOWA_SLIDER_SIZE.." "..MPOWA_SAVE[self.CurEdit].fontsize)
		MPowa_ConfigFrame_Container_2_Slider_Opacity:SetValue(tonumber(MPOWA_SAVE[self.CurEdit].fontalpha))
		MPowa_ConfigFrame_Container_2_Slider_OpacityText:SetText(MPOWA_SLIDER_OPACITY.." "..MPOWA_SAVE[self.CurEdit].fontalpha)
		MPowa_ConfigFrame_Container_1_2_Editbox:SetText(MPOWA_SAVE[self.CurEdit].buffname)
		MPowa_ConfigFrame_Container_1_2_Editbox_Stacks:SetText(MPOWA_SAVE[self.CurEdit].stacks)
		MPowa_ConfigFrame_Container_1_2_Editbox_Player:SetText(MPOWA_SAVE[self.CurEdit].rgmname or "")
		MPowa_ConfigFrame_Container_1_2_Editbox_DebuffDuration:SetText(MPOWA_SAVE[self.CurEdit].targetduration)
		MPowa_ConfigFrame_Container_1_2_Editbox_SECLEFT:SetText(MPOWA_SAVE[self.CurEdit].secsleftdur or "")
		MPowa_ConfigFrame_Container_1_2_Checkbutton_Debuff:SetChecked(MPOWA_SAVE[self.CurEdit].isdebuff)
		MPowa_ConfigFrame_Container_1_2_Checkbutton_ShowIfNotActive:SetChecked(MPOWA_SAVE[self.CurEdit].inverse)
		MPowa_ConfigFrame_Container_2_2_Checkbutton_Timer:SetChecked(MPOWA_SAVE[self.CurEdit].timer)
		MPowa_ConfigFrame_Container_1_2_Checkbutton_ShowCooldowns:SetChecked(MPOWA_SAVE[self.CurEdit].cooldown)
		MPowa_ConfigFrame_Container_1_2_Checkbutton_EnemyTarget:SetChecked(MPOWA_SAVE[self.CurEdit].enemytarget)
		MPowa_ConfigFrame_Container_1_2_Checkbutton_FriendlyTarget:SetChecked(MPOWA_SAVE[self.CurEdit].friendlytarget)
		MPowa_ConfigFrame_Container_1_2_Checkbutton_RaidMember:SetChecked(MPOWA_SAVE[self.CurEdit].raidgroupmember)
		MPowa_ConfigFrame_Container_1_2_Checkbutton_XSecsRemaining:SetChecked(MPOWA_SAVE[self.CurEdit].secsleft)
		MPowa_ConfigFrame_Container_1_2_Checkbutton_HideStacks:SetChecked(MPOWA_SAVE[self.CurEdit].hidestacks)
		MPowa_ConfigFrame_Container_2_2_Checkbutton_Hundreds:SetChecked(MPOWA_SAVE[self.CurEdit].hundredth)
		MPowa_ConfigFrame_Container_2_2_Checkbutton_FlashAnim:SetChecked(MPOWA_SAVE[self.CurEdit].flashanim)
		MPowa_ConfigFrame_Container_2_2_Editbox_FlashAnim:SetText(MPOWA_SAVE[self.CurEdit].flashanimstart)
		MPowa_ConfigFrame_Container_2_2_Checkbutton_Color:SetChecked(MPOWA_SAVE[self.CurEdit].usefontcolor)
		MPowa_ConfigFrame_Container_2_2_ColorpickerNormalTexture:SetVertexColor(MPOWA_SAVE[self.CurEdit].fontcolor_r, MPOWA_SAVE[self.CurEdit].fontcolor_g, MPOWA_SAVE[self.CurEdit].fontcolor_b)
		MPowa_ConfigFrame_Container_2_2_Colorpicker_SwatchBg.r = MPOWA_SAVE[self.CurEdit].fontcolor_r
		MPowa_ConfigFrame_Container_2_2_Colorpicker_SwatchBg.g = MPOWA_SAVE[self.CurEdit].fontcolor_g
		MPowa_ConfigFrame_Container_2_2_Colorpicker_SwatchBg.b = MPOWA_SAVE[self.CurEdit].fontcolor_b
		MPowa_ConfigFrame_Container_3_Slider_BeginSound:SetValue(MPOWA_SAVE[self.CurEdit].beginsound)
		MPowa_ConfigFrame_Container_3_Slider_BeginSoundText:SetText(MPOWA_SLIDER_BEGINSOUND..MPOWA.SOUND[MPOWA_SAVE[self.CurEdit].beginsound])
		MPowa_ConfigFrame_Container_3_Slider_EndSound:SetValue(MPOWA_SAVE[self.CurEdit].endsound)
		MPowa_ConfigFrame_Container_3_Slider_EndSoundText:SetText(MPOWA_SLIDER_BEGINSOUND..MPOWA.SOUND[MPOWA_SAVE[self.CurEdit].endsound])
		MPowa_ConfigFrame_Container_3_Checkbutton_BeginSound:SetChecked(MPOWA_SAVE[self.CurEdit].usebeginsound)
		MPowa_ConfigFrame_Container_3_Checkbutton_EndSound:SetChecked(MPOWA_SAVE[self.CurEdit].useendsound)
		
		-- ANIM START
		MPowa_ConfigFrame_Container_5_Slider_AnimDuration:SetValue(tonumber(MPOWA_SAVE[self.CurEdit].animduration))
		MPowa_ConfigFrame_Container_5_Slider_AnimDurationText:SetText(MPOWA_SLIDER_ANIMDURATION.." - "..MPOWA_SAVE[self.CurEdit].animduration)
		MPowa_ConfigFrame_Container_5_Slider_TranslateX:SetValue(tonumber(MPOWA_SAVE[self.CurEdit].translateoffsetx))
		MPowa_ConfigFrame_Container_5_Slider_TranslateXText:SetText(MPOWA_SLIDER_TRANSLATEX.." - "..MPOWA_SAVE[self.CurEdit].translateoffsetx)
		MPowa_ConfigFrame_Container_5_Slider_TranslateY:SetValue(tonumber(MPOWA_SAVE[self.CurEdit].translateoffsety))
		MPowa_ConfigFrame_Container_5_Slider_TranslateYText:SetText(MPOWA_SLIDER_TRANSLATEY.." - "..MPOWA_SAVE[self.CurEdit].translateoffsety)
		MPowa_ConfigFrame_Container_5_Slider_FadeAlpha:SetValue(tonumber(MPOWA_SAVE[self.CurEdit].fadealpha))
		MPowa_ConfigFrame_Container_5_Slider_FadeAlphaText:SetText(MPOWA_SLIDER_FADEALPHA.." - "..MPOWA_SAVE[self.CurEdit].fadealpha)
		MPowa_ConfigFrame_Container_5_Slider_ScaleFactor:SetValue(tonumber(MPOWA_SAVE[self.CurEdit].scalefactor))
		MPowa_ConfigFrame_Container_5_Slider_ScaleFactorText:SetText(MPOWA_SLIDER_SCALEFACTOR.." - "..MPOWA_SAVE[self.CurEdit].scalefactor)
		
		MPowa_ConfigFrame_Container_5_FadeIn:SetChecked(MPOWA_SAVE[self.CurEdit].fadein)
		MPowa_ConfigFrame_Container_5_GrowIn:SetChecked(MPOWA_SAVE[self.CurEdit].growin)
		MPowa_ConfigFrame_Container_5_RotateIn:SetChecked(MPOWA_SAVE[self.CurEdit].rotateanimin)
		MPowa_ConfigFrame_Container_5_SizeIn:SetChecked(MPOWA_SAVE[self.CurEdit].sizeanim)
		MPowa_ConfigFrame_Container_5_EscapeIn:SetChecked(MPOWA_SAVE[self.CurEdit].escapeanimin)
		MPowa_ConfigFrame_Container_5_BatmanIn:SetChecked(MPOWA_SAVE[self.CurEdit].batmananimin)
		MPowa_ConfigFrame_Container_5_FadeOut:SetChecked(MPOWA_SAVE[self.CurEdit].fadeout)
		MPowa_ConfigFrame_Container_5_GrowOut:SetChecked(MPOWA_SAVE[self.CurEdit].growout)
		MPowa_ConfigFrame_Container_5_RotateOut:SetChecked(MPOWA_SAVE[self.CurEdit].rotateanimout)
		MPowa_ConfigFrame_Container_5_Shrink:SetChecked(MPOWA_SAVE[self.CurEdit].shrinkanim)
		MPowa_ConfigFrame_Container_5_EscapeOut:SetChecked(MPOWA_SAVE[self.CurEdit].escapeanimout)
		MPowa_ConfigFrame_Container_5_BatmanOut:SetChecked(MPOWA_SAVE[self.CurEdit].batmananimout)
		MPowa_ConfigFrame_Container_5_Translate:SetChecked(MPOWA_SAVE[self.CurEdit].translateanim)
		-- ANIM END
		
		if MPOWA_SAVE[self.CurEdit].enemytarget or MPOWA_SAVE[self.CurEdit].friendlytarget then
			MPowa_ConfigFrame_Container_1_2_Editbox_DebuffDuration:Show()
		else
			MPowa_ConfigFrame_Container_1_2_Editbox_DebuffDuration:Hide()
		end
		if MPOWA_SAVE[self.CurEdit].flashanim then
			MPowa_ConfigFrame_Container_2_2_Editbox_FlashAnim:Show()
		else
			MPowa_ConfigFrame_Container_2_2_Editbox_FlashAnim:Hide()
		end
		if MPOWA_SAVE[self.CurEdit]["raidgroupmember"] then
			MPowa_ConfigFrame_Container_1_2_Editbox_Player:Show()
		else
			MPowa_ConfigFrame_Container_1_2_Editbox_Player:Hide()
		end
		if MPOWA_SAVE[self.CurEdit]["secsleft"] then
			MPowa_ConfigFrame_Container_1_2_Editbox_SECLEFT:Show()
		else
			MPowa_ConfigFrame_Container_1_2_Editbox_SECLEFT:Hide()
		end
		MPowa_ConfigFrame_Container_1_2_Checkbutton_SecondSpecifier:SetChecked(MPOWA_SAVE[self.CurEdit].secondspecifier)
		MPowa_ConfigFrame_Container_1_2_Editbox_SecondSpecifier:SetText(MPOWA_SAVE[self.CurEdit].secondspecifiertext)
		if MPOWA_SAVE[MPOWA.CurEdit]["secondspecifier"] then
			MPowa_ConfigFrame_Container_1_2_Editbox:SetWidth(135)
			MPowa_ConfigFrame_Container_1_2_Editbox:ClearAllPoints()
			MPowa_ConfigFrame_Container_1_2_Editbox:SetPoint("TOP", MPowa_ConfigFrame_Container_1_2, "TOP", -67.5, -20)
			MPowa_ConfigFrame_Container_1_2_Editbox_SecondSpecifier:Show()
		else
			MPowa_ConfigFrame_Container_1_2_Editbox:SetWidth(270)
			MPowa_ConfigFrame_Container_1_2_Editbox:ClearAllPoints()
			MPowa_ConfigFrame_Container_1_2_Editbox:SetPoint("TOP", MPowa_ConfigFrame_Container_1_2, "TOP", 0, -20)
			MPowa_ConfigFrame_Container_1_2_Editbox_SecondSpecifier:Hide()
		end
		MPOWA:TernarySetState(MPowa_ConfigFrame_Container_1_2_Checkbutton_Alive, MPOWA_SAVE[self.CurEdit].alive)
		MPOWA:TernarySetState(MPowa_ConfigFrame_Container_1_2_Checkbutton_Mounted, MPOWA_SAVE[self.CurEdit].mounted)
		MPOWA:TernarySetState(MPowa_ConfigFrame_Container_1_2_Checkbutton_InCombat, MPOWA_SAVE[self.CurEdit].incombat)
		MPOWA:TernarySetState(MPowa_ConfigFrame_Container_1_2_Checkbutton_InParty, MPOWA_SAVE[self.CurEdit].inparty)
		MPOWA:TernarySetState(MPowa_ConfigFrame_Container_1_2_Checkbutton_InRaid, MPOWA_SAVE[self.CurEdit].inraid)
		MPOWA:TernarySetState(MPowa_ConfigFrame_Container_1_2_Checkbutton_InBattleground, MPOWA_SAVE[self.CurEdit].inbattleground)
		MPOWA:TernarySetState(MPowa_ConfigFrame_Container_1_2_Checkbutton_InRaidInstance, MPOWA_SAVE[self.CurEdit].inraidinstance)
		MPowa_ConfigFrame:Show()
	end
end

function MPOWA:TernarySetState(button, value)
	local label = _G(button:GetName().."Text")
	button:Enable()
	label:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)

	if value==0 then
		button:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
		button:SetChecked(0)
	elseif value==false then
		button:SetCheckedTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
		button:SetChecked(1)
	elseif value==true then
		button:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
		button:SetChecked(1)
	end
end

function MPOWA:Ternary_OnClick(obj, var)
	if (MPOWA_SAVE[self.CurEdit][var]==0) then
		MPOWA_SAVE[self.CurEdit][var] = true -- Ignore => On
	elseif (MPOWA_SAVE[self.CurEdit][var]==true) then
		MPOWA_SAVE[self.CurEdit][var] = false -- On => Off
	else
		MPOWA_SAVE[self.CurEdit][var] = 0 -- Off => Ignore
	end	

	self:TernarySetState(obj, MPOWA_SAVE[self.CurEdit][var])
	if MPOWA_SAVE[self.CurEdit]["test"] or self.testAll then
		_G("TextureFrame"..self.CurEdit):Hide()
		_G("TextureFrame"..self.CurEdit):Show()
	else
		self:Iterate("player")
		self:Iterate("target")
	end
end

function MPOWA:SliderChange(var, obj, text)
	MPOWA_SAVE[self.CurEdit][var] = tonumber(strform("%.2f", obj:GetValue()))
	_G(obj:GetName().."Text"):SetText(text.." "..MPOWA_SAVE[self.CurEdit][var])
	self:ApplyConfig(self.CurEdit)
end

function MPOWA:SoundSliderChange(obj, var)
	local oldvar = MPOWA_SAVE[self.CurEdit][var]
	MPOWA_SAVE[self.CurEdit][var] = obj:GetValue()
	_G(obj:GetName().."Text"):SetText(MPOWA_SLIDER_BEGINSOUND..self.SOUND[MPOWA_SAVE[self.CurEdit][var]])
	if MPOWA_SAVE[self.CurEdit][var] ~= oldvar then
		if MPOWA_SAVE[self.CurEdit][var] < 16 then
			PlaySound(self.SOUND[MPOWA_SAVE[self.CurEdit][var]], "master")
		else
			PlaySoundFile("Interface\\AddOns\\ModifiedPowerAuras\\Sounds\\"..self.SOUND[MPOWA_SAVE[self.CurEdit][var]], "master")
		end
	end
end

function MPOWA:Checkbutton(var)
	if MPOWA_SAVE[self.CurEdit][var] then
		MPOWA_SAVE[self.CurEdit][var] = false
	else
		MPOWA_SAVE[self.CurEdit][var] = true
	end
	
	if MPOWA_SAVE[self.CurEdit]["test"] or self.testAll then
		_G("TextureFrame"..self.CurEdit):Hide()
		_G("TextureFrame"..self.CurEdit):Show()
	else
		self:Iterate("player")
		self:Iterate("target")
	end
end

function MPOWA:Checkbutton_FlashAnim()
	if MPOWA_SAVE[self.CurEdit]["flashanim"] then
		MPOWA_SAVE[self.CurEdit]["flashanim"] = false
		MPowa_ConfigFrame_Container_2_2_Editbox_FlashAnim:Hide()
		self.frames[self.CurEdit][1].flash = nil
	else
		MPOWA_SAVE[self.CurEdit]["flashanim"] = true
		MPowa_ConfigFrame_Container_2_2_Editbox_FlashAnim:Show()
		self:AddAnimFlash(self.CurEdit)
	end
end

function MPOWA:Checkbutton_USEFONTCOLOR()
	if MPOWA_SAVE[self.CurEdit].usefontcolor then
		MPOWA_SAVE[self.CurEdit].usefontcolor = false
		_G("TextureFrame"..self.CurEdit.."_Timer"):SetTextColor(1,1,1,MPOWA_SAVE[self.CurEdit].usefontcolor)
	else
		MPOWA_SAVE[self.CurEdit].usefontcolor = true
		_G("TextureFrame"..self.CurEdit.."_Timer"):SetTextColor(MPOWA_SAVE[self.CurEdit].fontcolor_r,MPOWA_SAVE[self.CurEdit].fontcolor_g,MPOWA_SAVE[self.CurEdit].fontcolor_b,MPOWA_SAVE[self.CurEdit].usefontcolor)
	end
end

local name = ""
function MPOWA:OpenColorPicker(n)
	CloseMenus()
	name = n
	
	button = MPowa_ConfigFrame_Container_2_2_Colorpicker_SwatchBg

	ColorPickerFrame.func = MPOWA.OptionsFrame_SetColor -- button.swatchFunc
	ColorPickerFrame:SetColorRGB(button.r, button.g, button.b)
	ColorPickerFrame.previousValues = {r = button.r, g = button.g, b = button.b, opacity = button.opacity}
	ColorPickerFrame.cancelFunc = MPOWA.OptionsFrame_CancelColor
	
	ColorPickerFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	
	ColorPickerFrame:SetMovable()
	ColorPickerFrame:EnableMouse()
	ColorPickerFrame:SetScript("OnMouseDown", function() ColorPickerFrame:StartMoving() end)
	ColorPickerFrame:SetScript("OnMouseUp", function() ColorPickerFrame:StopMovingOrSizing() end)
	
	ColorPickerFrame:Show()
end

function MPOWA:OptionsFrame_SetColor()
	local r,g,b = ColorPickerFrame:GetColorRGB()
	local swatch,frame
	swatch = MPowa_ConfigFrame_Container_2_2_ColorpickerNormalTexture
	frame = MPowa_ConfigFrame_Container_2_2_Colorpicker_SwatchBg
	swatch:SetVertexColor(r,g,b)
	frame.r = r
	frame.g = g
	frame.b = b

	MPOWA_SAVE[MPOWA.CurEdit][name.."_r"] = r
	MPOWA_SAVE[MPOWA.CurEdit][name.."_g"] = g
	MPOWA_SAVE[MPOWA.CurEdit][name.."_b"] = b
	
	if name == "fontcolor" then
		if MPOWA_SAVE[MPOWA.CurEdit].usefontcolor then
			_G("TextureFrame"..MPOWA.CurEdit.."_Timer"):SetTextColor(r,g,b,MPOWA_SAVE[MPOWA.CurEdit].fontalpha)
		else
			_G("TextureFrame"..MPOWA.CurEdit.."_Timer"):SetTextColor(1,1,1,MPOWA_SAVE[MPOWA.CurEdit].fontalpha)
		end
	elseif name == "icon" then
		MPowa_ConfigFrame_Container_1_Icon_Texture:SetVertexColor(r,g,b)
		MPOWA.frames[MPOWA.CurEdit][2]:SetVertexColor(r,g,b)
	end
end

function MPOWA:OptionsFrame_CancelColor()
	local r = ColorPickerFrame.previousValues.r
	local g = ColorPickerFrame.previousValues.g
	local b = ColorPickerFrame.previousValues.b
	local swatch,frame
	swatch = MPowa_ConfigFrame_Container_2_2_ColorpickerNormalTexture
	frame = MPowa_ConfigFrame_Container_2_2_Colorpicker_SwatchBg
	swatch:SetVertexColor(r,g,b)
	frame.r = r
	frame.g = g
	frame.b = b
	
	if name == "fontcolor" then
		if MPOWA_SAVE[MPOWA.CurEdit].usefontcolor then
			_G("TextureFrame"..MPOWA.CurEdit.."_Timer"):SetTextColor(r,g,b,MPOWA_SAVE[MPOWA.CurEdit].fontalpha)
		else
			_G("TextureFrame"..MPOWA.CurEdit.."_Timer"):SetTextColor(1,1,1,MPOWA_SAVE[MPOWA.CurEdit].fontalpha)
		end
	elseif name == "icon" then
		MPowa_ConfigFrame_Container_1_Icon_Texture:SetVertexColor(r,g,b)
		MPOWA.frames[MPOWA.CurEdit][2]:SetVertexColor(r,g,b)
	end
end

function MPOWA:Editbox_Duration(obj)
	if tonumber(obj:GetText()) ~= nil then
		MPOWA_SAVE[self.CurEdit]["targetduration"] = tonumber(obj:GetText())
		self:Iterate("target")
	end
end

function MPOWA:Editbox_SECSLEFT(obj)
	if tonumber(obj:GetText()) ~= nil then
		MPOWA_SAVE[self.CurEdit]["secsleftdur"] = tonumber(obj:GetText())
		if MPOWA_SAVE[self.CurEdit]["test"] or self.testAll then
			_G("TextureFrame"..self.CurEdit):Hide()
			_G("TextureFrame"..self.CurEdit):Show()
		else
			self:Iterate("target")
			self:Iterate("player")
		end
	end
end

function MPOWA:Editbox_Name(obj)
	local oldname = MPOWA_SAVE[self.CurEdit].buffname
	MPOWA_SAVE[self.CurEdit].buffname = obj:GetText()

	if oldname ~= MPOWA_SAVE[self.CurEdit].buffname then
		MPOWA_SAVE[self.CurEdit].texture = "Interface\\AddOns\\ModifiedPowerAuras\\images\\dummy.tga"
		MPowa_ConfigFrame_Container_1_Icon_Texture:SetTexture(MPOWA_SAVE[self.CurEdit].texture)
		_G("ConfigButton"..self.CurEdit.."_Icon"):SetTexture(MPOWA_SAVE[self.CurEdit].texture)
		_G("TextureFrame"..self.CurEdit.."_Icon"):SetTexture(MPOWA_SAVE[self.CurEdit].texture)
	end
	
	if not self.auras[MPOWA_SAVE[self.CurEdit].buffname] then
		self.auras[MPOWA_SAVE[self.CurEdit].buffname] = {}
	end
	if not self:GetTablePosition(self.auras[MPOWA_SAVE[self.CurEdit].buffname], self.CurEdit) then
		tinsert(self.auras[MPOWA_SAVE[self.CurEdit].buffname], self.CurEdit)
	end
	--self:Print(self.CurEdit)
	
	if MPOWA_SAVE[self.CurEdit].test or self.testAll then
		_G("TextureFrame"..self.CurEdit):Hide()
		_G("TextureFrame"..self.CurEdit):Show()
	else
		self:Iterate("player")
		self:Iterate("target")
	end
end

function MPOWA:Editbox_SecondSpecifier(obj)
	local oldname = MPOWA_SAVE[self.CurEdit].secondspecifiertext
	MPOWA_SAVE[self.CurEdit].secondspecifiertext = obj:GetText()

	if oldname ~= MPOWA_SAVE[self.CurEdit].secondspecifiertext then
		MPOWA_SAVE[self.CurEdit].texture = "Interface\\AddOns\\ModifiedPowerAuras\\images\\dummy.tga"
		MPowa_ConfigFrame_Container_1_Icon_Texture:SetTexture(MPOWA_SAVE[self.CurEdit].texture)
		_G("ConfigButton"..self.CurEdit.."_Icon"):SetTexture(MPOWA_SAVE[self.CurEdit].texture)
		_G("TextureFrame"..self.CurEdit.."_Icon"):SetTexture(MPOWA_SAVE[self.CurEdit].texture)
	end
	
	if MPOWA_SAVE[self.CurEdit].test or self.testAll then
		_G("TextureFrame"..self.CurEdit):Hide()
		_G("TextureFrame"..self.CurEdit):Show()
	else
		self:Iterate("player")
		self:Iterate("target")
	end
end

function MPOWA:Editbox_Stacks(obj)
	local oldcon = MPOWA_SAVE[self.CurEdit].stacks
	MPOWA_SAVE[self.CurEdit].stacks = obj:GetText()
	if oldcon ~= MPOWA_SAVE[self.CurEdit].stacks then
		if MPOWA_SAVE[self.CurEdit]["test"] or self.testAll then
			_G("TextureFrame"..self.CurEdit):Hide()
			_G("TextureFrame"..self.CurEdit):Show()
		else
			self:Iterate("player")
			self:Iterate("target")
		end
	end
end

function MPOWA:Editbox_FlashAnimStart(obj)
	local oldcon = MPOWA_SAVE[self.CurEdit].flashanimstart
	if tonumber(obj:GetText()) ~= nil then
		MPOWA_SAVE[self.CurEdit].flashanimstart = tonumber(obj:GetText())
	end
	if oldcon ~= MPOWA_SAVE[self.CurEdit].flashanimstart then
		if MPOWA_SAVE[self.CurEdit]["test"] or self.testAll then
			_G("TextureFrame"..self.CurEdit):Hide()
			_G("TextureFrame"..self.CurEdit):Show()
		else
			self:Iterate("player")
			self:Iterate("target")
		end
	end
end

function MPOWA:Editbox_Player(obj)
	local oldcon = MPOWA_SAVE[self.CurEdit]["rgmname"]
	if obj:GetText() ~= nil and obj:GetText() ~= "" then
		MPOWA_SAVE[self.CurEdit]["rgmname"] = obj:GetText()
		self.RaidGroupMembers[MPOWA_SAVE[self.CurEdit]["rgmname"]] = true
		self:GetGroup()
	end
end

function MPOWA:TestAll()
	if ConfigButton1 then
		if self.testAll then
			self.testAll = false
			for i=1, self.NumBuffs do
				if not self.active[i] then
					_G("TextureFrame"..i):Hide()
				end
				MPOWA_SAVE[i]["test"] = false
			end
		else
			self.testAll = true
			for i=1, self.NumBuffs do
				_G("TextureFrame"..i):Show()
			end
		end
	end
end

function MPOWA:Test()
	if ConfigButton1 then
		if MPOWA_SAVE[self.selected].test then
			MPOWA_SAVE[self.selected].test = false
			if not self.active[i] then
				_G("TextureFrame"..self.selected):Hide()
			end
		else
			MPOWA_SAVE[self.selected].test = true
			_G("TextureFrame"..self.selected):Show()
		end
	end
end

function MPOWA:ProfileSave()
	tinsert(MPOWA_PROFILE, MPOWA_SAVE[self.selected])
	self:ScrollFrame_Update()
end

function MPOWA:ProfileRemove()
	if MPOWA_PROFILE[MPOWA_PROFILE_SELECTED] ~= nil then
		tremove(MPOWA_PROFILE, MPOWA_PROFILE_SELECTED)
		MPOWA_PROFILE_SELECTED = 1
		self:ScrollFrame_Update()
	end
end

function MPOWA:Import()
	if MPOWA_PROFILE[MPOWA_PROFILE_SELECTED] ~= nil then
		tremove(MPOWA_SAVE, self.NumBuffs +1)
		tinsert(MPOWA_SAVE, self.NumBuffs +1, MPOWA_PROFILE[MPOWA_PROFILE_SELECTED])
		self:AddAura()
	end
end

function MPOWA:GetTableLength(T)
	local count = 0
	for _ in T do 
		count = count + 1 
	end 
	return count
end

function MPOWA:ScrollFrame_Update()
	local line -- 1 through 5 of our window to scroll
	local lineplusoffset -- an index into our data calculated from the scroll offset
	local FRAME = MPowa_ProfileFrame_ScrollFrame
	FauxScrollFrame_Update(FRAME,self:GetTableLength(MPOWA_PROFILE),7,40)
	for line=1,7 do
		lineplusoffset = line + FauxScrollFrame_GetOffset(FRAME)
		if MPOWA_PROFILE[lineplusoffset] ~= nil then
			_G("MPowa_ProfileFrame_ScrollFrame_Button"..line.."_Name"):SetText(MPOWA_PROFILE[lineplusoffset].buffname)
			_G("MPowa_ProfileFrame_ScrollFrame_Button"..line.."_Icon"):SetTexture(MPOWA_PROFILE[lineplusoffset].texture)
			_G("MPowa_ProfileFrame_ScrollFrame_Button"..line).line = lineplusoffset
			_G("MPowa_ProfileFrame_ScrollFrame_Button"..line):Show()
		else
			_G("MPowa_ProfileFrame_ScrollFrame_Button"..line):Hide()
		end
	end
end

function MPOWA:SelectIcon(obj)
	SELECTEDICON = _G(obj:GetName().."_Icon"):GetTexture()
	for cat, p in self.ICONARRAY do
		for i=1,p do
			if _G(cat..i.."_Border") then
				_G(cat..i.."_Border"):Hide()
			end
		end
	end
	_G(obj:GetName().."_Border"):Show()
end

function MPOWA:IconFrameOkay()
	MPowa_ConfigFrame_Container_1_Icon_Texture:SetTexture(SELECTEDICON)
	_G("ConfigButton"..self.CurEdit.."_Icon"):SetTexture(SELECTEDICON)
	_G("TextureFrame"..self.CurEdit.."_Icon"):SetTexture(SELECTEDICON)
	MPOWA_SAVE[self.CurEdit].texture = SELECTEDICON
	MPowa_IconFrame:Hide()
end
