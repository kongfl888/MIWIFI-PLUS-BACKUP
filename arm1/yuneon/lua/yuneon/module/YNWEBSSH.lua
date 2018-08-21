module ("yuneon.module.YNWEBSSH", package.seeall)

local LuciUtil = require("luci.util")
local uci = require("luci.model.uci").cursor()
local YUNEONPATH = uci:get("yuneon", "miwifiplus", "path")

function infoGet()
	return switchGet()
end

function switchGet()
	local enable = tonumber(LuciUtil.exec("ps | grep 'shellinaboxd' | grep -Ecv 'grep'")) == 2 and 1 or 0
	return enable
end

function switchSet()
	local enable = switchGet();
	if enable == 1 then
		os.execute("ps|grep 'shellinaboxd' | grep -v 'grep' | awk '{print $1}' |xargs kill -9")
		os.execute("sleep 1s")
	else
		os.execute(YUNEONPATH.."/bin/shellinaboxd -tb --disable-utmp-logging >/dev/null 2>&1")
		os.execute("sleep 1s")
	end
end