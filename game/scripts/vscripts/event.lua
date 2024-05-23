
if not FateEvent then
	FateEvent = {}
end

function FateEvent:Construct()

		local event_table = LoadKeyValues("scripts/npc/fate_event.txt")
		local today = tostring(GetSystemDate())
		local date = tonumber(string.sub(today, 4, -4))
		local month = tonumber(string.sub(today, 0, -7))
		local year = tonumber(string.sub(today, 7)) 
		--print("today :" .. today)
		--print(date)
		--print(month)
		--print(year)

		for k,v in pairs(event_table) do 
			--print(k,v)
			local event_start = v.StartDate
			--print(event_start)
			local event_end = v.EndDate
			local event_start_date = tonumber(string.sub(event_start, 0, -4))
			local event_end_date = tonumber(string.sub(event_end, 0, -4))
			local event_start_month = tonumber(string.sub(event_start, 4))
			local event_end_month = tonumber(string.sub(event_end, 4))
			local event_start_year
			local event_end_year
			--[[print("date :" .. event_start_date)
			print("date :" .. event_end_date)
			print("month :" .. event_start_month)
			print("month :" .. event_end_month)]]
			if string.len(event_start) > 5 then 
				--print('year?')
				event_start_date = tonumber(string.sub(event_start, 0, -7))
				event_end_date = tonumber(string.sub(event_end, 0, -7))
				event_start_month = tonumber(string.sub(event_start, 4, -4))
				event_end_month = tonumber(string.sub(event_end, 4, -4))
				event_start_year = tonumber(string.sub(event_start, 7))
				event_end_year = tonumber(string.sub(event_end, 7))
			end

			if event_start_year ~= nil then 
				if event_start_year == event_end_year then 
					if year == event_start_year then
						--if (month == event_start_month and date >= event_start_date) or (month > event_start_month and month < event_end_month) or (month == event_end_month and date <= event_end_date) then 
						if event_start_month == event_end_month then 
							if month == event_start_month and date >= event_start_date and date <= event_end_date then 
								self:RegistEvent(v.EventID, v.EventType, v)
								--print('same year same month event date: ' .. date)
							end
						else
							if (month == event_start_month and date >= event_start_date) then
								self:RegistEvent(v.EventID, v.EventType, v)
								--print('same year event date: ' .. date)
							elseif (month > event_start_month and month < event_end_month) then 
								self:RegistEvent(v.EventID, v.EventType, v)
								--print('same year event month: ' .. month)
							elseif (month == event_end_month and date <= event_end_date) then 
								self:RegistEvent(v.EventID, v.EventType, v)
								--print('same year event end month: ' .. date)
							end
						end
					end
				else
					if year == event_start_year then
						if (month == event_start_month and date >= event_start_date) or (month > event_start_month) then 
							self:RegistEvent(v.EventID, v.EventType, v)
							--print('cross year event ' .. event_start_year)
						end
					elseif year > event_start_year and year <= event_end_year then 
						if (month < event_end_month) or (month == event_end_month and date <= event_end_date) then 
							self:RegistEvent(v.EventID, v.EventType, v)
							--print('cross year event ' .. event_end_year)
						end
					end
				end
			else
				if (month == event_start_month and month == event_end_month) then
					if date >= event_start_date and date <= event_end_date then 
						self:RegistEvent(v.EventID, v.EventType, v)
					end
				else
					if (month == event_start_month and date >= event_start_date) or (month > event_start_month and month < event_end_month) or (month == event_end_month and date <= event_end_date) then 
						self:RegistEvent(v.EventID, v.EventType, v)
						--print('every year event')
					end
				end
			end
		end

end

