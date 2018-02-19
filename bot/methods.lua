serpent = require("serpent")

--json = (loadfile "./libs/JSON.lua")()


function download_to_file(url, file_name)
  -- print to server
  -- print("url to download: "..url)
  -- uncomment if needed
  local respbody = {}
  local options = {
    url = url,
    sink = ltn12.sink.table(respbody),
    redirect = true
}

  -- nil, code, headers, status
  local response = nil

  if url:starts('https') then
    options.redirect = false
    response = {https.request(options)}
  else
    response = {http.request(options)}
  end

  local code = response[2]
  local headers = response[3]
  local status = response[4]

  if code ~= 200 then return nil end

  file_name = file_name or get_http_file_name(url, headers)

  local file_path = "data/"..file_name
  -- print("Saved to: "..file_path)
	-- uncomment if needed
  file = io.open(file_path, "w+")
  file:write(table.concat(respbody))
  file:close()

  return file_path
end


-- DEPRECATED!!!!!
function string.starts(String, Start)
  -- print("string.starts(String, Start) is DEPRECATED use string:starts(text) instead")
  -- uncomment if needed
  return Start == string.sub(String,1,string.len(Start))
end

-- Returns true if String starts with Start
function string:starts(text)
  return text == string.sub(self,1,string.len(text))
end



function dl_cb (arg, data)
    vardump (data)
end

function vardump(value, depth, key)
    local linePrefix = ""
    local spaces = ""

    if key ~= nil then
        linePrefix = "["..key.."] = "
    end

    if depth == nil then
        depth = 0
    else
        depth = depth + 1
        for i=1, depth do spaces = spaces .. "  " end
    end

    if type(value) == 'table' then
        mTable = getmetatable(value)
        if mTable == nil then
            print(spaces ..linePrefix.."(table) ")
        else
            print(spaces .."(metatable) ")
            value = mTable
        end
        for tableKey, tableValue in pairs(value) do
            vardump(tableValue, depth, tableKey)
        end
    elseif type(value)  == 'function' or type(value) == 'thread' or type(value) == 'userdata' or value == nil then
        print(spaces..tostring(value))
    else
        print(spaces..linePrefix.."("..type(value)..") "..tostring(value))
    end
end

function ok_cb(extra, success, result)

end

function oldtg(data)
    if data.message then
        local msg = {}
        msg.to = {}
        msg.from = {}
        msg.replied = {}
        msg.to.id = data.message.chat_id
        msg.from.id = data.message.sender_user_id
        if data.message.content._ == "messageText" then
            msg.text = data.message.content.text
            if #data.message.content.entities ~= 0 then
                for k, v in ipairs (data.message.content.entities) do
                    if v.url_ then
                        msg.text = msg.text .. " url: " .. v.url_
                    end
                end
            end
        end
        if data.message.content.caption then
            msg.text = data.message.content.caption
        end
        msg.date = data.message.date
        msg.id = data.message.id
        msg.unread = false
        if data.message.reply_to_message_id == 0 then
            msg.reply_id = false
        else
            msg.reply_id = data.message.reply_to_message_id
        end
        if data.message.content._ == "messagePhoto" then
            msg.photo = true
    		if data.message.content.photo.sizes[3] then 
    			msg.file_id = data.message.content.photo.sizes[3].photo.persistent_id
    		else
    			msg.file_id = data.message.content.photo.sizes[0].photo.persistent_id
    		end
        else
            msg.photo = false
        end
        if data.message.content._ == "messageSticker" then
            msg.sticker = true
    		msg.file_id = data.message.content.sticker.sticker.persistent_id
        else
            msg.sticker = false
        end
        if data.message.content._ == "messageAudio" then
            msg.audio = true
    		msg.file_id = data.message.content.audio.audio.persistent_id
        else
            msg.audio = false
        end
        if data.message.content._ == "messageVoice" then
            msg.voice = true
    		msg.file_id = data.message.content.voice.voice.persistent_id
        else
            msg.voice = false
        end
        if data.message.content._ == "messageAnimation" then
            msg.gif = true
    		msg.file_id = data.message.content.animation.animation.persistent_id
        else
            msg.gif = false
        end
        if data.message.content._ == "messageVideo" then
            msg.video = true
    		msg.file_id = data.message.content.video.video.persistent_id
        else
            msg.video = false
        end
        if data.message.content._ == "messageDocument" then
            msg.document = true
    		msg.file_id = data.message.content.document.document.persistent_id
        else
            msg.document = false
        end
        if data.message.content._ == "MessageGame" then
            msg.game = true
        else
            msg.game = false
        end
    	if data.message.forward_info then
    		msg.forward = true
    		msg.forward = {}
    		msg.forward.from_id = data.message.forward_info.sender_user_id
    		msg.forward.msg_id = data.message.forward_info.data
    	else
    		msg.forward = false
    	end
        if data.message.content._ then
            msg.action = data.message.content._
        end
        if data.message.content._ == "messageChatAddMembers" or data.message.content._ == "messageChatDeleteMember" or
            data.message.content._ == "messageChatChangeTitle" or data.message.content._ == "messageChatChangePhoto" or
            data.message.content._ == "messageChatJoinByLink" or data.message.content._ == "messageGameScore" then
            msg.service = true
        else
            msg.service = false
        end
        local new_members = data.message.content.members
        if new_members then
            msg.added = {}
            for i = 0, #new_members, 1 do
                k = i+1
                msg.added[k] = {}
                msg.added[k].id = new_members[i].id
                if new_members[i].username then
                    msg.added[k].username = new_members[i].username
                else
                    msg.added[k].username = false
                end
                msg.added[k].first_name = new_members[i].first_name
                if new_members[i].last_name then
                    msg.added[k].last_name = new_members[i].last_name
                else
                    msg.added[k].last_name = false
                end
            end
        end
        return msg
    end
    return data
