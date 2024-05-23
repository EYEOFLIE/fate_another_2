
if not PlayerTables then
  	PlayerTables = class({})
end

function PlayerTables:start()
    self.tables = {}
    for i = 0, DOTA_MAX_PLAYERS - 1 do 
    	self.tables[i] = {}
    end
    print("[playertables.lua] Start PlayerTables")
end

function PlayerTables:equals(o1, o2, ignore_mt)
    if o1 == o2 then return true end
    local o1Type = type(o1)
    local o2Type = type(o2)
    if o1Type ~= o2Type then return false end
    if o1Type ~= 'table' then return false end

    if not ignore_mt then
        local mt1 = getmetatable(o1)
        if mt1 and mt1.__eq then
            --compare using built in method
            return o1 == o2
        end
    end

    local keySet = {}

    for key1, value1 in pairs(o1) do
        local value2 = o2[key1]
        if value2 == nil or self:equals(value1, value2, ignore_mt) == false then
            return false
        end
        keySet[key1] = true
    end

    for key2, _ in pairs(o2) do
        if not keySet[key2] then return false end
    end
    return true
end

function PlayerTables:copy(obj, seen)
  	if type(obj) ~= 'table' then return obj end
  	if seen and seen[obj] then return seen[obj] end

  	local s = seen or {}
  	local res = setmetatable({}, getmetatable(obj))

  	s[obj] = res

  	for k, v in pairs(obj) do 
  		res[self:copy(k, s)] = self:copy(v, s) 
  	end

  	return res
end

function PlayerTables:CreateTable(tableName, tableContents, pid)

	if type(pid) ~= "number" then
		print("[playertables.lua] Warning: Pid value '" .. pid .. "' is not an integer")
		return
	end

	if self.tables[pid][tableName] then
    	print("[playertables.lua] Warning: player table '" .. tableName .. "' already exists.  Overriding.")
  	end

  	self.tables[pid][tableName] = tableContents
    print("[playertables.lua] '" .. tableName .. "' has been created.")
  	CustomNetTables:SetTableValue("parsy", "player_" .. pid, self.tables[pid])
end

function PlayerTables:DeleteTable(tableName, pid)
  	if not self.tables[pid][tableName] then
    	print("[playertables.lua] Warning: Table '" .. tableName .. "' does not exist.")
    	return
  	end

  	self.tables[pid][tableName] = nil

  	CustomNetTables:SetTableValue("parsy", "player_" .. pid, self.tables[pid])
end

function PlayerTables:DeleteTableKey(tableName, key, pid)
  	if not self.tables[pid][tableName] then
    	print("[playertables.lua] Warning: Table '" .. tableName .. "' does not exist.")
    	return
  	end

  	local table = self.tables[pid][tableName]

  	if table[key] ~= nil then
    	table[key] = nil
  	end

  	CustomNetTables:SetTableValue("parsy", "player_" .. pid, self.tables[pid])
end

function PlayerTables:GetTableValue(tableName, key, pid)
  	if not self.tables[pid][tableName] then
    	print("[playertables.lua] Warning: Table '" .. tableName .. "' does not exist.")
    	return false
  	end

  	local ret = self.tables[pid][tableName][key]
  	
  	return ret
end

function PlayerTables:GetAllTableValues(tableName, pid)
  	if not self.tables[pid][tableName] then
    	print("[playertables.lua] Warning: Table '" .. tableName .. "' does not exist.")
    	return false
  	end

  	local ret = self.tables[pid][tableName]
  	if type(ret) == "table" then
    	return self:copy(ret)
  	end
  	return ret
end

function PlayerTables:SetTableValue(tableName, key, value, pid, bAlwaysUpdate)
  	if value == nil then
    	self:DeleteTableKey(tableName, key)
    	return 
  	end

  	if not self.tables[pid][tableName] then
    	print("[playertables.lua] Warning: Table '" .. tableName .. "' does not exist.")
    	return
  	end

  	local table = self.tables[pid][tableName]

  	if bAlwaysUpdate or not self:equals(table[key], value) then
    	table[key] = value
  	end

  	CustomNetTables:SetTableValue("parsy", "player_" .. pid, self.tables[pid])