function FateEvent:RegistEvent(EventID, EventType, EventContents)
	ServerTables:CreateTable("Event" .. EventContents.EventID, EventContents)
	if EventType == 1 then -- temporal unlock skin
		ServerTables:CreateTable("EventSkin", {})
		--ServerTables:CreateTable("Event" .. EventContents.EventID, {})
		for k,v in pairs (EventContents.EventSkin) do
			ServerTables:SetTableValue("EventSkin", k, v, true)
			--ServerTables:SetTableValue("Event" .. EventContents.EventID, k, v, true)
		end
		print('event skin enable')
		--[[local skin = ServerTables:GetAllTableValues("EventSkin")
		for a,b in pairs(skin) do 
			print(a,b)
		end]]
	elseif EventType == 2 then  -- claim limited skin
		--print('limited skin event start')
		--if ServerTables:GetAllTableValues("EventLimitedSkin") == nil then

		self.event = self.event or {}
		self.event[EventID] = EventID
		ServerTables:CreateTable("EventLimitedSkin", self.event)
		--ServerTables:CreateTable("Event" .. EventContents.EventID, EventContents)

		--print('limited skin event create data')
		--else
		--	ServerTables:SetTableValue("EventLimitedSkin", EventID, EventID, true)
		--end
		CustomGameEventManager:RegisterListener("event_claim", function(id, ...)
	        Dynamic_Wrap(self, "ClaimLimitedSkin")(self, ...) 
	    end)
		print('limited skin event listen regist')
		--[[Timers:CreateTimer(30, function()
			for pID = 0, DOTA_MAX_PLAYERS -1 do 
				if PlayerResource:IsValidPlayerID(pID) then
					--print('limited skin event valid player id')
					Timers:CreateTimer('checking_data_' .. pID, {
						endTime = 0,
						callback = function()
						if PlayerTables:GetTableValue("database", "db", pID) == true then 
							self:StartLimitedSkinEvent(pID, EventContents)
							--print('limited skin event send data')
							return nil 
						else
							--print('limited skin event no data base')
							return 1
						end
					end})
				end
			end
		end)]]
	elseif EventType == 4 then  -- padoru event
		ServerTables:CreateTable("EventPadoru", {})
		--ServerTables:CreateTable("Event" .. EventContents.EventID, {})
		for k,v in pairs (EventContents.EventItem) do
			ServerTables:SetTableValue("EventPadoru", k, v, true)
			--ServerTables:SetTableValue("Event" .. EventContents.EventID, k, v, true)
		end
		print('event padoru enable')
		local event = {
			EventName = EventContents.EventName,
			EventType = EventContents.EventType,
			EventID = EventContents.EventID,
			StartDate = EventContents.StartDate,
			EndDate = EventContents.EndDate,
			EventDetail = EventContents.EventDetail
		}
		ServerTables:CreateTable("EventPadoru" .. EventContents.EventID, event)
		--[[local skin = ServerTables:GetAllTableValues("EventPadoru")
		for a,b in pairs(skin) do 
			print(a,b)
		end]]

	elseif EventType == 5 then  -- Big board new + regist
		local event = {
			EventName = EventContents.EventName,
			EventType = EventContents.EventType,
			EventID = EventContents.EventID,
			StartDate = EventContents.StartDate,
			EndDate = EventContents.EndDate,
			EventDetail = EventContents.EventDetail,
			LinkSolo = EventContents.LinkSolo,
			LinkTeam = EventContents.LinkTeam,
			DetailLength = EventContents.DetailLength
		}
		ServerTables:CreateTable("EventTour" .. EventContents.EventID, event)
		--ServerTables:CreateTable("Event" .. EventContents.EventID, event)

		--[[for pID = 0, DOTA_MAX_PLAYERS -1 do 
			Timers:CreateTimer(30, function()
				if PlayerResource:IsValidPlayerID(pID) then

					Timers:CreateTimer('checking_data1_' .. pID, {
						endTime = 0,
						callback = function()
						if PlayerTables:GetTableValue("database", "db", pID) == true then 
							local ply = PlayerResource:GetPlayer(pID)

							CustomGameEventManager:Send_ServerToPlayer(ply, "fate_event", event)
							print(ply)
							print('tour event send data')
							return nil 
						else
							print('tour event no data base')
							return 1
						end
					end})
					
				end
			end)
		end]]
	elseif EventType == 6 then  -- same hero event
		ServerTables:CreateTable("SameHero", {samehero = true})
		--ServerTables:CreateTable("Event" .. EventContents.EventID, {})
		print('same hero enable')
		local event = {
			EventName = EventContents.EventName,
			EventType = EventContents.EventType,
			EventID = EventContents.EventID,
			StartDate = EventContents.StartDate,
			EndDate = EventContents.EndDate,
			EventDetail = EventContents.EventDetail
		}
		ServerTables:CreateTable("Event" .. EventContents.EventID, event)
		--[[local skin = ServerTables:GetAllTableValues("EventPadoru")
		for a,b in pairs(skin) do 
			print(a,b)
		end]]
	end
