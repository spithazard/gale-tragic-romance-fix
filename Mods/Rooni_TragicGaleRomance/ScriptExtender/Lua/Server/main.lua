local RESTORE = {
    clearFlagOn = nil,
    originalLetter = nil,
    shouldReset = false
}

-- If we're in the epilogue, register listeners and fix data
function OnSessionLoaded()
    Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", function(levelName, _)
        if levelName == "EPI_Main_A" then
            local tragicLover = LoveTragicallyCutShort()
            if (
                tragicLover ~= nil and 
                -- Don't do it if somehow it's already happened
                RESTORE.shouldReset == false
            ) then 
                FixGameData(tragicLover) 
            end
        end
    end)
end

---Checks for a tragic ending to Gale's romance
---@return string GUID of the avatar whose romance was tragically cut short,
--- or nil if no such avatar exists
function LoveTragicallyCutShort()
    local avatars = GetAvatars()
    local tragicLover = nil
    for _, avatar in pairs(avatars) do
        if (
            GetFlag(Const.GALE_EXPLODED_FLAG, avatar) == 1 and
            GetFlag(Const.GALE_VOLUNTEER_BLOWJOB, avatar) == 1 and
            GetFlag(Const.PARTNERED_WITH_GALE, avatar) == 1
        ) then
            tragicLover = avatar
            break
        end
    end
    return tragicLover
end

---Sets flag to enable kissing Gale's spectral form, and
---updates the letter to be the love letter instead of friend
---@param character string
function FixGameData(character)
    FixFlag(character)
    FixLetter()
end

---Undo changes when the game exits/level is unloaded
function RestoreOriginalGameData()
    if (RESTORE.shouldReset == true) then
        if (RESTORE.clearFlagOn ~= nil) then
            Osi.ClearFlag(Const.RELATIONSHIP_TRUNCATED_FLAG, RESTORE.clearFlagOn)
        end
        if (RESTORE.originalLetter ~= nil) then
            print(RESTORE.originalLetter)
            Ext.Loca.UpdateTranslatedString(Const.FRIEND_LETTER, RESTORE.originalLetter)
        end
    end
end

---Sets flag to enable kissing Gale's spectral form, and
---keeps track that we did
---@param character string
function FixFlag(character)
    if (GetFlag(Const.RELATIONSHIP_TRUNCATED_FLAG, character) ~= 1) then
        RESTORE.clearFlagOn = character
        RESTORE.shouldReset = true
        SetFlag(Const.RELATIONSHIP_TRUNCATED_FLAG, character)
    end
end

---Changes the letter to be the love letter by replacing the friend letter
---translated string with the love letter translated string
function FixLetter()
    -- Save initial letter loca to restore if changes are made
    RESTORE.shouldReset = true
    RESTORE.originalLetter = Ext.Loca.GetTranslatedString(Const.FRIEND_LETTER)
    local loveLetter = Ext.Loca.GetTranslatedString(Const.LOVE_LETTER)
    Ext.Loca.UpdateTranslatedString(Const.FRIEND_LETTER, loveLetter)
end

Ext.Events.ResetCompleted:Subscribe(OnSessionLoaded)

Ext.Events.SessionLoaded:Subscribe(OnSessionLoaded)
Ext.Events.GameStateChanged:Subscribe(function(e)
    if e.ToState == "UnloadLevel" then
        RestoreOriginalGameData()
    end
end)