end

function user_data(msg, data)
    if data.username then
        msg.from.username = data.username
    else
        msg.from.username = false
    end
    msg.from.first_name = data.first_name
    if data.last_name then
        msg.from.last_name = data.last_name
    else
        msg.from.last_name = false
    end
    if msg.action == "messageChatJoinByLink" then
        msg.added = {}
        msg.added[1] = {}
        msg.added[1].id = msg.from.id
        msg.added[1].username = msg.from.username
        msg.added[1].first_name = msg.from.fist_name
        msg.added[1].last_name = msg.from.last_name
    end
    return msg
end

function reply_data(msg, data)
    if data.username then
        msg.replied.username = data.username
    end
    msg.replied.first_name = data.first_name
    if data.last_name then
        msg.replied.last_name = data.last_name
    end
    return msg
end

function return_media(msg)
    if msg.photo then
        return "MessagePhoto"
    elseif msg.sticker then
        return "MessageSticker"
    elseif msg.audio then
        return "MessageAudio"
    elseif msg.voice then
        return "MessageVoice"
    elseif msg.gif then
        return "MessageAnimation"
    elseif msg.text then
        return "MessageText"
    elseif msg.service then
        return "MessageService"
    elseif msg.video then
        return "MessageVideo"
    elseif msg.document then
        return "MessageDocument"
    elseif msg.game then
        return "MessageGame"
    end
end

function serialize_to_file(data, file, uglify)
    file = io.open(file, 'w+')
    local serialized
    if not uglify then
        serialized = serpent.block(data, {
            comment = false,
            name = '_'
        })
    else
        serialized = serpent.dump(data)
    end
    file:write(serialized)
    file:close()
end

-- Returns a table with matches or nil
function match_pattern(pattern, text, lower_case)
    if text then
        local matches = {}
        if lower_case then
            matches = { string.match(text:lower(), pattern) }
        else
            matches = { string.match(text, pattern) }
        end
        if next(matches) then
            return matches
        end
    end
    -- nil
end

function get_receiver(msg)
    return msg.to.id

end

function getChatId(chat_id)
    local chat = {}
    local chat_id = tostring(chat_id)

    if chat_id:match('^-100') then
        local channel_id = chat_id:gsub('-100', '')
        chat = {ID = channel_id, type = 'channel'}
    else
        local group_id = chat_id:gsub('-', '')
        chat = {ID = group_id, type = 'group'}
    end

    return chat
end

function set_text(lang, keyword, text)
    local hash = 'lang:'..lang..':'..keyword
    redis:set(hash, text)
end

function is_mod(chat_id, user_id)
    return redis:sismember('mods:'..chat_id, user_id)
end

function is_admin(user_id)
    return redis:sismember('admins', user_id)
end

function is_gban(user_id)
    return redis:sismember('gbans', user_id)
end

function new_is_sudo(user_id)
    local var = false
    -- Check users id in config
    for v,user in pairs(_config.sudo_users) do
        if user == user_id then
            var = true
        end
    end
    return var
end

function lang_text(chat_id, keyword)
    local hash = 'langset:'..chat_id
    local lang = redis:get(hash)
    if not lang then
        redis:set(hash,'en')
        lang = redis:get(hash)
    end
    local hashtext = 'lang:'..lang..':'..keyword
    if redis:get(hashtext) then
        return redis:get(hashtext)
    else
        return 'Please, install your selected "'..lang..'" language by #install [`archive_name(english_lang, spanish_lang...)`]. First, active your language package like a normal plugin by it\'s name. For example, #plugins enable `english_lang`. Or set another one by typing #lang [language(en, es...)].'
    end

