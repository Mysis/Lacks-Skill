local original_spawn_dropin_player = HostNetworkSession._spawn_dropin_player
function HostNetworkSession:_spawn_dropin_player(peer)
  local peer_id = peer:id()
  local kick, kick_reason = LacksSkill:check_kick(peer_id)
  if kick then
    LacksSkill:kick_peer(peer_id, kick_reason)
  else
    original_spawn_dropin_player(self, peer)
  end
end

function LacksSkill:check_kick(peer_id)
  local peer = managers.network:session():peer(peer_id)
  local kick = false

  local peer_skills = {inspire = true, nine_lives = true, swan_song = true}
  local all_skills = LacksSkill:raw_skills_to_table(peer:skills())
  if all_skills[1] < 28 then
    peer_skills.inspire = false
  end
  if all_skills[14] < 4 then
    peer_skills.nine_lives = false
    if all_skills[14] < 12 then
      peer_skills.swan_song = false
    end
  end
  
  local kick_reason = {}
  local gamemode = LacksSkill:get_gamemode()
  if gamemode == "sm_wish" then
    if LacksSkill.settings.od_req_inspire and not peer_skills.inspire then
      kick = true
      table.insert(kick_reason, managers.localization:text("menu_inspire_beta"))
    end
    if LacksSkill.settings.od_req_nine_lives and not peer_skills.nine_lives then
      kick = true
      table.insert(kick_reason, managers.localization:text("menu_nine_lives_beta"))
    end
    if LacksSkill.settings.od_req_swan_song and not peer_skills.swan_song then
      kick = true
      table.insert(kick_reason, managers.localization:text("menu_perseverance_beta"))
    end
  elseif gamemode == "crime_spree" then
    if LacksSkill.settings.cs_req_inspire and not peer_skills.inspire then
      kick = true
      table.insert(kick_reason, managers.localization:text("menu_inspire_beta"))
    end
    if LacksSkill.settings.cs_req_nine_lives and not peer_skills.nine_lives then
      kick = true
      table.insert(kick_reason, managers.localization:text("menu_nine_lives_beta"))
    end
    if LacksSkill.settings.cs_req_swan_song and not peer_skills.swan_song then
      kick = true
      table.insert(kick_reason, managers.localization:text("menu_perseverance_beta"))
    end
  end
  
  return kick, kick_reason
end

function LacksSkill:kick_peer(peer_id, kick_reason)
  local session = managers.network:session()
  local peer = session:peer(peer_id)
  if peer then
    LacksSkill.kicked_by_ls = true
    local kick_message = peer:name() .. managers.localization:text("ls_kick_reason") .. kick_reason[1]
    table.remove(kick_reason, 1)
    while #kick_reason > 0 do
        kick_message = kick_message .. ", " .. kick_reason[1]
        table.remove(kick_reason, 1)
    end
    session:send_to_peers("kick_peer", peer:id(), 0)
    session:on_peer_kicked(peer, peer:id(), 0)
    LacksSkill:chat_message(kick_message, "ff0000")
    LacksSkill.kicked_by_ls = false
  end
end