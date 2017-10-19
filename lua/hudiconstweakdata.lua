Hooks:PostHook(HudIconsTweakData, "init", "hudiconstweakdatainitposthook", function(self)
    self.stealth_icon = {
      texture = "guis/textures/pd2/cn_playstyle_stealth",
      texture_rect = {
        0,
        0,
        16,
        16
      }
    }
    
    self.loud_icon = {
      texture = "guis/textures/pd2/cn_playstyle_loud",
      texture_rect = {
        0,
        0,
        16,
        16
      }
    }
  end)

