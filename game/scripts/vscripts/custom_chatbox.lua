FateChatBoxModule = FateChatBoxModule or class({})

function FateChatBoxModule:construct()
	print('Fate Chat Box Contruct!')
	CustomGameEventManager:RegisterListener("fate_chat_send", function(id, ...)
	    Dynamic_Wrap(self, "OnRecieveData")(self, ...) 
	end)

end

function FateChatBoxModule:OnRecieveData(arg)
	local playerId = arg.playerId
	local text = arg.text
	local team = arg.type

	if team == 2 then
		CustomGameEventManager:Send_ServerToAllClients( "fate_chat_display", {playerId=playerId, chattype=team, text=text} )
		CustomGameEventManager:Send_ServerToAllClients( "fate_chat_notify", {playerId=playerId} )
	elseif team == 1 then
		CustomGameEventManager:Send_ServerToTeam(PlayerResource:GetTeam(playerId), "fate_chat_display", {playerId=playerId, chattype=team, text=text})
		CustomGameEventManager:Send_ServerToTeam(PlayerResource:GetTeam(playerId), "fate_chat_notify", {playerId=playerId} )
	end
end

FateChatBoxModule.INITED = FateChatBoxModule.INITED or false
if not FateChatBoxModule.INITED then
	FateChatBoxModule():construct()
	FateChatBoxModule.INITED = true 
end

