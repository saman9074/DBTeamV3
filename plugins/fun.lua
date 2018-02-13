--[[
-- Translate text using Google Translate.
-- http://translate.google.com/translate_a/single?client=t&ie=UTF-8&oe=UTF-8&hl=en&dt=t&tl=en&sl=auto&text=hello
--]]
do
	local json = require('cjson')
--requests = require('requests')--
	http = require("socket.http")
	local https = require 'ssl.https'
	

function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

function send_ID_by_reply(channel_id, message_id)
    get_msg_info(channel_id, message_id, getID_by_reply_cb, false)
end
	
function getID_by_reply_cb(arg, msg)
		local f = io.open("./data/id_" .. msg.chat_id_ .. ".txt", "w")
                	f:write(msg.sender_user_id_)
					f:close()
end
	
	
function sleep(n)
  os.execute("sleep " .. tonumber(n))
end
	
local function run_bash(str)
    local cmd = io.popen(str)
    local result = cmd:read('*all')
    return result
end	
function translate(source_lang, target_lang, text)
  local path = "http://translate.google.com/translate_a/single"
  -- URL query parameters
  local params = {
    client = "t",
    ie = "UTF-8",
    oe = "UTF-8",
    hl = "en",
    dt = "t",
    tl = target_lang or "en",
    sl = source_lang or "auto",
    text = URL.escape(text)
  }

  local query = format_http_params(params, true)
  local url = path..query

  local res, code = https.request(url)
  -- Return nil if error
  if code > 200 then return nil end
  local trans = res:gmatch("%[%[%[\"(.*)\"")():gsub("\"(.*)", "")

  return trans
end


