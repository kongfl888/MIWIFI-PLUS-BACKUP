module ("yuneon.module.YNABOUT", package.seeall)

local YNFunction = require("yuneon.common.YNFunction")
local LuciUtil = require("luci.util")
local uci = require("luci.model.uci").cursor()

local YUNEONPATH = uci:get("yuneon", "miwifiplus", "path")

function aboutInfoGet()
	return uci:get("yuneon", "miwifiplus", "version")
end

function aboutMiwifiplusUpdate()
	os.execute("wget http://vv2.vicp.net/miwifi/update.sh -O /tmp/update.sh && chmod +x /tmp/update.sh")
	return os.execute("/tmp/update.sh") == 0
end

function aboutMiwifiplusRemove()
	os.execute("chmod +x " .. YUNEONPATH .. "/scripts/uninstall.sh")
	return os.execute(YUNEONPATH .. "/scripts/uninstall.sh") == 0
end