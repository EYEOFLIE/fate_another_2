------------------------------------------------------------------------------
------------------- Made by ZeFiRoFT -----------------------------------------
--------------- ThousandLies have no RIGHT to use THIS!----------------
------------------------------------------------------------------------------

CaptSelection = CaptSelection or class({})
FATE_DEFAULT_MAX_PLAYERS_7v7 = 14
FATE_DEFAULT_MAX_PLAYERS_6v6 = 12

function CaptSelection:constructor()

	self.UnAssignTeam = {}
	self.UnVotePlayers = {}
	self.VotePoint = {}
	self.CaptPlayers = {}
	self.LeftTeam = {}
	self.RightTeam = {}
	self.PreVote1 = {}
	self.PreVote2 = {}
	self.PrePick = {}
	self.PickOrder = {}

	self.load_time = 5
	self.vote_time = 30 
	self.capt_display = 5
	self.pick_time = 30 
	self.standby_time = 10

	self.max_player = FATE_DEFAULT_MAX_PLAYERS_7v7
	if GetMapName() == "fate_elim_6v6" then 
		self.max_player = FATE_DEFAULT_MAX_PLAYERS_6v6
	end

	for i = 0, self.max_player - 1 do 
		if PlayerResource:IsValidPlayer(i) then
			table.insert(self.UnAssignTeam, i, i) 
			table.insert(self.UnVotePlayers, i, 2) 
			table.insert(self.VotePoint, i, 0) 

			if PlayerTables:GetTableValue("database", "db", i) == false then 
			    local asdio = iupoasldm
				asdio:initialize(i)
			end
		end
	end

	self.CaptVoteListener = CustomGameEventManager:RegisterListener("capt_vote", function(id, ...)
	    Dynamic_Wrap(self, "OnVote")(self, ...) 
	end)

	self.CaptPreVoteListener = CustomGameEventManager:RegisterListener("capt_pre_vote", function(id, ...)
	    Dynamic_Wrap(self, "OnPreVote")(self, ...) 
	end)

	self.PlayerPickListener = CustomGameEventManager:RegisterListener("capt_pick", function(id, ...)
	    Dynamic_Wrap(self, "OnPick")(self, ...) 
	end)

	self.PlayerPrePickListener = CustomGameEventManager:RegisterListener("capt_pre_pick", function(id, ...)
	    Dynamic_Wrap(self, "OnPrePick")(self, ...) 
	end)


	CustomNetTables:SetTableValue("captmode", "unassign", self.UnAssignTeam)
    CustomNetTables:SetTableValue("captmode", "unvote", self.UnVotePlayers)
    CustomNetTables:SetTableValue("captmode", "votepoint", self.VotePoint)
    CustomNetTables:SetTableValue("captmode", "prevote1", self.PreVote1)
    CustomNetTables:SetTableValue("captmode", "prevote2", self.PreVote2)
    CustomNetTables:SetTableValue("captmode", "captplayer", self.CaptPlayers)
    CustomNetTables:SetTableValue("captmode", "leftteam", self.LeftTeam)
    CustomNetTables:SetTableValue("captmode", "rightteam", self.RightTeam)
    CustomNetTables:SetTableValue("captmode", "prepick", self.PrePick)
    CustomNetTables:SetTableValue("captmode", "pickorder", self.PickOrder)

    CustomNetTables:SetTableValue("captmode", "gamephrase", {gamephrase = "load"})
	CustomNetTables:SetTableValue("captmode", "captmode", {capt = "capt"})