local function run(msg, matches)
    if matches[1] == "tr" and matches[2] then
		reply_msg(msg.to.id,msg,msg.id, 'md')
	--[[elseif matches[1] == "eli" and matches[2] then
 				local url = "http://api.program-o.com/v2/chatbot/?bot_id=15&say="..matches[2].."&convo_id=".. msg.from.first_name .. "_" .. msg.id .. "&format=json"
  				local b,c = http.request(url)
				if c ~= 200 then return nil end
				local tab = json.decode(b)
				reply_msg(msg.to.id,tab['botsay'],msg.id, 'md')
	elseif matches[1] == "will" and matches[2] then
 				local url = "http://api.program-o.com/v2/chatbot/?bot_id=10&say="..matches[2].."&convo_id=".. msg.from.first_name .. "_" .. msg.id .. "&format=json"
  				local b,c = http.request(url)
				if c ~= 200 then return nil end
				local tab = json.decode(b)
				reply_msg(msg.to.id,tab['botsay'],msg.id, 'md')
	elseif matches[1] == "pr" and matches[2] then
				tdcli.sendChatAction(msg.to.id, 'Typing',100, dl_cb, nil)
 				local url = "http://api.program-o.com/v2/chatbot/?bot_id=6&say="..matches[2].."&convo_id=".. msg.from.first_name .. "_" .. msg.id .. "&format=json"
  				local b,c = http.request(url)
				if c ~= 200 then return nil end
				local tab = json.decode(b)
				reply_msg(msg.to.id,tab['botsay'],msg.id, 'md')
	elseif matches[1] == "ch" and matches[2] then
			    
 				tdcli.sendChatAction(msg.to.id, 'Typing',100, dl_cb, nil)
				local url = "http://api.program-o.com/v2/chatbot/?bot_id=12&say="..matches[2].."&convo_id=".. msg.from.first_name .. "_" .. msg.id .. "&format=json"
  				local b,c = http.request(url)
				if c ~= 200 then return nil end
				local tab = json.decode(b)
				reply_msg(msg.to.id, tab['botsay'],msg.id, 'md')]]--
	elseif matches[1] == "ali" and matches[2] then
				tdcli.sendChatAction(msg.to.id, 'Typing',100, dl_cb, nil)
				local url = "http://api.golden3.ir/chatbot/chatbot/conversation_start.php?bot_id=1&say=" .. matches[2] .. "&convo_id=userid_" .. msg.id
  				local b,c = http.request(url)
				if c ~= 200 then return nil end
				local tab = json.decode(b)
				reply_msg(msg.to.id, tab['botsay'],msg.id, 'md')
	elseif matches[1] == "voice" and matches[2] then
				tdcli.sendChatAction(msg.to.id, 'RecordVideo',100, dl_cb, nil)
				local url = "http://api.golden3.ir/chatbot/chatbot/conversation_start.php?bot_id=1&say=" .. matches[2] .. "&convo_id=userid_" .. msg.id
  				local b,c = http.request(url)
				if c ~= 200 then return nil end
				local tab = json.decode(b)			
				local url2 = "http://tts.baidu.com/text2audio?lan=en&ie=UTF-8&text=" .. tab['botsay']
			
				--local file = download_to_file(url,'BD-UniQue.mp3')--
				local vcdf = download_to_file(url2,'BD-UniQue.mp3')	
				sendAudio(msg.to.id, vcdf, "hi")
 				--tdcli.sendDocument(msg.to.id, 0, 0, 1, nil, vcdf, '@BeyondTeam', dl_cb, nil)--			
	elseif matches[1] == "علی" and matches[2] then
				tdcli.sendChatAction(msg.to.id, 'Typing',100, dl_cb, nil)
				local url = "http://api.golden3.ir/chatbot/chatbot/conversation_start.php?bot_id=4&say=" .. matches[2] .. "&convo_id=userid_" .. msg.id
  				local b,c = http.request(url)
				if c ~= 200 then return nil end
				local tab = json.decode(b)
				reply_msg(msg.to.id, tab['botsay'],msg.id, 'md')
	elseif matches[1] == "wiki" or matches[1] == "ویکی" and matches[2] ~= nil then
				if matches[2] == "fa" or matches[2] == "فارسی" and matches[3] then
					tdcli.sendChatAction(msg.to.id, 'UploadDocument',100, dl_cb, nil)
					local url = "http://api.golden3.ir/decoder/wiki.php?titles=" .. matches[3] .. "&lang=fa"
					local t,c = https.request(url)
					if c ~= 200 then return nil end
					local dec = htmlEntities.decode(t)
					hd = '<html><head><meta charset="UTF-8"></head> <body dir="rtl">'
					local f = io.open("./data/userid_" .. msg.id .. "_" .. matches[3] ..  ".html", "w")
                	f:write(hd)
					f:close()			
					local f = io.open("./data/userid_" .. msg.id .. "_" .. matches[3] ..  ".html", "a+")
                	f:write(dec .. '</body> </html>')
					f:close()										
					send_document_reply(msg.to.id, './data/userid_' .. msg.id .. "_" .. matches[3] ..  '.html', msg.id)
					sleep(4)
					run_bash("rm ./data/userid_" .. msg.id .. "_" .. matches[3] .. ".html")
				else
					tdcli.sendChatAction(msg.to.id, 'UploadDocument',100, dl_cb, nil)
					local url = "http://api.golden3.ir/decoder/wiki.php?titles=" .. matches[3] .. "&lang=" .. matches[2]
					local t,c = https.request(url)
					if c ~= 200 then return nil end
					local dec = htmlEntities.decode(t)
					hd = '<html><head><meta charset="UTF-8"></head> <body dir="ltr">'
					local f = io.open("./data/userid_" .. msg.id .. "_" .. matches[3] ..  ".html", "w")
                	f:write(hd)
					f:close()			
					local f = io.open("./data/userid_" .. msg.id .. "_" .. matches[3] ..  ".html", "a+")
                	f:write(dec .. '</body> </html>')
					f:close()										
				    send_document_reply(msg.to.id, './data/userid_' .. msg.id .. "_" .. matches[3] ..  '.html',msg.id)
					sleep(4)
					run_bash("rm ./data/userid_" .. msg.id .. "_" .. matches[3] .. ".html")
				end	
	
		elseif matches[1] == "جوک" then
				tdcli.sendChatAction(msg.to.id, 'Typing',100, dl_cb, nil)
				local url = "http://api.golden3.ir/chatbot/chatbot/conversation_start.php?bot_id=2&say=" .. matches[1] .. "&convo_id=userid_" .. msg.id
  				local b,c = http.request(url)
				if c ~= 200 then return nil end
				local tab = json.decode(b)
				reply_msg(msg.to.id, tab['botsay'],msg.id, 'md')
		elseif matches[1] == "mob" then
				if matches[2] and matches[3] and matches [4] then
					tdcli.sendChatAction(msg.to.id, 'Typing',100, dl_cb, nil)			
					local url = "http://api.golden3.ir/decoder/mob.php?device=" .. matches[2] .. "&n=" .. matches[3] .. "&brand=" .. matches[4] 
					local t,c = http.request(url)
					if c ~= 200 then return nil end
					local dec = htmlEntities.decode(t)
					reply_msg(msg.to.id, dec,msg.id, "md")
				elseif matches[2] and matches[3] and not matches [4] then
					tdcli.sendChatAction(msg.to.id, 'Typing',100, dl_cb, nil)			
					local url = "http://api.golden3.ir/decoder/mob.php?device=" .. matches[2] .. "&n=" .. matches[3]
					local t,c = http.request(url)
					if c ~= 200 then return nil end
					local dec = htmlEntities.decode(t)
					reply_msg(msg.to.id, dec,msg.id, "md")
				elseif matches[2] and not matches[3] and not matches [4] then
					tdcli.sendChatAction(msg.to.id, 'Typing',100, dl_cb, nil)			
					local url = "http://api.golden3.ir/decoder/mob.php?device=" .. matches[2] .. "&n=0"
					local t,c = http.request(url)
					if c ~= 200 then return nil end
					local dec = htmlEntities.decode(t)
					reply_msg(msg.to.id, dec,msg.id, "md")								
				end
		--elseif matches[1] == "ip" then--
			

			
		--[[elseif msg.reply_id then
			send_ID_by_reply(msg.to.id, msg.reply_id) 
			local file = "./data/id_" .. msg.to.id .. ".txt"
			local restoreVariables = nil
			local fileHandle = io.open (file, 'r')
			restoreVariables = fileHandle:read()
			fileHandle.close()		
			if restoreVariables == "360630346" then
				if matches[1] == "جوک" then
					local url = "http://api.golden3.ir/chatbot/chatbot/conversation_start.php?bot_id=2&say=" .. matches[1] .. "&convo_id=userid_" .. msg.id
  					local b,c = http.request(url)
					if c ~= 200 then return nil end
					local tab = json.decode(b)
					reply_msg(msg.to.id, tab['botsay'],msg.id, 'md')
				elseif matches[1] then
					local url = "http://api.golden3.ir/chatbot/chatbot/conversation_start.php?bot_id=1&say=" .. matches[1] .. "&convo_id=userid_" .. msg.id
  					local b,c = http.request(url)
					if c ~= 200 then return nil end
					local tab = json.decode(b)
					reply_msg(msg.to.id, tab['botsay'],msg.id, 'md')
				end
		     	run_bash("rm ./data/id*")
		   end]]--
    end
end

return {
  patterns = {
     '^[!/#](tr) (.*)$',
	 '^(eli) (.*)$',
	 '^(will) (.*)$',
	 '^(pr) (.*)$',
	 '^(voice) (.*)$',
	 '^([Aa]li) (.*)$',
	 '^(ip)$',
	 '^(mob) (.*)$',
	 '^(mob) (.*) (.*)$',
	 '^(mob) (.*) (.*) (.*)$',
	-- '^(علی) (.*)$',--
	 '^(جوک)$',			
     '^(wiki) (.*) (.*)$',
	 '^(ویکی) (.*) (.*)$',
	 '^(.*)$'

  }, 
  run = run 
}
end