end

function is_number(name_id)
    if tonumber(name_id) then
        return true
    else
        return false
    end
end

function no_markdown(text, replace)
    if text then
        text = tostring(text)
        if replace then
            text = text:gsub("`", replace)
            text = text:gsub("*", replace)
            text = text:gsub("_", replace)
            return text
        end
        text = text:gsub("`", "")
        text = text:gsub("*", "")
        text = text:gsub("_", "")
        return text
    end
    return false
end

function send_large_msg(chat_id, text)
    local text_len = string.len(text)
    local text_max = 4096
    local times = text_len/text_max
    local text = text
    for i = 1, times, 1 do
        local text = string.sub(text, 1, 4096)
        local rest = string.sub(text, 4096, text_len)
        local destination = chat_id
        local num_msg = math.ceil(text_len / text_max)
        if num_msg <= 1 then
            send_msg(destination, text, 'md')
        else
        text = rest
    end
  end
end

function scandir(directory)
    local i, t, popen = 0, {}, io.popen
    for filename in popen('ls -a "'..directory..'"'):lines() do
        i = i + 1
        t[i] = filename
    end
    return t
end

function plugins_names( )
    local files = {}
    for k, v in pairs(scandir("plugins")) do
        -- Ends with .lua
        if (v:match(".lua$")) then
            table.insert(files, v)
        end
    end
    return files
end

function langs_names( )
    local files = {}
    for k, v in pairs(scandir("lang")) do
        -- Ends with .lua
        if (v:match(".lua$")) then
            table.insert(files, v)
        end
    end
    return files
end

function get_multimatch_byspace(str, regex, cut)
    list = {}
    for wrd in str:gmatch("%S+") do
        if (regex and wrd:match(regex)) then
            table.insert(list, wrd:sub(wrd:find(regex)+cut))
        elseif (not regex) then
            table.insert(list, wrd)
        end
    end
    if (#list > 0) then
        return list
    end
    return false
end

function trim(text)
    local chars_tmp = {}
    local chars_m = {}
    local final_str = ""
    local text_arr = {}
    local ok = false
    local i
    for i=1, #text do
        table.insert(chars_tmp, text:sub(i, i))
    end
    i=1
    while(chars_tmp[i]) do
        if tostring(chars_tmp[i]):match('%S') then
            table.insert(chars_m, chars_tmp[i])
            ok = true
        elseif ok == true then
            table.insert(chars_m, chars_tmp[i])
        end
        i=i+1
    end
    i=#chars_m
    ok=false
    while(chars_m[i]) do
        if tostring(chars_m[i]):match('%S') then
            table.insert(text_arr, chars_m[i])
            ok = true
        elseif ok == true then
            table.insert(text_arr, chars_m[i])
        end
        i=i-1
    end
    for i=#text_arr, 1, -1 do
        final_str = final_str..text_arr[i]
    end
    return final_str
end

function underline(text, underline_spaces)
  local chars = {}
  local text_str = ""
  local symbol = trim(" ̲")
  for i=1, #text do
      table.insert(chars, text:sub(i, i))
  end
  for i=1, #chars do
      space = chars[i] == ' '
      if (not space) then
          text_str = text_str..chars[i]..symbol
      elseif (underline_spaces) then
          text_str = text_str..chars[i]..symbol
      else
          text_str = text_str..chars[i]
      end
  end
  return text_str
end

function up_underline(text, underline_spaces)
  local chars = {}
  local text_str = ""
  local symbol = trim(" ̅ ")
  for i=1, #text do
      table.insert(chars, text:sub(i, i))
  end
  for i=1, #chars do
      space = chars[i] == ' '
      if (not space) then
          text_str = text_str..chars[i]..symbol
      elseif (underline_spaces) then
          text_str = text_str..chars[i]..symbol
      else
          text_str = text_str..chars[i]
      end
  end
  return text_str
end

function strike_out(text, underline_spaces)
  local chars = {}
  local text_str = ""
  local symbol = trim(" ̶")
  for i=1, #text do
      table.insert(chars, text:sub(i, i))
  end
  for i=1, #chars do
      space = chars[i] == ' '
      if (not space) then
          text_str = text_str..chars[i]..symbol
      elseif (underline_spaces) then
          text_str = text_str..chars[i]..symbol
      else
          text_str = text_str..chars[i]
      end
  end
  return text_str
end
