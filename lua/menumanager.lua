_G.LacksSkill = _G.LacksSkill or {}
LacksSkill._path = ModPath
LacksSkill._data_path = SavePath .. "lacks_skill.txt"

LacksSkill.settings = {
  od_req_inspire = false,
  od_req_nine_lives = false,
  od_req_swan_song = false,
  cs_req_inspire = false,
  cs_req_nine_lives = false,
  cs_req_swan_song = false
}
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
    MenuCallbackHandler.LacksSkillODReqInspireAced = function(this, item)
      LacksSkill.settings.od_req_inspire = Utils:ToggleItemToBoolean(item)
    end
    MenuCallbackHandler.LacksSkillODReqNineLivesAced = function(this, item)
      LacksSkill.settings.od_req_nine_lives = Utils:ToggleItemToBoolean(item)
    end
    MenuCallbackHandler.LacksSkillODReqSwanSongAced = function(this, item)
      LacksSkill.settings.od_req_swan_song = Utils:ToggleItemToBoolean(item)
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

    MenuCallbackHandler.LacksSkillSave = function(this, item)
      LacksSkill:Save()
    end

    LacksSkill:Load()

    MenuHelper:LoadFromJsonFile(LacksSkill._path .. 'menu/main.json', LacksSkill, LacksSkill.settings)
    MenuHelper:LoadFromJsonFile(LacksSkill._path .. 'menu/onedown.json', LacksSkill, LacksSkill.settings)
    MenuHelper:LoadFromJsonFile(LacksSkill._path .. 'menu/crimespree.json', LacksSkill, LacksSkill.settings)
  end)

function LacksSkill:system_message(message, colorstring)
  managers.chat:_receive_message(1, "[LS]", message, Color(colorstring))
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

function LacksSkill:get_gamemode()
    if Global.game_settings.gamemode == GamemodeCrimeSpree.id then
        return "crime_spree"
    else
        return Global.game_settings.difficulty
    end
end


