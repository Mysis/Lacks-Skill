local original_spawn_dropin_player = HostNetworkSession._spawn_dropin_player
function HostNetworkSession:_spawn_dropin_player(peer)
  if LacksSkill:enabled() then
    local peer_id = peer:id()
    local kick, kick_reason = LacksSkill:check_kick(peer_id)
    if kick and LacksSkill.ignore_kick ~= true then
      LacksSkill:kick_peer(peer_id, kick_reason)
    else
      original_spawn_dropin_player(self, peer)
    end
  else
    original_spawn_dropin_player(self, peer)
  end
end

Hooks:PreHook(HostNetworkSession, "chk_spawn_member_unit", "chkspawnmemberunitprehook", function(self, peer, peer_id)
    if LacksSkill:enabled() and (managers.groupai and managers.groupai:state():whisper_mode() or Global.game_settings.job_plan == 2) then
      LacksSkill.previous_dropin_option = Global.game_settings.drop_in_option
      if LacksSkill:gamemode() == "sm_wish" then
        if LacksSkill.settings.od_stealth_kick == 1 then
          Global.game_settings.drop_in_option = 1
          LacksSkill.ignore_kick = true
        elseif LacksSkill.settings.od_stealth_kick == 2 then
          Global.game_settings.drop_in_option = 2
        end
      elseif LacksSkill:gamemode() == "crime_spree" then
        if LacksSkill.settings.cs_stealth_kick == 1 then
          Global.game_settings.drop_in_option = 1
          LacksSkill.ignore_kick = true
        elseif LacksSkill.settings.cs_stealth_kick == 2 then
          Global.game_settings.drop_in_option = 2
        else
        end
      end
    end
  end)

Hooks:PostHook(HostNetworkSession, "chk_spawn_member_unit", "chkspawnmemberunitposthook", function(self, peer, peer_id)
    if LacksSkill.previous_dropin_option then
      Global.game_settings.drop_in_option = LacksSkill.previous_dropin_option
    end
    LacksSkill.ignore_kick = false
  end)

Hooks:PreHook(HostNetworkSession, "_add_waiting", "addwaitingprehook", function(self, peer)
    if LacksSkill:enabled() then
      local kick, kick_reason = LacksSkill:check_kick(peer:id())
      if kick then
        LacksSkill:chat_message(peer:name() .. managers.localization:text("ls_warning") .. LacksSkill:kick_reason_to_string(kick_reason), "warning")
      end
    end
  end)

function LacksSkill:check_kick(peer_id)
  local peer = managers.network:session():peer(peer_id)
  local kick = false

  local peer_skills = {inspire = true, nine_lives = true, swan_song = true, nine_and_swan = true}
  local all_skills = LacksSkill:raw_skills_to_table(peer:skills())
  if all_skills[1] < 28 then
    peer_skills.inspire = false
  end
  if all_skills[14] < 12 then
    peer_skills.swan_song = false
    if all_skills[14] < 4 then
      peer_skills.nine_lives = false
    end
  elseif all_skills[14] == 14 then
    peer_skills.nine_and_swan = false
  end
  
  local kick_reason = {}
  local gamemode = LacksSkill:gamemode()
  if gamemode == "sm_wish" then
    if LacksSkill.settings.od_req_inspire and not peer_skills.inspire then
      kick = true
      table.insert(kick_reason, managers.localization:text("menu_inspire_beta"))
    end
    if LacksSkill.settings.od_req_nine_lives and LacksSkill.settings.od_req_swan_song and not peer_skills.nine_and_swan then
      kick = true
      table.insert(kick_reason, managers.localization:text("menu_nine_lives_beta"))
      table.insert(kick_reason, managers.localization:text("menu_perseverance_beta"))
    else
      if LacksSkill.settings.od_req_nine_lives and not peer_skills.nine_lives then
        kick = true
        table.insert(kick_reason, managers.localization:text("menu_nine_lives_beta"))
      end
      if LacksSkill.settings.od_req_swan_song and not peer_skills.swan_song then
        kick = true
        table.insert(kick_reason, managers.localization:text("menu_perseverance_beta"))
      end
    end
  elseif gamemode == "crime_spree" then
    if LacksSkill.settings.cs_req_inspire and not peer_skills.inspire then
      kick = true
      table.insert(kick_reason, managers.localization:text("menu_inspire_beta"))
    end
    if LacksSkill.settings.cs_req_nine_lives and LacksSkill.settings.cs_req_swan_song and not peer_skills.nine_and_swan then
      kick = true
      table.insert(kick_reason, managers.localization:text("menu_nine_lives_beta"))
      table.insert(kick_reason, managers.localization:text("menu_perseverance_beta"))
    else
      if LacksSkill.settings.cs_req_nine_lives and not peer_skills.nine_lives then
        kick = true
        table.insert(kick_reason, managers.localization:text("menu_nine_lives_beta"))
      end
      if LacksSkill.settings.cs_req_swan_song and not peer_skills.swan_song then
        kick = true
        table.insert(kick_reason, managers.localization:text("menu_perseverance_beta"))
      end
    end
  end
  
  return kick, kick_reason
end

function LacksSkill:kick_peer(peer_id, kick_reason)
  local session = managers.network:session()
  local peer = session:peer(peer_id)
  if peer then
    LacksSkill.kicked_by_ls = true
    local kick_message = peer:name() .. managers.localization:text("ls_kick_reason") .. LacksSkill:kick_reason_to_string(kick_reason)
    session:send_to_peers("kick_peer", peer:id(), 0)
    session:on_peer_kicked(peer, peer:id(), 0)
    LacksSkill:chat_message(kick_message, "kick")
    LacksSkill.kicked_by_ls = false
  end
end

function LacksSkill:kick_reason_to_string(kick_reason)
  local str = kick_reason[1]
  table.remove(kick_reason, 1)
  while #kick_reason > 0 do
      str = str .. ", " .. kick_reason[1]
      table.remove(kick_reason, 1)
  end
  return str
end