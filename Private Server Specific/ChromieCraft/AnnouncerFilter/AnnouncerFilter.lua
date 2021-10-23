local function bgQueueAnnouncerFilter(self, event, msg)
    return msg:find("BG Queue Announcer")
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", bgQueueAnnouncerFilter)
