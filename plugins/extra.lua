----------------------------------------------------
--      ___  ___ _____            __   _____      --
--     |   \| _ )_   _|__ __ _ _ _\ \ / /_  )     --
--     | |) | _ \ | |/ -_) _` | '  \ V / / /      --
--     |___/|___/ |_|\___\__,_|_|_|_\_/ /___|     --
--                                                --
----------------------------------------------------
--extra.lua
--by @iicc1
-- missing translations

local function run_bash(str)
    local cmd = io.popen(str)
    local result = cmd:read('*all')
    return result
end

local api_key = nil
local base_api = "https://maps.googleapis.com/maps/api"
local function GetENCity(persianWord)
		if     persianWord == "تهران" then return "Tehran"
    	elseif persianWord == "مشهد" then return "Mashhad"
		end
end
	
local function get_latlong(area)
	local api      = base_api .. "/geocode/json?"
	local parameters = "address=".. (URL.escape(area) or "")
	if api_key ~= nil then
		parameters = parameters .. "&key="..api_key
	end
	local res, code = https.request(api..parameters)
	if code ~=200 then return nil  end
	local data = json:decode(res)
	if (data.status == "ZERO_RESULTS") then
		return nil
	end
	if (data.status == "OK") then
		lat  = data.results[1].geometry.location.lat
		lng  = data.results[1].geometry.location.lng
		acc  = data.results[1].geometry.location_type
		types= data.results[1].types
		return lat,lng,acc,types
	end
end

local function get_staticmap(area)
	local api        = base_api .. "/staticmap?"
	local lat,lng,acc,types = get_latlong(area)
	local scale = types[1]
	if scale == "locality" then
		zoom=8
	elseif scale == "country" then 
		zoom=4
	else 
		zoom = 13 
	end
	local parameters =
		"size=600x300" ..
		"&zoom="  .. zoom ..
		"&center=" .. URL.escape(area) ..
		"&markers=color:red"..URL.escape("|"..area)
	if api_key ~= nil and api_key ~= "" then
		parameters = parameters .. "&key="..api_key
	end
	return lat, lng, api..parameters
end
local function run(msg, matches)
	if matches[1] ==  "extra" and not msg.reply_id then	
		if matches[2] then
			if permissions(msg.from.id, msg.to.id, "mod_commands") then
				local extra = {}
				extra = { string.match(matches[2], "^[!/#](%S+) (.*)$") }
				addCommand(msg.to.id, extra)
			end
		else
			local list = "<b>Extra list in this chat:</b>\n"
			for command, text in pairs (redis:hgetall("extra".. msg.to.id)) do
				list = list .. "[#/!]" .. command .. "\n"
			end
			send_msg(msg.to.id, list, 'html')
		end
	elseif matches[1] ==  "اذان" then
		if matches[2] then
			city = GetENCity(matches[2])
		elseif not matches[2] then
			city = 'Tehran'
		end	
		local lat,lng,url	= get_staticmap(city)
		local dumptime = run_bash('date +%s')
		local code = http.request('http://api.aladhan.com/timings/'..dumptime..'?latitude='..lat..'&longitude='..lng..'&timezonestring=Asia/Tehran&method=7')
		local jdat = json:decode(code)
		local data = jdat.data.timings
		local text = 'شهر: '..city
		text = text..'\nاذان صبح: '..data.Fajr
		text = text..'\nطلوع آفتاب: '..data.Sunrise
		text = text..'\nاذان ظهر: '..data.Dhuhr
		text = text..'\nغروب آفتاب: '..data.Sunset
		text = text..'\nاذان مغرب: '..data.Maghrib
		text = text..'\nعشاء : '..data.Isha
		send_msg(msg.to.id, text, 'html')
	elseif matches[1] ==  "حدیث" then
		if matches[2] then
			local code = http.request('http://golden3.ir/bot/hadis.php?t=1&sub='..matches[2])
			send_msg(msg.to.id, code, 'html')
		elseif not matches[2] then
			local code = http.request('http://golden3.ir/bot/hadis.php?t=1')
			send_msg(msg.to.id, code, 'html')
		end
	elseif matches[1] ==  "extra" and  msg.reply_id then
		if permissions(msg.from.id, msg.to.id, "mod_commands") then
			get_msg_info(msg.to.id, msg.reply_id, infofile, matches[2])			
		end
	elseif matches[1] == "extradel" and matches[2] then
		if permissions(msg.from.id, msg.to.id, "mod_commands") then
			local extra = ''
			extra = string.match(matches[2], "^[!/#](%S+)$")
			if extra then
				redis:hdel("extra" .. msg.to.id, extra)
				send_msg(msg.to.id, "The command: [!/#]" .. extra .." <b>has been removed.</b>", 'html')
			else
				send_msg(msg.to.id, "<b>Error:</b> the extra command does not exist in this chat.", 'html')
			end
		end
	elseif matches[1] then
		for command, text in pairs (redis:hgetall("extra".. msg.to.id)) do
			if matches[1] == command then
				local data = redis:hget("extra".. msg.to.id, command)
				if string.find(data, "%$") then
					local extra = {}
					if string.find(data, "nil") then
						extra = {string.match(data, "^[%$](%S+) (%S+)")}
					else
						extra = {string.match(data, "^[%$](%S+) (%S+) (.*)")}
					end
					if extra[1] == "sticker" then
						sendSticker(msg.to.id, extra[2])
					elseif extra[1] == "photo" then
						sendPhoto(msg.to.id, extra[2], extra[3])	
					elseif extra[1] == "audio" then
						sendAudio(msg.to.id, extra[2], extra[3])
					elseif extra[1] == "voice" then
						sendVoice(msg.to.id, extra[2], extra[3])
					elseif extra[1] == "gif" then
						sendAnimation(msg.to.id, extra[2], extra[3])
					elseif extra[1] == "video" then
						sendVideo(msg.to.id, extra[2], extra[3])
					elseif extra[1] == "document" then
						sendDocument(msg.to.id, extra[2], extra[3])
					end
				else
					send_msg(msg.to.id, data, 'html')
				end
			end
		end
	end
end

function infofile(matches,msginfo)
	local data = {}
	data.message_ = msginfo
	msg = oldtg(data)
	if msg.file_id then
		if msg.sticker then
			local extra = {}
			extra = { string.match(matches, "^[!/#](%S+) (.*)$") }
			if not extra[1] then
				extra = { string.match(matches, "^[!/#](%S+)$") }
			end
			local persistent = "$sticker " .. msg.file_id
			addCommand(msg.to.id, extra, true, persistent)
		elseif msg.photo then
			local extra = {}
			extra = { string.match(matches, "^[!/#](%S+) (.*)$") }
			if not extra[1] then
				extra = { string.match(matches, "^[!/#](%S+)$") }
			end
			local persistent = "$photo " .. msg.file_id
			addCommand(msg.to.id, extra, true, persistent)		
		elseif msg.audio then
			local extra = {}
			extra = { string.match(matches, "^[!/#](%S+) (.*)$") }
			if not extra[1] then
				extra = { string.match(matches, "^[!/#](%S+)$") }
			end
			local persistent = "$audio " .. msg.file_id
			addCommand(msg.to.id, extra, true, persistent)		
		elseif msg.voice then
			local extra = {}
			extra = { string.match(matches, "^[!/#](%S+) (.*)$") }
			if not extra[1] then
				extra = { string.match(matches, "^[!/#](%S+)$") }
			end
			local persistent = "$voice " .. msg.file_id
			addCommand(msg.to.id, extra, true, persistent)		
		elseif msg.gif then
			local extra = {}
			extra = { string.match(matches, "^[!/#](%S+) (.*)$") }
			if not extra[1] then
				extra = { string.match(matches, "^[!/#](%S+)$") }
			end
			local persistent = "$gif " .. msg.file_id
			addCommand(msg.to.id, extra, true, persistent)		
		elseif msg.video then
			local extra = {}
			extra = { string.match(matches, "^[!/#](%S+) (.*)$") }
			if not extra[1] then
				extra = { string.match(matches, "^[!/#](%S+)$") }
			end
			local persistent = "$video " .. msg.file_id
			addCommand(msg.to.id, extra, true, persistent)		
		elseif msg.document then
			local extra = {}
			extra = { string.match(matches, "^[!/#](%S+) (.*)$") }
			if not extra[1] then
				extra = { string.match(matches, "^[!/#](%S+)$") }
			end
			local persistent = "$document " .. msg.file_id
			addCommand(msg.to.id, extra, true, persistent)
		end
	end	
end

function addCommand(chat_id, command, file, persistent)
	local pattern = command[1]
	local text = ''
	if file == true then
		if command[2] then
			text = persistent .. " " .. command[2]
		else
			text = persistent .. " nil"
		end
	else
		text = command[2]
	end
	print(pattern)
	if redis:hget("extra".. msg.to.id, pattern) then
		redis:hset("extra" .. msg.to.id, pattern, text)
	else
		redis:hset("extra" .. msg.to.id, pattern, text)
	end
	send_msg(msg.to.id, "<b>New command:</b> [#/!]" ..pattern.."\nThat sends:\n".. redis:hget("extra" .. msg.to.id, pattern) , 'html')
end

return {
        patterns = {
				"^[!/#](%S+) (.*)$",
				'^[!/#](azan) (.*)$',
				'^[!/#](اذان)$',
				"^[!/#](حدیث)$",
				"^[!/#](.*)$"				
				},
    run = run
}
