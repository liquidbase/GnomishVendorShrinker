
local myname, ns = ...


local ItemSearch = ns.LibItemSearch
ns.LibItemSearch = nil


local NUMROWS = 14


function ns.NewMainFrame()
	local GVS = CreateFrame("frame", nil, MerchantFrame)

	local search = ns.MakeSearchField(GVS, scrollbar.Refresh)

	local rows = {}
	for i=1,NUMROWS do
		local row = ns.NewMerchantItemFrame(GVS)

		if i == 1 then
			row:SetPoint("TOPLEFT")
			row:SetPoint("RIGHT", -19, 0)
		else
			row:SetPoint("TOPLEFT", rows[i-1], "BOTTOMLEFT")
			row:SetPoint("RIGHT", rows[i-1])
		end

		rows[i] = row
	end

	local scrollbar = ns.NewScrollBar(GVS, 0, 5)
	function scrollbar:Refresh()
		local offset = scrollbar:GetValue()
		local searchstring = search:GetText()
		local n = GetMerchantNumItems()
		local row, n_searchmatch = 1, 0
		for i=1,n do
			local link = GetMerchantItemLink(i)
			if ItemSearch:Find(link, searchstring) then
				if n_searchmatch >= offset and n_searchmatch < offset + NUMROWS then
					rows[row]:SetValue(i)
					row = row + 1
				end
				n_searchmatch = n_searchmatch + 1
			end
		end
		scrollbar:SetMinMaxValues(0, math.max(0, n_searchmatch - NUMROWS))
		for i=row,NUMROWS do rows[i]:Hide() end
	end

	search:SetScript("OnTextChanged", Refresh)

	GVS:EnableMouseWheel(true)
	GVS:SetScript("OnMouseWheel", function(self, value)
		if value > 0 then
			scrollbar:Decrement()
		else
			scrollbar:Increment()
		end
	end)
	GVS:SetScript("OnEvent", scrollbar.Refresh)
	GVS:SetScript("OnShow", function(self, noreset)
		local max = math.max(0, GetMerchantNumItems() - NUMROWS)
		scrollbar:SetMinMaxValues(0, max)
		scrollbar:SetValue(noreset and math.min(scrollbar:GetValue(), max) or 0)
		scrollbar.Refresh()

		GVS:RegisterEvent("BAG_UPDATE")
		GVS:RegisterEvent("MERCHANT_UPDATE")
		GVS:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
	end)
	GVS:SetScript("OnHide", GVS.UnregisterAllEvents)

	return GVS
end