end

function FateEvent:StartLimitedSkinEvent(playerId, EventContents)	
	--print('raw SID ' .. EventContents.EventSkin)
	local SID = tostring(EventContents.EventSkin)
	if string.len(SID) == 2 then 
		SID = "0" .. SID 
	elseif string.len(SID) == 1 then 
		SID = "00" .. SID 
	end
	--print("SID : " .. SID)
	local skin = GetSkin(SID)
	--print('skin : ' .. skin)
	local status = iupoasldm.jyiowe[playerId].IFY.SKID[SID]
	for k,v in pairs(iupoasldm.jyiowe[playerId].IFY) do 
		if k == "SKID" then 
			for a,b in pairs (v) do 
				print(a,tostring(b))
			end
		end
	end
	if status == true then 
		print('skin was already claimed')
	elseif status == false then 
		print('skin can claimed')
	elseif status == nil then 
		print('no data')
	end
	local event_data = {
		EventName = EventContents.EventName,
		EventID = EventContents.EventID,
		EventType = EventContents.EventType,
		StartDate = EventContents.StartDate,
		EndDate = EventContents.EndDate,
		EventSkin = skin ,
		Status = status ,
	}
	PlayerTables:CreateTable("limitedevent" .. EventContents.EventID, event_data, playerId)
	local ply = PlayerResource:GetPlayer(playerId)
	CustomGameEventManager:Send_ServerToPlayer(ply, "fate_event", event_data)
end

function FateEvent:ClaimLimitedSkin(args)
	--[[for k,v in pairs(args) do 
		print(k,v)
	end]]
	local playerId = args.playerId
	local skin = args.event
	local EventID = args.id
	local SID = GetSID(skin)
	local ply = PlayerResource:GetPlayer(playerId)
	--print('claim skin')
	--print(SID)
	iupoasldm.jyiowe[playerId].IFY.SKID[SID] = true
	local event_data = PlayerTables:GetAllTableValues("limitedevent" .. EventID, playerId)
	event_data.Status = true
	CustomGameEventManager:Send_ServerToPlayer(ply, "fate_event", event_data)
	iupoasldm:FastUpdate(playerId)
end

function GetSkin(SID)
	local kiuok = LoadKeyValues("scripts/npc/abilities/heroes/sketch.txt")
	for k,v in pairs (kiuok) do 
		if k == SID then 
			--print(v)
			return v
		end
	end  
end

function IsEventSkin(SID)
	local skin_event_table = ServerTables:GetAllTableValues("EventSkin")
	--print("SID :" .. SID)
	if skin_event_table == false then 
		--print('no event available')
		return false
	else
		for k,v in pairs (skin_event_table) do 
			--print('SID :' .. v)
			if v == tonumber(SID) then 
				--print('SID :' .. SID)
				return true 
			end
		end
		return false 
	end
	return false 
end

if not EventStart then 
	FateEvent:Construct()
	EventStart = true 
end