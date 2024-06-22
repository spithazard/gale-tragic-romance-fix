--Returns a table with all avatars present
--@return table list of all avatar GUIDs
function GetAvatars()
    local avatar_list = {} 
    local avatars = Osi.DB_Avatars:Get(nil)
    for _, avatar in pairs(avatars) do
        table.insert(avatar_list, avatar[1])
    end
    return avatar_list
end
