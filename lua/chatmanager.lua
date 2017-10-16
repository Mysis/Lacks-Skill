local original_feed_system_message = ChatManager.feed_system_message
function ChatManager:feed_system_message(channel_id, message)
  if LacksSkill.kicked_by_ls ~= true then
    original_feed_system_message(self, channel_id, message)
  end
end