_G.LacksSkill = _G.LacksSkill or {}
LacksSkill._path = ModPath
LacksSkill._data_path = SavePath .. "lacks_skill.txt"

LacksSkill.settings = {
  show_disclaimer = true,
  
  broadcast_info = true,
  broadcast_warning = true,
  
  od_enabled = false,
  od_req_inspire = false,
  od_req_nine_lives = false,
  od_req_swan_song = false,
  od_stealth_kick = 1,
  
  cs_enabled = false,
  cs_req_inspire = false,
  cs_req_nine_lives = false,
  cs_req_swan_song = false,
  cs_stealth_kick = 1
}
LacksSkill.previous_dropin_option = nil
LacksSkill.ignore_kick = false
LacksSkill.kicked_by_ls = false

function LacksSkill:Load()
  local file = io.open(self._data_path, "r")
  if file then
    for k, v in pairs(json.decode(file:read('*all')) or {}) do
      self.settings[k] = v
    end
    file:close()
  end
end

function LacksSkill:Save()
  local file = io.open(self._data_path, 'w+')
  if file then
    file:write(json.encode(self.settings))
    file:close()
  end
end

Hooks:Add('LocalizationManagerPostInit', 'LocalizationManagerPostInit_LacksSkill', function(loc)
    for _, filename in pairs(file.GetFiles(LacksSkill._path .. 'loc/')) do
      local str = filename:match('^(.*).txt$')
      if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
        loc:load_localization_file(LacksSkill._path .. 'loc/' .. filename)
        break
      end
    end
    loc:load_localization_file(LacksSkill._path .. 'loc/english.json', false)
  end)

Hooks:Add('MenuManagerInitialize', 'MenuManagerInitialize_LacksSkill', function(menu_manager)
    
    MenuCallbackHandler.LacksSkillBroadcastInfo = function(this, item)
      LacksSkill.settings.broadcast_info = Utils:ToggleItemToBoolean(item)
    end
    MenuCallbackHandler.LacksSkillBroadcastWarning = function(this, item)
      LacksSkill.settings.broadcast_warning = Utils:ToggleItemToBoolean(item)
    end
    
    MenuCallbackHandler.LacksSkillODEnabled = function(this, item)
      LacksSkill.settings.od_enabled = Utils:ToggleItemToBoolean(item)
    end
    MenuCallbackHandler.LacksSkillODReqInspireAced = function(this, item)
      LacksSkill.settings.od_req_inspire = Utils:ToggleItemToBoolean(item)
    end
    MenuCallbackHandler.LacksSkillODReqNineLivesAced = function(this, item)
      LacksSkill.settings.od_req_nine_lives = Utils:ToggleItemToBoolean(item)
    end
    MenuCallbackHandler.LacksSkillODReqSwanSongAced = function(this, item)
      LacksSkill.settings.od_req_swan_song = Utils:ToggleItemToBoolean(item)
    end
    MenuCallbackHandler.LacksSkillODStealthKick = function(this, item)
      LacksSkill.settings.od_stealth_kick = item:value()
    end

    MenuCallbackHandler.LacksSkillCSEnabled = function(this, item)
      LacksSkill.settings.cs_enabled = Utils:ToggleItemToBoolean(item)
    end
    MenuCallbackHandler.LacksSkillCSReqInspireAced = function(this, item)
      LacksSkill.settings.cs_req_inspire = Utils:ToggleItemToBoolean(item)
    end
    MenuCallbackHandler.LacksSkillCSReqNineLivesAced = function(this, item)
      LacksSkill.settings.cs_req_nine_lives = Utils:ToggleItemToBoolean(item)
    end
    MenuCallbackHandler.LacksSkillCSReqSwanSongAced = function(this, item)
      LacksSkill.settings.cs_req_swan_song = Utils:ToggleItemToBoolean(item)
    end
    MenuCallbackHandler.LacksSkillCSStealthKick = function(this, item)
      LacksSkill.settings.cs_stealth_kick = item:value()
    end
    
    MenuCallbackHandler.LacksSkillChangedFocus = function(node, focus)
      if LacksSkill.settings.show_disclaimer then
        QuickMenu:new(managers.localization:text("ls_disclaimer_title"), managers.localization:text("ls_disclaimer_content"), {}, true)
        LacksSkill.settings.show_disclaimer = false
      end
    end

    MenuCallbackHandler.LacksSkillSave = function(this, item)
      LacksSkill:Save()
    end

    LacksSkill:Load()

    MenuHelper:LoadFromJsonFile(LacksSkill._path .. 'menu/main.json', LacksSkill, LacksSkill.settings)
    MenuHelper:LoadFromJsonFile(LacksSkill._path .. 'menu/onedown.json', LacksSkill, LacksSkill.settings)
    MenuHelper:LoadFromJsonFile(LacksSkill._path .. 'menu/crimespree.json', LacksSkill, LacksSkill.settings)
  end)

function LacksSkill:chat_message(message, infotype, private)
  log(infotype)
  local color
  log(tostring(private))
  if infotype == "kick" then
    log("kick")
    if private == nil then private = not LacksSkill.settings.broadcast_info end
    color = "ff0000"
  elseif infotype == "warning" then
    if private == nil then private = not LacksSkill.settings.broadcast_warning end
    log("warning")
    color = "ff7f00"
  else
    if private == nil then private = true end
    color = "ff0000"
  end
  log(tostring(private))
  managers.chat:_receive_message(1, "[LS]", message, Color(color), private and "stealth_icon" or "loud_icon")
  if not private then
    if Network:is_server() and LacksSkill.settings.broadcast_info then
      for key, peer in pairs(managers.network:session():peers()) do
        if peer then
          peer:send("send_chat_message", ChatManager.GAME, "[LS]: " .. message)
        end
      end
    end
  end
end

function LacksSkill:raw_skills_to_table(skillstring)
  local skillperkstringtable = string.split(skillstring, "-")
  local skillstringtable = string.split(skillperkstringtable[1], "_")
  local skilltable = {}
  for k, v in ipairs(skillstringtable) do
    skilltable[k] = tonumber(v)
  end
  return skilltable
end

function LacksSkill:skills_to_string(skilltable)
  local result = ""
  for i = 0, 4 do
    result = result .. "("
    for j = 1, 3 do
      result = result .. skilltable[i*3+j]
      if j ~= 3 then
        result = result .. "|"
      end
    end
    result = result .. ")"
  end
  return result
end

function LacksSkill:raw_skills_to_string(skillstring)
  result = LacksSkill:skills_to_string(LacksSkill:raw_skills_to_table(skillstring))
  return result
end

function LacksSkill:gamemode()
  if Global.game_settings.gamemode == GamemodeCrimeSpree.id then
      return "crime_spree"
  else
      return Global.game_settings.difficulty
  end
end

function LacksSkill:enabled()
  local gamemode = LacksSkill:gamemode()
  if (gamemode == "sm_wish" and LacksSkill.settings.od_enabled) or (gamemode == "crime_spree" and LacksSkill.settings.cs_enabled) then
    return true
  else
    return false
  end
end