end

if not PlayerTables.tables then PlayerTables:start() end


if not ServerTables then
  	ServerTables = class({})
end

function ServerTables:start()
    self.tables = {}
    print("[playertables.lua] Start ServerTables")
end

function ServerTables:equals(o1, o2, ignore_mt)
    if o1 == o2 then return true end
    local o1Type = type(o1)
    local o2Type = type(o2)
    if o1Type ~= o2Type then return false end
    if o1Type ~= 'table' then return false end

    if not ignore_mt then
        local mt1 = getmetatable(o1)
        if mt1 and mt1.__eq then
            --compare using built in method
            return o1 == o2
        end
    end

    local keySet = {}

    for key1, value1 in pairs(o1) do
        local value2 = o2[key1]
        if value2 == nil or self:equals(value1, value2, ignore_mt) == false then
            return false
        end
        keySet[key1] = true
    end

    for key2, _ in pairs(o2) do
        if not keySet[key2] then return false end
    end
    return true
end

function ServerTables:copy(obj, seen)
  	if type(obj) ~= 'table' then return obj end
  	if seen and seen[obj] then return seen[obj] end

  	local s = seen or {}
  	local res = setmetatable({}, getmetatable(obj))

  	s[obj] = res

  	for k, v in pairs(obj) do 
  		res[self:copy(k, s)] = self:copy(v, s) 
  	end

  	return res
end

function ServerTables:CreateTable(tableName, tableContents)

	if self.tables[tableName] then
    	print("[servertables.lua] Warning: player table '" .. tableName .. "' already exists.  Overriding.")
  	end

  	self.tables[tableName] = tableContents

  	CustomNetTables:SetTableValue("gsro", "gsro", self.tables)
end

function ServerTables:DeleteTable(tableName)
  	if not self.tables[tableName] then
    	print("[servertables.lua] Warning: Table '" .. tableName .. "' does not exist.")
    	return
  	end

  	self.tables[tableName] = nil

  	CustomNetTables:SetTableValue("gsro", "gsro", self.tables)
end

function ServerTables:DeleteTableKey(tableName, key)
  	if not self.tables[tableName] then
    	print("[servertables.lua] Warning: Table '" .. tableName .. "' does not exist.")
    	return
  	end

  	local table = self.tables[tableName]

  	if table[key] ~= nil then
    	table[key] = nil
  	end

  	CustomNetTables:SetTableValue("gsro", "gsro", self.tables)
end

function ServerTables:GetTableValue(tableName, key)
  	if not self.tables[tableName] then
    	print("[servertables.lua] Warning: Table '" .. tableName .. "' does not exist.")
    	return false
  	end

  	local ret = self.tables[tableName][key]
  	
  	return ret
end

function ServerTables:GetAllTableValues(tableName)
  	if not self.tables[tableName] then
    	print("[servertables.lua] Warning: Table '" .. tableName .. "' does not exist.")
    	return false
  	end

  	local ret = self.tables[tableName]
  	if type(ret) == "table" then
    	return self:copy(ret)
  	end
  	return ret
end

function ServerTables:SetTableValue(tableName, key, value, bAlwaysUpdate)
  	if value == nil then
    	self:DeleteTableKey(tableName, key)
    	return 
  	end

  	if not self.tables[tableName] then
    	print("[servertables.lua] Warning: Table '" .. tableName .. "' does not exist.")
    	return
  	end

  	local table = self.tables[tableName]

  	if bAlwaysUpdate or not self:equals(table[key], value) then
    	table[key] = value
  	end

  	CustomNetTables:SetTableValue("gsro", "gsro", self.tables)
end

if not ServerTables.tables then ServerTables:start() end