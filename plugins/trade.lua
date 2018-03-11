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

--js = (loadfile "js.lua")() -- one-time load of the routines



local function run(msg, matches)
	if matches[1] ==  "btcz" and not matches[2] then	
		local code = http.request('http://golden3.ir/bot/trade.php?t=1')		
				send_msg(msg.to.id, "قیمت بیتکوین زد: "..code, 'md')
	elseif matches[1] ==  "trade" and matches[2] then
			local code = http.request('http://golden3.ir/bot/trade.php?t=2&c='..matches[2])		
				send_msg(msg.to.id,"قیمت " .. matches[2].. ": " .. code, 'md')
	elseif matches[1] ==  "coins" and not matches[2] then
			local code = http.request('http://golden3.ir/bot/trade.php?t=3')		
				send_msg(msg.to.id,code, 'md')
	elseif matches[1] ==  "coin" and matches[2] then
			local code = http.request('http://golden3.ir/bot/trade.php?t=4&c='..matches[2])		
				send_msg(msg.to.id,code, 'md')
	
	end
end


return {
        patterns = {
				"^[!/#](trade) (.*)$",
				"^[!/#](coin) (.*)$",
				"^[!/#](coins) (.*)$",
				"^[!/#](btcz)$",
				"^[!/#](coins)$",
				"^[!/#](.*)$"				
				},
    run = run
}
